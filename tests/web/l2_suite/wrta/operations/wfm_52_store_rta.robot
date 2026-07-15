*** Settings ***
Documentation       Test case to verify print summary functionality on exception management page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           battc00059    dev:amol    action:read    obsolete


*** Test Cases ***
WFM-52 Verify Print Functionality
    [Documentation]    Test case to verify print functionality on exception management page

    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Verify Print Summary On Exception Management Page On Web
