"""
JSON File Comparison Utility

This module provides functionality to compare two JSON files and report differences.
It performs deep comparison of nested structures and provides detailed difference reports
with enhanced employee information for payroll data.
"""

import json
import os
import re
from typing import Any, Dict, List
from datetime import datetime


class JSONFileComparator:
    """Utility class for comparing JSON files and generating difference reports."""
    
    def __init__(self):
        self.differences = []
        self.compare_and_get_detailed_difference: Dict[str, Any] = {
            "comparison_mode": "position_based",
            "missing_in_pre_ids": [],
            "missing_in_post_ids": [],
        }
        self._pre_employee_lookup: Dict[str, Dict[str, Any]] = {}
        self._post_employee_lookup: Dict[str, Dict[str, Any]] = {}
        self._employee_lookup_cache_key: tuple[int, int] | None = None
    
    def compare_json_files(
        self,
        pre_file: str | None = None,
        post_file: str | None = None,
        **legacy_paths: str,
    ) -> Dict[str, Any]:
        """
        Compare two JSON files and return enhanced comparison results.
        
        Args:
            pre_file (str): Path to the first JSON file (pre-recompute data)
            post_file (str): Path to the second JSON file (post-recompute data)
            
        Returns:
            Dict containing:
                - match (bool): True if files are identical, False otherwise
                - differences (list): List of differences if files don't match
                - difference_report (str): Formatted difference report with employee info
                - error (str): Error message if comparison fails
        """
        try:
            # Reset differences for new comparison
            self.differences = []
            self.compare_and_get_detailed_difference = {
                "comparison_mode": "position_based",
                "missing_in_pre_ids": [],
                "missing_in_post_ids": [],
            }
            self._pre_employee_lookup = {}
            self._post_employee_lookup = {}
            self._employee_lookup_cache_key = None

            if pre_file is None:
                pre_file = legacy_paths.pop("file1_path", None)
            if post_file is None:
                post_file = legacy_paths.pop("file2_path", None)
            if pre_file is None or post_file is None:
                raise ValueError("Both pre_file and post_file are required")
            
            # Load JSON files
            pre_data = self._load_json_file(pre_file)
            post_data = self._load_json_file(post_file)
            
            # Compare the data. For employee payloads, compare by employee_id first
            # to avoid false diffs from ordering/index shifts.
            if self._is_employee_list(pre_data) and self._is_employee_list(post_data):
                self._compare_employee_aligned_lists(pre_data, post_data)
            else:
                self._compare_values(pre_data, post_data, "root")
            
            # Determine if files match
            files_match = len(self.differences) == 0
            
            # Generate enhanced difference report with employee data
            difference_report = self._generate_enhanced_difference_report_with_employee_data(pre_data, post_data) if not files_match else ""
            
            return {
                "match": files_match,
                "differences": self.differences.copy(),
                "difference_report": difference_report,
                "comparison_mode": self.compare_and_get_detailed_difference["comparison_mode"],
                "missing_in_pre_ids": self.compare_and_get_detailed_difference["missing_in_pre_ids"],
                "missing_in_post_ids": self.compare_and_get_detailed_difference["missing_in_post_ids"],
                "error": None
            }
            
        except Exception as e:
            return {
                "match": False,
                "differences": [],
                "difference_report": "",
                "comparison_mode": self.compare_and_get_detailed_difference["comparison_mode"],
                "missing_in_pre_ids": self.compare_and_get_detailed_difference["missing_in_pre_ids"],
                "missing_in_post_ids": self.compare_and_get_detailed_difference["missing_in_post_ids"],
                "error": str(e)
            }

    def _is_employee_list(self, payload: Any) -> bool:
        """Return True when payload looks like list[dict] with employee_id."""
        if not isinstance(payload, list) or not payload:
            return False
        for item in payload:
            if not isinstance(item, dict):
                return False
            if "employee_id" not in item:
                return False
        return True

    def _compare_employee_aligned_lists(self, pre_data: List[Dict[str, Any]], post_data: List[Dict[str, Any]]) -> None:
        """Compare by employee_id first, then field-level for common employees."""
        self.compare_and_get_detailed_difference["comparison_mode"] = "employee_id_aligned"

        pre_index = {str(item.get("employee_id")): item for item in pre_data if item.get("employee_id") is not None}
        post_index = {str(item.get("employee_id")): item for item in post_data if item.get("employee_id") is not None}
        self._pre_employee_lookup = pre_index
        self._post_employee_lookup = post_index
        self._employee_lookup_cache_key = (id(pre_data), id(post_data))

        pre_ids = set(pre_index.keys())
        post_ids = set(post_index.keys())
        missing_in_post_ids = sorted(pre_ids - post_ids)
        missing_in_pre_ids = sorted(post_ids - pre_ids)

        self.compare_and_get_detailed_difference["missing_in_pre_ids"] = missing_in_pre_ids
        self.compare_and_get_detailed_difference["missing_in_post_ids"] = missing_in_post_ids

        for employee_id in missing_in_pre_ids:
            self.differences.append(
                {
                    "path": f"root.employee[{employee_id}]",
                    "type": "missing_employee_in_pre",
                    "employee_id": employee_id,
                    "value1": None,
                    "value2": post_index.get(employee_id),
                }
            )

        for employee_id in missing_in_post_ids:
            self.differences.append(
                {
                    "path": f"root.employee[{employee_id}]",
                    "type": "missing_employee_in_post",
                    "employee_id": employee_id,
                    "value1": pre_index.get(employee_id),
                    "value2": None,
                }
            )

        common_ids = sorted(pre_ids & post_ids)
        for employee_id in common_ids:
            pre_record = pre_index[employee_id]
            post_record = post_index[employee_id]
            self._compare_employee_records(pre_record, post_record, employee_id)

    def _compare_employee_records(self, pre_record: Dict[str, Any], post_record: Dict[str, Any], employee_id: str) -> None:
        """Compare all fields for one employee record."""
        all_keys = set(pre_record.keys()) | set(post_record.keys())
        all_keys.discard("employee_id")

        for field in sorted(all_keys):
            path = f"root.employee[{employee_id}].{field}"
            if field not in pre_record:
                self.differences.append(
                    {
                        "path": path,
                        "type": "missing_key_in_file1",
                        "employee_id": employee_id,
                        "value1": None,
                        "value2": post_record[field],
                    }
                )
            elif field not in post_record:
                self.differences.append(
                    {
                        "path": path,
                        "type": "missing_key_in_file2",
                        "employee_id": employee_id,
                        "value1": pre_record[field],
                        "value2": None,
                    }
                )
            else:
                self._compare_values(pre_record[field], post_record[field], path)
    
    def _load_json_file(self, file_path: str) -> Any:
        """Load and parse JSON file."""
        # Normalize and validate file path
        file_path = os.path.abspath(os.path.normpath(file_path))

        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")
        
        with open(file_path, 'r', encoding='utf-8') as file:
            return json.load(file)
    
    def _compare_values(self, val1: Any, val2: Any, path: str) -> None:
        """Recursively compare two values and record differences."""
        if type(val1) != type(val2):
            self.differences.append({
                "path": path,
                "type": "type_mismatch",
                "value1": f"{type(val1).__name__}: {val1}",
                "value2": f"{type(val2).__name__}: {val2}"
            })
            return
        
        if isinstance(val1, dict):
            self._compare_dictionaries(val1, val2, path)
        elif isinstance(val1, list):
            self._compare_lists(val1, val2, path)
        else:
            if val1 != val2:
                self.differences.append({
                    "path": path,
                    "type": "value_difference",
                    "value1": val1,
                    "value2": val2
                })
    
    def _compare_dictionaries(self, dict1: Dict, dict2: Dict, path: str) -> None:
        """Compare two dictionaries."""
        all_keys = set(dict1.keys()) | set(dict2.keys())
        
        for key in all_keys:
            current_path = f"{path}.{key}" if path != "root" else key
            
            if key not in dict1:
                self.differences.append({
                    "path": current_path,
                    "type": "missing_key_in_file1",
                    "value1": None,
                    "value2": dict2[key]
                })
            elif key not in dict2:
                self.differences.append({
                    "path": current_path,
                    "type": "missing_key_in_file2",
                    "value1": dict1[key],
                    "value2": None
                })
            else:
                self._compare_values(dict1[key], dict2[key], current_path)
    
    def _compare_lists(self, list1: List, list2: List, path: str) -> None:
        """Compare two lists."""
        if len(list1) != len(list2):
            self.differences.append({
                "path": path,
                "type": "list_length_difference",
                "value1": f"length: {len(list1)}",
                "value2": f"length: {len(list2)}"
            })
        
        min_length = min(len(list1), len(list2))
        for i in range(min_length):
            current_path = f"{path}[{i}]"
            self._compare_values(list1[i], list2[i], current_path)
        
        # Handle extra elements in longer list
        if len(list1) > len(list2):
            for i in range(len(list2), len(list1)):
                self.differences.append({
                    "path": f"{path}[{i}]",
                    "type": "extra_element_in_file1",
                    "value1": list1[i],
                    "value2": None
                })
        elif len(list2) > len(list1):
            for i in range(len(list1), len(list2)):
                self.differences.append({
                    "path": f"{path}[{i}]",
                    "type": "extra_element_in_file2",
                    "value1": None,
                    "value2": list2[i]
                })
    
    def _generate_enhanced_difference_report_with_employee_data(self, pre_data, post_data) -> str:
        """Generate enhanced difference report with complete employee context."""
        if not self.differences:
            return "No differences found."

        summary_metrics = self._build_difference_summary_metrics(pre_data, post_data)
        max_variation_summary = "N/A"
        if summary_metrics["max_variation"]:
            max_item = summary_metrics["max_variation"]
            max_variation_summary = (
                f"employee={max_item['employee_id']} field={max_item['field']} "
                f"delta={max_item['delta']:.4f} abs_delta={max_item['abs_delta']:.4f} "
                f"pre={max_item['pre_value']} post={max_item['post_value']}"
            )

        missing_messages: List[str] = []
        for employee_id in self.compare_and_get_detailed_difference["missing_in_pre_ids"]:
            missing_messages.append(
                f"Employee {employee_id} missing in Pre-Recompute; present only in Post-Recompute"
            )
        for employee_id in self.compare_and_get_detailed_difference["missing_in_post_ids"]:
            missing_messages.append(
                f"Employee {employee_id} missing in Post-Recompute; present only in Pre-Recompute"
            )
        
        report_lines = [
            f"Payroll Recompute Comparison Report - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "=" * 100,
            f"Comparison mode: {self.compare_and_get_detailed_difference['comparison_mode']}",
            (
                "Missing in Pre-Recompute (only in post): "
                f"{len(self.compare_and_get_detailed_difference['missing_in_pre_ids'])}"
            ),
            (
                "Missing in Post-Recompute (only in pre): "
                f"{len(self.compare_and_get_detailed_difference['missing_in_post_ids'])}"
            ),
            f"Total differences found: {len(self.differences)}",
            ""
        ]
        
        for i, diff in enumerate(self.differences, 1):
            # Extract employee data for context
            employee_context = self._get_employee_context(diff['path'], pre_data, post_data)
            
            report_lines.extend([
                f"Difference {i}:",
                "-" * 50
            ])
            
            if employee_context:
                report_lines.extend([
                    f"  Employee ID: {employee_context['employee_id']}",
                    f"  Field Changed: {employee_context['field']}",
                    f"  Pre-Recompute:   {employee_context['pre_value']} ",
                    f"  Post-Recompute:  {employee_context['post_value']}",
                    f"  Change:          {employee_context['change_description']}",
                    ""
                ])
                
                # Show complete employee record for context
                if employee_context.get('pre_record') and employee_context.get('post_record'):
                    report_lines.extend([
                        "  Complete Employee Data:",
                        f"     Before: {employee_context['pre_record']}",
                        f"     After:  {employee_context['post_record']}",
                        ""
                    ])
            else:
                # Fallback to original format for non-employee data
                report_lines.extend([
                    f"  Path: {diff['path']}",
                    f"  Type: {diff['type']}",
                    f"  Pre-Recompute:  {diff['value1']}",
                    f"  Post-Recompute: {diff['value2']}",
                    ""
                ])
        
        return "\n".join(report_lines)

    def _build_difference_summary_metrics(self, pre_data: Any, post_data: Any) -> Dict[str, Any]:
        """Build aggregate metrics for failures and variation ranges."""
        type_counts: Dict[str, int] = {}
        value_difference_employee_ids = set()
        missing_employee_ids = set()
        variation_buckets = {"0-1": 0, "1-5": 0, "5-10": 0, "10+": 0}
        max_variation = None

        for diff in self.differences:
            diff_type = str(diff.get("type", ""))
            type_counts[diff_type] = type_counts.get(diff_type, 0) + 1

            employee_id = diff.get("employee_id")
            if employee_id:
                employee_id = str(employee_id)

            if diff_type in {"missing_employee_in_pre", "missing_employee_in_post"} and employee_id:
                missing_employee_ids.add(employee_id)

            employee_context = self._get_employee_context(diff.get("path", ""), pre_data, post_data)

            if diff_type == "value_difference":
                if employee_id is None and employee_context:
                    employee_id = str(employee_context.get("employee_id", "Unknown"))

                if employee_id:
                    value_difference_employee_ids.add(employee_id)

                numeric_delta = self._extract_numeric_delta(diff.get("value1"), diff.get("value2"))
                if numeric_delta is not None:
                    abs_delta = abs(numeric_delta)
                    if abs_delta < 1:
                        variation_buckets["0-1"] += 1
                    elif abs_delta < 5:
                        variation_buckets["1-5"] += 1
                    elif abs_delta < 10:
                        variation_buckets["5-10"] += 1
                    else:
                        variation_buckets["10+"] += 1

                    field_name = "N/A"
                    if employee_context:
                        field_name = str(employee_context.get("field", "N/A"))
                    elif "." in str(diff.get("path", "")):
                        field_name = str(diff.get("path", "")).split(".")[-1]

                    candidate_employee = employee_id or "Unknown"
                    if max_variation is None or abs_delta > max_variation["abs_delta"]:
                        max_variation = {
                            "employee_id": candidate_employee,
                            "field": field_name,
                            "pre_value": diff.get("value1"),
                            "post_value": diff.get("value2"),
                            "delta": numeric_delta,
                            "abs_delta": abs_delta,
                        }

        return {
            "type_counts": type_counts,
            "value_difference_employee_ids": value_difference_employee_ids,
            "missing_employee_ids": missing_employee_ids,
            "variation_buckets": variation_buckets,
            "max_variation": max_variation,
        }

    def _extract_numeric_delta(self, value1: Any, value2: Any) -> float | None:
        """Return numeric delta when both values are numeric-like, otherwise None."""
        try:
            number1 = float(value1)
            number2 = float(value2)
            return number2 - number1
        except (TypeError, ValueError):
            return None

    def _ensure_employee_lookups(self, pre_data: Any, post_data: Any) -> None:
        """Build employee_id lookups once per input pair and reuse across diff processing."""
        if not isinstance(pre_data, list) or not isinstance(post_data, list):
            return

        cache_key = (id(pre_data), id(post_data))
        if self._employee_lookup_cache_key == cache_key:
            return

        self._pre_employee_lookup = {
            str(item.get("employee_id")): item
            for item in pre_data
            if isinstance(item, dict) and item.get("employee_id") is not None
        }
        self._post_employee_lookup = {
            str(item.get("employee_id")): item
            for item in post_data
            if isinstance(item, dict) and item.get("employee_id") is not None
        }
        self._employee_lookup_cache_key = cache_key

    def _get_employee_context(self, path: str, pre_data, post_data) -> dict:
        """Return employee diff context from path, including pre/post values and numeric delta when applicable.
            Example:
            path = "root.employee[3100603230].worked_duration"
            context = comparator._get_employee_context(path, pre_data, post_data)
            # context["employee_id"] -> "3100603230"
            # context["change_description"] -> "Delta +1.5000 (+3.21%)"
        """
        # Employee id aligned path style: root.employee[3100603230].worked_duration
        emp_match = re.match(r"^root\.employee\[([^\]]+)\]\.(.+)$", path)
        if emp_match and isinstance(pre_data, list) and isinstance(post_data, list):
            employee_id = emp_match.group(1)
            field = emp_match.group(2)

            self._ensure_employee_lookups(pre_data, post_data)
            pre_record = self._pre_employee_lookup.get(employee_id)
            post_record = self._post_employee_lookup.get(employee_id)
            if pre_record and post_record:
                pre_value = pre_record.get(field, "N/A")
                post_value = post_record.get(field, "N/A")

                change_description = ""
                if field in ["worked_duration", "actual_cost"]:
                    try:
                        pre_num = float(pre_value)
                        post_num = float(post_value)
                        diff_value = post_num - pre_num
                        change_description = f"Delta {diff_value:+.4f}"
                        if pre_num != 0:
                            percent_change = (diff_value / pre_num) * 100
                            change_description += f" ({percent_change:+.2f}%)"
                    except (ValueError, TypeError):
                        change_description = f"{pre_value} -> {post_value}"
                else:
                    change_description = f"{pre_value} -> {post_value}"

                return {
                    "employee_id": employee_id,
                    "field": field,
                    "pre_value": pre_value,
                    "post_value": post_value,
                    "change_description": change_description,
                    "pre_record": pre_record,
                    "post_record": post_record,
                }

        # Pattern to match list index and field: [0].worked_duration or root[0].field
        match = re.match(r'(?:root)?(\[(\d+)\])\.(.+)$', path)
        if not match:
            return None
        
        index = int(match.group(2))
        field = match.group(3) 
        
        try:
            # Get employee records
            pre_record = pre_data[index] if index < len(pre_data) else None
            post_record = post_data[index] if index < len(post_data) else None
            
            if pre_record and post_record:
                employee_id = pre_record.get('employee_id', 'Unknown')
                pre_value = pre_record.get(field, 'N/A')
                post_value = post_record.get(field, 'N/A')
                
                # Calculate change description
                change_description = ""
                if field in ['worked_duration', 'actual_cost']:
                    try:
                        pre_num = float(pre_value)
                        post_num = float(post_value)
                        diff_value = post_num - pre_num
                        change_description = f"Delta {diff_value:+.4f}"
                        
                        # Add percentage change for better insight
                        if pre_num != 0:
                            percent_change = (diff_value / pre_num) * 100
                            change_description += f" ({percent_change:+.2f}%)"
                        
                    except (ValueError, TypeError):
                        change_description = f"{pre_value} -> {post_value}"
                else:
                    change_description = f"{pre_value} -> {post_value}"
                
                return {
                    'employee_id': employee_id,
                    'field': field,
                    'pre_value': pre_value,
                    'post_value': post_value,
                    'change_description': change_description,
                    'pre_record': pre_record,
                    'post_record': post_record
                }
        except (IndexError, KeyError, TypeError):
            pass
        
        return None

    def _generate_difference_report(self) -> str:
        """Generate a basic formatted difference report (legacy method)."""
        if not self.differences:
            return "No differences found."
        
        report_lines = [
            f"JSON Comparison Report - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "=" * 80,
            f"Total differences found: {len(self.differences)}",
            ""
        ]
        
        for i, diff in enumerate(self.differences, 1):
            # Extract employee information if path contains list index
            employee_info = self._extract_employee_info(diff['path'], diff['value1'], diff['value2'])
            
            report_lines.extend([
                f"Difference {i}:",
                f"  Path: {diff['path']}"
            ])
            
            # Add employee information if available
            if employee_info:
                report_lines.append(f"  Employee: {employee_info}")
            
            report_lines.extend([
                f"  Type: {diff['type']}",
                f"  Pre-Recompute:  {diff['value1']}",
                f"  Post-Recompute: {diff['value2']}",
                ""
            ])
        
        return "\n".join(report_lines)

    def _extract_employee_info(self, path: str, value1, value2) -> str:
        """Extract employee information from the difference path and values (legacy method)."""
        # Check if path contains list index pattern like [0].field_name
        list_index_match = re.match(r'^(?:root)?(\[(\d+)\])\.(.+)$', path)
        
        if list_index_match:
            index = int(list_index_match.group(2))
            field = list_index_match.group(3)
            return f"Record {index + 1} -> {field}"
        
        return None


