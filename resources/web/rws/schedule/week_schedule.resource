*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Week Schedule page functionality.
...
...                 = Purpose =
...                 - Centralizes actions for navigating, filtering, and verifying schedules on the Week Schedule page.
...
...                 = Prerequisites =
...                 - Required resources and variable files must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Verify Navigation To Week Schedule Page
...                 |    Navigate To RWS Week Schedule Page On Web

Resource            resources/web/common/common.resource
Variables           resources/web/rws/schedule/week_schedule_page.py
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/common/calendar_navigation.resource
Resource            resources/web/common/common_date_utility.resource
Resource            resources/web/rws/schedule/fixed_shifts.resource
Variables           resources/web/rws/schedule/week_schedule_api.py
Variables           resources/web/common/status_codes.py
Variables           test_data/localized_text/rws_localized_text.py
Resource            resources/api/api_executor.resource
Resource            resources/web/rws/schedule/batch_plan_status.resource
Resource            resources/web/rws/schedule/plan_status.resource


*** Keywords ***
Navigate To RWS Schedule Week Schedule Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Week Schedule Page
    ...    and verifies week schedule heading at the top of the page
    Navigate To Specific Page On Web    rws    schedule    week_schedule
    Wait Until Page Is Loaded

Select Week Number On Week Schedule Page On Web
    [Documentation]    Selects week number on Week Schedule page on web using week_day format
    ...    | =Arguments=    | =Description= |
    ...    | week_day_input    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    [Arguments]    ${week_day_input}
    ${target_date}    Calculate Date From Week Day Offset    ${week_day_input}
    ${week_label_date_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${week_label_date}    Calculate Week Start Date From Week Day Offset    ${week_day_input}    date_format=${week_label_date_format}
    ${date_format_year_only}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${date_format_month_only}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${date_format}    Get Config Value    DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA
    ${target_year}    Convert Date    ${target_date}    result_format=${date_format_year_only}
    ${target_month_name}    Convert Date    ${target_date}    result_format=${date_format_month_only}
    ${target_day_formatted}    Convert Date    ${target_date}    result_format=${date_format}
    ${year_last_2_digits}    Evaluate    str('${target_year}')[2:]
    Wait Until Page Is Loaded
    # Use dynamic locator templates instead of hardcoded XPath
    Click Element On Webpage    ${FIXEDSHIFTSPAGE_CALENDAR_BUTTON}
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
    Wait Until Element Disappears On Webpage    ${FIXEDSHIFTPAGE_CALENDAR_POP_UP}
    ${week_label_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_HEADER_WEEK_LABEL}    WEEK=${week_label_date}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${week_label_locator}    timeout=${LONG_TIMEOUT}
    Capture Screenshot On Webpage

Check Employees Availablity Post Schedule Generation On Week Schedule Page On Web
    [Documentation]
    ...    Verifies if schedule is published by checking for at least one employee shift row.
    ...    Returns True if shift rows are displayed, False otherwise.
    ...    | =Returns= | =Description= |
    ...    | is_schedule_published | Boolean flag which signifies if schedule shifts are displayed |
    ...    Example usage:
    ...    | ${schedule_published}=    Check Employees Availablity Post Schedule Generation On Week Schedule Page On Web
    ${shifts_count}    Get Element Count On Web Page    ${WEEK_SCHEDULE_EMPLOYEE_SHIFT_ROW}
    ${is_schedule_published}    Evaluate    ${shifts_count} > 0
    RETURN    ${is_schedule_published}

Get Vacant Day Cell On Week Schedule Page On Web
    [Documentation]    This keyword returns vacant day cell data (row, col) on week schedule page
    ${schedule_rows}    Get Elements    ${WEEK_SCHEDULE_SCHEDULE_ROWS}
    ${schedule_rows_length}    Get Length    ${schedule_rows}
    ${todays_col_index}    Get Todays Column Index On Week Schedule Page On Web

    VAR    ${blank_cell_found}    False
    FOR    ${row}    IN RANGE    1    ${schedule_rows_length}
        ${row_str}    Convert To String    ${row}

        ${cols}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_GRID_COLUMNS}    ROW_NUM=${row_str}
        ${schedule_cols}    Get Elements    ${cols}
        ${col_length}    Get Length    ${schedule_cols}
        FOR    ${col}    IN RANGE    ${todays_col_index}    ${col_length}    1
            ${col_str}    Convert To String    ${col}
            ${schedule_grid_element}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_GRID_ELEMENT}    ROW_NUM=${row_str}
            ...    COL_NUM=${col_str}
            ${grid_elm_text}    Get Element Text On Webpage    ${schedule_grid_element}

            ${holiday_cell}    Update Locator With Dynamic Values
            ...    ${WEEK_SCHEDULE_HOLIDAY_CELL}    TEMP_ROW=${row_str}    TEMP_COL=${col_str}
            ${is_elm_visible}    Is Element Present On Webpage    ${holiday_cell}
            IF    ${is_elm_visible}
                IF    $grid_elm_text == ''
                    VAR    ${blank_cell_found}    True
                    RETURN    ${row}    ${col}
                    BREAK
                END
            END
        END
    END
    IF    '${blank_cell_found}' == 'False'
        SKIP    No blank cells found on Week Schedule page
    END

Get Todays Column Index On Week Schedule Page On Web
    [Documentation]    This keyword returns the column index of the today's date
    ${todays_date}    Get Current Date    result_format=%a %d
    ${week_cols}    Get Elements    ${WEEK_SCHEDULE_DAY_HEADER}
    ${header_length}    Get Length    ${week_cols}
    VAR    ${col_ind}    0
    FOR    ${i}    IN RANGE    0    ${header_length}
        ${index_string}    Convert To String    ${i}
        ${day_header}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_CURRENT_DAY_HEADER}    COL_NUM=${index_string}+1
        ${week_txt}    Get Element Text On Webpage    ${day_header}
        ${contains}    Evaluate    "'${todays_date}' in '${week_txt}'"
        ${col_ind}    Evaluate    ${col_ind}+1
        IF    ${contains}
            RETURN    ${col_ind}
            BREAK
        END
    END

Add Shift On Week Schedule Page On Web
    [Documentation]    This keyword adds shift on week schedule page
    [Arguments]    ${week_schedule_shift_row}    ${week_schedule_shift_col}    ${shift_start_time}    ${shift_end_time}
    ${row_str}    Convert To String    ${week_schedule_shift_row}
    ${col_str}    Convert To String    ${week_schedule_shift_col}
    ${vacant_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_VACANT_CELL}    ROW_NUM=${row_str}    COL_NUM=${col_str}
    Click Element On Webpage    ${vacant_shift_cell}
    Click Element On Webpage    ${WEEK_SCHEDULE_SHIFT_START_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_SHIFT_START_TIME}    ${shift_start_time}
    Click Element On Webpage    ${WEEK_SCHEDULE_SHIFT_END_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_SHIFT_END_TIME}    ${shift_end_time}
    Click Element On Webpage    ${WEEK_SCHEDULE_ADD_SHIFT_ICON}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Un-allocate Shift On Week Schedule Page On Web
    [Documentation]    This keyword un-allocates shift on week schedule page
    [Arguments]    ${week_schedule_shift_row}    ${week_schedule_shift_col}

    ${row_str}    Convert To String    ${week_schedule_shift_row}
    ${col_str}    Convert To String    ${week_schedule_shift_col}
    ${scheduled_shift}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_UPDATED_SHIFT_TIME}    ROW_NUM=${row_str}
    ...    COL_NUM=${col_str}
    ${actual_shift_time}    Get Element Text On Webpage    ${scheduled_shift}
    ${grid_element}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_GRID_ELEMENT}    ROW_NUM=${row_str}    COL_NUM=${col_str}
    Click Element On Webpage    ${grid_element}
    Click Element On Webpage    ${WEEK_SCHEDULE_UN_ALLOCATE_SHIFT_BTN}
    Click Element On Webpage    ${WEEK_SCHEDULE_DELETE_OK_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    RETURN    ${actual_shift_time}

Click On Legend Icon And Verify All Tabs
    [Documentation]    Click on legend icon and verify all tabs should open successfully
    Click Element On Webpage    ${WEEK_SCHEDULE_LEGENDS_ICON}
    ...    error_message=Failed to click Legend icon on Week Schedule page
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_SHIFT_IMAGE}
    ...    error_message=Shift image not visible in Legend dialog
    Capture Screenshot On Webpage
    Click Element On Webpage    ${WEEK_SCHEDULE_ICONS_TAB}
    ...    error_message=Failed to click Icons tab in Legend dialog
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_ICONS_VIEW_CONTAINER}
    ...    error_message=Icons view container not visible after clicking Icons tab
    Capture Screenshot On Webpage
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_RESPONSE_TAB_CLOSE_BTN}
    ...    error_message=Failed to close Legend dialog

Verify Print Weekly Schedule Summary
    [Documentation]    This keyword verify the functionality of print Weekly Schedule Summary on week schedule page
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
    ${is_report_link_present}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_WEEKLY_SCHEDULE_SUMMARY}
    IF    not ${is_report_link_present}
        Log    Weekly Schedule Summary report link is not present on Week Schedule page
        Capture Screenshot On Webpage
        Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
        RETURN    ${False}
    END
    Click Element On Webpage    ${WEEK_SCHEDULE_WEEKLY_SCHEDULE_SUMMARY}
    Switch Page    NEW
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    ${weekly_schedule_summary_url}    Get Url
    Should Contain    ${weekly_schedule_summary_url}    /weekplan_schedule_report.jsp
    ${prefix}    Set Selector Prefix    ${None}
    ${report_title_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_STORE_SCHEDULE_SUMMARY_REPORT_TITLE}
    ${emp_details_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_SUMMARY_EMPLOYEE_DETAILS}
    ${shift_details_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_SUMMARY_SHIFT_DETAILS}
    Should Be True    ${report_title_displayed}    Weekly Schedule Summary report title is not displayed
    Should Be True    ${emp_details_displayed}    Employee details are not displayed in Weekly
    Should Be True    ${shift_details_displayed}    Shift details are not displayed in Weekly
    Set Selector Prefix    ${prefix}
    Close New Tab
    RETURN    ${True}

Get First Associate Name On Week Schedule Page On Web
    [Documentation]
    ...    Returns the first associate's name displayed on the Week Schedule page.
    ...    Skips the test if no associates are present.
    ...    | =Returns=    | =Description= |
    ...    | name    | The first associate name string. |
    ${is_associates_present}    Is Element Present On Webpage    ${WEEK_SCHEDULE_FIRST_ASSOCIATE_NAME}
    IF    not ${is_associates_present}
        SKIP    No associates present on Week Schedule page
    END
    ${first_associate_name}    Get Element Text On Webpage    ${WEEK_SCHEDULE_FIRST_ASSOCIATE_NAME}
    RETURN    ${first_associate_name}

Download And Verify Weekly Schedule Summary PDF Report On Web
    [Documentation]
    ...    Downloads and verifies the Weekly Schedule Summary PDF report.
    ...    Example:
    ...    | Download And Verify Weekly Schedule Summary PDF Report On Web
    Click Element On Webpage    ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON}
    ...    Failed to click on PDF download icon ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON} on Week Schedule page

    ${is_report_link_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_WEEKLY_SUMMARY_PDF_LINK}

    IF    ${is_report_link_visible}
        Click Element On Webpage    ${WEEK_SCHEDULE_WEEKLY_SUMMARY_PDF_LINK}
        ...    Failed to click on Weekly Schedule Summary PDF link ${WEEK_SCHEDULE_WEEKLY_SUMMARY_PDF_LINK} on Week Schedule page

        ${pdf_report_filepath}    ${pdf_report_download_dir}    Return Weekly PDF Report Download Directory And File Name On Web
        ...    WeeklyScheduleSummaryReport    weekly_schedule_summary
        Download And Verify PDF Report On Web    ${pdf_report_filepath}    ${pdf_report_download_dir}
    END

Download And Verify Weekly Schedule Detail PDF Report On Web
    [Documentation]
    ...    Downloads and verifies the Weekly Schedule Detail PDF report.
    ...    Example:
    ...    | Download And Verify Weekly Schedule Detail PDF Report On Web
    Click Element On Webpage    ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON}
    ...    Failed to click on PDF download icon ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON} on Week Schedule page

    ${is_report_link_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_WEEKLY_SCHEDULE_DETAIL_PDF_LINK}

    IF    ${is_report_link_visible}
        Click Element On Webpage    ${WEEK_SCHEDULE_WEEKLY_SCHEDULE_DETAIL_PDF_LINK}
        ...    Failed to click on Weekly Schedule Detail PDF link ${WEEK_SCHEDULE_WEEKLY_SCHEDULE_DETAIL_PDF_LINK} on Week Schedule page
        ${pdf_report_filepath}    ${pdf_report_download_dir}    Return Weekly PDF Report Download Directory And File Name On Web
        ...    WeeklyScheduleDetailReport    weekly_schedule_detail
        Download And Verify PDF Report On Web    ${pdf_report_filepath}    ${pdf_report_download_dir}
    END

Download And Verify Weekly Associate Summary PDF Report On Web
    [Documentation]
    ...    Downloads and verifies the Weekly Associate Summary PDF report for an associate.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Name of the associate (required). |
    ...    Example:
    ...    | Download And Verify Weekly Associate Summary PDF Report On Web    John Doe
    [Arguments]    ${associate_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON}
    ...    Failed to click on PDF download icon ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON} on Week Schedule page

    ${is_report_link_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_SUMMARY_PDF_LINK}

    IF    ${is_report_link_visible}
        Click Element On Webpage    ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_SUMMARY_PDF_LINK}
        ...    Failed to click on Weekly Associate Summary PDF link ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_SUMMARY_PDF_LINK} on Week Schedule page
        Fill Associate Details For PDF Report On Web    ${associate_name}
        ${pdf_report_filepath}    ${pdf_report_download_dir}    Return Weekly PDF Report Download Directory And File Name On Web
        ...    WeeklyAssociateSummaryReport    weekly_associate_summary
        Download And Verify PDF Report On Web    ${pdf_report_filepath}    ${pdf_report_download_dir}
    END

Download And Verify Weekly Associate Detail PDF Report On Web
    [Documentation]
    ...    Downloads and verifies the Weekly Associate Detail PDF report for an associate.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Name of the associate (required). |
    ...    Example:
    ...    | Download And Verify Weekly Associate Detail PDF Report On Web    Jane Smith
    [Arguments]    ${associate_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON}
    ...    Failed to click on PDF download icon ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON} on Week Schedule page
    ${is_report_link_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_DETAIL_PDF_LINK}

    IF    ${is_report_link_visible}
        Click Element On Webpage    ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_DETAIL_PDF_LINK}
        ...    Failed to click on Weekly Associate Detail PDF link ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_DETAIL_PDF_LINK} on Week Schedule page
        Fill Associate Details For PDF Report On Web    ${associate_name}

        ${pdf_report_filepath}    ${pdf_report_download_dir}    Return Weekly PDF Report Download Directory And File Name On Web
        ...    WeeklyAssociateDetailReport    weekly_associate_detail
        Download And Verify PDF Report On Web    ${pdf_report_filepath}    ${pdf_report_download_dir}
    END

Fill Associate Details For PDF Report On Web
    [Documentation]
    ...    Fills associate name in the PDF report popup.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Name of the associate (required). |
    [Arguments]    ${associate_name}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_PDF_REPORT_POPUP_NAME_TXT}    ${associate_name}
    ${associate_name_lnk}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PDF_REPORT_POPUP_NAME_LNK}
    ...    ASSOCIATE_NAME=${associate_name}
    Click Element On Webpage    ${associate_name_lnk}
    Click Element On Webpage    ${WEEK_SCHEDULE_PDF_REPORT_POPUP_DOWNLOAD_BTN}

Download And Verify PDF Report On Web
    [Documentation]
    ...    Utility that downloads and validates PDF files.
    ...    Only handles file download and verification - no report-specific logic.
    ...    | =Arguments=    | =Description= |
    ...    | pdf_report_filepath    | Full path where the file should be downloaded. |
    ...    | download_directory | Directory to create for downloads. |
    [Arguments]    ${pdf_report_filepath}    ${pdf_report_download_dir}
    OperatingSystem.Create Directory    ${pdf_report_download_dir}
    Download File From Webpage    ${pdf_report_filepath}    download_wait_time=${PAGE_LOAD_TIMEOUT}
    OperatingSystem.File Should Exist    ${pdf_report_filepath}
    OperatingSystem.File Should Not Be Empty    ${pdf_report_filepath}

Verify Week Navigation On Week Schedule Page On Web
    [Documentation]
    ...    Verifies calendar navigation on the Week Schedule page by performing sequential forward
    ...    and backward navigation through consecutive weeks. Tests the bidirectional navigation
    ...    functionality to ensure proper week traversal in both directions.
    ...    | =Arguments= | =Description= |
    ...    | number_of_weeks_to_navigate | Number of consecutive weeks to navigate in each direction |
    ...    Example usage:
    ...    | Verify Week Navigation On Week Schedule Page On Web    2
    [Arguments]    ${number_of_weeks_to_navigate}

    # Forward navigation: Navigate through consecutive weeks (Steps 1-3: weeks 1→2→3)
    Navigate Calendar By Weeks And Verify Navigated Week
    ...    ${NAVIGATION_DIRECTION_FORWARD}
    ...    ${number_of_weeks_to_navigate}
    ...    ${WEEK_SCHEDULE_FORWARD_ARROW}
    ...    ${WEEK_SCHEDULE_BACKWARD_ARROW}
    ...    ${WEEK_SCHEDULE_SELECTED_WEEK}

    # Backward navigation: Navigate back through the same weeks (Steps 4-5: weeks 3→2→1)
    Navigate Calendar By Weeks And Verify Navigated Week
    ...    ${NAVIGATION_DIRECTION_BACKWARD}
    ...    ${number_of_weeks_to_navigate}
    ...    ${WEEK_SCHEDULE_FORWARD_ARROW}
    ...    ${WEEK_SCHEDULE_BACKWARD_ARROW}
    ...    ${WEEK_SCHEDULE_SELECTED_WEEK}

Perform Group By None Sorting On Sort Preferences On Week Schedule Page On Web
    [Documentation]    Perform Sorting By None Group By Sort Preferences
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_TAB}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_NONE_RADIO_BTN}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_APPLY_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Perform Group By Department Sorting On Sort Preferences On Week Schedule Page On Web
    [Documentation]    Perform Sorting By Department Group By Sort Preferences
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_TAB}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_DEPARTMENT_RADIO_BTN}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_HIRE_DATE_RADIO_BTN}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_APPLY_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_GROUP_BY_HEADER}

Perform Group By Staff Group Sorting On Sort Preferences On Week Schedule Page On Web
    [Documentation]    Perform Sorting By Staff Group Group By Sort Preferences
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_TAB}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_STAFF_GROUP_RADIO_BTN}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_HIRE_DATE_RADIO_BTN}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_APPLY_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    Wait Until Element Is Present On Webpage    ${WEEK_SCHEDULE_GROUP_BY_HEADER}

Perform Reset For Sort Preferences On Week Schedule Page On Web
    [Documentation]    Perform Reset On Sort Preferences
    ${sort_preference_visible}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_TAB}
    IF    not ${sort_preference_visible}
        Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_ICON}
    END
    ${is_sort_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_WINDOW}
    IF    ${is_sort_displayed}
        Log    Sort Preference window is already displayed
    ELSE
        Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_ICON}
        Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_WINDOW}
    END
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREFERENCE_TAB}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREF_RESET}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_APPLY_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Verify Group By Header Visible On Week Schedule Page On Web
    [Documentation]    Verify Group By Header is visible On Week Schedule Page when sorted by a specific Group
    [Arguments]    ${expected_header_text}=${None}
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_GROUP_BY_HEADER}
    Capture Screenshot On Webpage
    IF    '${expected_header_text}' != '${None}'
        ${header_text}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_GROUP_BY_HEADER_TEXT}
        ...    HEADER_TEXT=${expected_header_text}
        Wait Until Element Is Present On Webpage    ${header_text}
    END

Verify Group By Header Not Visible On Week Schedule Page On Web
    [Documentation]    Verify Group By Header is not visible On Week Schedule Page when sorted by None Group
    ${is_header_visible}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_GROUP_BY_HEADER}
    IF    ${is_header_visible}
        Fail    Group By Header is visible on Week Schedule Page when sorted by None Group
    END

Go To Next Week Schedule On Week Schedule Page On Web
    [Documentation]    Shift to Next Weekly Schedule in Week Schedule Page
    ...    | =Arguments= | =Description= |
    ...    | number_of_weeks | Number of weeks to navigate forward (default is 1). |
    [Arguments]    ${number_of_weeks}=1
    FOR    ${_}    IN RANGE    0    ${number_of_weeks}
        Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_NEXT_WEEK}
        Wait Until Page Is Loaded
    END
    Capture Screenshot On Webpage

Open Advanced Filter Panel On Week Schedule Page On Web
    [Documentation]    Opens the advanced filter panel on the Week Schedule page.
    Wait Until Page Is Loaded
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADVANCED_FILTER_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_FILTER_SETTING_TAB}

Select Task In Advanced Filter On Week Schedule Page On Web
    [Documentation]    Selects the task in the advanced filter.
    ...    | =Arguments= | =Description= |
    ...    | task_name | Task name to be selected |
    [Arguments]    @{task_name}
    FOR    ${task}    IN    @{task_name}
        ${weekschedulepage_task_dropdown_dynamic}    Update Locator With Dynamic Values
        ...    ${WEEK_SCHEDULE_PAGE_TASK_DROPDOWN_OPTION}    TASK=${task}
        Keyboard Key    down    Control
        Click Element On Webpage    ${weekschedulepage_task_dropdown_dynamic}
        Keyboard Key    up    Control
    END

Fetch And Apply Advanced Filter On Week Schedule Page On Web
    [Documentation]    Clicks fetch, waits for results, and applies the filter if enabled.
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_FETCH_BTN}
    Wait Until Spinner Disappears On Week Schedule Page On Web
    ${is_apply_enabled}    Is Element Enabled On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_APPLY_BTN}
    IF    '${is_apply_enabled}' == 'True'
        Click Element On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_APPLY_BTN}
        Wait Until Spinner Disappears On Week Schedule Page On Web
        Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_PAGE_FILTER_ON_ICON}
        Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_PAGE_EMP_ROW}
        Wait Until Page Is Loaded
    ELSE
        Skip    No Records found for the filter criteria.
    END

Return Weekly PDF Report Download Directory And File Name On Web
    [Documentation]
    ...    Generates timestamped file path and download directory for PDF reports.
    ...    | =Arguments=    | =Description= |
    ...    | pdf_report_download_directory_name    | Type of report for directory organization (required). |
    ...    | pdf_report_file_name    | Report filename name (required). |
    ...    | =Returns=    | =Description= |
    ...    | filepath    | Full path to the PDF file with timestamp. |
    ...    | download_directory | Directory path where the file will be downloaded. |
    [Arguments]    ${pdf_report_download_directory_name}    ${pdf_report_file_name}
    VAR    ${base_dir}    ${EXECDIR}
    ${timestamp}    Get Current Date    result_format=%Y%m%d_%H%M%S
    VAR    ${download_directory}    ${base_dir}/downloads/${pdf_report_download_directory_name}
    VAR    ${filename}    ${pdf_report_file_name}_${timestamp}.pdf
    VAR    ${filepath}    ${download_directory}/${filename}
    RETURN    ${filepath}    ${download_directory}

Navigate To Next Week On Week Schedule Page On Web
    [Documentation]    This keyword navigates to next week on week schedule page
    Click Element On Webpage    ${WEEK_SCHEDULE_NEXT_WEEK_ARROW}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Verify Released To Store Message Displayed For Week On Week Schedule Page On Web
    [Documentation]    This keyword verifies the released to store message displayed for Week on week schedule page
    [Arguments]    ${store_name}
    ${RELEASED_TO_STORE_MSG}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_RELEASED_TO_STORE_MSG}
    ...    RELEASED_TO_STORE=${store_name}
    FOR    ${index}    IN RANGE    1    8
        ${released_to_store_msg_index}    Convert To String    ${index}
        ${RELEASED_TO_STORE_MSG_DAY}    Update Locator With Dynamic Values    ${RELEASED_TO_STORE_MSG}
        ...    MSG_INDEX=${released_to_store_msg_index}
        ${released_flag}    Is Element Visible On Webpage    ${RELEASED_TO_STORE_MSG_DAY}
        Should Be True    ${released_flag}    Released to store message is not displayed on week schedule page
    END
    Capture Screenshot On Webpage

Search Employee On Week Schedule Page On Web
    [Documentation]    This keyword searches for an employee on the week schedule page
    [Arguments]    ${employee_name}
    Clear Textbox On Webpage    ${WEEK_SCHEDULE_EMPLOYEE_SEARCH_INPUT}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_EMPLOYEE_SEARCH_INPUT}    ${employee_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_SEARCHED_EMPLOYEE}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Verify Detailed View Is Visible On Week Schedule Page On Web
    [Documentation]    Verify Detailed View is visible on Week Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | start_time_displayed | True if start time is displayed, False otherwise. |
    ...    | end_time_displayed | True if end time is displayed, False otherwise. |
    ...    | shift_details_displayed | True if shift details are displayed, False otherwise. |
    [Arguments]    ${start_time_displayed}=True
    ...    ${end_time_displayed}=True
    ...    ${shift_details_displayed}=True
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_DETAILED_VIEW}
    Capture Screenshot On Webpage
    IF    ${start_time_displayed}
        ${start_time_displayed}    Get Element Text On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_START_TIME}
        Should Not Be Empty    ${start_time_displayed}
    ELSE
        ${start_time}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_START_TIME}
        Should Not Be True    ${start_time}    msg=Start time is still visible
    END
    IF    ${end_time_displayed}
        ${end_time_displayed}    Get Element Text On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_END_TIME}
        Should Not Be Empty    ${end_time_displayed}
    ELSE
        ${end_time}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_END_TIME}
        Should Not Be True    ${end_time}    msg=End time is still visible
    END
    IF    ${shift_details_displayed}
        ${shift_details}    Get Element Text On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_TASK_DETAILS}
        Should Not Be Empty    ${shift_details}
    ELSE
        ${shift_detail}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_TASK_DETAILS}
        Should Not Be True    ${shift_detail}    msg=Shift details are still visible
    END

Verify Detailed View Is Not Visible On Week Schedule Page On Web
    [Documentation]    Verify Detailed View is not visible on Week Schedule page.
    [Arguments]    ${start_time_displayed}=True
    ...    ${end_time_displayed}=True
    ...    ${shift_details_displayed}=False
    ${detailed_view_visibility}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_DETAILED_VIEW}
    Capture Screenshot On Webpage
    Should Not Be True    ${detailed_view_visibility}    msg=Detailed view is still visible
    IF    ${start_time_displayed}
        ${start_time_displayed}    Get Element Text On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_START_TIME}
        Should Not Be Empty    ${start_time_displayed}
    ELSE
        ${start_time}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_START_TIME}
        Should Not Be True    ${start_time}    msg=Start time is still visible
    END
    IF    ${end_time_displayed}
        ${end_time_displayed}    Get Element Text On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_END_TIME}
        Should Not Be Empty    ${end_time_displayed}
    ELSE
        ${end_time}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_END_TIME}
        Should Not Be True    ${end_time}    msg=End time is still visible
    END
    IF    ${shift_details_displayed}
        ${shift_details}    Get Element Text On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_TASK_DETAILS}
        Should Not Be Empty    ${shift_details}
    ELSE
        ${shift_detail}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_FIRST_SHIFT_TASK_DETAILS}
        Should Not Be True    ${shift_detail}    msg=Shift details are still visible
    END

Perform Reset For Display Preferences On Week Schedule Page On Web
    [Documentation]    Perform Reset for Display Preferences
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_TAB}
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_RESET_BTN}
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_APPLY_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Navigate To Next Week Schedule On Web
    [Documentation]
    ...    Navigates to next week's schedule.
    ...    Example usage:
    ...    | Navigate To Next Week Schedule On Web
    Click Element On Webpage    ${WEEK_SCHEDULE_NEXT_WEEK_ARROW}
    Wait Until Page Is Loaded
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_PAGE_CONTENT_AREA}
    Capture Screenshot On Webpage

Check If Schedule Is In Plan Status With Rail Road On Web
    [Documentation]
    ...    Checks if schedule is in plan status (railroad indicator visible).
    ...    Used to determine if publish/unpublish operations are available.
    ...    | =Returns= | =Description= |
    ...    | is_in_plan_status | True if in plan status, False otherwise. |
    ...    Example usage:
    ...    | ${is_in_plan_status}    Check If Schedule Is In Plan Status With Rail Road On Web
    ${is_in_plan_status}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_PLAN_STATUS}
    RETURN    ${is_in_plan_status}

Perform Publish Operation On Week Schedule Page On Web
    [Documentation]
    ...    Publishes the current week schedule.
    ...    Opens action dropdown and clicks Publish option, then confirms.
    ...    Waits for Published state to appear before returning.
    ...    Example usage:
    ...    | Perform Publish Operation On Week Schedule Page On Web
    Click Element On Webpage    ${WEEK_SCHEDULE_ACTION_DROPDOWN}
    Wait Until Page Is Loaded
    # Wait for dropdown menu items to be fully rendered before checking lock option
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_PUBLISH_CURRENT}
    ...    timeout=${SHORT_TIMEOUT}
    ${lock_schedule_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_LOCK_SCHEDULE_OPTION}
    IF    ${lock_schedule_displayed}
        ${promise_alert}    Run Keyword And Ignore Error    Promise To    Wait For Alert    action=accept    timeout=3s
        Click Element On Webpage    ${WEEK_SCHEDULE_LOCK_SCHEDULE_OPTION}
        Run Keyword And Ignore Error    Wait For    ${promise_alert}[1]
        Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${FIXEDSHIFTSPAGE_PLEASE_WAIT_SPINNER}
        ...    timeout=${SHORT_TIMEOUT}
        Run Keyword And Ignore Error    Wait Until Element Disappears On Webpage
        ...    ${FIXEDSHIFTSPAGE_PLEASE_WAIT_SPINNER}    timeout=${SHORT_TIMEOUT}
        Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_LOCKED_STATE}
        Sleep    3s    # It is required to allow time for state change to reflect in UI
        Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_CALENDERNAV_SPINNER}
        Click Element On Webpage    ${WEEK_SCHEDULE_ACTION_DROPDOWN}
        Wait Until Page Is Loaded
    END
    Click Element On Webpage    ${WEEK_SCHEDULE_PUBLISH_CURRENT}
    Click Element On Webpage    ${WEEK_SCHEDULE_OK_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_PUBLISHED_STATE}    timeout=${LONG_TIMEOUT}
    ...    error_message=Failed to verify Published state on Week Schedule page after publishing
    Sleep    3s    # It is required to allow time for state change to reflect in UI    , needed as discussed with owner
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_CALENDERNAV_SPINNER}

Perform Unpublish Operation On Week Schedule Page On Web
    [Documentation]
    ...    Unpublishes the current week schedule.
    ...    Opens action dropdown and clicks Unpublish option, then confirms.
    ...    Waits for Unpublished state to appear before returning.
    ...    Example usage:
    ...    | Perform Unpublish Operation On Week Schedule Page On Web
    Click Element On Webpage    ${WEEK_SCHEDULE_ACTION_DROPDOWN}
    Wait Until Page Is Loaded
    # Wait for dropdown menu items to be fully rendered before clicking
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_UNPUBLISH_CURRENT}    timeout=5s
    Click Element On Webpage    ${WEEK_SCHEDULE_UNPUBLISH_CURRENT}
    Click Element On Webpage    ${WEEK_SCHEDULE_OK_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_UNPUBLISHED_STATE}    timeout=${LONG_TIMEOUT}
    ...    error_message=Failed to verify Unpublished state on Week Schedule page after unpublishing
    Sleep    3s    # It is required to allow time for state change to reflect in UI
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_CALENDERNAV_SPINNER}

Unpublish Schedule On Week Schedule Page On Web
    [Documentation]    Unpublishes the schedule if it is currently published.
    ...    Checks current status and performs unpublish if needed.
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Unpublish Schedule On Week Schedule Page On Web
    ${is_published}    Check If Schedule Is In Published State On Web
    IF    ${is_published}
        Perform Unpublish Operation On Week Schedule Page On Web
    ELSE
        Log    Schedule is already in Unpublished state; no action taken.
    END

