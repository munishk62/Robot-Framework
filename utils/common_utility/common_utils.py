import csv
import locale
import os
import re
import shutil
from collections import namedtuple
from datetime import datetime, timedelta
from typing import Union

import xlrd
from dateutil.relativedelta import relativedelta
from robot.libraries.BuiltIn import BuiltIn
from xlutils.copy import copy
from robot.api.deco import keyword
from robot.utils import timestr_to_secs
base_directory = os.path.abspath("")


def skip_test_if_in_list(test_to_skip):
    """
    Skip the test if its name starts with any of the identifiers in the test_to_skip list.

    :param test_to_skip: A comma-separated string of test identifiers to skip.
    """
    # Handle the case where test_to_skip is None or an empty string
    if not test_to_skip:
        return

    # Convert the test_to_skip string into a list
    skip_list = [test.strip() for test in test_to_skip.split(",") if test.strip()]

    # Get the current test name using the BuiltIn library
    current_test_name = BuiltIn().get_variable_value("${TEST NAME}")

    # Check if the current test name starts with any identifier in the skip list
    for identifier in skip_list:
        if current_test_name.startswith(identifier):
            BuiltIn().skip(
                f"Skipping {current_test_name} as it starts with '{identifier}' from the skip list."
            )
            break


def get_current_week_month(output_format, week_start_day="Sunday"):
    """
    Returns the current week start in the specified format, based on the given week start day.

    :param output_format: The desired format for the output string.
    :param week_start_day: The day the week starts on (e.g., "Sunday", "Monday", "Wednesday").
    :return: The formatted week start string.
    """
    # Map week start day to Python's weekday() index (Monday=0, Sunday=6)
    week_start_mapping = {
        "Monday": 0,
        "Tuesday": 1,
        "Wednesday": 2,
        "Thursday": 3,
        "Friday": 4,
        "Saturday": 5,
        "Sunday": 6,
    }
    today = datetime.now()
    # Default to Sunday if invalid input
    target_weekday = week_start_mapping.get(week_start_day, 6)
    current_weekday = today.weekday()
    # Calculate days since the week start day
    days_since_week_start = (current_weekday - target_weekday) % 7
    start_of_week = today - timedelta(days=days_since_week_start)
    formatted_date = start_of_week.strftime(output_format)
    return formatted_date


def get_Currentweek_from_system(today_str):
    today = datetime.strptime(today_str, "%Y-%m-%d %H:%M:%S.%f")
    weekday = today.weekday()
    sunday = today - timedelta(days=(weekday + 1) % 7)
    saturday = sunday + timedelta(days=6)
    sunday_str = sunday.strftime("%m/%d/%Y")
    saturday_str = saturday.strftime("%m/%d/%Y")
    week_range = f"{sunday_str} - {saturday_str}"
    return week_range


def get_week_end(date_string, date_format):
    """
    Calculate the end of the week (Saturday) for the given date, assuming the week starts on Sunday.

    :param date_string: The input date in string format.
    :param date_format: The format of the input date string.
    :return: The last day of the week (Saturday) formatted as 'dd/mm/yyyy'.
    """
    # Parse the input date string into a datetime object
    date_obj = datetime.strptime(date_string, date_format)

    # Find the start of the week (Sunday)
    start_of_week = date_obj - timedelta(
        days=date_obj.weekday() + 1 if date_obj.weekday() != 6 else 0
    )

    # Find the end of the week (Saturday)
    end_of_week = start_of_week + timedelta(days=6)

    # Format the end date as 'dd/mm/yyyy'
    formatted_end = end_of_week.strftime("%d/%m/%Y")

    # Return the formatted end date
    return formatted_end


def redirect_to_week_of_month(date_str, weeks, direction, date_format):
    """
    Adjust the date by a specified number of weeks either forward or backward.

    Args:
        date_str (str): The date string in the provided format.
        weeks (int or str): The number of weeks to adjust.
        direction (str): 'forward' to add weeks, 'backward' to subtract weeks.
        date_format (str): The format of the input and output date string.

    Returns:
        str: The adjusted date string in the specified format.
    """
    # Convert weeks to an integer if it's not already
    weeks = int(weeks)

    # Ensure direction is valid
    if direction not in ["forward", "backward"]:
        raise ValueError("Direction must be 'forward' or 'backward'.")

    # Extract the date part from the string
    date_part = date_str.replace("Week Of ", "")

    # Parse the date part into a datetime object
    parsed_date = datetime.strptime(date_part, date_format)

    # Adjust weeks based on direction
    if direction == "backward":
        weeks = -weeks

    # Calculate the new date
    new_date = parsed_date + timedelta(weeks=weeks)

    # Format the new date into the desired output format
    formatted_date = f"Week Of {new_date.strftime(date_format)}"

    return formatted_date


