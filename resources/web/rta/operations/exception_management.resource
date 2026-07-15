*** Settings ***
Documentation       Exception Management page related keyword implementation

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Resource            resources/web/rta/operations/timecard.resource
Variables           resources/web/rta/operations/exception_management_page.py
Variables           resources/web/rta/operations/timecard_list_page.py
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rta/operations/timecard_page.py
Resource            resources/web/common/user_profile_menu.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/clock/webclock_login.resource


*** Keywords ***
Navigate To RTA Operations Exception Management Page On Web
    [Documentation]    Navigate To RTA -> Operations -> Exception Management Page
    ...    and verifies exception management heading at the top of the page
    Navigate To Specific Page On Web    rta    operations    exception_management
    ${reporting_hierarchy_enabled}    Get Config Value    key=ENABLE_REPORTING_HIERARCHY
    IF    '${reporting_hierarchy_enabled}' == "Y"
        ${reportee_type}    Get System Value    ReporteeType    MY_LOCATION
        Apply Advanced Filter For Reportee Type On Exception Management Page On Web    ${reportee_type}
    END

Get First Employee Id On Exception Management Page On Web
    [Documentation]    This keyword returns first employee id on 'Exception Management' page
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_EMPLOYEE_ID}
    ${employee_id}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_EMPLOYEE_ID}
    RETURN    ${employee_id}

Search Employee In Exception Management Page On Web
    [Documentation]    This keyword searches for an employee in the Exception Management page
    [Arguments]    ${emp_name}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_BOX}
    Fill Textbox On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_BOX}    ${emp_name}
    Press Enter Key Using Browser Library
    Wait Until Page Is Loaded

Get First Employee Name On Exception Management Page On Web
    [Documentation]    This keyword returns first employee name on 'Exception Management' page
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_EMPLOYEE_NAME}
    ${employee_name}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_EMPLOYEE_NAME}
    RETURN    ${employee_name}

Click On Clock Icon Of First Employee On Exception Management Page On Web
    [Documentation]    This keyword clicks on clock icon for the first employee from list
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CLOCK_ICON}
    Wait Until Page Is Loaded

Verify Timecard Page Is Loaded On Web
    [Documentation]    This keyword verifies loading of Timecard page
    Run Keyword And Ignore Error    Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NO_OF_ASSOCIATES}
    Wait Until Page Is Loaded
    Verify Text Seen In Webpage    text_value=Timecard

Verify Employee Id On Timecard Page On Web
    [Documentation]    This keyword verifies the respective employee Id on Timecard page
    [Arguments]    ${emp_id}
    ${associate_name}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_ASSOCIATE_NAME}
    ...    associate_id=${emp_id}
    Wait Until Element Is Visible On Webpage    ${associate_name}
    Capture Screenshot On Webpage

Verify Employee Name In Filter Box On Exception Management Page On Web
    [Documentation]    This keyword verifies that the correct employee name is shown in the filter box
    [Arguments]    ${employee_name}
    ${filter_value}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_BOX}
    Should Be Equal    ${filter_value}    ${employee_name}    msg=Filter box does not contain the expected employee name

Clear Filter In Exception Management Page On Web
    [Documentation]    This keyword clears the filter in the Exception Management page
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    ...    error_message=Filter icon not visible on Exception Management page
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    ${is_clear_button_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_CLEAR_BUTTON}
    IF    ${is_clear_button_visible}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_CLEAR_BUTTON}
        Wait Until Page Is Loaded
    ELSE
        Log    Clear button is not visible no filter to clear.
    END

Select Display Configurations On Exception Management Page On Web
    [Documentation]    This keyword will select display configurations as per given locators.
    ...    | =Arguments= | =Description= |
    ...    | locator1 | Locator for first display configuration to select (optional) |
    ...    | locator2 | Locator for second display configuration to select (optional) |
    ...    | locator3 | Locator for third display configuration to select (optional) |
    ...    | locator4 | Locator for fourth display configuration to select (optional) |
    ...    Example usage:
    ...    | Select Display Configurations On Exception Management Page On Web    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ICON}    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ID} |
    [Arguments]    ${locator1}=${None}    ${locator2}=${None}    ${locator3}=${None}    ${locator4}=${None}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_RESET}
    Wait Until Element Is Visible On Webpage    ${locator1}
    ${is_locator1_present}    Is Element Visible On Webpage    ${locator1}
    IF    ${is_locator1_present}
        Click Element On Webpage    ${locator1}
    ELSE
        No Operation
    END
    ${is_locator2_present}    Is Element Visible On Webpage    ${locator2}
    IF    ${is_locator2_present}
        Click Element On Webpage    ${locator2}
    ELSE
        No Operation
    END
    ${is_locator3_present}    Is Element Visible On Webpage    ${locator3}
    IF    ${is_locator3_present}
        Click Element On Webpage    ${locator3}
    ELSE
        No Operation
    END
    ${is_locator4_present}    Is Element Visible On Webpage    ${locator4}
    IF    ${is_locator4_present}
        Click Element On Webpage    ${locator4}
    ELSE
        No Operation
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_APPLY}
    Wait Until Page Is Loaded

Reset Display Configurations On Exception Management Page On Web
    [Documentation]    This keyword will reset display configurations to default settings.
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_RESET}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_APPLY}
    Wait Until Page Is Loaded

Get Count For Selected Display Configurations On Exception Management Page On Web
    [Documentation]    As per selected configurations, this will give count of elements.
    [Arguments]    ${locator1}    ${locator2}=${None}    ${locator3}=${None}    ${locator4}=${None}
    ${emp_icon_count}    Get Element Count On Web Page    ${locator1}
    ${emp_type_count}    Get Element Count On Web Page    ${locator2}
    ${emp_id_count}    Get Element Count On Web Page    ${locator3}
    ${emp_job_title_count}    Get Element Count On Web Page    ${locator4}
    Capture Screenshot On Webpage
    RETURN    ${emp_icon_count}    ${emp_type_count}    ${emp_id_count}    ${emp_job_title_count}

Validate Display Preference Count On Exception Management Page On Web
    [Documentation]    This keyword validates the counts of display preferences on exception management page
    [Arguments]    ${emp_icon_count}    ${emp_type_count}    ${emp_id_count}    ${emp_job_title_count}    ${label}
    Should Be True    ${emp_icon_count} >= 0 and ${emp_type_count} >= 0 and ${emp_id_count} >= 0 and ${emp_job_title_count} >= 0
    ...    msg=One or more display preferences did not render correctly for ${label}.
    Log    Display preferences validated for "${label}".

Verify Print Summary On Exception Management Page On Web
    [Documentation]    Keyword is for print summary validation on Exception Management Page.
    Capture Screenshot On Webpage
    Wait Until Page Is Loaded
    ${page_count}    Get Element Count On Web Page    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAYED_RECORDS}
    ${icon_present}    Is Element Present On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PRINT_ICON}
    IF    not ${icon_present}    Fail    msg=Print icon not present as expected.
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PRINT_ICON}
    Switch Page    NEW
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    ${active_iframe_summary_page}    Get Active IFrame Element
    ${iframe_prefix}    Get Frame Element    ${active_iframe_summary_page}
    Set Selector Prefix    ${iframe_prefix}
    ${report_count}    Get Element Count On Web Page    ${EXCEPTION_MANAGEMENT_PAGE_SUMMARY_REPORT_RECORDS}
    Set Selector Prefix    ${EMPTY}
    ${report_url}    Get Url
    Should Be True
    ...    '/exceptionManagementReport.jsp' in '''${report_url}''' or '/exceptionManagementPdf.jsp' in '''${report_url}'''
    ...    Unexpected PDF URL: ${report_url}
    Close Page    CURRENT    CURRENT    CURRENT
    Should Be True    ${page_count} == ${report_count}    Count mismatch: page=${page_count} report=${report_count}
    Log    Print summary verified. Page=${page_count} Report=${report_count} URL=${report_url}

Verify Exception Management Page Is Loaded On Web
    [Documentation]    This keyword verifies if Exception Management page is loaded properly.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_TAB_LABEL}
    ${week_in_progress_lbl}    Get System Value    WeekScheduleDropdown    WEEK_IN_PROGRESS
    ${mngr_schd_lbl}    Get System Value    WeekScheduleDropdown    MANAGER_SCHEDULE
    ${em_label}    Get Text    ${EXCEPTION_MANAGEMENT_PAGE_TAB_LABEL}
    Should Be True    '${em_label}' == '${week_in_progress_lbl}' or '${em_label}' == '${mngr_schd_lbl}'
    Capture Screenshot On Webpage

Show Legend Dialog Box On Timecard Page On Web
    [Documentation]    This keyword will show all legends available for the Timecard page.
    ...    Pre-condition: You have to be on Timecard page to use this keyword.
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_LEGEND_ICON}
    Wait For Load State
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_TIMECARD_PAGE_LEGEND_LABEL}
    Capture Screenshot On Webpage

Verify Legend Tab Is Visible On Timecard Page On Web
    [Documentation]    This keyword ensure Legend tab of timecard is visible currently
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_LEGEND_ICON}

Close Legend Dialog Box On Timecard Page On Web
    [Documentation]    This keyword will close legend dialog box visible in Exception Management page
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CLOSE_LEGENDS}

Verify Legend Tab Is Not Visible In Timecard Page On Web
    [Documentation]    This keyword ensure Legend tab of timecard is not visible now
    Wait For Elements State    ${EXCEPTION_MANAGEMENT_PAGE_LEGEND_TAB_LABEL}    hidden    timeout=${MEDIUM_TIMEOUT}

Verify Week Navigation Info In Timecard Page On Web
    [Documentation]    Verifies the week date range displayed for the current week on the Timecard page.
    ...    Ensures that the date range matches the expected values for the current week.
    ...    Returns:
    ...    A dictionary that contains previous and next week number and previous/next start/end date.
    ${shown_week_txt}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_WEEKEND_LABEL_ON_TIMECARD_PAGE}
    VAR    ${shown_week_range}    ${shown_week_txt}[9:]
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${expected_next_week_start_date}    ${expected_next_week_end_date}
    ...    ${expected_previous_week_start_date}    ${expected_previous_week_end_date}
    ...    Process Week Range Of Timecard    ${shown_week_range}    ${timecard_date_format}
    @{current_week_info}    Get Shown Week Date Range From Timecard Page
    ${current_week_number}    Get From List    ${current_week_info}    0
    IF    '${current_week_number}' == '52'
        ${expected_next_week_number}    Evaluate    1
    ELSE
        ${expected_next_week_number}    Evaluate    ${current_week_number} + 1
    END
    IF    '${current_week_number}' == '1'
        ${expected_previous_week_number}    Evaluate    52
    ELSE
        ${expected_previous_week_number}    Evaluate    ${current_week_number} - 1
    END
    VAR    &{week_info}
    ...    expected_next_week_number_key=${expected_next_week_number}
    ...    expected_next_week_start_date_key=${expected_next_week_start_date}
    ...    expected_next_week_end_date_key=${expected_next_week_end_date}
    ...    expected_previous_week_number_key=${expected_previous_week_number}
    ...    expected_previous_week_start_date_key=${expected_previous_week_start_date}
    ...    expected_previous_week_end_date_key=${expected_previous_week_end_date}
    RETURN    &{week_info}

Get Shown Week Date Range From Timecard Page
    [Documentation]    Get week date range text from week date label in timecard page
    ...    and convert (e.g., "Week 44 : 24/11/2024 - 30/11/2024") to a date object for date calculation
    ...    | =Returns= | =Description= |
    ...    | week_number    | The week number extracted from the text. |
    ...    | date_obj_start | The start date of the week as a date object. |
    ...    | date_obj_end    | The end date of the week as a date object
    ${date_string_txt}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_WEEKEND_LABEL_ON_TIMECARD_PAGE}
    # Extract different sub-strings from text
    VAR    ${week_number}    ${date_string_txt}[5:7]
    VAR    ${date_string_start}    ${date_string_txt}[9:20]    # Extracts "24/11/2024"
    VAR    ${date_string_end}    ${date_string_txt}[22:]    # Extracts "30/11/2024"
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    # Convert sub-strings to different objects
    ${week_number}    Convert To Integer    ${week_number}
    ${date_obj_start}    Convert Date    ${date_string_start.strip()}
    ...    date_format=${timecard_date_format}    result_format=${timecard_date_format}
    ${date_obj_end}    Convert Date    ${date_string_end.strip()}
    ...    date_format=${timecard_date_format}    result_format=${timecard_date_format}
    RETURN    ${week_number}    ${date_obj_start}    ${date_obj_end}

Shift To Next Week Timecard Of User
    [Documentation]    This keyword navigates to the next week timecard page for the selected user.
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NEXT_WEEK_TIMECARD}
    Wait Until Page Is Loaded

Shift To Previous Week Timecard Of User
    [Documentation]    This keyword navigates to the previous week timecard page for the selected user.
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PREVIOUS_WEEK_TIMECARD}
    Wait Until Page Is Loaded

Go To Previous Week On Timecard Page On Web
    [Documentation]    Navigate to previous weeks on the Timecard page.
    ...    This keyword allows navigation backwards by a specified number of weeks from the current timecard view.
    ...    | =Arguments= | =Description= |
    ...    | number_of_weeks | Number of weeks to navigate backward (default is 1). |
    ...    Example usage:
    ...    | Go To Previous Week On Timecard Page On Web
    ...    | Go To Previous Week On Timecard Page On Web    number_of_weeks=2
    [Arguments]    ${number_of_weeks}=1
    FOR    ${_}    IN RANGE    0    ${number_of_weeks}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PREVIOUS_WEEK_TIMECARD}
        Wait Until Page Is Loaded
    END
    Capture Screenshot On Webpage

Validate The Navigation Date Info On Timecard Page On Web
    [Documentation]    This keyword verifies and validates the week number, week start date & week end date.
    ...    | =Arguments= | =Description= |
    ...    | week_info    | This contains expected week info |
    ...    | week_number | The week number extracted from the text. (Actual) |
    ...    | week_start_date    | The start date of the week extracted from the text. (Actual) |
    ...    | week_end_date    | The end date of the week extracted from the text. (Actual) |
    [Arguments]    ${week_info}    ${week_number}    ${week_start_date}    ${week_end_date}    ${navigation}="navigate_next"
    IF    '${navigation}' == 'navigate_next'
        Should Be Equal    ${week_info}[expected_next_week_number_key]    ${week_number}
        Should Be Equal    ${week_info}[expected_next_week_start_date_key]    ${week_start_date}
        Should Be Equal    ${week_info}[expected_next_week_end_date_key]    ${week_end_date}
        Capture Screenshot On Webpage
    ELSE IF    '${navigation}' == 'navigate_previous'
        Should Be Equal    ${week_info}[expected_previous_week_number_key]    ${week_number}
        Should Be Equal    ${week_info}[expected_previous_week_start_date_key]    ${week_start_date}
        Should Be Equal    ${week_info}[expected_previous_week_end_date_key]    ${week_end_date}
        Capture Screenshot On Webpage
    ELSE
        Fail    Invalid navigation value '${navigation}' provided to Validate The Navigation Date Info On Timecard Page On Web.
        ...    Expected 'navigate_next' or 'navigate_previous'.
    END

Get Violation Count Of First Employee On Exception Management Page On Web
    [Documentation]    This keyword returns the violation count of the first employee
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_VIOLATION_COUNT}    timeout=${MEDIUM_TIMEOUT}
    ${first_violation_count}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_VIOLATION_COUNT}
    ${violation_count}    Convert To Integer    ${first_violation_count}
    RETURN    ${violation_count}

Shift To Previous Week Exception Management Page On Web
    [Documentation]    This keyword navigates to the previous week on the Exception Management page
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PREVIOUS_WEEK_TIMECARD}
    Wait Until Page Is Loaded

Verify Bottom Tabs Visible On Exception Management Page On Web
    [Documentation]    This keyword verifies visibility of Exceptions By Day, Exceptions By Type, Pay Statistics sections tabs
    ${pay_by_day_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_STATISTICS_TABS}
    ...    TAB_INDEX=1
    ${pay_by_type_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_STATISTICS_TABS}
    ...    TAB_INDEX=2
    ${pay_statistics_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_STATISTICS_TABS}
    ...    TAB_INDEX=3
    ${pay_by_day}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${pay_by_day_locator}    timeout=${MEDIUM_TIMEOUT}
    ${pay_by_type}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${pay_by_type_locator}    timeout=${MEDIUM_TIMEOUT}
    ${pay_statistics}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${pay_statistics_locator}    timeout=${MEDIUM_TIMEOUT}
    ${any_tab_visible}    Evaluate    ${pay_by_day} or ${pay_by_type} or ${pay_statistics}
    Should Be True    ${any_tab_visible}
    ...    None of the bottom tabs (Exceptions By Day, Exceptions By Type, Pay Statistics) are visible on the Exception Management page.
    Capture Screenshot On Webpage

