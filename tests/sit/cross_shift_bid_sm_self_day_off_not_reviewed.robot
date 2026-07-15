*** Settings ***
Documentation       SITTC60082 - Cross Shift Bidding - SM adds a day off request for self and verifies Not Reviewed status

Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource

Test Setup          Clean Up Day Off Request For User On Date    SM1_STORE14    SM1_STORE14    start_date_offset=5_5    end_date_offset=5_5

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    sittc60082    config:rws    config:ess    config:add_edit_delete_dayoff_request_sm    mobile    sit    sit_b0    sit_v1    suite_d
...    config:mobile_sm_enabled    sit_r23


*** Test Cases ***
SITTC60082: Cross Shift Bidding - SM adds a day off request for self (not reviewed) at Store 14
    [Documentation]    Cross Shift Bidding - SM Adds Day Off Request For Self Not Reviewed

    ${day_off_data}    Get Day Off Data    start_date=5_5    end_date=5_5
    ${status_not_reviewed}    Get System Value    RequestStatus    NOT_REVIEWED

    Open SM Native Application On Mobile Phone    sittc60082
    Login SM App On Mobile    SM1_STORE14
    Navigate To Request On SM Phone App
    Add Day Off Details On SM Phone App    SM1_STORE14    ${day_off_data}[reason]    ${day_off_data}[start_date]    ${day_off_data}[end_date]

    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]
    Select Specific Day Off Request On SM Phone App    SM1_STORE14    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${status_not_reviewed}
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${status_not_reviewed}

    [Teardown]    Teardown Test Case    sittc60082_cross_shift_bid_sm_self_day_off_not_reviewed