def is_today_in_week_range(week_label: str) -> bool:
    """
    Validates if today's date falls within the week mentioned in the label.
    :param week_label: String like "Week of May 18, 2025"
    :return: True if today is within the week, else False
    """
    try:
        match = re.search(r"week of (.+)", week_label, re.IGNORECASE)
        if not match:
            print("Invalid label format")
            return False

        start_date_str = match.group(1).strip()
        try:
            start_date = datetime.strptime(start_date_str, "%B %d, %Y").date()
        except ValueError:
            start_date = datetime.strptime(start_date_str, "%b %d, %Y").date()

        end_date = start_date + timedelta(days=6)
        today = datetime.today().date()

        return start_date <= today <= end_date

    except ValueError as e:
        print(f"Invalid date format in label: {e}")
        return False


def get_weekday_index():
    """
    Returns the current weekday index where:
    Sunday = 0, Monday = 1, ..., Saturday = 6
    """
    python_weekday = datetime.today().weekday()  # Monday=0, Sunday=6
    custom_index = (python_weekday + 1) % 7  # Shift so Sunday=0
    return custom_index


def get_current_week_date_range(date_format="%m/%d/%Y"):
    # Get today's date
    today = datetime.today()
    # Find the start of the week (Monday)
    start_of_week = today - timedelta(days=today.weekday())
    # Find the end of the week (Sunday)
    end_of_week = start_of_week + timedelta(days=6)
    # Format the dates as 'MM/DD/YYYY'
    formatted_start = start_of_week.strftime(date_format)
    formatted_end = end_of_week.strftime(date_format)
    # Return the formatted date range
    return f"{formatted_start} - {formatted_end}"


def get_current_week_date_range_for_timecard(date_format, week_start_day="Sunday"):
    """
    Return current running week date range for Timecard page, based on the specified week start day.

    :param date_format: The desired format for the output string.
    :param week_start_day: The day the week starts on (e.g., "Sunday", "Monday", "Wednesday").
    :return: The formatted week date range string.
    """
    week_start_mapping = {
        "Monday": 0,
        "Tuesday": 1,
        "Wednesday": 2,
        "Thursday": 3,
        "Friday": 4,
        "Saturday": 5,
        "Sunday": 6,
    }
    today = datetime.today()
    # Default to Sunday if invalid input
    target_weekday = week_start_mapping.get(week_start_day, 6)
    current_weekday = today.weekday()
    days_since_week_start = (current_weekday - target_weekday) % 7
    start_of_week = today - timedelta(days=days_since_week_start)
    end_of_week = start_of_week + timedelta(days=6)
    formatted_start = start_of_week.strftime(date_format)
    formatted_end = end_of_week.strftime(date_format)
    return f"{formatted_start} - {formatted_end}"


def process_week_range_of_timecard(input_range, date_format):
    """
    Process the input date range and return the next and previous week ranges.
    The input range should be in the format "MM/DD/YYYY - MM/DD/YYYY".
    """
    # Parse the input range
    start_date, end_date = input_range.strip().split(" - ")
    start_date = datetime.strptime(start_date, date_format)
    end_date = datetime.strptime(end_date, date_format)

    # Get today's date
    possible_week_end = datetime.today()
    possible_week_start = possible_week_end - timedelta(days=6)

    # Check if the input range is valid
    start_status = (
        possible_week_start.date() <= start_date.date() <= possible_week_end.date()
    )
    no_of_days = (end_date - start_date).days

    # Verify if input range belongs to the current week
    if start_status and no_of_days == 6:
        # Generate next week range
        next_week_start = start_date + timedelta(days=7)
        next_week_start = next_week_start.strftime(date_format)
        next_week_end = end_date + timedelta(days=7)
        next_week_end = next_week_end.strftime(date_format)

        # Generate previous week range
        previous_week_start = start_date - timedelta(days=7)
        previous_week_start = previous_week_start.strftime(date_format)
        previous_week_end = start_date - timedelta(days=1)
        previous_week_end = previous_week_end.strftime(date_format)

        return next_week_start, next_week_end, previous_week_start, previous_week_end
    else:
        raise ValueError("The input range does not belong to the current week.")


def get_current_timestamp(format_string="%Y%m%d%H%M%S"):
    """
    Returns the current date/time formatted according to the provided format string.
    By default it returns in the format "%Y%m%d%H%M%S"

    Args:
    format_string (str): A format string to specify the date format (default is "%Y%m%d%H%M%S").

    Returns:
    str: The current date formatted as a string.
    """
    return datetime.now().strftime(format_string)


def check_today_is_within_given_week(
    week_start_date, week_end_date, date_format="%m/%d/%Y"
):
    # Convert input strings to datetime objects
    week_start_date = datetime.strptime(week_start_date, date_format)
    week_end_date = datetime.strptime(week_end_date, date_format)
    # Get today's date and clear the time part
    today = datetime.now().date()
    # Check if today is within the range
    is_within = week_start_date.date() <= today <= week_end_date.date()
    return is_within


