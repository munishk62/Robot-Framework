*** Settings ***
Documentation       BATTC00196: Verify HR store transfer using HRCI data loads
...
...                 **Test Objective:**
...                 Verify that an employee can be transferred from one store to another using HRCI
...                 (HR Associate Change Import) file upload via RWS Upload UI
...
...                 **Applicability:**
...                 - RWS license is enabled (Lookup: #PC00001)
...
...                 **User Criteria:**
...                 - SYSADMIN: CORP User with RWS Upload permissions
...                 - SM1_STORE1: SM User for source store
...                 - SM1_STORE2: SM User for destination store
...                 - ESSNH5_STORE2: ESS User (New Hire created in Suite Setup)
...
...                 **Setup:**
...                 - Config prerequisites for the domain are obtained from HR config ini for HRBA and HRCI (Lookup: #PC00059)
...                 - Test data file for HRBA and HRCI is created based on the config details from HR Config.ini (Lookup: #PC00059)
...                 - Logical staff group is used in HRCI file if logical staff group PF is enabled. Otherwise staff group is used (Lookup: #PC00060)
...                 - Password policy for the new user import is identified from the domain (Lookup: #PC00061)
...
...                 **Suite Setup:**
...                 - New hire is added to STORE2 using HRBA API (#Associate: ESSNH5_STORE2)
...
...                 **Test Flow:**
...                 1. Login as SYSADMIN and import HRCI file for store transfer
...                 2. Verify log entry in RWS Logs
...                 3. Login as SM1_STORE1 and verify employee appears in new store (Transfer Week)
...                 4. Login as SM1_STORE2 and verify employee in original store (Current Week)
...
...                 **Suite Teardown:**
...                 - Terminate the transferred employee via HRCI API

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/admin/rws_upload.resource
Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/rws/admin/rws_upload_api.resource
Library             test_data/TestDataLibrary.py
Library             pabot.PabotLib

Suite Setup         Run Only Once    Create Dynamic Employees For Store Transfer Suite Setup
Suite Teardown      Run Only Once    Terminate Dynamic Employee For HRCI Transfer Test

Test Tags           hrci    store_transfer    action:write    new_hire_dependent    # config:hrci_upload


*** Variables ***
${HRCI_FILE_PATH}       web/Generated/HRCI_Store_Transfer.txt


*** Test Cases ***
BATTC00196: Verify HR store transfer using HRCI data loads
    [Documentation]    Verify complete workflow for transferring employee from STORE2 to STORE1 using HRCI file upload
    ...
    ...    **Test Data:**
    ...    - #Week: Current week
    ...    - #TransferWeek: Current week +1
    ...    - #Associate: ESSNH5_STORE2 (created via HRBA in Suite Setup)
    ...    - #HRCI_Import1: Transfer from STORE2 to STORE1
    ...    - #TransferDate: From #TransferWeek
    ...    - #Store: ZAUTOSTORE001 (STORE1)
    ...    - #Department: Same department of the associate
    ...    - #Staff group: Same staff group / logical staffgroup of the associate
    ...    - #File1: HRCI1.txt
    ...
    ...    **Steps:**
    ...    1. Login as SYSADMIN
    ...    2. Import HRCI data using the input file
    ...    3. Verify the processing of records from RWS logs
    ...    4. Logout
    ...    5. Login as SM1_STORE1 and verify transferred associate in new store
    ...    6. Logout
    ...    7. Login as SM1_STORE2 and verify associate in original store before transfer
    ...    8. Logout
    [Tags]    dev:azar    battc00196    new_hire_azar    config:rws    bat_phase2    om_hr

    ${ess_user_nh5}=    Get Dynamic Employee    ESSNH5_STORE2
    ${store1_data}=    Get Store Data
    ${staff_group_id}=    Get System Value    HRBAStaffGroupId    NEWHIRE_STORE2_SG_1
    ${department_id}=    Get System Value    HRBADepartmentId    NEWHIRE_STORE2_DEPT_1
    ${date_format}=    Get Config Value    SERVER_DF
    ${effective_date}=    Calculate Date From Week Day Offset    1_0    date_format=${date_format}
    ${end_date}=    Calculate Date From Week Day Offset    2_6    date_format=${date_format}
    # Get HRCI template data with overrides for store transfer
    ${hrci_transfer_data}=    Get Hrci Store Transfer Data
    ...    employee_id=${ess_user_nh5}[employee_id]
    ...    home_store_id=${store1_data}[store_id]
    ...    home_department_id=${department_id}
    ...    home_staff_group_id=${staff_group_id}
    ...    effective_date=${effective_date}
    ...    end_date=${end_date}
    Login And Launch WFM Web App    user_key=SYSADMIN
    Perform HRCI Store Transfer Upload On Web
    ...    ${HRCI_FILE_PATH}
    ...    ${hrci_transfer_data}
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Roster Page On Web
    ${active_satuts}=    Get System Value    EmploymentStatus    ACTIVE
    ${reportee_type_my_location}=    Get System Value    ReporteeType    MY_LOCATION

    # Check if reportee filter is available and determine the reportee type to use
    ${reportee_info}=    Is Reportee Filter Available On Roster Page On Web
    VAR    ${reportee_type_to_use}=    ${EMPTY}
    IF    ${reportee_info}[available] and ${reportee_info}[my_location]
        VAR    ${reportee_type_to_use}=    ${reportee_type_my_location}
        Log    Using 'My Location' reportee type filter for SM1_STORE1    level=INFO
    END

    Apply Filter With Associate Criteria On Roster Page On Web
    ...    associate_id=${ess_user_nh5}[employee_id]
    ...    status=${active_satuts}
    ...    reportee_type=${reportee_type_to_use}
    ...    status_on_date=1_0
    Verify Employee Is Listed On Roster Page On Web    ${ess_user_nh5}[displayName]    ${ess_user_nh5}[employee_id]
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RWS Employee Roster Page On Web

    # Check reportee filter availability for SM1_STORE2
    ${reportee_info}=    Is Reportee Filter Available On Roster Page On Web
    VAR    ${reportee_type_to_use}=    ${EMPTY}
    IF    ${reportee_info}[available] and ${reportee_info}[my_location]
        VAR    ${reportee_type_to_use}=    ${reportee_type_my_location}
        Log    Using 'My Location' reportee type filter for SM1_STORE2    level=INFO
    END

    Apply Filter With Associate Criteria On Roster Page On Web
    ...    associate_id=${ess_user_nh5}[employee_id]
    ...    status=${active_satuts}
    ...    reportee_type=${reportee_type_to_use}
    Verify Employee Is Listed On Roster Page On Web    ${ess_user_nh5}[displayName]    ${ess_user_nh5}[employee_id]
    Close Browser
    Log    HRCI Store Transfer test completed successfully    level=INFO


*** Keywords ***
Create Dynamic Employees For Store Transfer Suite Setup
    [Documentation]    Creates dynamic employee for store transfer test via HRBA API in Suite Setup
    ...    ...    This runs ONCE per suite and creates:
    ...    - ESSNH5_STORE2 (dynamic employee_id in STORE2)
    ...    Employee is stored via 'Set Dynamic Employee' in pabot shared cache for retrieval in tests.
    ...    Note: Uses 'Run Only Once' wrapper in Suite Setup for pabot compatibility
    Create Dynamic Employees Via HRBA API

Create Dynamic Employees Via HRBA API
    [Documentation]    Creates 1 dynamic employee via HRBA API in Suite Setup for HRCI transfer testing
    ...
    ...    This runs ONCE per suite and creates:
    ...    - ESSNH5_STORE2 (dynamic employee_id in STORE2)
    ...
    ...    Employee is stored via 'Set Dynamic Employee' in pabot shared cache for retrieval in tests.
    ...
    ...    Note: Uses 'Run Only Once' wrapper in Suite Setup for pabot compatibility

    Log    🚀 Suite Setup: Creating dynamic employee for HRCI transfer test via HRBA API...    level=INFO

    ${store_data}=    Get Store Data    template_name=model_store2
    ${staff_group_id}=    Get System Value    HRBAStaffGroupId    NEWHIRE_STORE2_SG_1
    ${department_id}=    Get System Value    HRBADepartmentId    NEWHIRE_STORE2_DEPT_1
    ${job_code}=    Get System Value    HRBAJobCode    NEWHIRE_STORE2_JOB_CODE_1
    ${job_title}=    Get System Value    HRBAJobTitle    NEWHIRE_STORE2_JOB_TITLE_1
    ${contract_group}=    Get System Value    HRBAContractGroup    NEWHIRE_STORE2_CONTRACT_GROUP_1
    ${state_code}=    Get System Value    HRBAStateCode    NEWHIRE_STORE2_STATE_CODE_1
    ${country_code}=    Get System Value    HRBACountryCode    NEWHIRE_STORE2_COUNTRY_CODE_1
    ${full_time_part_time_indicator}=    Get System Value    HRBAFullTimePartTimeIndicator    NEWHIRE_STORE2_FT_PT_INDICATOR_1
    ${salaried_hourly}=    Get System Value    HRBASalariedHourly    NEWHIRE_STORE2_SALARIED_HOURLY_1
    ${partner_role_code}=    Get System Value    HRBAPartnerRoleCode    NEWHIRE_STORE2_PARTNER_ROLE_CODE_1
    ${additional_field}=    Get System Value    HRBAAdditionalField    NEWHIRE_STORE2_ADDITIONAL_FIELD_1

    # Calculate dynamic dates for HRBA record
    ${date_format}=    Get Config Value    SERVER_DF
    ${current_day_date}=    Get Current Date    result_format=${date_format}
    ${current_day_date}=    Subtract Time From Date    ${current_day_date}    1 day    result_format=${date_format}
    ${current_week_start_date}=    Calculate Date From Week Day Offset    0_0    date_format=${date_format}

    # Generate ESSNH5_STORE2 with dynamic employee ID
    ${essnh5_store2}=    Generate Dynamic Employee
    ...    user_key=ESSNH5_STORE2
    ...    store_data=${store_data}
    ...    profile_type=ASSOCIATE

    ${hrba_essnh5_store2}=    Get Hrba Api Upload Data
    ...    employee_id=${essnh5_store2}[employee_id]
    ...    associate_id=${essnh5_store2}[employee_id]
    ...    colleague_id=${essnh5_store2}[employee_id]
    ...    record_effective_from=${current_day_date}
    ...    last_name=${essnh5_store2}[lastName]
    ...    first_name=${essnh5_store2}[firstName]
    ...    job_title=${job_title}
    ...    job_code=${job_code}
    ...    job_effective_date=${current_day_date}
    ...    date_of_hire=${current_week_start_date}
    ...    home_store_id=${store_data}[store_id]
    ...    home_staff_group_id=${staff_group_id}    home_job_id=${staff_group_id}
    ...    home_department_id=${department_id}
    ...    home_department_effective_date=${current_week_start_date}
    ...    full_time_part_time_indicator=${full_time_part_time_indicator}    gte_30_lt_30h_indicator=${full_time_part_time_indicator}
    ...    salaried_hourly=${salaried_hourly}
    ...    contract_group=${contract_group}
    ...    contract_effective_date=${current_day_date}
    ...    state_code=${state_code}
    ...    country_code=${country_code}
    ...    base_wage_effective_date=${current_week_start_date}
    ...    badge_number=${essnh5_store2}[employee_id]
    ...    badge_effective_date=${current_day_date}
    ...    status_effective_date=${current_day_date}
    ...    partner_role_code=${partner_role_code}
    ...    additional_field=${additional_field}
    ...    full_time_date=${EMPTY}    gte_30_date=${EMPTY}

    # Import employee via HRBA API
    VAR    @{users}=    ${hrba_essnh5_store2}
    Create HRBA Users Via API
    ...    user_key=SYSADMIN
    ...    users_data=${users}

    Log    ✅ Successfully created ESSNH5_STORE2: Employee ID=${essnh5_store2}[employee_id] (${store_data}[store_name])    level=INFO

    # Store in pabot-shared cache (works across parallel processes)
    Set Dynamic Employee    ESSNH5_STORE2    ${essnh5_store2}
    Finish New Hire First Login Setup If Required On Web    ESSNH5_STORE2

    Log    📋 Suite Setup Complete: Employee created and available for tests    level=INFO

Terminate Dynamic Employee For HRCI Transfer Test
    [Documentation]    Terminates the dynamic employee via HRCI API in Suite Teardown
    ...
    ...    This runs ONCE at the end of the suite to clean up created employee.
    ...    Also deletes the HRCI transfer file after successful termination.

    Log    🧹 Suite Teardown: Terminating dynamic employee via HRCI API...    level=INFO

    # Get date configuration from environment
    ${date_format}=    Get Config Value    SERVER_DF
    ${current_day_date}=    Get Current Date    result_format=${date_format}
    ${termination_date}=    Add Time To Date    ${current_day_date}    2 days    result_format=${date_format}

    # Get employee from suite variable
    ${essnh5_store2}=    Get Dynamic Employee    ESSNH5_STORE2

    # Create HRCI record for termination
    ${hrci_essnh5_store2}=    Get Hrci Api Upload Data
    ...    employee_id=${essnh5_store2}[employee_id]
    ...    effective_date=${termination_date}

    # Terminate employee via HRCI API
    VAR    @{records}=    ${hrci_essnh5_store2}
    Update HRCI User Status Via API
    ...    user_key=SYSADMIN
    ...    records_data=${records}

    Log    ✅ Successfully terminated ESSNH5_STORE2: Employee ID=${essnh5_store2}[employee_id]    level=INFO

    # Delete HRCI transfer file after successful termination
    Run Keyword And Ignore Error    Remove File    ${HRCI_FILE_PATH}
    Log    🗑️ Deleted HRCI transfer file: ${HRCI_FILE_PATH}    level=INFO

    Log    🧹 Suite Teardown Complete    level=INFO
