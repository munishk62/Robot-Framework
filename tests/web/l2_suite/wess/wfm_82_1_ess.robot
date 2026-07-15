*** Settings ***
Documentation       Verify User Can Access All ESS Pages Without Error

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/navigation_menu.resource

Test Teardown       Close Browser

Test Tags           action:read    battc00091    dev:moiz    bat_phase1    config:ess    om_hr


*** Test Cases ***
BATTC00091: Verify user is able to access all the ESS pages without any error
    [Documentation]    Verify that an ESS user can access all ESS pages without error.
    Login And Launch WFM Web App    user_key=ESS2_STORE1
    Expand ESS Navigation Menu On Web
    ${ess_menu_list}    Get ESS Parent Modules From ESS Home Page On Web
    &{expected_headings}    Get All System Values    ESSPageTitles
    Navigate To Each ESS Module From Sidebar And Verify No Error On Web    ${ess_menu_list}    ${expected_headings}
