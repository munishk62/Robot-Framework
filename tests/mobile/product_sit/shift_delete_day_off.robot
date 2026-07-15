*** Settings ***
Documentation       BATTC00181 - Verify ESS user is able to delete day off requests in mobility without holiday hours

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Clean Up Day Off Request For User On Date    ESS3_STORE2    SM1_STORE2    start_date_offset=4_4    end_date_offset=4_4

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:ashish    battc00181    config:ess    config:holiday_hours_disabled    config:ess_add_edit_delete_dayoff    bat_phase2
...    mobile
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00181: Verify ESS user is able to delete day off requests in mobility without holiday hours
    [Documentation]    Verify ESS user is able to delete day off requests in mobility without holiday hours
    ${day_off_data1}    Get Day Off Data    start_date=4_4    end_date=4_4    reason=DayOffReasonType.PAID_VACATION
    Open Mobile ESS App    battc00181
    Login Mobile Ess App    ESS3_STORE2
    Navigate To Request Module On Mobile ESS

    Open Add Request Page On Mobile ESS
    Add Day Off Request On Mobile ESS    ${day_off_data1}[start_date]    ${day_off_data1}[end_date]    ${day_off_data1}[reason]
    ...    ${day_off_data1}[notes]
    Verify Pending Day Off Request List Item On Mobile ESS    ${day_off_data1}[start_date]    ${day_off_data1}[end_date]
    Tap Pending Day Off Request List Item On Mobile ESS    ${day_off_data1}[start_date]    ${day_off_data1}[end_date]
    Delete Request On Mobile ESS
    Verify No Pending Day Off Request List Item On Mobile ESS    ${day_off_data1}[start_date]    ${day_off_data1}[end_date]

    [Teardown]    Teardown Test Case    battc00181
