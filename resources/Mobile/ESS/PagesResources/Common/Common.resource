*** Settings ***
Documentation       This resource file contains common keywords used across mobile ESS app.

Library             DateTime
Library             OperatingSystem
Library             CSVLib
Library             utils/common_utility/utility.py
Library             utils/common_utility/common_utils.py
Resource            resources/Mobile/Common/Mobile_Device_Helper.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Utility.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/Common/Common_Mobile.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Localised_Locator.resource
Variables           resources/Mobile/ESS/Locators/Request.py
Variables           resources/Mobile/ESS/Locators/Smoke.py
Variables           resources/Mobile/ESS/Locators/ShiftTrade.py


*** Keywords ***
Teardown Test Case
    [Documentation]    Teardown for mobile test case: performs necessary cleanup after each test case.
    ...    Arguments:
    ...    - ${tc_id}: Test case ID to link the screen recording and screenshot.
    ...    Example:
    ...    - Teardown Test Case    battc00236
    [Arguments]    ${tc_id}
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Take Mobile Page Screenshot    ${tc_id}
    Run Keyword If Test Failed    Update Test Status    failed
    Run Keyword If Test Passed    Update Test Status    passed
    Close Mobile Application    ${tc_id}

Prepare Mobile ESS App For Suite Execution
    [Documentation]    This keyword will prepare the Mobile NextGen ESS App for suite execution.
    ...    It will clear data and make device register with provided QR code.
    [Arguments]    ${qr_code}=None
    IF    '${qr_code}' == 'None'
        ${qr_code}    Get Config Value    qr_code
    END
    Clear Registration Data On Mobile ESS App
    Register Mobile ESS App With QR Code    ${qr_code}

Clear Registration Data On Mobile ESS App
    [Documentation]    Clears registration data on mobile ESS app.
    ...    Example:
    ...    - Clear Registration Data On Mobile ESS App
    ${is_custom_tab_open}    Is Element Present On Mobile    ${close_custom_tab}    timeout=${SHORT_TIMEOUT}
    IF    ${is_custom_tab_open}
        Log To Console    Custom tab is open so closing it
        Click Element    ${close_custom_tab}
        Wait Until Page Does Not Contain Element    ${close_custom_tab}    timeout=${SHORT_TIMEOUT}
        ${is_launch_custom_tab_page}    Is Element Present On Mobile    ${SETTING_BUTTON}    timeout=${SHORT_TIMEOUT}
        IF    ${is_launch_custom_tab_page}
            Log To Console    Login page is visible so try to clear data
            Clear Data Mobile ESS App
            RETURN
        END
    END

    ${is_registration_page}    Is Element Present On Mobile
    ...    ${ENTER_REGISTRATION_BUTTON}
    ...    timeout=${MEDIUM_TIMEOUT}
    IF    ${is_registration_page}
        Log To Console    Registration page is visible so no need to clear data
        RETURN
    END

    ${is_logout_page}    Is Element Present On Mobile    ${LOG_BACK_IN}    timeout=2s
    IF    ${is_logout_page}
        Log To Console    Logout page is visible so clicking on back button
        Click Element    ${LOG_BACK_IN}
        Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}
        Clear Data Mobile ESS App
        RETURN
    END

    ${log_out_button}    Get Localised Locator Exact    ${LOG_OUT}
    ${is_access_forbidden_page}    Is Element Present On Mobile    ${log_out_button}    timeout=2s
    IF    ${is_access_forbidden_page}
        Log To Console    Access forbidden page is visible so clicking on logout button
        Click Element    ${log_out_button}
        Swipe Until Visible    ${LOG_BACK_IN}
        Click Element    ${LOG_BACK_IN}
        Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}
        Clear Data Mobile ESS App
        RETURN
    END

    ${drawer}    Get Localised Locator Exact    ${HOME_DRAWER}
    ${is_home_page}    Is Element Present On Mobile    ${drawer}    timeout=2s
    IF    ${is_home_page}
        Log To Console    Home page is visible so logging out
        Logout Mobile ESS App From Top Level Page
        Clear Data Mobile ESS App
        RETURN
    END

    ${is_login_page}    Is Element Present On Mobile    ${LOGIN_SUBMIT_BUTTON}    timeout=2s
    IF    ${is_login_page}
        Log To Console    Login page is visible so try to clear data
        Clear Data Mobile ESS App
        RETURN
    END

    ${is_tampering_page}    Is Element Present On Mobile    ${UNABLE_TO_LOGIN}    timeout=2s
    IF    ${is_tampering_page}
        Log To Console    Tampering page is visible so clicking on back to login button
        Click Element    ${POPUP_OK_BUTTON}
        Wait Until Page Contains Element    ${LOG_BACK_IN}
        Click Element    ${LOG_BACK_IN}
        Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}
        Clear Data Mobile ESS App
        RETURN
    END