# # Example usage
# check_today_is_within_given_week("09/30/2024", "10/04/2024")
def update_excel_file(file_path, data):
    try:
        # Normalize and get absolute path
        file_path = os.path.abspath(os.path.normpath(file_path))
        # Ensure the file has .xls extension
        _, ext = os.path.splitext(file_path)
        if ext.lower() != ".xls":
            raise ValueError("File must be in .xls format")
        # Read the existing .xls file
        rb = xlrd.open_workbook(file_path, formatting_info=True)
        sheet = rb.sheet_by_index(0)
        # Create a writable copy of the workbook
        wb = copy(rb)
        ws = wb.get_sheet(0)  # Get the first sheet for writing
        # Iterate through the dictionary (cell_id -> test_data)
        for cell_id, test_data in data.items():
            # Calculate row and column from cell_id (e.g., 'A1' -> row=0, col=0)
            row = int(cell_id[1:]) - 1
            col = ord(cell_id[0].upper()) - 65
            # Update the specified cell with test_data
            ws.write(row, col, test_data)
        # Save the workbook to a temporary file
        temp_file_path = file_path + ".temp"
        wb.save(temp_file_path)
        # Replace the original file with the updated one
        os.remove(file_path)  # Remove the original file
        shutil.move(
            temp_file_path, file_path
        )  # Move the temp file to the original location
        return True
    except Exception as e:
        print(f"Error updating Excel file: {e}")
        return False


def generate_date_with_hour(hour):
    hour = int(hour)
    # Get today's date
    today = datetime.now()
    # Create a new datetime object with the specified hour, setting minutes, seconds, and microseconds to zero
    specified_time = today.replace(hour=hour, minute=0, second=0, microsecond=0)
    # Format the datetime object to 'yyyymmddhhmmss'
    formatted_date = specified_time.strftime("%Y%m%d%H%M%S")
    return formatted_date


def get_cell_value_from_CSV(
    file_path: str, header: str, title: str
) -> Union[int, float, str]:
    """
    Retrieve a specific cell value from a CSV file based on a given header and title.

    This function reads a CSV file, searches for a row where the first column matches the specified `title`,
    and returns the value in the specified `header` column for that row. The function attempts to convert
    the cell value to an integer or a float, returning it as a string if both conversions fail.

    Parameters:
    - file_path (str): The path to the CSV file.
    - header (str): The column header from which to retrieve the value.
    - title (str): The value in the first column of the CSV that identifies the row.

    Returns:
    - int, float, or str: The value found in the specified cell. The value is returned as an integer or
      a float if conversion is successful, otherwise as a string.

    Raises:
    - ValueError: If no matching row with the specified title is found or if the header does not exist.
    - FileNotFoundError: If the specified file does not exist.
    - KeyError: If the specified header is not found in the CSV file.
    """
    safe_base_dir = os.path.abspath("Downloads")
    # Normalize the file path
    abs_file_path = os.path.abspath(os.path.normpath(file_path))
    # Check if the file path is within the safe directory
    if not abs_file_path.startswith(safe_base_dir):
        raise ValueError("Attempt to access a file outside the allowed directory.")
    # Open and read the CSV file
    try:
        with open(abs_file_path, mode="r", newline="") as file:
            reader = csv.DictReader(file)
            # Check if the header exists
            if header not in reader.fieldnames:
                raise KeyError(f"The header '{header}' does not exist in the CSV file.")
            # Iterate through each row to find the title
            for row in reader:
                if row[reader.fieldnames[0]] == title:  # Check the first column (title)
                    cell_value = row[
                        header
                    ]  # Return the cell corresponding to the header
                    try:
                        return int(cell_value)
                    except ValueError:
                        try:
                            return float(cell_value)
                        except ValueError:
                            # Return as a string if conversion fails
                            return cell_value

    except FileNotFoundError:
        raise FileNotFoundError(f"The file '{file_path}' was not found.")
    # Raise an error if the title or header is not found
    raise ValueError(
        f"No matching cell found for title '{title}' and header '{header}'."
    )


