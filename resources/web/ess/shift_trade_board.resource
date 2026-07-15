*** Settings ***
Documentation       Resource file containing keywords for ESS (Employee Self Service) Shift Trade Board functionality.
...                 Provides functions for shift swaps, extra work requests, and related shift trade board operations from the ESS user perspective.

Library             test_data/TestDataLibrary.py
Variables           resources/web/ess/shift_trade_board_page.py
Variables           resources/web/ess/shift_trade_board_api.py
Variables           resources/web/rws/schedule/plan_status_page.py
Variables           resources/web/rws/schedule/week_schedule_page.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/common/common_date_utility.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/week_schedule.resource


*** Keywords ***
Navigate To ESS Shift Trade Board Page On Web
    [Documentation]    Navigate To ESS -> Shift Trade Board -> Shift Trade Board Page
    ...    and verifies shift trade board heading at the top of the page
    Navigate To Specific Page On Web    ess    shift_trade_board

Navigate To Next Week On Shift Trade Board Page On Web
    [Documentation]
    ...    Navigates to the next week on the Shift Trade Board page and verifies that the week label increments by 7 days.
    ...    Example usage:
    ...    | Navigate To Next Week On Shift Trade Board Page On Web
    ${current_week}    Get Element Text On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SELECTED_WEEK}
    ${is_base_type_format}    Is Week Label Date Format Base On Shift Trade Board Page On Web
    IF    ${is_base_type_format}
        ${CALENDAR_NAVIGATION_DATE_FORMAT}    Get Config Value    key=CALENDAR_NAVIGATION_DATE_FORMAT
        VAR    ${date_format}    ${CALENDAR_NAVIGATION_DATE_FORMAT}
    END
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_NEXT_WEEK_BUTTON}
    ...    error_message=Failed to click on Next Week button on Shift Trade Board page
    Wait Until Page Is Loaded
    ${next_week_to_be_selected}    Get Element Text On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SELECTED_WEEK}
    VAR    ${current_week_to_be_selected}    ${current_week.replace('Week Of ', '')}
    VAR    ${next_week_to_be_selected}    ${next_week_to_be_selected.replace('Week Of ', '')}
    ${days}    Subtract Date From Date    ${next_week_to_be_selected}    ${current_week_to_be_selected}    date1_format=${date_format}
    ...    date2_format=${date_format}    result_format=compact
    Should Be Equal    ${days}    7d

Get The Day Of First Schedule Shift On Shift Trade Board Page On Web
    [Documentation]
    ...    Returns the index of the first scheduled shift available on the Shift Trade Board page.
    ...    | =Returns= | =Description= |
    ...    | ${i}    | Index of the first scheduled shift (1 to 7). Skips if no shift is available. |
    VAR    ${is_shift_available}    ${FALSE}
    FOR    ${i}    IN RANGE    1    8
        ${value}    Get Element Text On Webpage
        ...    (${SHIFT_TRADE_BOARD_PAGE_DAY})[${i}]
        IF    "${SPACE}-${SPACE}" in "${value}"
            VAR    ${is_shift_available}    ${TRUE}
            BREAK
        END
    END
    IF    "${is_shift_available}" == "${FALSE}"
        Capture Screenshot On Webpage
        SKIP    No scheduled shifts available
    END
    RETURN    ${i}

Verify Schedule Is Published On Shift Trade Board Page On Web
    [Documentation]
    ...    Verifies that the schedule is published on the Shift Trade Board page.
    ...    Example usage:
    ...    | Verify Schedule Is Published On Shift Trade Board Page On Web
    ${is_not_published_message_hidden}    Run Keyword And Return Status
    ...    Wait For Elements State    ${SHIFT_TRADE_BOARD_PAGE_SCHEDULE_NOT_PUBLISHED_MESSAGE}
    ...    state=hidden
    ...    message=Schedule is not published
    ${is_summary_tab_visible}    Run Keyword And Return Status
    ...    Wait For Elements State    ${SHIFT_TRADE_BOARD_PAGE_SCHEDULE_SUMMARY_TAB}
    ...    state=visible
    ...    message=Schedule is not published
    IF    '${is_not_published_message_hidden}' == 'False' or '${is_summary_tab_visible}' == 'False'
        Capture Screenshot On Webpage
        Skip    Schedule is not published
    END

Swap Shift At Day On Shift Trade Board Page On Web
    [Documentation]
    ...    Swaps the shift for the specified day with all eligible associates on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | swap_shift_template    | Dictionary containing shift swap details (start/end/min/max time).    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | notes    | Notes to include with the swap request.    |
    ...    Example usage:
    ...    | Swap Shift At Day On Shift Trade Board Page On Web    ${swap_shift_template}    1_4    Swap request notes
    [Arguments]    ${swap_shift_template}    ${trading_week}    ${notes}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_SHIFT}    TEMP_INDEX=${str_index}
    Wait Until Element Is Visible On Webpage    ${shift_locator}    timeout=${LONG_TIMEOUT}
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Failed to click on shift for day ${day} on Shift Trade Board page
    Click Swap Option On Shift Trade Board Page On Web
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    ${my_store_radio_button}    Is Element Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_STORE_RADIO_BUTTON}
    IF    ${my_store_radio_button}
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_STORE_RADIO_BUTTON}
        ...    error_message=Failed to click on My Store option on Shift Trade Board page
    END
    ${all_eligible_radio_button}    Is Element Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_ALL_ELIGIBLE}
    IF    ${all_eligible_radio_button}
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_ALL_ELIGIBLE}
        ...    error_message=Failed to click on All Eligible option on Shift Trade Board page
    END
    ${swap_request_start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${swap_shift_template}[preferred_start_time]
    ${swap_request_end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${swap_shift_template}[preferred_end_time]
    Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_START_TIME}    ${swap_request_start_time}
    Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_END_TIME}    ${swap_request_end_time}
    Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_MIN_TIME}    ${swap_shift_template}[preferred_shift_length_from]
    Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_MAX_TIME}    ${swap_shift_template}[preferred_shift_length_to]
    ${is_note_window_available}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES}    timeout=${MEDIUM_TIMEOUT}
    ${is_note_window_enabled}    Is Element Enabled On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES}
    IF    ${is_note_window_available} and ${is_note_window_enabled}
        Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES}    ${notes}
    END
    ${promise}    Promise To    Wait For Response    ${ESS_SWAP_SHIFT_RAISED_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SUBMIT_REQUEST_BUTTON}
    ...    error_message=Failed to click on Submit Request button for shift swap on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    submit swap shift request
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Verify Shift Trade Page Notification Message On Web
    [Documentation]    Verifies the notification message displayed on the Shift Trade Board page
    ...    | =Arguments=    | =Description=    |
    ...    | expected_message    | Expected notification message (optional)    |
    [Arguments]    ${expected_message}=${None}
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_NOTIFICATION_MESSAGE}    timeout=${LONG_TIMEOUT}
    ...    error_message=Notification message did not appear on Shift Trade Board page within expected time
    Capture Screenshot On Webpage
    IF    '${expected_message}' != '${None}'
        ${notification_message}    Get Element Text On Webpage    ${SHIFT_TRADE_BOARD_PAGE_NOTIFICATION_MESSAGE}
        Should Be Equal    ${notification_message}    ${expected_message}
    END
    Wait Until Element Disappears On Webpage    ${SHIFT_TRADE_BOARD_PAGE_NOTIFICATION_MESSAGE}

