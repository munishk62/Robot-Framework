*** Settings ***
Documentation       Test case for verifying Add, Edit & Delete leave request on Request Calendar page and Bulk Request page

Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/web/rws/employee/requests.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up All Requests For User On Date    ESS5_STORE1    SM1_STORE1    1_5    1_5    AND
...                     Close Browser

Test Tags    action:write    battc00161    dev:azar    config:holiday_hours_enabled    config:use_leave_hrs_in_ta:y    bat_phase1    om_hr


*** Test Cases ***
BATTC00161: Verify leave processing in bulk request page with holiday hours
    [Documentation]    Test Case to Verify Leave Processing on Bulk Request Page by Store Manager for an Associate in RWS Application
    ...    As Store manager Create Day Off request for an Associate, Approve it and then Delete it.
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user}    Get User    user_key=ESS5_STORE1
    ${day_off_data}    Get Day Off Data    reason=DayOffReasonType.PAID_VACATION
    ...    status_after_approval=RequestStatus.APPROVED    holiday_hours={"5": "8"}
    ${bulk_day_off_data}    Get Bulk Dayoff Requests Data
    VAR    ${creation_day}    ${bulk_day_off_data}[start_date]
    ${filter_data}    Get Request Calendar Filter Data
    Navigate To RWS Employee Requests Page On Web
    Set Filters On Requests Page On Web
    ...    start_date=${creation_day}
    ...    end_date=${creation_day}
    ...    request_type=${bulk_day_off_data}[request_type]
    ...    request_status=${bulk_day_off_data}[status]
    ...    request_reason=${bulk_day_off_data}[reason]

    Confirm Request Not Exist On Requests Page On Web    ${ess_user}[displayName]
    ...    ${creation_day}    ${creation_day}    ${bulk_day_off_data}[reason]    ${bulk_day_off_data}[status]
    Navigate To RWS Employee Request Calendar Page On Web
    Select Day On Request Calendar Page    ${creation_day}
    Switch To Week View On Request Calendar Page On Web
    Set Request Type And Status Filter On Request Calendar Page On Web    ${filter_data}[request_type]    ${filter_data}[request_status]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web    ${ess_user}[displayName]    ${creation_day}
    ...    ${creation_day}    ${day_off_data}[reason]    ${day_off_data}[status]    ${day_off_data}[holiday_hours]
    Navigate To RWS Employee Requests Page On Web
    Set Filters On Requests Page On Web
    ...    start_date=${creation_day}
    ...    end_date=${creation_day}
    ...    request_type=${bulk_day_off_data}[request_type]
    ...    request_status=${bulk_day_off_data}[status]
    ...    request_reason=${bulk_day_off_data}[reason]
    Check For Request Existence On Requests Page On Web    ${ess_user}[displayName]
    ...    ${creation_day}    ${creation_day}    ${bulk_day_off_data}[reason]    ${bulk_day_off_data}[status]
    Set Request Status And Verify Success On Requests Page On Web    ${ess_user}[displayName]
    ...    ${creation_day}    ${creation_day}    ${bulk_day_off_data}[reason]    ${bulk_day_off_data}[status]
    ...    ${bulk_day_off_data}[expected_status_after_approval]
    Navigate To RWS Employee Request Calendar Page On Web
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user}[displayName]    ${creation_day}
    ...    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]
    Navigate To RWS Employee Requests Page On Web
    Set Filters On Requests Page On Web
    ...    start_date=${creation_day}
    ...    end_date=${creation_day}
    ...    request_type=${bulk_day_off_data}[request_type]
    ...    request_status=${bulk_day_off_data}[expected_status_after_approval]
    ...    request_reason=${bulk_day_off_data}[reason]
    Confirm Request Not Exist On Requests Page On Web    ${ess_user}[displayName]
    ...    ${creation_day}    ${creation_day}    ${bulk_day_off_data}[reason]    ${bulk_day_off_data}[expected_status_after_approval]
