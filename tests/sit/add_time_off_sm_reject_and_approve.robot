*** Settings ***
Documentation       SITTC60055 - Requests - Create time off request from ESS and reject then approve from SM
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keyword    Clean Up Time Off Request For User On Date    ESS7_STORE11    SM1_STORE11    start_date_offset=3_2    end_date_offset=3_2

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    sittc60055    config:ess    config:ess_add_edit_delete_timeoff    config:add_edit_delete_timeoff_request_sm    config:ess_request_calendar    mobile    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60055: Requests - Create time off request from ESS and reject then approve from SM monthly calendar
    [Documentation]    Requests - Create time off request from ESS and reject then approve from SM
    ${time_off_data}    Get Time Off Data    start_date=3_2    start_time=20:00    end_time=23:00

    Open Mobile ESS App    sittc60055
    Login Mobile Ess App    ESS7_STORE11
    Navigate To Request Module On Mobile ESS

    Open Add Request Page On Mobile ESS
    Switch To Time Off Request On Mobile ESS
    Add Time Off Request On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[reason]    ${time_off_data}[notes]
    Close Mobile Application    sittc60055_ess7_time_off_request

    Open SM Native Application On Mobile Phone    sittc60055
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS7_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${time_off_data}[status]
    Decline Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS7_STORE11    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${time_off_data}[status_after_decline]
    Approve Request On SM Phone App
    [Teardown]    Teardown Test Case    sittc60055_sm1_decline_approve