# Robot Framework compatible functions
def compare_json_files(
    pre_file: str | None = None,
    post_file: str | None = None,
    **legacy_paths: str,
) -> Dict[str, Any]:
    """
    Robot Framework compatible function to compare JSON files.
    
    Args:
        pre_file (str): Path to the first JSON file (pre-recompute data)
        post_file (str): Path to the second JSON file (post-recompute data)
        
    Returns:
        Dict with enhanced comparison results including employee information
    """
    comparator = JSONFileComparator()
    if pre_file is None:
        pre_file = legacy_paths.pop("file1_path", None)
    if post_file is None:
        post_file = legacy_paths.pop("file2_path", None)
    return comparator.compare_json_files(pre_file=pre_file, post_file=post_file)


def get_comparison_status(
    pre_file: str | None = None,
    post_file: str | None = None,
    **legacy_paths: str,
) -> str:
    """
    Get simple match/no match status for JSON file comparison.
    
    Args:
        pre_file (str): Path to the first JSON file
        post_file (str): Path to the second JSON file
        
    Returns:
        str: "Match" or "Not Match"
    """
    if pre_file is None:
        pre_file = legacy_paths.pop("file1_path", None)
    if post_file is None:
        post_file = legacy_paths.pop("file2_path", None)
    result = compare_json_files(pre_file=pre_file, post_file=post_file)
    if result.get("error"):
        return f"Error: {result['error']}"
    return "Match" if result["match"] else "Not Match"


