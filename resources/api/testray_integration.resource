*** Settings ***
Documentation       TestRay Integration Utility - Updates test case execution results in TestRay
...                 This utility executes at the end of each test case to mark status as Passed/Failed

Library             Collections
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Resource            resources/api/api_executor.resource
Variables           resources/api/api_endpoints.py
Resource            resources/web/common/common_date_utility.resource


*** Variables ***
# Dynamic Variables (populated during execution)
${BEARER_TOKEN}     ${EMPTY}


*** Keywords ***
Update TestRay Result
    [Documentation]
    ...    Main keyword to update test case result in TestRay. Orchestrates all API calls in sequence.
    ...    | =Arguments= | =Description= |
    ...    | bearer_token | TestRay API bearer token for authentication. |
    ...    | test_plan_id | TestRay test plan ID. |
    ...    | test_case_tag | Test case tag (e.g., BATTC00008). |
    ...    | test_result | Test result status (Passed/Skip/Failed). |
    ...    | screenshot_path | (Optional) Path to screenshot file for attachment. |
    ...    Example usage:
    ...    | Update TestRay Result    ${bearer_token}    12345    BATTC00008    Passed    results/screenshot.png
    [Arguments]    ${bearer_token}
    ...    ${test_plan_id}
    ...    ${test_case_tag}
    ...    ${test_result}
    ...    ${screenshot_path}=${EMPTY}
    ...    ${error_comment}=${EMPTY}
    VAR    ${BEARER_TOKEN}    ${bearer_token}    scope=SUITE
    Log    Starting TestRay result update for test case: ${test_case_tag}    level=INFO
    ${cycle_name}    Get Variable Value    \${TESTRAY_CYCLE}    ${EMPTY}
    IF    '${cycle_name}' == '${EMPTY}'
        Log    No custom Test Cycle applied in executor command; proceeding with default cycle from API.    level=INFO
        ${client}    Get Config Value    CLIENT
        ${normalized_client}    Replace String    ${client}    _    ${SPACE}
        # Get test cycles and find matching cycle
        ${cycle_name}    Get Test Cycle    ${test_plan_id}    ${normalized_client}
    END
    # Get test case ID of the test case
    IF    '${cycle_name}' != '${EMPTY}'
        ${test_case_key}    Get Test Case Key By Tag    ${test_case_tag}
    ELSE
        Log    ⚠️ Skipping test case key retrieval as no matching cycle found for plan ${test_plan_id} and client ${normalized_client}.
        ...    level=WARN
        RETURN
    END
    # Update test run status
    IF    '${test_case_key}' != '${EMPTY}'
        ${test_run_id}    Update Test Case Status    ${test_plan_id}    ${cycle_name}    ${test_case_key}    ${test_result}
        ...    ${error_comment}
    ELSE
        Log    ⚠️ No matching TestRay test cycle found for plan ${test_plan_id} and client ${normalized_client}. Skipping status update.
        ...    level=WARN
        VAR    ${test_run_id}    ${EMPTY}
    END
    IF    '${test_run_id}' != '${EMPTY}'
        Log    ✅ Successfully updated TestRay result for ${test_case_tag}: ${test_result}    level=INFO
        # Attach screenshot if available
        IF    '${screenshot_path}' != '${EMPTY}'
            Attach Screenshot To Test Run    ${test_run_id}    ${screenshot_path}
        END
    ELSE
        Log    ❌ Failed to update TestRay result for ${test_case_tag}    level=WARN
    END

Get Test Cycle
    [Documentation]
    ...    Retrieves test cycles for a test plan and finds the latest one matching the filter. Returns the cycle name.
    ...    | =Arguments= | =Description= |
    ...    | test_plan_id | TestRay test plan ID. |
    ...    | client_filter | Cycle name filter string to match against. |
    ...    Example usage:
    ...    | ${cycle_name}    Get Test Cycle    12345    QA28 B0
    [Arguments]    ${test_plan_id}    ${client_filter}
    ${parsed_endpoint}    Replace String    ${TESTRAY_TEST_CYCLE_URL}    {0}    ${test_plan_id}
    VAR    ${endpoint}    ${TESTRAY_TEST_PLAN_URL}${parsed_endpoint}
    VAR    &{headers}
    ...    Authorization=Bearer ${BEARER_TOKEN}
    ...    Accept=application/json
    Log    Fetching test cycles for test plan: ${test_plan_id}    level=INFO
    ${response}    GET    ${endpoint}    headers=${headers}    expected_status=200
    VAR    ${cycles}    ${response.json()}
    VAR    @{cycle_names}    @{EMPTY}
    FOR    ${cycle}    IN    @{cycles}
        ${cycle_name}    Get From Dictionary    ${cycle}    cycleName
        ${contains_filter}    Run Keyword And Return Status    Should Contain    ${cycle_name}    ${client_filter}
        IF    ${contains_filter}
            Append To List    ${cycle_names}    ${cycle_name}
            Log    Found matching cycle: ${cycle_name}    level=INFO
        END
    END
    # Return the latest matching cycle
    ${count}    Get Length    ${cycle_names}
    IF    ${count} > 0
        ${last_index}    Evaluate    ${count} - 1
        ${latest_cycle}    Get From List    ${cycle_names}    ${last_index}
        RETURN    ${latest_cycle}
    ELSE
        Log    No test cycle found matching filter: ${client_filter}
        RETURN    ${EMPTY}
    END

