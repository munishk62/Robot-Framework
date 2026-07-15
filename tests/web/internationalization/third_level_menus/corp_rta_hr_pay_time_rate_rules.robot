*** Settings ***
Documentation       Verifies that the RTA > HR > Pay Time Rate Rules page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/rta/hr/pay_time_rate_rules.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${CORP_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:ravi    action:read    i18n    i18n_corp_rta


*** Variables ***
${CORP_USER_KEY}    SYSADMIN


*** Test Cases ***
BATTC9999: Verify I18n For HR Add Pay Time Rate Rules Page
    [Documentation]    Verifies HR Add Pay Time Rate Rules page loads for the globalized texts on the page.
    Navigate To RTA HR Pay Time Rate Rules Page On Web
    Click On Add Pay Time Rate Rules Button On Pay Time Rate Rules Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