Register Mobile ESS App With QR Code
    [Documentation]    Registers the Mobile ESS app using the provided QR code.
    ...    Example:
    ...    - Register Mobile ESS App With QR Code    <qr_code_value>
    [Arguments]    ${qr_code}
    Wait Until Page Contains Element    ${ENTER_REGISTRATION_BUTTON}    ${SHORT_TIMEOUT}
    Click Element    ${ENTER_REGISTRATION_BUTTON}
    Wait Until Page Contains Element    ${ENTER_REGISTRATION_FIELD}
    Run Keyword And Ignore Error    Hide Keyboard
    FOR    ${_}    IN RANGE    10
        Wait Until Page Contains Element    ${ENTER_REGISTRATION_FIELD}
        ${rc}    Run Keyword And Ignore Error    Input Text    ${ENTER_REGISTRATION_FIELD}    ${qr_code}
        IF    '${rc[0]}' == 'PASS'    BREAK
        Sleep    1s
        Run Keyword And Ignore Error    Click Element    ${REGISTRATION_SUBMIT_BUTTON}
        Run Keyword And Ignore Error    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}
    END
    Click Element    ${REGISTRATION_SUBMIT_BUTTON}
    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}    timeout=${PAGE_LOAD_TIMEOUT}

Dismiss Alert If Displayed For IOS Native App
    [Documentation]    This keyword will dismiss the iOS alert if displayed by clicking Don't Allow / Ok button.
    ...    If a count parameter is passed, it will execute the dismissal that many times.
    [Arguments]    ${count}=1
    FOR    ${_}    IN RANGE    ${count}
        ${Is_Alert_Displayed}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    ${ALERT_DONT_ALLOW_NATIVE}
        ...    3s
        IF    ${Is_Alert_Displayed}
            Click Element    ${ALERT_DONT_ALLOW_NATIVE}
        END
    END

Restart Mobile ESS App
    [Documentation]    Restart Mobile ESS App.
    Terminate Application    ${PACKAGE}
    Launch Mobile ESS App

Launch Mobile ESS App
    [Documentation]    Launches the ESS app
    ...    Example:
    ...    - Launch ESS app
    Activate Application    ${PACKAGE}
    Sleep    2s

Navigate Mobile ESS To Module
    [Documentation]    Navigates to the module based on passed semantic label.
    ...    Arguments:
    ...    - ${module_name}: The semantic label for the module navigation.
    ...    Preconditions:
    ...    - App should be on main page of modules where navigation bar is visible.
    ...    Behavior:
    ...    - If the module is within the navigation bar it will navigate by tapping.
    ...    - If the module is not within navigation bar it will navigate to more and then tap on module.
    ...    Example:
    ...    - Navigate Mobile Nextgen ESS To Module    Requests
    [Arguments]    ${module_name}
    ${module_semantic_path}    Get Localised Locator Contains    ${module_name}
    ${home_tab_title_locator}    Get Localised Locator Contains    ${HomeTabLabel}
    Wait Until Page Contains Element    ${home_tab_title_locator}
    ${present}    Run Keyword And Return Status
    ...    Expect Element    ${module_semantic_path}    visible
    IF    ${present}
        Click Element    ${module_semantic_path}
    ELSE
        ${more_localised_message}    Get Localised Message From Key    ${MoreTabLabel}
        # Hardcoding 5 because more options always comes on 5th place in bottom navigation bar.
        ${more_tab_title_locator}    Get Localised Locator Exact    ${BottomTabLabel}    ${more_localised_message}    5    5
        Wait Until Page Contains Element    ${more_tab_title_locator}
        Click Element    ${more_tab_title_locator}
        ${module_semantic_path}    Get Localised Locator Exact    ${module_name}
        Wait Until Page Contains Element    ${module_semantic_path}
        Click Element    ${module_semantic_path}
    END

