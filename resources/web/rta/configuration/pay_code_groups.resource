*** Settings ***
Documentation       Resource file for Pay Code Groups Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/pay_code_groups_page.py


*** Keywords ***
Navigate To RTA Configuration Pay Code Groups Page On Web
    [Documentation]    Navigates to the RTA Configuration Pay Code Groups page.
    Navigate To Specific Page On Web    rta    configuration    pay_code_groups

Click On Add Pay Code Group Button On Pay Code Groups Page On Web
    [Documentation]    Clicks on Add Pay Code Group button on Pay Code Groups page
    Click Element On Webpage    ${PAY_CODE_GROUPS_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Pay Code Group button on Pay Code Groups page."
    Wait Until Element Is Visible On Webpage    ${PAY_CODE_GROUPS_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Pay Code Group form did not open after clicking Add Pay Code Group button."
    Capture Screenshot On Webpage
