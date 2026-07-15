*** Settings ***
Documentation       SITTC60048 - Requests - Create day off request from ESS and SM deletes request from list view

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup         Clean Up Day Off Request For User On Date    ESS5_STORE11    SM1_STORE11    start_date_offset=4_4    end_date_offset=4_4
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    sittc60048    config:ess    config:ess_add_edit_delete_dayoff    config:add_edit_delete_dayoff_request_sm    config:ess_request_calendar    mobile    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60048: Requests - Create day off request from ESS and SM deletes request from list view
    [Documentation]    Verify SM can delete a day off request from list view.
    ${day_off_data}    Get Day Off Data    start_date=4_4    end_date=4_4
    ${holiday_hours_value}    Evaluate    list($day_off_data["holiday_hours"].values())[0]

    Open Mobile ESS App    sittc60048
    Login Mobile Ess App    ESS5_STORE11
    Navigate To Request Module On Mobile ESS
    Open Add Request Page On Mobile ESS
    ${is_holiday_hours_enabled}    Is Config Enabled    holiday_hours_enabled
    IF    ${is_holiday_hours_enabled}
        Add Day Off Request On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[reason]
        ...    ${day_off_data}[notes]    ${holiday_hours_value}
    ELSE
        Add Day Off Request On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[reason]
        ...    ${day_off_data}[notes]
    END
    Verify Pending Day Off Request List Item On Mobile ESS    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    Close Mobile Application    sittc60048_day_off_ess_create

    Open SM Native Application On Mobile Phone    sittc60048
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Click Pending Requests On SM Phone App
    Apply Filter On Pending Requests List On SM Phone App    end_date=${day_off_data}[start_date]
    Select Specific Day Off Request On SM Phone App    ESS5_STORE11    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[status]
    Delete Request On SM Phone App
    Verify Deleted Day Off Request Not Present In List View On SM Phone App    ESS5_STORE11    ${day_off_data}[start_date]    ${day_off_data}[status]

    [Teardown]    Teardown Test Case    sittc60048_sm_delete_list_view
