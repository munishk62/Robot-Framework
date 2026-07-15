*** Settings ***
Documentation       Timecard page related keyword implementation

Resource            resources/web/common/common.resource
Variables           resources/web/rta/operations/timecard_page.py
Variables           resources/web/rta/operations/exception_management_page.py
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/ess/my_timecard.resource
Resource            resources/web/common/common_date_utility.resource
Variables           resources/web/common/utility.py


*** Keywords ***
Is Export Button Visible On Timecard Page On Web
    [Documentation]    This keyword checks if the export button is visible on the Timecard page
    ${is_visible}    Is Element Present On Webpage    ${TIMECARD_PAGE_EXPORT_BUTTON}
    Capture Screenshot On Webpage
    RETURN    ${is_visible}

Verify Export Button Functionality On Timecard Page On Web
    [Documentation]    This keyword verifies if the Timecard data is exported successfully
    Wait Until Element Is Present On Webpage    ${TIMECARD_PAGE_EXPORT_BUTTON}
    Click Element On Webpage    ${TIMECARD_PAGE_EXPORT_BUTTON}
    Wait Until Page Is Loaded
    ${home_page}    Switch To Page On Web    NEW    ${LONG_TIMEOUT}
    Switch To Page On Web    ${home_page}    ${LONG_TIMEOUT}
    @{all_pages}    Get Page Ids    ALL    ALL    ALL
    ${no_of_tabs}    Get Length    ${all_pages}
    Should Be True    ${no_of_tabs} > 1
    ${home_page}    Switch To Page On Web    NEW    ${LONG_TIMEOUT}
    ${new_tab_url}    Get Url
    Should Contain    ${new_tab_url}    servlet
    Capture Screenshot On Webpage
    Close Page    CURRENT    CURRENT    CURRENT
    Switch To Page On Web    ${home_page}    ${LONG_TIMEOUT}

Is Add Break Button Available On Timecard Page On Web
    [Documentation]    Keyword to check and return if Add Break button is displayed on Timecard page
    ${is_break_button_visible}    Is Element Visible On Webpage    ${TIMECARD_PAGE_ADD_BREAK_ICON}
    Capture Screenshot On Webpage
    RETURN    ${is_break_button_visible}

