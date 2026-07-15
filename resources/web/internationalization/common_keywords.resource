*** Settings ***
Documentation       Common reusable keywords for internationalization (i18n) test suites.
...
...                 Provides suite-level i18n initialization (locale, bundles directory, and shared cache import)
...                 and visible-text verification against locale bundles.
...
...                 Intended to be shared across all i18n test suites regardless of module (ESS, RWS, PDV, etc.).
...                 Command to execute tests with logging of visible texts and i18n verification details:
...                 Ex: uv run python executor.py tests\web --test-env QA13_V1 --include-tags i18n_payroll_release_add_paychecks --show-browser --log-level DEBUG
...                 --variable=I18N_LOCALE:en_GB --variable I18N_VERBOSE_ALLOW_LIST_LOGS:True --variable I18N_LOG_MATCHED_PREVIEW_LIMIT:20
...                 --variable I18N_TRANSLATION_DEBUG_LOG:results/results_QA13_V1/i18n_sources.tsv
...                 Command to execute tests with default locale and no extra logging:
...                 Ex: uv run python executor.py tests\web\internationalization\ --test-env QA13_V1 --include-tags i18n_payroll_release_add_paychecks --show-browser

Resource            resources/web/internationalization/i18n_pabot_shared.resource


*** Keywords ***
Configure I18n Context For Test Suite
    [Documentation]
    ...    Suite setup: imports shared i18n caches and only configures locale/bundles when parent
    ...    ``tests/web/internationalization/__init__.robot`` context is not present (standalone file runs).
    ...    | =Flow= | =Description= |
    ...    | Parent context ready | Skip locale/bundles config and import caches. |
    ...    | Parent context missing | Configure locale + bundles, then import caches. |
    ${parent_context_ready}    Get Variable Value    \${I18N_PARENT_CONTEXT_READY}    ${False}
    IF    not ${parent_context_ready}
        Configure I18n Suite Locale From Contract    ${I18N_LOCALE_SUITE_FALLBACK}
        Configure I18n Bundles Dir From Contract
        VAR    ${I18N_PARENT_CONTEXT_READY}    ${True}    scope=SUITE
        Log    I18N | parent context not found; configured locale and bundles in child suite setup    level=INFO
    END
    Import I18n Internationalization Directory Caches Into Library
    ...    ${I18N_MENU_JSON_PATHS}
    ...    ${I18N_LOCALE}

Verify I18n For Visible Page Text
    [Documentation]
    ...    Verifies that all visible page text matches the expected locale bundles for i18n localization.
    ...    Applies i18n ignore patterns and whitelist file to filter expected variations.
    ...    Optional debug toggles can be passed via Robot variables:
    ...    ``I18N_VERBOSE_ALLOW_LIST_LOGS``, ``I18N_LOG_MATCHED_PREVIEW_LIMIT``,
    ...    and ``I18N_TRANSLATION_DEBUG_LOG``.
    ...    | =Arguments= | =Description= |
    ...    | visible_text | List of visible text strings collected from the page |
    [Arguments]    ${visible_text}

    ${i18n_ignore}    Get Resolved I18n Ignore String Patterns    @{I18N_IGNORE_PATTERNS}
    ${i18n_wl_file}    Get Resolved I18n Text Whitelist File Path
    ${i18n_verbose_logs}    Get Variable Value    \${I18N_VERBOSE_ALLOW_LIST_LOGS}    ${False}
    ${i18n_matched_preview_limit}    Get Variable Value    \${I18N_LOG_MATCHED_PREVIEW_LIMIT}    0
    ${i18n_translation_debug_log}    Get Variable Value    \${I18N_TRANSLATION_DEBUG_LOG}    ${EMPTY}
    Verify Visible Texts Against Locale Bundles    ${I18N_LOCALE}    ${visible_text}
    ...    include_page_i18n=${True}
    ...    skip_numeric_looking=${True}
    ...    ignore_string_patterns=${i18n_ignore}
    ...    text_whitelist_file=${i18n_wl_file}
    ...    try_date_suffix_relaxation=${True}
    ...    strip_trailing_ratio_time=${True}
    ...    max_properties_files_to_log=80
    ...    log_unmatched_dom_context=${True}
    ...    verbose_allow_list_logs=${i18n_verbose_logs}
    ...    log_matched_preview_limit=${i18n_matched_preview_limit}
    ...    translation_debug_log_path=${i18n_translation_debug_log}
