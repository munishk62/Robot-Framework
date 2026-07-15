*** Settings ***
Documentation       This resource file contains keywords related to the Labor Forecast > Calculation Methods page of RWS on Web.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/labor_forecast/calculation_methods_page.py


*** Keywords ***
Navigate To RWS Calculation Methods Page On Web
    [Documentation]    Navigates to the RWS Labor Forecast > Calculation Methods page.
    Navigate To Specific Page On Web    rws    labor_forecast    calculation_methods

Click On Add Calculation Method Button In Calculation Methods Page On Web
    [Documentation]    Clicks on the "Add Calculation Method" button
    Click Element On Webpage    ${CALC_METHODS_ADD_BTN}
    ...    error_message=Failed to click on "Add Calculation Method" button in Calculation Methods page.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${CALC_METHODS_ADD_CALC_METHOD_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Failed to load "Add Calculation Method" page
    Capture Screenshot On Webpage
