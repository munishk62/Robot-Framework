*** Settings ***
Documentation       Week 3 - SM1_STORE2 Schedule Suite
...                 **PURPOSE:**
...                 This suite consolidates all BATTC test cases that require Week 3 schedule data for STORE2.
...                 All tests in this suite use the same week setup, enabling efficient parallel execution.
...
...                 **ONE-TIME SETUP APPROACH:**
...                 Suite Setup executes 'Setup Schedule For Week 3' wrapped with 'Run Only Once' from pabot.PabotLib.
...                 This ensures schedule setup runs exactly ONCE across all parallel processes before any tests execute.
...
...                 **PARALLEL EXECUTION ENABLED:**
...                 Tests can be executed in parallel using pabot. The setup runs once, then all tests execute concurrently.
...
...                 **TEST CASES INCLUDED:**
...                 - BATTC00137: Week 3, Day 0 - Schedule Generated and Unpublished for SM1_STORE2
...
...                 **EXECUTION COMMANDS:**
...
...                 Sequential execution:
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week3_sm1store2_schedule_suite.robot --test-env QA28_B0
...
...                 Parallel execution (recommended, 7 processes):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week3_sm1store2_schedule_suite.robot --test-env QA28_B0 --processes 7
...
...                 With browser visible (for debugging):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week3_sm1store2_schedule_suite.robot --test-env QA28_B0 --show-browser
...
...                 **LOCK FILE CLEANUP:**
...                 If setup appears to be skipped, clean pabot lock files before running:
...                 Remove-Item -Path ".pabot_results" -Recurse -Force -ErrorAction SilentlyContinue

Library             pabot.PabotLib
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/organization/organization_distribution_list.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource

Suite Setup         Run Keywords    Run Keyword And Continue On Failure    Create Distribution List For Store2    AND
...                     Run Only Once    Pre Setup Schedule For Week 3 SM1Store2
Suite Teardown      Log    Week 3 SM1_STORE2 Suite Complete - All tests executed    level=INFO
Test Teardown       Close Browser

Test Tags           week3_sm1store2    dev:moiz    action:write    schedule_dependent


*** Test Cases ***
BATTC00137: Verify user is able to publish schedule by running the servlet for distribution list
    [Documentation]    User is able to publish schedule by servlet for distribution list.
    [Tags]    battc00137    bat_phase2    config:rws    config:weekplan_and_schedule_gen    checkschedulesetup
    ${is_auto_publish_applicable}    Verify Auto Publish Schedule Job Has Expected Queue Status In Database
    IF    not ${is_auto_publish_applicable}
        Skip    Auto Publish Schedule Job is not in expected queue status in database. Skipping servlet execution and related validations.
    END
    Login And Launch WFM Web App    user_key=SM1_STORE2
    ${schedule_data}    Get Schedule Generation Setup Data    template_name=3_0_sm1_store2
    ${store_data}    Get Store Data    template_name=model_store2
    ${distribution_list_data}    Get Distribution List Data
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Request Calendar Page On Web    ${schedule_data}[week_start_date]
    ${unpublished}    Check If Schedule Generated And In Unpublished State On Web
    IF    not ${unpublished}
        Skip    Schedule is not in Unpublished state before running servlet. Please check schedule setup execution for week 3.
    END
    Publish Week Schedule With Store Distribution Using Servlet On Web    ${schedule_data}[store_manager_user_key]
    ...    ${schedule_data}[week_start_date]    ${store_data}[store_id]${distribution_list_data}[name]
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Request Calendar Page On Web    ${schedule_data}[week_start_date]
    ${published}    Check If Schedule Is In Published State On Web
    Should Be True    ${published}    Schedule is not in Published state on Web after running servlet.


*** Keywords ***
Create Distribution List For Store2
    [Documentation]    Creates the distribution list for Store 2.
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Organization Distribution List Page On Web
    Verify RWS Distribution List Page Loaded On Web
    ${store_data}    Get Store Data    template_name=model_store2
    ${distribution_list_data}    Get Distribution List Data
    ${distribution_list_exists}    Check If Distribution List Exists On Distribution List Page On Web
    ...    ${store_data}[store_id]${distribution_list_data}[name]
    IF    not ${distribution_list_exists}
        ${dl_name}    ${dl_description}    Add New Distribution List From Distribution List Maintenance Page On Web    ${store_data}
        ...    ${distribution_list_data}
        Log    Distribution list added with name: ${dl_name} and description: ${dl_description}
        Add Unit Selection Criteria Based On Criterion Type On Web    ${distribution_list_data}[criterion_type]
        ...    ${distribution_list_data}[criterion]    ${store_data}[store_name]
        Log    Unit selection criteria added for distribution list: ${dl_name} with store: ${store_data}[store_name]
    END
    Close Browser
