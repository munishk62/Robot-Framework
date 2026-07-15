*** Settings ***
Documentation       SITTC60058 - Requests - Create time off request from ESS and reject with SM not reviewed from SM
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keyword    Clean Up Time Off Request For User On Date    ESS7_STORE11    SM1_STORE11    start_date_offset=3_6

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    sittc60058    config:ess    config:ess_add_edit_delete_timeoff    config:add_edit_delete_timeoff_request_sm    config:ess_request_calendar    mobile    sit    sit_b0    sit_v1    sit_r22
...          bug_reported    bugid_wfm_134018
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60058: Requests - Create time off request from ESS and reject with SM not reviewed from SM monthly calendar
    [Documentation]    Requests - Create time off request from ESS and reject with SM not reviewed from SM
    ${time_off_data}    Get Time Off Data    start_date=3_6    start_time=20:00    end_time=23:00
    ${edit_time_off_data}    Get Time Off Data    template_name=edit_timeoff

    Open Mobile ESS App    sittc60058
    Login Mobile Ess App    ESS7_STORE11
    Navigate To Request Module On Mobile ESS

    Open Add Request Page On Mobile ESS
    Switch To Time Off Request On Mobile ESS
    Add Time Off Request On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[reason]    ${time_off_data}[notes]
    Verify Pending Time Off Request List Item On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    Close Mobile Application    sittc60058_ess7_time_off_request

    Open SM Native Application On Mobile Phone    sittc60058
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS7_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[status]
    Decline Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS7_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[status_after_decline]
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    status=${time_off_data}[status_after_decline]
    Edit Time Off Details On SM Phone App    status=${edit_time_off_data}[status]
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS7_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${edit_time_off_data}[status]
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    status=${edit_time_off_data}[status]
    [Teardown]    Teardown Test Case    sittc60058_sm1_decline_not_reviewed
