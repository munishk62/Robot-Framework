*** Settings ***
Documentation       Verify that an ESS user is able to add, edit and delete day off requests and receive notifications with holiday hours

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/ess_request_calendar.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up All Requests For User On Date    ESS3_STORE1    SM1_STORE1    1_3    1_6    AND
...                     Close Browser

Test Tags    action:write    dev:moiz    config:holiday_hours_enabled    config:use_leave_hrs_in_ta:y    bat_phase1
...    config:ess_add_edit_delete_dayoff    om_hr


*** Test Cases ***
BATTC00156: Verify that an ESS user is able to add day off requests and receive notifications with holiday hours
    [Documentation]    Test to verify Add Day Off request with Holiday Hours on Requests Calendar page as ESS User
    [Tags]    battc00156
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${day_off_data}    Get Day Off Data    start_date=1_3    end_date=1_3
    ...    reason=DayOffReasonType.PAID_VACATION    holiday_hours={"3": "8"}
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Cleanup All Existing ESS Requests From SM On Request Calendar On Web    ${ess_user}[displayName]    num_of_weeks=0
    ...    specific_week_offset_day=${day_off_data}[start_date]
    Close Browser Tab On Web
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    Navigate To ESS Request Calendar Page
    Create ESS Day Off Request And Verify API Success    ${day_off_data}[start_date]    ${day_off_data}[start_date]
    ...    ${day_off_data}[reason]    holiday_hours=${day_off_data}[holiday_hours]
    Verify Day Off Request Details On Requests Calendar Page On Web    ${ess_user}[displayName]    ${day_off_data}[status]
    ...    ${day_off_data}[start_date]    ${day_off_data}[start_date]    ${day_off_data}[reason]
    ...    holiday_hours=${day_off_data}[holiday_hours]
    ${my_work_enabled}    Get Config Value    key=MYWORK_ENABLED
    ${dayoff_my_work_notification}    Get Config Value    key=DAYOFF_MYWORK_NOTIFICATIONS_ENABLED
    IF    ${my_work_enabled} and ${dayoff_my_work_notification}
        Log    Both MYWORK_ENABLED and DAYOFF_MYWORK_NOTIFICATIONS_ENABLED are True
        Navigate To Web My Work Page On Web
        Verify ESS Day Off Request Notification On My Work On Web    ${day_off_data}[start_date]
        Capture Screenshot On Webpage
        Navigate To ESS Request Calendar Page
    END

BATTC00155: Verify that an ESS user is able to edit day off requests with holiday hours
    [Documentation]    Test to verify Edit Day Off request with Holiday Hours on Requests Calendar page as ESS User
    [Tags]    battc00155
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${day_off_edit_data}    Get Day Off Data    start_date=1_4    end_date=1_5
    ...    reason=DayOffReasonType.PAID_VACATION    holiday_hours={"4": "8", "5": "8"}
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Cleanup All Existing ESS Requests From SM On Request Calendar On Web    ${ess_user}[displayName]    num_of_weeks=0
    ...    specific_week_offset_day=${day_off_edit_data}[start_date]
    Close Browser Tab On Web
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    Navigate To ESS Request Calendar Page
    Create ESS Day Off Request And Verify API Success    ${day_off_edit_data}[start_date]    ${day_off_edit_data}[end_date]
    ...    ${day_off_edit_data}[reason]    holiday_hours=${day_off_edit_data}[holiday_hours]
    Verify Day Off Request Details On Requests Calendar Page On Web    ${ess_user}[displayName]    ${day_off_edit_data}[status]
    ...    ${day_off_edit_data}[start_date]    ${day_off_edit_data}[end_date]    ${day_off_edit_data}[reason]
    ...    holiday_hours=${day_off_edit_data}[holiday_hours]
    Edit Day Off Request On Requests Calendar Page On Web    ${day_off_edit_data}[start_date]
    ...    edit_start_date=${day_off_edit_data}[end_date]

BATTC00154: Verify that an ESS user is able to delete day off requests with holiday hours
    [Documentation]    Test to verify Delete Day Off request with Holiday Hours on Requests Calendar page as ESS User
    [Tags]    battc00154
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${day_off_delete_data}    Get Day Off Data    start_date=1_6
    ...    reason=DayOffReasonType.PAID_VACATION    holiday_hours={"6": "8"}
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Cleanup All Existing ESS Requests From SM On Request Calendar On Web    ${ess_user}[displayName]    num_of_weeks=0
    ...    specific_week_offset_day=${day_off_delete_data}[start_date]
    Close Browser Tab On Web
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    Navigate To ESS Request Calendar Page
    Create ESS Day Off Request And Verify API Success    ${day_off_delete_data}[start_date]    ${day_off_delete_data}[start_date]
    ...    ${day_off_delete_data}[reason]    holiday_hours=${day_off_delete_data}[holiday_hours]
    Verify Day Off Request Details On Requests Calendar Page On Web    ${ess_user}[displayName]    ${day_off_delete_data}[status]
    ...    ${day_off_delete_data}[start_date]    ${day_off_delete_data}[start_date]    ${day_off_delete_data}[reason]
    ...    holiday_hours=${day_off_delete_data}[holiday_hours]
    Delete ESS Day Off Request And Verify API Success    ${ess_user}[displayName]    ${day_off_delete_data}[start_date]
    ...    ${day_off_delete_data}[status]
