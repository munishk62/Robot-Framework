*** Settings ***
Documentation       This resource file contains keywords related to the RWS > Schedule > Shift Template page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/shift_template_page.py


*** Keywords ***
Navigate To RWS Shift Template Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Shift Template Page On Web
    Navigate To Specific Page On Web    rws    schedule    shift_template

Click On Add Shift Template Button In Shift Template Page On Web
    [Documentation]    Click on Add Shift Template button in Shift Template page on Web
    Click Element On Webpage    ${SHIFT_TEMPLATE_ADD_TEMPLATE_BTN}
    ...    error_message=Failed to click on Add Shift Template button
    Wait Until Element Is Visible On Webpage    ${SHIFT_TEMPLATE_ADD_TEMPLATE_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Shift Template Save button was not visible after clicking Add Shift Template button
    Capture Screenshot On Webpage