def filter_from_csv(file_path: str, column_name: str, filter_value: str) -> list:
    """
    Filters rows from a CSV file based on a specified column name and filter value.

    This method reads a CSV file, validates the input parameters to prevent
    misuse, and filters rows where the column value matches the filter criteria.

    Args:
        file_path (str): The path to the CSV file. Must have a '.csv' extension.
        column_name (str): The column to filter by.
        filter_value (str): The value to match in the specified column.

    Returns:
        list: A list of dictionaries representing the filtered rows.

    Raises:
        ValueError: If the file path is not a CSV file, the file does not exist,
                    or the column_name is not found in the CSV header.
        IOError: If the file cannot be read.

    Examples:
        Given a CSV file `data.csv` with content:
        ```
        Name,Age,Country
        John,30,USA
        Alice,25,UK
        John,40,Canada
        ```

        Filter by "Name" with value "John":
        >>> filter_from_csv('data.csv', 'Name', 'John')
        [{'Name': 'John', 'Age': '30', 'Country': 'USA'},
         {'Name': 'John', 'Age': '40', 'Country': 'Canada'}]

    """
    normalised_path = os.path.normpath(os.path.join(base_directory, file_path))
    sanitised_csv_file = os.path.abspath(normalised_path)

    if not sanitised_csv_file.startswith(base_directory):
        raise ValueError(
            f"The file path '{sanitised_csv_file}' is outside the allowed base directory '{base_directory}'."
        )

    # Ensure the file has a .csv extension
    if not sanitised_csv_file.lower().endswith(".csv"):
        raise ValueError(
            f"The file path '{sanitised_csv_file}' must have a '.csv' extension."
        )

    # Check if the file exists
    if not os.path.exists(sanitised_csv_file):
        raise ValueError(f"The file '{sanitised_csv_file}' does not exist.")

    filtered_list = []

    try:
        with open(sanitised_csv_file, mode="r", encoding="utf-8") as file:
            reader = csv.DictReader(file)

            if column_name not in reader.fieldnames:
                raise ValueError(f"Column '{column_name}' not found in CSV header.")

            for row in reader:
                if row[column_name] == filter_value:
                    filtered_list.append(row)
    except IOError as e:
        raise IOError(f"Error reading the file '{file_path}': {e}")

    return filtered_list


def convert_date_format(date_string: str, input_format: str, output_format: str) -> str:
    """
    Convert a date string from one format to another.

    This function takes a date string and converts it from an input format to a specified output format.

    Parameters:
    - date_string (str): The original date string to be converted.
    - input_format (str): The format of the input date string. Uses Python's `strptime` format codes.
    - output_format (str): The desired format for the output date string. Uses Python's `strftime` format codes.

    Returns:
    - str: The date string in the desired output format.

    Raises:
    - ValueError: If the date_string does not match the input_format or if the format codes are invalid.
    """
    try:
        # Parse the date string using the provided input format
        date_obj = datetime.strptime(date_string, input_format)
        # Convert the date to the desired output format
        return date_obj.strftime(output_format)
    except ValueError as e:
        raise ValueError(f"Error converting date: {e}")


def convert_locale_date_format(
    date_string: str, input_format: str, output_format: str, language_code: str
) -> str:
    """
    Convert a date string from one format to another.

    This function takes a date string and converts it from an input format to a specified output format.

    Parameters:
    - date_string (str): The original date string to be converted.
    - input_format (str): The format of the input date string. Uses Python's `strptime` format codes.
    - output_format (str): The desired format for the output date string. Uses Python's `strftime` format codes.
    - locale (str): The locale to use for date formatting.
    Returns:
    - str: The date string in the desired output format.

    Raises:
    - ValueError: If the date_string does not match the input_format or if the format codes are invalid.
    """
    try:
        # Parse the date string using the provided input format
        locale.setlocale(locale.LC_ALL, language_code + ".UTF-8")
        date_obj = datetime.strptime(date_string, input_format)
        # Convert the date to the desired output format
        date_formated = date_obj.strftime(output_format)
        locale.setlocale(locale.LC_ALL, "en_US.UTF-8")
        return date_formated
    except ValueError as e:
        raise ValueError(f"Error converting date: {e}")


def round_off_value(number: float) -> str:
    """
    Round off a number and format it with commas.

    This function takes a floating-point number, rounds it to the nearest integer,
    and returns the rounded number as a string formatted with commas as thousand separators.

    Parameters:
    - number (float): The number to be rounded and formatted.

    Returns:
    - str: The rounded number formatted with commas.
    """
    # Round the number to the nearest integer
    rounded_value = round(number)
    # Format the rounded value with commas and return as a string
    return f"{rounded_value:,}"


# This function will give the last day of of the week in expected format for the week starting with Sunday
def get_current_week_end():
    # Get today's date
    today = datetime.today()
    # Find the start of the week (Sunday)
    start_of_week = today - timedelta(
        days=today.weekday() + 1 if today.weekday() != 6 else 0
    )
    # Find the end of the week (Saturday)
    end_of_week = start_of_week + timedelta(days=6)
    # Format the end date as 'dd/mm/yyyy'
    formatted_end = end_of_week.strftime("%d/%m/%Y")
    # Return the formatted end date
    return formatted_end


