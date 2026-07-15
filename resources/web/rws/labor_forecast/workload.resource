*** Settings ***
Documentation       This resource file provides keywords for activity-based workload verification on the Workload page.
...
...                 = Purpose =
...                 - Centralizes actions for verifying workload hours by activity and day.
...
...                 = Prerequisites =
...                 - Required libraries and variable files must be available and imported.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/labor_forecast/workload_page.py


*** Keywords ***
Get Activity Workload Hours For Day On Workload Page On Web
    [Documentation]    Gets workload hours for a specific activity on a given day using positional locator.
    ...    This keyword uses the aria-label attribute and positional index to locate and extract workload hours.
    ...    Returns hours in format like '8.00' or '0.00'.
    ...    | =Arguments= | =Description= |
    ...    | activity_name | Name of the activity (e.g., 'UK_STORE', 'CHECKOUT') |
    ...    | day_index | Day index (1-7) where 1=Sunday, 2=Monday, etc. |
    ...    | =Returns= | =Description= |
    ...    | workload_hours | Workload hours for the activity on the specified day |
    ...
    ...    Example usage:
    ...    | ${hours}=    Get Activity Workload Hours For Day On Workload Page On Web    UK_STORE    1
    [Arguments]    ${activity_name}    ${day_index}
    ${day_index}    Convert To Integer    ${day_index}

    # Build dynamic locator using activity name and positional day index
    ${activity_workload_locator}    Update Locator With Dynamic Values
    ...    ${WORKLOAD_PAGE_ACTIVITY_WORKLOAD_BY_DAY}    ACTIVITY_NAME=${activity_name}    DAY_NUMB=${day_index}

    TRY
        Wait Until Element Is Present On Webpage    ${activity_workload_locator}    timeout=${MEDIUM_TIMEOUT}
        ${workload_hours}    Get Element Text On Webpage    ${activity_workload_locator}
        # The element returns hours like '8.00', normalize to '8:00' format
        ${workload_hours}    Strip String    ${workload_hours}
        # Convert decimal format (8.00) to HH:MM format (8:00) by replacing '.' with ':'
        ${hours_minutes}    Split String    ${workload_hours}    .
        ${hours}    Get From List    ${hours_minutes}    0
        IF    len(${hours_minutes}) > 1
            VAR    ${minutes}    ${hours_minutes}[1]
        ELSE
            VAR    ${minutes}    00
        END
        VAR    ${workload_hours_formatted}    ${hours}:${minutes}
        RETURN    ${workload_hours_formatted}
    EXCEPT    AS    ${error}
        Log    Failed to get workload hours for activity ${activity_name} on day index ${day_index}: ${error}    WARN
        RETURN    0:00
    END

Build Expected Workload Hours Dictionary For Multiple Days On Workload Page On Web
    [Documentation]    Builds a workload hours dictionary for multiple days for workload page verification.
    ...    This helper creates a dictionary with day offsets as keys and hour values.
    ...    | =Arguments= | =Description= |
    ...    | week_offset | Week number (e.g., '1' or '2'). |
    ...    | hours_value | Expected hours value (e.g., '8:00' or '0:00'). |
    ...    | day_numbers | Variable number of day numbers (e.g., 1, 2, 3, 4, 5). |
    ...
    ...    *Returns*: Dictionary with day_offset keys and hour values.
    ...
    ...    Example usage:
    ...    | ${expected}=    Build Expected Workload Hours Dictionary For Multiple Days On Workload Page On Web
    ...    | ...    1    8:00    1    3    4    5    7
    ...    | Set To Dictionary    ${expected}    1_2=0:00    1_6=0:00
    [Arguments]    ${week_offset}    ${hours_value}    @{day_numbers}
    VAR    ${expected_hours_dict}    &{EMPTY}
    FOR    ${day_num}    IN    @{day_numbers}
        VAR    ${day_offset}    ${week_offset}_${day_num}
        Set To Dictionary    ${expected_hours_dict}    ${day_offset}=${hours_value}
    END
    RETURN    ${expected_hours_dict}

Verify Activity Workload Hours For Multiple Days On Workload Page On Web
    [Documentation]    Verifies workload hours for a specific activity across multiple days.
    ...    This keyword validates activity-based workload hours using a data-driven approach.
    ...    Supports both exact matching and range validation.
    ...    | =Arguments= | =Description= |
    ...    | activity_name | Name of the activity to verify (e.g., 'UK_STORE', 'CHECKOUT') |
    ...    | expected_hours_dict | Dictionary with day_offset keys (e.g., '1_1', '1_2') and expected hour values (e.g., '8:00'). |
    ...    | min_hours | Minimum acceptable hours in decimal format (e.g., 0.0). Optional. |
    ...    | max_hours | Maximum acceptable hours in decimal format (e.g., 8.5). Optional. |
    ...
    ...    Example usage (exact match):
    ...    | ${expected}=    Build Expected Workload Hours Dictionary For Multiple Days On Workload Page On Web
    ...    | ...    1    8:00    1    3    4    5    7
    ...    | Set To Dictionary    ${expected}    1_2=0:00    1_6=0:00
    ...    | Verify Activity Workload Hours For Multiple Days On Workload Page On Web    UK_STORE    ${expected}
    ...
    ...    Example usage (range validation):
    ...    | Verify Activity Workload Hours For Multiple Days On Workload Page On Web
    ...    | ...    UK_STORE    ${expected}    min_hours=7.5    max_hours=8.5
    [Arguments]    ${activity_name}    ${expected_hours_dict}    ${min_hours}=${None}    ${max_hours}=${None}
    Wait Until Page Is Loaded    ${PAGE_LOAD_TIMEOUT}
    VAR    ${use_range_validation}    ${{$min_hours is not None and $max_hours is not None}}
    VAR    @{day_offsets}    @{expected_hours_dict.keys()}
    FOR    ${day_offset}    IN    @{day_offsets}
        ${expected_hours}    Get From Dictionary    ${expected_hours_dict}    ${day_offset}
        ${day_num}    Split String    ${day_offset}    _
        ${day_num}    Get From List    ${day_num}    1
        # Template day numbers are 0-based; XPath positional index is 1-based — add 1 to convert.
        ${day_index_1based}    Evaluate    int($day_num) + 1
        ${actual_hours}    Get Activity Workload Hours For Day On Workload Page On Web    ${activity_name}    ${day_index_1based}

        IF    ${use_range_validation}
            ${actual_decimal}    Convert Time To Decimal Hours    ${actual_hours}
            Should Be True    ${actual_decimal} >= ${min_hours} and ${actual_decimal} <= ${max_hours}
            ...    msg=Day ${day_offset}: Activity ${activity_name} workload hours ${actual_hours} (${actual_decimal} hrs) is outside range ${min_hours}-${max_hours} hrs
            Log    ✓ Day ${day_offset}: Activity ${activity_name} workload=${actual_hours} (${actual_decimal} hrs) is within range
            ...    level=INFO
        ELSE
            ${expected_normalized}    Normalize Time String Format    ${expected_hours}
            ${actual_normalized}    Normalize Time String Format    ${actual_hours}
            Should Be Equal    ${actual_normalized}    ${expected_normalized}
            ...    msg=Day ${day_offset}: Activity ${activity_name} expected workload hours ${expected_hours}, got ${actual_hours}
            Log    ✓ Day ${day_offset}: Activity ${activity_name} workload=${actual_hours}    level=INFO
        END
    END
