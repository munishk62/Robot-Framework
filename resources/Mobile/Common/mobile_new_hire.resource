*** Settings ***
Documentation       Common keywords for mobile new hire suite setup and teardown.

Library             test_data/TestDataLibrary.py
Resource            resources/web/rws/admin/rws_upload.resource
Resource            resources/web/rws/admin/rws_upload_api.resource


*** Keywords ***
Terminate Dynamic Employees For New Hire Suite Teardown For Mobility
    [Documentation]    Terminates dynamic employees for new hire suite teardown for mobility.
    # Get date configuration from environment (not hardcoded!)
    ${date_format}=    Get Config Value    SERVER_DF
    ${current_day_date}=    Get Current Date    result_format=${date_format}
    ${termination_date}=    Add Time To Date    ${current_day_date}    2 days    result_format=${date_format}
    # Get employees from suite variable
    ${ess_nh7_store2}=    Get Dynamic Employee    ESSNH7_STORE2
    ${ess_nh3_store2}=    Get Dynamic Employee    ESSNH3_STORE2
    # Create HRCI records for termination
    ${hrci_ess_nh7_store2}=    Get Hrci Api Upload Data
    ...    employee_id=${ess_nh7_store2}[employee_id]
    ...    effective_date=${termination_date}
    ${hrci_ess_nh3_store2}=    Get Hrci Api Upload Data
    ...    employee_id=${ess_nh3_store2}[employee_id]
    ...    effective_date=${termination_date}
    # Terminate hired employees via HRCI API (single API call for multiple terminations if needed)
    VAR    @{records}=    ${hrci_ess_nh7_store2}    ${hrci_ess_nh3_store2}
    Update HRCI User Status Via API
    ...    user_key=SYSADMIN
    ...    records_data=${records}
    ${record_length}=    Get Length    ${records}
    Log To Console    📋 New Hire Teardown Complete: Successfully terminated ${record_length} employees

Get New Hire HRBA API Upload Data For Dynamic Associate
    [Documentation]    Gets the HRBA API data for the dynamic associate created for new hire suite.
    [Arguments]    ${dynamic_user_object}    ${store_data}
    ${staff_group_id}=    Get System Value    HRBAStaffGroupId    NEWHIRE_STORE2_SG_1
    ${department_id}=    Get System Value    HRBADepartmentId    NEWHIRE_STORE2_DEPT_1
    ${job_code}=    Get System Value    HRBAJobCode    NEWHIRE_STORE2_JOB_CODE_1
    ${job_title}=    Get System Value    HRBAJobTitle    NEWHIRE_STORE2_JOB_TITLE_1
    ${contract_group}=    Get System Value    HRBAContractGroup    NEWHIRE_STORE2_CONTRACT_GROUP_1
    ${state_code}=    Get System Value    HRBAStateCode    NEWHIRE_STORE2_STATE_CODE_1
    ${country_code}=    Get System Value    HRBACountryCode    NEWHIRE_STORE2_COUNTRY_CODE_1
    ${full_time_part_time_indicator}=    Get System Value
    ...    HRBAFullTimePartTimeIndicator
    ...    NEWHIRE_STORE2_FT_PT_INDICATOR_1
    ${salaried_hourly}=    Get System Value    HRBASalariedHourly    NEWHIRE_STORE2_SALARIED_HOURLY_1
    ${partner_role_code}=    Get System Value    HRBAPartnerRoleCode    NEWHIRE_STORE2_PARTNER_ROLE_CODE_1
    ${additional_field}=    Get System Value    HRBAAdditionalField    NEWHIRE_STORE2_ADDITIONAL_FIELD_1
    ${date_format}=    Get Config Value    SERVER_DF
    ${current_day_date}=    Get Current Date    result_format=${date_format}
    ${current_day_date}=    Subtract Time From Date    ${current_day_date}    1 day    result_format=${date_format}
    ${current_week_start_date}=    Calculate Date From Week Day Offset    0_0    date_format=${date_format}

    ${hrba_ess_nhx_store2}=    Get Hrba Api Upload Data
    ...    template_name=default
    ...    employee_id=${dynamic_user_object}[employee_id]
    ...    associate_id=${dynamic_user_object}[employee_id]
    ...    colleague_id=${dynamic_user_object}[employee_id]
    ...    record_effective_from=${current_day_date}
    ...    last_name=${dynamic_user_object}[lastName]
    ...    first_name=${dynamic_user_object}[firstName]
    ...    job_title=${job_title}
    ...    job_code=${job_code}
    ...    job_effective_date=${current_day_date}
    ...    date_of_hire=${current_week_start_date}
    ...    home_store_id=${store_data}[store_id]
    ...    home_staff_group_id=${staff_group_id}
    ...    home_job_id=${staff_group_id}
    ...    home_department_id=${department_id}
    ...    home_department_effective_date=${current_week_start_date}
    ...    full_time_part_time_indicator=${full_time_part_time_indicator}
    ...    gte_30_lt_30h_indicator=${full_time_part_time_indicator}
    ...    salaried_hourly=${salaried_hourly}
    ...    contract_group=${contract_group}
    ...    contract_effective_date=${current_day_date}
    ...    state_code=${state_code}
    ...    country_code=${country_code}
    ...    base_wage_effective_date=${current_week_start_date}
    ...    badge_number=${dynamic_user_object}[employee_id]
    ...    badge_effective_date=${current_day_date}
    ...    status_effective_date=${current_day_date}
    ...    partner_role_code=${partner_role_code}
    ...    additional_field=${additional_field}
    ...    supervisor_employee_id=${EMPTY}
    ...    full_time_date=${EMPTY}
    ...    gte_30_date=${EMPTY}

    RETURN    ${hrba_ess_nhx_store2}
