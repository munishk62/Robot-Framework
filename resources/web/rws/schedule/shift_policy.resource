*** Settings ***
Documentation       This resource file contains keywords related to the RWS > Schedule > Shift Policy page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/shift_policy_page.py


*** Keywords ***
Navigate To RWS Shift Policy Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Shift Policy Page On Web
    Navigate To Specific Page On Web    rws    schedule    shift_policy

Click On Add Shift Policy Button In Shift Policy Page On Web
    [Documentation]    Click on Add Shift Policy button in Shift Policy page on Web
    Click Element On Webpage    ${SHIFT_POLICY_ADD_POLICY_BTN}
    ...    error_message=Failed to click on Add Shift Policy button
    Wait Until Element Is Visible On Webpage    ${SHIFT_POLICY_ADD_POLICY_NEXT_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Shift Policy Next button was not visible after clicking Add Shift Policy button
    Capture Screenshot On Webpage