Select Date On Calendar
    [Documentation]    Selects the date on the calendar.
    ...    Arguments:
    ...    - ${localised_locator}: The localised locator for the calendar tap to open.
    ...    - ${select_date}: The PWx-Dx date to be selected on the calendar.
    ...    - ${calendar_open_date}: The current PWx-Dx open date on the calendar.
    ...    - ${is_pw_format}: Flag to check if open date on the calendar is passed in PWx-Dx format or YYYYMMdd (20241222) format
    [Arguments]    ${localised_locator}    ${select_date}    ${calendar_open_date}=NA    ${is_pw_format}=True
    VAR    ${FIXED_ISO_DATE_DF}    %Y-%m-%d
    ${server_df_format}    Get Config Value    SERVER_DF
    IF    '${calendar_open_date}'=="NA"
        ${today_offset}    Get Current Week Day Offset
        ${today}    Calculate Date From Week Day Offset    ${today_offset}    ${FIXED_ISO_DATE_DF}
        ${calendar_open_date_week_start}    Calculate Week Start    ${today}
        ${calendar_open_date_converted}    Convert Date    ${calendar_open_date_week_start}    ${server_df_format}
    ELSE IF    '${is_pw_format}' =="True"
        ${calendar_open_date_converted}    Calculate Date From Week Day Offset
        ...    ${calendar_open_date}
        ...    ${server_df_format}
    ELSE
        VAR    ${calendar_open_date_converted}    ${calendar_open_date}
    END
    Wait Until Page Contains Element    ${localised_locator}
    Click Element    ${localised_locator}
    Navigate Calendar To    ${select_date}    ${calendar_open_date_converted}

Select Date Range In MyRequest Filter On Mobile ESS
    [Documentation]    Select date range in filter on mobile Nextgen ESS app
    ...    Arguments:
    ...    ${start_date}: <start date for filter>
    ...    ${end_date}: <end date for filter>
    ...    ${date_range_req_calender}: <No. of days from current date>
    [Arguments]    ${start_date}    ${end_date}    ${date_range_req_calender}
    ${server_df_format}    Get Config Value    SERVER_DF
    ${FIXED_ISO_DATE_DF}    Get Config Value    DATE_FMT_YEAR_MONTH_DAY
    ${schedule_filter_date_range_locator}    Get Localised Locator Contains
    ...    ${schedule_filter_date_range}
    ${date_from_label}    Get Localised Locator Contains    ${common_semantics_filter_from}
    ${date_to_label}    Get Localised Locator Contains    ${common_semantics_filter_to}
    ${current_selected_to}    Get Date From Number Of Days Before Or After Current Date    ${date_range_req_calender}
    ...    True
    Wait Until Element Is Visible    ${schedule_filter_date_range_locator}
    Select Date On Calendar    ${date_from_label}    ${start_date}    is_pw_format=False
    ${formatted_week_end_date}    Get Formatted Date From
    ...    ${current_selected_to}
    ...    ${server_df_format}
    ...    ${FIXED_ISO_DATE_DF}
    ${week_end}    Calculate Week End    ${formatted_week_end_date}
    ${converted_week_end_date}    Convert Date    ${week_end}    result_format=${server_df_format}
    Select Date On Calendar    ${date_to_label}    ${end_date}    ${converted_week_end_date}    False

