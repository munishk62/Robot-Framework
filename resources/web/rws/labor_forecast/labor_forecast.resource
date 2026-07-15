*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Labor Forecast page.
...
...                 = Purpose =
...                 - Centralizes actions for navigating, creating, and verifying labor forecasts.
...
...                 = Prerequisites =
...                 - Required libraries and variable files must be available and imported.

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/rws/labor_forecast/labor_forecast_page.py
Variables           resources/web/rws/labor_forecast/labor_forecast_page_api.py
Variables           resources/web/common/status_codes.py
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/common/calendar_navigation.resource
Resource            resources/web/common/common_date_utility.resource
Variables           resources/web/rws/schedule/fixed_shifts_page.py


*** Keywords ***
Navigate To RWS Labor Forecast Page On Web
    [Documentation]    Navigate To RWS -> Labor Forecast -> Labor Forecast Page
    ...    and verifies labor forecast heading at the top of the page
    Navigate To Specific Page On Web    rws    labor_forecast    labor_forecast

Select Week And Store On Labor Forecast Page On Web
    [Documentation]
    ...    Selects the specified fiscal week using the calendar picker and then selects the specified
    ...    store using the corporate unit filter on the Labor Forecast page.
    ...    Intercepts the workload details API response after the filter is applied to ensure
    ...    data is fully loaded before proceeding, eliminating intermittent failures caused by
    ...    relying solely on page load state.
    ...    | =Arguments= | =Description= |
    ...    | week_day_input | Date in week-day offset format (e.g., 1_0 for current week + 1, first day of that week). |
    ...    | store_name    | Display name of the store to filter for (e.g., 'Z Autostore001_STORE1'). |
    ...    Example usage:
    ...    | Select Week And Store On Labor Forecast Page On Web    1_0    Z Autostore001_STORE1
    [Arguments]    ${week_day_input}    ${store_id}
    Select Week Number On Labor Forecast Page On Web    ${week_day_input}
    Wait Until Page Is Loaded
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_CONTENT_TABLE}
    ...    error_message=Labor forecast workload table not visible after week selection
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_SELECT_UNIT_CORP_FILTER}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_FILTER_SEARCH_TXT_BOX}
    ${unit_search_promise}    Promise To    Wait For Response    ${LABOR_FORECAST_UNIT_SEARCH_API}
    ...    timeout=${LONG_API_TIMEOUT}
    Fill Textbox On Webpage    ${LABOR_FORECAST_PAGE_FILTER_SEARCH_TXT_BOX}    ${store_id}
    Wait For    ${unit_search_promise}
    ${expected_unit_in_search_result}    Update Locator With Dynamic Values
    ...    ${LABOR_FORECAST_PAGE_EXPECTED_DROPDOWN_SEARCH_RESULT}    UNIT_ID=${store_id}
    Wait Until Element Is Visible On Webpage    ${expected_unit_in_search_result}
    ...    error_message=Store search result not visible in unit filter dropdown for: ${store_id}
    Click Element On Webpage    ${expected_unit_in_search_result}
    ${api_response_promise}    Promise To    Wait For Response    ${LABOR_FORECAST_WORKLOAD_DETAILS_API}
    ...    timeout=${LONG_API_TIMEOUT}
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_FILTER_SEARCH_BTN}
    ${api_response}    Wait For    ${api_response_promise}
    Should Be True    ${api_response.status} in [${HTTP_STATUS_CODES}[OK]]
    ...    msg=Workload details API returned unexpected status ${api_response.status} after store filter applied
    Wait Until Element Is Present On Webpage    ${LABOR_FORECAST_PAGE_WKLD_SUMMARY}    timeout=${LONG_TIMEOUT}
    Capture Screenshot On Webpage

Select Store To Search Workload Values On Labor Forecast Page On Web
    [Documentation]    Select the store to search workload values by Store name.
    ...    | =Arguments= | =Description= |
    ...    | unit_name | Name of the unit to search for workload values |
    [Arguments]    ${unit_name}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_CONTENT_TABLE}
    ...    error_message=Labor forecast workload table not visible after week selection
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_SELECT_UNIT_CORP_FILTER}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_FILTER_SEARCH_TXT_BOX}
    Type Text    ${LABOR_FORECAST_PAGE_FILTER_SEARCH_TXT_BOX}    ${unit_name}
    ${expected_unit_in_search_result}    Update Locator With Dynamic Values
    ...    ${LABOR_FORECAST_PAGE_EXPECTED_DROPDOWN_SEARCH_RESULT}    UNIT_ID=${unit_name}
    Wait Until Element Is Visible On Webpage    ${expected_unit_in_search_result}
    ...    error_message=Store search result not visible in unit filter dropdown for: ${unit_name}
    Click Element On Webpage    ${expected_unit_in_search_result}
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_FILTER_SEARCH_BTN}
    Wait Until Page Is Loaded
    Wait Until Element Is Present On Webpage    ${LABOR_FORECAST_PAGE_WKLD_SUMMARY}    timeout=${LONG_TIMEOUT}
    Capture Screenshot On Webpage

