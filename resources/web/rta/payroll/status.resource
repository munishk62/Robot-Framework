*** Settings ***
Documentation       Resource file for Payroll Status Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/payroll/status_page.py


*** Keywords ***
Navigate To RTA Payroll Status Page On Web
    [Documentation]    Navigates to the RTA -> Payroll -> Status page.
    Navigate To Specific Page On Web    rta    payroll    status

Click On First Payroll Status Record On Web
    [Documentation]    Clicks on the first payroll status record in the grid on Payroll Status page.
    ${element_count}    Get Element Count On Web Page    ${STATUS_PAGE_PAYROLL_GRID}
    IF    ${element_count} > 0
        Click Element On Webpage    (${STATUS_PAGE_PAYROLL_GRID})[1]
        ...    error_message="Failed to click on the first payroll status record in the grid on Payroll Status page."
        Wait Until Element Is Visible On Webpage    ${STATUS_PAGE_PREVIOUS_BUTTON}
        ...    error_message="Payroll status details did not open after clicking on a payroll status record."
        Capture Screenshot On Webpage
    ELSE
        Log    No payroll status records found in the grid on Payroll Status page.
        SKIP    No payroll status records to click on the grid on Payroll Status page.
    END
