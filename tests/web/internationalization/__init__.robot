*** Settings ***
Documentation       Parent suite for ``tests/web/internationalization``. Robot loads this when you run the folder or any
...                 child ``*.robot``; parent ``Suite Setup`` runs before child suites. One coordinated process saves
...                 menu+DB i18n caches (``Run Only Once Save I18n Internationalization Directory Shared Cache Files``); child
...                 suites only import. Locale: env ``I18N_LOCALE`` or ``--variable I18N_LOCALE:…``. Optional env
...                 ``I18N_PABOT_CACHE_STAMP`` overrides the default locale-aware stamp.

Resource            resources/web/internationalization/i18n_pabot_shared.resource
Library             pabot.PabotLib

Suite Setup         I18n Internationalization Directory Suite Setup


*** Keywords ***
I18n Internationalization Directory Suite Setup
    [Documentation]
    ...    Configures locale and bundle root, then one Pabot-coordinated save of shared i18n JSON + warm-up for flat bundles.
    Configure I18n Suite Locale From Contract    ${I18N_LOCALE_SUITE_FALLBACK}
    Configure I18n Bundles Dir From Contract
    VAR    ${I18N_PARENT_CONTEXT_READY}    ${True}    scope=SUITE
    Run Only Once    Save I18n Internationalization Directory Shared Cache Files    staging_dir=${I18N_PABOT_STAGING_DIR}
    Run Only Once    Warm Up I18n Flat Bundles For Locale    ${I18N_LOCALE}
