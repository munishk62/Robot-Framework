import re
import secrets
from datetime import datetime, timedelta
import pytz
from dateutil.relativedelta import relativedelta


# This method returns time from string in the format 'HH:MM'
def extract_time(text):
    pattern = r"\d{2}:\d{2}"
    return re.findall(pattern, text)


# This method returns date and time as per provided time zone value using pytz library
def get_date_time_for_timezone(timezone_str):
    # Validate the timezone
    try:
        timezone = pytz.timezone(timezone_str)
    except pytz.UnknownTimeZoneError:
        raise ValueError(f"Unknown timezone: {timezone_str}")

    # Get the current time in the specified timezone
    current_time = datetime.now(timezone)

    # Get the day with an ordinal suffix (e.g., 1st, 2nd, 3rd, 4th)
    day = current_time.day
    if 10 <= day % 100 <= 20:
        suffix = "th"
    else:
        suffix = {1: "st", 2: "nd", 3: "rd"}.get(day % 10, "th")

    # Format the date as: Monday, 20th January
    current_date = current_time.strftime(f"%A, {day}{suffix} %B")

    # Format the time as: 08:59
    current_time_str = current_time.strftime("%H:%M")

    return current_date, current_time_str


# This method will convert a time string from HH:MM:SS format to HH:MM format.
def convert_time_to_hh_mm(time_str):
    """
    Convert a time string from HH:MM:SS format to HH:MM format.

    Args:
    - time_str (str): Time in HH:MM:SS format.

    Returns:
    - str: Time in HH:MM format.
    """
    # Split the time string by colon
    parts = time_str.split(":")

    # Extract hours and minutes
    hh_mm = f"{parts[0]}:{parts[1]}"

    return hh_mm


def get_date_in_format(date_str, expected_format):
    """
    Convert a date string with ordinal suffixes to a specified format.

    :param date_str: The date string, either in the format "Monday, 17th February" or "Mon 17th Feb 2025".
    :param expected_format: The desired output format for the date string.
    :return: The date string formatted in the expected output format.
    """
    # Remove the ordinal suffix from the day
    date_str_cleaned = re.sub(r"(\d+)(st|nd|rd|th)", r"\1", date_str)

    # Determine the format of the input date string
    if "," in date_str_cleaned:
        # Format "Monday, 17th February", append the current year
        current_year = datetime.now().year
        date_str_cleaned += f" {current_year}"
        date_obj = datetime.strptime(date_str_cleaned, "%A, %d %B %Y")
    else:
        # Format "Mon 17th Feb 2025"
        date_obj = datetime.strptime(date_str_cleaned, "%a %d %b %Y")

    # Format the date according to the expected format
    formatted_date = date_obj.strftime(expected_format)

    return formatted_date


def calculate_week_difference(new_date, week_string, expected_format, week_format):
    """
    Calculate the difference in weeks between the given date and the date derived from a "Week Of" string.

    :param new_date: The date to compare, as a string.
    :param week_string: A single string in the format 'Week Of MMM DD, YYYY' or 'Week Of DD MMM, YYYY'.
    :param expected_format: The format of the new_date string.
    :param week_format: The format of the week_string.
    :return: The difference in weeks as an integer.
    """
    # Parse the new_date using the provided format
    new_date_obj = datetime.strptime(new_date, expected_format)

    # Calculate the start of the week for the new_date
    start_of_week_new_date = new_date_obj - timedelta(
        days=new_date_obj.weekday() + 1 if new_date_obj.weekday() != 6 else 0
    )

    # Parse the week_string to get the start of the week
    week_of_date_obj = datetime.strptime(week_string, week_format)

    # Calculate the difference in days between the two weeks
    difference_in_days = (start_of_week_new_date - week_of_date_obj).days

    # Convert the difference in days to weeks
    difference_in_weeks = difference_in_days // 7

    return difference_in_weeks


