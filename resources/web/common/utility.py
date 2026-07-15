import os
from utils import logger
from enum import Enum
from datetime import datetime, timedelta
import re
import shutil
import xlrd
from xlutils.copy import copy
from robot.api import logger

# Try to import adbutils, but provide a fallback if it's not available
try:
    from adbutils import AdbClient

    ADBUTILS_AVAILABLE = True
except ImportError:
    ADBUTILS_AVAILABLE = False
    print(
        "Warning: adbutils module not found. Android device functions will be unavailable."
    )

base_directory = os.path.abspath("")


def generate_date_format(is_dd_mm: bool):
    """
    Dynamically generates an Enum for date format based on the given condition.
    """

    # SERVER_DF - 20241118
    # FULL_DATE_DF - Monday, November 18, 2024
    # FULL_DATE_SPACE_DF - Monday November 18 2024
    # FULL_DATE_DF_WITHOUT_COMMA - Tuesday 17 December 2024
    # TODO: use full date instead of this after date util change
    # FULL_DATE_DF_WITH_ONE_COMMA - Tuesday, 17 December
    # FULL_DATE_DF_SHORT - Monday, 18 Nov 2024
    # DATE_DF - November 18, 2024
    # SHORT_DATE_DF - Nov 18, 2024
    # TODO: change DAY_DATE back to below format after change in date util
    # DAY_DATE - Tue, Nov 18  (%a, %d %b)
    # MONTH_DAY - November 18
    # WEB_INPUT_DATE - 18/11/2024
    # YEAR_DF - 2024
    # MONTH_DF - 11
    # YEAR_LAST_TWO_DIGITS - 24
    # WEB_FULL_DATE_LEADING_ZERO- Thursday 6 February 2025
    # FULL_MONTH_DF - November
    # FIXED_SHORT_DATE_DF - Nov 18 2024
    # FIXED_HYPHEN_DATE_DF - 18-Nov-2024
    # LONG_DAY_MONTH_DAY - Sunday, Feb 09
    # SHORT_MONTH_DAY_DF - Feb 09
    # FIXED_ISO_DATE_DF - 2024-11-18
    # SHORT_DATE_DF_Y - Sat, Feb 15 2025
    # DASH_NUMBER_DATE_DF  - 2013-06-09
    # FULL_DATE_WITH_COMMA - Sat, Feb 15, 2025
    # SHORT_DAY_DF - Tue
    # SHORT_MONTH_DF - Nov
    # FULL_DAY_DF = Thursady
    #
    # MONTH_YEAR - November 2024
    if is_dd_mm:

        class DateFormat(Enum):
            FULL_DATE_DF = "%A, %d %B, %Y"
            FULL_DATE_DF_WITHOUT_COMMA = "%A %d %B %Y"
            FULL_DATE_DF_WITH_ONE_COMMA = "%A, %d %B"
            FULL_DATE_DF_SHORT = "%A, %d %b %Y"
            FULL_DATE_SPACE_DF = "%A %d %B %Y"
            DATE_DF = "%d %B, %Y"
            DAY_DATE = "%a, %d %b"
            MONTH_DAY = "%d %b"
            WEB_INPUT_DATE = "%d/%m/%Y"
            SERVER_DF = "%Y%m%d"
            SHORT_MONTH_DF = "%b"
            SHORT_DAY_DF = "%a"
            FULL_DAY_DF = "%A"
            DAY_DF = "%d"
            YEAR_DF = "%Y"
            MONTH_DF = "%m"
            YEAR_LAST_TWO_DIGITS = "%y"
            FULL_MONTH_NAME = "%B"
            WEB_FULL_DATE_LEADING_ZERO = "%A {day} %B %Y"
            FULL_MONTH_DF = "%B"
            FIXED_SHORT_DATE_DF = "%b %d %Y"
            FIXED_FULL_DATE_TIME_DF = "%Y-%m-%d %H:%M:%S.%f"
            SHORT_DATE_DF = "%d %b, %Y"
            FIXED_FULL_DATE_DF = "%A, %B %d, %Y"
            FULL_DATE_WITH_COMMA = "%a, %d %b, %Y"
            LONG_DAY_MONTH_DAY = "%A, %d %b"
            SHORT_MONTH_DAY_DF = "%d %b"
            FIXED_ISO_DATE_DF = "%Y-%m-%d"
            SHORT_DATE_DF_Y = "%a, %d %b %Y"
            DASH_NUMBER_DATE_DF = "%Y-%d-%m"
            TIME_FORMAT = "%H:%M"
            MONTH_YEAR = "%B %Y"

    else:

        class DateFormat(Enum):
            FULL_DATE_DF = "%A, %B %d, %Y"
            FULL_DATE_DF_SHORT = "%A, %b %d %Y"
            FULL_DATE_DF_WITHOUT_COMMA = "%A %d %B %Y"
            FULL_DATE_DF_WITH_ONE_COMMA = "%A, %B %d"
            FULL_DATE_SPACE_DF = "%A %B %d %Y"
            DATE_DF = "%B %d, %Y"
            DAY_DATE = "%a, %b %d"
            MONTH_DAY = "%b %d"
            WEB_INPUT_DATE = "%m/%d/%Y"
            SERVER_DF = "%Y%m%d"
            SHORT_MONTH_DF = "%b"
            SHORT_DAY_DF = "%a"
            FULL_DAY_DF = "%A"
            YEAR_DF = "%Y"
            MONTH_DF = "%m"
            DAY_DF = "%d"
            YEAR_LAST_TWO_DIGITS = "%y"
            FULL_MONTH_NAME = "%B"
            WEB_FULL_DATE_LEADING_ZERO = "%A  %B {day} %Y"
            FULL_MONTH_DF = "%B"
            FIXED_SHORT_DATE_DF = "%b %d %Y"
            FIXED_FULL_DATE_TIME_DF = "%Y-%m-%d %H:%M:%S.%f"
            SHORT_DATE_DF = "%b %d, %Y"
            FIXED_FULL_DATE_DF = "%A, %B %d, %Y"
            FULL_DATE_WITH_COMMA = "%a, %b %d, %Y"
            LONG_DAY_MONTH_DAY = "%A, %b %d"
            SHORT_MONTH_DAY_DF = "%b %d"
            FIXED_ISO_DATE_DF = "%Y-%m-%d"
            SHORT_DATE_DF_Y = "%a, %b %d %Y"
            DASH_NUMBER_DATE_DF = "%Y-%m-%d"
            TIME_FORMAT = "%H:%M"
            MONTH_YEAR = "%B %Y"

    return DateFormat