Get Available Shift Dates From Week Navigator On Timecard Page On Web
    [Documentation]    Prepare week dates from week navigator
    ...    Args:    ${input_date_format}: input format of the date
    ...    ${output_date_format}: output format of the date
    ...    Returns:    ${formatted_dates}: list of week dates in desired format (default: 'Mon mm/dd' format)
    ${current_week_from_page}    Get Element Text On Webpage    ${TIMECARD_PAGE_WEEK_NAVIGATOR}
    ${week_start_date}    ${week_end_date}    Extract Week Start End Dates    ${current_week_from_page}
    ${input_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR    default=%m/%d/%Y
    ${output_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY    default=%a %m/%d
    ${formatted_dates}    Generate Week Dates    ${week_start_date}
    ...    ${week_end_date}    ${input_date_format}    ${output_date_format}
    RETURN    ${formatted_dates}

Get Already Applied Shifts On Timecard Page On Web
    [Documentation]    Get already applied shifts on Timecard page
    ...    Returns:    ${total_shift_req_raised_elements_list}: list of already applied
    ${total_shift_req_raised_elements}    Get Elements    ${TIMECARD_PAGE_SCHEDULE_SHIFT_DATES}
    ${prefix}    Set Selector Prefix    ${None}
    VAR    @{total_shift_req_raised_elements_list}    @{EMPTY}
    # iterate over each row and get all applied week shifts
    FOR    ${element}    IN    @{total_shift_req_raised_elements}
        ${text}    Get Element Text On Webpage    ${element}
        Append To List    ${total_shift_req_raised_elements_list}    ${text}
    END
    Set Selector Prefix    ${prefix}
    RETURN    ${total_shift_req_raised_elements_list}

Get First Available Week On Timecard Page On Web
    [Documentation]    Get first available week to raise Shift request
    [Arguments]    ${week_to_apply_request}
    ${first_element}    Get First Element After Sorting Dates On Web    ${week_to_apply_request}
    ${day_numeric}    Extract Day Numeric From Week String On Web    ${first_element}
    RETURN    ${day_numeric}    ${first_element}

Get First Element After Sorting Dates On Web
    [Documentation]    Fetch first element after sorting dates.
    ...    Args:
    ...    ${date_list}: date list to fetch first element from
    ...    Returns:
    ...    ${first_element}: first element from sorted date list
    [Arguments]    ${date_list}
    ${sorted_dates}    Evaluate    sorted(${date_list})
    ${first_element}    Get From List    ${sorted_dates}    0
    RETURN    ${first_element}

Extract Day Numeric From Week String On Web
    [Documentation]    Keyword to extract day numeric from given week date string
    [Arguments]    ${week}
    ${result_format_day}    Get Config Value    DATE_FMT_DAY_ONLY
    ${week_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${day_numeric}    Convert Date    ${week}    result_format=${result_format_day}    date_format=${week_format}
    # Remove leading zeros from day numeric by converting through integer
    ${day_numeric_int}    Convert To Integer    ${day_numeric}
    ${extracted_day_value}    Convert To String    ${day_numeric_int}
    RETURN    ${extracted_day_value}

Check Todays Shift And Its Actuals Presence On Timecard Page On Web
    [Documentation]    check todays shift and its actuals presence on Timecard page
    [Arguments]    ${shift_request_week}
    # prepare dynamic week locator for shift request to raise
    ${week_locator}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_SHIFT_REQUEST_WEEK}
    ...    TEMP_WEEK=${shift_request_week}
    ${is_visible}    Is Element Present On Webpage    ${week_locator}
    VAR    ${is_actuals_present}    True
    IF    ${is_visible}
        # prepare dynamic actual locator
        ${week_locator_actuals}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_SHIFT_REQUEST_ACTUAL_WEEK}    TEMP_WEEK=${shift_request_week}
        Wait Until Element Is Visible On Webpage    ${week_locator_actuals}
        ${check_actual_value}    Get Property    ${week_locator_actuals}    textContent
        IF    '${check_actual_value.strip()}' == ''
            # If actual is blank, create shift request for current week
            VAR    ${is_actuals_present}    False
        END
    END
    RETURN    ${is_actuals_present}

Add Shift On Timecard Page On Web
    [Documentation]    Add Shift Workflow On Timecard Page On Web
    [Arguments]    ${day}
    ...    ${shift_request_week}
    ...    ${shift_data}
    ...    ${shift_end_date}=${None}
    ...    ${shift_to_be_added}=${None}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_ICON}
    Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_WINDOW}
    Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_START_DATE_ICON}
    ${day_locator_currentweek}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_SHIFT_DAY_CURRENT_WEEK}    TEMP_DAY=${day}
    Log    Shift Day: ${day}
    Log    Shift Week: ${shift_request_week}
    Wait Until Page Is Loaded
    ${is_visible}    Is Element Present On Webpage    ${day_locator_currentweek}
    IF    ${is_visible}
        Click Element On Webpage    ${day_locator_currentweek}
    ELSE
        Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DAY_NEXT_MONTH}
        Click Element On Webpage    ${day_locator_currentweek}
    END
    ${numeric_date}    Get Element Text On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_FROM_DATE_TXT_BOX_ON_POPUP}
    ${actuals_locator}    Update Locator With Dynamic Values    ${EXCEPTION_MANAGEMENT_PAGE_SHIFT_ACTUALS}    DATE=${numeric_date}
    ${actual_counts}    Get Element Count On Web Page    ${actuals_locator}
    Skip If    ${actual_counts}    msg=Shift already exists for the date ${shift_request_week}, skipping shift addition.
    IF    '${shift_end_date}' != '${None}'
        Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_END_DATE_ICON}
        ${shift_end_date_locator_currentweek}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_SHIFT_DAY_CURRENT_WEEK}    TEMP_DAY=${shift_end_date}
        ${is_visible_shift_end_date_currentweek}    Is Element Present On Webpage
        ...    ${shift_end_date_locator_currentweek}
        IF    ${is_visible_shift_end_date_currentweek}
            Click Element On Webpage    ${shift_end_date_locator_currentweek}
        ELSE
            IF    ${shift_to_be_added} == Previous_week
                Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DAY_PREV_MONTH}
                Click Element On Webpage    ${shift_end_date_locator_currentweek}
            END
            Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DAY_NEXT_MONTH}
            Click Element On Webpage    ${shift_end_date_locator_currentweek}
        END
    ELSE IF    'shift_end_date' in ${shift_data}
        Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_END_DATE_ICON}
        ${shift_end_date_locator_currentweek}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_SHIFT_DAY_CURRENT_WEEK}    TEMP_DAY=${shift_data}[shift_end_date]
        ${is_visible_shift_end_date_currentweek}    Is Element Present On Webpage
        ...    ${shift_end_date_locator_currentweek}
        IF    ${is_visible_shift_end_date_currentweek}
            Click Element On Webpage    ${shift_end_date_locator_currentweek}
        ELSE
            Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DAY_NEXT_MONTH}
            Click Element On Webpage    ${shift_end_date_locator_currentweek}
        END
    END
    Fill The Shift Details In Add Shift Pop Up On Timecard Page On Web    shift_data=${shift_data}
    Capture Screenshot On Webpage
    Click Element On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_BUTTON}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    Verify Success Notification Toast On Time Card Page On Web

