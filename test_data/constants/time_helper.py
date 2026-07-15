from datetime import datetime

def convert_minutes_to_timeformat(minutes, time_format_12hrs=False, am_pm_format="AM/PM"):
    """
    Converts minutes from midnight to a time string in either 12-hour or 24-hour format.

    This function is designed for workforce management systems where shifts and time patterns
    are often stored as minutes from midnight (e.g., 480 = 8:00 AM, 1020 = 5:00 PM).
    
    The function supports multiple time display formats:
    - 24-hour format: "HH:MM" (e.g., "08:00", "17:00")
    - 12-hour format with customizable AM/PM notation (e.g., "08:00 AM", "05:00 pm", "05:00PM", "05:00p")

    Args:
        minutes (int): Minutes from midnight (0-1439, where 1440 represents next day's midnight).
                      Examples:
                      - 0 = 00:00 (midnight)
                      - 480 = 08:00 (8:00 AM)
                      - 720 = 12:00 (noon)
                      - 1020 = 17:00 (5:00 PM)
                      - 1440 = 00:00 (next day's midnight, treated as 24:00)

        time_format_12hrs (bool, optional): If True, returns time in 12-hour format with AM/PM.
                                           If False, returns time in 24-hour format.
                                           Defaults to False (24-hour format).

        am_pm_format (str, optional): The AM/PM notation style when time_format_12hrs=True.
                                     Valid values:
                                     - With space & leading zero: "AM/PM" (default), "am/pm", "A/P", "a/p"
                                     - Without space, with leading zero: "AMPM", "ampm", "AP", "ap"
                                     - With space, no leading zero: "-AM/PM", "-am/pm", "-A/P", "-a/p"
                                     - Without space, no leading zero: "-AMPM", "-ampm", "-AP", "-ap"
                                     Defaults to "AM/PM"
                                     Use "-" prefix to omit leading zero ("5:00" vs "05:00")
                                     This parameter is ignored when time_format_12hrs=False.

    Returns:
        str: Time string in the requested format.
             - 24-hour format: "HH:MM" (e.g., "08:00", "17:00")
             - 12-hour format: "HH:MM AM/PM" (e.g., "08:00 AM", "05:00 pm")

    Raises:
        ValueError: If minutes is negative or if am_pm_format is invalid.

    Examples:
        >>> convert_minutes_to_timeformat(480)
        '08:00'
        
        >>> convert_minutes_to_timeformat(480, time_format_12hrs=True)
        '08:00 AM'
        
        >>> convert_minutes_to_timeformat(1020, time_format_12hrs=True, am_pm_format="am/pm")
        '05:00 pm'
        
        >>> convert_minutes_to_timeformat(1020, time_format_12hrs=True, am_pm_format="ampm")
        '05:00pm'
        
        >>> convert_minutes_to_timeformat(1020, time_format_12hrs=True, am_pm_format="-AM/PM")
        '5:00 PM'
        
        >>> convert_minutes_to_timeformat(1020, time_format_12hrs=True, am_pm_format="-ampm")
        '5:00pm'
        
        >>> convert_minutes_to_timeformat(720, time_format_12hrs=True, am_pm_format="A/P")
        '12:00 P'
        
        >>> convert_minutes_to_timeformat(720, time_format_12hrs=True, am_pm_format="AP")
        '12:00PM'
        
        >>> convert_minutes_to_timeformat(0)
        '00:00'
        
        >>> convert_minutes_to_timeformat(1440)
        '24:00'

    Notes:
        - Handles special case: 1440 minutes is treated as "24:00" (end of day) rather than "00:00"
        - Minutes >= 1440 wrap around to next day (e.g., 1500 minutes = 01:00 next day)
        - Used primarily for shift times, schedule patterns, and time-based workforce data
    """
    # Validate input
    if minutes < 0:
        raise ValueError(f"Minutes cannot be negative: {minutes}")
    
    # Calculate hours and minutes
    hours = minutes // 60
    mins = minutes % 60
    
    # Handle special case: 1440 minutes = 24:00 (end of day)
    if minutes == 1440:
        if time_format_12hrs:
            return convert_24hr_time_to_12hr("24:00", am_pm_format)
        return "24:00"
    
    # Handle wrap-around for minutes > 1440 (next day)
    hours = hours % 24
    
    # Format as 24-hour time first
    time_24hr = f"{hours:02d}:{mins:02d}"
    
    # Convert to 12-hour format if requested
    if time_format_12hrs:
        return convert_24hr_time_to_12hr(time_24hr, am_pm_format)
    
    return time_24hr



