*** Settings ***
Documentation       Test case to Verify HRBA and HRCI data loads

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/user_Profile/user_profile.resource
Resource            resources/web/rws/admin/rws_upload.resource
Resource            resources/web/rws/users/users.resource
Resource            resources/web/ess/my_profile.resource
Resource            resources/web/rws/admin/rws_upload_api.resource

Test Teardown       Close Browser

Test Tags           dev:ravi    battc00018    bat_phase2    action:write    config:ess    config:rws    om_hr


*** Test Cases ***
BATTC00018: Verify HRBA and HRCI data loads
    [Documentation]    Test case to Verify HRBA and HRCI data loads

    @{hrba_data}=    Create Dynamic HRBA Data
    ${has_hrba_data}=    Evaluate    len($hrba_data) > 0
    IF    not ${has_hrba_data}
        Fail    No HRBA data was generated. Cannot continue with HRBA/HRCI flow.
    END
    VAR    ${associate_id}=    ${hrba_data}[0][employee_id]
    ${hrba_file_path}=    Create HRBA File    ${hrba_data}

    VAR    ${test_env}=    %{TEST_ENVIRONMENT=${EMPTY}}
    VAR    ${base_dir}=    ${EXECDIR}

    VAR    ${hrci_template_file_path}=    ${base_dir}/web/external_files/rws_upload/hrci/hrci_template_file.txt
    VAR    ${hrci_import_file_path}=    ${base_dir}/web/external_files/rws_upload/hrci/hrci_import_file_${test_env}.txt
    OperatingSystem.File Should Exist    ${hrci_template_file_path}

    ${date_format}=    Get Config Value    SERVER_DF
    ${current_date}=    Get Current Date    result_format=${date_format}

    Generate HRCI Import File
    ...    ${hrci_template_file_path}    ${hrci_import_file_path}
    ...    ${associate_id}    ${current_date}

    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Admin RWS Upload Page On Web
    Upload HRBA File Via UI    ${hrba_file_path}

    Navigate To RWS Users User Page On Web
    Verify User Is Created Successfully    ${associate_id}

    Navigate To RWS Admin RWS Upload Page On Web
    Upload HRCI File And Verify Completion    ${hrci_import_file_path}
    Verify HRCI Upload Success Message

    Navigate To RWS Users User Page On Web
    Delete Newly Created Users And Verify Deletion On Web    ${associate_id}


*** Keywords ***
Login To WFM As ESS User And Navigate To My Profile Page On Web
    [Documentation]    Login to WFM and navigate to My Profile page for multiple users by iterating through a list of user IDs.
    [Arguments]    @{user_ids}
    ${app_url}=    Get Config Value    key=app_url
    FOR    ${user_id}    IN    @{user_ids}
        Login With New User On Web    ${user_id}    ${user_id}@123    ${app_url}
        Navigate To ESS My Profile Page On Web
        Log Out From Web Application
        Close Browser
    END

Delete Newly Created Users And Verify Deletion On Web
    [Documentation]    Delete multiple users and verify their deletion by iterating through a list of user IDs.
    [Arguments]    @{user_ids}
    FOR    ${user_id}    IN    @{user_ids}
        Open User Details Page And Delete User On Web    ${user_id}
        Verify User Is Deleted Successfully    ${user_id}
    END

Create Dynamic HRBA Data
    [Documentation]    Creates HRBA template data for one dynamic employee used by this test flow.
    ...
    ...    Creates one employee data payload:
    ...    - ESSNH5_STORE2 (dynamic employee_id in STORE2)
    ...
    ...    | =Returns= | =Description= |
    ...    | hrba_data | List containing one HRBA template dictionary for file generation/import |

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

    VAR    @{hrba_data}=    ${hrba_essnh5_store2}
    RETURN    @{hrba_data}

Create HRBA File
    [Documentation]    Builds HRBA file content from template data and writes it to a .txt file.
    ...    | =Arguments= | =Description= |
    ...    | users_data | List of template dictionaries from Get Hrba Api Upload Data. |
    ...    | =Returns= | =Description= |
    ...    | file_path | Full path of the generated HRBA import file |
    ...    Example usage:
    ...    | ${user1}= | Get Hrba Api Upload Data | partner_id=EMP001 | last_name=Smith | home_store_id=STORE01 |
    ...    | ${user2}= | Get Hrba Api Upload Data | partner_id=EMP002 | last_name=Jones | home_store_id=STORE01 |
    ...    | @{users}= | Create List | ${user1} | ${user2} |
    ...    | ${file_path}= | Create HRBA File | ${users} |
    [Arguments]    ${users_data}

    ${payload}=    Build Data Import Payload    ${users_data}

    ${payload_data}=    Get From Dictionary    ${payload}    data
    ${has_payload_data}=    Evaluate    len($payload_data) > 0

    IF    not ${has_payload_data}
        Log    HRBA payload data node is empty
        Fail    HRBA payload data node is empty. Cannot write hrba_file.txt.
    END

    ${payload_rows}=    Evaluate    '\\n'.join(json.dumps(item) for item in $payload_data)    json
    ${payload_rows}=    Replace String    ${payload_rows}    "    ${EMPTY}
    ${payload_rows}=    Replace String    ${payload_rows}    [    ${EMPTY}
    ${payload_rows}=    Replace String    ${payload_rows}    ]    ${EMPTY}
    ${payload_rows}=    Replace String    ${payload_rows}    ,${SPACE}    ,
    ${payload_rows}=    Catenate    SEPARATOR=\n    ${payload_rows}    TT,,
    ${payload_rows}=    Catenate    SEPARATOR=\n    HH    ${payload_rows}

    # Write payload rows to file (one JSON object per line, no brackets)
    VAR    ${test_env}=    %{TEST_ENVIRONMENT=${EMPTY}}
    VAR    ${file_path}=    ${EXECDIR}/web/external_files/rws_upload/hrba/hrba_file_${test_env}.txt
    Create File    ${file_path}    ${payload_rows}
    RETURN    ${file_path}
