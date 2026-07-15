*** Settings ***
Documentation       This resource file contains keywords related to the Employee > School Calendar page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/employee/school_calendar_page.py


*** Keywords ***
Navigate To RWS School Calendar Page On Web
    [Documentation]    Navigate To RWS -> Employee -> School Calendar Page On Web
    Navigate To Specific Page On Web    rws    employee    school_calendar

Click On Add School Calendar Button On School Calendar Page On Web
    [Documentation]    Click on the Add School Calendar button on the School Calendar page.
    Click Element On Webpage    ${SCHOOL_CAL_ADD_SCHOOL_CALENDAR_BTN}
    ...    error_message=Failed to click on Add School Calendar button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${SCHOOL_CAL_ADD_SCHOOL_CALENDAR_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add School Calendar Save button was not visible after clicking Add School Calendar button
    Capture Screenshot On Webpage
