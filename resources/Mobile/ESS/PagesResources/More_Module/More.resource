*** Settings ***
Documentation       Resource file for More Page ESS app.

Resource            resources/Mobile/ESS/PagesResources/Common/Utility.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource


*** Keywords ***
Navigate To More Tab On Mobile ESS
    [Documentation]    Used for navigating to More tab on mobile ESS app.
    ${more_tab_title_locator}    Get Localised Locator Contains    ${MoreTabLabel}
    Wait Until Page Contains Element    ${more_tab_title_locator}
    Click Element    ${more_tab_title_locator}
    Log    Navigated to More tab on mobile ESS app.

Select Timecard From More Tab On Mobile ESS
    [Documentation]    Used for clicking on Timecard option on More tab on mobile ESS app.
    ${timecard_option_locator}    Get Localised Locator Contains    ${TimecardButtonLabel}
    Wait Until Element Is Visible    ${timecard_option_locator}
    Click Element    ${timecard_option_locator}
    Log    Clicked on Timecard option on More tab on mobile ESS app.
