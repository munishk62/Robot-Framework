*** Settings ***
Documentation       Resource file for Activity Codes Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/activity_codes_page.py


*** Keywords ***
Navigate To RTA Configuration Activity Codes Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Activity Codes page.
    Navigate To Specific Page On Web    rta    configuration    activity_codes

Click On Add Activity Code Button On Activity Codes Page On Web
    [Documentation]    Clicks on Add Activity Code button on Activity Codes page
    Click Element On Webpage    ${ACTIVITY_CODES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Activity Code button on Activity Codes page."
    Wait Until Element Is Visible On Webpage    ${ACTIVITY_CODES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Activity Code form did not open after clicking Add Activity Code button."
    Capture Screenshot On Webpage
