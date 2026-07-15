*** Settings ***
Documentation       Resource file for Day Definition Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/day_definition_page.py


*** Keywords ***
Navigate To RTA Configuration Day Definition Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Day Definition page.
    Navigate To Specific Page On Web    rta    configuration    day_definition

Click On Add Day Definition Button On Day Definition Page On Web
    [Documentation]    Clicks on Add Day Definition button on Day Definition page
    Click Element On Webpage    ${DAY_DEFINITION_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Day Definition button on Day Definition page."
    Wait Until Element Is Visible On Webpage    ${DAY_DEFINITION_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Day Definition form did not open after clicking Add Day Definition button."
    Capture Screenshot On Webpage
