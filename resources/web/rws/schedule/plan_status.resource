*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Plan Status page.
...
...                 = Purpose =
...                 - Centralizes actions for navigating, creating, and verifying schedules on Plan Status Page.
...
...                 = Prerequisites =
...                 - Required libraries and variable files must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 |Generate Week Plan For Unscheduled Week
...                 |    Select Unscheduled Week By Date On Plan Status Page On Web
...                 |    Click On Generate Week Plan On Plan Status Page On Web
...                 |    Verify Success Notifier Message On Plan Status Page On Web

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/rws/schedule/plan_status_page.py
Variables           resources/web/rws/schedule/plan_status_page_api.py
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/rws/schedule/batch_plan_status.resource
Resource            resources/web/common/common_date_utility.resource
Variables           resources/web/rws/schedule/fixed_shifts_page.py


*** Keywords ***
Navigate To RWS Schedule Plan Status Page On Web
    [Documentation]    Navigates to the RWS -> Schedule -> Plan Status page.
    ...    Plan Status has no direct menu entry so this keyword navigates to
    ...    Week Schedule via the menu and then switches to Plan Status via the railroad dropdown.
    ...    Example usage:
    ...    | Navigate To RWS Schedule Plan Status Page On Web
    Navigate To Specific Page On Web    rws    schedule    week_schedule
    Wait Until Page Is Loaded
    Navigate To Plan Status Page From Week Schedule Page On Web

Generate Week Plan On Plan Status Page On Web
    [Documentation]    This keyword is used to click on Generate Week Plan button for the week.
    ...    You need to be on the Rail Road Page to click this button.
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_GENERATE_SCHEDULE_BUTTON}    ${PAGE_LOAD_TIMEOUT}
    ${generate_week_plan_button_visible}    Is Element Visible On Webpage
    ...    ${PLAN_STATUS_GENERATE_SCHEDULE_BUTTON}
    IF    ${generate_week_plan_button_visible}
        Click Element On Webpage    ${PLAN_STATUS_GENERATE_SCHEDULE_BUTTON}
        Verify Success Notifier Message On Plan Status Page On Web
    END

Verify Success Notifier Message On Plan Status Page On Web
    [Documentation]    This keyword verifies the success message after generating
    ...    week plan/workload/optimized schedule etc.
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_SUCCESS_NOTIFIER_MESSAGE}
    ...    timeout=${LONG_TIMEOUT}    error_message=Success message notifier is not displayed
    Capture Screenshot On Webpage
    ${message_content}    Get Element Text On Webpage    ${PLAN_STATUS_SUCCESS_MESSAGE_CONTENT}
    Log    ${message_content}
    TRY
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_DISABLED_TIMELINE_CONTAINER}
    EXCEPT
        Log
        ...    Disabled timeline container is not displayed after generating week plan. Batch execution might have not started or completed already.
    END
    Wait Until Element Disappears On Webpage    ${PLAN_STATUS_SUCCESS_NOTIFIER_MESSAGE}

Verify If Generate Week Plan Is Completed On Plan Status Page On Web
    [Documentation]    This keyword verifies if week plan is generated/checked and accordingly returns true/false.
    ${generate_schedule_button_checked}    Wait Until Mentioned Button Is Checked On Plan Status Page On Web
    ...    ${PLAN_STATUS_GENERATE_SCHEDULE_BUTTON_CHECK}
    IF    ${generate_schedule_button_checked}
        Capture Screenshot On Webpage
    ELSE
        Fail    Failed to generate week plan
    END

Generate Workload On Plan Status Page On Web
    [Documentation]    This keyword is used to click on Generate Workload button for the week.
    ...    You need to be on the Rail Road Page and have created week plan to click this button.
    ${generate_workload_button_visible}    Is Element Visible On Webpage
    ...    ${PLAN_STATUS_GENERATE_WORKLOAD_BUTTON}
    ${generate_wkld_btn_enabled}    Is Element Enabled On Webpage
    ...    ${PLAN_STATUS_GENERATE_WORKLOAD_BUTTON}
    IF    ${generate_workload_button_visible} and ${generate_wkld_btn_enabled}
        ${promise}    Promise To    Wait For Response    ${PLAN_STATUS_PAGE_WORKLOAD_GENERATE_SUCCESS_API}
        Click Element On Webpage    ${PLAN_STATUS_GENERATE_WORKLOAD_BUTTON}
        ...    error_message=Failed to click on generate workload button
        ${response_body}    Wait For    ${promise}
        ${status_ok}    Get System Value    HttpStatusCode    OK
        Should Be Equal As Strings    ${response_body.status}    ${status_ok}
        ...    msg=Workload generation API did not return success status
    ELSE
        Fail    Generate Workload button is not visible to click
    END

