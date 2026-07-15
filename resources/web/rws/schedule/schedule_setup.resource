*** Settings ***
Documentation       Schedule Setup Keywords for L2 Suite
...
...                 This resource file contains reusable keywords for schedule setup across multiple weeks.
...                 These keywords are used by:
...                 1. L2 Suite Setup (tests/web/l2_suite/__init__.robot) - Executed in Suite Setup BEFORE any tests
...                 2. Schedule Setup Test Cases (tests/web/l2_suite/rws/schedule/00_Schedule_setup_test.robot)
...
...                 The keywords handle schedule data creation for weeks: 0_0, 1_0, 2_0, 3_0, 5_0, 7_0
...
...                 **NEW PARAMETERIZED APPROACH:**
...                 Use 'Setup Schedule For Week' with template_name parameter instead of individual week keywords.
...                 Example: Setup Schedule For Week    template_name=3_0_sm1_store1
...
...                 **SUPPORTED TEMPLATE NAMES:**
...                 - 0_0_sm1_store1: Week 0 (current week) with Store1
...                 - 0_0_store2: Week 0 for Store2
...                 - 1_0_sm1_store1: Week 1 (next week) with Store1
...                 - 1_0_sm1_store2: Week 1 for Store2
...                 - 2_0_sm1_store1: Week 2 with Store1
...                 - 3_0_sm1_store1: Week 3 with Store1
...                 - 4_0_sm1store2: Week 4 for Store2 (new hire setup)
...                 - 5_0_sm1_store1: Week 5 with Store1
...                 - 6_0_sm1_store1: Week 6 with Store1 (not published)
...                 - 7_0_sm1_store1: Week 7 with Store1 (not published, no modifications)
...                 - 8_0_sm1_store1: Week 8 with Store1 (no generation, no modifications, not published)

Resource            resources/web/rws/schedule/batch_plan_status.resource
Resource            resources/web/rws/schedule/schedule.resource
Resource            resources/web/om/unit_db.resource
Resource            resources/web/rws/admin/rws_upload_api.resource
Resource            resources/web/rws/employee/roster_db.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource
Resource            resources/web/rws/admin/rfp_upload.resource


*** Keywords ***
Setup Schedule For Week
    [Documentation]
    ...    DEPRECATED: Use 'New Setup Schedule For Week' with template_name parameter instead.
    ...    Parameterized keyword for schedule setup across multiple weeks and stores
    ...
    ...    This is the new unified keyword that replaces all individual week setup keywords.
    ...    It uses template-driven configuration to handle all schedule setup scenarios.
    ...
    ...    **Arguments:**
    ...    - template_name: Template identifier that maps to specific week and store configuration
    ...    - **options: Additional options to override template defaults (optional)
    ...
    ...    **Template Naming Convention:**
    ...    Format: {week}_{variation}_{manager}_{store}
    ...    - week: 0,1,2,3,4,5,6,7,8 (week number)
    ...    - variation: 0 (default), can be extended for variations
    ...    - manager: sm1 (store manager 1)
    ...    - store: store1, store2, sm1store2, etc.
    ...
    ...    **Process:**
    ...    1. Load template configuration from TestDataLibrary
    ...    2. Extract store data and schedule options
    ...    3. Call 'Setup Schedule For Week With Multiple Associates' with template data
    ...    4. Handle all week-specific scenarios: generation, publishing, shift modifications
    ...
    ...    **Examples:**
    ...    | Setup Schedule For Week | template_name=0_0_sm1_store1 |
    ...    | Setup Schedule For Week | template_name=3_0_sm1_store1 |
    ...    | Setup Schedule For Week | template_name=0_0_store2 | is_dynamic_user=${True} |
    ...
    ...    **Supported Templates:**
    ...    See documentation header for complete list of supported template names.
    [Arguments]    ${template_name}    &{options}

    # Validate template_name parameter
    IF    '${template_name}' == '${EMPTY}' or '${template_name}' == 'None'
        Fail    template_name parameter is required and cannot be empty
    END

    # Get template data from TestDataLibrary
    TRY
        ${setup_data}=    Get Schedule Generation Setup Data    template_name=${template_name}
        ${store_data}=    Get Store Data    template_name=${setup_data}[store_template]
    EXCEPT    AS    ${error}
        Fail    Invalid template_name '${template_name}': ${error}
    END

    # Prepare schedule options from template with optional overrides
    VAR    &{schedule_options}=
    ...    publish_schedule=${setup_data}[publish_schedule]
    ...    generate_schedule=${setup_data}[generate_schedule]
    ...    modify_shifts_required=${setup_data}[modify_shifts_required]
    ...    pre_publish_un_allocation=${setup_data}[pre_publish_un_allocation]

    # Apply any additional options passed by caller
    FOR    ${key}    ${value}    IN    &{options}
        Set To Dictionary    ${schedule_options}    ${key}    ${value}
    END

    # Log the setup being performed
    Log    Setting up schedule for template: ${template_name}    level=INFO
    Log    Store: ${store_data}[store_id], Week: ${setup_data}[week_start_date]    level=INFO
    Log    Options: ${schedule_options}    level=DEBUG

    # Execute the actual schedule setup
    Setup Schedule For Week With Multiple Associates
    ...    store_id=${store_data}[store_id]
    ...    week_start_date=${setup_data}[week_start_date]
    ...    store_manager_user_key=${setup_data}[store_manager_user_key]
    ...    users=${setup_data}[users]
    ...    schedule_options=&{schedule_options}

