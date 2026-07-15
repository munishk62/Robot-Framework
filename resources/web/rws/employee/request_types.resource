*** Settings ***
Documentation       This resource file contains keywords related to the Employee > Request Types page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/employee/request_types_page.py


*** Keywords ***
Navigate To RWS Request Types Page On Web
    [Documentation]    Navigate To RWS -> Employee -> Request Types Page On Web
    Navigate To Specific Page On Web    rws    employee    request_types

Click On Add Request Type Button On Request Types Page On Web
    [Documentation]    Click on the Add Request Type button on the Request Types page.
    Click Element On Webpage    ${REQ_TYPES_ADD_REQUEST_TYPE_BTN}
    ...    error_message=Failed to click on Add Request Type button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${REQ_TYPES_ADD_REQUEST_TYPE_ADD_NEW_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Request Type Add New button was not visible after clicking Add Request Type button
    Capture Screenshot On Webpage