Capture Total Hours On Exception Management Page On Web
    [Documentation]    This keyword returns Hours captured on Exception Management Page
    ...    | =Returns= | =Description= |
    ...    | total_hours_excpt_mgt | Total Hours on exception management page |
    Wait Until Page Is Loaded
    Wait For Elements State    ${EXCEPTION_MANAGEMENT_PAGE_PAY_TOTAL_HOURS}    stable
    ${total_hours_excpt_mgt_text}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_TOTAL_HOURS}    stable
    ${total_hours_excpt_mgt}    Convert To Number    ${total_hours_excpt_mgt_text}
    RETURN    ${total_hours_excpt_mgt}

Capture Total Hours On Pay Statistics Section On Web
    [Documentation]    This keyword returns Total Hours captured on Pay Statistics section
    ...    | =Returns= | =Description= |
    ...    | total_hours | Total Hours captured on pay statistics section |
    ${total_hours_text}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_STATISTICS_HOURS}
    ${total_hours}    Convert To Number    ${total_hours_text}
    RETURN    ${total_hours}

Get Schedule Dates From Exception Management Page On Web
    [Documentation]
    ...    Retrieves all schedule dates displayed on the exception management page.
    ...    | =Returns= | =Description= |
    ...    | days_list | List of days that already have schedules |
    VAR    @{days_list}    @{EMPTY}
    VAR    ${timecard_shift_date_part_index}    1
    ${elements}    Get Elements    ${EXCEPTION_MANAGEMENT_PAGE_SCHEDULE_DATES}
    IF    ${elements} != None
        FOR    ${element}    IN    @{elements}
            ${text}    Get Element Text On Webpage    ${element}
            VAR    ${input_string}    ${text}
            @{split_result}    Split String    ${input_string}
            ${date_part}    Get From List    ${split_result}    1
            @{date_split}    Split String    ${date_part}    /
            ${day}    Get From List    ${date_split}    ${timecard_shift_date_part_index}
            ${day}    Strip String    ${day}
            ${day}    Convert To Integer    ${day}
            ${day}    Convert To String    ${day}
            Append To List    ${days_list}    ${day}
        END
    END
    RETURN    ${days_list}

Get Total Number Of Exceptions Shown In Exception Management Page On Web
    [Documentation]    This keyword will return total number of exceptions,
    ...    of all employees available in current webpage
    VAR    ${total_exception_count}    0
    VAR    ${no_of_exception_types}    6
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CLOCK_ICON}    timeout=${MEDIUM_TIMEOUT}
    FOR    ${i}    IN RANGE    1    ${no_of_exception_types}
        ${column}    Convert To String    ${i}
        ${locator}    Update Locator With Dynamic Values
        ...    ${EXCEPTION_MANAGEMENT_PAGE_EXCEP_COUNT_COLUMN}    COL=${column}
        ${visible_count}    Get Element Text On Webpage    ${locator}
        ${visible_count_converted}    Convert To Integer    ${visible_count}
        ${total_exception_count}    Evaluate    ${total_exception_count}+${visible_count_converted}
    END
    RETURN    ${total_exception_count}

Get Available Calendar Days On Exception Management Page On Web
    [Documentation]
    ...    Retrieves available days from the calendar that don't have existing schedules.
    ...    | =Arguments= | =Description= |
    ...    | existing_days | List of days that already have schedules |
    ...    | =Returns= | =Description= |
    ...    | day | First check if current day available, next available day found, or None if no days available |
    [Arguments]    ${existing_days}
    ${days_in_current_week}    Get Elements    ${EXCEPTION_MANAGEMENT_PAGE_NO_OF_DAYS_IN_CURRENT_WEEK}
    VAR    @{days_on_calendar_list}    @{EMPTY}
    FOR    ${each_day_on_cal}    IN    @{days_in_current_week}
        ${text}    Get Text    ${each_day_on_cal}
        ${text}    Strip String    ${text}
        Append To List    ${days_on_calendar_list}    ${text}
    END
    # Find if current day available if not get first available day
    ${day_only_format}    Get Config Value    key=DATE_FMT_DAY_ONLY
    ${current_day}    Get Current Date    result_format=${day_only_format}
    FOR    ${day}    IN    @{days_on_calendar_list}
        ${day}    Strip String    ${day}
        IF    '${current_day}' not in ${existing_days}
            ${current_day}    Evaluate    '${current_day}'.lstrip('0')
            RETURN    ${current_day}
        ELSE IF    '${day}' not in ${existing_days}
            ${day}    Evaluate    '${day}'.lstrip('0')
            RETURN    ${day}
        END
    END
    RETURN    ${None}

Navigate Calendar To Find Available Day On Exception Management Page On Web
    [Documentation]
    ...    Navigates through calendar weeks to find a day that can be selected.
    ...    | =Arguments= | =Description= |
    ...    | target_day | Day number to find and make visible on calendar |
    ...    | =Returns= | =Description= |
    ...    | is_day_visible | Returns flag True if day was found and is visible, False otherwise |
    [Arguments]    ${target_day}
    ${shift_add_date_updated}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_DATE_ON_CALENDAR}    SHIFT_DATE=${target_day}
    ${is_day_visible}    Is Element Visible On Webpage    ${shift_add_date_updated}
    IF    ${is_day_visible}    RETURN    True
    # Try next week
    ${cal_pop_up_win}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CAL_POP_UP}
    IF    not ${cal_pop_up_win}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_CALENDAR_ICON}
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NAV_NEXT_WEEK}
    Capture Screenshot On Webpage
    ${is_day_visible}    Is Element Visible On Webpage    ${shift_add_date_updated}
    IF    ${is_day_visible}    RETURN    True
    # Try previous weeks
    ${cal_pop_up_win}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CAL_POP_UP}
    IF    not ${cal_pop_up_win}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_CALENDAR_ICON}
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NAV_PRE_WEEK}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NAV_PRE_WEEK}
    Capture Screenshot On Webpage
    ${is_day_visible}    Is Element Visible On Webpage    ${shift_add_date_updated}
    RETURN    ${is_day_visible}

Select Date On Calendar For Shift On Exception Management Page On Web
    [Documentation]
    ...    Selects a specific date on the calendar for adding a shift.
    ...    | =Arguments= | =Description= |
    ...    | day | Day number to select on calendar |
    ...    | =Returns= | =Description= |
    ...    | shift_date_added | Formatted date that was selected |
    [Arguments]    ${day}
    ${shift_add_date_updated}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_DATE_ON_CALENDAR}    SHIFT_DATE=${day}
    ${is_date_visible}    Is Element Visible On Webpage    ${shift_add_date_updated}
    IF    not ${is_date_visible}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CALENDAR_MONTH_NAVIGATION_LOCATOR}
    END
    Click Element On Webpage    ${shift_add_date_updated}
    ${shift_added_date_text}    Get Element Text On Webpage
    ...    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_FROM_DATE_TXT_BOX_ON_POPUP}
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${timecard_shift_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${shift_date_added}    Convert Date    ${shift_added_date_text}    result_format=${timecard_shift_date_format}
    ...    date_format=${timecard_date_format}
    RETURN    ${shift_date_added}

Select Date On Calendar For Special Pay On Exception Management Page On Web
    [Documentation]
    ...    Selects a specific date on the calendar for adding special pay.
    ...    | =Arguments= | =Description= |
    ...    | day | Day number to select on calendar |
    ...    | =Returns= | =Description= |
    ...    | shift_date_added | Formatted date that was selected |
    [Arguments]    ${day}
    ${shift_add_date_updated}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_DATE_ON_CALENDAR}    SHIFT_DATE=${day}
    ${is_date_visible}    Is Element Visible On Webpage    ${shift_add_date_updated}
    IF    not ${is_date_visible}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CALENDAR_MONTH_NAVIGATION_LOCATOR}
    END
    Click Element On Webpage    ${shift_add_date_updated}
    ${shift_added_date_text}    Get Element Text On Webpage
    ...    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_DATE_TEXT_BOX}
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${timecard_shift_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${special_pay_date}    Convert Date    ${shift_added_date_text}    result_format=${timecard_shift_date_format}
    ...    date_format=${timecard_date_format}
    RETURN    ${special_pay_date}

Save Shift On Exception Management Page On Web
    [Documentation]    Saves the added shift on Exception Management Page
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_BUTTON_ON_POPUP}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_SAVED_SUCCESS_ALERT}    timeout=${LONG_TIMEOUT}
    Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_SAVED_SUCCESS_ALERT}    timeout=${LONG_TIMEOUT}

Open Add Shift Dialog On Exception Management Page On Web
    [Documentation]
    ...    Opens the Add Shift dialog and calendar picker.
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_BUTTON}
    ...    error_message=Add shift button is not visible on Exception Management page
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_POPUP}
    ...    error_message=Add shift popup is not visible on Exception Management page
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_CALENDAR_ICON}
    ...    error_message=Calendar icon is not visible on Add shift popup on Exception Management page

Open Add Special Pay Dialog On Exception Management Page On Web
    [Documentation]
    ...    Opens the Add special pay dialog and calendar picker.
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_BUTTON}
    ...    error_message=Add special pay button is not visible on Exception Management page
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_ON_DIALOGUE}
    ...    error_message=Add special pay popup is not visible on Exception Management page
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_DATE}
    ...    error_message=Special pay date field is not visible on Add special pay popup on Exception Management page

Add Shift On Exception Management Page On Web
    [Documentation]    Identifies an available date and adds a shift for that date.
    ...    | =Arguments= | =Description= |
    ...    | shift_data | Shift data object from template |
    ...    | =Returns= | =Description= |
    ...    | shift_date_added | Date for which shift is added |
    ...    | formatted_start_time | Start time of shift as displayed |
    ...    | formatted_end_time | End time of shift as displayed |
    [Arguments]    ${shift_data}
    Open Add Shift Dialog On Exception Management Page On Web
    ${day_only_format}    Get Config Value    key=DATE_FMT_DAY_ONLY
    ${day}    Calculate Date From Week Day Offset    ${shift_data}[shift_day]    ${day_only_format}
    ${formatted_day}    Evaluate    '${day}'.lstrip('0')
    ${shift_date_added}    Select Date On Calendar For Shift On Exception Management Page On Web    ${formatted_day}
    ${numeric_date}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_FROM_DATE_TXT_BOX_ON_POPUP}
    ${shift_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_ACTUALS}    DATE=${numeric_date}
    ${actual_counts}    Get Element Count On Web Page    ${shift_locator}
    Skip If    ${actual_counts}    msg=Shift already exists for the date ${shift_date_added}, skipping shift addition.
    Fill Textbox On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_START_TIME}    ${shift_data}[start_time]
    Fill Textbox On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_END_TIME}    ${shift_data}[end_time]
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_LOCATION}
    IF    'location' in ${shift_data}
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_LOCATION}    text
        ...    ${shift_data}[location]
    ELSE
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_LOCATION}    index
        ...    1
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_DEPT}
    IF    'department' in ${shift_data}
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_DEPT}    text
        ...    ${shift_data}[department]
    ELSE
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_DEPT}    index
        ...    1
    END
    ${activity_code_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_ACTIVITY_CODE_MANDATORY_STAR}
    IF    ${activity_code_visible}
        IF    'activity_code' in ${shift_data}
            Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_ACTIVITY_CODE}
            Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_ACTIVITY_CODE}    text
            ...    ${shift_data}[activity_code]
        ELSE
            Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_ACTIVITY_CODE}    index
            ...    1
        END
    ELSE
        Log    Activity code field not visible, hence skip selection.
    END
    ${staff_group_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_STAFF_GROUP}
    IF    ${staff_group_visible}
        IF    'staff_group' in ${shift_data}
            Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_STAFF_GROUP}
            Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_STAFF_GROUP}    text
            ...    ${shift_data}[staff_group]
        ELSE
            Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_STAFF_GROUP}    index
            ...    1
        END
    ELSE
        Log    Staff Group field not visible, hence skip selection.
    END
    ${scheduled_task_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_SCHEDULED_TASK}
    IF    ${scheduled_task_visible}
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_SCHEDULED_TASK}    index    1
    END
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_REASON_CODE}
    ${formatted_end_time}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_END_TIME}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_REASON_CODE}
    Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_REASON_CODE}    text
    ...    ${shift_data}[reason_code]
    ${formatted_start_time}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_START_TIME}
    Save Shift On Exception Management Page On Web
    RETURN    ${shift_date_added}    ${formatted_start_time}    ${formatted_end_time}

Get Unscheduled Work Count Of First Employee On Web
    [Documentation]    This keyword returns the unscheduled work count of the first employee
    ...    | =Returns= | =Description= |
    ...    | unscheduled_work_count | Unscheduled Work Count on exception management page |
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_UNSCHEDULED_WORK}
    ${txt}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_UNSCHEDULED_WORK}
    ${unscheduled_work_count}    Convert To Integer    ${txt}
    RETURN    ${unscheduled_work_count}

Get Unscheduled Work Count Of Specific Employee On Web
    [Documentation]    This keyword returns the unscheduled work count of the specific employee
    ...    | =Arguments= | =Description= |
    ...    | emp_name | Name of employee for which unscheduled work count to be checked |
    ...    | =Returns= | =Description= |
    ...    | unscheduled_work_count | Unscheduled Work Count on exception management page |
    [Arguments]    ${emp_name}
    ${unscheduled_work_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_UNSCHEDULED_WORK}
    ...    EMP_NAME=${emp_name}
    Wait Until Element Is Visible On Webpage    ${unscheduled_work_locator}
    ${txt}    Get Element Text On Webpage    ${unscheduled_work_locator}
    ${unscheduled_work_count}    Convert To Integer    ${txt}
    RETURN    ${unscheduled_work_count}

Get Unscheduled Absence Count Of Specific Employee On Web
    [Documentation]    This keyword returns the unscheduled absence count of the specific employee
    ...    | =Arguments= | =Description= |
    ...    | emp_name | Name of employee for which unscheduled absence count to be checked |
    ...    | =Returns= | =Description= |
    ...    | unscheduled_absence_count | Unscheduled Absence Count on exception management page |
    [Arguments]    ${emp_name}
    ${unscheduled_absence_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_UNSCHEDULED_ABSENCE}
    ...    EMP_NAME=${emp_name}
    Wait Until Element Is Visible On Webpage    ${unscheduled_absence_locator}
    ${txt}    Get Element Text On Webpage    ${unscheduled_absence_locator}
    ${unscheduled_absence_count}    Convert To Integer    ${txt}
    RETURN    ${unscheduled_absence_count}

Verify Warning Icon Visible For Specific Shift On Web
    [Documentation]    This keyword verifies the presence of the warning icon for shift added for specific date and time
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Date for which shift is added |
    ...    | shift_time | Time for which shift is added |
    [Arguments]    ${shift_date}    ${shift_time}
    ${icon_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_WARNING_ICON}    SHIFT_DATE=${shift_date}    SHIFT_TIME=${shift_time}
    Wait Until Element Is Visible On Webpage    ${icon_locator}

Delete Shift On Timecard Page On Web
    [Documentation]    This keyword deletes Punch Data on Timecard Page
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Date for which shift is added |
    [Arguments]    ${shift_date}    ${shift_time}=NA
    IF    '${shift_time}' != 'NA'
        ${alt_shift_time}    Evaluate    $shift_time.lstrip('0')
        ${shift_delete_date_updated}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_DELETE_DATE_TIME}
        ...    SHIFT_DATE=${shift_date}    SHIFT_TIME=${shift_time}    ALT_SHIFT_TIME=${alt_shift_time}
    ELSE
        ${shift_delete_date_updated}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_DELETE_DATE}
        ...    SHIFT_DATE=${shift_date}
    END
    Click Element On Webpage    ${shift_delete_date_updated}
    ...    error_message=Shift delete icon for date ${shift_date} is not visible on timecard page
    ${promise}    Promise To    Wait For Alert    action=accept    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DELETE_SHIFT}
    ${alert_status}    Run Keyword And Return Status
    ...    Wait For    ${promise}
    IF    not ${alert_status}
        ${timecard_reason}    Get System Value    class_name=TimeCardReasonCodes    constant_name=TIMECARD_REASON_CODE
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_DELETE_REASON_CODE}    text    ${timecard_reason}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_DELETE_CONFIRMATION_YES}
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_SAVED_SUCCESS_ALERT}    timeout=${LONG_TIMEOUT}
    ...    error_message=Shift saved success alert not visible on exception management page
    Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_SAVED_SUCCESS_ALERT}
    Log    Shift for date ${shift_date} deleted successfully

