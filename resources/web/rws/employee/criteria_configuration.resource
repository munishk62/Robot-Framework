*** Settings ***
Documentation       This resource file contains keywords related to the Employee > Criteria Configuration page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/employee/criteria_configuration_page.py


*** Keywords ***
Navigate To RWS Criteria Configuration Page On Web
    [Documentation]    Navigate To RWS -> Employee -> Criteria Configuration Page On Web
    Navigate To Specific Page On Web    rws    employee    criteria_configuration

Click On Add Criteria Configuration Button On Criteria Configuration Page On Web
    [Documentation]    Click on the Add Criteria Configuration button on the Criteria Configuration page.
    Click Element On Webpage    ${CRITERIA_CONFIG_ADD_CRITERIA_BTN}
    ...    error_message=Failed to click on Add Criteria Configuration button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${CRITERIA_CONFIG_ADD_CRITERIA_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Criteria Configuration Previous button was not visible after clicking Add Criteria Configuration button
    Capture Screenshot On Webpage
