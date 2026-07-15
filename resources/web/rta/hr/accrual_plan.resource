*** Settings ***
Documentation       Resource file for HR Accrual Plan Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/accrual_plan_page.py


*** Keywords ***
Navigate To RTA HR Accrual Plan Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Accrual Plan page.
    Navigate To Specific Page On Web    rta    hr    accrual_plan

Click On Add Accrual Plan Button On Accrual Plan Page On Web
    [Documentation]    Clicks on Add Accrual Plan button on Accrual Plan page
    Click Element On Webpage    ${ACCRUAL_PLAN_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Accrual Plan button on Accrual Plan page."
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PLAN_PAGE_LIST_BUTTON}
    ...    error_message="Add Accrual Plan form did not open after clicking Add Accrual Plan button."
    Capture Screenshot On Webpage
