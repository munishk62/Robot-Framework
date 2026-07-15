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

Suite Setup         Run Only Once    Pre Setup Schedule For Week 1 SM1 Store10 SIT
Test Teardown       Close Browser


*** Test Cases ***
SITTC80009 : Verify VDI Based Workload Regeneration Using Regenerate Unedited Schedules Option When Schedule Is Not Edited And Published
    [Documentation]    Verifies that VDI based workload regeneration works correctly when using the
    ...    'Delete and Generate unedited schedules' option on an UNEDITED but PUBLISHED schedule.
    ...
    ...    **KEY TEST POINT**: This verifies that unedited schedules ARE regenerated even if they are
    ...    published. The "unedited" status takes precedence over the published status.
    ...
    ...    Conditions:
    ...    - Unit Attribute: Blank (not set)
    ...    - Import Options: via UI (VDI import)
    ...    - Schedule Regeneration Preference: Delete and Generate unedited schedules
    ...    - Weekplan Status: Workload Generated, Schedule Generated, UNEDITED and PUBLISHED
    ...
    ...    Test Data:
    ...    - CorpUser: SYSADMIN
    ...    - SMUser: SM1_STORE10_SIT
    ...    - Associate: ESS1_STORE10_SIT
    ...    - Store: Store of SM1_STORE10_SIT (ZSITSTORE010)
    ...    - Week: Planning Week #1
    ...
    ...    PRE-STATE (after Suite Setup / VDIImport1):
    ...    Associate has shifts Day 2-6 from 10a to 6p (unedited, to be published).
    ...    Demand hours Day 2-6: 8hrs/day; Day 1, 7: 0hrs.
    ...    Schedule is PUBLISHED (but still unedited).
    ...
    ...    POST-STATE (after VDIImport2 with Delete and Generate unedited schedules):
    ...    Associate has shifts Day 1, 3, 4, 5, 7 from 2p to 10p (REGENERATED).
    ...    Demand hours Day 1, 3, 4, 5, 7: 8hrs/day; Day 2, 6: 0hrs.
    ...
    ...    KEY TEST POINT: Even though PUBLISHED, the unedited schedule IS regenerated because
    ...    the "Delete and Generate unedited schedules" option checks for edits, not published status.
    [Tags]    dev:azar    rws    sittc80009    sit_v3    sit_bp    sit    web    sit_r22_epic    schedule_dependent
    ...    sit_schedule_dependent
    ${vdi_regen_data}=    Get VDI Workload Regeneration Data
    ...    template_name=default
    ...    week_start_date=1_0
    ...    associate_user_key=ESS1_STORE10_SIT
    ${vdi_import_data}=    Get VDI Import Data
    ...    template_name=vdi_import_schedule_regeneration_sit
    ...    week_start_date=${vdi_regen_data}[week_start_date]
    VAR    ${week_start}=    ${vdi_import_data}[week_start_date]
    ${vdi_metric_id}=    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}=    Get System Value    VDIActivity    VDI_ACTIVITY_1
    VAR    ${week_offset}=    ${week_start.split('_')[0]}
    Login And Launch WFM Web App    user_key=SM1_STORE10_SIT
    ${associate_data}=    Get User    user_key=${vdi_regen_data}[associate_user_key]
    VAR    ${associate_display_name}=    ${associate_data}[displayName]
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Go To Schedule Page On Web
    # Build reusable pre-state verification data (10a to 6p, Day 2-6)
    ${pre_shift_pattern_data}=    Get Shift Time Pattern Data    template_name=late_morning_8hr
    ${pre_shift_start_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${pre_shift_pattern_data['uiStartTime']}
    ${pre_shift_end_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${pre_shift_pattern_data['uiEndTime']}
    ${pre_shift_data}=    Get Employee Shift Setup Data
    ...    template_name=vdi_pre_state_days125_late_morning_8hr
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
    # Days without shifts (Day 1, Day 7): 0hrs for all types
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
    # Schedule is unedited - published status should NOT prevent regeneration with "unedited" option
    Publish Schedule On Week Schedule Page On Web
    Log Out From Web Application
    Close Browser
    # 2pm = 14:00 = index 56 (14*4), 10pm = 22:00 = index 88 (22*4)
    # Indices 56-87 = 32 intervals = 8 hours (2pm-10pm)
    ${vdi_import_data}=    Get VDI Import Data
    ...    template_name=vdi_import_schedule_regeneration_sit
    ...    week_start_date=${week_start}
    ${smuser}=    Get User    user_key=SM1_STORE10_SIT
    VAR    ${store_id}=    ${smuser}[unitID]
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}
    ...    skip_days=${vdi_regen_data}[post_no_shift_days]    activity_name=${vdi_activity_name}
    ${vdi_upload_file_path}=    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Admin RFP Upload Page On Web
    # The unedited (but published) schedule WILL be regenerated because it's unedited
    ${vdi_schedule_regeneration_option}=    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_UNEDITED_SCHEDULES
    Upload VDI File On Web    ${vdi_upload_file_path}    ${vdi_schedule_regeneration_option}
    Navigate To RWS Admin RFP Logs Page On Web
    Apply Filter And Select Latest Log File On RFP Logs Page    Volume Driver Interval Import
    Verify Log File Content On Web
    Log Out From Web Application
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE10_SIT
    # ── Step 10: Navigate to Labor Forecast and verify workload is regenerated ─
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
    # Verify workload for configured activity.
    Verify Activity Workload Hours For Multiple Days On Workload Page On Web    ${vdi_import_data}[activity_name]    ${expected_workload}
    # Build reusable verification data by overriding defaults for shift pattern and shift days.
    ${post_shift_pattern_data}=    Get Shift Time Pattern Data    template_name=closing_shift
    ${post_shift_start_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${post_shift_pattern_data['uiStartTime']}
    ${post_shift_end_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${post_shift_pattern_data['uiEndTime']}
    ${post_shift_data}=    Get Employee Shift Setup Data
    ...    template_name=vdi_post_state_days0246_closing_shift
    ...    ess_user_key=${vdi_regen_data}[associate_user_key]
    @{post_shift_days}=    Extract Day Numbers From Shift Data    ${post_shift_data}
    ${post_no_shift_data}=    Get Employee Shift Setup Data    template_name=default    ess_user_key=${vdi_regen_data}[associate_user_key]
    ${post_no_shift_data}=    Build Employee Shift Setup Data With Overrides For Verification
    ...    ${post_no_shift_data}    default    @{post_no_shift_days}
    # CRITICAL: Even though published, the unedited schedule IS regenerated with "unedited" option
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
    ${expected_scheduled_no_shifts}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{post_no_shift_days}
    ${expected_demand_no_shifts}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
    ...    ${week_offset}    ${vdi_regen_data}[hours_zero]    @{post_no_shift_days}
    ${expected_unfilled_no_shifts}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
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
    ...    ${associate_display_name}    ${expected_scheduled_no_shifts}
    Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_demand_no_shifts}
    Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
    ...    ${associate_display_name}    ${expected_unfilled_no_shifts}
    Navigate To Review Schedule Changes Report Page On Web
    Verify Schedule Changes Report Shows Deleted And Generated On Web
    Log Out From Web Application
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE10_SIT
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Go To Schedule Page On Web
    Unpublish Schedule On Week Schedule Page On Web
    Navigate To Plan Status Page From Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start}
    Clear Existing Generated Data On Batch Plan Status Page On Web
