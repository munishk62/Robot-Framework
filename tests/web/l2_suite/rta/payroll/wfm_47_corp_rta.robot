*** Settings ***
Documentation       This test case is to verify that user is able to add, edit and delete Payroll and Policy Check Sets
...                 from Release Checks page

Resource            resources/web/authentication/login.resource
Resource            resources/web/payroll/release_checks.resource

Test Teardown       Close Browser

Test Tags           dev:azar    config:rta    action:write    bat_phase1    module:timekeeping


*** Test Cases ***
BATTC00056: Verify add/edit/delete operations for payroll check sets
    [Documentation]    Test case to verify user is able to add, edit and delete Payroll Check Sets
    [Tags]    battc00056
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${active_status}    Get System Value    ReleaseChecks    ACTIVE_STATUS
    ${draft_status}    Get System Value    ReleaseChecks    DRAFT_STATUS
    ${payroll_checkset_data}    Get Payroll Data
    Navigate To RTA Payroll Release Checks Page On Web
    Cleanup Existing Check Set On Web    ${payroll_checkset_data}[payroll_checkset_id]
    ${payroll_checkset_id}    Add Payroll Check Set On Web    ${payroll_checkset_data}[payroll_checkset_name]
    ...    check_set_id=${payroll_checkset_data}[payroll_checkset_id]
    ...    check_set_description=${payroll_checkset_data}[payroll_checkset_description]
    Verify Payroll Check Set Name And Status On Release Checks Page On Web    ${payroll_checkset_id}
    ...    ${payroll_checkset_data}[payroll_checkset_name]    ${draft_status}
    Open Check Set From Payroll Check Sets On Web    ${payroll_checkset_id}
    Update Check Set Name On Web    ${payroll_checkset_data}[edited_payroll_checkset_name]
    Update Check Set Description On Web    ${payroll_checkset_data}[edited_payroll_checkset_description]
    Update Check Set Status On Web    ${active_status}
    Save The Check Set On Web
    Verify Payroll Check Set Name And Status On Release Checks Page On Web    ${payroll_checkset_id}
    ...    ${payroll_checkset_data}[edited_payroll_checkset_name]    ${active_status}
    [Teardown]    Run Keyword And Continue On Failure
    ...    Run Keywords
    ...    Navigate To RTA Payroll Release Checks Page On Web    AND
    ...    Delete Check Set From Payroll Check Sets On Web    ${payroll_checkset_id}

BATTC00057: Verify add/edit/delete operations for policy check sets
    [Documentation]    Test case to verify user is able to add, edit and delete Policy Check Sets
    [Tags]    battc00057
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${active_status}    Get System Value    ReleaseChecks    ACTIVE_STATUS
    ${draft_status}    Get System Value    ReleaseChecks    DRAFT_STATUS
    ${policy_checkset_data}    Get Pay Policy Data
    Navigate To RTA Payroll Release Checks Page On Web
    Cleanup Existing Check Set On Web    ${policy_checkset_data}[policy_checkset_id]
    ${policy_checkset_id}    Add Policy Check Set On Web    ${policy_checkset_data}[policy_checkset_name]
    ...    check_set_id=${policy_checkset_data}[policy_checkset_id]
    ...    check_set_description=${policy_checkset_data}[policy_checkset_description]
    Verify Policy Check Set Name And Status On Release Checks Page On Web    ${policy_checkset_id}
    ...    ${policy_checkset_data}[policy_checkset_name]    ${draft_status}
    Open Check Set From Policy Check Sets On Web    ${policy_checkset_id}
    Update Check Set Name On Web    ${policy_checkset_data}[edited_policy_checkset_name]
    Update Check Set Description On Web    ${policy_checkset_data}[edited_policy_checkset_description]
    Update Check Set Status On Web    ${active_status}
    Save The Check Set On Web
    Verify Policy Check Set Name And Status On Release Checks Page On Web    ${policy_checkset_id}
    ...    ${policy_checkset_data}[edited_policy_checkset_name]    ${active_status}
    [Teardown]    Run Keyword And Continue On Failure
    ...    Run Keywords
    ...    Navigate To RTA Payroll Release Checks Page On Web    AND
    ...    Delete Check Set From Policy Check Sets On Web    ${policy_checkset_id}
