*** Settings ***
Documentation       This resource file contains keywords for csv parsing and global variable initialization for mobile resources.

Library             utils/common_utility/common_utils.py
Library             utils/common_utility/csv_helper.py
Resource            resources/Mobile/Common/Mobile_Device_Helper.resource


*** Keywords ***
Init Mobility Common Resources
    [Documentation]    To init all variables and imports
    Log To Console    Initialising mobility common resource and parsing localised data
    Set Log Level    WARN
    Parse Data For ESS
    Parse Data For SM
    Set Log Level    INFO

Parse Data For ESS
    [Documentation]    Generates data and global variables from the csv sheets based on variation and language for ESS resources.
    ...    Example:
    ...    - Parse Data For ESS
    ${LANG_CODE}=    Get Config Value    LOCALE
    VAR    ${test_env}    %{TEST_ENVIRONMENT=${EMPTY}}
    VAR    ${standard_translation_file}    resources/Mobile/ESS/Variables/workcloud_standard_translations.csv
    VAR    ${env_translation_file}    test_data/environments/${test_env}/workcloud_${test_env}_translations.csv
    ${translation_file}=    Resolve Translation File
    ...    ${standard_translation_file}    ${env_translation_file}    ${LANG_CODE}    ${test_env}

    &{result}=    Read Csv As Translation Map
    ...    ${translation_file}
    ...    KEY
    ...    ${LANG_CODE}
    ...    encoding=utf8
    VAR    &{TRANSLATED_MAP}=    &{result}    scope=GLOBAL

Parse Data For SM
    [Documentation]    Generates data and global variables from the csv sheets based on variation and language for SM resources.
    ...    Example:
    ...    - Parse Data For SM
    ${LANG_CODE}=    Get Config Value    LOCALE
    VAR    ${test_env}    %{TEST_ENVIRONMENT=${EMPTY}}
    VAR    ${standard_translation_file}    resources/Mobile/SM/Variables/sm_standard_translations.csv
    VAR    ${env_translation_file}    test_data/environments/${test_env}/sm_${test_env}_translations.csv
    ${translation_file}=    Resolve Translation File
    ...    ${standard_translation_file}    ${env_translation_file}    ${LANG_CODE}    ${test_env}

    &{result}=    Read Csv As Translation Map
    ...    ${translation_file}
    ...    KEY
    ...    ${LANG_CODE}
    ...    encoding=utf8
    VAR    &{TRANSLATED_SM_MAP}=    &{result}    scope=GLOBAL

Resolve Translation File
    [Documentation]
    ...    Returns the translation CSV path to use for parsing. Prefers the environment-specific
    ...    file when it exists AND contains the required language column; otherwise falls back to
    ...    the standard translation file. This prevents ``Read Csv As Translation Map`` from
    ...    failing when the env-specific CSV does not include the requested language column.
    ...    | =Arguments= | =Description= |
    ...    | standard_file | Path to the default/standard translation CSV. |
    ...    | env_file      | Path to the environment-specific translation CSV. |
    ...    | lang_code     | Language column (e.g. ``en_US``) that must exist in the chosen file. |
    ...    | test_env      | Current test environment name (used only for logging). |
    ...
    ...    *Returns*: Path to the translation file that should be used.
    ...
    ...    Example usage:
    ...    | ${file}=    Resolve Translation File    ${standard_file}    ${env_file}    en_US    QA28
    [Arguments]    ${standard_file}    ${env_file}    ${lang_code}    ${test_env}
    ${env_file_exists}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${env_file}
    IF    not ${env_file_exists}
        Log To Console
        ...    ⚠️ Translation file not found for ${test_env} in path ${env_file}. Defaulting to standard translations.
        RETURN    ${standard_file}
    END
    ${has_lang_column}=    Csv Has Column    ${env_file}    ${lang_code}
    IF    not ${has_lang_column}
        Log To Console
        ...    ⚠️ Env translation file ${env_file} is missing column '${lang_code}'. Defaulting to standard translations.
        RETURN    ${standard_file}
    END
    Log To Console    ✅ Translation file found for ${test_env}. Using ${env_file} for localization.
    RETURN    ${env_file}
