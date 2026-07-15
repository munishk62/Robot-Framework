*** Settings ***
Documentation       Verifies that the RTA > Payroll > Process Store Release page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/rta/payroll/process_store_release.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${SM_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:ravi    action:read    i18n    i18n_sm_rta


*** Variables ***
${SM_USER_KEY}      SM1_STORE1


*** Test Cases ***
BATTC9999: Verify I18n For Payroll Add Process Store Release Page
    [Documentation]    Verifies Add Process Store Release page loads for the globalized texts on the page.
    Navigate To RTA Payroll Process Store Release Page On Web
    Click On Process Store Release Button On Process Store Release Page On Web
    Start Visible Text Inventory
    ${visible_texts}    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
