*** Settings ***
Documentation       SITTC60040 - Requests - Create day off request from ESS, edit, and reject from SM monthly calendar

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keywords
...        Clean Up Day Off Request For User On Date    ESS5_STORE11    SM1_STORE11    start_date_offset=2_2    end_date_offset=2_2    AND
...        Clean Up Day Off Request For User On Date    ESS5_STORE11    SM1_STORE11    start_date_offset=2_3    end_date_offset=2_3

Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60040: Requests - Create day off request from ESS, edit, and reject from SM monthly calendar
    [Documentation]    Requests - Create day off request from ESS, edit, and reject from SM monthly calendar
    [Tags]    dev:bushra    sittc60040    config:ess    config:ess_add_edit_delete_dayoff    config:add_edit_delete_dayoff_request_sm
    ...        mobile    sit    sit_b0    sit_v1    sit_r22
    ...    config:mobile_shift_enabled    config:mobile_sm_enabled
    ${day_off_data}    Get Day Off Data    start_date=2_2    end_date=2_2
    ${day_off_data_edit}    Get Day Off Data    start_date=2_3    end_date=2_3
    ${holiday_hours_value}    Evaluate    list($day_off_data["holiday_hours"].values())[0]
    Open Mobile ESS App    sittc60040
    Login Mobile Ess App    ESS5_STORE11
    Navigate To Request Module On Mobile ESS
    Open Add Request Page On Mobile ESS
    ${is_holiday_hours_enabled}    Is Config Enabled    holiday_hours_enabled
    IF    ${is_holiday_hours_enabled}
        Add Day Off Request On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[reason]
        ...    ${day_off_data}[notes]    ${holiday_hours_value}
    ELSE
        Add Day Off Request On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[reason]
        ...    ${day_off_data}[notes]
    END
    Verify Pending Day Off Request List Item On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    Tap Pending Day Off Request List Item On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    Edit Day Off Request On Mobile ESS    request_start=${day_off_data_edit}[start_date]    current_selected_start_date=${day_off_data}[start_date]
    ...    request_end=${day_off_data_edit}[end_date]    current_selected_end_date=${day_off_data}[end_date]
    Navigate Back On Mobile ESS
    Verify Pending Day Off Request List Item On Mobile ESS    ${day_off_data_edit}[start_date]    ${day_off_data_edit}[end_date]
    Close Mobile Application    sittc60040_ess5_raise_day_off_request
    Open SM Native Application On Mobile Phone    sittc60040
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${day_off_data_edit}[start_date]
    Select Specific Day Off Request On SM Phone App    ESS5_STORE11    ${day_off_data_edit}[start_date]    ${day_off_data_edit}[end_date]    ${day_off_data_edit}[status]
    Verify Day Off Details On SM Phone App    start_date=${day_off_data_edit}[start_date]    end_date=${day_off_data_edit}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${day_off_data}[status]
    ...    requester_note=${day_off_data}[notes]    approver_note=${None}
    IF    ${is_holiday_hours_enabled}
        Verify Holiday Hours Details On SM Phone App    ${holiday_hours_value}
        Close Holiday Hours Details On SM Phone App
    END
    Decline Request On SM Phone App

    [Teardown]    Teardown Test Case    sittc60040_sm1_day_off_decline