Get Test Case Key By Tag
    [Documentation]
    ...    Searches for test case in JIRA using JQL query and returns the issue key (e.g., WFM-99857).
    ...    | =Arguments= | =Description= |
    ...    | test_tag | Test case tag to search for. |
    ...    Example usage:
    ...    | ${test_case_key}    Search Test Case By Tag    battc00008
    [Arguments]    ${test_tag}
    VAR    ${jql}    project = "Workforce Management" and "Test Case ID" ~ "${test_tag}" ORDER BY key DESC
    VAR    &{request_body}
    ...    jql=${jql}
    ...    startAt=${0}
    ...    maxResults=1
    VAR    &{headers}
    ...    Authorization=Bearer ${BEARER_TOKEN}
    ...    Content-Type=application/json
    Log    Searching for test case: ${test_tag}    level=INFO
    ${response}    POST    ${TESTRAY_TEST_ID_URL}    json=${request_body}    headers=${headers}    expected_status=200
    VAR    ${json_response}    ${response.json()}
    ${total}    Get From Dictionary    ${json_response}    total
    IF    '${total}' == '0'
        Log    No test case found with tag: ${test_tag}    level=WARN
        RETURN    ${EMPTY}
    END
    ${issues}    Get From Dictionary    ${json_response}    issues
    ${first_issue}    Get From List    ${issues}    0
    ${test_case_key}    Get From Dictionary    ${first_issue}    key
    Log    Found issue key: ${test_case_key}    level=INFO
    RETURN    ${test_case_key}

Update Test Case Status
    [Documentation]
    ...    Updates the test run status in TestRay and returns the test run ID.
    ...    | =Arguments= | =Description= |
    ...    | test_plan_id | TestRay test plan ID. |
    ...    | cycle_name | Name of the test cycle. |
    ...    | test_case_key | Test case key (e.g., WFM-99857). |
    ...    | result | Test result status (Passed/Skip/Failed). |
    ...    Example usage:
    ...    | ${test_run_id}    Update Test Run Status    12345    QA28 B0 Cycle 1    WFM-99857    Passed
    [Arguments]    ${test_plan_id}    ${cycle_name}    ${test_case_key}    ${result}    ${error_comment}
    ${updated_endpoint}    Replace String    ${TESTRAY_TEST_RUN_UPDATE_URL}    {0}    ${test_plan_id}
    ${parsed_endpoint}    Replace String    ${updated_endpoint}    {1}    ${cycle_name}
    VAR    ${endpoint}    ${TESTRAY_TEST_PLAN_URL}${parsed_endpoint}
    ${timestamp_format}    Get Config Value    DATE_FORMAT_MMDDYYYY_12HR_TIME
    ${timestamp}    Get Current Date    result_format=${timestamp_format}
    ${comment_length}    Get Length    ${error_comment}
    IF    ${comment_length} > 2
        VAR    ${comment}    ${error_comment} : Updated through Automation APIs on ${timestamp}
    ELSE
        VAR    ${comment}    Updated through Automation APIs on ${timestamp}
    END
    VAR    &{request_body}
    ...    testcaseKey=${test_case_key}
    ...    result=${result}
    ...    comment=${comment}
    VAR    &{headers}
    ...    Authorization=Bearer ${BEARER_TOKEN}
    ...    Content-Type=application/json
    Log    Updating test run status to: ${result} for test case: ${test_case_key}    level=INFO
    ${response}    POST    ${endpoint}    json=${request_body}    headers=${headers}    expected_status=200
    VAR    ${json_response}    ${response.json()}
    ${test_run_id}    Get From Dictionary    ${json_response}    testRunId
    Log    Test run updated successfully. Test Run ID: ${test_run_id}    level=INFO
    RETURN    ${test_run_id}

Attach Screenshot To Test Run
    [Documentation]
    ...    Attaches screenshot to the test run if file exists. Logs warning if file is not found.
    ...    | =Arguments= | =Description= |
    ...    | test_run_id | TestRay test run ID. |
    ...    | screenshot_path | Path to screenshot file. |
    ...    Example usage:
    ...    | Attach Screenshot To Test Run    2148847    results/screenshot.png
    [Arguments]    ${test_run_id}    ${screenshot_path}
    ${file_exists}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${screenshot_path}
    IF    not ${file_exists}
        Log    Screenshot file not found: ${screenshot_path}. Skipping attachment.    level=WARN
        RETURN
    END
    ${endpoint}    Replace String    ${TESTRAY_TEST_ATTACHMENT_URL}    {0}    ${test_run_id}
    ${file_stream}    Get File For Streaming Upload    ${screenshot_path}
    VAR    &{files}    file=${file_stream}
    VAR    &{headers}    Authorization=Bearer ${BEARER_TOKEN}    Accept=application/json
    Log    Attaching screenshot: ${screenshot_path}    level=INFO
    ${response}    POST    ${endpoint}    files=${files}    headers=${headers}    expected_status=200
    VAR    ${json_response}    ${response.json()}
    ${message}    Get From Dictionary    ${json_response}    message
    ${success}    Run Keyword And Return Status    Should Be Equal As Strings    ${message}    Success
    IF    not ${success}
        Log    Screenshot attachment failed for test run: ${test_run_id}    level=WARN
    ELSE
        Log    Screenshot attached successfully to test run: ${test_run_id}    level=INFO
    END
    Remove File    path=${screenshot_path}

