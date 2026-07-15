*** Settings ***
Documentation       Common Schedule Setup Keywords
...
...                 Unified schedule setup keywords shared across mobile and web test suites.
...                 Each keyword is named by week/store permutation (e.g., Pre Setup Schedule For Week 2 SM1Store2)
...                 so that both mobile and web suites can reference the SAME keyword name via Run Only Once.
...                 This prevents parallel execution conflicts where two processes set up the same store/week differently.

Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/new_hire_setup/common_new_hire_setup.resource
Library             test_data/TestDataLibrary.py


*** Keywords ***
# ============================================================================
# WEEK 0 - STORE 1 (SM1_STORE1) — Web only
# ============================================================================
Pre Setup Schedule For Week 0 SM1Store1
    [Documentation]    Schedule setup for Week 0 (current week) for Store1.
    ...    Workflow: wip_generate_and_publish_schedule (generates, publishes, creates WIP copy)
    ...    Employees: ESS4_STORE1, ESS2_STORE1, ESS1_STORE1
    ${smuser}    Get User    SM1_STORE1
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=wip_generate_and_publish_schedule
    ...    _date_format=${resultant_date_format}
    ${ess4_store1}    Get Employee Shift Setup Data    template_name=addlastday_standard8    ess_user_key=ESS4_STORE1
    ${ess2_store1}    Get Employee Shift Setup Data    template_name=addtoday_standard8    ess_user_key=ESS2_STORE1
    ${ess1_store1}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS1_STORE1
    VAR    @{employee_operations}    ${ess4_store1}    ${ess2_store1}    ${ess1_store1}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 0 - STORE 2 (SM1_STORE2) — mobile and web
# ============================================================================

Pre Setup Schedule For Week 0 SM1Store2
    [Documentation]    Schedule setup for Week 0 (current week) for Store2.
    ...    Workflow: generate_and_publish_schedule
    ...    Employees: Union of mobile (ESS5_STORE2) and web (ESSNH1, ESSNH4, ESSNH6).
    Run Only Once    Create Dynamic Employees For SM1Store2
    ${smuser}    Get User    SM1_STORE2
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=wip_generate_and_publish_schedule
    ...    _date_format=${resultant_date_format}
    # Mobile employee
    ${ess5_store2}    Get Employee Shift Setup Data    template_name=addlastday_standard8    ess_user_key=ESS5_STORE2
    # Web employees (dynamic new hires — require Create Dynamic Employees suite setup to have run first)
    ${essnh1_store2}    Get Employee Shift Setup Data    template_name=add6_standard8    ess_user_key=ESSNH1_STORE2
    ${essnh4_store2}    Get Employee Shift Setup Data    template_name=addtoday_standard7    ess_user_key=ESSNH4_STORE2
    ${essnh6_store2}    Get Employee Shift Setup Data    template_name=addtoday_standard7    ess_user_key=ESSNH6_STORE2
    ${ess_nh7_store2}    Get Employee Shift Setup Data    template_name=addtoday_standard8    ess_user_key=ESSNH7_STORE2
    VAR    @{employee_operations}    ${ess5_store2}    ${essnh1_store2}    ${essnh4_store2}    ${essnh6_store2}    ${ess_nh7_store2}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 1 - STORE 1 (SM1_STORE1) — Web only
# ============================================================================

Pre Setup Schedule For Week 1 SM1Store1
    [Documentation]    Schedule setup for Week 1 for Store1.
    ...    Workflow: only_generate_schedule (generates but does NOT publish)
    ...    Employees: ESS1_STORE1, ESS6_STORE1
    ${smuser}    Get User    SM1_STORE1
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=1_0
    ...    week_offset=1_0    _date_format=${resultant_date_format}
    ${ess1_store1}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS1_STORE1
    ${ess6_store1}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS6_STORE1
    VAR    @{employee_operations}    ${ess1_store1}    ${ess6_store1}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 1 - STORE 2 (SM1_STORE2) — Web only
# ============================================================================

