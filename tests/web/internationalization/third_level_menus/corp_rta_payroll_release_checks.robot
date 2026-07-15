*** Settings ***
Documentation       Verifies that the RTA > Payroll > Release Checks page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/rta/payroll/release_checks.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${CORP_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:ravi    action:read    i18n    i18n_corp_rta


*** Variables ***
${CORP_USER_KEY}    SYSADMIN


*** Test Cases ***
BATTC9999: Verify I18n For Payroll Release Add Paychecks Page
    [Documentation]    Verifies Payroll Release Add Paychecks page loads for the globalized texts on the page.
    Navigate To RTA Payroll Release Checks Page On Web
    Click On Add Paycheck Set Button On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Payroll Release Add Policy Checks Page
    [Documentation]    Verifies Payroll Release Add Policy Checks page loads for the globalized texts on the page.
    Navigate To RTA Payroll Release Checks Page On Web
    Click On Add Policy Check Button On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
