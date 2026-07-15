# Internationalization Test Execution Guide

## Tests Execution Commands

Use one base command and add only the options you need.

```bash
uv run python executor.py <target> --test-env <ENV> --include-tags i18n [options]
```

Where:

| Argument or variable | Purpose | Example |
|---|---|---|
| `<target>` | Test file or folder to execute. | `tests/web/internationalization` or `tests/web/internationalization/third_level_menus/corp_rws_predictive_analytics_build_machine_learning_model.robot` |
| `--test-env <ENV>` | Required environment key used for config, data, and i18n discovery. | `--test-env QA13_V1` |
| `--include-tags i18n` | Runs only i18n-tagged tests. | `--include-tags i18n` |
| `--show-browser` | Headed mode for visual debugging. Omit for headless execution. | `--show-browser` |
| `--results-dir <PATH>` | Custom output folder for logs/reports. | `--results-dir results/all_june_5` |
| `--processes <N>` | Parallel worker count. | `--processes 10` |
| `--testlevelsplit` | Splits work at test level in parallel runs. | `--testlevelsplit` |
| `--log-level <LEVEL>` | Robot log verbosity. | `--log-level DEBUG` |
| `--variable I18N_LOCALE:<locale>` | Locale override for this run. | `--variable I18N_LOCALE:en_US` |
| `--variable I18N_VERBOSE_ALLOW_LIST_LOGS:True` | Enables detailed i18n allow-list diagnostics. | `--variable I18N_VERBOSE_ALLOW_LIST_LOGS:True` |
| `--variable I18N_LOG_MATCHED_PREVIEW_LIMIT:<N>` | Number of matched values shown in preview logs. | `--variable I18N_LOG_MATCHED_PREVIEW_LIMIT:20` |
| `--variable I18N_TRANSLATION_DEBUG_LOG:<PATH>` | Writes merged i18n sources to TSV for debugging. | `--variable I18N_TRANSLATION_DEBUG_LOG:results/results_QA13_V1/i18n_sources.tsv` |

Example:

- Single test, headed:

```bash
uv run python executor.py tests/web/internationalization/third_level_menus/corp_rws_predictive_analytics_build_machine_learning_model.robot --test-env QA13_V1 --include-tags i18n --variable I18N_LOCALE:en_US --show-browser
```

## Pre-requisites

Environment data should be available for the given environment.
(Environment data is already checked in for QA13_V1 env.)

```text
test_data/environments/QA13_V1
  - config.json
  - encrypted_credentials.json
```

## Whitelisted Text File

Text to be whitelisted should be placed in the common file (shared across locales):

```text
test_data\environments\QA13_V1\i18n_data\whitelist_text
  - whitelist_text.txt (already checked in)
```

## JSON Menu Paths

Menu JSON files should be placed in the environment folder below.
At runtime, paths are auto-discovered for the current ``--test-env``.

```text
test_data\environments\<TEST_ENVIRONMENT>\i18n_data\menu_json_files
  - CONNECT.json
  - ESS.json
  - PSA.json
  - RQS.json
  - RTA.json
  - RWS.json
```

Optional override:

```dotenv
# Comma-separated absolute file paths (wins over auto-discovery)
I18N_MENU_JSON_PATHS=C:\path\to\CONNECT.json,C:\path\to\ESS.json
```

## Bundles Directory Path in Scoped .env File

Bundle files are auto-discovered from the environment folder below for the active ``--test-env``.

```text
test_data\environments\<TEST_ENVIRONMENT>\i18n_data\resource_bundles
```

Optional override:

```dotenv
# Explicit override only when you do not want to use the checked-in environment folder
BUNDLES_DIR=C:\path\to\resource_bundles
```

## Override Examples

Use these only when you want custom data instead of the default files under
``test_data\environments\<TEST_ENVIRONMENT>\i18n_data``.

Custom bundles:

```dotenv
BUNDLES_DIR=C:\custom\i18n\resource_bundles
```

Custom menu JSON files:

```dotenv
I18N_MENU_JSON_PATHS=C:\custom\menus\CONNECT.json,C:\custom\menus\ESS.json
```

Custom whitelist file:

```dotenv
I18N_TEXT_WHITELIST_FILE=C:\custom\i18n\whitelist_text.txt
```

One-off locale override on the command line:

```bash
uv run python executor.py tests\web\internationalization --test-env QA13_V1 --include-tags i18n --variable I18N_LOCALE:es_MX
```