def get_date_format_value(condition, attribute):
    """
    Gets the value of the specified attribute from the dynamically generated Enum.
    """
    date_format = generate_date_format(condition)
    try:
        return getattr(date_format, attribute).value
    except AttributeError:
        raise ValueError(f"{attribute} not found in DateFormat Enum")


class LocatorStrategy(Enum):
    CONTAINS = 1
    EXACT = 2


class DayFormat(Enum):
    SHORT = 1
    MEDIUM = 2
    LONG = 3


def convert_dx_to_day(
    d_code: str, day_format: DayFormat, first_day_of_week: int
) -> str:
    """
    Convert D1, D2, ... to a day of the week based on the first day of the week.
    :param d_code: String like 'D1', 'D2', ...
    :param first_day_of_week: The first day of the week (1 = Sunday, 2 = Monday, ...)
    :param day_format: The format of the day name (SHORT, MEDIUM, LONG)
    :return: Day name localizable key based on DayFormat.
    """
    days_short = [
        "common.label.day.sunday.s",
        "common.label.day.monday.s",
        "common.label.day.tuesday.s",
        "common.label.day.wednesday.s",
        "common.label.day.thursday.s",
        "common.label.day.friday.s",
        "common.label.day.saturday.s",
    ]
    days_medium = [
        "common.label.day.sunday.m",
        "common.label.day.monday.m",
        "common.label.day.tuesday.m",
        "common.label.day.wednesday.m",
        "common.label.day.thursday.m",
        "common.label.day.friday.m",
        "common.label.day.saturday.m",
    ]
    days_large = [
        "common.label.day.sunday.l",
        "common.label.day.monday.l",
        "common.label.day.tuesday.l",
        "common.label.day.wednesday.l",
        "common.label.day.thursday.l",
        "common.label.day.friday.l",
        "common.label.day.saturday.l",
    ]

    first_day_index = (first_day_of_week - 1) % 7

    day_number = int(d_code[1:]) - 1

    day_index = (first_day_index + day_number) % 7

    if day_format == DayFormat.SHORT:
        return days_short[day_index]
    elif day_format == DayFormat.MEDIUM:
        return days_medium[day_index]
    elif day_format == DayFormat.LONG:
        return days_large[day_index]