Pre Setup Schedule For Week 1 SM1Store2
    [Documentation]    Schedule setup for Week 1 for Store2.
    ...    Workflow: generate_and_publish_schedule
    ...    Employees: ESS5_STORE2, ESS6_STORE2, ESSNH4_STORE2, ESSNH6_STORE2
    Run Only Once    Create Dynamic Employees For SM1Store2
    ${smuser}    Get User    SM1_STORE2
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=1_0
    ...    week_offset=1_0    _date_format=${resultant_date_format}
    ${ess5_store2}    Get Employee Shift Setup Data    template_name=add123_standard8_addunallocate6    ess_user_key=ESS5_STORE2
    ${ess6_store2}    Get Employee Shift Setup Data    template_name=add012_standard8    ess_user_key=ESS6_STORE2
    ${essnh4_store2}    Get Employee Shift Setup Data    template_name=add01356_standard7    ess_user_key=ESSNH4_STORE2
    ${essnh6_store2}    Get Employee Shift Setup Data    template_name=add01356_standard7    ess_user_key=ESSNH6_STORE2
    VAR    @{employee_operations}    ${ess5_store2}    ${ess6_store2}    ${essnh4_store2}    ${essnh6_store2}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 1 SM1 Store6 SIT
    [Documentation]    Schedule setup for Week 1 for Store6.
    ...    Workflow: Delete and Generate all schedules (to set up test data for schedule regeneration testing in later weeks)
    ...    Employees: none (schedule will be generated with default shifts for all employees, but no per-employee modifications)
    ...
    ...    VDI File: Uses template_name=vdi_import_schedule_regeneration_sit with a custom driver_import_array override.
    ...    The array sets hours 28-47 (indices) to 1 (active) representing 1FTE from 10a to 6p.
    ...    Days 0 (Sunday) and 6 (Saturday) are skipped (all hours = 0).
    ...    The custom file path is passed via workflow_details[vdi_upload_file_path] so the
    ...    existing Pre Setup Store Schedule For Week pipeline uses it instead of regenerating
    ...    from the default template. No other setups are affected.
    ...
    ...    TEST: SITTC80001
    ${smuser}    Get User    SM1_STORE6_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    ${resultant_date_format}    Get Config Value    SERVER_DF
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=1_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE6_SIT Week 1: ${vdi_upload_file_path}    level=INFO
    # Build workflow and pass the pre-generated file path so the pipeline skips default VDI generation
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=1_0
    ...    week_offset=1_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 2 SM1 Store6 SIT
    [Documentation]    Schedule setup for Week 2 for Store6.
    ...    Workflow: Delete and Generate all schedules (to set up test data for VDI workload regeneration testing)
    ...    Employees: none (schedule will be generated with default shifts for all employees, but no per-employee modifications)
    ...
    ...    VDI File: Uses template_name=vdi_import_schedule_regeneration_sit with a custom driver_import_array override.
    ...    The array sets hours 40-71 (indices) to 1 (active) representing 1FTE from 10a to 6p.
    ...    Days 0 (Sunday) and 6 (Saturday) are skipped (all hours = 0).
    ...    The custom file path is passed via workflow_details[vdi_upload_file_path] so the
    ...    existing Pre Setup Store Schedule For Week pipeline uses it instead of regenerating
    ...    from the default template. No other setups are affected.
    ...
    ...    TEST: SITTC80002
    ${smuser}    Get User    SM1_STORE6_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=2_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE6_SIT Week 2: ${vdi_upload_file_path}    level=INFO
    # Build workflow and pass the pre-generated file path so the pipeline skips default VDI generation
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=2_0
    ...    week_offset=2_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 2 - STORE 1 (SM1_STORE1) — Web only
# ============================================================================

Pre Setup Schedule For Week 2 SM1Store1
    [Documentation]    Schedule setup for Week 2 for Store1.
    ...    Workflow: no_schedule_generation
    ...    Employees: none
    ${smuser}    Get User    SM1_STORE1
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=no_schedule_generation    week_start_date=2_0
    ...    week_offset=2_0    _date_format=${resultant_date_format}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 2 - STORE 2 (SM1_STORE2) — CONFLICT between mobile and web
# ============================================================================

Pre Setup Schedule For Week 2 SM1Store2
    [Documentation]    Schedule setup for Week 2 for Store2.
    ...    Employees: ESS4_STORE2, ESS6_STORE2, ESS5_STORE2 (from mobile)
    ${smuser}    Get User    SM1_STORE2
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=2_0
    ...    week_offset=2_0    _date_format=${resultant_date_format}
    ${ess4_store2}    Get Employee Shift Setup Data    template_name=add012_standard8_addunallocate3    ess_user_key=ESS4_STORE2
    ${ess6_store2}    Get Employee Shift Setup Data    template_name=add012_standard8_addunallocate3    ess_user_key=ESS6_STORE2
    ${ess5_store2}    Get Employee Shift Setup Data    template_name=add123_standard8_addunallocate06    ess_user_key=ESS5_STORE2
    VAR    @{employee_operations}    ${ess4_store2}    ${ess6_store2}    ${ess5_store2}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 3 - STORE 1 (SM1_STORE1) — mobile and web
# ============================================================================