def get_difference_report(
    pre_file: str | None = None,
    post_file: str | None = None,
    **legacy_paths: str,
) -> str:
    """
    Get detailed difference report for JSON file comparison with employee information.
    
    Args:
        pre_file (str): Path to the first JSON file (pre-recompute data)
        post_file (str): Path to the second JSON file (post-recompute data)
        
    Returns:
        str: Enhanced formatted difference report with employee context
    """
    if pre_file is None:
        pre_file = legacy_paths.pop("file1_path", None)
    if post_file is None:
        post_file = legacy_paths.pop("file2_path", None)
    result = compare_json_files(pre_file=pre_file, post_file=post_file)
    if result.get("error"):
        return f"Error: {result['error']}"
    return result["difference_report"] if not result["match"] else "Files are identical."


def _extract_file_type(file_path: str) -> str:
    """Return 'unit_pay_data' or 'ta_cost_segment_data' from the file path, or 'unknown'."""
    lower = file_path.lower()
    if "unit_pay_data" in lower:
        return "unit_pay_data"
    if "ta_cost_segment_data" in lower:
        return "ta_cost_segment_data"
    return os.path.splitext(os.path.basename(file_path))[0]


def _extract_employee_id_from_path(path: str) -> str | None:
    """Return employee ID string from a path like root.employee[3100602941]... or None."""
    match = re.match(r"^root\.employee\[([^\]]+)\]", path)
    if match:
        return match.group(1)
    return None