def format_date_without_leading_zero(date, date_format):
    day = date.day
    formatted_date = date.strftime(date_format.value).replace("{day}", str(day))
    return formatted_date


def find_latest_date(date_strings, date_format):
    """
    Finds and returns the latest date from a list of date strings.
    Args:
        date_strings (list of str): A list of date strings to compare.
        date_format (str): The format in which the dates are provided (compatible with datetime.strptime).
    Returns:
        str: The latest date as a string, formatted according to date_format.
    Raises:
        ValueError: If any date string does not match the provided date_format or if the list is empty.
    """
    if not date_strings:
        raise ValueError("date_strings list is empty.")
    # Parse the date strings into datetime objects
    datetime_objects = [
        datetime.strptime(date_str, date_format) for date_str in date_strings
    ]

    # Find the latest datetime object
    latest_datetime = max(datetime_objects)

    # Convert the latest datetime object back to a string in the original format
    latest_date_str = latest_datetime.strftime(date_format)

    return latest_date_str


def is_future_date(date_str, date_format):
    """
    Determines whether a given date string represents a future date.
    Args:
        date_str (str): The date as a string.
        date_format (str): The format of the date string.
    Returns:
        bool: True if the given date is in the future compared to the current date, False otherwise.
    Raises:
        ValueError: If the input string does not match the expected date format.
    """
    # Convert the input string to a datetime object
    date = datetime.strptime(date_str, date_format)
    # Get the current date
    current_date = datetime.now().date()
    # Check if the given date is in the future
    return date.date() > current_date


def process_week_range_of_timecard(input_range, date_format, week_start_day="Sunday"):
    """
    Process the input date range and return the next and previous week ranges.

    Args:
        input_range (str): A string representing the date range in the format "MM/DD/YYYY - MM/DD/YYYY".
        date_format (str): The date format string compatible with datetime.strptime and strftime.

    Returns:
        tuple[str, str, str, str]: A tuple containing four strings:
            - next_week_start (str): Start date of the next week, formatted according to date_format.
            - next_week_end (str): End date of the next week, formatted according to date_format.
            - previous_week_start (str): Start date of the previous week, formatted according to date_format.
            - previous_week_end (str): End date of the previous week, formatted according to date_format.

    Raises:
        ValueError: If the input range does not belong to the current week or is not valid.
    """
    # Parse the input range
    start_date, end_date = input_range.strip().split(" - ")
    start_date = datetime.strptime(start_date, date_format)
    end_date = datetime.strptime(end_date, date_format)

    # Get today's date and determine the current week (Sunday-Saturday)
    today = datetime.today()
    # Map week_start_day to Python's weekday index (Monday=0 ... Sunday=6)
    week_days = {
        "Sunday": 6,
        "Monday": 0,
        "Tuesday": 1,
        "Wednesday": 2,
        "Thursday": 3,
        "Friday": 4,
        "Saturday": 5,
    }
    # Accept both string and int for week_start_day
    if isinstance(week_start_day, int) or (
        isinstance(week_start_day, str) and week_start_day.isdigit()
    ):
        # Framework convention: 1=Sunday ... 7=Saturday
        fw_index = int(week_start_day)
        python_weekday = 6 if fw_index == 1 else fw_index - 2
    else:
        python_weekday = week_days.get(str(week_start_day), 6)  # default to Sunday

    today = datetime.strptime(today.strftime(date_format), date_format)
    days_since_week_start = (today.weekday() - python_weekday) % 7
    week_start = today - timedelta(days=days_since_week_start)
    week_end = week_start + timedelta(days=6)

    # Check if the input range matches the current week exactly
    is_current_week = (start_date.date() == week_start.date()) and (
        end_date.date() == week_end.date()
    )
    no_of_days = (end_date - start_date).days

    # Verify if input range belongs to the current week
    if is_current_week and no_of_days == 6:
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
        raise ValueError(
            "Invalid input range. Expected a 7-day range within the current week in format MM/DD/YYYY - MM/DD/YYYY."
        )