Pre Setup Schedule For Week 3 SM1Store1
    [Documentation]    Schedule setup for Week 3 for Store1.
    ...    Workflow: generate_and_publish_schedule
    ...    Employees: Union of mobile (ESS4) and web (ESS4, ESS5, ESS6).
    ${smuser}    Get User    SM1_STORE1
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=3_0
    ...    week_offset=3_0    _date_format=${resultant_date_format}
    ${ess4_store1}    Get Employee Shift Setup Data    template_name=add012_standard8    ess_user_key=ESS4_STORE1
    ${ess5_store1}    Get Employee Shift Setup Data    template_name=add123_standard8_addunallocate6    ess_user_key=ESS5_STORE1
    ${ess6_store1}    Get Employee Shift Setup Data    template_name=add012_standard8    ess_user_key=ESS6_STORE1
    VAR    @{employee_operations}    ${ess4_store1}    ${ess5_store1}    ${ess6_store1}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 3 - STORE 2 (SM1_STORE2) — CONFLICT between mobile and web
# ============================================================================

Pre Setup Schedule For Week 3 SM1Store2
    [Documentation]    Schedule setup for Week 3 for Store2.
    ...    Employees: Union of mobile (ESS5, ESS6) and web (ESS4).
    ${smuser}    Get User    SM1_STORE2
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=3_0
    ...    week_offset=3_0    _date_format=${resultant_date_format}
    # Web employee
    ${ess4_store2}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS4_STORE2
    # Mobile employees
    ${ess6_store2}    Get Employee Shift Setup Data    template_name=add012_standard8_addunallocate3    ess_user_key=ESS6_STORE2
    ${ess5_store2}    Get Employee Shift Setup Data    template_name=add12_standard8_addunallocate06    ess_user_key=ESS5_STORE2
    VAR    @{employee_operations}    ${ess4_store2}    ${ess6_store2}    ${ess5_store2}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 4 - STORE 2 (SM1_STORE2) — Web Only
# ============================================================================

Pre Setup Schedule For Week 4 SM1Store2
    [Documentation]    Schedule setup for Week 4 for Store2.
    ...    Employees: ESS6_STORE2, ESS5_STORE2 (from mobile)
    ${smuser}    Get User    SM1_STORE2
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=no_schedule_generation    week_start_date=4_0
    ...    week_offset=4_0    _date_format=${resultant_date_format}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 5 - STORE 1 (SM1_STORE1) — Web only
# ============================================================================

Pre Setup Schedule For Week 5 SM1Store1
    [Documentation]    Schedule setup for Week 5 for Store1.
    ...    Workflow: generate_and_publish_schedule
    ...    Employees: ESS4_STORE1
    ${smuser}    Get User    SM1_STORE1
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=5_0
    ...    week_offset=5_0    _date_format=${resultant_date_format}
    ${ess4_store1}    Get Employee Shift Setup Data    template_name=add012_standard8    ess_user_key=ESS4_STORE1
    VAR    @{employee_operations}    ${ess4_store1}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 5 - STORE 2 (SM1_STORE2) — Mobile only
# ============================================================================

Pre Setup Schedule For Week 5 SM1Store2
    [Documentation]    Schedule setup for Week 5 for Store2.
    ...    Workflow: generate_and_publish_schedule
    ...    Employees: ESS5_STORE2, ESS6_STORE2
    ${smuser}    Get User    SM1_STORE2
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=5_0
    ...    week_offset=5_0    _date_format=${resultant_date_format}
    ${ess5_store2}    Get Employee Shift Setup Data    template_name=add12_standard8_addunallocate06    ess_user_key=ESS5_STORE2
    ${ess6_store2}    Get Employee Shift Setup Data    template_name=add12_standard8_addunallocate06    ess_user_key=ESS6_STORE2
    VAR    @{employee_operations}    ${ess5_store2}    ${ess6_store2}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 6 - STORE 1 (SM1_STORE1) — mobile and web
# ============================================================================

Pre Setup Schedule For Week 6 SM1Store1
    [Documentation]    Schedule setup for Week 6 for Store1.
    ...    Workflow: only_generate_schedule
    ...    Employees: Union of mobile (none) and web (ESS1-6 all no_shifts_assigned).
    ${smuser}    Get User    SM1_STORE1
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=6_0
    ...    week_offset=6_0    _date_format=${resultant_date_format}
    ${ess1_store1}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS1_STORE1
    ${ess2_store1}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS2_STORE1
    ${ess3_store1}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS3_STORE1
    ${ess4_store1}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS4_STORE1
    ${ess5_store1}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS5_STORE1
    ${ess6_store1}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS6_STORE1
    VAR    @{employee_operations}
    ...    ${ess1_store1}
    ...    ${ess2_store1}
    ...    ${ess3_store1}
    ...    ${ess4_store1}
    ...    ${ess5_store1}
    ...    ${ess6_store1}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 7 - STORE 1 (SM1_STORE1) — Web only
# ============================================================================

