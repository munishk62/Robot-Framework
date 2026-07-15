# Environment-Specific Locator Management Guide

## Overview

This guide explains how to use the new environment-specific locator management system in the WFM Test Automation framework. This system allows you to define different UI locators for different environments while keeping the same variable names in your Robot Framework tests.

## Problem Solved

Previously, when UI elements changed slightly between environments (different customer deployments or releases), The test case used to fails as the corresponding element is not found for that environment. This needs a fix from engineering to have consistent locators. However in mean time we have provided a way to have environment-specific locators. This new system allows you to:

1. Keep the same variable names across all environments
2. Define environment-specific locator values in JSON files
3. Automatically load the correct locators based on the current test environment
4. Provide fallback default values when environment-specific locators aren't defined

## File Structure

```
test_data/environments/
├── QA28_B0/
│   ├── config.json          # Existing configuration
│   ├── constants.json       # Existing constants  
│   └── locators.json        # NEW: Environment-specific locators
├── QA28_V3/
│   ├── config.json
│   ├── constants.json
│   └── locators.json        # Different locator values for this environment
└── DEMO05/
    ├── config.json
    ├── constants.json
    └── locators.json
```

## Locators.json Structure

The `locators.json` file follows a simple module-based structure:

```json
{
  "module_name": {
    "LOCATOR_VARIABLE_NAME": "xpath_or_css_selector"
  }
}
```

### Example:

```json
{
  "schedule": {
    "ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX": "//div[@id='mainContainer']//tbody[@id='tBodyContainer']/tr/td[{CELL_INDEX}]",
    "ALLSCHEDULESPAGE_PUBLISHED_SCHEDULE_LOCATOR": "//span[contains(normalize-space(@aria-label), 'Published Schedule For {WEEK_DATE}')]",
    "FIXEDSHIFTSPAGE_SUBMIT_BUTTON": "//button[@id='submit']"
  },
  "hr": {
    "REQUEST_CALENDAR_SUBMIT_BUTTON": "//button[@id='submitRequest']",
    "REQUEST_CALENDAR_DATE_PICKER": "//input[@class='datepicker']"
  }
}
```

## Migrating Existing Page Objects

### Step 1: Update Page Object Files

For each `*_page.py` file that needs environment-specific locators:

**Before:**
```python
# all_schedules_page.py
ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX = "//div[@id='mainContainer']//tbody[@id='tBodyContainer']/tr/td[{CELL_INDEX}]"
ALLSCHEDULESPAGE_PUBLISHED_SCHEDULE_LOCATOR = "//span[contains(normalize-space(@aria-label), 'Published Schedule For {WEEK_DATE}')]"
```

**After:**
```python
# all_schedules_page.py
# Define your locators normally - no wrapping needed!
ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX = "//div[@id='mainContainer']//tbody[@id='tBodyContainer']/tr/td[{CELL_INDEX}]"
ALLSCHEDULESPAGE_PUBLISHED_SCHEDULE_LOCATOR = "//span[contains(normalize-space(@aria-label), 'Published Schedule For {WEEK_DATE}')]"

# Simply add these 2 lines at the end of the file:
from test_data.dynamic_locator_loader import apply_environment_locators
apply_environment_locators("schedule", globals())
```

### Step 2: Create Environment-Specific Locator Files

Create `locators.json` files for each environment where locators differ:

```bash
# Create locator files for each environment
touch test_data/environments/QA28_B0/locators.json
touch test_data/environments/QA28_V3/locators.json
touch test_data/environments/DEMO05/locators.json
```

### Step 3: Define Environment-Specific Values

In each environment's `locators.json`, define only the locators that differ from the default:

**QA28_B0/locators.json** (uses default values - can be empty or minimal):
```json
{
  "schedule": {}
}
```

**QA28_V3/locators.json** (has different UI structure):
```json
{
  "schedule": {
    "ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX": "//div[@id='scheduleContainer']//tbody[@id='weekTableBody']/tr/td[{CELL_INDEX}]",
    "ALLSCHEDULESPAGE_PUBLISHED_SCHEDULE_LOCATOR": "//span[contains(normalize-space(@title), 'Published Schedule For {WEEK_DATE}')]"
  }
}
```