# ========================================
# MIGRATION REQUIRED - BREAKING CHANGE
# ========================================
# All individual week keywords have been removed. Use the parameterized approach:
#
# OLD: Setup Schedule For Week 0
# NEW: Setup Schedule For Week    template_name=0_0_sm1_store1
#
# OLD: Setup Schedule For Week 0-Store2
# NEW: Setup Schedule For Week    template_name=0_0_store2    is_dynamic_user=${True}
#
# See SCHEDULE_SETUP_PARAMETERIZATION_GUIDE.md for complete migration mapping.

Pre Setup Store Schedule For Week
    [Documentation]
    ...    This keyword sets up the schedule for a given store and week based on provided parameters.
    ...    It handles forecast generation, workload generation, schedule generation, publishing, and shift modifications
    ...    for multiple associates as specified.
    ...    1. First, it checks the current schedule status from state machine for the store and week.
    ...    2. It generates forecast and workload if not already generated.
    ...    3. If a schedule exists and is not week in progress, it deletes the existing schedule.
    ...    4. It generates a new schedule if specified in workflow actions.
    ...    5. If setup is for current week (0_0) and schedule is not already in week in progress, it publishes the schedule and generates week in progress schedule.
    ...    6. Finally, it performs shift setup operations for each associate as specified in employee operations.
    ...    7. If specified in workflow actions, it publishes the schedule after all modifications.
    ...    | =Arguments= | =Description= |
    ...    | smuser | Store manager user details. |
    ...    | workflow_details | Workflow configuration dictionary. |
    ...    | employee_operations | List of employee shift operations. |
    ...    | schedule_gen_type | Optional override (Y=optimized, N=template). When omitted uses config default. |
    [Arguments]    ${smuser}    ${workflow_details}    ${employee_operations}    ${schedule_gen_type}=${NONE}
    Log
    ...    Starting Schedule Setup for ${smuser}[unitID] week offset ${workflow_details}[week_offset] week start date ${workflow_details}[week_start_date]
    ...    console=yes
    ${is_dual}=    Get Config Value    DUO_SCHEDULE_GENERATION_ENABLED
    ${is_delete_weekplan_enabled}=    Is Config Enabled    delete_weekplan_data
    IF    ${is_delete_weekplan_enabled}
        Delete Week Plan Via Servlet And Generate Forecast    ${smuser}    ${workflow_details}
    END
    ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]    ${smuser}[unitID]
    ...    ${workflow_details}[week_start_date]
    Log    ${current_unit_status_map}
    ${should_use_vdi_workload}=    Should Use VDI Based Workload For Store    ${smuser}[unitID]
    IF    not ${should_use_vdi_workload}
        IF    not ${current_unit_status_map}[is_forecast_generated] and not ${current_unit_status_map}[is_schedule_week_in_progress] and ${current_unit_status_map}[can_generate_forecast]
            Log    Generating Forecast - can_generate_Forecast: ${current_unit_status_map}[can_generate_forecast]    console=yes
            Generate Forecast Via API And Wait For Completion New    ${smuser}[user_key]    ${smuser}[unitID]
            ...    ${workflow_details}[week_start_date]    ${workflow_details}[week_offset]
            ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
            ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
            Log    ${current_unit_status_map}
        END
    END
    IF    not ${current_unit_status_map}[is_workload_generated] and not ${current_unit_status_map}[is_schedule_week_in_progress]
        IF    ${should_use_vdi_workload} or ${current_unit_status_map}[can_generate_workload]
            Generate Workload Or Perform VDI Import    ${smuser}    ${workflow_details}
            ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
            ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
            Log    ${current_unit_status_map}
        ELSE
            Log    Skipping workload generation - can_generate_workload is False    console=yes
        END
    END

    ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
    ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]

    IF    ${current_unit_status_map}[is_schedule_generated] and not ${current_unit_status_map}[is_schedule_week_in_progress]
        Delete Existing Schedule Based On Current Status Via API    ${smuser}[user_key]    ${smuser}[unitID]
        ...    ${workflow_details}[week_start_date]    ${workflow_details}[week_offset]    ${current_unit_status_map}
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    ${current_unit_status_map}
    END
    IF    (${workflow_details}[generate_schedule] or ${is_dual}) and not ${current_unit_status_map}[is_schedule_week_in_progress]
        IF    not ${current_unit_status_map}[can_generate_schedule]
            Fail
            ...    Schedule cannot be generated for unit ${smuser}[unitID] week starting on ${workflow_details}[week_start_date]. API indicates generation is not allowed in current state.
        END
        Log    Generating Schedule - can_generate_schedule: ${current_unit_status_map}[can_generate_schedule]    console=yes
        Generate Schedule Via API And Wait For Completion New    ${smuser}[user_key]    ${smuser}[unitID]
        ...    ${workflow_details}[week_start_date]    ${schedule_gen_type}
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    ${current_unit_status_map}
    END
    IF    '${workflow_details}[week_offset]' == '0_0' and not ${current_unit_status_map}[is_schedule_week_in_progress] and not ${is_dual}
        # Week 0 WIP generation - only in first iteration for non-dual; dual mode defers this to second iteration
        Log    Generating Week In Progress Schedule for current week (0_0) - schedule is not already in progress    console=yes
        IF    ${current_unit_status_map}[can_lock_schedule]
            Lock Schedule Via API And Wait For Completion    ${smuser}[unitID]    ${workflow_details}[week_start_date]
            ...    ${smuser}[user_key]
        END
        Publish Schedule Via API    ${smuser}[unitID]    ${workflow_details}[week_offset]    ${smuser}[user_key]    MANAGER
        Generate Week In Progress Schedule And Wait For Completion    ${smuser}[user_key]    ${smuser}[unitID]
        ...    ${workflow_details}[week_start_date]
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    ${current_unit_status_map}
        Set To Dictionary    ${current_unit_status_map}    is_schedule_week_in_progress=${TRUE}
    END
    IF    not ${is_dual}
        ${store_details}=    Get Unit Details From UnitId Via DB    ${smuser}[unitID]
        ${gen_shift_id}=    Get Latest GenShiftId For Week Via API    ${smuser}[user_key]    ${store_details}[unit_skey]
        ...    ${workflow_details}[week_start_date]
        FOR    ${employee_operation}    IN    @{employee_operations}
            Log    ${employee_operation}
            Perform Shift Setup Operations By User For Week    ${smuser}[user_key]    ${smuser}[unitID]
            ...    ${workflow_details}[week_offset]    ${employee_operation}    ${gen_shift_id}
            Sleep    ${SHORT_TIMEOUT}  # Sleep added to handle any eventual consistency delay after shift setup operations before fetching status again
        END
    ELSE
        Log    Dual schedule enabled: skipping shift setup in first iteration. Shifts will be applied in the dual (second) pass only.
        ...    console=yes
    END
    # IF    not ${is_dual}
    ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]    ${smuser}[unitID]
    ...    ${workflow_details}[week_start_date]
    Log    Status map refreshed after shift operations: ${current_unit_status_map}
    IF    ${workflow_details}[publish_schedule] and not ${current_unit_status_map}[is_schedule_week_in_progress] and ${current_unit_status_map}[is_schedule_generated] and ${current_unit_status_map}[can_lock_schedule]
        Lock Schedule Via API And Wait For Completion    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        ...    ${smuser}[user_key]
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    Status map refreshed after lock: ${current_unit_status_map}
    END
    IF    ${workflow_details}[publish_schedule] and not ${current_unit_status_map}[is_schedule_week_in_progress] and ${current_unit_status_map}[is_schedule_generated] and ${current_unit_status_map}[can_publish_schedule]
        Publish Schedule Via API    ${smuser}[unitID]    ${workflow_details}[week_offset]    ${smuser}[user_key]    MANAGER
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    Status after publish: ${current_unit_status_map}
    END
    Log
    ...    Completed Schedule Setup for ${smuser}[unitID] week offset ${workflow_details}[week_offset] week start date ${workflow_details}[week_start_date]
    ...    console=yes
    # END
    IF    ${is_dual}
        Schedule Setup For Dual    ${smuser}    ${workflow_details}    ${employee_operations}    ${schedule_gen_type}
    END