Fill The Shift Details In Add Shift Pop Up On Timecard Page On Web
    [Documentation]
    ...    This keyword fills the shift details in the add shift pop-up on the timecard page.
    ...    | =Arguments= | =Description= |
    ...    | ${shift_data} | A dictionary containing shift details such as start_time, end_time, location, department, activity_code, reason_code, and staff_group. |
    [Arguments]    ${shift_data}
    Fill Textbox On Webpage    ${TIMECARD_PAGE_SHIFT_START_TIME}    ${shift_data}[start_time]
    Fill Textbox On Webpage    ${TIMECARD_PAGE_SHIFT_END_TIME}    ${shift_data}[end_time]
    Click Element On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_LOCATION}
    IF    'location' in ${shift_data}
        Select List Item On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_LOCATION}    text
        ...    ${shift_data}[location]
    ELSE
        Select List Item On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_LOCATION}    index
        ...    1
    END
    Click Element On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_DEPT}
    Wait Until Element Is Present On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_DEPT_FIRST_OPTION}
    IF    'department' in ${shift_data}
        Select List Item On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_DEPT}    text
        ...    ${shift_data}[department]
    ELSE
        Select List Item On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_DEPT}    index
        ...    1
    END
    ${is_visible_shift_activity_code}    Is Element Visible On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_ACTIVITY_CODE_MANDATORY_STAR}
    IF    ${is_visible_shift_activity_code}
        Click Element On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_ACTIVITY_CODE}
        ...    error_message=Activity code dropdown not clickable on add shift popup
        Wait Until Element Is Present On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_ACTIVITY_CODE_FIRST_OPTION}
        ...    error_message=Activity code dropdown options not loaded on add shift popup
        IF    'activity_code' in ${shift_data}
            Select List Item On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_ACTIVITY_CODE}    text
            ...    ${shift_data}[activity_code]
        ELSE
            Select List Item On Webpage    ${TIMECARD_PAGE_ADD_SHIFT_ACTIVITY_CODE}    attribute=index
            ...    value=1
        END
    END
    Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_SHIFT_REASON_CODE_DROPDOWN}
    Select List Item On Webpage    ${TIMECARD_PAGE_SHIFT_REASON_CODE_DROPDOWN}    text    ${shift_data}[reason_code]
    ${is_visible_shift_staff_group}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_STAFF_GROUP}
    IF    ${is_visible_shift_staff_group}
        IF    'staff_group' in ${shift_data}
            Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_STAFF_GROUP}    text
            ...    ${shift_data}[staff_group]
        ELSE
            Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_STAFF_GROUP}    attribute=index
            ...    value=1
        END
    END
    ${scheduled_task_visible}    Is Element Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_SCHEDULED_TASK}
    IF    ${scheduled_task_visible}
        Select List Item On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_SCHEDULED_TASK}    index    1
    END

Remove Shift On Timecard Page On Web
    [Documentation]    Remove Shift on Timecard page
    [Arguments]    ${shift_request_week}
    ${week_locator}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_SHIFT_REQUEST_WEEK}
    ...    TEMP_WEEK=${shift_request_week}
    ${is_visible}    Is Element Present On Webpage    ${week_locator}
    IF    ${is_visible}
        Click Element On Webpage    ${week_locator}
        ...    error_message=Week locator not visible on timecard page for week: ${shift_request_week}
        ${promise}    Promise To    Wait For Alert    action=accept    timeout=${MEDIUM_TIMEOUT}
        Click Element On Webpage    ${TIMECARD_PAGE_DELETE_SHIFT}    error_message=Delete shift button not clickable on timecard page
        ${alert_status}    Run Keyword And Return Status    Wait For    ${promise}
        IF    not ${alert_status}
            Select List Item On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_REASON_CODE}
            ...    index    1
            Capture Screenshot On Webpage
            Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_CONFIRMATION_YES}
            ...    error_message=Delete confirmation yes button not clickable on timecard page
        END
        Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
        ...    error_message=Save icon not visible after deleting shift on timecard page
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}    error_message=Save icon not clickable after deleting shift
        Verify Success Notification Toast On Time Card Page On Web
    END