def is_date_greater_than_end_of_the_week_date(new_date, week_end_date, date_format):
    """
    Determine if new_date is greater than week_end_date, using the provided date format.

    :param new_date: The date to compare, as a string.
    :param week_end_date: The end of the week date, as a string.
    :param date_format: The format of the input date strings.
    :return: True if new_date is greater than week_end_date, otherwise False.
    """
    # Parse the dates using the provided format
    new_date_obj = datetime.strptime(new_date, date_format)
    week_end_date_obj = datetime.strptime(week_end_date, date_format)

    # Return whether new_date is greater than week_end_date
    return new_date_obj > week_end_date_obj


# This function will give date needed in full format for further validations
def format_date_full(new_date):
    # Define the input and desired output formats
    input_format = "%d/%m/%Y"
    # Parse the date
    date_obj = datetime.strptime(new_date, input_format)
    # Format the day to remove leading zero
    day = date_obj.day
    formatted_date = date_obj.strftime(f"%A {day} %B %Y")
    return formatted_date


def format_date_full_to_update_locator(new_date, expected_format, expected_full_format):
    """
    Format the date string from the given input format to the specified output format.

    :param new_date: The date string to convert.
    :param expected_format: The format of the input date string.
    :param expected_full_format: The desired output format for the date string.
    :return: The date string formatted in the expected output format.
    """
    # Parse the date using the provided input format
    date_obj = datetime.strptime(new_date, expected_format)

    # Format the date according to the provided output format
    formatted_date = date_obj.strftime(expected_full_format)

    # Remove leading zero from day if present
    formatted_date = re.sub(r"\b0(\d{1})\b", r"\1", formatted_date)

    return formatted_date


# This will internally Format the date string.
def format_date_to_single_digit(date_obj, expected_full_format):
    """
    Format the date string based on the provided format.
    """
    day = date_obj.day
    return date_obj.strftime(expected_full_format.format(day=day))


# This will internally Calculate the week range from a starting date.
def get_week_range(start_date, expected_full_format):
    """
    Calculate the week range from a starting date.
    """
    # Find the start of the week (Sunday)
    start_of_week = start_date - timedelta(days=start_date.weekday() + 1)
    # Find the end of the week (Saturday)
    end_of_week = start_of_week + timedelta(days=6)

    start_formatted = format_date_to_single_digit(start_of_week, expected_full_format)
    end_formatted = format_date_to_single_digit(end_of_week, expected_full_format)

    return f"{start_formatted} To {end_formatted}"


# This fnction will Get the next week's date range formatted based on the provided client format.
def get_current_week_range(expected_full_format):
    """
    Get the current week's date range formatted based on the provided format.
    """
    today = datetime.today()
    return get_week_range(today, expected_full_format)


# This fnction will Get the next week's date range formatted based on the provided client format.
def get_next_week_range(expected_full_format):
    """
    Get the next week's date range formatted based on the provided format.
    """
    today = datetime.today()
    # Find the start of the next week (Sunday)
    start_of_next_week = today + timedelta(days=(6 - today.weekday() + 1))
    return get_week_range(start_of_next_week, expected_full_format)


# This method converts date given in the format 'dd/mm/yyyy' into 'Day dd/mm'.
# For example, it takes '28/10/2024' as input and returns Mon 28/10.
def construct_date_month(date_str, date_format, output_format):
    try:
        # Parse the input date string
        date_obj = datetime.strptime(date_str, date_format)
        # Format the date to 'Day dd/mm'
        formatted_date = date_obj.strftime(output_format)
        return formatted_date
    except ValueError:
        return "Invalid date"


def get_week_dates():
    # named tuple
    WeekDates = namedtuple(
        "WeekDates",
        [
            "current_week_date_numeric",
            "current_week",
            "previous_week_date_numeric",
            "previous_week",
        ],
    )
    current_date = datetime.now()
    previous_week_date = current_date - timedelta(days=7)
    # Format dates as "Mon 21/10"
    return WeekDates(
        current_date.strftime("%d"),
        current_date.strftime("%a %d/%m"),
        previous_week_date.strftime("%d"),
        previous_week_date.strftime("%a %d/%m"),
    )


def modify_url_with_parameter(url, profile_id, unit_id):
    # this function with replace current URL with supplied parameter, and will return new URL
    profile_id = profile_id.strip('"')
    unit_id = unit_id.strip('"')
    print(f"original URL: {url}")
    url = url.replace("&operation=logUserIn", "&operation=switchUnit")
    url += f"&profileId={profile_id}&deptId=&unitId={unit_id}"
    print(f"Modified URL: {url}")
    return url


# This function returns true or false based on the date passed is in future or not.
# Date supported as of now is YYYYMMDD format. This can be expanded to other types of dates as well.
def is_future_date(date_str):
    # Convert the input string to a datetime object
    date = datetime.strptime(date_str, "%Y%m%d")
    # Get the current date
    current_date = datetime.now().date()
    # Check if the given date is in the future
    return date.date() > current_date


