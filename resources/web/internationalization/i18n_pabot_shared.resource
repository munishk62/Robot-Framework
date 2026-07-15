*** Settings ***
Documentation       Pabot-safe internationalization (i18n) caches: ``tests/web/internationalization/__init__.robot`` runs
...                 ``Run Only Once Save I18n Internationalization Directory Shared Cache Files`` (one menu+DB save per
...                 executor run for the whole folder). Child suites call ``Import I18n Internationalization Directory Caches
...                 Into Library``. Stamp comes from ``Get I18n Web Directory Shared Cache Stamp`` (locale suffix unless env
...                 ``I18N_PABOT_CACHE_STAMP`` is set). Suites outside that folder (e.g. ``tests/web/examples``) keep their own
...                 ``Run Only Once Save I18n Shared Cache Files`` with per-suite stamp. The ``Import I18n Caches From Live
...                 Sources`` branch runs when parallel keys are missing (plain ``robot`` without Pabot).
...
...                 **Configuration (defaults in this resource; override with env, ``--variable``, or suite ``Variables``):**
...                 ``I18N_LOCALE`` (env → Robot ``${I18N_LOCALE}`` default ``en_US`` here → ``${I18N_LOCALE_SUITE_FALLBACK}``);
...                 bundle root from env ``BUNDLES_DIR`` / ``WFM_RESOURCE_BUNDLES_DIR`` or auto-discovered from
...                 ``test_data/environments/<TEST_ENVIRONMENT>/i18n_data/resource_bundles``; menu JSON from env
...                 ``I18N_MENU_JSON_PATHS`` (comma-separated) or auto-discovered from
...                 ``test_data/environments/<TEST_ENVIRONMENT>/i18n_data/menu_json_files`` then merged with ``@{I18N_MENU_JSON_PATHS}`` and optional YAML
...                 ``menu_json_paths`` when ``I18N_SHARED_CONTRACT_PATH`` / default contract exists; ignore patterns from
...                 ``I18N_IGNORE_PATTERNS_FILE`` / ``I18N_IGNORE_PATTERNS`` (``|||`` segments) then ``@{I18N_IGNORE_PATTERNS}``;
...                 optional whitelist file env ``I18N_TEXT_WHITELIST_FILE`` or ``${I18N_TEXT_WHITELIST_FILE}``. DB2 query list:
...                 env ``I18N_DB2_LOCALE_SOURCES_FILE`` or contract ``db2_locale_sources_file``; DB literals: ``i18n_whitelist_db.resource``.
...
...                 **Ad-hoc bootstrap:** ``Run I18n Shared Cache Bootstrap Job`` is for a single-process CI pre-step or
...                 tooling (same directory save + warm-up, no ``Run Only Once``).

Resource            resources/web/internationalization/i18n_whitelist_db.resource
Library             Collections
Library             OperatingSystem
Library             pabot.PabotLib
Library             resources/common/library/WebInternationalizationLibrary.py


*** Variables ***
# Default staging dir is built inside ``Save I18n Shared Cache Files`` via ``Join Path`` (never compose ${EXECDIR} in this table).
${I18N_PABOT_STAGING_DIR}           ${EMPTY}
# Default locale when env ``I18N_LOCALE`` and suite overrides are unset; overridden by ``--variable I18N_LOCALE:…``.
${I18N_LOCALE}                      en_US
# Optional alternate contract YAML (``menu_json_paths``, ``db2_locale_sources_file`` only — not locale/bundles).
${I18N_SHARED_CONTRACT_PATH}        ${EMPTY}
# Passed into ``Get Resolved I18n Locale`` when env and ``${I18N_LOCALE}`` are empty (rare).
${I18N_LOCALE_SUITE_FALLBACK}       ${EMPTY}
# Optional UTF-8 file: one literal per line for ``Verify … text_whitelist_file=``; overridden by env ``I18N_TEXT_WHITELIST_FILE``.
# ${I18N_TEXT_WHITELIST_FILE}    ${EXECDIR}${/}test_data${/}environments${/}QA13_V1${/}i18n_data${/}whitelist_text${/}whitelist_text.txt
${I18N_TEXT_WHITELIST_FILE}         ${EMPTY}