Select The Future Week That Has Workload Values On Labor Forecast Page On Web
    [Documentation]    This keyword navigates through current and past week to check if workload
    ...    values are available and stays in that week where workload values are found. It will
    ...    check current week and past 3 weeks.
    ...    | =Arguments= | =Description= |
    ...    | store_id | ID of the store to search for workload values |
    ...    | =Returns= | =Description= |
    ...    | workload_value_present | Boolean flag which signifies if workload values are present |
    [Arguments]    ${store_id}=${None}
    VAR    ${workload_value_present}    False
    FOR    ${week_count_to_be_checked}    IN RANGE    1
        ${wkld_generated}    Check If Workload Is Generated On Labor Forecast Page On Web
        IF    ${wkld_generated}
            ${no_wkld_msg_displayed}    Check If Workload Data Not Found Message Displayed On Labor Forecast Page On Web
            IF    ${no_wkld_msg_displayed}
                Search For Workload Values For Future Week On Labor Forecast Page On Web    ${store_id}
            ELSE
                ${wkld_values_displayed}    Is Workload Values Displayed On Labor Forecast Page On Web
                IF    ${wkld_values_displayed}
                    ${workload_value_present}    Evaluate    not ${workload_value_present}
                    BREAK
                END
            END
        ELSE
            Search For Workload Values For Future Week On Labor Forecast Page On Web    ${store_id}
        END
        IF    ${week_count_to_be_checked} == 1
            Log    Workload value not found!!
        END
    END
    RETURN    ${workload_value_present}

Search For Workload Values For Previous Week On Labor Forecast Page On Web
    [Documentation]    This keyword navigates to previous week and searches for workload values
    ...    for the given store id.
    ...    | =Arguments= | =Description= |
    ...    | store_id | ID of the store to search for workload values |
    [Arguments]    ${store_id}
    ${selected_week}    Get Selected Week From Week Navigation On Labor Forecast Page On Web
    Log    Workload not available in the ${selected_week}. Checking in previous week...
    Go To The Previous Week On Labor Forecast Page On Web
    IF    '${store_id}' != '${None}'
        Select Store To Search Workload Values On Labor Forecast Page On Web    ${store_id}
    END

Search For Workload Values For Future Week On Labor Forecast Page On Web
    [Documentation]    This keyword navigates to future week and searches for workload values
    ...    for the given store id.
    ...    | =Arguments= | =Description= |
    ...    | store_id | ID of the store to search for workload values |
    [Arguments]    ${store_id}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_TABLE}
    ...    error_message=labor forecast workload table not visible
    ${selected_week}    Get Selected Week From Week Navigation On Labor Forecast Page On Web
    Log    Workload not available in the ${selected_week}. Checking in previous week...
    Navigate To Next Week On Labor Forecast Page On Web
    IF    '${store_id}' != '${None}'
        Select Store To Search Workload Values On Labor Forecast Page On Web    ${store_id}
    END

Open The Day View In Selected Week On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on the day as per the index passed to open the day view
    ...    for workload values.
    ...    | =Arguments= | =Description= |
    ...    | day_index | Index of the day to open in the week view |
    ...    | =Returns= | =Description= |
    ...    | day_label | Label of the day opened in the week view |
    [Arguments]    ${day_index}
    ${day_index}    Convert To String    ${day_index}
    ${day_of_week}    Update Locator With Dynamic Values    ${LABOR_FORECAST_PAGE_WEEKVIEW_DAY_OF_WEEK}
    ...    DAY_INDEX=${day_index}
    ${day_label}    Get Element Text On Webpage    ${day_of_week}
    Click Element On Webpage    ${day_of_week}
    RETURN    ${day_label}

Get Day View Workload Hours And Label On Labor Forecast Page On Web
    [Documentation]    This keyword gets the value of total workload hours in day view. You need to be
    ...    on the day view before you use this keyword.
    ...    | =Returns= | =Description= |
    ...    | total_wkld_hrs | Total workload hours for the day |
    ...    | day_label | Label of the day opened in the week view |
    ${total_wkld_hrs}    Get Element Text On Webpage    ${LABOR_FORECAST_PAGE_DAYVIEW_TOTAL_WKLD_HRS_OF_DAY}
    ${day_label}    Get Element Text On Webpage    ${LABOR_FORECAST_PAGE_DAYVIEW_DAY_LABEL}
    RETURN    ${total_wkld_hrs}    ${day_label}

