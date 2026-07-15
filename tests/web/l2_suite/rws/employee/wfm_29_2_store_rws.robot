*** Settings ***
Documentation       Test case for verifying Add, Approve & Delete time off request on Request Calendar page

Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up All Requests For User On Date    ESS5_STORE1    SM1_STORE1    1_1    8_7    AND
...                     Close Browser

Test Tags           bat_phase1


*** Test Cases ***
BATTC00037: Verify add/edit/delete time off request in SM Request Calendar
    [Documentation]    Test Case to Verify Request Calendar Operations Time Off by Store Manager for an Associate in RWS Application
    ...    As Store manager Create Time Off request for an Associate, Approve it and then Delete it.
    [Tags]    dev:azar    action:write    battc00037    config:rws    config:add_edit_delete_timeoff_request_sm
    ...    config:sm_add_timeoff_request    om_hr
    ${time_off_data}    Get Time Off Data    start_date=1_3    reason=TimeOffReasonType.COMMON_REASON    start_time=16:00    duration=08:00
    ${ess_user5}    Get User    user_key=ESS5_STORE1
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user5}
    ...    ${time_off_data}[reason]    8_3    request_type=Time Off
    IF    ${is_alternate_offset_required}
        ${time_off_data}    Get Time Off Data    start_date=8_3    reason=TimeOffReasonType.COMMON_REASON    start_time=16:00
        ...    duration=08:00
    END
    VAR    ${request_exists}    False
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Cleanup All Existing ESS Requests From SM On Request Calendar On Web    ${ess_user5}[displayName]    num_of_weeks=0
    ...    specific_week_offset_day=${time_off_data}[start_date]
    ${request_created}    Create SM Time Off Request And Verify API Success On Request Calendar Page On Web    ${ess_user5}[displayName]
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[duration]    ${time_off_data}[reason]
    ...    ${time_off_data}[status]
    IF    $request_created != $None
        VAR    ${request_exists}    True
    END
    Edit Time Off Request Status And Verify API Success On Request Calendar Page On Web    ${ess_user5}[displayName]
    ...    ${time_off_data}[start_date]    ${time_off_data}[reason]    ${time_off_data}[start_time]    ${time_off_data}[start_time]
    ...    ${time_off_data}[status]    ${time_off_data}[status_after_approval]
    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user5}[displayName]
    ...    ${time_off_data}[start_date]    ${time_off_data}[reason]    ${time_off_data}[start_time]    ${time_off_data}[start_time]
    ...    ${time_off_data}[status_after_approval]
    VAR    ${request_exists}    False
    [Teardown]    Run Keyword And Ignore Error    Run Keyword If    ${request_exists}
    ...    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user5}[displayName]    ${time_off_data}[start_date]
    ...    ${time_off_data}[reason]    ${time_off_data}[start_time]    ${time_off_data}[start_time]
    ...    ${time_off_data}[status_after_approval]