def _extract_field_from_path(path: str) -> str:
    """Return field name from a path like root.employee[3100602941].worked_duration."""
    match = re.match(r"^root\.employee\[[^\]]+\]\.([^\s]+)$", path)
    if match:
        return match.group(1)
    return "unknown_field"


def _extract_compact_source_prefix(file_path: str) -> str:
    """Return compact source prefix for message section output."""
    lower = file_path.lower()
    if "unit_pay_data" in lower:
        return "unit_pay"
    if "ta_cost_segment_data" in lower:
        return "cost_segment"
    if "ta_cost_diff_segment_data" in lower:
        return "cost_diff_segment"
    return "unknown"


def get_compact_difference_message(
    pre_file: str | None = None,
    post_file: str | None = None,
    **legacy_paths: str,
) -> str:
    """
    Get compact, diff-only message for Robot assertion output.

    Output format: one block per difference with Employee ID, Type, File,
    Pre-Recompute and Post-Recompute values.  Keeps log.html message sections clean.
    """
    if pre_file is None:
        pre_file = legacy_paths.pop("file1_path", None)
    if post_file is None:
        post_file = legacy_paths.pop("file2_path", None)

    result = compare_json_files(pre_file=pre_file, post_file=post_file)
    if result.get("error"):
        return f"Error: {result['error']}"
    if result.get("match"):
        return "Files are identical."

    differences = result.get("differences", [])
    if not differences:
        return "No differences found."

    source_prefix = _extract_compact_source_prefix(pre_file)

    lines: List[str] = []
    for diff in differences:
        path = diff.get("path", "")
        employee_id = _extract_employee_id_from_path(path) or path
        field_name = _extract_field_from_path(path)
        source_field = f"{source_prefix}_{field_name}"
        value1 = diff.get("value1")
        value2 = diff.get("value2")
        # For missing-employee diffs the values are full record dicts; use "present"/"absent" instead.
        diff_type = diff.get("type", "")
        if diff_type == "missing_employee_in_post":
            pre_display = "present"
            post_display = "absent"
            source_field = f"{source_prefix}_missing_emp"
        elif diff_type == "missing_employee_in_pre":
            pre_display = "absent"
            post_display = "present"
            source_field = f"{source_prefix}_missing_emp"
        else:
            pre_display = value1
            post_display = value2
        lines.append(f"Emp_ID-{employee_id}/{source_field}/Pre-{pre_display}/Post-{post_display}")

    return "\n".join(lines)


