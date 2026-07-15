*** Settings ***
Documentation       BATTC00109 - Verify ESS user is able to add day off requests in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keywords
...        Clean Up Day Off Request For User On Date    ESS3_STORE2    SM1_STORE2    start_date_offset=4_4    end_date_offset=4_4    AND
...        Clean Up Day Off Request For User On Date    ESS3_STORE2    SM1_STORE2    start_date_offset=4_5    end_date_offset=4_5

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:bushra    battc00109    config:ess    config:holiday_hours_disabled    config:ess_add_edit_delete_dayoff    bat_phase2
...    mobile
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00109: Verify ESS user is able to add day off requests in mobility
    [Documentation]    Verify ESS user is able to add day off requests in mobility
    ${day_off_data1}    Get Day Off Data    start_date=4_4    end_date=4_4    reason=DayOffReasonType.PAID_VACATION
    ${day_off_data2}    Get Day Off Data    start_date=4_5    end_date=4_5    reason=DayOffReasonType.PAID_VACATION
    Open Mobile ESS App    battc00109
    Login Mobile Ess App    ESS3_STORE2
    Navigate To Request Module On Mobile ESS

    Open Add Request Page On Mobile ESS
    Add Day Off Request On Mobile ESS    ${day_off_data1}[start_date]    ${day_off_data1}[end_date]    ${day_off_data1}[reason]
    ...    ${day_off_data1}[notes]
    Verify Pending Day Off Request List Item On Mobile ESS    ${day_off_data1}[start_date]    ${day_off_data1}[end_date]
    Open Add Request Page On Mobile ESS
    Add Day Off Request On Mobile ESS    ${day_off_data2}[start_date]    ${day_off_data2}[end_date]    ${day_off_data2}[reason]
    ...    ${day_off_data2}[notes]
    Verify Pending Day Off Request List Item On Mobile ESS    ${day_off_data2}[start_date]    ${day_off_data2}[end_date]

    [Teardown]    Teardown Test Case    battc00109