# This utility returns list of future dates
def get_future_days(start_date_str=None, date_format="mm/dd/yyyy", num_days=10):
    # Convert the custom format to Python's strftime format
    python_date_format = (
        date_format.replace("mm", "%m").replace("dd", "%d").replace("yyyy", "%Y")
    )

    # Use today's date if no start_date_str is provided
    if start_date_str is None:
        start_date = datetime.today()
    else:
        # Parse the input date string into a datetime object
        start_date = datetime.strptime(start_date_str, python_date_format)

    # Generate the future days as specified by num_days
    future_dates = [
        (start_date + timedelta(days=i)).strftime(python_date_format)
        for i in range(1, num_days + 1)
    ]

    return future_dates


def get_current_week_start_date(output_format, week_start_day="Sunday"):
    """
    Returns the current week start date in the specified format, based on the configured week start day.

    This function is used by Robot Framework calendar navigation keywords to determine the starting
    date of the current week. It supports both day names and numeric day codes.

    Framework day numbering convention: 1 = Sunday, 2 = Monday, ..., 7 = Saturday

    Args:
        output_format (str): Python strftime format string for the output.
                             Example: "%b %d, %Y" produces "Oct 05, 2025"
        week_start_day (str or int, optional): The day the week starts on. Accepts:
                                                - Day names: "Sunday", "Monday", ..., "Saturday"
                                                - Numeric codes: 1-7 (1=Sunday, 7=Saturday)
                                                Default: "Sunday"

    Returns:
        str: The formatted week start date string.
             Example: "Oct 05, 2025" (if output_format is "%b %d, %Y")

    Robot Framework Usage:
        # Get current week start date with Sunday as first day
        ${week_start}    Get Current Week Start Date    %b %d, %Y    Sunday
        # Returns: Oct 06, 2025 (if today is Oct 10, 2025)

        # Get current week start date with Monday as first day
        ${week_start}    Get Current Week Start Date    %b %d, %Y    Monday
        # Returns: Oct 07, 2025 (if today is Oct 10, 2025)

        # Using numeric day code (2 = Monday)
        ${week_start}    Get Current Week Start Date    %b %d, %Y    2
        # Returns: Oct 07, 2025 (if today is Oct 10, 2025)

        # From calendar_navigation.resource - used with config values
        ${CALENDAR_NAVIGATION_DATE_FORMAT}    Get Config Value    key=CALENDAR_NAVIGATION_DATE_FORMAT
        ${WEEK_START_DAY}    Get Config Value    key=FISCAL_WEEK_START_DAY
        ${current_week_start_date}    Get Current Week Start Date
        ...    ${CALENDAR_NAVIGATION_DATE_FORMAT}
        ...    ${WEEK_START_DAY}
    """
    # Framework mapping (custom): 1=Sunday ... 7=Saturday
    custom_day_mapping = {
        "Sunday": 1,
        "Monday": 2,
        "Tuesday": 3,
        "Wednesday": 4,
        "Thursday": 5,
        "Friday": 6,
        "Saturday": 7,
    }

    # Allow numeric input (int or numeric string) using framework numbering
    if isinstance(week_start_day, int) or (
        isinstance(week_start_day, str) and week_start_day.isdigit()
    ):
        custom_index = int(week_start_day)
        if custom_index < 1 or custom_index > 7:
            custom_index = 1  # default to Sunday
    else:
        custom_index = custom_day_mapping.get(week_start_day, 1)  # default to Sunday

    # Translate framework index to Python weekday() index (Monday=0 ... Sunday=6)
    # Framework: 1=Sunday -> 6, 2=Monday -> 0, ..., 7=Saturday ->5
    if custom_index == 1:
        target_weekday = 6
    else:
        target_weekday = custom_index - 2  # shift so Monday(2)->0, Tuesday(3)->1, ...

    today = datetime.now()
    current_weekday = today.weekday()  # Python's weekday
    days_since_week_start = (current_weekday - target_weekday) % 7
    start_of_week = today - timedelta(days=days_since_week_start)
    return start_of_week.strftime(output_format)


