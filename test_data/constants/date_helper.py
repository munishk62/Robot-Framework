"""
Date helper utilities for WFM application

= Week Day Offset Notation =

week_day offset notation (e.g., '1_4') to represent dates relative to the current week start.
Here, first number is the week offset (0=current week, 1=next week, -1=previous week) and second number is the day of the week
(0=first day of week, 6=7th day of week).
- 1_4 means next week ahead, 5th day of that week.
- 1_6 means next week, 7th (last) day of that week.
- 0_0 means current week, first day of the week.
- -1_3 means previous week, 4th day of that week.
- -1_0 means previous week, first day of that week.

Note the first day of week is determined by the FISCAL_WEEK_START_DAY setting in config.json where values can be 1 to 7, 1=Sunday, 2=Monday, ..., 7=Saturday.
"""

import datetime
from datetime import datetime, timedelta


def get_planning_week_start(fiscal_week_start_day=1, date_format="%Y-%m-%d", base_date=None):
    """
    Get the planning week start date based on the FISCAL_WEEK_START_DAY in config.json.
    Args:
        fiscal_week_start_day (int): The day of the week that the fiscal week starts on (1=Sun, 7=Saturday).
            Defaults to 1 (Sunday).
        date_format (str): The format to return the date in. Defaults to '%Y-%m-%d'.
        base_date (str): Optional base date in '%Y-%m-%d' format always to calculate week start from. Defaults to None (current date).
    Returns:
        str: Week start date in 'YYYY-MM-DD' format
    """
    # Validate fiscal_week_start_day
    # Get current date
    if base_date:
        current_date = datetime.strptime(base_date, "%Y-%m-%d")
    else:
        current_date = datetime.now()

    # Calculate the current day of week (1=Monday, 2=Tuesday, ..., 7=Sunday)
    current_weekday = current_date.isoweekday()

    # Calculate days to subtract to reach the week's start day
    days_offset = (current_weekday - fiscal_week_start_day + 1) % 7

    # Subtract the offset days to get the week start date
    week_start_date = current_date - timedelta(days=days_offset)

    # Return the result as a string in 'YYYY-MM-DD' format
    return week_start_date.strftime(date_format)


def calculate_week_start_date_from_weekday_offset(
    weekday_offset, fiscal_week_start_day=1, date_format="%Y-%m-%d", base_date=None
):
    """
    Calculate the start date of a week given a weekday offset.

    Args:
        weekday_offset (str): week_day offset format, refer `Week Day Offset Notation`
        fiscal_week_start_day (int): The day of the week that the fiscal week starts on (1=Sun, 7=Saturday).
            Defaults to 1 (Sunday).
        date_format (str): The format to return the date in. Defaults to '%Y-%m-%d'.
        base_date (str): Optional base date in '%Y-%m-%d' format always to calculate week start from. Defaults to None (current date).
    Returns:
        str: The calculated week start date in 'YYYY-MM-DD' format
    """
    # If no base date provided, use planning week start
    base_date = get_planning_week_start(fiscal_week_start_day, base_date=base_date)

    print(f"Using base week start date for calculation: {base_date}")

    # Parse the week_day format
    week_day_parts = weekday_offset.split("_")
    if len(week_day_parts) != 2:
        raise ValueError(
            f"Invalid weekday_offset format: {weekday_offset}. Expected format: 'week_day' (e.g., '1_4')"
        )

    week_offset = int(week_day_parts[0])

    # Calculate total days offset to the start of the week
    total_days = week_offset * 7

    # Parse the base date
    base_date_obj = datetime.strptime(base_date, "%Y-%m-%d")

    # Add the offset days
    target_date = base_date_obj + timedelta(days=total_days)

    # Return the result in 'YYYY-MM-DD' format
    return target_date.strftime(date_format)