Withdraw Advertised Shift On Shift Trade Board Page On Web
    [Documentation]
    ...    Withdraws Advertised shift request raised by the associate on the Shift Trade Board page.
    ...    | =Arguments= | =Description= |
    ...    | trading_week    | Weekday offset string (e.g., '1_4') for the planning week. |
    ...    Example usage:
    ...    | Withdraw Advertised Shift On Shift Trade Board Page On Web    1_4
    [Arguments]    ${trading_week}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${shift_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_SHIFT}    TEMP_INDEX=${str_index}
    Wait Until Element Is Visible On Webpage    ${shift_locator}    timeout=${LONG_TIMEOUT}
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Failed to click on shift for day ${day} to withdraw request on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_WITHDRAW_REQUEST_OPTION}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_WITHDRAW_REQUEST_OPTION}
    ...    error_message=Failed to click on Withdraw Request option on Shift Trade Board page
    ${promise}    Promise To    Wait For Response    ${ESS_ADVERTISED_SHIFT_WITHDRAW_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_WITHDRAW_REQUEST_BUTTON}
    ...    error_message=Failed to click on Withdraw Request button on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    withdraw shift request
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Withdraw Swap Shift On Shift Trade Board Page On Web
    [Documentation]
    ...    Withdraws a shift swap request raised by the associate on the Shift Trade Board page.
    ...    | =Arguments= | =Description= |
    ...    | trading_week    | Weekday offset string (e.g., '1_4') for the planning week. |
    ...    Example usage:
    ...    | Withdraw Swap Shift On Shift Trade Board Page On Web    1_4
    [Arguments]    ${trading_week}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${shift_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_SHIFT}    TEMP_INDEX=${str_index}
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Failed to click on shift for day ${day} to withdraw request on Shift Trade Board page
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_WITHDRAW_REQUEST_OPTION}
    ...    error_message=Failed to click on Withdraw Request option on Shift Trade Board page
    ${promise}    Promise To    Wait For Response    ${ESS_SWAP_SHIFT_WITHDRAW_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_WITHDRAW_REQUEST_BUTTON}
    ...    error_message=Failed to click on Withdraw Request button on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    withdraw shift request
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Is Week Label Date Format Base On Shift Trade Board Page On Web
    [Documentation]
    ...    Checks if the week label date format on the Shift Trade Board page matches the expected base format.
    ...    | =Returns=    | =Description=    |
    ...    | ${is_base_format} | True if format matches base, False otherwise. |
    ...    Example usage:
    ...    | ${is_base_format}    Is Week Label Date Format Base On Shift Trade Board Page On Web
    ${week_date_label}    Get Element Text On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SELECTED_WEEK}
    VAR    ${date_string}    ${week_date_label}[8:]    # Extracts date part from the week label
    ${is_day_first_format}    Evaluate    "re.match(r'\\d{1,2} \\w{3}, \\d{4}', '''${date_string}''') is not None"    re
    VAR    ${is_base_format}    True
    IF    ${is_day_first_format}
        VAR    ${is_base_format}    False
    END
    RETURN    ${is_base_format}

Is Swap Tab Visible On Shift Trade Board Page On Web
    [Documentation]
    ...    Checks whether the Swap tab/option is currently visible on the Shift Trade Board page
    ...    without changing the UI state.
    ...
    ...    *Returns*: ``${TRUE}`` if the Swap option becomes visible within ``${LONG_TIMEOUT}``,
    ...    ``${FALSE}`` otherwise.
    ...
    ...    Example usage:
    ...    | ${is_visible}=    Is Swap Tab Visible On Shift Trade Board Page On Web
    ${is_swap_tab_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_OPTION}    timeout=${LONG_TIMEOUT}
    RETURN    ${is_swap_tab_visible}

Click Swap Option On Shift Trade Board Page On Web
    [Documentation]
    ...    Clicks the Swap option on the Shift Trade Board page when it is visible.
    ...    If the Swap tab is not present, the calling test is skipped.
    ...
    ...    Note: This keyword changes UI state. For a non-mutating presence check, use
    ...    ``Is Swap Tab Visible On Shift Trade Board Page On Web``.
    ...
    ...    Example usage:
    ...    | Click Swap Option On Shift Trade Board Page On Web
    ${is_swap_tab_visible}    Is Swap Tab Visible On Shift Trade Board Page On Web
    IF    ${is_swap_tab_visible}
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_OPTION}
        ...    error_message=Failed to click on Swap option on Shift Trade Board page
    ELSE
        Skip    msg=Swap tab is not present in the Shift Trade Board page
    END

Check If Open Shift Available For Day On Shift Trade Board Page On Web
    [Documentation]    Checks if there is an open shift available for any Day on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | =Returns=    | =Description=    |
    ...    | is_available    | True if open shift is available, otherwise skips the test    |
    ...    | shift_start_time    | Start time of the open shift (if available)    |
    ...    | shift_end_time    | End time of the open shift (if available)    |
    [Arguments]    ${trading_week}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${day_shift_locator}    Update Locator With Dynamic Values
    ...    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT}    DAY_INDEX=${str_index}
    ${is_open_shift_available}    Is Element Visible On Webpage    ${day_shift_locator}
    IF    ${is_open_shift_available}
        ${shift_start_time_locator}    Update Locator With Dynamic Values
        ...    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_START_TIME}    DAY_INDEX=${str_index}
        ${shift_start_time}    Get Element Text On Webpage    ${shift_start_time_locator}
        ${shift_end_time_locator}    Update Locator With Dynamic Values
        ...    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_END_TIME}    DAY_INDEX=${str_index}
        ${shift_end_time}    Get Element Text On Webpage    ${shift_end_time_locator}
        RETURN    True    ${shift_start_time}    ${shift_end_time}
    ELSE
        Skip    msg=Open shift not available on Shift Trade Board page
    END

Respond To Open Shift Request On Shift Trade Board Page On Web
    [Documentation]    Responds to an open shift request on the Shift Trade Board page
    ...    | =Arguments=    | =Description=    |
    ...    | shift_start | Start time of the shift to respond to open shift |
    ...    | shift_end    | End time of the shift to respond to open shift |
    ...    | response_notes | Notes to include with the response (will be added only if notes field is available) |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    [Arguments]    ${shift_start}    ${shift_end}    ${response_notes}    ${trading_week}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${open_shift_locator}    Update Locator With Dynamic Values
    ...    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_WITH_TIMINGS}    DAY_INDEX=${str_index}
    ...    START_TIME=${shift_start}    END_TIME=${shift_end}
    Wait Until Element Is Visible On Webpage    ${open_shift_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${open_shift_locator}
    ...    error_message=Failed to click on open shift with start time '${shift_start}' and end time '${shift_end}' for day index ${day_index}
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    Wait Until Element Is Present On Webpage    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_RESPOND_TAB}    ${SHORT_TIMEOUT}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_RESPOND_TAB}
    ...    error_message=Failed to click on Respond tab for open shift with start time '${shift_start}' and end time '${shift_end}' for day index ${day_index}
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    ${is_note_window_available}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_RESPONSE_NOTES}    timeout=${MEDIUM_TIMEOUT}
    ${is_note_window_enabled}    Is Element Enabled On Webpage    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_RESPONSE_NOTES}
    IF    ${is_note_window_available} and ${is_note_window_enabled}
        Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_RESPONSE_NOTES}    ${response_notes}
    END
    ${promise}    Promise To    Wait For Response    ${ESS_OPEN_SHIFT_RESPOND_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_ACCEPT_BUTTON}
    ...    error_message=Failed to click Accept button for open shift with start time '${shift_start}' and end time '${shift_end}' for day index ${day_index}
    Handle Shift Trade Action Completion On Web    accept open shift
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    ${close_icon_visible}    Is Element Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SHIFT_PANEL_CLOSE_ICON}
    IF    ${close_icon_visible}
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SHIFT_PANEL_CLOSE_ICON}
        ...    error_message=Failed to close shift details panel after responding to open shift
        ${shift_with_response_checkmark_locator}    Update Locator With Dynamic Values
        ...    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_RESPONSE_CHECKMARK}    DAY_INDEX=${str_index}
        ...    START_TIME=${shift_start}    END_TIME=${shift_end}
        ${is_checkmark_visible}    Is Element Visible On Webpage    ${shift_with_response_checkmark_locator}
        Should Be True    ${is_checkmark_visible}    msg=Response checkmark is not visible for the responded open shift
    END

