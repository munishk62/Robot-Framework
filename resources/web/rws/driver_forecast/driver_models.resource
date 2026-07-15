*** Settings ***
Documentation       This resource file contains keywords related to the Driver Models page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/driver_forecast/driver_models_page.py


*** Keywords ***
Navigate To RWS Driver Models Page On Web
    [Documentation]    Navigate To RWS -> Driver Forecast -> Driver Models Page On Web
    Navigate To Specific Page On Web    rws    driver_forecast    driver_models

Click On Add Forecast Model Button In Driver Models Page On Web
    [Documentation]    Click On Add Forecast Model Button In Driver Models Page On Web
    ${is_add_button_present}    Is Element Present On Webpage    ${DRIVER_MODELS_ADD_FORECAST_MODEL_BUTTON}
    Skip If    not ${is_add_button_present}    Add Forecast Model button not present on Driver Models page, skipping click action
    Click Element On Webpage    ${DRIVER_MODELS_ADD_FORECAST_MODEL_BUTTON}
    ...    error_message=Failed to click on Add Forecast Model button in Driver Models page on web.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${DRIVER_MODELS_ADD_FORECAST_SAVE_BUTTON}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Forecast Model form did not open after clicking on Add Forecast Model button in Driver Models page on web.
    Capture Screenshot On Webpage
