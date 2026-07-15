*** Settings ***
Documentation       SITTC60050 - Requests - SM adds cross-week day off request from monthly calendar and edits start date

Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keywords
...                 Clean Up Day Off Request For User On Date    ESS6_STORE11    SM1_STORE11    start_date_offset=2_6    end_date_offset=3_1    AND
...                 Clean Up Day Off Request For User On Date    ESS6_STORE11    SM1_STORE11    start_date_offset=3_2    end_date_offset=3_2

Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60050: Requests - SM creates cross-week day off in monthly calendar, edits start date in month view
    [Documentation]    SM1_STORE11 adds a cross-week day off on behalf of ESS6_STORE11 from PW#2 Day 6 to PW#3 Day 1 (3 days) using the SM monthly calendar.
    ...    SM then opens the request from the monthly calendar, verifies the day off details, and edits the start date from PW#2 Day 6 to PW#3 Day 2.
    ...    Verify the updated start date is reflected on the details page after save.
    [Tags]    dev:bushra    sittc60050    config:ess_add_edit_delete_dayoff    config:add_edit_delete_dayoff_request_sm    mobile    sit
    ...    config:mobile_sm_enabled    sit_v1    sit_b0    sit_r22
    ${day_off_data}    Get Day Off Data    start_date=2_6    end_date=3_1
    ${day_off_data_edit}    Get Day Off Data    start_date=3_2    end_date=3_2
    ${holiday_hours_value}    Evaluate    list($day_off_data["holiday_hours"].values())[0]
    ${inclusive_days}    Calculate Days Between Date Offsets    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    ${is_holiday_hours_enabled}    Is Config Enabled    holiday_hours_enabled
    Open SM Native Application On Mobile Phone    sittc60050
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    IF    ${is_holiday_hours_enabled}
        Add Day Off Details With Holiday Hours On SM Phone App    ESS6_STORE11    ${day_off_data}[reason]
        ...    ${day_off_data}[start_date]    ${day_off_data}[end_date]    holiday_hours=${holiday_hours_value}
    ELSE
        Add Day Off Details On SM Phone App    ESS6_STORE11    ${day_off_data}[reason]
        ...    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    END
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]
    Select Specific Day Off Request On SM Phone App    ESS6_STORE11    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[status]
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=${inclusive_days}    reason=${day_off_data}[reason]    status=${day_off_data}[status]
    IF    ${is_holiday_hours_enabled}
        Edit Day Off Details On SM Phone App    edit_start_date=${day_off_data_edit}[start_date]    holiday_hours=${holiday_hours_value}
    ELSE
        Edit Day Off Details On SM Phone App    edit_start_date=${day_off_data_edit}[start_date]
    END
    Request Calendar Navigation On SM Phone App    ${day_off_data_edit}[start_date]    ${day_off_data_edit}[start_date]
    Select Specific Day Off Request On SM Phone App    ESS6_STORE11    ${day_off_data_edit}[start_date]    ${day_off_data_edit}[end_date]    ${day_off_data}[status]
    Verify Day Off Details On SM Phone App    start_date=${day_off_data_edit}[start_date]    end_date=${day_off_data_edit}[end_date]
    ...    reason=${day_off_data}[reason]    status=${day_off_data}[status]

    [Teardown]    Teardown Test Case    sittc60050_sm1_edit_day_off_start_date