def calculate_week_start_date_from_date(
    any_date, fiscal_week_start_day=1, date_format="%Y-%m-%d"
):
    """
    Calculate the start date of the week for a given date.

    Args:
        any_date (str): The date string in date_format (default '%Y-%m-%d') format
        fiscal_week_start_day (int): The day of the week that the fiscal week starts on (1=Sun, 7=Saturday).
            Defaults to 1 (Sunday).
        date_format (str): The format to return the date in. Defaults to '%Y-%m-%d'.
    Returns:
        str: The calculated week start date in 'YYYY-MM-DD' format
    """

    # Parse the input date
    input_date = datetime.strptime(any_date, date_format)

    # Calculate the current day of week (1=Monday, 2=Tuesday, ..., 7=Sunday)
    current_weekday = input_date.isoweekday()

    # Calculate days to subtract to reach the week's start day
    days_offset = (current_weekday - fiscal_week_start_day + 1) % 7

    # Subtract the offset days to get the week start date
    week_start_date = input_date - timedelta(days=days_offset)

    # Return the result as a string in 'YYYY-MM-DD' format
    return week_start_date.strftime(date_format)


def calculate_week_start(date_string):
    """
    Calculate the start date of the week based on fiscal week start from environment config.

    Single source of truth: Fetches FISCAL_WEEK_START_DAY from config.json.
    This function will fail if config is missing - by design to catch configuration errors early.

    Args:
        date_string (str): Date in YYYY-MM-DD format

    Returns:
        str: Week start date in YYYY-MM-DD format

    Raises:
        ValueError: If FISCAL_WEEK_START_DAY is not found in environment config

    Example:
        >>> calculate_week_start("2024-11-25")
        "2024-11-24"  # If fiscal week starts on Sunday (1)
    """
    # Import here to avoid circular dependency
    from test_data.environment_manager import EnvironmentManager

    # Get fiscal week start from config - single source of truth
    env_manager = EnvironmentManager()
    fiscal_week_start_day = env_manager.get_config_value("FISCAL_WEEK_START_DAY")

    # Let it fail if config is missing - don't hide configuration errors
    if fiscal_week_start_day is None or fiscal_week_start_day == "":
        raise ValueError(
            "FISCAL_WEEK_START_DAY not found in environment config. "
            "Please ensure config.json contains FISCAL_WEEK_START_DAY key. "
            "Run environment sync: python -m dev_utils.env_config_sync.cli --env <ENV_NAME>"
        )

    fiscal_week_start_day = int(fiscal_week_start_day)

    # Use the new function to calculate week start
    return calculate_week_start_date_from_date(date_string, fiscal_week_start_day)


def calculate_date_from_week_day_offset(
    weekday_offset, fiscal_week_start_day=1, date_format="%Y-%m-%d", base_date=None
):
    """
    Calculates a date from a given weekday offset.

    Args:
        weekday_offset (str): week_day offset format, refer `Week Day Offset Notation`
        fiscal_week_start_day (int): The day of the week that the fiscal week starts on (1=Sun, 7=Saturday).
        Defaults to 1 (Sunday).
        date_format (str): The format to return the date in. Defaults to '%Y-%m-%d'.
        base_date (str): Optional base date in '%Y-%m-%d' format always to calculate from. Defaults to None (current week start).
    Returns:
        str: The calculated date in 'YYYY-MM-DD' format
    """
    # If no base date provided, use planning week start
    base_date = get_planning_week_start(fiscal_week_start_day, base_date=base_date)

    print(f"Using base week start date for calculation: {base_date}")

    # Parse the week_day format
    week_day_parts = weekday_offset.split("_")
    if len(week_day_parts) != 2:
        raise ValueError(
            f"Invalid weekday_offset format: {weekday_offset}. Expected format: 'week_day' (e.g., '1_4')"
        )

    week_offset = int(week_day_parts[0])
    day_offset = int(week_day_parts[1])

    # Calculate total days offset
    total_days = week_offset * 7 + day_offset

    # Parse the base date
    base_date_obj = datetime.strptime(base_date, "%Y-%m-%d")

    # Add the offset days
    target_date = base_date_obj + timedelta(days=total_days)

    # Return the result in 'YYYY-MM-DD' format
    return target_date.strftime(date_format)


