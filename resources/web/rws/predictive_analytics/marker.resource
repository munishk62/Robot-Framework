*** Settings ***
Documentation       This resource file contains keywords related to the Predictive Analytics > Marker page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/predictive_analytics/marker_page.py


*** Keywords ***
Navigate To RWS Marker Page On Web
    [Documentation]    Navigate To RWS -> Predictive Analytics -> Marker Page On Web
    Navigate To Specific Page On Web    rws    predictive_analytics    marker

Click On Add Marker Button On Marker Page On Web
    [Documentation]    Click on the Add Marker button on the Marker page.
    Click Element On Webpage    ${MARKER_ADD_MARKER_BTN}
    ...    error_message=Failed to click on Add Marker button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${MARKER_ADD_MARKER_PAGE_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Marker Previous button was not visible after clicking Add Marker button
    Capture Screenshot On Webpage
