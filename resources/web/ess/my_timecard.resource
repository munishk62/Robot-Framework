*** Settings ***
Documentation       Resource file containing keywords for My Timecard page on ESS

Variables           resources/web/ess/my_timecard_page.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To ESS My Timecard Page On Web
    [Documentation]    Navigate To ESS -> My Timecard -> My Timecard Page
    ...    and verifies my timecard heading at the top of the page
    Navigate To Specific Page On Web    ess    my_timecard

Verify My Timecard Page Legend On Web
    [Documentation]    This keyword verifies the My Timecard page legend
    Click Element On Webpage    ${MY_TIMECARD_PAGE_LEGEND_ICON}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TIMECARD_STATUS}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TRANSACTION_TYPES}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TIME_GRID}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_RAW_PUNCHES_GRID}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_AUDIT_GRID}
    Capture Screenshot On Webpage

Verify Labels Displayed Under Legend Categories On My Timecard Page On Web
    [Documentation]    This keyword verifies that all labels are displayed under legend categories on My Timecard page
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TIMECARD_STATUS_FIRST_ICON}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TIMECARD_STATUS_FIRST_LABEL}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TRANSACTION_TYPES_FIRST_ICON}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TRANSACTION_TYPES_FIRST_LABEL}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TIME_GRID_FIRST_ICON}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TIME_GRID_FIRST_LABEL}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_RAW_PUNCHES_GRID_FIRST_ICON}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_RAW_PUNCHES_GRID_FIRST_LABEL}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_AUDIT_GRID_FIRST_ICON}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_AUDIT_GRID_FIRST_LABEL}
    Capture Screenshot On Webpage

Close My Timecard Page Legend On Web
    [Documentation]    This keyword closes the My Timecard page legend
    Click Element On Webpage    ${MY_TIMECARD_PAGE_LEGEND_CLOSE_BUTTON}
    Wait Until Element Disappears On Webpage    ${MY_TIMECARD_PAGE_LEGEND_TIMECARD_STATUS}

Verify My Timecard Page Grid On Web
    [Documentation]    This keyword verifies the My Timecard page grid elements
    [Arguments]    ${activity_code_present}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_WEEK_LABEL}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_TIME_GRID}
    ${is_date_field_visible}    Is Element Visible On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_DATE_FIELD}
    Should Be True    ${is_date_field_visible}    msg=Date field is not visible
    ${date_field}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_DATE_FIELD}
    Should Not Be Empty    ${date_field}    msg=Text for Date field in timecard grid is empty
    ${is_schedule_field_visible}    Is Element Visible On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_SCHEDULE_FIELD}
    Should Be True    ${is_schedule_field_visible}    msg=Schedule field is not visible
    ${schedule_field}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_SCHEDULE_FIELD}
    Should Not Be Empty    ${schedule_field}    msg=Text for Schedule field in timecard grid is empty
    ${is_actual_field_visible}    Is Element Visible On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_ACTUAL_FIELD}
    Should Be True    ${is_actual_field_visible}    msg=Actual field is not visible
    ${actual_field}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_ACTUAL_FIELD}
    Should Not Be Empty    ${actual_field}    msg=Text for Actual field in timecard grid is empty
    ${is_total_hrs_field_visible}    Is Element Visible On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_TOTAL_HRS_FIELD}
    Should Be True    ${is_total_hrs_field_visible}    msg=Total Hrs field is not visible
    ${total_hrs_field}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_TOTAL_HRS_FIELD}
    Should Not Be Empty    ${total_hrs_field}    msg=Text for Total Hrs field in timecard grid is empty
    ${is_location_field_visible}    Is Element Visible On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_LOCATION_FIELD}
    Should Be True    ${is_location_field_visible}    msg=Location field is not visible
    ${location_field}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_LOCATION_FIELD}
    Should Not Be Empty    ${location_field}    msg=Text for Location field in timecard grid is empty
    ${is_department_field_visible}    Is Element Visible On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_DEPARTMENT_FIELD}
    Should Be True    ${is_department_field_visible}    msg=Department field is not visible
    ${department_field}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_DEPARTMENT_FIELD}
    Should Not Be Empty    ${department_field}    msg=Text for Department field in timecard grid is empty
    IF    ${activity_code_present}
        ${is_activity_field_visible}    Is Element Visible On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_ACTIVITY_FIELD}
        Should Be True    ${is_activity_field_visible}    msg=Activity field is not visible
        ${activity_field}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_ACTIVITY_FIELD}
        Should Not Be Empty    ${activity_field}    msg=Text for Activity field in timecard grid is empty
    END
    ${is_reason_code_field_visible}    Is Element Visible On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_REASON_CODE_FIELD}
    Should Be True    ${is_reason_code_field_visible}    msg=Reason Code field is not visible
    ${reason_code_field}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_GRID_REASON_CODE_FIELD}
    Should Not Be Empty    ${reason_code_field}    msg=Text for Reason Code field in timecard grid is empty

