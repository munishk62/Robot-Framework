import os
from enum import Enum
import locale
import subprocess
from datetime import datetime
import re

import yaml
from adbutils import AdbClient

base_directory = os.path.abspath("")


def generate_date_format(is_dd_mm: bool):
    """
    Dynamically generates an Enum for date format based on the given condition.
    """

    # SERVER_DF - 20241118
    # FULL_DATE_DF - Monday, November 18, 2024
    # FULL_DATE_SPACE_DF - Monday November 18 2024
    # FULL_DATE_DF_WITHOUT_COMMA - Tuesday 17 December 2024
    # FULL_DATE_DF_WITH_ONE_COMMA - Tuesday, 17 December
    # FULL_DATE_DF_SHORT - Monday, 18 Nov 2024
    # DATE_DF - November 18, 2024
    # SHORT_DATE_DF - Nov 18, 2024
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
    # TIME_FORMAT - 14:30
    # FULL_DATE_WITH_COMMA - Sat, Feb 15, 2025
    # SHORT_DAY_DF - Tue
    # LONG_DAY_DF - Tuesday
    # SHORT_MONTH_DF - Nov
    # MONTH_YEAR - November 2024
    # H_DATE_DF-13 Jul 2025
    # FULL_MONTH_DATE_DF - June 08 2025
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
            LONG_DAY_DF = "%A"
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
            H_DATE_DF = "%d %b %Y"
            SHORT_DAY_DATE_DF = "%a %d"
            FULL_DAY_DF = "%A"
            FULL_MONTH_DATE_DF = "%d %B %Y"

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
            LONG_DAY_DF = "%A"
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
            H_DATE_DF = "%d %b %Y"
            SHORT_DAY_DATE_DF = "%a %d"
            FULL_DAY_DF = "%A"
            FULL_MONTH_DATE_DF = "%B %d %Y"

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


def _xpath_escape(text: str) -> str:
    """Escape a string for safe use inside XPath expressions.

    If the text contains an apostrophe, it is wrapped using XPath ``concat()``
    so that the expression remains valid.  Otherwise the text is simply wrapped
    in single quotes.

    Args:
        text: The raw string value to embed in an XPath expression.

    Returns:
        An XPath-safe string literal (e.g. ``'hello'`` or ``concat('it',\"'\",'s')``).
    """
    if "'" not in text:
        return f"'{text}'"
    parts = text.split("'")
    escaped = ",\"'\",".join(f"'{p}'" for p in parts)
    return f"concat({escaped})"


def get_locator_value(
    semantic_label: str,
    platform_variable: str,
    strategy: LocatorStrategy = LocatorStrategy.CONTAINS,
) -> str:
    """
    Generates an XPath locator string based on the platform and semantic label.

    This function creates an XPath expression to locate elements dynamically
    depending on the platform. For Android, it uses `content-desc` as the attribute,
    while for other platforms (e.g. iOS), it uses `label`.

    Handles semantic labels containing apostrophes by using XPath ``concat()``.

    Args:
            semantic_label (str): The semantic label or accessibility label for the element.
            platform_variable (str): The target platform, e.g. 'android', 'ios' etc.
            strategy (LocatorStrategy): The strategy to use for the locator (CONTAINS or EXACT).
    Returns:
            str: The generated XPath string for the specified platform and semantic label.

    Raises:
            ValueError: If the platform_variable is not recognized.

    Examples:
            For Android:
                    >>> get_locator_value("login_button", "android", LocatorStrategy.CONTAINS)
                    "//*[contains(@content-desc,'login_button')]"

            For iOS:
                    >>> get_locator_value("login_button", "ios", LocatorStrategy.EXACT)
                    "//*[@label='{semantic_label}']"
    """
    escaped = _xpath_escape(semantic_label)

    if strategy == LocatorStrategy.EXACT:
        if platform_variable == 'android':
            return f"//*[normalize-space(@content-desc)={escaped}] | //*[@text={escaped}]"
        elif platform_variable == 'ios':
            # iOS production-grade locator (works without the dev_utils healer).
            #
            # Attribute priority:
            #   1) @name  -> accessibility identifier, most stable iOS id (set
            #      by developers; calendar cells like "Tuesday, June 30, 2026",
            #      buttons like "btnStart" use @name).
            #   2) @label -> visible text fallback (some controls only set @label).
            #
            # Visibility filter — `not(@visible='false')` is intentional, NOT
            # `@visible='true'`:
            #   * WebDriverAgent (the iOS backend) sometimes omits the @visible
            #     attribute on a node, depending on view type / WDA version /
            #     snapshotMaxDepth. With `@visible='true'`, such a node matches
            #     **nothing** -> ElementNotFound.
            #   * XPath treats `@visible='false'` on a node that has no @visible
            #     attribute as false (empty node-set vs string comparison), so
            #     `not(@visible='false')` evaluates to true and the node is
            #     included. Explicitly hidden nodes (@visible='false') are
            #     correctly excluded.
            #   * Result: visible duplicates are filtered out; nodes without a
            #     @visible attribute are still found (graceful degradation).
            #
            # XPath `|` returns a unique node-set, so overlapping branches do
            # not produce duplicate matches for the same element.
            return (
                f"//*[@name={escaped} and not(@visible='false')]"
                f" | //*[normalize-space(@label)={escaped} and not(@visible='false')]"
            )
        else:
            raise ValueError(f"Unsupported platform: {platform_variable}")

    if strategy == LocatorStrategy.CONTAINS:
        if platform_variable == 'android':
            return f"//*[contains(@content-desc,{escaped})] | //*[contains(normalize-space(@content-desc),{escaped})] | //*[contains(normalize-space(@text),{escaped})]"
        elif platform_variable == 'ios':
            # See EXACT branch for the rationale on @name-first ordering and
            # why `not(@visible='false')` is used as the visibility filter
            # instead of `@visible='true'`.
            return (
                f"//*[contains(@name,{escaped}) and not(@visible='false')]"
                f" | //*[contains(@label,{escaped}) and not(@visible='false')]"
                f" | //*[contains(normalize-space(@label),{escaped}) and not(@visible='false')]"
            )
        else:
            raise ValueError(f"Unsupported platform: {platform_variable}")


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
    day_index = convert_dx_to_index(d_code, first_day_of_week)
    if day_format == DayFormat.SHORT:
        return days_short[day_index]
    elif day_format == DayFormat.MEDIUM:
        return days_medium[day_index]
    elif day_format == DayFormat.LONG:
        return days_large[day_index]


