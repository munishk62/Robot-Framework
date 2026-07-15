*** Settings ***
Documentation       SITTC60061 - Requests - Create time off request from ESS and SM deletes request from list view
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keyword    Clean Up Time Off Request For User On Date    ESS7_STORE11    SM1_STORE11    start_date_offset=4_4

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    SITTC60061    config:ess    config:ess_add_edit_delete_timeoff    config:add_edit_delete_timeoff_request_sm    config:ess_request_calendar    mobile    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60061: Requests - Create time off request from ESS and SM deletes request from list view
    [Documentation]    Requests - Create time off request from ESS and SM deletes request from list view
    ${time_off_data}    Get Time Off Data    start_date=4_4    start_time=20:00    end_time=23:00

    Open Mobile ESS App    SITTC60061
    Login Mobile Ess App    ESS7_STORE11
    Navigate To Request Module On Mobile ESS
    Open Add Request Page On Mobile ESS
    Switch To Time Off Request On Mobile ESS
    Add Time Off Request On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[reason]    ${time_off_data}[notes]
    Verify Pending Time Off Request List Item On Mobile ESS
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    Close Mobile Application    SITTC60061_ess7_time_off_request

    Open SM Native Application On Mobile Phone    SITTC60061
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Click Pending Requests On SM Phone App
    Apply Filter On Pending Requests List On SM Phone App    end_date=${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS7_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[status]
    Delete Request On SM Phone App
    Verify Deleted Time Off Request Not Present In List View On SM Phone App
    ...    ESS7_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[status]
    [Teardown]    Teardown Test Case    SITTC60061_sm1_delete