def convert_24hr_time_to_12hr(time_24hr_str, am_pm_format="AM/PM"):
    """
    Converts a 24-hour time string to a 12-hour format with customizable AM/PM notation.

    This function supports multiple AM/PM format styles to accommodate different display preferences
    commonly used in workforce management systems and time tracking applications.

    Supported AM/PM Formats:
        With space (and leading zero for hours 1-9):
        - "AM/PM" (default): Uppercase with both letters (e.g., "02:30 PM")
        - "am/pm": Lowercase with both letters (e.g., "02:30 pm")
        - "A/P": Single uppercase letter (e.g., "02:30 P")
        - "a/p": Single lowercase letter (e.g., "02:30 p")
        
        Without space (and leading zero for hours 1-9):
        - "AMPM": Uppercase with both letters (e.g., "02:30PM")
        - "ampm": Lowercase with both letters (e.g., "02:30pm")
        - "AP": Single uppercase letter (e.g., "02:30PM")
        - "ap": Single lowercase letter (e.g., "02:30p")
        
        With space (no leading zero):
        - "-AM/PM": Uppercase with both letters (e.g., "2:30 PM")
        - "-am/pm": Lowercase with both letters (e.g., "2:30 pm")
        - "-A/P": Single uppercase letter (e.g., "2:30 P")
        - "-a/p": Single lowercase letter (e.g., "2:30 p")
        
        Without space (no leading zero):
        - "-AMPM": Uppercase with both letters (e.g., "2:30PM")
        - "-ampm": Lowercase with both letters (e.g., "2:30pm")
        - "-AP": Single uppercase letter (e.g., "2:30PM")
        - "-ap": Single lowercase letter (e.g., "2:30p")

    Args:
        time_24hr_str (str): The time string in "HH:MM" 24-hour format.
                            Examples: "14:30", "08:00", "00:15", "24:00"
                            Note: "24:00" is automatically converted to "00:00" (midnight)
        
        am_pm_format (str, optional): The desired AM/PM format style. 
                                      Valid values: "AM/PM", "am/pm", "A/P", "a/p", "AMPM", "ampm", "AP", "ap"
                                      Prefix with "-" for no leading zero: "-AM/PM", "-am/pm", "-A/P", "-a/p", etc.
                                      Defaults to "AM/PM"

    Returns:
        str: The time string in 12-hour format with the specified AM/PM notation.
             Examples based on format:
             - "AM/PM": "02:30 PM", "08:00 AM" (with space, with leading zero)
             - "am/pm": "02:30 pm", "08:00 am" (with space, with leading zero)
             - "A/P": "02:30 P", "08:00 A" (with space, with leading zero)
             - "a/p": "02:30 p", "08:00 a" (with space, with leading zero)
             - "AMPM": "02:30PM", "08:00AM" (no space, with leading zero)
             - "ampm": "02:30pm", "08:00am" (no space, with leading zero)
             - "AP": "02:30PM", "08:00AM" (no space, with leading zero)
             - "ap": "02:30p", "08:00a" (no space, with leading zero)
             - "-AM/PM": "2:30 PM", "8:00 AM" (with space, no leading zero)
             - "-ampm": "2:30pm", "8:00am" (no space, no leading zero)
             - "-AP": "2:30PM", "8:00AM" (no space, no leading zero)
             - "-ap": "2:30p", "8:00a" (no space, no leading zero)

    Raises:
        ValueError: If am_pm_format is not one of the supported values.
        ValueError: If time_24hr_str is not in valid "HH:MM" format.

    Examples:
        >>> convert_24hr_time_to_12hr("14:30")
        '02:30 PM'

        >>> convert_24hr_time_to_12hr("14:30", "am/pm")
        '02:30 pm'
        
        >>> convert_24hr_time_to_12hr("14:30", "ampm")
        '02:30pm'
        
        >>> convert_24hr_time_to_12hr("17:00", "-AM/PM")
        '5:00 PM'
        
        >>> convert_24hr_time_to_12hr("17:00", "-ampm")
        '5:00pm'
        
        >>> convert_24hr_time_to_12hr("08:00", "A/P")
        '08:00 A'
        
        >>> convert_24hr_time_to_12hr("08:00", "AP")
        '08:00AM'
        
        >>> convert_24hr_time_to_12hr("00:15", "a/p")
        '12:15 a'

        >>> convert_24hr_time_to_12hr("24:00", "AM/PM")
        '12:00 AM'
    """
    # Check for no-leading-zero prefix
    strip_leading_zero = am_pm_format.startswith('-')
    if strip_leading_zero:
        am_pm_format = am_pm_format[1:]  # Remove the '-' prefix
    
    # Validate am_pm_format parameter (after stripping prefix)
    valid_formats = ["AM/PM", "am/pm", "A/P", "a/p", "AMPM", "ampm", "AP", "ap"]
    if am_pm_format not in valid_formats:
        raise ValueError(
            f"Invalid am_pm_format: '{am_pm_format}' (after removing '-' prefix if present). "
            f"Supported formats are: {', '.join(valid_formats)} or any with '-' prefix for no leading zero"
        )

    # Handle special case: 24:00 represents midnight (00:00)
    if time_24hr_str == "24:00":
        time_24hr_str = "00:00"

    # Parse the 24-hour time string into a datetime object
    # %H for 24-hour format (00-23), %M for minutes (00-59)
    time_object = datetime.strptime(time_24hr_str, "%H:%M")

    # Format the datetime object into a 12-hour string
    # %I for 12-hour format (01-12), %M for minutes, %p for AM/PM
    time_12hr_str = time_object.strftime("%I:%M %p")

    # Apply the requested AM/PM format transformation
    if am_pm_format == "am/pm":
        # Convert "AM" to "am" and "PM" to "pm" (with space)
        time_12hr_str = time_12hr_str.replace(" AM", " am").replace(" PM", " pm")
    elif am_pm_format == "A/P":
        # Convert "AM" to "A" and "PM" to "P" (with space)
        time_12hr_str = time_12hr_str.replace(" AM", " A").replace(" PM", " P")
    elif am_pm_format == "a/p":
        # Convert "AM" to "a" and "PM" to "p" (with space)
        time_12hr_str = time_12hr_str.replace(" AM", " a").replace(" PM", " p")
    elif am_pm_format == "AMPM":
        # Remove space for "AMPM" format
        time_12hr_str = time_12hr_str.replace(" AM", "AM").replace(" PM", "PM")
    elif am_pm_format == "ampm":
        # Convert to lowercase and remove space
        time_12hr_str = time_12hr_str.replace(" AM", "am").replace(" PM", "pm")
    elif am_pm_format == "AP":
        # Convert to single letter and remove space (uppercase)
        time_12hr_str = time_12hr_str.replace(" AM", "AM").replace(" PM", "PM")
    elif am_pm_format == "ap":
        # Convert to single letter and remove space (lowercase)
        time_12hr_str = time_12hr_str.replace(" AM", "a").replace(" PM", "p")
    # "AM/PM" format needs no transformation (default strftime output)
    
    # Strip leading zero from hour if requested
    if strip_leading_zero and time_12hr_str[0] == '0':
        time_12hr_str = time_12hr_str[1:]  # Remove leading zero
    
    return time_12hr_str


