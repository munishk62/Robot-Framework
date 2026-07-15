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

Suite Setup         Run Keywords    Run Only Once    Pre Setup Schedule For Week 3 SM1 Store6 SIT
...                     AND    Run Only Once    Pre Setup Schedule For Week 3 SM1 Store7 SIT
...                     AND    Run Only Once    Pre Setup Schedule For Week 3 SM1 Store8 SIT
...                     AND    Run Only Once    Pre Setup Schedule For Week 3 SM1 Store9 SIT
Test Teardown       Close Browser


*** Test Cases ***
SITTC80011 : Verify VDI Based Workload Regeneration Using Regenerate Based On Unit Attribute Option When Schedule Is Not Edited And Unpublished
    [Documentation]    SITTC80011 (WFM-133517): Workload (1FTE 10a-6p, Day 2-6) and schedule are generated for PW#3
    ...    for the four VDI unit-attribute stores. Schedules are NOT edited and remain unpublished. CORP imports
    ...    VDI File 2 (2p-10p, Day 1,3,4,5,7) with no regeneration option, then triggers "Delete and Generate"
    ...    based on unit attribute via Advanced Settings.
    ...
    ...    **Expected per unit attribute (not edited):**
    ...    - ZSITSTORE006 (all) → schedule regenerated to 2p-10p (Day 1,3,4,5,7).
    ...    - ZSITSTORE007 (unedited) → schedule regenerated (it is unedited).
    ...    - ZSITSTORE008 (do not) → schedule NOT regenerated (retains 10a-6p Day 2-6).
    ...    - ZSITSTORE009 (blank) → default, schedule NOT regenerated (retains 10a-6p Day 2-6).
    [Tags]    dev:shantanu    rws    sittc80011    sit_v3    sit_bp    sit    web    sit_r22_epic    schedule_dependent
    ...    sit_schedule_dependent
    ${vdi_regen_data}=    Get VDI Workload Regeneration Data
    ...    template_name=default
    ...    week_start_date=3_0
    ${vdi_regen_overrides}=    Get VDI Workload Regeneration Data
    ...    template_name=default
    ...    driver_start_time=10:00
    ...    driver_end_time=18:00
    ${vdi_import_data}=    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=3_0
    VAR    ${week_offset}=    ${vdi_import_data}[week_start_date]
    ${vdi_metric_id}=    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}=    Get System Value    VDIActivity    VDI_ACTIVITY_1
    VAR    ${week_prefix}=    ${week_offset.split('_')[0]}
    VAR    ${edited}=    ${FALSE}
    VAR    ${published}=    ${FALSE}
    ${pre_shift_pattern_data}=    Get Shift Time Pattern Data    template_name=late_morning_8hr
    ${pre_shift_start_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${pre_shift_pattern_data['uiStartTime']}
    ${pre_shift_end_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${pre_shift_pattern_data['uiEndTime']}
    ${post_shift_pattern_data}=    Get Shift Time Pattern Data    template_name=closing_shift
    ${post_shift_start_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${post_shift_pattern_data['uiStartTime']}
    ${post_shift_end_time_week}=    Convert UI Time Format To 24 Hour Format For Web    ${post_shift_pattern_data['uiEndTime']}
    @{pre_shift_days_template}=    Get From Dictionary    ${vdi_regen_data}    pre_shift_days
    @{pre_no_shift_days_template}=    Get From Dictionary    ${vdi_regen_data}    pre_no_shift_days
    ${day1_index}=    Get From List    ${pre_no_shift_days_template}    0
    @{post_shift_days_template}=    Get From Dictionary    ${vdi_regen_data}    post_shift_days
    @{post_no_shift_days_template}=    Get From Dictionary    ${vdi_regen_data}    post_no_shift_days
    @{post_workload_days}=    Get From Dictionary    ${vdi_regen_data}    post_shift_days
    VAR    ${pre_shift_template}=    vdi_pre_state_days125_late_morning_8hr
    VAR    ${post_shift_template}=    vdi_post_state_days0246_closing_shift
    ${store6_data}=    Get User    user_key=SM1_STORE6_SIT
    ${store7_data}=    Get User    user_key=SM1_STORE7_SIT
    ${store8_data}=    Get User    user_key=SM1_STORE8_SIT
    ${store9_data}=    Get User    user_key=SM1_STORE9_SIT
    VAR    &{store6}=    sm=SM1_STORE6_SIT    associate=ESS1_STORE6_SIT    unit_id=${store6_data}[unitID]    attribute=all
    VAR    &{store7}=    sm=SM1_STORE7_SIT    associate=ESS1_STORE7_SIT    unit_id=${store7_data}[unitID]    attribute=unedited
    VAR    &{store8}=    sm=SM1_STORE8_SIT    associate=ESS1_STORE8_SIT    unit_id=${store8_data}[unitID]    attribute=do_not
    VAR    &{store9}=    sm=SM1_STORE9_SIT    associate=ESS1_STORE9_SIT    unit_id=${store9_data}[unitID]    attribute=blank
    VAR    @{stores}=    ${store6}    ${store7}    ${store8}    ${store9}
    FOR    ${store}    IN    @{stores}
        Login And Launch WFM Web App    user_key=${store}[sm]
        ${associate_data}=    Get User    user_key=${store}[associate]
        VAR    ${associate_display_name}=    ${associate_data}[displayName]
        Navigate To RWS Schedule Week Schedule Page On Web
        Select Week Number On Week Schedule Page On Web    ${week_offset}
        Go To Schedule Page On Web
        ${pre_shift_data}=    Get Employee Shift Setup Data    template_name=${pre_shift_template}    ess_user_key=${store}[associate]
        @{pre_shift_days}=    Extract Day Numbers From Shift Data    ${pre_shift_data}
        ${pre_no_shift_data}=    Get Employee Shift Setup Data    template_name=default    ess_user_key=${store}[associate]
        ${pre_no_shift_data}=    Build Employee Shift Setup Data With Overrides For Verification    ${pre_no_shift_data}    default    @{pre_no_shift_days_template}
        @{pre_no_shift_days}=    Extract Day Numbers From Shift Data    ${pre_no_shift_data}
        Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
        ...    ${pre_shift_data}    ${week_offset}    ${pre_shift_start_time_week}    ${pre_shift_end_time_week}    True
        ${pre_shift_hours}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web    ${week_prefix}    ${pre_shift_pattern_data}    @{pre_shift_days}
        ${pre_zero_hours}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
        ...    ${week_prefix}    ${vdi_regen_data}[hours_zero]    @{pre_no_shift_days}
        Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}    ${pre_shift_hours}
        ...    min_hours=${vdi_regen_data}[scheduled_min_hours]    max_hours=${vdi_regen_data}[scheduled_max_hours]
        Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web
        ...    ${associate_display_name}    ${pre_zero_hours}
        Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
        ...    ${associate_display_name}    ${pre_shift_hours}
        Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}    ${pre_zero_hours}
        Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}    ${pre_shift_hours}
        ...    min_hours=${vdi_regen_data}[pre_unfilled_min_hours]    max_hours=${vdi_regen_data}[pre_unfilled_max_hours]
        Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
        ...    ${associate_display_name}    ${pre_zero_hours}
        IF    ${edited}
            Add Shift On Week Schedule Page For The Given Associate And Day On Web
            ...    ${associate_display_name}    ${day1_index}    12:00 PM    08:00 PM
        END
        IF    ${published}    Publish Schedule On Week Schedule Page On Web
        Log Out From Web Application
        Close Browser
    END
    Login And Launch WFM Web App    user_key=SYSADMIN
    FOR    ${store}    IN    @{stores}
        Navigate To RWS Admin RFP Upload Page On Web
        ${vdi_import_data}=    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=${week_offset}
        Set To Dictionary    ${vdi_import_data}    unit_id=${store}[unit_id]    metric_id=${vdi_metric_id}
        ...    skip_days=${post_no_shift_days_template}    activity_name=${vdi_activity_name}
        ${vdi_upload_file_path}=    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
        Upload VDI File On Web    ${vdi_upload_file_path}
        Navigate To RWS Admin RFP Logs Page On Web
        Apply Filter And Select Latest Log File On RFP Logs Page    Volume Driver Interval Import
        Verify Log File Content On Web
    END
    ${target_date}=    Calculate Date From Week Day Offset    ${week_offset}
    ${fiscal_year}=    Get Fiscal Year For Date    ${target_date}
    ${fiscal_week}=    Wait Until Keyword Succeeds    3x    5s    Get Fiscal Week Number Via API    ${week_offset}    SYSADMIN
    ${schedule_type}=    Get System Value    WeekplanType    SCHEDULE
    ${delete_generate_operation}=    Get System Value    WeekplanOperation    DELETE_AND_GENERATE
    ${vdi_schedule_regeneration_option}=    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_BASED_ON_STORE_ATTRIBUTE
    Navigate To RWS Advanced Settings Page On Web
    VAR    &{weekplan_data}=    type=${schedule_type}    store_group=VDI Workload Stores
    ...    fiscal_year=${fiscal_year}    fiscal_week=${fiscal_week}    operation=${delete_generate_operation}
    ...    schedule_preference=${vdi_schedule_regeneration_option}
    Generate Weekplan On Advanced Settings Page On Web    ${weekplan_data}
    Log Out From Web Application
    Close Browser
    FOR    ${store}    IN    @{stores}
        Login And Launch WFM Web App    user_key=${store}[sm]
        ${associate_data}=    Get User    user_key=${store}[associate]
        VAR    ${associate_display_name}=    ${associate_data}[displayName]
        Navigate To RWS Schedule Week Schedule Page On Web
        Select Week Number On Week Schedule Page On Web    ${week_offset}
        Navigate To Plan Status Page From Week Schedule Page On Web
        Go To The Workload Page On Plan Status Page On Web
        ${expected_workload}=    Build Expected Workload Hours Dictionary For Multiple Days On Workload Page On Web
        ...    ${week_prefix}    ${vdi_regen_data}[hours_full_day]    @{post_workload_days}
        ${expected_workload_zero}=    Build Expected Workload Hours Dictionary For Multiple Days On Workload Page On Web
        ...    ${week_prefix}    ${vdi_regen_data}[hours_zero]    @{post_no_shift_days_template}
        FOR    ${day_key}    ${hours}    IN    &{expected_workload_zero}
            Set To Dictionary    ${expected_workload}    ${day_key}=${hours}
        END
        Verify Activity Workload Hours For Multiple Days On Workload Page On Web    ${vdi_activity_name}    ${expected_workload}
        Navigate To RWS Schedule Week Schedule Page On Web
        Select Week Number On Week Schedule Page On Web    ${week_offset}
        Go To Schedule Page On Web
        ${regenerated}=    Evaluate
        ...    '${store}[attribute]' == 'all' or ('${store}[attribute]' == 'unedited' and not ${edited})
        ${demand_shift_days}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
        ...    ${week_prefix}    ${vdi_regen_data}[hours_full_day]    @{post_shift_days_template}
        ${demand_zero_days}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
        ...    ${week_prefix}    ${vdi_regen_data}[hours_zero]    @{post_no_shift_days_template}
        Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
        ...    ${associate_display_name}    ${demand_shift_days}
        Verify Associate Demand Hours For Multiple Days On Week Schedule Page On Web
        ...    ${associate_display_name}    ${demand_zero_days}
        IF    ${regenerated}
            ${regen_shift_data}=    Get Employee Shift Setup Data    template_name=${post_shift_template}
            ...    ess_user_key=${store}[associate]
            ${regen_no_shift_data}=    Get Employee Shift Setup Data    template_name=default    ess_user_key=${store}[associate]
            ${regen_no_shift_data}=    Build Employee Shift Setup Data With Overrides For Verification
            ...    ${regen_no_shift_data}    default    @{post_no_shift_days_template}
            Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
            ...    ${regen_shift_data}    ${week_offset}    ${post_shift_start_time_week}    ${post_shift_end_time_week}    True
            Verify Shift Not Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
            ...    ${regen_no_shift_data}    ${week_offset}    ${post_shift_start_time_week}    ${post_shift_end_time_week}
            Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
            ...    ${demand_shift_days}    min_hours=${vdi_regen_data}[scheduled_min_hours]
            ...    max_hours=${vdi_regen_data}[scheduled_max_hours]
            Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web
            ...    ${associate_display_name}    ${demand_zero_days}
            Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
            ...    ${demand_shift_days}    min_hours=${vdi_regen_data}[post_unfilled_min_hours]
            ...    max_hours=${vdi_regen_data}[post_unfilled_max_hours]
            Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
            ...    ${associate_display_name}    ${demand_zero_days}
        ELSE
            ${preserved_shift_data}=    Get Employee Shift Setup Data    template_name=default    ess_user_key=${store}[associate]
            ${preserved_shift_data}=    Build Employee Shift Setup Data With Overrides For Verification
            ...    ${preserved_shift_data}    default    @{pre_shift_days_template}
            Verify Shift Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
            ...    ${preserved_shift_data}    ${week_offset}    ${vdi_regen_overrides}[driver_start_time]
            ...    ${vdi_regen_overrides}[driver_end_time]    True
            ${preserved_no_shift_data}=    Get Employee Shift Setup Data    template_name=default    ess_user_key=${store}[associate]
            ${preserved_no_shift_data}=    Build Employee Shift Setup Data With Overrides For Verification
            ...    ${preserved_no_shift_data}    default    @{pre_no_shift_days_template}
            Verify Shift Not Exists For Associate On Multiple Days On Week Schedule Page On Web    ${associate_display_name}
            ...    ${preserved_no_shift_data}    ${week_offset}    ${vdi_regen_overrides}[driver_start_time]
            ...    ${vdi_regen_overrides}[driver_end_time]
            ${preserved_sched_days}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
            ...    ${week_prefix}    ${vdi_regen_data}[hours_full_day]    @{pre_shift_days_template}
            ${preserved_sched_zero}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
            ...    ${week_prefix}    ${vdi_regen_data}[hours_zero]    @{pre_no_shift_days_template}
            Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web    ${associate_display_name}
            ...    ${preserved_sched_days}    min_hours=${vdi_regen_data}[scheduled_min_hours]
            ...    max_hours=${vdi_regen_data}[scheduled_max_hours]
            Verify Associate Scheduled Hours For Multiple Days On Week Schedule Page On Web
            ...    ${associate_display_name}    ${preserved_sched_zero}
            ${preserved_unfilled_full}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
            ...    ${week_prefix}    ${vdi_regen_data}[hours_full_day]    @{pre_no_shift_days_template}
            @{partial_unfilled_days}=    Get From Dictionary    ${vdi_regen_data}    partial_unfilled_days
            ${preserved_unfilled_partial}=    Build Expected Hours Dictionary For Multiple Days On Week Schedule Page On Web
            ...    ${week_prefix}    4:00    @{partial_unfilled_days}
            Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
            ...    ${associate_display_name}    ${preserved_unfilled_full}
            Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
            ...    ${associate_display_name}    ${preserved_unfilled_partial}
            Verify Associate Unfilled Hours For Multiple Days On Week Schedule Page On Web
            ...    ${associate_display_name}    ${demand_zero_days}
        END
        Log Out From Web Application
        Close Browser
    END
    FOR    ${store}    IN    @{stores}
        Login And Launch WFM Web App    user_key=${store}[sm]
        Navigate To RWS Schedule Week Schedule Page On Web
        Select Week Number On Week Schedule Page On Web    ${week_offset}
        IF    ${published}
            Go To Schedule Page On Web
            Run Keyword And Ignore Error    Unpublish Schedule On Week Schedule Page On Web
        END
        Navigate To Plan Status Page From Week Schedule Page On Web
        Select Week Number On Week Schedule Page On Web    ${week_offset}
        Clear Existing Generated Data On Batch Plan Status Page On Web
        Log Out From Web Application
        Close Browser
    END