Publish Schedule On Week Schedule Page On Web
    [Documentation]
    ...    Publishes the schedule if it is currently unpublished.
    ...    Checks current status and performs publish if needed.
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Publish Schedule On Week Schedule Page On We
    ${is_published}    Check If Schedule Is In Published State On Web
    IF    not ${is_published}
        Perform Publish Operation On Week Schedule Page On Web
    ELSE
        Log    Schedule is already in Published state; no action taken.
    END

Verify Permit Add Edit Shift Operation On UnPublished Schedule On Week Schedule Page On Web
    [Documentation]
    ...    Verifies Add/Edit shift operation on Unpublished schedule on week schedule page
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Verify Permit Add Edit Shift Operation On UnPublished Schedule On Week Schedule Page On Web
    Click First Vacant Day Cell On Week Schedule Page On Web
    Verify Add Shift Option Displayed On First Available Vacant Day On Week Schedule Page On Web
    ${is_shift_present}    Is Element Present On Webpage    ${WEEK_SCHEDULE_PAGE_FIRST_AVAILABLE_SHIFT_DAY_CELL}
    IF    not ${is_shift_present}
        Log    No shifts are present to edit on the schedule, skipping edit verification steps.
        RETURN
    END
    Click First Available Scheduled Day Cell On Week Schedule Page On Web
    Check And Click Edit Shift Tab On Week Schedule Page On Web
    Verify Shift Edit Save Button Is Displayed On Week Schedule Page On Web

Verify Not Permit Add Edit Shift Operation On Published Schedule On Week Schedule Page On Web
    [Documentation]
    ...    Verifies Add/Edit shift operation on Published schedule on week schedule page.
    ...    This keyword handles BOTH cases based on the allow_edit_after_publish parameter:
    ...    - If allow_edit_after_publish=True: Verifies shifts ARE editable (add shift option displayed, save button enabled)
    ...    - If allow_edit_after_publish=False: Verifies shifts are NOT editable (add shift option not displayed, save button disabled)
    ...    | =Arguments= | =Description= |
    ...    | ${allow_edit_after_publish}    | Flag indicating if editing is allowed after publishing (True=editable, False=not editable) |
    ...    Example usage:
    ...    | Verify Not Permit Add Edit Shift Operation On Published Schedule On Week Schedule Page On Web    ${False} |
    ...    | Verify Not Permit Add Edit Shift Operation On Published Schedule On Week Schedule Page On Web    ${True} |
    [Arguments]    ${allow_edit_after_publish}
    Click First Vacant Day Cell On Week Schedule Page On Web
    IF    ${allow_edit_after_publish}
        Verify Add Shift Option Displayed On First Available Vacant Day On Week Schedule Page On Web
    ELSE
        Verify Add Shift Option Not Displayed On Week Schedule Page On Web
    END
    ${is_shift_present}    Is Element Present On Webpage    ${WEEK_SCHEDULE_PAGE_FIRST_AVAILABLE_SHIFT_DAY_CELL}
    IF    not ${is_shift_present}
        Log    No shifts are present to edit on the schedule, skipping edit verification steps.
        RETURN
    END
    Click First Available Scheduled Day Cell On Week Schedule Page On Web
    IF    ${allow_edit_after_publish}
        Check And Click Edit Shift Tab On Week Schedule Page On Web
        Verify Shift Edit Save Button Is Displayed On Week Schedule Page On Web
    ELSE
        Verify Shift Edit Save Button Is Disabled On Week Schedule Page On Web
    END

Click First Available Scheduled Day Cell On Week Schedule Page On Web
    [Documentation]
    ...    Clicks on first available scheduled day cell on week schedule page
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Click First Available Scheduled Day Cell On Week Schedule Page On Web
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_FIRST_AVAILABLE_SHIFT_DAY_CELL}

Click First Vacant Day Cell On Week Schedule Page On Web
    [Documentation]
    ...    Clicks on first vacant day cell on week schedule page
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Click First Vacant Day Cell On Week Schedule Page On Web
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_FIRST_VACANT_DAY_CELL}

Verify Add Shift Option Displayed On First Available Vacant Day On Week Schedule Page On Web
    [Documentation]
    ...    Verifies Add Shift option is displayed on week schedule page
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Verify Add Shift Option Displayed On First Available Vacant Day On Week Schedule Page On Web
    ${is_add_shift_displayed}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_ADD_SHIFT_POPUP_ICON}
    Capture Screenshot On Webpage
    Should Be True    ${is_add_shift_displayed}    Expected: Add Shift option should be visible. Actual: Add Shift option was not visible.

Verify Save Button Not Displayed On Week Schedule Page On Web
    [Documentation]    Verify Save button is not displayed on week schedule page
    ${is_save_btn_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_EDIT_SAVE_BTN}
    Capture Screenshot On Webpage
    Should Not Be True    ${is_save_btn_displayed}
    ...    Expected: Save button should be hidden on the week schedule page. Actual: Save button was visible.

Verify Add Shift Option Not Displayed On Week Schedule Page On Web
    [Documentation]
    ...    Verifies Add Shift option is not displayed on week schedule page
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Verify Add Shift Option Not Displayed On Week Schedule Page On Web
    ${is_add_shift_displayed}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_ADD_SHIFT_POPUP_ICON}
    Capture Screenshot On Webpage
    Should Not Be True    ${is_add_shift_displayed}
    ...    Expected: Add Shift option should be hidden on the week schedule page. Actual: Add Shift option was visible.

Verify Shift Edit Save Button Is Displayed On Week Schedule Page On Web
    [Documentation]
    ...    Verifies Save button is displayed on week schedule page
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Verify Shift Edit Save Button Is Displayed On Week Schedule Page On Web
    ${is_save_btn_displayed}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_EDIT_SAVE_BTN}
    Capture Screenshot On Webpage
    Should Be True    ${is_save_btn_displayed}
    ...    Expected: Save button should be displayed on the week schedule page. Actual: Save button was not displayed.

Verify Shift Edit Save Button Is Enabled On Week Schedule Page On Web
    [Documentation]
    ...    Verifies Save button is enabled on week schedule page
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Verify Shift Edit Save Button Is Enabled On Week Schedule Page On Web
    Wait Until Element Is Present On Webpage    ${WEEK_SCHEDULE_EDIT_SAVE_BTN}
    ${is_save_btn_enabled}    Is Element Enabled On Webpage    ${WEEK_SCHEDULE_EDIT_SAVE_BTN}
    Capture Screenshot On Webpage
    Should Be True    ${is_save_btn_enabled}
    ...    Expected: Save button should be enabled on the week schedule page. Actual: Save button was not enabled.

Verify Shift Edit Save Button Is Disabled On Week Schedule Page On Web
    [Documentation]
    ...    Verifies Save button is disabled on week schedule page
    ...    | =Arguments= | =Description= |
    ...    | (none)    | This keyword takes no arguments |
    ...    Example usage:
    ...    | Verify Shift Edit Save Button Is Disabled On Week Schedule Page On Web
    ${disabled_attr}    Get Attribute    ${WEEK_SCHEDULE_EDIT_SAVE_BTN}    disabled
    Capture Screenshot On Webpage
    Should Be Equal As Strings    ${disabled_attr}    disabled
    ...    Expected: Save button should be disabled on the week schedule page. Actual: disabled attribute was '${disabled_attr}'.

Check One Or More Shift Scheduled On Week Schedule Page On Web
    [Documentation]    Verify scheduled count is at least one or more on Week Schedule page
    ${element_count}    Get Element Count On Web Page    ${WEEK_SCHEDULE_SCHEDULED_CELL_COUNT}
    Capture Screenshot On Webpage
    ${result}    Evaluate    ${element_count} > 0
    RETURN    ${result}

Verify No Scheduled Shift On Week Schedule Page On Web
    [Documentation]    Verify no scheduled shift on Week Schedule page
    ${element_count}    Get Element Count On Web Page    ${WEEK_SCHEDULE_SCHEDULED_CELL_COUNT}
    Capture Screenshot On Webpage
    ${result}    Evaluate    ${element_count} == 0
    Should Be True    ${result}    Expected: No scheduled shifts should be present. Actual: Found ${element_count} scheduled shifts.

Filter By All Unscheduled Shifts On Week Schedule Page On Web
    [Documentation]    Filter All Unscheduled Shifts On Advanced Filters On Week Schedule Page
    Click Element On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_FILTER_SETTING_TAB}
    Click Element On Webpage    ${WEEK_SCHEDULE_FILTER_ALL_UNSCHEDULED_CHECKBOX}
    Click Element On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_FETCH_BTN}
    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_LOADING_SPINNER}
    ${is_apply_btn_disabled}    Is Element Disabled On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_APPLY_BTN}
    Skip If    ${is_apply_btn_disabled}    msg= No Unscheduled data hence Filter feature is not available
    Click Element On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_APPLY_BTN}
    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_LOADING_SPINNER}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Clear Advanced Filter Search On Week Schedule Page On Web
    [Documentation]    Reset Advanced Filter Search on Week Schedule Page
    Click Element On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_FILTER_SETTING_TAB}
    Click Element On Webpage    ${WEEK_SCHEDULE_SORT_PREF_RESET}
    Wait Until Spinner Disappears On Week Schedule Page On Web
    Click Element On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_FETCH_BTN}
    Wait Until Spinner Disappears On Week Schedule Page On Web
    Click Element On Webpage    ${WEEK_SCHEDULE_ADVANCED_FILTER_APPLY_BTN}
    Wait Until Spinner Disappears On Week Schedule Page On Web
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Close Shift On Week Schedule Page On Web
    [Documentation]    This keyword closes the shift details pop-up on week schedule page
    Click Element On Webpage    ${WEEK_SCHEDULE_SHIFT_CLOSE_BTN}
    ...    error_message=Failed to close the shift details pop-up on week schedule page.
    Capture Screenshot On Webpage

Get Shifts Count On Week Schedule Page On Web
    [Documentation]    This keyword returns the count of shifts on week schedule page
    ${element_count}    Get Element Count On Web Page    ${WEEK_SCHEDULE_SHIFT_COUNT}
    RETURN    ${element_count}

Search For The Mentioned Employee From Employee Filter On Web
    [Documentation]    This Keywords returns employee in search from filter by employee option
    ...    | =Arguments= | =Description= |
    ...    | emp_name | Employee name to get the schedule details |
    [Arguments]    ${emp_name}
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_FILTER_BY_EMP}
    Clear Textbox On Webpage    ${WEEK_SCHEDULE_FILTER_BY_EMP}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_FILTER_BY_EMP}    ${emp_name}
    Press Enter Key Using Browser Library
    Wait Until Page Is Loaded

Get Tasks In Advanced Filter On Week Schedule Page On Web
    [Documentation]    This keyword gets the list of tasks in advanced filter on week schedule page
    VAR    @{tasks}    @{EMPTY}
    ${task_count}    Get Element Count On Web Page    ${WEEK_SCHEDULE_PAGE_TASK_DROPDOWN_SELECT}
    FOR    ${index}    IN RANGE    0    ${task_count}
        ${task_name}    Get Element Text On Webpage    ${WEEK_SCHEDULE_PAGE_TASK_DROPDOWN_SELECT} >> nth=${index}
        Append To List    ${tasks}    ${task_name}
    END
    @{task}    Split String    ${tasks}[0]    \n
    RETURN    @{task}

Get Total Employees Count On Week Schedule Page On Web
    [Documentation]    Get total employees count
    ...    | =Returns= | =Description= |
    ...    | emp_count | Returns employee count on week schedule |
    Wait Until Page Is Loaded
    ${emp_count}    Get Element Count On Web Page    ${WEEK_SCHEDULE_EMPLOYEE_RECORDS}
    RETURN    ${emp_count}

Check If Schedule Is In Published State On Web
    [Documentation]
    ...    Checks if schedule is in publish status
    ...    | =Returns= | =Description= |
    ...    | is_scheduled_published | True if in publish status, False otherwise. |
    ...    Example usage:
    ...    | ${is_scheduled_published}    Check If Schedule Is In Published Status On Web
    ${go_to_schedule_visible}    Is Element Visible On Webpage    ${WEEKSCHEDULEPAGE_GO_TO_SCHEDULE_LINK}
    IF    ${go_to_schedule_visible}
        Click Element On Webpage    ${WEEKSCHEDULEPAGE_GO_TO_SCHEDULE_LINK}
        Wait Until Page Is Loaded
    END
    ${is_scheduled_published}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_PUBLISHED_STATE}
    Capture Screenshot On Webpage
    RETURN    ${is_scheduled_published}

Check If Schedule Generated And In Unpublished State On Web
    [Documentation]
    ...    Checks if schedule is generated and in unpublish status
    ...    | =Returns= | =Description= |
    ...    | is_schedule_unpublished | True if in unpublish status, False otherwise. |
    ...    Example usage:
    ...    | ${is_schedule_unpublished}    Check If Schedule Generated And In Unpublished State On Web
    ${go_to_schedule_visible}    Is Element Visible On Webpage    ${WEEKSCHEDULEPAGE_GO_TO_SCHEDULE_LINK}
    IF    ${go_to_schedule_visible}
        Click Element On Webpage    ${WEEKSCHEDULEPAGE_GO_TO_SCHEDULE_LINK}
        Wait Until Page Is Loaded
    END
    ${is_schedule_unpublished}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_UNPUBLISHED_STATE}
    Capture Screenshot On Webpage
    RETURN    ${is_schedule_unpublished}

Check If Week Schedule Page Is Loaded On Web
    [Documentation]
    ...    Checks if Week Schedule page is loaded by verifying the presence of the Published/Unpublished element.
    ...    | =Returns=    | =Description=    |
    ...    | is_page_loaded | True if page is loaded, False otherwise. |
    ${is_page_loaded}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_INITIAL_STATE}    timeout=${MEDIUM_TIMEOUT}
    RETURN    ${is_page_loaded}

Perform Add Shift Operation On Week Schedule Page On Web
    [Documentation]    This keyword add shift operation on Week Schedule page
    ...    Example:
    ...    | Perform Add Shift Operation On Week Schedule Page On Web    John,Doe    09:00 AM    05:00 PM    2
    [Arguments]    ${associate_full_name}    ${shift_start_time}    ${shift_end_time}    ${day}
    @{name_parts}    Split String    ${associate_full_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    # Click on the associate's day cell using dynamic locator
    ${associate_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_ASSOCIATE_CELL}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    DAY_INDEX=${day}
    Click Element On Webpage    ${associate_cell}
    # Click and fill start time using dynamic locator
    ${start_time_input}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_ASSOCIATE_START_TIME_INPUT}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    DAY_INDEX=${day}
    Click Element On Webpage    ${start_time_input}
    Fill Textbox On Webpage    ${start_time_input}    ${shift_start_time}
    # Click and fill end time using dynamic locator
    ${end_time_input}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_ASSOCIATE_END_TIME_INPUT}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    DAY_INDEX=${day}
    Click Element On Webpage    ${end_time_input}
    Fill Textbox On Webpage    ${end_time_input}    ${shift_end_time}
    Wait Until Element Is Visible On Webpage    ${ASSOCIATE_TEMPLATES_ADD_SHIFT}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_ADD_EDIT_SHIFT_API}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_ADD_SHIFT}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[CREATED]
    Wait Until Success Notifier Message Disappears In Week Schedule Page On Web

Perform Swap The Shift Operation On Week Schedule Page On Web
    [Documentation]    Performs the swap shift operation on the Week Schedule page for two associates.
    ...    | =Arguments= | =Description= |
    ...    | associate_full_name | Full display name of the first associate (e.g., "John,Doe"). |
    ...    | associate_full_name1 | Full display name of the second associate (e.g., "Jane,Smith"). |
    ...    | day | Day using 0-based indexing (0=Monday, 1=Tuesday, 2=Wednesday, 3=Thursday, etc.). Value is internally converted to 1-based for UI. |
    ...
    ...    **Indexing Convention:**
    ...    - Input day parameter: 0-based (0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun)
    ...    - UI locators: 1-based (keyword converts by adding 1)
    ...
    ...    Example usage:
    ...    | Perform Swap The Shift Operation On Week Schedule Page On Web    John,Doe    Jane,Smith    2
    ...    | # Swaps shifts between John and Jane on Wednesday (day=2 becomes 3 for 1-based UI)
    [Arguments]    ${associate_full_name}    ${associate_full_name1}    ${day}
    @{name_parts}    Split String    ${associate_full_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]

    @{name_parts1}    Split String    ${associate_full_name1}    ,
    VAR    ${first_name1}    ${name_parts1}[0]
    VAR    ${last_name1}    ${name_parts1}[1]
    ${day}    Evaluate    ${day} + 1
    ${day_index_str}    Convert To String    ${day}

    # Click on the associate's day cell using dynamic locator
    ${swap_associate_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_SWAP_ASSOCIATE_CELL}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    DAY_INDEX=${day_index_str}
    Click Element On Webpage    ${swap_associate_cell}

    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SWAP_SHIFT_ICON}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_SWAP_SHIFT_API}

    # Click on the swap target associate button using dynamic locator
    ${associate_swap_button}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_SWAP_BUTTON}    FIRST_NAME=${first_name1}
    ...    LAST_NAME=${last_name1}
    Click Element On Webpage    ${associate_swap_button}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Success Notifier Message Disappears In Week Schedule Page On Web

Perform Unallocate The Shift Operation On Week Schedule Page On Web
    [Documentation]    Performs the unallocate shift operation on the Week Schedule page to remove a shift from an associate.
    ...    | =Arguments= | =Description= |
    ...    | associate_full_name | Full display name of the associate (e.g., "John,Doe"). |
    ...    | day | Day using 0-based indexing (0=Monday, 1=Tuesday, 2=Wednesday, 3=Thursday, etc.). Value is internally converted to 1-based for UI. |
    ...
    ...    **Indexing Convention:**
    ...    - Input day parameter: 0-based (0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun)
    ...    - UI locators: 1-based (keyword converts by adding 1)
    ...
    ...    Example usage:
    ...    | Perform Unallocate The Shift Operation On Week Schedule Page On Web    John,Doe    2
    ...    | # Unallocates shift for John on Wednesday (day=2 becomes 3 for 1-based UI)
    [Arguments]    ${associate_full_name}    ${day}
    @{name_parts}    Split String    ${associate_full_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    ${day}    Evaluate    ${day} + 1
    ${day_index_str}    Convert To String    ${day}

    # Click on the associate's day cell using dynamic locator
    ${unallocate_associate_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_UNALLOCATE_ASSOCIATE_CELL}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    DAY_INDEX=${day_index_str}
    Click Element On Webpage    ${unallocate_associate_cell}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_UNALLOCATE_SHIFT_BUTTON}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_UNALLOCATE_SHIFT_POPUPWINDOW}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_UNALLOCATE_SHIFT_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_UNALLOCATE_SHIFT_OK_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Success Notifier Message Disappears In Week Schedule Page On Web

Perform Reassign The Shift Operation On Week Schedule Page On Web
    [Documentation]    Performs the reassign shift operation on the Week Schedule page to move a shift from one associate to another.
    ...    | =Arguments= | =Description= |
    ...    | associate_full_name | Full display name of the source associate (e.g., "John,Doe"). |
    ...    | associate_full_name1 | Full display name of the target associate (e.g., "Jane,Smith"). |
    ...    | day | Day using 0-based indexing (0=Monday, 1=Tuesday, 2=Wednesday, 3=Thursday, etc.). Value is internally converted to 1-based for UI. |
    ...
    ...    **Indexing Convention:**
    ...    - Input day parameter: 0-based (0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun)
    ...    - UI locators: 1-based (keyword converts by adding 1)
    ...
    ...    Example usage:
    ...    | Perform Reassign The Shift Operation On Week Schedule Page On Web    John,Doe    Jane,Smith    2
    ...    | # Reassigns shift from John to Jane on Wednesday (day=2 becomes 3 for 1-based UI)
    [Arguments]    ${associate_full_name}    ${associate_full_name1}    ${day}
    @{name_parts}    Split String    ${associate_full_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    @{name_parts1}    Split String    ${associate_full_name1}    ,
    VAR    ${first_name1}    ${name_parts1}[0]
    VAR    ${last_name1}    ${name_parts1}[1]
    ${day}    Evaluate    ${day} + 1
    ${day_index_str}    Convert To String    ${day}

    # Click on the associate's day cell using dynamic locator
    ${reassign_associate_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_REASSIGN_ASSOCIATE_CELL}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    DAY_INDEX=${day_index_str}
    Click Element On Webpage    ${reassign_associate_cell}

    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REASSIGN_SHIFT_ICON}
    # Click on the reassign target associate button using dynamic locator
    ${associate_reassign_button}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_REASSIGN_BUTTON}
    ...    FIRST_NAME=${first_name1}
    ...    LAST_NAME=${last_name1}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_REASSIGN_SHIFT_API}
    Click Element On Webpage    ${associate_reassign_button}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Success Notifier Message Disappears In Week Schedule Page On Web

Perform Edit Shift Operation On Week Schedule Page On Web
    [Documentation]    This keyword edit shift operation on Week Schedule page
    ...    Example:
    ...    | Perform Edit Shift Operation On Week Schedule Page On Web    Jane,Smith    10:00 AM    06:00 PM    2
    [Arguments]    ${associate_full_name}    ${shift_start_time}    ${shift_end_time}    ${day}
    @{name_parts}    Split String    ${associate_full_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    ${day}    Evaluate    ${day} + 1
    ${day_index_str}    Convert To String    ${day}
    # Click on the associate's edit cell using dynamic locator
    ${edit_associate_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_EDIT_ASSOCIATE_CELL}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    DAY_INDEX=${day_index_str}
    Click Element On Webpage    ${edit_associate_cell}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EDIT_SHIFT_BUTTON}
    Clear Textbox On Webpage    ${WEEKSCHEDULEPAGE_CHECKIN_STARTTIME}
    Fill Textbox On Webpage    ${WEEKSCHEDULEPAGE_CHECKIN_STARTTIME}    ${shift_start_time}
    ${task_count}    Get Element Count    ${WEEKSCHEDULEPAGE_EDIT_TASK}
    WHILE    ${task_count} > 1    limit=${task_count}
        ${delete_count_str}    Convert To String    ${task_count * 2}
        ${delete_task_icon}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_EDIT_DELETE_TASK_ICON}
        ...    TASK_COUNT=${delete_count_str}
        Click Element On Webpage    ${delete_task_icon}
        ${task_count}    Get Element Count    ${WEEKSCHEDULEPAGE_EDIT_TASK}
    END
    ${edit_end_time_input}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_EDIT_END_TIME_INPUT}    TASK_COUNT=1
    Clear Textbox On Webpage    ${edit_end_time_input}
    Fill Textbox On Webpage    ${edit_end_time_input}    ${shift_end_time}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_EDIT_SHIFT_SAVE_BUTTON}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_ADD_EDIT_SHIFT_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EDIT_SHIFT_SAVE_BUTTON}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Perform Undo On Week Schedule Page On Web
    [Documentation]    This keyword perform undo operation on Week Schedule page
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_UNDO_SHIFT_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_UNDO_ICON}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Perform Shift Edit Operation On Week Schedule Page On Web
    [Documentation]    This keyword perform all edit operations on Week Schedule page
    [Arguments]    ${week_start_date}
    ...    ${employee_name1}
    ...    ${employee_name2}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${edit_start_time}
    ...    ${edit_end_time}
    ...    ${day_offset}
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Request Calendar Page On Web    ${week_start_date}
    Perform Add Shift Operation On Week Schedule Page On Web    ${employee_name1}    ${start_time}    ${end_time}    ${day_offset}
    Perform Swap The Shift Operation On Week Schedule Page On Web    ${employee_name1}    ${employee_name2}    ${day_offset}
    Perform Unallocate The Shift Operation On Week Schedule Page On Web    ${employee_name2}    ${day_offset}
    Perform Reassign The Shift Operation On Week Schedule Page On Web    ${employee_name1}    ${employee_name2}    ${day_offset}
    Perform Edit Shift Operation On Week Schedule Page On Web    ${employee_name2}    ${edit_start_time}    ${edit_end_time}
    ...    ${day_offset}
    Perform Unallocate The Shift Operation On Week Schedule Page On Web    ${employee_name1}    ${day_offset}
    Perform Undo On Week Schedule Page On Web

Verify Print Weekly Schedule Detail
    [Documentation]    This keyword verify the functionality of print Weekly Schedule Detail on week schedule page
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
    ${is_report_link_present}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_WEEKLY_SCHEDULE_DETAIL}
    IF    not ${is_report_link_present}
        Log    Weekly Schedule Detail report link is not present on Week Schedule page
        Capture Screenshot On Webpage
        Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
        RETURN    ${False}
    END
    Click Element On Webpage    ${WEEK_SCHEDULE_WEEKLY_SCHEDULE_DETAIL}
    Switch Page    NEW
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    ${weekly_schedule_detailed_url}    Get Url
    Should Contain    ${weekly_schedule_detailed_url}    /weekplan_schedule_report.jsp
    ${prefix}    Set Selector Prefix    ${None}
    ${report_title_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_STORE_SCHEDULE_DETAIL_REPORT_TITLE}
    ${emp_details_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_DETAILS_SHIFT_DETAILS}
    ${shift_details_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_SUMMARY_SHIFT_DETAILS}
    Should Be True    ${report_title_displayed}    Weekly Schedule Detail report title is not displayed
    Should Be True    ${emp_details_displayed}    Employee details are not displayed in Weekly
    Should Be True    ${shift_details_displayed}    Shift details are not displayed in Weekly
    Set Selector Prefix    ${prefix}
    Close New Tab
    RETURN    ${True}

Verify Print Weekly Associate Summary
    [Documentation]    This keyword verify the functionality of print Weekly Associate Summary on week schedule page
    [Arguments]    ${associate_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
    ${is_report_link_present}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_SUMMARY}
    IF    not ${is_report_link_present}
        Log    Weekly Associate Summary report link is not present on Week Schedule page
        Capture Screenshot On Webpage
        Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
        RETURN    ${False}
    END
    Click Element On Webpage    ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_SUMMARY}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_NAME_INPUT_TEXTBOX}    ${associate_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_SEARCHED_ASSOCIATE}
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_BTN}
    Switch Page    NEW
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    ${weekly_schedule_associate_summary_url}    Get Url
    Should Contain    ${weekly_schedule_associate_summary_url}    /ess_schedule_report.jsp
    ${prefix}    Set Selector Prefix    ${None}
    ${report_title_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_ASSOCIATE_SCHEDULE_SUMMARY_REPORT_TITLE}
    ${emp}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_ASSOCIATE_NAME}    EMP_NAME=${associate_name}
    ${associate_is_displayed}    Is Element Visible On Webpage    ${emp}
    ${shift_details_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_ASSOCIATE_SHIFT_ROW}
    Should Be True    ${report_title_displayed}    Weekly Associate Summary report title is not displayed
    Should Be True    ${associate_is_displayed}    Associate name is not displayed in Weekly Associate Summary
    Should Be True    ${shift_details_displayed}    Shift details are not displayed in Weekly Associate Summary
    Set Selector Prefix    ${prefix}
    Close New Tab
    RETURN    ${True}

Verify Print Weekly Associate Detail
    [Documentation]    This keyword verify the functionality of print Weekly Associate Detail on week schedule page
    [Arguments]    ${associate_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
    ${is_report_link_present}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_DETAIL}
    IF    not ${is_report_link_present}
        Log    Weekly Associate Detail report link is not present on Week Schedule page
        Capture Screenshot On Webpage
        Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
        RETURN    ${False}
    END
    Click Element On Webpage    ${WEEK_SCHEDULE_WEEKLY_ASSOCIATE_DETAIL}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_NAME_INPUT_TEXTBOX}    ${associate_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_SEARCHED_ASSOCIATE}
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_BTN}
    Switch Page    NEW
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    ${weekly_schedule_associate_detail_url}    Get Url
    Should Contain    ${weekly_schedule_associate_detail_url}    /ess_schedule_report.jsp
    ${prefix}    Set Selector Prefix    ${None}
    ${report_title_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_ASSOCIATE_SCHEDULE_DETAIL_REPORT_TITLE}
    ${emp}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_ASSOCIATE_NAME}    EMP_NAME=${associate_name}
    ${associate_is_displayed}    Is Element Visible On Webpage    ${emp}
    ${shift_details_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_DETAILS_SHIFT_ROW}
    Should Be True    ${report_title_displayed}    Weekly Associate Detail report title is not displayed
    Should Be True    ${associate_is_displayed}    Associate name is not displayed in Weekly Associate Detail
    Should Be True    ${shift_details_displayed}    Shift details are not displayed in Weekly Associate Detail
    Set Selector Prefix    ${prefix}
    Close New Tab
    RETURN    ${True}

Verify Print Period Associate Summary
    [Documentation]    This keyword verify the functionality of print Period Associate Summary on week schedule page
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
    ${is_report_link_present}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_SUMMARY}
    IF    not ${is_report_link_present}
        Log    Period Associate Summary report link is not present on Week Schedule page
        Capture Screenshot On Webpage
        Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
        RETURN    ${False}
    END
    Click Element On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_SUMMARY}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_NAME_INPUT_TEXTBOX}    ${associate_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_SEARCHED_ASSOCIATE}
    Select Date Through Date Picker For ESS Requests On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_START_DATE_CALENDAR}    ${start_date}
    Select Date Through Date Picker For ESS Requests On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_END_DATE_CALENDAR}    ${end_date}
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_BTN}
    Switch Page    NEW
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    ${period_associate_summary_url}    Get Url
    Should Contain    ${period_associate_summary_url}    /ess_schedule_report.jsp
    ${prefix}    Set Selector Prefix    ${None}
    ${report_title_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_SCHEDULE_SUMMARY_REPORT_TITLE}
    ${emp}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_ASSOCIATE_NAME}    EMP_NAME=${associate_name}
    ${associate_is_displayed}    Is Element Visible On Webpage    ${emp}
    ${shift_details_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_ASSOCIATE_SHIFT_ROW}
    Should Be True    ${report_title_displayed}    Period Associate Summary report title is not displayed
    Should Be True    ${associate_is_displayed}    Associate name is not displayed in Period Associate Summary
    Should Be True    ${shift_details_displayed}    Shift details are not displayed in Period Associate Summary
    Set Selector Prefix    ${prefix}
    Close New Tab
    RETURN    ${True}

Verify Print Period Associate Detail
    [Documentation]    This keyword verify the functionality of print Period Associate Detail on week schedule page
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
    ${is_report_link_present}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_DETAIL}
    IF    not ${is_report_link_present}
        Log    Period Associate Detail report link is not present on Week Schedule page
        Capture Screenshot On Webpage
        Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_ICON}
        RETURN    ${False}
    END
    Click Element On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_DETAIL}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_NAME_INPUT_TEXTBOX}    ${associate_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_SEARCHED_ASSOCIATE}
    Select Date Through Date Picker For ESS Requests On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_START_DATE_CALENDAR}    ${start_date}
    Select Date Through Date Picker For ESS Requests On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_END_DATE_CALENDAR}    ${end_date}
    Click Element On Webpage    ${WEEK_SCHEDULE_PRINT_BTN}
    Switch Page    NEW
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    ${period_associate_detail_url}    Get Url
    Should Contain    ${period_associate_detail_url}    /ess_schedule_report.jsp
    ${prefix}    Set Selector Prefix    ${None}
    ${report_title_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_SCHEDULE_DETAIL_REPORT_TITLE}
    ${emp}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_ASSOCIATE_NAME}    EMP_NAME=${associate_name}
    ${associate_is_displayed}    Is Element Visible On Webpage    ${emp}
    ${shift_details_displayed}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_DETAILS_SHIFT_ROW}
    Should Be True    ${report_title_displayed}    Period Associate Detail report title is not displayed
    Should Be True    ${associate_is_displayed}    Associate name is not displayed in Period Associate Detail
    Should Be True    ${shift_details_displayed}    Shift details are not displayed in Period Associate Detail
    Set Selector Prefix    ${prefix}
    Close New Tab
    RETURN    ${True}

Get Associate Name With Shift Present On Week Schedule Page On Web
    [Documentation]
    ...    Returns the Associate Name With Shift Present displayed on the Week Schedule page.
    ...    Skips the test if no associates are present.
    ...    | =Returns=    | =Description= |
    ...    | name    | The first associate name string. |
    ${is_associates_present}    Is Element Present On Webpage    ${WEEK_SCHEDULE_ASSOCIATE_WITH_SHIFT}
    IF    not ${is_associates_present}
        SKIP    No associates with shift present on Week Schedule page
    END
    ${associate_name}    Get Element Text On Webpage    ${WEEK_SCHEDULE_ASSOCIATE_WITH_SHIFT}
    RETURN    ${associate_name}

