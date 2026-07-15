*** Settings ***
Documentation       SITTC60064 - Requests - SM creates time off in monthly calendar and rejects in month view
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keyword    Clean Up Time Off Request For User On Date    ESS8_STORE11    SM1_STORE11    start_date_offset=2_0

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    sittc60064    config:ess    config:ess_add_edit_delete_timeoff    config:add_edit_delete_timeoff_request_sm    config:ess_request_calendar    mobile    sit    sit_b0    sit_v1    sit_r22
...          bug_reported    bugid_wfm_134018
...    config:mobile_sm_enabled


*** Test Cases ***
SITTC60064: Requests - SM creates time off in monthly calendar and rejects in month view
    [Documentation]    Requests - SM creates time off in monthly calendar and rejects in month view
    ${time_off_data}    Get Time Off Data    start_date=2_0

    Open SM Native Application On Mobile Phone    sittc60064
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Add Time Off Details On SM Phone App    ESS8_STORE11    ${time_off_data}[reason]
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[duration]
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS8_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status]
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    status=${time_off_data}[status]
    Approve Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS8_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status_after_approval]
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    status=${time_off_data}[status_after_approval]
    Decline Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS8_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status_after_decline]
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    status=${time_off_data}[status_after_decline]
    [Teardown]    Teardown Test Case    sittc60064_sm1_approve_decline
