*** Settings ***
Documentation       SITTC60083 - Cross Shift Bidding - SM adds a time off request for self and verifies Not Reviewed status

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Clean Up Time Off Request For User On Date    SM2_STORE14    SM2_STORE14    start_date_offset=5_5    end_date_offset=5_5

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    SITTC60083    config:rws    config:ess    config:add_edit_delete_timeoff_request_sm    mobile    sit    sit_b0    sit_v1    suite_d
...    config:mobile_sm_enabled    sit_r23


*** Test Cases ***
SITTC60083: Cross Shift Bidding - SM adds a time off request for self (not reviewed) at Store 14
    [Documentation]    Cross Shift Bidding - SM Adds Time Off Request For Self And Verifies Not Reviewed

    ${time_off_data}    Get Time Off Data    start_date=5_5    end_date=5_5    duration=03:00    end_time=23:00
    ${status_not_reviewed}    Get System Value    RequestStatus    NOT_REVIEWED

    Open SM Native Application On Mobile Phone    sittc60083
    Login SM App On Mobile    SM2_STORE14
    Navigate To Request On SM Phone App
    Add Time Off Details On SM Phone App    SM2_STORE14    ${time_off_data}[reason]    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[duration]    ${status_not_reviewed}

    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    SM2_STORE14    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${status_not_reviewed}
    Verify Time Off Details On SM Phone App    start_date=${time_off_data}[start_date]    reason=${time_off_data}[reason]    status=${status_not_reviewed}

    [Teardown]    Teardown Test Case    sittc60083_cross_shift_bid_sm_self_time_off_not_reviewed
