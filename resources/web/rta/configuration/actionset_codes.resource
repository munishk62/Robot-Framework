*** Settings ***
Documentation       Resource file for Actionset Codes Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/actionset_codes_page.py


*** Keywords ***
Navigate To RTA Configuration Actionset Codes Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Actionset Codes page.
    Navigate To Specific Page On Web    rta    configuration    actionset_codes

Click On Add Actionset Code Button On Actionset Codes Page On Web
    [Documentation]    Clicks on Add Actionset Code button on Actionset Codes page
    Click Element On Webpage    ${ACTIONSET_CODES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Actionset Code button on Actionset Codes page."
    Wait Until Element Is Visible On Webpage    ${ACTIONSET_CODES_PAGE_SAVE_BUTTON}
    ...    error_message="Add Actionset Code form did not open after clicking Add Actionset Code button."
    Capture Screenshot On Webpage