Add Break For Shift On Timecard Page On Web
    [Documentation]    Add break workflow on Timecard page on web
    ...    | =Arguments= | =Description= |
    ...    | ${day} | The day numeric to add break for. |
    ...    | ${add_break_data} | From template, break details such as reason_code, break_start_time, and break_end_time. |
    ...    | ${timecard_reason} | (Optional) Specific reason code to select for the break. If not provided, it uses the one from add_break_data. |
    [Arguments]    ${day}    ${add_break_data}    ${timecard_reason}=${None}
    Click Element On Webpage    ${TIMECARD_PAGE_ADD_BREAK_ICON}
    Click Element On Webpage    ${TIMECARD_PAGE_ADD_BREAK_START_DATE_ICON}
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
    IF    '${timecard_reason}' != '${None}'
        Select List Item On Webpage    ${TIMECARD_PAGE_ADD_BREAK_REASON_CODE_DROPDOWN}    text    ${timecard_reason}
    ELSE
        Select List Item On Webpage    ${TIMECARD_PAGE_ADD_BREAK_REASON_CODE_DROPDOWN}    text    ${add_break_data}[reason_code]
    END
    Fill Textbox On Webpage    ${TIMECARD_PAGE_ADD_BREAK_START_TIME}    ${add_break_data}[break_start_time]
    Fill Textbox On Webpage    ${TIMECARD_PAGE_ADD_BREAK_END_TIME}    ${add_break_data}[break_end_time]
    Click Element On Webpage    ${TIMECARD_PAGE_ADD_BREAK_BUTTON}
    Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
    Verify Success Notification Toast On Time Card Page On Web
    Capture Screenshot On Webpage

Edit Break For Shift On Timecard Page On Web
    [Documentation]    Edit break workflow
    [Arguments]    ${shift_request_week}    ${edit_reason_code}=${None}
    ${week_locator}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_SHIFT_REQUEST_WEEK}    TEMP_WEEK=${shift_request_week}
    ${is_visible}    Is Element Present On Webpage    ${week_locator}
    IF    ${is_visible}
        Click Element On Webpage    ${week_locator}
        ${week_locator_department}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_EDIT_BREAK_DEPARTMENT_WEEK}    TEMP_WEEK=${shift_request_week}
        ${week_locator_reason_code}    Update Locator With Dynamic Values
        ...    ${TIMECARD_PAGE_EDIT_BREAK_REASON_CODE_WEEK}    TEMP_WEEK=${shift_request_week}
        Wait Until Element Is Visible On Webpage    ${week_locator_reason_code}
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
        Wait Until Element Is Visible On Webpage    ${week_locator_reason_code}
        Capture Screenshot On Webpage
    END

Delete Break For Shift On Timecard Page On Web
    [Documentation]    delete Break workflow
    ...    | =Arguments=    | =Description=    |
    ...    | shift_request_week | The week of the shift from which the break    |
    [Arguments]    ${shift_request_week}
    ...    ${timecard_reason}
    ...    ${break_end_time}
    ${break_end_time_12_hr_format}    Convert Time From 24 Hour To 12 Hour Format For Web    ${break_end_time}
    ${break_end}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_BREAK_END_SHIFT_WEEK_ROW}    TEMP_WEEK=${shift_request_week}
    ...    END_TIME=${break_end_time_12_hr_format}
    ${break_start}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_BREAK_START_SHIFT_WEEK_ROW}    TEMP_WEEK=${shift_request_week}
    ${is_visible}    Is Element Present On Webpage    ${break_start}
    IF    ${is_visible}
        Click Element On Webpage    ${break_start}    error_message=Break segment with start time locator not found for given week
        ${promise}    Promise To    Wait For Alert    action=accept    timeout=${MEDIUM_TIMEOUT}
        Click Element On Webpage    ${TIMECARD_PAGE_DELETE_BREAK}
        ...    error_message=Delete break button not clickable for given break segment
        ${alert_status}    Run Keyword And Return Status    Wait For    ${promise}
        IF    not ${alert_status}
            Select List Item On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_REASON_CODE}
            ...    text    ${timecard_reason}
            Click Element On Webpage    ${TIMECARD_PAGE_SHIFT_DELETE_YES_BTN}
            ...    error_message=Delete break confirmation button not clickable
        END
        Click Element On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN}
        ...    error_message=Save icon not clickable after deleting break segment
        Verify Success Notification Toast On Time Card Page On Web
        Wait Until Element Disappears On Webpage    ${break_end}
        Capture Screenshot On Webpage
    END