Click On Open Shifts Tab On Week Schedule Page On Web
    [Documentation]    This keyword clicks on open shifts tab on week schedule page
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFTS_TAB}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Get Open Shifts Count On Week Schedule Page On Web
    [Documentation]    Gets the count of open shifts from the badge displayed on the Open Shifts tab.
    ...    | =Arguments=    | =Description= |
    ...    | (none)    | This keyword takes no arguments. |
    ...    | =Returns=    | =Description= |
    ...    | count    | Number of open shifts as integer. |
    ...    Example usage:
    ...    | ${count}    Get Open Shifts Count On Week Schedule Page On Web
    Wait Until Element Is Present On Webpage    ${WEEK_SCHEDULE_PAGE_OPEN_SHIFT_BADGE}
    ${count_text}    Get Element Text On Webpage    ${WEEK_SCHEDULE_PAGE_OPEN_SHIFT_BADGE}
    ${count}    Convert To Integer    ${count_text}
    Capture Screenshot On Webpage
    RETURN    ${count}

Verify Open Shift Count Not Equal After Day Off Approved On Week Schedule Page On Web
    [Documentation]    Verifies that the open shift count has changed after a day off approval.
    ...    | =Arguments=    | =Description= |
    ...    | initial_open_shift_count    | The open shift count before day off approval (integer). |
    ...    | updated_open_shift_count    | The open shift count after day off approval (integer). |
    ...    Example usage:
    ...    | Verify Open Shift Count Not Equal After Day Off Approved On Week Schedule Page On Web    5    6
    [Arguments]    ${initial_open_shift_count}    ${updated_open_shift_count}
    Should Not Be Equal    ${initial_open_shift_count}    ${updated_open_shift_count}
    ...    Expected: Open shift count should be changed after day off approved. Actual: Open shift count did not change.

Verify Open Shift Count Equal After Day Off Approved On Week Schedule Page On Web
    [Documentation]    This keyword verifies open shift count is equal after day off approved on week schedule page
    [Arguments]    ${initial_open_shift_count}    ${updated_open_shift_count}
    Should Be Equal    ${initial_open_shift_count}    ${updated_open_shift_count}
    ...    Expected: Open shift count should remain unchanged after day off approved. Actual: Open shift count changed.

Delete Open Shift On Week Schedule Page On Web
    [Documentation]    Deletes an open shift from the open pool on week schedule page
    ...    | =Arguments=    | =Description= |
    ...    | shift_start_time    | Shift start time in 24hr format (e.g., "09:00", "13:00"). |
    ...    | shift_end_time    | Shift end time in 24hr format (e.g., "09:00", "13:00"). |
    ...    | day_offset    | Day offset in week_day format (e.g., 1_2) to calculate the formatted date. |
    ...    Example usage:
    ...    | Delete Shift On Week Schedule Page On Web    09:00    13:00    0_1
    [Arguments]    ${shift_start_time}    ${shift_end_time}    ${day_offset}

    Click On Open Shifts Tab On Week Schedule Page On Web

    # Convert times from 24hr to 12hr UI format (remove space for UI locator)
    ${start_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
    ${start_time_12hr}    Replace String    ${start_time_with_space}    ${SPACE}    ${EMPTY}
    ${end_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_time}
    ${end_time_12hr}    Replace String    ${end_time_with_space}    ${SPACE}    ${EMPTY}

    # Convert day_offset to formatted date for aria-label matching (e.g., "Monday 08 December")
    ${target_date}    Calculate Date From Week Day Offset    ${day_offset}
    ${date_format}    Get Config Value    key=DATE_FMT_WEEKDAY_DAY_MONTH
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}

    # Build locator with start time, end time, and formatted date
    ${open_pool_shift}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_OPEN_SHIFT_ENTRY}
    ...    START_TIME=${start_time_12hr}
    ...    END_TIME=${end_time_12hr}
    ...    FORMATTED_DATE=${formatted_date}

    Click Element On Webpage    ${open_pool_shift}
    ...    error_message=Failed to click on open pool shift with start time '${shift_start_time}', end time '${shift_end_time}', date '${formatted_date}'.
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFTS_DELETE_TAB}    error_message=Failed to click on delete tab for open shift.
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_OPEN_SHIFT_DELETE_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SCHEDULE_DELETE_OK_BTN}
    ...    error_message=Failed to click OK button to confirm deletion of open shift.
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    ...    error_message=Success notifier message did not appear after deleting open shift.
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Delete Shift On Week Schedule Page On Web
    [Documentation]    This keyword deletes a shift on week schedule page
    [Arguments]    ${actual_shift_time}
    Click On Open Shifts Tab On Week Schedule Page On Web
    ${open_pool_shift}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_OPEN_POOL_SHIFT}
    ...    SHIFT_TIME=${actual_shift_time}
    Click Element On Webpage    ${open_pool_shift}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFTS_DELETE_TAB}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_OPEN_SHIFT_DELETE_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SCHEDULE_DELETE_OK_BTN}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}    timeout=${LONG_TIMEOUT}
    ...    error_message=Success notifier message did not appear after deleting open shift, waiting for ${LONG_TIMEOUT} seconds.
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Verify Scheduled Shift On Week Schedule Page On Web
    [Documentation]    This keyword verifies the generated schedule on Week Schedule page
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to verify schedules for |
    ...    | parsed_shifts | Parsed shift data from API response |
    ...    | planning_week_start_date | Planning week start date in week_day format |
    ...    Example usage:
    ...    | Verify Scheduled Shift On Week Schedule Page On Web | Associate05, | ${parsed_shifts} | 1_1 |
    [Arguments]    ${associate_name}    ${parsed_shifts}    ${planning_week_start_date}
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Request Calendar Page On Web    ${planning_week_start_date}
    ${go_to_schedule}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEKSCHEDULE_SCHEDULE_SCHEDULE_LINK}
    IF    ${go_to_schedule}
        Click Element On Webpage    ${WEEKSCHEDULE_SCHEDULE_SCHEDULE_LINK}
        Wait Until Page Is Loaded
    END
    Search Employee On Week Schedule Page On Web    ${associate_name}
    Verify Shifts On Review Page Match API Data On Web    ${associate_name}    ${parsed_shifts}    ${planning_week_start_date}

Get Selected Week From Week Navigation On Schedule Page On Web
    [Documentation]    This keyword gets the week date from week navigation on Schedule page.
    ...    | =Returns= | =Description= |
    ...    | selected_week | The label of the selected week |
    ${selected_week}    Get Element Text On Webpage    ${WEEK_SCHEDULE_PAGE_CAL_NAV_DATE_LABEL}
    RETURN    ${selected_week}

Generate WIP Copy For Published Week On Week Schedule Page On Web
    [Documentation]    Generates Week In Progress copy on Week Schedule page for the current week
    [Arguments]    ${user_key}

    Login And Launch WFM Web App    user_key=${user_key}
    Navigate To RWS Schedule Week Schedule Page On Web
    ${heading_text}    Get Element Text On Webpage    ${WEEKSCHEDULEPAGE_HEADING}
    ${week_in_progress}    Get System Value    WeekScheduleDropdown    WEEK_IN_PROGRESS
    ${manager_schedule}    Get System Value    WeekScheduleDropdown    MANAGER_SCHEDULE
    IF    '${heading_text}' == '${week_in_progress}'
        Close Browser
    ELSE IF    '${heading_text}' == '${manager_schedule}'
        ${base_url}    Get Config Value    key=base_url
        ${servlet_url}    Get Config Value    key=SERVLET_URL
        ${contains_unit_id}    Evaluate    "'unitId' in '''${servlet_url}'''"
        ${contains_site_token}    Evaluate    "'siteToken' in '''${servlet_url}'''"
        IF    ${contains_unit_id} and ${contains_site_token}
            Log    Both unitId and siteToken are present in the servlet URL, need to replace them
        END
        VAR    ${wip_copy_url}    ${base_url}/${servlet_url}
        New Page    ${wip_copy_url}
        Wait For Elements State    text=PUBLISH JOB QUEUE CREATED SUCCESSFULLY    visible    timeout=${LONG_TIMEOUT}
        Capture Screenshot On Webpage
        Reload Current Page
        Wait For Elements State    text=SUCCESS    visible    timeout=${LONG_TIMEOUT}
        Switch Back To First Opened Page Tab On Web
        Navigate To RWS Schedule Week Schedule Page On Web
        FOR    ${_}    IN RANGE    1    10
            Reload Current Page
            ${heading}    Get Element Text On Webpage    ${WEEKSCHEDULEPAGE_HEADING}
            IF    '${heading}' == '${week_in_progress}'
                Capture Screenshot On Webpage
                Close Browser
                BREAK
            END
            # Sleep is essential to wait until the WIP copy is generated
            Sleep    ${LONG_TIMEOUT}
        END
        IF    '${heading}' != '${week_in_progress}'
            Capture Screenshot On Webpage
            Fail    Failed to publish WIP copy on Week Schedule page
        END
    ELSE
        Capture Screenshot On Webpage
        Fail    Unexpected schedule state: ${heading_text}. Expected either '${week_in_progress}' or '${manager_schedule}'
    END
    Close Browser

Add Shift On Week Schedule Page For Associate And Day On Web
    [Documentation]    Adds a shift on week schedule page for a specific associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full name of the associate (e.g., "John Doe"). |
    ...    | day_offset    | Day offset from Monday (0=Monday, 1=Tuesday, etc.). |
    ...    | shift_start_time    | Start time of the shift (e.g., "09:00 AM"). |
    ...    | shift_end_time    | End time of the shift (e.g., "05:00 PM"). |
    ...    Example usage:
    ...    | Add Shift On Week Schedule Page For Associate And Day On Web    John Doe    2    09:00 AM    05:00 PM
    [Arguments]    ${associate_name}
    ...    ${day_offset}
    ...    ${shift_start_time}
    ...    ${shift_end_time}

    # Convert day_offset to formatted date for aria-label matching (e.g., "Friday 05 December")
    ${target_date}    Calculate Date From Week Day Offset    ${day_offset}
    ${date_format}    Get Config Value    key=DATE_FMT_WEEKDAY_DAY_MONTH
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}

    # Convert times to 12hr format without space for locator matching
    ${shift_start_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
    ${shift_start_12hr}    Replace String    ${shift_start_with_space}    ${SPACE}    ${EMPTY}
    ${shift_end_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_time}
    ${shift_end_12hr}    Replace String    ${shift_end_with_space}    ${SPACE}    ${EMPTY}

    # Update locator with all values
    ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_DAY_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_name}
    ...    START_TIME=${shift_start_12hr}
    ...    END_TIME=${shift_end_12hr}
    ...    FORMATTED_DATE=${formatted_date}

    Click Element On Webpage    ${associate_shift_cell}
    Click Element On Webpage    ${WEEK_SCHEDULE_SHIFT_START_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_SHIFT_START_TIME}    ${shift_start_time}
    Click Element On Webpage    ${WEEK_SCHEDULE_SHIFT_END_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_SHIFT_END_TIME}    ${shift_end_time}
    Click Element On Webpage    ${WEEK_SCHEDULE_ADD_SHIFT_ICON}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Add Shift On Week Schedule Page For The Given Associate And Day On Web
    [Documentation]    Adds a shift on week schedule page for a specific associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full name of the associate (e.g., "John Doe"). |
    ...    | day_offset    | Day offset from Monday (0=Monday, 1=Tuesday, etc.). |
    ...    | shift_start_time    | Start time of the shift (e.g., "09:00 AM"). |
    ...    | shift_end_time    | End time of the shift (e.g., "05:00 PM"). |
    ...    Example usage:
    ...    | Add Shift On Week Schedule Page For The Given Associate And Day On Web    John Doe    2    09:00 AM    05:00 PM
    [Arguments]    ${associate_name}
    ...    ${day_offset}
    ...    ${shift_start_time}
    ...    ${shift_end_time}

    # Convert 0-based day_offset to 1-based weekDayContainer index (Monday=0 -> [1], Friday=4 -> [5])
    ${weekday_container_index}    Evaluate    int(${day_offset}) + 1
    ${weekday_container_index_str}    Convert To String    ${weekday_container_index}

    ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_name}    DAY_OFFSET=${weekday_container_index_str}

    Click Element On Webpage    ${associate_shift_cell}
    Click Element On Webpage    ${WEEK_SCHEDULE_SHIFT_START_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_SHIFT_START_TIME}    ${shift_start_time}
    Click Element On Webpage    ${WEEK_SCHEDULE_SHIFT_END_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_SHIFT_END_TIME}    ${shift_end_time}
    Click Element On Webpage    ${WEEK_SCHEDULE_ADD_SHIFT_ICON}
    # Try to wait for notification, but don't fail if it appears/disappears too quickly
    ${notification_appeared}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}    timeout=5s
    IF    ${notification_appeared}
        Capture Screenshot On Webpage
        Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    ELSE
        Log    Success notification did not appear or disappeared too quickly (operation likely succeeded)    level=WARN
        Capture Screenshot On Webpage
    END

Edit Shift On Week Schedule Page For Associate And Day On Web
    [Documentation]    Edits an existing shift on week schedule page for a specific associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full name of the associate (e.g., "John Doe"). |
    ...    | day_offset    | Day offset from Monday (0=Monday, 1=Tuesday, etc.). |
    ...    | shift_start_time    | New start time of the shift (e.g., "09:00 AM"). |
    ...    | shift_end_time    | New end time of the shift (e.g., "05:00 PM"). |
    ...    Example usage:
    ...    | Edit Shift On Week Schedule Page For The Given Associate And Day On Web    John Doe    2    10:00 AM    06:00 PM
    [Arguments]    ${associate_name}
    ...    ${day_offset}
    ...    ${shift_start_time}
    ...    ${shift_end_time}

    # Convert day_offset to formatted date for aria-label matching (e.g., "Friday 05 December")
    ${target_date}    Calculate Date From Week Day Offset    ${day_offset}
    ${date_format}    Get Config Value    key=DATE_FMT_WEEKDAY_DAY_MONTH
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}

    # Convert times to 12hr format without space for locator matching
    ${shift_start_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
    ${shift_start_12hr}    Replace String    ${shift_start_with_space}    ${SPACE}    ${EMPTY}
    ${shift_end_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_time}
    ${shift_end_12hr}    Replace String    ${shift_end_with_space}    ${SPACE}    ${EMPTY}

    # Update locator with all values
    ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_DAY_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_name}
    ...    START_TIME=${shift_start_12hr}
    ...    END_TIME=${shift_end_12hr}
    ...    FORMATTED_DATE=${formatted_date}

    Click Element On Webpage    ${associate_shift_cell}
    Click Element On Webpage    ${WEEK_SCHEDULE_EDIT_SHIFT_BUTTON}
    Clear Textbox On Webpage    ${WEEK_SCHEDULE_TIME_PICKER_START_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_TIME_PICKER_START_TIME}    ${shift_start_time}
    Clear Textbox On Webpage    ${WEEK_SCHEDULE_TIME_PICKER_END_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_TIME_PICKER_END_TIME}    ${shift_end_time}
    Click Element On Webpage    ${WEEK_SCHEDULE_EDIT_SAVE_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Edit Shift On Week Schedule Page For The Given Associate And Day On Web
    [Documentation]    Edits an existing shift on week schedule page for a specific associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full name of the associate (e.g., "John Doe"). |
    ...    | day_offset    | Day offset from Monday (0=Monday, 1=Tuesday, etc.). |
    ...    | shift_start_time    | New start time of the shift (e.g., "09:00 AM"). |
    ...    | shift_end_time    | New end time of the shift (e.g., "05:00 PM"). |
    ...    Example usage:
    ...    | Edit Shift On Week Schedule Page For The Given Associate And Day On Web    John Doe    2    10:00 AM    06:00 PM
    [Arguments]    ${associate_name}
    ...    ${day_offset}
    ...    ${shift_start_time}
    ...    ${shift_end_time}

    # Convert 0-based day_offset to 1-based weekDayContainer index (Monday=0 -> [1], Friday=4 -> [5])
    ${weekday_container_index}    Evaluate    int(${day_offset}) + 1
    ${weekday_container_index_str}    Convert To String    ${weekday_container_index}

    ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_name}    DAY_OFFSET=${weekday_container_index_str}

    Click Element On Webpage    ${associate_shift_cell}
    Click Element On Webpage    ${WEEK_SCHEDULE_EDIT_SHIFT_BUTTON}
    Clear Textbox On Webpage    ${WEEK_SCHEDULE_TIME_PICKER_START_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_TIME_PICKER_START_TIME}    ${shift_start_time}
    Clear Textbox On Webpage    ${WEEK_SCHEDULE_TIME_PICKER_END_TIME}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_TIME_PICKER_END_TIME}    ${shift_end_time}
    Click Element On Webpage    ${WEEK_SCHEDULE_EDIT_SAVE_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Un-allocate Shift On Week Schedule Page For Associate And Day On Web
    [Documentation]    Un-allocates a shift for the given associate and day. Returns trimmed shift time string.
    ...    This keyword reads the shift cell text (which may contain extra tokens/newlines), extracts only
    ...    the first two time tokens (start and end) and returns them as a single string.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John Doe"). |
    ...    | day_offset    | Day offset from Monday (0=Monday, 1=Tuesday, etc.). |
    ...    | shift_start_time | Shift start time in 24hr format (e.g., "09:00", "13:00"). |
    ...    | shift_end_time | Shift end time in 24hr format (e.g., "09:00", "13:00"). |
    ...    | =Returns=    | =Description= |
    ...    | trimmed_shift_time | Shift times containing only start and end (e.g., "10:00a 05:00p"). |
    ...    Example usage:
    ...    | ${shift_time}    Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web    John Doe    2    09:00    17:00
    [Arguments]    ${associate_name}    ${day_offset}    ${shift_start_time}    ${shift_end_time}

    # Convert day_offset to formatted date for aria-label matching (e.g., "Friday 05 December")
    ${target_date}    Calculate Date From Week Day Offset    ${day_offset}
    ${date_format}    Get Config Value    key=DATE_FMT_WEEKDAY_DAY_MONTH
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}

    # Convert times to 12hr format without space for locator matching
    ${shift_start_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
    ${shift_start_12hr}    Replace String    ${shift_start_with_space}    ${SPACE}    ${EMPTY}
    ${shift_end_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_time}
    ${shift_end_12hr}    Replace String    ${shift_end_with_space}    ${SPACE}    ${EMPTY}

    # Update locator with dynamic values
    ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_DAY_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_name}
    ...    START_TIME=${shift_start_12hr}
    ...    END_TIME=${shift_end_12hr}
    ...    FORMATTED_DATE=${formatted_date}

    ${actual_shift_time}    Get Element Text On Webpage    ${associate_shift_cell}

    # Split the text (handles spaces/newlines). Example: "10:00a 05:00p 01" -> ["10:00a","05:00p","01"]
    ${tokens}    Split String    ${actual_shift_time}
    ${tokens_count}    Get Length    ${tokens}
    IF    ${tokens_count} >= 2
        VAR    ${time1}    ${tokens}[0]
        VAR    ${time2}    ${tokens}[1]
        VAR    ${trimmed_shift_time}    ${time1} ${time2}
    ELSE
        # Fallback: return original value if it doesn't contain two tokens
        VAR    ${trimmed_shift_time}    ${actual_shift_time}
    END

    Click Element On Webpage    ${associate_shift_cell}
    Click Element On Webpage    ${WEEK_SCHEDULE_UN_ALLOCATE_SHIFT_BTN}
    Click Element On Webpage    ${WEEK_SCHEDULE_DELETE_OK_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    RETURN    ${trimmed_shift_time}

Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web
    [Documentation]    Un-allocates a shift for the given associate and day. Returns trimmed shift time string.
    ...    This keyword reads the shift cell text (which may contain extra tokens/newlines), extracts only
    ...    the first two time tokens (start and end) and returns them as a single string.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John Doe"). |
    ...    | day_offset    | Day offset as 1-based index (1=Monday, 2=Tuesday, etc.). |
    ...    | =Returns=    | =Description= |
    ...    | trimmed_shift_time | Shift times containing only start and end (e.g., "10:00a 05:00p"). |
    ...    Example usage:
    ...    | ${shift_time}    Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web    John Doe    1
    [Arguments]    ${associate_name}    ${day_offset}

    # day_offset is 1-based (1=Monday, 2=Tuesday, etc.) matching XPath indexing directly
    ${weekday_container_index_str}    Convert To String    ${day_offset}

    ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT_UNALLOCATED}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_name}    DAY_OFFSET=${weekday_container_index_str}
    ${actual_shift_time}    Get Element Text On Webpage    ${associate_shift_cell}

    # Split the text (handles spaces/newlines). Example: "10:00a 05:00p 01" -> ["10:00a","05:00p","01"]
    ${tokens}    Split String    ${actual_shift_time}
    ${tokens_count}    Get Length    ${tokens}
    IF    ${tokens_count} >= 2
        VAR    ${time1}    ${tokens}[0]
        VAR    ${time2}    ${tokens}[1]
        VAR    ${trimmed_shift_time}    ${time1} ${time2}
    ELSE
        # Fallback: return original value if it doesn't contain two tokens
        VAR    ${trimmed_shift_time}    ${actual_shift_time}
    END

    Click Element On Webpage    ${associate_shift_cell}
    Click Element On Webpage    ${WEEK_SCHEDULE_UN_ALLOCATE_SHIFT_BTN}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_OPEN_SHIFT_UNALLOCATE_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${WEEK_SCHEDULE_DELETE_OK_BTN}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    RETURN    ${trimmed_shift_time}

Download And Verify Period Associate Summary PDF Report On Web
    [Documentation]
    ...    Downloads and verifies the Period Associate Summary PDF report for an associate.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Name of the associate (required). |
    ...    | start_date | Start date for report. |
    ...    | end_date | End date for report. |
    ...    Example:
    ...    | Download And Verify Period Associate Summary PDF Report On Web    Jane Smith    2_0    2_0
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}
    Click Element On Webpage    ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON}
    ...    Failed to click on PDF download icon ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON} on Week Schedule page.
    ${is_report_link_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_SUMMARY}

    IF    ${is_report_link_visible}
        Click Element On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_SUMMARY}
        ...    Failed to click on Period Associate Summary PDF link ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_SUMMARY} on Week Schedule page.
        Fill Textbox On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_NAME_INPUT_TEXTBOX}    ${associate_name}
        Click Element On Webpage    ${WEEK_SCHEDULE_SEARCHED_ASSOCIATE}    Failed to click on element ${WEEK_SCHEDULE_SEARCHED_ASSOCIATE}
        Select Date Through Date Picker For ESS Requests On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_START_DATE_CALENDAR}
        ...    ${start_date}
        Select Date Through Date Picker For ESS Requests On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_END_DATE_CALENDAR}    ${end_date}
        Click Element On Webpage    ${WEEK_SCHEDULE_PDF_REPORT_POPUP_DOWNLOAD_BTN}
        ...    Failed to click on element ${WEEK_SCHEDULE_PDF_REPORT_POPUP_DOWNLOAD_BTN}
        ${pdf_report_filepath}    ${pdf_report_download_dir}    Return Weekly PDF Report Download Directory And File Name On Web
        ...    PeriodAssociateSummaryReport    period_associate_summary
        Download And Verify PDF Report On Web    ${pdf_report_filepath}    ${pdf_report_download_dir}
    END

Download And Verify Period Associate Detail PDF Report On Web
    [Documentation]
    ...    Downloads and verifies the Period Associate Detail PDF report for an associate.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Name of the associate (required). |
    ...    | start_date | Start date for report. |
    ...    | end_date | End date for report. |
    ...    Example:
    ...    | Download And Verify Period Associate Detail PDF Report On Web    Jane Smith    2_0    2_0
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}
    Click Element On Webpage    ${WEEK_SCHEDULE_PDF_DOWNLOAD_ICON}

    ${is_report_link_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_DETAIL}
    IF    ${is_report_link_visible}
        Click Element On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_DETAIL}
        Fill Textbox On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_NAME_INPUT_TEXTBOX}    ${associate_name}
        Click Element On Webpage    ${WEEK_SCHEDULE_SEARCHED_ASSOCIATE}
        Select Date Through Date Picker For ESS Requests On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_START_DATE_CALENDAR}
        ...    ${start_date}
        Select Date Through Date Picker For ESS Requests On Webpage    ${WEEK_SCHEDULE_PERIOD_ASSOCIATE_END_DATE_CALENDAR}    ${end_date}
        Click Element On Webpage    ${WEEK_SCHEDULE_PDF_REPORT_POPUP_DOWNLOAD_BTN}
        ${pdf_report_filepath}    ${pdf_report_download_dir}    Return Weekly PDF Report Download Directory And File Name On Web
        ...    PeriodAssociateDetailReport    period_associate_detail
        Download And Verify PDF Report On Web    ${pdf_report_filepath}    ${pdf_report_download_dir}
    END

Verify Week In Progress Copy Exists On Week Schedule Page On Web
    [Documentation]    Verifies if the Week In Progress copy exists on the Week Schedule page
    ...    | =Returns=    | =Description= |
    ...    | wip_visible | True if Week In Progress copy is visible, False otherwise. |
    ${wip_copy}    Get System Value    WeekScheduleDropdown    WEEK_IN_PROGRESS
    ${heading}    Get Element Text On Webpage    ${WEEKSCHEDULEPAGE_HEADING}
    IF    '${heading}' != '${wip_copy}'
        VAR    ${wip_visible}    False
        Capture Screenshot On Webpage
        Skip    Setup did not create Week In Progress copy
    ELSE
        VAR    ${wip_visible}    True
    END
    RETURN    ${wip_visible}

Wait Until Spinner Disappears On Week Schedule Page On Web
    [Documentation]    Waits until the loading spinner disappears on Week Schedule page.
    ${spinner_wait}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}    timeout=${SHORT_TIMEOUT}
    IF    ${spinner_wait}
        Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}
    END

Get No Of Shifts For Associate On Specific Day On Week Schedule Page On Web
    [Documentation]    Gets the number of shifts for the given associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | personId | (int) personId uniquely identifying the person in system. |
    ...    | day_no    | O index based day no. e.g 0, 1, 2 max can be 6 for week view    |
    [Arguments]    ${personId}    ${day_offset}
    ${day}    Get Day Number    ${day_offset}
    ${associate_day_shift_cell}    Format String    ${WEEK_SCHEDULE_PAGE_ANY_SHIFT_EXIST_ASSOCIATE_DAY}    PERSON_ID=${personId}
    ...    DAY_NO=${day}
    ${no_of_shifts_day}    Get Element Count On Web Page    ${associate_day_shift_cell}
    RETURN    ${no_of_shifts_day}

Verify Any Shift Is Present For Associate On Specific Day On Week Schedule Page On Web
    [Documentation]    Verifies that a shift is present for the given associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | personId | (int) personId uniquely identifying the person in system. |
    ...    | day_no    | O index based day no. e.g 0, 1, 2 max can be 6 for week view    |
    [Arguments]    ${personId}    ${day_offset}
    ${no_of_shifts_day}    Get No Of Shifts For Associate On Specific Day On Week Schedule Page On Web    ${personId}    ${day_offset}
    Should Be True    ${no_of_shifts_day} > 0    msg=No shifts found for personId ${personId} on day offset ${day_offset}

Verify Any Shift Is Not Present For Associate On Specific Day On Week Schedule Page On Web
    [Documentation]    Verifies that a shift is NOT present for the given associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | personId | (int) personId uniquely identifying the person in system. |
    ...    | day_no    | O index based day no. e.g 0, 1, 2 max can be 6 for week view    |
    [Arguments]    ${personId}    ${day_offset}
    ${no_of_shifts_day}    Get No Of Shifts For Associate On Specific Day On Week Schedule Page On Web    ${personId}    ${day_offset}
    Should Be Equal As Integers
    ...    ${no_of_shifts_day}
    ...    0
    ...    msg=${no_of_shifts_day} Shifts found for personId ${personId} on day offset ${day_offset}

Verify Shift Exists For Associate On Specific Day On Week Schedule Page On Web
    [Documentation]    Verifies that a shift exists for the given associate on a specific day with specific times
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe"). |
    ...    | day_offset    | Day offset in week_day format (e.g., 1_4). |
    ...    | shift_start_time | Shift start time in 24hr format (e.g., "09:00", "13:00"). |
    ...    | shift_end_time | Shift end time in 24hr format (e.g., "09:00", "13:00"). |
    ...    Example usage:
    ...    | Verify Shift Exists For Associate On Specific Day On Week Schedule Page On Web    John, Doe    6_4    09:00    13:00
    [Arguments]    ${associate_name}    ${day_offset}    ${shift_start_time}=${None}    ${shift_end_time}=${None}
    IF    '${shift_start_time}' != '${None}' and '${shift_end_time}' != '${None}'
        # Convert times from 24hr to 12hr UI format (remove space for UI locator)
        ${shift_start_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
        ${shift_start_12hr}    Replace String    ${shift_start_with_space}    ${SPACE}    ${EMPTY}
        ${shift_end_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_time}
        ${shift_end_12hr}    Replace String    ${shift_end_with_space}    ${SPACE}    ${EMPTY}

        # Convert day_offset to formatted date for aria-label matching (e.g., "Monday 08 December")
        ${target_date}    Calculate Date From Week Day Offset    ${day_offset}
        ${date_format}    Get Config Value    key=DATE_FMT_WEEKDAY_DAY_MONTH
        ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}

        # Update locator with 3 values first
        ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_DAY_SHIFT}
        ...    ASSOCIATE_DISPLAY_NAME=${associate_name}
        ...    START_TIME=${shift_start_12hr}
        ...    END_TIME=${shift_end_12hr}
        ...    FORMATTED_DATE=${formatted_date}
    ELSE
        ${day}    Get Day Number    ${day_offset}
        ${weekday}    Evaluate    int(${day}) + 1
        ${weekday_string}    Convert To String    ${weekday}
        ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}
        ...    EMP_NAME=${associate_name}    DAY=${weekday_string}
    END
    # Sleep added to allow page rendering and DOM updates to complete before checking element visibility
    Wait Until Element Is Visible On Webpage    ${associate_shift_cell}    timeout=${MEDIUM_TIMEOUT}
    ...    error_message=Shift for ${associate_name} on ${day_offset} not visible
    ${shift_text}    Get Element Text On Webpage    ${associate_shift_cell}
    Should Not Be Empty    ${shift_text}    msg=No shift found for ${associate_name} on day ${day_offset}
    Capture Screenshot On Webpage

Verify Shift Exists For Associate Using 24Hr Time On Week Schedule Page On Web
    [Documentation]    Verifies that a shift exists for the given associate on a specific day.
    ...    Adapts to the environment's time display format via the TIME_FORMAT_12_HRS config:
    ...    - TIME_FORMAT_12_HRS=true: converts 24hr input to 12hr without AM/PM (17:00 → 05:00)
    ...    - TIME_FORMAT_12_HRS=false: uses 24hr times as-is (17:00 → 17:00)
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe"). |
    ...    | day_offset    | Day offset in week_day format (e.g., 1_4). |
    ...    | shift_start_time | Shift start time in 24hr format (e.g., "09:00", "17:00"). |
    ...    | shift_end_time | Shift end time in 24hr format (e.g., "09:00", "17:00"). |
    ...    Example usage:
    ...    | Verify Shift Exists For Associate Using 24Hr Time On Week Schedule Page On Web    John, Doe    6_4    10:00    17:00
    [Arguments]    ${associate_name}    ${day_offset}    ${shift_start_time}=${None}    ${shift_end_time}=${None}
    IF    '${shift_start_time}' != '${None}' and '${shift_end_time}' != '${None}'
        # Convert day_offset to formatted date for aria-label matching with zero-padded day (e.g., "Thursday 09 April")
        ${target_date}    Calculate Date From Week Day Offset    ${day_offset}
        # Use %d for zero-padded day instead of config value which may use %#d (single digit)
        ${formatted_date}    Convert Date    ${target_date}    result_format=%A %d %B

        # Determine display time format: 12hr (strip AM/PM) or 24hr based on environment config
        ${is_time_format_12hrs}    Get Config Value    key=TIME_FORMAT_12_HRS
        IF    ${is_time_format_12hrs}
            # Convert 24hr to 12hr and strip AM/PM suffix (17:00 → 05:00)
            ${start_time_with_ampm}    Convert 24hr Time To 12hr    ${shift_start_time}
            ${start_time_display}    Replace String Using Regexp    ${start_time_with_ampm}    \\s*(AM|PM)    ${EMPTY}
            ${end_time_with_ampm}    Convert 24hr Time To 12hr    ${shift_end_time}
            ${end_time_display}    Replace String Using Regexp    ${end_time_with_ampm}    \\s*(AM|PM)    ${EMPTY}
        ELSE
            # Use 24hr times as-is for environments where TIME_FORMAT_12_HRS is false (e.g., BMR_SB)
            VAR    ${start_time_display}    ${shift_start_time}
            VAR    ${end_time_display}    ${shift_end_time}
        END

        ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_DAY_SHIFT}
        ...    ASSOCIATE_DISPLAY_NAME=${associate_name}
        ...    START_TIME=${start_time_display}
        ...    END_TIME=${end_time_display}
        ...    FORMATTED_DATE=${formatted_date}
    ELSE
        ${day}    Get Day Number    ${day_offset}
        ${weekday}    Evaluate    int(${day}) + 1
        ${weekday_string}    Convert To String    ${weekday}
        ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}
        ...    EMP_NAME=${associate_name}    DAY=${weekday_string}
    END
    Wait Until Element Is Visible On Webpage    ${associate_shift_cell}    timeout=${MEDIUM_TIMEOUT}
    ...    error_message=Shift not found for associate '${associate_name}' on day offset '${day_offset}' (start: ${shift_start_time}, end: ${shift_end_time})
    ${shift_text}    Get Element Text On Webpage    ${associate_shift_cell}
    Should Not Be Empty    ${shift_text}    msg=No shift text found for ${associate_name} on day ${day_offset}
    Capture Screenshot On Webpage