Get TestRay Result From Test Execution Status
    [Documentation]
    ...    Maps Robot Framework test status to TestRay result string (Passed/Skip/Failed).
    ...    Suite Setup failures are treated as Skipped in TestRay to differentiate from actual test failures.
    VAR    ${execution_status}    ${TEST STATUS}
    VAR    ${message}    ${TEST MESSAGE}
    ${lower_msg}    Convert To Lowercase    ${message}
    ${is_suite_setup_failure}    Run Keyword And Return Status
    ...    Should Contain    ${lower_msg}    suite setup failed
    IF    ${is_suite_setup_failure} or '${execution_status}' == 'SKIP'
        VAR    ${result}    Skip
    ELSE IF    '${execution_status}' == 'PASS'
        VAR    ${result}    Passed
    ELSE
        VAR    ${result}    Failed
    END
    RETURN    ${result}

Get TestRay Result Error Message From Test Execution
    [Documentation]
    ...    Retrieves error message from the current test case if it failed.
    IF    '${TEST STATUS}' == 'FAIL'    RETURN    ${TEST MESSAGE}
    RETURN    ${EMPTY}

Get Tag From Current Test
    [Documentation]
    ...    Retrieves the BATTC tag from the current test case tags.
    FOR    ${tag}    IN    @{TEST TAGS}
        ${is_battc}    Run Keyword And Return Status    Should Match Regexp    ${tag}    (?i)^battc\\d+
        IF    ${is_battc}    RETURN    ${tag}
    END
    Log    Test tag not found; skipping TestRay update.    level=WARN
    RETURN    ${EMPTY}

Publish Test Status To TestRay
    [Documentation]    Wrapper keyword to update TestRay result for the current test case.
    ...    Main entry point keyword for publishing the current test case result to TestRay.
    ...    Typically called from Test Teardown / Suite Teardown so that the final Robot
    ...    Framework status (PASS/FAIL/SKIP) is sent to TestRay for the matching BATTC tag.
    ...    Prerequisites:
    ...    - Environment variable BEARER_TOKEN must be set with a valid TestRay API token.
    ...    - TestRay Plan ID must be available to run executor command with --testray-plan.
    ...    If any prerequisites are missing or no BATTC tag is found on the test, this
    ...    keyword safely logs the reason and skips the TestRay update without failing tests.
    ...    | =Arguments= | =Description= |
    ...    | user_bearer_token | (Optional) TestRay API bearer token. If not provided, reads from BEARER_TOKEN env variable. |
    ...    Example usage:
    ...    | Publish Test Status To TestRay    ${BEARER_TOKEN} |
    [Arguments]    ${user_bearer_token}=${EMPTY}
    IF    '${user_bearer_token}' != '${EMPTY}'
        VAR    ${BEARER_TOKEN}    ${user_bearer_token}
    ELSE
        ${BEARER_TOKEN}    Get Environment Variable    BEARER_TOKEN    ${EMPTY}
    END
    ${test_plan_id}    Get Variable Value    \${TESTRAY_PLAN}    ${EMPTY}
    IF    '${BEARER_TOKEN}' == '${EMPTY}' or '${test_plan_id}' == '${EMPTY}'
        Log    Missing TestRay config (token/plan id); skipping update.    level=INFO
        RETURN
    END
    ${test_case_tag}    Get Tag From Current Test
    IF    '${test_case_tag}' == '${EMPTY}'
        Log    No BATTC tag found in Test Tags, skipping TestRay update.    level=WARN
        RETURN
    END
    ${test_result}    Get TestRay Result From Test Execution Status
    IF    '${test_result}' == 'Failed'
        ${error_comment}    Get TestRay Result Error Message From Test Execution
        ${screenshot_path}    Capture And Return Full Screenshot File Path
        Update TestRay Result    ${BEARER_TOKEN}    ${test_plan_id}    ${test_case_tag}    ${test_result}    ${screenshot_path}
        ...    ${error_comment}
    ELSE IF    '${test_result}' == 'Skip'
        ${error_comment}    Get TestRay Result Error Message From Test Execution
        Update TestRay Result    ${BEARER_TOKEN}    ${test_plan_id}    ${test_case_tag}    ${test_result}    error_comment=${error_comment}
    ELSE
        Update TestRay Result    ${BEARER_TOKEN}    ${test_plan_id}    ${test_case_tag}    ${test_result}
    END
