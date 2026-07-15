*** Settings ***
Documentation       This resource file contains keywords related to the Labor Forecast > Workload Batch Config page in RWS on web.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/labor_forecast/workload_batch_config_page.py


*** Keywords ***
Navigate To RWS Workload Batch Config Page On Web
    [Documentation]    Navigate To RWS -> Labor Forecast -> Workload Batch Config Page On Web
    Navigate To Specific Page On Web    rws    labor_forecast    workload_batch_config

Click On Add Config Button In Workload Batch Config Page On Web
    [Documentation]    Click On Add Config Button In Workload Batch Config Page On Web
    Click Element On Webpage    ${WORKLOAD_BATCH_CONFIG_ADD_CONFIG_BTN}
    ...    error_message=Failed to click on Add Config button in Workload Batch Config page on web
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${WORKLOAD_BATCH_CONFIG_ADD_CONFIG_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Failed to load "Add Config" page
    Capture Screenshot On Webpage