Navigate Mobile ESS Week Schedule To
    [Documentation]    Navigates to the week schedule on mobile ESS app based on the provided week day.
    ...    Arguments:
    ...    - ${week_day}: The PWx-Dx format week day to navigate (e.g., 3_2 for Wednesday of current week).
    ...    - ${calendar_open_date}: Calendar open date
    [Arguments]    ${week_day}    ${calendar_open_date}=NA
    VAR    ${FIXED_ISO_DATE_DF}    %Y-%m-%d
    ${complete_date_format}    Get Config Value    FULL_DATE_DF_MONTH_SHORT
    ${month_day_format}    Get Config Value    MONTH_DAY_FORMAT
    ${today_offset}    Get Current Week Day Offset
    ${today}    Calculate Date From Week Day Offset    ${today_offset}    ${FIXED_ISO_DATE_DF}
    IF    '${calendar_open_date}'!="NA"
        ${current_selected_date}    Calculate Date From Week Day Offset
        ...    ${calendar_open_date}
        ...    ${FIXED_ISO_DATE_DF}
        ${week_start}    Calculate Week Start    ${current_selected_date}
    ELSE
        ${week_start}    Calculate Week Start    ${today}
    END
    ${week_start_date}    Convert Date    ${week_start}    ${month_day_format}
    ${week_end_date_format}    Convert Date    ${week_start}    ${FIXED_ISO_DATE_DF}
    ${week_end}    DateTime.Add Time To Date    ${week_end_date_format}    6 days
    ${week_end_date}    Convert Date    ${week_end}    ${month_day_format}

    ${date_picker_locator}    Get Localised Locator Exact    requests.details.label.start_to_end_day
    ...    ${week_start_date}    ${week_end_date}
    Wait Until Page Contains Element    ${date_picker_locator}
    Click Element    ${date_picker_locator}
    ${pwd_date_formated}    Calculate Date From Week Day Offset    ${week_day}    ${FIXED_ISO_DATE_DF}
    ${is_date_before_today}    Evaluate    '${pwd_date_formated}' < '${today}'
    ${complete_date}    Calculate Date From Week Day Offset    ${week_day}    ${complete_date_format}
    ${pwd_final_locator}    Get Locator Contains    ${complete_date}
    IF    ${is_date_before_today}
        Swipe Until Visible    ${pwd_final_locator}    "up"
    ELSE
        Swipe Until Visible    ${pwd_final_locator}
    END
    Click Element    ${pwd_final_locator}
    ${apply_locator}    Get Localised Locator Exact    ${applyOnCalender}
    Click Element    ${apply_locator}

Select Time Length On Time Picker On Mobile ESS
    [Documentation]    Selects the time length on the time picker.
    ...    Arguments:
    ...    - ${time}: The time to be selected on the time picker in 24 hour format.
    ...    - ${prepopulated_time}: The prepopulated time on the time picker in 24 hour format (optional).
    ...    - ${isTimePickerModeDropDown}: Flag to check if time picker is in drop down mode or not.
    [Arguments]    ${time}    ${prepopulated_time}=NA    ${isTimePickerModeDropDown}=True
    Validate 24 Hour Time Format    ${time}
    IF    "${TIME_FORMAT_12_HRS} == 'TRUE'"
        ${hour_input_locator}    Get Localised Locator Contains    common.hour.label    12
        ${hour_value}    Evaluate    '${time}'.split(':')[0]
        IF    ${hour_value} > 12
            ${hour_value}    Evaluate    ${hour_value} - 12
        END
        IF    '${hour_value}' == '0'
            VAR    ${hour_value}    12
        END
        ${minute_value}    Evaluate    '${time}'.split(':')[1]
    ELSE
        ${hour_input_locator}    Get Localised Locator Contains    common.hour.label    00
        ${hour_value}    Evaluate    '${time}'.split(':')[0]
        ${minute_value}    Evaluate    '${time}'.split(':')[1]
    END
    # This logic to get locator for pre populated hour value
    IF    "${prepopulated_time}" != "NA" and "${prepopulated_time}" != "''"
        Validate 24 Hour Time Format    ${prepopulated_time}
        ${prepopulated_hour_value}    Evaluate    int('${prepopulated_time}'.split(':')[0])
        IF    "${TIME_FORMAT_12_HRS} == 'true'"
            IF    ${prepopulated_hour_value} > 12
                ${prepopulated_hour_value}    Evaluate    ${prepopulated_hour_value} - 12
            END
            IF    '${prepopulated_hour_value}' == '0'
                VAR    ${prepopulated_hour_value}    12
            END
        END
        ${hour_input_locator}    Get Localised Locator Contains    common.hour.label    ""
    END
    IF    "${prepopulated_time}" == "''"
        ${hour_input_locator}    Get Localised Locator Contains    ${common_label_hour}
        ${minute_input_locator}    Get Localised Locator Contains    ${common_label_minutes}
    END
    Wait Until Element Is Visible    ${hour_input_locator}
    Click Element    ${hour_input_locator}
    Input Text    ${hour_input_locator}    ${hour_value}
    Sleep    2s
    IF    ${isTimePickerModeDropDown}
        Click Element    ${minute_input_locator}
        ${minute_value_locator}    Get Locator Contains    ${minute_value}
        Wait Until Element Is Visible    ${minute_value_locator}
        Click Element    ${minute_value_locator}
    ELSE
        ${minute_input_locator}    Get Localised Locator Contains    common.minutes.abrv
        Input Text    ${minute_input_locator}    ${minute_value}
    END
    ${ok_button_locator}    Get Localised Locator Exact    common.label.ok
    Click Element    ${ok_button_locator}

