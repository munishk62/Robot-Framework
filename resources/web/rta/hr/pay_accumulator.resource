*** Settings ***
Documentation       Resource file for HR Pay Accumulator Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/pay_accumulator_page.py


*** Keywords ***
Navigate To RTA HR Pay Accumulator Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Pay Accumulator page.
    Navigate To Specific Page On Web    rta    hr    pay_accumulator

Click On Add Pay Accumulator Button On Pay Accumulator Page On Web
    [Documentation]    Clicks on Add Pay Accumulator button on Pay Accumulator page
    Click Element On Webpage    ${PAY_ACCUMULATOR_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Pay Accumulator button on Pay Accumulator page."
    Wait Until Element Is Visible On Webpage    ${PAY_ACCUMULATOR_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Pay Accumulator form did not open after clicking Add Pay Accumulator button."
    Capture Screenshot On Webpage
