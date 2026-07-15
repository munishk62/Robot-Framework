*** Settings ***
Documentation       Test case for verifying Add, Edit & Delete leave request on SM Calendar page

Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up All Requests For User On Date    ESS5_STORE1    SM1_STORE1    2_1    8_7    AND
...                     Close Browser

Test Tags    dev:azar    action:write    battc00036    config:rws    config:use_leave_hrs_in_ta:n    config:holiday_hours_disabled
...    config:add_edit_delete_dayoff_request_sm    bat_phase1    om_hr


*** Test Cases ***
BATTC00036: Verify add/edit/delete day off request in SM Request Calendar without holiday hours
    [Documentation]    Test Case to Verify Request Calendar Operations Day Off by Store Manager for an Associate in RWS Application
    ...    As Store manager Create Day Off request for an Associate, Approve it and then Delete it.
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}
    ...    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${ess_user5}    Get User    user_key=ESS5_STORE1
    ${day_off_data}    Get Day Off Data    template_name=unpaid_approved    start_date=2_1
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user5}
    ...    ${day_off_data}[reason]    8_1
    IF    ${is_alternate_offset_required}
        ${day_off_data}    Get Day Off Data    template_name=unpaid_approved    start_date=8_1
    END
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Request Calendar Page On Web
    Switch To Week View On Request Calendar Page On Web
    Select Day On Request Calendar Page    ${day_off_data}[start_date]
    VAR    ${associate_name}    ${ess_user5}[displayName]
    ${creation_day}    Find Next Available Day Without Any Existing Requests On Request Calendar Page On Web    ${associate_name}
    ...    ${day_off_data}[start_date]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web    ${associate_name}    ${creation_day}
    ...    ${creation_day}    ${day_off_data}[reason]    ${day_off_data}[status]
    Edit Day Off Request Status And Verify API Success On Request Calendar Page On Web    ${associate_name}    ${creation_day}
    ...    ${day_off_data}[reason]    ${day_off_data}[status]    ${day_off_data}[status_after_approval]
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${associate_name}    ${creation_day}
    ...    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]