Pre Setup Schedule For Week 7 SM1Store1
    [Documentation]    Schedule setup for Week 7 for Store1.
    ...    Workflow: only_generate_schedule (generated but not published)
    ...    Employees: none
    ${smuser}    Get User    SM1_STORE1
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=7_0
    ...    week_offset=7_0    _date_format=${resultant_date_format}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 8 - STORE 1 (SM1_STORE1) — mobile and web
# ============================================================================

Pre Setup Schedule For Week 8 SM1Store1
    [Documentation]    Schedule setup for Week 8 for Store1.
    ...    Workflow: no_schedule_generation (no generation, no modifications, not published)
    ...    Employees: none
    ${smuser}    Get User    SM1_STORE1
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=no_schedule_generation    week_start_date=8_0
    ...    week_offset=8_0    _date_format=${resultant_date_format}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# WEEK 9 - STORE 2 (SM1_STORE2) — mobile only
# ============================================================================

Pre Setup Schedule For Week 9 SM1Store2
    [Documentation]    Schedule setup for Week 9 for Store2.
    ...    Workflow: only_generate_schedule
    ...    Employees: ESS4, ESS5, ESS1.
    ${smuser}    Get User    SM1_STORE2
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=9_0
    ...    week_offset=9_0    _date_format=${resultant_date_format}
    ${ess1_store2}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS1_STORE2
    ${ess4_store2}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS4_STORE2
    ${ess5_store2}    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS5_STORE2
    VAR    @{employee_operations}    ${ess1_store2}    ${ess4_store2}    ${ess5_store2}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 3 SM1Store12
    [Documentation]    Schedule setup for Week 3 for Store12.
    ...    Workflow: generate_and_publish_schedule (forecast/workload, generate, publish, per-associate shift edits).
    ...    Employees: ESS1_STORE12 to ESS7_STORE12 use employee_shift_setup sit_mobile_* (odd=morning_7hr, even=standard_8hr)
    ${smuser}    Get User    SM1_STORE12
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=3_0
    ...    week_offset=3_0    _date_format=${resultant_date_format}
    ${ess1_store12}    Get Employee Shift Setup Data    template_name=sit_mobile_ess1_store12    ess_user_key=ESS1_STORE12
    ${ess2_store12}    Get Employee Shift Setup Data    template_name=sit_mobile_ess2_store12    ess_user_key=ESS2_STORE12
    ${ess3_store12}    Get Employee Shift Setup Data    template_name=sit_mobile_ess3_store12    ess_user_key=ESS3_STORE12
    ${ess4_store12}    Get Employee Shift Setup Data    template_name=sit_mobile_ess4_store12    ess_user_key=ESS4_STORE12
    ${ess5_store12}    Get Employee Shift Setup Data    template_name=sit_mobile_ess5_store12    ess_user_key=ESS5_STORE12
    ${ess6_store12}    Get Employee Shift Setup Data    template_name=sit_mobile_ess6_store12    ess_user_key=ESS6_STORE12
    ${ess7_store12}    Get Employee Shift Setup Data    template_name=sit_mobile_ess7_store12    ess_user_key=ESS7_STORE12
    VAR    @{employee_operations}
    ...    ${ess1_store12}
    ...    ${ess2_store12}
    ...    ${ess3_store12}
    ...    ${ess4_store12}
    ...    ${ess5_store12}
    ...    ${ess6_store12}
    ...    ${ess7_store12}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# VDI WORKLOAD TESTS - STORE 7 (SM1_STORE7_SIT) - PW#1 (unpublished)
# ============================================================================

Pre Setup Schedule For Week 1 SM1 Store7 SIT
    [Documentation]    Schedule setup for Week 1 for Store7 SIT (unpublished).
    ...    Workflow: Delete and Generate all schedules for VDI workload test
    ...    VDI Import: 1FTE from 10a to 6p for Day 2 to Day 6
    ...    Schedule: Unpublished
    ${smuser}    Get User    SM1_STORE7_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=1_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE7_SIT Week 1: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=1_0
    ...    week_offset=1_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# VDI WORKLOAD TESTS - STORE 7 (SM1_STORE7_SIT) - PW#2 (unpublished)
# ============================================================================

Pre Setup Schedule For Week 2 SM1 Store7 SIT
    [Documentation]    Schedule setup for Week 2 for Store7 SIT (unpublished).
    ...    Workflow: Delete and Generate all schedules for VDI workload test
    ...    VDI Import: 1FTE from 10a to 6p for Day 2 to Day 6
    ...    Schedule: Unpublished
    ${smuser}    Get User    SM1_STORE7_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=2_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE7_SIT Week 2: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=2_0
    ...    week_offset=2_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# VDI WORKLOAD TESTS - STORE 8 (SM1_STORE8_SIT) - PW#1 (template base)
# ============================================================================

