*** Settings ***
Documentation       Resource file for Earning Code Groups Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/earning_code_groups_page.py


*** Keywords ***
Navigate To RTA Configuration Earning Code Groups Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Earning Code Groups page.
    Navigate To Specific Page On Web    rta    configuration    earning_code_groups

Click On Add Earning Code Group Button On Earning Code Groups Page On Web
    [Documentation]    Clicks on Add Earning Code Group button on Earning Code Groups page
    Click Element On Webpage    ${EARNING_CODE_GROUPS_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Earning Code Group button on Earning Code Groups page."
    Wait Until Element Is Visible On Webpage    ${EARNING_CODE_GROUPS_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Earning Code Group form did not open after clicking Add Earning Code Group button."
    Capture Screenshot On Webpage