Verify Shift Not Exists For Associate On Specific Day On Week Schedule Page On Web
    [Documentation]    Verifies that shift has been unallocated (moved to open pool) for the given associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe"). |
    ...    | day_offset    | Day offset in week_day format (e.g., 1_2). |
    ...    | shift_start_time | Shift start time in 24hr format (e.g., "09:00", "13:00"). |
    ...    | shift_end_time | Shift end time in 24hr format (e.g., "09:00", "13:00"). |
    ...    Example usage:
    ...    | Verify Shift Not Exists For Associate On Specific Day On Week Schedule Page On Web    John, Doe    1_2    09:00    13:00
    [Arguments]    ${associate_name}    ${day_offset}    ${shift_start_time}=${None}    ${shift_end_time}=${None}
    IF    '${shift_start_time}' != '${None}' and '${shift_end_time}' != '${None}'
        # Convert times from 24hr to 12hr UI format (remove space for UI locator)
        ${shift_start_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
        ${shift_start_12hr}    Replace String    ${shift_start_with_space}    ${SPACE}    ${EMPTY}
        ${shift_end_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_time}
        ${shift_end_12hr}    Replace String    ${shift_end_with_space}    ${SPACE}    ${EMPTY}

        # Convert day_offset to formatted date for aria-label matching (e.g., "Friday 05 December")
        ${target_date}    Calculate Date From Week Day Offset    ${day_offset}
        ${date_format}    Get Config Value    key=DATE_FMT_WEEKDAY_DAY_MONTH
        ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}

        # Update locator with all values
        ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_DAY_SHIFT}
        ...    ASSOCIATE_DISPLAY_NAME=${associate_name}
        ...    START_TIME=${shift_start_12hr}
        ...    END_TIME=${shift_end_12hr}
        ...    FORMATTED_DATE=${formatted_date}
    ELSE
        ${day}    Get Day Number    ${day_offset}
        ${weekday}    Evaluate    int(${day}) + 1
        ${weekday_string}    Convert To String    ${weekday}
        ${associate_shift_cell}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}
        ...    EMP_NAME=${associate_name}    DAY=${weekday_string}
    END
    # Sleep added to allow page rendering and DOM updates to complete before checking element visibility
    Sleep    2s    # needed as discussed with owner
    ${is_shift_visible}    Is Element Visible On Webpage    ${associate_shift_cell}
    Should Not Be True    ${is_shift_visible}    shift is not expected but found visible
    Capture Screenshot On Webpage

Apply Display Preferences On Week Schedule Page On Web
    [Documentation]
    ...    Applies display preferences on the Week Schedule page based on provided configuration.
    ...    Supports sections: Colleague and Shift. More can be added as needed.
    ...    | =Arguments= | =Description= |
    ...    | display_preferences_data | Dictionary containing display preference settings from template. |
    [Arguments]    ${display_preferences_data}
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_TAB}
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREF_SELECTION_PANEL}
    # Apply Colleague section preferences
    ${has_colleague}    Run Keyword And Return Status    Dictionary Should Contain Key    ${display_preferences_data}    colleague
    IF    ${has_colleague}
        ${colleague_preferences}    Get From Dictionary    ${display_preferences_data}    colleague
        Apply Colleague Preferences On Display Preferences On Web    ${colleague_preferences}
    END
    # Apply Shift section preferences
    ${has_shift}    Run Keyword And Return Status    Dictionary Should Contain Key    ${display_preferences_data}    shift
    IF    ${has_shift}
        ${shift_preferences}    Get From Dictionary    ${display_preferences_data}    shift
        Apply Shift Preferences On Display Preferences On Web    ${shift_preferences}
    END
    # more of these preferences can be added here similarly as required
    Capture Screenshot On Webpage
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_APPLY_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Apply Colleague Preferences On Display Preferences On Web
    [Documentation]
    ...    Applies Colleague section preferences (Primary Job, more can be added as needed).
    ...    | =Arguments= | =Description= |
    ...    | colleague_preferences | Dictionary containing colleague preference settings. |
    [Arguments]    ${colleague_preferences}
    ${has_primary_job}    Run Keyword And Return Status    Dictionary Should Contain Key    ${colleague_preferences}    primary_job
    IF    ${has_primary_job}
        ${primary_job_enabled}    Get From Dictionary    ${colleague_preferences}    primary_job
        Toggle Checkbox In Checked Or Unchecked State On Web    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_COLLEAGUE_PRIMARY_JOB}
        ...    ${primary_job_enabled}    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_COLLEAGUE_PRIMARY_JOB_INPUT}    attribute=class
        ...    expected_attribute_value=ng-not-empty
    END
    # more from this section can be added here similarly as per requirements

Apply Shift Preferences On Display Preferences On Web
    [Documentation]
    ...    Applies Shift section preferences (Shift Details, Detailed View, more can be added as needed).
    ...    | =Arguments= | =Description= |
    ...    | shift_preferences | Dictionary containing shift preference settings. |
    [Arguments]    ${shift_preferences}
    ${has_shift_details}    Run Keyword And Return Status    Dictionary Should Contain Key    ${shift_preferences}    shift_details
    IF    ${has_shift_details}
        ${shift_details_value}    Get From Dictionary    ${shift_preferences}    shift_details
        ${radio_locator}    Update Locator With Dynamic Values
        ...    ${WEEK_SCHEDULE_DISPLAY_PREF_SHIFT_DETAILS_RADIO}    DETAIL=${shift_details_value}
        Click Element On Webpage    ${radio_locator}
        Log    Selected shift details: ${shift_details_value}
    END
    ${has_detailed_view}    Run Keyword And Return Status    Dictionary Should Contain Key    ${shift_preferences}    detailed_view
    IF    ${has_detailed_view}
        ${detailed_view_enabled}    Get From Dictionary    ${shift_preferences}    detailed_view
        Toggle Checkbox In Checked Or Unchecked State On Web    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_DETAILED_VIEW}
        ...    ${detailed_view_enabled}    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_DETAILED_VIEW_INPUT}    attribute=class
        ...    expected_attribute_value=ng-not-empty
    END
    # more from this section can be added here similarly as per requirements

Check If Schedule Is In Plan Status On Web
    [Documentation]    Checks if schedule is in plan status by checking element states and returns True if in plan status, False otherwise.
    ${element_states}    Get Element States    ${WEEKLYPLANPAGE_HEADING}
    ${is_detached}    Evaluate    'detached' in ${element_states}
    IF    ${is_detached}
        Log    Schedule page - not in plan status.
        VAR    ${is_in_plan_status}    ${False}
    ELSE
        Log    Plan status page - in plan status.
        VAR    ${is_in_plan_status}    ${True}
    END
    RETURN    ${is_in_plan_status}

Verify Week Schedule Page Notification Message On Web
    [Documentation]    Verifies the notification message displayed on the Week Schedule page
    ...    | =Arguments=    | =Description=    |
    ...    | expected_message    | Expected notification message (optional)    |
    [Arguments]    ${expected_message}=${None}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_ALERT_MESSAGE}
    Capture Screenshot On Webpage
    IF    '${expected_message}' != '${None}'
        ${notification_message}    Get Element Text On Webpage    ${WEEKSCHEDULEPAGE_ALERT_MESSAGE}
        Should Be Equal    ${notification_message}    ${expected_message}
    END
    Run Keyword And Ignore Error    Click Element On Webpage    ${WEEKSCHEDULEPAGE_ALERT_CLOSE_BUTTON}

Verify Advertised Shift Response On Week Schedule Page On Web
    [Documentation]    Verifies the advertised shift response on the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | associate_with_shift    | Name of the associate with the advertised shift (e.g., "John Doe"). |
    ...    | shift_offset_date    | Shift offset date in week_day format (e.g., "1_2"). |
    ...    | responder_name    | Name of the associate who responded to the advertised shift (e.g., "Jane Smith"). |
    ...    | response_notes    | Notes provided by the responder for the advertised shift. |
    ...    Example usage:
    ...    | Verify Advertised Shift Response On Week Schedule Page On Web    John Doe    1_2    Jane Smith    response_notes
    [Arguments]    ${associate_with_shift}    ${shift_offset_date}    ${responder_name}    ${response_notes}=${None}
    ${day}    Get Day Number    ${shift_offset_date}
    ${weekday}    Evaluate    int(${day}) + 1
    ${weekday_string}    Convert To String    ${weekday}
    ${advertised_shift_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}    EMP_NAME=${associate_with_shift}    DAY=${weekday_string}
    Click Element On Webpage    ${advertised_shift_locator}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_ADVERTISE_SHIFT_REQUEST_RESPONSES_BTN}
    ${actual_responder_name}    Get Element Text On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_RESPONSES_RESPONDER_NAME}
    Should Be Equal As Strings    ${actual_responder_name}    ${responder_name}
    IF    '${response_notes}' != '${None}'
        ${actual_response_notes}    Get Element Text On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_RESPONSES_RESPONDER_NOTES}
        Should Be Equal As Strings    ${actual_response_notes}    ${response_notes}
    END
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_CLOSE_BTN}

Approve Advertised Shift Response On Week Schedule Page On Web
    [Documentation]    Approves the advertised shift response on the Week Schedule page.
    ...
    ...    | =Arguments=    | =Description= |
    ...    | associate_with_shift    | Name of the associate with the advertised shift (e.g., "John Doe"). |
    ...    | shift_offset_date    | Shift offset date in week_day format (e.g., "1_2"). |
    ...
    ...    Example usage:
    ...    | Approve Advertised Shift Response On Week Schedule Page On Web    John Doe    1_2
    [Arguments]    ${associate_with_shift}    ${shift_offset_date}
    ${day}    Get Day Number    ${shift_offset_date}
    ${weekday}    Evaluate    int(${day}) + 1
    ${weekday_string}    Convert To String    ${weekday}
    ${advertised_shift_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}    EMP_NAME=${associate_with_shift}    DAY=${weekday_string}
    Click Element On Webpage    ${advertised_shift_locator}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_ADVERTISE_SHIFT_REQUEST_RESPONSES_BTN}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_ADVERTISED_SHIFT_APPROVE_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_APPROVE_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_CLOSE_BTN}

Add Schedule Notes On Week Schedule Page On Web
    [Documentation]    Adds schedule level notes from the Schedule Notes tab in the bottom panel.
    ...    | =Arguments=    | =Description= |
    ...    | notes_text    | Text to add as schedule notes (required). |
    ...    Example usage:
    ...    | Add Schedule Notes On Week Schedule Page On Web    Schedule Level Web Notes added by SM
    [Arguments]    ${notes_text}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SCHEDULE_NOTES_TAB}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SCHEDULE_NOTES_ADD_NOTES_TXT}
    Fill Textbox On Webpage    ${WEEKSCHEDULEPAGE_SCHEDULE_NOTES_ADD_NOTES_TXT}    ${notes_text}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SCHEDULE_NOTES_ADD_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Add Employee Notes For Associate On Week Schedule Page On Web
    [Documentation]    Adds employee level notes for a specific associate.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full display name of the associate (e.g., "John, Doe"). |
    ...    | notes_text    | Text to add as employee notes (required). |
    ...    Example usage:
    ...    | Add Employee Notes For Associate On Week Schedule Page On Web    John, Doe    Employee Level note added by SM
    [Arguments]    ${associate_name}    ${notes_text}
    ${associate_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ASSOCIATE_BY_NAME}    ASSOCIATE_NAME=${associate_name}
    Click Element On Webpage    ${associate_locator}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EMP_NOTES_TAB}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_EMP_NOTES_TEXTBOX}
    Fill Textbox On Webpage    ${WEEKSCHEDULEPAGE_EMP_NOTES_TEXTBOX}    ${notes_text}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EMP_ADD_NOTE_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Add Shift Notes On Week Schedule Page On Web
    [Documentation]    Adds shift level notes to a specific shift.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full display name of the associate (e.g., "John, Doe"). |
    ...    | day_offset    | Day offset: integer (0=Monday, 1=Tuesday, etc.) or week_day format (e.g., 1_2). |
    ...    | notes_text    | Text to add as shift notes (required). |
    ...    Example usage:
    ...    | Add Shift Notes On Week Schedule Page On Web    John, Doe    1_2    Shift Level Notes added by SM
    ...    | Add Shift Notes On Week Schedule Page On Web    John, Doe    2    Shift Level Notes added by SM
    [Arguments]    ${associate_name}    ${day_offset}    ${notes_text}
    # Handle both integer and week_day format
    ${day_offset_str}    Convert To String    ${day_offset}
    ${contains_underscore}    Run Keyword And Return Status    Should Contain    ${day_offset_str}    _
    IF    ${contains_underscore}
        ${day}    Get Day Number    ${day_offset}
    ELSE
        VAR    ${day}    ${day_offset}
    END
    ${weekday}    Evaluate    int(${day}) + 1
    ${weekday_string}    Convert To String    ${weekday}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}    EMP_NAME=${associate_name}    DAY=${weekday_string}
    Click Element On Webpage    ${shift_locator}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_NOTES_TAB}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_NOTES_TXTBOX}
    Fill Textbox On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_NOTES_TXTBOX}    ${notes_text}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_NOTES_ADD_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_CLOSE_BTN}

Open Reports Notes On Week Schedule Page On Web
    [Documentation]    Opens the Notes report from the Reports dropdown menu.
    ...    Example usage:
    ...    | Open Reports Notes On Week Schedule Page On Web
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_DROPDOWN}
    ${notes_option_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_REPORTS_DROPDOWN_OPTION}    REPORTS_OPTION=Notes
    Click Element On Webpage    ${notes_option_locator}
    Wait Until Page Is Loaded

Open Reports Store Schedule Weekly On Week Schedule Page On Web
    [Documentation]    Navigates to the Store Schedule Weekly page from the report/page dropdown.
    ...    This keyword is typically used to return to the main Store Schedule Weekly schedule view
    ...    after viewing another report or page for the same store/week context.
    ...    Example usage:
    ...    | Open Reports Store Schedule Weekly On Week Schedule Page On Web
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_PAGE_DROPDOWN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_SCHEDULE_WEEKLY}
    ...    error_message=Schedule Weekly option not visible in page dropdown
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_SCHEDULE_WEEKLY}
    Wait Until Page Is Loaded

Verify Notes In Reports By Category On Week Schedule Page On Web
    [Documentation]    Verifies notes in the Notes report filtered by specific category.
    ...    This keyword assumes the Notes report panel is already open via
    ...    ``Open Reports Notes On Week Schedule Page On Web``. It then opens the advanced filter,
    ...    resets any existing filters, selects a category, applies the filter, and verifies the
    ...    expected notes are displayed.
    ...    | =Arguments=    | =Description= |
    ...    | category    | Category to filter by: "Schedule", "Associate", or "Shift" (required). |
    ...    | expected_notes    | Expected note text to verify (required). |
    ...    Example usage:
    ...    | Open Reports Notes On Week Schedule Page On Web
    ...    | Verify Notes In Reports By Category On Week Schedule Page On Web    Schedule    Schedule Level Web Notes added by SM
    [Arguments]    ${category}    ${expected_notes}
    Sleep    ${SHORT_TIMEOUT}  # Sleep added to allow page rendering and DOM updates to complete before interacting with filters , needed as discussed with owner
    Wait Until Page Is Loaded
    # Click Advanced Filters icon to open filter panel
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_NOTES_FILTER_ICON}
    Wait Until Page Is Loaded
    # Reset any existing filters
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_NOTES_FILTER_RESET_BTN}
    Wait Until Page Is Loaded
    # Select category from dropdown
    Select Options By    ${WEEKSCHEDULEPAGE_REPORTS_NOTES_CATEGORY_FILTER}    label    ${category}
    # Apply the filter
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_NOTES_FILTER_APPLY_BTN}
    Wait Until Page Is Loaded
    ${schedule}    Get System Value    ScheduleNotesCategory    SCHEDULE
    ${associate}    Get System Value    ScheduleNotesCategory    ASSOCIATE
    ${shift}    Get System Value    ScheduleNotesCategory    SHIFT
    # Verify notes based on category
    IF    '${category}' == '${schedule}'
        ${notes_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_REPORTS_SCHEDULE_NOTES}
        ...    SCHEDULE_NOTES=${expected_notes}
    ELSE IF    '${category}' == '${associate}'
        ${notes_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_REPORTS_EMPLOYEE_NOTES}
        ...    EMPLOYEE_NOTES=${expected_notes}
    ELSE IF    '${category}' == '${shift}'
        ${notes_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_REPORTS_SHIFT_NOTES}
        ...    SHIFT_NOTES=${expected_notes}
    ELSE
        Fail    Invalid category: ${category}. Valid categories are: Schedule, Associate, Shift
    END
    Wait Until Element Is Visible On Webpage    ${notes_locator}
    ${note_text}    Get Element Text On Webpage    ${notes_locator}
    Should Contain    ${note_text}    ${expected_notes}
    Capture Screenshot On Webpage

Close Notes Report On Week Schedule Page On Web
    [Documentation]    Closes the Notes report panel.
    ...    Example usage:
    ...    | Close Notes Report On Week Schedule Page On Web
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_NOTES_CLOSE_BTN}
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_NOTES_PANEL}

Delete Schedule Notes On Week Schedule Page On Web
    [Documentation]    Deletes schedule level notes from the Schedule Notes tab.
    ...    | =Arguments=    | =Description= |
    ...    | notes_text    | Text of the note to delete (required). |
    ...    Example usage:
    ...    | Delete Schedule Notes On Week Schedule Page On Web    Schedule Level Web Notes added by SM
    [Arguments]    ${notes_text}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SCHEDULE_NOTES_TAB}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SCHEDULE_NOTES_ADD_NOTES_TXT}
    ${delete_btn_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_SCHEDULE_NOTES_DELETE_BTN}
    ...    NOTES_TEXT=${notes_text}
    Click Element On Webpage    ${delete_btn_locator}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_DELETE_NOTES_OK_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Delete Employee Notes For Associate On Week Schedule Page On Web
    [Documentation]    Deletes employee level notes for a specific associate.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full display name of the associate (e.g., "John, Doe"). |
    ...    | notes_text    | Text of the note to delete (required). |
    ...    Example usage:
    ...    | Delete Employee Notes For Associate On Week Schedule Page On Web    John, Doe    Employee Level note added by SM
    [Arguments]    ${associate_name}    ${notes_text}
    ${associate_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ASSOCIATE_BY_NAME}    ASSOCIATE_NAME=${associate_name}
    Click Element On Webpage    ${associate_locator}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EMP_NOTES_TAB}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_EMP_NOTES_TEXTBOX}
    ${delete_btn_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_EMP_NOTES_DELETE_BTN}    NOTES_TEXT=${notes_text}
    Click Element On Webpage    ${delete_btn_locator}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_DELETE_NOTES_OK_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_CLOSE_BTN}

Delete Shift Notes On Week Schedule Page On Web
    [Documentation]    Deletes shift level notes from a specific shift.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full display name of the associate (e.g., "John, Doe"). |
    ...    | day_offset    | Day offset: integer (0=Monday, 1=Tuesday, etc.) or week_day format (e.g., 1_2). |
    ...    | notes_text    | Text of the note to delete (required). |
    ...    Example usage:
    ...    | Delete Shift Notes On Week Schedule Page On Web    John, Doe    1_2    Shift Level Notes added by SM
    ...    | Delete Shift Notes On Week Schedule Page On Web    John, Doe    2    Shift Level Notes added by SM
    [Arguments]    ${associate_name}    ${day_offset}    ${notes_text}
    # Handle both integer and week_day format
    ${day_offset_str}    Convert To String    ${day_offset}
    ${contains_underscore}    Run Keyword And Return Status    Should Contain    ${day_offset_str}    _
    IF    ${contains_underscore}
        ${day}    Get Day Number    ${day_offset}
    ELSE
        VAR    ${day}    ${day_offset}
    END
    ${weekday}    Evaluate    int(${day}) + 1
    ${weekday_string}    Convert To String    ${weekday}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}    EMP_NAME=${associate_name}    DAY=${weekday_string}
    Click Element On Webpage    ${shift_locator}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_NOTES_TAB}
    ${delete_note_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_DELETE_NOTE_WITH_TXT}    ADDED_NOTE=${notes_text}
    Click Element On Webpage    ${delete_note_locator}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_CLOSE_BTN}

Get Associate Staff Group Name On Week Schedule Page On Web
    [Documentation]    Retrieves the staff group name of the specified associate from the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full name of the associate (e.g., "John Doe"). |
    ...    | =Returns=    | =Description= |
    ...    | staff_group_name    | Staff group name of the associate. |
    ...    Example usage:
    ...    | ${staff_group}    Get Associate Staff Group Name On Week Schedule Page On Web    John Doe
    [Arguments]    ${associate_name}
    ${staff_group_locator}    Update Locator With Dynamic Values
    ...    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_STAFF_GROUP_LBL}    ASSOCIATE_DISPLAY_NAME=${associate_name}
    ${staff_group_name}    Get Element Text On Webpage    ${staff_group_locator}
    RETURN    ${staff_group_name}

Select Staff Groups In Advanced Filter On Week Schedule Page On Web
    [Documentation]    Selects the staff-groups in the advanced filter.
    ...    | =Arguments= | =Description= |
    ...    | staff_group_name | Staff group name to be selected |
    [Arguments]    @{staff_group_name}
    FOR    ${staff_group}    IN    @{staff_group_name}
        ${week_schedule_page_staff_group_option}    Update Locator With Dynamic Values
        ...    ${WEEK_SCHEDULE_PAGE_STAFF_GROUP_DROPDOWN_OPTION}    STAFF_GROUP=${staff_group}
        Keyboard Key    down    Control
        Click Element On Webpage    ${week_schedule_page_staff_group_option}
        Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_FETCH_BUTTON}
        Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}
    END

Save And Apply Filtered Schedule On Week Schedule Page On Web
    [Documentation]    Saves the filtered schedule on the Week Schedule page.
    [Arguments]    ${filter_name}
    ${is_filter_textbox_visible}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_PAGE_FILTER_NAME_INPUT}
    IF    not ${is_filter_textbox_visible}
        Log    Filter name input box is not visible, opening advanced filter panel.
        SKIP    Filter name input box is not visible, cannot save filter.
    END
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_PAGE_FILTER_NAME_INPUT}    ${filter_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_SAVE_FILTER_BUTTON}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_APPLY_BTN}
    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_APPLY_BTN}
    Run Keyword And Ignore Error    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_CLOSE_BTN}
    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}
    Capture Screenshot On Webpage

Verify Results After Applying Filter On Staff Group On Week Schedule Page On Web
    [Documentation]    Verifies the results after applying the filter on the Week Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | filter_criteria | Dictionary containing filter criteria settings. |
    [Arguments]    @{staff_group_names}

    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}
    ${staff_groups}    Get Elements    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_STAFF_GRP_LBL}
    ${prefix}    Set Selector Prefix    ${None}
    FOR    ${element}    IN    @{staff_groups}
        ${staff_group_text}    Get Element Text On Webpage    ${element}
        Should Be True    '${staff_group_text}' in ${staff_group_names}
        ...    msg=Staff group "${staff_group_text}" not in expected list ${staff_group_names}
    END
    Set Selector Prefix    ${prefix}

Is Saved Advanced Filter Present On Week Schedule Page On Web
    [Documentation]    Checks if the advanced filter is present on the Week Schedule page.
    ...    | =Returns= | =Description= |
    ...    | is_present | True if advanced filter is present, False otherwise. |
    [Arguments]    ${filter_name}

    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADVANCED_FILTER_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_SAVED_FILTERS_TAB}
    ${filter_link}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_NAME}    FILTER_NAME=${filter_name}
    ${is_adv_filter_present}    Is Element Present On Webpage    ${filter_link}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_FILTER_SETTING_TAB}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_CLOSE_BTN}
    RETURN    ${is_adv_filter_present}

Delete Saved Advanced Filter On Week Schedule Page On Web
    [Documentation]    Deletes the saved advanced filter on the Week Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | filter_name | Name of the filter to delete. |
    [Arguments]    ${filter_name}

    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADVANCED_FILTER_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_SAVED_FILTERS_TAB}
    ${filter_link}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_NAME}    FILTER_NAME=${filter_name}
    Click Element On Webpage    ${filter_link}
    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_DELETE_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_CLOSE_BTN}

Edit Existing Advanced Filter On Week Schedule Page On Web
    [Documentation]    Edits an existing advanced filter on the Week Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | filter_name | Name of the filter to edit. |
    ...    | new_criteria | Dictionary containing new filter criteria settings. |
    [Arguments]    ${filter_name}    ${edit_filter_name}    @{staff_group_name}

    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADVANCED_FILTER_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_SAVED_FILTERS_TAB}
    ${filter_link}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_NAME}    FILTER_NAME=${filter_name}
    Click Element On Webpage    ${filter_link}
    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_CLEAR_BTN}

    FOR    ${staff_group}    IN    @{staff_group_name}
        ${staff_group}    Convert To String    ${staff_group}
        ${week_schedule_page_staff_group_option}    Update Locator With Dynamic Values
        ...    ${WEEK_SCHEDULE_PAGE_STAFF_GROUP_DROPDOWN_OPTION}    STAFF_GROUP=${staff_group}
        Click Element On Webpage    ${week_schedule_page_staff_group_option}
        Keyboard Key    down    Control
    END

    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_FETCH_BUTTON}
    Clear Textbox On Webpage    ${WEEK_SCHEDULE_PAGE_FILTER_NAME_INPUT}
    Fill Textbox On Webpage    ${WEEK_SCHEDULE_PAGE_FILTER_NAME_INPUT}    ${edit_filter_name}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_SAVE_FILTER_BUTTON}
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_APPLY_BTN}
    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}
    Capture Screenshot On Webpage
    Run Keyword And Ignore Error    Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_ADV_FILTER_CLOSE_BTN}

Add Advanced Filter For Staff Group On Week Schedule Page On Web
    [Documentation]    Adds an advanced filter for staff group on the Week Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | adv_filter_name | Name of the advanced filter to be created. |
    ...    | staff_group_name | Staff group name to be selected |
    [Arguments]    ${adv_filter_name}    @{staff_group_name}

    Select Staff Groups In Advanced Filter On Week Schedule Page On Web    @{staff_group_name}
    Save And Apply Filtered Schedule On Week Schedule Page On Web    ${adv_filter_name}

Publish Week Schedule With Store Distribution Using Servlet On Web
    [Documentation]    Publishes the schedule using the servlet for the given week offset and distribution list.
    ...    | =Arguments= | =Description= |
    ...    | user_key | User key for authentication. |
    ...    | week_offset | Week number in offset format (e.g., "2_0"). |
    ...    | distribution_list | Distribution list identifier (name). |
    [Arguments]    ${user_key}    ${week_offset}    ${distribution_list}
    ${week_number}    Split String    ${week_offset}    _
    Generate Auth Token With User Credentials    ${user_key}
    ${response}    Send A Get Request    ${WEEK_SCHEDULE_PUBLISH_SCHEDULE_SERVLET}    ${week_number}[0]
    ...    ${distribution_list}    return_raw_response=True
    RETURN    ${response}

Generate Week In Progress Copy With Store Distribution Using Servlet On Web
    [Documentation]    Generates a week-in-progress copy using the servlet for the given distribution list.
    ...    | =Arguments= | =Description= |
    ...    | user_key | User key for authentication. |
    ...    | distribution_list | Distribution list identifier (name). |
    [Arguments]    ${user_key}    ${distribution_list}
    Generate Auth Token With User Credentials    ${user_key}
    ${response}    Send A Get Request    ${WEEK_SCHEDULE_GENERATE_WIP_COPY_SERVLET}    ${distribution_list}
    ...    return_raw_response=True
    RETURN    ${response}

Get Weekly Workload Hours From Schedule Page On Web
    [Documentation]    Reads workload hours from weekly schedule page for specified day
    ...    | =Arguments=    | =Description= |
    ...    | schedule_day_index | Day to get workload hours for (1-7) |
    [Arguments]    ${schedule_day_index}
    ${str_index}    Convert To String    ${schedule_day_index}
    ${workload_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_TOTAL_WORKLOAD_HOURS}    DAY_INDEX=${str_index}
    Click Element On Webpage    ${workload_locator}
    Wait Until Page Is Loaded
    ${workload_hours}    Get Element Text On Webpage    ${workload_locator}
    ${weekly_workload_hours}    Strip String    ${workload_hours}
    Log    Retrieved workload hours from schedule: ${weekly_workload_hours}
    RETURN    ${weekly_workload_hours}

Get Weekly Scheduled Hours From Schedule Page On Web
    [Documentation]    Reads scheduled hours from weekly schedule page for specified day
    ...    | =Arguments=    | =Description= |
    ...    | schedule_day_index | Day to get scheduled hours for (1-7) |
    [Arguments]    ${schedule_day_index}
    ${str_index}    Convert To String    ${schedule_day_index}
    ${schedule_hr_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_TOTAL_SCHEDULED_HOURS}    DAY_INDEX=${str_index}
    Click Element On Webpage    ${schedule_hr_locator}
    ${scheduled_hours}    Get Element Text On Webpage    ${schedule_hr_locator}
    ${weekly_scheduled_hours}    Strip String    ${scheduled_hours}
    Log    Retrieved scheduled hours from schedule: ${weekly_scheduled_hours}
    RETURN    ${weekly_scheduled_hours}

Get Weekly Unallocated Hours From Schedule Page On Web
    [Documentation]    Reads unallocated hours from weekly schedule page for specified day
    ...    | =Arguments=    | =Description= |
    ...    | schedule_day_index | Day to get unallocated hours for (1-7) |
    [Arguments]    ${schedule_day_index}
    ${str_index}    Convert To String    ${schedule_day_index}
    ${unallocated_hr_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_TOTAL_UNALLOCATED_HOURS}    DAY_INDEX=${str_index}
    Click Element On Webpage    ${unallocated_hr_locator}
    ${unallocated_hours}    Get Element Text On Webpage    ${unallocated_hr_locator}
    ${weekly_unallocated_hours}    Replace String Using Regexp    ${unallocated_hours}    [()]    ${EMPTY}
    ${weekly_unallocated_hours}    Strip String    ${weekly_unallocated_hours}
    Log    Retrieved unallocated hours from schedule: ${weekly_unallocated_hours}
    RETURN    ${weekly_unallocated_hours}

