*** Settings ***
Documentation       Week 1 - SM1_STORE1 Schedule Suite
...
...                 **PURPOSE:**
...                 This suite consolidates all BATTC test cases that require Week 1 schedule data for Store1.
...                 All tests in this suite use the same week setup, enabling efficient parallel execution.
...
...                 **ONE-TIME SETUP APPROACH:**
...                 Suite Setup executes 'Setup Schedule For Week template_name=1_0_sm1_store1' wrapped with 'Run Only Once' from pabot.PabotLib.
...                 This ensures schedule setup runs exactly ONCE across all parallel processes before any tests execute.
...
...                 **PARALLEL EXECUTION ENABLED:**
...                 Tests can be executed in parallel using pabot. The setup runs once, then all tests execute concurrently.
...
...                 **TEST CASES INCLUDED:**
...                 - BATTC00027: Week 1 - Day Schedule Operations (wfm_22_1_store_rws)
...
...                 **EXECUTION COMMANDS:**
...
...                 Sequential execution:
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week1_sm1store1_schedule_suite.robot --test-env QA28_B0
...
...                 Parallel execution (recommended, 2 processes):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week1_sm1store1_schedule_suite.robot --test-env QA28_B0 --processes 2
...
...                 With browser visible (for debugging):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week1_sm1store1_schedule_suite.robot --test-env QA28_B0 --show-browser
...
...                 **LOCK FILE CLEANUP:**
...                 If setup appears to be skipped, clean pabot lock files before running:
...                 Remove-Item -Path ".pabot_results" -Recurse -Force -ErrorAction SilentlyContinue

Library             pabot.PabotLib
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/rws/schedule/day_schedule.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/rws/schedule/plan_status.resource
Variables           test_data/localized_text/rws_localized_text.py

Suite Setup         Run Only Once    Pre Setup Schedule For Week 1 SM1Store1
Suite Teardown      Log    Week 1 SM1_STORE1 Suite Complete - All tests executed    level=INFO
Test Teardown       Close Browser

Test Tags           schedule_dependent


*** Test Cases ***
BATTC00027: Verify schedule operations on the daily schedule page, including add/edit/unallocate/undo and delete operations
    [Documentation]    Test case for verifying Add, Edit, Delete & Undo operations on Day Schedule page
    ...    Week: 1
    [Tags]    dev:ravi    action:write    battc00027    config:rws    bat_phase1    config:weekplan_and_schedule_gen    checkschedulesetup

    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${associate_data}    Get User    user_key=ESS1_STORE1
    VAR    ${associate_display_name}    ${associate_data}[displayName]
    ${shift_data}    Get Shift Data
    VAR    ${day_offset}    7

    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    1_1
    Navigate To Day Level Schedule From Week Schedule Page For The Given Day On Web    ${day_offset}
    Add Shift For The Given Associate On Day Schedule Page On Web    ${associate_display_name}    ${shift_data}[start_time]
    ...    ${shift_data}[end_time]
    Edit Shift For The Given Associate On Day Schedule Page On Web    ${associate_display_name}    ${shift_data}[edit_time]
    Perform Undo Operation On Day Schedule Page On Web
    Un-allocate Shift For The Given Associate On Day Schedule Page On Web    ${associate_display_name}
    Delete Shift For The Given Associate On Day Schedule Page On Web    ${shift_data}[start_time]
    ...    ${shift_data}[end_time]

BATTC00206: Verify manager is able to review employee alerts created from edits and their removal when resolved
    [Documentation]    Verify manager is able to review employee alerts created from edits and their removal when resolved
    ...    Test verifies:
    ...    1. Manager can add multiple shifts for an associate that violates max weekly hours
    ...    2. Employee alert is displayed when max hours exceeded
    ...    3. Alert is removed when shifts are unallocated/deleted
    ...    Week: Current Week + 1
    [Tags]    dev:azar    action:read    battc00206    bat_phase2    config:rws    config:weekplan_and_schedule_gen

    ${ess_user}    Get User    user_key=ESS6_STORE1
    ${alert_data}    Get Employee Alert Data
    ${date_format}    Get Config Value    SERVER_DF
    ${week_start_date_actual}    Calculate Date From Week Day Offset    ${alert_data}[week_start_date]    date_format=${date_format}
    Check Applicability For Employee Max Weekly Hours Alert Validation On Week Schedule Page On Web    ${ess_user}
    ...    ${week_start_date_actual}
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${alert_data}[week_start_date]
    Go To Schedule Page On Web
    Search Employee On Week Schedule Page On Web    ${ess_user}[displayName]
    FOR    ${shift}    IN    @{alert_data}[shifts_to_add]
        Add Shift On Week Schedule Page For The Given Associate And Day On Web
        ...    ${ess_user}[displayName]
        ...    ${shift}[day_offset]
        ...    ${shift}[start_time]
        ...    ${shift}[end_time]
    END
    Click On Associate On Week Schedule Page On Web    ${ess_user}[displayName]
    Click On Alert Tab For Selected Associate In Bottom Panel On Week Schedule Page On Web
    VAR    ${expected_alert_message}    ${LOCALISED_TEXT}[employee_alert_max_hours]
    Verify Employee Alert Is Displayed On Week Schedule Page On Web    ${expected_alert_message}
    FOR    ${shift}    IN    @{alert_data}[shifts_to_add]
        ${unallocate_dayoffset}    Evaluate    ${shift}[day_offset]+1
        Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web
        ...    ${ess_user}[displayName]
        ...    ${unallocate_dayoffset}
    END
    Click On Open Shifts Tab On Week Schedule Page On Web
    FOR    ${shift}    IN    @{alert_data}[shifts_to_add]
        Delete Open Shift On Week Schedule Page On Web
        ...    ${shift}[start_time]
        ...    ${shift}[end_time]
        ...    ${shift}[day_offset_with_week]
    END
    Click On Associate On Week Schedule Page On Web    ${ess_user}[displayName]
    Click On Alert Tab For Selected Associate In Bottom Panel On Week Schedule Page On Web
    Verify Employee Alert Is Not Displayed On Week Schedule Page On Web