Select Time On Time Picker
    [Documentation]    Selects the time on the time picker.
    ...    Arguments:
    ...    - ${time}: The time to be selected on the time picker in 24 hour format.
    ...    - ${prepopulated_time}: The prepopulated time on the time picker in 24 hour format (optional).
    ...    - ${isTimePickerModeDropDown}: Flag to check if time picker is in drop down mode or not for minute selection we have dropdown as default 15 min interval only has 4 options to input.
    ...    - ${tap_ok}: Flag to check if OK button needs to be tapped after selecting time few cases time picker is inbuilt UI no separate popup.
    [Arguments]    ${time}    ${prepopulated_time}=NA    ${isTimePickerModeDropDown}=True    ${tap_ok}=True
    Validate 24 Hour Time Format    ${time}
    ${am_localised_locator}    Get Localised Locator Exact    common.label.am_string
    ${pm_localised_locator}    Get Localised Locator Exact    common.label.pm_string
    ${time_format_12_hrs}    Get Config Value    TIME_FORMAT_12_HRS
    IF    '${time_format_12_hrs}' == 'True'
        ${hour_input_locator}    Get Localised Locator Contains    common.hour.label    12
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
        ${hour_input_locator}    Get Localised Locator Contains    common.hour.label    0
        ${hour_value}    Evaluate    '${time}'.split(':')[0]
        ${minute_value}    Evaluate    '${time}'.split(':')[1]
    END
    # This logic to get locator for pre populated hour value
    IF    '${prepopulated_time}' != 'NA'
        Validate 24 Hour Time Format    ${prepopulated_time}
        ${prepopulated_hour_value}    Evaluate    int('${prepopulated_time}'.split(':')[0])
        IF    '${time_format_12_hrs}' == 'True'
            IF    ${prepopulated_hour_value} > 12
                ${prepopulated_hour_value}    Evaluate    ${prepopulated_hour_value} - 12
            ELSE IF    '${prepopulated_hour_value}' == '0'
                VAR    ${prepopulated_hour_value}    12
            END
        END
        ${hour_input_locator}    Get Localised Locator Contains    common.hour.label    ""
    END
    Wait Until Element Is Visible    ${hour_input_locator}
    Clear Text    ${hour_input_locator}
    Input Text    ${hour_input_locator}    ${hour_value}
    Sleep    2s
    IF    ${isTimePickerModeDropDown}
        ${minute_input_locator}    Get Localised Locator Contains    common.minute.label
        Click Element    ${minute_input_locator}
        Sleep    2s
        ${minute_value_locator}    Get Locator Contains    ${minute_value}
        Wait Until Element Is Visible    ${minute_value_locator}
        Click Element    ${minute_value_locator}
    ELSE
        ${minute_input_locator}    Get Localised Locator Contains    common.minutes.abrv
        Clear Text    ${minute_input_locator}
        Input Text    ${minute_input_locator}    ${minute_value}
    END
    IF    '${time_format_12_hrs}' == 'True'
        Sleep    2s
        Click Element    ${am_pm_locator}
    END
    IF    ${tap_ok}
        ${ok_button_locator}    Get Localised Locator Exact    common.label.ok
        Click Element    ${ok_button_locator}
    END