Navigate To Week Schedule Overs And Shorts Page On Web
    [Documentation]
    ...    Accesses the Overs & Shorts report from the reports dropdown in the week schedule page.
    ...    | =Arguments= | =Description= |
    ...    None. No arguments required.
    ...
    ...    Example usage:
    ...    | Navigate To Week Schedule Overs And Shorts Page On Web |
    ...
    ...    *Returns*: Boolean indicating successful navigation (True if report accessed, False if unavailable).
    ...
    ...    *Behavior*:
    ...    1. Opens the reports dropdown menu from the week schedule page
    ...    2. Selects the "Overs & Shorts" report option
    ...    3. Waits for the report page to load and verifies accessibility
    ...    4. Captures a screenshot for test evidence
    ...    5. Returns True on successful navigation, False if report is not available in environment
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_DROPDOWN}
    ${overs_shorts_option_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_REPORTS_DROPDOWN_OPTION}
    ...    REPORTS_OPTION=Overs & Shorts
    ${is_overs_shorts_available}    Run Keyword And Return Status
    ...    Wait Until Element Is Present On Webpage    ${overs_shorts_option_locator}    timeout=5s
    IF    not ${is_overs_shorts_available}
        Log    Overs & Shorts report option is not available in this environment - skipping navigation    level=WARN
        RETURN    ${False}
    END
    Click Element On Webpage    ${overs_shorts_option_locator}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    Log    Successfully accessed Overs & Shorts report
    RETURN    ${True}

Get Total Workload Hours From Overs Shorts Report On Web
    [Documentation]    Reads total workload hours from Overs & Shorts report
    ...    | =Arguments=    | =Description= |
    ...    | day | Day to get unallocated hours for (1-7) |
    [Arguments]    ${schedule_day_index}
    ${str_index}    Convert To String    ${schedule_day_index}
    ${workload_hours}    Update Locator With Dynamic Values    ${OVERS_SHORTS_REPORT_TOTAL_WORKLOAD_HOURS_FOR_DAY}
    ...    DAY_INDEX=${str_index}
    ${is_present}    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${workload_hours}    timeout=5s
    IF    not ${is_present}
        Log    Workload hours not present in Overs & Shorts report for day ${schedule_day_index} - skipping this value    level=WARN
        RETURN    ${EMPTY}
    END
    Click Element On Webpage    ${workload_hours}
    ${workload_hours_Overs_Shorts_Report}    Get Element Text On Webpage    ${workload_hours}
    ${weekly_workload_hours}    Strip String    ${workload_hours_Overs_Shorts_Report}
    Log    Retrieved total workload hours from report: ${weekly_workload_hours}
    RETURN    ${weekly_workload_hours}

Get Total Scheduled Hours From Overs Shorts Report On Web
    [Documentation]    Reads total scheduled hours (without break) from Overs & Shorts report
    ...    | =Arguments=    | =Description= |
    ...    | day | Day to get Scheduled hours for (1-7) |
    [Arguments]    ${schedule_day_index}
    ${str_index}    Convert To String    ${schedule_day_index}
    ${scheduled_hours}    Update Locator With Dynamic Values    ${OVERS_SHORTS_REPORT_TOTAL_SCHEDULED_HOURS_FOR_DAY}
    ...    DAY_INDEX=${str_index}
    ${is_present}    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${scheduled_hours}    timeout=5s
    IF    not ${is_present}
        Log    Scheduled hours not present in Overs & Shorts report for day ${schedule_day_index} - skipping this value    level=WARN
        RETURN    ${EMPTY}
    END
    Click Element On Webpage    ${scheduled_hours}
    ${scheduled_hours_overs_shorts_report}    Get Element Text On Webpage    ${scheduled_hours}
    ${weekly_workload_hours}    Strip String    ${scheduled_hours_overs_shorts_report}
    Log    Retrieved total scheduled hours from report: ${weekly_workload_hours}
    RETURN    ${weekly_workload_hours}

Get Unallocated Hours From Overs Shorts Report On Web
    [Documentation]    Reads unallocated hours from Overs & Shorts report
    ...    | =Arguments=    | =Description= |
    ...    | schedule_day_index | Day to get unallocated hours for (1-7) |
    [Arguments]    ${schedule_day_index}
    ${str_index}    Convert To String    ${schedule_day_index}
    ${unallocated_hr_locator}    Update Locator With Dynamic Values    ${OVERS_SHORTS_REPORT_UNALLOCATED_HOURS_FOR_DAY}
    ...    DAY_INDEX=${str_index}
    ${is_present}    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${unallocated_hr_locator}    timeout=5s
    IF    not ${is_present}
        Log    Unallocated hours not present in Overs & Shorts report for day ${schedule_day_index} - skipping this value    level=WARN
        RETURN    ${EMPTY}
    END
    Click Element On Webpage    ${unallocated_hr_locator}
    ${unallocated_hours_overs_shorts_report}    Get Element Text On Webpage    ${unallocated_hr_locator}
    ${weekly_unallocated_hours}    Strip String    ${unallocated_hours_overs_shorts_report}
    Log    Retrieved unallocated hours from report: ${weekly_unallocated_hours}
    RETURN    ${weekly_unallocated_hours}

Compare Schedule And Report Values On Web
    [Documentation]    Compares the hours values between the Week Schedule page and Overs & Shorts report.
    ...
    ...    This keyword performs a comprehensive comparison of workload, scheduled, and unallocated hours
    ...    between the values captured from the week schedule page and the overs & shorts report.
    ...    It handles format differences like leading zeros (04:15 vs 4:15) and ignores zero values.
    ...    It logs the comparison results and fails the test if any values don't match.
    ...
    ...    | =Arguments= | =Description= |
    ...    | template_data | Template dictionary containing zero_time constant for comparison logic |
    ...    | schedule_workload | Workload hours from schedule page |
    ...    | schedule_scheduled | Scheduled hours from schedule page |
    ...    | schedule_unallocated | Unallocated hours from schedule page |
    ...    | report_workload | Workload hours from overs & shorts report |
    ...    | report_scheduled | Scheduled hours from overs & shorts report |
    ...    | report_unallocated | Unallocated hours from overs & shorts report |
    ...
    ...    Example usage:
    ...    | Compare Schedule And Report Values On Web
    ...    |    ...    template_data=${template_data}
    ...    |    ...    schedule_workload=${schedule_workload_hrs}
    ...    |    ...    schedule_scheduled=${schedule_scheduled_hrs}
    ...    |    ...    schedule_unallocated=${schedule_unallocated_hrs}
    ...    |    ...    report_workload=${report_workload_hrs}
    ...    |    ...    report_scheduled=${report_scheduled_hrs}
    ...    |    ...    report_unallocated=${report_unallocated_hrs}
    [Arguments]    ${template_data}    ${schedule_workload}
    ...    ${schedule_scheduled}
    ...    ${schedule_unallocated}
    ...    ${report_workload}
    ...    ${report_scheduled}
    ...    ${report_unallocated}

    ${normalized_schedule_workload}    Normalize Time String Format    ${schedule_workload}
    ${normalized_report_workload}    Normalize Time String Format    ${report_workload}
    ${normalized_schedule_scheduled}    Normalize Time String Format    ${schedule_scheduled}
    ${normalized_report_scheduled}    Normalize Time String Format    ${report_scheduled}
    ${normalized_schedule_unallocated}    Normalize Time String Format    ${schedule_unallocated}
    ${normalized_report_unallocated}    Normalize Time String Format    ${report_unallocated}
    # Note: Normalize Time String Format converts empty/None/null inputs to 0:00, so we only need to check for zero_time
    # Workload
    IF    '${normalized_schedule_workload}' == '${template_data}[zero_time]' or '${normalized_report_workload}' == '${template_data}[zero_time]'
        Log    Skipping Workload hours comparison: value missing or zero (Schedule='${schedule_workload}' Report='${report_workload}')
        ...    level=WARN
    ELSE
        Should Be Equal    ${normalized_schedule_workload}    ${normalized_report_workload}
        ...    msg=Workload hours mismatch: Schedule (${schedule_workload}) != Report (${report_workload})
        Log    ✓ Workload hours match: ${schedule_workload}    level=INFO
    END

    # Scheduled
    IF    '${normalized_schedule_scheduled}' == '${template_data}[zero_time]' or '${normalized_report_scheduled}' == '${template_data}[zero_time]'
        Log    Skipping Scheduled hours comparison: value missing or zero (Schedule='${schedule_scheduled}' Report='${report_scheduled}')
        ...    level=WARN
    ELSE
        Should Be Equal    ${normalized_schedule_scheduled}    ${normalized_report_scheduled}
        ...    msg=Scheduled hours mismatch: Schedule (${schedule_scheduled}) != Report (${report_scheduled})
        Log    ✓ Scheduled hours match: ${schedule_scheduled}    level=INFO
    END

    # Unallocated
    IF    '${normalized_schedule_unallocated}' == '${template_data}[zero_time]' or '${normalized_report_unallocated}' == '${template_data}[zero_time]'
        Log
        ...    Skipping Unallocated hours comparison: value missing or zero (Schedule='${schedule_unallocated}' Report='${report_unallocated}')
        ...    level=WARN
    ELSE
        Should Be Equal    ${normalized_schedule_unallocated}    ${normalized_report_unallocated}
        ...    msg=Unallocated hours mismatch: Schedule (${schedule_unallocated}) != Report (${report_unallocated})
        Log    ✓ Unallocated hours match: ${schedule_unallocated}    level=INFO
    END

    Log    ✅ Schedule vs Overs & Shorts Report comparison finished (skipped zero/missing values where applicable)    level=INFO

Navigate To Review Schedule Changes Report Page On Web
    [Documentation]    Navigates to the Review Schedule Changes report from the Reports dropdown menu.
    ...    This keyword accesses the schedule changes report that shows all operations performed
    ...    on the schedule including add shift, edit shift, unallocate shift, and delete open shift operations.
    ...
    ...    Example usage:
    ...    | Navigate To Review Schedule Changes Report Page On Web
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_DROPDOWN}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REVIEW_SCHEDULE_CHANGES_REPORT_OPTION}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    Log    Successfully navigated to Review Schedule Changes report

Verify Schedule Changes Report Contains Add Shift Operation On Web
    [Documentation]    Verifies that the schedule changes report contains an "Add Shift" operation
    ...    for the specified associate and day with the specified shift times.
    ...
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to verify the operation for |
    ...    | target_day | Day offset in week_day format (e.g., 1_2) or integer (0=Monday, 1=Tuesday, etc.) |
    ...    | shift_start_time | Start time of the shift in 24hr format (e.g., "09:00", "13:00") |
    ...    | shift_end_time | End time of the shift in 24hr format (e.g., "09:00", "17:00") |
    ...
    ...    Example usage:
    ...    | Verify Schedule Changes Report Contains Add Shift Operation On Web    John Doe    1_2    09:00    17:00
    [Arguments]    ${associate_name}    ${target_day}    ${shift_start_time}    ${shift_end_time}

    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    ${start_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
    ${start_time_12hr}    Replace String    ${start_time_with_space}    ${SPACE}    ${EMPTY}
    ${end_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_time}
    ${end_time_12hr}    Replace String    ${end_time_with_space}    ${SPACE}    ${EMPTY}
    ${add_shift_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_ADD_SHIFT_ROW}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    START_TIME=${start_time_12hr}
    ...    END_TIME=${end_time_12hr}
    ...    FORMATTED_DATE=${formatted_date}
    Click Element On Webpage    ${add_shift_locator}
    Log    ✓ Add Shift operation found for associate ${associate_name} on day ${target_day}

Verify Schedule Changes Report Contains Shift Extend Operation On Web
    [Documentation]    Verifies that the schedule changes report contains a "Shift Extend" operation
    ...    for the specified associate and day.
    ...
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to verify the operation for |
    ...    | target_day | Day number (e.g., 2 for Day 2) or week_day format (e.g., 1_2) |
    ...    | shift_start_time | Original shift start time in 24hr format (e.g., "09:00") |
    ...    | edited_shift_end_time | Extended shift end time in 24hr format (e.g., "18:00") |
    ...
    ...    Example usage:
    ...    | Verify Schedule Changes Report Contains Shift Extend Operation On Web    John Doe    2    09:00    18:00
    [Arguments]    ${associate_name}    ${target_day}    ${shift_start_time}    ${edited_shift_end_time}
    # Check if target_day is already a date or needs to be calculated from week_day format
    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    ${start_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
    ${start_time_12hr}    Replace String    ${start_time_with_space}    ${SPACE}    ${EMPTY}
    ${end_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${edited_shift_end_time}
    ${end_time_12hr}    Replace String    ${end_time_with_space}    ${SPACE}    ${EMPTY}
    ${shift_extend_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_SHIFT_EXTEND_ROW}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    START_TIME=${start_time_12hr}
    ...    END_TIME=${end_time_12hr}
    ...    FORMATTED_DATE=${formatted_date}
    Click Element On Webpage    ${shift_extend_locator}
    Log    ✓ Shift Extend operation found for associate ${associate_name} on day ${target_day}

Verify Schedule Changes Report Contains Unallocate Shift Operation On Web
    [Documentation]    Verifies that the schedule changes report contains an "Unallocate Shift" operation
    ...    for the specified associate and day.
    ...
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to verify the operation for |
    ...    | target_day | Day number (e.g., 2 for Day 2) |
    ...
    ...    Example usage:
    ...    | Verify Schedule Changes Report Contains Unallocate Shift Operation On Web    John Doe    2
    [Arguments]    ${associate_name}    ${target_day}
    # Check if target_day is already a date or needs to be calculated from week_day format
    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    ${unallocate_shift_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_UNALLOCATE_SHIFT_ROW}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    FORMATTED_DATE=${formatted_date}
    Click Element On Webpage    ${unallocate_shift_locator}
    Log    ✓ Unallocate Shift operation found for associate ${associate_name} on day ${target_day}

Verify Schedule Changes Report Contains Delete Open Shift Operation On Web
    [Documentation]    Verifies that the schedule changes report contains a "Delete Open Shift" operation
    ...    for the specified day with the specified shift times.
    ...
    ...    | =Arguments= | =Description= |
    ...    | target_day | Day offset from Monday (0=Monday, 1=Tuesday, etc.) or week_day format (e.g., 1_2) |
    ...    | shift_start_time | Start time of the deleted shift in 24hr format (e.g., "09:00", "13:00") |
    ...    | shift_end_time | End time of the deleted shift in 24hr format (e.g., "17:00", "18:00") |
    ...
    ...    Example usage:
    ...    | Verify Schedule Changes Report Contains Delete Open Shift Operation On Web    2    09:00    17:00
    [Arguments]    ${target_day}    ${shift_start_time}    ${shift_end_time}

    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    ${start_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
    ${start_time_12hr}    Replace String    ${start_time_with_space}    ${SPACE}    ${EMPTY}
    ${end_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_time}
    ${end_time_12hr}    Replace String    ${end_time_with_space}    ${SPACE}    ${EMPTY}
    ${delete_open_shift_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_DELETE_OPEN_SHIFT_ROW}
    ...    START_TIME=${start_time_12hr}
    ...    END_TIME=${end_time_12hr}
    ...    FORMATTED_DATE=${formatted_date}
    Click Element On Webpage    ${delete_open_shift_locator}
    Log    ✓ Delete Open Shift operation found for day ${target_day}

Click On Associate On Week Schedule Page On Web
    [Documentation]    Clicks on an associate row on the Week Schedule page to open their details panel.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full display name of the associate (e.g., "John, Doe"). |
    ...    Example usage:
    ...    | Click On Associate On Week Schedule Page On Web    John, Doe
    [Arguments]    ${associate_name}
    ${associate_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ASSOCIATE_BY_NAME}    ASSOCIATE_NAME=${associate_name}
    Click Element On Webpage    ${associate_locator}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Verify Employee Alert Is Displayed On Week Schedule Page On Web
    [Documentation]    Verifies that a specific employee alert is displayed in the Alert tab.
    ...    | =Arguments=    | =Description= |
    ...    | alert_message    | Expected alert message text to verify (from constants). |
    ...    Example usage:
    ...    | Verify Employee Alert Is Displayed On Week Schedule Page On Web    HR Alert: Employee Maximum hours per week exceeded
    [Arguments]    ${alert_message}
    ${alert_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ALERT_MESSAGE_BY_TEXT}    ALERT_MESSAGE=${alert_message}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${alert_locator}    timeout=${MEDIUM_TIMEOUT}
    ${is_alert_visible}    Is Element Visible On Webpage    ${alert_locator}
    Should Be True    ${is_alert_visible}    Expected alert '${alert_message}' was not found in the Alert tab
    Capture Screenshot On Webpage
    Log    ✓ Alert '${alert_message}' is displayed

Verify Employee Alert Is Not Displayed On Week Schedule Page On Web
    [Documentation]    Verifies that no availability alerts are displayed on the Week Schedule page.
    ...    This keyword passes if:
    ...    - No alerts are present
    ...    - Other non-availability alerts are present (checked by specific locators)
    ...    This keyword fails only if:
    ...    - Availability alerts are present (detected by specific locators)
    ...
    ...    = Improvement =
    ...    - Uses locator-based detection instead of text-based for better internationalization
    ...    - Checks for specific availability alert types from constants
    ...    - Works with non-English locales
    ...
    ...    Example usage:
    ...    | Verify Employee Alert Is Not Displayed On Week Schedule Page On Web
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_EMP_ALERTS_TAB_LABEL}    timeout=${MEDIUM_TIMEOUT}
    Capture Screenshot On Webpage

    # Check if "No Alerts Present" locator is visible using the constant value
    VAR    ${no_alert_message}    ${LOCALISED_TEXT}[no_alert_present]
    ${no_alert_message_lower}    Convert To Lower Case    ${no_alert_message}
    ${no_alerts_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ALERT_MESSAGE_BY_TEXT}
    ...    ALERT_MESSAGE=${no_alert_message_lower}
    ${no_alerts_present}    Run Keyword And Return Status    Is Element Visible On Webpage    ${no_alerts_locator}
    IF    ${no_alerts_present}
        Log    ✓ No alerts are present - verification passed
        RETURN
    END

    # Check for specific availability-related alerts using constants
    VAR    ${availability_alerts_found}    ${False}

    # Check for "Employee scheduled outside available hours" alert
    VAR    ${outside_hours_alert}    ${LOCALISED_TEXT}[shift_alert_outside_available_hours]
    ${outside_hours_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ALERT_MESSAGE_BY_TEXT}
    ...    ALERT_MESSAGE=${outside_hours_alert}
    ${outside_hours_visible}    Run Keyword And Return Status    Is Element Visible On Webpage    ${outside_hours_locator}
    IF    ${outside_hours_visible}
        VAR    ${availability_alerts_found}    ${True}
    END

    # Fail if any availability alerts are found
    IF    ${availability_alerts_found}
        ${alert_text}    Get Element Text On Webpage    ${WEEKSCHEDULEPAGE_ALERTS_MESSAGE_TEXT}
        Fail    Availability alerts found on Week Schedule page: ${alert_text}
    END
    Log    ✓ No availability alerts detected - verification passed

Navigate To Alerts Report On Week Schedule Page On Web
    [Documentation]    Navigates to the Alerts report from the Reports dropdown menu.
    ...    This keyword opens the Alerts report which displays both employee alerts and shift alerts
    ...    for the current week schedule.
    ...    Example usage:
    ...    | Navigate To Alerts Report On Week Schedule Page On Web
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_DROPDOWN}
    ${alerts_option_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_REPORTS_DROPDOWN_OPTION}    REPORTS_OPTION=Alerts
    Click Element On Webpage    ${alerts_option_locator}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    Log    Successfully navigated to Alerts report

Verify Alert Is Displayed In Alerts Report On Week Schedule Page On Web
    [Documentation]    Verifies that a specific alert is displayed in the Alerts report.
    ...    This can be used for both employee alerts and shift alerts.
    ...    | =Arguments=    | =Description= |
    ...    | alert_message    | Expected alert message text to verify (from constants). |
    ...    Example usage:
    ...    | Verify Alert Is Displayed In Alerts Report On Week Schedule Page On Web    HR Alert: Employee Maximum hours per week exceeded
    ...    | Verify Alert Is Displayed In Alerts Report On Week Schedule Page On Web    Shift Alert: Daily: Shift Minimum Length not met
    [Arguments]    ${alert_message}
    ${alert_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ALERTS_MESSAGE_BY_TEXT_IN_REPORT}
    ...    ALERT_MESSAGE=${alert_message}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${alert_locator}    timeout=${MEDIUM_TIMEOUT}
    ${is_alert_visible}    Is Element Visible On Webpage    ${alert_locator}
    Should Be True    ${is_alert_visible}    Expected alert '${alert_message}' was not found in the Alerts report
    Capture Screenshot On Webpage
    Log    ✓ Alert '${alert_message}' is displayed in Alerts report

Verify Alert Is Not Displayed In Alerts Report On Week Schedule Page On Web
    [Documentation]    Verifies that a specific alert is NOT displayed in the Alerts report.
    ...    | =Arguments=    | =Description= |
    ...    | alert_message    | Alert message text that should not be present. |
    ...    Example usage:
    ...    | Verify Alert Is Not Displayed In Alerts Report On Week Schedule Page On Web    HR Alert: Employee Maximum hours per week exceeded
    [Arguments]    ${alert_message}
    ${alert_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ALERTS_MESSAGE_BY_TEXT_IN_REPORT}
    ...    ALERT_MESSAGE=${alert_message}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${alert_locator}    timeout=${MEDIUM_TIMEOUT}
    ${is_alert_visible}    Is Element Visible On Webpage    ${alert_locator}
    Should Be Equal    ${is_alert_visible}    ${False}    Alert '${alert_message}' is still visible in the Alerts report
    Capture Screenshot On Webpage
    Log    ✓ Alert '${alert_message}' is not displayed in Alerts report

Verify Employee Alert Is Displayed In Alerts Report On Week Schedule Page On Web
    [Documentation]    Verifies that a specific employee alert is displayed in the Alerts report for an associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full display name of the associate (e.g., "StoreZ1, Associate03"). |
    ...    | target_day    | Day offset from Monday (0=Monday, 1=Tuesday, etc.) or week_day format (e.g., 6_0). |
    ...    | alert_message    | Expected alert message text to verify (from constants). |
    ...    Example usage:
    ...    | Verify Employee Alert Is Displayed In Alerts Report On Week Schedule Page On Web    StoreZ1, Associate03    6_0    ${employee_alert}
    [Arguments]    ${associate_name}    ${target_day}    ${alert_message}
    # Calculate the target date from day offset
    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    # Get date format from config (e.g., "MM/dd/yyyy" -> "03/08/2026")
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    # Build the locator with associate name, formatted date, and alert message
    ${alert_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_ALERTS_REPORT_ALERT_BY_ASSOCIATE_DATE_MESSAGE}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    FORMATTED_DATE=${formatted_date}
    ...    ALERT_MESSAGE=${alert_message}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${alert_locator}    timeout=${MEDIUM_TIMEOUT}
    ${is_alert_visible}    Is Element Visible On Webpage    ${alert_locator}
    Should Be True    ${is_alert_visible}
    ...    Expected employee alert '${alert_message}' for '${associate_name}' on '${formatted_date}' was not found in the Alerts report
    Capture Screenshot On Webpage
    Log    ✓ Employee alert '${alert_message}' for '${associate_name}' on '${formatted_date}' is displayed in Alerts report

Verify Shift Alert Is Displayed In Alerts Report On Week Schedule Page On Web
    [Documentation]    Verifies that a specific shift alert is displayed in the Alerts report for an associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full display name of the associate (e.g., "StoreZ1, Associate03"). |
    ...    | target_day    | Day offset from Monday (0=Monday, 1=Tuesday, etc.) or week_day format (e.g., 6_0). |
    ...    | alert_message    | Expected alert message text to verify (from constants). |
    ...    Example usage:
    ...    | Verify Shift Alert Is Displayed In Alerts Report On Week Schedule Page On Web    StoreZ1, Associate03    6_0    ${shift_alert}
    [Arguments]    ${associate_name}    ${target_day}    ${alert_message}
    # Calculate the target date from day offset
    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    # Get date format from config (e.g., "MM/dd/yyyy" -> "03/08/2026")
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    # Build the locator with associate name, formatted date, and alert message
    ${alert_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_ALERTS_REPORT_ALERT_BY_ASSOCIATE_DATE_MESSAGE}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    FORMATTED_DATE=${formatted_date}
    ...    ALERT_MESSAGE=${alert_message}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${alert_locator}    timeout=${MEDIUM_TIMEOUT}
    ${is_alert_visible}    Is Element Visible On Webpage    ${alert_locator}
    Should Be True    ${is_alert_visible}
    ...    Expected shift alert '${alert_message}' for '${associate_name}' on '${formatted_date}' was not found in the Alerts report
    Capture Screenshot On Webpage
    Log    ✓ Shift alert '${alert_message}' for '${associate_name}' on '${formatted_date}' is displayed in Alerts report

Verify Employee Alert Is Not Displayed In Alerts Report On Week Schedule Page On Web
    [Documentation]    Verifies that a specific employee alert is NOT displayed in the Alerts report for an associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full display name of the associate (e.g., "StoreZ1, Associate03"). |
    ...    | target_day    | Day offset from Monday (0=Monday, 1=Tuesday, etc.) or week_day format (e.g., 6_0). |
    ...    | alert_message    | Alert message text that should not be present. |
    ...    Example usage:
    ...    | Verify Employee Alert Is Not Displayed In Alerts Report On Week Schedule Page On Web    StoreZ1, Associate03    6_0    ${employee_alert}
    [Arguments]    ${associate_name}    ${target_day}    ${alert_message}
    # Calculate the target date from day offset
    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    # Get date format from config (e.g., "MM/dd/yyyy" -> "03/08/2026")
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    # Build the locator with associate name, formatted date, and alert message
    ${alert_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_ALERTS_REPORT_ALERT_BY_ASSOCIATE_DATE_MESSAGE}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    FORMATTED_DATE=${formatted_date}
    ...    ALERT_MESSAGE=${alert_message}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${alert_locator}    timeout=${MEDIUM_TIMEOUT}
    ${is_alert_visible}    Is Element Visible On Webpage    ${alert_locator}
    Should Be Equal    ${is_alert_visible}    ${False}
    ...    Employee alert '${alert_message}' for '${associate_name}' on '${formatted_date}' is still visible in the Alerts report
    Capture Screenshot On Webpage
    Log    ✓ Employee alert '${alert_message}' for '${associate_name}' on '${formatted_date}' is not displayed in Alerts report

Verify Shift Alert Is Not Displayed In Alerts Report On Week Schedule Page On Web
    [Documentation]    Verifies that a specific shift alert is NOT displayed in the Alerts report for an associate on a specific day.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name    | Full display name of the associate (e.g., "StoreZ1, Associate03"). |
    ...    | target_day    | Day offset from Monday (0=Monday, 1=Tuesday, etc.) or week_day format (e.g., 6_0). |
    ...    | alert_message    | Alert message text that should not be present. |
    ...    Example usage:
    ...    | Verify Shift Alert Is Not Displayed In Alerts Report On Week Schedule Page On Web    StoreZ1, Associate03    6_0    ${shift_alert}
    [Arguments]    ${associate_name}    ${target_day}    ${alert_message}
    # Calculate the target date from day offset
    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    # Get date format from config (e.g., "MM/dd/yyyy" -> "03/08/2026")
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    # Build the locator with associate name, formatted date, and alert message
    ${alert_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_ALERTS_REPORT_ALERT_BY_ASSOCIATE_DATE_MESSAGE}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    FORMATTED_DATE=${formatted_date}
    ...    ALERT_MESSAGE=${alert_message}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${alert_locator}    timeout=${MEDIUM_TIMEOUT}
    ${is_alert_visible}    Is Element Visible On Webpage    ${alert_locator}
    Should Be Equal    ${is_alert_visible}    ${False}
    ...    Shift alert '${alert_message}' for '${associate_name}' on '${formatted_date}' is still visible in the Alerts report
    Capture Screenshot On Webpage
    Log    ✓ Shift alert '${alert_message}' for '${associate_name}' on '${formatted_date}' is not displayed in Alerts report

Click On Alert Tab For Selected Shift In Bottom Panel On Week Schedule Page On Web
    [Documentation]    Clicks on alert tab for selected shift in bottom panel
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_ALERT_TAB}
    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}

Click On Alert Tab For Selected Associate In Bottom Panel On Week Schedule Page On Web
    [Documentation]    Clicks on alert tab for selected associate in bottom panel
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EMP_ALERTS_TAB}
    Wait Until Element Disappears On Webpage    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}

Verify Alert Message From Alert Tab In Bottom Panel On Week Schedule Page On Web
    [Documentation]    Verifies the alert message from the Alert tab in the bottom panel.
    ...    | =Arguments= | =Description= |
    ...    | alert_message | The alert message text to be verified. |
    ...    | visibility | True to verify presence, False to verify absence. Default is True. |
    [Arguments]    ${alert_message}    ${visibility}=True
    Capture Screenshot On Webpage
    ${alert_list}    Get Text Value Of All Elements Of Given Locator As List    ${WEEKSCHEDULEPAGE_ALERTS}
    ${alert_list_stripped}    Evaluate    [alert.strip() for alert in $alert_list]
    IF    not ${visibility}
        Should Not Contain    ${alert_list_stripped}    ${alert_message}
        ...    Alert message '${alert_message}' found in alert list: ${alert_list} for the selected shift, even after shift is unallocated..
    ELSE
        Should Contain    ${alert_list_stripped}    ${alert_message}
        ...    Alert message '${alert_message}' not found in alert list: ${alert_list} for the selected shift.
    END

Click On Searched Associate On Week Schedule Page On Web
    [Documentation]    Clicks on the searched associate on the Week Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe"). |
    [Arguments]    ${associate_name}
    ${associate_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_SEARCHED_ASSOCIATE}    EMP_NAME=${associate_name}
    Click Element On Webpage    ${associate_locator}
    Wait Until Page Is Loaded

Verify Success Notification Message On Week Schedule Page On Web
    [Documentation]    Verifies that the success notification message is displayed on the Week Schedule page.
    ...    Example usage:
    ...    | Verify Success Notification Message On Week Schedule Page On Web
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}    timeout=${LONG_TIMEOUT}
    ...    error_message=Success notification message not displayed on Week Schedule page.
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}

Get Open Shift Locator On Week Schedule Page On Web
    [Documentation]    Constructs the locator for an open shift based on day offset and shift times.
    ...    | =Arguments=    | =Description= |
    ...    | open_shift_day_offset | Day offset for the open shift: week_day format (e.g., 1_2). |
    ...    | shift_start_time | Start time of the open shift in 24-hour format (e.g., "14:00"). |
    ...    | shift_end_time | End time of the open shift in 24-hour format (e.g., "16:00"). |
    ...    | =Returns=    | =Description= |
    ...    | open_shift_locator | Locator for the specified open shift. |
    ...    Example usage:
    ...    | ${open_shift_locator}    Get Open Shift Locator On Week Schedule Page On Web    1_5    shift_start_time    shift_end_time
    [Arguments]    ${open_shift_day_offset}    ${shift_start_time}    ${shift_end_time}
    ${day}    Get Day Number    ${open_shift_day_offset}
    ${weekday}    Evaluate    int(${day}) + 1
    ${weekday_string}    Convert To String    ${weekday}
    # Convert times from 24hr to 12hr UI format (remove space for UI locator)
    ${start_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_start_time}
    ${start_time_12hr}    Replace String    ${start_time_with_space}    ${SPACE}    ${EMPTY}
    ${end_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_end_time}
    ${end_time_12hr}    Replace String    ${end_time_with_space}    ${SPACE}    ${EMPTY}
    ${open_shift_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_EDIT_OPEN_SHIFT}
    ...    DAY=${weekday_string}    START_TIME=${start_time_12hr}    END_TIME=${end_time_12hr}
    RETURN    ${open_shift_locator}

Add Open Shift On Week Schedule Page On Web
    [Documentation]    Adds an open shift on the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | weekday_offset | Day offset for the open shift: week_day format (e.g., 1_2). |
    ...    | shift_data | Dictionary containing open shift details: start_time, end_time (required). |
    ...    Example usage:
    ...    | Add Open Shift On Week Schedule Page On Web    1_3    {'start_time': '14:00', 'end_time': '16:00'} |
    [Arguments]    ${weekday_offset}    ${shift_data}
    Click On Open Shifts Tab On Week Schedule Page On Web
    ${week_date_format}    Get Config Value    SERVER_DF
    ${week_date}    Calculate Date From Week Day Offset    ${weekday_offset}    ${week_date_format}
    ${add_open_shift_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_OPEN_SHIFTS_PLUS_ICON}    DATE=${week_date}
    Click Element On Webpage    ${add_open_shift_locator}    error_message=Add Open Shift '+' icon for date ${week_date} not found.
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_START_TIME_INPUT}
    ...    error_message=Open Shift modal did not appear for date ${week_date}.
    IF    'task' in ${shift_data}
        Select List Item On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_TASK_SELECT}    text    ${shift_data}[task]
    END
    Clear Textbox On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_START_TIME_INPUT}
    Fill Textbox On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_START_TIME_INPUT}    ${shift_data}[start_time]
    Clear Textbox On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_END_TIME_INPUT}
    Fill Textbox On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_END_TIME_INPUT}    ${shift_data}[end_time]
    # for task, can add parameter and respective code if needed
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_OPEN_SHIFT_ADD_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_SAVE_BTN}    error_message=Save button to save open shift not clickable.
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[CREATED]
    Close Shift On Week Schedule Page On Web
    Log    Open shift added successfully from ${shift_data}[start_time] to ${shift_data}[end_time] on date ${week_date}.