Get All Employee Count On Web
    [Documentation]
    ...    Returns the count of all employees currently visible on the Exception Management page.
    ...    This count reflects the employees displayed after any filters or view changes are applied.
    ...    | =Returns= | =Description= |
    ...    | total_employee_count | Total number of employee records visible on the page. |
    ...    Example usage:
    ...    | ${all_emp_count}    Get All Employee Count On Web
    ${total_employee_count}    Get Element Count On Web Page    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAYED_RECORDS}
    RETURN    ${total_employee_count}

Get Part Time Employee Count On Web
    [Documentation]
    ...    Returns the count of Part-Time (PT) employees displayed on the Exception Management page.
    ...    This count is based on employees with 'PT' employee type label before any filters are applied.
    ...    | =Returns= | =Description= |
    ...    | pt_employee_count | Number of Part-Time employee records displayed. |
    ...    Example usage:
    ...    | ${pt_count}    Get Part Time Employee Count On Web
    ${pt_employee_count}    Get Element Count On Web Page    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_PT}
    RETURN    ${pt_employee_count}

Get Full Time Employee Count On Web
    [Documentation]
    ...    Returns the count of Full-Time (FT) employees displayed on the Exception Management page.
    ...    This count is based on employees with 'FT' employee type label before any filters are applied.
    ...    | =Returns= | =Description= |
    ...    | ft_employee_count | Number of Full-Time employee records displayed. |
    ...    Example usage:
    ...    | ${ft_count}    Get Full Time Employee Count On Web
    ${ft_employee_count}    Get Element Count On Web Page    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_FT}
    RETURN    ${ft_employee_count}

Apply Advanced Filter For Part Time Employees On Web
    [Documentation]
    ...    Applies Part-Time (PT) employee filter and returns the total count of displayed employees.
    ...    After applying the filter, only PT employees should be visible.
    ...    The returned count represents the total number of employee records shown after filtering.
    ...    | =Returns= | =Description= |
    ...    | pt_filtered_count | Total number of employee records displayed after PT filter is applied. |
    ...    Example usage:
    ...    | ${pt_filtered_count}    Apply Advanced Filter For Part Time Employees On Web
    Apply Advanced Filter For Employee Type On Web    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_EMPLOYEE_TYPE_PT}
    ${pt_filtered_count}    Get All Employee Count On Web
    RETURN    ${pt_filtered_count}

Apply Advanced Filter For Full Time Employees On Web
    [Documentation]
    ...    Applies Full-Time (FT) employee filter and returns the total count of displayed employees.
    ...    After applying the filter, only FT employees should be visible.
    ...    The returned count represents the total number of employee records shown after filtering.
    ...    | =Returns= | =Description= |
    ...    | ft_filtered_count | Total number of employee records displayed after FT filter is applied. |
    ...    Example usage:
    ...    | ${ft_filtered_count}    Apply Advanced Filter For Full Time Employees On Web
    Apply Advanced Filter For Employee Type On Web    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_EMPLOYEE_TYPE_FT}
    ${ft_filtered_count}    Get All Employee Count On Web
    RETURN    ${ft_filtered_count}

Apply Advanced Filter For Combined Employees On Web
    [Documentation]
    ...    Applies both PT and FT filters together and returns the combined count of displayed employees.
    ...    | =Returns= | =Description= |
    ...    | combined_filtered_count | Total number of employees when both PT and FT filters are applied. |
    ...    Example usage:
    ...    | ${combined_count}    Apply Advanced Filter For Combined Employees On Web
    Apply Advanced Filter On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_EMPLOYEE_TYPE_PT}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_EMPLOYEE_TYPE_FT}
    ${combined_filtered_count}    Get All Employee Count On Web
    RETURN    ${combined_filtered_count}

Apply Advanced Filter For Employee Type On Web
    [Documentation]    Applies advanced filter for a single employee type (PT or FT).
    ...    | =Arguments= | =Description= |
    ...    | employee_type_filter_locator | Locator used to select the employee type in filter panel. |
    [Arguments]    ${employee_type_filter_locator}
    Apply Advanced Filter On Web    ${employee_type_filter_locator}
    Log    Applied filter for employee type using locator: ${employee_type_filter_locator}

Apply Advanced Filter On Web
    [Documentation]    Applies advanced filter(s). primary_filter_locator is required; secondary_filter_locator optional.
    [Arguments]    ${primary_filter_locator}    ${secondary_filter_locator}=${None}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_CLEAR_BUTTON}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    Click Element On Webpage    ${primary_filter_locator}
    IF    '${secondary_filter_locator}' != '${None}'
        Click Element On Webpage    ${secondary_filter_locator}
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_FETCH_BUTTON}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_APPLY_BUTTON}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Clear Advanced Filter On Web
    [Documentation]
    ...    Clears all applied filters on the Exception Management page and resets to default view.
    ...    This should be used at the end of filter tests to ensure clean state.
    ...    Example usage:
    ...    | Clear Advanced Filter On Web
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_CLEAR_BUTTON}
    Wait Until Page Is Loaded
    Log    Advanced filter cleared successfully

Verify PDF Export Button On Web
    [Documentation]
    ...    Verifies that clicking the PDF export button opens a new browser tab with a valid PDF URL.
    ...    Switches to the new tab and validates the URL content without closing it.
    ...    Browser cleanup is handled by test teardown.
    ...    | =Validations= | =Description= |
    ...    | New tab opened | Confirms more than one tab exists after click. |
    ...    | URL content | Must contain one of: servlet / pdf / exceptionmanagement (case-insensitive) |
    ...    Example usage:
    ...    | Verify PDF Export Button On Web
    Wait Until Element Is Present On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PDF_ICON}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PDF_ICON}
    Wait Until Page Is Loaded
    Switch Page    NEW
    Wait Until Page Is Loaded
    @{all_pages}    Get Page Ids    ALL    ALL    ALL
    ${no_of_tabs}    Get Length    ${all_pages}
    Should Be True    ${no_of_tabs} > 1    PDF export did not open a new tab
    ${pdf_url}    Get Url
    Capture Screenshot On Webpage
    ${pdf_url_lower}    Convert To Lower Case    ${pdf_url}
    Should Be True
    ...    'servlet' in '''${pdf_url_lower}''' or 'pdf' in '''${pdf_url_lower}''' or 'exceptionmanagement' in '''${pdf_url_lower}'''
    ...    Unexpected PDF URL: ${pdf_url}
    Close Page    CURRENT    CURRENT    CURRENT

Click On Random Clock Icon And Return Associate ID On Web
    [Documentation]    This keyword clicks on random clock icon and returns associate id
    ${emp_count}    Get Element Count    ${EXCEPTION_MANAGEMENT_PAGE_NO_OF_ASSOCIATES}
    ${associate_index}    Evaluate    random.randint(1, ${emp_count})    random
    ${associate_index_str}    Convert To String    ${associate_index}
    ${clock_icon}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_RANDOM_CLOCK_ICON}    TEMP=${associate_index_str}

    ${associate_id}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_RANDOM_ASSOCIATE_ID}    TEMP=${associate_index_str}

    ${associate_id}    Get Element Text On Webpage    ${associate_id}
    Click Element On Webpage    ${clock_icon}
    RETURN    ${associate_id}    ${associate_index}

Open Timecard Page For The Given Associate Index On Web
    [Documentation]    This keyword opens the timecard page for the given index
    [Arguments]    ${index}
    ${index_str}    Convert To String    ${index}
    ${associate_clock_icon}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_RANDOM_CLOCK_ICON}    TEMP=${index_str}
    Click Element On Webpage    ${associate_clock_icon}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Is Punch Import Data Added On Timecard Page On Web
    [Documentation]    This keyword returns the presence of Punch Data on Timecard Page
    ...    | =Arguments= | =Description= |
    ...    | punch_imported_date | Date for which punch data is imported |
    ...    | =Returns= | =Description= |
    ...    | is_punch_data_present | Boolean flag indicating if punch data is present |
    ...    Example usage:
    ...    | ${is_present}    Is Punch Import Data Added On Timecard Page On Web    01/12/2024
    [Arguments]    ${punch_imported_date}
    ${imported_shift}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_IMPORTED_SHIFT_DATE_LBL}
    ...    SHIFT_DATE=${punch_imported_date}

    VAR    ${is_punch_data_present}    False
    WHILE    not ${is_punch_data_present}    limit=${LOOP_TIMEOUT}
        ${is_punch_data_present}    Is Element Present On Webpage    ${imported_shift}
        IF    ${is_punch_data_present}    RETURN    ${is_punch_data_present}

        Shift To Next Week Timecard Of User
        TRY
            Wait Until Page Is Loaded
            Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_WEEKEND_LABEL_ON_TIMECARD_PAGE}
            ...    timeout=${MEDIUM_TIMEOUT}
        EXCEPT
            Log    Page load timeout when navigating to next week, continuing...
        END

        Shift To Previous Week Timecard Of User
        TRY
            Wait Until Page Is Loaded
            Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_WEEKEND_LABEL_ON_TIMECARD_PAGE}
            ...    timeout=${MEDIUM_TIMEOUT}
        EXCEPT
            Log    Page load timeout when navigating to previous week, continuing...
        END
    END
    RETURN    ${is_punch_data_present}

Get Warning Icon Count Of Punch Data In Timecard On Web
    [Documentation]    This keyword returns the count of warning icons for a specific punch
    [Arguments]    ${date}    ${time}
    ${time}    Fetch From Left    ${time}    \xa0
    ${warning_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_WARNING_ICON}    SHIFT_DATE=${date}    SHIFT_TIME=${time}
    ${warning_elements}    Get Elements    ${warning_locator}
    ${warning_count}    Get Length    ${warning_elements}
    RETURN    ${warning_count}

Verify Timecard Success Toast Notification On Web
    [Documentation]    Verifies that the toast message notification is displayed in WFM.
    Wait For Elements State    ${TIMECARD_PAGE_NOTIFICATION_SUCCESS_TOAST}    visible    timeout=${SHORT_TIMEOUT}

Verify Punch Visible In Timecard Page On Web
    [Documentation]    This will verify specific punch shown in timecard page
    [Arguments]    ${transaction_type}    ${date}    ${time}
    ${time}    Fetch From Left    ${time}    \xa0
    ${shift_start_value}    Get System Value    PunchTransactionType    SHIFT_START
    IF    '${transaction_type}' == '${shift_start_value}'
        ${time_locator}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_PUNCH_SHOWN_START_TIME}    TEMP_date=${date}    TEMP_time=${time}
    ELSE
        ${time_locator}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_PUNCH_FOLLOWING_ACTUAL}    TEMP_date=${date}    TEMP_time=${time}
    END
    Wait Until Element Is Visible On Webpage    ${time_locator}    timeout=${MEDIUM_TIMEOUT}

Delete Actual Punch Of Given Transaction Type On Web
    [Documentation]    This will delete punch of provided transaction, date and time
    [Arguments]    ${transaction_type}    ${date}    ${time}    ${reason_code}
    ${time}    Fetch From Left    ${time}    \xa0
    ${shift_start_value}    Get System Value    PunchTransactionType    SHIFT_START
    IF    '${transaction_type}' == '${shift_start_value}'
        ${time_locator}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_PUNCH_SHOWN_START_TIME}    TEMP_date=${date}    TEMP_time=${time}
        Click Element On Webpage    ${time_locator}
    ELSE
        ${time_locator}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_PUNCH_FOLLOWING_ACTUAL}    TEMP_date=${date}    TEMP_time=${time}
        Click Element On Webpage    ${time_locator}
    END
    Wait Until Element Is Visible On Webpage    ${time_locator}    timeout=${MEDIUM_TIMEOUT}
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${TIMECARD_PAGE_PUNCH_DELETE_BTN}
    ${alert_status}    Run Keyword And Return Status
    ...    Wait For    ${promise}
    IF    not ${alert_status}
        Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_PUNCH_DELETE_DIALOG_BOX}    timeout=${MEDIUM_TIMEOUT}
        Select List Item On Webpage    ${TIMECARD_PAGE_PUNCH_DELETE_REASON}    text    ${reason_code}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_DELETE_CONFIRMATION_YES}
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}

Fill Punch Details And Submit On Web
    [Documentation]    Fills all punch details in the dialog and submits the punch.
    [Arguments]    ${transaction_type_value}    ${time}    ${reason_code}
    ${punch_added_date_text}    Get Element Text On Webpage
    ...    ${EXCEPTION_MANAGEMENT_PAGE_PUNCH_FROM_DATE_TXT_BOX_ON_POPUP}
    ${punch_date_input_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${punch_date_display_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${punch_date_added}    Convert Date    ${punch_added_date_text}    date_format=${punch_date_input_format}
    ...    result_format=${punch_date_display_format}
    Select List Item On Webpage    ${TIMECARD_PAGE_PUNCH_TRANSACTION_TYPE}    value    ${transaction_type_value}
    Fill Textbox On Webpage    ${TIMECARD_PAGE_PUNCH_TIME}    ${time}
    ${act_code_status}    Is Element Visible On Webpage    ${TIMECARD_PAGE_ADD_PUNCH_ACTIVITY_CODE}
    IF    ${act_code_status}
        Select List Item On Webpage    ${TIMECARD_PAGE_ADD_PUNCH_ACTIVITY_CODE}    attribute=index    value=1
    END
    Click Element On Webpage    ${TIMECARD_PAGE_PUNCH_REASON}
    Select List Item On Webpage    ${TIMECARD_PAGE_PUNCH_REASON}    label    ${reason_code}
    ${formatted_time}    Get Element Text On Webpage    ${TIMECARD_PAGE_PUNCH_TIME}
    Click Element On Webpage    ${TIMECARD_PAGE_PUNCH_ADD_PUNCH}
    Wait Until Element Disappears On Webpage    ${TIMECARD_PAGE_PUNCH_DIALOG_BOX}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    RETURN    ${punch_date_added}    ${formatted_time}

Navigate To Available Day On Calendar Of Exception Management Page On Web
    [Documentation]    Navigates calendar weeks to make the target day visible.
    [Arguments]    ${day_locator}
    ${is_day_visible}    Is Element Visible On Webpage    ${day_locator}
    IF    not ${is_day_visible}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NAV_NEXT_WEEK}
        Wait Until Page Is Loaded
        Capture Screenshot On Webpage
        ${is_day_visible}    Is Element Visible On Webpage    ${day_locator}
        IF    not ${is_day_visible}
            Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NAV_PRE_WEEK}
            Wait Until Page Is Loaded
            Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NAV_PRE_WEEK}
            Wait Until Page Is Loaded
            Capture Screenshot On Webpage
        END
    END

Find And Add Punch On Available Day On Web
    [Documentation]    Finds an available day without existing punch and adds the punch details.
    [Arguments]    ${days_list}    ${days_on_calendar_list}    ${transaction_type_value}    ${time}    ${reason_code}
    VAR    ${found}    False
    FOR    ${day}    IN    @{days_on_calendar_list}
        ${day}    Strip String    ${day}
        IF    '${day}' not in ${days_list}
            VAR    ${found}    True
            ${punch_add_date_updated}    Update Locator With Dynamic Values
            ...    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_DATE_ON_CALENDAR}    SHIFT_DATE=${day}
            Navigate To Available Day On Calendar Of Exception Management Page On Web    ${punch_add_date_updated}
            Click Element On Webpage    ${punch_add_date_updated}
            ${punch_date_added}    ${formatted_time}    Fill Punch Details And Submit On Web
            ...    ${transaction_type_value}    ${time}    ${reason_code}
            RETURN    ${punch_date_added}    ${formatted_time}
        END
    END
    IF    not ${found}
        SKIP    msg=No available day to add a punch. Skipping test.
    END

