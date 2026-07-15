*** Settings ***
Documentation       This resource file contains keywords related to the Labor Forecast > Activities page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/labor_forecast/activities_page.py


*** Keywords ***
Navigate To RWS Activities Page On Web
    [Documentation]    Navigate To RWS -> Labor Forecast -> Activities Page On Web
    Navigate To Specific Page On Web    rws    labor_forecast    activities

Click On Add Task Button In Activities Page On Web
    [Documentation]    Click On Add Task Button In Activities Page On Web
    Click Element On Webpage    ${ACTIVITIES_ADD_TASK_BTN}
    ...    error_message=Failed to click on Add Task button in Activities page on web
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ACTIVITIES_ADD_TASK_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Failed to load "Add Task" page
    Capture Screenshot On Webpage
