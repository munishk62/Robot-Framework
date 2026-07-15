*** Settings ***
Documentation       This resource file contains keywords related to the Predictive Analytics > Driver Setup page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/predictive_analytics/driver_setup_page.py


*** Keywords ***
Navigate To RWS Driver Setup Page On Web
    [Documentation]    Navigate To RWS -> Predictive Analytics -> Driver Setup Page On Web
    Navigate To Specific Page On Web    rws    predictive_analytics    driver_setup

Click On Add Driver Button On Driver Setup Page On Web
    [Documentation]    Click on the Add Driver button on the Driver Setup page.
    Click Element On Webpage    ${DRIVER_SETUP_ADD_DRIVER_BTN}
    ...    error_message=Failed to click on Add Driver button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${DRIVER_SETUP_ADD_DRIVER_PAGE_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Driver Previous button was not visible after clicking Add Driver button
    Capture Screenshot On Webpage