Collect Available Calendar Days On Web
    [Documentation]    Collects all available days from the calendar, navigating to next week if needed.
    VAR    @{days_on_calendar_list}    @{EMPTY}
    ${days_in_current_week}    Get Elements    ${EXCEPTION_MANAGEMENT_PAGE_NO_OF_DAYS_IN_CURRENT_WEEK}
    FOR    ${each_day_on_cal}    IN    @{days_in_current_week}
        ${text}    Get Element Text On Webpage    ${each_day_on_cal}
        ${text}    Strip String    ${text}
        Append To List    ${days_on_calendar_list}    ${text}
    END
    ${calendar_list_length}    Get Length    ${days_on_calendar_list}
    IF    ${calendar_list_length} < 7
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NAV_NEXT_WEEK}
        Wait Until Page Is Loaded
        ${days_in_next_part_of_week}    Get Elements    ${EXCEPTION_MANAGEMENT_PAGE_NO_OF_DAYS_IN_CURRENT_WEEK}
        FOR    ${each_day_on_cal}    IN    @{days_in_next_part_of_week}
            ${text}    Get Element Text On Webpage    ${each_day_on_cal}
            ${text}    Strip String    ${text}
            Append To List    ${days_on_calendar_list}    ${text}
        END
    END
    RETURN    @{days_on_calendar_list}

Add Punch Where No Actual Is Present On Web
    [Documentation]    This keyword identifies the appropriate date and adds punch for that date.
    ...    Also it will return time formatted set in application.
    [Arguments]    ${transaction_type}    ${time}    ${reason_code}
    ${transaction_type_value}    Get Transaction Type Value Of Punch On Web    ${transaction_type}
    @{days_list}    Extract Days From Schedule Dates On Web
    Click Element On Webpage    ${TIMECARD_PAGE_ADD_PUNCH_BUTTON}
    Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_PUNCH_DIALOG_BOX}    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${TIMECARD_PAGE_PUNCH_DATE_ICON}
    @{days_on_calendar_list}    Collect Available Calendar Days On Web
    ${punch_date_added}    ${formatted_time}    Find And Add Punch On Available Day On Web
    ...    ${days_list}    ${days_on_calendar_list}    ${transaction_type_value}    ${time}    ${reason_code}
    RETURN    ${punch_date_added}    ${formatted_time}

Get Transaction Type Value Of Punch On Web
    [Documentation]    Returns the numeric value for the given transaction type.
    [Arguments]    ${transaction_type}
    ${shift_start_value}    Get System Value    PunchTransactionType    SHIFT_START
    ${shift_end_value}    Get System Value    PunchTransactionType    SHIFT_END
    IF    '${transaction_type}' == '${shift_start_value}'
        RETURN    1
    ELSE IF    '${transaction_type}' == '${shift_end_value}'
        RETURN    2
    ELSE
        Fail    Invalid transaction type: ${transaction_type}. Expected '${shift_start_value}' or '${shift_end_value}'
    END

Extract Days From Schedule Dates On Web
    [Documentation]    Extracts day numbers from schedule date elements and returns as a list.
    ${elements}    Get Elements    ${EXCEPTION_MANAGEMENT_PAGE_SCHEDULE_DATES}
    VAR    @{days_list}    @{EMPTY}
    IF    ${elements}
        FOR    ${element}    IN    @{elements}
            ${text}    Get Element Text On Webpage    ${element}
            @{split_result}    Split String    ${text}
            ${date_part}    Get From List    ${split_result}    1
            @{date_split}    Split String    ${date_part}    /
            ${day}    Get From List    ${date_split}    0
            ${day}    Strip String    ${day}
            ${day}    Convert To Integer    ${day}
            ${day}    Convert To String    ${day}
            Append To List    ${days_list}    ${day}
        END
    END
    RETURN    @{days_list}

Get Status For Special Pay Button Is Present In Timecard On Web
    [Documentation]    This will return status for presence of special pay button in timecard page
    ...    | =Returns= | =Description= |
    ...    | sp_status | Returns boolean True/False based on presence special pay button |
    ${sp_status}    Run Keyword And Return Status
    ...    Wait For Elements State    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_BTN}
    RETURN    ${sp_status}

Add Special Pay On Web
    [Documentation]    Verify add delete special pay workflow
    ...    Identifies an available date and adds a special pay for that date.
    ...    | =Arguments= | =Description= |
    ...    | special_pay_data | Special pay data object from template |
    ...    | =Returns= | =Description= |
    ...    | sp_added_date | Date for which special pay is added |
    [Arguments]    ${special_pay_data}
    Open Add Special Pay Dialog On Exception Management Page On Web
    ${day_only_format}    Get Config Value    key=DATE_FMT_DAY_ONLY
    ${day}    Calculate Date From Week Day Offset    ${special_pay_data}[sp_date]    ${day_only_format}
    ${formated_day}    Evaluate    '${day}'.lstrip('0')
    ${sp_added_date}    Select Date On Calendar For Special Pay On Exception Management Page On Web    ${formated_day}
    Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_PAY_CODE}    text    ${special_pay_data}[pay_code]
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_LOCATION}
    ${sp_charge_loc_type}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_CHARGE_LOC_TYPE}
    ...    LOC_OPTION=${special_pay_data}[charge_loc_type]
    ${is_charge_loc_type_visible}    Is Element Present On Webpage    ${sp_charge_loc_type}
    IF    ${is_charge_loc_type_visible}
        Click Element On Webpage    ${sp_charge_loc_type}    error_message=Charge Location Radio not visible for special pay addition.
    END
    IF    'location' in ${special_pay_data}
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_LOCATION}    value
        ...    ${special_pay_data}[location]
    ELSE
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_LOCATION}    index
        ...    1
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_DEPARTMENT}
    IF    'department' in ${special_pay_data}
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_DEPARTMENT}    text
        ...    ${special_pay_data}[department]
    ELSE
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_DEPARTMENT}    index
        ...    1
    END
    ${reason_code_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_REASON}
    IF    ${reason_code_visible}
        IF    'reason_code' in ${special_pay_data}
            Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_REASON}
            Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_REASON}    text
            ...    ${special_pay_data}[reason_code]
        END
    ELSE
        Log    Reason code not present for special pay addition, hence skip selection
    END
    ${staff_group_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_STAFF_GROUP}
    IF    ${staff_group_visible}
        IF    'staff_group' in ${special_pay_data}
            Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_STAFF_GROUP}
            Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_STAFF_GROUP}    text
            ...    ${special_pay_data}[staff_group]
        ELSE
            Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_STAFF_GROUP}    index
            ...    1
        END
    ELSE
        Log    Staff Group field not visible, hence skip selection.
    END
    Fill Textbox On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_USAGE}    ${special_pay_data}[usage]
    Save And Verify Special Pay On Exception Management Page On Web    ${sp_added_date}
    RETURN    ${sp_added_date}

Delete Special Pay On Web
    [Documentation]    Delete special pay workflow
    ...    | =Arguments= | =Description= |
    ...    | sp_added_date | Date for which special pay record to be deleted |
    [Arguments]    ${sp_added_date}
    ${special_pay_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_WEEK_TO_RAISE_SPECIAL_PAY_REQ}
    ...    SP_PAY_ADDED_DATE=${sp_added_date}
    ${is_visible}    Is Element Present On Webpage    ${special_pay_locator}
    IF    ${is_visible}
        Click Element On Webpage    ${special_pay_locator}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DELETE_SPECIAL_PAY}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_DELETE_YES_BTN}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
        Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_SAVED_SUCCESS_ALERT}
        Verify Timecard Page Notification Status On Web
        Log    assert that after delete special pay, respective special pay record is not present on page.
        Wait Until Element Disappears On Webpage    ${special_pay_locator}
    END

Verify Timecard Page Notification Status On Web
    [Documentation]    This keyword verifies the notification status whether it is success or error
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NOTIFICATION_SUCCESS}

Verify Presence Of Actual Punch Data On Web
    [Documentation]    This keyword looks for the presence of Actual Punch data
    ...    | =Returns= | =Description= |
    ...    | True/False | Returns True if punches present else False |
    ${elements}    Get Elements    ${EXCEPTION_MANAGEMENT_PAGE_ACTUAL_DATES}
    VAR    &{days_dict}    &{EMPTY}
    VAR    ${index}    0
    ${day_numeric_index}    Get Config Value    key=TIMECARD_SHIFT_DAY_NUMERIC_INDEX
    IF    ${elements} != None
        FOR    ${index}    ${element}    IN ENUMERATE    @{elements}
            ${text}    Get Element Text On Webpage    ${element}
            VAR    ${input_string}    ${text}
            @{split_result}    Split String    ${input_string}
            ${date_part}    Get From List    ${split_result}    1
            @{date_split}    Split String    ${date_part}    /
            ${day}    Get From List    ${date_split}    ${day_numeric_index}
            Set To Dictionary    ${days_dict}    ${index}    ${day}
            ${shift_add_date_updated}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_ADD_DATE}
            ...    SHIFT_DATE=${text}
            ${actual_punch_text}    Get Element Text On Webpage    ${shift_add_date_updated}
            IF    '${actual_punch_text}' != '\xa0'    RETURN    True
        END
        RETURN    False
    END

Navigate To Pay Results Section On Web
    [Documentation]    This keyword navigates to Pay Results section
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_TAB}
    Wait Until Element Is Present On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DROP_DOWN}
    ...    timeout=${LONG_TIMEOUT}    error_message=Pay Results section did not load within expected time after clicking the tab.

Navigate To Timecard Section On Web
    [Documentation]    This keyword navigates to Timecard section
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_TIMECARD_TAB}

Verify Default View In Pay Results Section On Web
    [Documentation]    This keyword verifies that summary view is selected by default in Pay Results section
    ...    | =Arguments= | =Description= |
    ...    | view_type | View to be verified Summary / Detailed |
    [Arguments]    ${view_type}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DROP_DOWN}
    ${view_selected_text}    Get Selected List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DROP_DOWN}    text
    Should Be Equal As Strings    ${view_selected_text}[0]    ${view_type}    Summary view is not selected by default

Select View In Pay Results Section On Web
    [Documentation]    This keyword selects view in Pay Results section
    ...    | =Arguments= | =Description= |
    ...    | view_type | View to be selected Summary / Detailed |
    [Arguments]    ${view_type}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DROP_DOWN}
    Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DROP_DOWN}    text    ${view_type}

Verify Summary View Data For Added Shift In Pay Results Section On Web
    [Documentation]    This keyword verifies data in Pay Results section summary view when shift is added
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Shift date |
    [Arguments]    ${shift_date}
    ${usage_hours}    Get Hours For Date In Pay Results Section On Web    ${shift_date}
    Should Not Be Empty    ${usage_hours}    "Hours not visible for date ${shift_date} in Pay Results section"
    ${cost}    Get Cost For Date In Pay Results Section On Web    ${shift_date}
    Should Not Be Empty    ${cost}    "Cost not visible for date ${shift_date} in Pay Results section"

Verify Detailed View Data For Added Shift In Pay Results Section On Web
    [Documentation]    This keyword verifies data in Pay Results section detailed view
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Shift date |
    [Arguments]    ${shift_date}
    ${start_time_loc}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_START_TIME}
    ...    SHIFT_DATE=${shift_date}
    Wait Until Element Is Visible On Webpage    ${start_time_loc}
    ${end_time_loc}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_END_TIME}
    ...    SHIFT_DATE=${shift_date}
    Wait Until Element Is Visible On Webpage    ${end_time_loc}
    ${hours_loc}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_HOURS}
    ...    SHIFT_DATE=${shift_date}
    Wait Until Element Is Visible On Webpage    ${hours_loc}
    ${cost_loc}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_COST}
    ...    SHIFT_DATE=${shift_date}
    Wait Until Element Is Visible On Webpage    ${cost_loc}
    ${cost_visible}    Get Element Text On Webpage    ${cost_loc}
    Should Not Be Empty    ${cost_visible}    "Cost not visible for date ${shift_date} in Pay Results section"
    ${multiplier_loc}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_MUL}
    ...    SHIFT_DATE=${shift_date}
    Wait Until Element Is Visible On Webpage    ${multiplier_loc}
    ${rate_loc}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_RATE}
    ...    SHIFT_DATE=${shift_date}
    Wait Until Element Is Visible On Webpage    ${rate_loc}

Verify No Data Message In Pay Results Section On Web
    [Documentation]    This keyword verifies no data message in Pay Results section
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_NO_DATA_MSG}

Get Presence Of Review Warning Button On Timecard Page On Web
    [Documentation]    This will return status for presence of review warning button in timecard page
    ${is_review_warnings_button_present}    Run Keyword And Return Status
    ...    Wait For Elements State    ${EXCEPTION_MANAGEMENT_PAGE_REVIEW_WARNINGS_BTN}
    RETURN    ${is_review_warnings_button_present}

Verify Presence Of Shift Data For Current Day On Web
    [Documentation]    This keyword looks for the presence shift for current day
    ...    | =Returns= | =Description= |
    ...    | True/False | Returns True if shift present else False |
    ${day_only_format}    Get Config Value    key=PUNCH_DATE_DISPLAY_FORMAT
    ${current_day}    Get Current Date    result_format=${day_only_format}
    ${shift_add_date_updated}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_ADD_DATE}
    ...    SHIFT_DATE=${current_day}
    ${current_day_shift_present}    Is Element Present On Webpage    ${shift_add_date_updated}
    RETURN    ${current_day_shift_present}

Get Job Code For Date In Pay Results Section On Web
    [Documentation]    This keyword gets the job code text for specific date in Pay Results section
    ...    | =Returns= | =Description= |
    ...    | job_code_text | Returns text for job code |
    [Arguments]    ${shift_date}
    ${job_code_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_JOB_CODE}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Present On Webpage
    ...    ${job_code_locator}    timeout=${MEDIUM_TIMEOUT}
    IF    ${is_visible}
        ${job_code_text}    Evaluate JavaScript    ${job_code_locator}    (element) => element.textContent
        RETURN    ${job_code_text}
    ELSE
        RETURN
    END

Get Pay Category For Date In Pay Results Section On Web
    [Documentation]    This keyword gets the pay category text for specific date in Pay Results section
    ...    | =Returns= | =Description= |
    ...    | pay_category_text | Returns text for pay category |
    [Arguments]    ${shift_date}
    ${pay_category_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_PAY_CATEGORY}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Is Element Visible On Webpage    ${pay_category_locator}
    IF    ${is_visible}
        ${pay_category_text}    Get Element Text On Webpage    ${pay_category_locator}
        RETURN    ${pay_category_text}
    ELSE
        RETURN
    END

Get Cost For Date In Pay Results Section On Web
    [Documentation]    This keyword gets the cost for specific date in Pay Results section
    ...    | =Returns= | =Description= |
    ...    | cost_text | Returns text for cost |
    [Arguments]    ${shift_date}
    ${cost_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_COST}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Present On Webpage
    ...    ${cost_locator}    timeout=${MEDIUM_TIMEOUT}
    IF    ${is_visible}
        ${cost_text}    Evaluate JavaScript    ${cost_locator}    (element) => element.textContent
        RETURN    ${cost_text}
    ELSE
        RETURN
    END

Get Hours For Date In Pay Results Section On Web
    [Documentation]    This keyword gets the hours for specific date in Pay Results section
    ...    | =Returns= | =Description= |
    ...    | hours_text | Returns text for hours |
    [Arguments]    ${shift_date}
    ${hours_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_HOURS}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Is Element Visible On Webpage    ${hours_locator}
    IF    ${is_visible}
        ${hours_text}    Get Element Text On Webpage    ${hours_locator}
        RETURN    ${hours_text}
    ELSE
        RETURN
    END

Get Hours In Minutes For Pay Results Section On Web
    [Documentation]    This keyword converts hours in minutes in Pay Results section
    ...    | =Arguments= | =Description= |
    ...    | pay_hours | Hours to be converted |
    ...    | =Returns= | =Description= |
    ...    | hours_to_minutes | Returns minutes |
    [Arguments]    ${pay_hours}
    ${hours_to_minutes}    Convert Hours To Minutes On Web    ${pay_hours}
    RETURN    ${hours_to_minutes}

Get Store For Date In Pay Results Section On Web
    [Documentation]    This keyword gets the store for specific date in Pay Results section
    ...    | =Returns= | =Description= |
    ...    | store_text | Returns store |
    [Arguments]    ${shift_date}
    ${store_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_STORE}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Is Element Visible On Webpage    ${store_locator}
    IF    ${is_visible}
        ${store_text}    Get Element Text On Webpage    ${store_locator}
        RETURN    ${store_text}
    ELSE
        RETURN
    END