Switch To Audit Tab On My Timecard Page On Web
    [Documentation]    This keyword opens the Audit tab in My Timecard page
    VAR    ${tab_present_status}    ${True}
    ${audit_tab_status}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage
    ...    ${MY_TIMECARD_PAGE_AUDIT_TAB}
    IF    not ${audit_tab_status}
        Capture Screenshot On Webpage
        VAR    ${tab_present_status}    ${False}
    ELSE
        Click Element On Webpage    ${MY_TIMECARD_PAGE_AUDIT_TAB}
        ${audit_details_status}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_AUDIT_TAB_CHANGE_LOG}
        IF    not ${audit_details_status}
            Capture Screenshot On Webpage
            Log    No Audit details to display
        END
    END
    RETURN    ${tab_present_status}

Verify Audit Tab Time Format On My Timecard Page On Web
    [Documentation]    This keyword verifies the time format in Time column in Audit tab on My Timecard page
    [Arguments]    ${audit_date}
    ${audit_record}    Update Locator With Dynamic Values    ${MY_TIMECARD_PAGE_AUDIT_TAB_SPECIFIC_RECORD_TIME}
    ...    AUDIT_DATE=${audit_date}
    ${record_available}    Is Element Visible On Webpage    ${audit_record}
    IF    not ${record_available}
        Log    No records available in Audit tab
        Capture Screenshot On Webpage
    ELSE
        ${time_value}    Get Element Text On Webpage    ${audit_record}
        ${formatted_time_value}    Replace String    ${time_value.strip()}    \n    ${SPACE}
        Capture Screenshot On Webpage
        ${expected_time_format}    Get System Value    MyTimecardAuditTimeFormat    MY_TIMECARD_PAGE_AUDIT_TAB_TIME_FORMAT_REGEX
        ${is_valid_format}    Evaluate    bool(re.match(r'${expected_time_format}', '${formatted_time_value}'))    modules=re
        Should Be True    ${is_valid_format}
        ...    msg=Time format '${formatted_time_value}' does not match expected format MM/DD/YYYY hh:mm AM/PM
    END

Switch To Pay Results Tab On My Timecard Page On Web
    [Documentation]    This keyword opens the Pay Results tab in My Timecard page
    ${pay_result_status}    Is Element Visible On Webpage    ${MY_TIMECARD_PAGE_PAY_RESULTS_TAB}
    IF    not ${pay_result_status}
        Log    Pay Results tab is not available
    ELSE
        Click Element On Webpage    ${MY_TIMECARD_PAGE_PAY_RESULTS_TAB}
        Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_PAY_RESULTS_TAB_DATE}
    END
    Capture Screenshot On Webpage

Switch To Timecard Tab On My Timecard Page On Web
    [Documentation]    This keyword switches back to Timecard tab in My Timecard page
    Click Element On Webpage    ${MY_TIMECARD_PAGE_TIMECARD_TAB}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_TIME_GRID}
    Capture Screenshot On Webpage