# This utility returns the future date which is 11 months ahead of current date
def get_future_date():
    # Get today's date
    today = datetime.today()
    # Calculate the future date with 11 months added
    future_date = today + relativedelta(months=11)
    # Add a number of days equal to the day of the month of today to ensure uniqueness
    future_date += timedelta(days=today.day)
    # Return the future date formatted as dd/mm/yyyy
    return future_date.strftime("%d/%m/%Y")


# This function will return the date in dd/mm/yyyy format considering week as Sunday to Saturday
def get_start_of_next_week(date_format="%d/%m/%Y"):
    """Get the start date of the next week (Sunday) in dd/mm/yyyy format."""
    today = datetime.now()
    # Adjust weekday to align Sunday as the start of the week
    current_weekday = (today.weekday() + 1) % 7  # Adjust to make Sunday = 0
    # Calculate days until the next Sunday
    days_to_next_sunday = 7 - current_weekday
    next_sunday = today + timedelta(days=days_to_next_sunday)
    return next_sunday.strftime(date_format)


def get_start_of_next_week_in_full_format(output_format):
    """
    Get the start date of the next week (Sunday) in a specified format.

    :param output_format: The desired format for the output date string.
    :return: The formatted date string.
    """
    today = datetime.now()
    # Adjust weekday to align Sunday as the start of the week
    current_weekday = (today.weekday() + 1) % 7  # Adjust so Sunday is 0
    # Calculate days until the next Sunday
    days_until_next_sunday = 7 - current_weekday
    next_sunday = today + timedelta(days=days_until_next_sunday)

    # Format the date according to the specified output format
    formatted_date = next_sunday.strftime(output_format)

    # Remove leading zero from day if present
    formatted_date = re.sub(r"\b0(\d{1})\b", r"\1", formatted_date)

    return formatted_date


def get_start_of_next_week_wed_to_tue(output_format):
    """
    Get the start date of the next week (Wednesday) in a specified format.

    :param output_format: The desired format for the output date string.
    :return: The formatted date string.
    """
    today = datetime.now()

    # Calculate the current weekday where Wednesday is 0, and Thursday is 6
    # Normally: Monday=0, ..., Sunday=6
    # Adjust so Wednesday is 0: Wednesday=0, Thursday=1, ..., Tuesday=6
    # Add 5 to shift Python's weekday (Monday=0) so that Wednesday (2) becomes 0: (2 + 5) % 7 = 0
    current_weekday = (today.weekday() + 5) % 7

    # Calculate days until the next Wednesday
    days_until_next_wednesday = (7 - current_weekday) % 7

    # If today is Wednesday, we want the next Wednesday, hence add 7 days
    if days_until_next_wednesday == 0:
        days_until_next_wednesday = 7

    next_wednesday = today + timedelta(days=days_until_next_wednesday)

    # Format the date according to the specified output format
    formatted_date = next_wednesday.strftime(output_format)
    return formatted_date


def normalize_string(s):
    """Normalize strings by removing special whitespace characters and leading/trailing spaces."""
    return s.replace("\\xa0", "").replace(",", "").strip().split(".")[0]


def normalize_date(s):
    """Normalize strings by removing special whitespace characters and leading/trailing spaces."""
    s = s.replace("\\xa0", "").replace(",", "").strip().split(".")[0]
    if s.count(" ") > 1:
        s = s.rsplit(" ", 1)[0]
    return s.strip()


def normalize_shift_time(s):
    return (
        s.replace("Not Scheduled", "")
        .replace("Day Off", "")
        .replace("Not Available", "")
        .replace("Parental Leave - Unpaid", "")
        .replace("Available", "")
        .strip()
    )


def compare_shift_details_dicts(dict1, dict2):
    error_message = ""
    # Compare names directly
    if dict1["name"] != dict2["name"]:
        error_message = "Names do not match."
    else:
        # Normalize and compare dates
        dates1 = [normalize_date(date) for date in dict1["date"]]
        dates2 = [normalize_date(date) for date in dict2["date"]]
        if dates1 != dates2:
            print(dates1)
            print(dates2)
            error_message = "Dates do not match."
        else:
            # Compare shift times directly
            shift1 = [normalize_shift_time(shift) for shift in dict1["shift_time"]]
            shift2 = [normalize_shift_time(shift) for shift in dict2["shift_time"]]
            if shift1 != shift2:
                print(shift1)
                print(shift2)
                error_message = "Shift times do not match."
            else:
                print("All sections match. The dictionaries are the same.")
                return True, error_message
    return False, error_message