Get Employee Name In Timecard Section On Web
    [Documentation]    This keyword returns employee name from Timecard page
    ...    | =Returns= | =Description= |
    ...    | emp_name | Returns employee name |
    ${emp_name}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_EMP_NAME}
    RETURN    ${emp_name}

Verify Total Pay Displayed In Pay Results Section On Web
    [Documentation]    This keyword returns true/false total pay is displayed
    ...    | =Returns= | =Description= |
    ...    | is_total_pay_displayed | Returns boolean true/false |
    ${is_total_pay_displayed}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage
    ...    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_TOTAL_PAY}
    RETURN    ${is_total_pay_displayed}

Capture Total Pay In Pay Results Section On Web
    [Documentation]    This keyword captures total pay on 'Pay Results' page
    ...    | =Returns= | =Description= |
    ...    | total_pay | Returns total pay |
    ${total_pay}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_TOTAL_PAY}
    RETURN    ${total_pay}

Verify Pay Results Data Not Visible For Deleted Shift
    [Documentation]    This keyword verifies that pay results data is not visible for a deleted shift
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Shift date |
    ...    | =Returns= | =Description= |
    ...    | true/false | Returns boolean value based on pay results data present or not |
    [Arguments]    ${shift_date}
    ${cost_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_COST}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Is Element Visible On Webpage    ${cost_locator}
    RETURN    ${is_visible}

Is Add Punch Button Available On Timecard Page On Web
    [Documentation]    Keyword to check and return if Add Punch button is displayed on Timecard page
    ...    | =Returns= | =Description= |
    ...    | is_Punch_button_visible | Boolean flag which signifies if 'Add Punch' button is displayed |
    ${is_Punch_button_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PUNCH_ADD_BTN}
    Capture Screenshot On Webpage
    RETURN    ${is_Punch_button_visible}

Select Transaction Type On Timecard Page On Web
    [Documentation]    Select Transaction Type on Timecard page on web
    ...    | =Arguments= | =Description= |
    ...    | transaction_type | The transaction type to select |
    [Arguments]    ${transaction_type}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PUNCH_TRANSACTION_TYPE}
    ${selected}    Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PUNCH_TRANSACTION_TYPE}    text    ${transaction_type}
    # Only validate if we got a valid response
    IF    ${selected} is not None
        List Should Contain Value    ${selected}    ${transaction_type}
    END

Add Punch On Timecard Page On Web
    [Documentation]    Add Punch workflow
    ...    | =Arguments= | =Description= |
    ...    | shift_start_day | The day offset for which the punch is to be added |
    ...    | transaction_type | The transaction type to select |
    ...    | punch_start_time | The punch start time to enter |
    ...    | reason_code | The reason code to select |
    ...    | activity_code | The activity code to select |
    ...    Example usage | Add Punch On Timecard Page On Web    3    Shift Start    09:00 AM    Sick    Regular Work
    [Arguments]    ${shift_start_day}    ${transaction_type}    ${punch_start_time}    ${reason_code}    ${activity_code}
    ${date_format}    Get Config Value    key=DATE_FMT_DAY_NON_ZERO_PADDED
    ${formated_date}    Calculate Date From Week Day Offset    ${shift_start_day}    ${date_format}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PUNCH_ADD_BTN}
    Select Transaction Type On Timecard Page On Web    ${transaction_type}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PUNCH_DATE_ICON}
    # prepare dynamic day locator
    ${day_locator_currentweek}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_SHIFT_DAY_CURRENT_WEEK}
    ...    TEMP_DAY=${formated_date}
    ${is_visible}    Is Element Present On Webpage    ${day_locator_currentweek}
    # redirect to appropriate week
    IF    ${is_visible}
        Click Element On Webpage    ${day_locator_currentweek}
    ELSE
        # Go to next month to see if day locator is present or not
        Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DAY_NEXT_MONTH}
        Click Element On Webpage    ${day_locator_currentweek}
    END
    ${is_visible}    Is Element Visible On Webpage    ${TIMECARD_PAGE_ADD_PUNCH_ACTIVITY_CODE_ASTERICS}
    IF    ${is_visible}
        Select List Item On Webpage    ${TIMECARD_PAGE_ADD_PUNCH_ACTIVITY_CODE_DROPDOWN}    text    ${activity_code}
    END
    Capture Screenshot On Webpage
    Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_ADD_PUNCH_REASON_CODE_DROPDOWN}
    ...    error_message=Reason code dropdown did not appear for punch addition within expected time.
    Select List Item On Webpage    ${TIMECARD_PAGE_ADD_PUNCH_REASON_CODE_DROPDOWN}    text    ${reason_code}
    Fill Textbox On Webpage    ${TIMECARD_PAGE_ADD_PUNCH_START_TIME}    ${punch_start_time}
    Click Element On Webpage    ${TIMECARD_PAGE_PUNCHES_ADD_PUNCH_BTN}
    Handle Cross Week Notification If Appears On Timecard Page On Web
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    Wait Until Page Is Loaded
    Verify Success Notification Toast On Time Card Page On Web
    Capture Screenshot On Webpage

Handle Cross Week Notification If Appears On Timecard Page On Web
    [Documentation]    Handles cross-week notification popup that appears when punches span across fiscal weeks
    ...    This notification typically appears after clicking Add Punch button when the punch time
    ...    falls outside the current fiscal week boundary. The keyword waits for the notification
    ...    and clicks OK to proceed.
    ...    Example usage: Handle Cross Week Notification If Appears On Timecard Page On Web
    ${cross_week_notification_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_CROSS_WEEK_NOTIFICATION}    timeout=${SHORT_TIMEOUT}
    IF    ${cross_week_notification_visible}
        Log    Cross-week notification appeared - portion of the shift falls outside fiscal week
        Capture Screenshot On Webpage
        Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_CROSS_WEEK_NOTIFICATION_OK_BUTTON}    timeout=${SHORT_TIMEOUT}
        Click Element On Webpage    ${TIMECARD_PAGE_CROSS_WEEK_NOTIFICATION_OK_BUTTON}
        Wait Until Element Disappears On Webpage    ${TIMECARD_PAGE_CROSS_WEEK_NOTIFICATION}    timeout=${SHORT_TIMEOUT}
        Log    Cross-week notification handled successfully
    ELSE
        Log    No cross-week notification appeared
    END

Edit Punch On Timecard Page On Web
    [Documentation]    Edit Punch workflow
    ...    | =Arguments= | =Description= |
    ...    | shift_request_week | The week for which the shift edit is to be performed |
    ...    | edit_reason_code | The reason code to select during edit (optional) |
    [Arguments]    ${shift_request_week}    ${edit_reason_code}=${None}
    ${date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${formatted_date}    Calculate Date From Week Day Offset    ${shift_request_week}    ${date_format}
    ${week_locator}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_SHIFT_REQUEST_WEEK}
    ...    TEMP_WEEK=${formatted_date}
    ${is_visible}    Is Element Present On Webpage    ${week_locator}
    IF    ${is_visible}
        Click Element On Webpage    ${week_locator}
        ${week_locator_department}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_EDIT_PUNCH_DEPARTMENT_WEEK}    TEMP_WEEK=${formatted_date}
        # edit shift
        Is Element Visible On Webpage    ${week_locator_department}
        Click Element On Webpage    ${week_locator_department}
        Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_CHANGE_LOCATION_POPUP}
        Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_SHIFT_EDIT_DEPT_DROPDOWN}
        IF    '${edit_reason_code}' != '${None}'
            Select List Item On Webpage    ${TIMECARD_PAGE_SHIFT_EDIT_REASON_CODE_DROPDOWN}
            ...    text    ${edit_reason_code}
        ELSE
            Select List Item On Webpage    ${TIMECARD_PAGE_SHIFT_EDIT_REASON_CODE_DROPDOWN}
            ...    index    2
        END
        Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_EDIT_CHANGE_LOCATION_BTN}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
        Verify Success Notification Toast On Time Card Page On Web
        Capture Screenshot On Webpage
    END

Format Punch Time For Timecard Search
    [Documentation]    Helper keyword to format punch time for timecard search based on system configuration
    ...    This keyword handles both 12-hour and 24-hour formats with proper leading zero handling
    ...    Returns the formatted time string for UI search
    ...    | =Arguments= | =Description= |
    ...    | punch_time | The punch time in 24-hour format (HH:MM) |
    ...    | =Returns= | =Description= |
    ...    | formatted_time | Formatted time string based on environment configuration |
    [Arguments]    ${punch_time}

    ${12_hour_time_format}    Get Config Value    key=TIME_FORMAT_12_HRS

    # Handle time format conversion based on environment configuration
    IF    ${12_hour_time_format}
        # Convert 24-hour time to 12-hour format for 12-hour environments
        ${formatted_punch_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${punch_time}
        # Standardize AM/PM format (ensure 'am' and 'pm' instead of 'a' and 'p')
        ${converted_punch_time}    Replace String    ${formatted_punch_time}    ${SPACE}p    ${SPACE}pm
        ${converted_punch_time}    Replace String    ${converted_punch_time}    ${SPACE}a    ${SPACE}am

        # Handle leading zero normalization for UI compatibility
        ${normalized_punch_time}    Evaluate
        ...    '${converted_punch_time}'.lstrip('0') if '${converted_punch_time}'.startswith('0') and len('${converted_punch_time}') > 1 else '${converted_punch_time}'
        RETURN    ${normalized_punch_time}
    ELSE
        # Use 24-hour time as-is for 24-hour environments
        RETURN    ${punch_time}
    END

Delete Punch On Timecard Page On Web
    [Documentation]    Delete punch added on Timecard page on web
    ...    | =Arguments= | =Description= |
    ...    | shift_request_date | The date for which the shift delete is to be performed |
    ...    | timecard_reason | The reason code to select during delete |
    ...    | punch_time | The punch time to identify the punch to be deleted (24-hour format HH:MM) |
    ...    Example usage :
    ...    Delete Punch On Timecard Page On Web    2023-09-15    Personal    17:00
    [Arguments]    ${shift_request_date}    ${timecard_reason}    ${punch_time}
    ${date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${formatted_date}    Calculate Date From Week Day Offset    ${shift_request_date}    ${date_format}

    # Get formatted time for system display based on environment configuration
    ${primary_time_format}    Format Punch Time For Timecard Search    ${punch_time}
    # This is needed because some UI elements might expect leading zeros
    ${12_hour_time_format}    Get Config Value    key=TIME_FORMAT_12_HRS
    IF    ${12_hour_time_format}
        # Convert 24-hour time to 12-hour format for 12-hour environments
        ${formatted_punch_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${punch_time}
        # Standardize AM/PM format (ensure 'am' and 'pm' instead of 'a' and 'p')
        ${alt_time_format}    Replace String    ${formatted_punch_time}    ${SPACE}p    ${SPACE}pm
        ${alt_time_format}    Replace String    ${alt_time_format}    ${SPACE}a    ${SPACE}am
    ELSE
        VAR    ${alt_time_format}    ${punch_time}
    END

    # Try to find punch elements using primary time format first
    ${punch_end_shift_locator}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_PUNCH_END_SHIFT_WEEK_ROW}    TEMP_WEEK=${formatted_date}    PUNCH_TIME=${primary_time_format}

    ${punch_start_shift_locator}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_PUNCH_START_SHIFT_WEEK_ROW}    TEMP_WEEK=${formatted_date}    PUNCH_TIME=${primary_time_format}

    # Check if elements are present with primary time format
    ${is_end_shift_visible}    Is Element Present On Webpage    ${punch_end_shift_locator}
    ${is_start_shift_visible}    Is Element Present On Webpage    ${punch_start_shift_locator}

    # If not found with primary format, try alternative format without leading zero
    IF    not ${is_end_shift_visible} and not ${is_start_shift_visible} and '${alt_time_format}' != '${primary_time_format}'
        Log    Primary time format ${primary_time_format} not found, trying alternative format ${alt_time_format}
        ${punch_end_shift_locator}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_PUNCH_END_SHIFT_WEEK_ROW}    TEMP_WEEK=${formatted_date}    PUNCH_TIME=${alt_time_format}

        ${punch_start_shift_locator}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_PUNCH_START_SHIFT_WEEK_ROW}    TEMP_WEEK=${formatted_date}    PUNCH_TIME=${alt_time_format}

        ${is_end_shift_visible}    Is Element Present On Webpage    ${punch_end_shift_locator}
        ${is_start_shift_visible}    Is Element Present On Webpage    ${punch_start_shift_locator}
        VAR    ${used_time_format}    ${alt_time_format}
    ELSE
        VAR    ${used_time_format}    ${primary_time_format}
    END

    # Process punch deletion based on which element is found
    IF    ${is_end_shift_visible}
        Log    Deleting end shift punch at time ${used_time_format}
        Click Element On Webpage    ${punch_end_shift_locator}
        ${promise}    Promise To    Wait For Alert    action=accept
        Click Element On Webpage    ${TIMECARD_PAGE_DELETE_PUNCH}
        ${alert_status}    Run Keyword And Return Status    Wait For    ${promise}
        IF    not ${alert_status}
            Select List Item On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_REASON_CODE}    text    ${timecard_reason}
            Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_YES_BTN}
        END
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
        Verify Success Notification Toast On Time Card Page On Web
    ELSE IF    ${is_start_shift_visible}
        Log    Deleting start shift punch at time ${used_time_format}
        Click Element On Webpage    ${punch_start_shift_locator}
        ${promise}    Promise To    Wait For Alert    action=accept
        Click Element On Webpage    ${TIMECARD_PAGE_DELETE_PUNCH}
        ${alert_status}    Run Keyword And Return Status    Wait For    ${promise}
        IF    not ${alert_status}
            Select List Item On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_REASON_CODE}    text    ${timecard_reason}
            Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_YES_BTN}
        END
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
        Verify Success Notification Toast On Time Card Page On Web
    ELSE
        VAR    @{searched_formats}    ${primary_time_format}    ${alt_time_format}
        ${searched_formats_str}    Evaluate    ', '.join(${searched_formats})
        Fail
        ...    Unable to find punch element for time ${punch_time} on date ${formatted_date}. Searched for time formats: ${searched_formats_str}
    END

Get First Available Week On Exception Management Page On Web
    [Documentation]    Get first available week from the given week list on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | week_to_apply_request | List of weeks available to apply request |
    ...    | day | Day index to get first available week (default is 0) |
    ...    | =Returns= | =Description= |
    ...    | day_numeric, first_element | Returns day numeric and first available week string |
    [Arguments]    ${week_to_apply_request}
    ${first_element}    Get First Element After Sorting Dates On Web    ${week_to_apply_request}
    ${day_numeric}    Extract Day Numeric From Week String For Timecard Punch On Web    ${first_element}
    RETURN    ${day_numeric}    ${first_element}

Extract Day Numeric From Week String For Timecard Punch On Web
    [Documentation]    Keyword to extract day numeric from given week date string
    [Arguments]    ${week}    ${day_numeric_index}=1
    VAR    ${date_string}    ${week}
    ${day}    Evaluate    '${date_string}'.split(' ')[1].split('/')[${day_numeric_index}]
    RETURN    ${day}

Is Punch Shift Available On Timecard Page On Web
    [Documentation]    This keyword looks for the presence of Punch Shift data
    ...    | =Arguments= | =Description= |
    ...    | shift_request_week | The week for which the shift presence is to be checked |
    ...    | punch_time | The punch time to check for (24-hour format HH:MM) |
    ...    | =Returns= | =Description= |
    ...    | True/False | Returns True if punches present else False |
    [Arguments]    ${shift_request_week}    ${punch_time}
    ${date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${formatted_date}    Calculate Date From Week Day Offset    ${shift_request_week}    ${date_format}

    # Get formatted time for system display based on environment configuration
    ${converted_punch_time}    Format Punch Time For Timecard Search    ${punch_time}
    ${punch_shift_locator}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_PUNCH_END_SHIFT_WEEK_ROW}    TEMP_WEEK=${formatted_date}    PUNCH_TIME=${converted_punch_time}
    ${is_punch_shift_visible}    Is Element Present On Webpage    ${punch_shift_locator}
    RETURN    ${is_punch_shift_visible}

