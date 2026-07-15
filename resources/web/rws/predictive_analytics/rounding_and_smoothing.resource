*** Settings ***
Documentation       This resource file contains keywords related to the Predictive Analytics > Rounding and Smoothing page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/predictive_analytics/rounding_and_smoothing_page.py


*** Keywords ***
Navigate To RWS Rounding And Smoothing Page On Web
    [Documentation]    Navigate To RWS -> Predictive Analytics -> Rounding and Smoothing Page On Web
    Navigate To Specific Page On Web    rws    predictive_analytics    rounding_and_smoothing

Click On Add RAS Model Button On Rounding And Smoothing Page On Web
    [Documentation]    Click on the Add RAS Model button on the Rounding and Smoothing page.
    Click Element On Webpage    ${RAS_PAGE_ADD_RAS_MODEL_BTN}
    ...    error_message=Failed to click on Add RAS Model button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${RAS_PAGE_ADD_RAS_MODEL_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add RAS Model Previous button was not visible after clicking Add RAS Model button
    Capture Screenshot On Webpage
