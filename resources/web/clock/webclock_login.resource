*** Settings ***
Documentation       Web Clock Login Resource
...
...                 Keywords for web clock login functionality including navigation,
...                 badge ID entry, and error validation.

Resource            resources/web/common/database.resource
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Variables           resources/web/clock/webclock_login_page.py
Variables           resources/web/clock/webclock_login_page_api.py
Resource            resources/web/clock/webclock_db.resource


*** Keywords ***
Initialize Browser For Web Clock
    [Documentation]
    ...    Initializes browser context for web clock testing without authentication.
    ...    This is a lightweight alternative to full login when only web clock access is needed.
    ...    Uses Launch Chrome Browser to properly initialize browser with visibility settings.
    ...
    ...    Example usage:
    ...    | Initialize Browser For Web Clock
    Launch Browser    browser_name=chrome
    ${base_url}    Get Config Value    key=app_url
    Open New Browser Context With Page    ${base_url}

Navigate To Web Clock Page On Web
    [Documentation]
    ...    Navigates to web clock login page using URL template from config.
    ...
    ...    | =Arguments= | =Description= |
    ...    | store_id    | Store ID (e.g., STORE5) |
    ...
    ...    Example usage:
    ...    | Navigate To Web Clock Page On Web    ${store_data}[store_id]
    [Arguments]    ${store_id}
    ${base_url}    Get Config Value    key=base_url
    ${domain_id}    Get Config Value    key=domainId
    ${url_template}    Get Config Value    key=webclock_url_template
    ${web_clock_url}    Replace String    ${url_template}    {base_url}    ${base_url}
    ${web_clock_url}    Replace String    ${web_clock_url}    {store_id}    ${store_id}
    ${web_clock_url}    Replace String    ${web_clock_url}    {domain_id}    ${domain_id}
    New Page    ${web_clock_url}
    Wait Until Page Is Loaded

Click Tap To Continue On Web Clock Page On Web
    [Documentation]
    ...    Clicks the 'Tap to Continue' button if visible.
    ...    Example usage:
    ...    | Click Tap To Continue On Web Clock Page On Web
    ${is_visible}    Is Element Visible On Webpage    ${WEB_CLOCK_TAP_TO_CONTINUE_BTN}
    IF    ${is_visible}
        Click Element On Webpage    ${WEB_CLOCK_TAP_TO_CONTINUE_BTN}
        Wait Until Page Is Loaded
    END

Enter Badge ID On Web Clock Page On Web
    [Documentation]
    ...    Enters badge ID using on-screen keyboard.
    ...
    ...    | =Arguments= | =Description= |
    ...    | badge_id    | Badge ID to enter |
    ...
    ...    Example usage:
    ...    | Enter Badge ID On Web Clock Page On Web    123456
    [Arguments]    ${badge_id}
    VAR    ${char_array}    ${{list(str("${badge_id}"))}}
    FOR    ${digit}    IN    @{char_array}
        ${digit_locator}    Replace String    ${WEB_CLOCK_KEYBOARD_DIGIT_TEMPLATE}    {char}    ${digit}
        Click Element On Webpage    ${digit_locator}
    END