Generate Workload Or Perform VDI Import
    [Documentation]
    ...    Handles workload generation for a store/week. If VDI import is enabled, performs the VDI
    ...    file upload (using a pre-generated custom file or generating from the default template).
    ...    For VDI-enabled flows, workload generation is additionally gated by DB config flag
    ...    (required for HNM/BP behavior). Otherwise falls back to standard API-based generation.
    ...    | =Arguments= | =Description= |
    ...    | smuser | Store manager user details. |
    ...    | workflow_details | Workflow configuration dictionary (must include week_start_date, week_offset). |
    [Arguments]    ${smuser}    ${workflow_details}
    ${should_use_vdi_workload}=    Should Use VDI Based Workload For Store    ${smuser}[unitID]
    ${should_delete_workload_store_based_vdi}=    Should Delete Workload For DB Driven VDI    ${smuser}[unitID]
    IF    ${should_delete_workload_store_based_vdi}
        Log    DB-driven VDI requires existing workload cleanup before VDI import.    console=yes
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Delete Existing Workload Based On Current Status Via API    ${smuser}[user_key]    ${smuser}[unitID]
        ...    ${workflow_details}[week_start_date]    ${workflow_details}[week_offset]    ${current_unit_status_map}
        Log    Existing workload cleanup completed. Proceeding with VDI import.    console=yes
    END
    IF    ${should_use_vdi_workload}
        Log    VDI Import is enabled. Performing VDI import before workload generation.
        ${vdi_regen}=    Get From Dictionary    ${workflow_details}    vdi_schedule_regeneration    default=NA
        ${custom_vdi_file}=    Get From Dictionary    ${workflow_details}    vdi_upload_file_path    default=${NONE}
        IF    $custom_vdi_file is not None
            Log    Using pre-generated custom VDI file: ${custom_vdi_file}    console=yes
            TRY
                Login And Launch WFM Web App    user_key=SYSADMIN
                Navigate To RWS Admin RFP Upload Page On Web
                Upload VDI File On Web    ${custom_vdi_file}    ${vdi_regen}
                Navigate To RWS Admin RFP Logs Page On Web
                Apply Filter And Select Latest Log File On RFP Logs Page    Volume Driver Interval Import
                Verify Log File Content On Web
            FINALLY
                Run Keyword And Ignore Error    Log Out From Web Application
                Run Keyword And Ignore Error    Close Browser
            END
        ELSE
            Perform VDI Import Operation    ${workflow_details}[week_start_date]    ${smuser}[unitID]
            ...    schedule_regeneration=${vdi_regen}
        END
        ${generate_workload_config_flag_status}=    Get Generate Workload Config Flag Status From Database
        ${should_gen_workload_post_vdi_import}=    Evaluate    ${generate_workload_config_flag_status} == 0
        IF    not ${should_gen_workload_post_vdi_import}
            Log    Skipping workload generation - Generate workload config flag is disabled
            RETURN
        END
    END
    Log    Generating workload - can_generate_workload flag is True    console=yes
    Generate Workload Via API And Wait For Completion New    ${smuser}[user_key]    ${smuser}[unitID]
    ...    ${workflow_details}[week_start_date]    ${workflow_details}[week_offset]

