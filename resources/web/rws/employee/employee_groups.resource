*** Settings ***
Documentation       This resource file contains keywords related to the Employee > Employee Groups page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/employee/employee_groups_page.py


*** Keywords ***
Navigate To RWS Employee Groups Page On Web
    [Documentation]    Navigate To RWS -> Employee -> Employee Groups Page On Web
    Navigate To Specific Page On Web    rws    employee    employee_groups

Click On Add Employee Group Button On Employee Groups Page On Web
    [Documentation]    Click on the Add Employee Group button on the Employee Groups page.
    Click Element On Webpage    ${EMP_GROUPS_ADD_EMPLOYEE_GROUP_BTN}
    ...    error_message=Failed to click on Add Employee Group button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${EMP_GROUPS_ADD_EMPLOYEE_GROUP_PAGE_ADD_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Employee Group Save button was not visible after clicking Add Employee Group button
    Capture Screenshot On Webpage