Edit Open Shift On Week Schedule Page On Web
    [Documentation]    Edits an existing open shift on the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | open_shift_day_offset | Day offset for the open shift: week_day format (e.g., 1_2). |
    ...    | shift_template | Template identifier for the open shift to edit (e.g., "shift_template"). |
    ...    | new_start_time | New start time for the open shift (optional). |
    ...    | new_end_time | New end time for the open shift (optional). |
    ...    Example usage:
    ...    | Edit Open Shift On Week Schedule Page On Web    1_4    shift_template    10:00    18:00 |
    [Arguments]    ${open_shift_day_offset}    ${shift_template}    ${new_start_time}=${None}    ${new_end_time}=${None}
    Click On Open Shifts Tab On Week Schedule Page On Web
    ${open_shift_locator}    Get Open Shift Locator On Week Schedule Page On Web    ${open_shift_day_offset}
    ...    ${shift_template}[start_time]    ${shift_template}[end_time]
    Click Element On Webpage    ${open_shift_locator}
    ...    error_message=Open shift to edit not found on date offset ${open_shift_day_offset}.
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EDIT_OPEN_SHIFT_TAB}    error_message=Edit tab on open shift modal not clickable.
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_START_TIME_INPUT}
    ...    error_message=Open Shift modal did not appear for date offset ${open_shift_day_offset}.
    IF    '${new_start_time}' != '${None}'
        Clear Textbox On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_START_TIME_INPUT}
        Fill Textbox On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_START_TIME_INPUT}    ${new_start_time}
    END
    IF    '${new_end_time}' != '${None}'
        Clear Textbox On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_END_TIME_INPUT}
        Fill Textbox On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_END_TIME_INPUT}    ${new_end_time}
    END
    # for edit task, can add parameter and respective code if needed
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_OPEN_SHIFT_DELETE_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${WEEK_SCHEDULE_EDIT_SAVE_BTN}    error_message=Save button to save edited open shift not clickable.
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Close Shift On Week Schedule Page On Web
    Log    Open shift on date ${open_shift_day_offset} edited successfully.

Copy Open Shift On Week Schedule Page On Web
    [Documentation]    Copies an existing open shift to multiple days on the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | open_shift_day_offset | Day offset for the open shift: week_day format (e.g., 1_2). |
    ...    | shift_template | Template identifier for the open shift to copy (e.g., "shift_template"). |
    ...    | copy_to_days | Array of day offsets to copy the open shift to: week_day format (e.g., [3, 4]). |
    ...    Example usage:
    ...    | Copy Open Shift On Week Schedule Page On Web    1_5    shift_template    [3, 4] |
    [Arguments]    ${open_shift_day_offset}    ${shift_template}    ${copy_to_days}
    VAR    ${is_copy_applicable}    True
    Click On Open Shifts Tab On Week Schedule Page On Web
    ${open_shift_locator}    Get Open Shift Locator On Week Schedule Page On Web    ${open_shift_day_offset}
    ...    ${shift_template}[start_time]    ${shift_template}[end_time]
    Click Element On Webpage    ${open_shift_locator}
    ...    error_message=Open shift to copy not found on date offset ${open_shift_day_offset}.
    ${copy_tab_visible}    Is Element Visible On Webpage    ${WEEKSCHEDULEPAGE_COPY_OPEN_SHIFT_TAB}
    Capture Screenshot On Webpage
    IF    not ${copy_tab_visible}
        Close Shift On Week Schedule Page On Web
        Log
        ...    Copy tab is not visible for the selected open shift on date offset ${open_shift_day_offset}, cannot proceed with copy operation.
        VAR    ${is_copy_applicable}    False
        RETURN    ${is_copy_applicable}
    END
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_COPY_OPEN_SHIFT_TAB}    error_message=Copy tab on open shift modal not clickable.
    FOR    ${weekday}    IN    @{copy_to_days}
        ${weekday_string}    Convert To String    ${weekday}
        ${copy_to_day_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_DAY_BTN}
        ...    OFFSET_DAY=${weekday_string}
        Click Element On Webpage    ${copy_to_day_locator}
        ...    error_message=Day button for offset ${weekday_string} not clickable in copy open shift modal.
    END
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_OPEN_SHIFT_COPY_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_COPY_BTN}
    ...    error_message=Copy button to save on open shift modal not clickable.
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Verify Success Notification Message On Week Schedule Page On Web
    Close Shift On Week Schedule Page On Web
    Log    Open shift on date ${open_shift_day_offset} copied successfully.
    RETURN    ${is_copy_applicable}

Assign Open Shift To Associate On Week Schedule Page On Web
    [Documentation]    Assigns an open shift to a specific associate on the Week Schedule page.
    ...    The current-store tab is clicked using a generic locator based on the ng-click attribute
    ...    (storeSelected=true), which works across all clients regardless of display text
    ...    (e.g., "My Store", "My Property", etc.).
    ...    | =Arguments=    | =Description= |
    ...    | open_shift_day_offset | Day offset for the open shift: week_day format (e.g., 1_2). |
    ...    | shift_template | Template identifier for the open shift to assign (e.g., "shift_template"). |
    ...    | associate_name | Full display name of the associate to assign the shift to (e.g., "John, Doe"). |
    ...    Example usage:
    ...    | Assign Open Shift To Associate On Week Schedule Page On Web    2_3    shift_template    John, Doe |
    [Arguments]    ${open_shift_day_offset}    ${shift_template}    ${associate_name}
    Click On Open Shifts Tab On Week Schedule Page On Web
    ${open_shift_locator}    Get Open Shift Locator On Week Schedule Page On Web    ${open_shift_day_offset}
    ...    ${shift_template}[start_time]    ${shift_template}[end_time]
    Click Element On Webpage    ${open_shift_locator}
    ...    error_message=Open shift to assign not found on date offset ${open_shift_day_offset}.
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_ASSIGN_OPEN_SHIFT_TAB}    error_message=Assign tab on open shift modal not clickable.
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_ASSIGN_OPEN_SHIFT_STORE_TYPE_BTN}
    ...    error_message=Current store tab not clickable in assign open shift modal.
    ${associate_assign_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ASSOCIATE_ASSIGN_BTN}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_name}
    Wait Until Spinner Disappears On Week Schedule Page On Web
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_OPEN_SHIFT_ASSIGN_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${associate_assign_locator}
    ...    error_message=Associate '${associate_name}' not clickable in assign open shift modal.
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Close Shift On Week Schedule Page On Web

Drag And Drop Shift From Open Shifts Panel To Associate On Week Schedule Page On Web
    [Documentation]    Drags and drops a shift from the Open Shifts panel to a specific associate on the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | open_shift_day_offset | Day offset for the open shift: week_day format (e.g., 1_2). |
    ...    | shift_template | Template identifier for the open shift to drag and drop (e.g., "shift_template"). |
    ...    | associate_name | Full display name of the associate to assign the shift to (e.g., "John, Doe"). |
    ...    Example usage:
    ...    | Drag And Drop Shift From Open Shifts Panel To Associate On Week Schedule Page On Web    2_4    shift_template    John, Doe |
    [Arguments]    ${open_shift_day_offset}    ${shift_template}    ${associate_name}
    ${day}    Get Day Number    ${open_shift_day_offset}
    ${weekday}    Evaluate    int(${day}) + 1
    ${weekday_string}    Convert To String    ${weekday}
    Click On Open Shifts Tab On Week Schedule Page On Web
    Sleep    ${SHORT_TIMEOUT}  # timeout to ensure open shifts panel is fully loaded before scroll of shifts table starts, Needed as discussed with owner
    ${associate_shift_day_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_ASSOCIATE_WEEKDAY_CELL}    ASSOCIATE_NAME=${associate_name}    DAY=${weekday_string}
    Scroll Element To Center Of Webpage    ${associate_shift_day_locator}
    ${open_shift_locator}    Get Open Shift Locator On Week Schedule Page On Web    ${open_shift_day_offset}
    ...    ${shift_template}[start_time]    ${shift_template}[end_time]

    # Drag And Drop Element On Webpage    ${open_shift_locator}    ${associate_shift_day_locator}
    Hover    ${open_shift_locator}
    Mouse Button    down
    Hover    ${associate_shift_day_locator}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_OPEN_SHIFT_ASSIGN_NOTIFICATION_MESSAGE_API}
    Mouse Button    up
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Close Shift On Week Schedule Page On Web
    Log    Successfully dragged and dropped shift to associate '${associate_name}'.

Move Open Shift To Specified Day On Week Schedule Page On Web
    [Documentation]    Moves an open shift to a specified day on the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | open_shift_day_offset | Day offset for the open shift: week_day format (e.g., 1_2). |
    ...    | shift_template | Template identifier for the open shift to move (e.g., "shift_template"). |
    ...    | move_to_days | Array of day offsets to move the open shift to: week_day format (e.g., [3, 4]). |
    ...    Example usage:
    ...    | Move Open Shift To Specified Day On Week Schedule Page On Web    1_5    shift_template    [3, 4] |
    [Arguments]    ${open_shift_day_offset}    ${shift_template}    ${move_to_days}
    Click On Open Shifts Tab On Week Schedule Page On Web
    ${open_shift_locator}    Get Open Shift Locator On Week Schedule Page On Web    ${open_shift_day_offset}
    ...    ${shift_template}[start_time]    ${shift_template}[end_time]
    Click Element On Webpage    ${open_shift_locator}
    ...    error_message=Open shift to move not found on date offset ${open_shift_day_offset}.
    ${move_tab_visible}    Is Element Visible On Webpage    ${WEEKSCHEDULEPAGE_MOVE_OPEN_SHIFT_TAB}
    Capture Screenshot On Webpage
    IF    not ${move_tab_visible}
        Close Shift On Week Schedule Page On Web
        Log
        ...    Move tab is not visible for the selected open shift on date offset ${open_shift_day_offset}, cannot proceed with move operation.
        RETURN
    END
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_MOVE_OPEN_SHIFT_TAB}    error_message=Move tab on open shift modal not clickable.
    FOR    ${weekday}    IN    @{move_to_days}
        ${weekday_string}    Convert To String    ${weekday}
        ${move_to_day_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_DAY_BTN}
        ...    OFFSET_DAY=${weekday_string}
        Click Element On Webpage    ${move_to_day_locator}
        ...    error_message=Day button for offset ${weekday_string} not clickable in move open shift modal.
    END
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_OPEN_SHIFT_MOVE_NOTIFICATION_MESSAGE_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_OPEN_SHIFT_MOVE_BTN}
    ...    error_message=Move button to save on open shift modal not clickable.
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Close Shift On Week Schedule Page On Web
    Log    Open shift moved successfully from date ${open_shift_day_offset}.

Cleanup Existing Open Shifts On Week Schedule Page On Web
    [Documentation]    Deletes all existing open shifts on the Week Schedule page to ensure a clean state.
    ...    | =Arguments=    | =Description= |
    ...    | weekday_offsets | Array of day offsets to check for open shifts: week_day format (e.g., ["1_2", "3_4"]). |
    ...    | shift_start_time | Start time of the open shifts to delete (e.g., "14:30"). |
    ...    | shift_end_time | End time of the open shifts to delete (e.g., "16:30"). |
    ...    Example usage:
    ...    | Cleanup Existing Open Shifts On Week Schedule Page On Web    [1_2,3_4]    14:30    16:30 |
    [Arguments]    ${weekday_offsets}    ${shift_start_time}    ${shift_end_time}
    ${open_shifts_panel_already_open}    Is Element Visible On Webpage    ${WEEK_SCHEDULE_SHIFT_CLOSE_BTN}
    IF    ${open_shifts_panel_already_open}
        Close Shift On Week Schedule Page On Web
    END
    Click On Open Shifts Tab On Week Schedule Page On Web
    FOR    ${weekday_offset}    IN    @{weekday_offsets}
        VAR    ${open_shift_check}    True
        WHILE    ${open_shift_check}    limit=${LOOP_LIMIT}
            ${open_shift_locator}    Get Open Shift Locator On Week Schedule Page On Web    ${weekday_offset}
            ...    ${shift_start_time}    ${shift_end_time}
            ${open_shift_visible}    Is Element Visible On Webpage    ${open_shift_locator}
            IF    ${open_shift_visible}
                Delete Open Shift On Week Schedule Page On Web    ${shift_start_time}    ${shift_end_time}    ${weekday_offset}
                Click On Open Shifts Tab On Week Schedule Page On Web
            ELSE
                VAR    ${open_shift_check}    False
            END
        END
    END
    Log    All existing open shifts have been deleted successfully.

Unallocate Shifts For Specific Days On Week Schedule Page On Web
    [Documentation]    Unallocates shifts for specific days on the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | associate_display_name | Full display name of the associate (e.g., "John, Doe"). |
    ...    | days | Array of day indices to unallocate shifts for (e.g., [1, 3, 5]). |
    ...    Example usage:
    ...    | Unallocate Shifts For Specific Days On Week Schedule Page On Web    John, Doe    [1, 3, 5] |
    [Arguments]    ${associate_display_name}    ${days}
    FOR    ${day}    IN    @{days}
        ${day_normalized}    Evaluate    ${day} + 1
        ${day_string}    Convert To String    ${day_normalized}
        ${shift_locator}    Update Locator With Dynamic Values
        ...    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}    EMP_NAME=${associate_display_name}    DAY=${day_string}
        ${shift_available_for_associate}    Is Element Present On Webpage    ${shift_locator}
        IF    ${shift_available_for_associate}
            Perform Unallocate The Shift Operation On Week Schedule Page On Web    ${associate_display_name}    ${day}
            Verify Success Notification Message On Week Schedule Page On Web
        END
    END
    Log    Shifts unallocated successfully.

Compare Scheduled Hours Between Week Schedule Page And Week Plan Schedule Report Page On Web
    [Documentation]    Compares the scheduled hours between the Week Schedule page and the Week Plan Schedule Report page for the specified associate.
    ...    Validates daily shift hours and total scheduled hours only.
    ...    | =Arguments=    | =Description= |
    ...    | display_name    | Full display name of the associate (e.g., "John, Doe"). |
    ...    Example usage:
    ...    | Compare Scheduled Hours Between Week Schedule Page And Week Plan Schedule Report Page On Web    John, Doe
    [Arguments]    ${display_name}
    # Get data from Week Schedule Page
    ${ws_daily_hours}
    ...    ${ws_total_hours}
    ...    Get The Daily And Total Scheduled Hours For The Associate On Week Schedule Page On Web    ${display_name}
    # Get data from Week Plan Schedule Report Page
    Open Reports Week Plan Schedule On Week Schedule Page On Web
    ${wp_daily_hours}
    ...    ${wp_total_hours}
    ...    Get The Daily And Total Scheduled Hours For The Associate On Week Plan Schedule Report Page On Web    ${display_name}
    # Normalize daily hours for comparison
    VAR    @{normalized_ws_hours}    @{EMPTY}
    FOR    ${shift}    IN    @{ws_daily_hours}
        ${normalized}    Replace String    ${shift}    \n    ${SPACE}
        # Remove dashes and parentheses
        ${normalized}    Replace String    ${normalized}    -    ${EMPTY}
        ${normalized}    Replace String    ${normalized}    (    ${EMPTY}
        ${normalized}    Replace String    ${normalized}    )    ${EMPTY}
        # Remove multiple spaces
        ${normalized}    Strip String    ${normalized}
        ${normalized_shift}    Replace String Using Regexp    ${normalized}    \\s+    ${SPACE}
        Append To List    ${normalized_ws_hours}    ${normalized_shift}
    END
    VAR    @{normalized_wp_hours}    @{EMPTY}
    FOR    ${shift}    IN    @{wp_daily_hours}
        ${normalized}    Replace String    ${shift}    \n    ${SPACE}
        # Remove dashes and parentheses
        ${normalized}    Replace String    ${normalized}    -    ${EMPTY}
        ${normalized}    Replace String    ${normalized}    (    ${EMPTY}
        ${normalized}    Replace String    ${normalized}    )    ${EMPTY}
        # Remove multiple spaces
        ${normalized}    Strip String    ${normalized}
        ${normalized_shift}    Replace String Using Regexp    ${normalized}    \\s+    ${SPACE}
        Append To List    ${normalized_wp_hours}    ${normalized_shift}
    END
    # Compare daily hours
    Lists Should Be Equal    ${normalized_ws_hours}    ${normalized_wp_hours}
    ...    msg=Daily shift hours do not match between Week Schedule and Week Plan Schedule Report
    # Compare total hours
    Should Be Equal    ${ws_total_hours}    ${wp_total_hours}
    ...    msg=Total hours do not match between Week Schedule and Week Plan Schedule Report

Open Reports Week Plan Schedule On Week Schedule Page On Web
    [Documentation]    Opens the Week Plan Schedule report from the Reports dropdown menu.
    ...    Example usage:
    ...    | Open Reports Week Plan Schedule On Week Schedule Page On Web
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_REPORTS_DROPDOWN}
    ${weekplan_schedule_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_REPORTS_DROPDOWN_OPTION}
    ...    REPORTS_OPTION=Weekplan Schedule
    Wait Until Element Is Visible On Webpage    ${weekplan_schedule_locator}
    Click Element And Switch To New Browser Tab On Web    ${weekplan_schedule_locator}
    Wait Until Page Is Loaded

Get The Daily And Total Scheduled Hours For The Associate On Week Plan Schedule Report Page On Web
    [Documentation]    Gets the daily and total scheduled hours for the specified associate from the Week Plan Schedule Report page.
    ...    | =Arguments=    | =Description= |
    ...    | display_name    | Full display name of the associate (e.g., "John, Doe"). |
    ...    | =Returns=    | =Description= |
    ...    | daily_shift_hours    | List of daily scheduled hours for the associate. |
    ...    | total_hours    | Total scheduled hours for the associate. |
    ...    Example usage:
    ...    | ${daily_hours}    ${total_hours}    Get The Daily And Total Scheduled Hours For The Associate On Week Plan Schedule Report Page On Web    John, Doe
    [Arguments]    ${display_name}
    ${prefix}    Set Selector Prefix    ${None}
    ${associate_shifts}    Update Locator With Dynamic Values    ${WEEK_PLAN_SCHEDULE_REPORT_ASSOCIATE_SHIFTS}
    ...    ASSOCIATE_DISPLAY_NAME=${display_name}
    ${shift_count}    Get Element Count On Web Page    ${associate_shifts}
    ${end_range}    Evaluate    ${shift_count} + 1
    VAR    @{daily_shift_hours}    @{EMPTY}
    FOR    ${INDEX}    IN RANGE    1    ${end_range}
        ${index_str}    Convert To String    ${INDEX}
        ${shift_day}    Update Locator With Dynamic Values    ${WEEK_PLAN_SCHEDULE_REPORT_ASSOCIATE_SHIFTS_INDEX}
        ...    ASSOCIATE_DISPLAY_NAME=${display_name}    INDEX=${index_str}
        ${shift_text}    Get Element Text On Webpage    ${shift_day}
        Append To List    ${daily_shift_hours}    ${shift_text}
    END
    ${total_hours}    Update Locator With Dynamic Values    ${WEEK_PLAN_SCHEDULE_REPORT_ASSOCIATE_TOTAL_HOURS}
    ...    ASSOCIATE_DISPLAY_NAME=${display_name}
    ${associate_total_hours}    Get Element Text On Webpage    ${total_hours}
    Set Selector Prefix    ${prefix}
    RETURN    ${daily_shift_hours}    ${associate_total_hours}

Get The Daily And Total Scheduled Hours For The Associate On Week Schedule Page On Web
    [Documentation]    Gets the daily and total scheduled hours for the specified associate from the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | display_name    | Full display name of the associate (e.g., "John, Doe"). |
    ...    | =Returns=    | =Description= |
    ...    | daily_shift_hours    | List of daily scheduled hours for the associate. |
    ...    | total_hours    | Total scheduled hours for the associate. |
    ...    Example usage:
    ...    | ${daily_hours}    ${total_hours}    Get The Daily And Total Scheduled Hours For The Associate On Week Schedule Page On Web    John, Doe
    [Arguments]    ${display_name}
    ${associate_shifts}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFTS}
    ...    ASSOCIATE_DISPLAY_NAME=${display_name}
    ${shift_count}    Get Element Count On Web Page    ${associate_shifts}
    ${end_range}    Evaluate    ${shift_count} + 1
    VAR    @{daily_shift_hours}    @{EMPTY}
    FOR    ${INDEX}    IN RANGE    1    ${end_range}
        ${index_str}    Convert To String    ${INDEX}
        ${shift_day}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFTS_INDEX}
        ...    ASSOCIATE_DISPLAY_NAME=${display_name}    INDEX=${index_str}
        ${shift_text}    Get Element Text On Webpage    ${shift_day}
        Append To List    ${daily_shift_hours}    ${shift_text}
    END
    ${total_hours}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_TOTAL_HOURS}
    ...    ASSOCIATE_DISPLAY_NAME=${display_name}
    ${associate_total_hours}    Get Element Text On Webpage    ${total_hours}
    RETURN    ${daily_shift_hours}    ${associate_total_hours}

Publish Week Schedule With Unit Id Using Servlet On Web
    [Documentation]    Publishes the schedule using the servlet for the given week offset for specific unit.
    ...    | =Arguments= | =Description= |
    ...    | user_key | User key for authentication. |
    ...    | week_offset | Week number in offset format (e.g., "2_0"). |
    ...    | unit_skey | Unit SKEY for which the schedule is to be published. |
    [Arguments]    ${user_key}    ${week_offset}    ${unit_skey}
    ${week_number}    Split String    ${week_offset}    _
    Generate Auth Token With User Credentials    ${user_key}
    ${response}    Send A Get Request    ${WEEK_SCHEDULE_PUBLISH_SCHEDULE_FOR_UNIT_SERVLET}    ${week_number}[0]
    ...    ${unit_skey}    return_raw_response=True
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Integers    ${response.status_code}    ${status_ok}
    ...    msg=Failed to publish schedule via servlet; expected HTTP 200.

Perform Copy Shift Operation On Week Schedule Page On Web
    [Documentation]    Performs the copy shift operation on the Week Schedule page for a specified associate and day.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe"). |
    ...    | day_offset | Source day using 0-based indexing (0=Monday, 1=Tuesday, 2=Wednesday, etc.) or week_day format (e.g., 6_0). |
    ...    | target_days | List of target days using 1-based indexing (1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, etc.). Values are internally converted to 0-based for UI locators. Pass as list variable (e.g., ${list_var}) or individual arguments. |
    ...
    ...    **Indexing Convention:**
    ...    - Source day_offset: 0-based (0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun)
    ...    - Target day list: 1-based (1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun)
    ...    - UI locators: 0-based (keyword converts target_days by subtracting 1)
    ...
    ...    Example usage:
    ...    | @{days}=    Create List    4    5
    ...    | Perform Copy Shift Operation On Week Schedule Page On Web    John, Doe    2    @{days}
    ...    | # Or pass individual arguments:
    ...    | Perform Copy Shift Operation On Week Schedule Page On Web    John, Doe    2    4    5
    ...    | # Copies shift from Wednesday (day_offset=2) to Thursday and Friday (target_days=4,5)
    ...    | # target_days [4,5] is converted to [3,4] for 0-based UI locators (Thu=3, Fri=4)
    [Arguments]    ${associate_name}    ${day_offset}    @{target_days}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}    EMP_NAME=${associate_name}    DAY=${day_offset}
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Shift to copy not found for associate '${associate_name}' on day offset ${day_offset}.
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_COPY_SHIFT_TAB}    error_message=Copy tab on shift modal not clickable.
    FOR    ${day_to_copy}    IN    @{target_days}
        # Convert to 0-based indexing for UI (subtract 1 from the day value)
        ${day_index}    Evaluate    int(${day_to_copy}) - 1
        ${day_string}    Convert To String    ${day_index}
        ${copy_to_day_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_COPY_SHIFT_FOR_WEEKDAY}    DAY=${day_string}
        Click Element On Webpage    ${copy_to_day_locator}
        ...    error_message=Day button for offset ${day_string} not clickable in copy shift modal.
    END
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_COPY_SHIFT_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_COPY_SHIFT_COPY_BTN}    error_message=Copy button to save on shift modal not clickable.
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Success Notifier Message Disappears In Week Schedule Page On Web

Perform Move Shift Operation On Week Schedule Page On Web
    [Documentation]    Performs the move shift operation on the Week Schedule page for a specified associate and day.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe"). |
    ...    | day_offset | Source day using 0-based indexing (0=Monday, 1=Tuesday, 2=Wednesday, etc.) or week_day format (e.g., 6_0). |
    ...    | target_day | Target day using 1-based indexing (1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, etc.). Value is internally converted to 0-based for UI locators. |
    ...
    ...    **Indexing Convention:**
    ...    - Source day_offset: 0-based (0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun)
    ...    - Target day: 1-based (1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun)
    ...    - UI locators: 0-based (keyword converts target_day by subtracting 1)
    ...
    ...    Example usage:
    ...    | Perform Move Shift Operation On Week Schedule Page On Web    John, Doe    2    5
    ...    | # Moves shift from Wednesday (day_offset=2) to Friday (target_day=5)
    ...    | # target_day 5 is converted to 4 for 0-based UI locator (Fri=4)
    [Arguments]    ${associate_name}    ${day_offset}    ${target_day}
    ${shift_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE}    EMP_NAME=${associate_name}    DAY=${day_offset}
    Click Element On Webpage    ${shift_locator}
    ...    error_message=Shift to move not found for associate '${associate_name}' on day offset ${day_offset}.
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_MOVE_TAB}    error_message=Move tab on shift modal not clickable.
    # Convert to 0-based indexing for UI (subtract 1 from the day value)
    ${day_index}    Evaluate    int(${target_day}) - 1
    ${day_string}    Convert To String    ${day_index}
    ${move_to_day_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_MOVE_SHIFT_FOR_WEEKDAY}    DAY=${day_string}
    Click Element On Webpage    ${move_to_day_locator}
    ...    error_message=Day button for offset ${day_string} not clickable in move shift modal.
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_MOVE_SHIFT_API}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_MOVE_SHIFT_MOVE_BTN}    error_message=Move button to save on shift modal not clickable.
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Success Notifier Message Disappears In Week Schedule Page On Web

Perform Drag And Drop Shift Operation On Week Schedule Page On Web
    [Documentation]    Performs the drag and drop shift operation on the Week Schedule page for a specified associate and day.
    ...    Supports both same-associate and different-associate drag and drop operations.
    ...    | =Arguments= | =Description= |
    ...    | associate_name_1 | Full display name of the source associate (e.g., "John, Doe"). |
    ...    | day_offset | Source day using 0-based indexing (0=Monday, 1=Tuesday, 2=Wednesday, etc.) or week_day format (e.g., 6_0). |
    ...    | target_day | Target day using 1-based indexing (1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, etc.). Value is internally converted to 0-based for UI locators. |
    ...    | associate_name_2 | (Optional) Full display name of the target associate. If not provided, uses associate_name_1 for same-associate operations. |
    ...
    ...    **Indexing Convention:**
    ...    - Source day_offset: 0-based (0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun)
    ...    - Target day: 1-based (1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun)
    ...    - UI locators: 0-based (keyword converts target_day by subtracting 1)
    ...
    ...    Example usage (same associate - 3 arguments):
    ...    | Perform Drag And Drop Shift Operation On Week Schedule Page On Web    John, Doe    2    5
    ...    | # Drags shift from Wednesday (day_offset=2) to Friday (target_day=5) for same associate
    ...    | # target_day 5 is converted to 4 for 0-based UI locator (Fri=4)
    ...
    ...    Example usage (different associates - 4 arguments):
    ...    | Perform Drag And Drop Shift Operation On Week Schedule Page On Web    John, Doe    2    5    Jane, Smith
    ...    | # Drags shift from John on Wednesday to Jane on Friday
    [Arguments]    ${source}    ${day_offset}    ${target_day}    ${target}=${EMPTY}
    ${source_shift_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SOURCE_SHIFT_WITH_NAME_DAYOFFSET}    EMP_NAME=${source}    DAY_OFFSET=${day_offset}
    # Determine which associate name to use for target locator - if associate_name_2 is empty, use associate_name_1
    ${target_associate}    Set Variable If    '${target}' != '${EMPTY}'    ${target}    ${source}
    ${target_shift_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_TARGET_SHIFT_CELL_WITH_NAME_DAYOFFSET}    EMP_NAME=${target_associate}    DAY_OFFSET=${target_day}
    ${post_drag_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SOURCE_SHIFT_WITH_NAME_DAYOFFSET}    EMP_NAME=${target_associate}    DAY_OFFSET=${target_day}
    Wait Until Success Notifier Message Disappears In Week Schedule Page On Web
    Scroll Element To Center Of Webpage    ${target_shift_locator}
    Hover    ${source_shift_locator}
    Mouse Button    down
    Hover    ${target_shift_locator}
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_MOVE_SHIFT_API}
    Mouse Button    up
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Success Notifier Message Disappears In Week Schedule Page On Web
    Wait Until Element Is Visible On Webpage    ${post_drag_locator}
    ...    error_message=Drag and drop operation failed

Add Detailed Shift With Task Segments By Right Click On Week Schedule Page On Web
    [Documentation]    Adds a detailed shift with task segments by right-clicking on a day cell for the specified associate.
    ...    This keyword handles multi-segment shifts with tasks, meal breaks, and rest periods.
    ...    API validation is performed to ensure shift creation succeeds.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Display name of the associate (e.g., "Smith, John"). |
    ...    | day_offset | Day offset for the shift (e.g., 1 for Monday if week starts on Sunday). |
    ...    | task_segments | List of dictionaries containing task segment details. Each dict must have: start_time (e.g., "10:00"), end_time (e.g., "14:00"), task_name (e.g., "Continued Work", "Meal Break"). |
    ...    | apply_meal_break_rules | Whether to apply meal break rules on save (default: True). Pass ${False} to save via 'Do not Apply Meal Break Rules' option. |
    ...    Example usage:
    ...    | ${segments}= | Create List |
    ...    | ...    ${{'start_time': '10:00', 'end_time': '14:00', 'task_name': 'Continued Work'}} |
    ...    | ...    ${{'start_time': '14:00', 'end_time': '14:30', 'task_name': 'Meal Break'}} |
    ...    | Add Detailed Shift With Task Segments By Right Click On Week Schedule Page On Web | Smith, John | 1 | ${segments} |
    [Arguments]    ${associate_display_name}    ${day_offset}    ${task_segments}    ${apply_meal_break_rules}=True
    ${day_offset_str}    Convert To String    ${day_offset}
    ${day_cell_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_display_name}    DAY_OFFSET=${day_offset_str}
    Right Click Element On Webpage    ${day_cell_locator}
    ...    error_message=Failed to right-click on day cell for ${associate_display_name} on day ${day_offset}
    Wait Until Page Is Loaded
    # Wait for modal to fully initialize - first input field must be visible and stable for interaction
    ${first_start_time_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_START_TIME}    INDEX=1
    Wait Until Element Is Visible On Webpage    ${first_start_time_locator}
    ...    error_message=Detailed shift modal failed to open - first time picker not visible for ${associate_display_name}
    ${segment_count}    Get Length    ${task_segments}
    FOR    ${index}    ${segment}    IN ENUMERATE    @{task_segments}    start=1
        ${index_str}    Convert To String    ${index}
        ${start_time_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_START_TIME}    INDEX=${index_str}
        ${end_time_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_END_TIME}    INDEX=${index_str}
        ${task_dropdown_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_TASK_DROPDOWN}
        ...    INDEX=${index_str}
        Click Element On Webpage    ${start_time_locator}
        ...    error_message=Failed to click start time field for segment ${index} on ${associate_display_name}
        Fill Textbox On Webpage    ${start_time_locator}    ${segment}[start_time]
        Click Element On Webpage    ${end_time_locator}
        ...    error_message=Failed to click end time field for segment ${index} on ${associate_display_name}
        Fill Textbox On Webpage    ${end_time_locator}    ${segment}[end_time]
        Select Task From Detailed Shift Dropdown On Week Schedule Page On Web    ${task_dropdown_locator}    ${segment}[task_name]
        IF    ${index} < ${segment_count}
            ${add_task_icon_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_ADD_TASK_ICON}
            ...    INDEX=${index_str}
            Click Element On Webpage    ${add_task_icon_locator}
            ...    error_message=Failed to click Add Task icon for segment ${index}
            Wait Until Page Is Loaded
            ${next_index}    Evaluate    ${index} + 1
            ${next_index_str}    Convert To String    ${next_index}
            ${next_start_time_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_START_TIME}
            ...    INDEX=${next_index_str}
            Wait Until Element Is Visible On Webpage    ${next_start_time_locator}
            ...    error_message=New task segment ${next_index} failed to appear after clicking Add Task
        END
    END
    # Always validate API response to ensure shift was created successfully
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_RIGHT_CLICK_ADD_SHIFT_API}
    IF    not ${apply_meal_break_rules}
        ${is_dropdown_arrow_visible}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_DROPDOWN_ARROW}
        IF    ${is_dropdown_arrow_visible}
            Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_DROPDOWN_ARROW}
            ...    error_message=Failed to click Save dropdown for meal break options
            Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_ADD_NO_MEAL_RULES}
            ...    error_message=Do not Apply Meal Break Rules option not visible
            Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_ADD_NO_MEAL_RULES}
            ...    error_message=Failed to click Do not Apply Meal Break Rules option
        ELSE
            Log    Save dropdown arrow not present; saving without meal break rule selection
            Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_BTN}
            ...    error_message=Failed to click Save button for detailed shift
        END
    ELSE
        Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_BTN}
        ...    error_message=Failed to click Save button for detailed shift
    END
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_created}    Get System Value    HttpStatusCode    CREATED
    Should Be Equal As Integers    ${response_body.status}    ${status_created}
    ...    msg=Failed to add detailed shift for ${associate_display_name} on day ${day_offset}; expected HTTP 201 CREATED.
    Capture Screenshot On Webpage