def calculate_future_date(days_to_add, result_format, week_start_day=None):
    """
    Returns (future_date, current_week_end).

    - future_date = today + days_to_add
    - current_week_end = end of THIS week anchored to today, using the configured week_start_day.
      If week_start_day is not provided, uses ${WEEK_START_DAY} or defaults to 'Sunday'.
    """
    # normalize inputs
    days_to_add = int(days_to_add)

    # resolve week_start_day (param > Robot var > default)
    if week_start_day is None or str(week_start_day).strip() == "":
        try:
            week_start_day = BuiltIn().get_variable_value("${WEEK_START_DAY}", "Sunday")
        except Exception:
            week_start_day = "Sunday"

    day_norm = str(week_start_day).strip().lower()
    weekday_map = {
        "monday": 0,
        "mon": 0,
        "tuesday": 1,
        "tue": 1,
        "tues": 1,
        "wednesday": 2,
        "wed": 2,
        "thursday": 3,
        "thu": 3,
        "thurs": 3,
        "friday": 4,
        "fri": 4,
        "saturday": 5,
        "sat": 5,
        "sunday": 6,
        "sun": 6,
    }
    target_weekday = weekday_map.get(day_norm, 6)  # default to Sunday

    # compute future date
    today = datetime.today()
    future_date = today + timedelta(days=days_to_add)
    formatted_date = future_date.strftime(result_format)

    # anchor week end to TODAY's configured week
    today_weekday = today.weekday()  # Mon=0..Sun=6
    days_since_week_start = (today_weekday - target_weekday) % 7
    start_of_current_week = today - timedelta(days=days_since_week_start)
    end_of_current_week = start_of_current_week + timedelta(days=6)
    formatted_week_end = end_of_current_week.strftime(result_format)

    return formatted_date, formatted_week_end


def convert_date_to_format(date_string, expected_format):
    """
    Convert a date string from the fixed format '%d/%m/%Y' to the expected format.

    :param date_string: The date string to convert.
    :param expected_format: The desired output format for the date string.
    :return: The date string formatted in the expected format.
    """
    # Define the current format
    current_format = "%d/%m/%Y"

    # Parse the date using the fixed current format
    date_obj = datetime.strptime(date_string, current_format)

    # Format the date according to the expected format
    formatted_date = date_obj.strftime(expected_format)

    return formatted_date


def extract_time(text, expected_format="%I:%M %p", increment=15, breakpoint=7):
    """
    Extract the time from the given text and format it according to the expected format,
    returning both actual and rounded times using nearest increment rounding.

    :param text: The input text containing the time.
    :param expected_format: The desired output format for the time string.
    :param increment: The rounding increment in minutes (default is 15).
    :param breakpoint: (Unused in nearest rounding)
    :return: A tuple containing the formatted actual time and rounded time strings.
    """

    # Define a pattern to match time in HH:MM format
    pattern = r"\d{1,2}:\d{2}"

    # Find the first occurrence of the time pattern
    match = re.search(pattern, text)
    if not match:
        raise ValueError("No valid time found in the text")

    time_str = match.group(0)
    is_pm = "pm" in text.lower()
    is_am = "am" in text.lower()

    # Parse the time string into a datetime object
    time_obj = datetime.strptime(time_str, "%I:%M")

    # Adjust for AM/PM
    if is_pm and time_obj.hour < 12:
        time_obj = time_obj.replace(hour=time_obj.hour + 12)
    elif is_am and time_obj.hour == 12:
        time_obj = time_obj.replace(hour=0)

    # Save original for actual_time
    actual_time_obj = time_obj

    # Nearest increment rounding logic
    minutes = time_obj.minute
    rounded_minutes = round(minutes / increment) * increment

    rounded_time_obj = time_obj.replace(second=0, microsecond=0)
    if rounded_minutes >= 60:
        rounded_time_obj = rounded_time_obj.replace(minute=0) + timedelta(hours=1)
    else:
        rounded_time_obj = rounded_time_obj.replace(minute=rounded_minutes)

    # Format the times according to the expected format
    actual_time = actual_time_obj.strftime(expected_format)
    rounded_time = rounded_time_obj.strftime(expected_format)

    # Convert AM/PM to lowercase if present in the format
    if "%p" in expected_format:
        actual_time = actual_time.replace("AM", "am").replace("PM", "pm")
        rounded_time = rounded_time.replace("AM", "am").replace("PM", "pm")

    return actual_time, rounded_time