Perform Clock Action With Invalid Badge On Web Clock Transaction Page On Web
    [Documentation]
    ...    Performs a clock action with an invalid badge ID and validates that the API responds
    ...    with an expected status of either 200 (OK) or 422 (Unprocessable Entity).
    ...    | =Arguments= | =Description= |
    ...    | action | Action type: clock_in or clock_out |
    ...    | invalid_employee_badge_id | Badge ID for the invalid clock action |
    ...    | store_id | Store ID for web clock navigation |
    [Arguments]    ${action}    ${invalid_employee_badge_id}    ${store_id}
    ${is_password_enabled}    Get Config Value    key=IS_PASSWORD_ENABLED
    Navigate To Web Clock Page On Web    ${store_id}
    Click Tap To Continue On Web Clock Page On Web
    Enter Badge ID On Web Clock Page On Web    ${invalid_employee_badge_id}
    IF    '${is_password_enabled}' == 'Y'
        Fill Textbox On Webpage    locator=${WEB_CLOCK_PASSWORD_INPUT}    text=1111
        VAR    ${target_api}    ${WEB_CLOCK_ERROR_MESSAGE_API}
    ELSE
        VAR    ${target_api}    ${WEB_CLOCK_ACTION_API}
    END
    ${promise}    Promise To    Wait For Response    ${target_api}
    IF    '${action}' == 'clock_in'
        Click Element On Webpage    ${WEB_CLOCK_CLOCK_IN_BTN}
    ELSE IF    '${action}' == 'clock_out'
        Click Element On Webpage    ${WEB_CLOCK_CLOCK_OUT_BTN}
    ELSE
        Fail    Invalid action '${action}'. Must be 'clock_in' or 'clock_out'.
    END
    ${response}    Wait For    ${promise}
    ${status_ok}    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${response.status}    200
    ${status_unprocessable}    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${response.status}    422
    Should Be True    ${status_ok} or ${status_unprocessable}
    ...    msg=Expected response status to be 200 or 422, but it was '${response.status}'.
    Wait Until Page Is Loaded

Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web
    [Documentation]
    ...    Performs clock actions with valid badge ID and validates API response body.
    ...    Verifies punch acceptance via ClockRequestManager API response (1001=0 means accepted).
    ...    | =Arguments= | =Description= |
    ...    | action | Action type: clock_in, clock_out, meal_start, meal_end, break_start, or break_end (string literal, not variable) |
    ...    | employee_badge_id | Badge ID for the employee |
    ...    | store_id | Store ID for web clock navigation |
    ...    Example usage:
    ...    | Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web | clock_in | 12345 | STORE1 |
    ...    | Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web | meal_start | 12345 | STORE1 |
    [Arguments]    ${action}    ${employee_badge_id}    ${store_id}
    ${http_ok}    Get System Value    HttpStatusCode    OK
    Navigate To Web Clock Page On Web    ${store_id}
    ${prefix}    Set Selector Prefix    ${NONE}
    Click Tap To Continue On Web Clock Page On Web
    Click Uppercase Keyboard Button On Web Clock Page On Web
    Wait Until Page Is Loaded
    Enter Badge ID On Web Clock Page On Web    ${employee_badge_id}
    ${is_password_enabled}    Get Config Value    key=IS_PASSWORD_ENABLED
    IF    '${is_password_enabled}' == 'Y'
        Fill Textbox On Webpage    locator=${WEB_CLOCK_PASSWORD_INPUT}    text=1111
    END
    ${promise}    Promise To    Wait For Response    ${WEB_CLOCK_ACTION_API}
    IF    '${action}' == 'clock_in'
        VAR    ${clock_action_btn_locator}    ${WEB_CLOCK_CLOCK_IN_BTN}
    ELSE IF    '${action}' == 'clock_out'
        VAR    ${clock_action_btn_locator}    ${WEB_CLOCK_CLOCK_OUT_BTN}
    ELSE IF    '${action}' == 'meal_start'
        VAR    ${clock_action_btn_locator}    ${WEB_CLOCK_MEAL_START_BTN}
    ELSE IF    '${action}' == 'meal_end'
        VAR    ${clock_action_btn_locator}    ${WEB_CLOCK_MEAL_END_BTN}
    ELSE IF    '${action}' == 'break_start'
        VAR    ${clock_action_btn_locator}    ${WEB_CLOCK_BREAK_START_BTN}
    ELSE IF    '${action}' == 'break_end'
        VAR    ${clock_action_btn_locator}    ${WEB_CLOCK_BREAK_END_BTN}
    ELSE
        Fail    Invalid action '${action}'. Must be 'clock_in', 'clock_out', 'meal_start', 'meal_end', 'break_start', or 'break_end'
    END
    Click Element On Webpage    ${clock_action_btn_locator}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    ${confirm_response}    Handle Activity Code Selection If Present On Web
    ${first_response}    Wait For    ${promise}
    Should Be Equal As Strings    ${first_response.status}    ${http_ok}
    ${response}    Set Variable If    $confirm_response is not None    ${confirm_response}    ${first_response}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${WEB_CLOCK_ERROR_MESSAGE_MODAL}
    ...    timeout=${SHORT_TIMEOUT}
    Capture Screenshot On Webpage
    Verify Clock Punch API Response Body    ${response}
    Wait Until Page Is Loaded
    Set Selector Prefix    ${prefix}

