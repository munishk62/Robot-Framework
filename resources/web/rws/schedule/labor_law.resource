*** Settings ***
Documentation       This resource file contains keywords related to the RWS > Schedule > Labor Law page on Web.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/labor_law_page.py


*** Keywords ***
Navigate To RWS Labor Law Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Labor Law Page On Web
    Navigate To Specific Page On Web    rws    schedule    labor_law

Click On Add Labor Law Button In Labor Law Page On Web
    [Documentation]    Click on Add Labor Law button in Labor Law page on Web
    Click Element On Webpage    ${LABOR_LAW_ADD_LABOR_LAW_BTN}
    ...    error_message=Failed to click on Add Labor Law button
    Wait Until Element Is Visible On Webpage    ${LABOR_LAW_ADD_LABOR_LAW_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Labor Law Save button was not visible after clicking Add Labor Law button
    Capture Screenshot On Webpage

Click On Basic Details Tab In Add Labor Law Page On Web
    [Documentation]    Click on Basic Details tab in Add Labor Law page on Web
    Click Element On Webpage    ${LABOR_LAW_ADD_LABOR_LAW_BASIC_DETAILS_TAB}
    ...    error_message=Failed to click on Basic Details tab in Add Labor Law page
    Wait Until Element Is Visible On Webpage    ${LABOR_LAW_ADD_LABOR_LAW_BASIC_DETAILS_ACTIVE}    timeout=${LONG_TIMEOUT}
    ...    error_message=Basic Details tab was not visible after clicking
    Capture Screenshot On Webpage

Click On Meal Break Tab In Add Labor Law Page On Web
    [Documentation]    Click on Meal Break tab in Add Labor Law page on Web
    Click Element On Webpage    ${LABOR_LAW_ADD_LABOR_LAW_MEAL_BREAK_TAB}
    ...    error_message=Failed to click on Meal Break tab in Add Labor Law page
    Wait Until Element Is Visible On Webpage    ${LABOR_LAW_ADD_LABOR_LAW_MEAL_BREAK_ACTIVE}    timeout=${LONG_TIMEOUT}
    ...    error_message=Meal Break tab was not visible after clicking
    Capture Screenshot On Webpage
