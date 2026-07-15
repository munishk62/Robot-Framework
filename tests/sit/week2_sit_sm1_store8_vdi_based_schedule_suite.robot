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

Suite Setup         Run Only Once    Pre Setup Schedule For Week 2 SM1 Store8 SIT
Test Teardown       Close Browser


*** Test Cases ***
SITTC80006 : Verify VDI Based Workload Regeneration When Optimized Schedule Is Generated Already
    [Documentation]    SITTC80006: Workload is generated for the store ZSITSTORE008 for VDI based activity (1FTE from 10a to 6p for day 2 to Day 6) for PW#1
    ...    Optimized schedule is generated for the store ZSITSTORE008 for PW#2. No edits are present in the schedule
    ...
    ...    **Pre-Conditions (Setup):**
    ...    - Workload generated: 1FTE from 10a to 6p for Day 2-6 (skip Day 1 & 7) for PW#1
    ...    - Optimized schedule generated for PW#2 using optimized algorithm
    ...    - No manual edits applied to schedule
    ...    - Schedule remains unpublished
    ...
    ...    **Conditions:**
    ...    - Unit Attribute: Do not Delete and Generate schedules
    ...    - Import Options: via UI (VDI import)
    ...    - Schedule Regeneration Preference: Delete and Generate all schedules
    ...    - Weekplan Status: Workload Generated, Optimized Schedule Generated, Unedited and Unpublished
    ...
    ...    **Test Flow:**
    ...    1. Verify pre-state: Days 2-6 have 10a-6p shifts, Days 1 & 7 have no shifts
    ...    2. Logout, login as CORP, perform VDI import with 2p-10p for Days 1,3,4,5,7 (skip 2,6)
    ...    3. Verify workload regenerated: Days 1,3,4,5,7 have 8hrs, Days 2,6 have 0hrs
    ...    4. Verify schedule regenerated: Days 1,3,4,5,7 have 2p-10p shifts, Days 2,6 have no shifts
    ...    5. Teardown: Delete schedule and workload for PW#2
    [Tags]    dev:azar    rws    sittc80006    sit_v3    sit_bp    sit    web    sit_r22_epic    schedule_dependent
    ...    sit_schedule_dependent
    [Setup]    Run Only Once    Pre Setup Schedule For Week 2 SM1 Store8 SIT
    ${vdi_regen_data}=    Get VDI Workload Regeneration Data
    ...    template_name=default
    ...    week_start_date=2_0
    ...    associate_user_key=ESS1_STORE8_SIT
    ${vdi_import_data}=    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=2_0
    VAR    ${week_start}=    ${vdi_import_data}[week_start_date]
    ${vdi_metric_id}=    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}=    Get System Value    VDIActivity    VDI_ACTIVITY_1
    VAR    ${week_offset}=    ${week_start.split('_')[0]}
    Login And Launch WFM Web App    user_key=SM1_STORE8_SIT
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
    ...    ess_user_key=${vdi_regen_data}[associate_user_key]
    @{pre_shift_days}=    Extract Day Numbers From Shift Data    ${pre_shift_data}
    @{pre_no_shift_days}=    Get From Dictionary    ${vdi_regen_data}    pre_no_shift_days
    # ${pre_no_shift_data}=    Get Employee Shift Setup Data    template_name=default    ess_user_key=${vdi_regen_data}[associate_user_key]
    # ${pre_no_shift_data}=    Build Employee Shift Setup Data With Overrides For Verification
    # ...    ${pre_no_shift_data}    default    @{pre_no_shift_days}
    Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${pre_shift_data}    ${week_start}    ${pre_shift_start_time_week}    ${pre_shift_end_time_week}    True
    # Verify hours separately for Day 2-6 (pre-state: 10a-6p workload)
    # Use shift pattern data to calculate expected hours (8:00 from 480 min duration)
    ${expected_scheduled_before}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${pre_shift_pattern_data}    @{pre_shift_days}
    ${expected_demand_before}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${pre_shift_pattern_data}    @{pre_shift_days}
    # Unfilled hours are always 0:00 (explicit string)
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
    Log Out From Web Application
    Close Browser
    ${vdi_import_data}=    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=${week_start}
    ${smuser}=    Get User    user_key=SM1_STORE8_SIT
    VAR    ${store_id}=    ${smuser}[unitID]
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}
    ...    skip_days=${vdi_regen_data}[post_no_shift_days]    activity_name=${vdi_activity_name}
    ${vdi_upload_file_path}=    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Admin RFP Upload Page On Web
    ${vdi_schedule_regeneration_option}=    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    Upload VDI File On Web    ${vdi_upload_file_path}    ${vdi_schedule_regeneration_option}
    Navigate To RWS Admin RFP Logs Page On Web
    Apply Filter And Select Latest Log File On RFP Logs Page    Volume Driver Interval Import
    Verify Log File Content On Web
    Log Out From Web Application
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE8_SIT
    # ── Step 9: Navigate to Labor Forecast and verify workload is regenerated ─
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Navigate To Plan Status Page From Week Schedule Page On Web
    Go To The Workload Page On Plan Status Page On Web
    # Build expected workload for days with 8 hours (Day 1, 3, 4, 5, 7)
    @{post_workload_days}=    Get From Dictionary    ${vdi_regen_data}    post_shift_days
    @{post_no_shift_days}=    Get From Dictionary    ${vdi_regen_data}    post_no_shift_days
    ${expected_workload}=    Build Expected Workload Hours Dictionary For Multiple Days On Workload Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_full_day]    @{post_workload_days}
    ${expected_workload_zero}=    Build Expected Workload Hours Dictionary For Multiple Days On Workload Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{post_no_shift_days}
    FOR    ${day_key}    ${hours}    IN    &{expected_workload_zero}
        Set To Dictionary    ${expected_workload}    ${day_key}=${hours}
    END
    Verify Activity Workload Hours For Multiple Days On Workload Page On Web    ${vdi_import_data}[activity_name]    ${expected_workload}
    # Build reusable verification data by overriding defaults for shift pattern and shift days.
    ${post_shift_pattern_data}=    Get Shift Time Pattern Data    template_name=closing_shift
    ${post_shift_start_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${post_shift_pattern_data['uiStartTime']}
    ${post_shift_end_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${post_shift_pattern_data['uiEndTime']}
    ${post_shift_data}=    Get Employee Shift Setup Data    template_name=vdi_post_state_days0246_closing_shift
    ...    ess_user_key=${vdi_regen_data}[associate_user_key]
    @{post_shift_days}=    Extract Day Numbers From Shift Data    ${post_shift_data}
    ${post_no_shift_data}=    Get Employee Shift Setup Data    template_name=default    ess_user_key=${vdi_regen_data}[associate_user_key]
    ${post_no_shift_data}=    Build Employee Shift Setup Data With Overrides For Verification
    ...    ${post_no_shift_data}    default    @{post_no_shift_days}
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Go To Schedule Page On Web
    Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${post_shift_data}    ${week_start}    ${post_shift_start_time_week}    ${post_shift_end_time_week}    True
    Verify Shift Not Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${post_no_shift_data}    ${week_start}    ${post_shift_start_time_week}    ${post_shift_end_time_week}
    # Days with shifts (0,2,3,4,6): Use post shift pattern data for hours calculation
    ${expected_scheduled_with_shifts}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${post_shift_pattern_data}    @{post_shift_days}
    ${expected_demand_with_shifts}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${post_shift_pattern_data}    @{post_shift_days}
    ${expected_unfilled_with_shifts}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{post_shift_days}
    # Days without shifts (1,5): 0hrs for all types
    ${expected_scheduled_no_shifts_after}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{post_no_shift_days}
    ${expected_demand_no_shifts_after}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{post_no_shift_days}
    ${expected_unfilled_no_shifts_after}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{post_no_shift_days}
    # Combine and verify separately
    # Verify days with shifts separately (range validation for 8hr days)
    Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${expected_scheduled_with_shifts}    min_hours=${vdi_regen_data}[scheduled_min_hours]
    ...    max_hours=${vdi_regen_data}[scheduled_max_hours]
    Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_demand_with_shifts}
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
    ...    ${expected_unfilled_with_shifts}    min_hours=${vdi_regen_data}[post_unfilled_min_hours]
    ...    max_hours=${vdi_regen_data}[post_unfilled_max_hours]
    # Verify days without shifts separately (exact match 0:00)
    Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_scheduled_no_shifts_after}
    Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_demand_no_shifts_after}
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_unfilled_no_shifts_after}
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE8_SIT
    Navigate To RWS Schedule Week Schedule Page On Web
    Navigate To Plan Status Page From Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Clear Existing Generated Data On Batch Plan Status Page On Web
