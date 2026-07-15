*** Settings ***
Documentation       Resource file for Action Codes Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/action_codes_page.py


*** Keywords ***
Navigate To RTA Configuration Action Codes Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Action Codes page.
    Navigate To Specific Page On Web    rta    configuration    action_codes

Click On Add Action Code Button On Action Codes Page On Web
    [Documentation]    Clicks on Add Action Code button on Action Codes page
    Click Element On Webpage    ${ACTION_CODES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Action Code button on Action Codes page."
    Wait Until Element Is Visible On Webpage    ${ACTION_CODES_PAGE_SAVE_BUTTON}
    ...    error_message="Add Action Code form did not open after clicking Add Action Code button."
    Capture Screenshot On Webpage
