*** Settings ***
Documentation      Common keywords for HRCI new hire suite setup and teardown for schedule dependent tests in week 0.

Library             pabot.PabotLib
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/admin/rws_upload_api.resource
Variables           resources/web/rws/schedule/week_schedule_page.py
Library             test_data/TestDataLibrary.py


*** Keywords ***
Create Dynamic Employees For SM1Store2
    [Documentation]    Creates dynamic employees via HRBA API in Suite Setup for HRCI tests
    ...
    ...    This runs ONCE per suite and creates:
    ...    - ESSNH1_STORE2 (dynamic employee_id in STORE2)
    ...    - ESSNH4_STORE2 (dynamic employee_id in STORE2, for transfer testing)
    ...    - ESSNH6_STORE2 (dynamic employee_id in STORE2, for termination testing)
    ...
    ...    Employees are stored via 'Set Dynamic Employee' in pabot shared cache for retrieval in tests.
    ...
    ...    Note: Uses 'Run Only Once' wrapper in Suite Setup for parallel execution safety

    Log    🚀 Suite Setup: Creating dynamic employees for HRCI transfer test via HRBA API...    level=INFO

    ${store_data}    Get Store Data    template_name=model_store2
    ${staff_group_id}    Get System Value    HRBAStaffGroupId    NEWHIRE_STORE2_SG_1
    ${department_id}    Get System Value    HRBADepartmentId    NEWHIRE_STORE2_DEPT_1
    ${job_code}    Get System Value    HRBAJobCode    NEWHIRE_STORE2_JOB_CODE_1
    ${job_title}    Get System Value    HRBAJobTitle    NEWHIRE_STORE2_JOB_TITLE_1
    ${contract_group}    Get System Value    HRBAContractGroup    NEWHIRE_STORE2_CONTRACT_GROUP_1
    ${state_code}    Get System Value    HRBAStateCode    NEWHIRE_STORE2_STATE_CODE_1
    ${country_code}    Get System Value    HRBACountryCode    NEWHIRE_STORE2_COUNTRY_CODE_1
    ${full_time_part_time_indicator}    Get System Value    HRBAFullTimePartTimeIndicator    NEWHIRE_STORE2_FT_PT_INDICATOR_1
    ${salaried_hourly}    Get System Value    HRBASalariedHourly    NEWHIRE_STORE2_SALARIED_HOURLY_1
    ${partner_role_code}    Get System Value    HRBAPartnerRoleCode    NEWHIRE_STORE2_PARTNER_ROLE_CODE_1
    ${additional_field}    Get System Value    HRBAAdditionalField    NEWHIRE_STORE2_ADDITIONAL_FIELD_1
    ${date_format}    Get Config Value    SERVER_DF
    ${current_day_date}    Get Current Date    result_format=${date_format}
    ${current_day_date}    Subtract Time From Date    ${current_day_date}    1 day    result_format=${date_format}
    ${current_week_start_date}    Calculate Date From Week Day Offset    0_0    date_format=${date_format}
    # Generate Users with dynamic employee ID
    ${essnh1_store2}    Generate Dynamic Employee    user_key=ESSNH1_STORE2    store_data=${store_data}    profile_type=ASSOCIATE
    ${essnh3_store2}    Generate Dynamic Employee    user_key=ESSNH3_STORE2    store_data=${store_data}    profile_type=ASSOCIATE
    ${essnh4_store2}    Generate Dynamic Employee    user_key=ESSNH4_STORE2    store_data=${store_data}    profile_type=ASSOCIATE
    ${essnh6_store2}    Generate Dynamic Employee    user_key=ESSNH6_STORE2    store_data=${store_data}    profile_type=ASSOCIATE
    ${essnh7_store2}    Generate Dynamic Employee    user_key=ESSNH7_STORE2    store_data=${store_data}    profile_type=ASSOCIATE

    ${hrba_essnh1_store2}    Get Hrba Api Upload Data
    ...    employee_id=${essnh1_store2}[employee_id]
    ...    associate_id=${essnh1_store2}[employee_id]    colleague_id=${essnh1_store2}[employee_id]
    ...    record_effective_from=${current_day_date}
    ...    last_name=${essnh1_store2}[lastName]    first_name=${essnh1_store2}[firstName]
    ...    job_title=${job_title}    job_code=${job_code}
    ...    job_effective_date=${current_day_date}    date_of_hire=${current_week_start_date}
    ...    home_store_id=${store_data}[store_id]
    ...    home_staff_group_id=${staff_group_id}    home_job_id=${staff_group_id}
    ...    home_department_id=${department_id}    home_department_effective_date=${current_week_start_date}
    ...    full_time_part_time_indicator=${full_time_part_time_indicator}    gte_30_lt_30h_indicator=${full_time_part_time_indicator}
    ...    salaried_hourly=${salaried_hourly}    contract_group=${contract_group}
    ...    contract_effective_date=${current_day_date}
    ...    state_code=${state_code}    country_code=${country_code}
    ...    base_wage_effective_date=${current_week_start_date}
    ...    badge_number=${essnh1_store2}[employee_id]    badge_effective_date=${current_day_date}
    ...    status_effective_date=${current_day_date}    partner_role_code=${partner_role_code}
    ...    additional_field=${additional_field}
    ...    supervisor_employee_id=${EMPTY}
    ...    full_time_date=${EMPTY}    gte_30_date=${EMPTY}

    ${hrba_essnh3_store2}    Get Hrba Api Upload Data
    ...    employee_id=${essnh3_store2}[employee_id]
    ...    associate_id=${essnh3_store2}[employee_id]    colleague_id=${essnh3_store2}[employee_id]
    ...    record_effective_from=${current_day_date}
    ...    last_name=${essnh3_store2}[lastName]    first_name=${essnh3_store2}[firstName]
    ...    job_title=${job_title}    job_code=${job_code}
    ...    job_effective_date=${current_day_date}    date_of_hire=${current_week_start_date}
    ...    home_store_id=${store_data}[store_id]
    ...    home_staff_group_id=${staff_group_id}    home_job_id=${staff_group_id}
    ...    home_department_id=${department_id}    home_department_effective_date=${current_week_start_date}
    ...    full_time_part_time_indicator=${full_time_part_time_indicator}    gte_30_lt_30h_indicator=${full_time_part_time_indicator}
    ...    salaried_hourly=${salaried_hourly}    contract_group=${contract_group}
    ...    contract_effective_date=${current_day_date}
    ...    state_code=${state_code}    country_code=${country_code}
    ...    base_wage_effective_date=${current_week_start_date}
    ...    badge_number=${essnh3_store2}[employee_id]    badge_effective_date=${current_day_date}
    ...    status_effective_date=${current_day_date}    partner_role_code=${partner_role_code}
    ...    additional_field=${additional_field}
    ...    supervisor_employee_id=${EMPTY}
    ...    full_time_date=${EMPTY}    gte_30_date=${EMPTY}

    ${hrba_essnh4_store2}    Get Hrba Api Upload Data
    ...    employee_id=${essnh4_store2}[employee_id]
    ...    associate_id=${essnh4_store2}[employee_id]    colleague_id=${essnh4_store2}[employee_id]
    ...    record_effective_from=${current_day_date}
    ...    last_name=${essnh4_store2}[lastName]    first_name=${essnh4_store2}[firstName]
    ...    job_title=${job_title}    job_code=${job_code}    job_effective_date=${current_day_date}
    ...    date_of_hire=${current_week_start_date}    home_store_id=${store_data}[store_id]
    ...    home_staff_group_id=${staff_group_id}    home_job_id=${staff_group_id}
    ...    home_department_id=${department_id}
    ...    home_department_effective_date=${current_week_start_date}
    ...    full_time_part_time_indicator=${full_time_part_time_indicator}    gte_30_lt_30h_indicator=${full_time_part_time_indicator}
    ...    salaried_hourly=${salaried_hourly}
    ...    contract_group=${contract_group}    contract_effective_date=${current_day_date}
    ...    state_code=${state_code}    country_code=${country_code}
    ...    base_wage_effective_date=${current_week_start_date}    badge_number=${essnh4_store2}[employee_id]
    ...    badge_effective_date=${current_day_date}    status_effective_date=${current_day_date}
    ...    partner_role_code=${partner_role_code}    additional_field=${additional_field}
    ...    supervisor_employee_id=${EMPTY}
    ...    full_time_date=${EMPTY}    gte_30_date=${EMPTY}

    ${hrba_essnh6_store2}    Get Hrba Api Upload Data
    ...    employee_id=${essnh6_store2}[employee_id]
    ...    associate_id=${essnh6_store2}[employee_id]    colleague_id=${essnh6_store2}[employee_id]
    ...    record_effective_from=${current_day_date}
    ...    last_name=${essnh6_store2}[lastName]    first_name=${essnh6_store2}[firstName]
    ...    job_title=${job_title}    job_code=${job_code}    job_effective_date=${current_day_date}
    ...    date_of_hire=${current_week_start_date}
    ...    home_store_id=${store_data}[store_id]
    ...    home_staff_group_id=${staff_group_id}    home_job_id=${staff_group_id}
    ...    home_department_id=${department_id}    home_department_effective_date=${current_week_start_date}
    ...    full_time_part_time_indicator=${full_time_part_time_indicator}    gte_30_lt_30h_indicator=${full_time_part_time_indicator}
    ...    salaried_hourly=${salaried_hourly}
    ...    contract_group=${contract_group}    contract_effective_date=${current_day_date}
    ...    state_code=${state_code}    country_code=${country_code}
    ...    base_wage_effective_date=${current_week_start_date}    badge_number=${essnh6_store2}[employee_id]
    ...    badge_effective_date=${current_day_date}    status_effective_date=${current_day_date}
    ...    partner_role_code=${partner_role_code}    additional_field=${additional_field}
    ...    supervisor_employee_id=${EMPTY}
    ...    full_time_date=${EMPTY}    gte_30_date=${EMPTY}

    ${hrba_essnh7_store2}    Get Hrba Api Upload Data
    ...    employee_id=${essnh7_store2}[employee_id]
    ...    associate_id=${essnh7_store2}[employee_id]    colleague_id=${essnh7_store2}[employee_id]
    ...    record_effective_from=${current_day_date}
    ...    last_name=${essnh7_store2}[lastName]    first_name=${essnh7_store2}[firstName]
    ...    job_title=${job_title}    job_code=${job_code}    job_effective_date=${current_day_date}
    ...    date_of_hire=${current_week_start_date}    home_store_id=${store_data}[store_id]
    ...    home_staff_group_id=${staff_group_id}    home_job_id=${staff_group_id}
    ...    home_department_id=${department_id}    home_department_effective_date=${current_week_start_date}
    ...    full_time_part_time_indicator=${full_time_part_time_indicator}    gte_30_lt_30h_indicator=${full_time_part_time_indicator}
    ...    salaried_hourly=${salaried_hourly}    contract_group=${contract_group}
    ...    contract_effective_date=${current_day_date}    state_code=${state_code}
    ...    country_code=${country_code}    base_wage_effective_date=${current_week_start_date}
    ...    badge_number=${essnh7_store2}[employee_id]    badge_effective_date=${current_day_date}
    ...    status_effective_date=${current_day_date}
    ...    partner_role_code=${partner_role_code}    additional_field=${additional_field}
    ...    supervisor_employee_id=${EMPTY}
    ...    full_time_date=${EMPTY}    gte_30_date=${EMPTY}
    VAR    @{users}    ${hrba_essnh1_store2}    ${hrba_essnh3_store2}    ${hrba_essnh4_store2}    ${hrba_essnh6_store2}    ${hrba_essnh7_store2}
    Create HRBA Users Via API
    ...    user_key=SYSADMIN
    ...    users_data=${users}
    Log    ✅ Successfully created ESSNH1_STORE2: Employee ID=${essnh1_store2}[employee_id] (${store_data}[store_name])    level=INFO
    Log    ✅ Successfully created ESSNH3_STORE2: Employee ID=${essnh3_store2}[employee_id] (${store_data}[store_name])    level=INFO
    Log    ✅ Successfully created ESSNH4_STORE2: Employee ID=${essnh4_store2}[employee_id] (${store_data}[store_name])    level=INFO
    Log    ✅ Successfully created ESSNH6_STORE2: Employee ID=${essnh6_store2}[employee_id] (${store_data}[store_name])    level=INFO
    Log    ✅ Successfully created ESSNH7_STORE2: Employee ID=${essnh7_store2}[employee_id] (${store_data}[store_name])    level=INFO

    # Store in pabot-shared cache (works across parallel processes)
    Set Dynamic Employee    ESSNH1_STORE2    ${essnh1_store2}
    Set Dynamic Employee    ESSNH3_STORE2    ${essnh3_store2}
    Set Dynamic Employee    ESSNH4_STORE2    ${essnh4_store2}
    Set Dynamic Employee    ESSNH6_STORE2    ${essnh6_store2}
    Set Dynamic Employee    ESSNH7_STORE2    ${essnh7_store2}

    Finish New Hire First Login Setup If Required On Web    ESSNH1_STORE2
    Finish New Hire First Login Setup If Required On Web    ESSNH3_STORE2
    Finish New Hire First Login Setup If Required On Web    ESSNH4_STORE2
    Finish New Hire First Login Setup If Required On Web    ESSNH6_STORE2
    Finish New Hire First Login Setup If Required On Web    ESSNH7_STORE2
    Log    📋 Suite Setup Complete: Employees created and available for tests    level=INFO

