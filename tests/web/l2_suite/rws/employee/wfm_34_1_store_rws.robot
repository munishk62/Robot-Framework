*** Settings ***
Documentation       Test case for verifying Add, Edit & Delete time-off request on Roster page

Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Close Browser

Test Tags    dev:ravi    action:write    battc00043    bat_phase1    config:rws    config:add_edit_delete_timeoff_request_sm
...    config:add_edit_delete_dayoff_request_sm    om_hr


*** Test Cases ***
BATTC00043: Verify add/edit/delete time off request in Roster
    [Documentation]    Test case for verifying Add, Edit, Delete Time-off Requests on Roster page
    ${time_off_data}    Get Time Off Data    template_name=approve_timeoff
    ${ess_user_5}    Get User    user_key=ESS5_STORE1
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user_5}
    ...    ${time_off_data}[reason]    8_2    request_type=Time Off
    IF    ${is_alternate_offset_required}
        ${time_off_data}    Get Time Off Data    template_name=approve_timeoff    start_date=8_2
    END
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Roster Page On Web
    Click On Associate On Roster Page On Web    ${ess_user_5}[displayName]
    Navigate To TimeOff Requests Page On Roster Page On Web
    Cleanup Existing TimeOff Requests On Roster Page On Web    ${time_off_data}[start_date]
    Add TimeOff Request On Roster Page On Web    ${time_off_data}[start_date]    ${time_off_data}[reason]    ${time_off_data}[status]
    ...    ${time_off_data}[start_time]    ${time_off_data}[duration]    ${time_off_data}[comment]
    Update TimeOff Request On Roster Page On Web    ${time_off_data}[start_date]    ${time_off_data}[status_after_approval]
    Delete TimeOff Request On Roster Page On Web    ${time_off_data}[start_date]
