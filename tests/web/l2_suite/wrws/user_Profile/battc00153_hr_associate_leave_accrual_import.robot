*** Settings ***
Documentation       Test case to Verify HR Associate Leave Accrual Details Import (HRAC) data loads

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/admin/rws_upload.resource

Test Teardown       Close Browser

Test Tags           dev:komal    battc00153    config:direct_login    bat_phase2    action:write    config:rws    om_hr    regrooming_required    refactoring_required_PC00149


*** Test Cases ***
BATTC00153: Verify and add leave balance data for the employee
    [Documentation]    Test case to verify and add leave balance data for the employee through HRAC upload

    # Get ESS6_STORE1 user as specified in test data requirements
    ${ess_user6}    Get User    user_key=ESS6_STORE1
    VAR    ${associate_emp_id}    ${ess_user6}[username]

    ${date_format}    Get Config Value    SERVER_DF
    ${current_date}    Get Current Date    result_format=${date_format}

    # Set up leave balance parameters as specified in test data
    VAR    ${test_env}    %{TEST_ENVIRONMENT=${EMPTY}}
    ${hrac_template_name}    Get System Value    HRACImportTemplate    HRAC_IMPORT_TEMPLATE_NAME
    IF    not $hrac_template_name or '${hrac_template_name}' == 'HRAC_IMPORT_TEMPLATE_NAME'
        VAR    ${hrac_template_name}    default
    END
    ${leave_balance_type}    Get System Value    HRACLeaveBalanceType    VACATION
    ${leave_balance_action}    Get System Value    HRACLeaveBalanceAction    LEAVE_BALANCE_UNIT
    Should Match Regexp    ${leave_balance_action}    ^(H|D)$
    ...    msg=Invalid LEAVE_BALANCE_UNIT: ${leave_balance_action}. Expected H or D. Please add/update constants value.

    VAR    ${leave_balance_to_add}    01:00
    IF    '${leave_balance_action}' == 'D'
        # Convert time format to days (01:00 = 1 hour = 0.125 days for 8-hour workday)
        ${leave_balance_days}    Convert Time To Hours    ${leave_balance_to_add}
        ${leave_balance_days}    Evaluate    ${leave_balance_days} / 8.0    # Convert hours to days
    ELSE
        # For hourly action, keep time in HH:MM format
        VAR    ${leave_balance_days}    ${leave_balance_to_add}
    END

    # Fetch HRAC template data using the modern data provider approach
    ${hrac_data}    Get Generic Entity Data    hrac_import    template_name=${hrac_template_name}
    ...    employee_id=${associate_emp_id}
    ...    effective_date=${current_date}
    ...    leave_balance_type=${leave_balance_type}
    ...    leave_balance_days=${leave_balance_days}
    ...    leave_balance_action=${leave_balance_action}

    # Set up file path for HRAC upload
    VAR    ${hrac_import_file_path}    web/Generated/hrac_import_file_${test_env}.txt

    Login And Launch WFM Web App    user_key=SYSADMIN

    # Use the consolidated keyword for HRAC upload workflow
    Perform HRAC Leave Accrual Upload Via UI    ${hrac_import_file_path}    ${hrac_data}

    # Extract filename for log verification
    ${file_name_only}    Fetch From Right    ${hrac_import_file_path}    /
    ${log_verify_file_name}    Remove String    ${file_name_only}    .txt
    Verify HRAC Log Entry On RWS Logs Page    ${log_verify_file_name}

    Log    HRAC upload completed successfully for associate ${associate_emp_id}
    Log    Leave balance successfully updated. Added ${leave_balance_to_add} hours of ${leave_balance_type}

    # Step 4: Logout from the application
    Log Out From Web Application


*** Keywords ***
Convert Time To Hours
    [Documentation]    Converts time format (HH:MM) to decimal hours
    [Arguments]    ${time_string}

    @{time_parts}    Split String    ${time_string}    :
    ${hours}    Convert To Number    ${time_parts}[0]
    ${minutes}    Convert To Number    ${time_parts}[1]
    ${decimal_hours}    Evaluate    ${hours} + (${minutes} / 60.0)

    RETURN    ${decimal_hours}
