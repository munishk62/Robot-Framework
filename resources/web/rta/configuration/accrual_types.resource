*** Settings ***
Documentation       Resource file for Accrual Types Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/accrual_types_page.py


*** Keywords ***
Navigate To RTA Configuration Accrual Types Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Accrual Types page.
    Navigate To Specific Page On Web    rta    configuration    accrual_types

Click On Add Accrual Type Button On Accrual Types Page On Web
    [Documentation]    Clicks on Add Accrual Type button on Accrual Types page
    Click Element On Webpage    ${ACCRUAL_TYPES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Accrual Type button on Accrual Types page."
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_TYPES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Accrual Type form did not open after clicking Add Accrual Type button."
    Capture Screenshot On Webpage