Pre Setup Schedule For Week 1 SM1 Store8 SIT
    [Documentation]    Schedule setup for Week 1 for Store8 SIT.
    ...    Workflow: Template base schedule generation for VDI workload test
    ...    VDI Import: 1FTE from 10a to 6p for Day 2 to Day 6
    ...    Employees: Schedule generated with template base
    ...
    ...    TEST: SITTC80005
    ${smuser}    Get User    SM1_STORE8_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=1_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE8_SIT Week 1 (template-based): ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=1_0
    ...    week_offset=1_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}    schedule_gen_type=N

# ============================================================================
# VDI WORKLOAD TESTS - STORE 8 (SM1_STORE8_SIT) - PW#2 (optimized)
# ============================================================================

Pre Setup Schedule For Week 2 SM1 Store8 SIT
    [Documentation]    Schedule setup for Week 2 for Store8 SIT.
    ...    Workflow: Optimized schedule generation for VDI workload test
    ...    VDI Import: 1FTE from 10a to 6p for Day 2 to Day 6
    ...    Employees: Schedule generated with optimized approach
    ...
    ...    TEST: SITTC80006
    ${smuser}    Get User    SM1_STORE8_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=2_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE8_SIT Week 1 (optimized): ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=2_0
    ...    week_offset=2_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# VDI WORKLOAD TESTS - STORE 9 (SM1_STORE9_SIT) - PW#1
# ============================================================================

Pre Setup Schedule For Week 1 SM1 Store9 SIT
    [Documentation]    Schedule setup for Week 1 for Store9 SIT.
    ...    Workflow: Delete and Generate all schedules for VDI workload test
    ...    VDI Import: 1FTE from 10a to 6p for Day 2 to Day 6
    ...    Employees: Schedule generated with default shifts
    ${smuser}    Get User    SM1_STORE9_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=1_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE9_SIT Week 1: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=1_0
    ...    week_offset=1_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# VDI WORKLOAD TESTS - STORE 9 (SM1_STORE9_SIT) - PW#2
# ============================================================================

Pre Setup Schedule For Week 2 SM1 Store9 SIT
    [Documentation]    Schedule setup for Week 2 for Store9 SIT.
    ...    Workflow: Please Select for VDI workload test
    ...    VDI Import: 1FTE from 10a to 6p for Day 2 to Day 6
    ...    Employees: Schedule generated with default shifts
    ${smuser}    Get User    SM1_STORE9_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=2_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE9_SIT Week 2: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=2_0
    ...    week_offset=2_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# VDI WORKLOAD TESTS - STORE 10 (SM1_STORE10_SIT) - PW#1
# ============================================================================

Pre Setup Schedule For Week 1 SM1 Store10 SIT
    [Documentation]    Schedule setup for Week 1 for Store10 SIT.
    ...    Workflow: Delete and Generate all schedules for VDI workload test
    ...    VDI Import: 1FTE from 10a to 6p for Day 2 to Day 6
    ...    Employees: Schedule generated with default shifts
    ${smuser}    Get User    SM1_STORE10_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=1_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE10_SIT Week 1: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=1_0
    ...    week_offset=1_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# VDI WORKLOAD TESTS - STORE 10 (SM1_STORE10_SIT) - PW#2
# ============================================================================

Pre Setup Schedule For Week 2 SM1 Store10 SIT
    [Documentation]    Schedule setup for Week 2 for Store10 SIT.
    ...    Workflow: Delete and Generate all schedules for VDI workload test
    ...    VDI Import: 1FTE from 10a to 6p for Day 2 to Day 6
    ...    Employees: Schedule generated with default shifts
    ${smuser}    Get User    SM1_STORE10_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=2_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE10_SIT Week 2: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=2_0
    ...    week_offset=2_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# VDI WORKLOAD - UNIT ATTRIBUTE REGENERATION (Store6-9 SIT, PW#3-6)
# Used by SITTC80011-80014 (SC_1.robot). Each keyword generates the 1FTE
# 10a-6p (Day 2-6) base workload and an unedited, unpublished schedule for one
# store/week. Days 0 (Sunday) and 6 (Saturday) are skipped. The four stores in
# the same planning week (Store6-9) form one unit-attribute regeneration test.
# ============================================================================

