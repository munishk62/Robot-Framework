*** Settings ***
Documentation       This resource file contains keywords related to the Plan Budget > Budget Plan page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/plan_budget/budget_plan_page.py


*** Keywords ***
Navigate To RWS Budget Plan Page On Web
    [Documentation]    Navigate To RWS -> Plan Budget -> Budget Plan Page On Web
    Navigate To Specific Page On Web    rws    plan_budget    budget_plan

Click On Add Budget Plan Button In Budget Plan Page On Web
    [Documentation]    Click On Add Budget Plan Button In Budget Plan Page On Web
    Click Element On Webpage    ${BUDGET_PLAN_ADD_BUDGET_PLAN_BTN}
    ...    error_message=Unable to click on Add Budget Plan button in Budget Plan page
    Wait Until Element Is Visible On Webpage    ${BUDGET_PLAN_ADD_BUDGET_PLAN_ACTIVE_TAB}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Budget Plan tab is not active after clicking on Add Budget Plan button in Budget Plan page
    Capture Screenshot On Webpage

Click On Copy Budget Plan Tab In Budget Plan Page On Web
    [Documentation]    Click On Copy Budget Plan Tab In Budget Plan Page On Web
    Click Element On Webpage    ${BUDGET_PLAN_COPY_BUDGET_PLAN_TAB}
    ...    error_message=Unable to click on Copy Budget Plan tab in Budget Plan page
    Wait Until Element Is Visible On Webpage    ${BUDGET_PLAN_COPY_BUDGET_PLAN_ACTIVE_TAB}
    ...    error_message=Copy Budget Plan tab is not active after clicking on Copy Budget Plan tab in Budget Plan page
    Capture Screenshot On Webpage