def compare_shift_dicts(dict1, dict2):
    error_message = ""
    # Compare names directly
    if dict1["name"] != dict2["name"]:
        error_message = "Names do not match."
    else:
        # Normalize and compare dates
        dates1 = [normalize_date(date) for date in dict1["date"]]
        dates2 = [normalize_date(date) for date in dict2["date"]]
        if dates1 != dates2:
            print(dates1)
            print(dates2)
            error_message = "Dates do not match."
        else:
            # Compare shift times directly
            shift1 = [normalize_shift_time(shift) for shift in dict1["shift_time"]]
            shift2 = [normalize_shift_time(shift) for shift in dict2["shift_time"]]
            if shift1 != shift2:
                print(shift1)
                print(shift2)
                error_message = "Shift times do not match."
            else:
                # Normalize and compare breaks
                breaks1 = [normalize_string(b) for b in dict1["break"]]
                breaks2 = [normalize_string(b) for b in dict2["break"]]
                if breaks1 != breaks2:
                    error_message = "Breaks do not match."
                else:
                    # Normalize and Compare locations directly
                    location1 = [normalize_string(b) for b in dict1["location"]]
                    location2 = [normalize_string(b) for b in dict2["location"]]
                    if location1 != location2:
                        error_message = "Locations do not match."
                    else:
                        print("All sections match. The dictionaries are the same.")
                        return True, error_message
    return False, error_message


def get_index_of_first_empty_entry_in_list(given_list):
    """Get the index of the first empty entry in a list.

    Args:
        given_list (list): The list to search for an empty entry.

    Returns:
        int: The index of the first empty entry in the list, or -1 if no empty entry is found.
    """
    # Iterate through the list and return the index of the first empty entry
    for index, entry in enumerate(given_list):
        if not entry:
            return index
    # Return -1 if no empty entry is found
    return -1


def check_atleast_one_valid_schedule_in_list(schedule_list):
    """Check if at least one valid schedule is present in the list.

    Args:
        schedule_list (list): The list of schedules to check.

    Returns:
        bool: True if at least one valid schedule is found, False otherwise.
    """
    # Iterate through the list and check if any schedule is not empty
    for schedule in schedule_list:
        if len(str(schedule).strip()) > 0:
            return True
    # Return False if no valid schedule is found
    return False


def validate_time_format(time_string: str) -> bool:
    """
    Validates time in format hh:mmam or hh:mmpm (12-hour, no space).
    Example valid: 10:30am, 01:45pm, 12:00pm
    """
    pattern = r"^(0?[1-9]|1[0-2]):[0-5][0-9](a|p)m?\s?-?$"
    return bool(re.match(pattern, time_string.strip().lower()))


def get_current_month_year():
    now = datetime.now()
    return now.strftime("%b %Y")


def update_next_month_year(current_month_year):
    try:
        dateobj = datetime.strptime(current_month_year, "%b %Y")
        next_month = dateobj + relativedelta(months=1)
        return next_month.strftime("%b %Y")
    except ValueError:
        return None


def update_previous_month_year(current_month_year):
    try:
        dateobj = datetime.strptime(current_month_year, "%b %Y")
        previous_month = dateobj - relativedelta(months=1)
        return previous_month.strftime("%b %Y")
    except ValueError:
        return None


def get_payfile_csv_details(file_path: str, user_id):
    normalised_path = os.path.normpath(os.path.join(base_directory, file_path))
    sanitised_csv_file = os.path.abspath(normalised_path)

    if not sanitised_csv_file.startswith(base_directory):
        raise ValueError(
            f"The file path '{sanitised_csv_file}' is outside the allowed base directory '{base_directory}'."
        )

    # Ensure the file has a .csv extension
    if not sanitised_csv_file.lower().endswith(".csv"):
        raise ValueError(
            f"The file path '{sanitised_csv_file}' must have a '.csv' extension."
        )

    # Check if the file exists
    if not os.path.exists(sanitised_csv_file):
        raise ValueError(f"The file '{sanitised_csv_file}' does not exist.")

    results = []

    try:
        with open(sanitised_csv_file, newline="") as csvfile:
            """
            Example:
            Given a CSV payfile `data.csv` with content:
            ```
            011321,,Automation,User,STORE5,Standard,Standard Agreement1,DEPT4,
            011332,,Automation,User,STORE6,Standard,Standard Agreement1,DEPT4,
            ```
            Filter by user_id "011321"
            >>> get_payfile_csv_details('data.csv', '011321')
            results=
            [{'AUTO': 'Automation','USER': 'User','STORE': 'STORE5','STANDARD': 'Standard','AGREEMENT': 'Standard Agreement1',
                'DEPT': 'DEPT4','JCODE': 'JCODE4','DATE': '20250330','START_DATE': '20250330','END_DATE': '20250405','ORG_NAME': 'SUNPREM',
                'TIME': '9.0','HOURS': '198.0','NUMERAL': '-1','STORE2': 'STORE5','DEPT2': 'DEPT4'}]
            """
            reader = csv.reader(csvfile)
            for row in reader:
                if row[0] == user_id:
                    data = {
                        "AUTO": row[2],
                        "USER": row[3],
                        "STORE": row[4],
                        "STANDARD": row[5],
                        "AGREEMENT": row[6],
                        "DEPT": row[7],
                        "JCODE": row[10],
                        "DATE": row[13],
                        "START_DATE": row[14],
                        "END_DATE": row[15],
                        "ORG_NAME": row[16],
                        "TIME": row[19],
                        "HOURS": row[20],
                        "NUMERAL": row[30],
                        "STORE2": row[31],
                        "DEPT2": row[32],
                    }
                    results.append(data)
        if not results:
            raise ValueError(f"No entries found for User ID: {user_id}")
    except IOError as e:
        raise IOError(f"Error reading the file '{file_path}': {e}")
    return results


