*** Settings ***
Documentation       SIT Suite: VDI Based Workload Regeneration Tests
...                 **PURPOSE:**
...                 This suite verifies VDI based workload regeneration scenarios for schedule planning week 1.
...
...                 **SUITE SETUP:**
...                 Generates schedule for PW#1 for SM1_STORE6_SIT using VDI Import 1 (File 1)
...                 which creates workload of 1FTE from 10a to 6p for Day 2 to Day 6.

Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/rws/labor_forecast/workload.resource
Resource            resources/web/rws/schedule/batch_plan_status.resource
Resource            resources/web/rws/schedule/plan_status.resource
Resource            resources/web/rws/admin/rfp_upload.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource
Resource            resources/web/rws/advanced_settings/advanced_settings.resource
Resource            resources/web/common/common_date_utility.resource
Library             Collections
Library             test_data/TestDataLibrary.py
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 2 SM1 Store9 SIT
Test Teardown       Close Browser


*** Test Cases ***
SITTC80008 : Verify VDI Based Workload Regeneration Using Regenerate Unedited Schedules Option When Schedule Is Edited And Unpublished
    [Documentation]    SITTC80008: Workload is generated for the store ZSITSTORE009 for VDI based activity (1FTE from 10a to 6p for day 2 to Day 6) for PW#2
    ...    Optimized schedule is generated for the store ZSITSTORE009 for PW#2. Schedule is manually edited (shift added on Day 1), then VDI import with "Delete and Generate unedited schedules" preserves the edited schedule.
    ...
    ...    **Pre-Conditions (Setup):**
    ...    - Workload generated: 1FTE from 10a to 6p for Day 2-6 (skip Day 1 & 7) for PW#2
    ...    - Schedule generated using optimized algorithm
    ...    - No manual edits applied to schedule initially
    ...    - Schedule remains unpublished
    ...
    ...    **Conditions:**
    ...    - Unit Attribute: Blank (not set)
    ...    - Import Options: via UI (VDI import)
    ...    - Schedule Regeneration Preference: Delete and Generate unedited schedules
    ...    - Weekplan Status: Workload Generated, Schedule Generated, EDITED and UNPUBLISHED
    ...
    ...    **Test Flow:**
    ...    1. Verify pre-state: Days 2-6 have 10a-6p shifts, Days 1 & 7 have no shifts
    ...    2. Edit schedule: add shift on Day 1 (12p-8p) - this makes the schedule EDITED
    ...    3. Keep schedule UNPUBLISHED (edited but unpublished)
    ...    4. Logout, login as CORP, perform VDI import with 2p-10p for Days 1,3,4,5,7 (skip 2,6) with "Delete and Generate unedited schedules"
    ...    5. Verify workload regenerated: Days 1,3,4,5,7 have 8hrs, Days 2,6 have 0hrs
    ...    6. **CRITICAL**: Verify schedule is NOT regenerated - manual edit (Day 1 12p-8p) is PRESERVED + Day 2-6 still have 10a-6p shifts
    ...    7. Verify unfilled hours reflect mismatch between preserved schedule and new demand
    ...    8. Verify Review Schedule Changes report shows manual Add Shift operation (not deletion/regeneration)
    ...    9. Teardown: Delete schedule and workload for PW#2
    ...
    ...    **CRITICAL TEST POINT:** "Delete and Generate unedited schedules" option PRESERVES edited schedules. The workload changes but the manual edits remain intact.
    [Tags]    dev:azar    rws    sittc80008    sit_v3    sit_bp    sit    web    sit_r22_epic    schedule_dependent
    ...    sit_schedule_dependent
    ${vdi_regen_data}=    Get VDI Workload Regeneration Data
    ...    template_name=default
    ...    week_start_date=2_0
    ...    associate_user_key=ESS1_STORE9_SIT
    ${post_unfilled_day1_override}=    Get VDI Workload Regeneration Data
    ...    template_name=default
    ...    post_unfilled_min_hours=0.0
    ...    post_unfilled_max_hours=8.0
    ${post_unfilled_partial_override}=    Get VDI Workload Regeneration Data
    ...    template_name=default
    ...    post_unfilled_min_hours=0.0
    ...    post_unfilled_max_hours=4.0
    ${vdi_metric_id}=    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}=    Get System Value    VDIActivity    VDI_ACTIVITY_1
    ${vdi_import_data}=    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=2_0
    ...    activity_name=${vdi_activity_name}
    VAR    ${week_start}=    ${vdi_import_data}[week_start_date]
    VAR    ${week_offset}=    ${week_start.split('_')[0]}
    Login And Launch WFM Web App    user_key=SM1_STORE9_SIT
    ${associate_data}=    Get User    user_key=${vdi_regen_data}[associate_user_key]
    VAR    ${associate_display_name}=    ${associate_data}[displayName]
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Go To Schedule Page On Web
    # Build reusable pre-state verification data (10a to 6p, Day 2-6)
    ${pre_shift_pattern_data}=    Get Shift Time Pattern Data    template_name=late_morning_8hr
    ${pre_shift_start_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${pre_shift_pattern_data['uiStartTime']}
    ${pre_shift_end_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${pre_shift_pattern_data['uiEndTime']}
    ${pre_shift_data}=    Get Employee Shift Setup Data    template_name=vdi_pre_state_days125_late_morning_8hr
    ...    ess_user_key=ESS1_STORE9_SIT
    @{pre_shift_days}=    Extract Day Numbers From Shift Data    ${pre_shift_data}
    @{pre_no_shift_days}=    Get From Dictionary    ${vdi_regen_data}    pre_no_shift_days
    ${day1_index}=    Get From List    ${pre_no_shift_days}    0
    # ${pre_no_shift_data}=    Get Employee Shift Setup Data    template_name=default    ess_user_key=${vdi_regen_data}[associate_user_key]
    # ${pre_no_shift_data}=    Build Employee Shift Setup Data With Overrides For Verification
    # ...    ${pre_no_shift_data}    default    @{pre_no_shift_days}
    Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${pre_shift_data}    ${week_start}    ${pre_shift_start_time_week}    ${pre_shift_end_time_week}    True
    # Verify hours separately for Day 2-6 (pre-state: 10a-6p workload)
    ${expected_scheduled_before}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${pre_shift_pattern_data}    @{pre_shift_days}
    ${expected_demand_before}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${pre_shift_pattern_data}    @{pre_shift_days}
    ${expected_unfilled_before}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{pre_shift_days}
    # Days without shifts (0,6): 0hrs for all types
    ${expected_scheduled_no_shifts}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{pre_no_shift_days}
    ${expected_demand_no_shifts}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{pre_no_shift_days}
    ${expected_unfilled_no_shifts}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{pre_no_shift_days}
    Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${expected_scheduled_before}    min_hours=${vdi_regen_data}[scheduled_min_hours]
    ...    max_hours=${vdi_regen_data}[scheduled_max_hours]
    Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_demand_before}
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${expected_unfilled_before}    min_hours=${vdi_regen_data}[pre_unfilled_min_hours]
    ...    max_hours=${vdi_regen_data}[pre_unfilled_max_hours]
    # Verify days without shifts separately (exact match 0:00)
    Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_scheduled_no_shifts}
    Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_demand_no_shifts}
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_unfilled_no_shifts}
    # Manual edit: add a shift on Day 1 (0-based index 0) from 12:00 PM to 08:00 PM
    # This makes the schedule EDITED, which means it will be PRESERVED by "Delete and Generate unedited schedules"
    Add Shift On Week Schedule Page For The Given Associate And Day On Web
    ...    ${associate_display_name}    ${day1_index}    12:00 PM    08:00 PM
    # Verify shift was added: scheduled hours 8hrs, demand hours 0hrs (before VDI import)
    VAR    &{expected_scheduled_hours_add_shift}=    ${week_offset}_${day1_index}=${vdi_regen_data}[hours_full_day]
    Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${expected_scheduled_hours_add_shift}    min_hours=${vdi_regen_data}[scheduled_min_hours]
    ...    max_hours=${vdi_regen_data}[scheduled_max_hours]
    VAR    &{expected_demand_hours_add_shift}=    ${week_offset}_${day1_index}=${vdi_regen_data}[hours_zero]
    Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_demand_hours_add_shift}
    VAR    &{expected_unfilled_hours_add_shift}=    ${week_offset}_${day1_index}=${vdi_regen_data}[hours_zero]
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_unfilled_hours_add_shift}
    # Per test requirements, schedule remains unpublished
    # When "Delete and Generate unedited schedules" is used, the edited schedule will be PRESERVED
    Log Out From Web Application
    Close Browser
    ${vdi_import_data}=    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=${week_start}
    ${smuser}=    Get User    user_key=SM1_STORE9_SIT
    VAR    ${store_id}=    ${smuser}[unitID]
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}
    ...    skip_days=${vdi_regen_data}[post_no_shift_days]    activity_name=${vdi_activity_name}
    ${vdi_upload_file_path}=    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Admin RFP Upload Page On Web
    ${vdi_schedule_regeneration_option}=    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_UNEDITED_SCHEDULES
    Upload VDI File On Web    ${vdi_upload_file_path}    ${vdi_schedule_regeneration_option}
    Navigate To RWS Admin RFP Logs Page On Web
    Apply Filter And Select Latest Log File On RFP Logs Page    Volume Driver Interval Import
    Verify Log File Content On Web
    Log Out From Web Application
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE9_SIT
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Navigate To Plan Status Page From Week Schedule Page On Web
    Go To The Workload Page On Plan Status Page On Web
    # Build expected workload for days with 8 hours (Day 1, 3, 4, 5, 7)
    @{post_workload_days}=    Get From Dictionary    ${vdi_regen_data}    post_shift_days
    @{post_no_shift_days}=    Get From Dictionary    ${vdi_regen_data}    post_no_shift_days
    ${expected_workload}=    Build Expected Workload Hours Dictionary For Multiple Days On Workload Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_full_day]    @{post_workload_days}
    # Add days with 0 hours (Day 2, 6)
    FOR    ${day_key}    IN    @{post_no_shift_days}
        Set To Dictionary    ${expected_workload}    ${week_offset}_${day_key}=${vdi_regen_data}[hours_zero]
    END
    # Verify workload for configured activity.
    Verify Activity Workload Hours For Multiple Days On Workload Page On Web    ${vdi_import_data}[activity_name]    ${expected_workload}
    # **CRITICAL**: The manual edit (Day 1 12p-8p) should be PRESERVED (not deleted/regenerated)
    # Original schedule (Day 2-6 10a-6p) should also be PRESERVED
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Go To Schedule Page On Web
    # Verify manual shift on Day 1 still exists (12p-8p = 12:00-20:00 in 24hr format)
    ${manual_shift_pattern_data}=    Get Shift Time Pattern Data    template_name=afternoon_8hr
    ${manual_shift_start_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${manual_shift_pattern_data['uiStartTime']}
    ${manual_shift_end_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${manual_shift_pattern_data['uiEndTime']}
    ${manual_shift_data}=    Get Employee Shift Setup Data    template_name=default    ess_user_key=ESS1_STORE9_SIT
    ${manual_shift_data}=    Build Employee Shift Setup Data With Overrides For Verification
    ...    ${manual_shift_data}    default    0
    Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${manual_shift_data}    ${week_start}    ${manual_shift_start_time_week}    ${manual_shift_end_time_week}    True
    # Verify original shifts (Day 2-6 10a-6p) still exist
    ${preserved_shift_data}=    Get Employee Shift Setup Data    template_name=vdi_pre_state_days125_late_morning_8hr
    ...    ess_user_key=ESS1_STORE9_SIT
    Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${preserved_shift_data}    ${week_start}    ${pre_shift_start_time_week}    ${pre_shift_end_time_week}    True
    # Scheduled hours remain unchanged (Day 1: 8hrs manual edit, Day 2-6: 8hrs each, Day 7: 0hrs)
    @{all_shift_days}=    Get From Dictionary    ${vdi_regen_data}    pre_shift_days
    ${expected_scheduled_preserved}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${manual_shift_pattern_data}    @{all_shift_days}
    VAR    &{expected_scheduled_day7}=    ${week_offset}_6=${vdi_regen_data}[hours_zero]
    Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${expected_scheduled_preserved}    min_hours=${vdi_regen_data}[scheduled_min_hours]
    ...    max_hours=${vdi_regen_data}[scheduled_max_hours]
    Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_scheduled_day7}
    # Demand hours changed to Day 1,3,4,5,7=8hrs; Day 2,6=0hrs
    ${post_demand_pattern}=    Get Shift Time Pattern Data    template_name=closing_shift
    @{demand_high_days}=    Get From Dictionary    ${vdi_regen_data}    post_shift_days
    @{demand_zero_days}=    Get From Dictionary    ${vdi_regen_data}    post_no_shift_days
    ${expected_demand_after_vdi}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${post_demand_pattern}    @{demand_high_days}
    ${expected_demand_zero_after_vdi}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{demand_zero_days}
    Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_demand_after_vdi}
    Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_demand_zero_after_vdi}
    # Unfilled hours reflect mismatch between preserved schedule and new demand
    # Day 1: manual shift 12p-8p (720-1200min) vs demand 2p-10p (840-1320min) -> partial overlap, ~2-2.5hrs unfilled
    # Day 2,6: scheduled 10a-6p but demand=0hrs -> 0hrs unfilled
    # Day 3,4,5: scheduled 10a-6p vs demand 2p-10p -> partial overlap, ~0-0.5hrs unfilled
    # Day 7: scheduled=0 but demand=8hrs -> 8hrs unfilled
    ${expected_unfilled_day2_6}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{demand_zero_days}
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_unfilled_day2_6}
    # Day 1: 2-2.5hrs unfilled (mismatch between 12p-8p shift and 2p-10p demand)
    VAR    &{expected_unfilled_day1}=    ${week_offset}_0=${vdi_regen_data}[hours_zero]
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${expected_unfilled_day1}    min_hours=${post_unfilled_day1_override}[post_unfilled_min_hours]
    ...    max_hours=${post_unfilled_day1_override}[post_unfilled_max_hours]
    # Day 3,4,5: 0-0.5hrs unfilled (some overlap between 10a-6p and 2p-10p)
    @{partial_unfilled_days}=    Get From Dictionary    ${vdi_regen_data}    partial_unfilled_days
    ${expected_unfilled_day3_4_5}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{partial_unfilled_days}
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${expected_unfilled_day3_4_5}    min_hours=${post_unfilled_partial_override}[post_unfilled_min_hours]
    ...    max_hours=${post_unfilled_partial_override}[post_unfilled_max_hours]
    # Day 7: 8hrs unfilled (no shift but 8hrs demand)
    VAR    &{expected_unfilled_day7}=    ${week_offset}_6=${vdi_regen_data}[hours_full_day]
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_unfilled_day7}
    Navigate To Review Schedule Changes Report Page On Web
    # Report should show the manual Add Shift operation (the edit was preserved)
    # NOT a deletion/regeneration, because the edited schedule was NOT regenerated
    Verify Schedule Changes Report Contains Add Shift Operation On Web
    ...    ${associate_display_name}    ${week_offset}_0    12:00    20:00
    Log Out From Web Application
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE9_SIT
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Go To Schedule Page On Web
    Unpublish Schedule On Week Schedule Page On Web
    Navigate To Plan Status Page From Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Clear Existing Generated Data On Batch Plan Status Page On Web