## Usage in Robot Framework Tests

### Method 1: Automatic Loading (Recommended)

The locators are automatically loaded when you import the variables file. No changes needed in your Robot Framework tests:

```robotframework
*** Settings ***
Variables    resources/web/rws/schedule/all_schedules_page.py

*** Test Cases ***
Test Schedule Navigation
    Click Element On Webpage    ${ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX}
    # The correct locator for the current environment is automatically used
```

## Running Tests with Different Environments

The system automatically detects the environment from the `TEST_ENVIRONMENT` environment variable, which is set by the executor:

```bash
# Run tests with QA28_B0 environment (will use QA28_B0/locators.json)
python executor.py tests/web/schedule/ --test-env QA28_B0

# Run tests with QA28_V3 environment (will use QA28_V3/locators.json)  
python executor.py tests/web/schedule/ --test-env QA28_V3

# Run tests with DEMO05 environment (will use DEMO05/locators.json)
python executor.py tests/web/schedule/ --test-env DEMO05
```

## Best Practices

### 1. Define Default Values in Page Objects

Always define your locators with sensible default values in the page object files. Environment-specific overrides are optional:

```python
# Default locator that works for most environments
LOCATOR_NAME = "//default[@xpath='expression']"

# Add environment override capability at end of file
from test_data.dynamic_locator_loader import apply_environment_locators
apply_environment_locators("module_name", globals())
```

### 2. Organize by Module

Structure your locators.json by module for better organization:

```json
{
  "schedule": {
    "ALLSCHEDULESPAGE_WEEK_STATUS_CELL": "//xpath1",
    "FIXEDSHIFTSPAGE_SUBMIT_BUTTON": "//xpath2"
  },
  "hr": {
    "REQUEST_CALENDAR_DATE_PICKER": "//xpath3",
    "TIMEOFF_SUBMIT_BUTTON": "//xpath4"
  },
  "planning": {
    "WORKLOAD_TABLE_ROW": "//xpath5"
  }
}
```

### 3. Document Locator Differences (optional)

Add comments in your locators.json to explain why certain environments need different locators:

```json
{
  "_comment": "QA28_V3 uses different DOM structure due to UI framework upgrade",
  "schedule": {
    "ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX": "//div[@id='scheduleContainer']//tbody[@id='weekTableBody']/tr/td[{CELL_INDEX}]"
  }
}
```

### 4. Test Locator Loading

You can verify which locators are being loaded:

```robotframework
*** Settings ***
Library    resources/web/common/LocatorLibrary.py

*** Test Cases ***
Debug Locator Loading
    ${env}=    Get Current Environment Name
    Log    Current environment: ${env}
    ${locator}=    Get Environment Locator    schedule    ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX
    Log    Using locator: ${locator}
```

## Troubleshooting

### Issue: Locator Not Found

**Problem:** Warning message: "Locator module.page.LOCATOR_NAME not found in environment ENV_NAME"

**Solution:** 
1. Check that `locators.json` exists in the environment directory
2. Verify the JSON structure matches the expected hierarchy
3. Ensure the locator name is spelled correctly
4. Check that the environment variable `TEST_ENVIRONMENT` is set correctly

### Issue: JSON Parse Error

**Problem:** Error loading locators file due to invalid JSON

**Solution:**
1. Validate your JSON syntax using a JSON validator
2. Check for trailing commas, missing quotes, or other syntax errors
3. Ensure file encoding is UTF-8

### Issue: Locator Manager Not Initialized

**Problem:** AttributeError or initialization errors

**Solution:**
1. Ensure the environment directory exists under `test_data/environments/`
2. Check that `TEST_ENVIRONMENT` environment variable is set
3. Verify file permissions allow reading the locators.json file

## Migration Checklist

- [ ] Create `locators.json` files for each environment
- [ ] Update `*_page.py` files to use `get_environment_locator()`
- [ ] Add `LocatorLibrary` import to resource files if needed
- [ ] Test with multiple environments to verify correct locator loading
- [ ] Document any environment-specific locator differences
- [ ] Update team documentation and training materials

