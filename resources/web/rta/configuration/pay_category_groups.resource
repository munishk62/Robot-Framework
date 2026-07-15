*** Settings ***
Documentation       Resource file for Pay Category Groups Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/pay_category_groups_page.py


*** Keywords ***
Navigate To RTA Configuration Pay Category Groups Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Pay Category Groups page.
    Navigate To Specific Page On Web    rta    configuration    pay_category_groups

Click On Add Pay Category Group Button On Pay Category Groups Page On Web
    [Documentation]    Clicks on Add Pay Category Group button on Pay Category Groups page
    Click Element On Webpage    ${PAY_CATEGORY_GROUPS_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Pay Category Group button on Pay Category Groups page."
    Wait Until Element Is Visible On Webpage    ${PAY_CATEGORY_GROUPS_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Pay Category Group form did not open after clicking Add Pay Category Group button."
    Capture Screenshot On Webpage
