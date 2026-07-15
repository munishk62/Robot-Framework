*** Settings ***
Documentation       SITTC60044 - Requests - Create day off request from ESS and approve with SM not reviewed from SM monthly calendar

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Clean Up Day Off Request For User On Date    ESS5_STORE11    SM1_STORE11    start_date_offset=3_5    end_date_offset=3_5

Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60044: Requests - Create day off request from ESS and approve with SM not reviewed from SM monthly calendar
    [Documentation]    ESS creates a day off in planning week 3 day 5. SM opens the request from the monthly calendar, approves it, then sets status to Not Reviewed using edit and verifies that state. The first detail check omits status so it is not confused with the post-approve SM not reviewed assertion.
    [Tags]    dev:kishan    sittc60044    config:ess    config:ess_add_edit_delete_dayoff    config:add_edit_delete_dayoff_request_sm    mobile    sit    sit_b0    sit_v1    sit_r22
    ...    config:mobile_shift_enabled    config:mobile_sm_enabled
    ${day_off_data}    Get Day Off Data    start_date=3_5    end_date=3_5
    ${holiday_hours_value}    Evaluate    list($day_off_data["holiday_hours"].values())[0]
    ${status_approved}    Get System Value    RequestStatus    APPROVED
    ${status_not_reviewed}    Get System Value    RequestStatus    NOT_REVIEWED
    Open Mobile ESS App    sittc60044
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
    Close Mobile Application    sittc60044_ess5_raise_day_off_request

    Open SM Native Application On Mobile Phone    sittc60044
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]
    Select Request On SM Phone App    ESS5_STORE11
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    requester_note=${day_off_data}[notes]
    IF    ${is_holiday_hours_enabled}
        Verify Holiday Hours Details On SM Phone App    ${holiday_hours_value}
        Close Holiday Hours Details On SM Phone App
    END
    Approve Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]    ${day_off_data}[start_date]
    Select Request On SM Phone App    ESS5_STORE11
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${status_approved}
    ...    requester_note=${day_off_data}[notes]
    Edit Day Off Details On SM Phone App    status=${status_not_reviewed}
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]    ${day_off_data}[start_date]
    Select Request On SM Phone App    ESS5_STORE11
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${status_not_reviewed}
    ...    requester_note=${day_off_data}[notes]
