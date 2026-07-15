"""
CSV Library for Robot Framework.

A comprehensive library for reading and writing CSV files in Robot Framework tests.
Supports data with and without headers, with proper error handling, logging, and
security considerations.

Features:
- Read CSV files into list of lists or list of dictionaries.
- Write CSV files from list of lists or list of dictionaries.
- Append data to existing CSV files.
- Validate CSV file format and content.
- Handle both CSV files with and without headers.
- Comprehensive error handling and logging.
- Secure file path validation to prevent directory traversal.

Example usage:
| ${data}=    Read CSV File    data/test_data.csv    with_headers=${True}
| ${users}=   Read CSV File    users.csv
| Write CSV File    output.csv    ${data}    with_headers=${True}
"""

import csv
import logging
from pathlib import Path
from typing import Any, List, Dict, Union, Optional

from robot.api.deco import keyword


class CSVLibrary:
    """
    CSV file handling library for Robot Framework tests.

    Provides keywords for reading and writing CSV files with flexible support
    for headers, encoding, delimiters, and error handling.

    Attributes:
        ROBOT_LIBRARY_SCOPE (str): Library scope for Robot Framework.
        logger (logging.Logger): Logger instance for this library.
    """

    ROBOT_LIBRARY_SCOPE = "SUITE"

    def __init__(self):
        """
        Initialize the CSV Library.

        Sets up logging and configures the library for Robot Framework.
        """
        self.logger = logging.getLogger(__name__)
        self.logger.info("CSVLibrary initialized")

    # =====================================================================
    # SECURITY AND VALIDATION UTILITIES
    # =====================================================================

    def _validate_file_path(self, file_path: str) -> Path:
        """
        Validate and resolve a file path to prevent directory traversal attacks.

        Security check ensures that the resolved path is within the current
        working directory or a subdirectory (project root context).

        Arguments:
            file_path: The file path to validate.

        Returns:
            Path: A validated Path object.

        Raises:
            ValueError: If the path attempts directory traversal outside the
                       allowed base directory.
        """
        try:
            # Resolve the path to absolute
            resolved_path = Path(file_path).resolve()
            
            # Get the base directory (current working directory as project root)
            base_dir = Path.cwd().resolve()
            
            # Ensure resolved path is within or under the base directory
            try:
                resolved_path.relative_to(base_dir)
            except ValueError:
                error_msg = (
                    f"Path traversal detected: resolved path '{resolved_path}' "
                    f"is outside the allowed base directory '{base_dir}'"
                )
                self.logger.error(error_msg)
                raise ValueError(error_msg)

            self.logger.debug(f"Validated file path: {resolved_path}")
            return resolved_path

        except ValueError:
            raise
        except (OSError, Exception) as e:
            error_msg = f"Invalid file path '{file_path}': {str(e)}"
            self.logger.error(error_msg)
            raise ValueError(error_msg) from e

    def _validate_csv_content(self, content: List) -> None:
        """
        Validate CSV content for proper format.

        Arguments:
            content: List of lists or list of dicts to validate.

        Raises:
            ValueError: If content format is invalid.
        """
        if not isinstance(content, list):
            error_msg = f"Content must be a list, got {type(content).__name__}"
            self.logger.error(error_msg)
            raise ValueError(error_msg)

        if not content:
            self.logger.warning("Content is empty")
            return

        first_item = content[0]
        if not isinstance(first_item, (list, dict)):
            error_msg = (
                f"Content items must be lists or dicts, got {type(first_item).__name__}"
            )
            self.logger.error(error_msg)
            raise ValueError(error_msg)

    # =====================================================================
    # READ CSV KEYWORDS
    # =====================================================================

    @keyword
    def read_csv_file(
        self,
        file_path: str,
        with_headers: bool = True,
        delimiter: str = ",",
        encoding: str = "utf-8",
    ) -> List[Union[List, Dict]]:
        """
        Read CSV file and return data as list of lists or list of dicts.

        When with_headers is True, returns a list of dictionaries where keys
        are header names. When False, returns a list of lists.

        Arguments:
            file_path: Path to the CSV file to read.
            with_headers: If True, treats first row as headers and returns
                         list of dicts. If False, returns list of lists.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').

        Returns:
            List[Union[List, Dict]]: List of lists or list of dictionaries.

        Raises:
            FileNotFoundError: If file does not exist.
            PermissionError: If file cannot be read.
            ValueError: If CSV format is invalid.

        Examples:
        | ${data}=    Read CSV File    test_data.csv
        | ${data}=    Read CSV File    test_data.csv    with_headers=${False}
        | ${data}=    Read CSV File    test_data.csv    delimiter=;
        | Log List    ${data}
        """
        try:
            file_path = self._validate_file_path(file_path)

            if not file_path.exists():
                error_msg = f"CSV file not found: {file_path}"
                self.logger.error(error_msg)
                raise FileNotFoundError(error_msg)

            if not file_path.is_file():
                error_msg = f"Path is not a file: {file_path}"
                self.logger.error(error_msg)
                raise ValueError(error_msg)

            data = []

            with open(file_path, "r", encoding=encoding, newline="") as csv_file:
                reader = csv.reader(csv_file, delimiter=delimiter)

                if with_headers:
                    headers = next(reader, None)
                    if not headers:
                        self.logger.warning(
                            f"CSV file '{file_path}' is empty or has no headers"
                        )
                        return []

                    for row in reader:
                        if row:  # Skip empty rows
                            row_dict = {}
                            for i, header in enumerate(headers):
                                row_dict[header] = row[i] if i < len(row) else ""
                            data.append(row_dict)
                else:
                    for row in reader:
                        if row:  # Skip empty rows
                            data.append(row)

            self.logger.info(f"Successfully read {len(data)} rows from '{file_path}'")
            return data

        except FileNotFoundError as e:
            self.logger.error(f"File not found: {str(e)}")
            raise
        except PermissionError as e:
            error_msg = f"Permission denied reading file '{file_path}': {str(e)}"
            self.logger.error(error_msg)
            raise PermissionError(error_msg) from e
        except UnicodeDecodeError as e:
            error_msg = (
                f"Encoding error reading '{file_path}'. "
                f"Try different encoding: {str(e)}"
            )
            self.logger.error(error_msg)
            raise ValueError(error_msg) from e
        except csv.Error as e:
            error_msg = f"CSV format error in '{file_path}': {str(e)}"
            self.logger.error(error_msg)
            raise ValueError(error_msg) from e
        except Exception as e:
            error_msg = f"Unexpected error reading CSV file: {str(e)}"
            self.logger.error(error_msg)
            raise

    @keyword
    def read_csv_file_as_dicts(
        self,
        file_path: str,
        delimiter: str = ",",
        encoding: str = "utf-8",
    ) -> List[Dict[str, str]]:
        """
        Read CSV file with headers and return data as list of dictionaries.

        Convenience keyword for reading CSV files where first row contains
        column headers.

        Arguments:
            file_path: Path to the CSV file to read.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').

        Returns:
            List[Dict[str, str]]: List of dictionaries with header keys.

        Examples:
        | ${users}=    Read CSV File As Dicts    users.csv
        | FOR    ${user}    IN    @{users}
        |     Log    ${user}[username]
        | END
        """
        self.logger.debug(f"Reading CSV file as dicts: {file_path}")
        return self.read_csv_file(
            file_path,
            with_headers=True,
            delimiter=delimiter,
            encoding=encoding,
        )

    @keyword
    def read_csv_file_as_lists(
        self,
        file_path: str,
        has_headers: bool = False,
        delimiter: str = ",",
        encoding: str = "utf-8",
    ) -> List[List[str]]:
        """
        Read CSV file and return data as list of lists.

        Arguments:
            file_path: Path to the CSV file to read.
            has_headers: If True, skips first row (assumes it's headers).
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').

        Returns:
            List[List[str]]: List of lists where each inner list is a row.

        Examples:
        | ${data}=    Read CSV File As Lists    data.csv
        | ${data}=    Read CSV File As Lists    data.csv    has_headers=${True}
        """
        self.logger.debug(
            f"Reading CSV file as lists (has_headers={has_headers}): {file_path}"
        )
        data = self.read_csv_file(
            file_path,
            with_headers=False,
            delimiter=delimiter,
            encoding=encoding,
        )
        if has_headers and data:
            data = data[1:]  # Skip header row
        return data

    # =====================================================================
    # WRITE CSV KEYWORDS
    # =====================================================================

    @keyword
    def write_csv_file(
        self,
        file_path: str,
        data: Union[List[List], List[Dict]],
        with_headers: bool = True,
        delimiter: str = ",",
        encoding: str = "utf-8",
        overwrite: bool = True,
    ) -> None:
        """
        Write data to a CSV file.

        Handles both list of lists and list of dictionaries. When data is
        list of dicts, headers are extracted from dict keys.

        Arguments:
            file_path: Path where the CSV file will be written.
            data: List of lists or list of dictionaries to write.
            with_headers: If True, writes headers from dict keys or first
                         row (if data is list of lists).
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').
            overwrite: If True, overwrites existing file. If False, raises
                      error if file exists.

        Raises:
            FileExistsError: If file exists and overwrite is False.
            PermissionError: If cannot write to file.
            ValueError: If data format is invalid.

        Examples:
        | ${data}=    Create List    ${user1}    ${user2}
        | Write CSV File    output.csv    ${data}
        | Write CSV File    users.csv    ${users}    delimiter=;
        | Write CSV File    data.csv    ${list_of_lists}    with_headers=${False}
        """
        try:
            if not data:
                self.logger.warning("No data provided to write to CSV")
                return

            self._validate_csv_content(data)

            file_path = self._validate_file_path(file_path)

            # Create parent directories if they don't exist
            file_path.parent.mkdir(parents=True, exist_ok=True)

            if file_path.exists() and not overwrite:
                error_msg = f"File already exists and overwrite is False: {file_path}"
                self.logger.error(error_msg)
                raise FileExistsError(error_msg)

            # Determine if data is list of dicts or list of lists
            is_dict_data = isinstance(data[0], dict)

            with open(file_path, "w", encoding=encoding, newline="") as csv_file:
                if is_dict_data:
                    # Extract headers from dict keys
                    fieldnames = list(data[0].keys())
                    writer = csv.DictWriter(
                        csv_file, fieldnames=fieldnames, delimiter=delimiter
                    )

                    if with_headers:
                        writer.writeheader()
                    writer.writerows(data)
                else:
                    writer = csv.writer(csv_file, delimiter=delimiter)

                    if with_headers and data:
                        writer.writerow(data[0])
                        writer.writerows(data[1:])
                    else:
                        writer.writerows(data)

            self.logger.info(f"Successfully wrote {len(data)} rows to '{file_path}'")

        except FileExistsError as e:
            self.logger.error(f"File exists error: {str(e)}")
            raise
        except PermissionError as e:
            error_msg = f"Permission denied writing to '{file_path}': {str(e)}"
            self.logger.error(error_msg)
            raise PermissionError(error_msg) from e
        except ValueError as e:
            self.logger.error(f"Invalid data format: {str(e)}")
            raise
        except Exception as e:
            error_msg = f"Unexpected error writing CSV file: {str(e)}"
            self.logger.error(error_msg)
            raise

    @keyword
    def write_csv_from_list_of_dicts(
        self,
        file_path: str,
        data: List[Dict],
        delimiter: str = ",",
        encoding: str = "utf-8",
        overwrite: bool = True,
    ) -> None:
        """
        Write list of dictionaries to CSV file with headers from dict keys.

        Convenience keyword for writing structured data where each dictionary
        represents a row with named columns.

        Arguments:
            file_path: Path where the CSV file will be written.
            data: List of dictionaries to write.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').
            overwrite: If True, overwrites existing file. Default is True.

        Examples:
        | ${users}=    Create List
        | ...    &{user1}=    username=john    email=john@example.com
        | ...    &{user2}=    username=jane    email=jane@example.com
        | Write CSV From List Of Dicts    users.csv    ${users}
        """
        self.logger.debug(f"Writing list of dicts to CSV file: {file_path}")
        self.write_csv_file(
            file_path,
            data,
            with_headers=True,
            delimiter=delimiter,
            encoding=encoding,
            overwrite=overwrite,
        )

    @keyword
    def write_csv_from_list_of_lists(
        self,
        file_path: str,
        data: List[List],
        with_headers: bool = False,
        delimiter: str = ",",
        encoding: str = "utf-8",
        overwrite: bool = True,
    ) -> None:
        """
        Write list of lists to CSV file.

        Arguments:
            file_path: Path where the CSV file will be written.
            data: List of lists to write.
            with_headers: If True, first row is treated as headers.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').
            overwrite: If True, overwrites existing file. Default is True.

        Examples:
        | ${data}=    Create List
        | ...    ${header_list}    ${row1}    ${row2}
        | Write CSV From List Of Lists    data.csv    ${data}
        | ...    with_headers=${True}
        """
        self.logger.debug(f"Writing list of lists to CSV file: {file_path}")
        self.write_csv_file(
            file_path,
            data,
            with_headers=with_headers,
            delimiter=delimiter,
            encoding=encoding,
            overwrite=overwrite,
        )

    @keyword
    def write_single_column_csv(
        self,
        file_path: str,
        values: List[Any],
        header: Optional[str] = None,
        delimiter: str = ",",
        encoding: str = "utf-8",
        overwrite: bool = True,
        skip_empty: bool = True,
        deduplicate: bool = False,
    ) -> int:
        """
        Write a single-column CSV from a list of values.

        This keyword is designed for DataDriver use cases where a CSV needs
        one value per row, optionally under a single header like ``${user_id}``.

        Arguments:
            file_path: Destination CSV file path.
            values: List of values to write, one per row.
            header: Column header name. If None or empty, no header row is written.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').
            overwrite: If True, overwrites existing file.
            skip_empty: If True, skips None/blank values.
            deduplicate: If True, removes duplicate values while preserving
                original order.

        Returns:
            int: Number of data rows written (header row not included).

        Raises:
            ValueError: If values is not a list.
            FileExistsError: If file exists and overwrite is False.

        Examples:
        | # With header
        | ${count}=    Write Single Column CSV
        | ...    availableUsersInEnv.csv    ${users}
        | ...    header=${user_id}
        |
        | # Without header
        | ${count}=    Write Single Column CSV
        | ...    users.csv    ${users}
        """
        if not isinstance(values, list):
            error_msg = f"Values must be a list, got {type(values).__name__}"
            self.logger.error(error_msg)
            raise ValueError(error_msg)

        file_path_obj = self._validate_file_path(file_path)
        file_path_obj.parent.mkdir(parents=True, exist_ok=True)

        if file_path_obj.exists() and not overwrite:
            error_msg = f"File already exists and overwrite is False: {file_path_obj}"
            self.logger.error(error_msg)
            raise FileExistsError(error_msg)

        normalized_values: List[str] = []
        for item in values:
            if item is None:
                if skip_empty:
                    continue
                normalized_values.append("")
                continue

            text_value = str(item).strip()
            if skip_empty and text_value == "":
                continue
            normalized_values.append(text_value)

        if deduplicate:
            seen = set()
            unique_values: List[str] = []
            for value in normalized_values:
                if value in seen:
                    continue
                seen.add(value)
                unique_values.append(value)
            normalized_values = unique_values

        with open(file_path_obj, "w", encoding=encoding, newline="") as csv_file:
            # Write with header if provided, otherwise write values only
            if header and header.strip():
                writer = csv.DictWriter(
                    csv_file, fieldnames=[header], delimiter=delimiter
                )
                writer.writeheader()
                for value in normalized_values:
                    writer.writerow({header: value})
            else:
                # Write values directly without header
                writer = csv.writer(csv_file, delimiter=delimiter)
                for value in normalized_values:
                    writer.writerow([value])

        header_status = (
            "with header" if (header and header.strip()) else "without header"
        )
        self.logger.info(
            "Successfully wrote single-column CSV '%s' %s and %d data rows",
            file_path_obj,
            header_status,
            len(normalized_values),
        )
        return len(normalized_values)

    @keyword
    def write_csv_from_list_of_tuples(
        self,
        file_path: str,
        data: List[tuple],
        headers: Optional[List[str]] = None,
        delimiter: str = ",",
        encoding: str = "utf-8",
        overwrite: bool = True,
    ) -> int:
        """
        Write list of tuples (from DB queries) to CSV file.

        Designed for database query results that return tuples. Headers are
        optional - if provided, they will be written as the first row.

        Arguments:
            file_path: Destination CSV file path.
            data: List of tuples from database query results.
            headers: Optional list of column headers. If provided, must match
                    tuple length. If None, no header row is written.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').
            overwrite: If True, overwrites existing file.

        Returns:
            int: Number of data rows written (header row not included).

        Raises:
            ValueError: If data is not list of tuples or headers don't match.
            FileExistsError: If file exists and overwrite is False.

        Examples:
        | # DB query result with headers
        | ${result}=    Get Store Details From DB
        | ${headers}=    Create List    store_id    store_name    store_code
        | ...    timezone
        | ${count}=    Write CSV From List Of Tuples
        | ...    stores.csv    ${result}    headers=${headers}
        |
        | # DB query result without headers
        | ${result}=    Get Store Details From DB
        | ${count}=    Write CSV From List Of Tuples
        | ...    stores_no_header.csv    ${result}
        """
        # Validation
        if not isinstance(data, list):
            error_msg = f"Data must be a list, got {type(data).__name__}"
            self.logger.error(error_msg)
            raise ValueError(error_msg)

        # Check if data contains tuples or lists
        if data and not isinstance(data[0], (tuple, list)):
            error_msg = (
                f"Data items must be tuples or lists, got {type(data[0]).__name__}"
            )
            self.logger.error(error_msg)
            raise ValueError(error_msg)

        # Validate headers match tuple length if provided
        if headers:
            if not isinstance(headers, list):
                error_msg = f"Headers must be a list, got {type(headers).__name__}"
                self.logger.error(error_msg)
                raise ValueError(error_msg)

            if data:
                tuple_len = len(data[0])
                headers_len = len(headers)
                if tuple_len != headers_len:
                    error_msg = (
                        f"Headers length ({headers_len}) does not match "
                        f"tuple length ({tuple_len})"
                    )
                    self.logger.error(error_msg)
                    raise ValueError(error_msg)

        file_path_obj = self._validate_file_path(file_path)
        file_path_obj.parent.mkdir(parents=True, exist_ok=True)

        if file_path_obj.exists() and not overwrite:
            error_msg = f"File already exists and overwrite is False: {file_path_obj}"
            self.logger.error(error_msg)
            raise FileExistsError(error_msg)

        with open(file_path_obj, "w", encoding=encoding, newline="") as csv_file:
            writer = csv.writer(csv_file, delimiter=delimiter)

            # Write headers if provided
            if headers:
                writer.writerow(headers)

            # Write data rows
            for row in data:
                writer.writerow(row)

        header_status = "with header" if headers else "without header"
        self.logger.info(
            "Successfully wrote CSV from tuples '%s' %s and %d data rows",
            file_path_obj,
            header_status,
            len(data),
        )
        return len(data)

    # =====================================================================
    # APPEND CSV KEYWORDS
    # =====================================================================

    @keyword
    def append_to_csv_file(
        self,
        file_path: str,
        data: Union[List[List], List[Dict]],
        delimiter: str = ",",
        encoding: str = "utf-8",
    ) -> None:
        """
        Append data to existing CSV file without overwriting headers.

        Arguments:
            file_path: Path to the CSV file to append to.
            data: List of lists or list of dictionaries to append.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').

        Raises:
            FileNotFoundError: If file does not exist.
            PermissionError: If cannot write to file.

        Examples:
        | Append To CSV File    users.csv    ${new_users}
        | Append To CSV File    data.csv    ${new_rows}    delimiter=;
        """
        try:
            if not data:
                self.logger.warning("No data provided to append to CSV")
                return

            self._validate_csv_content(data)
            file_path = self._validate_file_path(file_path)

            if not file_path.exists():
                error_msg = f"CSV file not found: {file_path}"
                self.logger.error(error_msg)
                raise FileNotFoundError(error_msg)

            is_dict_data = isinstance(data[0], dict)

            with open(file_path, "a", encoding=encoding, newline="") as csv_file:
                if is_dict_data:
                    fieldnames = list(data[0].keys())
                    writer = csv.DictWriter(
                        csv_file, fieldnames=fieldnames, delimiter=delimiter
                    )
                    writer.writerows(data)
                else:
                    writer = csv.writer(csv_file, delimiter=delimiter)
                    writer.writerows(data)

            self.logger.info(f"Successfully appended {len(data)} rows to '{file_path}'")

        except FileNotFoundError as e:
            self.logger.error(f"File not found: {str(e)}")
            raise
        except PermissionError as e:
            error_msg = f"Permission denied appending to '{file_path}': {str(e)}"
            self.logger.error(error_msg)
            raise PermissionError(error_msg) from e
        except Exception as e:
            error_msg = f"Unexpected error appending to CSV file: {str(e)}"
            self.logger.error(error_msg)
            raise

    # =====================================================================
    # VALIDATION AND UTILITY KEYWORDS
    # =====================================================================

    @keyword
    def get_csv_row_count(
        self,
        file_path: str,
        exclude_headers: bool = True,
        delimiter: str = ",",
        encoding: str = "utf-8",
    ) -> int:
        """
        Get the number of rows in a CSV file.

        Arguments:
            file_path: Path to the CSV file.
            exclude_headers: If True, doesn't count the header row.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').

        Returns:
            int: Number of rows in the CSV file.

        Examples:
        | ${count}=    Get CSV Row Count    data.csv
        | Should Be Equal As Numbers    ${count}    5
        """
        try:
            file_path = self._validate_file_path(file_path)

            if not file_path.exists():
                error_msg = f"CSV file not found: {file_path}"
                self.logger.error(error_msg)
                raise FileNotFoundError(error_msg)

            row_count = 0
            with open(file_path, "r", encoding=encoding, newline="") as csv_file:
                reader = csv.reader(csv_file, delimiter=delimiter)
                row_count = sum(1 for _ in reader)

            if exclude_headers and row_count > 0:
                row_count -= 1

            self.logger.info(f"Row count in '{file_path}': {row_count}")
            return row_count

        except FileNotFoundError as e:
            self.logger.error(f"File not found: {str(e)}")
            raise
        except Exception as e:
            error_msg = f"Error reading CSV row count: {str(e)}"
            self.logger.error(error_msg)
            raise

    @keyword
    def validate_csv_file(
        self,
        file_path: str,
        delimiter: str = ",",
        encoding: str = "utf-8",
    ) -> bool:
        """
        Validate that a CSV file exists and has valid format.

        Arguments:
            file_path: Path to the CSV file to validate.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').

        Returns:
            bool: True if file is valid, False otherwise.

        Examples:
        | ${is_valid}=    Validate CSV File    data.csv
        | Run Keyword If    ${is_valid}    Process CSV File
        """
        try:
            file_path = self._validate_file_path(file_path)

            if not file_path.exists():
                self.logger.warning(f"CSV file not found: {file_path}")
                return False

            if not file_path.is_file():
                self.logger.warning(f"Path is not a file: {file_path}")
                return False

            # Try to read the file to validate format
            with open(file_path, "r", encoding=encoding, newline="") as csv_file:
                reader = csv.reader(csv_file, delimiter=delimiter)
                # Try to read at least one row
                next(reader, None)

            self.logger.info(f"CSV file is valid: {file_path}")
            return True

        except (PermissionError, UnicodeDecodeError, csv.Error) as e:
            self.logger.warning(f"CSV file validation failed: {str(e)}")
            return False
        except Exception as e:
            self.logger.warning(f"Unexpected error during CSV validation: {str(e)}")
            return False

    @keyword
    def get_csv_headers(
        self,
        file_path: str,
        delimiter: str = ",",
        encoding: str = "utf-8",
    ) -> List[str]:
        """
        Get the header row from a CSV file.

        Arguments:
            file_path: Path to the CSV file.
            delimiter: CSV delimiter character (default: ',').
            encoding: File encoding (default: 'utf-8').

        Returns:
            List[str]: List of header column names.

        Raises:
            FileNotFoundError: If file does not exist.
            ValueError: If file is empty or has no headers.

        Examples:
        | ${headers}=    Get CSV Headers    data.csv
        | Log List    ${headers}
        """
        try:
            file_path = self._validate_file_path(file_path)

            if not file_path.exists():
                error_msg = f"CSV file not found: {file_path}"
                self.logger.error(error_msg)
                raise FileNotFoundError(error_msg)

            with open(file_path, "r", encoding=encoding, newline="") as csv_file:
                reader = csv.reader(csv_file, delimiter=delimiter)
                headers = next(reader, None)

                if not headers:
                    error_msg = f"No headers found in '{file_path}'"
                    self.logger.error(error_msg)
                    raise ValueError(error_msg)

            self.logger.debug(f"Headers from '{file_path}': {headers}")
            return headers

        except FileNotFoundError as e:
            self.logger.error(f"File not found: {str(e)}")
            raise
        except Exception as e:
            error_msg = f"Error reading CSV headers: {str(e)}"
            self.logger.error(error_msg)
            raise

    @keyword
    def csv_file_exists(self, file_path: str) -> bool:
        """
        Check if a CSV file exists.

        Arguments:
            file_path: Path to the CSV file.

        Returns:
            bool: True if file exists, False otherwise.

        Examples:
        | ${exists}=    CSV File Exists    data.csv
        | Run Keyword If    ${exists}    Read CSV File    data.csv
        """
        try:
            file_path = self._validate_file_path(file_path)
            exists = file_path.exists() and file_path.is_file()
            self.logger.debug(f"CSV file exists: {file_path} = {exists}")
            return exists
        except Exception as e:
            self.logger.warning(f"Error checking if file exists: {str(e)}")
            return False

    @keyword
    def delete_csv_file(self, file_path: str) -> None:
        """
        Delete a CSV file.

        Arguments:
            file_path: Path to the CSV file to delete.

        Raises:
            FileNotFoundError: If file does not exist.
            PermissionError: If file cannot be deleted.

        Examples:
        | Delete CSV File    temp_data.csv
        """
        try:
            file_path = self._validate_file_path(file_path)

            if not file_path.exists():
                error_msg = f"CSV file not found: {file_path}"
                self.logger.error(error_msg)
                raise FileNotFoundError(error_msg)

            file_path.unlink()
            self.logger.info(f"Successfully deleted: {file_path}")

        except FileNotFoundError as e:
            self.logger.error(f"File not found: {str(e)}")
            raise
        except PermissionError as e:
            error_msg = f"Permission denied deleting file '{file_path}': "
            f"{str(e)}"
            self.logger.error(error_msg)
            raise PermissionError(error_msg) from e
        except Exception as e:
            error_msg = f"Error deleting CSV file: {str(e)}"
            self.logger.error(error_msg)
            raise
