*** Settings ***
Documentation       BATTC00183 - Verify ESS user is able to edit time off requests in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Clean Up Time Off Request For User On Date    ESS3_STORE2    SM1_STORE2    start_date_offset=4_2

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           dev:kishan    battc00183    config:ess    config:ess_add_edit_delete_timeoff    bat_phase2    mobile
...    config:mobile_shift_enabled    regrooming_required


*** Test Cases ***
BATTC00183: Verify ESS user is able to edit time off requests in mobility
    [Documentation]    Verify ESS user is able to edit time off requests in mobility
    ${reason_timeoff}    Get System Value    TimeOffReasonType    PAID_VACATION
    ${time_off_data}    Get Time Off Data    template_name=edit_timeoff    start_date=4_2    reason=${reason_timeoff}    notes=Time Off Request
    Open Mobile ESS App    battc00183
    Login Mobile Ess App    ESS3_STORE2
    Navigate To Request Module On Mobile ESS

    Open Add Request Page On Mobile ESS
    Switch To Time Off Request On Mobile ESS
    Add Time Off Request On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${time_off_data}[reason]    ${time_off_data}[notes]
    Verify Pending Time Off Request List Item On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    Tap Pending Time Off Request List Item On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    Edit Time Off Request On Mobile ESS    request_start_time=${time_off_data}[edit_start_time]    prepopulated_start_time=${time_off_data}[start_time]
    Navigate Back On Mobile ESS
    Verify Pending Time Off Request List Item On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[edit_start_time]    ${time_off_data}[end_time]

    [Teardown]    Teardown Test Case    battc00183