Schedule Setup For Dual
    [Documentation]
    ...    Sets up a second schedule pass for the Dual Schedule Generation scenario.
    ...    Follows the same pipeline as Pre Setup Store Schedule For Week with these differences:
    ...    1. Week plan deletion is SKIPPED (dual never wipes the plan).
    ...    2. Forecast is ALWAYS regenerated (even if already generated), unless week is in-progress.
    ...    3. Workload is ALWAYS regenerated (even if already generated), unless week is in-progress.
    ...    4. Existing schedule deletion is SKIPPED (the second generation runs on top of the first).
    ...    5. Schedule generation always runs when generate_schedule=True and not week-in-progress.
    ...    6. If setup is for current week (0_0) and schedule is not already in week in progress, it publishes the schedule and generates week in progress schedule.
    ...    7. Finally, it performs shift setup operations for each associate as specified in employee operations.
    ...    8. If specified in workflow actions, it publishes the schedule after all modifications.
    [Arguments]    ${smuser}    ${workflow_details}    ${employee_operations}    ${schedule_gen_type}=${NONE}
    Log
    ...    Starting Dual Schedule Setup for ${smuser}[unitID] week offset ${workflow_details}[week_offset] week start date ${workflow_details}[week_start_date]
    ...    console=yes
    ${should_use_vdi_workload}=    Should Use VDI Based Workload For Store    ${smuser}[unitID]
    ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]    ${smuser}[unitID]
    ...    ${workflow_details}[week_start_date]
    Log    ${current_unit_status_map}
    # ③ Forecast and ④ Workload — always regenerate unless WIP
    IF    not ${should_use_vdi_workload} and not ${current_unit_status_map}[is_schedule_week_in_progress] and ${current_unit_status_map}[can_generate_forecast]
        Log
        ...    Dual Schedule Forecast Generation: Generating forecast - can_generate_forecast: ${current_unit_status_map}[can_generate_forecast]
        ...    console=yes
        Generate Forecast Via API And Wait For Completion New    ${smuser}[user_key]    ${smuser}[unitID]
        ...    ${workflow_details}[week_start_date]    ${workflow_details}[week_offset]
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    ${current_unit_status_map}
    ELSE IF    ${should_use_vdi_workload} and not ${current_unit_status_map}[is_schedule_week_in_progress}
        Log    Skipping dual forecast generation because VDI workload flow is enabled for ${smuser}[unitID].    console=yes
    END
    IF    not ${current_unit_status_map}[is_schedule_week_in_progress] and ${current_unit_status_map}[can_generate_workload]
        # Workload — VDI path respected
        IF    ${should_use_vdi_workload}
            Log    VDI Import is enabled. Performing VDI import before workload generation.
            ${vdi_regen}=    Get From Dictionary    ${workflow_details}    vdi_schedule_regeneration    default=NA
            Perform VDI Import Operation    ${workflow_details}[week_start_date]    ${smuser}[unitID]    schedule_regeneration=${vdi_regen}
        ELSE
            Log
            ...    Dual Schedule Workload Generation: Generating workload - can_generate_workload: ${current_unit_status_map}[can_generate_workload]
            ...    console=yes
            Generate Workload Via API And Wait For Completion New    ${smuser}[user_key]    ${smuser}[unitID]
            ...    ${workflow_details}[week_start_date]    ${workflow_details}[week_offset]
        END
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    ${current_unit_status_map}
    END
    # ⑤ Schedule deletion — SKIPPED for dual schedule
    # ⑥ Generate schedule — always run if flag set and not WIP (second generation in dual)
    IF    ${workflow_details}[generate_schedule] and not ${current_unit_status_map}[is_schedule_week_in_progress]
        IF    not ${current_unit_status_map}[can_generate_schedule]
            Fail
            ...    Schedule cannot be generated for unit ${smuser}[unitID] week starting on ${workflow_details}[week_start_date]. API indicates generation is not allowed in current state.
        END
        Log    Dual Schedule Generation: Generating schedule - can_generate_schedule: ${current_unit_status_map}[can_generate_schedule]
        ...    console=yes
        Generate Schedule Via API And Wait For Completion New    ${smuser}[user_key]    ${smuser}[unitID]
        ...    ${workflow_details}[week_start_date]    ${schedule_gen_type}
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    ${current_unit_status_map}
    END
    # ⑦ Week-In-Progress for week 0 — Generate WIP BEFORE shift modifications (same as single schedule flow)
    IF    '${workflow_details}[week_offset]' == '0_0' and not ${current_unit_status_map}[is_schedule_week_in_progress] and ${current_unit_status_map}[is_schedule_generated]
        Log
        ...    Schedule validation passed - is_generated=${current_unit_status_map}[is_schedule_generated], can_publish=${current_unit_status_map}[can_publish_schedule]
        ...    console=yes
        IF    ${current_unit_status_map}[can_lock_schedule]
            Log    Lock schedule is enabled. Locking schedule before publication.    console=yes
            Lock Schedule Via API And Wait For Completion    ${smuser}[unitID]    ${workflow_details}[week_start_date]
            ...    ${smuser}[user_key]
        END
        Publish Schedule Via API    ${smuser}[unitID]    ${workflow_details}[week_offset]    ${smuser}[user_key]    MANAGER
        Log    Schedule published for week 0 in dual mode, generating Week In Progress schedule    console=yes
        Generate Week In Progress Schedule And Wait For Completion    ${smuser}[user_key]    ${smuser}[unitID]
        ...    ${workflow_details}[week_start_date]
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    ${current_unit_status_map}
        Set To Dictionary    ${current_unit_status_map}    is_schedule_week_in_progress=${TRUE}
    END
    # ⑧ Shift setup — performed AFTER WIP generation (same as normal flow)
    ${store_details}=    Get Unit Details From UnitId Via DB    ${smuser}[unitID]
    ${gen_shift_id}=    Get Latest GenShiftId For Week Via API    ${smuser}[user_key]    ${store_details}[unit_skey]
    ...    ${workflow_details}[week_start_date]
    FOR    ${employee_operation}    IN    @{employee_operations}
        Log    ${employee_operation}
        Perform Shift Setup Operations By User For Week    ${smuser}[user_key]    ${smuser}[unitID]
        ...    ${workflow_details}[week_offset]    ${employee_operation}    ${gen_shift_id}
    END
    # ⑨ Final publish — for weeks other than 0_0 or if additional publish is needed after modifications
    ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]    ${smuser}[unitID]
    ...    ${workflow_details}[week_start_date]
    Log    Status map refreshed after shift operations: ${current_unit_status_map}
    IF    ${workflow_details}[publish_schedule] and not ${current_unit_status_map}[is_schedule_week_in_progress] and ${current_unit_status_map}[is_schedule_generated] and ${current_unit_status_map}[can_lock_schedule]
        Lock Schedule Via API And Wait For Completion    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        ...    ${smuser}[user_key]
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
    END
    IF    ${workflow_details}[publish_schedule] and not ${current_unit_status_map}[is_schedule_week_in_progress] and ${current_unit_status_map}[is_schedule_generated] and ${current_unit_status_map}[can_publish_schedule]
        Publish Schedule Via API    ${smuser}[unitID]    ${workflow_details}[week_offset]    ${smuser}[user_key]    MANAGER
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    Status after publish: ${current_unit_status_map}
    END
    Log
    ...    Completed Dual Schedule Setup for ${smuser}[unitID] week offset ${workflow_details}[week_offset] week start date ${workflow_details}[week_start_date]
    ...    console=yes

