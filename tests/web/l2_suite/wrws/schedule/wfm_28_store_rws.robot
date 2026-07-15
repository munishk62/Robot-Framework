*** Settings ***
Documentation       verifies Week Schedule page Legends: opening legend panel and validating all expected legend tabs/categories (labels & visibility) for RWS store context (WFM-28)

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/week_schedule.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           battc00020    action:read    dev:amol    obsolete


*** Test Cases ***
BATTC00020: Verify week navigation for schedule page and review legends
    [Documentation]    Opens Week Schedule legend panel (RWS store context) and validates presence & visibility of all expected legend tabs/categories with correct labels
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    ${is_in_plan_status}    Check If Schedule Is In Plan Status With Rail Road On Web
    Skip If    ${is_in_plan_status}    msg=Schedule is in plan status; legend display cannot be verified in this state.
    Click On Legend Icon And Verify All Tabs
