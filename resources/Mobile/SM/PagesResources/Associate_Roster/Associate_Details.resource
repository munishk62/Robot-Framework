*** Settings ***
Documentation       This resource contains keywords required for Associate Details Page.

Library             Process
Resource            resources/Mobile/SM/PagesResources/Common/Common.resource
Resource            resources/Mobile/Common/MobileKeyboardUtils.resource
Variables           resources/Mobile/SM/Locators/Associate_Details.py


*** Keywords ***
Search And Select Associate Name On Associate Details Page On SM Phone App
    [Documentation]    Used to search associate name on associate details page.
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Name of the associate to be searched |
    [Arguments]    ${associate_name}
    Wait Until Page Contains Element    ${ASSOCIATE_DETAILS_NAME_LABEL}    error=Associate details page not opened successfully
    Click Element    ${ASSOCIATE_DETAILS_NAME_LABEL}
    Wait Until Page Contains Element    ${ASSOCIATE_DETAILS_SEARCH_ICON}
    ...    error=Search textbox is not visible after clicking search icon on associate details page
    Input Text    ${ASSOCIATE_DETAILS_SEARCH_ICON}    ${associate_name}
    ${formatted_searched_associate}    Get Message With Arguments For SM    ${SEARCHED_DETAILS_SEARCHED_ASSOCIATE}    ${associate_name}
    Wait Until Page Contains Element    ${formatted_searched_associate}
    ...    error=Associate with name ${associate_name} is not visible after searching on associate details page
    Click Element    ${formatted_searched_associate}