Navigate To Next Week On My Timecard Page On Web
    [Documentation]    This keyword navigates to the next week in My Timecard page
    ${max_week}    Get Config Value    key=MAX_WEEK_NUMBER
    ${current_week}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_WEEK_LABEL}
    ${current_week_number}    Evaluate    '${current_week}'.split('Week ')[1].split(' :')[0]
    Click Element On Webpage    ${MY_TIMECARD_PAGE_NEXT_WEEK_BUTTON}
    Wait Until Page Is Loaded
    Wait Until Element Disappears On Webpage    ${MY_TIMECARD_PAGE_LOADER}
    Capture Screenshot On Webpage
    ${next_week}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_WEEK_LABEL}
    ${next_week_number}    Evaluate    '${next_week}'.split('Week ')[1].split(' :')[0]
    ${is_next_week}    Evaluate
    ...    int(${next_week_number}) == (1 if int(${current_week_number}) == ${max_week} else int(${current_week_number}) + 1)
    Should Be True    ${is_next_week}    msg=Expected text label for next week not found

Navigate To Previous Week On My Timecard Page On Web
    [Documentation]    This keyword navigates to the previous week in My Timecard page
    ${max_week}    Get Config Value    key=MAX_WEEK_NUMBER
    ${current_week}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_WEEK_LABEL}
    ${current_week_number}    Evaluate    '${current_week}'.split('Week ')[1].split(' :')[0]
    Click Element On Webpage    ${MY_TIMECARD_PAGE_PREVIOUS_WEEK_BUTTON}
    Wait Until Page Is Loaded
    Wait Until Element Disappears On Webpage    ${MY_TIMECARD_PAGE_LOADER}
    Capture Screenshot On Webpage
    ${previous_week}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_WEEK_LABEL}
    ${previous_week_number}    Evaluate    '${previous_week}'.split('Week ')[1].split(' :')[0]
    ${is_previous_week}    Evaluate
    ...    int(${previous_week_number}) == (${max_week} if int(${current_week_number}) == 1 else int(${current_week_number}) - 1)
    Should Be True    ${is_previous_week}    msg=Expected text label for previous week not found

Verify Timecard Loaded For Current Week On My Timecard Page On Web
    [Documentation]    This keyword verifies that timecard is loaded for current week on My Timecard page
    ${timecard_week_range_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${week_start_day}    Get Config Value    key=FISCAL_WEEK_START_DAY
    ${current_week_start_date}    Get Current Week Start Date    ${timecard_week_range_format}    ${week_start_day}
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_WEEK_LABEL}    timeout=${LONG_TIMEOUT}
    ...    error_message=Timecard page is not loaded after waiting for ${LONG_TIMEOUT} seconds
    ${week_label}    Get Element Text On Webpage    ${MY_TIMECARD_PAGE_WEEK_LABEL}
    ${dates_range}    Evaluate    '${week_label}'.split(' : ')[1]
    ${start_date}    Evaluate    '${dates_range}'.split(' - ')[0]
    Should Be Equal As Strings    ${start_date}    ${current_week_start_date}
    ...    msg=Timecard is not loaded for current week. Expected start date: ${current_week_start_date}, Found: ${start_date}

