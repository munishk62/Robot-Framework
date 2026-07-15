*** Settings ***
Documentation       Resource file for HR Pay Time Rate Rules Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/pay_time_rate_rules_page.py


*** Keywords ***
Navigate To RTA HR Pay Time Rate Rules Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Pay Time Rate Rules page.
    Navigate To Specific Page On Web    rta    hr    pay_time_rate_rules

Click On Add Pay Time Rate Rules Button On Pay Time Rate Rules Page On Web
    [Documentation]    Clicks on Add Pay Time Rate Rules button on Pay Time Rate Rules page
    Click Element On Webpage    ${PAY_TIME_RATE_RULES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Pay Time Rate Rules button on Pay Time Rate Rules page."
    Wait Until Element Is Visible On Webpage    ${PAY_TIME_RATE_RULES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Pay Time Rate Rules form did not open after clicking Add Pay Time Rate Rules button."
    Capture Screenshot On Webpage