def calculate_date_from_week_day_offset_in_multiple_formats(
    weekday_offset, fiscal_week_start_day=1, *date_formats, base_date=None
):
    """
    Calculates a date from a given weekday offset and returns it in multiple formats.

    Args:
        weekday_offset (str): week_day offset format, refer `Week Day Offset Notation`
        fiscal_week_start_day (int): The day of the week that the fiscal week starts on (1=Sun, 7=Saturday).
        Defaults to 1 (Sunday).
        *date_formats (str): Variable number of date format strings (e.g., '%Y-%m-%d', '%d/%m/%Y', '%B %d, %Y')
        base_date (str): Optional base date in '%Y-%m-%d' format always to calculate from. Defaults to None (current week start).

    Returns:
        list: List of formatted dates in the same order as input formats
    """
    # If no formats provided, use default
    if not date_formats:
        date_formats = ("%Y-%m-%d",)

    # Get base date
    base_date = get_planning_week_start(fiscal_week_start_day, base_date=base_date)

    print(f"Using base week start date for calculation: {base_date}")

    # Parse the week_day format
    week_day_parts = weekday_offset.split("_")
    if len(week_day_parts) != 2:
        raise ValueError(
            f"Invalid weekday_offset format: {weekday_offset}. Expected format: 'week_day' (e.g., '1_4')"
        )

    week_offset = int(week_day_parts[0])
    day_offset = int(week_day_parts[1])

    # Calculate total days offset
    total_days = week_offset * 7 + day_offset

    # Parse the base date
    base_date_obj = datetime.strptime(base_date, "%Y-%m-%d")

    # Add the offset days
    target_date = base_date_obj + timedelta(days=total_days)

    # Format the date in all requested formats and return as list
    formatted_dates = [target_date.strftime(fmt) for fmt in date_formats]

    return formatted_dates


def parse_relative_week_day_notation(notation):
    """
    Parse a planning week notation like "3_5" or "PW3-D5" into week and day numbers.

    Args:
        notation: String notation for planning week (e.g., "3_5" or "PW3-D5")

    Returns:
        Tuple of (week_num, day_num)
    """
    if "_" in notation:
        # Format: "3_5"
        parts = notation.split("_")
        if len(parts) == 2:
            return int(parts[0]), int(parts[1])
    elif "PW" in notation and "-D" in notation:
        # Format: "PW3-D5"
        week_part = notation.split("-D")[0]
        day_part = notation.split("-D")[1]
        week_num = int(week_part.replace("PW", ""))
        day_num = int(day_part)
        return week_num, day_num

    # Default fallback
    return 0, 0  # Week 1, Sunday


def sort_dates_chronologically(date_list, date_format="%a %m/%d"):
    """
    Sort a list of date strings chronologically.

    Args:
        date_list (list): List of date strings to sort
        date_format (str): Format of the date strings. Defaults to '%a %m/%d' (e.g., 'Mon 11/18')

    Returns:
        list: Sorted list of date strings in chronological order

    Example:
        >>> dates = ['Wed 11/20', 'Mon 11/18', 'Tue 11/19']
        >>> sort_dates_chronologically(dates)
        ['Mon 11/18', 'Tue 11/19', 'Wed 11/20']
    """
    try:
        # Sort dates by parsing them and comparing as datetime objects
        sorted_dates = sorted(
            date_list, key=lambda x: datetime.strptime(x, date_format)
        )
        return sorted_dates
    except ValueError as e:
        raise ValueError(f"Error parsing dates with format '{date_format}': {str(e)}")

def combine_week_offset_and_day_offset(week_no_or_offset, day_no):
    """
    Combine week offset and day offset into a single week_day offset string.

    Args:
        week_no_or_offset (int): The week no as 2,3,4 or week_offset e.g. 2_0, 3_0 etc.
        day_no (int): The day offset within the week (e.g., 0=first day of week, 6=seventh day)
    Returns:
        str: week_day offset string in the format 'week_day' (e.g., '2_3')
    """
    week_no = week_no_or_offset
    if "_" in week_no_or_offset:
        parts = week_no_or_offset.split("_")
        week_no = int(parts[0])  # Extract week no from offset

    return f"{week_no}_{day_no}"


