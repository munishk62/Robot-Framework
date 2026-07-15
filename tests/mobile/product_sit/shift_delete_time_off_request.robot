*** Settings ***
Documentation       BATTC00184 - Verify ESS user is able to delete time off requests in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Clean Up Time Off Request For User On Date    ESS3_STORE2    SM1_STORE2    start_date_offset=4_4

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           dev:kishan    battc00184    config:ess    config:ess_add_edit_delete_timeoff    bat_phase2    mobile
...    config:mobile_shift_enabled    regrooming_required


*** Test Cases ***
BATTC00184: Verify ESS user is able to delete time off requests in mobility
    [Documentation]    Verify ESS user is able to delete time off requests in mobility
    ${reason_timeoff}    Get System Value    TimeOffReasonType    PAID_VACATION
    ${time_off_data}    Get Time Off Data    template_name=delete_timeoff    start_date=4_3    reason=${reason_timeoff}
    ...    notes=Time Off Request
    Open Mobile ESS App    battc00184
    Login Mobile Ess App    ESS3_STORE2
    Navigate To Request Module On Mobile ESS

    Open Add Request Page On Mobile ESS
    Switch To Time Off Request On Mobile ESS
    Add Time Off Request On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${time_off_data}[reason]    ${time_off_data}[notes]
    Verify Pending Time Off Request List Item On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    Tap Pending Time Off Request List Item On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    Delete Request On Mobile ESS
    Verify No Pending Time Off Request List Item On Mobile ESS    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]

    [Teardown]    Teardown Test Case    battc00184