def get_date_time_for_timezone(timezone_str):
    """
    Get the current date and time formatted for the given timezone in 12-hour format with leading zeros.
    :param timezone_str: The timezone to use.
    :return: A tuple of formatted date and time strings.
    """
    # Validate the timezone
    try:
        timezone = pytz.timezone(timezone_str)
    except pytz.UnknownTimeZoneError:
        raise ValueError(f"Unknown timezone: {timezone_str}")

    # Get the current time in the specified timezone
    current_time = datetime.now(pytz.utc).astimezone(timezone)

    # Get the day with an ordinal suffix (e.g., 1st, 2nd, 3rd)
    day = current_time.day
    if 10 <= day % 100 <= 20:
        suffix = "th"
    else:
        suffix = {1: "st", 2: "nd", 3: "rd"}.get(day % 10, "th")

    # Format the date as: Thursday, 10th April
    current_date = current_time.strftime(f"%A, {day}{suffix} %B")

    # Format the time as: 06:06 (12-hour format with leading zeros)
    current_time_str = current_time.strftime(
        "%I:%M"
    )  # Keep leading zeros for single-digit hours

    return current_date, current_time_str


# This method will convert a time string from HH:MM:SS format to HH:MM format.
def convert_time_to_hh_mm(time_str):
    """
    Convert a time string from HH:MM:SS format to HH:MM format.

    Args:
    - time_str (str): Time in HH:MM:SS format.

    Returns:
    - str: Time in HH:MM format.
    """
    # Split the time string by colon
    parts = time_str.split(":")

    # Extract hours and minutes
    hh_mm = f"{parts[0]}:{parts[1]}"

    return hh_mm


def get_formatted_date(day_date, date_format="%d/%m/%Y"):
    # Get the current date
    current_date = datetime.now()
    current_year = current_date.year
    current_month = current_date.month
    current_day = current_date.day

    # Split the input to get the day and date
    try:
        day, date_str = day_date.split()
        given_day = int(date_str)
    except ValueError:
        raise ValueError("Input must be in the format 'Day date', e.g., 'Thu 28'")

    # Determine the month to use
    if given_day < current_day:
        # If the given date is less than today, use the next month
        if current_month == 12:  # If it's December, wrap to the next year
            next_month = 1
            year = current_year + 1
        else:
            next_month = current_month + 1
            year = current_year
    else:
        # Use the current month
        next_month = current_month
        year = current_year

    # Create a datetime object for the specified date
    try:
        date_object = datetime(year, next_month, given_day)
    except ValueError:
        raise ValueError("Invalid date provided")

    # Convert to the desired format
    formatted_date = date_object.strftime(date_format)

    return formatted_date


# This method returns 1st of previous month in yyyymmdd format. If it is executed in Dec 2024, it will return '20241101'
def get_previous_month_first():
    # Get the current date
    today = datetime.now()

    # Move back to the first day of the previous month
    first_of_previous_month = today.replace(day=1) - relativedelta(months=1)

    # Format the date in 'yyyymmdd'
    return first_of_previous_month.strftime("%Y%m%d")


# This function returns the latest date when list of dates are provided as input along with the date format.
def find_latest_date(date_strings, date_format):
    # Parse the date strings into datetime objects
    datetime_objects = [
        datetime.strptime(date_str, date_format) for date_str in date_strings
    ]

    # Find the latest datetime object
    latest_datetime = max(datetime_objects)

    # Convert the latest datetime object back to a string in the original format
    latest_date_str = latest_datetime.strftime(date_format)

    return latest_date_str