Check If Workload Data Not Found Message Displayed On Labor Forecast Page On Web
    [Documentation]    This keyword returns true/false based on the visibility of the 'Workload Data Not Found'
    ...    message
    ...    | =Returns= | =Description= |
    ...    | no_wkld_msg_displayed | Boolean flag which signifies if 'Workload Data Not Found' message is displayed |
    ${no_wkld_msg_displayed}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_NO_WKLD_MSG}
    RETURN    ${no_wkld_msg_displayed}

Check If Workload Is Generated On Labor Forecast Page On Web
    [Documentation]
    ...    Verifies if workload is generated by checking for presence of activity rows.
    ...    Returns true if at least one workload activity row is displayed, false otherwise.
    ...    | =Returns= | =Description= |
    ...    | is_wkld_generated | Boolean flag which signifies if workload activities are displayed |
    ...    Example usage:
    ...    | ${wkld_generated}=    Check If Workload Is Generated On Labor Forecast Page On Web
    FOR    ${_}    IN RANGE    10
        ${is_no_data_msg}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${LABOR_FORECAST_PAGE_WKLD_NOT_GENERATED_MSG}    timeout=${SHORT_TIMEOUT}
        ${is_wkld_generated}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    (${LABOR_FORECAST_PAGE_WORKLOAD_ROW_ACTIVITIES})[1]    timeout=${SHORT_TIMEOUT}
        IF    ${is_no_data_msg}
            RETURN    ${FALSE}
        ELSE IF    ${is_wkld_generated}
            RETURN    ${TRUE}
        END
    END
    RETURN    ${FALSE}

Get Selected Week From Week Navigation On Labor Forecast Page On Web
    [Documentation]    This keyword gets the week date from week navigation.
    ...    | =Returns= | =Description= |
    ...    | selected_week | The label of the selected week |
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_TABLE}    timeout=${SHORT_TIMEOUT}
    ...    error_message=labor forecast workload table not visible
    ${selected_week}    Get Element Text On Webpage    ${LABOR_FORECAST_PAGE_CAL_NAV_DATE_LABEL}
    RETURN    ${selected_week}

Go To The Previous Week On Labor Forecast Page On Web
    [Documentation]    This keyword navigates the user to previous week for checking the workload values.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_PREVIOUS_WEEK_BTN}
    Wait Until Element Disappears On Webpage    ${LABOR_FORECAST_PAGE_PREVIOUS_WEEK_BTN}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_PREVIOUS_WEEK_BTN}
    Wait Until Page Is Loaded

Is Workload Values Displayed On Labor Forecast Page On Web
    [Documentation]    This keyword returns true/false based on the visibility of workload values
    ...    on Labor Forecast page.
    ...    | =Returns= | =Description= |
    ...    | wkld_value_visible | Boolean flag which signifies if workload values are visible |
    VAR    ${wkld_value_visible}    False
    WHILE    not ${wkld_value_visible}    limit=${LOOP_TIMEOUT}
        ${wkld_value_rows}    Get Element Count    ${LABOR_FORECAST_PAGE_WKLD_VALUES_FOR_UNIT}
        IF    ${wkld_value_rows} > 0
            ${wkld_value_visible}    Evaluate    not ${wkld_value_visible}
            BREAK
        END
    END
    RETURN    ${wkld_value_visible}

Get Week View Workload Hours For Day On Labor Forecast Page On Web
    [Documentation]    This keyword gets the value of total workload hours for the selected day (as per index)
    ...    in the week view.
    ...    | =Arguments= | =Description= |
    ...    | day_index | Index of the day to get workload hours |
    ...    | =Returns= | =Description= |
    ...    | total_wkld_hrs | Total workload hours for the day |
    [Arguments]    ${day_index}
    ${day_index}    Convert To String    ${day_index}
    ${total_wkld_hrs_of_day}    Update Locator With Dynamic Values
    ...    ${LABOR_FORECAST_PAGE_WEEKVIEW_TOTAL_WKLD_HRS_OF_DAY}    DAY_INDEX=${day_index}
    ${total_wkld_hrs}    Get Element Text On Webpage    ${total_wkld_hrs_of_day}
    RETURN    ${total_wkld_hrs}

Get Day Index With Workload Hours On Labor Forecast Page On Web
    [Documentation]    This keyword returns the day index where total workload hours is not zero.
    ...    If all days have zero workload hours, it returns -1.
    ...    | =Returns= | =Description= |
    ...    | day_index | Index of the day where total workload hours is present, -1 if none found |
    VAR    ${wkld_day_index}    -1
    FOR    ${day_index}    IN RANGE    1    8
        ${day_index_str}    Convert To String    ${day_index}
        ${total_wkld_hrs_for_day}    Update Locator With Dynamic Values
        ...    ${LABOR_FORECAST_PAGE_WEEKVIEW_TOTAL_WKLD_HRS_OF_DAY}    DAY_INDEX=${day_index_str}
        ${total_wkld_hrs}    Get Element Text On Webpage    ${total_wkld_hrs_for_day}
        IF    '${total_wkld_hrs}' != '0.00' and '${total_wkld_hrs}' != ''
            ${wkld_day_index}    Get Variable Value    ${day_index}
            BREAK
        END
    END
    RETURN    ${wkld_day_index}