Validate 24 Hour Time Format
    [Documentation]    Validate 24 Hour Time Format.
    ...    Arguments:
    ...    ${time_string}: <Time>
    [Arguments]    ${time_string}
    TRY
        Evaluate    datetime.datetime.strptime('${time_string}', "%H:%M")    datetime
        Log    Time format is valid: ${time_string}
    EXCEPT
        Fail    Invalid time format: ${time_string}
    END

Convert Punch Timestamp To 24 Hour Time
    [Documentation]
    ...    Converts a punch timestamp from ``DATE_FORMAT_YYMMDDHHMM`` to ``HH:MM``, or returns the value unchanged when already in 24-hour time.
    ...    | =Arguments= | =Description= |
    ...    | punch_timestamp | Value from ``Get Today Date With Timezone`` or an ``HH:MM`` time string. |
    ...    Example usage:
    ...    | ${24_hr_time} | Convert Punch Timestamp To 24 Hour Time | ${clock_in_time} |
    [Arguments]    ${punch_timestamp}
    ${is_24_hour_time}    Run Keyword And Return Status    Validate 24 Hour Time Format    ${punch_timestamp}
    IF    ${is_24_hour_time}    RETURN    ${punch_timestamp}
    ${timestamp_format}    Get Config Value    DATE_FORMAT_YYMMDDHHMM
    ${24_hr_time}    Evaluate
    ...    datetime.datetime.strptime('${punch_timestamp}', '${timestamp_format}').strftime('%H:%M')
    ...    modules=datetime
    RETURN    ${24_hr_time}

Toggle Days On Day Picker
    [Documentation]    Toggles the days on the day picker.
    ...    Arguments:
    ...    - ${days_list}: The list of integers subset of    this list [0, 1, 2, 3, 4, 5, 6] representing the days to be toggled with respect to first day of week defined on config
    [Arguments]    ${days_list}
    ${first_day_of_week}    Get Config Value    FISCAL_WEEK_START_DAY
    FOR    ${day}    IN    @{days_list}
        Log    Selecting non-working day: ${day}
        ${day_key}    Convert Dx To Day    ${day}    MEDIUM    ${first_day_of_week}
        ${day_locator}    Get Localised Locator Contains    ${day_key}
        Swipe Until Visible    ${day_locator}
        Click Element    ${day_locator}
    END

Format Time String
    [Documentation]    Formats the time string from 24 hour to 12 hour format based on profile configuration.
    ...    Arguments:
    ...    - ${24_hr_time_string}: The time 24 hour string to be formatted in format configured in profile variation.
    [Arguments]    ${24_hr_time_string}
    Validate 24 Hour Time Format    ${24_hr_time_string}
    ${time_format_12_hrs}    Get Config Value    TIME_FORMAT_12_HRS
    IF    '${time_format_12_hrs}' == 'True'
        ${formatted_time}    Evaluate
        ...    datetime.datetime.strptime('${24_hr_time_string}', '%H:%M').strftime('%I:%M %p')    datetime
    ELSE
        ${formatted_time}    Evaluate    '${24_hr_time_string}' if len('${24_hr_time_string}'.split(':')[0]) > 1 else '0${24_hr_time_string}'
        # VAR    ${formatted_time}    ${24_hr_time_string}
    END
    ${am_suffix}    Get Localised Message From Key    common.label.am_string
    ${pm_suffix}    Get Localised Message From Key    common.label.pm_string
    ${localised_formated_time}    Evaluate
    ...    '${formatted_time}'.replace('AM', '${am_suffix}').replace('PM', '${pm_suffix}')
    RETURN    ${localised_formated_time}