# Optional additional menu JSON paths (left empty by default).
# Runtime base paths are auto-discovered from:
#    test_data/environments/<TEST_ENVIRONMENT>/i18n_data/menu_json_files/*.json
# You can still override with env ``I18N_MENU_JSON_PATHS`` or contract ``menu_json_paths``.
@{I18N_MENU_JSON_PATHS}             @{EMPTY}

@{I18N_IGNORE_PATTERNS}
...                                 ^ACTIVITY*
...                                 ^Calculation*
...                                 (?i)^STORE\\d+\\s*-\\s*\\w+(?:\\s+\\d+)?$
...                                 ^BA\\*(?:[1-9]|1\\d|2[0-8])$
...                                 (?i)^Store\\d+\\s+Associate\\d+$
...                                 (?i)^Store\\s+Admin\\d+$
...                                 (?i)^DMGR\\s+S\\dD\\d(?:D\\d)?$
...                                 (?i)^ZAUTOSTORE.*$
...                                 (?i)^ZEMP\d+$
...                                 \\$\\s*\\d{1,3}(?:,\\d{3})*
...                                 ^(?:0[1-9]|1[0-2])/(?:0[1-9]|[12]\\d|3[01])/\\d{4}\\s*-\\s*(?:0[1-9]|1[0-2])/(?:0[1-9]|[12]\\d|3[01])/\\d{4}$
...                                 (?i)^-\\s*\\d{1,2}:\\d{2}(?:[ap](?:m)?)?$
...                                 ^-$


*** Keywords ***
Get Default I18n Pabot Staging Dir
    [Documentation]
    ...    Returns ``<EXECDIR>/test_data/generated`` using ``Join Path`` only. Use when a suite needs the path string;
    ...    or pass ``staging_dir=${I18N_PABOT_STAGING_DIR}`` with ``${I18N_PABOT_STAGING_DIR}`` defaulting to ``${EMPTY}`` in this resource.
    ${p}=    Join Path    ${EXECDIR}    test_data    generated
    RETURN    ${p}

Configure I18n Suite Locale From Contract
    [Documentation]
    ...    Sets suite variable ``${I18N_LOCALE}`` via `Get Resolved I18n Locale`. Precedence: env ``I18N_LOCALE`` → Robot
    ...    ``${I18N_LOCALE}`` (resource default ``en_US``, suite override, or ``--variable``) → ``suite_fallback`` → resource default ``en_US``.
    ...    Call from the DataDriver ``config_keyword`` before CSV generation.
    ...
    ...    | =Arguments= | =Description= |
    ...    | suite_fallback | Optional; pass ``${I18N_LOCALE_SUITE_FALLBACK}`` when env and ``${I18N_LOCALE}`` are empty. |
    [Arguments]    ${suite_fallback}=${EMPTY}
    ${effective_fallback}=    Set Variable If    '${suite_fallback}' != '${EMPTY}'    ${suite_fallback}    ${I18N_LOCALE}
    ${resolved}=    Get Resolved I18n Locale    ${effective_fallback}    ${I18N_SHARED_CONTRACT_PATH}
    VAR    ${I18N_LOCALE}=    ${resolved}    scope=SUITE
    Log    I18N | suite locale configured: ${I18N_LOCALE}    level=INFO

Configure I18n Bundles Dir From Contract
    [Documentation]
    ...    Resolves the app ``.properties`` root via `Get Resolved I18n Bundles Dir` (env override or
    ...    ``test_data/environments/<TEST_ENVIRONMENT>/i18n_data/resource_bundles`` auto-discovery) and calls
    ...    `Set Default I18n Bundles Dir For Visible Text Verify`. Run after
    ...    ``Configure I18n Suite Locale From Contract``.
    ${bd}=    Get Resolved I18n Bundles Dir
    Log    I18N | suite bundles dir configured (library default): ${bd}    level=INFO
    Set Default I18n Bundles Dir For Visible Text Verify    ${bd}