Verify Week Navigation On Labor Forecast Page On Web
    [Documentation]
    ...    Navigates backward and forward on labor forecast page using calendar navigator.
    ...    Verifies that the week navigation functions correctly in both directions.
    ...    | =Arguments= | =Description= |
    ...    | number_of_weeks_to_navigate | Number of steps to navigate in each direction |
    ...    Example usage:
    ...    | Verify Week Navigation On Labor Forecast Page On Web    2
    [Arguments]    ${number_of_weeks_to_navigate}

    Navigate Calendar By Weeks And Verify Navigated Week
    ...    ${NAVIGATION_DIRECTION_FORWARD}
    ...    ${number_of_weeks_to_navigate}
    ...    ${LABOR_FORECAST_PAGE_FORWARD_ARROW}
    ...    ${LABOR_FORECAST_PAGE_BACKWARD_ARROW}
    ...    ${LABOR_FORECAST_PAGE_SELECTED_WEEK}

    Navigate Calendar By Weeks And Verify Navigated Week
    ...    ${NAVIGATION_DIRECTION_BACKWARD}
    ...    ${number_of_weeks_to_navigate}
    ...    ${LABOR_FORECAST_PAGE_FORWARD_ARROW}
    ...    ${LABOR_FORECAST_PAGE_BACKWARD_ARROW}
    ...    ${LABOR_FORECAST_PAGE_SELECTED_WEEK}

Click On Sort Preference Icon On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on Sort preference icon on Labor Forecast page.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_SORT_PREFERENCE_ICON}
    Wait Until Page Is Loaded

Click On Sort Preference Tab On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on Sort preference on Labor Forecast page.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_SORT_PREFERENCE_TAB}
    Wait Until Page Is Loaded

Set Sort Preference With Option On Labor Forecast Page On Web
    [Documentation]    This keyword set sort preference on Labor Forecast page with passing argument as sort_parameter total, Staff group, department, task
    [Arguments]    ${sort_parameter}
    Click On Sort Preference Tab On Labor Forecast Page On Web
    IF    '${sort_parameter}' == 'Total'
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_TOTAL_SORT_PREFERENCE_RADIO_BTN}
    ELSE IF    '${sort_parameter}' == 'Staff Group'
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_STAFF_GRP_SORT_PREFERENCE_RADIO_BTN}
    ELSE IF    '${sort_parameter}' == 'Department'
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_DEPT_SORT_PREFERENCE_RADIO_BTN}
    ELSE IF    '${sort_parameter}' == 'Task'
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_TASK_SORT_PREFERENCE_RADIO_BTN}
    END
    Click On Apply Sort Button On Labor Forecast Page On Web
    Wait Until Page Is Loaded

Verify Task Name Is Visible On Labor Forecast Page On Web
    [Documentation]    This keyword verifies task name is visible on Labor Forecast page.
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_ROW}
    ${is_task_name_visible}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_TASK_NAME}
    Capture Screenshot On Webpage
    Should Be True    ${is_task_name_visible}    Task name is not displayed

Verify Staff Group Is Visible On Labor Forecast Page On Web
    [Documentation]    This keyword verifies staff group is visible on Labor Forecast page.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_STAFF_GROUP}
    ${is_staff_group_visible}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_STAFF_GROUP}
    Capture Screenshot On Webpage
    Should Be True    ${is_staff_group_visible}    Staff group is not displayed

Verify Task Name Is Not Visible On Labor Forecast Page On Web
    [Documentation]    This keyword verifies task name is not visible on Labor Forecast page.
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_ROW}
    ${is_task_name_visible}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_TASK_NAME}
    Capture Screenshot On Webpage
    Should Not Be True    ${is_task_name_visible}    Task name is displayed

Reset Sort Preference On Labor Forecast Page On Web
    [Documentation]    This keyword reset sort preference on Labor Forecast page with default.
    Click On Sort Preference Icon On Labor Forecast Page On Web
    Click On Sort Preference Tab On Labor Forecast Page On Web
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_SORT_RESET_BTN}
    Click On Apply Sort Button On Labor Forecast Page On Web
    Wait Until Page Is Loaded

