*** Settings ***
Documentation       This resource file contains common keywords used across SM app.

Library             DateTime
Library             OperatingSystem
Library             CSVLib
Library             utils/common_utility/utility.py
Variables           resources/Mobile/SM/Locators/SM_Common.py
Variables           resources/Mobile/SM/Locators/Associate_Roster_Page.py
Variables           resources/Mobile/SM/Locators/Common_Page.py
Resource            resources/Mobile/Common/Mobile_Device_Helper.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Common/Localised_Locator.resource


*** Keywords ***
Prepare Mobile SM App For Suite Execution
    [Documentation]    This keyword prepares the mobile SM app for suite execution by performing necessary setup steps.
    ...    Example:
    ...    - Prepare Mobile SM App For Suite Execution
    [Arguments]    ${qr_code}=None
    IF    '${qr_code}' == 'None'
        ${qr_code}    Get Config Value    qr_code
    END
    Clear Registration Data On Mobile SM App
    Register Mobile SM App With QR Code    ${qr_code}

Select Date On SM Calendar
    [Documentation]    Selects the date on the calendar.
    ...    Arguments:
    ...    - ${localised_locator}: The localised locator for the calendar tap to open.
    ...    - ${select_date}: The x_y date to be selected on the calendar.
    ...    - ${calendar_open_date}: The current x_y open date on the calendar.
    ...    - ${is_offset_format}: Flag to check if open date on the calendar is passed in x_y format or YYYYMMdd (20241222) format
    [Arguments]    ${localised_locator}    ${select_date}    ${calendar_open_date}=${None}    ${is_offset_format}=True
    ${server_df_format}    Get Config Value    SERVER_DF
    IF    '${calendar_open_date}' == '${None}'
        ${calendar_open_date_converted}    Get Current Date    result_format=${server_df_format}
    ELSE IF    '${is_offset_format}' == 'True'
        ${calendar_open_date_converted}    Calculate Date From Week Day Offset
        ...    ${calendar_open_date}
        ...    ${server_df_format}
    ELSE
        VAR    ${calendar_open_date_converted}    ${calendar_open_date}
    END
    Wait Until Page Contains Element    ${localised_locator}
    Click Element    ${localised_locator}
    Navigate SM Calendar To    ${select_date}    ${calendar_open_date_converted}

