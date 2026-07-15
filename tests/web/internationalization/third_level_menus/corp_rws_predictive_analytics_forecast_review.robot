*** Settings ***
Documentation       Verifies that the RWS Predictive Analytics > Forecast Review page loads and displays globalized texts correctly.

Resource            resources/web/authentication/login.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Resource            resources/web/internationalization/common_keywords.resource
Resource            resources/web/rws/predictive_analytics/forecast_review.resource

Suite Setup         Configure I18n Context For Test Suite
Suite Teardown      Close Browser
Test Setup          Login And Launch WFM Web App    user_key=${CORP_USER_KEY}    locale=${I18N_LOCALE}
Test Teardown       Close Browser

Test Tags           dev:vrushabh    action:read    i18n    i18n_corp_rws


*** Variables ***
${CORP_USER_KEY}    SYSADMIN


*** Test Cases ***
BATTC9999: Verify I18n For Forecast Review Markers And Add Marker Page
    [Documentation]    Verifies that the RWS Predictive Analytics > Forecast Review page loads and displays globalized texts correctly.
    Navigate To Forecast Review Page On Web
    Expand Markers Tab On Forecast Review Page On Web
    Start Visible Text Inventory
    Expand Add Marker Tab On Forecast Review Page On Web
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    Verify I18n For Visible Page Text    ${visible_texts}