Delete Week Plan Via Servlet And Generate Forecast
    [Documentation]
    ...    This keyword deletes the existing week plan data for the specified store and week using a servlet API call.
    ...    It is used as part of the schedule setup process to ensure a clean slate before generating new plans and schedules.
    ...    After deletion, generates forecast TWICE sequentially.
    [Arguments]    ${smuser}    ${workflow_details}
    ${should_use_vdi_workload}=    Should Use VDI Based Workload For Store    ${smuser}[unitID]
    # Week Plan deletion
    Log    Deleting existing week plan data via servlet for unit ${smuser}[unitID] and week starting ${workflow_details}[week_start_date]
    ...    console=yes
    Delete Week Plan From Servlet    ${smuser}[user_key]    ${smuser}[unitID]    ${workflow_details}[week_start_date]
    ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
    ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
    Log
    ...    Status after week plan deletion: is_forecast_generated:${current_unit_status_map}[is_forecast_generated],can_generate_workload:${current_unit_status_map}[can_generate_workload]
    Log    Delete Week Plan Completed for Week starting ${workflow_details}[week_start_date]
    IF    ${should_use_vdi_workload}
        Log    Skipping forecast generation after week plan deletion because VDI workload flow is enabled for ${smuser}[unitID].
        ...    console=yes
        RETURN
    END
    IF    not ${current_unit_status_map}[is_forecast_generated] and not ${current_unit_status_map}[can_generate_workload]
        # First forecast generation
        Log    Generating forecast (first pass) - can_generate_workload: ${current_unit_status_map}[can_generate_workload]    console=yes
        Generate Forecast Via API And Wait For Completion New    ${smuser}[user_key]    ${smuser}[unitID]
        ...    ${workflow_details}[week_start_date]    ${workflow_details}[week_offset]
        ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
        ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
        Log    Status after first forecast: ${current_unit_status_map}
        IF    not ${current_unit_status_map}[is_forecast_generated]
            Fail    First forecast generation failed for unit ${smuser}[unitID] week ${workflow_details}[week_start_date]
        END
        # Second forecast generation - check can_generate_workload again
        IF    not ${current_unit_status_map}[can_generate_workload]
            Log    Generating forecast (second pass) - can_generate_workload: ${current_unit_status_map}[can_generate_workload]
            ...    console=yes
            Generate Forecast Via API And Wait For Completion New    ${smuser}[user_key]    ${smuser}[unitID]
            ...    ${workflow_details}[week_start_date]    ${workflow_details}[week_offset]
            ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${smuser}[user_key]
            ...    ${smuser}[unitID]    ${workflow_details}[week_start_date]
            Log    Status after second forecast: ${current_unit_status_map}
            IF    not ${current_unit_status_map}[is_forecast_generated]
                Fail    Second forecast generation failed for unit ${smuser}[unitID] week ${workflow_details}[week_start_date]
            END
            Log    Both forecast generations completed successfully    console=yes
        ELSE
            Log    Skipping second forecast - can_generate_workload is already True    console=yes
        END
    ELSE IF    not ${current_unit_status_map}[can_generate_workload]
        Fail
        ...    Cannot generate forecast - can_generate_workload is False for unit ${smuser}[unitID] week ${workflow_details}[week_start_date]
    ELSE
        Fail
        ...    Week plan deletion could not be confirmed via API status map for unit ${smuser}[unitID] and week starting ${workflow_details}[week_start_date]. Status map: ${current_unit_status_map}
    END