Navigate To Next Week On Labor Forecast Page On Web
    [Documentation]    This keyword navigates the user to next week for checking the workload values.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_FORWARD_WEEK_BTN}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_TABLE}
    ...    error_message=labor forecast workload table not visible
    Run Keyword And Ignore Error    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    Capture Screenshot On Webpage

Click On Apply Sort Button On Labor Forecast Page On Web
    [Documentation]    This keyword clicks apply button on sort preference
    ...    on Labor Forecast page.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_SORT_APPLY_BTN}
    Wait Until Page Is Loaded

Click On Display Preference Icon On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on display preference icon on Labor Forecast page.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_DISPLAY_PREF_ICON}
    Wait Until Page Is Loaded

Click On Short Name Button In Display Preference On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on short name option button display preference on Labor Forecast page.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_SHORT_NAME_DISPLAY_PREF_RADIO_BTN}
    Wait Until Page Is Loaded

Click On Display Preference Tab On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on display preference tab on Labor Forecast page.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_DISPLAY_PREF_TAB}
    Wait Until Page Is Loaded

Click On Apply Button On Labor Forecast Page On Web
    [Documentation]    This keyword clicks apply button on display preference
    ...    on Labor Forecast page.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_APPLY_BTN}
    Wait Until Page Is Loaded

Set Display Preference With Short Name On Labor Forecast Page On Web
    [Documentation]    This keyword set display preference on Labor Forecast page with short name.
    Click On Display Preference Tab On Labor Forecast Page On Web
    Click On Short Name Button In Display Preference On Labor Forecast Page On Web
    Click On Apply Button On Labor Forecast Page On Web
    Wait Until Page Is Loaded

Verify Display Preference With Short Name Is Visible On Labor Forecast Page On Web
    [Documentation]    This keyword verifies display preference on Labor Forecast page with short name.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_ROW}
    ${is_short_name_visible}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_SHORT_NAME}
    Should Be True    ${is_short_name_visible}    Short Name is not visible
    Capture Screenshot On Webpage

Verify Display Preference With Short Name Is Not Visible On Labor Forecast Page On Web
    [Documentation]    This keyword verifies display preference on Labor Forecast page with short name.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_ROW}
    ${is_short_name_visible}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_SHORT_NAME}
    Should Not Be True    ${is_short_name_visible}    Short Name is visible
    Capture Screenshot On Webpage

Reset Display Preference On Labor Forecast Page On Web
    [Documentation]    This keyword reset display preference on Labor Forecast page with default.
    Click On Display Preference Icon On Labor Forecast Page On Web
    Click On Display Preference Tab On Labor Forecast Page On Web
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_RESET_BTN}
    Click On Apply Button On Labor Forecast Page On Web

Get Count Of Task Name On Labor Forecast Page On Web
    [Documentation]    This keyword gets the count of task name displayed on labor forecast page.
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_ROW}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_TOTAL_WORKLOAD}
    Wait Until Element Is Visible On Webpage    (${LABOR_FORECAST_PAGE_TASK_NAME_COUNT})[1]    timeout=${LONG_TIMEOUT}
    ...    error_message=Task name count not visible
    Run Keyword And Ignore Error    Wait Until Element Disappears On Webpage
    ...    (${LABOR_FORECAST_PAGE_TASK_NAME_COUNT})[1]    timeout=${SHORT_TIMEOUT}
    ${task_name_count}    Get Element Count On Web Page    ${LABOR_FORECAST_PAGE_TASK_NAME_COUNT}
    Capture Screenshot On Webpage
    RETURN    ${task_name_count}

Reset The Advance Filter Settings On Labor Forecast Page On Web
    [Documentation]    This keyword reset advance filter settings on Labor Forecast page with default.
    # Click On Advance Filter Icon On Labor Forecast Page On Web
    Click On Advance Filter Settings Tab On Labor Forecast Page On Web
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_ADVANCE_FILTER_RESET_BTN}
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_ADVANCE_FILTER_APPLY_BTN}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_ROW}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_TOTAL_WORKLOAD}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_CONTAINER}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_CONTAINER_LAZY_LOAD}
    Wait Until Page Is Loaded

Get Tasks In Advanced Filter On Labor Forecast Page On Web
    [Documentation]    This keyword gets the list of tasks in advanced filter Labor Forecast Page On Web
    VAR    @{tasks}    @{EMPTY}
    ${task_elements}    Get Elements    ${LABOR_FORECAST_PAGE_STAFF_GROUP_DROPDOWN}
    FOR    ${task_element}    IN    @{task_elements}
        ${task_name}    Get Element Text On Webpage    ${task_element}
        Append To List    ${tasks}    ${task_name}
    END
    @{task}    Split String    ${tasks}[0]    \n
    RETURN    @{task}

