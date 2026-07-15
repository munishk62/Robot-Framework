*** Settings ***
Documentation       Verifies that the RWS Organization > Units page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/organization/units.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${CORP_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:vrushabh    action:read    i18n    i18n_corp_rws


*** Variables ***
${CORP_USER_KEY}    SYSADMIN


*** Test Cases ***
BATTC9999: Verify I18n For Organization Units Basic Details Page
    [Documentation]    Verifies that the RWS Organization > Units >
    ...    Basic Details page loads and displays globalized texts correctly.
    Navigate To RWS Organization Units Page On Web
    Click On First Store Name In Units Page On Web
    Click On Basic Details Of Store Details In Units Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Organization Units Departments Page
    [Documentation]    Verifies that the RWS Organization > Units >
    ...    Departments page loads and displays globalized texts correctly.
    Navigate To RWS Organization Units Page On Web
    Click On First Store Name In Units Page On Web
    Click On Departments Of Store Details In Units Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Organization Units Staff Groups Page
    [Documentation]    Verifies that the RWS Organization > Units >
    ...    Staff Groups page loads and displays globalized texts correctly.
    Navigate To RWS Organization Units Page On Web
    Click On First Store Name In Units Page On Web
    Click On Staff Groups Of Store Details In Units Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Organization Units Scheduled Events Page
    [Documentation]    Verifies that the RWS Organization > Units >
    ...    Scheduled Events page loads and displays globalized texts correctly.
    Navigate To RWS Organization Units Page On Web
    Click On First Store Name In Units Page On Web
    Click On Scheduled Events Of Store Details In Units Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
