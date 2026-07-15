#!/usr/bin/env python3
"""
Populate a suite's test data CSV file by copying test cases from source CSV files.
Only includes test cases marked as "Yes" in the suite column of wfm_sit_suites.csv.

Usage:
    python3 populate_suite_testdata.py <suite_name> [--source <source1> <source2> ...]

    OR (auto-detect sources from suite mapping)

    python3 populate_suite_testdata.py <suite_name> --auto

Examples:
    # Populate MORRISON.csv from VARIATION1 and BASE
    python3 populate_suite_testdata.py MORRISON --source VARIATION1 BASE

    # Auto-detect source files by checking which sources have most "Yes" values for this suite
    python3 populate_suite_testdata.py MORRISON --auto
"""

import csv
import sys
import os
from collections import defaultdict


def read_suite_mapping(suite_map_file, suite_name):
    """
    Read wfm_sit_suites.csv and return test cases marked as 'Yes' for the given suite.

    Returns:
        set: Test case IDs that should be included (marked as 'Yes')
    """
    if not os.path.exists(suite_map_file):
        print(f"❌ Error: Suite mapping file not found: {suite_map_file}")
        return set()

    with open(suite_map_file, "r") as f:
        reader = csv.DictReader(f)

        # Check if suite column exists
        if suite_name not in reader.fieldnames:
            print(f"❌ Error: Suite '{suite_name}' not found in {suite_map_file}")
            print(
                f"Available suites: {', '.join([f for f in reader.fieldnames if f != 'TAG'])}"
            )
            return set()

        # Collect test cases marked as Yes
        included_tests = set()
        for row in reader:
            if row[suite_name] == "Yes":
                included_tests.add(row["TAG"])

    return included_tests


def read_test_data_csv(file_path):
    """
    Read a test data CSV file and return rows as list of dicts.

    Returns:
        tuple: (header_row, data_rows_dict)
        where data_rows_dict is {test_case_id: [rows for that test case]}
    """
    if not os.path.exists(file_path):
        return None, None

    with open(file_path, "r") as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames

        # Group rows by SCOPE (test case ID)
        test_data = defaultdict(list)
        current_test_case = None

        for row in reader:
            scope = row["SCOPE"]

            # If scope starts with TC, it's a test case identifier
            if scope.startswith("TC"):
                current_test_case = scope

            # Store row under current test case
            if current_test_case:
                test_data[current_test_case].append(row)
            else:
                # GLOBAL scope rows
                test_data["GLOBAL"].append(row)

    return fieldnames, test_data


def auto_detect_sources(suite_map_file, suite_name, testdata_dir):
    """
    Auto-detect the best source CSV files by analyzing the suite mapping.
    Returns list of source file names (without .csv extension).
    """
    # Read suite mapping to see which suites have test cases
    with open(suite_map_file, "r") as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames

        # Count how many "Yes" values each suite has that match our target suite
        suite_overlap = defaultdict(int)

        for row in reader:
            if row[suite_name] == "Yes":
                # This test case is in our target suite
                # Check which other suites also have it
                for other_suite in fieldnames:
                    if other_suite != "TAG" and other_suite != suite_name:
                        if row[other_suite] == "Yes":
                            suite_overlap[other_suite] += 1

        # Sort by overlap count
        sorted_suites = sorted(suite_overlap.items(), key=lambda x: x[1], reverse=True)

        print("\n📊 Suite overlap analysis:")
        for suite, count in sorted_suites[:10]:  # Show top 10
            print(f"   {suite}: {count} common test cases")

        # Return top sources that have test data files
        sources = []
        for suite, count in sorted_suites:
            # Check if corresponding CSV file exists
            csv_path = os.path.join(testdata_dir, f"{suite}.csv")
            if os.path.exists(csv_path):
                sources.append(suite)
                if len(sources) >= 3:  # Limit to top 3 sources
                    break

        return sources


def get_all_testdata_files_priority_order(testdata_dir):
    """
    Get all test data CSV files in priority order.
    Priority: BASE, VARIATION1-7, then MOB_QA* files, then rest
    """
    priority_files = ["BASE"]

    # Add VARIATION1 through VARIATION7
    for i in range(1, 8):
        priority_files.append(f"VARIATION{i}")

    # Get all CSV files in testdata dir
    all_files = []
    if os.path.exists(testdata_dir):
        for file in os.listdir(testdata_dir):
            if file.endswith(".csv"):
                name = file[:-4]  # Remove .csv
                all_files.append(name)

    # Separate MOB_QA files and others
    mob_qa_files = [f for f in all_files if f.startswith("MOB_QA")]
    other_files = [
        f for f in all_files if f not in priority_files and not f.startswith("MOB_QA")
    ]

    # Combine in priority order
    return priority_files + sorted(mob_qa_files) + sorted(other_files)


