*** Settings ***
Documentation       SITTC60053 - Requests - Create time off, Edit and Decline from SM
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keywords
...        Clean Up Time Off Request For User On Date    ESS7_STORE11    SM1_STORE11    start_date_offset=2_2    AND
...        Clean Up Time Off Request For User On Date    ESS7_STORE11    SM1_STORE11    start_date_offset=2_3

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    sittc60053    config:ess    config:ess_add_edit_delete_timeoff    config:add_edit_delete_timeoff_request_sm    config:ess_request_calendar    mobile    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60053: Requests - Create time off request from ESS, edit, and reject from SM monthly calendar
    [Documentation]    Requests - Create time off, Edit and Decline from SM
    ${time_off_data}    Get Time Off Data    template_name=edit_timeoff    start_date=2_2    duration=3:00    end_time=23:00    notes=Doctor's appointment. Can I take Time Off?
    ${edit_time_off_data}    Get Time Off Data    template_name=edit_timeoff    start_date=2_3

    Open Mobile ESS App    sittc60053
    Login Mobile Ess App    ESS7_STORE11
    Navigate To Request Module On Mobile ESS

    Open Add Request Page On Mobile ESS
    Switch To Time Off Request On Mobile ESS
    Add Time Off Request On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[reason]    ${time_off_data}[notes]
    Tap Pending Time Off Request List Item On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    Edit Time Off Request On Mobile ESS    ${edit_time_off_data}[start_date]
    Navigate Back On Mobile ESS
    Close Mobile Application    sittc60053_ess7_time_off_request_edit_decline

    Open SM Native Application On Mobile Phone    sittc60053
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${edit_time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS7_STORE11    ${edit_time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${time_off_data}[status]
    Decline Request On SM Phone App
    [Teardown]    Teardown Test Case    sittc60053_sm1_time_off_decline