Withdraw Response From Open Shift Request On Shift Trade Board Page On Web
    [Documentation]    Withdraws the response from an open shift request on the Shift Trade Board page.
    ...    | =Arguments= | =Description=    |
    ...    | shift_start | Start time of the shift to withdraw response from open shift |
    ...    | shift_end    | End time of the shift to withdraw response from open shift |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    [Arguments]    ${shift_start}    ${shift_end}    ${trading_week}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${open_shift_locator}    Update Locator With Dynamic Values
    ...    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_WITH_TIMINGS}    DAY_INDEX=${str_index}
    ...    START_TIME=${shift_start}    END_TIME=${shift_end}
    Click Element On Webpage    ${open_shift_locator}
    ...    error_message=Failed to click on open shift with start time '${shift_start}' and end time '${shift_end}' for day index ${day_index} to withdraw response
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_MY_RESPONSE_TAB}
    ...    error_message=Failed to click on My Response tab for open shift with start time '${shift_start}' and end time '${shift_end}' for day index ${day_index} to withdraw response
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    ${promise}    Promise To    Wait For Response    ${ESS_OPEN_SHIFT_RESPOND_WITHDRAW_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_WITHDRAW_RESPONSE_BUTTON}
    ...    error_message=Failed to click Withdraw Response button for open shift with start time '${shift_start}' and end time '${shift_end}' for day index ${day_index}
    Handle Shift Trade Action Completion On Web    withdraw open shift response
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Raise Extra Work Request At Day On Shift Trade Board Page On Web
    [Documentation]
    ...    Raises an extra work request for a specific day on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | extra_work_req_data    | Dictionary with keys: extra_work_start_time, extra_work_end_time,    |
    ...    |    | extra_work_shift_length, extra_work_request_notes.    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    Example usage:
    ...    | &{extra_work_req_data}=    Create Dictionary    extra_work_start_time=08:00    extra_work_end_time=16:00    extra_work_shift_length=08:00    extra_work_request_notes=Test
    ...    | Raise Extra Work Request At Day On Shift Trade Board Page On Web    ${extra_work_req_data}    1_4
    [Arguments]    ${extra_work_req_data}    ${trading_week}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${shift_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_SHIFT}    TEMP_INDEX=${str_index}
    Wait Until Element Is Visible On Webpage    ${shift_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Failed to click on shift for day ${day} for extra work request on Shift Trade Board page
    ${extra_work_start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${extra_work_req_data}[extra_work_start_time]
    ${extra_work_end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${extra_work_req_data}[extra_work_end_time]
    Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_START_TIME}    ${extra_work_start_time}
    Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_END_TIME}    ${extra_work_end_time}
    Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_HOURS}    ${extra_work_req_data}[extra_work_shift_length]
    ${is_note_window_available}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_NOTES}    timeout=${MEDIUM_TIMEOUT}
    ${is_note_window_enabled}    Is Element Enabled On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_NOTES}
    IF    ${is_note_window_available} and ${is_note_window_enabled}
        Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_NOTES}    ${extra_work_req_data}[extra_work_request_notes]
    END
    ${promise}    Promise To    Wait For Response    ${ESS_ADDITIONAL_WORK_RAISED_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_REQUEST_BUTTON}
    ...    error_message=Failed to click on Request button for extra work request on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    submit extra work request
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Get Unavailable Shift Day Index On Shift Trade Board Page On Web
    [Documentation]
    ...    Returns the index of the first day with no scheduled shift on the Shift Trade Board page.
    ...    | =Returns=    | =Description=    |
    ...    | ${unavailable_index} | Index of first unavailable shift (1 to 7), or 0 if all days have scheduled shifts. |
    VAR    ${unavailable_index}    0
    FOR    ${i}    IN RANGE    1    8
        ${value}    Get Element Text On Webpage    (${SHIFT_TRADE_BOARD_PAGE_DAY})[${i}]
        IF    "${SPACE}-${SPACE}" not in "${value}" and not ${unavailable_index}
            VAR    ${unavailable_index}    ${i}
        END
        IF    ${unavailable_index} > 0    BREAK
    END
    RETURN    ${unavailable_index}

Withdraw Extra Work Shift On Shift Trade Board Page On Web
    [Documentation]
    ...    Withdraws an extra work shift request raised by the associate on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart).
    ...    Example usage:
    ...    | Withdraw Extra Work Shift On Shift Trade Board Page On Web    1_4
    [Arguments]    ${trading_week}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${shift_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_SHIFT}    TEMP_INDEX=${str_index}
    Wait Until Element Is Visible On Webpage    ${shift_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Failed to click on shift for day ${day} for extra work withdrawal on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_MY_REQUEST_OPTION}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_MY_REQUEST_OPTION}
    ...    error_message=Failed to click on My Request option for extra work withdrawal on Shift Trade Board page
    ${promise}    Promise To    Wait For Response    ${ESS_ADDITIONAL_WORK_RAISED_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_WITHDRAW_BUTTON}
    ...    error_message=Failed to click on Withdraw button for extra work on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    withdraw extra work
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Complete Extra Work Request Withdrawal Workflow On Web
    [Documentation]
    ...    Performs a complete workflow to withdraw an extra work request: logs in, navigates to the shift trade board, selects the week, withdraws the request, and verifies the action.
    ...    | =Arguments=    | =Description=    |
    ...    | requester_user_key    | User key of the associate who raised the extra work request.    |
    ...    | planning_week_date    | Weekday offset string (e.g., 1_4) for the week to select.    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    Example usage:
    ...    | Complete Extra Work Request Withdrawal Workflow On Web    ESS4_STORE1    1_4    1_4
    [Arguments]    ${requester_user_key}    ${planning_week_date}    ${trading_week}
    Login And Launch WFM Web App    user_key=${requester_user_key}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${planning_week_date}
    Withdraw Extra Work Shift On Shift Trade Board Page On Web    ${trading_week}
    Capture Screenshot On Webpage

Login To ESS And Go To Selected Week Shift Trade Board Of Responder On Web
    [Documentation]
    ...    Logs in as the specified ESS associate, navigates to the ESS Shift Trade Board page, and advances to the specified week.
    ...    | =Arguments=    | =Description=    |
    ...    | responder_user_key    | ESS user key for the responder (e.g., ESS2_STORE1).    |
    ...    | planning_week_date    | Weekday offset string (e.g., '1_4') for the week to select.    |
    ...    Example usage:
    ...    | Login To ESS And Go To Selected Week Shift Trade Board Of Responder On Web    ESS2_STORE1    1_4
    [Arguments]    ${responder_user_key}    ${planning_week_date}
    Login And Launch WFM Web App    user_key=${responder_user_key}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${planning_week_date}

Get Shift Time On Shift Trade Board Page On Web
    [Documentation]
    ...    Returns the shift time for the specified day index on the Shift Trade Board page.
    ...    | =Arguments= | =Description=    |
    ...    | day_index    | Index of the day to retrieve the shift time.    |
    ...    | =Returns= | =Description=    |
    ...    | ${shift_start_time} | Start time of the shift for the specified day index.    |
    ...    | ${shift_end_time} | End time of the shift for the specified day index.    |
    ...    Example usage:
    ...    | ${shift_start_time}    ${shift_end_time}    Get Shift Time On Shift Trade Board Page On Web    1_4    |
    [Arguments]    ${day_index}
    ${str_index}    Convert To String    ${day_index}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_SHIFT}    TEMP_INDEX=${str_index}
    Wait For Elements State    ${shift_locator}    visible    timeout=${LONG_TIMEOUT}
    ${shift_time}    Get Element Text On Webpage    ${shift_locator}
    ${split_time}    Split String    ${shift_time}    -
    ${shift_start_time}    Strip String    ${split_time}[0]
    ${shift_end_time}    Strip String    ${split_time}[1]
    RETURN    ${shift_start_time}    ${shift_end_time}

Respond To Additional Work Request On Shift Trade Board Page On Web
    [Documentation]    Responds to an additional work request for the specified day and associate on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | requester_name    | Name of the associate who raised the extra work request.    |
    ...    | extra_work_respond_notes | Notes to include with the response.    |
    ...    Example usage:
    ...    | Respond To Additional Work Request On Shift Trade Board Page On Web    1_4    John Doe    Responding to request
    [Arguments]    ${trading_week}    ${requester_name}    ${extra_work_respond_notes}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${request_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_REQUEST}    TEMP_INDEX=${str_index}
    ...    TEMP_NAME=${requester_name}
    Wait Until Element Is Visible On Webpage    ${request_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${request_locator}
    ...    error_message=Failed to click on additional work request from ${requester_name} for day ${day} on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPOND_BUTTON}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPOND_BUTTON}
    ...    error_message=Failed to click on Respond button for additional work request on Shift Trade Board page
    ${is_note_window_available}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX}    timeout=${MEDIUM_TIMEOUT}
    ${is_note_window_enabled}    Is Element Enabled On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX}
    IF    ${is_note_window_available} and ${is_note_window_enabled}
        Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX}    ${extra_work_respond_notes}
    END
    ${promise}    Promise To    Wait For Response    ${ESS_ADDITIONAL_WORK_RESPOND_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_OFFER_SHIFT_BUTTON}
    ...    error_message=Failed to click on Offer Shift button for additional work request on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    offer shift for extra work
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SHIFT_PANEL_CLOSE_ICON}
    ...    error_message=Failed to click on Close button for additional work request dialog on Shift Trade Board page
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Withdraw Extra Work Shift Respond On Shift Trade Board Page On Web
    [Documentation]
    ...    Withdraws an extra work shift request response for the specified day and requestor on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | requester_name | Name of the associate who raised the extra work request.    |
    ...    Example usage:
    ...    | Withdraw Extra Work Shift Respond On Shift Trade Board Page On Web    1_4    John Doe
    [Arguments]    ${trading_week}    ${requester_name}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${request_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_REQUEST}    TEMP_INDEX=${str_index}
    ...    TEMP_NAME=${requester_name}
    Wait Until Element Is Visible On Webpage    ${request_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${request_locator}
    ...    error_message=Failed to click on extra work request from ${requester_name} for day ${day} to withdraw response on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_RESPONSE_TAB}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_RESPONSE_TAB}
    ...    error_message=Failed to click on My Response tab for extra work request from ${requester_name} on Shift Trade Board page
    ${promise}    Promise To    Wait For Response    ${ESS_ADDITIONAL_WORK_RESPOND_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_WITHDRAW_RESPONSE_BUTTON}
    ...    error_message=Failed to click Withdraw Response button for extra work request on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    withdraw extra work response
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Complete Extra Work Response Withdrawal Workflow On Web
    [Documentation]
    ...    Performs a complete workflow to withdraw an extra work shift response: logs in, navigates to shift trade board, selects the week, withdraws the response, and verifies the action.
    ...    | =Arguments=    | =Description=    |
    ...    | requester_user_key    | User key of the associate who withdraws the extra work response.    |
    ...    | planning_week_date    | Weekday offset string (e.g., 1_4) for the week to select.    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | requester_name    | Name of the associate who raised the extra work request.    |
    ...    Example usage:
    ...    | Complete Extra Work Response Withdrawal Workflow On Web    ESS2_STORE1    1_4    1_4    John Doe
    [Arguments]    ${requester_user_key}    ${planning_week_date}    ${trading_week}    ${requester_name}
    Login And Launch WFM Web App    user_key=${requester_user_key}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${planning_week_date}
    Withdraw Extra Work Shift Respond On Shift Trade Board Page On Web    ${trading_week}    ${requester_name}
    Close Browser