Verify Error Message On Web Clock Page On Web
    [Documentation]
    ...    Verifies error message is displayed on web clock page and captures screenshot.
    ...    Tries both modal and top notification error message locations (BATTC00090 specific).
    ...
    ...    Example usage:
    ...    | Verify Error Message On Web Clock Page On Web
    # Try modal first (for clock-in scenario), then fallback to top notification (for clock-out scenario)
    ${modal_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${WEB_CLOCK_ERROR_MESSAGE_MODAL}
    IF    ${modal_visible}
        ${actual_message}    Get Element Text On Webpage    ${WEB_CLOCK_ERROR_MESSAGE_MODAL}
    ELSE
        Wait Until Element Is Visible On Webpage    ${WEB_CLOCK_ERROR_MESSAGE_TOP}    timeout=${SHORT_TIMEOUT}
        ${actual_message}    Get Element Text On Webpage    ${WEB_CLOCK_ERROR_MESSAGE_TOP}
    END
    Capture Screenshot On Webpage
    Log    Web Clock Error Message: ${actual_message}

Verify Notification Message On Web Clock Page On Web
    [Documentation]
    ...    Verifies notification message on web clock page, checks for error conditions, and dismisses the message.
    ...    Loads all WebClockNotificationMessages from constants.json via Get All System Values.
    ...    All keys except ACCEPTED_AT are treated as error patterns.
    ...    Fails the test if the message matches any error pattern.
    ...    To add a new error pattern, add it to constants.json only - this keyword requires no changes.
    ...    Example usage:
    ...    | Verify Notification Message On Web Clock Page On Web
    ${all_messages}    Get All System Values    WebClockNotificationMessages
    Wait Until Element Is Visible On Webpage    ${WEB_CLOCK_ERROR_MESSAGE_MODAL}    timeout=${LONG_TIMEOUT}
    ...    error_message=Notification message did not appear within long timeout
    ${actual_message}    Get Element Text On Webpage    ${WEB_CLOCK_ERROR_MESSAGE_MODAL}
    Capture Screenshot On Webpage
    Log    Web Clock Notification Message: ${actual_message}
    ${message_lower}    Convert To Lower Case    ${actual_message}
    Click Element On Webpage    ${WEB_CLOCK_LOGIN_CONFIRMATION_OK_BUTTON}
    Wait Until Page Is Loaded
    FOR    ${key}    ${pattern}    IN    &{all_messages}
        IF    '${key}' != 'ACCEPTED_AT'
            ${is_error}    Run Keyword And Return Status    Should Contain    ${message_lower}    ${pattern}
            IF    ${is_error}
                Fail    Web Clock punch action failed: ${actual_message}
            END
        END
    END
    Log    Web Clock punch action successful: ${actual_message}    level=INFO

Verify Clock Punch API Response Body
    [Documentation]
    ...    Verifies that the ClockRequestManager response body indicates a successful punch.
    ...    The response body uses a custom &key=value format where 1001=0 means accepted
    ...    and any non-zero value means the punch was rejected by the server.
    ...    The 1002 field carries the human-readable message for both success and error cases.
    ...    This keyword provides pure API-based validation without depending on UI notification elements.
    ...    | =Arguments= | =Description= |
    ...    | response | Response object returned by Wait For on the ClockRequestManager promise |
    ...    Example usage:
    ...    | Verify Clock Punch API Response Body    ${response}
    [Arguments]    ${response}
    ${body_raw}    Evaluate    $response.get('body', b'')
    ${body_text}    Evaluate    $body_raw.decode('utf-8') if isinstance($body_raw, bytes) else str($body_raw)
    ${params}    Evaluate    {p.split('=', 1)[0]: p.split('=', 1)[1] for p in $body_text.lstrip('&').split('&') if '=' in p}
    ${error_code}    Evaluate    $params.get('1001', '-1')
    ${punch_message}    Evaluate    $params.get('1002', 'No message in response body')
    Log    Clock punch response - code: ${error_code}, message: ${punch_message}    level=INFO
    Should Be Equal As Strings    ${error_code}    0
    ...    msg=Clock punch rejected (1001=${error_code}): ${punch_message}

Verify Web Clock Time Matches Store Timezone On Web
    [Documentation]    Verifies web clock time matches store timezone with configurable tolerance.
    ...    Resolves 12hr/24hr format ambiguity mathematically to prevent strptime ValueError crashes.
    ...
    ...    | =Arguments= | =Description= |
    ...    | web_clock_time | Time from web clock (e.g., "17:08:25", "6:05 AM", "06:05", "17:23") |
    ...    | web_clock_date | Date from web clock (e.g., "Tue 11/18") |
    ...    | store_timezone | Store timezone from database (e.g., "America/New_York") |
    [Arguments]    ${web_clock_time}    ${web_clock_date}    ${store_timezone}

    ${date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${24hr_format}    Get Config Value    key=WEB_CLOCK_PARSE_TIME_FORMAT_24HR
    ${tolerance}    Get Config Value    key=WEB_CLOCK_TIME_TOLERANCE_MINUTES

    # Store reference: single snapshot prevents drift
    ${store_now}    Evaluate    \__import_\_('datetime').datetime.now(\__import_\_('pytz').timezone('${store_timezone}'))
    ${store_total_minutes}    Evaluate    $store_now.hour \* 60 + $store_now.minute
    ${store_time_display}    Evaluate    $store_now.strftime('${24hr_format}')
    ${store_date}    Evaluate    $store_now.strftime('${date_format}')

    # Strip seconds from web clock string (e.g. "17:08:25" → "17:08")
    ${wc_normalised}    Evaluate    ':'.join('${web_clock_time}'.strip().split(':')\[:2\])

    # Check if explicit AM/PM suffix is present (e.g., "09:26 AM")
    ${has_ampm}    Evaluate    bool(\__import_\_('re').search(r'(?i)\\s\*(AM|PM)$', '${wc_normalised}'))

    IF    ${has_ampm}
        # Safely parse explicit 12-hour string
        ${config_12hr_format}    Get Config Value    key=WEB_CLOCK_PARSE_TIME_FORMAT_12HR
        ${wc_parse_format}    Set Variable If    "${config_12hr_format}" != "${NONE}" and "${config_12hr_format}" != ""
        ...    ${config_12hr_format}    %I:%M
        ${wc_dt}    Evaluate    \__import_\_('datetime').datetime.strptime('${wc_normalised}'.upper().strip(), '${wc_parse_format} %p')
        ${wc_total_minutes}    Evaluate    $wc_dt.hour \* 60 + $wc_dt.minute
    ELSE
        # No AM/PM suffix. Parse safely using 24-hour parser (allows hours 00-23 without crashing)
        ${wc_dt_base}    Evaluate    \__import_\_('datetime').datetime.strptime('${wc_normalised}', '${24hr_format}')
        ${base_mins}    Evaluate    $wc_dt_base.hour \* 60 + $wc_dt_base.minute

        # Auto-disambiguation math:
        # If hour is <= 12 (e.g. 09:26), it could be AM or a 12-hour clock missing 'PM'.
        # If hour is > 12 (e.g. 17:23), it is strictly 24-hour, no ambiguity possible.
        IF    $wc_dt_base.hour <= 12
            # Create a 12-hour shifted alternative (e.g., 09:26 -> 21:26)
            ${alt_mins}    Evaluate    (${base_mins} + 720) % 1440
            ${diff_base}    Evaluate    (lambda d: min(d, 1440 - d))(abs(${store_total_minutes} - ${base_mins}))
            ${diff_alt}    Evaluate    (lambda d: min(d, 1440 - d))(abs(${store_total_minutes} - ${alt_mins}))
            ${wc_total_minutes}    Set Variable If    ${diff_base} <= ${diff_alt}    ${base_mins}    ${alt_mins}
        ELSE
            VAR    ${wc_total_minutes}    ${base_mins}
        END
    END

    # Calculate absolute minute difference with day-wrap
    ${diff_minutes}    Evaluate    (lambda d: min(d, 1440 - d))(abs(${store_total_minutes} - ${wc_total_minutes}))

    Should Be True    ${diff_minutes} <= ${tolerance}
    ...    Time mismatch! Web clock: ${wc_normalised}, Store time: ${store_time_display}, Difference: ${diff_minutes} min (tolerance: ${tolerance} min)

    Log    ✓ Time verified: Web clock=${wc_normalised}, Store=${store_time_display}, Diff=${diff_minutes} min (tolerance=${tolerance} min)
    Log    ✓ Date: Web clock=${web_clock_date}, Store=${store_date}

Navigate And Verify Web Clock Time Matches Store Timezone On Web
    [Documentation]    Navigates to web clock page and verifies time matches store timezone.
    ...    Combines navigation, time/date fetching, timezone retrieval, and verification into one keyword.
    ...    Reads date/time elements from initial page load (no click needed).
    ...    | =Arguments= | =Description= |
    ...    | store_id | Store ID to navigate to web clock page |
    ...    Example usage:
    ...    | Navigate And Verify Web Clock Time Matches Store Timezone On Web | ${store_data}[store_id] |
    [Arguments]    ${store_id}
    Navigate To Web Clock Page On Web    ${store_id}
    ${prefix}    Set Selector Prefix    ${NONE}
    ${web_clock_date}    Get Element Text On Webpage    ${WEB_CLOCK_LOGIN_CURRENT_DATE}
    ${web_clock_time}    Get Element Text On Webpage    ${WEB_CLOCK_LOGIN_CURRENT_TIME_DEVICE}

    ${store_unit_timezone}    Get Store Timezone From DB    ${store_id}

    Verify Web Clock Time Matches Store Timezone On Web
    ...    ${web_clock_time}
    ...    ${web_clock_date}
    ...    ${store_unit_timezone}
    Set Selector Prefix    ${prefix}

Handle Activity Code Selection If Present On Web
    [Documentation]
    ...    Handles activity code selection if the activity code element is present on the web clock page.
    ...    When the server returns an activity code list (two-step punch flow), selects the first activity
    ...    code and submits — capturing the second API response which is the real punch confirmation.
    ...    Also handles employee name confirmation dialog (client-specific behavior).
    ...    Returns the second API response if a dialog was submitted so the caller can verify
    ...    the actual punch result. Returns ${NONE} if no dialog was present.
    ...    No arguments required; operates on current page context.
    ...    Example usage:
    ...    | ${confirm_response}=    Handle Activity Code Selection If Present On Web
    ${activity_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${WEB_CLOCK_LOGIN_ACTIVITY}
    IF    ${activity_visible}
        ${is_act_code_visible}    Is Element Visible On Webpage    ${WEB_CLOCK_LOGIN_ACTIVITY}
        IF    ${is_act_code_visible}
            Click Element On Webpage    ${WEB_CLOCK_LOGIN_ACTIVITY}
            ${second_promise}    Promise To    Wait For Response    ${WEB_CLOCK_ACTION_API}
            Click Element On Webpage    ${WEB_CLOCK_LOGIN_ACTIVITY_SUBMIT}
            ${second_response}    Wait For    ${second_promise}
            RETURN    ${second_response}
        END
    ELSE
        Log    Activity code selection not available - continuing without activity selection
    END
    ${employee_confirm_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEB_CLOCK_LOGIN_EMPLOYEE_NAME_SUBMIT}    timeout=${SHORT_TIMEOUT}
    IF    ${employee_confirm_visible}
        ${second_promise}    Promise To    Wait For Response    ${WEB_CLOCK_ACTION_API}
        Click Element On Webpage    ${WEB_CLOCK_LOGIN_EMPLOYEE_NAME_SUBMIT}
        ${second_response}    Wait For    ${second_promise}
        Log    Employee name confirmation dialog handled - submitted    level=INFO
        RETURN    ${second_response}
    END
    RETURN    ${NONE}

Click Uppercase Keyboard Button On Web Clock Page On Web
    [Documentation]
    ...    Clicks the uppercase keyboard button if visible.
    ...    Example usage:
    ...    | Click Uppercase Keyboard Button On Web Clock Page On Web
    ${is_visible}    Is Element Visible On Webpage    ${WEB_CLOCK_KEYBOARD_UPPERCASE_BTN}
    IF    ${is_visible}
        Click Element On Webpage    ${WEB_CLOCK_KEYBOARD_UPPERCASE_BTN}
        Wait Until Page Is Loaded
    END

Skip If Actual Web Clock Punch Already Exists On Web
    [Documentation]
    ...    Pre-execution guard that detects leftover punches from a failed previous run on the same day.
    ...    Logs in to WFM as the SM user, opens the employee's timecard on the Exception Management page,
    ...    checks for today's shift row using the date-specific locator, closes the browser, and skips
    ...    the test if an existing punch is found. Call this before initializing the web clock browser.
    ...
    ...    | =Arguments= | =Description= |
    ...    | sm_user_key | SM user key used to log in to WFM (e.g., SM1_STORE1, SM1_STORE2) |
    ...    | employee_username | Employee username to open timecard for |
    ...
    ...    Example usage:
    ...    | Skip If Actual Web Clock Punch Already Exists On Web    SM1_STORE1    ${ess_user}[username]
    [Arguments]    ${sm_user_key}    ${employee_username}
    Login And Launch WFM Web App    user_key=${sm_user_key}
    Navigate To RTA Operations Exception Management Page On Web
    ${display_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${store_date}    Get Current Date    result_format=${display_date_format}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TIMECARD_ROW}
    ...    DATE=${store_date}
    Open Employee Timecard On Exception Management Page On Web    ${employee_username}
    ${is_punch_present}    Is Element Visible On Webpage    ${shift_locator}
    Capture Screenshot On Webpage
    Set Selector Prefix    ${NONE}
    Close Browser
    Skip If    ${is_punch_present}    Actual punch already exists for ${store_date} - skipping to avoid 'already on record' error
