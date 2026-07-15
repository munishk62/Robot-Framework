*** Settings ***
Documentation       Resource file for Earning Codes Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/earning_codes_page.py


*** Keywords ***
Navigate To RTA Configuration Earning Codes Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Earning Codes page.
    Navigate To Specific Page On Web    rta    configuration    earning_codes

Click On Add Earning Code Button On Earning Codes Page On Web
    [Documentation]    Clicks on Add Earning Code button on Earning Codes page
    Click Element On Webpage    ${EARNING_CODES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Earning Code button on Earning Codes page."
    Wait Until Element Is Visible On Webpage    ${EARNING_CODES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Earning Code form did not open after clicking Add Earning Code button."
    Capture Screenshot On Webpage
