*** Settings ***
Documentation       Verifies that the Store RWS Upcoming > Upcoming page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/rws/upcoming/upcoming.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${SM_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:vrushabh    action:read    i18n    i18n_sm_rws


*** Variables ***
${SM_USER_KEY}      SM1_STORE1


*** Test Cases ***
BATTC9999: Verify I18n For SM RWS Upcoming Upcoming Page
    [Documentation]    Verifies that the Store RWS Upcoming > Upcoming page loads and displays globalized texts correctly.
    Navigate To RWS Upcoming Page On Web
    Start Visible Text Inventory
    Click On All Visible Add Icons And Iterate Through Available Tabs On Upcoming Page On Web
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
