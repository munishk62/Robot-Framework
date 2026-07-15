*** Settings ***
Documentation       This resource file contains keywords related to the Predictive Analytics > Forecast Model Setup page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/predictive_analytics/forecast_model_setup_page.py


*** Keywords ***
Navigate To RWS Forecast Model Setup Page On Web
    [Documentation]    Navigate To RWS -> Predictive Analytics -> Forecast Model Setup Page On Web
    Navigate To Specific Page On Web    rws    predictive_analytics    forecast_model_setup

Click On Add Driver Model Button On Forecast Model Setup Page On Web
    [Documentation]    Click on the Add Driver Model button on the Forecast Model Setup page.
    Click Element On Webpage    ${FORECAST_MODEL_SETUP_ADD_DRIVER_MODEL_BTN}
    ...    error_message=Failed to click on Add Driver Model button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${FORECAST_MODEL_SETUP_ADD_DRIVER_MODEL_PAGE_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Driver Model Previous button was not visible after clicking Add Driver Model button
    Capture Screenshot On Webpage
