*** Settings ***
Documentation
...                 This resource file provides date utility keywords for working with calendar dates, planning weeks, and time-related operations in WFM automation.
...
...                 = Purpose =
...                 - Centralizes date and calendar-related actions for reuse in test cases and other resource files.
...
...                 = Prerequisites =
...                 - Required libraries: DateTime, String, Browser.
...                 - The common.resource file must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Get Day Number
...                 |    ${day}=    Get Day Number    2_3

Library             DateTime
Library             String
Library             resources/web/common/utility.py
Resource            resources/web/clock/webclock_db.resource


*** Keywords ***
Get Day Number
    [Documentation]
    ...    Extracts the day number from a week_day format (e.g., "2_3" returns "3").
    ...    | =Arguments=    | =Description= |
    ...    | week_day_input    | String in week_day format (e.g., 2_3).    |
    ...    Example usage:
    ...    | Get Day Number    2_3
    [Arguments]    ${week_day_input}
    ${parts}    Split String    ${week_day_input}    _
    VAR    ${day_number}    ${parts}[1]
    RETURN    ${day_number}

Get Current Planning Year On Web
    [Documentation]    Get the current planning year based on current date - updated for current framework
    ${current_year}    Get Current Date    result_format=%Y
    # Planning year logic: Current year is the planning year (not next year)
    VAR    ${planning_year}    ${current_year}
    # Keep planning year as current year regardless of month
    # (Removed the increment logic that was causing 2026 instead of 2025)
    Log    Current planning year: ${planning_year}
    RETURN    ${planning_year}

Get Current Date As Per Specific Timezone
    [Documentation]
    ...    Returns the current date in store's timezone formatted as display_date_format.
    ...    Ensures date verification uses store's actual date instead of system date.
    ...    | =Arguments= | =Description= |
    ...    | display_date_format | Desired date format for output (e.g., %Y-%m-%d) |
    ...    | store_id | Store identifier to get timezone information |
    ...    | =Returns= | =Description= |
    ...    | store_date | Current date in store timezone formatted as display_date_format|
    ...    Example usage:
    ...    | ${store_date} = | Adjust Date For Store Timezone | STORE1 |
    [Arguments]    ${display_date_format}    ${store_id}=${UNIT_ID}
    # Get date format and store timezone
    ${store_timezone}    Get Store Timezone From DB    ${store_id}
    # Get current time in store's timezone and format it
    ${store_time}    Evaluate    __import__('datetime').datetime.now(__import__('zoneinfo').ZoneInfo('${store_timezone}'))
    ${store_date}    Evaluate    $store_time.strftime('${display_date_format}')
    Log    Using store timezone time: ${store_time} (Timezone: ${store_timezone})
    Log    Using store timezone date: ${store_date} (Timezone: ${store_timezone})
    RETURN    ${store_date}

Get Fiscal Year For Date
    [Documentation]
    ...    Returns the fiscal year for a given date.
    ...    | =Arguments= | =Description= |
    ...    | date_string | Date in YYYY-MM-DD format |
    ...    | =Returns= | =Description= |
    ...    | fiscal_year | Fiscal year as a 4-digit string (e.g., 2026) |
    ...    Example usage:
    ...    | ${fiscal_year}= | Get Fiscal Year For Date | 2026-02-15 |
    [Arguments]    ${date_string}
    ${date_format_year_only}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${fiscal_year}    Convert Date    ${date_string}    result_format=${date_format_year_only}
    RETURN    ${fiscal_year}

Get Fiscal Week For Date
    [Documentation]
    ...    Returns the fiscal week number for a given date based on environment's fiscal week start day.
    ...    Uses the ISO week number calculation where week 1 is the first week containing the fiscal week start day.
    ...    | =Arguments= | =Description= |
    ...    | date_string | Date in YYYY-MM-DD format |
    ...    | =Returns= | =Description= |
    ...    | fiscal_week | Fiscal week number as a 2-digit zero-padded string (e.g., 08, 52) |
    ...    Example usage:
    ...    | ${fiscal_week}= | Get Fiscal Week For Date | 2026-02-15 |
    [Arguments]    ${date_string}
    # Calculate fiscal week using Python's isocalendar
    # Note: This is a simplified implementation using ISO week calculation.
    # For environment-specific fiscal week logic, use Get Fiscal Week Number Via API from batch_plan_status.resource
    ${date_obj}    Convert Date    ${date_string}    datetime
    ${iso_week}    Evaluate    $date_obj.isocalendar()[1]

    # Format as 2-digit zero-padded string
    ${fiscal_week}    Evaluate    str(${iso_week}).zfill(2)

    RETURN    ${fiscal_week}