# this method returns weeks date range from week navigator locator in below format
# 12/15/2025 - 12/21/2025
def extract_week_start_end_dates(week_string):
    # Split the string around the colon to separate the week number from the dates
    parts = week_string.split(": ")
    # The dates part is the second element in the resulting list
    dates_part = parts[1] if len(parts) > 1 else ""
    # Split the dates part around the hyphen to get start and end dates
    start_date_str, end_date_str = dates_part.split(" - ")

    return start_date_str, end_date_str


# this method returns weeks dates in below format
# returns in format: Mon 16/12
def generate_week_dates(
    start_date_str, end_date_str, date_format_input, date_format_output
):
    # Define the date format for input and output
    # Parse the start and end dates
    start_date = datetime.strptime(start_date_str, date_format_input)
    end_date = datetime.strptime(end_date_str, date_format_input)

    # Initialize a list to store the formatted date strings
    formatted_dates = []

    # Iterate over each day in the date range
    current_date = start_date
    while current_date <= end_date:
        # Format the current date
        formatted_date = current_date.strftime(date_format_output)
        formatted_dates.append(formatted_date)

        # Move to the next day
        current_date += timedelta(days=1)

    return formatted_dates


def update_excel_file(file_path, data):
    """
    Update an Excel (.xls) file with new data at specified cell locations.

    Args:
        file_path (str): Path to the .xls file
        data (dict): Dictionary mapping cell references to values (e.g., {'A1': 'value'})

    Returns:
        bool: True if successful, False otherwise

    Raises:
        ValueError: For invalid file format or cell references
        FileNotFoundError: If the file doesn't exist
        PermissionError: If file access is denied
    """
    try:
        # Normalize and validate file path
        file_path = os.path.abspath(os.path.normpath(file_path))

        # Validate file extension
        _, ext = os.path.splitext(file_path)
        if ext.lower() != ".xls":
            raise ValueError(f"File must be in .xls format, got {ext}")

        # Check file existence
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")

        # Validate input data
        if not isinstance(data, dict) or not data:
            raise ValueError("Data must be a non-empty dictionary")

        # Validate cell references
        for cell_id in data.keys():
            if not _is_valid_cell_reference(cell_id):
                raise ValueError(f"Invalid cell reference: {cell_id}")

        # Create backup of original file
        backup_path = file_path + ".backup"
        shutil.copy2(file_path, backup_path)

        try:
            # Read the existing .xls file
            rb = xlrd.open_workbook(file_path, formatting_info=True)
            wb = copy(rb)
            ws = wb.get_sheet(0)

            # Update cells
            for cell_id, test_data in data.items():
                row, col = _parse_cell_reference(cell_id)
                ws.write(row, col, test_data)

            # Save directly to original file
            wb.save(file_path)

            # Remove backup on success
            os.remove(backup_path)

            logger.info(f"Successfully updated {len(data)} cells in {file_path}")
            return True

        except Exception as e:
            # Restore from backup on failure
            if os.path.exists(backup_path):
                shutil.move(backup_path, file_path)
                logger.info(f"Restored original file from backup due to error: {e}")
            raise

    except (ValueError, FileNotFoundError) as e:
        logger.info(f"Validation error: {e}")
        return False
    except PermissionError as e:
        logger.info(f"Permission denied accessing file: {e}")
        return False
    except Exception as e:
        logger.info(f"Unexpected error updating Excel file: {e}")
        return False