# This method converts the date format received in dd. For example,
# date received in this format '24 Nov, 2024', will be converted to '24/11/2024'
def convert_date_format_european(date_str, input_format, output_format):
    # Parse the input date string to a datetime object
    date_obj = datetime.strptime(date_str, input_format)

    # Format the datetime object to the desired output format
    formatted_date = date_obj.strftime(output_format)

    return formatted_date


# This method receives starting day of the week (Sunday-Saturday) as input and returns the ending date of the same week.
# For example, on receiving date 29/12/2024, would return 04/01/2025.
def get_end_of_week(start_date_str, input_format):
    # Parse the input date string to a datetime object
    start_date = datetime.strptime(start_date_str, input_format)

    # Calculate the end date (Saturday)
    # Since Sunday is the start of the week, Saturday is 6 days later
    days_to_add = 6
    end_date = start_date + timedelta(days=days_to_add)

    # Format the end date to the desired output format
    end_date_str = end_date.strftime(input_format)

    return end_date_str


# this method returns weeks date range from week navigator locator in below format
# 15/12/2024 - 21/12/2024
def extract_week_dates(week_string):
    # Split the string around the colon to separate the week number from the dates
    parts = week_string.split(": ")
    # The dates part is the second element in the resulting list
    dates_part = parts[1] if len(parts) > 1 else ""
    # Split the dates part around the hyphen to get start and end dates
    start_date_str, end_date_str = dates_part.split(" - ")

    return start_date_str, end_date_str


# this method returns weeks dates in below format
# return Mon 16/12
def generate_week_dates(
    start_date_str, end_date_str, timecard_date_format, timecard_shift_date_format
):
    # Define the date format for input and output
    # timecard_date_format read from TestData\Web\*_test_data.csv
    # timecard_shift_date_format read from TestData\Web\*_test_data.csv
    date_format_input = timecard_date_format
    date_format_output = timecard_shift_date_format

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


# This utility returns the future date which is next days to input date, days
def get_next_future_day(input_date, i, date_format, output_format):
    # Convert input string to a datetime object
    date_obj = datetime.strptime(input_date, date_format)
    # Calculate the next day
    next_day = date_obj + timedelta(days=int(i))
    # Output the next day in the desired format
    return next_day.strftime(output_format)


# This utility returns list of 10 future dates
def get_10_days_list(date_format="mm/dd/yyyy"):
    # Define a mapping from user-friendly format to strftime-compatible format
    format_mapping = {"dd/mm/yyyy": "%d/%m/%Y", "mm/dd/yyyy": "%m/%d/%Y"}

    # Use the provided format or default to "mm/dd/yyyy"
    strftime_format = format_mapping.get(date_format, "%m/%d/%Y")

    # Set the start date to be 10 days from today
    start_date = datetime.now() + timedelta(days=10)

    res = []
    for _ in range(10):
        # Generate a random number of days to add, ensuring it's in the future
        random_days = secrets.choice(range(21))  # Generates a number between 0 and 20
        future_date = start_date + timedelta(days=random_days)
        # Format the date using the mapped strftime format
        formatted_date = future_date.strftime(strftime_format)
        res.append(formatted_date)

    return res


# This utility returns the random future date which is 1-11  months ahead of current date
def get_random_future_date():
    # Get today's date
    today = datetime.today()
    # Generate a random number of months to add (between 1 and 11 months)
    random_months = secrets.randbelow(11) + 1
    future_date = today + timedelta(
        days=random_months * 30
    )  # Approximating 30 days per month
    # Generate a random number of days to add (between 1 and 30 days)
    random_days = secrets.randbelow(30) + 1
    future_date += timedelta(days=random_days)
    # Return the future date formatted as dd/mm/yyyy
    return future_date.strftime("%d/%m/%Y")