def convert_ui_time_to_24hr(time_string):
    """
    Converts time from UI format (12hr or 24hr) to 24hr format for verification/comparison.

    This function intelligently detects the time format and converts accordingly:
    - If time is in 12hr format (contains 'a' or 'p'): Converts to 24hr format
    - If time is already in 24hr format: Returns as-is
    - Handles overnight shifts with dash prefix (e.g., "- 05:00p" → "05:00")

    Args:
        time_string (str): Time string in either 12hr UI format (e.g., "08:00a", "- 05:00p")
                          or 24hr format (e.g., "08:00")

    Returns:
        str: Time in 24hr format (HH:MM)

    Raises:
        ValueError: If time_string is not in a recognizable format

    Examples:
        >>> convert_ui_time_to_24hr("08:00a")
        '08:00'

        >>> convert_ui_time_to_24hr("- 05:00p")
        '17:00'

        >>> convert_ui_time_to_24hr("08:00")
        '08:00'

        >>> convert_ui_time_to_24hr("- 16:00")
        '16:00'
    """
    # Check if time is in 12hr format (contains 'a' or 'p')
    is_12hr_format = "a" in time_string.lower() or "p" in time_string.lower()

    if is_12hr_format:
        # Strip dash and spaces (used for overnight shifts like "- 05:00p")
        time_clean = time_string.replace("-", "").strip()
        # Convert from 12hr to 24hr format
        time_24hr = datetime.strptime(
            time_clean.replace("a", " AM").replace("p", " PM"), "%I:%M %p"
        ).strftime("%H:%M")
    else:
        # Already in 24hr format, strip dash and spaces (used for overnight shifts like "- 16:00")
        time_24hr = time_string.replace("-", "").strip()

    return time_24hr


# Example usage demonstrating all supported formats:
# if __name__ == "__main__":
#     # Test cases with different times
#     test_times = ["08:00", "14:30", "00:15", "12:00", "00:00", "24:00"]

#     # Test all supported formats
#     formats = ["AM/PM", "am/pm", "A/P", "a/p"]

#     print("=" * 70)
#     print("Time Conversion Examples - All Supported Formats")
#     print("=" * 70)

#     for time_24hr in test_times:
#         print(f"\n24-hour time: {time_24hr}")
#         print("-" * 50)
#         for fmt in formats:
#             time_12hr = convert_24hr_time_to_12hr(time_24hr, fmt)
#             print(f"  Format '{fmt:6}' -> {time_12hr}")

#     print("\n" + "=" * 70)
