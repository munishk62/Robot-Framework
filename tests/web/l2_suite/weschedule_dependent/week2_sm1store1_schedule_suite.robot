*** Settings ***
Documentation       Week 2 - SM1_STORE1 Schedule Suite
...
...                 **PURPOSE:**
...                 This suite consolidates all BATTC test cases that require Week 2 schedule data for Store1.
...                 All tests in this suite use the same week setup, enabling efficient parallel execution.
...
...                 **ONE-TIME SETUP APPROACH:**
...                 Suite Setup executes 'Setup Schedule For Week template_name=2_0_sm1_store1' wrapped with 'Run Only Once' from pabot.PabotLib.
...                 This ensures schedule setup runs exactly ONCE across all parallel processes before any tests execute.
...
...                 **PARALLEL EXECUTION ENABLED:**
...                 Tests can be executed in parallel using pabot. The setup runs once, then all tests execute concurrently.
...
...                 **TEST CASES INCLUDED:**
...                 - BATTC00047: Week 2 - Associate Template Schedule Generation (WFM_38_1_store_rws)
...
...                 **EXECUTION COMMANDS:**
...
...                 Sequential execution:
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week2_sm1store1_schedule_suite.robot --test-env QA28_B0
...
...                 With browser visible (for debugging):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week2_sm1store1_schedule_suite.robot --test-env QA28_B0 --show-browser
...
...                 **LOCK FILE CLEANUP:**
...                 If setup appears to be skipped, clean pabot lock files before running:
...                 Remove-Item -Path ".pabot_results" -Recurse -Force -ErrorAction SilentlyContinue

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/roster/template_calendar.resource
Resource            resources/web/rws/schedule/batch_plan_status.resource

Suite Setup         Run Only Once    Pre Setup Schedule For Week 2 SM1Store1
Suite Teardown      Log    Week 2 SM1_STORE1 Suite Complete - All tests executed    level=INFO
Test Teardown       Close Browser

Test Tags           week2_sm1store1    bat_phase1    schedule_dependent


*** Test Cases ***
BATTC00047: Verify user is able to add/edit/delete associate template and generate schedules using it
    [Documentation]    Verify complete lifecycle: create work pattern and associate template, edit shifts using copy
    ...    functionality, generate schedule, verify shifts appear correctly, then delete template and verify cleanup
    ...    Week: 2
    [Tags]    dev:azar    action:write    config:rws    config:add_edit_delete_schedule_template
    ...    config:add_edit_delete_associate_template_sm    battc00047    config:weekplan_and_schedule_gen    checkschedulesetup
    ...    bug_reported    bugid_wfm_136666_bsp    bugid_wfm_136663_pbst    bugid_wfm_140090_twn

    ${ess_user5}    Get User    user_key=ESS5_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${work_pattern_name_from_db}    Get Existing Available Work Pattern Via DB
    Skip If    '${work_pattern_name_from_db}' == 'NONE'    No existing work pattern available in database for this test
    ${work_pattern_data}    Get Work Pattern Data
    ...    work_pattern_name=${work_pattern_name_from_db}
    ...    store_id=StoreEntity.MODEL_STORE1.UNIT_ID
    ...    planning_week_start_date=2_0
    ...    planning_week_end_date=2_6
    VAR    ${planning_week_start_date}    ${work_pattern_data}[planning_week_start_date]
    Navigate To Template Calendar Page On Web
    ${map_status}    Map Work Pattern To Store On Web    planning_week_start_date=${planning_week_start_date}
    ...    work_pattern_name=${work_pattern_data}[work_pattern_name]
    IF    ${map_status}    Verify Work Pattern Mapping Success On Web
    ${fixed_shift_data}    Get Add Associate Template Data
    ...    week_start_date=${planning_week_start_date}
    # Parse JSON strings into Python objects for shift_day_list and copy_shift_config
    ${shift_day_list}    Evaluate    json.loads('[{"day_number": "0", "start_time": "06:00", "end_time": "13:00"}]')    json
    # Get original day values
    VAR    ${day_to_add}    ${shift_day_list}[0][day_number]

    # Conditionally adjust day number based on fiscal week start configuration
    ${fiscal_week_start}    Get Config Value    FISCAL_WEEK_START_DAY
    IF    ${fiscal_week_start} > 1
        ${adjusted_day_add}    Convert Day Number By Fiscal Week Start    ${day_to_add}
    ELSE
        VAR    ${adjusted_day_add}    ${day_to_add}
    END

    ${shift_day_list}    Evaluate    $shift_day_list[0].update({'day_number': '${adjusted_day_add}'}) or $shift_day_list

    Set To Dictionary    ${fixed_shift_data}    shift_day_list=${shift_day_list}
    ${template_id_ref_number}    Add New Blank Template Assign Shift By Mapping Work Pattern On Associate Template Page On Web
    ...    ${ess_user5}[displayName]    ${planning_week_start_date}    ${work_pattern_data}[work_pattern_name]
    ...    ${fixed_shift_data}[shift_day_list]
    Edit Template Copy Shifts Lock And Capture API Data On Web
    ...    ${template_id_ref_number}    ${fixed_shift_data}[copy_shift_config]
    ${parsed_shifts}    Capture And Parse Template Info From API And Wait For Review Dropdown    ${template_id_ref_number}
    Navigate To Review Fixed Shifts And Regenerate With API Data Verification On Web
    ...    ${planning_week_start_date}
    Verify Shifts On Review Page Match API Data On Web    ${ess_user5}[displayName]    ${parsed_shifts}    ${planning_week_start_date}
    ${batch_plan_data}    Get Batch Plan Data
    Navigate To Plan Status Page From Review Fixed Shifts Page On Web    ${planning_week_start_date}
    Clear Existing Generated Data On Batch Plan Status Page On Web
    Generate Forecast Workload Schedule And Publish On Batch Plan Status Page On Web    ${batch_plan_data}[regenerate_forecast_required]
    ...    ${batch_plan_data}[schedule_type]    ${batch_plan_data}[do_publish_schedule]
    Verify Scheduled Shift On Week Schedule Page On Web    ${ess_user5}[displayName]    ${parsed_shifts}    ${planning_week_start_date}
    Close Browser
    [Teardown]    Run Keywords
    ...    Run Keyword If Test Passed    Clear Generated Schedule And Workload If Exists On Web    SM1_STORE1    ${planning_week_start_date}    AND
    ...    Run Keyword If Test Passed    Close Browser    AND
    ...    Run Keyword If Test Passed    Delete Work Pattern Based Template And Verify Api Success On Web    SM1_STORE1    ${template_id_ref_number}    AND
    ...    Run Keyword If Test Passed    Close Browser    AND
    ...    Run Keyword If Test Passed    Verify Created Shift Removed Post Associate Template Deletion On Review Fixed Shift Page On Web    SM1_STORE1    ${ess_user5}[displayName]    ${parsed_shifts}    ${planning_week_start_date}    AND
    ...    Run Keyword If Test Passed    Close Browser