Advertise The Shift At Day On Shift Trade Board Page On Web
    [Documentation]
    ...    Advertises the shift for the specified day on the Shift Trade Board page.
    ...    | =Arguments= | =Description= |
    ...    | trading_week    | Weekday offset string (e.g., '1_4') for the planning week. |
    ...    | advertise_notes    | Notes for the advertisement from test data template. |
    ...    Example usage:
    ...    | Advertise The Shift At Day On Shift Trade Board Page On Web    1_4    ${advertise_shift_data}[advertise_notes]
    [Arguments]    ${trading_week}    ${advertise_notes}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${shift_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_SHIFT}    TEMP_INDEX=${str_index}
    Wait Until Element Is Visible On Webpage    ${shift_locator}
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Failed to click on shift for day ${day} to advertise on Shift Trade Board page
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Failed to double-click on shift for day ${day} to advertise on Shift Trade Board page
    Click Advertise Option On Shift Trade Board Page On Web
    ${is_note_window_available}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${SHIFT_TRADE_BOARD_PAGE_ADVERTISE_NOTES}    timeout=${MEDIUM_TIMEOUT}
    ${is_note_window_enabled}    Is Element Enabled On Webpage    ${SHIFT_TRADE_BOARD_PAGE_ADVERTISE_NOTES}
    VAR    ${advertise_notes_available_and_enabled}    False
    IF    ${is_note_window_available} and ${is_note_window_enabled}
        Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_ADVERTISE_NOTES}    ${advertise_notes}
        VAR    ${advertise_notes_available_and_enabled}    True
    END
    ${promise}    Promise To    Wait For Response    ${ESS_ADVERTISED_SHIFT_RAISED_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_ADVERTISE_BUTTON}
    ...    error_message=Failed to click on Advertise button for day ${day} on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    advertise shift
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    RETURN    ${advertise_notes_available_and_enabled}

Is Advertise Tab Visible On Shift Trade Board Page On Web
    [Documentation]
    ...    Checks whether the Advertise tab/option is currently visible on the Shift Trade Board page
    ...    without changing the UI state.
    ...
    ...    *Returns*: ``${TRUE}`` if the Advertise option becomes visible within ``${MEDIUM_TIMEOUT}``,
    ...    ``${FALSE}`` otherwise.
    ...
    ...    Example usage:
    ...    | ${is_visible}=    Is Advertise Tab Visible On Shift Trade Board Page On Web
    ${is_status_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_ADVERTISE_OPTION}    timeout=${MEDIUM_TIMEOUT}
    RETURN    ${is_status_visible}

Click Advertise Option On Shift Trade Board Page On Web
    [Documentation]
    ...    Clicks the Advertise option on the Shift Trade Board page when it is visible.
    ...    If the Advertise tab is not present, the calling test is skipped.
    ...
    ...    Note: This keyword changes UI state. For a non-mutating presence check, use
    ...    ``Is Advertise Tab Visible On Shift Trade Board Page On Web``.
    ...
    ...    Example usage:
    ...    | Click Advertise Option On Shift Trade Board Page On Web
    ${is_status_visible}    Is Advertise Tab Visible On Shift Trade Board Page On Web
    IF    ${is_status_visible}
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_ADVERTISE_OPTION}
        ...    error_message=Failed to click on Advertise option for day on Shift Trade Board page
    ELSE
        Skip    msg=Advertise tab is not present in the Shift Trade Board page
    END

Respond To Advertise Request On Shift Trade Board Page On Web
    [Documentation]    Responds to and accepts an advertised shift for a specific associate on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string (e.g., 1_4) for the week.    |
    ...    | requester_name    | Name of the associate who advertised the shift.    |
    ...    | advertise_respond_notes | Notes to include with the response.    |
    ...    Example usage:
    ...    | Respond To Advertise Request On Shift Trade Board Page On Web    1_4    John Doe    Accepting advertised shift
    [Arguments]    ${trading_week}    ${requester_name}    ${advertise_respond_notes}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${request_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_REQUEST}    TEMP_INDEX=${str_index}
    ...    TEMP_NAME=${requester_name}
    Wait Until Element Is Visible On Webpage    ${request_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${request_locator}
    ...    error_message=Failed to click on advertise request from ${requester_name} for day ${day} on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPOND_BUTTON}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPOND_BUTTON}
    ...    error_message=Failed to click on Respond button for advertise request on Shift Trade Board page
    ${is_note_window_available}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX}    timeout=${MEDIUM_TIMEOUT}
    ${is_note_window_enabled}    Is Element Enabled On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX}
    IF    ${is_note_window_available} and ${is_note_window_enabled}
        Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX}    ${advertise_respond_notes}
    END
    ${promise}    Promise To    Wait For Response    ${ESS_ADVERTISED_SHIFT_RESPOND_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_ACCEPT_BUTTON}
    ...    error_message=Failed to click on Accept button for advertise request on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    accept advertise request
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    ${close_icon_visible}    Is Element Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SHIFT_PANEL_CLOSE_ICON}
    IF    ${close_icon_visible}
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SHIFT_PANEL_CLOSE_ICON}
        ...    error_message=Failed to click on Close button for advertise request dialog on Shift Trade Board page
    END

Complete Advertise Shift Request Withdrawal Workflow On Web
    [Documentation]
    ...    Completes the workflow to withdraw an advertised shift request previously raised by the associate on the Shift Trade Board page.
    ...    Includes login, navigation to the specified week, and withdrawal of the request.
    ...    | =Arguments=    | =Description=    |
    ...    | requester_user_key    | User key of the associate who raised the advertise shift request.    |
    ...    | planning_week_date    | Weekday offset string (e.g., '1_4') for the week to select.    |
    ...    | trading_week    | Weekday offset string (e.g., '1_4') for the week to withdraw shift.    |
    ...    Example usage:
    ...    | Complete Advertise Shift Request Withdrawal Workflow On Web    ESS1_STORE1    1_4    1_4
    [Arguments]    ${requester_user_key}    ${planning_week_date}    ${trading_week}
    Login And Launch WFM Web App    user_key=${requester_user_key}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${planning_week_date}
    Withdraw Advertised Shift On Shift Trade Board Page On Web    ${trading_week}
    Close Browser

Withdraw Advertise Shift Respond On Shift Trade Board Page On Web
    [Documentation]
    ...    Withdraws a response to an advertised shift request for the specified week and requestor on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string (e.g., '1_4') for the planning week. |
    ...    | requester_name | Name of the associate who raised the advertised shift request. |
    ...    Example usage:
    ...    | Withdraw Advertise Shift Respond On Shift Trade Board Page On Web    1_4    John Doe
    [Arguments]    ${trading_week}    ${requester_name}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${request_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_REQUEST}    TEMP_INDEX=${str_index}
    ...    TEMP_NAME=${requester_name}
    Wait Until Element Is Visible On Webpage    ${request_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${request_locator}
    ...    error_message=Failed to click on advertise request from ${requester_name} for day ${day} to withdraw response on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_RESPONSE_TAB}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_RESPONSE_TAB}
    ...    error_message=Failed to click on Withdraw Response tab for advertise request from ${requester_name} on Shift Trade Board page
    ${promise}    Promise To    Wait For Response    ${ESS_ADVERTISED_SHIFT_RESPOND_WITHDRAW_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_WITHDRAW_RESPONSE_BUTTON}
    ...    error_message=Failed to click Withdraw Response button for advertise request on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    withdraw advertise response
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Complete Advertise Shift Response Withdrawal Workflow On Web
    [Documentation]
    ...    Completes the workflow to withdraw a previously raised advertise shift response on the Shift Trade Board page.
    ...    Includes login, navigation to the specified week, and withdrawal of the response.
    ...    | =Arguments=    | =Description=    |
    ...    | responder_user_key    | User key of the associate withdrawing the advertise shift response. |
    ...    | planning_week_date    | Weekday offset string (e.g., 1_4) for the week to select.    |
    ...    | requester_name    | Name of the associate who raised the advertise shift request. |
    ...    | trading_week    | Weekday offset string (e.g., 1_4) for the week to withdraw shift. |
    ...    Example usage:
    ...    | Complete Advertise Shift Response Withdrawal Workflow On Web    ESS2_STORE1    1_4    John Doe    1_4
    [Arguments]    ${responder_user_key}    ${planning_week_date}    ${requester_name}    ${trading_week}
    Login And Launch WFM Web App    user_key=${responder_user_key}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${planning_week_date}
    Withdraw Advertise Shift Respond On Shift Trade Board Page On Web    ${trading_week}    ${requester_name}
    Capture Screenshot On Webpage
    Close Browser

