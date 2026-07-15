*** Settings ***
Documentation       This resource contains keyword required for More tab related features.

Library             Process
Library             test_data/TestDataLibrary.py
Resource            resources/Mobile/SM/PagesResources/Associate_Roster/Associate_Roster.resource
Resource            resources/Mobile/SM/PagesResources/Common/Localised_Locator.resource
Variables           resources/Mobile/SM/Locators/SM_More.py


*** Keywords ***
Select More Tab On SM Phone App
    [Documentation]    Used to verify menu list on expanding More tab.
    TRY
        Wait Until Page Contains Element    ${MORE_BUTTON}
        Click Element    ${MORE_BUTTON}
    EXCEPT
        Log    Click not successful, try again    WARN
        Wait Until Page Contains Element    ${MORE_BUTTON}
        Click Element    ${MORE_BUTTON}
    END

Select Associate Roster From More Tab On SM Phone App
    [Documentation]    Used to click on associate roster from more tab.
    ${associate_roster_semantic}    Get Localised Locator Contains For SM    1000000000231
    Wait Until Page Contains Element    ${associate_roster_semantic}
    ...    error=Associate Roster option is not visible after clicking More icon
    Click Element    ${associate_roster_semantic}

Select Timecard From More Tab On SM Phone App
    [Documentation]    Used to click on timecard option from more tab.
    ${timecard_semantic}    Get Localised Locator Contains For SM    1000000000014
    Wait Until Page Contains Element    ${timecard_semantic}
    ...    error=Timecard option is not visible after clicking More icon
    Click Element    ${timecard_semantic}

Navigate To Associate Roster Module On SM Phone App
    [Documentation]    Used to navigate to associate roster module from more tab.
    Select More Tab On SM Phone App
    Select Associate Roster From More Tab On SM Phone App
    Verify Associate Roster Page Is Visible On SM Phone App
