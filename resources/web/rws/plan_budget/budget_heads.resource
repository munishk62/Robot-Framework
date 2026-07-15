*** Settings ***
Documentation       This resource file contains keywords related to the Plan Budget > Budget Heads page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/plan_budget/budget_heads_page.py


*** Keywords ***
Navigate To RWS Budget Heads Page On Web
    [Documentation]    Navigate To RWS -> Plan Budget -> Budget Heads Page On Web
    Navigate To Specific Page On Web    rws    plan_budget    budget_heads

Click On Add Budget Head Button In Budget Heads Page On Web
    [Documentation]    Click On Add Budget Head Button In Budget Heads Page On Web
    Click Element On Webpage    ${BUDGET_HEADS_ADD_BUDGET_HEAD_BTN}
    ...    error_message=Failed to click on Add Budget Head button in Budget Heads page on Web
    Wait Until Element Is Visible On Webpage    ${BUDGET_HEADS_ADD_BUDGET_HEAD_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Budget Head form is not displayed after clicking on Add Budget Head
    Capture Screenshot On Webpage