# This method receives date as Day MM/DD and returns the date in yyyymmdd format
# On receiving input_date "Sun 02/16", it would return '20250216'
def convert_date_to_yyyymmdd_format(date_str):
    # Get the current year
    current_year = datetime.now().year

    # Split the input string to extract the day and date
    _, date_part = date_str.split()
    month, day = map(int, date_part.split("/"))

    # Create a datetime object for the given date using the current year
    input_date = datetime(current_year, month, day)

    # Format the date as yyyymmdd
    formatted_date = input_date.strftime("%Y%m%d")

    return formatted_date


def get_time_in_minutes(time_24hr_str):
    """
    Converts time in 24-hour format (HH:MM) to the total number of minutes.

    Args:
        time_24hr_str (str): A string representing time in 24-hour format, e.g., "1:00", "14:30", etc.

    Returns:
        int: Total number of minutes from 00:00 to the given time.

    Raises:
        ValueError: If the input is not in the correct format or contains invalid values.

    Example Usage:
        >>> get_time_in_minutes("1:00")
        60
        >>> get_time_in_minutes("2:30")
        150
        >>> get_time_in_minutes("12:45")
        765
        >>> get_time_in_minutes("0:15")
        15
    """
    # Split the time string by ':'
    hours, minutes = map(int, time_24hr_str.split(":"))
    # Convert hours to minutes and add remaining minutes
    total_minutes = (hours * 60) + minutes
    return total_minutes


# This method returns 10 current and future week starting dates, spanning roughly 10 weeks ahead of the current date
def get_current_and_future_week_start_dates(
    date_format="mm/dd/yyyy", week_start_day="Sunday"
):
    # Define a mapping from user-friendly format to strftime-compatible format
    format_mapping = {"dd/mm/yyyy": "%d/%m/%Y", "mm/dd/yyyy": "%m/%d/%Y"}

    # Map the week start day to a corresponding integer where Monday is 0 and Sunday is 6
    week_start_mapping = {
        "Monday": 0,
        "Tuesday": 1,
        "Wednesday": 2,
        "Thursday": 3,
        "Friday": 4,
        "Saturday": 5,
        "Sunday": 6,
    }

    # Get today's date
    today = datetime.now()

    # Find the start date of this week
    current_weekday = today.weekday()
    target_weekday = week_start_mapping[week_start_day]
    days_until_current_week_start = (current_weekday - target_weekday) % 7
    this_week_start_date = today - timedelta(days=days_until_current_week_start)

    # Generate 10 week start dates including this week's start date
    week_start_dates = []
    for i in range(10):
        future_week_start_date = this_week_start_date + timedelta(weeks=i)
        formatted_date = future_week_start_date.strftime(
            format_mapping.get(date_format, "%m/%d/%Y")
        )
        week_start_dates.append(formatted_date)

    return week_start_dates


def extract_date_from_week_label(week_text):
    # Remove either "Week Of" or "As Of"
    for prefix in ["Week Of", "As of :"]:
        if week_text.startswith(prefix):
            week_text = week_text.replace(prefix, "").strip()
            break
    try:
        # Format: May 18, 2025
        return datetime.strptime(week_text, "%b %d, %Y").date()
    except ValueError:
        pass
    try:
        start_date_str = week_text.split(" - ")[0].strip()
        return datetime.strptime(start_date_str, "%m/%d/%Y").date()
    except ValueError:
        raise ValueError(f"Unrecognized date format in: {week_text}")


def validate_date_difference(date1, date2, expected_diff):
    actual_diff = (date2 - date1).days
    return actual_diff == int(expected_diff)


# # Testing
# if __name__ == '__main__':
#     print(get_random_future_date())


# This method returns the formatted week date range in the format 'MM/DD/YYYY-MM/DD/YYYY'
def get_formatted_week(date_obj_start, date_obj_end):
    """
    Generate a formatted week date range string.

    Args:
        date_obj_start (str): The start date as a string in the format '%Y-%m-%d %H:%M:%S.%f'.
        date_obj_end (str): The end date as a string in the format '%Y-%m-%d %H:%M:%S.%f'.

    Returns:
        str: A string representing the date range in the format 'MM/DD/YYYY-MM/DD/YYYY'.
    """
    start_date = datetime.strptime(date_obj_start, "%Y-%m-%d %H:%M:%S.%f")
    end_date = datetime.strptime(date_obj_end, "%Y-%m-%d %H:%M:%S.%f")

    # Format the dates as MM/dd/yyyy
    formatted_start_date = start_date.strftime("%m/%d/%Y")
    formatted_end_date = end_date.strftime("%m/%d/%Y")

    # Combine the formatted dates
    formatted_week = f"{formatted_start_date}-{formatted_end_date}"

    return formatted_week


