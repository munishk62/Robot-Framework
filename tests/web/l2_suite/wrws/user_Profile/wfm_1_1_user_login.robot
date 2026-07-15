*** Settings ***
Documentation       Test case to Verify login using valid credentials for WFM application and logout
...
...                 NOTE: This test uses OR condition for config filtering.
...                 Test runs if ANY of these conditions match:
...                 - 'direct_login' is in enabled_configs array
...                 - DIRECT_LOGIN config value equals True
...                 - DIRECT_LOGIN config value equals true
...                 This allows flexibility for different environment configurations.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/user_Profile/user_profile.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rta/operations/device.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/ess/ess_request_calendar.resource

Test Teardown       Close Browser

Test Tags    dev:ravi    battc00001    bat_phase1    action:read    config_or:direct_login    config_or:ess    config_or:rws
...    config_or:rta    om_hr


*** Test Cases ***
BATTC00001: Verify login using valid credentials for WFM application and logout - Verify Corp Login Using Valid Credentials And Logout
    [Documentation]    Test case to Verify Corp login using valid credentials for WFM application and logout
    ${is_direct_login}    Get Config Value    DIRECT_LOGIN
    ${is_rws_enabled}    Is Config Enabled    rws
    ${is_rta_enabled}    Is Config Enabled    rta

    IF    ${is_direct_login}
        Login And Launch WFM Web App    user_key=SYSADMIN
        IF    ${is_rws_enabled}
            Navigate To RWS Users User Profile Page On Web
        END
        IF    ${is_rta_enabled}    Navigate To RTA Devices Device Page On Web
        Log Out From Web Application
    ELSE
        Skip    Direct Login is disabled, skipping the test case
    END

BATTC00001: Verify login using valid credentials for WFM application and logout - Verify SM Login Using Valid Credentials And Logout
    [Documentation]    Test case to Verify SM login using valid credentials for WFM application and logout
    ${is_direct_login}    Get Config Value    DIRECT_LOGIN
    ${is_rws_enabled}    Is Config Enabled    rws
    ${is_rta_enabled}    Is Config Enabled    rta
    IF    ${is_direct_login}
        Login And Launch WFM Web App    user_key=SM1_STORE1
        IF    ${is_rws_enabled}
            Navigate To RWS Schedule Week Schedule Page On Web
        END
        IF    ${is_rta_enabled}
            Navigate To RTA Operations Exception Management Page On Web
        END
        Log Out From Web Application
    ELSE
        Skip    Direct Login is disabled, skipping the test case
    END

BATTC00001: Verify login using valid credentials for WFM application and logout - Verify ESS Login Using Valid Credentials And Logout
    [Documentation]    Test case to Verify ESS login using valid credentials for WFM application and logout
    ${is_direct_login}    Get Config Value    DIRECT_LOGIN
    ${is_ess_enabled}    Is Config Enabled    ess
    IF    ${is_direct_login}
        Login And Launch WFM Web App    user_key=ESS3_STORE1
        IF    ${is_ess_enabled}    Navigate To ESS Request Calendar Page
        Log Out From Web Application
    ELSE
        Skip    Direct Login is disabled, skipping the test case
    END
