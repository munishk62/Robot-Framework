*** Settings ***
Documentation       BATTC00112 - Verify login using valid credentials for WFM application from mobility and logout

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           action:read    dev:kishan    battc00112    mobile    bat_phase2
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00112: Verify login using valid credentials for WFM application from mobility and logout
    [Documentation]    Verifies that users can successfully log in to the WFM mobile ESS application with valid credentials and log out
    Open Mobile ESS App    battc00112
    Login Mobile Ess App    ESS2_STORE2
    Logout Mobile ESS App From Top Level Page

    [Teardown]    Teardown Test Case    battc00112
