*** Settings ***
Documentation       Verifies that the RWS Organization > Organization Structure page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/organization/organization_structure.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${CORP_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:vrushabh    action:read    i18n    i18n_corp_rws


*** Variables ***
${CORP_USER_KEY}    SYSADMIN


*** Test Cases ***
BATTC9999: Verify I18n For Organization Structure Organization Levels Page
    [Documentation]    Verifies that the RWS Organization > Organization Structure >
    ...    Organization Levels page loads and displays globalized texts correctly.
    Navigate To RWS Organization Structure Page On Web
    Click On Organization Levels Link On Organization Structure Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Organization Structure Organization Attributes Page
    [Documentation]    Verifies that the RWS Organization > Organization Structure >
    ...    Organization Attributes page loads and displays globalized texts correctly.
    Navigate To RWS Organization Structure Page On Web
    Click On Organization Attributes Link On Organization Structure Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Run Keyword And Continue On Failure
    ...    Verify I18n For Visible Page Text    ${visible_texts}
    Click On All Attribute Name Link On Organization Attributes Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Run Keyword And Continue On Failure
    ...    Verify I18n For Visible Page Text    ${visible_texts}
    Click On Add Attribute Button On Organization Attributes Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Organization Structure Departments Page
    [Documentation]    Verifies that the RWS Organization > Organization Structure >
    ...    Departments page loads and displays globalized texts correctly.
    Navigate To RWS Organization Structure Page On Web
    Click On Departments Link And Expand Store On Organization Structure Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Run Keyword And Continue On Failure
    ...    Verify I18n For Visible Page Text    ${visible_texts}
    Click On Add Store Department Button On Organization Structure Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Organization Structure Scheduled Events Page
    [Documentation]    Verifies that the RWS Organization > Organization Structure >
    ...    Scheduled Events page loads and displays globalized texts correctly.
    Navigate To RWS Organization Structure Page On Web
    Click On Scheduled Events Link On Organization Structure Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Run Keyword And Continue On Failure
    ...    Verify I18n For Visible Page Text    ${visible_texts}
    Click On Add Scheduled Event Group Button On Scheduled Events Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Organization Structure Staff Groups Page
    [Documentation]    Verifies that the RWS Organization > Organization Structure >
    ...    Staff Groups page loads and displays globalized texts correctly.
    Navigate To RWS Organization Structure Page On Web
    Click On Staff Groups Link On Organization Structure Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Run Keyword And Continue On Failure
    ...    Verify I18n For Visible Page Text    ${visible_texts}
    Click On Add Staff Group Button On Staff Groups Page On Web
    Start Visible Text Inventory
    Click On Hours Allocation By Store Tab On Staff Group Details Page On Web
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