Verify If Generate Workload Is Completed On Plan Status Page On Web
    [Documentation]    This keyword verifies if workload is generated/checked and accordingly returns true/false.
    ${generate_workload_button_checked}    Wait Until Mentioned Button Is Checked On Plan Status Page On Web
    ...    ${PLAN_STATUS_GENERATE_WORKLOAD_BUTTON_CHECK}
    IF    ${generate_workload_button_checked}
        Capture Screenshot On Webpage
    ELSE
        Fail    Failed to generate workload.
    END

Generate Schedule Using Template On Plan Status Page On Web
    [Documentation]    This keyword is used to click on Generate schedule using the template.
    ...    You need to be on the Rail Road Page and have created week plan and workload to click this button.
    ${generate_schd_using_template_btn_visible}    Is Element Visible On Webpage
    ...    ${PLAN_STATUS_GENERATE_SCHEDULE_USING_TEMPLATE_BTN}
    IF    ${generate_schd_using_template_btn_visible}
        Click Element On Webpage    ${PLAN_STATUS_GENERATE_SCHEDULE_USING_TEMPLATE_BTN}
        Verify Success Notifier Message On Plan Status Page On Web
    END

Verify If Generate Schedule Using Template Is Completed On Plan Status Page On Web
    [Documentation]    This keyword verifies if schedule is generated using template/checked
    ...    and accordingly returns true/false.
    ${generate_schd_using_template_btn_checked}    Wait Until Mentioned Button Is Checked On Plan Status Page On Web
    ...    ${PLAN_STATUS_GENERATE_SCHD_USING_TEMPLATE_BTN_CHECK}
    IF    ${generate_schd_using_template_btn_checked}
        Capture Screenshot On Webpage
    ELSE
        Fail    Failed to generate schedule using template.
    END

Go To The Forecast Page On Plan Status Page On Web
    [Documentation]    This keyword is used to navigate to forecast page after
    ...    week plan is generated.
    TRY
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_GOTO_FORECAST_LINK}
        ...    timeout=${LONG_TIMEOUT}    error_message=Go to forecast page link is not visible/clickable on plan status page
    EXCEPT
        Log    message=Go to forecast page link is not visible/clickable on plan status page    level=INFO
    END
    ${goto_forecast_page_link_visible}    Is Element Visible On Webpage
    ...    ${PLAN_STATUS_GOTO_FORECAST_LINK}
    IF    ${goto_forecast_page_link_visible}
        Click Element On Webpage    ${PLAN_STATUS_GOTO_FORECAST_LINK}
        ...    error_message=Failed to click on go to forecast page link on plan status page
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_FORECAST_TABLE_HEADER}    timeout=${MEDIUM_TIMEOUT}
        ...    error_message=Failed to navigate to forecast page after clicking forecast link on plan status page
    END
    Capture Screenshot On Webpage

Go To The Workload Page On Plan Status Page On Web
    [Documentation]    This keyword is used to navigate to workload page after
    ...    workload is generated.
    TRY
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_GOTO_WORKLOAD_LINK}
    EXCEPT
        No Operation
    END
    ${goto_workload_page_link_visible}    Is Element Visible On Webpage
    ...    ${PLAN_STATUS_GOTO_WORKLOAD_LINK}
    IF    ${goto_workload_page_link_visible}
        Click Element On Webpage    ${PLAN_STATUS_GOTO_WORKLOAD_LINK}
    END
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Go To Schedule Page On Web
    [Documentation]    This keyword is used to navigate to schedule page after
    ...    week plan/workload are generated.
    TRY
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_GOTO_SCHEDULE_LINK}
    EXCEPT
        No Operation
    END
    ${goto_schedule_page_link_visible}    Is Element Visible On Webpage
    ...    ${PLAN_STATUS_GOTO_SCHEDULE_LINK}
    IF    ${goto_schedule_page_link_visible}
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_EMPTY_BATCH}    timeout=${SCHEDULE_GENERATION_TIMEOUT}
        ...    error_message=Empty batch message is not visible on plan status page before navigating to schedule page
        Click Element On Webpage    ${PLAN_STATUS_GOTO_SCHEDULE_LINK}
        Wait Until Element Disappears On Webpage    ${PLAN_STATUS_GOTO_SCHEDULE_LINK}
        Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_INITIAL_STATE}    timeout=${LONG_TIMEOUT}
        ...    error_message=Failed to navigate to schedule page after clicking schedule link on plan status page
    END
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Verify If Schedule Status Is Displayed As Expected On Plan Status Page On Web
    [Documentation]    This keyword verifies the schedule status text matches with the passed argument value.
    ...    | =Arguments= | =Description= |
    ...    | expected_schedule_status    | Expected schedule status to verify |
    [Arguments]    ${expected_schedule_status}
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_SCHEDULE_STATUS_CONTAINER}
    ${actual_schedule_status}    Get Element Text On Webpage    ${PLAN_STATUS_SCHEDULE_STATUS_CONTAINER}
    IF    "${expected_schedule_status}" in "${actual_schedule_status}"
        Log    Schedule status value is ${actual_schedule_status} and is as expected.
    ELSE
        Fail    Schedule status value is ${actual_schedule_status} which doesn't match with expected schedule
        ...    status value
    END
    Capture Screenshot On Webpage