def calculate_fiscal_week_number(
    date_string, fiscal_week_start_day=1, date_format="%Y-%m-%d", base_date=None
):
    """
    Calculate the fiscal week number (1-52) for a given date.

    This function determines which week (1-52) a given date falls into within the fiscal year,
    based on the fiscal week start day configuration.

    Args:
        date_string (str): Date in the specified date_format (default '%Y-%m-%d')
        fiscal_week_start_day (int): The day of the week that the fiscal week starts on (1=Sun, 7=Saturday).
            Defaults to 1 (Sunday).
        date_format (str): The format of the input date string. Defaults to '%Y-%m-%d'.
        base_date (str): Optional fiscal year start date in '%Y-%m-%d' format. If not provided,
            uses the fiscal year start calculated from the input date.

    Returns:
        int: Fiscal week number (1-52)

    Example:
        >>> calculate_fiscal_week_number("2026-02-15", fiscal_week_start_day=1)
        8  # If fiscal year starts 2025-12-28
    """
    # Parse the input date
    target_date = datetime.strptime(date_string, date_format)

    # If no base_date provided, calculate fiscal year start from the target date
    if not base_date:
        # Get the week start of the target date
        current_weekday = target_date.isoweekday()
        days_offset = (current_weekday - fiscal_week_start_day + 1) % 7
        week_start_of_target = target_date - timedelta(days=days_offset)

        # Assume fiscal year starts on the same week start day of the previous year period
        # We need to find fiscal year start: go back until we find a date where the fiscal year changed
        fiscal_year_start = week_start_of_target

        # Go back week by week until we find the fiscal year start (arbitrary year boundary)
        # For most fiscal calendars, this is based on a specific quarter start or calendar year
        # We'll assume fiscal year starts on the first occurrence of fiscal_week_start_day >= Jan 1
        fiscal_year_start = datetime(target_date.year, 1, 1)
        current_weekday = fiscal_year_start.isoweekday()
        days_offset = (current_weekday - fiscal_week_start_day + 1) % 7
        fiscal_year_start = fiscal_year_start - timedelta(days=days_offset)

        base_date = fiscal_year_start.strftime("%Y-%m-%d")
    else:
        fiscal_year_start = datetime.strptime(base_date, "%Y-%m-%d")

    # Calculate the difference in days between base_date and target date
    fiscal_year_start = datetime.strptime(base_date, "%Y-%m-%d")
    days_difference = (target_date - fiscal_year_start).days

    # Calculate week number (add 1 because week 0 doesn't exist; week 1 starts at day 0)
    fiscal_week_number = (days_difference // 7) + 1

    # Ensure week number is within valid range (1-53 for some years with 53 weeks)
    if fiscal_week_number < 1:
        fiscal_week_number = 1
    elif fiscal_week_number > 53:
        fiscal_week_number = 53

    return fiscal_week_number


def calculate_fiscal_week_number_from_week_day_offset(
    weekday_offset, fiscal_week_start_day=1, base_date=None
):
    """
    Calculate the fiscal week number (1-52) from a week_day offset format.

    Args:
        weekday_offset (str): Week-day offset string (e.g., '8_0', '1_3')
        fiscal_week_start_day (int): The day of the week that the fiscal week starts on (1=Sun, 7=Saturday).
            Defaults to 1 (Sunday).
        base_date (str): Optional fiscal year start date in '%Y-%m-%d' format

    Returns:
        int: Fiscal week number (1-52)

    Example:
        >>> calculate_fiscal_week_number_from_week_day_offset("8_0", fiscal_week_start_day=1)
        8
    """
    # First, calculate the actual date from the week_day offset
    date_string = calculate_date_from_week_day_offset(
        weekday_offset, fiscal_week_start_day, "%Y-%m-%d", base_date
    )

    # Then, calculate the fiscal week number for that date
    return calculate_fiscal_week_number(
        date_string, fiscal_week_start_day, "%Y-%m-%d", base_date
    )
