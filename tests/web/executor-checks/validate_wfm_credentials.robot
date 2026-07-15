*** Settings ***
Documentation       Test case to verify if all users defined in credentials file have valid WFM access.
...                 This is an example of how to use the CSVLibrary for data-driven testing.

Resource            resources/web/authentication/login.resource
Library             resources.common.library.CSVLibrary
Library             DataDriver    dialect=excel    encoding=utf_8    config_keyword=Generate User List CSV File From Env And Return Config

# Suite Setup    Create Test Data Directory
Suite Teardown      Cleanup Test Data Directory


*** Test Cases ***
Verifying WFM User Credentials Are Valid For ${user_key}
    [Documentation]    Template test case for validating WFM credentials for each user.
    ...    Uses DataDriver to iterate through CSV data.
    [Template]    Verify WFM User Credentials Are Valid
    # This template will be populated by DataDriver from the CSV file


*** Keywords ***
Create Test Data Directory
    [Documentation]    Create temporary test data directory for this suite.
    ${test_dir}=    Normalize Path    ${EXECDIR}/exec_checks_data
    Create Directory    ${test_dir}
    VAR    ${TEST_DATA_DIR}=    ${test_dir}    scope=SUITE
    Log    Test data directory: ${test_dir}

Cleanup Test Data Directory
    [Documentation]    Remove test data directory after suite execution.
    Run Keyword And Ignore Error    Remove Directory    ${TEST_DATA_DIR}    recursive=True

Generate User List CSV File From Env And Return Config
    [Documentation]    Generates a CSV file with user credentials from the environment-specific credentials file.
    ...    This keyword is used by DataDriver to create test data for validating WFM credentials.
    [Arguments]    ${original_config}
    Log    Original DataDriver config: ${original_config}
    Create Test Data Directory
    ${users}=    Get Available Users
    VAR    ${csv_file}=    ${TEST_DATA_DIR}/availableUsersInEnv.csv
    ${row_count}=    Write Single Column CSV
    ...    ${csv_file}
    ...    ${users}
    ...    header=\${user_key}
    Log    Wrote ${row_count} users to ${csv_file}
    VAR    &{new_config}=    file=${csv_file}
    RETURN    ${new_config}

Verify WFM User Credentials Are Valid
    [Documentation]    Template keyword that attempts to log in with provided user credentials
    ...    and verifies access to WFM application.
    ...    This keyword is used as a template for data-driven testing.
    [Arguments]    ${user_key}
    Login And Launch WFM Web App    user_key=${user_key}
    Verify Successful Login To WFM Application
    Capture Screenshot On Webpage
    Close Browser
    Log    User ${user_key} credentials would be validated here
