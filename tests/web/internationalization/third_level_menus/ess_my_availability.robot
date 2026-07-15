*** Settings ***
Documentation       I18n validation suite for ESS My Availability page.
...                 Verifies visible-text internationalization coverage for the ESS My Availability page.
...                 Suite configures locale and bundles directory via ``Configure I18n Suite Locale From Contract`` and ``Configure I18n Bundles Dir From Contract``.

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/my_availability.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${ESS_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:ravi    action:read    i18n    i18n_ess


*** Variables ***
${ESS_USER_KEY}     ESS2_STORE1


*** Test Cases ***
ESS > My Availability: Verify I18n For Ess Add Availability Page
    [Documentation]    Verifies I18n for ESS My Availability page.
    Navigate To ESS My Availability Page
    Click On Add Availability Icon On My Availability Page On Web
    Start Visible Text Inventory
    ${visible_text}    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_text}
    Verify I18n For Visible Page Text    ${visible_text}
