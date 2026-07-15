*** Settings ***
Documentation       This is the global documentation for the test suite. Needs to be Updated

Library             DateTime
Library             String
Library             SSHLibrary
Library             JSONLibrary
Resource            resources/web/common/common.resource


*** Keywords ***
Get Value For JSONPath
    [Documentation]    Get value of the jsonpath provided from mentioned json object.
    [Arguments]    ${json_object}    ${json_path}
    ${jsonpath_value}    Get Value From Json    ${json_object}    ${json_path}
    IF    len(${jsonpath_value}) == 0
        FAIL    JSONPath ${json_path} not found in JSON Object
    END
    RETURN    ${jsonpath_value[0]}

Find Text With Pattern
    [Documentation]    Get value for the mentioned regex from the provided string.
    [Arguments]    ${string_value}    ${regex}
    ${value_in_list}    Get Regexp Matches    ${string_value}    pattern=${regex}
    RETURN    ${value_in_list}[0]

Update Locator With Dynamic Values
    [Documentation]    Generic keyword to update locator with any number of placeholder values.
    ...    Uses Format String for safe parameter substitution.
    ...    Handles non-breaking spaces and preserves formatting.
    ...
    ...    Example usage:
    ...    ${locator_var}=    Update Locator With Dynamic Values    ${xpath_template}
    ...    ...    FORMATTED_DATE=${date}    ASSOCIATE_NAME=${name}    START_TIME=${start}    END_TIME=${end}
    [Arguments]    ${locator}    ${preserve_spaces}=${True}    &{values}

    # Determine replacement character based on preserve_spaces flag
    IF    ${preserve_spaces}
        VAR    ${space_replacement}    ${SPACE}
    ELSE
        VAR    ${space_replacement}    ${EMPTY}
    END

    VAR    &{normalized_values}    &{EMPTY}
    FOR    ${key}    ${value}    IN    &{values}
        ${normalized_value}    Replace String    ${value}    \xa0    ${space_replacement}
        Set To Dictionary    ${normalized_values}    ${key}=${normalized_value}
    END

    ${updated_locator}    Format String    ${locator}    &{normalized_values}

    ${final_locator}    Replace String    ${updated_locator}    \xa0    ${space_replacement}
    RETURN    ${final_locator}

Normalize Time String Format
    [Documentation]    Normalizes time format to handle differences between leading zeros (04:15 vs 4:15)
    ...    and treats zero values (00:00 or 0:00) as equivalent for comparison purposes.
    ...    This ensures consistent time comparisons across different UI elements.
    ...
    ...    | =Arguments= | =Description= |
    ...    | time_string | Time string to normalize (e.g., "04:15", "4:15", "00:00", "0:00") |
    ...
    ...    Returns the normalized time string for consistent comparison.
    [Arguments]    ${time_string}
    ${trimmed_time}    Strip String    ${time_string}
    IF    '${trimmed_time}' == '' or '${trimmed_time}' == 'None' or '${trimmed_time}' == 'null'
        RETURN    0:00
    END
    IF    '${trimmed_time}' == '0:00' or '${trimmed_time}' == '00:00' or '${trimmed_time}' == '0'
        RETURN    0:00
    END
    TRY
        ${time_parts}    Split String    ${trimmed_time}    :
        ${hours}    Strip String    ${time_parts}[0]
        ${minutes}    Strip String    ${time_parts}[1]
        ${normalized_hours}    Evaluate    int('${hours}')
        ${normalized_minutes}    Evaluate    int('${minutes}')
        ${normalized_time}    Evaluate    f"{${normalized_hours}}:{${normalized_minutes}:02d}"
        RETURN    ${normalized_time}
    EXCEPT
        RETURN    ${trimmed_time}
    END