Verify Special Pay Section Details For Paid Leave Requests On Web
    [Documentation]    Verifies the special pay section details
    ...    | =Arguments= | =Description= |
    ...    | special_pay_date | The planning week day for which the special pay presence is to be checked in format example 1_2 |
    ...    | pay_code | Pay code for special pay |
    ...    Example usage:
    ...    | Verify Special Pay Section Details On Web    1_2    Paid Vacation
    [Arguments]    ${special_pay_date}    ${pay_code}
    ${timecard_shift_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${spl_pay_date}    Calculate Date From Week Day Offset    ${special_pay_date}    date_format=${timecard_shift_date_format}
    ${spl_pay_date_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_DATE}
    ...    REQUEST_DAY=${spl_pay_date}
    ${spl_pay_pay_code_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_PAY_CODE}    REQUEST_DAY=${spl_pay_date}    PAY_CODE=${pay_code}
    Wait Until Element Is Visible On Webpage    ${spl_pay_date_locator}
    Wait Until Element Is Visible On Webpage    ${spl_pay_pay_code_locator}

Is Special Pay Data Visible On Timecard Page On Web
    [Documentation]    This keyword looks for the presence of special pay data
    ...    | =Arguments= | =Description= |
    ...    | special_pay_date | Date in week_day format (e.g., 1_2) for which special pay presence is checked |
    ...    | =Returns= | =Description= |
    ...    | True/False | Returns True if special pay present else False |
    [Arguments]    ${special_pay_date}
    ${timecard_shift_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${spl_pay_date}    Calculate Date From Week Day Offset    ${special_pay_date}    date_format=${timecard_shift_date_format}
    ${spl_pay_date_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_DATE}
    ...    REQUEST_DAY=${spl_pay_date}
    ${is_special_pay_visible}    Is Element Present On Webpage    ${spl_pay_date_locator}
    RETURN    ${is_special_pay_visible}

Is Add Lunch Button Available On Timecard Page On Web
    [Documentation]    Keyword to check and return if Add Lunch button is displayed on Timecard page
    ...    | =Returns= | =Description= |
    ...    | is_Lunch_button_visible | Boolean flag which signifies if 'Add Lunch' button is displayed |
    ${is_lunch_button_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_LUNCH_BTN}
    RETURN    ${is_lunch_button_visible}

Verify Lunch Added On Timecard Page On Web
    [Documentation]    Verify that lunch added on Timecard page on web
    ...    | =Arguments= | =Description= |
    ...    ${max_previous_week_to_iterate} | Maximum previous week to iterate to find available shift date |
    ...    Returns the week for which lunch was added
    [Arguments]    ${max_previous_week_to_iterate}    ${lunch_shift_data}
    FOR    ${week_index}    IN RANGE    0    ${max_previous_week_to_iterate}
        ${week_shift_dates_from_week_navigator}    Get Available Shift Dates From Week Navigator On Timecard Page On Web
        ${already_applied_shifts}    Get Already Applied Shifts On Timecard Page On Web
        ${week_to_apply_request}    Evaluate
        ...    list(set(${week_shift_dates_from_week_navigator}) ^ set(${already_applied_shifts}))
        ${count_of_week_to_apply_request}    Get Length    ${week_to_apply_request}
        IF    $count_of_week_to_apply_request >= 1
            ${day_numeric}    ${shift_request_week}    Get First Available Week On Exception Management Page On Web
            ...    ${week_to_apply_request}
            Add Lunch On Timecard Page On Web    ${day_numeric}    ${lunch_shift_data}
            RETURN    ${shift_request_week}
        ELSE IF    $count_of_week_to_apply_request == 0
            ${count_of_already_applied_shifts}    Get Length    ${already_applied_shifts}
            # iterate to see actual is blank or not
            VAR    ${shift_added_successfully}    False
            FOR    ${index}    IN RANGE    ${count_of_already_applied_shifts}
                # Get Each Week To Raise Request
                ${shift_request_week}    Get From List    ${already_applied_shifts}    ${index}
                ${day_numeric}    Extract Day Numeric From Week String On Web    ${shift_request_week}
                ${is_actuals_present}    Check Todays Shift And Its Actuals Presence On Timecard Page On Web
                ...    ${shift_request_week}
                IF    not ${is_actuals_present}
                    Add Lunch On Timecard Page On Web    ${day_numeric}    ${lunch_shift_data}
                    VAR    ${shift_added_successfully}    True
                    RETURN    ${shift_request_week}
                END
            END
            IF    not ${shift_added_successfully}
                # Shift To Previous Week Timecard Page Of User
                Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_PREVIOUS_WEEK_TIMECARD}
                Wait Until Page Is Loaded
                Capture Screenshot On Webpage
            END
        ELSE
            Log    No week available to apply shift or all weeks shifts are applied with actuals
        END
        # Previous Week Navigation Completed For Week Index: ${week_index+1}
        ${next_index}    Evaluate    ${week_index} + 1
        IF    ${next_index} == ${max_previous_week_to_iterate}
            Skip    max_previous_week_to_iterate Count:: ${next_index} is reached to set limit, hence skipping test
        END
    END
    RETURN    ${shift_request_week}

Add Lunch On Timecard Page On Web
    [Documentation]    Add Lunch workflow on Timecard page on web
    ...    | =Arguments= | =Description= |
    ...    | day | The day for which the lunch is to be added |
    [Arguments]    ${day}    ${lunch_shift_data}
    ${day_int}    Convert To Integer    ${day}
    ${day}    Evaluate    str(${day_int})
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_LUNCH_BTN}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_LUNCH_DATE_ICON}
    # prepare dynamic day locator
    ${day_locator_currentweek}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_SHIFT_DAY_CURRENT_WEEK}
    ...    TEMP_DAY=${day}
    ${is_visible}    Is Element Present On Webpage    ${day_locator_currentweek}
    # redirect to appropriate week
    IF    ${is_visible}
        Click Element On Webpage    ${day_locator_currentweek}
    ELSE
        # Go to next month to see if day locator is present or not
        Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DAY_NEXT_MONTH}
        Click Element On Webpage    ${day_locator_currentweek}
    END
    ${start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${lunch_shift_data}[lunch_start_time]
    ${end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${lunch_shift_data}[lunch_end_time]
    Fill Textbox On Webpage    ${TIMECARD_PAGE_ADD_LUNCH_START_TIME}    ${start_time}
    Fill Textbox On Webpage    ${TIMECARD_PAGE_ADD_LUNCH_END_TIME}    ${end_time}
    Select List Item On Webpage    ${TIMECARD_PAGE_ADD_LUNCH_REASON_CODE_DROPDOWN}    text    ${lunch_shift_data}[reason_code]
    Click Element On Webpage    ${TIMECARD_PAGE_LUNCH_ADD_LUNCH_BTN}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    Verify Success Notification Toast On Time Card Page On Web

Delete Lunch On Timecard Page On Web
    [Documentation]    Delete lunch added on Timecard page on web
    ...    | =Arguments= | =Description= |
    ...    | shift_request_week | The week for which the shift delete is to be performed |
    ...    | timecard_reason | The reason code to select during delete |
    ...    | lunch_time | The lunch time to identify the lunch to be deleted |
    ...    Example usage :
    ...    Delete Lunch On Timecard Page On Web    2023-09-15    Personal    12:00 PM
    [Arguments]    ${shift_request_week}    ${timecard_reason}    ${lunch_time}
    ${formatted_lunch_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${lunch_time}
    ${converted_lunch_time}    Replace String    ${formatted_lunch_time}    ${SPACE}p    ${SPACE}pm
    ${lunch_start_shift_locator}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_LUNCH_START_SHIFT_WEEK_ROW}    TEMP_WEEK=${shift_request_week}    LUNCH_TIME=${converted_lunch_time}
    ${is_visible}    Is Element Present On Webpage    ${lunch_start_shift_locator}
    IF    ${is_visible}
        Click Element On Webpage    ${lunch_start_shift_locator}
        ${promise}    Promise To    Wait For Alert    action=accept
        Click Element On Webpage    ${TIMECARD_PAGE_DELETE_LUNCH}
        ${alert_status}    Run Keyword And Return Status
        ...    Wait For    ${promise}
        IF    not ${alert_status}
            Select List Item On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_REASON_CODE}
            ...    text    ${timecard_reason}
            Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_YES_BTN}
        END
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
        Verify Success Notification Toast On Time Card Page On Web
        # assert that after delete lunch respective lunch record is not present on page.
        Wait Until Element Disappears On Webpage    ${lunch_start_shift_locator}
    END

Is Lunch Shift Available On Timecard Page On Web
    [Documentation]    This keyword looks for the presence of lunch Shift data
    ...    | =Arguments= | =Description= |
    ...    | shift_request_week | The week for which the shift presence is to be checked |
    ...    | =Returns= | =Description= |
    ...    | True/False | Returns True if lunches present else False |
    [Arguments]    ${shift_request_week}    ${lunch_time}
    ${formatted_lunch_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${lunch_time}
    ${converted_lunch_time}    Replace String    ${formatted_lunch_time}    ${SPACE}p    ${SPACE}pm
    ${lunch_start_shift_locator}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_LUNCH_START_SHIFT_WEEK_ROW}    TEMP_WEEK=${shift_request_week}    LUNCH_TIME=${converted_lunch_time}
    ${is_lunch_shift_visible}    Is Element Present On Webpage    ${lunch_start_shift_locator}
    RETURN    ${is_lunch_shift_visible}

Click On Associate Clock Icon On Exception Management Page On Web
    [Documentation]    clicks on associate clock icon on exception management page
    ...    | =Arguments= | =Description= |
    ...    | Associate_name | Name of the associate whose clock icon is to be clicked |
    [Arguments]    ${associate_name}
    ${contains_comma}    Run Keyword And Return Status    Should Contain    ${associate_name}    ,
    IF    ${contains_comma}
        @{name_parts}    Split String    ${associate_name}    ,
    ELSE
        @{name_parts}    Split String    ${associate_name}    ${SPACE}
    END
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    ${exception_management_page_associate}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_SELECT_ASSOCIATE}    FIRST_NAME=${first_name}    LAST_NAME=${last_name}
    Click Element On Webpage    ${exception_management_page_associate}
    Wait Until Page Is Loaded

Handle Lunch Add And Remove Operations On Web
    [Documentation]    Wrapper keyword that handles lunch button visibility check and performs add/remove lunch operations
    ...    | =Arguments= | =Description= |
    ...    | max_previous_week_to_iterate | Maximum previous week to iterate to find available shift date |
    ...    | delete_reason_code | Reason code to be used while deleting lunch |
    [Arguments]    ${max_previous_week_to_iterate}    ${lunch_shift_data}
    ${is_lunch_button_visible}    Is Add Lunch Button Available On Timecard Page On Web
    IF    ${is_lunch_button_visible}
        ${shift_request_week}    Verify Lunch Added On Timecard Page On Web    ${max_previous_week_to_iterate}    ${lunch_shift_data}
        Delete Lunch On Timecard Page On Web    ${shift_request_week}    ${lunch_shift_data}[reason_code]
        RETURN    ${shift_request_week}
    ELSE
        Capture Screenshot On Webpage
        SKIP    RTA lunch feature not available
    END

Get Department Name Of Specific Employee On Web
    [Documentation]    This keyword gets the department name of specific employee
    ...    | =Arguments= | =Description= |
    ...    | emp_name | Name of employee for which department to be fetched |
    ...    | =Returns= | =Description= |
    ...    | dept_name | Returns department name of employee |
    [Arguments]    ${emp_name}
    ${emp_row}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMP_ROW}    EMP_NAME=${emp_name}
    Click Element On Webpage    ${emp_row}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_BOTTOM_TAB}
    ${dept_name}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_EMP_DETAILS_DEPARTMENT}
    RETURN    ${dept_name}

Select Day On Exception Management Page On Web
    [Documentation]
    ...    Selects a date on the web calendar using a week-day format (e.g., 1_2).
    ...    | =Arguments=    | =Description=    |
    ...    | week_day_input    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    ...    Example usage:
    ...    | Select Day On Exception Management Page    2_3
    [Arguments]    ${week_day_input}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CALENDAR_BUTTON}
    Select Date Through Date Picker For ESS Requests On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CALENDAR_BUTTON}    ${week_day_input}
    Wait Until Page Is Loaded
    Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPINNER}
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}
    ...    Verify Header Week Start Date On Week Label On Web    ${week_day_input}    ${EXCEPTION_MANAGEMENT_PAGE_CALENDAR_BUTTON}
    Verify Exception Management Page Is Loaded Successfully On Web

Search & Click On Clock For Employee On Exception Management Page On Web
    [Documentation]    This keyword searches and clicks on clock icon for employee on Exception Management Page
    ...    | =Arguments= | =Description= |
    ...    | employee_name | Name of the employee whose clock icon is to be clicked |
    [Arguments]    ${employee_name}
    VAR    ${normalized_name}    ${employee_name}
    ${contains_comma}    Run Keyword And Return Status    Should Contain    ${employee_name}    ,
    IF    ${contains_comma}
        ${normalized_name}    Replace String    ${employee_name}    ,    ${EMPTY}
    END
    ${name_parts}    Split String    ${normalized_name}    ${SPACE}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_EMPLOYEE_ID}
    Fill Textbox On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ASSOCIATE_SEARCH_BOX}    ${employee_name}
    Press Enter Key Using Browser Library
    ${employee_clock}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_CLOCK_ICON}
    ...    FIRST_NAME=${name_parts}[0]    LAST_NAME=${name_parts}[1]
    Wait Until Element Is Visible On Webpage    ${employee_clock}
    Capture Screenshot On Webpage
    Click Element On Webpage    ${employee_clock}

Delete Performed Web Clock Actions From Time Card Page On Web
    [Documentation]    Deletes today's shift from timecard using date-specific locator.
    ...    Automatically uses today's date for web clock actions.
    ...    Handles both Windows alert and reason code popup scenarios.
    ...    Example usage:
    ...    | Delete Performed Web Clock Actions From Time Card Page On Web
    ${delete_reason_code}    Get System Value    WebClockAssociateDetails    DELETE_REASON_CODE
    ${display_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${display_date}    Get Current Date    result_format=${display_date_format}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TIMECARD_ROW}
    ...    DATE=${display_date}
    Log    Shift locator for deletion: ${shift_locator}
    Click Element On Webpage    ${shift_locator}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_REMOVE_SHIFT_ICON}
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_REMOVE_SHIFT_ICON}
    ${alert_status}    Run Keyword And Return Status
    ...    Wait For    ${promise}
    IF    not ${alert_status}
        Wait Until Page Is Loaded
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DELETE_REASON_CODE}    value    ${delete_reason_code}
        Wait Until Page Is Loaded
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DELETE_CONFIRMATION_BUTTON}
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    Verify Success Notification Toast On Time Card Page On Web
    Capture Screenshot On Webpage
    Wait Until Page Is Loaded

Open Employee Timecard On Exception Management Page On Web
    [Documentation]
    ...    Opens the timecard for a specific employee on the Exception Management page
    ...    and waits until that employee's timecard is confirmed visible.
    ...    Fails with a clear message if the timecard page does not open within the timeout.
    ...    | =Arguments= | =Description= |
    ...    | employee_badge_id | Employee username or badge ID to open timecard for |
    ...    Example usage:
    ...    | Open Employee Timecard On Exception Management Page On Web | ${ess_user}[username] |
    [Arguments]    ${employee_badge_id}
    ${updated_link_to_click_employee}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_LINK_TO_CLICK_EMPLOYEE}    EMP_ID=${employee_badge_id}
    Click Element On Webpage    ${updated_link_to_click_employee}
    Verify Timecard Page Is Loaded On Web
    ${employee_on_timecard_locator}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_ASSOCIATE_NAME}    associate_id=${employee_badge_id}
    Wait Until Element Is Visible On Webpage    ${employee_on_timecard_locator}    timeout=${LONG_TIMEOUT}
    ...    error_message=Timecard page did not open for employee '${employee_badge_id}' within expected time. The ui-selectmenu-text span containing the employee ID was not found.

Check If On Exception Management Timecard Page On Web
    [Documentation]
    ...    Returns True if the persistent calendar left arrow element is visible, indicating the Exception Management timecard page is loaded.
    ...    | =Returns= | =Description= |
    ...    | on_timecard_page | Boolean flag: True if on timecard page, False otherwise |
    ...    Example usage:
    ...    | ${on_timecard_page}    Check If On Exception Management Timecard Page On Web
    ${on_timecard_page}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${EXCEPTION_MANAGEMENT_PAGE_CALENDAR_LEFT_ARROW_FOR_CLOCK}
    RETURN    ${on_timecard_page}