Get Merged Menu Json Paths For I18n Save
    [Documentation]
    ...    Merges, in order: env ``I18N_MENU_JSON_PATHS`` (comma-separated paths) or auto-discovered
    ...    ``test_data/environments/<TEST_ENVIRONMENT>/i18n_data/menu_json_files/*.json``, ``suite_menu_paths`` (pass
    ...    ``${I18N_MENU_JSON_PATHS}`` as a single list variable), optional contract ``menu_json_paths``, then again
    ...    ``${I18N_MENU_JSON_PATHS}`` from this resource. De-duplicated. Do not use ``@{...}`` as the first ``Combine Lists``
    ...    argument.
    [Arguments]    ${suite_menu_paths}
    ${from_env}=    Get Menu Json Paths From Environment
    ${m0}=    Combine Lists    ${from_env}    ${suite_menu_paths}
    ${contract_paths}=    Get Menu Json Paths From I18n Contract    ${I18N_SHARED_CONTRACT_PATH}
    ${m1}=    Combine Lists    ${m0}    ${contract_paths}
    ${m2}=    Combine Lists    ${m1}    ${I18N_MENU_JSON_PATHS}
    ${out}=    Dedupe Ordered String List    ${m2}
    RETURN    ${out}

Save I18n Internationalization Directory Shared Cache Files
    [Documentation]
    ...    Writes ``i18n_extra_<stamp>.json`` and ``i18n_whitelist_<stamp>.json`` using ``Get I18n Web Directory Shared
    ...    Cache Stamp`` for ``cache_key_stamp``. Expects ``Configure I18n Suite Locale From Contract`` and
    ...    ``Configure I18n Bundles Dir From Contract`` to have run (e.g. parent ``__init__.robot``). Wrap with
    ...    ``Run Only Once`` in suite setup under Pabot.
    [Arguments]    ${unit_extra_where}=${EMPTY}    ${employee_extra_where}=${EMPTY}    ${staging_dir}=${EMPTY}
    ${stamp}=    Get I18n Web Directory Shared Cache Stamp    ${I18N_LOCALE_SUITE_FALLBACK}    ${I18N_SHARED_CONTRACT_PATH}
    ${menus}=    Get Merged Menu Json Paths For I18n Save    ${I18N_MENU_JSON_PATHS}
    Save I18n Shared Cache Files
    ...    ${menus}
    ...    ${I18N_LOCALE}
    ...    ${unit_extra_where}
    ...    ${employee_extra_where}
    ...    ${staging_dir}
    ...    ${stamp}

Import I18n Internationalization Directory Caches Into Library
    [Documentation]
    ...    Imports caches produced by ``Save I18n Internationalization Directory Shared Cache Files`` (same stamp as
    ...    ``Get I18n Web Directory Shared Cache Stamp``). Call from each child suite after ``Configure … From Contract``.
    [Arguments]    ${menu_json_paths}    ${locale}    ${unit_extra_where}=${EMPTY}    ${employee_extra_where}=${EMPTY}
    ${stamp}=    Get I18n Web Directory Shared Cache Stamp    ${I18N_LOCALE_SUITE_FALLBACK}    ${I18N_SHARED_CONTRACT_PATH}
    Import I18n Caches Into Library
    ...    ${menu_json_paths}
    ...    ${locale}
    ...    ${unit_extra_where}
    ...    ${employee_extra_where}
    ...    ${stamp}

Run I18n Shared Cache Bootstrap Job
    [Documentation]
    ...    One-shot job: resolve locale/bundles, ``Save I18n Internationalization Directory Shared Cache Files``, then
    ...    ``Warm Up I18n Flat Bundles For Locale``. Does not use ``Run Only Once`` (intended for a single process or
    ...    explicit CI step). Uses the same directory/locale-aware stamp as ``tests/web/internationalization/__init__.robot``.
    [Arguments]    ${unit_extra_where}=${EMPTY}    ${employee_extra_where}=${EMPTY}    ${staging_dir}=${EMPTY}
    Configure I18n Suite Locale From Contract    ${I18N_LOCALE_SUITE_FALLBACK}
    Configure I18n Bundles Dir From Contract
    Save I18n Internationalization Directory Shared Cache Files
    ...    ${unit_extra_where}
    ...    ${employee_extra_where}
    ...    ${staging_dir}
    Warm Up I18n Flat Bundles For Locale    ${I18N_LOCALE}

Import I18n Cache Files Into Library
    [Documentation]    Imports both serialized caches from disk into the library (extras JSON + whitelist JSON).
    [Arguments]    ${whitelist_file_path}    ${extras_file_path}
    Import Cached Extra Translations From File    ${extras_file_path}
    Import Cached I18n Text Whitelist From File    ${whitelist_file_path}
    Log    I18N | imported shared cache files into library    level=INFO

Try Import I18n Cache Files From Staging Dir
    [Documentation]
    ...    Attempts staged-file import using ``cache_key_stamp`` from an explicit ``staging_dir``, the configured
    ...    ``${I18N_PABOT_STAGING_DIR}``, or the default ``<EXECDIR>/test_data/generated`` when no override is set.
    ...    This supports serial/non-Pabot folder runs after parent setup saved files but no Pabot keys exist.
    ...    | =Arguments= | =Description= |
    ...    | cache_key_stamp | Stamp suffix used by ``Save I18n Shared Cache Files``. |
    ...    | staging_dir | Optional staging directory override; when empty, use ``${I18N_PABOT_STAGING_DIR}`` if set, else the default staging dir. |
    ...
    ...    | =Returns= | =Description= |
    ...    | bool | ``${True}`` when both staged files exist and import succeeds; else ``${False}``. |
    [Arguments]    ${cache_key_stamp}    ${staging_dir}=${EMPTY}
    IF    $staging_dir
        ${staging_dir}=    Normalize Path    ${staging_dir}
    ELSE IF    $I18N_PABOT_STAGING_DIR
        ${staging_dir}=    Normalize Path    ${I18N_PABOT_STAGING_DIR}
    ELSE
        ${staging_dir}=    Get Default I18n Pabot Staging Dir
    END
    ${wl_fp}=    Join Path    ${staging_dir}    i18n_whitelist_${cache_key_stamp}.json
    ${extras_fp}=    Join Path    ${staging_dir}    i18n_extra_${cache_key_stamp}.json
    ${has_wl}=    Run Keyword And Return Status    File Should Exist    ${wl_fp}
    ${has_extras}=    Run Keyword And Return Status    File Should Exist    ${extras_fp}
    IF    ${has_wl} and ${has_extras}
        ${import_status}    ${import_result}=    Run Keyword And Ignore Error
        ...    Import I18n Cache Files Into Library
        ...    ${wl_fp}
        ...    ${extras_fp}
        IF    '${import_status}' == 'PASS'
            Log    I18N | imported staged cache files from staging dir: ${staging_dir} (stamp=${cache_key_stamp})    level=INFO
            RETURN    ${True}
        END
        Log
        ...    I18N | staged cache files exist but import failed; falling back to live menu/DB import (staging_dir=${staging_dir}, stamp=${cache_key_stamp}, reason=${import_result})
        ...    level=WARN
    END
    RETURN    ${False}

Import I18n Caches From Live Sources
    [Documentation]
    ...    Rebuilds i18n caches in *this* process only: clears extras, loads menu JSON and DB2 strings, fetches
    ...    DB whitelist, then ``Set Cached I18n Text Whitelist``. Use when Pabot parallel keys are not set (local
    ...    ``robot`` runs). Not used on a typical Pabot run after ``Save I18n Shared Cache Files``.
    [Arguments]    ${menu_json_paths}    ${locale}    ${owner_id}    ${unit_extra_where}=${EMPTY}    ${employee_extra_where}=${EMPTY}
    Clear Extra Translation Sources For Visible Text Verify
    ${menu_deduped}=    Get Merged Menu Json Paths For I18n Save    ${menu_json_paths}
    ${db2_cfg}=    Get Db2 Locale Sources Path From I18n Contract    ${I18N_SHARED_CONTRACT_PATH}
    Add Translation Sources From Menu Json Files    ${menu_deduped}    locale=${locale}
    Add Translation Sources From Db2 For Locale
    ...    locale=${locale}
    ...    owner_lang_mapping=${owner_id}
    ...    owner_rfx_user=${owner_id}
    ...    sources_config_path=${db2_cfg}
    ${wl}=    Get I18n Text Whitelist From Db    ${owner_id}    ${unit_extra_where}    ${employee_extra_where}
    Set Cached I18n Text Whitelist    ${wl}
    Log    I18N | imported caches from live menu/DB sources (no shared files)    level=INFO

Save I18n Shared Cache Files
    [Documentation]
    ...    Run *once* per suite with ``Run Only Once`` under Pabot: clears extra cache, loads menu JSON and DB2 strings into
    ...    memory, writes ``i18n_extra_<stamp>.json`` and ``i18n_whitelist_<stamp>.json`` under ``${staging_dir}``, then sets
    ...    parallel keys ``I18N_WHITELIST_FILE_<stamp>`` and ``I18N_EXTRA_EXPORT_FILE_<stamp>`` so multiple i18n suites in one
    ...    Pabot run do not overwrite each other. When ``cache_key_stamp`` is empty, ``Get I18n Pabot Suite File Stamp`` derives
    ...    a stable stamp from ``${SUITE_SOURCE}`` (identical on all workers for the same ``*.robot`` file).
    ...
    ...    | =Arguments= | =Description= |
    ...    | menu_json_paths | List merged with contract ``menu_json_paths`` and ``${I18N_MENU_JSON_PATHS}``. |
    ...    | locale | Locale for menu/DB2 (e.g. ``es_MX``). |
    ...    | unit_extra_where | Optional; passed to `Get I18n Text Whitelist From Db`. |
    ...    | employee_extra_where | Optional; passed to `Get I18n Text Whitelist From Db`. |
    ...    | staging_dir | Optional. ``${EMPTY}`` builds ``<EXECDIR>/test_data/generated``. |
    ...    | cache_key_stamp | Optional Pabot/file suffix; empty = derived from ``${SUITE_SOURCE}``. |
    [Arguments]    ${menu_json_paths}    ${locale}    ${unit_extra_where}=${EMPTY}
    ...    ${employee_extra_where}=${EMPTY}    ${staging_dir}=${EMPTY}    ${cache_key_stamp}=${EMPTY}
    ${owner_id}=    Get Config Value    key=OWNER_ID
    IF    '${cache_key_stamp}' == '${EMPTY}'
        ${cache_key_stamp}=    Get I18n Pabot Suite File Stamp
    END
    IF    '${staging_dir}' == '${EMPTY}'
        ${staging_dir}=    Join Path    ${EXECDIR}    test_data    generated
    ELSE
        ${staging_dir}=    Normalize Path    ${staging_dir}
    END
    Create Directory    ${staging_dir}
    Clear Extra Translation Sources For Visible Text Verify
    ${menu_deduped}=    Get Merged Menu Json Paths For I18n Save    ${menu_json_paths}
    ${db2_cfg}=    Get Db2 Locale Sources Path From I18n Contract    ${I18N_SHARED_CONTRACT_PATH}
    Add Translation Sources From Menu Json Files    ${menu_deduped}    locale=${locale}
    Add Translation Sources From Db2 For Locale
    ...    locale=${locale}
    ...    owner_lang_mapping=${owner_id}
    ...    owner_rfx_user=${owner_id}
    ...    sources_config_path=${db2_cfg}
    ${extras_fp}=    Join Path    ${staging_dir}    i18n_extra_${cache_key_stamp}.json
    ${wl_fp}=    Join Path    ${staging_dir}    i18n_whitelist_${cache_key_stamp}.json
    Export Cached Extra Translations To File    ${extras_fp}
    ${wl}=    Get I18n Text Whitelist From Db    ${owner_id}    ${unit_extra_where}    ${employee_extra_where}
    Save Cached I18n Text Whitelist To File    ${wl_fp}    ${wl}
    VAR    ${pk_wl}=    I18N_WHITELIST_FILE_${cache_key_stamp}
    VAR    ${pk_ex}=    I18N_EXTRA_EXPORT_FILE_${cache_key_stamp}
    Set Parallel Value For Key    ${pk_wl}    ${wl_fp}
    Set Parallel Value For Key    ${pk_ex}    ${extras_fp}
    Log    I18N | saved shared cache files under ${staging_dir} (stamp=${cache_key_stamp}) and registered paths with Pabot    level=INFO

Import I18n Caches Into Library
    [Documentation]
    ...    Run on *every* worker in suite setup (do *not* wrap with ``Run Only Once``). If ``Get Parallel Value For Key``
    ...    returns both ``I18N_WHITELIST_FILE_<stamp>`` and ``I18N_EXTRA_EXPORT_FILE_<stamp>``, imports those files into the
    ...    library. ``cache_key_stamp`` must match ``Save I18n Shared Cache Files`` (default: same derived stamp from
    ...    ``${SUITE_SOURCE}``). If keys are absent (serial/non-Pabot), tries default staged files first,
    ...    then falls back to `Import I18n Caches From Live Sources`.
    ...
    ...    | =Arguments= | =Description= |
    ...    | menu_json_paths | List for live-source fallback. |
    ...    | locale | Locale for fallback. |
    ...    | unit_extra_where | Optional whitelist fragment for fallback. |
    ...    | employee_extra_where | Optional whitelist fragment for fallback. |
    ...    | cache_key_stamp | Must match save step; empty = ``Get I18n Pabot Suite File Stamp``. |
    [Arguments]    ${menu_json_paths}    ${locale}    ${unit_extra_where}=${EMPTY}
    ...    ${employee_extra_where}=${EMPTY}    ${cache_key_stamp}=${EMPTY}
    ${owner_id}=    Get Config Value    key=OWNER_ID
    IF    '${cache_key_stamp}' == '${EMPTY}'
        ${cache_key_stamp}=    Get I18n Pabot Suite File Stamp
    END
    VAR    ${pk_wl}=    I18N_WHITELIST_FILE_${cache_key_stamp}
    VAR    ${pk_ex}=    I18N_EXTRA_EXPORT_FILE_${cache_key_stamp}
    ${st_w}    ${wp}=    Run Keyword And Ignore Error    Get Parallel Value For Key    ${pk_wl}
    ${st_e}    ${ep}=    Run Keyword And Ignore Error    Get Parallel Value For Key    ${pk_ex}
    IF    '${st_w}' == 'PASS' and '${st_e}' == 'PASS'
        ${nw}=    Strip String    ${wp}
        ${ne}=    Strip String    ${ep}
        IF    '${nw}' != '${EMPTY}' and '${ne}' != '${EMPTY}'
            Import I18n Cache Files Into Library    ${nw}    ${ne}
        ELSE
            ${loaded_from_staging}=    Try Import I18n Cache Files From Staging Dir    ${cache_key_stamp}
            IF    not ${loaded_from_staging}
                Log    I18N | Pabot keys empty and no staged files; using live menu/DB import (expected only when save step skipped)
                ...    level=INFO
                Import I18n Caches From Live Sources
                ...    ${menu_json_paths}
                ...    ${locale}
                ...    ${owner_id}
                ...    ${unit_extra_where}
                ...    ${employee_extra_where}
            END
        END
    ELSE
        ${loaded_from_staging}=    Try Import I18n Cache Files From Staging Dir    ${cache_key_stamp}
        IF    not ${loaded_from_staging}
            Log    I18N | Get Parallel Value For Key failed and no staged files; using live menu/DB import (non-Pabot run)    level=INFO
            Import I18n Caches From Live Sources
            ...    ${menu_json_paths}
            ...    ${locale}
            ...    ${owner_id}
            ...    ${unit_extra_where}
            ...    ${employee_extra_where}
        END
    END
