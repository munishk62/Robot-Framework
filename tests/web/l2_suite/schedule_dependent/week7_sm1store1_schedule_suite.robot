*** Settings ***
Documentation       Week 7 - SM1_STORE1 Schedule Suite
...
...                 **PURPOSE:**
...                 This suite consolidates all BATTC test cases that require Week 7 schedule data for Store1.
...                 All tests in this suite use the same week setup, enabling efficient parallel execution.
...
...                 **ONE-TIME SETUP APPROACH:**
...                 Suite Setup executes 'Setup Schedule For Week template_name=7_0_sm1_store1' wrapped with 'Run Only Once' from pabot.PabotLib.
...                 This ensures schedule setup runs exactly ONCE across all parallel processes before any tests execute.
...
...                 **PARALLEL EXECUTION ENABLED:**
...                 Tests can be executed in parallel using pabot. The setup runs once, then all tests execute concurrently.
...
...                 **TEST CASES INCLUDED:**
...                 - BATTC00028: Week 7 - Publish/Unpublish Toggle (wfm_23_1_store_rws)
...
...                 **EXECUTION COMMANDS:**
...
...                 Sequential execution:
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week7_sm1store1_schedule_suite.robot --test-env QA28_B0
...
...                 With browser visible (for debugging):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week7_sm1store1_schedule_suite.robot --test-env QA28_B0 --show-browser
...
...                 **LOCK FILE CLEANUP:**
...                 If setup appears to be skipped, clean pabot lock files before running by deleting the .pabot_results lock directory:
...                 - On Windows (PowerShell):
...                 Remove-Item -Path ".pabot_results" -Recurse -Force -ErrorAction SilentlyContinue
...                 - On Linux/Unix shells:
...                 rm -rf .pabot_results

Library             pabot.PabotLib
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/rws/schedule/plan_status.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource

Suite Setup         Run Only Once    Pre Setup Schedule For Week 7 SM1Store1
Suite Teardown      Log    Week 7 SM1_STORE1 Suite Complete - All tests executed    level=INFO
Test Teardown       Close Browser

Test Tags           week7_sm1store1    bat_phase1    schedule_dependent


*** Test Cases ***
BATTC00028: Verify publish and unpublish for weekly schedule
    [Documentation]
    ...    Validates week schedule publish/unpublish functionality:
    ...    1. Navigates to next week's schedule
    ...    2. Skips test if schedule is in plan status (railroad visible)
    ...    3. Unpublish schedule and verify shifts are editable
    ...    4. Publish schedule and check PC00098 configuration (EDIT_SC event in database)
    ...    5. If EDIT_SC event EXISTS: Verify shifts ARE editable (add shift option displayed, save button enabled)
    ...    6. If EDIT_SC event NOT exists: Verify shifts are NOT editable (add shift option not displayed, save button disabled)
    ...    7. Unpublish schedule again and verify shifts are editable
    ...    Week: 7
    [Tags]    dev:azar    action:write    battc00028    config:rws    config:weekplan_and_schedule_gen    checkschedulesetup
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    7_0
    Go To Schedule Page On Web
    ${is_in_plan_status}=    Check If Schedule Is In Plan Status With Rail Road On Web
    Skip If    ${is_in_plan_status}    msg=Schedule is in plan status and cannot be published/unpublished yet

    # Step 1-3: Unpublish schedule and verify shifts are editable
    Unpublish Schedule On Week Schedule Page On Web
    Verify Permit Add Edit Shift Operation On UnPublished Schedule On Week Schedule Page On Web

    # Step 4-6: Publish schedule and verify shift editability based on PC00098 (EDIT_SC event)
    # Query database to check if EDIT_SC event exists (FROM_STATE=5 means Published state)
    Publish Schedule On Week Schedule Page On Web
    ${allow_edit_after_publish}=    Check If Schedule Is Editable In Published State Via DB
    Log    EDIT_SC event check result: ${allow_edit_after_publish}    level=INFO

    # Verify shift editability in published state:
    # - If allow_edit_after_publish=True (EDIT_SC exists): Shifts ARE editable
    # - If allow_edit_after_publish=False (EDIT_SC not found): Shifts are NOT editable
    Verify Not Permit Add Edit Shift Operation On Published Schedule On Week Schedule Page On Web
    ...    ${allow_edit_after_publish}

    # Additional verification: Check if add shift option is displayed/hidden appropriately
    IF    not ${allow_edit_after_publish}
        # When EDIT_SC not present, add shift option should not be displayed
        Verify Add Shift Option Not Displayed On Week Schedule Page On Web
    END

    # Step 7: Unpublish schedule and verify shifts are editable again
    Unpublish Schedule On Week Schedule Page On Web
    Verify Permit Add Edit Shift Operation On UnPublished Schedule On Week Schedule Page On Web