Respond To Swap Request On Shift Trade Board Page On Web
    [Documentation]
    ...    Responds to and accepts a swap shift request from a specific associate on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | requester_name | Name of the associate who raised the swap request. |
    ...    | notes    | Notes to include with the swap response. |
    ...    Example usage:
    ...    | Respond To Swap Request On Shift Trade Board Page On Web    1_4    John Doe    Automation sample respond note
    [Arguments]    ${trading_week}    ${requester_name}    ${notes}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${request_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_REQUEST}
    ...    TEMP_INDEX=${str_index}    TEMP_NAME=${requester_name}
    Wait Until Element Is Visible On Webpage    ${request_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${request_locator}
    ...    error_message=Failed to click on swap request from ${requester_name} for day ${day} on Shift Trade Board page
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    Wait For Load State    domcontentloaded    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPOND_BUTTON}
    ...    error_message=Failed to click on Respond button for swap request on Shift Trade Board page
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    ${is_note_window_available}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX}    timeout=${MEDIUM_TIMEOUT}
    ${is_note_window_enabled}    Is Element Enabled On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX}
    IF    ${is_note_window_available} and ${is_note_window_enabled}
        Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX}    ${notes}
    END
    ${promise}    Promise To    Wait For Response    ${ESS_SWAP_SHIFT_RESPOND_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_ACCEPT_SWAP_BUTTON}
    ...    error_message=Failed to click on Accept Swap button for swap request on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    accept swap shift
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SHIFT_PANEL_CLOSE_ICON}
    ...    error_message=Failed to click on Close button for swap request dialog on Shift Trade Board page

Withdraw Swap Shift Respond On Shift Trade Board Page On Web
    [Documentation]
    ...    Withdraws a swap shift response for the specified day and requestor on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | requester_name | Name of the associate who raised the swap request.    |
    ...    Example usage:
    ...    | Withdraw Swap Shift Respond On Shift Trade Board Page On Web    1_4    John Doe
    [Arguments]    ${trading_week}    ${requester_name}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${request_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_REQUEST}    TEMP_INDEX=${str_index}
    ...    TEMP_NAME=${requester_name}
    Click Element On Webpage    ${request_locator}
    ...    error_message=Failed to click on request from ${requester_name} for day ${day} to withdraw response on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_RESPONSE_TAB}    timeout=${MEDIUM_TIMEOUT}
    ...    error_message=Withdraw Response button did not appear for swap request on Shift Trade Board page
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_RESPONSE_TAB}
    ...    error_message=Failed to click on Withdraw Response tab for ${requester_name} on Shift Trade Board page
    ${promise}    Promise To    Wait For Response    ${ESS_SWAP_SHIFT_RESPONSE_WITHDRAW_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_WITHDRAW_RESPONSE_BUTTON}
    ...    error_message=Failed to click on Withdraw Response button for swap shift on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    withdraw swap shift response
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Complete Swap Shift Response Withdrawal Workflow On Web
    [Documentation]
    ...    Performs a complete workflow to withdraw a swap shift response: logs in as the specified user,
    ...    navigates to the shift trade board, selects the specified week, withdraws the response, and verifies the action.
    ...    | =Arguments=    | =Description=    |
    ...    | responder_user_key    | User key of the associate withdrawing the swap shift response.    |
    ...    | planning_week_date    | Weekday offset string (e.g., 1_4) for the week to select.    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | requester_name    | Name of the associate who raised the swap request.    |
    ...    Example usage:
    ...    | Complete Swap Shift Response Withdrawal Workflow On Web    ESS2_STORE1    1_4    1_4    John Doe
    [Arguments]    ${responder_user_key}    ${planning_week_date}    ${trading_week}    ${requester_name}
    Login And Launch WFM Web App    user_key=${responder_user_key}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${planning_week_date}
    Withdraw Swap Shift Respond On Shift Trade Board Page On Web    ${trading_week}    ${requester_name}
    Capture Screenshot On Webpage
    Close Browser

Complete Swap Shift Request Withdrawal Workflow On Web
    [Documentation]
    ...    Performs the complete workflow to withdraw a swap shift request previously raised by the associate on the Shift Trade Board page.
    ...    Includes login, navigation to specified week, and withdrawal of the request.
    ...    | =Arguments=    | =Description=    |
    ...    | requester_user_key    | User key of the associate who raised the swap shift request.    |
    ...    | planning_week_date    | Weekday offset string (e.g., 1_4) for the week to select.    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    Example usage:
    ...    | Complete Swap Shift Request Withdrawal Workflow On Web    ESS1_STORE1    1_4    1_4
    [Arguments]    ${requester_user_key}    ${planning_week_date}    ${trading_week}
    Login And Launch WFM Web App    user_key=${requester_user_key}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${planning_week_date}
    Withdraw Swap Shift On Shift Trade Board Page On Web    ${trading_week}
    Close Browser

Swap The Shift At Day For Associate On Shift Trade Board Page On Web
    [Documentation]
    ...    Swaps the shift for a specific day with an individual associate on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | responder_name | Name of the associate to swap the shift with.    |
    ...    | notes    | Notes to include with the swap request.    |
    ...    Example usage:
    ...    | Swap The Shift At Day For Associate On Shift Trade Board Page On Web    1_4    John Doe    Swap request notes
    [Arguments]    ${trading_week}    ${responder_name}    ${notes}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_SHIFT}    TEMP_INDEX=${str_index}
    Wait Until Element Is Visible On Webpage    ${shift_locator}    timeout=${LONG_TIMEOUT}
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Failed to click on shift for day ${day} for associate swap on Shift Trade Board page
    Click Swap Option On Shift Trade Board Page On Web
    ${my_store_radio_button_visible}    Is Element Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_STORE_RADIO_BUTTON}
    IF    ${my_store_radio_button_visible}
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_STORE_RADIO_BUTTON}
        ...    error_message=Failed to click on My Store radio button for associate swap on Shift Trade Board page
    END
    ${individual_associate_radio_button}    Is Element Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_INDIVIDUAL_ASSOCIATE_RADIO_BUTTON}
    IF    ${individual_associate_radio_button}
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_INDIVIDUAL_ASSOCIATE_RADIO_BUTTON}
        ...    error_message=Failed to click on Individual Associate radio button for associate swap on Shift Trade Board page
    END
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_ASSOCIATE_LIST}
    ...    error_message=Failed to click on Associate List dropdown on Shift Trade Board page
    Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_ASSOCIATE_TEXTBOX}    ${responder_name}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_ASSOCIATE_LIST_FIRST_OPTION}
    ...    error_message=Failed to select associate ${responder_name} from the list on Shift Trade Board page
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAPWITH_DROPDOWN}
    ...    error_message=Failed to click on SwapWith dropdown on Shift Trade Board page
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAPWITH_FIRST_OPTION}
    ...    error_message=Failed to select first option from SwapWith dropdown on Shift Trade Board page
    ${is_note_window_available}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES}    timeout=${MEDIUM_TIMEOUT}
    ${is_note_window_enabled}    Is Element Enabled On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES}
    IF    ${is_note_window_available} and ${is_note_window_enabled}
        Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES}    ${notes}
    END
    ${promise}    Promise To    Wait For Response    ${ESS_SWAP_SHIFT_RAISED_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SUBMIT_REQUEST_BUTTON}
    ...    error_message=Failed to click on Submit Request button for associate swap on Shift Trade Board page
    Handle Shift Trade Action Completion On Web    submit associate swap request
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Select Week Number On Shift Trade Board Calendar Page On Web
    [Documentation]
    ...    Selects the week number on the Shift Trade Board calendar page using week_day format.
    ...    Navigates through the calendar interface to select the target week based on the calculated date.
    ...    Handles year rollover scenarios by falling back to current year if target year is unavailable.
    ...    | =Arguments=    | =Description=    |
    ...    | week_day_input | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    ...    Example usage:
    ...    | Select Week Number On Shift Trade Board Calendar Page On Web    1_2
    ...    | Select Week Number On Shift Trade Board Calendar Page On Web    0_1
    [Arguments]    ${week_day_input}
    Select Date Through Date Picker For ESS Requests On Webpage    ${SHIFTTRADEBOARD_CALENDAR_BUTTON}    ${week_day_input}
    Wait Until Page Is Loaded
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}
    ...    Verify Header Week Start Date On Week Label On Web    ${week_day_input}    ${SHIFTTRADEBOARD_CALENDAR_BUTTON}

