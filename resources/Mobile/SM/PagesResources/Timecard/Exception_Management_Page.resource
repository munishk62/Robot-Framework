*** Settings ***
Documentation       Resource file for Timecard Exception Management Page

Library             DateTime
Library             test_data/TestDataLibrary.py
Resource            resources/Mobile/SM/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/Mobile/SM/Locators/Exception_Management_Page.py
Variables           resources/Mobile/SM/Locators/Timecard_Page.py


*** Keywords ***
Select Associate On Exception Management Page On SM Phone App
    [Documentation]
    ...    Searches for and selects the associate on exception management; opens the associate timecard for the current week/day.
    ...    | =Arguments= | =Description= |
    ...    | employee_id | Employee id for the associate to select. |
    ...    | display_name | Display name used for search. |
    ...    Example usage:
    ...    | Select Associate On Exception Management Page On SM Phone App | ${user}[username] | ${user}[displayName] |
    [Arguments]    ${employee_id}    ${display_name}
    Search For Employee On Exception Management Page On SM Phone App    ${display_name}
    ${employee_id_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MGMT_EMPLOYEE_ID}    EMP_CODE=${employee_id}
    Swipe Until Visible    ${employee_id_locator}
    Wait Until Element Is Visible    ${employee_id_locator}
    Click Element    ${employee_id_locator}

Verify Today Is Displayed On SM Timecard On SM Phone App
    [Documentation]
    ...    Verifies today's date is shown on the SM timecard page after associate selection; does not change week or day.
    ...    Example usage:
    ...    | Verify Today Is Displayed On SM Timecard On SM Phone App |
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    ${today_week_day}    Get Current Week Day Offset
    ${day_date_format}    Get Config Value    DAY_DATE_FORMAT
    ${today_date}    Calculate Date From Week Day Offset    ${today_week_day}    ${day_date_format}
    ${today_date_locator}    Get Locator Contains For SM    ${today_date}
    Wait Until Page Contains Element    ${today_date_locator}
    Log    Verified today's date ${today_date} on SM timecard.

Swipe Down Slightly On SM Timecard On SM Phone App
    [Documentation]
    ...    Performs a short downward swipe on the SM timecard content to reveal lower rows or alerts.
    ${screen_width}    Get Window Width
    ${screen_height}    Get Window Height
    ${start_x}    Evaluate    int(${screen_width} * 0.5)
    ${start_y}    Evaluate    int(${screen_height} * 0.55)
    ${end_y}    Evaluate    int(${screen_height} * 0.40)
    Swipe    start_x=${start_x}    start_y=${start_y}    end_x=${start_x}    end_y=${end_y}    duration=500ms

Wait Until Page Contains Element On SM Timecard With Light Swipe Down
    [Documentation]
    ...    Waits until the locator is present on the SM timecard page, swiping down slightly between attempts when needed.
    ...    | =Arguments= | =Description= |
    ...    | locator | Target element locator. |
    ...    | max_swipes | Maximum light swipe attempts before final hard wait. |
    [Arguments]    ${locator}    ${max_swipes}=5
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    FOR    ${_}    IN RANGE    ${max_swipes}
        ${is_present}    Run Keyword And Return Status
        ...    Wait Until Page Contains Element    ${locator}    timeout=2s
        IF    ${is_present}    RETURN
        Swipe Down Slightly On SM Timecard On SM Phone App
    END
    Wait Until Page Contains Element    ${locator}

Select Week On Exception Management Page On SM Phone App
    [Documentation]
    ...    Selects target week on the calendar using a week-day format (e.g., 1_2).
    ...    | =Arguments=    | =Description=    |
    ...    | week_day_input    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    ...    Example usage:
    ...    | Select Week On Exception Management Page    2_3
    [Arguments]    ${week_day_input}    ${calendar_open_date}=NA
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    ${server_df_format}    Get Config Value    SERVER_DF
    IF    '${calendar_open_date}'=="NA"
        ${today}    Get Current Date    result_format=%Y-%m-%d
        ${week_start}    Calculate Week Start    ${today}
        ${calendar_open_date_converted}    Convert Date    ${week_start}    ${server_df_format}
    ELSE
        ${calendar_open_date_converted}    Calculate Date From Week Day Offset    ${calendar_open_date}    ${server_df_format}
    END
    Wait Until Page Contains Element    ${CALENDAR_NAVIGATION}    timeout=10s
    Click Element    ${CALENDAR_NAVIGATION}
    Navigate SM Calendar To    ${week_day_input}    ${calendar_open_date_converted}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}