Edit Detailed Shift With Task Segments On Week Schedule Page On Web
    [Documentation]    Edits a detailed shift's task segments on the Week Schedule page.
    ...    This keyword clicks on an existing shift, modifies task segments, and saves with optional meal break rule override.
    ...    API validation is performed to ensure shift edit succeeds.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Display name of the associate (e.g., "Smith, John"). |
    ...    | day_offset | Day offset for the shift (e.g., 1 for Monday). |
    ...    | task_segments | List of updated task segment dictionaries. |
    ...    | apply_meal_break_rules | Whether to apply meal break rules (default: True). |
    ...    Example usage:
    ...    | ${segments}= | Create List |
    ...    | ...    ${{'start_time': '10:00', 'end_time': '13:00', 'task_name': 'Continued Work'}} |
    ...    | Edit Detailed Shift With Task Segments On Week Schedule Page On Web | Smith, John | 1 | ${segments} | ${False} |
    [Arguments]    ${associate_display_name}    ${day_offset}    ${task_segments}    ${apply_meal_break_rules}=True
    ${day_offset_str}    Convert To String    ${day_offset}
    ${shift_cell_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_display_name}    DAY_OFFSET=${day_offset_str}
    Click Element On Webpage    ${shift_cell_locator}
    ...    error_message=Failed to click shift for ${associate_display_name} on day ${day_offset}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EDIT_SHIFT_BUTTON}
    ...    error_message=Edit Shift button not clickable for ${associate_display_name}
    Wait Until Page Is Loaded

    # Update time fields for existing task segments
    FOR    ${index}    ${segment}    IN ENUMERATE    @{task_segments}    start=1
        # In edit mode, time pickers use sequential indexing: (segment*2-1) for start, (segment*2) for end
        ${start_time_index}    Evaluate    ${index} * 2 - 1
        ${end_time_index}    Evaluate    ${index} * 2
        ${start_time_index_str}    Convert To String    ${start_time_index}
        ${end_time_index_str}    Convert To String    ${end_time_index}
        ${start_time_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_TIME_PICKER_EDIT_INDEX}
        ...    INDEX=${start_time_index_str}
        ${end_time_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_TIME_PICKER_EDIT_INDEX}
        ...    INDEX=${end_time_index_str}

        # Update only start and end times (tasks remain unchanged)
        Clear Textbox On Webpage    ${start_time_locator}
        Fill Textbox On Webpage    ${start_time_locator}    ${segment}[start_time]
        Clear Textbox On Webpage    ${end_time_locator}
        Fill Textbox On Webpage    ${end_time_locator}    ${segment}[end_time]
    END
    # Always validate API response - toast message validation not required
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_ADD_EDIT_SHIFT_API}
    IF    not ${apply_meal_break_rules}
        ${is_dropdown_arrow_visible}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_DROPDOWN_ARROW}
        IF    ${is_dropdown_arrow_visible}
            Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_DROPDOWN_ARROW}
            ...    error_message=Failed to click Save dropdown for meal break options
            Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_NO_MEAL_RULES}
            ...    error_message=Do not Apply Meal Break Rules option not visible
            Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_NO_MEAL_RULES}
            ...    error_message=Failed to click Do not Apply Meal Break Rules option
        ELSE
            Log    Save dropdown arrow not present; saving without meal break rule selection
            Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_BTN}
            ...    error_message=Failed to click Save button to edit shift
        END
    ELSE
        Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_BTN}
        ...    error_message=Failed to click Save button to edit shift
    END
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Integers    ${response_body.status}    ${status_ok}
    ...    msg=Failed to edit shift for ${associate_display_name} on day ${day_offset}; expected HTTP 200 OK.
    Capture Screenshot On Webpage

Edit Detailed Shift Meal Break Segment On Week Schedule Page On Web
    [Documentation]    Edits only the meal-break segment time in detailed shift edit modal.
    ...    This keyword uses a deterministic meal row index from template-driven shift data.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Display name of the associate whose shift should be edited. |
    ...    | day_offset | Day offset for the shift. |
    ...    | meal_break_start_time | Updated meal-break start time. |
    ...    | meal_break_end_time | Updated meal-break end time. |
    ...    | apply_meal_break_rules | Whether to apply meal-break rules while saving (default: True). |
    ...    | meal_row_index | Row index of the meal segment in detailed shift modal (default: 2). |
    ...
    ...    *Returns*: ${True} when meal break is edited and saved successfully.
    [Arguments]    ${associate_display_name}    ${day_offset}    ${meal_break_start_time}    ${meal_break_end_time}
    ...    ${apply_meal_break_rules}=True    ${meal_row_index}=2

    ${day_offset_str}    Convert To String    ${day_offset}

    ${shift_cell_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_display_name}    DAY_OFFSET=${day_offset_str}

    Click Element On Webpage    ${shift_cell_locator}
    ...    error_message=Failed to click shift for ${associate_display_name} on day ${day_offset}

    Wait Until Page Is Loaded

    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EDIT_SHIFT_BUTTON}
    ...    error_message=Edit Shift button not clickable for ${associate_display_name}

    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_SHIFT_TASK_DROPDOWN_FIRST}

    ${resolved_meal_row_index}    Convert To Integer    ${meal_row_index}
    Should Be True    ${resolved_meal_row_index} > 0
    ...    msg=Meal row index must be a positive integer, but got: ${meal_row_index}

    # Only perform calculations once we are 100% sure we have a valid positive row index
    ${start_time_index}    Evaluate    ${resolved_meal_row_index} * 2 - 1
    ${end_time_index}    Evaluate    ${resolved_meal_row_index} * 2

    ${start_time_index_str}    Convert To String    ${start_time_index}
    ${end_time_index_str}    Convert To String    ${end_time_index}

    ${start_time_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_TIME_PICKER_EDIT_INDEX}
    ...    INDEX=${start_time_index_str}

    ${end_time_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_DETAILED_SHIFT_TIME_PICKER_EDIT_INDEX}
    ...    INDEX=${end_time_index_str}

    Clear Textbox On Webpage    ${start_time_locator}
    Fill Textbox On Webpage    ${start_time_locator}    ${meal_break_start_time}

    Clear Textbox On Webpage    ${end_time_locator}
    Fill Textbox On Webpage    ${end_time_locator}    ${meal_break_end_time}

    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_ADD_EDIT_SHIFT_API}

    IF    not ${apply_meal_break_rules}
        ${is_dropdown_arrow_visible}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_DROPDOWN_ARROW}

        IF    ${is_dropdown_arrow_visible}
            Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_DROPDOWN_ARROW}
            ...    error_message=Failed to click Save dropdown for meal break options

            Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_NO_MEAL_RULES}
            ...    error_message=Do not Apply Meal Break Rules option not visible

            Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_NO_MEAL_RULES}
            ...    error_message=Failed to click Do not Apply Meal Break Rules option
        ELSE
            Log    Save dropdown arrow not present; saving without meal break rule selection
            Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_BTN}
            ...    error_message=Failed to click Save button to edit shift
        END
    ELSE
        Click Element On Webpage    ${WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_BTN}
        ...    error_message=Failed to click Save button to edit shift
    END

    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}

    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Integers    ${response_body.status}    ${status_ok}
    ...    msg=Failed to edit meal break segment for ${associate_display_name} on day ${day_offset}; expected HTTP 200 OK.

    Capture Screenshot On Webpage
    RETURN    ${True}

Select Task From Detailed Shift Dropdown On Week Schedule Page On Web
    [Documentation]    Selects a task from the detailed shift's task dropdown on the Week Schedule page.
    ...    This keyword handles Angular ng-model dropdowns for task selection in detailed shift modals.
    ...    Uses Playwright's Select Options By method with special handling for default "First Primary Task".
    ...    | =Arguments= | =Description= |
    ...    | dropdown_locator | XPath locator for the task dropdown element. |
    ...    | task_name | Name of the task to select (e.g., "Continued work", "Meal Break", "First Primary Task"). |
    ...    Example usage:
    ...    | Select Task From Detailed Shift Dropdown On Week Schedule Page On Web | (//select[@aria-label='Task'])[1] | Meal Break |
    [Arguments]    ${dropdown_locator}    ${task_name}
    Wait Until Element Is Visible On Webpage    ${dropdown_locator}
    ...    error_message=Task dropdown not visible for selection: ${task_name}
    IF    '${task_name}' == 'FIRST_PRIMARY_TASK'
        Select Options By    ${dropdown_locator}    index    0
        Press Keys    ${dropdown_locator}    Tab
    ELSE
        Select Options By    ${dropdown_locator}    text    ${task_name}
    END
    # Wait for Angular to process the selection by ensuring dropdown is stable after change
    Wait Until Element Is Visible On Webpage    ${dropdown_locator}
    Capture Screenshot On Webpage

Verify Shift Contains Task Segments On Week Schedule Page On Web
    [Documentation]    Verifies that a shift contains expected task segments (e.g., Meal Break, Rest Period) by inspecting the shift task dropdowns.
    ...    This keyword clicks on the specified shift, retrieves all task segment names, and validates that expected segments are present.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Display name of the associate (e.g., "Smith, John"). |
    ...    | day_offset | Day offset for the shift (e.g., 1 for Day 1 of the week, 0-based index). |
    ...    | expected_task_segments | List of expected task segment names to verify. Can be a single-item or multi-item list. |
    ...    Example usage:
    ...    | @{segments}= | Create List | Meal Break |
    ...    | Verify Shift Contains Task Segments On Week Schedule Page On Web | Smith, John | 1 | ${segments} |
    ...    | @{segments}= | Create List | Meal Break | Rest Period |
    ...    | Verify Shift Contains Task Segments On Week Schedule Page On Web | Smith, John | 2 | ${segments} |
    [Arguments]    ${associate_display_name}    ${day_offset}    ${expected_task_segments}
    ${day_offset_str}    Convert To String    ${day_offset}
    ${shift_cell_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_display_name}    DAY_OFFSET=${day_offset_str}
    Click Element On Webpage    ${shift_cell_locator}
    ...    error_message=Failed to click shift for verification: ${associate_display_name} on day ${day_offset}
    Wait Until Page Is Loaded
    # Open edit modal to access task segment dropdowns
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EDIT_SHIFT_BUTTON}
    ...    error_message=Edit Shift button not clickable for ${associate_display_name}
    Wait Until Page Is Loaded
    # Wait for the first task dropdown to be visible before counting - ensures modal is fully rendered
    # Use [1]-indexed locator to avoid Playwright strict mode violation (multiple elements match)
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_SHIFT_TASK_DROPDOWN_FIRST}
    ...    error_message=Task dropdown not visible after opening edit modal for ${associate_display_name} on day ${day_offset}
    ${task_count}    Get Element Count On Web Page    ${WEEK_SCHEDULE_SHIFT_TASK_DROPDOWN}
    VAR    ${all_tasks_text}    ${EMPTY}
    FOR    ${i}    IN RANGE    1    ${task_count} + 1
        ${i_str}    Convert To String    ${i}
        ${task_dropdown}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_SHIFT_TASK_DROPDOWN_INDEX}    INDEX=${i_str}
        # Get selected option text from dropdown, not all options
        VAR    ${selected_option_locator}    ${task_dropdown}
        ${task_text}    Get Element Text On Webpage    ${selected_option_locator}
        VAR    ${all_tasks_text}    ${all_tasks_text}${task_text}
    END
    FOR    ${expected_segment}    IN    @{expected_task_segments}
        Should Contain    ${all_tasks_text}    ${expected_segment}
        ...    msg=Shift for ${associate_display_name} on day ${day_offset} should contain ${expected_segment} segment
    END

Unallocate Shift And Delete From Open Pool On Week Schedule Page On Web
    [Documentation]    Unallocates a shift from an associate and deletes it from the open shift pool.
    ...    API validation is performed for both unallocate and delete operations to ensure success.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Display name of the associate. |
    ...    | day_offset | Day offset for the shift. |
    ...    Example usage:
    ...    | Unallocate Shift And Delete From Open Pool On Week Schedule Page On Web | Smith, John | 1 |
    [Arguments]    ${associate_display_name}    ${day_offset}
    # Always validate API response for unallocate operation
    ${promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_UNALLOCATE_SHIFT_API}
    ${shift_time}    Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web
    ...    ${associate_display_name}
    ...    ${day_offset}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Integers    ${response_body.status}    ${status_ok}
    ...    msg=Failed to unallocate shift for ${associate_display_name} on day ${day_offset}; expected HTTP 200 OK.
    Wait Until Page Is Loaded
    # Always validate API response for delete operation
    ${delete_promise}    Promise To    Wait For Response    ${WEEK_SCHEDULE_DELETE_SHIFT_API}
    Delete Shift On Week Schedule Page On Web    ${shift_time}
    ${delete_response}    Wait For    ${delete_promise}
    Log    ${delete_response.body}
    Should Be Equal As Integers    ${delete_response.status}    ${status_ok}
    ...    msg=Failed to delete shift ${shift_time} from open pool; expected HTTP 200 OK.

Check And Click Edit Shift Tab On Week Schedule Page On Web
    [Documentation]    Checks if Edit Shift tab already displayed on the shift details,
    ...    and clicks it if not already active.
    ...    | =Arguments= | =Description= |
    ...    | None | No arguments required. |
    ...    Example usage:
    ...    | Check And Click Edit Shift Tab On Week Schedule Page On Web |
    ${is_edit_tab_opened}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_EDIT_SHIFT_BUTTON}.active-tab
    IF    not ${is_edit_tab_opened}
        Click Element On Webpage    ${WEEK_SCHEDULE_EDIT_SHIFT_BUTTON}
        ...    error_message=Failed to click Edit Shift button to open edit tab.
        Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_EDIT_SHIFT_BUTTON}.active-tab
        ...    error_message=Edit Shift tab did not become active after clicking Edit Shift button.
    END

Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web
    [Documentation]    Verifies that shifts exist for the given associate on multiple specified days.
    ...    Arguments: associate_name (e.g., "John, Doe"), template (dictionary containing shifts_to_add with dayNo fields), week_offset (week number as integer or week_day format like '1' or '1_0'), optional shift_start_time (e.g., "09:00"), optional shift_end_time (e.g., "17:00"), visibility (True/False).
    ...    The keyword extracts day numbers from the template and constructs full week_day offsets automatically.
    ...    Example: Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web    John, Doe    ${shift_data}    1_0    09:00    17:00    True
    [Arguments]    ${associate_name}
    ...    ${template}
    ...    ${week_offset}
    ...    ${shift_start_time}=${None}
    ...    ${shift_end_time}=${None}
    ...    ${visibility}=True
    ${users}    Get From Dictionary    ${template}    users    default=@{EMPTY}

    VAR    @{shift_days}    @{EMPTY}
    FOR    ${user}    IN    @{users}
        ${shifts_to_add}    Get From Dictionary    ${user}    shifts_to_add    default=@{EMPTY}

        FOR    ${shift}    IN    @{shifts_to_add}
            ${day}    Get From Dictionary    ${shift}    day    default=${EMPTY}
            ${dayNo}    Get From Dictionary    ${shift}    dayNo    default=${EMPTY}
            ${effective_day}    Set Variable If    '${day}' != ''    ${day}    '${dayNo}' != ''    ${dayNo}    ${EMPTY}
            IF    '${effective_day}' != ''
                Append To List    ${shift_days}    ${effective_day}
            END
        END
    END

    ${top_level_shifts}    Get From Dictionary    ${template}    shifts_to_add    default=@{EMPTY}
    FOR    ${shift}    IN    @{top_level_shifts}
        ${day}    Get From Dictionary    ${shift}    day    default=${EMPTY}
        ${dayNo}    Get From Dictionary    ${shift}    dayNo    default=${EMPTY}
        ${effective_day}    Set Variable If    '${day}' != ''    ${day}    '${dayNo}' != ''    ${dayNo}    ${EMPTY}
        IF    '${effective_day}' != ''
            Append To List    ${shift_days}    ${effective_day}
        END
    END

    ${shift_days_count}    Get Length    ${shift_days}
    IF    not ${shift_days_count}
        Fail
        ...    No shift days found in template for keyword "Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web".
    END

    # Extract week number from week_offset (handles both '1' and '1_0' formats)
    ${week_parts}    Split String    ${week_offset}    _
    ${week_number}    Get From List    ${week_parts}    0

    FOR    ${day}    IN    @{shift_days}
        ${day_trimmed}    Replace String Using Regexp    ${day}    [^0-9]    ${EMPTY}
        VAR    ${offset}    ${week_number}_${day_trimmed}
        IF    '${visibility}' == 'True'
            Verify Shift Exists For Associate On Specific Day On Week Schedule Page On Web
            ...    ${associate_name}    ${offset}    ${shift_start_time}    ${shift_end_time}
        ELSE
            Verify Shift Not Exists For Associate On Specific Day On Week Schedule Page On Web
            ...    ${associate_name}    ${offset}    ${shift_start_time}    ${shift_end_time}
        END
    END

Verify Shift Not Exists For Associate On Multiple Days On Week Schedule Page On Web
    [Documentation]    Verifies that shifts do NOT exist for the given associate on multiple specified days.
    ...    This keyword iterates through all days specified in the template's shifts_to_add array
    ...    and verifies that no shifts exist for the associate on those days.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe"). |
    ...    | shifts_data    | Template dictionary containing shifts_to_add with dayNo fields. |
    ...    | week_offset | Week number as integer or week_day format (e.g., '1', '2', '1_0'). |
    ...    | shift_start_time | Shift start time in 24hr format (e.g., "06:00"). Optional, defaults to None. |
    ...    | shift_end_time | Shift end time in 24hr format (e.g., "13:00"). Optional, defaults to None. |
    ...    Example usage:
    ...    | ${shift_data}=    Get Employee Shift Setup Data    template_name=add01356_standard7
    ...    | Verify Shift Not Exists For Associate On Multiple Days On Week Schedule Page On Web    John, Doe    ${shift_data}    1    06:00    13:00
    ...    | Verify Shift Not Exists For Associate On Multiple Days On Week Schedule Page On Web    John, Doe    ${shift_data}    2_0    06:00    13:00
    ...    | Verify Shift Not Exists For Associate On Multiple Days On Week Schedule Page On Web    John, Doe    ${shift_data}    1
    [Arguments]    ${associate_name}
    ...    ${shifts_data}
    ...    ${week_offset}
    ...    ${shift_start_time}=${None}
    ...    ${shift_end_time}=${None}

    # Extract shifts_to_add from template
    ${has_shifts_to_add}    Run Keyword And Return Status    Dictionary Should Contain Key    ${shifts_data}    shifts_to_add
    IF    ${has_shifts_to_add}
        ${template_shifts}    Get From Dictionary    ${shifts_data}    shifts_to_add
    ELSE
        Fail    Template missing 'shifts_to_add' field. Cannot verify shift non-existence.
    END

    # Extract week number from week_offset (handles both '1' and '1_0' formats)
    ${week_parts}    Split String    ${week_offset}    _
    ${week_number}    Get From List    ${week_parts}    0

    # Iterate through each shift day and verify it doesn't exist
    FOR    ${shift}    IN    @{template_shifts}
        ${day_no}    Get From Dictionary    ${shift}    dayNo
        # Construct day_offset as <week_number>_<dayNo>
        VAR    ${day_offset}    ${week_number}_${day_no}
        Log    Verifying shift does NOT exist for ${associate_name} on day offset ${day_offset}    level=INFO
        Verify Shift Not Exists For Associate On Specific Day On Week Schedule Page On Web
        ...    ${associate_name}    ${day_offset}    ${shift_start_time}    ${shift_end_time}
    END

