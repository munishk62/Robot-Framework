*** Settings ***
Documentation       Clock Supervisors page related keyword implementation for RTA Operations

# Library    resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/rta/operations/clock_supervisors_page.py


*** Keywords ***
Navigate To RTA Operations Clock Supervisors Page On Web
    [Documentation]
    ...    Navigates to RTA -> Operations -> Clock Supervisors page
    ...    Example usage:
    ...    | Navigate To RTA Operations Clock Supervisors Page On Web
    Navigate To Specific Page On Web    rta    operations    clock_supervisors
    Wait Until Page Is Loaded

Click On Add Supervisor Button On Clock Supervisors Page On Web
    [Documentation]
    ...    Clicks on the "Add Supervisor" button to open the add form.
    ...    Example usage:
    ...    | Click On Add Supervisor Button On Clock Supervisors Page On Web
    Click Element On Webpage    ${CLOCK_SUPERVISORS_PAGE_ADD_SUPERVISOR_BUTTON}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${CLOCK_SUPERVISORS_PAGE_PREVIOUS_BUTTON}
    Capture Screenshot On Webpage
