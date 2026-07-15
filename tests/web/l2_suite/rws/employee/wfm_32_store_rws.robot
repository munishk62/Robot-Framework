*** Settings ***
Documentation       Test case for verifying Basic employee details on Roster page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/employee/roster.resource

Test Teardown       Close Browser

Test Tags           dev:ravi    action:read    battc00041    bat_phase1    config:rws    om_hr


*** Test Cases ***
BATTC00041: Verify roster basic details for the associate
    [Documentation]    Test case for verifying Associate basic details on Roster page
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${associate_data}    Get User    user_key=ESS1_STORE1
    Navigate To RWS Employee Roster Page On Web
    ${associate_id}    Get Id For The Given Associate On Roster Page On Web    ${associate_data}[displayName]
    ${associate_id_after_filter}    Apply Filter On Associate Id On Roster Page On Web    ${associate_id}
    Should Be Equal    ${associate_id_after_filter}    ${associate_id}    Associate Ids do not match after applying filter on id
    Click On First Employee Name On Roster Page On Web
    Navigate To Employee Basic Details Page On Web
    Verify Employee Basic Details On Roster Page On Web    ${associate_data}[displayName]    ${associate_id}
