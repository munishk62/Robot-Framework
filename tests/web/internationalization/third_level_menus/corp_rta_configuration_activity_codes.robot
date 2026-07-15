*** Settings ***
Documentation       Verifies that the RTA > Configuration > Activity Codes > Add New Activity Code form loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/rta/configuration/activity_codes.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${CORP_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:ravi    action:read    i18n    i18n_corp_rta


*** Variables ***
${CORP_USER_KEY}    SYSADMIN


*** Test Cases ***
BATTC9999: Verify I18n For Configuration Add New Activity Codes Page
    [Documentation]    Verifies Configuration Add New Activity Codes page loads for the globalized texts on the page.
    Navigate To RTA Configuration Activity Codes Page On Web
    Click On Add Activity Code Button On Activity Codes Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
