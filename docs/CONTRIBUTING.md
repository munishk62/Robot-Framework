# WFM Test Automation contributing guide

Before you can contribute to the WFM Test Automation project, please follow these guidelines to ensure a smooth development process. We also assume you are aware of Robot Framework. Refer to the [Robot Framework User Guide](https://docs.robotframework.org/docs) for more information.

## Core design principles for effective test cases

1. **Simplicity**: Keep test cases simple and focused on a single functionality or feature.
2. **Readability**: Write test cases that are easy to read and understand. Create higher level keywords that describe the user action rather than technical implementation details. This makes it easier for non-technical stakeholders to understand the tests.
3. **Embrace the Page Object Model (POM)**: Organize test cases around the application’s UI structure. This helps in maintaining and reusing code effectively.
4. **Reusability**: Create reusable keywords and libraries to avoid duplication and promote maintainability.
5. Maintain clear and consistent naming conventions for test cases, keywords, and variables to enhance readability and maintainability. Test case names should be descriptive and state the expected outcome. e.g Valid Use Can Login, Invalid User Cannot Login, etc.Keywords names should clearly describe the action they perform, e.g. `Open Login Page`, `Verify error message is displayed`, etc.
6. Externalize test data to separate it from the test logic. This allows for easier updates and modifications without changing the test code.
7. Leverge Setup and Teardown methods to prepare the test environment and clean up after tests. This ensures that each test runs in a consistent state. 
8. Utilize tags for categorizing and selectively running your tests. E.g. `smoke`, `critical` `variation1`, etc.

## Getting Started

1. Clone the repository.
2. Install precommit hooks to automatically run linting and formatting checks on your Robot Framework files. See [Pre-commit Hooks Setup Guide](PRECOMMIT_SETUP.md) for instructions.
3. Create a new branch, ensure the name follows this standard pattern - ^(feature|bugfix|release|executor)(_|-)[a-zA-Z0-9]+[a-zA-Z0-9._-]*$. So feature-wfm-123, feature_schedule_sanity, bugfix_wfm-21, release_v45.1.22, executor_cvs_config, etc are valid.
4. Ensure every commit message is prefixed with a JIRA-ID. e.g. "WFM-123 : A commit message"

## Adding Robot Framework Test Cases

### File Structure

When adding new test cases, follow the existing file structure:
- filenames are in lowercase and use underscores to separate words
- directories are in lowercase and use underscores to separate words
- keep the directory structure as flat as possible to avoid deep nesting
- avoid repeatition of words in filenames and directories. e.g. if you are in the `ess` directory, you don't need to repeat `ess` in the filename or directory name.
- for locator files, use the format `pageName_page.py` where `pageName` is the name of the screen being tested. This helps in following the Page Object Model (POM) design pattern.
- for Robot Python libraries, use the format `*Library.py` and keep keyword implementation reusable and module-focused.
- in `*_page.py` locator files, locator variables must be declared in `ALL_CAPS` for consistency.

### Environment-Specific Locators (New Feature)
The framework now supports environment-specific UI locators to handle variations in DOM structure between environments. See [Environment-Specific Locators Guide](ENVIRONMENT_SPECIFIC_LOCATORS.md) for detailed usage instructions. Key points:

- Locators are defined in `test_data/environments/{ENV_NAME}/locators.json`
- Page object files use `get_environment_locator()` function for dynamic loading
- Fallback defaults ensure tests work even without environment-specific locators
- Same variable names across all environments for consistent test code

```
wfm-automation/
├── resources/ # Reusable keywords are stored in .resource files in the resources folder. These are organized by feature or module. 
│   ├── web/   # web specific keywords are stored here.
│   │   ├── common
│   │   ├── hr # HR is a module related reusable keywords
│   │   |   ├── request_calendar.resource   # reusable keywords for request calendar
│   │   |   ├── request_calendar_db.resource   # reusable keywords for request calendar db queries related keywords!  
│   │   |   └── request_calendar_page.py # locator file for the request calendar. Following the page object model
│   │   |   └── request_calendar_api.py # Any api urls / regex for urls used in the request calendar
├── tests/   # the Test Suites can be organized in multiple .robot files and subfolders
│   ├── web/  # web specific test suites are stored here.
│   │   ├── l2_suite/
│   │   │   ├── wfm123_schedule_workflow.robot # test suites can be grouped by functionality
│   │   ├── hr/
│   │   │   ├── request_calendar_day_off.robot # test suites can be grouped by functionality
├── test_data/  # test data in form of data provider templates go here.
│   ├── entities/ # All data provider templates related to entities like day_off, schedule, shifts, timecard, payroll etc. go here
│   ├── environments/ # All environment specific data like config, constants, jenkins file etc. go here in respective environment folders
├── docs/ # documentation related to contribution guidelines, architecture, code review checklist, test data provider guide etc. go here.
├── executor.py  # The main script to run the tests
```

```NOTE
Use of ***_db.resource is an exception because WST does not have API for all the data we need for test validation, 
so we have to directly query the db for some of the validations. Should be kept minimal.
```
### Style Guide

All Robot Framework code must follow the [official Robot Framework style guide](https://docs.robotframework.org/docs/style_guide). Key points include:

- Variable casing - ref : https://docs.robotframework.org/docs/style_guide#variable-scope-and-casing
- Use 4 spaces for indentation
- Use space-separated format for settings, variables, and keywords
- Use clear, descriptive names for test cases and keywords
- Group related test cases and keywords logically
- Include documentation for test suites, test cases, and keywords
- Maintain a consistent capitalization style

Example:

```robotframework
*** Settings ***
Documentation     Example test suite
Resource          resources/keywords/common_keywords.robot

*** Variables ***
${EXAMPLE_VAR}    example value

*** Test Cases ***
Valid Login
    [Documentation]    Tests that a user can login with valid credentials
    Open Login Page
    Input Username    valid_user
    Input Password    valid_pass
    Submit Credentials
    Login Should Succeed

*** Keywords ***
Login Should Succeed
    [Documentation]    Verifies that login was successful
    Page Should Contain Element    id:welcome-message
```

## Code Quality

### Static Code Analysis with Robocop

We use Robocop for static code analysis of Robot Framework code. Before submitting your PR, run:

```bash
uv run robocop check --reports all .
```

Fix any issues reported by Robocop before submitting your changes.

### Code Formatting

Use the Robocop formatter to ensure consistent code formatting:

```bash
uv run robocop format path/to/your/files.robot
```

## Test Execution Setup

Once you check out the repo go to directory where repo is checked and follow below steps.
- Install Python 3.13+ refer -> https://www.python.org/downloads/
- Install UV  refer -> https://docs.astral.sh/uv/getting-started/installation/#pypi
  ```bash
  pip install uv
  ```
- Create virtual environment & install dependencies
  ```
  uv sync
  ```  
- Activate the virtual environment. UV creates a virtual environment named `.venv` in the root of the repo.
  ```bash
  # On Windows:
  .venv\Scripts\activate
  # On Unix/Mac:
  # source .venv/bin/activate
  ```
- **SWS Bundle Setup**
The framework depends on SWS Bundle for some of its feature. So we need to install the same. 
Run below commands to install the SWS bundle.
  ```
  cd SWS_RF_Bundle_uv_jenkins
  uv run python install_bundle.py
  ```

Once the installation is done "Bundle Installed Successfully!" message will be seen in the console
if there are any permission issue from uv, try running the command using admin privilege.

```Troubleshooting
If you see a 'UnicodeEncodeError: 'charmap' codec can't encode characters in position' issue on windows. Do as below
Open a fresh Command Prompt, run 'chcp 65001' followed by set PYTHONUTF8=1 and set PYTHONIOENCODING=utf-8, then re-run steps from "Activate the virtual environment" uv run python install_bundle.py from this new cmd; rfbrowser will inherit UTF-8 settings and complete clean-node.
```

## Running Tests

### Setting up Environment Variable
- Certain information like user credentials, site token (wfm api calls need it), db credentials are stored in env variable and referred by the framework.
- We now used scoped environment so that we can have multiple env files corresponding to differen environments and easily switch, So create .env_scoped folder in root of repo if it does not exist already
- Replace .env_example with env_{ENV_NAME_UNDER_TEST}.env and place it in .env_scoped folder
- Ensure  `USER_CREDENTIALS`, `DB2_CONNECTION`,`SITE_TOKEN`  variable are updated with details from the env
- Note the keys in the `USER_CREDENTIALS` variable should match the keys used in your robot test for "Get User    user_key={someUserKey}".

### Ensure Test Data is Set Up
- We follow Test data provider strategy for setting test data. Here is a (simplified guide)[SIMPLIFIED_DATA_PROVIDER_GUIDE.md] on how to add it.
- Identify the environment name - e.g. QA28_B0 
- Environment specific config & logical constants are stored in `test_data/environments/{ENV_NAME}/config.json` & `test_data/environments/{ENV_NAME}/constants.json`.

### Running Tests with Robot Framework
We have a python script `executor.py` that allows you to run Robot Framework tests with various options.

Health checks now run as a standalone step before `executor.py` starts test execution:
- Application reachability check using configured `base_url`
- DB2 connectivity and queue checks using `DB2_CONNECTION`

Use `python -m dev_utils.run_health_check` for this gate, for example:
- `--test-env <ENV>` to select the environment
- `--timeout <seconds>` to tune timeout (default: `10`)
- `--skip-database` to bypass DB2 and queue checks temporarily

For complete details, examples, and troubleshooting, see [Pre-Execution Health Checks](PRE_EXECUTION_HEALTH_CHECKS.md).

```bash
usage: executor.py [-h] [--test-env TEST_ENV] [--include-tags INCLUDE_TAGS] [--exclude-tags EXCLUDE_TAGS] [--results-dir RESULTS_DIR] [--global-data-file-name GLOBAL_DATA_FILE_NAME]
                   [--dry-run] [--log-level {TRACE,DEBUG,INFO,WARN,NONE}] [--log-file LOG_FILE] [--show-browser] [--processes PROCESSES]
                   [extra_robot_args]
                   test_files_path [test_files_path ...]

Run Robot Framework tests.

positional arguments:
  test_files_path       List of robot test files or directories to execute.

options:
  -h, --help            show this help message and exit
  --test-env TEST_ENV   The environment name (one word) to run the tests against. Please ensure the directory with same name exists under test_data/environments/.
  --include-tags INCLUDE_TAGS
                        Only run tests with these tags (comma-separated).
  --exclude-tags EXCLUDE_TAGS
                        Exclude tests with these tags (comma-separated).
  --results-dir RESULTS_DIR
                        Directory to store test results.
  --global-data-file-name GLOBAL_DATA_FILE_NAME
                        A global data file name to be used across all tests. This should be a Python file without the .py extension. It should be located in
                        test_data/environments/{TEST_ENV}/ and contain variables to be used in the tests.
  --dry-run             Perform a dry run without executing the tests.
  --log-level {TRACE,DEBUG,INFO,WARN,NONE}
                        Set the logging level. Available levels: TRACE, DEBUG, INFO (default), WARN, NONE.
  --log-file LOG_FILE   File to write logs to.
  --show-browser        Show browser UI (headed mode). Omit for headless execution (default).
  --browser {"chrome", "firefox", "edge", "safari"}
                        Specify the browser to use for tests. Options are: chrome, firefox, edge, safari. Default is chrome. Ths may need installation of respective browser drivers.Check https://robotframework-browser.org/#installation
  --processes PROCESSES
                        Number of parallel processes to use for test execution.
  --validate-user-keys   Skip tests that reference user keys missing from USER_CREDENTIALS env variable.
  extra_robot_args     Any robot framework specific arguments to pass to the test execution. e.g. --variable PAGE_LOAD_TIMEOUT:100s --variable HEADLESS:True
```


```bash
# Using UV
# E.g. To run tests in the `tests/web/` directory with a specific data file and environment:
uv run python executor.py tests/web/ --test-env QA28_B0 
# E.g. To run tests in the `tests/web/` directory with a specific include tags, result dir and environment:
uv run python executor.py tests/web/ --test-env QA28_B0  --include-tags tag1,tag2 --results-dir results_qa28
# E.g. To run tests in the `tests/web/` directory with a specific include tags, result dir, environment and extra robot arguments:
uv run python executor.py tests/web/ --test-env QA28 --include-tags data_provider_dayoff --variable PAGE_LOAD_TIMEOUT:100s --variable HEADLESS:True
# E.g. To ensure tests referencing undefined user keys are skipped during execution:
uv run python executor.py tests/web/ --test-env QA28_B0 --validate-user-keys
```

### Overridable Global Arguments  
We have some global static arguments used by keywords & test with default values. These can be overridden by passing them as extra_robot_args in test execution

|Argument|Description|Default Value|Defined In|
|--------|-----------|--------------|-----------|
|PAGE_LOAD_TIMEOUT|Timeout for page loads|90s|web\resources\common\timeout_variables.py|
|LONG_TIMEOUT|Timeout for long operations|30s|web\resources\common\timeout_variables.py|
|MEDIUM_TIMEOUT|Timeout for medium operations|10s|web\resources\common\timeout_variables.py|
|SHORT_TIMEOUT|Timeout for short operations|5s|web\resources\common\timeout_variables.py|
|HEADLESS|Run browser in headless mode|False|web\resources\authentication\login.resource|


## Pull Request Process
Once you are done with changes and ready to push to main, create a pull request. Follow the below process for same.

1. Ensure all tests pass locally
2. Run Robocop checks, dry-run and fix any issues before raising PR.
3. Update documentation if necessary
4. Perform self code review based on these [guidelines](SELF_CODE_REVIEW_CHECKLIST.md)
5. Create a pull request with a clear description of the changes. Include JIRA ID as prefix in the name of PR. e.g. "WFM-XXX Test for abc"
6. In case of single PR for multiple tickets, please add all JIRA tickets numbers separated by comma.
7. Fill PR template
8. Attach robot execution logs (NOT REPORT). Reviewer should be able to view all step executions. 


## Code Review

All submissions require review. We use GitHub pull requests for this purpose. Ensure PR process described above is followed.
This PR will go through a multi-stage review process:
Review Stages:
    Peer Review 📝 - Requires approval from peer review group
    Architect Review 🏗️ - Requires approval from architect group
    Ready to Merge ✅ - Only architects can merge

The PR's are labelled as per stages described above.

## Additional Resources

- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [Robot Framework Style Guide](https://docs.robotframework.org/docs/style_guide)
- [Robocop Documentation](https://robocop.readthedocs.io/)