Navigate SM Calendar To
    [Documentation]    Used for navigation of calendar based on current open date of calendar and required date.
    ...    Args:
    ...    ${offset_date}: <date offset in format x_y>
    ...    ${current_open_month_year}: <current open date on calendar> not in x_y format but in YYYYMMdd (20241222) format
    [Arguments]    ${offset_date}    ${current_open_month_year}
    ${source_date_format}    Get Config Value    SM_CALENDAR_COMMON_DF
    ${year_only_date_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${month_only_date_format}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${day_only_date_format}    Get Config Value    DATE_FMT_DAY_ONLY
    ${week_day_only_format}    Get Config Value    DATE_FORMAT_WEEK_DAY_ONLY
    ${readable_date}    Calculate Date From Week Day Offset In Multiple Formats
    ...    ${offset_date}
    ...    ${source_date_format}
    ...    ${year_only_date_format}
    ...    ${month_only_date_format}
    ...    ${day_only_date_format}
    ...    ${week_day_only_format}
    ${full_date}    Calculate Date From Week Day Offset    ${offset_date}    ${source_date_format}
    Log To Console    Date navigating to: ${full_date}
    VAR    ${year}    ${readable_date}[1]
    VAR    ${month}    ${readable_date}[2]
    ${month_converted}    Evaluate    datetime.datetime.strptime('${month}', '%B').month    modules=datetime
    ${current_year}    Evaluate    '${current_open_month_year}[0:4]'
    ${current_month}    Evaluate    '${current_open_month_year}[4:6]'
    ${current_month_converted}    Convert To Integer    ${current_month}
    VAR    ${next_month_locator}    ${CALENDAR_NEXT_MONTH}
    VAR    ${prev_month_locator}    ${CALENDAR_PREV_MONTH}
    VAR    ${count}    0
    IF    ${current_year} < ${year} or (${current_year} == ${year} and ${current_month_converted} < ${month_converted})
        VAR    ${next_or_previous}    ${next_month_locator}
        ${count}    Evaluate    (${month_converted}-${current_month_converted}) + ((${year} - ${current_year})*12)
    ELSE
        VAR    ${next_or_previous}    ${prev_month_locator}
        ${count}    Evaluate    (${current_month_converted}-${month_converted}) + ((${current_year} - ${year})*12)
    END
    FOR    ${_}    IN RANGE    ${count}
        Wait Until Page Contains Element    ${next_or_previous}
        Click Element    ${next_or_previous}
        IF    $next_or_previous == $next_month_locator
            IF    "${current_month_converted}" == "12"
                ${current_year}    Evaluate    ${current_year} + 1
                ${current_month_converted}    Evaluate    1
            ELSE
                ${current_month_converted}    Evaluate    ${current_month_converted} + 1
            END
        ELSE
            IF    "${current_month_converted}" == "1"
                ${current_year}    Evaluate    ${current_year} - 1
                VAR    ${current_month_converted}    12
            ELSE
                ${current_month_converted}    Evaluate    ${current_month_converted} - 1
            END
        END
    END
    ${locator}    Get Locator Contains    ${full_date}
    # Handle edge case: calendar may display the next month header (e.g. June) even
    # when the open date falls on the last day of the previous month (e.g. May 31),
    # causing count=0 while the target date is not yet visible.
    ${is_date_visible}    Run Keyword And Return Status    Wait Until Page Contains Element    ${locator}    timeout=3s
    IF    not ${is_date_visible}
        # Determine corrective direction: if we navigated forward (or didn't move at
        # all because count=0), go back; otherwise go forward.
        IF    $next_or_previous == $next_month_locator or $count == 0
            Wait Until Page Contains Element    ${CALENDAR_PREV_MONTH}    timeout=${LONG_TIMEOUT}
            Click Element    ${CALENDAR_PREV_MONTH}
        ELSE
            Wait Until Page Contains Element    ${CALENDAR_NEXT_MONTH}
            Click Element    ${CALENDAR_NEXT_MONTH}
        END
    END
    Wait Until Page Contains Element    ${locator}
    Click Element    ${locator}

Select Time On SM Time Picker
    [Documentation]    Selects the time on the time picker.
    ...    Arguments:
    ...    - ${time}: The time to be selected on the time picker in 24 hour format.
    ...    - ${prepopulated_time}: The prepopulated time on the time picker in 24 hour format (optional).
    ...    - ${isTimePickerModeDropDown}: Flag to check if time picker is in drop down mode or not for minute selection we have dropdown as default 15 min interval only has 4 options to input.
    ...    - ${tap_ok}: Flag to check if OK button needs to be tapped after selecting time few cases time picker is inbuilt UI no separate popup.
    [Arguments]    ${time}    ${isTimePickerModeDropDown}=True    ${tap_ok}=True
    ${is_radial_picker_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    ${TIME_PICKER_RADIAL_PICKER}
    IF    ${is_radial_picker_visible}
        Click Element    ${TIME_PICKER_TOGGLE_TIME_INPUT_MODE}
    END
    Validate 24 Hour Time Format    ${time}
    ${am_localised_text}    Get Localised Message From Key For SM    1000000002141
    ${pm_localised_text}    Get Localised Message From Key For SM    1000000002143
    ${am_localised_text_upper}    Convert To Uppercase    ${am_localised_text}
    ${pm_localised_text_upper}    Convert To Uppercase    ${pm_localised_text}
    ${am_localised_locator}    Get Locator Contains For SM    ${am_localised_text_upper}
    ${pm_localised_locator}    Get Locator Contains For SM    ${pm_localised_text_upper}
    ${time_format_12_hrs}    Get Config Value    TIME_FORMAT_12_HRS
    VAR    ${hour_input_locator}    ${TIME_PICKER_INPUT_HOUR}
    IF    '${time_format_12_hrs}' == 'True'
        ${hour_value}    Evaluate    '${time}'.split(':')[0]
        IF    ${hour_value} > 12
            ${hour_value}    Evaluate    ${hour_value} - 12
            VAR    ${am_pm_locator}    ${pm_localised_locator}
        ELSE IF    '${hour_value}' =='00'
            VAR    ${hour_value}    12
            VAR    ${am_pm_locator}    ${am_localised_locator}
        ELSE
            VAR    ${am_pm_locator}    ${am_localised_locator}
        END
        ${minute_value}    Evaluate    '${time}'.split(':')[1]
    ELSE
        ${hour_value}    Evaluate    '${time}'.split(':')[0]
        ${minute_value}    Evaluate    '${time}'.split(':')[1]
    END
    Wait Until Element Is Visible    ${hour_input_locator}
    Input Text    ${hour_input_locator}    ${hour_value}
    VAR    ${minute_input_locator}    ${TIME_PICKER_INPUT_MINUTE}
    Input Text    ${minute_input_locator}    ${minute_value}
    IF    '${time_format_12_hrs}' == 'True'
        Click Element    ${TIME_PICKER_AM_PM_DROPDOWN}
        Wait Until Element Is Visible    ${am_pm_locator}
        Click Element    ${am_pm_locator}
    END
    IF    ${tap_ok}
        ${ok_button_locator}    Get Localised Locator Exact For SM    1000000000527
        Click Element    ${ok_button_locator}
    END

Select Date From Date List Picker On SM Phone App
    [Documentation]    This keyword is used to select a date from date list picker On SM Phone App app.
    ...    Example:
    ...    - Select Date From Date List Picker On SM Phone App    1_1
    [Arguments]    ${date}
    ${start_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${year_only_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY

    ${year_only_value}    Calculate Date From Week Day Offset    ${date}    ${year_only_format}
    ${week_start_value}    Calculate Date From Week Day Offset    ${date}    ${start_date_format}

    ${year_locator}    Get Message With Arguments For SM    ${YEAR_TAB_LOCATOR}    ${year_only_value}
    Wait Until Page Contains Element    ${year_locator}
    Click Element    ${year_locator}

    ${week_of}    Get Localised Message From Key For SM    1000000000217
    VAR    ${week_start_message}    ${week_of} ${week_start_value}
    ${week_date_locator}    Get Message With Arguments For SM    ${WEEk_START_LOCATOR}    ${week_start_message}

    Wait Until Page Contains Element    ${week_date_locator}
    Click Element    ${week_date_locator}

Search And Select Option From List Picker On SM Phone App
    [Documentation]    This keyword is used to search and select an option from list picker On SM Phone App app.
    ...    Example:
    ...    - Search And Select Option From List Picker On SM Phone App    option1
    [Arguments]    ${search_keyword}
    Wait Until Page Contains Element    ${LIST_PICKER_SEARCH_BOX}
    Input Text    ${LIST_PICKER_SEARCH_BOX}    ${search_keyword}
    Wait Until Page Contains Element    ${SEARCH_LIST_FIRST_OPTION}
    Click Element    ${SEARCH_LIST_FIRST_OPTION}

Select Time On Round Time Picker On SM Phone App
    [Documentation]    This keyword is used to select time on round time picker On SM Phone App app.
    ...    Example:
    ...    - Select Time On Round Time Picker On SM Phone App    23:00
    [Arguments]    ${time}
    Validate 24 Hour Time Format    ${time}
    ${is_time_format_12hrs}    Get Config Value    key=TIME_FORMAT_12_HRS
    Switch To Context    NATIVE_APP
    Sleep    3s    # Sleep added to handle any animation delay in opening time picker
    Click Element    ${ROUND_TIME_HOUR}
    IF    ${is_time_format_12hrs}
        ${formatted_time}    Convert 24hr Time To 12hr    ${time}
        Log    Selecting Time in 12 hour format: ${formatted_time}
        # Split the formatted time into hours, minutes and AM/PM
        ${hour}    Convert To Integer    ${formatted_time.split(":")[0]}
        ${minute}    Convert To Integer    ${formatted_time.split(":")[1].split(" ")[0]}
        VAR    ${am_pm}    ${formatted_time.split(" ")[1]}
        ${hour_locator}    Get Message With Arguments For SM    ${ROUND_TIME_MINUTES_HOUR}    ${hour}
        Click Element    ${hour_locator}

        ${minute_locator}    Get Message With Arguments For SM    ${ROUND_TIME_MINUTES_HOUR}    ${minute}
        Click Element    ${minute_locator}

        # Compare AM PM with ignore case to avoid any issues with different case formats and select the respective AM or PM option
        IF    '${am_pm}'.upper() == 'AM'
            Click Element    ${ROUND_TIME_AM}
        ELSE
            Click Element    ${ROUND_TIME_PM}
        END
    ELSE
        VAR    ${formatted_time}    ${time}
        Log    Selecting Time in 24 hour format: ${formatted_time}
        # Split the time into hours and minutes
        ${hour}    Convert To Integer    ${time.split(":")[0]}
        ${minute}    Convert To Integer    ${time.split(":")[1]}
        ${hour_locator}    Get Message With Arguments For SM    ${ROUND_TIME_MINUTES_HOUR}    ${hour}
        Click Element    ${hour_locator}
        ${minute_locator}    Get Message With Arguments For SM    ${ROUND_TIME_MINUTES_HOUR}    ${minute}
        Click Element    ${minute_locator}
    END
    Click Element    ${ROUND_TIME_OK_BUTTON}

Select Duration On Time Picker On SM Phone App
    [Documentation]    This keyword is used to select duration on time picker On SM Phone App app.
    ...    Arguments:
    ...    - ${time}: The time to be selected on the time picker in 24 hour format.
    ...    - ${tap_ok}: Flag to check if OK button needs to be tapped after selecting time few cases time picker is inbuilt UI no separate popup.
    [Arguments]    ${time}    ${tap_ok}=True
    ${is_radial_picker_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    ${TIME_PICKER_RADIAL_PICKER}
    IF    ${is_radial_picker_visible}
        Click Element    ${TIME_PICKER_TOGGLE_TIME_INPUT_MODE}
    END
    VAR    ${hour_input_locator}    ${TIME_PICKER_INPUT_HOUR}
    ${hour_value}    Evaluate    '${time}'.split(':')[0]
    ${minute_value}    Evaluate    '${time}'.split(':')[1]
    Wait Until Element Is Visible    ${hour_input_locator}
    Input Text    ${hour_input_locator}    ${hour_value}
    VAR    ${minute_input_locator}    ${TIME_PICKER_INPUT_MINUTE}
    Input Text    ${minute_input_locator}    ${minute_value}
    IF    ${tap_ok}
        ${ok_button_locator}    Get Localised Locator Exact For SM    1000000000527
        Click Element    ${ok_button_locator}
    END

Navigate Back On SM Phone App
    [Documentation]    Navigates back on mobile SM app by tapping on back arrow.
    Wait Until Element Is Visible    ${BACK_BUTTON}
    Click Element    ${BACK_BUTTON}

Tap Cancel On SM Phone App
    [Documentation]    Cancels the current action on mobile SM app by tapping on cancel button.
    ${cancel_button_locator}    Get Localised Locator Contains For SM    ${CANCEL_BUTTON}
    Wait Until Element Is Visible    ${cancel_button_locator}
    Click Element    ${cancel_button_locator}

Close Snack Bar When Visible On SM Phone App
    [Documentation]    Closes the snack bar if it is visible on mobile SM app by tapping on close button.
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    ${MEDIUM_TIMEOUT}    500ms    Click Element    xpath=${CLOSE_SNACK_BAR_BUTTON}

Get Current Value From Scrollable Time Picker Container On SM Phone App
    [Documentation]
    ...    Returns the currently selected integer value from a scrollable time picker container on SM phone app.
    ...    The container element exposes its current value via the ``content-desc`` attribute
    ...    (e.g. ``content-desc="12"`` for the hour container, ``content-desc="25"`` for the minute container).
    ...    | =Arguments= | =Description= |
    ...    | container_locator | XPath locator of the picker container (hours or minutes). |
    ...
    ...    *Returns*: Integer value currently shown on the picker.
    ...
    ...    Example usage:
    ...    | ${current_hour}=    Get Current Value From Scrollable Time Picker Container On SM Phone App    ${TIME_HOURS_CONTAINER}
    ...    | ${current_minute}=    Get Current Value From Scrollable Time Picker Container On SM Phone App    ${TIME_MINUTES_CONTAINER}
    [Arguments]    ${container_locator}
    Wait Until Element Is Visible    ${container_locator}
    ${raw_value}    Get Element Attribute    ${container_locator}    content-desc
    ${value}    Convert To Integer    ${raw_value}
    RETURN    ${value}

Get Tap Count For Scrollable Time Picker On SM Phone App
    [Documentation]
    ...    Calculates the exact number of backward taps required to move from ``current_value`` to
    ...    ``target_value`` on a scrollable time picker where each tap decrements the displayed value by one
    ...    and the range wraps cyclically (e.g. 0 wraps back to 23 for hours, 0 wraps back to 59 for minutes).
    ...    Formula: ``(current_value - target_value) % total_values``
    ...    | =Arguments= | =Description= |
    ...    | current_value | Integer value currently shown on the picker. |
    ...    | target_value | Integer value to reach. |
    ...    | total_values | Total number of distinct values on the picker (24 for hours, 60 for minutes). |
    ...
    ...    *Returns*: Number of taps required (0 if already at target).
    ...
    ...    Example usage:
    ...    | ${taps}=    Get Tap Count For Scrollable Time Picker On SM Phone App    10    8    24
    ...    | ${taps}=    Get Tap Count For Scrollable Time Picker On SM Phone App    3    55    60
    [Arguments]    ${current_value}    ${target_value}    ${total_values}
    ${taps}    Evaluate    (${current_value} - ${target_value}) % ${total_values}
    RETURN    ${taps}

Select Time On Scrollable Time Picker On SM Phone App
    [Documentation]
    ...    Selects the given time on the scrollable time picker on SM phone app.
    ...    Reads the current hour and minute values directly from the picker containers' ``content-desc``
    ...    attribute, calculates the exact number of backward taps required for each, and taps precisely —
    ...    avoiding unnecessary taps.  The picker advances backward on each tap (each tap decrements by 1
    ...    and wraps cyclically: 24 hours, 60 minutes).
    ...    | =Arguments= | =Description= |
    ...    | shift_time | Target time in ``HH:MM`` 24-hour format. |
    ...
    ...    Example usage:
    ...    | Select Time On Scrollable Time Picker On SM Phone App    14:30
    [Arguments]    ${shift_time}
    ${time_parts}    Split String    ${shift_time}    :
    ${target_hour_val}    Convert To Integer    ${time_parts}[0]
    ${target_minute_val}    Convert To Integer    ${time_parts}[1]

    ${current_minute}    Get Current Value From Scrollable Time Picker Container On SM Phone App    ${TIME_MINUTES_CONTAINER}
    ${minute_taps}    Get Tap Count For Scrollable Time Picker On SM Phone App    ${current_minute}    ${target_minute_val}    60
    Log    Minutes: current=${current_minute}, target=${target_minute_val}, taps=${minute_taps}
    IF    ${minute_taps} > 0
        FOR    ${_}    IN RANGE    ${minute_taps}
            Select Clickable Point Above Center    ${TIME_MINUTES_CONTAINER}    vertical_direction=above    vertical_offset_ratio=0.5
        END
    END
    ${minute_locator}    Get Message With Arguments For SM    ${TIME_MINUTE_LOCATOR}    ${time_parts}[1]
    ${is_correct_minute_selected}    Run Keyword And Return Status    Wait Until Page Contains Element    ${minute_locator}    timeout=3s
    IF    not ${is_correct_minute_selected}
        Fail    Minute value is not correct, perform correct taps to select the correct minute value.
    END

    ${current_hour}    Get Current Value From Scrollable Time Picker Container On SM Phone App    ${TIME_HOURS_CONTAINER}
    ${hour_taps}    Get Tap Count For Scrollable Time Picker On SM Phone App    ${current_hour}    ${target_hour_val}    24
    Log    Hours: current=${current_hour}, target=${target_hour_val}, taps=${hour_taps}
    IF    ${hour_taps} > 0
        FOR    ${_}    IN RANGE    ${hour_taps}
            Select Clickable Point Above Center    ${TIME_HOURS_CONTAINER}    vertical_direction=above    vertical_offset_ratio=0.5
        END
    END
    ${hour_locator}    Get Message With Arguments For SM    ${TIME_HOUR_LOCATOR}    ${time_parts}[0]
    ${is_correct_hour_selected}    Run Keyword And Return Status    Wait Until Page Contains Element    ${hour_locator}    timeout=3s
    IF    not ${is_correct_hour_selected}
        Fail    Hour value is not correct, perform correct taps to select the correct hour value.
    END

    Click Element    ${TIME_SAVE_BUTTON}