Open And Verify Accrual Balance Tab On Timecard Page On Web
    [Documentation]    This opens Accrual Balances tab of employee in its timecard and also verify whether it is visible
    Wait Until Element Is Present On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_BTN}
    Click Element On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_BTN}
    Wait Until Element Is Present On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_TAB}
    Capture Screenshot On Webpage
    ${accrual_balances_label}    Get Element Text On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_TAB}
    Should Not Be Empty    ${accrual_balances_label}    msg=Accrual Balances label is empty on Accrual Balances tab of Timecard page
    ${accrual_balance_tab_accrual_type}    Get Element Text On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_TAB_ACCRUAL_TYPE}
    Should Not Be Empty    ${accrual_balance_tab_accrual_type}
    ...    msg=Accrual Type field is not visible on Accrual Balances tab of Timecard page
    ${accrual_balance_tab_bal_date}    Get Element Text On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_TAB_BAL_DATE}
    Should Not Be Empty    ${accrual_balance_tab_bal_date}
    ...    msg=Balance Date field is not visible on Accrual Balances tab of Timecard page
    ${accrual_balance_tab_actual_bal}    Get Element Text On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_TAB_ACTUAL_BAL}
    Should Not Be Empty    ${accrual_balance_tab_actual_bal}
    ...    msg=Actual Balance field is not visible on Accrual Balances tab of Timecard page
    ${accrual_balance_tab_unit}    Get Element Text On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_TAB_UNIT}
    Should Not Be Empty    ${accrual_balance_tab_unit}    msg=Unit field is not visible on Accrual Balances tab of Timecard page

Close Accrual Balance Tab On Timecard Page On Web
    [Documentation]    This will close Accrual Balances tab on timecard
    Click Element On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_CLOSE}
    Wait Until Element Disappears On Webpage    ${TIMECARD_PAGE_ACCRUALBALANCE_TAB}    timeout=${SHORT_TIMEOUT}
    Capture Screenshot On Webpage

Add Shift For Day With No Actual Data Present On Timecard Page On Web
    [Documentation]    This Keyword will add shift for day with no actual data present on Timecard Page On Web
    [Arguments]    ${max_previous_week_to_iterate}    ${shift_data}
    FOR    ${week_index}    IN RANGE    0    ${max_previous_week_to_iterate}
        ${week_shift_dates_from_week_navigator}    Get Available Shift Dates From Week Navigator On Timecard Page On Web
        ${already_applied_shifts}    Get Already Applied Shifts On Timecard Page On Web
        ${week_to_apply_request}    Evaluate
        ...    list(set(${week_shift_dates_from_week_navigator}) ^ set(${already_applied_shifts}))
        ${count_of_week_to_apply_request}    Get Length    ${week_to_apply_request}
        IF    $count_of_week_to_apply_request >= 1
            ${day_numeric}    ${shift_request_week}    Get First Available Week On Timecard Page On Web    ${week_to_apply_request}
            Add Shift On Timecard Page On Web    ${day_numeric}    ${shift_request_week}    ${shift_data}
            RETURN    ${shift_request_week}
            BREAK
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
                    Add Shift On Timecard Page On Web    ${day_numeric}    ${shift_request_week}    ${shift_data}
                    VAR    ${shift_added_successfully}    True
                    RETURN    ${shift_request_week}
                    BREAK
                END
            END
            IF    not ${shift_added_successfully}
                # Shift To Previous Week Timecard Page Of User
                Click Element On Webpage    ${TIMECARD_PAGE_PREVIOUS_WEEK_BTN}
                Wait Until Page Is Loaded
                Capture Screenshot On Webpage
            END
        ELSE
            Log    No week available to apply shift or all weeks shifts are applied with actuals
        END
        # Previous Week Navigation Completed For Week Index: ${week_index+1}
        IF    ${week_index} + 1 == ${max_previous_week_to_iterate}
            Skip    max_previous_week_to_iterate reached the set limit, hence skipping test
        END
    END
    RETURN    ${shift_request_week}