Perform Shift Setup Operations By User For Week
    [Documentation]
    ...    This keyword performs shift setup operations for a given associate based on the provided employee operation
    [Arguments]    ${store_manager_user_key}
    ...    ${store_id}
    ...    ${week_offset}
    ...    ${employee_operation}
    ...    ${gen_shift_id}
    # Use fallback method which handles both credential and dynamic users
    ${ess_user}=    Get User With Person Id Fallback    ${employee_operation}[ess_user_key]
    Log    Performing shift setup operations for ESS user: ${ess_user}[displayName] (PersonId: ${ess_user}[personId])
    VAR    @{person_id_aslist}=    ${ess_user}[personId]
    ${associate_shifts_map}=    Get Shift Details For Associates Via API    ${store_manager_user_key}    ${gen_shift_id}
    ...    ${person_id_aslist}
    ${person_id_as_int}=    Convert To Integer    ${ess_user}[personId]
    ${person_id_as_str}=    Convert To String    ${ess_user}[personId]
    ${has_int_key}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${associate_shifts_map}    ${person_id_as_int}
    IF    ${has_int_key}
        ${associate_shifts}=    Get From Dictionary    ${associate_shifts_map}    ${person_id_as_int}    default=@{EMPTY}
    ELSE
        ${associate_shifts}=    Get From Dictionary    ${associate_shifts_map}    ${person_id_as_str}    default=@{EMPTY}
    END
    ${no_of_shifts}=    Get Length    ${associate_shifts}
    Log    Associate Shifts for ESS user ${ess_user}[displayName]: ${no_of_shifts}
    Clear Associate Shifts For Week    ${store_manager_user_key}    ${store_id}    ${gen_shift_id}    ${associate_shifts}
    ${associate_staffgroup_id}=    Get Associate StaffGroupId From PersonId Via DB    ${person_id_as_int}
    Add Shifts From Schedule Setup Template Data    ${store_manager_user_key}    ${store_id}    ${gen_shift_id}    ${week_offset}
    ...    ${person_id_as_int}    ${associate_staffgroup_id}    ${employee_operation}
    Add And Unallocate Shifts From Schedule Setup Template Data    ${store_manager_user_key}    ${store_id}    ${gen_shift_id}
    ...    ${week_offset}    ${person_id_as_int}    ${associate_staffgroup_id}    ${employee_operation}