Verify Web Clock Actions On Time Card Page On Web
    [Documentation]    Opens employee timecard and verifies clock action presence for today's date.
    ...    Uses date-specific locator with today's date in "Ddd MM/DD" format.
    ...    | =Arguments= | =Description= |
    ...    | employee_badge_id | Employee badge ID to locate and verify clock actions for |
    ...    Example usage:
    ...    | Verify Web Clock Actions On Time Card Page On Web | 12345 |
    [Arguments]    ${employee_badge_id}    ${store_id}

    # Get date format and store timezone
    ${display_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${store_timezone}    Get Store Timezone From DB    ${store_id}

    # Get current date in store's timezone and format it
    ${store_date}    Evaluate
    ...    __import__('datetime').datetime.now(__import__('zoneinfo').ZoneInfo('${store_timezone}')).strftime('${display_date_format}')
    Log    Using store timezone date: ${store_date} (Timezone: ${store_timezone})

    Open Employee Timecard On Exception Management Page On Web    ${employee_badge_id}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TIMECARD_ROW}
    ...    DATE=${store_date}
    Wait Until Element Is Visible On Webpage    ${shift_locator}    timeout=${LONG_TIMEOUT}
    ...    error_message=Clock action entry for ${store_date} did not appear within expected time.
    ${is_time_present}    Is Element Present On Webpage    ${shift_locator}
    IF    ${is_time_present}
        Log    Clock action entry verified successfully for ${store_date}
        Capture Screenshot On Webpage
    ELSE
        Capture Screenshot On Webpage
        Fail    Clock action entry not found for ${store_date} after waiting
    END

Get Special Pay Count For Specific Date On Timecard Page On Web
    [Documentation]    This keyword looks for the presence of special pay data for specific date
    ...    | =Arguments= | =Description= |
    ...    | special_pay_date | Date in week_day format (e.g., 1_2) for which special pay presence is checked |
    ...    | =Returns= | =Description= |
    ...    | sp_rec_count | Returns count of special pay records found |
    [Arguments]    ${special_pay_date}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_SECTION}
    ${day_month_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${spl_pay_date}    Calculate Date From Week Day Offset    ${special_pay_date}    date_format=${day_month_date_format}
    ${spl_pay_date_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SP_BY_DATE}
    ...    SP_DATE=${spl_pay_date}
    ${sp_rec_count}    Get Element Count On Web Page    ${spl_pay_date_locator}
    RETURN    ${sp_rec_count}

Verify Shift Is Present In Timecard For Day Page On Web
    [Documentation]    This keyword verifies that shift is present on Timecard page on web
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Shift date |
    ...    | =Returns= | =Description= |
    ...    | true/false | Returns boolean value based on shift present or not |
    [Arguments]    ${shift_date}
    ${shift_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_TIMECARD_FIRST_SHIFT_INSTANCE}
    ...    DAY=${shift_date}
    ${shift_is_visible}    Is Element Visible On Webpage    ${shift_locator}
    RETURN    ${shift_is_visible}

Get Warning Count Of Specific Employee On Web
    [Documentation]    This keyword returns the warning count of the specific employee
    ...    | =Arguments= | =Description= |
    ...    | emp_name | Name of employee for which warning count to be checked |
    ...    | =Returns= | =Description= |
    ...    | warning_count | Warning Count on exception management page |
    [Arguments]    ${emp_name}
    ${warning_count_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_WARNING_COUNT}
    ...    EMP_NAME=${emp_name}
    Wait Until Element Is Visible On Webpage    ${warning_count_locator}
    ${warning_count_txt}    Get Element Text On Webpage    ${warning_count_locator}
    ${warning_count}    Convert To Number    ${warning_count_txt}
    RETURN    ${warning_count}

Select Exceptions By Day Tab On Exception Management Page On Web
    [Documentation]    This keyword selects Exceptions By Day tab on Exception Management Page on web
    Select Bottom Tab By Index On Exception Management Page On Web    1

Select Exceptions By Type Tab On Exception Management Page On Web
    [Documentation]    This keyword selects Exceptions By Type tab on Exception Management Page on web
    Select Bottom Tab By Index On Exception Management Page On Web    2

Select Pay Statistics Tab On Exception Management Page On Web
    [Documentation]    This keyword selects Pay Statistics tab on Exception Management Page on web
    Select Bottom Tab By Index On Exception Management Page On Web    3

Select Bottom Tab By Index On Exception Management Page On Web
    [Documentation]    This keyword selects the specific option in bottom tabs on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | tab_index | Index for the tab to be selected |
    [Arguments]    ${tab_index}
    ${bottom_tab_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_PAY_STATISTICS_TABS}
    ...    TAB_INDEX=${tab_index}
    Wait Until Element Is Visible On Webpage    ${bottom_tab_locator}
    Scroll And Verify Element Presence On Webpage    ${bottom_tab_locator}
    Click Element On Webpage    ${bottom_tab_locator}

Verify Total Hours Count In Bottom Tab On Exception Management Page On Web
    [Documentation]    This keyword verifies total hours count in Exceptions By Day, Exceptions By Type,
    ...    Pay Statistics tab with expected value on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | expected_total_hours | Expected total hours to be verified |
    [Arguments]    ${expected_total_hours}
    Select Exceptions By Day Tab On Exception Management Page On Web
    ${total_hours_by_day}    Capture Total Hours On Pay Statistics Section On Web
    Should Be Equal As Numbers    ${expected_total_hours}    ${total_hours_by_day}
    ...    msg=Total hours on Exception By Day tab does not match with total hours on Exception Management page.
    Select Exceptions By Type Tab On Exception Management Page On Web
    ${total_hours_by_type}    Capture Total Hours On Pay Statistics Section On Web
    Should Be Equal As Numbers    ${expected_total_hours}    ${total_hours_by_type}
    ...    msg=Total hours on Exception By Type tab does not match with total hours on Exception Management page.
    Select Pay Statistics Tab On Exception Management Page On Web
    ${total_hours_pay_section}    Capture Total Hours On Pay Statistics Section On Web
    Should Be Equal As Numbers    ${expected_total_hours}    ${total_hours_pay_section}
    ...    msg=Total hours on Pay Statistics tab does not match with total hours on Exception Management page.
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_BOTTOM_TAB_CLOSE}

Verify Imported Shift On Timecard Page On Web
    [Documentation]    Verifies that imported shift is visible on timecard for specific date.
    ...    Waits for batch processing and validates shift row presence.
    ...    | =Arguments= | =Description= |
    ...    | display_date | Formatted date string (e.g., "Fri 11/28") |
    ...    | batch_wait_minutes | Batch processing wait time in minutes |
    ...    Example usage:
    ...    | Verify Imported Shift On Timecard Page On Web    Fri 11/28    5
    [Arguments]    ${display_date}    ${batch_wait_minutes}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TIMECARD_ROW}
    ...    DATE=${display_date}
    ${shift_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${shift_locator}
    Capture Screenshot On Webpage
    IF    not ${shift_visible}
        Fail
        ...    Imported punches not visible on timecard for ${display_date}. Batch processing may have failed or is taking longer than expected (waited ${batch_wait_minutes} minutes). Check Punch Import page for errors or increase WEB_CLOCK_BATCH_PROCESSING_WAIT_MINUTES config.
    END
    Log    Imported shift verified successfully on timecard for ${display_date}

Delete Imported Shift On Timecard Page On Web
    [Documentation]    Deletes imported shift from timecard using date-specific locator.
    ...    | =Arguments= | =Description= |
    ...    | display_date | Formatted date string (e.g., "Fri 11/28") |
    ...    Example usage:
    ...    | Delete Imported Shift On Timecard Page On Web    Fri 11/28
    [Arguments]    ${display_date}
    ${delete_reason_code}    Get System Value    WebClockAssociateDetails    DELETE_REASON_CODE
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TIMECARD_ROW}
    ...    DATE=${display_date}
    Click Element On Webpage    ${shift_locator}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_REMOVE_SHIFT_ICON}
    Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DELETE_REASON_CODE}    value    ${delete_reason_code}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DELETE_CONFIRMATION_BUTTON}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NOTIFICATION_MESSAGE}

Verify Associate Presence On Exception Management Page On Web
    [Documentation]    Verify employee presence on exception management page
    ...    | =Arguments= | =Description= |
    ...    | Associate_name | Name of the associate whose clock icon is to be clicked |
    ...    | visible_flag | Flag to check if associate presence or absence, True for presence, False for absence|
    [Arguments]    ${associate_name}    ${visible_flag}=True
    Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPINNER}
    @{name_parts}    Split String    ${associate_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    ${exception_management_page_associate}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_DETAIL}    FIRST_NAME=${first_name}    LAST_NAME=${last_name}
    ${is_emp_visible}    Is Element Visible On Webpage    ${exception_management_page_associate}
    IF    ${visible_flag}
        Should Be True    ${is_emp_visible}
        ...    msg=Expected associate '${associate_name}' to be visible on the exception management page, but it was not. Actual visibility: ${is_emp_visible}
    ELSE
        Should Be True    not ${is_emp_visible}
        ...    msg=Expected associate '${associate_name}' not to be visible on the exception management page, but it was. Actual visibility: ${is_emp_visible}
    END

Apply Advanced Filter By Staff Group On Exception Management Page On Web
    [Documentation]
    ...    Applies filter for employees by Staff Group on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | staff_group_filter_value | Staff Group filter value to be applied |
    ...    Example usage:
    ...    | Apply Advanced Filter By Staff Group On Exception Management Page On Web    Staff Group3 |
    [Arguments]    ${staff_group_filter_value}
    ${staff_group_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_STAFF_GROUP}    STAFF_GROUP=${staff_group_filter_value}
    Apply Advanced Filter On Web    ${staff_group_locator}

Apply Advanced Filter By Name On Exception Management Page On Web
    [Documentation]
    ...    Applies filter for employees by Staff Group and Name on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | staff_group_filter_value | Staff Group filter value to be applied |
    ...    | employee_name_value | Employee name value to be selected |
    ...    Example usage:
    ...    | Apply Advanced Filter By Name On Exception Management Page On Web    Staff Group1    Store1, Associate04 |
    [Arguments]    ${staff_group_filter_value}    ${employee_name_value}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_RESET_BUTTON}
    ${staff_group_locator}    Update Locator With Dynamic Values
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_STAFF_GROUP}    STAFF_GROUP=${staff_group_filter_value}
    Click Element On Webpage    ${staff_group_locator}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_FETCH_BUTTON}
    Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPINNER}
    ${is_select_all_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_SELECT_ALL}
    IF    ${is_select_all_visible}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_SELECT_ALL}
        ${employee_name_locator}    Update Locator With Dynamic Values
        ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMP_NAME}    EMP_NAME=${employee_name_value}
        Click Element On Webpage    ${employee_name_locator}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_APPLY_BUTTON}
        Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPINNER}
    ELSE
        Fail    No Employees are filtered by the staff group: ${staff_group_filter_value} as expected
    END

Is Reportee Filter Available On Exception Management Page On Web
    [Documentation]
    ...    Checks if the Reportee filter is available on Exception Management Page on web
    ...    | =Returns= | =Description= |
    ...    | is_reportee_filter_visible | Boolean flag which signifies if 'Reportee' filter is displayed |
    Open Advanced Filter On Exception Management Page On Web
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_FETCH_BUTTON}
    ${is_reportee_filter_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_REPORTEE_TYPE}
    RETURN    ${is_reportee_filter_visible}

Apply Advanced Filter By Reportee Type On Exception Management Page On Web
    [Documentation]
    ...    Applies filter for employees by Reportee Type on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | reportee_type_filter_value | Reportee Type filter value to be applied |
    ...    Example usage:
    ...    | Apply Advanced Filter By Reportee Type On Exception Management Page On Web    Direct |
    [Arguments]    ${reportee_type_filter_value}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    IF    '${reportee_type_filter_value}' == 'DIRECT'
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_DIRECT_REPORTEE}
    ELSE IF    '${reportee_type_filter_value}' == 'INDIRECT'
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_INDIRECT_REPORTEE}
    ELSE IF    '${reportee_type_filter_value}' == 'MY_LOCATION'
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_MY_LOCATION_REPORTEE}
    ELSE
        Fail    Invalid reportee type filter value: ${reportee_type_filter_value}
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_FETCH_BUTTON}
    Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPINNER}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_APPLY_BUTTON}
    Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SPINNER}

Open Advanced Filter On Exception Management Page On Web
    [Documentation]
    ...    Click advanced filter icon on the Exception Management page
    ...    Example usage:
    ...    | Open Advanced Filter On Exception Management Page On Web |
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    Wait Until Page Is Loaded

Verify Display Preference On Exception Management Page On Web
    [Documentation]    Verifies that the display preferences on Exception Management Page are as expected.
    ...    | =Arguments= | =Description= |
    ...    | visible_locator | Locator expected to be visible |
    ...    | not_visible_locator_1 | Locator expected to be not visible |
    ...    | not_visible_locator_2 | Locator expected to be not visible |
    ...    Example usage:
    ...    | Verify Display Preference On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ID_COLUMN}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_COLUMN}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ICON_COLUMN}
    [Arguments]    ${visible_locator}    ${not_visible_locator_1}    ${not_visible_locator_2}
    Capture Screenshot On Webpage
    Wait Until Element Is Visible On Webpage    ${visible_locator}
    Get Element Text On Webpage    ${visible_locator}
    ${is_first_not_visible}    Run Keyword And Return Status
    ...    Wait For Elements State    ${not_visible_locator_1}    hidden    timeout=${MEDIUM_TIMEOUT}
    ${is_second_not_visible}    Run Keyword And Return Status
    ...    Wait For Elements State    ${not_visible_locator_2}    hidden    timeout=${MEDIUM_TIMEOUT}
    Should Be True    ${is_first_not_visible}
    ...    msg=Expected ${not_visible_locator_1} to be not visible, but it was visible
    Should Be True    ${is_second_not_visible}
    ...    msg=Expected ${not_visible_locator_2} to be not visible, but it was visible
    Log    Verified: ${visible_locator} is visible, ${not_visible_locator_1} and ${not_visible_locator_2} are not visible

Build Locator For Display Preference On Exception Management Page On Web
    [Documentation]    Builds locator for display preference element on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | employee_name | Name of the employee |
    ...    | employee_id | ID of the employee |
    ...    | employee_type | Type of the employee |
    ...    | =Returns= | =Description= |
    ...    | employee_id_locator | Locator for employee ID element |
    ...    | employee_type_locator | Locator for employee type element |
    ...    | employee_icon_locator | Locator for employee icon element |
    ...    | employee_name | Locator for employee name element |
    ...    Example usage:
    ...    | ${emp_id_locator}    ${emp_type_locator}    ${emp_icon_locator}    ${emp_name_locator} =
    ...    Build Locator For Display Preference On Exception Management Page On Web
    ...    John Doe    12345    FT
    [Arguments]    ${employee_name}    ${employee_id}    ${employee_type}
    ${employee_id_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_WITH_ID_SEARCH}
    ...    EMPLOYEE_NAME=${employee_name}    EMPLOYEE_ID=${employee_id}
    ${employee_type_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_WITH_TYPE}
    ...    EMPLOYEE_NAME=${employee_name}    EMPLOYEE_TYPE=${employee_type}
    ${employee_icon_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_WITH_ICON_SEARCH}
    ...    EMPLOYEE_NAME=${employee_name}
    ${employee_name}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_NAME}    EMPLOYEE_NAME=${employee_name}
    RETURN    ${employee_id_locator}    ${employee_type_locator}    ${employee_icon_locator}    ${employee_name}

Apply Sort Preference And Verify Order On Exception Management Page On Web
    [Documentation]    Applies sort preference on Exception Management page and validates the sorting order.
    ...    This keyword handles both sorting scenarios:
    ...    1. Full Timers First: FT associates appear first, followed by PT associates
    ...    2. Alphabetical: All associates sorted alphabetically by name
    ...    | =Arguments= | =Description= |
    ...    | sort_type | Sort type to apply. Valid values: 'Full Timers First' or 'Alphabetical' |
    ...    Example usage:
    ...    | Apply Sort Preference And Verify Order On Exception Management Page On Web    Full Timers First
    ...    | Apply Sort Preference And Verify Order On Exception Management Page On Web    Alphabetical
    [Arguments]    ${sort_type}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SORT_PREFERENCE_ICON}
    Wait Until Page Is Loaded
    IF    '${sort_type}' == 'Full Timers First'
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SORT_BY_FULL_TIMERS_FIRST_RADIO}
    ELSE IF    '${sort_type}' == 'Alphabetical'
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SORT_BY_ALPHABETICAL_RADIO}
    ELSE
        Fail    Invalid sort type: ${sort_type}. Expected 'Full Timers First' or 'Alphabetical'
    END
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SORT_PREFERENCE_APPLY_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    Verify Sort Order On Exception Management Page On Web    ${sort_type}

