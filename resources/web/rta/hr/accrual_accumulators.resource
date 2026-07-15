*** Settings ***
Documentation       Resource file for HR Accrual Accumulators Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/accrual_accumulators_page.py


*** Keywords ***
Navigate To RTA HR Accrual Accumulators Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Accrual Accumulators page.
    Navigate To Specific Page On Web    rta    hr    accrual_accumulators

Click On Add Accrual Accumulators Button On Accrual Accumulators Page On Web
    [Documentation]    Clicks on Add Accrual Accumulators button on Accrual Accumulators page
    Click Element On Webpage    ${ACCRUAL_ACCUMULATORS_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Accrual Accumulators button on Accrual Accumulators page."
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_ACCUMULATORS_PAGE_ADD_POPUP}
    ...    error_message="Add Accrual Accumulators form did not open after clicking Add Accrual Accumulators button."
    Capture Screenshot On Webpage