# Additional utility functions for enhanced reporting
def get_employee_summary_from_differences(
    pre_file: str | None = None,
    post_file: str | None = None,
    **legacy_paths: str,
) -> Dict[str, Any]:
    """
    Get summary of employees affected by differences in payroll recompute.
    
    Args:
        pre_file (str): Path to pre-recompute JSON file
        post_file (str): Path to post-recompute JSON file
        
    Returns:
        Dict containing summary statistics and affected employee list
    """
    if pre_file is None:
        pre_file = legacy_paths.pop("file1_path", None)
    if post_file is None:
        post_file = legacy_paths.pop("file2_path", None)

    result = compare_json_files(pre_file=pre_file, post_file=post_file)
    
    if result.get("error") or result["match"]:
        return {
            "affected_employees": [],
            "total_affected": 0,
            "fields_changed": [],
            "summary": "No differences found or error occurred"
        }
    
    # Analyze differences to extract employee impact
    affected_employees = set()
    fields_changed = set()
    
    comparator = JSONFileComparator()
    pre_data = comparator._load_json_file(pre_file)
    post_data = comparator._load_json_file(post_file)
    
    for diff in result["differences"]:
        employee_context = comparator._get_employee_context(
            diff["path"],
            pre_data,
            post_data,
        )
        if employee_context:
            affected_employees.add(employee_context["employee_id"])
            fields_changed.add(employee_context["field"])
    
    return {
        "affected_employees": list(affected_employees),
        "total_affected": len(affected_employees),
        "fields_changed": list(fields_changed),
        "total_differences": len(result["differences"]),
        "summary": f"{len(affected_employees)} employees affected with {len(result['differences'])} total changes"
    }
