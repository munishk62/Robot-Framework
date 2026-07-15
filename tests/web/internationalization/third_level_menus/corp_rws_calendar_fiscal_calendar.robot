*** Settings ***
Documentation       Verifies that the RWS Calendar > Fiscal Calendar page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/rws/calendar/fiscal_calendar.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${CORP_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:vrushabh    action:read    i18n    i18n_corp_rws


*** Variables ***
${CORP_USER_KEY}    SYSADMIN


*** Test Cases ***
BATTC9999: Verify I18n For Fiscal Calendar Page
    [Documentation]    Verifies that the RWS Calendar > Fiscal Calendar >
    ...    Add Fiscal Year page loads and displays globalized texts correctly.
    Navigate To RWS Fiscal Calendar Page On Web
    Open First Calendar Group Details On Fiscal Calendar Page On Web
    Start Visible Text Inventory
    Switch To Fiscal Calendar Tab On Calendar Group Details Page On Web
    Click On Add Fiscal Year Button On Fiscal Calendar Tab On Web
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