Delete Current Schedule On Plan Status Page On Web
    [Documentation]    This keyword is to delete the current schedule.
    Click Element On Webpage    ${PLAN_STATUS_ACTION_DROPDOWN}
    ...    error_message=Failed to click on action dropdown to delete schedule
    Click Element On Webpage    ${PLAN_STATUS_ACTION_DELETE_CURRENT_SCHEDULE}
    ...    error_message=Failed to click on delete current schedule option
    Click Element On Webpage    ${PLAN_STATUS_OK_BTN}
    ...    error_message=Failed to click on OK button to confirm schedule deletion
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_PLAN_PROGRESS_PANEL}
    ...    timeout=${LONG_TIMEOUT}    error_message=Plan progress panel is not displayed after confirming schedule deletion
    Capture Screenshot On Webpage

Delete Workload If Already Generated On Plan Status Page On Web
    [Documentation]    This keyword deletes the Workload if already generated.
    ...    User needs to be on RailRoad page.
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_DELETE_WORKLOAD}
    ${delete_wkld_button_enabled}    Is Element Enabled On Webpage
    ...    ${PLAN_STATUS_DELETE_WORKLOAD}
    IF    ${delete_wkld_button_enabled}
        Delete The Workload On Plan Status Page On Web
    END
    ${delete_wkld_schd_button_enabled}    Is Element Enabled On Webpage
    ...    ${PLAN_STATUS_DELETE_WKLD_SCHD}
    IF    ${delete_wkld_schd_button_enabled}
        Delete The Workload And Schedule On Plan Status Page On Web
    END

Delete The Workload On Plan Status Page On Web
    [Documentation]    This keyword deletes the Workload. User needs to be on RailRoad
    ...    page and workload should already be created.
    Click Element On Webpage    ${PLAN_STATUS_DELETE_WORKLOAD}
    ...    error_message=Failed to click on delete workload button
    Click Element On Webpage    ${PLAN_STATUS_DELETE_WORKLOAD_CONFIRMATION_OK}
    ...    error_message=Failed to click on OK button to confirm workload deletion
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_SUCCESS_NOTIFIER_MESSAGE}
    ...    timeout=${LONG_TIMEOUT}    error_message=Success message notifier is not displayed after confirming workload deletion
    Capture Screenshot On Webpage
    ${message_content}    Get Element Text On Webpage    ${PLAN_STATUS_SUCCESS_MESSAGE_CONTENT}
    Log    ${message_content}
    Capture Screenshot On Webpage

Delete The Workload And Schedule On Plan Status Page On Web
    [Documentation]    This keyword deletes the Workload and Schedule. User needs to be on RailRoad
    ...    page and workload and schedule should already be created.
    Click Element On Webpage    ${PLAN_STATUS_DELETE_WKLD_SCHD}
    Click Element On Webpage    ${PLAN_STATUS_DELETE_WKLD_SCHD_CONFIRM_OK}
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    ${message_content}    Get Element Text On Webpage    ${PLAN_STATUS_SUCCESS_MESSAGE_CONTENT}
    Log    ${message_content}
    Capture Screenshot On Webpage

Verify If Workpattern Not Mapped Message Is Displayed On Plan Status Page On Web
    [Documentation]    This keyword verifies if work pattern not mapped message is displayed.
    TRY
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_WORKPATTERN_NOT_MAPPED_MSG}
        Capture Screenshot On Webpage
        ${message_content}    Get Element Text On Webpage    ${PLAN_STATUS_WORKPATTERN_NOT_MAPPED_MSG}
        Log    ${message_content}
    EXCEPT
        Fail    Success message notifier is not displayed
        Capture Screenshot On Webpage
    END