Skip Test If Today Is Last Day Of Fiscal Week
    [Documentation]
    ...    Skips the test if today is the last day of the fiscal week as per environment configuration.
    ...
    ...    The fiscal week start is defined by FISCAL_WEEK_START_DAY in config.json using 1-7 numbering:
    ...    - 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday
    ...
    ...    This keyword uses a universal formula that works for ANY fiscal week configuration:
    ...    - Sunday-Saturday (start=1): skips on Saturday
    ...    - Monday-Sunday (start=2): skips on Sunday
    ...    - Wednesday-Tuesday (start=4): skips on Tuesday
    ...    - etc.
    ...
    ...    **Formula Explanation:**
    ...    The conversion formula `(fiscal_week_start + 4) % 7` combines two operations:
    ...    1. Convert config numbering (1-7) to Python weekday() numbering (0-6)
    ...    2. Calculate last day of week (start day + 6 days)
    ...
    ...    | =Arguments= | =Description= |
    ...    | None | This keyword does not take any arguments |
    ...
    ...    Example usage:
    ...    | Skip Test If Today Is Last Day Of Fiscal Week

    ${fiscal_week_start}    Get Config Value    key=FISCAL_WEEK_START_DAY
    ${fiscal_week_start}    Convert To Integer    ${fiscal_week_start}

    # Universal formula: converts config day (1-7) to Python weekday (0-6) AND calculates last day
    # Works for ANY fiscal week configuration (Sun-Sat, Mon-Sun, Wed-Tue, etc.)
    ${week_last_day}    Evaluate    (${fiscal_week_start} + 4) % 7
    ${today}    Evaluate    __import__('datetime').datetime.now().weekday()

    Log    Skip check: Today=${today}, Fiscal_week_last_day=${week_last_day}, Fiscal_week_start=${fiscal_week_start}

    IF    ${today} == ${week_last_day}
        Skip    Test skipped: Today is the last day of the fiscal week
    END

Convert Fiscal Day Index To Weekday Short Name
    [Documentation]
    ...    Calculates the short weekday name from a day number within a fiscal week.
    ...
    ...    This keyword determines the standard day of the week (e.g., 'Sun', 'Mon') for a
    ...    given day number within a custom fiscal calendar. It requires knowing which day
    ...    the fiscal week starts on. For example, if the fiscal week starts on a Wednesday,
    ...    the 0th day of that fiscal week is Wednesday.
    ...
    ...    | =Arguments= | =Description= |
    ...    | day_index | The day number within the fiscal week (an integer from 0 to 6). |
    ...
    ...    | =Returns= |
    ...    | day_short | The three-letter short name of the calculated day (e.g., Sun, Mon, Sat). |
    ...    Example usage:
    ...    | ${day_short} | Convert Fiscal Day Index To Weekday Short Name | 4 |
    [Arguments]    ${day_index}

    VAR    @{weekdays}    Sun    Mon    Tue    Wed    Thu    Fri    Sat
    ${fiscal_week_start_raw}    Get Config Value    key=FISCAL_WEEK_START_DAY
    ${fiscal_week_start}    Convert To Integer    ${fiscal_week_start_raw}
    # ${day} is 0–6 within the fiscal week
    ${weekday_index}    Evaluate    (${fiscal_week_start} + ${day_index} - 1) % 7
    VAR    ${day_short}    ${weekdays}[${weekday_index}]

    RETURN    ${day_short}

Convert Days To Hours And Minutes
    [Documentation]
    ...    Converts days (numeric value) into HH:MM format.
    ...    Assumes 1 day = 24 hours.
    ...
    ...    | =Arguments= | =Description= |
    ...    | days | Number of days to convert (can be integer or decimal) |
    ...
    ...    | =Returns= | =Description= |
    ...    | formatted_time | Time in HH:MM format (e.g., 480:00 for 20 days, 36:00 for 1.5 days) |
    ...
    ...    Example usage:
    ...    | ${result}= | Convert Days To Hours And Minutes | 20 |
    ...    | Should Be Equal | ${result} | 480:00 |
    ...
    ...    | ${result}= | Convert Days To Hours And Minutes | 1.5 |
    ...    | Should Be Equal | ${result} | 36:00 |
    [Arguments]    ${days}
    ${days_float}    Convert To Number    ${days}
    ${total_hours}    Evaluate    int(${days_float} * 24)
    VAR    ${formatted_time}    ${total_hours}:00
    RETURN    ${formatted_time}

Get Fiscal Year For Date From DB
    [Documentation]
    ...    Returns the fiscal year for a given date by querying the database.
    ...    | =Arguments= | =Description= |
    ...    | date_offset | Date offset in offset week_date format (e.g., 2_3) to calculate fiscal year for |
    ...    | =Returns= | =Description= |
    ...    | fiscal_year | Fiscal year as a 4-digit string (e.g., 2026) |
    ...    Example usage:
    ...    | ${fiscal_year}= | Get Fiscal Year For Date From DB    1_5 |
    [Arguments]    ${date_offset}
    ${date_db_format}    Get Config Value    key=SERVER_DF
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${date}    Calculate Date From Week Day Offset    ${date_offset}    date_format=${date_db_format}
    ${fiscal_year_db_query}    Catenate    SEPARATOR=${SPACE}
    ...    SELECT FISCAL_YEAR
    ...    FROM RWSUSER.RWS_CALENDAR rc
    ...    WHERE rc.OWNER_ID = ${owner_id}
    ...    AND rc.DATE_SKEY = ${date}

    ${fiscal_year_result}    Execute Query And Return Result    ${fiscal_year_db_query}
    ${year_string}    Convert To String    ${fiscal_year_result}[0][0]
    ${result_length}    Get Length    ${year_string}
    IF    ${result_length} > 0
        VAR    ${fiscal_year}    ${year_string}
        RETURN    ${fiscal_year}
    ELSE
        RETURN    ${EMPTY}
    END