Get Activities In Advanced Filter On Labor Forecast Page On Web
    [Documentation]    This keyword gets the list of activities in advanced filter Labor Forecast Page On Web
    ${is_filter_panel_present}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_FILTER_PANEL}
    IF    not ${is_filter_panel_present}
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_ADVANCE_SEARCH_ICON}
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_FILTER_SETTINGS}
        Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_FILTER_PANEL}
    END
    @{activity}    Get All Options From Dropdown On Web    ${LABOR_FORECAST_PAGE_ACTIVITY_DROPDOWN}
    RETURN    @{activity}

Select Staff Group In Advanced Filter On Labor Forecast Page On Web
    [Documentation]    This keyword selects the staff group in advanced filter Labor Forecast Page On Web
    [Arguments]    ${staff_grp}
    ${staff_grp_option}    Update Locator With Dynamic Values
    ...    ${LABOR_FORECAST_PAGE_STAFF_GROUP_DROPDOWN_SELECT}    STAFF_GRP=${staff_grp}
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_STAFF_GROUP_DROPDOWN}
    Keyboard Key    down    Control
    Click Element On Webpage    ${staff_grp_option}

Select Activity In Advanced Filter On Labor Forecast Page On Web
    [Documentation]
    ...    Selects the specified activity in the advanced filter on the Labor Forecast page.
    ...    | =Arguments= | =Description= |
    ...    | activity    | Name of the activity to select in the advanced filter. |
    [Arguments]    ${activity1}    ${activity2}
    ${activity_option1}    Update Locator With Dynamic Values
    ...    ${LABOR_FORECAST_PAGE_ACTIVITY_DROPDOWN_SELECT}    ACTIVITY=${activity1}
    Wait Until Page Is Loaded
    ${is_filter_panel_present}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_FILTER_PANEL}
    IF    not ${is_filter_panel_present}
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_ADVANCE_SEARCH_ICON}
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_FILTER_SETTINGS}
        Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_FILTER_PANEL}
    END
    Keyboard Key    down    Control
    Click Element On Webpage    ${activity_option1}
    Capture Screenshot On Webpage
    ${activity_option2}    Update Locator With Dynamic Values
    ...    ${LABOR_FORECAST_PAGE_ACTIVITY_DROPDOWN_SELECT}    ACTIVITY=${activity2}
    Keyboard Key    down    Control
    Click Element On Webpage    ${activity_option2}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Click On Advance Filter Apply Button On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on advance filter apply button on Labor Forecast page.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_ADVANCE_FILTER_APPLY_BTN}
    Capture Screenshot On Webpage

Click On Advance Filter Icon On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on advance filter icon on Labor Forecast page.
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_ROW}
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_ADVANCE_SEARCH_ICON}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_ADVANCE_FILTER_PANEL}
    Capture Screenshot On Webpage

Click On Advance Filter Settings Tab On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on advance filter tab on Labor Forecast page.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_ROW}
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_ADVANCE_SEARCH_ICON}
    ${is_saved_filter_present}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_SAVED_FILTERS}
    IF    not ${is_saved_filter_present}
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_ADVANCE_SEARCH_ICON}
        Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_SAVED_FILTERS}
    END
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_FILTER_SETTINGS}
    Capture Screenshot On Webpage

Get Total Hours On Labor Forecast Page On Web
    [Documentation]    This keyword Get Total Hours On Labor Forecast Page On Web
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_ROW}
    ${total_hr}    Get Element Text On Webpage    ${LABOR_FORECAST_PAGE_TOTAL_WORKLOAD}
    RETURN    ${total_hr}

Open And Verify Workload PDF Report On Labor Forecast Page On Web
    [Documentation]    Workload PDF Report to open in new tab and functionality be verified
    Wait Until Element Is Present On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_PANEL}
    Click Element And Switch To New Browser Tab On Web    ${LABOR_FORECAST_PAGE_PDF_ICON}
    Capture Screenshot On Webpage
    ${pdf_attribute_in_url}    Get System Value    LaborForecastPdfAttribute    ANNUAL_WORKLOAD_PDF_URL_COMPONENT
    ${current_url}    Get Url
    Should Contain    ${current_url}    ${pdf_attribute_in_url}
    Close Browser Tab On Web

Click On Third Day Header In Week View On Labor Forecast Page On Web
    [Documentation]    This keyword clicks on any day and verifies total hours
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_THIRD_COLUMN}
    Wait Until Page Is Loaded
    ${is_no_workload_displayed}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_NO_WORKLOAD_DATA_MSG}
    IF    ${is_no_workload_displayed}
        Skip    No workload data found for the selected day.
    END