Generate Optimized Schedule On Plan Status Page On Web
    [Documentation]    Generates an optimized schedule for the week with environment-aware button selection.
    ...    Priority: 1) Optimized Schedule button (standard environments)
    ...    2) Template-based Schedule button (TB_SB/legacy environments without optimized option)
    ...    You need to be on the Rail Road Page and have created week plan and workload.
    ...    | =Arguments= | =Description= |
    ...    | (none) | No arguments required. |
    ...    Example usage:
    ...    | Generate Optimized Schedule On Plan Status Page On Web
    ${table_visible}    Is Element Visible On Webpage    ${PLAN_STATUS_FORECAST_TABLE_BODY}
    IF    ${table_visible}
        Wait Until Element Disappears On Webpage    ${PLAN_STATUS_FORECAST_TABLE_BODY}    timeout=${LONG_TIMEOUT}
    END
    ${generate_optimized_schedule_btn_visible}    Is Element Visible On Webpage
    ...    ${PLAN_STATUS_GENERATE_OPTIMIZED_SCHEDULE_BUTTON}
    IF    ${generate_optimized_schedule_btn_visible}
        Log    Optimized schedule button is available. Using optimized schedule generation.    level=INFO
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_GENERATE_OPTIMIZED_SCHEDULE_BUTTON}    timeout=${LONG_TIMEOUT}
        ...    error_message=Generate optimized schedule button is not visible on plan status page
        Click Element On Webpage    ${PLAN_STATUS_GENERATE_OPTIMIZED_SCHEDULE_BUTTON}
        Verify Success Notifier Message On Plan Status Page On Web
        Capture Screenshot On Webpage
    ELSE
        ${template_schedule_btn_visible}    Is Element Visible On Webpage
        ...    ${PLAN_STATUS_GENERATE_SCHEDULE_USING_TEMPLATE_BTN_ALTERNATE}
        IF    ${template_schedule_btn_visible}
            Log    Optimized schedule button not available. Falling back to template-based schedule generation (TB_SB environment).
            ...    level=INFO
            Click Element On Webpage    ${PLAN_STATUS_GENERATE_SCHEDULE_USING_TEMPLATE_BTN_ALTERNATE}
            Verify Success Notifier Message On Plan Status Page On Web
            Capture Screenshot On Webpage
        ELSE
            Fail    Neither optimized schedule button nor template-based schedule button is visible on plan status page
        END
    END

Verify If Generate Optimized Schedule Is Completed On Plan Status Page On Web
    [Documentation]    Verifies schedule generation completion with environment-aware button checks.
    ...    Checks for completion in this priority order:
    ...    1) Optimized Schedule button check mark (standard environments)
    ...    2) Template-based Schedule button check mark (TB_SB environments)
    ...    | =Arguments= | =Description= |
    ...    | (none) | No arguments required. |
    ...    Example usage:
    ...    | Verify If Generate Optimized Schedule Is Completed On Plan Status Page On Web
    ${generate_optimized_schedule_btn_checked}    Wait Until Mentioned Button Is Checked On Plan Status Page On Web
    ...    ${PLAN_STATUS_GENERATE_OPTIMIZED_SCHEDULE_BUTTON_CHECK}
    IF    ${generate_optimized_schedule_btn_checked}
        Capture Screenshot On Webpage
    ELSE
        Log    Optimized schedule button check mark not found. Checking for template schedule completion.    level=INFO
        ${template_schedule_btn_checked}    Wait Until Mentioned Button Is Checked On Plan Status Page On Web
        ...    ${PLAN_STATUS_GENERATE_SCHD_USING_TEMPLATE_BTN_CHECK}
        IF    ${template_schedule_btn_checked}
            Capture Screenshot On Webpage
        ELSE
            Fail    Failed to generate optimized or template-based schedule. No completion check marks found.
        END
    END

Wait Until Mentioned Button Is Checked On Plan Status Page On Web
    [Documentation]    This keyword waits until the mentioned button is checked.
    ...    | =Arguments= | =Description= |
    ...    | button_locator    | Locator of the button to wait for it to be checked |
    [Arguments]    ${button_locator}
    Wait Until Page Is Loaded
    ${retry}    ${retry_interval}    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}
    ...    Refresh Batch Generation Section Until Execution Completes On Plan Status Page On Web
    ${button_visible}    Is Element Visible On Webpage    ${button_locator}
    RETURN    ${button_visible}

