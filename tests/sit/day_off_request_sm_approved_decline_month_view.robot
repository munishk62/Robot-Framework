*** Settings ***
Documentation       SITTC60051 - Requests - SM creates day off in monthly calendar and rejects in month view

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Clean Up Day Off Request For User On Date    ESS6_STORE11    SM1_STORE11    start_date_offset=2_0    end_date_offset=2_0

Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60051: Requests - SM creates day off in monthly calendar and rejects in month view
    [Documentation]    SM creates a day off in planning week 2 day 1 in approved status; SM declines from monthly calendar.
    [Tags]    dev:bushra    sittc60051    config:ess    config:add_edit_delete_dayoff_request_sm    mobile    sit    sit_b0    sit_v1    sit_r22
    ...    config:mobile_sm_enabled
    ${status_approved}    Get System Value    RequestStatus    APPROVED
    ${status_declined}    Get System Value    RequestStatus    DECLINED
    VAR    &{holiday_hrs}    0=8
    ${day_off_data}    Get Day Off Data    start_date=2_0    end_date=2_0    holiday_hours=${holiday_hrs}    status=${status_approved}
    ${is_holiday_hours_enabled}    Is Config Enabled    holiday_hours_enabled
    Open SM Native Application On Mobile Phone    sittc60051
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    IF    ${is_holiday_hours_enabled}
        Add Day Off Details With Holiday Hours On SM Phone App    ESS6_STORE11    ${day_off_data}[reason]
        ...    ${day_off_data}[start_date]    ${day_off_data}[end_date]    status=${status_approved}    holiday_hours=${day_off_data}[holiday_hours]
    ELSE
        Add Day Off Details On SM Phone App    ESS6_STORE11    ${day_off_data}[reason]
        ...    ${day_off_data}[start_date]    ${day_off_data}[end_date]    status=${status_approved}
    END
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]
    Select Specific Day Off Request On SM Phone App    ESS6_STORE11    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[status]
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${status_approved}
    Navigate Back From Request Details On SM Phone App
    Select Dropdown For Specific Day Off Request On SM Phone App    ESS6_STORE11    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${status_approved}
    Decline Request From More Actions Navigation Drawer On SM Phone App
    Select Specific Day Off Request On SM Phone App    ESS6_STORE11    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${status_declined}
    Verify Day Off Details On SM Phone App    start_date=${day_off_data}[start_date]    end_date=${day_off_data}[end_date]
    ...    total_days=1    reason=${day_off_data}[reason]    status=${status_declined}

    [Teardown]    Close Mobile Application    sittc60051_sm_create_day_off_request