def get_previous_and_next_year():
    # Get the current year
    current_year = datetime.now().year

    # Calculate the previous and next year
    previous_year = current_year - 1
    next_year = current_year + 1

    return previous_year, next_year, current_year


def get_next_day(date_str, days=1, return_format="%Y%m%d"):
    """
    Calculate the next day (or days ahead) and return it formatted as specified.

    Args:
        date_str (str): The date string in the format 'Day MM/DD'.
        days (int): Number of days to add to the date.
        return_format (str): The format string for the returned date.

    Returns:
        str: The next day formatted as specified by return_format.
    """
    # Extract the date part and assume the current year
    date_part = date_str.split(" ")[1]  # Extract 'MM/DD'
    current_year = datetime.now().year
    date_obj = datetime.strptime(f"{current_year}/{date_part}", "%Y/%m/%d")

    # Calculate the next day(s)
    next_day_obj = date_obj + timedelta(days=days)
    next_day_formatted = next_day_obj.strftime(return_format)

    return next_day_formatted


def get_future_date_by_1():
    """
    Returns a future date increased by 1 day in the format 'MM/DD/YYYY'.
    """
    future_date = datetime.now() + timedelta(days=1)
    return future_date.strftime("%m/%d/%Y")


def get_future_day(days_ahead=1):
    """
    Returns a future date in the format 'DD' after a specified number of days.

    Args:
        days_ahead (int): Number of days to add to the current date.

    Returns:
        str: Future date in 'DD' format.
    """
    future_date = datetime.now() + timedelta(days=days_ahead)
    return future_date.strftime("%d")


def get_recent_date_from_list(date_list):
    """
    Returns the most recent date from a list of date strings in the format 'MM/DD/YYYY'.
    """
    most_recent = max(date_list, key=lambda d: datetime.strptime(d, "%m/%d/%Y"))
    return most_recent


def get_date_from_date_string(input_str):
    current_year = datetime.now().year
    dt = datetime.strptime(f"{input_str}/{current_year}", "%a %m/%d/%Y")
    output_date = dt.strftime("%m/%d/%Y")
    return output_date


# This method converts current weekday and date string (e.g., 'Mon 23') to a formatted date string in the specified output format.
# Ex: It will accept date as 'Mon 23' as input and returns date in the desired format, ex: '%m/%d/%Y'.
def convert_weekday_to_date(day_date_str, output_format="%m/%d/%Y"):
    # Get the current date
    today = datetime.now()

    # Split the input string into day name and day number
    day_name, day_number = day_date_str.split()
    day_number = int(day_number)  # Convert day number to integer

    # Create a date object for the first day of the current month
    first_day_of_month = today.replace(day=1)

    # Find the date matching the given day number within the current month
    target_date = first_day_of_month.replace(day=day_number)

    # Format the date using the specified output format
    formatted_date = target_date.strftime(output_format)
    return formatted_date


# This function adds a specified number of hours and minutes to a given time string in the format 'HH:MMam' or 'HH:MMpm'.
def add_time_to_string(time_str, add_str):
    # Parse the input time string
    time_format = "%I:%M%p"
    time_obj = datetime.strptime(time_str, time_format)

    # Determine whether the add_str is hours or minutes
    add_hours, add_minutes = map(int, add_str.split(":"))

    # Add the specified hours and minutes
    new_time_obj = time_obj + timedelta(hours=add_hours, minutes=add_minutes)

    # Return the new time as a string in the same format
    return new_time_obj.strftime(time_format)