Get Accrual Balance Value On Timecard Page On Web
    [Documentation]    This gets accrual balance value from accrual balance window on timecard page
    ...    | =Arguments= | =Description= |
    ...    | accrual_balance_type | The type of accrual balance for which the value needs to be fetched from timecard page. |
    ...    | =Returns= | =Description= |
    ...    | accrual_balance_value | Accrual balance value in timecard page |
    [Arguments]    ${accrual_balance_type}
    ${accrual_balance_locator}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_ACCRUALBALANCE_VALUE}
    ...    ACCRUAL_TYPE=${accrual_balance_type}
    Wait Until Element Is Visible On Webpage    ${accrual_balance_locator}
    ...    timeout=${MEDIUM_TIMEOUT}    error_message=Accrual balance value locator not visible for accrual type: ${accrual_balance_type}
    ${accrual_balance_text}    Get Element Text On Webpage    ${accrual_balance_locator}
    ${accrual_balance_string}    Find Text With Pattern    ${accrual_balance_text}    ^(\\d+\\.\\d+)
    ${accrual_balance_value}    Convert To Number    ${accrual_balance_string}
    RETURN    ${accrual_balance_value}

Navigate To Planning Week From Calendar On Timecard List Page On Web
    [Documentation]    This keyword navigates to the specified planning week from the calendar on the Timecard List Page
    ...    | =Arguments= | =Description= |
    ...    | ${week_start_date} | The start date of the week to navigate to (format: mm/dd/yyyy) |
    ...    Example Usage:
    ...    | Navigate To Planning Week From Calendar On Timecard List Page On Web    09/01/2023 |
    [Arguments]    ${week_start_date}
    Wait Until Element Is Visible On Webpage    ${TIMECARD_LISTPAGE_PREV_WEEK_BUTTON}
    Click Element On Webpage    ${TIMECARD_LISTPAGE_CURRENT_WEEK_BUTTON}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${week_start_date_formatted}    Calculate Date From Week Day Offset    ${week_start_date}    ${date_format}
    ${prev_week_date_element}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_WEEK_CALENDAR_LIST}
    ...    WEEK_START_DATE=${week_start_date_formatted}
    Click Element On Webpage    ${prev_week_date_element}
    Run Keyword And Ignore Error    Wait Until Element Disappears On Webpage
    ...    ${TIMECARD_LISTPAGE_CURRENT_WEEK_BUTTON}    timeout=${SHORT_TIMEOUT}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${TIMECARD_LISTPAGE_CURRENT_WEEK_BUTTON}
    ...    error_message=Current week button not visible on Timecard List Page after loading state

Verify The Audit Tab Details For The Performed Punch Transactions On Timecard Page On Web
    [Documentation]    This keyword verifies the audit tab details for the performed punch transactions
    ...    | =Arguments= | =Description= |
    ...    | ${start_time} | The start time of the punch transaction (format: HH:MM in 24-hour format) |
    ...    | ${start_date} | The start date of the punch transaction (format: mm/dd/yyyy) |
    ...    Example Usage:
    ...    | Verify The Audit Tab Details For The Performed Punch Transactions On Timecard Page On Web    13:00    09/01/2023 |
    [Arguments]    ${start_time}    ${start_date}    ${store_id}
    Switch To Audit Tab On My Timecard Page On Web
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${current_date}    Get Current Date As Per Specific Timezone    ${date_format}    ${store_id}
    ${date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${formatted_date}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}

    ${start_12hr}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
    # Extract just the time portion (HH:MM) from the 12-hour format by removing AM/PM markers and spaces
    # Handles single letter format (a/p), full format (am/pm/AM/PM), with or without spaces
    ${converted_start_time}    Replace String Using Regexp    ${start_12hr}    \\s*[apAP][mM]?\\s*$    ${EMPTY}
    ${converted_punch_time}    Replace String Using Regexp    ${converted_start_time}    ^0    ${EMPTY}
    ${deleted_audit_detail_locator}    Update Locator With Dynamic Values    ${MY_TIMECARD_PAGE_AUDIT_TAB_PUNCH_DELETED_INFO}
    ...    CURRENT_DATE=${current_date}    PUNCH_DATE=${formatted_date}    PUNCH_TIME=${converted_punch_time}
    Wait Until Element Is Visible On Webpage    ${deleted_audit_detail_locator}
    ${added_audit_detail_locator}    Update Locator With Dynamic Values    ${MY_TIMECARD_PAGE_AUDIT_TAB_PUNCH_ADDED_INFO}
    ...    CURRENT_DATE=${current_date}    PUNCH_DATE=${formatted_date}    PUNCH_TIME=${converted_punch_time}
    Wait Until Element Is Visible On Webpage    ${added_audit_detail_locator}
    Capture Screenshot On Webpage