def extract_number(text):
    match = re.search(r"\d+", text)
    if match:
        return int(match.group(0))
    else:
        return None


def today_date():
    today = datetime.today().strftime("%m/%d/%Y")
    return today


def fiscal_to_python_weekday(fiscal_week_start):
    return (int(fiscal_week_start) + 5) % 7


def get_date_from_day_code_midweek(fiscal_week_start, day_code):
    """Retrieve the date from current week using fiscal week data without planning week.
    Args:
     fiscal_week_start: the week start date mentioned in test data.
     day_code : required day
    Returns:
     returns the retrieved date in %m-%d-%y format.
    """
    today = datetime.today()
    today_weekday = today.weekday()  # Monday=0, Sunday=6

    # Convert fiscal start to Python weekday system
    week_start_day = fiscal_to_python_weekday(fiscal_week_start)

    # Days since start of the fiscal week
    days_since_week_start = (today_weekday - week_start_day) % 7
    week_start_date = today - timedelta(days=days_since_week_start)

    # Extract the day number from day code (like "D3")
    day_number = int(day_code[1])
    target_date = week_start_date + timedelta(days=day_number - 1)

    return target_date.strftime("%m-%d-%y")
    # return target_date.strftime("%m/%d/%Y")


def get_date_from_day_code_midweek_dateformat(fiscal_week_start, day_code):
    """Retrieve the date from current week using fiscal week data without planning week.
    Args:
     fiscal_week_start: the week start date mentioned in test data.
     day_code : required day
    Returns:
     returns the retrieved date in %m/%d/%Y format.
    """
    today = datetime.today()
    today_weekday = today.weekday()
    week_start_day = fiscal_to_python_weekday(fiscal_week_start)
    days_since_week_start = (today_weekday - week_start_day) % 7
    week_start_date = today - timedelta(days=days_since_week_start)
    day_number = int(day_code[1])
    target_date = week_start_date + timedelta(days=day_number - 1)
    return target_date.strftime("%m/%d/%Y")


def hours_difference(start_time, end_time):
    start = datetime.strptime(start_time, "%I:%M %p")
    end = datetime.strptime(end_time, "%I:%M %p")
    if end <= start:
        end += timedelta(days=1)
    diff = end - start
    hours = diff.total_seconds() / 3600
    return "{:.2f}".format(hours)


def get_day_to_weekday_map(week_start_day):
    days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    week_start = week_start_day[:3].capitalize()
    if week_start not in days:
        raise ValueError(f"Invalid week start day: {week_start_day}")
    start_index = days.index(week_start)
    return {days[(start_index + i) % 7]: f"weekday_{i}" for i in range(7)}


@keyword("Is Element Present On Mobile")
def is_element_present_on_mobile(locator, timeout="10s", interval="1s"):
    """Return True if element matches locator and is visible within timeout; else False.
    Does not fail the test. Uses AppiumLibrary.expect_element internally.
    """
    try:
        timeout_td = timedelta(seconds=timestr_to_secs(timeout))
        interval_td = timedelta(seconds=timestr_to_secs(interval))
    except (ValueError, TypeError):
        timeout_td = timedelta(seconds=float(timeout))
        interval_td = timedelta(seconds=float(interval))
    bi = BuiltIn()
    previous = None
    try:
        previous = bi.run_keyword("AppiumLibrary.Register Keyword To Run On Failure", "Nothing")
    except Exception:
        pass
    try:
        lib = bi.get_library_instance("AppiumLibrary")
    except Exception:
        return False
    try:
        lib.expect_element(
            locator,
            "visible",
            timeout=timeout_td,
            retry_interval=interval_td,
            loglevel="NONE",
        )
        return True
    except AssertionError:
        return False
    except Exception:
        return False
    finally:
        if previous is not None:
            try:
                bi.run_keyword("AppiumLibrary.Register Keyword To Run On Failure", previous)
            except Exception:
                pass