def populate_suite_testdata(suite_name, source_files, testdata_dir, suite_map_file):
    """
    Main function to populate suite's test data CSV.

    Args:
        suite_name: Name of the target suite (e.g., MORRISON)
        source_files: List of source CSV file names (e.g., ['VARIATION1', 'BASE'])
        testdata_dir: Directory containing test data CSV files
        suite_map_file: Path to wfm_sit_suites.csv
    """
    # Read suite mapping to get included test cases
    print(f"\n📖 Reading suite mapping from {suite_map_file}")
    included_tests = read_suite_mapping(suite_map_file, suite_name)

    if not included_tests:
        print(f"❌ No test cases found for suite '{suite_name}'")
        return False

    print(f"✅ Found {len(included_tests)} test cases to include in {suite_name}")

    # Target file
    target_file = os.path.join(testdata_dir, f"{suite_name}.csv")

    # Read existing target file to preserve GLOBAL rows
    existing_global_rows = []
    if os.path.exists(target_file):
        print(f"\n📖 Reading existing {suite_name}.csv to preserve GLOBAL data...")
        fields, existing_data = read_test_data_csv(target_file)
        if existing_data and "GLOBAL" in existing_data:
            existing_global_rows = existing_data["GLOBAL"]
            print(
                f"   - Found {len(existing_global_rows)} existing GLOBAL rows (will be preserved)"
            )

    # Collect all test data
    all_test_data = defaultdict(list)

    # Preserve existing GLOBAL rows (don't merge from sources)
    if existing_global_rows:
        all_test_data["GLOBAL"] = existing_global_rows

    fieldnames = None

    # Read from source files
    for source in source_files:
        source_file = os.path.join(testdata_dir, f"{source}.csv")

        if not os.path.exists(source_file):
            print(f"⚠️  Warning: Source file not found: {source_file}")
            continue

        print(f"\n📖 Reading from {source}.csv...")
        fields, test_data = read_test_data_csv(source_file)

        if not fields or not test_data:
            print(f"⚠️  Warning: Could not read {source_file}")
            continue

        # Store fieldnames from first source
        if not fieldnames:
            fieldnames = fields

        # Skip GLOBAL rows - we preserve the target file's GLOBAL data
        # Only collect test case rows (only if in included_tests)
        test_cases_added = 0
        for test_case, rows in test_data.items():
            if test_case == "GLOBAL":
                continue

            if test_case in included_tests:
                # Only add if not already collected from another source
                if test_case not in all_test_data or len(all_test_data[test_case]) == 0:
                    all_test_data[test_case] = rows
                    test_cases_added += 1

        print(f"   - Added {test_cases_added} test cases from {source}")

    # Check which test cases are still missing
    found_tests = set(tc for tc in all_test_data.keys() if tc != "GLOBAL")
    missing_tests = included_tests - found_tests

    # If there are missing test cases, search through all test data files
    if missing_tests:
        print(
            f"\n🔍 Searching for {len(missing_tests)} missing test cases in other files..."
        )

        # Get all test data files in priority order
        all_priority_files = get_all_testdata_files_priority_order(testdata_dir)

        # Remove already processed sources and target suite
        remaining_files = [
            f
            for f in all_priority_files
            if f not in source_files and f != suite_name and f not in ["GLOBAL"]
        ]

        for source in remaining_files:
            if not missing_tests:
                break  # All found

            source_file = os.path.join(testdata_dir, f"{source}.csv")

            if not os.path.exists(source_file):
                continue

            fields, test_data = read_test_data_csv(source_file)

            if not fields or not test_data:
                continue

            # Store fieldnames from first source if not already set
            if not fieldnames:
                fieldnames = fields

            # Look for missing test cases in this file
            found_in_this_file = []
            for test_case in list(missing_tests):
                if test_case in test_data:
                    all_test_data[test_case] = test_data[test_case]
                    found_in_this_file.append(test_case)
                    missing_tests.remove(test_case)

            if found_in_this_file:
                print(
                    f"   ✅ Found {len(found_in_this_file)} test case(s) in {source}.csv"
                )
                for tc in found_in_this_file[:3]:  # Show first 3
                    print(f"      - {tc}")
                if len(found_in_this_file) > 3:
                    print(f"      ... and {len(found_in_this_file) - 3} more")

    # Check if we have any data
    if not all_test_data:
        print("\n❌ No test data collected from source files")
        return False

    # Write to target file
    print(f"\n📝 Writing to {target_file}...")

    with open(target_file, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        # Write GLOBAL rows first
        global_count = 0
        if "GLOBAL" in all_test_data:
            for row in all_test_data["GLOBAL"]:
                writer.writerow(row)
                global_count += 1

        # Write test case rows (sorted by test case ID)
        test_case_count = 0
        for test_case in sorted([tc for tc in all_test_data.keys() if tc != "GLOBAL"]):
            for row in all_test_data[test_case]:
                writer.writerow(row)
            test_case_count += 1

    # Summary
    print(f"\n✅ Successfully populated {suite_name}.csv")
    print(f"   - GLOBAL rows: {global_count}")
    print(f"   - Test cases: {test_case_count}")
    print(
        f"   - Total rows: {global_count + sum(len(rows) for tc, rows in all_test_data.items() if tc != 'GLOBAL')}"
    )

    # Show which included tests were found vs missing
    found_tests = set(tc for tc in all_test_data.keys() if tc != "GLOBAL")
    missing_tests = included_tests - found_tests

    if missing_tests:
        print(
            f"\n⚠️  Warning: {len(missing_tests)} test case(s) marked as 'Yes' but not found in source files:"
        )
        for tc in sorted(missing_tests)[:10]:  # Show first 10
            print(f"   - {tc}")
        if len(missing_tests) > 10:
            print(f"   ... and {len(missing_tests) - 10} more")

    return True


def main():
    # Paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    testdata_dir = os.path.join(script_dir, "TestData")
    suite_map_file = os.path.join(script_dir, "TestMap", "wfm_sit_suites.csv")

    # Parse arguments
    if len(sys.argv) < 2:
        print(__doc__)
        print("❌ Error: Suite name is required")
        print("\nUsage:")
        print(
            "  python3 populate_suite_testdata.py <suite_name> --source <source1> <source2> ..."
        )
        print("  python3 populate_suite_testdata.py <suite_name> --auto")
        sys.exit(1)

    suite_name = sys.argv[1].upper()

    # Determine source files
    if len(sys.argv) == 3 and sys.argv[2] == "--auto":
        print(f"🔍 Auto-detecting source files for {suite_name}...")
        source_files = auto_detect_sources(suite_map_file, suite_name, testdata_dir)

        if not source_files:
            print("\n❌ Could not auto-detect suitable source files")
            print("Please specify source files manually using --source option")
            sys.exit(1)

        print(f"\n✅ Selected sources: {', '.join(source_files)}")

    elif len(sys.argv) >= 4 and sys.argv[2] == "--source":
        source_files = [s.upper() for s in sys.argv[3:]]
        print(f"📋 Using specified sources: {', '.join(source_files)}")

    else:
        print(__doc__)
        print("❌ Error: Invalid arguments")
        print("\nUsage:")
        print(
            "  python3 populate_suite_testdata.py <suite_name> --source <source1> <source2> ..."
        )
        print("  python3 populate_suite_testdata.py <suite_name> --auto")
        sys.exit(1)

    # Validate files exist
    if not os.path.exists(suite_map_file):
        print(f"❌ Error: Suite mapping file not found: {suite_map_file}")
        sys.exit(1)

    if not os.path.exists(testdata_dir):
        print(f"❌ Error: Test data directory not found: {testdata_dir}")
        sys.exit(1)

    # Show summary before processing
    print(f"\n{'=' * 60}")
    print(f"Suite:       {suite_name}")
    print(f"Sources:     {', '.join(source_files)}")
    print(f"Suite Map:   {suite_map_file}")
    print(f"TestData:    {testdata_dir}")
    print(f"{'=' * 60}")

    # Populate
    success = populate_suite_testdata(
        suite_name, source_files, testdata_dir, suite_map_file
    )

    if success:
        print("\n✨ Done!")
    else:
        print("\n❌ Failed to populate suite test data")
        sys.exit(1)


if __name__ == "__main__":
    main()
