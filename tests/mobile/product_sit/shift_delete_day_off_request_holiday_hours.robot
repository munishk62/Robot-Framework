*** Settings ***
Documentation       BATTC00182 - Verify ESS user is able to delete day off requests in mobility with holiday hours

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Clean Up Day Off Request For User On Date    ESS3_STORE2    SM1_STORE2    start_date_offset=4_4    end_date_offset=4_4

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:ashish    battc00182    config:ess    bat_phase2    config:holiday_hours_enabled    config:ess_add_edit_delete_dayoff
...    mobile
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00182: Verify ESS user is able to delete day off requests in mobility with holiday hours
    [Documentation]    Verify ESS user is able to delete day off requests in mobility with holiday hours
    ${day_off_data}    Get Day Off Data    start_date=4_4    end_date=4_4
    ...    holiday_hours={"4":"8"}
    ${holiday_hours_value}    Evaluate    list((json.loads($day_off_data["holiday_hours"]) if isinstance($day_off_data["holiday_hours"], str) else $day_off_data["holiday_hours"]).values())[0]    json
    Open Mobile ESS App    battc00182
    Login Mobile Ess App    ESS3_STORE2
    Navigate To Request Module On Mobile ESS

    Open Add Request Page On Mobile ESS
    Add Day Off Request On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[reason]
    ...    ${day_off_data}[notes]    ${holiday_hours_value}
    Verify Pending Day Off Request List Item On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    Tap Pending Day Off Request List Item On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    Delete Request On Mobile ESS
    Verify No Pending Day Off Request List Item On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]

    [Teardown]    Teardown Test Case    battc00182
