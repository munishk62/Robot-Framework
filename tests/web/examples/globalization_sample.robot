*** Settings ***
Documentation       Unified PDV menu DataDriver with internationalization (i18n) checks after each row.
...                 Set suite variables ``${PDV_DATADRIVER_MENU_USER_KEY}``, ``${PDV_DATADRIVER_MENU_MODULE}``; locale from ``Configure I18n Suite Locale From Contract``; bundle root from env override ``BUNDLES_DIR`` / ``WFM_RESOURCE_BUNDLES_DIR`` or auto-discovery under ``test_data/environments/<TEST_ENVIRONMENT>/i18n_data/resource_bundles`` via ``Configure I18n Bundles Dir From Contract``.
...                 DataDriver ``config_keyword`` and template keyword must live in *this* file so DataDriver can read argument names.

Resource            resources/web/pdv/pdv_menu_datadriver_dispatch.resource
Resource            resources/web/internationalization/i18n_pabot_shared.resource
Library             pabot.PabotLib
Library             resources/common/library/WebInternationalizationLibrary.py

Test Tags           dev:kapil    action:read    i18n_sample
# ESS
# "Mi programa","","Mi programa"
# "Panel de intercambio de turnos","","Panel de intercambio de turnos"
# SM
# "Pronóstico laboral","","Pronóstico laboral"
# "Presupuesto del plan","Plan presupuestario","Presupuesto del plan_Plan presupuestario"
# "Presupuesto del plan","Generación de presupuestos","Presupuesto del plan_Generación de presupuestos"
# "Programa","Programa de día","Programa_Programa de día"
# "Programa","Programa semanal","Programa_Programa semanal"


*** Variables ***
${PDV_DATADRIVER_MENU_USER_KEY}     ESS1_STORE1
${PDV_DATADRIVER_MENU_MODULE}       ess
${I18N_LOCALE}                      es_MX


*** Test Cases ***
# Generate PDV Child Menu CSV For Environment And Return Config
#    [Documentation]
#    ...    DataDriver ``config_keyword``: forwards suite user, module, and locale into ``Generate PDV Child Menu CSV For Environment With Params And Return Config``.
#    VAR    &{original_config}    &{EMPTY}
#    Generate PDV Child Menu CSV For Environment And Return Config    ${original_config}

Sample I18n Test For Just Single Menu Item
    [Documentation]    Verifies the i18n for a single menu item.
    [Tags]    i18n
    Login For I18n PDV Menu Datadriven Suite
    Verify I18n For RWS Child Menu Page    Mi programa    ${EMPTY}    Mi programa

Log All Translations To File
    [Documentation]    Logs all translations to a file for analysis purpose.
    Configure I18n Suite Locale From Contract    ${I18N_LOCALE_SUITE_FALLBACK}
    Configure I18n Bundles Dir From Contract
    ${owner_id}=    Get Config Value    key=OWNER_ID
    Add Translation Sources From Menu Json Files    ${I18N_MENU_JSON_PATHS}    locale=${I18N_LOCALE}
    Add Translation Sources From Db2 For Locale    locale=${I18N_LOCALE}    owner_lang_mapping=${owner_id}    owner_rfx_user=${owner_id}
    Write I18n Translation Sources To File
    ...    ${OUTPUT_DIR}${/}i18n_sources_${I18N_LOCALE}.tsv
    ...    ${I18N_LOCALE}
    Run Only Once    Save I18n Shared Cache Files
    ...    menu_json_paths=${I18N_MENU_JSON_PATHS}
    ...    locale=${I18N_LOCALE}
    ...    staging_dir=${I18N_PABOT_STAGING_DIR}


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
    ...    Saves shared cache files once under Pabot, imports caches on every worker, then logs in with suite
    ...    ``user_key``, ``module_name``, and ``locale``.
    Configure I18n Suite Locale From Contract    ${I18N_LOCALE_SUITE_FALLBACK}
    Configure I18n Bundles Dir From Contract
    Run Only Once    Save I18n Shared Cache Files
    ...    menu_json_paths=${I18N_MENU_JSON_PATHS}
    ...    locale=${I18N_LOCALE}
    ...    staging_dir=${I18N_PABOT_STAGING_DIR}
    Import I18n Caches Into Library
    ...    menu_json_paths=${I18N_MENU_JSON_PATHS}
    ...    locale=${I18N_LOCALE}
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
    ...    log_unmatched_dom_context=${True}