Verify Success Notification Toast On Time Card Page On Web
    [Documentation]    Verifies that the notification message displayed on Exception Management page.
    ...    Example usage:
    ...    | Verify Success Notification Toast On Time Card Page On Web
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NOTIFICATION_MESSAGE}
    ...    timeout=${LONG_TIMEOUT}
    ...    error_message=Notification message did not appear within expected time after performing action on timecard page.
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_NOTIFICATION_MESSAGE}

Enter Employee Data In Employee Search Field On Time Card Page On Web
    [Documentation]    This keyword enters the given text in employee search field on Time Card Page on web
    ...    | =Arguments= | =Description= |
    ...    | emp_data | Input value to be used for searching the employee |
    [Arguments]    ${emp_data}
    Wait Until Element Is Visible On Webpage    ${TIMECARD_PAGE_EMPLOYEE_SEARCH_BOX}
    Clear Textbox On Webpage    ${TIMECARD_PAGE_EMPLOYEE_SEARCH_BOX}
    Fill Textbox On Webpage    ${TIMECARD_PAGE_EMPLOYEE_SEARCH_BOX}    ${emp_data}

Is Employee Displayed After Search On Time Card Page On Web
    [Documentation]    This keyword validates the search result after searching for an employee on Time Card Page on web
    ...    | =Arguments= | =Description= |
    ...    | emp_data | Input value to be used for searching the employee |
    [Arguments]    ${emp_data}
    ${employee_name_locator}    Update Locator With Dynamic Values    ${TIMECARD_PAGE_SEARCHED_EMPLOYEE}
    ...    SEARCH_INPUT=${emp_data}
    ${is_employee_visible}    Is Element Visible On Webpage    ${employee_name_locator}
    RETURN    ${is_employee_visible}

Search And Validate Employee Search On Time Card Page On Web
    [Documentation]    This keyword combines searching for an employee and validating the search result on Time Card Page on web
    ...    | =Arguments= | =Description= |
    ...    | emp_data | Input value to be used for searching the employee |
    [Arguments]    ${emp_data}
    ${is_search_field_visible}    Is Element Visible On Webpage    ${TIMECARD_PAGE_EMPLOYEE_SEARCH_BOX}
    IF    not ${is_search_field_visible}
        Click Element On Webpage    ${TIMECARD_PAGE_USER_ID_BUTTON}
    END
    Enter Employee Data In Employee Search Field On Time Card Page On Web    ${emp_data}
    ${is_matching_result_visible}    Is Employee Displayed After Search On Time Card Page On Web    ${emp_data}
    Capture Screenshot On Webpage
    RETURN    ${is_matching_result_visible}

Verify Week Navigator Bar Of Expected Date Displayed On Timecard Page On Web
    [Documentation]    This keyword verifies that the week navigator bar on timecard page is displaying the expected date based on the given offset
    ...    | =Arguments= | =Description= |
    ...    | date_offset | The offset in days from current week to calculate the expected date to be displayed on week navigator bar |
    [Arguments]    ${date_offset}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${expected_date}    Calculate Date From Week Day Offset    ${date_offset}    ${date_format}
    ${week_navigator_locator}    Update Locator With Dynamic Values
    ...    ${TIMECARD_PAGE_WEEK_NAVIGATOR_BAR}    EXPECTED_DATE=${expected_date}
    ${is_week_navigator_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${week_navigator_locator}    timeout=${LONG_TIMEOUT}
    Should Be True    ${is_week_navigator_visible}
    Log    Week navigator bar is displaying the expected date: ${expected_date} based on the given offset: ${date_offset}