Navigate To Mentioned Week On Plan Status Page On Web
    [Documentation]
    ...    Navigates to a specific week on the Plan Status Page by comparing the target date with the currently selected week.
    ...    The keyword converts the provided date format and navigates forward through weeks until the target week is found.
    ...    | =Arguments= | =Description= |
    ...    | target_week_date    | Date of the target week to navigate to (in MM/DD/YYYY format) |
    ...    Example usage:
    ...    | Navigate To Mentioned Week On Plan Status Page On Web    12/25/2024
    [Arguments]    ${target_week_date}
    ${source_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${required_date_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${target_week_datetime}    Convert Date    ${target_week_date}    date_format=${source_date_format}
    ...    result_format=${required_date_format}
    Navigate To Plan Status Page From Week Schedule Page On Web
    ${week_date_label}    Get Selected Week From Week Navigation On Plan Status Page On Web
    WHILE    '${target_week_datetime}' not in '${week_date_label}'    limit=${LOOP_TIMEOUT}
        Navigate To Next Week On Plan Status Page On Web
        ${week_date_label}    Get Selected Week From Week Navigation On Plan Status Page On Web
    END
    Wait Until Page Is Loaded

Navigate To Next Week On Plan Status Page On Web
    [Documentation]    This keyword navigates the user to next week for checking the workload values.
    Click Element On Webpage    ${PLAN_STATUS_NEXT_WEEK_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Delete Schedule On Plan Status Page On Web
    [Documentation]    This keyword deletes the schedule for the selected week.
    Click Element On Webpage    ${PLAN_STATUS_DELETE_SCHD}
    Click Element On Webpage    ${PLAN_STATUS_DELETE_SCHD_CONFIRM_OK}
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${PLAN_STATUS_SUCCESS_NOTIFIER_MESSAGE}
    ${is_delete_workload_visible}    Is Element Visible On Webpage    ${PLAN_STATUS_DELETE_WORKLOAD}
    RETURN    ${is_delete_workload_visible}

Move To The Future Week On Plan Status Page On Web
    [Documentation]    This keyword moves to the future week on Plan Status Page.
    ...    | =Arguments= | =Description= |
    ...    | weeks_to_move    | Number of weeks to move forward |
    [Arguments]    ${weeks_to_move}=1
    FOR    ${index}    IN RANGE    ${weeks_to_move}
        Navigate To Next Week On Plan Status Page On Web
        Log    Moved to next week ${index} times.
    END

Return To Plan Status Page From RailRoad Option On Web
    [Documentation]    This keyword navigates back to Plan Status Page from RailRoad options like Forecast/Workload/Schedule.
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_RAILROAD_DRPDWN}
    ...    timeout=${MEDIUM_TIMEOUT}    error_message=Railroad dropdown is not visible to return back to Plan Status page
    Click Element On Webpage    ${PLAN_STATUS_RAILROAD_DRPDWN}
    ...    error_message=Failed to click on railroad dropdown to return back to Plan Status page
    Click Element On Webpage    ${PLAN_STATUS_PLAN_STATUS_OPTION}
    ...    error_message=Failed to click on Plan Status option from railroad dropdown to return back to Plan Status page
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_PLAN_TITLE}
    ...    timeout=${MEDIUM_TIMEOUT}    error_message=Failed to navigate back to Plan Status page from railroad dropdown

Get Selected Week From Week Navigation On Plan Status Page On Web
    [Documentation]    This keyword gets the week date from week navigation on Plan Status page.
    ...    It assumes that the Plan Status page is already displayed.
    ...    | =Returns= | =Description= |
    ...    | selected_week | The label of the selected week |
    ...    Example usage:
    ...    | ${week_label}    Get Selected Week From Week Navigation On Plan Status Page On Web
    ${selected_week}    Get Element Text On Webpage    ${PLAN_STATUS_CAL_NAV_DATE_LABEL}
    RETURN    ${selected_week}

Check If Plan Status Page Displayed On Web
    [Documentation]    This keyword checks if Plan Status page is displayed.
    Wait Until Page Is Loaded
    ${is_plan_status_displayed}    Is Element Visible On Webpage    ${PLAN_STATUS_PLAN_TITLE}
    RETURN    ${is_plan_status_displayed}

Navigate To Required Week On Plan Status Page On Web
    [Documentation]    This keyword navigates to the required week on Plan Status Page by clicking on next week button specified number of times.
    ...    | =Arguments= | =Description= |
    ...    | week | The week in CALENDAR_NAVIGATION_DATE_FORMAT to navigate to |
    [Arguments]    ${weeks_to_move}    ${week}
    ${date_label}    Update Locator With Dynamic Values    ${PLAN_STATUS_PAGE_DATE_LABEL}    DATE=${week}
    FOR    ${index}    IN RANGE    ${weeks_to_move}
        Click Element On Webpage    ${PLAN_STATUS_NEXT_WEEK_BTN}
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_MAIN_PAGE_CONTAINER}
        ...    error_message=plan status main page container not visible after clicking next week button
        Log    Clicked on Next Week button ${index} times.
    END
    Wait Until Element Is Visible On Webpage    ${date_label}    timeout=${LONG_TIMEOUT}
    ...    error_message=Target week date label not visible after navigating to required week

