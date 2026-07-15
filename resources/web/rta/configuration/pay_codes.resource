*** Settings ***
Documentation       Resource file for Pay Codes Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/pay_codes_page.py


*** Keywords ***
Navigate To RTA Configuration Pay Codes Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Pay Codes page.
    Navigate To Specific Page On Web    rta    configuration    pay_codes

Click On Add Pay Code Button On Pay Codes Page On Web
    [Documentation]    Clicks on Add Pay Code button on Pay Codes page
    Click Element On Webpage    ${PAY_CODES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Pay Code button on Pay Codes page."
    Wait Until Element Is Visible On Webpage    ${PAY_CODES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Pay Code form did not open after clicking Add Pay Code button."
    Capture Screenshot On Webpage