def _is_valid_cell_reference(cell_ref):
    """Validate cell reference format (e.g., A1, AB123)."""
    pattern = r"^[A-Z]+[1-9]\d*$"
    return bool(re.match(pattern, cell_ref.upper()))


def _parse_cell_reference(cell_ref):
    """
    Parse cell reference to row and column indices.
    Supports multi-letter columns (A, B, ..., Z, AA, AB, etc.)

    Args:
        cell_ref (str): Cell reference like 'A1', 'AB123'

    Returns:
        tuple: (row_index, col_index) - both 0-based
    """
    match = re.match(r"^([A-Z]+)([1-9]\d*)$", cell_ref.upper())
    if not match:
        raise ValueError(f"Invalid cell reference format: {cell_ref}")

    col_letters, row_num = match.groups()

    # Convert column letters to 0-based index
    col_index = 0
    for char in col_letters:
        col_index = col_index * 26 + (ord(char) - ord("A") + 1)
    col_index -= 1  # Convert to 0-based

    # Convert row number to 0-based index
    row_index = int(row_num) - 1

    return row_index, col_index


def get_future_weeks_start_end_dates(
    date_format, day_type="start", week_start_day="Sunday", no_of_future_dates=10
):
    """
    Generate a list of future week start or end dates based on the specified parameters.

    :param day_type: "start" for week start dates or "end" for week end dates.
    :param date_format: Format in which dates should be returned.
    :param week_start_day: The day considered as the start of the week (default: "Sunday").
    :param no_of_future_dates: Number of future dates to generate (default: 10).
    :return: List of formatted dates as strings.
    """
    # Dictionary to map week start day to its corresponding weekday index
    week_days = {
        "Sunday": 6,  # Sunday is treated as the 6th index in Python's `weekday()` method
        "Monday": 0,
        "Tuesday": 1,
        "Wednesday": 2,
        "Thursday": 3,
        "Friday": 4,
        "Saturday": 5,
    }

    # Validate the provided week_start_day
    if week_start_day not in week_days:
        raise ValueError(
            f"Invalid week_start_day: {week_start_day}. Must be one of {list(week_days.keys())}."
        )

    # Validate the day_type
    if day_type not in ["start", "end"]:
        raise ValueError(
            f"Invalid day_type: {day_type}. Must be either 'start' or 'end'."
        )

    # Get today's date
    today = datetime.now()

    # Determine the target weekday index
    if day_type == "start":
        target_weekday = week_days[week_start_day]
    else:  # day_type == "end"
        target_weekday = (
            week_days[week_start_day] - 1
        ) % 7  # Week end day is the day before the start day

    # Find the first future target date
    days_until_next_target = (target_weekday - today.weekday() + 7) % 7
    if days_until_next_target == 0:  # If today is the target day, move to the next one
        days_until_next_target = 7
    first_target_date = today + timedelta(days=days_until_next_target)

    # Generate the list of future target dates
    future_dates = [
        first_target_date + timedelta(weeks=i) for i in range(no_of_future_dates)
    ]

    # Format the dates as per the provided date_format
    formatted_dates = [date.strftime(date_format) for date in future_dates]

    return formatted_dates