Refresh Batch Generation Section Until Execution Completes On Plan Status Page On Web
    [Documentation]    This keyword refreshes the batch generation section until batch execution completes.
    Click Element On Webpage    ${PLAN_STATUS_REFRESH_ICON}    error_message=Failed to click on refresh icon
    Wait Until Page Is Loaded
    ${batch_section_disappeared}    Run Keyword And Return Status    Wait Until Element Disappears On Webpage
    ...    ${PLAN_STATUS_BATCH_QUEUE_SECTION}    ${SHORT_TIMEOUT}
    ${disabled_timeline_container}    Run Keyword And Return Status    Wait Until Element Disappears On Webpage
    ...    ${PLAN_STATUS_DISABLED_TIMELINE_CONTAINER}    ${SHORT_TIMEOUT}
    Should Be True    ${disabled_timeline_container} and ${batch_section_disappeared}
    ...    Batch execution did not complete within expected time

Select Week Number On Plan Status Page On Web
    [Documentation]    Selects the week on the Plan Status page using the calendar date picker.
    ...    Uses the same shared calendar component (FIXEDSHIFTSPAGE locators) as Labor Forecast.
    ...    | =Arguments= | =Description= |
    ...    | week_day_input | Week-day offset string (e.g., 4_0 for 4 weeks forward, start of week) |
    ...    Example usage:
    ...    | Select Week Number On Plan Status Page On Web    4_0
    [Arguments]    ${week_day_input}
    ${target_date}    Calculate Date From Week Day Offset    ${week_day_input}
    ${date_format_year_only}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${date_format_month_only}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${date_format}    Get Config Value    DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA
    ${target_year}    Convert Date    ${target_date}    result_format=${date_format_year_only}
    ${target_month_name}    Convert Date    ${target_date}    result_format=${date_format_month_only}
    ${target_day_formatted}    Convert Date    ${target_date}    result_format=${date_format}
    ${year_last_2_digits}    Evaluate    str('${target_year}')[2:]
    Wait Until Page Is Loaded
    Click Element On Webpage    ${PLAN_STATUS_CAL_NAV_DATE_LABEL}
    Click Element On Webpage    ${FIXEDSHIFTSPAGE_CALENDAR_MONTH_YEAR_HEADER}
    ${year_button_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_YEAR_BUTTON_BY_YEAR}    TARGET_YEAR=${target_year}
    ${is_element_present}    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${year_button_locator}
    IF    ${is_element_present}
        Click Element On Webpage    ${year_button_locator}
    ELSE
        Click Element On Webpage    ${FIXEDSHIFTSPAGE_YEAR_BUTTON_DYNAMIC_BY_YEAR}
    END
    ${year_digits_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_YEAR_DIGITS_BY_LAST_TWO}
    ...    YEAR_LAST_2_DIGITS=${year_last_2_digits}
    Click Element On Webpage    ${year_digits_locator}
    ${month_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_MONTH_BUTTON_BY_NAME}    MONTH_NAME=${target_month_name}
    Click Element On Webpage    ${month_locator}
    ${day_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_DAY_BUTTON_BY_FORMATTED_DATE}
    ...    FORMATTED_DATE=${target_day_formatted}
    Wait Until Element Is Visible On Webpage    ${day_locator}
    ${week_number_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_WEEK_NUMBER_BUTTON}    DAY_LOCATOR=${day_locator}
    Click Element On Webpage    ${week_number_locator}
    Wait Until Page Is Loaded
    Wait Until Element Disappears On Webpage    ${FIXEDSHIFTPAGE_CALENDAR_POP_UP}
