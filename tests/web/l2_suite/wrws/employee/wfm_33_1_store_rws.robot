*** Settings ***
Documentation       Test case for verifying Add, Edit & Delete leave request on Roster page

Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Close Browser

Test Tags    dev:ravi    action:write    battc00042    bat_phase1    config:rws    config:add_edit_delete_dayoff_request_sm
...    config:use_leave_hrs_in_ta:n    config:holiday_hours_disabled    om_hr


*** Test Cases ***
BATTC00042: Verify add/edit/delete day off request in Roster without holiday hours
    [Documentation]    Test case for verifying Add, Edit, Delete Leave Requests on Roster page
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}
    ...    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${day_off_data}    Get Day Off Data
    ${ess_user5}    Get User    user_key=ESS5_STORE1
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user5}
    ...    ${day_off_data}[reason]    8_0
    IF    ${is_alternate_offset_required}
        ${day_off_data}    Get Day Off Data    start_date=8_0    end_date=8_0
    END
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Roster Page On Web
    Search Employee On Roster Page On Web    ${ess_user5}[displayName]
    Click On First Employee Name On Roster Page On Web
    Navigate To Leave Requests Page On Roster Page On Web
    Cleanup Existing Leave Requests On Roster Page On Web    ${day_off_data}[start_date]
    Add Leave Request On Roster Page On Web    ${day_off_data}[start_date]
    ...    ${day_off_data}[end_date]    ${day_off_data}[reason]    ${day_off_data}[status]
    Update Leave Request Status On Roster Page On Web    ${day_off_data}[start_date]    ${day_off_data}[status_after_approval]
    Delete DayOff Request On Roster Page On Web    ${day_off_data}[start_date]
