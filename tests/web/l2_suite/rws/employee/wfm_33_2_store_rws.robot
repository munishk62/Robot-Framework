*** Settings ***
Documentation       Test case for verifying Add, Edit & Delete leave request with Holiday hours on Roster page

Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/authentication/login.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up All Requests For User On Date    ESS5_STORE1    SM1_STORE1    1_0    1_0    AND
...                     Close Browser

Test Tags    dev:moiz    action:write    battc00159    config:holiday_hours_enabled    config:use_leave_hrs_in_ta:y    bat_phase1    om_hr
...    config:add_edit_delete_dayoff_request_sm


*** Test Cases ***
BATTC00159: Verify add/edit/delete day off request in Roster with holiday hours
    [Documentation]    Test Case to Verify Add, Edit & Delete Leave Requests with Holiday hours by Store Manager for an Associate on Roster Page
    ${day_off_data}    Get Day Off Data    offset_date=1_0
    ...    reason=DayOffReasonType.UNPAID_DAY_OFF    status_before_approval=RequestStatus.NOT_REVIEWED
    ...    status_after_approval=RequestStatus.APPROVED    holiday_hours={"0": "4"}
    ${ess_user5}    Get User    user_key=ESS5_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Roster Page On Web
    Search Employee On Roster Page On Web    ${ess_user5}[displayName]
    Click On First Employee Name On Roster Page On Web
    Navigate To Leave Requests Page On Roster Page On Web
    Cleanup Existing Leave Requests On Roster Page On Web    ${day_off_data}[offset_date]
    Add Leave Request On Roster Page On Web    ${day_off_data}[offset_date]
    ...    ${day_off_data}[offset_date]    ${day_off_data}[reason]    ${day_off_data}[status_before_approval]
    ...    ${day_off_data}[holiday_hours]
    Update Leave Request Status On Roster Page On Web    ${day_off_data}[offset_date]    ${day_off_data}[status_after_approval]
    Delete DayOff Request On Roster Page On Web    ${day_off_data}[offset_date]