Clear Associate Shifts For Week
    [Documentation]
    ...    This keyword unallocates all existing shifts for the associate for the given week.
    [Arguments]    ${store_manager_user_key}
    ...    ${store_id}
    ...    ${gen_shift_id}
    ...    ${associate_shifts}
    ${gen_shift_id_str}=    Convert To String    ${gen_shift_id}
    ${current_date_skey}=    Get Current Date    result_format=%Y%m%d
    FOR    ${shift}    IN    @{associate_shifts}
        # Example operation: Unallocate shift if specified
        Log    shift details: ${shift}
        IF    '${gen_shift_id_str}'[0] == '7' and ${shift}[startDateSkey] < ${current_date_skey}
            Log    Skipping shift operation on past dated shifts - shift startdate: ${shift}[startDateSkey]
            CONTINUE
        END
        ${response}=    Unallocate Shift Via API    ${store_manager_user_key}    ${store_id}    ${gen_shift_id}    ${shift}[shiftSeqNo]
        Log    ${response}
        Log    Unallocated shift start_date: ${shift}[startDate] SeqNo: ${shift}[shiftSeqNo]
        ${delete_response}=    Delete Open Shift Via API    ${store_manager_user_key}    ${store_id}    ${gen_shift_id}
        ...    ${shift}[shiftSeqNo]
        Log    ${delete_response}
        # Additional operations can be added here based on employee_operation configuration
    END

Add Shifts From Schedule Setup Template Data
    [Documentation]    This keyword adds shifts for the associate based on the schedule setup template data provided in employee_operation.
    [Arguments]    ${store_manager_user_key}
    ...    ${store_id}
    ...    ${gen_shift_id}
    ...    ${week_offset}
    ...    ${person_id_as_int}
    ...    ${associate_staffgroup_id}
    ...    ${employee_operation}
    ${shifts_to_add}=    Get From Dictionary    ${employee_operation}    shifts_to_add    default=@{EMPTY}
    IF    len(${shifts_to_add}) > 0
        FOR    ${shift}    IN    @{shifts_to_add}
            Log    Adding shift for associate - shift details: ${shift}    console=yes
            Add Single Shift From Schedule Setup Template Data    ${store_manager_user_key}    ${store_id}    ${gen_shift_id}
            ...    ${week_offset}    ${person_id_as_int}    ${associate_staffgroup_id}    ${shift}
        END
    END

Add And Unallocate Shifts From Schedule Setup Template Data
    [Documentation]    This keyword adds shifts for the associate and then unallocates them based on the schedule setup template data provided in employee_operation.
    [Arguments]    ${store_manager_user_key}
    ...    ${store_id}
    ...    ${gen_shift_id}
    ...    ${week_offset}
    ...    ${person_id_as_int}
    ...    ${associate_staffgroup_id}
    ...    ${employee_operation}
    ${shifts_to_add_and_unallocate}=    Get From Dictionary    ${employee_operation}    shifts_to_add_and_unallocate    default=@{EMPTY}
    IF    len(${shifts_to_add_and_unallocate}) > 0
        FOR    ${shift}    IN    @{shifts_to_add_and_unallocate}
            ${add_shift_response}=    Add Single Shift From Schedule Setup Template Data    ${store_manager_user_key}    ${store_id}
            ...    ${gen_shift_id}    ${week_offset}    ${person_id_as_int}    ${associate_staffgroup_id}    ${shift}
            VAR    ${created_shift_seq_no}=    ${add_shift_response}[metaInfo][createdShift][shiftSeqNo]
            Log    Created shift with SeqNo: ${created_shift_seq_no} for associate, now unallocating as per template configuration
            ...    console=yes
            Unallocate Shift Via API    ${store_manager_user_key}    ${store_id}    ${gen_shift_id}    ${created_shift_seq_no}
        END
    END

Add Single Shift From Schedule Setup Template Data
    [Documentation]    This keyword adds a single shift for the associate based on the shift details provided.
    [Arguments]    ${store_manager_user_key}
    ...    ${store_id}
    ...    ${gen_shift_id}
    ...    ${week_offset}
    ...    ${person_id_as_int}
    ...    ${associate_staffgroup_id}
    ...    ${shift}
    Log    ${shift}
    IF    '${shift}[dayNo]' == 'today'
        ${shift_start_date}=    Get Current Date    result_format=%Y%m%d
    ELSE
        ${shift_date_offset}=    Combine Week Offset And Day No    ${week_offset}    ${shift}[dayNo]
        ${shift_start_date}=    Calculate Date From Week Day Offset    ${shift_date_offset}    %Y%m%d
    END

    ${shift_start_date_as_int}=    Convert To Integer    ${shift_start_date}
    VAR    &{shift_details}=
    ...    assignedTo=${person_id_as_int}
    ...    staffGroupId=${associate_staffgroup_id}
    ...    startDate=${shift_start_date_as_int}
    ...    startTime=${shift}[startTime]
    ...    duration=${shift}[duration]
    ...    shiftSource=M
    ${add_shift_response}=    Add Shift Via API    ${store_manager_user_key}    ${store_id}    ${gen_shift_id}    ${shift_details}
    RETURN    ${add_shift_response}

