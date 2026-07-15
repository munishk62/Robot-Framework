*** Settings ***
Documentation       Resource file for Pay Categories Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/pay_categories_page.py


*** Keywords ***
Navigate To RTA Configuration Pay Categories Page On Web
    [Documentation]    Navigates to the RTA -> Configuration ->
    ...    Pay Categories page.
    Navigate To Specific Page On Web    rta    configuration    pay_categories

Click On Add Pay Category Button On Pay Categories Page On Web
    [Documentation]    Clicks on Add Pay Category button on Pay Categories page
    Click Element On Webpage    ${PAY_CATEGORIES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Pay Category button on Pay Categories page."
    Wait Until Element Is Visible On Webpage    ${PAY_CATEGORIES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Pay Category form did not open after clicking Add Pay Category button."
    Capture Screenshot On Webpage
