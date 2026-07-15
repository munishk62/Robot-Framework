*** Settings ***
Documentation       This resource file contains keywords related to the Employee > Reporting Hierarchy page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/employee/reporting_hierarchy_page.py


*** Keywords ***
Navigate To RWS Reporting Hierarchy Page On Web
    [Documentation]    Navigate To RWS -> Employee -> Reporting Hierarchy Page On Web
    Navigate To Specific Page On Web    rws    employee    reporting_hierarchy

Click On Add Reporting Hierarchy Button On Reporting Hierarchy Page On Web
    [Documentation]    Click on the Add Reporting Hierarchy button on the Reporting Hierarchy page.
    Click Element On Webpage    ${REPORTING_HIERARCHY_ADD_REPORTING_HIERARCHY_BTN}
    ...    error_message=Failed to click on Add Reporting Hierarchy button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${REPORTING_HIERARCHY_ADD_REPORTING_HIERARCHY_NEXT_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Reporting Hierarchy Next button was not visible after clicking Add Reporting Hierarchy button
    Capture Screenshot On Webpage

Click On Next Button On Add Reporting Hierarchy Details Tab Page On Web
    [Documentation]    Click on the Next button on the Add Reporting Hierarchy Details Tab page
    Click Element On Webpage    ${REPORTING_HIERARCHY_ADD_REPORTING_HIERARCHY_NEXT_BTN}
    ...    error_message=Failed to click on Next button on Add Reporting Hierarchy Details Tab page
    Wait Until Element Is Visible On Webpage    ${REPORTING_HIERARCHY_ADD_REPORTING_HIERARCHY_SAVE_BTN}
    ...    error_message=Add Reporting Hierarchy Save button was not visible after clicking Add Reporting Hierarchy button
    Capture Screenshot On Webpage
