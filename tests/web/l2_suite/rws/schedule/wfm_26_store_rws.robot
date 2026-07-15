*** Settings ***
Documentation       Verify Week Schedule page print functionality (Weekly Schedule Page)

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/week_schedule.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           dev:kashi    action:read


*** Test Cases ***
WFM-26 Verify Week Schedule Page Print Functionality Is Working Properly
    [Documentation]    Verifies Week Schedule page print icon redirection.
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    ${weekly_schedule_summary_url}    Verify Print Weekly Schedule Summary
    Should Contain    ${weekly_schedule_summary_url}    /weekplan_schedule_report.jsp
