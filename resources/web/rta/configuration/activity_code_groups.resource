*** Settings ***
Documentation       Resource file for Activity Code Groups Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/activity_code_groups_page.py


*** Keywords ***
Navigate To RTA Configuration Activity Code Groups Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Activity Code Groups page.
    Navigate To Specific Page On Web    rta    configuration    activity_code_groups

Click On Add Activity Code Group Button On Activity Code Groups Page On Web
    [Documentation]    Clicks on Add Activity Code Group button on Activity Code Groups page
    Click Element On Webpage    ${ACTIVITY_CODE_GROUPS_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Activity Code Group button on Activity Code Groups page."
    Wait Until Element Is Visible On Webpage    ${ACTIVITY_CODE_GROUPS_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Activity Code Group form did not open after clicking Add Activity Code Group button."
    Capture Screenshot On Webpage