Verify Data Available On Labor Forecast Page On Web
    [Documentation]    This keyword verifies data is available on Labor Forecast page
    Wait Until Page Is Loaded
    Wait Until Element Disappears On Webpage    ${LABOR_FORECAST_PAGE_PLEASE_WAIT_SPINNER}
    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_PANEL}
    # Wait for the day total hours element to be visible and loaded
    ${is_element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${LABOR_FORECAST_PAGE_DAY_TOTAL_HRS}    timeout=${MEDIUM_TIMEOUT}
    IF    ${is_element_visible}
        # Element is visible, wait for it to load content
        ${day_total_hrs}    Get Element Text On Webpage    ${LABOR_FORECAST_PAGE_DAY_TOTAL_HRS}
        Capture Screenshot On Webpage
        Should Not Be Empty    ${day_total_hrs}    Expected data not available in day total hours element
    ELSE
        # Element is not visible, verify no data available message
        Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_NO_WORKLOAD_DATA_MSG}    timeout=${SHORT_TIMEOUT}
        ${no_data_msg_visible}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_NO_WORKLOAD_DATA_MSG}
        Capture Screenshot On Webpage
        Should Be True    ${no_data_msg_visible}    Expected no data message when day total hours element is not visible
    END

Navigate To The Mentioned Week On Labor Forecast Page On Web
    [Documentation]    This keyword navigates to the mentioned week on Labor Forecast Page On Web
    ...    | =Arguments= | =Description= |
    ...    | target_week | The target week date in mm/dd/yyyy format to navigate to |
    [Arguments]    ${target_week}
    ${source_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${required_date_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${target_week_datetime}    Convert Date    ${target_week}    date_format=${source_date_format}
    ...    result_format=${required_date_format}
    ${week_date_label}    Get Element Text On Webpage    ${LABOR_FORECAST_PAGE_CAL_NAV_DATE_LABEL}
    WHILE    '${target_week_datetime}' not in '${week_date_label}'    limit=${LOOP_TIMEOUT}
        Navigate To Next Week On Labor Forecast Page On Web
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_TABLE}
        ...    error_message=labor forecast workload table not visible
        ${week_date_label}    Get Element Text On Webpage    ${LABOR_FORECAST_PAGE_CAL_NAV_DATE_LABEL}
    END
    Wait Until Page Is Loaded

Select Week Number On Labor Forecast Page On Web
    [Documentation]
    ...    Selects week number on Labor Forecast page using calendar picker with week-day format.
    ...    | =Arguments= | =Description= |
    ...    | week_day_input | Date in week-day format (e.g., 6_0 for 6 weeks from current, 1st day from weekstart). |
    ...    Example usage:
    ...    | Select Week Number On Labor Forecast Page On Web    6_0
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
    # Click calendar button to open date picker
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_CALENDAR_BUTTON}
    Click Element On Webpage    ${FIXEDSHIFTSPAGE_CALENDAR_MONTH_YEAR_HEADER}
    # Select year
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
    # Select month
    ${month_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_MONTH_BUTTON_BY_NAME}    MONTH_NAME=${target_month_name}
    Click Element On Webpage    ${month_locator}
    # Select day and week number
    ${day_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_DAY_BUTTON_BY_FORMATTED_DATE}
    ...    FORMATTED_DATE=${target_day_formatted}
    Wait Until Element Is Visible On Webpage    ${day_locator}
    ${week_number_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_WEEK_NUMBER_BUTTON}    DAY_LOCATOR=${day_locator}
    Click Element On Webpage    ${week_number_locator}
    Wait Until Page Is Loaded
    Wait Until Element Disappears On Webpage    ${FIXEDSHIFTPAGE_CALENDAR_POP_UP}

Generate Workload On Labor Forecast Page On Web
    [Documentation]    This keyword generates workload on Labor Forecast Page On Web
    ...    Logic: If Delete is present -> Delete first then Generate. If only Generate is present -> Click Generate only.
    ...    Handles DOM detachment issue when Generate button is clicked by ignoring errors.
    Click Element On Webpage    ${LABOR_FORECAST_PAGE_ACTION_DROPDOWN}
    ...    error_message=Action dropdown element not clickable on Labor Forecast page.
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_ACTION_DRPDWN_DELETE}
    ${delete_btn_present}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_ACTION_DRPDWN_DELETE}
    IF    ${delete_btn_present}
        Log    Delete button found - performing delete first then generate
        ${promise}    Promise To    Wait For Alert    action=accept
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_ACTION_DRPDWN_DELETE}
        ...    error_message=Delete button element not clickable in action dropdown on Labor Forecast page.
        Wait For    ${promise}
        Wait Until Page Is Loaded
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_ACTION_DROPDOWN}
        ...    error_message=Action dropdown element not clickable after delete operation on Labor Forecast page.
        Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_GENERATE_BTN}    timeout=${LONG_TIMEOUT}
        ...    error_message=Generate button element not visible after delete operation on Labor Forecast page.
        Run Keyword And Ignore Error    Click Element On Webpage    ${LABOR_FORECAST_PAGE_GENERATE_BTN}
        ...    error_message=Generate button element not clickable after delete operation on Labor Forecast page.
    ELSE
        ${generate_btn_present}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_GENERATE_BTN}
        IF    ${generate_btn_present}
            Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_GENERATE_BTN}    timeout=${LONG_TIMEOUT}
            ...    error_message=Generate button element not visible in action dropdown on Labor Forecast page.
            Run Keyword And Ignore Error    Click Element On Webpage    ${LABOR_FORECAST_PAGE_GENERATE_BTN}
            ...    error_message=Generate button element not clickable in action dropdown on Labor Forecast page.
        ELSE
            Log    Neither Delete nor Generate button found in dropdown    level=WARN
        END
    END
    Wait Until Page Is Loaded
    Wait Until Element Is Present On Webpage    ${LABOR_FORECAST_PAGE_WKLD_SUMMARY}    timeout=${LONG_TIMEOUT}
    ...    error_message=Workload summary element not present after workload generation on Labor Forecast page.