Login To SM And Go To Selected Week Schedule Page On Web
    [Documentation]
    ...    Logs in as the specified SM user, navigates to the RWS Schedule Week Schedule page, and advances to the specified week.
    ...    | =Arguments=    | =Description=    |
    ...    | sm_user_key    | SM user key for the store manager (e.g., SM1_STORE1).    |
    ...    | planning_week_date    | Weekday offset string (e.g., '1_4') for the week to select.    |
    ...    Example usage:
    ...    | Login To SM And Go To Selected Week Schedule Page On Web    SM1_STORE1    1_4
    [Arguments]    ${sm_user_key}    ${planning_week_date}
    Login And Launch WFM Web App    user_key=${sm_user_key}
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${planning_week_date}
    ${go_to_schedule_visible}    Is Element Visible On Webpage    ${WEEKSCHEDULEPAGE_GO_TO_SCHEDULE_LINK}
    IF    ${go_to_schedule_visible}
        Click Element On Webpage    ${WEEKSCHEDULEPAGE_GO_TO_SCHEDULE_LINK}
        Wait Until Page Is Loaded
    END

Approve Swap Shift Request In SM Week Schedule On Web
    [Documentation]
    ...    Approves a swap shift request for an associate in the SM week schedule page.
    ...    Navigates to the associate's shift details, opens responses, and approves the request with specified status.
    ...    | =Arguments=    | =Description=    |
    ...    | requester_name    | Display name of the associate who made the swap request    |
    ...    | trading_week    | Week and day in format 'week_day' (e.g., '1_4' for week 1, day 4)    |
    ...    | note    | Response note text to identify the approval button    |
    ...    | status    | Approval status to set for the request    |
    ...    Example usage:
    ...    | Approve Swap Shift Request In SM Week Schedule On Web    John Doe    1_4    Approved by manager    Approve
    [Arguments]    ${requester_name}    ${responder_name}    ${trading_week}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${details_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_SHIFT_DETAILS_TAB}
    ...    ASSOCIATE_DISPLAY_NAME=${requester_name}    SHIFT_DAY=${str_index}
    Wait Until Element Is Visible On Webpage    ${details_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${details_locator}
    ...    error_message=Failed to click on shift details for ${requester_name} on day ${day} in SM Week Schedule
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SWAP_SHIFT_REQUEST_RESPONSES_BTN}
    ...    error_message=Failed to click on Swap Shift Request Responses button in SM Week Schedule
    ${approve_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_SWAP_SHIFT_REQUEST_APPROVE_BTN}
    ...    ASSOCIATE_NAME=${responder_name}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_SWAP_APPROVED_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${approve_locator}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Approve Extra Work Request Of Associate In SM Week Schedule
    [Documentation]
    ...    Approves an extra work shift request for an associate in the SM week schedule page.
    ...    Navigates to the associate's (requester's) shift details, opens extra work responses, and approves the request.
    ...    | =Arguments=    | =Description=    |
    ...    | requester_name    | Display name of the associate who raised the extra work request    |
    ...    | trading_week    | Week and day in format 'week_day' (e.g., '1_4' for week 1, day 4)    |
    ...    Example usage:
    ...    | Approve Extra Work Request Of Associate In SM Week Schedule    John Doe    1_4
    [Arguments]    ${requester_name}    ${trading_week}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${details_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_SHIFT_DETAILS_TAB}
    ...    ASSOCIATE_DISPLAY_NAME=${requester_name}    SHIFT_DAY=${str_index}
    Wait Until Element Is Visible On Webpage    ${details_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${details_locator}
    ...    error_message=Failed to click on shift details for ${requester_name} on day ${day} for extra work approval in SM Week Schedule
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EXTRAWORK_SHIFT_REQUEST_RESPONSES_BTN}
    ...    error_message=Failed to click on Extra Work Shift Request Responses button in SM Week Schedule
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_ADDITIONAL_WORK_APPROVED_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EXTRAWORK_SHIFT_REQUEST_APPROVE_BTN}
    ...    error_message=Failed to click on Approve button for extra work request in SM Week Schedule
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Approve Open Shift Response In SM Week Schedule On Web
    [Documentation]
    ...    Approves an open shift response for an associate in the SM week schedule page.
    ...
    ...    Navigates to the open shift request details and approves the response submitted by an ESS user.
    ...    The keyword filters the specific open shift request by date and time, ensuring the correct shift is approved.
    ...
    ...    **Note:** This keyword handles multiple open shift requests by filtering based on date, start time, and end time.
    ...    Since date+time uniquely identifies an open shift request, the first approve button for that specific request is clicked.
    ...    The date format is retrieved from config and times are automatically converted based on environment settings.
    ...    Times can be provided in either 12hr format (e.g., '08:00a', '05:00p') or 24hr format (e.g., '08:00', '17:00').
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | shift_date    | Date in week_day format (e.g., '1_6') to identify the specific open shift request |
    ...    | shift_start_time    | Start time in 12hr or 24hr format (e.g., '08:00a' or '08:00') |
    ...    | shift_end_time    | End time in 12hr or 24hr format (e.g., '05:00p' or '17:00') |
    ...
    ...    Example usage:
    ...    | Approve Open Shift Response In SM Week Schedule On Web | 1_6 | 08:00a | 05:00p |
    ...    | Approve Open Shift Response In SM Week Schedule On Web | 1_6 | 08:00 | 17:00 |
    [Arguments]    ${shift_date}    ${shift_start_time}    ${shift_end_time}

    # Navigate to schedule page if on plan status page
    ${is_plan_status_page}    Is Element Present On Webpage    ${PLAN_STATUS_PAGE_GO_TO_SCHEDULE_PAGE}
    IF    ${is_plan_status_page}
        Click Element On Webpage    ${PLAN_STATUS_PAGE_GO_TO_SCHEDULE_PAGE}
    END
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REQUESTS_TAB}
    ${shift_start_24hr}    Convert UI Time Format To 24 Hour Format For Web    ${shift_start_time}
    ${shift_end_24hr}    Convert UI Time Format To 24 Hour Format For Web    ${shift_end_time}

    # Build date format for open shift requests list (e.g., "Sat 3 Jan" - non-zero-padded day)
    ${actual_date}    Calculate Date From Week Day Offset    ${shift_date}
    # Get individual date components with non-zero-padded day
    ${weekday}    Convert Date    ${actual_date}    result_format=%a
    ${day_format}    Get Config Value    DATE_FMT_DAY_NON_ZERO_PADDED
    ${day}    Convert Date    ${actual_date}    result_format=${day_format}
    ${month}    Convert Date    ${actual_date}    result_format=%b
    # Combine: "Sat 3 Jan" (not "Sat 03 Jan")
    VAR    ${formatted_date}    ${weekday} ${day} ${month}

    # Get date format for responses panel (e.g., "01/02/2026")
    ${response_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_response_date}    Convert Date    ${actual_date}    result_format=${response_date_format}

    ${is_time_format_12hrs}    Get Config Value    TIME_FORMAT_12_HRS
    IF    ${is_time_format_12hrs}
        ${start_time_display}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_24hr}
        ${end_time_display}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_24hr}
        # Remove space before AM/PM indicator to match UI format (e.g., "08:00 a" → "08:00a")
        ${start_time_display}    Replace String    ${start_time_display}    ${SPACE}a    a
        ${start_time_display}    Replace String    ${start_time_display}    ${SPACE}p    p
        ${end_time_display}    Replace String    ${end_time_display}    ${SPACE}a    a
        ${end_time_display}    Replace String    ${end_time_display}    ${SPACE}p    p
    ELSE
        VAR    ${start_time_display}    ${shift_start_24hr}
        VAR    ${end_time_display}    ${shift_end_24hr}
    END
    ${details_button_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_REQUEST_DETAILS_BY_DATE_TIME_BTN}
    ...    DATE=${formatted_date}
    ...    START_TIME=${start_time_display}
    ...    END_TIME=${end_time_display}
    Click Element On Webpage    ${details_button_locator}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_REQUEST_RESPOSES_BTN}

    # Build dynamic locator for the specific response to approve (uses different date format than details button)
    # Responses panel uses full date format (e.g., "01/02/2026") instead of abbreviated format (e.g., "Sat 3 Jan")
    ${approve_button_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_REQUEST_APPROVE_BY_DATE_TIME_BTN}
    ...    RESPONSE_DATE=${formatted_response_date}
    ...    START_TIME=${start_time_display}
    ...    END_TIME=${end_time_display}
    Click Element On Webpage    ${approve_button_locator}
    ...    error_message=Failed to click on Approve button for open shift request response in SM Week Schedule page
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}    timeout=60s
    ...    error_message=Failed to find success notification after approving open shift request response in SM Week Schedule page
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_CLOSE_BTN}
    ...    error_message=Failed to click on Close button for open shift request details in SM Week Schedule page

