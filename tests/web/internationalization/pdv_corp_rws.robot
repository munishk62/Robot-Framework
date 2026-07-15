*** Settings ***
Documentation       Unified PDV menu DataDriver with internationalization (i18n) checks after each row.
...                 Set suite variables ``${PDV_DATADRIVER_MENU_USER_KEY}``, ``${PDV_DATADRIVER_MENU_MODULE}``; locale from ``Configure I18n Suite Locale From Contract`` (env ``I18N_LOCALE``, ``-v I18N_LOCALE``, resource default);
...                 bundle root from env override ``BUNDLES_DIR`` / ``WFM_RESOURCE_BUNDLES_DIR`` or auto-discovery under ``test_data/environments/<TEST_ENVIRONMENT>/i18n_data/resource_bundles`` via ``Configure I18n Bundles Dir From Contract``.
...                 Optional ``test_data/i18n/shared_i18n_contract.yaml`` only augments menu paths / DB2 sources.
...                 DataDriver ``config_keyword`` and template keyword must live in *this* file so DataDriver can read argument names.
...                 Shared i18n caches: parent ``__init__.robot`` runs ``Run Only Once Save``; this suite uses ``Import I18n Internationalization Directory Caches Into Library``; see ``resources/web/internationalization/i18n_pabot_shared.resource``.

Resource            resources/web/pdv/pdv_menu_datadriver_dispatch.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Library             resources/common/library/WebInternationalizationLibrary.py
Library             DataDriver    dialect=excel    encoding=utf_8
...                     config_keyword=Generate PDV Child Menu CSV For Environment And Return Config

Suite Setup         Login For I18n PDV Menu Datadriven Suite
Suite Teardown      Remove PDV Datadriven Child Menu Csv For Suite

Test Tags           dev:kapil    action:read    i18n    i18n_corp_rws
# python executor.py tests\web\internationalization\sysadmin.robot --testlevelsplit --processes 8 --results-dir results\i18_sysadmin_whitelist --test-env QA29_B0


*** Variables ***
${PDV_DATADRIVER_MENU_USER_KEY}     SYSADMIN
${PDV_DATADRIVER_MENU_MODULE}       rws


*** Test Cases ***
BATTC009999: Verify I18n For RWS Child Menu Page (${PDV_DATADRIVER_MENU_USER_KEY}) - ${page_name}
    [Documentation]    Verifies each discovered RWS child menu page loads for the active MyWork or non-MyWork mode.
    [Template]    Verify I18n For RWS Child Menu Page


*** Keywords ***
Generate PDV Child Menu CSV For Environment And Return Config
    [Documentation]
    ...    DataDriver ``config_keyword``: forwards suite user, module, and locale into ``Generate PDV Child Menu CSV For Environment With Params And Return Config``.
    [Arguments]    ${original_config}
    Configure I18n Suite Locale From Contract    ${I18N_LOCALE_SUITE_FALLBACK}
    Configure I18n Bundles Dir From Contract
    ${new_config}=    Generate PDV Child Menu CSV For Environment With Params And Return Config
    ...    ${original_config}
    ...    ${PDV_DATADRIVER_MENU_USER_KEY}
    ...    ${PDV_DATADRIVER_MENU_MODULE}
    ...    ${I18N_LOCALE}
    RETURN    ${new_config}

Login For I18n PDV Menu Datadriven Suite
    [Documentation]
    ...    Imports directory-level shared i18n caches (saved in parent ``__init__.robot``), then logs in with suite
    ...    ``user_key``, ``module_name``, and ``locale``.
    Configure I18n Suite Locale From Contract    ${I18N_LOCALE_SUITE_FALLBACK}
    Configure I18n Bundles Dir From Contract
    Import I18n Internationalization Directory Caches Into Library
    ...    ${I18N_MENU_JSON_PATHS}
    ...    ${I18N_LOCALE}
    Login For PDV Menu Datadriven Suite On Web
    ...    user_key=${PDV_DATADRIVER_MENU_USER_KEY}
    ...    module_name=${PDV_DATADRIVER_MENU_MODULE}
    ...    locale=${I18N_LOCALE}

Verify I18n For RWS Child Menu Page
    [Documentation]
    ...    DataDriver template: CSV columns ``parent_menu``, ``child_menu``, ``page_name``. Row navigation uses suite user and module.
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu label from generated CSV |
    ...    | child_menu | Child label; empty when the parent has no sub-items |
    ...    | page_name | Combined identifier from generated CSV |
    [Arguments]    ${parent_menu}    ${child_menu}    ${page_name}
    Verify PDV Child Menu Page For Datadriven Row On Web
    ...    ${parent_menu}
    ...    ${child_menu}
    ...    ${page_name}
    ...    ${PDV_DATADRIVER_MENU_USER_KEY}
    ...    ${PDV_DATADRIVER_MENU_MODULE}
    Start Visible Text Inventory
    ${visible_texts}=    Stop Visible Text Inventory And Return Texts
    Log    Visible texts collected: ${visible_texts}
    ${i18n_ignore}=    Get Resolved I18n Ignore String Patterns    @{I18N_IGNORE_PATTERNS}
    ${i18n_wl_file}=    Get Resolved I18n Text Whitelist File Path
    Verify Visible Texts Against Locale Bundles    ${I18N_LOCALE}    ${visible_texts}
    ...    include_page_i18n=${True}
    ...    skip_numeric_looking=${True}
    ...    ignore_string_patterns=${i18n_ignore}
    ...    text_whitelist_file=${i18n_wl_file}
    ...    try_date_suffix_relaxation=${True}
    ...    strip_trailing_ratio_time=${True}
