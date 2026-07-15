*** Settings ***
Documentation       Resource file for HR Exception Correction Policy Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/exception_correction_policy_page.py


*** Keywords ***
Navigate To RTA HR Exception Correction Policy Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Exception Correction Policy page.
    Navigate To Specific Page On Web    rta    hr    exception_correction_policy

Click On Add Exception Correction Policy Button On Exception Correction Policy Page On Web
    [Documentation]    Clicks on Add Exception Correction Policy button on Exception Correction Policy page
    Click Element On Webpage    ${EXCEPTION_CORRECTION_POLICY_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Exception Correction Policy button on Exception Correction Policy page."
    Wait Until Element Is Visible On Webpage    ${EXCEPTION_CORRECTION_POLICY_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Exception Correction Policy form did not open after clicking Add Exception Correction Policy button."
    Capture Screenshot On Webpage