Check If Week In Progress State For Labor Forecast Page On Web
    [Documentation]    This keyword checks if the current week is in 'In Progress' state on Labor Forecast Page On Web
    ${is_week_in_progress_present}    Is Element Visible On Webpage    ${LABOR_FORECAST_PAGE_WEEK_IN_PROGRESS}
    RETURN    ${is_week_in_progress_present}

Collect Daily Data For All Days On Labor Forecast Page On Web
    [Documentation]    This keyword collects daily data for all days on Labor Forecast Page On Web
    ...    It clicks on each day header from day 2 to day 8, verifies data availability,
    ...    and captures total hours for each day.
    FOR    ${day_index}    IN RANGE    2    9
        ${day_index_str}    Convert To String    ${day_index}
        ${day_header_locator}    Update Locator With Dynamic Values
        ...    ${LABOR_FORECAST_PAGE_DAY_HEADER_COLUMN}    DAY_INDEX=${day_index_str}
        Wait Until Element Is Visible On Webpage    ${day_header_locator}
        Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_DAY_TOTAL_HRS}
        Log    Clicking on day header with index: ${day_index_str}
        Wait Until Page Is Loaded
        Click Element On Webpage    ${day_header_locator}
        Wait Until Page Is Loaded
        Verify Data Available On Labor Forecast Page On Web
        ${day_total_hrs}    Get Element Text On Webpage    ${LABOR_FORECAST_PAGE_DAY_TOTAL_HRS}
        Capture Screenshot On Webpage
        Should Not Be Empty    ${day_total_hrs}    Expected data not available in day total hours element
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_BACK_TO_WEEK_DISPLAY_BUTTON}
        Wait Until Page Is Loaded
        Wait Until Element Is Present On Webpage    ${LABOR_FORECAST_PAGE_WKLD_SUMMARY}    timeout=${LONG_TIMEOUT}
    END

Navigate To Required Week On Labor Forecast Page On Web
    [Documentation]    This keyword navigates to the required week on Labor Forecast Page On Web
    ...    | =Arguments= | =Description= |
    ...    | week | The week in CALENDAR_NAVIGATION_DATE_FORMAT to navigate to |
    [Arguments]    ${weeks_to_move}    ${week}
    ${date_label}    Update Locator With Dynamic Values    ${LABOR_FORECAST_PAGE_DATE_LABEL}    DATE=${week}
    FOR    ${index}    IN RANGE    ${weeks_to_move}
        Click Element On Webpage    ${LABOR_FORECAST_PAGE_FORWARD_WEEK_BTN}
        Wait Until Element Is Visible On Webpage    ${LABOR_FORECAST_PAGE_WORKLOAD_TABLE}    timeout=${LONG_TIMEOUT}
        ...    error_message=labor forecast workload table not visible
        Log    Clicked on Next Week button ${index} times.
    END
    Wait Until Element Is Visible On Webpage    ${date_label}    error_message=Target week date label not visible

Get Two Random Activities From Labor Forecast Page On Web
    [Documentation]    This keyword gets two random activities from Labor Forecast Page On Web
    ${task_count}    Get Count Of Task Name On Labor Forecast Page On Web
    ${index_1}    ${index_2}    Evaluate    random.sample(range(1, ${task_count} + 1), 2)    random
    ${index_1_str}    Convert To String    ${index_1}
    ${index_2_str}    Convert To String    ${index_2}
    ${activity_1}    Get Element Text On Webpage    (${LABOR_FORECAST_PAGE_TASK_NAME_COUNT})[${index_1_str}]
    ${activity_2}    Get Element Text On Webpage    (${LABOR_FORECAST_PAGE_TASK_NAME_COUNT})[${index_2_str}]
    RETURN    ${activity_1}    ${activity_2}