Search For Employee On Exception Management Page On SM Phone App
    [Documentation]    Used for searching employee on exception management page on SM phone app.
    ...    Args:
    ...    ${display_name}: Display name for associate to be searched.
    [Arguments]    ${display_name}
    Wait Until Element Is Visible    ${EXCEPTION_MGMT_SEARCH_ICON}
    Click Element    ${EXCEPTION_MGMT_SEARCH_ICON}
    Expect Element    ${EXCEPTION_MGMT_SEARCH_INPUT_FIELD}    visible
    Input Text    ${EXCEPTION_MGMT_SEARCH_INPUT_FIELD}    ${display_name}
    Log    Searching for employee with display name: ${display_name}

Verify Clock Punch Transaction On Timecard On SM Phone App
    [Documentation]
    ...    Verifies the punch transaction type label is present on today's SM timecard for the selected associate.
    ...    | =Arguments= | =Description= |
    ...    | transaction_type_constant | ``PunchTransactionType`` key from ``constants.json`` (for example ``SHIFT_START``). |
    ...    Example usage:
    ...    | Verify Clock Punch Transaction On Timecard On SM Phone App | SHIFT_START |
    [Arguments]    ${transaction_type_constant}
    ${transaction_type_label}    Get System Value    PunchTransactionType    ${transaction_type_constant}
    ${transaction_type_locator}    Get Locator Contains For SM    ${transaction_type_label}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    Swipe Until Visible    ${transaction_type_locator}
    Wait Until Page Contains Element    ${transaction_type_locator}
    Log    Verified ${transaction_type_label} on SM timecard.

Verify Soft Timecard Alert Message For Punch On SM Phone App
    [Documentation]
    ...    Soft-checks for a review alert in ``{transaction type} at {time}`` form; failure is logged but does not fail the test.
    ...    | =Arguments= | =Description= |
    ...    | transaction_type_constant | ``PunchTransactionType`` key from ``constants.json`` (for example ``SHIFT_START``). |
    ...    | transaction_time | Punch time used to build the alert message. |
    ...    Example usage:
    ...    | Verify Soft Timecard Alert Message For Punch On SM Phone App | SHIFT_START | ${clock_in_time} |
    [Arguments]    ${transaction_type_constant}    ${transaction_time}
    Run Keyword And Ignore Error    Verify Timecard Alert Message Contains For Punch On SM Phone App    ${transaction_type_constant}    ${transaction_time}

Verify Timecard Alert Message Contains For Punch On SM Phone App
    [Documentation]
    ...    Asserts the timecard page contains the review alert message in ``{transaction type} at {formatted time}`` form.
    ...    | =Arguments= | =Description= |
    ...    | transaction_type_constant | ``PunchTransactionType`` key from ``constants.json`` (for example ``SHIFT_START``). |
    ...    | transaction_time | Punch time used to build the alert message. |
    [Arguments]    ${transaction_type_constant}    ${transaction_time}
    ${transaction_type_label}    Get System Value    PunchTransactionType    ${transaction_type_constant}
    ${24_hr_time}    Convert Punch Timestamp To 24 Hour Time    ${transaction_time}
    ${formatted_time}    Format Time String    ${24_hr_time}
    ${formatted_time}    Evaluate    __import__('re').sub(r'^0(?=\d:)', '', '${formatted_time}')    modules=re
    ${alert_locator}    Get Localised Locator Contains For SM    ${TIMECARD_PUNCH_REVIEW_ALERT_MESSAGE}    ${transaction_type_label}    ${formatted_time}
    Wait Until Page Contains Element On SM Timecard With Light Swipe Down    ${alert_locator}
    Log    Verified timecard alert message for ${transaction_type_label} at ${formatted_time}.
