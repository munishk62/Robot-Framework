*** Settings ***
Documentation       Verify if the user is able to open the existing Payroll and Policy Check Sets.

Resource            resources/web/authentication/login.resource
Resource            resources/web/payroll/release_checks.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    config:rta    action:read    obsolete


*** Test Cases ***
WFM-48 Verify Already Added Payroll Check Set And Policy Check Set
    [Documentation]    Test case to verify if the user is able to open the existing Payroll and Policy Check Sets.
    [Tags]    payroll_checkset    policy_checkset
    # Perform login as corporate user
    ${sys_admin_user}    Get User    user_key=SYSADMIN
    Login To WFM    ${sys_admin_user}[user_key]

    Navigate To RTA Payroll Release Checks Page On Web
    # Open an existing Payroll Check Set and take screenshot.
    ${payroll_checkset_present}    Open An Existing Check Set From Payroll Check Sets On Web
    IF    not ${payroll_checkset_present}
        Skip    No checkset present in Payroll Check Sets!
    END

    # Open an existing Policy Check Set and take screenshot
    ${policy_checkset_present}    Open An Existing Check Set From Policy Check Sets On Web
    IF    not ${policy_checkset_present}
        Skip    No checkset present in Policy Check Sets!
    END
