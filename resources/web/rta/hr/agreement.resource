*** Settings ***
Documentation       Resource file for HR Agreement Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/agreement_page.py


*** Keywords ***
Navigate To RTA HR Agreement Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Agreement page.
    Navigate To Specific Page On Web    rta    hr    agreement

Click On Add Agreement Button On Agreement Page On Web
    [Documentation]    Clicks on Add Agreement button on Agreement page
    Click Element On Webpage    ${AGREEMENT_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Agreement button on Agreement page."
    Wait Until Element Is Visible On Webpage    ${AGREEMENT_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Agreement form did not open after clicking Add Agreement button."
    Capture Screenshot On Webpage
