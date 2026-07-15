*** Settings ***
Documentation       Resource file for HR Time Rounding Policy Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/time_rounding_policy_page.py


*** Keywords ***
Navigate To RTA HR Time Rounding Policy Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Time Rounding Policy page.
    Navigate To Specific Page On Web    rta    hr    time_rounding_policy

Click On Add Time Rounding Policy Button On Time Rounding Policy Page On Web
    [Documentation]    Clicks on Add Time Rounding Policy button on Time Rounding Policy page
    Click Element On Webpage    ${TIME_ROUNDING_POLICY_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Time Rounding Policy button on Time Rounding Policy page."
    Wait Until Element Is Visible On Webpage    ${TIME_ROUNDING_POLICY_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Time Rounding Policy form did not open after clicking Add Time Rounding Policy button."
    Capture Screenshot On Webpage
