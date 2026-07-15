# Using the Pre-run Modifier to Skip Tests Based on Enabled Configurations

This project uses a Robot Framework pre-run modifier (`ConfigFilter.py`) to automatically skip test cases that require specific configurations which are not enabled for the current environment.

## How It Works

- Each test that depends on a specific configuration should be tagged with `config:{config_name}`.
  - Example: `config:holiday_hrs`
- The enabled configurations for the environment are defined in the `enabled_configs` list in the environment's `config.json` file (e.g., `test_data/environments/QA28/config.json`).
- The pre-run modifier reads the enabled configs and removes any test from the suite that requires a config not present in the list.

```Note
As documented in TEST_DATA_SEEDER_UTILITY.md, the enabled configurations for a environment will be pre populated in environment's `config.json` file.
Current ConfigFilter implementation assumes that enabled_configs are defined in the `config.json` file for each environment. The structure might change in the future of config.json and we will accommodate that in the modifier as well.
```

```Note
As a QE test engineer or architect, you need to decide if the entire test case should be skipped if the required configuration is not enabled. Not all configs are mandatory for every test, so this approach allows for flexibility in test execution based on the current environment's capabilities.
```
## Example

Suppose your `config.json` contains:
```json
{
  "enabled_configs": [
    "holiday_hrs"
  ]
}
```

A test with the tag `config:holiday_hrs` will run, but a test with tag  `config:rta` will be skipped.

## How to Tag Tests

In your Robot Framework test file:
```robot
*** Test Cases ***
Test With Holiday Hours
    [Tags]    config:holiday_hrs
    ...test steps...

Test With MyWork
    [Tags]    config:rta
    ...test steps...
```

## How to Use

The modifier is automatically applied when running tests via `executor.py`. No manual steps are needed.

## Notes

- Tests without any `config:{config_name}` tag are always included.
- You can use multiple `config:{config_name}` tags on a test; all must be enabled for the test to run.