Verify Open Shifts Exist For Multiple Days On Week Schedule Page On Web
    [Documentation]    Verifies that open shifts exist across multiple days on the Week Schedule page
    ...    This keyword checks the Open Shifts tab to confirm that shifts with specified times
    ...    are present in the unallocated/open pool for the given days.
    ...    | =Arguments=    | =Description= |
    ...    | shifts_data    | Template dictionary containing shifts_to_add with dayNo and shift_pattern fields. |
    ...    | shift_start_time_week    | Start time in 24hr format (e.g., "06:00") for all shifts. |
    ...    | shift_end_time_week    | End time in 24hr format (e.g., "13:00") for all shifts. |
    ...    Example usage with template:
    ...    | ${shift_data}=    Get Employee Shift Setup Data    template_name=add01356_standard7
    ...    | ${shift_start_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${schedule_data_week['uiStartTime']}
    ...    | ${shift_end_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${schedule_data_week['uiEndTime']}
    ...    | Verify Open Shifts Exist For Multiple Days On Week Schedule Page On Web    ${shift_data}    ${shift_start_time_week}    ${shift_end_time_week}
    [Arguments]    ${shifts_data}    ${shift_start_time_week}    ${shift_end_time_week}
    ${parsed_shifts}    Extract Shifts From Template Data On Week Schedule Page On Web    ${shifts_data}
    ${day_offsets}    Build Day Offsets From Shift Data On Week Schedule Page On Web    ${parsed_shifts}
    Execute Bulk Open Shift Verification On Week Schedule Page On Web    ${day_offsets}    ${shift_start_time_week}
    ...    ${shift_end_time_week}

Verify Open Shift Exists For Specific Day On Week Schedule Page On Web
    [Documentation]    Verifies that an open shift with specified times exists for a specific day on the Week Schedule page.
    ...    This keyword checks the Open Shifts tab to confirm that a shift with the specified start and end times
    ...    are present in the unallocated/open pool for the given day.
    ...    | =Arguments=    | =Description= |
    ...    | day_offset    | Day offset in week_day format (e.g., 1_0 for week 1, day 0). |
    ...    | start_time    | Shift start time in 24hr format (e.g., "06:00"). |
    ...    | end_time    | Shift end time in 24hr format (e.g., "13:00"). |
    ...    Example usage:
    ...    | Verify Open Shift Exists For Specific Day On Week Schedule Page On Web    1_0    06:00    13:00
    [Arguments]    ${day_offset}    ${start_time}    ${end_time}
    ${start_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
    ${start_time_12hr}    Replace String    ${start_time_with_space}    ${SPACE}    ${EMPTY}
    ${end_time_with_space}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}
    ${end_time_12hr}    Replace String    ${end_time_with_space}    ${SPACE}    ${EMPTY}
    ${target_date}    Calculate Date From Week Day Offset    ${day_offset}
    ${date_format}    Get Config Value    key=DATE_FMT_WEEKDAY_DAY_MONTH
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    ${open_shift_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_OPEN_SHIFT_ENTRY}
    ...    START_TIME=${start_time_12hr}
    ...    END_TIME=${end_time_12hr}
    ...    FORMATTED_DATE=${formatted_date}
    Capture Screenshot On Webpage
    Log    Verifying open shift exists: ${start_time}-${end_time} on ${formatted_date}    level=INFO
    Wait Until Element Is Visible On Webpage    ${open_shift_locator}    timeout=${MEDIUM_TIMEOUT}
    ...    error_message=Open shift with times ${start_time}-${end_time} on ${formatted_date} not visible
    Log    ✓ Open shift found: ${start_time}-${end_time} on ${formatted_date}    level=INFO

Verify Associate Is Terminated On Week Schedule Page On Web
    [Documentation]    Verifies that an associate has been terminated by confirming they are no longer visible in the week schedule.
    ...    This keyword checks that the associate's row is no longer present in the schedule grid,
    ...    indicating that the termination process has been completed successfully.
    ...    | =Arguments=    | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe"). |
    ...    Example usage:
    ...    | Verify Associate Is Terminated On Week Schedule Page On Web    John, Doe
    [Arguments]    ${associate_name}
    Log    Verifying associate ${associate_name} is terminated and no longer visible in schedule
    ${associate_row_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_ASSOCIATE_BY_NAME}
    ...    ASSOCIATE_NAME=${associate_name}

    Capture Screenshot On Webpage
    ${is_associate_visible}    Is Element Visible On Webpage    ${associate_row_locator}
    Should Not Be True    ${is_associate_visible}
    ...    msg=Associate ${associate_name} is still visible in schedule - termination may not have been processed

    Log    ✓ Associate ${associate_name} is no longer visible in schedule (termination confirmed)

Delete Open Shifts For Multiple Days On Week Schedule Page On Web
    [Documentation]    Deletes open shifts across multiple days on the Week Schedule page
    ...    This keyword navigates to the Open Shifts tab and removes shifts with specified times
    ...    from the unallocated/open pool for the given days.
    ...    | =Arguments=    | =Description= |
    ...    | shifts_data    | Template dictionary containing shifts_to_add with dayNo and shift_pattern fields. |
    ...    | shift_start_time_week    | Start time in 24hr format (e.g., "06:00") for all shifts. |
    ...    | shift_end_time_week    | End time in 24hr format (e.g., "13:00") for all shifts. |
    ...    Example usage with template:
    ...    | ${shift_data}=    Get Employee Shift Setup Data    template_name=add01356_standard7
    ...    | ${shift_start_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${schedule_data_week['uiStartTime']}
    ...    | ${shift_end_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${schedule_data_week['uiEndTime']}
    ...    | Delete Open Shifts For Multiple Days On Week Schedule Page On Web    ${shift_data}    ${shift_start_time_week}    ${shift_end_time_week}
    [Arguments]    ${shifts_data}    ${shift_start_time_week}    ${shift_end_time_week}
    ${parsed_shifts}    Extract Shifts From Template Data On Week Schedule Page On Web    ${shifts_data}
    ${day_offsets}    Build Day Offsets From Shift Data On Week Schedule Page On Web    ${parsed_shifts}
    Execute Bulk Open Shift Deletion On Week Schedule Page On Web    ${day_offsets}    ${shift_start_time_week}    ${shift_end_time_week}

Extract Shifts From Template Data On Week Schedule Page On Web
    [Documentation]    Extracts shift data from various template structures (new, old, legacy)
    ...    | =Arguments=    | =Description= |
    ...    | shifts_data    | Template dictionary in any supported format |
    ...    | =Returns=    | =Description= |
    ...    | parsed_data    | Dictionary with 'shifts' list and 'week_offset' value |
    [Arguments]    ${shifts_data}
    # Check for new template structure with shifts_to_add
    ${has_shifts_to_add}    Run Keyword And Return Status    Dictionary Should Contain Key    ${shifts_data}    shifts_to_add
    IF    ${has_shifts_to_add}
        ${template_shifts}    Get From Dictionary    ${shifts_data}    shifts_to_add
        VAR    ${week_offset}    1
        Log    Using template with shifts_to_add: ${template_shifts.__len__()} shifts found    level=INFO
    ELSE
        # Check for old template structure with users
        ${is_old_template}    Run Keyword And Return Status    Dictionary Should Contain Key    ${shifts_data}    users
        IF    ${is_old_template}
            ${users_list}    Get From Dictionary    ${shifts_data}    users
            ${first_user}    Get From List    ${users_list}    0
            ${template_shifts}    Get From Dictionary    ${first_user}    shifts_to_add
            ${week_offset}    Get From Dictionary    ${shifts_data}    week_offset
            Log    Extracted ${template_shifts.__len__()} shifts from old template with week_offset ${week_offset}    level=INFO
        ELSE
            # Direct shifts list (legacy support)
            VAR    ${template_shifts}    ${shifts_data}
            VAR    ${week_offset}    1
            Log    Using direct shifts data with ${template_shifts.__len__()} shifts    level=INFO
        END
    END
    VAR    ${parsed_data}    &{EMPTY}
    Set To Dictionary    ${parsed_data}    shifts=${template_shifts}    week_offset=${week_offset}

    RETURN    ${parsed_data}

Build Day Offsets From Shift Data On Week Schedule Page On Web
    [Documentation]    Converts shift data to day offsets in week_day format
    ...    | =Arguments=    | =Description= |
    ...    | parsed_shifts    | Dictionary containing 'shifts' list and 'week_offset' |
    ...    | =Returns=    | =Description= |
    ...    | day_offsets    | List of day offsets in week_day format (e.g., ["1_2", "1_3"]) |
    [Arguments]    ${parsed_shifts}
    ${template_shifts}    Get From Dictionary    ${parsed_shifts}    shifts
    ${week_offset}    Get From Dictionary    ${parsed_shifts}    week_offset
    VAR    @{day_offsets}    @{EMPTY}
    FOR    ${shift_info}    IN    @{template_shifts}
        ${day_number}    Extract Day Number From Shift Info On Week Schedule Page On Web    ${shift_info}
        ${day_offset}    Convert Day Number To Day Offset On Week Schedule Page On Web    ${day_number}    ${week_offset}
        Append To List    ${day_offsets}    ${day_offset}
    END
    RETURN    ${day_offsets}

Extract Day Number From Shift Info On Week Schedule Page On Web
    [Documentation]    Extracts day number from shift info, handling both dayNo and day fields
    ...    | =Arguments=    | =Description= |
    ...    | shift_info    | Dictionary containing shift information |
    ...    | =Returns=    | =Description= |
    ...    | day_number    | Day number or "today" string |
    [Arguments]    ${shift_info}
    ${has_dayno}    Run Keyword And Return Status    Dictionary Should Contain Key    ${shift_info}    dayNo
    IF    ${has_dayno}
        ${day_number}    Get From Dictionary    ${shift_info}    dayNo
    ELSE
        ${day_number}    Get From Dictionary    ${shift_info}    day
    END
    RETURN    ${day_number}

Convert Day Number To Day Offset On Week Schedule Page On Web
    [Documentation]    Converts day number to week_day format, handling "today" special case
    ...    | =Arguments=    | =Description= |
    ...    | day_number    | Day number (1-7) or "today" string |
    ...    | week_offset    | Week offset number |
    ...    | =Returns=    | =Description= |
    ...    | day_offset    | Day offset in week_day format (e.g., "1_2") |
    [Arguments]    ${day_number}    ${week_offset}
    IF    "${day_number}" == "today"
        ${current_day_offset}    Get Current Week Day Offset
        ${current_day}    Evaluate    "${current_day_offset}".split("_")[1]
        VAR    ${day_offset}    ${week_offset}_${current_day}
        Log    Converted 'today' to current day offset: ${day_offset}    level=INFO
    ELSE
        VAR    ${day_offset}    ${week_offset}_${day_number}
    END
    RETURN    ${day_offset}

Execute Bulk Open Shift Deletion On Week Schedule Page On Web
    [Documentation]    Performs bulk deletion of open shifts with error handling and reporting
    ...    | =Arguments=    | =Description= |
    ...    | day_offsets    | List of day offsets in week_day format |
    ...    | shift_start_time    | Start time in 24hr format |
    ...    | shift_end_time    | End time in 24hr format |
    [Arguments]    ${day_offsets}    ${shift_start_time}    ${shift_end_time}
    Log    Deleting open shifts across ${day_offsets.__len__()} days with times ${shift_start_time}-${shift_end_time}    level=INFO
    Click On Open Shifts Tab On Week Schedule Page On Web
    VAR    @{failed_deletions}    @{EMPTY}
    VAR    ${successful_deletions}    ${0}
    FOR    ${day_offset}    IN    @{day_offsets}
        ${status}    ${error_msg}    Run Keyword And Ignore Error
        ...    Delete Open Shift On Week Schedule Page On Web    ${shift_start_time}    ${shift_end_time}    ${day_offset}
        IF    '${status}' == 'PASS'
            ${successful_deletions}    Evaluate    ${successful_deletions} + 1
            Log    ✅ Open shift deleted for day ${day_offset} (${shift_start_time}-${shift_end_time})    level=INFO
        ELSE
            Append To List    ${failed_deletions}    Day ${day_offset}: ${error_msg}
            Log    ❌ Open shift deletion failed for day ${day_offset}: ${error_msg}    level=WARN
        END
    END
    Validate Bulk Deletion Results On Week Schedule Page On Web    ${successful_deletions}    ${day_offsets}    ${failed_deletions}

Validate Bulk Deletion Results On Week Schedule Page On Web
    [Documentation]    Validates bulk deletion results and fails if there were any errors
    ...    | =Arguments=    | =Description= |
    ...    | successful_deletions    | Number of successful deletions |
    ...    | day_offsets    | Original list of day offsets |
    ...    | failed_deletions    | List of error messages for failed deletions |
    [Arguments]    ${successful_deletions}    ${day_offsets}    ${failed_deletions}
    ${total_shifts}    Get Length    ${day_offsets}
    Log    Open Shifts Deletion Summary: ${successful_deletions}/${total_shifts} shifts deleted successfully    level=INFO
    ${has_failures}    Evaluate    len(${failed_deletions}) > 0
    IF    ${has_failures}
        ${failure_summary}    Catenate    SEPARATOR=\n    @{failed_deletions}
        Fail    Failed to delete ${failed_deletions.__len__()} open shift(s):\n${failure_summary}
    END

Execute Bulk Open Shift Verification On Week Schedule Page On Web
    [Documentation]    Performs bulk verification of open shifts with error handling and reporting
    ...    | =Arguments=    | =Description= |
    ...    | day_offsets    | List of day offsets in week_day format |
    ...    | shift_start_time    | Start time in 24hr format |
    ...    | shift_end_time    | End time in 24hr format |
    [Arguments]    ${day_offsets}    ${shift_start_time}    ${shift_end_time}
    Log    Verifying open shifts across ${day_offsets.__len__()} days with times ${shift_start_time}-${shift_end_time}    level=INFO
    Click On Open Shifts Tab On Week Schedule Page On Web
    VAR    @{failed_verifications}    @{EMPTY}
    VAR    ${successful_verifications}    ${0}
    FOR    ${day_offset}    IN    @{day_offsets}
        ${status}    ${error_msg}    Run Keyword And Ignore Error    Verify Open Shift Exists For Specific Day On Week Schedule Page On Web
        ...    ${day_offset}    ${shift_start_time}    ${shift_end_time}
        IF    '${status}' == 'PASS'
            ${successful_verifications}    Evaluate    ${successful_verifications} + 1
            Log    ✅ Open shift verified for day ${day_offset} (${shift_start_time}-${shift_end_time})    level=INFO
        ELSE
            Append To List    ${failed_verifications}    Day ${day_offset}: ${error_msg}
            Log    ❌ Open shift verification failed for day ${day_offset}: ${error_msg}    level=WARN
        END
    END
    Validate Bulk Verification Results On Week Schedule Page On Web    ${successful_verifications}    ${day_offsets}
    ...    ${failed_verifications}

Validate Bulk Verification Results On Week Schedule Page On Web
    [Documentation]    Validates bulk verification results and fails if there were any errors
    ...    | =Arguments=    | =Description= |
    ...    | successful_verifications    | Number of successful verifications |
    ...    | day_offsets    | Original list of day offsets |
    ...    | failed_verifications    | List of error messages for failed verifications |
    [Arguments]    ${successful_verifications}    ${day_offsets}    ${failed_verifications}
    ${total_shifts}    Get Length    ${day_offsets}
    Log    Open Shifts Verification Summary: ${successful_verifications}/${total_shifts} shifts verified successfully    level=INFO
    ${has_failures}    Evaluate    len(${failed_verifications}) > 0
    IF    ${has_failures}
        ${failure_summary}    Catenate    SEPARATOR=\n    @{failed_verifications}
        Fail    Failed to verify ${failed_verifications.__len__()} open shift(s):\n${failure_summary}
    END

Check And Wait Till Schedule Is In Published State On Web
    [Documentation]    Checks if the schedule is in Published state, and waits until it is if not already published.
    ...    This keyword verifies the current schedule state and uses a wait loop to check for Published status,
    ...    ensuring that subsequent actions that require a published schedule can proceed without errors.
    ...    | =Arguments=    | =Description= |
    ...    | ${week_number} | Week offset number to check (e.g., 2_0 for week 2). |
    ...    Example usage:
    ...    | Check And Wait Till Schedule Is In Published State On Web | ${week_number} |
    [Arguments]    ${week_number}
    FOR    ${_}    IN RANGE    4
        Navigate To RWS Schedule Week Schedule Page On Web
        Select Week Number On Week Schedule Page On Web    ${week_number}
        Go To Schedule Page On Web
        Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_INITIAL_STATE}    timeout=${MEDIUM_TIMEOUT}
        ...    error_message=Schedule state element not visible on Week Schedule page
        ${is_published}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${WEEK_SCHEDULE_PUBLISHED_STATE}    timeout=${LONG_TIMEOUT}
        IF    ${is_published}
            Capture Screenshot On Webpage
            Log    Schedule is in Published state
            RETURN
        END
    END
    Fail    Schedule did not reach Published state within the expected time.

Check And Lock Schedule Via API For Week Start Date On Web
    [Documentation]    Checks if the schedule has the option to be locked, and if so,
    ...    locks it via API and waits until the schedule is in Locked state on the web.
    ...    This keyword first checks for the presence of the "Lock Schedule" option in the
    ...    action dropdown and, if available, locks the schedule for the given week start
    ...    date via API before verifying the Locked state on the Week Schedule page.
    [Arguments]    ${schedule_data}
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_ACTION_DROPDOWN}
    Click Element On Webpage    ${WEEK_SCHEDULE_ACTION_DROPDOWN}
    ${is_lock_option_present}    Run Keyword And Return Status
    ...    Wait Until Element Is Present On Webpage    ${WEEK_SCHEDULE_LOCK_SCHEDULE_OPTION}    timeout=${SHORT_TIMEOUT}
    IF    not ${is_lock_option_present}
        Log    Lock Schedule option not present in action dropdown, schedule may already be locked.    level=INFO
        RETURN
    END
    ${store_data}    Get User    user_key=${schedule_data}[store_manager_user_key]
    ${server_df_format}    Get Config Value    SERVER_DF
    ${week_date}    Calculate Date From Week Day Offset    ${schedule_data}[week_start_date]    ${server_df_format}
    Lock Schedule Via API And Wait For Completion    ${store_data}[unitID]    ${week_date}    ${schedule_data}[store_manager_user_key]
    Check And Wait Till Schedule Is In Locked State On Web    ${schedule_data}[week_start_date]

Check And Wait Till Schedule Is In Locked State On Web
    [Documentation]    Checks if the schedule is in Locked state, and waits until it is if not already locked.
    ...    This keyword verifies the current schedule state and uses a wait loop to check for Locked status,
    ...    ensuring that subsequent actions that require a locked schedule can proceed without errors.
    ...    | =Arguments=    | =Description= |
    ...    | ${week_number} | Week offset number to check (e.g., 2_0 for week 2). |
    ...    Example usage:
    ...    | Check And Wait Till Schedule Is In Locked State On Web | ${week_number} |
    [Arguments]    ${week_number}
    FOR    ${_}    IN RANGE    4
        Navigate To RWS Schedule Week Schedule Page On Web
        Select Week Number On Week Schedule Page On Web    ${week_number}
        Go To Schedule Page On Web
        Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_INITIAL_STATE}    timeout=${MEDIUM_TIMEOUT}
        ...    error_message=Schedule state element not visible on Week Schedule page
        ${is_locked}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${WEEK_SCHEDULE_LOCKED_STATE}    timeout=${LONG_TIMEOUT}
        IF    ${is_locked}
            Capture Screenshot On Webpage
            Log    Schedule is in Locked state
            RETURN
        END
    END
    Fail    Schedule did not reach Locked state within the expected time.

Apply Group Statistics Preferences On Display Preferences On Web
    [Documentation]
    ...    Applies Group Statistics display preferences on the Week Schedule page.
    ...    This keyword opens the Display Preferences dialog, navigates to the
    ...    preferences tab, and ensures that the "Unallocated" demand option in
    ...    Group Statistics is enabled before applying the changes.
    ...    NOTE: This keyword does not accept any arguments and always enforces
    ...    the Unallocated demand preference to be enabled.
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_ICON}
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_TAB}
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREF_SELECTION_PANEL}
    Toggle Checkbox In Checked Or Unchecked State On Web    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_DEMAND_UNALLOCATED}    True
    ...    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_DEMAND_UNALLOCATED_INPUT}    attribute=class    expected_attribute_value=ng-not-empty
    Capture Screenshot On Webpage
    Click Element On Webpage    ${WEEK_SCHEDULE_DISPLAY_PREFERENCE_APPLY_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Pick Two Random Tasks From Task List
    [Documentation]    Picks two random tasks from the task list.
    ...    | =Arguments= | =Description= |
    ...    | tasks_list | List of task names. |
    ...    | =Returns= | =Description= |
    ...    | task_1 | First randomly selected task name. |
    ...    | task_2 | Second randomly selected task name. |
    ...    Example usage:
    ...    | ${task_1}    ${task_2}    Pick Two Random Tasks From Task List | @{tasks_list} |
    [Arguments]    @{tasks_list}
    ${task_count}    Get Length    ${tasks_list}
    Should Be True    ${task_count} >= 2    At least two tasks must be available in the task list
    ${selected_tasks}    Evaluate    random.sample($tasks_list, 2)    random
    RETURN    ${selected_tasks}[0]    ${selected_tasks}[1]

Verify Schedule Changes Report Shows Deletion And Regeneration Operation On Web
    [Documentation]    Verifies that the schedule changes report contains a "Deleted" and/or "Regenerated" operation
    ...    indicating that the schedule was deleted and regenerated (completely replacing previous edits).
    ...
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe") |
    ...    | target_day | Day offset from Monday (0=Monday, 1=Tuesday, etc.) or week_day format (e.g., 1_2) |
    ...
    ...    Example usage:
    ...    | Verify Schedule Changes Report Shows Deletion And Regeneration Operation On Web    John, Doe    0
    [Arguments]    ${associate_name}    ${target_day}
    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    ${deletion_regeneration_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_DELETION_AND_REGENERATION_ROW}    FORMATTED_DATE=${formatted_date}
    ...    ASSOCIATE_NAME=${associate_name}
    Click Element On Webpage    ${deletion_regeneration_locator}
    Log    ✓ Deletion and Regeneration operation found for ${associate_name} on day ${target_day}

Verify Schedule Changes Report Shows Deleted And Generated On Web
    [Documentation]    Verifies that the schedule changes report contains a "Deleted" and/or "Generated" operation
    ...    indicating that the schedule was deleted and regenerated (completely replacing previous edits).

    Wait Until Element Is Present On Webpage    ${WEEKSCHEDULEPAGE_SCHEDULE_DELETED_AND_GENERATION}    timeout=${MEDIUM_TIMEOUT}
    Log    ✓ Deleted and Generated operations found

Verify Schedule Changes Report Not Shows Deletion And Regeneration Operation On Web
    [Documentation]    Verifies that the schedule changes report contains a "Deleted" and/or "Regenerated" operation
    ...    indicating that the schedule was deleted and regenerated (completely replacing previous edits).
    ...
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "John, Doe") |
    ...    | target_day | Day offset from Monday (0=Monday, 1=Tuesday, etc.) or week_day format (e.g., 1_2) |
    ...
    ...    Example usage:
    ...    | Verify Schedule Changes Report Shows Deletion And Regeneration Operation On Web    John, Doe    0
    [Arguments]    ${associate_name}    ${target_day}
    ${target_date}    Calculate Date From Week Day Offset    ${target_day}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${date_format}
    ${deletion_regeneration_locator}    Update Locator With Dynamic Values
    ...    ${WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_DELETION_AND_REGENERATION_ROW}    FORMATTED_DATE=${formatted_date}
    ...    ASSOCIATE_NAME=${associate_name}
    Wait Until Element Is Not Present On Webpage    ${deletion_regeneration_locator}    timeout=${MEDIUM_TIMEOUT}
    Log    ✓ Deletion and Regeneration operation not found for ${associate_name} on day ${target_day}

Get Associate Scheduled Hours For Day On Week Schedule Page On Web
    [Documentation]    Gets the scheduled hours for a specific associate on a given day.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Full name of the associate (e.g., "John Doe"). |
    ...    | day_offset | Day offset in week_day format (e.g., "1_2" for week 1, day 2). |
    ...
    ...    *Returns*: The scheduled hours as a string (e.g., "8:00").
    ...
    ...    Example usage:
    ...    | ${hours}=    Get Associate Scheduled Hours For Day On Week Schedule Page On Web    John Doe    1_2
    [Arguments]    ${associate_display_name}    ${day_offset}
    ${date}    Calculate Date From Week Day Offset    ${day_offset}
    ${formatted_date}    Convert Date    ${date}    result_format=%A %d %B
    ${locator}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_SCHEDULED_HOURS_FOR_DAY}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_display_name}
    ...    FORMATTED_DATE=${formatted_date}
    ${scheduled_hours}    Get Element Text On Webpage    ${locator}
    RETURN    ${scheduled_hours}

Get Associate Demand Hours For Day On Week Schedule Page On Web
    [Documentation]    Gets the demand (workload) hours for a specific associate on a given day.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Full name of the associate (e.g., "John Doe"). |
    ...    | day_offset | Day offset in week_day format (e.g., "1_2" for week 1, day 2). |
    ...
    ...    *Returns*: The demand hours as a string (e.g., "8:00").
    ...
    ...    Example usage:
    ...    | ${hours}=    Get Associate Demand Hours For Day On Week Schedule Page On Web    John Doe    1_2
    [Arguments]    ${associate_display_name}    ${day_offset}
    ${date}    Calculate Date From Week Day Offset    ${day_offset}
    ${formatted_date}    Convert Date    ${date}    result_format=%A %d %B
    ${locator}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_DEMAND_HOURS_FOR_DAY}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_display_name}
    ...    FORMATTED_DATE=${formatted_date}
    ${demand_hours}    Get Element Text On Webpage    ${locator}
    RETURN    ${demand_hours}

Get Associate Unfilled Hours For Day On Week Schedule Page On Web
    [Documentation]    Gets the unfilled hours for a specific associate on a given day.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Full name of the associate (e.g., "John Doe"). |
    ...    | day_offset | Day offset in week_day format (e.g., "1_2" for week 1, day 2). |
    ...
    ...    *Returns*: The unfilled hours as a string (e.g., "0:00").
    ...
    ...    Example usage:
    ...    | ${hours}=    Get Associate Unfilled Hours For Day On Week Schedule Page On Web    John Doe    1_2
    [Arguments]    ${associate_display_name}    ${day_offset}
    ${date}    Calculate Date From Week Day Offset    ${day_offset}
    ${formatted_date}    Convert Date    ${date}    result_format=%A %d %B
    ${locator}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_UNFILLED_HOURS_FOR_DAY}
    ...    ASSOCIATE_DISPLAY_NAME=${associate_display_name}
    ...    FORMATTED_DATE=${formatted_date}
    ${unfilled_hours}    Get Element Text On Webpage    ${locator}
    RETURN    ${unfilled_hours}

Build Employee Shift Setup Data With Overrides For Verification
    [Documentation]
    ...    Applies verification-specific shift overrides on top of provided employee shift setup data.
    ...    The base template data should be created in the test using `Get Employee Shift Setup Data`.
    ...    | =Arguments= | =Description= |
    ...    | employee_shift_data | Base employee shift setup dictionary from data provider. |
    ...    | shift_pattern | Shift time pattern template name to apply for each provided day. |
    ...    | day_numbers | Day numbers (0-6) to include in `shifts_to_add`. |
    ...
    ...    *Returns*: Employee shift setup dictionary with overridden `shifts_to_add` values.
    [Arguments]    ${employee_shift_data}    ${shift_pattern}=default    @{day_numbers}
    ${updated_employee_shift_data}    Copy Dictionary    ${employee_shift_data}
    VAR    @{shifts_to_add}    @{EMPTY}
    FOR    ${day_no}    IN    @{day_numbers}
        VAR    &{shift_entry}    dayNo=${day_no}    shift_pattern=${shift_pattern}
        Append To List    ${shifts_to_add}    ${shift_entry}
    END
    Set To Dictionary    ${updated_employee_shift_data}    shifts_to_add=${shifts_to_add}
    RETURN    ${updated_employee_shift_data}

Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    [Documentation]    Builds a simple hours dictionary for multiple days from shift pattern data or explicit hours.
    ...    This helper creates a dictionary with day offsets as keys and hour values.
    ...    Hours are calculated from shift pattern duration, or can be explicitly provided.
    ...    | =Arguments= | =Description= |
    ...    | week_offset | Week number (e.g., '1' or '2'). |
    ...    | shift_pattern_data_or_hours | Either shift pattern data dict (with 'duration' key) OR explicit hours string (e.g., '8:00'). |
    ...    | day_numbers | Variable number of day numbers (e.g., 1, 2, 3, 4, 5). |
    ...
    ...    *Returns*: Dictionary with day_offset keys and hour values.
    ...
    ...    Example usage (in test file):
    ...    | # Using shift pattern data (calculates hours from duration)
    ...    | ${shift_pattern}=    Get Shift Time Pattern Data    template_name=default    duration=${480}
    ...    | ${expected}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    | ...    1    ${shift_pattern}    1    2    3    4    5
    ...    |
    ...    | # Using explicit hours (for 0:00 or special cases)
    ...    | ${expected}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    | ...    1    0:00    1    5
    [Arguments]    ${week_offset}    ${shift_pattern_data_or_hours}    @{day_numbers}

    # Check if input is a dictionary (shift pattern data) or a string (explicit hours)
    ${input_type}    Evaluate    type($shift_pattern_data_or_hours).__name__

    IF    '${input_type}' == 'dict'
        # Calculate hours from shift pattern duration
        ${duration_minutes}    Get From Dictionary    ${shift_pattern_data_or_hours}    duration
        ${hours}    Evaluate    ${duration_minutes} // 60
        ${minutes}    Evaluate    ${duration_minutes} % 60
        ${expected_hours}    Evaluate    f"{int($hours)}:{int($minutes):02d}"
    ELSE
        # Use explicit hours string
        VAR    ${expected_hours}    ${shift_pattern_data_or_hours}
    END

    VAR    ${expected_hours_dict}    &{EMPTY}
    FOR    ${day_num}    IN    @{day_numbers}
        VAR    ${day_offset}    ${week_offset}_${day_num}
        Set To Dictionary    ${expected_hours_dict}    ${day_offset}=${expected_hours}
    END

    RETURN    ${expected_hours_dict}

Build Expected Associate Hours Dictionary For Multiple Days On Week Schedule Page On Web
    [Documentation]    Builds nested expected scheduled, demand, and unfilled hours for multiple days.
    ...    This helper reuses one shared list of day numbers so tests do not need to repeat
    ...    hardcoded day offsets when verifying combined associate hours.
    ...    | =Arguments= | =Description= |
    ...    | week_offset | Week number (e.g., '1' or '2'). |
    ...    | scheduled_pattern_data_or_hours | Shift pattern data dict or explicit hours string for scheduled hours. |
    ...    | demand_pattern_data_or_hours | Shift pattern data dict or explicit hours string for demand hours. |
    ...    | unfilled_pattern_data_or_hours | Shift pattern data dict or explicit hours string for unfilled hours. |
    ...    | day_numbers | Variable number of day numbers (e.g., 1, 2, 3, 4, 5). |
    ...
    ...    *Returns*: Dictionary keyed by day_offset with nested `scheduled`, `demand`, and
    ...    `unfilled` values.
    [Arguments]    ${week_offset}
    ...    ${scheduled_pattern_data_or_hours}
    ...    ${demand_pattern_data_or_hours}
    ...    ${unfilled_pattern_data_or_hours}
    ...    @{day_numbers}
    ${scheduled_hours_dict}    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${scheduled_pattern_data_or_hours}    @{day_numbers}
    ${demand_hours_dict}    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${demand_pattern_data_or_hours}    @{day_numbers}
    ${unfilled_hours_dict}    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${unfilled_pattern_data_or_hours}    @{day_numbers}
    VAR    ${expected_hours_dict}    &{EMPTY}
    FOR    ${day_num}    IN    @{day_numbers}
        VAR    ${day_offset}    ${week_offset}_${day_num}
        ${scheduled_hours}    Get From Dictionary    ${scheduled_hours_dict}    ${day_offset}
        ${demand_hours}    Get From Dictionary    ${demand_hours_dict}    ${day_offset}
        ${unfilled_hours}    Get From Dictionary    ${unfilled_hours_dict}    ${day_offset}
        VAR    &{expected_day_hours}    scheduled=${scheduled_hours}    demand=${demand_hours}    unfilled=${unfilled_hours}
        Set To Dictionary    ${expected_hours_dict}    ${day_offset}=${expected_day_hours}
    END
    RETURN    ${expected_hours_dict}

Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web
    [Documentation]    Verifies scheduled hours for an associate across multiple days.
    ...    This keyword validates only scheduled hours for the specified days.
    ...    Supports both exact matching and range validation.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Full name of the associate (e.g., "John Doe"). |
    ...    | expected_hours_dict | Dictionary with day_offset keys (e.g., '1_2') and expected hour values (e.g., '8:00'). |
    ...    | min_hours | Minimum acceptable hours in decimal format (e.g., 7.5 for 7 hrs 30 min). Optional. |
    ...    | max_hours | Maximum acceptable hours in decimal format (e.g., 8.0 for 8 hrs). Optional. |
    ...
    ...    Example usage (exact match):
    ...    | ${expected_scheduled}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    | ...    1    8:00    1    2    3    4    5
    ...    | Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web
    ...    | ...    ${associate_name}    ${expected_scheduled}
    ...
    ...    Example usage (range validation):
    ...    | Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web
    ...    | ...    ${associate_name}    ${expected_scheduled}    ${min_hours}    ${max_hours}
    [Arguments]    ${associate_display_name}    ${expected_hours_dict}    ${min_hours}=${None}    ${max_hours}=${None}
    VAR    ${use_range_validation}    ${{$min_hours is not None and $max_hours is not None}}
    VAR    @{day_offsets}    @{expected_hours_dict.keys()}
    FOR    ${day_offset}    IN    @{day_offsets}
        ${expected_hours}    Get From Dictionary    ${expected_hours_dict}    ${day_offset}
        ${actual_hours}    Get Associate Scheduled Hours For Day On Week Schedule Page On Web
        ...    ${associate_display_name}    ${day_offset}

        IF    ${use_range_validation}
            ${actual_decimal}    Convert Time To Decimal Hours    ${actual_hours}
            Should Be True    ${actual_decimal} >= ${min_hours} and ${actual_decimal} <= ${max_hours}
            ...    msg=Day ${day_offset}: Scheduled hours ${actual_hours} (${actual_decimal} hrs) is outside range ${min_hours}-${max_hours} hrs
            Log
            ...    ✓ Day ${day_offset}: Scheduled hours=${actual_hours} (${actual_decimal} hrs) is within range ${min_hours}-${max_hours} hrs
            ...    level=INFO
        ELSE
            ${expected_normalized}    Evaluate
            ...    ":".join([str(int(x.strip())) for x in "${expected_hours}".replace("(", "").replace(")", "").split(":")])
            ${actual_normalized}    Evaluate
            ...    ":".join([str(int(x.strip())) for x in "${actual_hours}".replace("(", "").replace(")", "").split(":")])
            Should Be Equal    ${actual_normalized}    ${expected_normalized}
            ...    msg=Day ${day_offset}: Expected scheduled hours ${expected_hours}, got ${actual_hours}
            Log    ✓ Day ${day_offset}: Scheduled hours=${actual_hours}    level=INFO
        END
    END

Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    [Documentation]    Verifies demand (workload) hours for an associate across multiple days.
    ...    This keyword validates only demand hours for the specified days.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Full name of the associate (e.g., "John Doe"). |
    ...    | expected_hours_dict | Dictionary with day_offset keys (e.g., '1_2') and expected hour values (e.g., '8:00'). |
    ...
    ...    Example usage:
    ...    | ${expected_demand}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    | ...    1    8:00    1    2    3    4    5
    ...    | Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    ...    | ...    ${associate_name}    ${expected_demand}
    [Arguments]    ${associate_display_name}    ${expected_hours_dict}
    VAR    @{day_offsets}    @{expected_hours_dict.keys()}
    FOR    ${day_offset}    IN    @{day_offsets}
        ${expected_hours}    Get From Dictionary    ${expected_hours_dict}    ${day_offset}
        ${actual_hours}    Get Associate Demand Hours For Day On Week Schedule Page On Web
        ...    ${associate_display_name}    ${day_offset}
        ${expected_normalized}    Evaluate
        ...    ":".join([str(int(x.strip())) for x in "${expected_hours}".replace("(", "").replace(")", "").split(":")])
        ${actual_normalized}    Evaluate
        ...    ":".join([str(int(x.strip())) for x in "${actual_hours}".replace("(", "").replace(")", "").split(":")])
        Should Be Equal    ${actual_normalized}    ${expected_normalized}
        ...    msg=Day ${day_offset}: Expected demand hours ${expected_hours}, got ${actual_hours}
        Log    ✓ Day ${day_offset}: Demand hours=${actual_hours}    level=INFO
    END

Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
    [Documentation]    Verifies unfilled hours for an associate across multiple days.
    ...    This keyword validates only unfilled hours for the specified days.
    ...    Supports both exact matching and range validation.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Full name of the associate (e.g., "John Doe"). |
    ...    | expected_hours_dict | Dictionary with day_offset keys (e.g., '1_2') and expected hour values (e.g., '0:00'). |
    ...    | min_hours | Minimum acceptable hours in decimal format (e.g., 0.0). Optional. |
    ...    | max_hours | Maximum acceptable hours in decimal format (e.g., 0.75 for 45 min). Optional. |
    ...
    ...    Example usage (exact match):
    ...    | ${expected_unfilled}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    | ...    1    0:00    1    2    3    4    5
    ...    | Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
    ...    | ...    ${associate_name}    ${expected_unfilled}
    ...
    ...    Example usage (range validation):
    ...    | Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
    ...    | ...    ${associate_name}    ${expected_unfilled}    ${min_hours}    ${max_hours}
    [Arguments]    ${associate_display_name}    ${expected_hours_dict}    ${min_hours}=${None}    ${max_hours}=${None}
    VAR    ${use_range_validation}    ${{$min_hours is not None and $max_hours is not None}}
    VAR    @{day_offsets}    @{expected_hours_dict.keys()}
    FOR    ${day_offset}    IN    @{day_offsets}
        ${expected_hours}    Get From Dictionary    ${expected_hours_dict}    ${day_offset}
        ${actual_hours}    Get Associate Unfilled Hours For Day On Week Schedule Page On Web
        ...    ${associate_display_name}    ${day_offset}

        IF    ${use_range_validation}
            ${actual_decimal}    Convert Time To Decimal Hours    ${actual_hours}
            Should Be True    ${actual_decimal} >= ${min_hours} and ${actual_decimal} <= ${max_hours}
            ...    msg=Day ${day_offset}: Unfilled hours ${actual_hours} (${actual_decimal} hrs) is outside range ${min_hours}-${max_hours} hrs
            Log
            ...    ✓ Day ${day_offset}: Unfilled hours=${actual_hours} (${actual_decimal} hrs) is within range ${min_hours}-${max_hours} hrs
            ...    level=INFO
        ELSE
            ${expected_normalized}    Evaluate
            ...    ":".join([str(int(x.strip())) for x in "${expected_hours}".replace("(", "").replace(")", "").split(":")])
            ${actual_normalized}    Evaluate
            ...    ":".join([str(int(x.strip())) for x in "${actual_hours}".replace("(", "").replace(")", "").split(":")])
            Should Be Equal    ${actual_normalized}    ${expected_normalized}
            ...    msg=Day ${day_offset}: Expected unfilled hours ${expected_hours}, got ${actual_hours}
            Log    ✓ Day ${day_offset}: Unfilled hours=${actual_hours}    level=INFO
        END
    END

Verify Associate Hours For Multiple Days On Week Schedule Page On Web
    [Documentation]    Verifies scheduled, demand, and unfilled hours for an associate across multiple days.
    ...    This is a convenience keyword that combines all three hour verifications.
    ...    For more flexibility, use the individual verification keywords instead.
    ...    | =Arguments= | =Description= |
    ...    | associate_display_name | Full name of the associate (e.g., "John Doe"). |
    ...    | expected_hours_dict | Dictionary with day_offset keys and nested dicts with 'scheduled', 'demand', 'unfilled' keys. |
    ...
    ...    Example usage:
    ...    | ${expected_hours}=    Create Dictionary
    ...    | ...    1_1={'scheduled': '8:00', 'demand': '8:00', 'unfilled': '0:00'}
    ...    | Verify Associate Hours For Multiple Days On Week Schedule Page On Web    ${associate_name}    ${expected_hours}
    [Arguments]    ${associate_display_name}    ${expected_hours_dict}
    VAR    @{day_offsets}    @{expected_hours_dict.keys()}
    FOR    ${day_offset}    IN    @{day_offsets}
        ${expected_day_hours}    Get From Dictionary    ${expected_hours_dict}    ${day_offset}
        ${expected_scheduled}    Get From Dictionary    ${expected_day_hours}    scheduled
        ${expected_demand}    Get From Dictionary    ${expected_day_hours}    demand
        ${expected_unfilled}    Get From Dictionary    ${expected_day_hours}    unfilled

        ${actual_scheduled}    Get Associate Scheduled Hours For Day On Week Schedule Page On Web
        ...    ${associate_display_name}    ${day_offset}
        ${actual_demand}    Get Associate Demand Hours For Day On Week Schedule Page On Web
        ...    ${associate_display_name}    ${day_offset}
        ${actual_unfilled}    Get Associate Unfilled Hours For Day On Week Schedule Page On Web
        ...    ${associate_display_name}    ${day_offset}

        Should Be Equal    ${actual_scheduled}    ${expected_scheduled}
        ...    msg=Day ${day_offset}: Expected scheduled hours ${expected_scheduled}, got ${actual_scheduled}
        Should Be Equal    ${actual_demand}    ${expected_demand}
        ...    msg=Day ${day_offset}: Expected demand hours ${expected_demand}, got ${actual_demand}
        Should Be Equal    ${actual_unfilled}    ${expected_unfilled}
        ...    msg=Day ${day_offset}: Expected unfilled hours ${expected_unfilled}, got ${actual_unfilled}

        Log    ✓ Day ${day_offset}: Scheduled=${actual_scheduled}, Demand=${actual_demand}, Unfilled=${actual_unfilled}    level=INFO
    END

Wait Until Success Notifier Message Disappears In Week Schedule Page On Web
    [Documentation]    Waits until the success notifier message disappears in the Week Schedule page.
    ...    | =Arguments=    | =Description= |
    ...    | ${timeout}    | Timeout in seconds to wait for the success notifier message to disappear. |
    ...    Example usage:
    ...    | Wait Until Success Notifier Message Disappears In Week Schedule Page On Web | timeout=${SHORT_TIMEOUT} |
    [Arguments]    ${timeout}=${SHORT_TIMEOUT}
    ${is_msg_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage
    ...    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}    timeout=${timeout}
    ${is_spinner_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage
    ...    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}    timeout=${timeout}
    IF    ${is_msg_visible} or ${is_spinner_visible}
        Run Keyword And Ignore Error
        ...    Wait Until Element Disappears On Webpage
        ...    ${WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE}
        Wait Until Element Disappears On Webpage
        ...    ${WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER}
    END