Pre Setup Schedule For Week 3 SM1 Store6 SIT
    [Documentation]    Schedule setup for Week 3 for Store6 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE006.
    ...
    ...    TEST: SITTC80011
    ${smuser}    Get User    SM1_STORE6_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=3_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE6_SIT Week 3: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=3_0
    ...    week_offset=3_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 3 SM1 Store7 SIT
    [Documentation]    Schedule setup for Week 3 for Store7 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE007.
    ...
    ...    TEST: SITTC80011
    ${smuser}    Get User    SM1_STORE7_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=3_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE7_SIT Week 3: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=3_0
    ...    week_offset=3_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 3 SM1 Store8 SIT
    [Documentation]    Schedule setup for Week 3 for Store8 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE008.
    ...
    ...    TEST: SITTC80011
    ${smuser}    Get User    SM1_STORE8_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=3_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE8_SIT Week 3: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=3_0
    ...    week_offset=3_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 3 SM1 Store9 SIT
    [Documentation]    Schedule setup for Week 3 for Store9 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE009.
    ...
    ...    TEST: SITTC80011
    ${smuser}    Get User    SM1_STORE9_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=3_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE9_SIT Week 3: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=3_0
    ...    week_offset=3_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 4 SM1 Store6 SIT
    [Documentation]    Schedule setup for Week 4 for Store6 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE006.
    ...
    ...    TEST: SITTC80012
    ${smuser}    Get User    SM1_STORE6_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=4_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE6_SIT Week 4: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=4_0
    ...    week_offset=4_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 4 SM1 Store7 SIT
    [Documentation]    Schedule setup for Week 4 for Store7 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE007.
    ...
    ...    TEST: SITTC80012
    ${smuser}    Get User    SM1_STORE7_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=4_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE7_SIT Week 4: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=4_0
    ...    week_offset=4_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 4 SM1 Store8 SIT
    [Documentation]    Schedule setup for Week 4 for Store8 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE008.
    ...
    ...    TEST: SITTC80012
    ${smuser}    Get User    SM1_STORE8_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=4_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE8_SIT Week 4: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=4_0
    ...    week_offset=4_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 4 SM1 Store9 SIT
    [Documentation]    Schedule setup for Week 4 for Store9 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE009.
    ...
    ...    TEST: SITTC80012
    ${smuser}    Get User    SM1_STORE9_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=4_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE9_SIT Week 4: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=4_0
    ...    week_offset=4_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 5 SM1 Store6 SIT
    [Documentation]    Schedule setup for Week 5 for Store6 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE006.
    ...
    ...    TEST: SITTC80013
    ${smuser}    Get User    SM1_STORE6_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=5_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE6_SIT Week 5: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=5_0
    ...    week_offset=5_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 5 SM1 Store7 SIT
    [Documentation]    Schedule setup for Week 5 for Store7 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE007.
    ...
    ...    TEST: SITTC80013
    ${smuser}    Get User    SM1_STORE7_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=5_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE7_SIT Week 5: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=5_0
    ...    week_offset=5_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 5 SM1 Store8 SIT
    [Documentation]    Schedule setup for Week 5 for Store8 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE008.
    ...
    ...    TEST: SITTC80013
    ${smuser}    Get User    SM1_STORE8_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=5_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE8_SIT Week 5: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=5_0
    ...    week_offset=5_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 5 SM1 Store9 SIT
    [Documentation]    Schedule setup for Week 5 for Store9 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE009.
    ...
    ...    TEST: SITTC80013
    ${smuser}    Get User    SM1_STORE9_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=5_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE9_SIT Week 5: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    PLEASE_SELECT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=5_0
    ...    week_offset=5_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 6 SM1 Store6 SIT
    [Documentation]    Schedule setup for Week 6 for Store6 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE006.
    ...
    ...    TEST: SITTC80014
    ${smuser}    Get User    SM1_STORE6_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=6_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE6_SIT Week 6: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=6_0
    ...    week_offset=6_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 6 SM1 Store7 SIT
    [Documentation]    Schedule setup for Week 6 for Store7 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE007.
    ...
    ...    TEST: SITTC80014
    ${smuser}    Get User    SM1_STORE7_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=6_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE7_SIT Week 6: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=6_0
    ...    week_offset=6_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 6 SM1 Store8 SIT
    [Documentation]    Schedule setup for Week 6 for Store8 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE008.
    ...
    ...    TEST: SITTC80014
    ${smuser}    Get User    SM1_STORE8_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=6_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE8_SIT Week 6: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=6_0
    ...    week_offset=6_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Pre Setup Schedule For Week 6 SM1 Store9 SIT
    [Documentation]    Schedule setup for Week 6 for Store9 SIT (VDI unit-attribute regeneration tests).
    ...    Workflow: Delete and Generate all schedules. Generates 1FTE 10a-6p workload for Day 2 to Day 6
    ...    (Days 1 & 7 skipped) and an unedited, unpublished schedule for unit ZSITSTORE009.
    ...
    ...    TEST: SITTC80014
    ${smuser}    Get User    SM1_STORE9_SIT
    VAR    ${store_id}    ${smuser}[unitID]
    # Keep VDI data declarative; upload keyword builds interval array from template times.
    ${vdi_import_data}    Get VDI Import Data    template_name=vdi_import_schedule_regeneration_sit    week_start_date=6_0
    ${vdi_metric_id}    Get System Value    VDIMetricId    VDI_METRIC_ID_1
    ${vdi_activity_name}    Get System Value    VDIActivity    VDI_ACTIVITY_1
    Set To Dictionary    ${vdi_import_data}    unit_id=${store_id}    metric_id=${vdi_metric_id}    activity_name=${vdi_activity_name}
    ...    driver_start_time=10:00    driver_end_time=18:00    skip_days=[0, 6]
    ${vdi_upload_file_path}    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Log    Custom VDI file generated for SM1_STORE9_SIT Week 6: ${vdi_upload_file_path}    level=INFO
    ${vdi_schedule_regeneration}    Get System Value    VDI_Schedule_Regeneration    DELETE_AND_GENERATE_ALL_SCHEDULES
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=6_0
    ...    week_offset=6_0    _date_format=${resultant_date_format}    vdi_schedule_regeneration=${vdi_schedule_regeneration}
    Set To Dictionary    ${workflow}    vdi_upload_file_path=${vdi_upload_file_path}
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Extract Day Numbers From Shift Data
    [Documentation]
    ...    Extracts shift day numbers from employee shift setup data.
    ...    This allows tests to define days once in shift data and reuse the same day list for
    ...    hour verifications without repeating hardcoded day arguments.
    ...    | =Arguments= | =Description= |
    ...    | employee_shift_data | Employee shift setup dictionary that may contain `shifts_to_add` at the top level or inside `users`. |
    ...
    ...    *Returns*: List of day numbers found in the shift data.
    [Arguments]    ${employee_shift_data}
    VAR    @{day_numbers}    @{EMPTY}
    ${users}    Get From Dictionary    ${employee_shift_data}    users    default=@{EMPTY}
    FOR    ${user}    IN    @{users}
        ${user_shifts}    Get From Dictionary    ${user}    shifts_to_add    default=@{EMPTY}
        FOR    ${shift}    IN    @{user_shifts}
            ${day_no}    Get From Dictionary    ${shift}    dayNo    default=${EMPTY}
            IF    '${day_no}' != ''
                Append To List    ${day_numbers}    ${day_no}
            END
        END
    END
    ${top_level_shifts}    Get From Dictionary    ${employee_shift_data}    shifts_to_add    default=@{EMPTY}
    FOR    ${shift}    IN    @{top_level_shifts}
        ${day_no}    Get From Dictionary    ${shift}    dayNo    default=${EMPTY}
        IF    '${day_no}' != ''    Append To List    ${day_numbers}    ${day_no}
    END
    RETURN    @{day_numbers}