Reorder Days By Fiscal Week
    [Documentation]    Reorder day_number fields based on fiscal week start day while preserving timing patterns.
    ...    Only changes the day_number to match fiscal week ordering, keeps original availability
    ...    and timing patterns intact.
    ...    | =Arguments= | =Description= |
    ...    | days_list | List of day objects with availability data |
    ...    | day_number_field | Field name that contains the day number (default: day_number) |
    ...    | =Returns= | =Description= |
    ...    | reordered_list | List with day_number fields reordered based on fiscal week start |
    ...    Example usage:
    ...    | ${reordered_days}=    Reorder Days By Fiscal Week    ${availability_hours_list}    day_number
    [Arguments]    ${days_list}    ${day_number_field}=day_number
    ${fiscal_week_start_day}    Get Config Value    key=FISCAL_WEEK_START_DAY
    ${fiscal_week_start_day}    Convert To Integer    ${fiscal_week_start_day}

    Log    Reordering day numbers based on fiscal week start day: ${fiscal_week_start_day}    DEBUG

    # Generate the new day number ordering based on fiscal week start day
    # fiscal_week_start_day: 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday
    VAR    @{fiscal_order}    @{EMPTY}
    FOR    ${i}    IN RANGE    7
        ${day_num}    Evaluate    ((${fiscal_week_start_day} - 1 + ${i}) % 7) + 1
        Append To List    ${fiscal_order}    ${day_num}
    END
    # Create the reordered list by assigning new day numbers while keeping original data
    VAR    @{reordered_days}    @{EMPTY}
    ${days_length}    Get Length    ${days_list}
    ${fiscal_length}    Get Length    ${fiscal_order}
    FOR    ${i}    IN RANGE    ${days_length}
        ${day}    Get From List    ${days_list}    ${i}
        IF    ${i} < ${fiscal_length}
            # Copy the day object and update only the day_number
            ${day_obj}    Copy Dictionary    ${day}
            ${new_day_num}    Get From List    ${fiscal_order}    ${i}
            Set To Dictionary    ${day_obj}    ${day_number_field}    ${new_day_num}
            Append To List    ${reordered_days}    ${day_obj}
        END
    END

    VAR    @{reordered_day_numbers}    @{EMPTY}
    FOR    ${d}    IN    @{reordered_days}
        ${day_num}    Get From Dictionary    ${d}    ${day_number_field}
        Append To List    ${reordered_day_numbers}    ${day_num}
    END

    RETURN    ${reordered_days}

Convert Time To Decimal Hours
    [Documentation]    Converts a time/duration string to decimal hours. Supports both 24-hour
    ...    (HH:MM) and 12-hour (HH:MM AM/PM) formats.
    ...    Used for range validation where exact time matching is not required.
    ...    | =Arguments= | =Description= |
    ...    | time_string | Time in 24-hour "HH:MM" (e.g., "7:30", "13:15") or 12-hour "HH:MM AM/PM" (e.g., "07:30 PM", "9:00pm", "12:00 AM"). |
    ...    | =Returns= | =Description= |
    ...    | decimal_hours | Decimal representation of hours (e.g., 7.5, 8.0, 0.75) |
    ...
    ...    Example usage:
    ...    | ${decimal}=    Convert Time To Decimal Hours    7:30
    ...    | # Returns 7.5
    ...    | ${decimal}=    Convert Time To Decimal Hours    07:30 PM
    ...    | # Returns 19.5
    [Arguments]    ${time_string}
    ${trimmed_time}    Strip String    ${time_string}
    ${normalized_time}    Replace String    ${trimmed_time}    (    ${EMPTY}
    ${normalized_time}    Replace String    ${normalized_time}    )    ${EMPTY}
    ${normalized_time}    Strip String    ${normalized_time}
    # Handle empty or null values
    IF    '${normalized_time}' == '' or '${normalized_time}' == 'None' or '${normalized_time}' == 'null'
        RETURN    0.0
    END
    # Handle zero values
    IF    '${normalized_time}' == '0:00' or '${normalized_time}' == '00:00' or '${normalized_time}' == '0'
        RETURN    0.0
    END
    ${upper_time}    Convert To Upper Case    ${normalized_time}
    # Detect a 12-hour clock suffix: AM/PM or single-letter A/P (any case)
    ${meridiem_matches}    Get Regexp Matches    ${upper_time}    (AM|PM|A|P)\\s*$
    TRY
        IF    ${meridiem_matches}
            # 12-hour format: normalize suffix to AM/PM and parse with strptime
            ${is_pm}    Evaluate    'PM' in '''${upper_time}''' or '''${upper_time}'''.rstrip().endswith('P')
            ${suffix}    Set Variable If    ${is_pm}    PM    AM
            ${time_part}    Replace String Using Regexp    ${upper_time}    \\s*(AM|PM|A|P)\\s*$    ${EMPTY}
            ${time_part}    Strip String    ${time_part}
            ${parsed_time}    Evaluate    datetime.datetime.strptime('${time_part} ${suffix}', '%I:%M %p')    datetime
            ${decimal_hours}    Evaluate    ${parsed_time.hour} + (${parsed_time.minute} / 60.0)
        ELSE
            # 24-hour format / duration: split on ':'
            ${time_parts}    Split String    ${normalized_time}    :
            ${hours}    Strip String    ${time_parts}[0]
            ${minutes}    Strip String    ${time_parts}[1]
            ${hours_int}    Convert To Integer    ${hours}
            ${minutes_int}    Convert To Integer    ${minutes}
            ${decimal_hours}    Evaluate    ${hours_int} + (${minutes_int} / 60.0)
        END
        RETURN    ${decimal_hours}
    EXCEPT    AS    ${error}
        Log    Failed to convert time '${time_string}' to decimal hours: ${error}    WARN
        RETURN    0.0
    END
