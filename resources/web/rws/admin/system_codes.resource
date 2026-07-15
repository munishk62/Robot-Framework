*** Settings ***
Documentation       This resource file contains keywords related to the RWS > Admin > System Codes page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/admin/system_codes_page.py


*** Keywords ***
Navigate To RWS System Codes Page On Web
    [Documentation]    Navigate To RWS -> Admin -> System Codes Page On Web
    Navigate To Specific Page On Web    rws    admin    system_codes

Click On Add System Code Button In System Codes Page On Web
    [Documentation]    Click on Add System Code button in System Codes page on Web
    Click Element On Webpage    ${SYSTEM_CODES_ADD_CODE_SET_BTN}
    ...    error_message=Failed to click on Add System Code button
    Wait Until Element Is Visible On Webpage    ${SYSTEM_CODES_ADD_CODE_SET_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add System Code Save button was not visible after clicking Add System Code button
    Capture Screenshot On Webpage
