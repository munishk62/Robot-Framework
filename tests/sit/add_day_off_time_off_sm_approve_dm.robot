*** Settings ***
Documentation       SITTC60086 and SITTC60087 - DM approves day off and time off requests for Store Managers
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keywords
...                 Clean Up Day Off Request For User On Date    SM1_STORE14    DM1_DIST3    start_date_offset=5_5    end_date_offset=5_5    AND
...                 Clean Up Day Off Request For User On Date    SM2_STORE14    DM1_DIST3    start_date_offset=5_5    end_date_offset=5_5    AND
...                 Clean Up Time Off Request For User On Date    SM1_STORE14    DM1_DIST3    start_date_offset=5_5    AND
...                 Clean Up Time Off Request For User On Date    SM2_STORE14    DM1_DIST3    start_date_offset=5_5

Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60086: Cross Shift Bidding - Re-generate schedule with delete and regenerate for Store 14 and verify (planning week #5)
    [Documentation]    SM1 and SM2 create day off request and DM approves from month view
    [Tags]    dev:bushra    sittc60086    config:rws    config:add_edit_delete_dayoff_request_sm    mobile    sit
    ...    config:mobile_sm_enabled    sit_r23
    ${status_approved}    Get System Value    RequestStatus    APPROVED
    ${reportee_type}    Get System Value    ReporteeType    DIRECT
    ${day_off_data}    Get Day Off Data    start_date=5_5    end_date=5_5
    Open SM Native Application On Mobile Phone    sittc60086
    Login SM App On Mobile    SM1_STORE14
    Navigate To Request On SM Phone App
    Add Day Off Details On SM Phone App    SM1_STORE14    ${day_off_data}[reason]
    ...    ${day_off_data}[start_date]    ${day_off_data}[end_date]    status=${day_off_data}[status]
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]
    Select Specific Day Off Request On SM Phone App    SM1_STORE14    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[status]
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${day_off_data}[status]
    Logout SM App On Mobile

    Login SM App On Mobile    SM2_STORE14
    Navigate To Request On SM Phone App
    Add Day Off Details On SM Phone App    SM2_STORE14    ${day_off_data}[reason]
    ...    ${day_off_data}[start_date]    ${day_off_data}[end_date]    status=${day_off_data}[status]
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]
    Select Specific Day Off Request On SM Phone App    SM2_STORE14    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    ...    ${day_off_data}[status]
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${day_off_data}[status]
    Logout SM App On Mobile

    Login SM App On Mobile    DM1_DIST3
    Navigate To Request On SM Phone App
    Click Pending Requests On SM Phone App
    Apply Filter On Pending Requests List On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]    my_reports_type=${reportee_type}
    Select Specific Day Off Request On SM Phone App    SM1_STORE14    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[status]
    Approve Request On SM Phone App
    Select Specific Day Off Request On SM Phone App    SM2_STORE14    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[status]
    Approve Request On SM Phone App
    Navigate To Request On SM Phone App
    Apply Filter On Pending Requests List On SM Phone App    my_reports_type=${reportee_type}
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]
    Select Specific Day Off Request On SM Phone App    SM1_STORE14    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${status_approved}
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${status_approved}
    Navigate Back From Request Details On SM Phone App
    Select Specific Day Off Request On SM Phone App    SM2_STORE14    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${status_approved}
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${status_approved}
    Logout SM App On Mobile

    [Teardown]    Close Mobile Application    sittc60086_sm_create_day_off_request

SITTC60087: Requests - DM approves time off leave requests for Store Manager
    [Documentation]    SM1 and SM2 create time off request and DM approves from month view
    [Tags]    dev:bushra    sittc60087    config:rws    config:add_edit_delete_timeoff_request_sm    mobile    sit
    ...    config:mobile_sm_enabled
    ${status_approved}    Get System Value    RequestStatus    APPROVED
    ${reportee_type}    Get System Value    ReporteeType    DIRECT
    ${time_off_data}    Get Time Off Data    start_date=5_5
    Open SM Native Application On Mobile Phone    sittc60087
    Login SM App On Mobile    SM1_STORE14
    Navigate To Request On SM Phone App
    Add Time Off Details On SM Phone App    SM1_STORE14    ${time_off_data}[reason]
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[duration]    status=${time_off_data}[status]
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    SM1_STORE14    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status]
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    reason=${time_off_data}[reason]    status=${time_off_data}[status]
    Logout SM App On Mobile

    Login SM App On Mobile    SM2_STORE14
    Navigate To Request On SM Phone App
    Add Time Off Details On SM Phone App    SM2_STORE14    ${time_off_data}[reason]
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[duration]    status=${time_off_data}[status]
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    SM2_STORE14    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status]
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    reason=${time_off_data}[reason]    status=${time_off_data}[status]
    Logout SM App On Mobile

    Login SM App On Mobile    DM1_DIST3
    Navigate To Request On SM Phone App
    Click Pending Requests On SM Phone App
    Apply Filter On Pending Requests List On SM Phone App    start_date=${time_off_data}[start_date]    end_date=${time_off_data}[start_date]    my_reports_type=${reportee_type}
    Select Specific Time Off Request On SM Phone App    SM1_STORE14    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status]
    Approve Request On SM Phone App
    Select Specific Time Off Request On SM Phone App    SM2_STORE14    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status]
    Approve Request On SM Phone App
    Navigate To Request On SM Phone App
    Apply Filter On Pending Requests List On SM Phone App    my_reports_type=${reportee_type}
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    SM1_STORE14    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${status_approved}
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    reason=${time_off_data}[reason]    status=${status_approved}
    Navigate Back From Request Details On SM Phone App
    Select Specific Time Off Request On SM Phone App    SM2_STORE14    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${status_approved}
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    reason=${time_off_data}[reason]    status=${status_approved}
    Logout SM App On Mobile

    [Teardown]    Close Mobile Application    sittc60087_sm_create_time_off_request