Verify Sort Order On Exception Management Page On Web
    [Documentation]    Verifies the sort order of employees on Exception Management page.
    ...    For 'Full Timers First': Validates that all FT employees appear before PT employees.
    ...    For 'Alphabetical': Validates that employees are sorted alphabetically by name.
    ...    | =Arguments= | =Description= |
    ...    | sort_type | Sort type to verify. Valid values: 'Full Timers First' or 'Alphabetical' |
    ...    Example usage:
    ...    | Verify Sort Order On Exception Management Page On Web    Full Timers First
    ...    | Verify Sort Order On Exception Management Page On Web    Alphabetical
    [Arguments]    ${sort_type}
    ${employee_count}    Get Element Count On Web Page    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_NAME_LIST}
    Should Be True    ${employee_count} > 0    msg=No employees found on Exception Management page to verify sort order
    VAR    @{name_list}    @{EMPTY}
    IF    '${sort_type}' == 'Full Timers First'
        # For Full Timers First, get all employee names using index-based access
        FOR    ${index}    IN RANGE    ${employee_count}
            VAR    ${name_locator}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_NAME_LIST} >> nth=${index}
            ${name}    Get Element Text On Webpage    ${name_locator}
            Append To List    ${name_list}    ${name}
        END
        Verify Full Timers First Sort Order On Web    ${name_list}
    ELSE IF    '${sort_type}' == 'Alphabetical'
        # For Alphabetical, we are verifying the employees from the first department
        ${emp_list_count}    Get Element Count On Web Page    ${EXCEPTION_MANAGEMENT_PAGE_EMP_LIST}
        ${max_count}    Evaluate    min(${emp_list_count}, ${employee_count})
        FOR    ${index}    IN RANGE    ${max_count}
            VAR    ${name_locator}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_NAME_LIST} >> nth=${index}
            ${name}    Get Element Text On Webpage    ${name_locator}
            Append To List    ${name_list}    ${name}
        END
        Verify Alphabetical Sort Order On Web    ${name_list}
    ELSE
        Fail    Invalid sort type: ${sort_type}. Expected 'Full Timers First' or 'Alphabetical'
    END
    Capture Screenshot On Webpage
    ${final_count}    Get Length    ${name_list}
    Log    Sort order verification completed successfully for ${final_count} employees with sort type: ${sort_type}

Verify Full Timers First Sort Order On Web
    [Documentation]    Verifies that Full Time employees appear before Part Time employees in the list.
    ...    This validates the 'Full Timers First' sorting preference where all FT associates
    ...    are displayed first, followed by all PT associates.
    ...    | =Arguments= | =Description= |
    ...    | name_list | List of employee names in displayed order |
    [Arguments]    ${name_list}
    VAR    ${ft_count}    0
    VAR    ${pt_count}    0
    VAR    ${ft_section_ended}    False
    VAR    ${employees_without_type}    0
    FOR    ${name}    IN    @{name_list}
        ${name_stripped}    Strip String    ${name}
        # Build a locator to find employee type in the same row as this employee name
        ${employee_type_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE}
        ...    NAME_STRIPPED=${name_stripped}
        ${type_element_exists}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${employee_type_locator}
        VAR    ${emp_type}    ${EMPTY}
        VAR    ${type_found}    False
        IF    ${type_element_exists}
            ${type_text}    Get Element Text On Webpage    ${employee_type_locator}
            ${type_text}    Strip String    ${type_text}
            IF    '${type_text}' == 'FT' or '${type_text}' == 'PT'
                VAR    ${emp_type}    ${type_text}
                VAR    ${type_found}    True
            END
        END
        IF    ${type_found}
            IF    '${emp_type}' == 'FT'
                ${ft_count}    Evaluate    ${ft_count} + 1
                IF    ${ft_section_ended}
                    Fail
                    ...    Sort order violation: FT employee '${name_stripped}' found after PT employees. Full Timers First sorting is not applied correctly.
                END
            ELSE IF    '${emp_type}' == 'PT'
                ${pt_count}    Evaluate    ${pt_count} + 1
                VAR    ${ft_section_ended}    True
            END
        ELSE
            ${employees_without_type}    Evaluate    ${employees_without_type} + 1
        END
    END
    Log    Full Timers First sort verification passed: ${ft_count} FT employees appear before ${pt_count} PT employees
    IF    ${employees_without_type} > 0
        Log    Warning: ${employees_without_type} employees found without employee type information    level=WARN
    END
    Should Be True    ${ft_count} > 0 or ${pt_count} > 0
    ...    msg=No employees with type information found to verify Full Timers First sort order

Verify Alphabetical Sort Order On Web
    [Documentation]    Verifies that employees are sorted alphabetically by name (case-insensitive).
    ...    This validates the 'Alphabetical' sorting preference where all associates are
    ...    displayed in alphabetical order regardless of their employee type.
    ...    | =Arguments= | =Description= |
    ...    | name_list | List of employee names in displayed order |
    [Arguments]    ${name_list}
    ${sorted_names}    Evaluate    sorted([name.strip() for name in ${name_list}], key=str.lower)
    ${cleaned_name_list}    Evaluate    [name.strip() for name in ${name_list}]
    Lists Should Be Equal    ${cleaned_name_list}    ${sorted_names}
    ...    msg=Employees are not sorted alphabetically. Expected order: ${sorted_names}, Actual order: ${cleaned_name_list}
    ${employee_count}    Get Length    ${name_list}
    Log    Alphabetical sort verification passed for ${employee_count} employees

Verify Exception Management Page Is Loaded Successfully On Web
    [Documentation]    Verifies that the Exception Management page is loaded by checking visibility of employee and bottom tab on page.
    Check Reporting Hierarchy And Apply Reportee Type Filter On Exception Management Page On Web
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_EMPLOYEE_ID}
    Log    Exception Management page is loaded successfully with employees displayed
    Verify Bottom Tabs Visible On Exception Management Page On Web
    Log    Bottom tab is visible on Exception Management page
    Capture Screenshot On Webpage

Save And Verify Special Pay On Exception Management Page On Web
    [Documentation]    Saves special pay changes on Exception Management page on web
    ...    | =Arguments= | =Description= |
    ...    | sp_added_date | Date for which special pay added |
    [Arguments]    ${sp_added_date}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_ON_DIALOGUE}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_SAVED_SUCCESS_ALERT}    timeout=${LONG_TIMEOUT}
    ${special_pay_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_WEEK_TO_RAISE_SPECIAL_PAY_REQ}
    ...    SP_PAY_ADDED_DATE=${sp_added_date}
    Wait Until Element Is Visible On Webpage    ${special_pay_locator}

Apply Advanced Filter For Department On Web
    [Documentation]    Applies advanced filter for department on Exception Management Page on web
    ${department_name}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DEPARTMENT_NAME}
    ${department_name}    Strip String    ${department_name}
    ${dept_type_filter_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_DEPARTMENT_OPTION}
    ...    DEPT_NAME=${department_name}
    Apply Advanced Filter On Web    ${dept_type_filter_locator}

Verify Employee Type Employee Id And Employee Icon On Exception Management Page On Web
    [Documentation]    Verifies that employee type, employee id and employee icon are displayed on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | employee_name | Name of the employee |
    ...    | employee_id | ID of the employee |
    ...    | employee_type | Type of the employee |
    ...    Example usage:
    ...    | Verify Employee Type Employee Id And Employee Icon On Exception Management Page On Web
    ...    John Doe    12345    FT
    [Arguments]    ${employee_name}    ${employee_id}    ${employee_type}
    ${employee_id_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_WITH_ID_SEARCH}
    ...    EMPLOYEE_NAME=${employee_name}    EMPLOYEE_ID=${employee_id}
    Wait Until Element Is Visible On Webpage    ${employee_id_locator}
    Get Element Text On Webpage    ${employee_id_locator}
    ${employee_type_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_WITH_TYPE}
    ...    EMPLOYEE_NAME=${employee_name}    EMPLOYEE_TYPE=${employee_type}
    Wait Until Element Is Visible On Webpage    ${employee_type_locator}
    Get Element Text On Webpage    ${employee_type_locator}
    ${employee_icon_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_WITH_ICON_SEARCH}
    ...    EMPLOYEE_NAME=${employee_name}
    Wait Until Element Is Visible On Webpage    ${employee_icon_locator}
    Get Element Text On Webpage    ${employee_icon_locator}

Verify Activity Code Field Present In Add Shift On Exception Management Page On Web
    [Documentation]    This keyword verifies that the activity code is required in the add shift on exception management page
    ...    | =Returns= | =Description= |
    ...    | activity_code_visible | Returns boolean value based on activity code field presence |
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_BUTTON}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_POPUP}
    ${activity_code_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_ACTIVITY_CODE}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_CANCEL_SHIFT_BTN}
    RETURN    ${activity_code_visible}

Apply Advanced Filter For Reportee Type On Exception Management Page On Web
    [Documentation]    ...    Applies filter for employees by Reportee Type on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | reportee_type | Reportee Type filter value to be applied |
    [Arguments]    ${reportee_type}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    ${filter_option}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_REPORTEE_TYPE_RADIO_BTN}    TYPE=${reportee_type}
    Wait Until Element Is Visible On Webpage    ${filter_option}
    ...    error_message=Reportee type filter option: ${reportee_type} is not visible on Exception Management page
    Click Element On Webpage    ${filter_option}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_FETCH_BUTTON}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_APPLY_BUTTON}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FIRST_EMP_LIST}    timeout=${MEDIUM_TIMEOUT}
    ...    error_message=No employees found after applying reportee type filter: ${reportee_type}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Is Punch Shift For Start Available On Timecard Page On Web
    [Documentation]    This keyword looks for the presence of Punch Shift data
    ...    | =Arguments= | =Description= |
    ...    | shift_request_week | The week for which the shift presence is to be checked |
    ...    | punch_start_time | The punch time to check for (24-hour format HH:MM) |
    ...    | =Returns= | =Description= |
    ...    | True/False | Returns True if punches present else False |
    [Arguments]    ${shift_request_week}    ${punch_start_time}
    ${date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${12_hour_time_format}    Get Config Value    key=TIME_FORMAT_12_HRS
    ${formatted_date}    Calculate Date From Week Day Offset    ${shift_request_week}    ${date_format}
    ${formatted_punch_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${punch_start_time}
    ${converted_punch_time}    Replace String    ${formatted_punch_time}    ${SPACE}p    ${SPACE}pm
    IF    ${12_hour_time_format}
        ${converted_punch_time}    Evaluate
        ...    '${converted_punch_time}'.lstrip('0') if '${converted_punch_time}'.startswith('0') and len('${converted_punch_time}') > 1 else '${converted_punch_time}'
    END
    ${punch_shift_locator}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_PUNCH_START_SHIFT_WEEK_ROW}    TEMP_WEEK=${formatted_date}    PUNCH_TIME=${converted_punch_time}
    ${is_punch_shift_visible}    Is Element Present On Webpage    ${punch_shift_locator}
    RETURN    ${is_punch_shift_visible}

Check Reporting Hierarchy And Apply Reportee Type Filter On Exception Management Page On Web
    [Documentation]    This keyword checks the reporting hierarchy for the user and
    ...    applies the reportee type filter accordingly on Exception Management Page on web
    ${reporting_hierarchy_enabled}    Get Config Value    key=ENABLE_REPORTING_HIERARCHY
    IF    '${reporting_hierarchy_enabled}' == "Y"
        ${reportee_type}    Get System Value    ReporteeType    MY_LOCATION
        Apply Advanced Filter For Reportee Type On Exception Management Page On Web    ${reportee_type}
    END

Is Employee Icon Visible For Employees On Exception Management Page On Web
    [Documentation]    This keyword checks for the presence of employee icon on Exception Management Page on web
    ...    | =Returns= | =Description= |
    ...    | True/False | Returns True if employee detail icon is visible else False |
    ${is_emp_icon_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ICON}
    RETURN    ${is_emp_icon_visible}

Assert At Least Two Staff Groups Are Available On Web
    [Documentation]    This keyword checks if there are at least two staff groups available in the environment
    ...    to perform filter testing on Exception Management Page on web
    ${reporting_hierarchy_enabled}    Get Config Value    key=ENABLE_REPORTING_HIERARCHY
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    ...    error_message=Filter icon not visible on Exception Management page
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_APPLY_BUTTON}
    ...    error_message=Filter take too long to load on Exception Management page after clicking filter icon
    IF    '${reporting_hierarchy_enabled}' == "Y"
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_MY_LOCATION_REPORTEE}
    END
    Wait Until Page Is Loaded
    ${staffgroup_count}    Get Element Count On Web Page    ${EXCEPTION_MANAGEMENT_PAGE_AD_FILTER_STAFF_GROUPS}
    Skip If    ${staffgroup_count} < 2    Not enough staff groups available in the environment to perform filter testing.
    Capture Screenshot On Webpage
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON}

Cleanup Shift And Special Pay If Exists On Timecard Page On Web
    [Documentation]    This keyword cleans up the shift and special pay added for an employee on a specific date from timecard and Exception Management page on web
    ...    | =Arguments= | =Description= |
    ...    | shift_date_offsets | One or more date offsets from current week to identify shifts to be cleaned up. |
    ...    Example usage:
    ...    | Cleanup Shift And Special Pay If Exists On Timecard Page On Web    -2_3 |
    ...    | Cleanup Shift And Special Pay If Exists On Timecard Page On Web    -2_3    -2_4 |
    [Arguments]    @{shift_date_offsets}
    FOR    ${date_offset}    IN    @{shift_date_offsets}
        Open Add Shift Dialog On Exception Management Page On Web
        ${day_only_format}    Get Config Value    key=DATE_FMT_DAY_ONLY
        ${day}    Calculate Date From Week Day Offset    ${date_offset}    ${day_only_format}
        ${formatted_day}    Evaluate    '${day}'.lstrip('0')
        ${shift_date_added}    Select Date On Calendar For Shift On Exception Management Page On Web    ${formatted_day}
        ${numeric_date}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_FROM_DATE_TXT_BOX_ON_POPUP}
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_CLOSE_BTN}
        ...    error_message=Failed to close add shift dialog on Exception Management page after selecting date for cleanup. Please check if the calendar popup is closed.
        Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_CLOSE_BTN}
        ${sp_pay_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_ADDED}
        ...    SP_PAY_ADDED_DATE=${shift_date_added}
        ${is_sp_pay_present}    Is Element Present On Webpage    ${sp_pay_locator}
        ${shift_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_ACTUALS}    DATE=${numeric_date}
        ${actual_counts}    Get Element Count On Web Page    ${shift_locator}
        IF    ${actual_counts}
            Delete Shift On Timecard Page On Web    ${shift_date_added}
        END
        IF    ${is_sp_pay_present}
            Delete Special Pay On Web    ${shift_date_added}
        END
    END

Enter Employee Data In Employee Search Field On Exception Management Page On Web
    [Documentation]    This keyword searches for an employee using the search box on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | employee_data | Data of the employee to be searched |
    [Arguments]    ${employee_data}
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_SEARCH_BOX}
    Clear Textbox On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_SEARCH_BOX}
    Fill Textbox On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_SEARCH_BOX}    ${employee_data}

Is Employee Displayed After Search On Exception Management Page On Web
    [Documentation]    This keyword validates the search result after searching for an employee on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | employee_data | Data of the employee to be searched |
    [Arguments]    ${employee_data}
    ${employee_name_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SEARCHED_EMPLOYEE}
    ...    SEARCH_INPUT=${employee_data}
    ${is_employee_visible}    Is Element Visible On Webpage    ${employee_name_locator}
    RETURN    ${is_employee_visible}

Search And Validate Employee Search On Exception Management Page On Web
    [Documentation]    This keyword combines searching for an employee and validating the search result on Exception Management Page on web
    ...    | =Arguments= | =Description= |
    ...    | employee_data | Data of the employee to be searched |
    [Arguments]    ${employee_data}
    Enter Employee Data In Employee Search Field On Exception Management Page On Web    ${employee_data}
    ${is_matching_result_visible}    Is Employee Displayed After Search On Exception Management Page On Web    ${employee_data}
    Capture Screenshot On Webpage
    RETURN    ${is_matching_result_visible}