Teardown Dynamic Employees For SM1Store2
    [Documentation]    Terminates dynamic employees created for HRCI tests in Suite Teardown
    ...    This runs ONCE per suite and terminates the employees created in setup to clean up test data.
    ...    Terminates the dynamic employees via HRCI API in Suite Teardown.
    ...    This runs ONCE per suite and terminates the employees created in Suite Setup to clean up after
    ...    the tests. It ensures that the test data does not persist beyond the suite execution.

    Log    🧹 Suite Teardown: Terminating dynamic employees via HRCI API...    level=INFO

    # Get date configuration from environment (not hardcoded!)
    ${date_format}    Get Config Value    SERVER_DF
    ${termination_date}    Calculate Date From Week Day Offset    0_2    date_format=${date_format}
    ${termination_date_transfer_effective_date}    Calculate Date From Week Day Offset    1_1    date_format=${date_format}

    # Get employees from suite variables
    ${essnh1_store2}    Get Dynamic Employee    ESSNH1_STORE2
    ${essnh4_store2}    Get Dynamic Employee    ESSNH4_STORE2

    # Create HRCI records for termination
    ${hrci_essnh1_store2}    Get Hrci Api Upload Data
    ...    employee_id=${essnh1_store2}[employee_id]
    ...    effective_date=${termination_date}
    # Create HRCI record for termination
    ${hrci_essnh4_store2}    Get Hrci Api Upload Data
    ...    employee_id=${essnh4_store2}[employee_id]
    ...    effective_date=${termination_date_transfer_effective_date}

    # Terminate both employees via HRCI API (single API call for both)
    VAR    @{records}    ${hrci_essnh1_store2}    ${hrci_essnh4_store2}
    Update HRCI User Status Via API
    ...    user_key=SYSADMIN
    ...    records_data=${records}

    Log    ✅ Successfully terminated ESSNH1_STORE2: Employee ID=${essnh1_store2}[employee_id]    level=INFO
    Log    ✅ Successfully terminated ESSNH4_STORE2: Employee ID=${essnh4_store2}[employee_id]    level=INFO

    Log    🧹 Suite Teardown Complete    level=INFO
