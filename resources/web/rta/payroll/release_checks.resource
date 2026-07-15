*** Settings ***
Documentation       Resource file for Payroll Release Checks Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/payroll/release_checks_page.py


*** Keywords ***
Navigate To RTA Payroll Release Checks Page On Web
    [Documentation]    Navigates to the RTA -> Payroll -> Release Checks page.
    Navigate To Specific Page On Web    rta    payroll    release_checks

Click On Add Paycheck Set Button On Web
    [Documentation]    Clicks on the "Add Paycheck Set" button on the Release Checks page.
    Click Element On Webpage    ${RELEASE_CHECKS_PAGE_ADD_PAYCHECK_BUTTON}
    ...    error_message="Failed to click on the 'Add Paycheck Set' button on the Release Checks page."
    Wait Until Element Is Visible On Webpage    ${RELEASE_CHECKS_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Payroll release check details did not open after clicking on the 'Add Paycheck Set' button."
    Capture Screenshot On Webpage

Click On Add Policy Check Button On Web
    [Documentation]    Clicks on the "Add Policy Check" button on the Release Checks page.
    Click Element On Webpage    ${RELEASE_CHECKS_PAGE_ADD_POLICYCHECK_BUTTON}
    ...    error_message="Failed to click on the 'Add Policy Check' button on the Release Checks page."
    Wait Until Element Is Visible On Webpage    ${RELEASE_CHECKS_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Policy check details did not open after clicking on the 'Add Policy Check' button."
    Capture Screenshot On Webpage
