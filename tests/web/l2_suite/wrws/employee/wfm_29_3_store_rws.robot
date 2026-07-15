*** Settings ***
Documentation       Test case for verifying Add, Edit & Delete Day Off request with Holiday hours in SM Request Calendar page

Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up All Requests For User On Date    ESS5_STORE1    SM1_STORE1    2_1    2_1    AND
...                     Close Browser

Test Tags    action:write    battc00160    dev:moiz    config:holiday_hours_enabled    config:use_leave_hrs_in_ta:y    bat_phase1    om_hr
...    config:add_edit_delete_dayoff_request_sm


*** Test Cases ***
BATTC00160: Verify add/edit/delete day off request in SM Request Calendar with holiday hours
    [Documentation]    Test case for verifying Add, Edit & Delete Day Off request with Holiday hours in SM Request Calendar page.
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${user}    Get User    user_key=ESS5_STORE1
    ${day_off_data}    Get Day Off Data    template_name=paid_approved    start_date=2_1
    ...    status_before_approval=RequestStatus.NOT_REVIEWED    holiday_hours={"1":"8"}
    Cleanup Existing ESS Day Off Requests From SM On Request Calendar On Web    ${user}[displayName]    num_of_weeks=0
    ...    specific_week_offset_day=${day_off_data}[start_date]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web    ${user}[displayName]    ${day_off_data}[start_date]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_before_approval]
    ...    ${day_off_data}[holiday_hours]
    Edit Day Off Request Status And Verify API Success On Request Calendar Page On Web    ${user}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_before_approval]
    ...    ${day_off_data}[status_after_approval]
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${user}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]