Skip If Today Is Last Day Of Week
    [Documentation]
    ...    Skips the test if today is the last day of the fiscal week as per config.
    ...    The fiscal week start is defined by FISCAL_WEEK_START_DAY in config.json (1=Sunday, 7=Saturday).
    ...    If today is the last day of the fiscal week, the test is skipped.
    ...    | =Arguments= | =Description= |
    ...    | None    | This keyword does not take any arguments. |
    ...    Example usage:
    ...    | Skip If Today Is Last Day Of Week
    ${fiscal_week_start}    Get Config Value    key=FISCAL_WEEK_START_DAY
    ${fiscal_week_start}    Convert To Integer    ${fiscal_week_start}
    ${week_start_day}    Evaluate    (${fiscal_week_start} - 1) % 7
    ${week_last_day}    Evaluate    (${week_start_day} + 6) % 7
    ${today}    Evaluate    __import__('datetime').datetime.now().weekday()
    IF    ${today} == ${week_last_day}
        Skip    Test skipped: Today is the last day of the week
    END

Handle Shift Trade Action Completion On Web
    [Documentation]
    ...    Handles the shift trade acknowledgment popup that appears when performing shift actions like advertise, withdraw, swap, or extra work.
    ...    Waits for the popup to appear and clicks "I Agree" button if present, otherwise continues normally.
    ...    Uses a short timeout (2s) by default for quick popup detection.
    ...
    ...    The popup contains an acknowledgment message about voluntary shift changes and clicking "I Agree" confirms understanding.
    ...    | =Arguments=    | =Description=    |
    ...    | action_description    | Description of the action that triggered the popup (for logging)    |
    ...
    ...    Example usage:
    ...    | Handle Shift Trade Action Completion On Web    clicking Advertise button
    ...    | Handle Shift Trade Action Completion On Web    swap shift action
    [Arguments]    ${action_description}=shift trade action

    # Set short timeout for quick popup detection
    VAR    ${timeout}    2s

    Log    Checking for shift trade acknowledgment popup after ${action_description}

    # Check if the popup is present
    ${popup_present}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_CONFIRMATION_POPUP_MODAL}    timeout=${timeout}

    IF    ${popup_present}
        Log    Shift trade acknowledgment popup detected - handling confirmation

        # Verify the popup message is displayed (optional validation)
        ${message_visible}    Run Keyword And Return Status
        ...    Is Element Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_CONFIRMATION_POPUP_MESSAGE}

        IF    ${message_visible}
            ${popup_message}    Get Element Text On Webpage    ${SHIFT_TRADE_BOARD_PAGE_CONFIRMATION_POPUP_MESSAGE}
            Log    Popup message: ${popup_message}
        END

        # Click "I Agree" button to confirm the action
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_CONFIRMATION_POPUP_I_AGREE_BUTTON}
        ...    error_message=Failed to click 'I Agree' button on shift trade acknowledgment popup

        # Wait for popup to disappear
        Wait Until Element Disappears On Webpage    ${SHIFT_TRADE_BOARD_PAGE_CONFIRMATION_POPUP_MODAL}
        ...    timeout=${timeout}

        Log    Successfully handled shift trade acknowledgment popup - clicked 'I Agree'
    ELSE
        Log    No shift trade acknowledgment popup appeared after ${action_description}
    END

Click On Week Label On Shift Trade Board Page On Web
    [Documentation]    Clicks on the week label on Shift Trade Board page to open the week details popup
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SELECTED_WEEK}
    ...    error_message=Failed to click on week label on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_DATE_PICKER_POPUP}
    ...    error_message=Week details popup did not appear after clicking week label on Shift Trade Board page
    Capture Screenshot On Webpage

Click On Print Icon On Shift Trade Board Page On Web
    [Documentation]    Clicks on the print icon on Shift Trade Board page to open the print menu
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_PRINT_ICON}
    ...    error_message=Failed to click on print icon on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_PRINT_BUTTON_MENU}
    ...    error_message=Print menu did not appear after clicking print icon on Shift Trade Board page
    Capture Screenshot On Webpage

Click On PDF Icon On Shift Trade Board Page On Web
    [Documentation]    Clicks on the PDF icon on Shift Trade Board page to open the PDF menu
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_PDF_ICON}    error_message=Failed to click on PDF icon on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_PDF_BUTTON_MENU}
    ...    error_message=PDF menu did not appear after clicking PDF icon on Shift Trade Board page
    Capture Screenshot On Webpage

Click On Filter Icon On Shift Trade Board Page On Web
    [Documentation]    Clicks on the filter icon on Shift Trade Board page to open the filter menu
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_FILTER_ICON}
    ...    error_message=Failed to click on filter icon on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_FILTER_POPUP}
    ...    error_message=Filter menu did not appear after clicking filter icon on Shift Trade Board page
    Capture Screenshot On Webpage

Click On Legend Icon On Shift Trade Board Page On Web
    [Documentation]    Clicks on the legend icon on Shift Trade Board page to open the legend
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_LEGEND_ICON}
    ...    error_message=Failed to click on legend icon on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_LEGEND_POPUP}
    ...    error_message=Legend popup did not appear after clicking legend icon on Shift Trade Board page
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_LEGEND_ICON}
    ...    error_message=Failed to click on legend icon on Shift Trade Board page
    Capture Screenshot On Webpage

Click On My Schedule Shift On Shift Trade Board Page On Web
    [Documentation]    Clicks on the "My Schedule" shift on Shift Trade Board page to open the shift details
    ${is_schedule_available}    Is Element Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_SCHEDULE_SHIFT}
    IF    not ${is_schedule_available}
        Capture Screenshot On Webpage
        Log    "My Schedule" shift is not available on Shift Trade Board page to click
        RETURN
    END
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_SCHEDULE_SHIFT}
    ...    error_message=Failed to click on My Schedule shift on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SHIFT_DETAILS_PANE}
    ...    error_message=Shift details pane did not appear after clicking My Schedule shift on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    (${SHIFT_TRADE_BOARD_PAGE_TIME_PICKER})[1]
    ...    error_message=First time picker input did not become visible after clicking My Schedule shift on Shift Trade Board page
    Click Element On Webpage    (${SHIFT_TRADE_BOARD_PAGE_TIME_PICKER})[1]
    ...    error_message=Failed to click on first time picker input after clicking My Schedule shift on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_TIME_PICKER_POPUP}
    ...    error_message=Time picker details popup did not appear after clicking first time picker input on Shift Trade Board page
    Click Element On Webpage    (${SHIFT_TRADE_BOARD_PAGE_TIME_PICKER})[2]
    ...    error_message=Failed to click on second time picker input after clicking My Schedule shift on Shift Trade Board page
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_TIME_PICKER_POPUP}
    ...    error_message=Time picker details popup did not appear after clicking second time picker input on Shift Trade Board page
    Capture Screenshot On Webpage

Decline Swap Shift Request On Shift Trade Board Page On Web
    [Documentation]
    ...    Declines a swap shift request from a specific associate on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | requester_name | Name of the associate who raised the swap request.    |
    ...    | notes    | Notes to include with the decline response. |
    ...    Example usage:
    ...    | Decline Swap Shift Request On Shift Trade Board Page On Web    1_4    John Doe    Automation sample decline note
    [Arguments]    ${trading_week}    ${requester_name}    ${notes}=${None}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${swap_shift_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_REQUEST}
    ...    TEMP_INDEX=${str_index}    TEMP_NAME=${requester_name}
    Wait Until Element Is Visible On Webpage    ${swap_shift_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${swap_shift_locator}
    ...    error_message=Failed to click on swap request from ${requester_name} for day ${day} on Shift Trade Board page
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    Wait For Load State    domcontentloaded    timeout=${MEDIUM_TIMEOUT}
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPOND_BUTTON}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_RESPOND_BUTTON}
    ...    error_message=Failed to click on Respond button for swap request on Shift Trade Board page
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    IF    '${notes}' != '${None}'
        ${is_note_window_available}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES}    timeout=${MEDIUM_TIMEOUT}
        ${is_note_window_enabled}    Is Element Enabled On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES}
        IF    ${is_note_window_available} and ${is_note_window_enabled}
            Fill Textbox On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES}    ${notes}
        END
    END
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_DECLINE_BUTTON}    timeout=${MEDIUM_TIMEOUT}
    Capture Screenshot On Webpage
    ${promise}    Promise To    Wait For Response    ${ESS_SWAP_SHIFT_DECLINE_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_DECLINE_BUTTON}
    ...    error_message=Failed to click on Decline button for swap request on Shift Trade Board page
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    ${is_close_button_visible}    Is Element Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_CLOSE_BUTTON}
    IF    ${is_close_button_visible}
        Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_CLOSE_BUTTON}
        ...    error_message=Failed to click on Close button after declining swap shift request on Shift Trade Board page
    END