# ============================================================================
# WEEK 3 - STORE 3 (SIT_STORE1) — Web only
# ============================================================================

Pre Setup Schedule For Week 3 SM1Store1 SIT
    [Documentation]    Schedule setup for Week 3 for SIT Store1.
    ...    Workflow: generate_and_publish_schedule
    ...    Employees: ESS7_STORE1_SIT, ESS8_STORE1_SIT, ESS16_STORE1_SIT, ESS17_STORE1_SIT
    ${smuser}    Get User    SM1_STORE1_SIT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=3_0
    ...    week_offset=3_0    _date_format=${resultant_date_format}
    ${ess7_store1_sit}    Get Employee Shift Setup Data    template_name=add_weekdays_late_morning_7hr
    ${ess8_store1_sit}    Get Employee Shift Setup Data    template_name=add_weekdays_until_evening_7hr
    ${ess16_store1_sit}    Get Employee Shift Setup Data    template_name=add_weekdays_afternoon_7hr
    ${ess17_store1_sit}    Get Employee Shift Setup Data    template_name=add_weekdays_evening_7hr
    VAR    @{employee_operations}    ${ess7_store1_sit}    ${ess8_store1_sit}    ${ess16_store1_sit}    ${ess17_store1_sit}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# PLANNING WEEK 1 - SIT_STORE1 — Mobile SIT only
# ============================================================================

