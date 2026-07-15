*** Settings ***
Documentation       Test case to verify PDF functionality on exception management page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           dev:amol    action:read    config:rta    obsolete


*** Test Cases ***
WFM-49 Verify PDF Export Button Functionality On Exception Management Page
    [Documentation]    Test case to verify PDF export button functionality on exception management page

    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Verify PDF Export Button On Web