Verify Approval Status For Swap Shift Request On Shift Trade Board Page On Web
    [Documentation]
    ...    Verifies the approval status of a swap shift request in the "My Response" tab on the Shift Trade Board page.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | requester_name | Name of the associate who raised the swap request.    |
    ...    | expected_approval_status | Expected approval status to verify (e.g., "Approved", "Declined", "Pending"). |
    ...    Example usage:
    ...    | Verify Approval Status For Swap Shift Request On Shift Trade Board Page On Web    1_4    John Doe    Approved
    [Arguments]    ${trading_week}    ${requester_name}    ${expected_approval_status}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${swap_shift_locator}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_REQUEST}
    ...    TEMP_INDEX=${str_index}    TEMP_NAME=${requester_name}
    Wait Until Element Is Visible On Webpage    ${swap_shift_locator}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${swap_shift_locator}
    ...    error_message=Failed to click on swap request from ${requester_name} for day ${day} on Shift Trade Board page
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_RESPONSE_TAB}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_MY_RESPONSE_TAB}
    ...    error_message=Failed to click on My Response tab for ${requester_name} on Shift Trade Board page
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_APPROVAL_STATUS}    timeout=${MEDIUM_TIMEOUT}
    ...    error_message=Failed to find approval status for swap request from ${requester_name} for day ${day} on Shift Trade Board page
    ${approval_status_text}    Get Element Text On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_APPROVAL_STATUS}
    Capture Screenshot On Webpage
    Should Be Equal As Strings    ${approval_status_text}    ${expected_approval_status}
    Log
    ...    Verified approval status: ${expected_approval_status} for swap shift request from ${requester_name} for day ${day} on Shift Trade Board page

Verify Responses In Raised Swap Shift On Shift Trade Board Page On Web
    [Documentation]
    ...    Verifies the response details for a raised individual swap shift request in the "My Response" tab on the Shift Trade Board page.
    ...    Checks that the response details (e.g., responder name, response note) match the expected values.
    ...    | =Arguments=    | =Description=    |
    ...    | trading_week    | Weekday offset string in week_day format where day is 0-based (e.g., 1_4 for week 1, day 5 from weekstart). |
    ...    | responder_name | Name of the associate who responded to the swap request.    |
    ...    | shift_start_time | Start time of the shift in 12hr or 24hr format (e.g., '08:00a' or '08:00'). |
    ...    | shift_end_time | End time of the shift in 12hr or 24hr format (e.g., '04:00p' or '16:00'). |
    ...    | expected_shift_location | Expected location (unitID - unitName) of the shift. |
    ...    | expected_response_status | Expected response status for the individual swap shift request. |
    ...    Example usage:
    ...    | Verify Responses In Raised Swap Shift On Shift Trade Board Page On Web    1_4    John Doe    08:00a    04:00p    Store1 - D1STORE1    Declined    |
    [Arguments]    ${trading_week}    ${responder_name}    ${shift_start_time}    ${shift_end_time}    ${expected_shift_location}
    ...    ${expected_response_status}    ${expected_start_time}    ${expected_end_time}
    ${week_day_parts}    Split String    ${trading_week}    _
    ${day_index}    Convert To Integer    ${week_day_parts}[1]
    ${day}    Evaluate    ${day_index} + 1
    ${str_index}    Convert To String    ${day}
    ${open_shift_locator}    Update Locator With Dynamic Values
    ...    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_WITH_TIMINGS}    DAY_INDEX=${str_index}
    ...    START_TIME=${shift_start_time}    END_TIME=${shift_end_time}
    Click Element On Webpage    ${open_shift_locator}
    ...    error_message=Failed to click on swap shift for day ${day} with timings ${shift_start_time} - ${shift_end_time} on Shift Trade Board page
    Wait Until Spinner Disappears On Shift Trade Board Page On Web
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_RESPONSES_TAB}
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_RESPONSES_TAB}
    ...    error_message=Failed to click on Responses tab for swap shift on Shift Trade Board page
    Capture Screenshot On Webpage

    ${responder_associate_name}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_RESPONSES_RESPONDER_NAME}
    ...    ASSOCIATE_NAME=${responder_name}
    Wait Until Element Is Visible On Webpage    ${responder_associate_name}    timeout=${MEDIUM_TIMEOUT}
    ...    error_message=Failed to find response from ${responder_name} for swap shift on Shift Trade Board page

    ${responder_shift_timings}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_RESPONSES_SHIFT_TIMINGS}
    ...    ASSOCIATE_NAME=${responder_name}
    ${actual_shift_timings}    Get Element Text On Webpage    ${responder_shift_timings}
    Should Be Equal As Strings    ${actual_shift_timings}    ${expected_start_time} - ${expected_end_time}

    ${responder_shift_location}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_RESPONSES_LOCATION}
    ...    ASSOCIATE_NAME=${responder_name}
    ${actual_shift_location}    Get Element Text On Webpage    ${responder_shift_location}
    Should Be Equal As Strings    ${actual_shift_location}    ${expected_shift_location}

    IF    '${expected_response_status}' == 'Declined'
        ${responder_response_status}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_RESPONSES_STATUS_DECLINED}
        ...    ASSOCIATE_NAME=${responder_name}
        Wait Until Element Is Visible On Webpage    ${responder_response_status}    timeout=${MEDIUM_TIMEOUT}
        ...    error_message=Failed to find Declined status for response from ${responder_name} for swap shift on Shift Trade Board page
    ELSE
        ${responder_response_status}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_RESPONSES_STATUS}
        ...    ASSOCIATE_NAME=${responder_name}
        Wait Until Element Is Visible On Webpage    ${responder_response_status}    timeout=${MEDIUM_TIMEOUT}
        ...    error_message=Failed to find response status for response from ${responder_name} for swap shift on Shift Trade Board page
    END
    Log    Verified response details for raised swap shift request on Shift Trade Board page
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_CLOSE_BUTTON}
    ...    error_message=Failed to click on Close button after verifying responses for raised swap shift request on Shift Trade Board page

Verify Other Responses On Swap Shift On Shift Trade Board Page On Web
    [Documentation]
    ...    Verifies the response details for other responses (non-individual) for a swap shift request in the "Responses" tab on the Shift Trade Board page.
    ...    Checks that the response details (e.g., responder name, response note) match the expected values.
    ...    | =Arguments=    | =Description=    |
    ...    | responder_list | List of names of the associates who responded to the swap request with non-individual responses.    |
    ...    | common_response_status | Expected common response status for all other responses (e.g., "Approved", "Declined", "Pending"). |
    ...    Example usage:
    ...    | Verify Other Responses On Swap Shift On Shift Trade Board Page On Web    @{responder_list}    Approved    |
    [Arguments]    ${responder_list}    ${common_response_status}
    Wait Until Element Is Visible On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_OTHER_RESPONSES_TAB}    timeout=${MEDIUM_TIMEOUT}
    ...    error_message=Failed to find Other Responses tab for swap shift on Shift Trade Board page
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_OTHER_RESPONSES_TAB}
    ...    error_message=Failed to click on Other Responses tab for swap shift on Shift Trade Board page
    FOR    ${responder_name}    IN    @{responder_list}
        ${responder_response_status}    Update Locator With Dynamic Values    ${SHIFT_TRADE_BOARD_PAGE_OTHER_RESPONSES_ASSOCIATE_RESPONSE}
        ...    ASSOCIATE_NAME=${responder_name}
        Wait Until Element Is Visible On Webpage    ${responder_response_status}    timeout=${MEDIUM_TIMEOUT}
        ...    error_message=Failed to find response from ${responder_name} in Other Responses tab for swap shift on Shift Trade Board page
        ${actual_response_status}    Get Element Text On Webpage    ${responder_response_status}
        Should Be Equal As Strings    ${actual_response_status}    ${common_response_status}
        Log    Verified response details for other response from ${responder_name} for swap shift on Shift Trade Board page
    END
    Click Element On Webpage    ${SHIFT_TRADE_BOARD_PAGE_CLOSE_BUTTON}
    ...    error_message=Failed to click on Close button after verifying responses on Shift Trade Board page

Wait Until Spinner Disappears On Shift Trade Board Page On Web
    [Documentation]    Waits until the loading spinner disappears on shift trade board page.
    ${spinner_wait}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${SHIFT_TRADE_BOARD_PAGE_SPINNER}    timeout=${SHORT_TIMEOUT}
    IF    ${spinner_wait}
        Wait Until Element Disappears On Webpage    ${SHIFT_TRADE_BOARD_PAGE_SPINNER}
    END
