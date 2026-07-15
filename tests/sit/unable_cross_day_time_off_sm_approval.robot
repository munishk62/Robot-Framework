*** Settings ***
Documentation       SITTC60054 - Requests - Unable to add cross day time off
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keyword    Clean Up Time Off Request For User On Date    ESS7_STORE11    SM1_STORE11    start_date_offset=2_6

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    sittc60054    config:ess    config:ess_add_edit_delete_timeoff    config:add_edit_delete_timeoff_request_sm    config:ess_request_calendar    mobile    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60054: Requests - Cross-day time off validation, add time off ending at midnight, and approve from SM monthly calendar
    [Documentation]    Requests - Unable to add cross day time off
    ${time_off_data}    Get Time Off Data    start_date=2_6    start_time=22:00    end_time=2:00
    ${edit_time_off_data}    Get Time Off Data    start_time=20:00    end_time=00:00

    Open Mobile ESS App    sittc60054
    Login Mobile Ess App    ESS7_STORE11
    Navigate To Request Module On Mobile ESS

    Open Add Request Page On Mobile ESS
    Switch To Time Off Request On Mobile ESS
    Add Time Off Request On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[reason]    ${time_off_data}[notes]
    Click Submit Request On Mobile ESS
    Verify Invalid Error Data Message On Mobile ESS
    Swipe To Request Start Date On Mobile ESS
    Select Request Start Date On Mobile ESS    ${time_off_data}[start_date]
    Select Request Start Time On Mobile ESS    ${edit_time_off_data}[start_time]    prepopulated_start_time=${time_off_data}[start_time]
    Select Request End Time On Mobile ESS    ${edit_time_off_data}[end_time]     prepopulated_end_time=${time_off_data}[end_time]
    Submit Request On Mobile ESS
    Verify Pending Time Off Request List Item On Mobile ESS    ${time_off_data}[start_date]    ${edit_time_off_data}[start_time]    ${edit_time_off_data}[end_time]
    Close Mobile Application    sittc60054_ess7_cross_day_time_off

    Open SM Native Application On Mobile Phone    sittc60054
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS7_STORE11    ${time_off_data}[start_date]    ${edit_time_off_data}[start_time]    ${edit_time_off_data}[end_time]    ${time_off_data}[status]
    Approve Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]    ${time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App    ESS7_STORE11    ${time_off_data}[start_date]    ${edit_time_off_data}[start_time]    ${edit_time_off_data}[end_time]    ${time_off_data}[status_after_approval]
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    status=${time_off_data}[status_after_approval]
    [Teardown]    Teardown Test Case    sittc60054_sm1_cross_day_time_off_approve