Navigate Back On Mobile ESS
    [Documentation]    Navigates back on mobile ESS app by tapping on back arrow.
    ${back_arrow_locator}    Get Localised Locator Exact    ${backArrow}
    Wait Until Element Is Visible    ${back_arrow_locator}
    Click Element    ${back_arrow_locator}

Get Unit Display Text
    [Documentation]    Gets the unit display name.
    ...    Args:
    ...    ${User_Key}: <User unique key from master users sheet>
    ...    ${Unit_Display_Format}: <Unit display format>
    [Arguments]    ${user_key}
    ${user}    Get User    ${user_key}
    ${user_name}    Evaluate    '${Unit_Display_Format}'.replace('UNIT_ID', '${user}[UNIT_ID]')
    # Replace UNIT_NAME if it exists in the format
    ${user_name}    Evaluate    '${user_name}'.replace('UNIT_NAME', '${user}[UNIT_NAME]')
    RETURN    ${user_name}

Tap Submit Button On Mobile ESS
    [Documentation]    Submits a request on mobile Nextgen ESS app.
    ${common_submit_semantic_locator}    Get Localised Locator Exact    ${common_submit_locator}
    Wait Until Element Is Visible    ${common_submit_semantic_locator}
    Click Element    ${common_submit_semantic_locator}
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}

Open Custom Filter On Mobile ESS
    [Documentation]    Tap to open custom filter on mobile Nextgen ESS app
    ${filter_label}    Get Localised Locator Contains    ${common_filter_label_locator}
    Wait Until Element Is Visible    ${filter_label}
    Click Element    ${filter_label}

Apply Custom Filter On Mobile ESS
    [Documentation]    Taps Apply filter on mobile Nextgen ESS app
    ${apply_btn}    Get Localised Locator Exact    ${applyOnCalender}
    Wait Until Element Is Visible    ${apply_btn}
    Click Element    ${apply_btn}
    Wait Until Page Does Not Contain Element    ${apply_btn}

Reset Custom Filter On Mobile ESS
    [Documentation]    Tap reset custom filter on mobile Nextgen ESS app
    ${common_label_reset_locator}    Get Localised Locator Exact    ${common_Label_Reset}
    Wait Until Element Is Visible    ${common_label_reset_locator}
    Click Element    ${common_label_reset_locator}

Tap Close Toast Message On Mobile ESS
    [Documentation]    Tap Close Toast Message on mobile Nextgen ESS app
    ${close_label}    Get Localised Locator Contains    ${close_Button}
    Wait Until Element Is Visible    ${close_label}
    Click Element    ${close_label}
    Wait Until Page Does Not Contain Element    ${close_label}

Clear Text
    [Documentation]    Clears the text in the input field.
    ...    Arguments:
    ...    - ${locator}: The locator of the input field.
    [Arguments]    ${locator}
    IF    '${MOBILE_PLATFORM}' == 'ios'
        Click Element    ${locator}
        Click Element    ${locator}
        Click Element    ${SELECT_ALL_BUTTON}
        Click Element    ${KEYBOARD_DELETE_BUTTON}
    ELSE
        AppiumLibrary.Clear Text    ${locator}
    END

Get Date From Number Of Days Before Or After Current Date
    [Documentation]    Gets the date in YYYYMMDD format from number of days before or after current date based on the flag passed.
    ...    Arguments:
    ...    ${days_count}: Number of days before or after current date to calculate the date for.
    ...    ${before_after_date}: Flag to indicate whether to calculate date before or after current date. True for after and False for before. Default is True.
    [Arguments]    ${days_count}    ${before_after_date}=True
    ${server_date_format}    Get Config Value    SERVER_DF
    ${current_date}    Get Current Date    result_format=${server_date_format}
    IF    '${before_after_date}' =="True"
        ${date}    Add Time To Date    ${current_date}    ${days_count} days    result_format=${server_date_format}
    ELSE
        ${date}    Add Time To Date    ${current_date}    -${days_count} days    result_format=${server_date_format}
    END
    RETURN    ${date}

