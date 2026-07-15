*** Settings ***
Documentation       Resource file for Pay Types Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/pay_types_page.py


*** Keywords ***
Navigate To RTA Configuration Pay Types Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Pay Types page.
    Navigate To Specific Page On Web    rta    configuration    pay_types

Click On Add Pay Type Button On Pay Types Page On Web
    [Documentation]    Clicks on Add Pay Type button on Pay Types page
    Click Element On Webpage    ${PAY_TYPES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Pay Type button on Pay Types page."
    Wait Until Element Is Visible On Webpage    ${PAY_TYPES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Pay Type form did not open after clicking Add Pay Type button."
    Capture Screenshot On Webpage
