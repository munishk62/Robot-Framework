*** Settings ***
Documentation       This resource file contains keywords related to the Predictive Analytics > Forecast Driver Analysis page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/predictive_analytics/forecast_driver_analysis_page.py


*** Keywords ***
Navigate To RWS Forecast Driver Analysis Page On Web
    [Documentation]    Navigate To RWS -> Predictive Analytics -> Forecast Driver Analysis Page On Web
    Navigate To Specific Page On Web    rws    predictive_analytics    forecast_driver_analysis

Expand Forecast Driver Analysis Markers Tab On Web
    [Documentation]    Expand the Markers tab on the Forecast Driver Analysis page.
    Click Element On Webpage    ${FORECAST_DRIVER_ANALYSIS_MARKERS_TAB}
    ...    error_message=Failed to click on Markers tab on Forecast Driver Analysis page
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${FORECAST_DRIVER_ANALYSIS_MARKERS_TAB_ACTIVE}    timeout=${LONG_TIMEOUT}
    ...    error_message=Markers tab was not active after clicking on it
    Capture Screenshot On Webpage

Expand Forecast Driver Analysis Statistics Tab On Web
    [Documentation]    Expand the Statistics tab on the Forecast Driver Analysis page.
    Click Element On Webpage    ${FORECAST_DRIVER_ANALYSIS_STATISTICS_TAB}
    ...    error_message=Failed to click on Statistics tab on Forecast Driver Analysis page
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${FORECAST_DRIVER_ANALYSIS_STATISTICS_TAB_ACTIVE}    timeout=${LONG_TIMEOUT}
    ...    error_message=Statistics tab was not active after clicking on it
    Capture Screenshot On Webpage
