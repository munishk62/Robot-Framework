*** Settings ***
Documentation       Verifies that the PSA > State Machine Configuration page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/psa/state_machine_configuration/state_machine_configuration.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${CORP_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:vrushabh    action:read    i18n    i18n_corp_psa


*** Variables ***
${CORP_USER_KEY}    SYSADMIN


*** Test Cases ***
BATTC9999: Verify I18n For PSA State Machine Configuration Page
    [Documentation]    Verifies that the PSA > State Machine Configuration page loads and displays globalized texts correctly.
    Navigate To PSA State Machine Configuration Page On Web
    Click On System Configuration Tab On State Machine Configuration Page On Web
    Start Visible Text Inventory
    Click On Unit Configuration Tab On State Machine Configuration Page On Web
    Click On Configure State Machine Tab On State Machine Configuration Page On Web
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
