*** Settings ***
Documentation       This resource file contains keywords related to the Employee > Associate Delegation page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/employee/associate_delegation_page.py


*** Keywords ***
Navigate To RWS Associate Delegation Page On Web
    [Documentation]    Navigate To RWS -> Employee -> Associate Delegation Page On Web
    Navigate To Specific Page On Web    rws    employee    associate_delegation

Click On Add Associate Delegation Button On Associate Delegation Page On Web
    [Documentation]    Click on the Add Associate Delegation button on the Associate Delegation page.
    Click Element On Webpage    ${ASSOCIATE_DELEGATION_ADD_ASSOCIATE_DELEGATION_BTN}
    ...    error_message=Failed to click on Add Associate Delegation button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ASSOCIATE_DELEGATION_ADD_ASSOCIATE_DELEGATION_BASIC_DETAILS_SECTION}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Associate Delegation Basic Details section was not visible after clicking Add Associate Delegation button
    Capture Screenshot On Webpage

Click On Next Button On Add Associate Delegation Details Tab Page On Web
    [Documentation]    Click on the Next button on the Add Associate Delegation Details Tab page
    Click Element On Webpage    ${ASSOCIATE_DELEGATION_ADD_ASSOCIATE_DELEGATION_NEXT_BTN}
    ...    error_message=Failed to click on Next button on Add Associate Delegation Details Tab page
    Wait Until Element Disappears On Webpage    ${ASSOCIATE_DELEGATION_ADD_ASSOCIATE_DELEGATION_BASIC_DETAILS_SECTION}
    Wait Until Element Is Visible On Webpage    ${ASSOCIATE_DELEGATION_ADD_ASSOCIATE_DELEGATION_DELEGATE_SECTION}    timeout=${LONG_TIMEOUT}
    ...    error_message=Delegate section was not visible after clicking Next button on Add Associate Delegation Details Tab page
    Capture Screenshot On Webpage
    Click Element On Webpage    ${ASSOCIATE_DELEGATION_ADD_ASSOCIATE_DELEGATION_NEXT_BTN}
    ...    error_message=Failed to click on Next button on Add Associate Delegation Delegate Tab page
    Wait Until Element Disappears On Webpage    ${ASSOCIATE_DELEGATION_ADD_ASSOCIATE_DELEGATION_DELEGATE_SECTION}
    Wait Until Element Is Visible On Webpage    ${ASSOCIATE_DELEGATION_ADD_ASSOCIATE_DELEGATION_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Associate Delegation Save button was not visible after clicking Next button on Add Associate Delegation Delegate Tab page
    Capture Screenshot On Webpage
