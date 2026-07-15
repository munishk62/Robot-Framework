*** Settings ***
Documentation       Resource file for HR Accrual Policy Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/accrual_policy_page.py


*** Keywords ***
Navigate To RTA HR Accrual Policy Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Accrual Policy page.
    Navigate To Specific Page On Web    rta    hr    accrual_policy

Click On Add Accrual Policy Button On Accrual Policy Page On Web
    [Documentation]    Clicks on Add Accrual Policy button on Accrual Policy page
    Click Element On Webpage    ${ACCRUAL_POLICY_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Accrual Policy button on Accrual Policy page."
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_POLICY_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Accrual Policy form did not open after clicking Add Accrual Policy button."
    Capture Screenshot On Webpage