Pre Setup Schedule For Week 1 SM1Store1 SIT
    [Documentation]    Schedule setup for Mobile SIT Store1 on planning week 1 (PW#1).
    ...    Workflow: generate_and_publish_schedule
    ...    Employees: ESS7_STORE1_SIT, ESS8_STORE1_SIT, ESS16_STORE1_SIT, ESS17_STORE1_SIT
    ...    Used by tests/sit/shift_trade_individual_swap_decline_withdraw_reswap.robot (SITTC70003) and tests/sit/shift_trade_all_eligible_swap_decline_accept.robot (SITTC70004).
    ...    (planning week 1), not the current calendar week.
    ...    Web suites use Pre Setup Schedule For Week 3 SM1Store1 SIT on week 3_0.
    ${smuser}    Get User    SM1_STORE1_SIT
    ${resultant_date_format}    Get Config Value    SERVER_DF
    ${workflow}    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=1_0
    ...    week_offset=1_0    _date_format=${resultant_date_format}
    ${ess7_store1_sit}    Get Employee Shift Setup Data    template_name=add_weekdays_late_morning_7hr
    ${ess8_store1_sit}    Get Employee Shift Setup Data    template_name=add_weekdays_until_evening_7hr
    ${ess16_store1_sit}    Get Employee Shift Setup Data    template_name=add_weekdays_afternoon_7hr
    ${ess17_store1_sit}    Get Employee Shift Setup Data    template_name=add_weekdays_evening_7hr
    VAR    @{employee_operations}    ${ess7_store1_sit}    ${ess8_store1_sit}    ${ess16_store1_sit}    ${ess17_store1_sit}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# PLANNING WEEK 6 - SIT_STORE14 — Mobile SIT only
# ============================================================================

Pre Setup Schedule For Week 6 SM1Store14 SIT
    [Documentation]    Schedule setup for Mobile SIT Store14 on planning week 6 (PW#6).
    ...    Workflow: only_generate_schedule
    ...    Employees: ESS17_STORE14
    ...    Used by tests/sit/cross_shift_bidding_generate_schedule_store14_store15_week6_week7_week8.robot (SITTC60074),(SITTC60075),(SITTC60076).
    ...    (planning week 6), not the current calendar week.
    ${smuser}    Get User    SM1_STORE14
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=6_0
    ...    week_offset=6_0    _date_format=%Y%m%d
    ${ess17_store14}    Get Employee Shift Setup Data    template_name=sit_mobile_ess17_store14
    VAR    @{employee_operations}    ${ess17_store14}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# PLANNING WEEK 7 - SIT_STORE14 — Mobile SIT only
# ============================================================================

Pre Setup Schedule For Week 7 SM1Store14 SIT
    [Documentation]    Schedule setup for Week 7 for Store14.
    ...    Workflow: only_generate_schedule (generated but not published)
    ...    Employees: none
    ...    Used by (SITTC60074).
    ...    (planning week 7), not the current calendar week.
    ${smuser}    Get User    SM1_STORE14
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=7_0
    ...    week_offset=7_0    _date_format=%Y%m%d
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# PLANNING WEEK 8 - SIT_STORE14 — Mobile SIT only
# ============================================================================

Pre Setup Schedule For Week 8 SM1Store14 SIT
    [Documentation]    Schedule setup for Week 8 for Store14.
    ...    Workflow: only_generate_schedule (generated but not published)
    ...    Employees: none
    ...    Used by (SITTC60074).
    ...    (planning week 8), not the current calendar week.
    ${smuser}    Get User    SM1_STORE14
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=8_0
    ...    week_offset=8_0    _date_format=%Y%m%d
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# PLANNING WEEK 6 - SIT_STORE15 — Mobile SIT only
# ============================================================================

Pre Setup Schedule For Week 6 SM1Store15 SIT
    [Documentation]    Schedule setup for Mobile SIT Store15 on planning week 6 (PW#6).
    ...    Workflow: only_generate_schedule
    ...    Employees: ESS17_STORE15
    ...    Used by (SITTC60074) and (SITTC60075).
    ...    (planning week 6), not the current calendar week.
    ${smuser}    Get User    SM1_STORE15
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=6_0
    ...    week_offset=6_0    _date_format=%Y%m%d
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# PLANNING WEEK 7 - SIT_STORE15 — Mobile SIT only
# ============================================================================

Pre Setup Schedule For Week 7 SM1Store15 SIT
    [Documentation]    Schedule setup for Week 7 for Store15.
    ...    Workflow: only_generate_schedule (generated but not published)
    ...    Employees: none
    ...    Used by (SITTC60074).
    ...    (planning week 7), not the current calendar week.
    ${smuser}    Get User    SM1_STORE15
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=7_0
    ...    week_offset=7_0    _date_format=%Y%m%d
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

# ============================================================================
# PLANNING WEEK 8 - SIT_STORE15 — Mobile SIT only
# ============================================================================

Pre Setup Schedule For Week 8 SM1Store15 SIT
    [Documentation]    Schedule setup for Week 8 for Store15.
    ...    Workflow: only_generate_schedule (generated but not published)
    ...    Employees: none
    ...    Used by (SITTC60074).
    ...    (planning week 8), not the current calendar week.
    ${smuser}    Get User    SM1_STORE15
    ${workflow}    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=8_0
    ...    week_offset=8_0    _date_format=%Y%m%d
    VAR    @{employee_operations}    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}
