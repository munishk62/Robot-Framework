*** Settings ***
Documentation       This resource file contains keywords related to the Predictive Analytics > Seasonality Index page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/predictive_analytics/seasonality_index_page.py


*** Keywords ***
Navigate To RWS Seasonality Index Page On Web
    [Documentation]    Navigate To RWS -> Predictive Analytics -> Seasonality Index Page On Web
    Navigate To Specific Page On Web    rws    predictive_analytics    seasonality_index

Click On Initialize Mode Button On Seasonality Index Page On Web
    [Documentation]    Click on the Initialize Mode button on the Seasonality Index page.
    Click Element On Webpage    ${SEASONALITY_INDEX_INITIALIZE_MODE_BTN}
    ...    error_message=Failed to click on Initialize Mode button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${SEASONALITY_INDEX_INITIALIZE_MODE_INIT_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Initialize Mode Init button was not visible after clicking Initialize Mode button
    Capture Screenshot On Webpage
