*** Settings ***
Documentation       Verifies that the RWS Schedule > Store Employee Group page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/rws/schedule/store_employee_group.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${CORP_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:vrushabh    action:read    i18n    i18n_corp_rws


*** Variables ***
${CORP_USER_KEY}    SYSADMIN


*** Test Cases ***
BATTC9999: Verify I18n For Store Employee Group Employee Group Types Page
    [Documentation]    Verifies that the RWS Schedule > Store Employee Group >
    ...    Employee Group Types page loads and displays globalized texts correctly.
    Navigate To RWS Store Employee Group Page On Web
    Click On Employee Group Types Link In Store Employee Group Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Store Employee Group Employee Groups Page
    [Documentation]    Verifies that the RWS Schedule > Store Employee Group >
    ...    Employee Groups page loads and displays globalized texts correctly.
    Navigate To RWS Store Employee Group Page On Web
    Click On Employee Groups Link In Store Employee Group Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}

BATTC9999: Verify I18n For Store Employee Group Store Employee Groups Page
    [Documentation]    Verifies that the RWS Schedule > Store Employee Group >
    ...    Store Employee Groups page loads and displays globalized texts correctly.
    Navigate To RWS Store Employee Group Page On Web
    Click On Store Employee Groups Link In Store Employee Group Page On Web
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