Verify Audit Tab Details For Added Shift On My Timecard Page On Web
    [Documentation]    This keyword verifies the audit details for added shift in Audit tab on My Timecard page
    ...    | =Arguments= | =Description= |
    ...    | audit_date | Audit date for which record to be verified |
    ...    | action | Action to be verified |
    ...    | shift_time | Time of shift |
    ...    | location | Location of associate |
    ...    Example usage:
    ...    | Verify Audit Tab Details For Added Shift On My Timecard Page On Web    12/03/2024    Added    08:00    STORE1-D1Store 1
    [Arguments]    ${audit_date}    ${action}    ${shift_time}    ${location}
    ${audit_record_action}    Update Locator With Dynamic Values    ${MY_TIMECARD_PAGE_AUDIT_TAB_SPECIFIC_RECORD_ACTION}
    ...    AUDIT_DATE=${audit_date}
    ${audit_action_text}    Get Element Text On Webpage    ${audit_record_action}
    Should Be Equal As Strings    ${audit_action_text}    ${action}
    ...    msg=Expected action '${action}' not found in Audit tab for date ${audit_date}
    ${shift_time_formatted}    Convert Time From 24 Hour To 12 Hour Format For Web    ${shift_time}
    ${time_part}    Split String    ${shift_time_formatted}    ${SPACE}
    ${expected_shift_time}    Evaluate    '${time_part}[0]'.lstrip('0')
    ${audit_shift_time}    Update Locator With Dynamic Values    ${MY_TIMECARD_PAGE_AUDIT_TAB_SPECIFIC_RECORD_SHIFT_TIME}
    ...    AUDIT_DATE=${audit_date}
    ${audit_shift_time_text}    Get Element Text On Webpage    ${audit_shift_time}
    ${updated_audit_shift_time_text}    Split String    ${audit_shift_time_text.strip()}    ${SPACE}
    ${audit_shift_time_text_without_zero}    Evaluate    '${updated_audit_shift_time_text}[0]'.lstrip('0')
    Should Be Equal As Strings    ${audit_shift_time_text_without_zero}    ${expected_shift_time}
    ...    msg=Expected shift time '${shift_time}' not found in Audit tab for date ${audit_date}
    ${audit_location}    Update Locator With Dynamic Values    ${MY_TIMECARD_PAGE_AUDIT_TAB_SPECIFIC_RECORD_LOCATION}
    ...    AUDIT_DATE=${audit_date}
    ${audit_location_text}    Get Element Text On Webpage    ${audit_location}
    ${audit_location_text}    Strip String    ${audit_location_text}
    ${location}    Strip String    ${location}
    Should Be Equal As Strings    ${audit_location_text}    ${location}
    ...    msg=Expected location '${location}' not found in Audit tab for date ${audit_date}

Get Time Card Punch Count For Specific Date On My Timecard Page On Web
    [Documentation]    This keyword gets the count of punches for specific date on My Timecard page
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Date for which punch record to be verified |
    ...    | =Returns= | =Description= |
    ...    | timecard_punch_record_count | Record count for punches for given date |
    [Arguments]    ${shift_date}    ${shift_time}
    ${timecard_punch_record}    Update Locator With Dynamic Values    ${MY_TIMECARD_PAGE_TIMECARD_GRID_RECORD_BY_DATE_TIME}
    ...    SHIFT_DATE=${shift_date}    SHIFT_TIME=${shift_time}
    ${timecard_punch_record_count}    Get Element Count On Web Page    ${timecard_punch_record}
    RETURN    ${timecard_punch_record_count}

Click On Weekend Dropdown On My Timecard Page On Web
    [Documentation]    This keyword clicks on weekend dropdown on My Timecard page
    Click Element On Webpage    ${MY_TIMECARD_PAGE_WEEKEND_DROPDOWN}
    ...    error_message=Could not click on weekend dropdown on My Timecard page
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_WEEKEND_MENU}
    ...    error_message=Weekend menu did not appear after clicking on weekend dropdown
    Capture Screenshot On Webpage

Click On Legend Icon On My Timecard Page On Web
    [Documentation]    This keyword clicks on legend icon on My Timecard page
    Click Element On Webpage    ${MY_TIMECARD_PAGE_LEGEND_ICON}    error_message=Could not click on legend icon on My Timecard page
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_LEGEND_MENU}
    ...    error_message=Legend menu did not appear after clicking on legend icon
    Capture Screenshot On Webpage

Click On Show Punches Icon On My Timecard Page On Web
    [Documentation]    This keyword clicks on show punches icon on My Timecard page
    Click Element On Webpage    ${MY_TIMECARD_PAGE_SHOW_PUNCHES_ICON}
    ...    error_message=Could not click on Show Punches icon on My Timecard page
    Wait Until Element Is Visible On Webpage    ${MY_TIMECARD_PAGE_SHOW_PUNCHES_MENU}
    ...    error_message=Show Punches menu did not appear after clicking on Show Punches icon on My Timecard page
    Capture Screenshot On Webpage