Perform VDI Import Operation
    [Documentation]
    ...    This keyword performs VDI import operation for the given store and week using RWS Admin RFP Upload page on web application.
    ...    | =Arguments= | =Description= |
    ...    | week_start_date | Week start date or offset (e.g. 20260601 or 1_0) for the VDI import. |
    ...    | unit_id | Unit/Store ID for which the VDI import is performed. |
    ...    | schedule_regeneration | Optional. Text of the schedule regeneration dropdown option to select on the RFP Upload page. Defaults to ``NA`` (no selection). Valid values: ``NA``, ``Delete and Generate based on Store Attribute``, ``Delete and Generate unedited schedules``, ``Delete and Generate all schedules``. |
    ...
    ...    The value is passed as an override to the ``default`` template in ``vdi_import/base_templates.json``.
    ...    When the dropdown is present on the page (planning week 1 config enabled), the keyword selects the given option.
    ...    When ``NA`` is passed the dropdown selection is skipped entirely.
    ...
    ...    Example usage:
    ...    | Perform VDI Import Operation    ${week_start_date}    ${unit_id}
    ...    | Perform VDI Import Operation    ${week_start_date}    ${unit_id}    schedule_regeneration=Delete and Generate all schedules
    [Arguments]    ${week_start_date}    ${unit_id}    ${schedule_regeneration}=NA
    ${vdi_import_data}=    Get VDI Import Data    template_name=default    week_start_date=${week_start_date}    unit_id=${unit_id}
    ...    schedule_regeneration=${schedule_regeneration}
    ${vdi_upload_file_path}=    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    TRY
        Login And Launch WFM Web App    user_key=SYSADMIN
        Navigate To RWS Admin RFP Upload Page On Web
        Upload VDI File On Web    ${vdi_upload_file_path}    ${schedule_regeneration}
        Navigate To RWS Admin RFP Logs Page On Web
        Apply Filter And Select Latest Log File On RFP Logs Page    Volume Driver Interval Import
        Verify Log File Content On Web
    FINALLY
        Run Keyword And Ignore Error    Log Out From Web Application
        Run Keyword And Ignore Error    Close Browser
    END

Generate Workload From VDI Import
    [Documentation]    Performs VDI import as a precondition for workload generation scenarios.
    ...    | =Arguments= | =Description= |
    ...    | week_start_date | Week offset or week start date used to prepare VDI import data. |
    ...    | unit_id | Unit identifier used to prepare VDI import data. |
    ...
    ...    Example usage:
    ...    | Generate Workload From VDI import    9_0    STORE1 |
    [Arguments]    ${week_start_date}    ${unit_id}
    Perform VDI Import Operation    ${week_start_date}    ${unit_id}

Should Delete Workload For DB Driven VDI
    [Documentation]    Determines whether workload cleanup should happen before VDI operations for a store.
    ...    Workload cleanup is required only when the environment does not use the legacy ``vdi_import`` config flag
    ...    and the database explicitly marks the store as VDI-enabled.
    ...    | =Arguments= | =Description= |
    ...    | store_id | Store unit ID to evaluate. |
    ...    | =Returns= | =Description= |
    ...    | should_delete_workload_store_based_vdi | True only when DB-driven VDI cleanup should run. |
    ...    Example usage:
    ...    | ${should_delete_workload_store_based_vdi}=    Should Delete Workload For DB Driven VDI    ZSITSTORE006 |
    [Arguments]    ${store_id}
    ${is_vdi_workload_enabled_by_config}=    Is Config Enabled    key=vdi_import
    VAR    ${should_delete_workload_store_based_vdi}=    ${False}
    IF    not ${is_vdi_workload_enabled_by_config}
        TRY
            ${vdi_workload_regeneration_status}
            ...    ${should_delete_workload_store_based_vdi}=
            ...    Get VDI Based Workload Regeneration Status For Store From Database    ${store_id}
            Log    DB-driven VDI cleanup evaluation for store ${store_id}: ${vdi_workload_regeneration_status}    console=yes
        EXCEPT
            Log    DB-driven VDI cleanup evaluation failed for store ${store_id}. Workload cleanup before VDI will be skipped.
            ...    console=yes
            VAR    ${should_delete_workload_store_based_vdi}=    ${False}
        END
    END
    RETURN    ${should_delete_workload_store_based_vdi}