def convert_dx_to_index(d_code: str, first_day_of_week: int) -> int:
    """
    Convert 1, 2, ... to a day of the week based on the first day of the week.
    :param d_code: String like '0','1', '2', ...
    :param first_day_of_week: The first day of the week (1 = Sunday, 2 = Monday, ...)
    :return: Day name localizable key based on DayFormat.
    """
    first_day_index = (first_day_of_week - 1) % 7
    day_number = int(d_code)
    day_index = (first_day_index + day_number) % 7
    return day_index


def convert_dx_to_day_for_nativeSM(
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
        "1000000000922",
        "1000000000923",
        "1000000000924",
        "1000000000925",
        "1000000000926",
        "1000000000927",
        "1000000000928",
    ]
    days_medium = [
        "1000000000186",
        "1000000000187",
        "1000000000188",
        "1000000000189",
        "1000000000190",
        "1000000000191",
        "1000000000192",
    ]
    days_large = [
        "1000000000321",
        "1000000000322",
        "1000000000323",
        "1000000000324",
        "1000000000325",
        "1000000000326",
        "1000000000327",
    ]

    first_day_index = (first_day_of_week - 1) % 7

    day_number = int(d_code) - 1

    day_index = (first_day_index + day_number) % 7

    if day_format == DayFormat.SHORT:
        return days_short[day_index]
    elif day_format == DayFormat.MEDIUM:
        return days_medium[day_index]
    elif day_format == DayFormat.LONG:
        return days_large[day_index]


def check_and_uninstall_app(app_package):
    """
    Checks if the specified app is installed on the device and uninstalls it if it is.
    Args:
        app_package:
            The package name of the app to check and uninstall.
    """
    if not re.match(r"^[a-zA-Z0-9._-]+$", app_package):
        raise ValueError("Invalid package name")
    client = AdbClient(host="127.0.0.1", port=5037)
    devices = client.device_list()
    if len(devices) > 0:
        device = devices[0]
        output = device.shell("pm list packages {}".format(app_package))
        if output:
            device.uninstall(app_package)


def format_date_without_leading_zero(date, date_format):
    day = date.day
    formatted_date = date.strftime(date_format.value).replace("{day}", str(day))
    return formatted_date


def format_date_locale(date, from_format, to_format, locale_name):
    date_obj = datetime.strptime(date, from_format).date()
    locale.setlocale(locale.LC_TIME, locale_name)
    # Format date in localized output format
    return date_obj.strftime(to_format)


def get_connected_ios_device_udid():
    """Return the UDID of a physically connected real iOS device.

    Runs ``xcrun xctrace list devices`` and inspects only the real-device
    section (everything before the ``== Simulators ==`` header), so simulators
    are never matched. Real-device UDIDs match either the modern 25-character
    format (``00008150-0001615011EB401C``) or the legacy 40-hex format. The
    host Mac, whose identifier is a standard ``8-4-4-4-12`` UUID, is ignored
    because it matches neither pattern.

    | =Returns= | =Description= |
    | udid | UDID of the first connected real iOS device, or an empty string when none is attached or detection fails (e.g. ``xctrace`` unavailable). |

    Example usage:
    | ${udid}=    Get Connected Ios Device Udid
    """
    real_device_pattern = re.compile(
        r"\(([0-9A-Fa-f]{8}-[0-9A-Fa-f]{16}|[0-9a-f]{40})\)\s*$"
    )
    try:
        result = subprocess.run(
            ["xcrun", "xctrace", "list", "devices"],
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
    except (FileNotFoundError, OSError, subprocess.SubprocessError):
        # xctrace missing (no Xcode) or the call failed; let caller fall back.
        return ""

    for line in (result.stdout or "").splitlines():
        stripped = line.strip()
        # Stop at the simulator section; only physically attached devices count.
        if stripped.startswith("== Simulators =="):
            break
        if not stripped or stripped.startswith("=="):
            continue
        match = real_device_pattern.search(stripped)
        if match:
            return match.group(1)
    return ""


def load_yaml(yaml_path):
    """
    Load configuration from a YAML file.
    Args:
        yaml_path:
    Returns:
        dict: Parsed configuration data
    """
    normalised_path = os.path.normpath(os.path.join(base_directory, yaml_path))
    sanitised_file = os.path.abspath(normalised_path)
    if not sanitised_file.startswith(base_directory):
        raise ValueError(
            f"The file path '{sanitised_file}' is outside the allowed base directory '{base_directory}'."
        )
    if not os.path.exists(sanitised_file):
        raise ValueError(f"The file '{sanitised_file}' does not exist.")

    with open(sanitised_file, "r") as f:
        return yaml.safe_load(f)