Navigate Calendar To
    [Documentation]    Used for navigation of calendar based on current open date of calendar and required date.
    ...
    ...    Args:
    ...    ${pw_day}: <planning week day>
    ...    ${current_open_month_year}: <current open date on calendar> not in PWx-Dx format but in YYYYMMdd (20241222) format
    [Arguments]    ${pw_day}    ${current_open_month_year}
    ${source_date_format}    Get Config Value    FULL_DATE_DF
    ${year_only_date_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${month_only_date_format}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${readable_date}    Calculate Date From Week Day Offset In Multiple Formats    ${pw_day}    ${source_date_format}    ${year_only_date_format}    ${month_only_date_format}
    Log To Console    Date navigating to: ${readable_date}
    VAR    ${year}    ${readable_date}[1]
    VAR    ${month}    ${readable_date}[2]
    VAR    ${full_date}    ${readable_date}[0]
    ${full_date}    Strip Leading Zeros From Date    ${full_date}
    ${month_converted}    Evaluate    datetime.datetime.strptime('${month}', '%B').month    modules=datetime
    ${current_year}    Evaluate    '${current_open_month_year}[0:4]'
    ${current_month}    Evaluate    '${current_open_month_year}[4:6]'
    ${current_month_converted}    Convert To Integer    ${current_month}
    ${next_month_locator}    Get Localised Locator Contains    ${next_Month}
    ${prev_month_locator}    Get Localised Locator Contains    ${prev_Month}
    ${ok_button}    Get Localised Locator Contains    ${calendar_Ok_Button}
    ${next_button}    Get Localised Locator Exact    ${common_label_next}
    ${month_locator}    Get Locator Exact    ${month}
    VAR    ${count}    0
    IF    ${current_year} < ${year} or (${current_year} == ${year} and ${current_month_converted} < ${month_converted})
        VAR    ${next_or_previous}    ${next_month_locator}
        ${count}    Evaluate    (${month_converted}-${current_month_converted}) + ((${year} - ${current_year})*12)
    ELSE
        VAR    ${next_or_previous}    ${prev_month_locator}
        ${count}    Evaluate    (${current_month_converted}-${month_converted}) + ((${current_year} - ${year})*12)
    END
    FOR    ${_}    IN RANGE    ${count}
        ${is_visible}    Run Keyword And Return Status    Expect Element    ${month_locator}    visible
        IF    ${is_visible}
            Log    Required month is visible now.
            BREAK
        END
        Wait Until Element Is Visible    ${next_or_previous}
        Click Element    ${next_or_previous}
        IF    "${next_or_previous}" == "${next_month_locator}"
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
    Wait Until Page Contains Element    ${locator}
    Click Element    ${locator}
    ${is_ok_btn_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    ${ok_button}
    ...    timeout=2s
    IF    ${is_ok_btn_visible}
        Click Element    ${ok_button}
        Log    Clicked on OK button as it was visible.
    ELSE
        Click Element    ${next_button}
        Log    OK button not visible, click on next button.
    END

Wait Until Mobile Element Is Clickable
    [Documentation]    Waits until the specified mobile element is clickable.
    ...
    ...    The clickability attribute differs per platform: Android UiAutomator2
    ...    exposes ``clickable`` while iOS XCUITest has no such attribute and uses
    ...    ``enabled`` as the clickability equivalent. Reading ``clickable`` on iOS
    ...    raises _"Attribute 'clickable' is not valid for element"_, so the
    ...    attribute is selected based on ``${MOBILE_PLATFORM}``.
    ...
    ...    | =Arguments= | =Description= |
    ...    | ${locator} | The locator of the mobile element to wait for. |
    ...    | ${timeout} | The maximum time to wait for the element to become clickable (default is ``${MEDIUM_TIMEOUT}``). |
    [Arguments]    ${locator}    ${timeout}=${MEDIUM_TIMEOUT}
    Wait Until Element Is Visible    ${locator}    ${timeout}
    IF    '${MOBILE_PLATFORM}' == 'ios'
        ${clickable}    Get Element Attribute    ${locator}    enabled
    ELSE
        ${clickable}    Get Element Attribute    ${locator}    clickable
    END
    Should Be Equal As Strings    ${clickable}    true
