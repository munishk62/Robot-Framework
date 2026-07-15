*** Settings ***
Documentation       RWS Upload page related keyword implementation

Resource            resources/web/common/common.resource
Variables           resources/web/rws/admin/rws_upload_page.py
Variables           resources/web/rws/employee/request_calendar_api.py
Resource            resources/api/api_executor.resource
Resource            resources/web/rws/admin/rws_logs.resource
Resource            resources/web/common/common_date_utility.resource
Library             DateTime
Library             resources/web/common/utility.py


*** Variables ***
${HRAC_IMPORT_FILE_DIR}     web/external_files/rws_upload/hrac


*** Keywords ***
Navigate To RWS Admin RWS Upload Page On Web
    [Documentation]    Navigate To RWS -> Admin -> RWS Upload Page
    ...    and verifies RWS upload heading at the top of the page
    Navigate To Specific Page On Web    rws    admin    rws_upload

Create HRAC Import File On Web
    [Documentation]    This keyword replaces placeholders in HRAC file and creates a new HRAC import file
    [Arguments]    ${associate_id}    ${current_date}    ${no_of_days}    ${leave_balance_type}
    Run Keyword And Ignore Error    Remove File    ${HRAC_IMPORT_FILE_PATH}
    ${file_content}=    OperatingSystem.Get File    ${HRAC_TEMPLATE_FILE_PATH}
    ${updated_content}=    Replace String    ${file_content}    "placeholder_emp_id"    ${associate_id}
    ${updated_content}=    Replace String    ${updated_content}    "placeholder_current_date"    ${current_date}
    ${updated_content}=    Replace String    ${updated_content}    "placeholder_no_of_days"    ${no_of_days}
    ${updated_content}=    Replace String    ${updated_content}    "placeholder_leave_type"    ${leave_balance_type}
    Create File    ${HRAC_IMPORT_FILE_PATH}    ${updated_content}
    File Should Not Be Empty    ${HRAC_IMPORT_FILE_PATH}

Upload HRAC File On Web
    [Documentation]    This keyword uploads HRAC file on RWS Upload page
    ${rws_upload_data_type}=    Get System Value    RWSUploadDataType    HRAC
    Select List Item On Webpage    ${RWS_UPLOAD_PAGE_DATATYPE_DROPDOWN}    attribute=text    value=${rws_upload_data_type}
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_RAW_FORMAT_DETAILS_LBL}
    Upload File By Selector    ${RWS_UPLOAD_PAGE_FILE_NAME_TXT}    path=${HRAC_IMPORT_FILE_PATH}
    Click Element On Webpage    ${RWS_UPLOAD_PAGE_FILE_UPLOAD_BTN}
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_PREVIOUS_BTN}
    ...    error_message=Previous button is not visible after HRAC file upload

Assert HRAC File Upload Is Successful On Web
    [Documentation]    This keyword verifies HRAC file upload success message
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_RECORD_PROCESSED_LBL}
    ...    error_message=HRAC file upload success message is not visible
    Capture Screenshot On Webpage

Get Accrual Leave Balance For Employee Via API
    [Documentation]    This keyword fetches the accrual leave balance for the given employee via API
    [Arguments]    ${user_key}
    ${server_df}=    Get Config Value    SERVER_DF
    ${current_date}=    Get Current Date    result_format=${server_df}
    Generate Auth Token With User Credentials    user_key=${user_key}
    ${api_response}=    Send A Post Request    ${RWS_FETCH_LEAVE_ACCRUALS}    ${current_date}
    RETURN    ${api_response}

Perform HRAC Upload Operation On Web
    [Documentation]    This keyword performs HRAC operation on web for the given employee
    [Arguments]    ${associate_id}    ${current_date}    ${leave_balance_to_add_deduct}    ${leave_balance_type}
    Navigate To RWS Admin RWS Upload Page On Web
    Create HRAC Import File On Web    ${associate_id}    ${current_date}    ${leave_balance_to_add_deduct}    ${leave_balance_type}
    Upload HRAC File On Web
    Assert HRAC File Upload Is Successful On Web

Create HRAC Leave Accrual File
    [Documentation]    Creates HRAC leave accrual .txt file from resolved template data
    ...
    ...    **Separation of Concerns:** This keyword ONLY creates the file.
    ...    Test cases should fetch template data using Get Hrac Import Data.
    ...
    ...    **File Format:**
    ...    HH,,
    ...    HRAC,RFLX,<employee_id>,<effective_date>,I,<leave_type>,<no_of_days>,D,,
    ...    TT,,
    ...
    ...    | =Arguments= | =Description= |
    ...    | file_path | Full path where HRAC file will be created (e.g., web/Generated/HRAC_Leave_Accrual.txt) |
    ...    | template_data | Resolved template data dictionary from Get Hrac Import Data |
    ...
    ...    Example usage:
    ...    | ${hrac_data}= | Get Hrac Import Data | employee_id=123 | leave_balance_type=VAC |
    ...    | ${file_path}= | Set Variable | web/Generated/HRAC_Leave_Accrual.txt |
    ...    | Create HRAC Leave Accrual File | ${file_path} | ${hrac_data} |
    [Arguments]    ${file_path}    ${template_data}
    # Define file header and footer
    VAR    ${header}=    HH,,
    VAR    ${footer}=    TT,,
    # Build data row using field_order metadata (consistent with HRBA/HRCI approach)
    ${data_row}=    Build CSV Row From Field Order    ${template_data}
    # Combine into full file content
    VAR    @{rows}=    ${header}    ${data_row}    ${footer}
    ${content}=    Catenate    SEPARATOR=\n    @{rows}
    # Create file
    Run Keyword And Ignore Error    Remove File    ${file_path}
    Create File    ${file_path}    ${content}
    Log To Console    HRAC Leave Accrual file created at: ${file_path}
    RETURN    ${file_path}

Upload HRAC Leave Accrual File Via UI
    [Documentation]    Uploads HRAC leave accrual file via RWS Upload UI and verifies success
    ...
    ...    Extracts filename from file path for log verification automatically.
    ...
    ...    | =Arguments= | =Description= |
    ...    | file_path | Full path to HRAC leave accrual .txt file |
    ...
    ...    Example usage:
    ...    | Upload HRAC Leave Accrual File Via UI | web/Generated/HRAC_Leave_Accrual.txt |
    [Arguments]    ${file_path}
    # Select HRAC data type
    ${hrac_data_type}=    Get System Value    RWSUploadDataType    HRAC
    Wait Until Element Is Visible On Webpage    ${RWS_UPLOAD_PAGE_DATATYPE_DROPDOWN}    timeout=${MEDIUM_TIMEOUT}
    Select Options By    ${RWS_UPLOAD_PAGE_DATATYPE_DROPDOWN}    text    ${hrac_data_type}
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_RAW_FORMAT_DETAILS}
    # Upload file
    Upload File By Selector    ${RWS_UPLOAD_PAGE_FILE_NAME_TXT}    path=${file_path}
    Click Element On Webpage    ${RWS_UPLOAD_PAGE_FILE_UPLOAD_BTN}
    # Verify upload success
    Assert HRAC File Upload Is Successful On Web
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_PREVIOUS_BTN}
    Log To Console    HRAC Leave Accrual file uploaded successfully
    # Extract filename from path for log verification (remove directory path and extension)
    ${filename_with_ext}=    Evaluate    "${file_path}".split("/")[-1]
    ${log_verify_file_name}=    Evaluate    "${filename_with_ext}".rsplit(".", 1)[0]
    Log To Console    Verifying log entry for file: ${log_verify_file_name}
    # Verify log entry
    Verify HRAC Log Entry On RWS Logs Page    ${log_verify_file_name}

Perform HRAC Leave Accrual Upload Via UI
    [Documentation]    Complete workflow: Create HRAC leave accrual file and upload via UI
    ...
    ...    **Separation of Concerns:** Test case fetches data, this keyword handles upload workflow.
    ...
    ...    | =Arguments= | =Description= |
    ...    | file_path | Full path where HRAC file will be created |
    ...    | template_data | Resolved template data from Get Hrac Import Data |
    ...
    ...    Example usage:
    ...    | ${hrac_data}= | Get Hrac Import Data | employee_id=123 | leave_balance_type=VAC |
    ...    | ${file_path}= | Set Variable | web/Generated/HRAC_Leave_Accrual.txt |
    ...    | Perform HRAC Leave Accrual Upload Via UI | ${file_path} | ${hrac_data} |
    [Arguments]    ${file_path}    ${template_data}
    # Navigate to RWS Upload page
    Navigate To RWS Admin RWS Upload Page On Web
    # Create HRAC file from resolved data (file_path first, template_data second)
    Create HRAC Leave Accrual File    ${file_path}    ${template_data}
    # Upload file and verify (log file name extracted from file path)
    Upload HRAC Leave Accrual File Via UI    ${file_path}
    Log To Console    HRAC Leave Accrual upload completed successfully

Build CSV Row From Field Order
    [Documentation]    Builds a CSV row from template data using explicit field_order metadata
    ...
    ...    This ensures deterministic field ordering for CSV file generation,
    ...    preventing flaky failures from unpredictable dictionary iteration.
    ...
    ...    | =Arguments= | =Description= |
    ...    | template_data | Dictionary with field names, values, and field_order metadata |
    ...
    ...    *Important*: Template MUST include 'field_order' key (list of field names in correct order).
    ...
    ...    Example usage:
    ...    | ${csv_row}= | Build CSV Row From Field Order | ${template_data} |
    [Arguments]    ${template_data}
    # Validate field_order exists
    ${has_field_order}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${template_data}    field_order
    IF    not ${has_field_order}
        Fail
        ...    Template missing 'field_order' metadata. This is required to ensure correct CSV field ordering. Add 'field_order' array to the template JSON.
    END
    ${field_order}=    Get From Dictionary    ${template_data}    field_order
    # Build CSV row using explicit field order
    VAR    @{field_values}=    @{EMPTY}
    FOR    ${field_name}    IN    @{field_order}
        ${field_value}=    Get From Dictionary    ${template_data}    ${field_name}    default=${EMPTY}
        # Do NOT quote values - HRAC uses unquoted CSV format
        Append To List    ${field_values}    ${field_value}
    END
    # Join with commas to create CSV row
    ${csv_row}=    Catenate    SEPARATOR=,    @{field_values}
    RETURN    ${csv_row}

Setup HRAC Import For New Hire
    [Documentation]    Imports leave balance (HRAC) for the dynamically created new hire employee.
    ...
    ...    This keyword imports HR Associate Leave Accrual Details (HRAC) to add leave balance
    ...    for the new hire employee, which is required for testing day off requests with leave types.
    ...
    ...    **Workflow:**
    ...    1. Get dynamic new hire user from suite variable
    ...    2. Get current date for HRAC import
    ...    3. Fetch HRAC template data using Get Hrac Import Data
    ...    4. Login as Corp user (SYSADMIN)
    ...    5. Upload HRAC file via UI
    ...    6. Verify upload success
    ...    7. Verify log entry on RWS Logs page
    ...    8. Cleanup (file deletion handled by Create HRAC Leave Accrual File)
    ...
    ...    **Separation of Concerns:**
    ...    - This keyword handles the setup workflow
    ...    - Get Hrac Import Data fetches template data
    ...    - Perform HRAC Leave Accrual Upload Via UI handles file creation and upload
    ...
    ...    **Parameters:**
    ...    | =Arguments=    | =Description=    | =Required=    |
    ...    | user_key    | New hire user key from SUITE_DYNAMIC_EMPLOYEES (e.g., ESSNH1_STORE2, ESSNH2_STORE2)    | Optional (default: ESSNH2_STORE2)    |
    ...    | leave_balance_days    | Number of leave days to add    | Optional (default: 10)    |
    ...    | leave_type    | Leave balance type KEY from HRACLeaveBalanceType constant (e.g., VACATION, SICK)    | **REQUIRED - NO DEFAULT**    |
    ...
    ...    **Important:**
    ...    - The leave_type parameter is **MANDATORY** and has NO default value
    ...    - It expects the CONSTANT KEY (e.g., VACATION), not the value (VAC)
    ...    - The keyword will look up the value from environment-specific HRACLeaveBalanceType constant
    ...    - This ensures environment-agnostic tests - the constant key is always used
    ...
    ...    **Example:**
    ...    | ${leave_type_key}= | Set Variable | VACATION |
    ...    | Setup HRAC Import For New Hire | user_key=ESSNH1_STORE2 | leave_balance_days=10 | leave_type=${leave_type_key} |
    ...
    ...    Or for different environments:
    ...    | Setup HRAC Import For New Hire | leave_type=VACATION | leave_balance_days=10 | user_key=ESSNH2_STORE2 |
    ...    | Setup HRAC Import For New Hire | leave_type=SICK | leave_balance_days=10 | user_key=ESSNH1_STORE2 |
    [Arguments]    ${leave_type}    ${leave_balance_days}=10    ${user_key}=ESSNH2_STORE2
    # Get the dynamic new hire user
    ${new_hire_user}=    Get Dynamic Employee    ${user_key}
    Log    ${new_hire_user}[displayName]
    VAR    ${associate_id}=    ${new_hire_user}[username]

    # Get current date in server format
    ${server_df}=    Get Config Value    SERVER_DF
    ${current_date}=    Get Current Date    result_format=${server_df}

    # Get leave balance type from constants
    ${leave_balance_type}=    Get System Value    HRACLeaveBalanceType    ${leave_type}
    ${leave_balance_action}=    Get System Value    HRACLeaveBalanceAction  LEAVE_BALANCE_UNIT

    IF    not '${leave_balance_action}' == 'H' or '${leave_balance_action}' == 'LEAVE_BALANCE_UNIT'
        VAR    ${leave_balance_action}    D
    ELSE
        ${leave_balance_days}=    Convert Days To Hours And Minutes    ${leave_balance_days}
    END

    Log    Importing leave balance for new hire ${associate_id}: ${leave_balance_days} days of ${leave_balance_type}    level=INFO

    # Fetch HRAC template data with overrides
    ${hrac_data}=    Get Hrac Import Data
    ...    employee_id=${associate_id}
    ...    effective_date=${current_date}
    ...    leave_balance_days=${leave_balance_days}
    ...    leave_balance_type=${leave_balance_type}
    ...    leave_balance_action=${leave_balance_action}

    # Use static file path
    VAR    ${hrac_file_path}=    ${HRAC_IMPORT_FILE_DIR}/hrac_import_file.txt

    # Get corp user for upload operation
    ${corp_user}=    Get User    user_key=SYSADMIN

    TRY
        # Login and perform HRAC import
        Login And Launch WFM Web App    ${corp_user}[user_key]
        Perform HRAC Leave Accrual Upload Via UI    ${hrac_file_path}    ${hrac_data}
        Close Browser
        Log    HRAC import completed successfully for ${associate_id}    level=INFO
        Log    HRAC file created: ${hrac_file_path}    level=INFO
    EXCEPT    AS    ${error}
        Log    HRAC import failed: ${error}    level=WARN
        Run Keyword And Ignore Error    Close Browser
    END

Verify RWS Import Success Notification
    [Documentation]    Verify that RWS import was successful based on notification
    Wait For Load State    networkidle
    Wait Until Element Is Visible On Webpage    ${RWS_UPLOAD_PAGE_RECORD_PROCESSED_CONTAINS_LBL}    timeout=300s
    ...    error_message=RWS import success notification is not visible

    ${notification_text}=    Get Element Text On Webpage    ${RWS_UPLOAD_PAGE_RECORD_PROCESSED_CONTAINS_LBL}
    Should Contain    ${notification_text}    Record Processed
    Log    RWS Import completed successfully: ${notification_text}

Verify User Able To Import HRBA
    [Documentation]    Complete workflow to import HRBA file and verify success
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | file_path    | Full path to HRBA CSV file to upload    |
    ...    | upload_timeout    | Maximum wait time for upload completion Default: 300s    |
    ...
    ...    Example usage:
    ...    | Verify User Able To Import HRBA | ${hrba_file_path} | upload_timeout=600s |
    [Arguments]    ${file_path}    ${upload_timeout}=300s
    Navigate To RWS Admin RWS Upload Page On Web
    Upload HRBA File Via UI    ${file_path}    ${upload_timeout}

Set Employee Status Via HRCI Upload
    [Documentation]    Sets employee status by uploading HRCI file and verifies the log entry
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | emp_id    | Employee ID for status change    |
    ...    | hrci_file_path    | Path where HRCI file will be created    |
    ...    | hrci_log_verify_file_name    | File name to verify in RWS Logs page    |
    ...    | status_change    | Status code (L, A, T, I)    |
    ...
    ...    Example usage:
    ...    | Set Employee Status Via HRCI Upload | ${emp_id} | ${file_path} | ${log_file} | T |
    [Arguments]    ${emp_id}    ${hrci_file_path}    ${hrci_log_verify_file_name}    ${status_change}
    Navigate To RWS Admin RWS Upload Page On Web
    Create HRCI File For Employee Status Change    ${emp_id}    ${hrci_file_path}    ${status_change}
    Upload HRCI File And Verify Completion    ${hrci_file_path}
    Verify HRCI Log Entry On RWS Logs Page    ${hrci_log_verify_file_name}

Select HRBA Import Data Type
    [Documentation]    Select HR Associate Basic Details Import data type
    Wait Until Element Is Visible On Webpage    ${RWS_UPLOAD_PAGE_DATATYPE_DROPDOWN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Data type dropdown is not visible on RWS Upload page on web
    Select List Item On Webpage    ${RWS_UPLOAD_PAGE_DATATYPE_DROPDOWN}    value    120010
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_RAW_FORMAT_DETAILS}
    ...    error_message=HR Associate Basic Details Import format details are not visible after selecting data type

Upload HRBA File Via UI
    [Documentation]    Upload HRBA file through the RWS Upload UI
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | file_path    | Full path to HRBA CSV file to upload    |
    ...    | upload_timeout    | Maximum wait time for upload completion Default: 300s    |
    ...
    ...    Example usage:
    ...    | Upload HRBA File Via UI | ${hrba_file_path} | upload_timeout=600s |
    [Arguments]    ${file_path}    ${upload_timeout}=300s
    Select HRBA Import Data Type
    Upload File And Submit RWS    ${file_path}    ${upload_timeout}

Upload File And Submit RWS
    [Documentation]    Upload file and click upload button for RWS uploads with error handling
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | file_path    | Full path to file to upload    |
    ...    | upload_timeout    | Maximum wait time for upload completion Default: 300s    |
    ...
    ...    Example usage:
    ...    | Upload File And Submit RWS | ${file_path} | upload_timeout=600s |
    [Arguments]    ${file_path}    ${upload_timeout}=300s
    Wait Until Page Is Loaded
    Wait For Load State    networkidle
    # Upload file
    Upload File By Selector    ${RWS_UPLOAD_PAGE_FILE_NAME_TXT}    path=${file_path}

    # Click upload button and wait for completion with timeout
    Click Element On Webpage    ${RWS_UPLOAD_PAGE_FILE_UPLOAD_BTN}
    Wait For Elements State    ${RWS_UPLOAD_PAGE_FILE_UPLOAD_BTN}    hidden    timeout=${upload_timeout}
    Verify RWS Import Success Notification

Create HRCI File For Employee Status Change
    [Documentation]    Creates the HRCI CSV file with the specified format for employee status change
    ...
    ...    Accepts either a single employee ID or a list of employee IDs.
    ...
    ...    **HRCI file format:**
    ...    HH,,,
    ...    HRCI,<emp_id>,STATUS_CHANGE,<date_YYYYMMDD>,,<status_code>
    ...    TT,,,
    ...
    ...    **Date Logic:** Uses current date minus 2 days for status change date
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | employee_ids    | Single employee ID or list of employee IDs    |
    ...    | hrci_file_path    | Path where HRCI file will be created    |
    ...    | status_change    | Status code (L=Long Leave, A=Active, T=Terminate)    |
    ...
    ...    Example usage:
    ...    | Create HRCI File For Employee Status Change | ${emp_id} | ${file_path} | T |
    ...    | Create HRCI File For Employee Status Change | @{emp_list} | ${file_path} | A |
    [Arguments]    ${employee_ids}    ${hrci_file_path}    ${status_change}

    ${from_date_format}=    Get Config Value    DATE_FMT_YEAR_MONTH_DAY
    ${required_date_format}=    Get Config Value    SERVER_DF

    # Calculate date as current date minus 2 days
    ${current_date}=    Get Current Date    result_format=${from_date_format}
    ${specific_date}=    Subtract Time From Date    ${current_date}    2 days    result_format=${required_date_format}
    VAR    ${header}=    HH,,,
    VAR    ${footer}=    TT,,,
    VAR    @{rows}=    ${header}

    # Convert single employee ID to list if needed
    IF    not isinstance($employee_ids, list)
        VAR    @{emp_list}=    ${employee_ids}
    ELSE
        VAR    @{emp_list}=    @{employee_ids}
    END

    FOR    ${emp_id}    IN    @{emp_list}
        Log To Console    Processing employee ID: ${emp_id}
        VAR    ${row}=    HRCI,${emp_id},STATUS_CHANGE,${specific_date},,${status_change}
        Append To List    ${rows}    ${row}
    END
    Append To List    ${rows}    ${footer}
    ${content}=    Catenate    SEPARATOR=\n    @{rows}
    Create File    ${hrci_file_path}    ${content}
    Log To Console    HRCI file created at: ${hrci_file_path}

Upload HRCI File And Verify Completion
    [Documentation]    Uploads HRCI file to RWS Upload page and verifies upload completion
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | file_path    | Full path to HRCI CSV file to upload    |
    ...
    ...    Example usage:
    ...    | Upload HRCI File And Verify Completion | ${hrci_file_path} |
    [Arguments]    ${file_path}
    Wait Until Element Is Visible On Webpage    ${RWS_UPLOAD_PAGE_DATATYPE_DROPDOWN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Data type dropdown is not visible on RWS Upload page on web
    Select List Item On Webpage    ${RWS_UPLOAD_PAGE_DATATYPE_DROPDOWN}    value    120026
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_RAW_FORMAT_DETAILS}
    ...    error_message=HR Changes Import format details are not visible after selecting data type
    Upload File By Selector    ${RWS_UPLOAD_PAGE_FILE_NAME_TXT}    path=${file_path}
    Click Element On Webpage    ${RWS_UPLOAD_PAGE_FILE_UPLOAD_BTN}
    Verify HRCI Upload Success Message
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_PREVIOUS_BTN}
    ...    error_message=Previous button is not visible after HRCI file upload
    Log To Console    HRCI file uploaded successfully

Verify HRCI Upload Success Message
    [Documentation]    Verifies that the HRCI file upload success notification is displayed
    Wait For Load State    networkidle    ${PAGE_LOAD_TIMEOUT}
    Wait Until Element Is Visible On Webpage    ${RWS_UPLOAD_PAGE_RECORD_PROCESSED_CONTAINS_LBL}    timeout=60s
    ...    error_message=HRCI file upload success notification is not visible
    ${notification_text}=    Get Element Text On Webpage    ${RWS_UPLOAD_PAGE_RECORD_PROCESSED_CONTAINS_LBL}
    Should Contain    ${notification_text}    Record Processed
    Log To Console    RWS HRCI File upload notification verified successfully: ${notification_text}

Replace Placeholders In HRCI File
    [Documentation]    Replaces placeholders in HRCI file with actual values
    ...
    ...    Replaces: "placeholder_emp_id" and "placeholder_past_date"
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | file_path    | Path to template HRCI file with placeholders    |
    ...    | output_hrci_file    | Path where updated HRCI file will be created    |
    ...    | emp_id    | Employee ID to replace placeholder_emp_id    |
    ...
    ...    Example usage:
    ...    | Replace Placeholders In HRCI File | ${template} | ${output} | ${emp_id} |
    [Arguments]    ${file_path}    ${output_hrci_file}    ${emp_id}
    ${file_content}=    Get File    ${file_path}
    ${past_date}=    Get Previous Month First
    ${updated_content}=    Replace String    ${file_content}    "placeholder_emp_id"    ${emp_id}
    ${updated_content}=    Replace String    ${updated_content}    "placeholder_past_date"    ${past_date}
    Create File    ${output_hrci_file}    ${updated_content}
    Log To Console    Placeholders replaced in HRCI file: ${output_hrci_file}

Generate HRBA Import File For Two Associates With Dynamic Emp IDs
    [Documentation]    Generates HRBA import file for two associates with dynamic employee and badge IDs
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | hrba_template_file_path    | Path to HRBA template file with placeholders    |
    ...    | hrba_import_file_path    | Path where HRBA import file will be created    |
    ...    | associate1_emp_id    | Employee ID for first associate    |
    ...    | associate1_badge_id    | Badge ID for first associate    |
    ...    | associate2_emp_id    | Employee ID for second associate    |
    ...    | associate2_badge_id    | Badge ID for second associate    |
    ...
    ...    Example usage:
    ...    | Generate HRBA Import File For Two Associates With Dynamic Emp IDs | ${template_path} | ${import_path} | 12345 | B001 | 67890 | B002 |
    [Arguments]    ${hrba_template_file_path}
    ...    ${hrba_import_file_path}
    ...    ${associate1_emp_id}
    ...    ${associate1_badge_id}
    ...    ${associate2_emp_id}
    ...    ${associate2_badge_id}

    ${file_content}=    OperatingSystem.Get File    ${hrba_template_file_path}

    # Replace placeholders for first associate
    ${updated_content}=    Replace String    ${file_content}    "place_holder_emp_id1"    ${associate1_emp_id}
    ${updated_content}=    Replace String    ${updated_content}    "place_holder_badge_id1"    ${associate1_badge_id}

    # Replace placeholders for second associate
    ${updated_content}=    Replace String    ${updated_content}    "place_holder_emp_id2"    ${associate2_emp_id}
    ${updated_content}=    Replace String    ${updated_content}    "place_holder_badge_id2"    ${associate2_badge_id}

    Run Keyword And Ignore Error    Remove File    ${hrba_import_file_path}
    Create File    ${hrba_import_file_path}    ${updated_content}

Generate HRCI Import File
    [Documentation]    Generates HRCI import file for an associate with dynamic employee ID
    ...
    ...    Replaces placeholders in the template file:
    ...    - "place_holder_emp_id" -> ${associate_id}
    ...    - "placeholder_current_date" -> ${current_date}
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | hrci_template_file_path    | Path to HRCI template file with placeholders    |
    ...    | hrci_import_file_path    | Path where HRCI import file will be created    |
    ...    | associate_id    | Employee ID to replace place_holder_emp_id    |
    ...    | current_date    | Current date in required format for HRCI file    |
    ...
    ...    Example usage:
    ...    | Generate HRCI Import File | ${template_path} | ${import_path} | 12345 | 2024-06-15 |
    [Arguments]    ${hrci_template_file_path}
    ...    ${hrci_import_file_path}
    ...    ${associate_id}
    ...    ${current_date}

    ${file_content}=    OperatingSystem.Get File    ${hrci_template_file_path}

    IF    $associate_id is $None or str($associate_id).strip() == ''
        Log    Associate ID is empty or whitespace. Employee ID is required to generate HRCI import file.    level=WARN
        Fail    associate_id cannot be empty or whitespace
    END

    ${updated_content}=    Replace String    ${file_content}    "place_holder_emp_id"    ${associate_id}
    ${updated_content}=    Replace String    ${updated_content}    "placeholder_current_date"    ${current_date}

    Run Keyword And Ignore Error    Remove File    ${hrci_import_file_path}
    Create File    ${hrci_import_file_path}    ${updated_content}

Create HRCI Store Transfer File
    [Documentation]    Creates HRCI store transfer .txt file from resolved template data
    ...
    ...    **Separation of Concerns:** This keyword ONLY creates the file.
    ...    Test cases should fetch template data using Get Hrci Store Transfer Data.
    ...
    ...    **File Format:**
    ...    HH,,,,,,,,
    ...    "HRCI","<employee_id>","STORE_XFER","<effective_date>","<end_date>","<home_store_id>","<home_department_id>","<home_staff_group_id>"
    ...    TT,,,,,,,,
    ...
    ...    | =Arguments= | =Description= |
    ...    | file_path | Output path for HRCI store transfer file (e.g., web/Generated/HRCI_Store_Transfer.txt) |
    ...    | template_data | Resolved template data dictionary from Get Hrci Store Transfer Data |
    ...
    ...    Example usage:
    ...    | ${hrci_data}= | Get Hrci Store Transfer Data | employee_id=123 | home_store_id=STORE1 |
    ...    | Create HRCI Store Transfer File | ${file_path} | ${hrci_data} |
    [Arguments]    ${file_path}    ${template_data}

    # Define file header and footer
    VAR    ${header}=    HH,,,,,,,,
    VAR    ${footer}=    TT,,,,,,,,

    # Build data row using field_order metadata (consistent with HRBA/HRCI approach)
    ${data_row}=    Build HRCI Store Transfer Data From Template Data    ${template_data}

    # Combine into full file content
    VAR    @{rows}=    ${header}    ${data_row}    ${footer}
    ${content}=    Catenate    SEPARATOR=\n    @{rows}

    # Create file
    Run Keyword And Ignore Error    Remove File    ${file_path}
    Create File    ${file_path}    ${content}
    Log    HRCI Store Transfer file created at: ${file_path}

Upload HRCI Store Transfer File On Web
    [Documentation]    Uploads HRCI store transfer file via RWS Upload UI and verifies success
    ...
    ...    Extracts filename from file path for log verification automatically.
    ...
    ...    | =Arguments= | =Description=    |
    ...    | file_path | Full path to HRCI store transfer .txt file |
    ...
    ...    Example usage:
    ...    | Upload HRCI Store Transfer File On Web | web/Generated/HRCI_Store_Transfer.txt |
    [Arguments]    ${file_path}

    # Select HRCI data type
    Select List Item On Webpage    ${RWS_UPLOAD_PAGE_DATATYPE_DROPDOWN}    text    HR Changes Import
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_RAW_FORMAT_DETAILS}
    ...    error_message=HR Changes Import format details are not visible after selecting data type

    # Upload file
    Upload File By Selector    ${RWS_UPLOAD_PAGE_FILE_NAME_TXT}    path=${file_path}
    Click Element On Webpage    ${RWS_UPLOAD_PAGE_FILE_UPLOAD_BTN}

    # Verify upload success
    Verify HRCI Upload Success Message
    Wait Until Element Is Present On Webpage    ${RWS_UPLOAD_PAGE_PREVIOUS_BTN}
    ...    error_message=Previous button is not visible after HRCI store transfer file upload
    Log    HRCI Store Transfer file uploaded successfully

    # Extract filename from path for log verification (remove directory path and extension)
    ${filename_with_ext}=    Evaluate    "${file_path}".split("/")[-1]
    ${log_verify_file_name}=    Evaluate    "${filename_with_ext}".rsplit(".", 1)[0]
    Log    Verifying log entry for file: ${log_verify_file_name}

    # Verify log entry
    Verify HRCI Log Entry On RWS Logs Page    ${log_verify_file_name}

Perform HRCI Store Transfer Upload On Web
    [Documentation]    Complete workflow: Create HRCI store transfer file and upload via UI
    ...
    ...    **Separation of Concerns:** Test case fetches data, this keyword handles upload workflow.
    ...
    ...    | =Arguments= | =Description= |
    ...    | file_path | Output path for HRCI file (e.g., web/Generated/HRCI_Store_Transfer.txt) |
    ...    | template_data | Resolved template data from Get Hrci Store Transfer Data |
    ...
    ...    Example usage:
    ...    | ${hrci_data}= | Get Hrci Store Transfer Data | employee_id=123 | home_store_id=STORE1 |
    ...    | Perform HRCI Store Transfer Upload On Web | ${file_path} | ${hrci_data} |
    [Arguments]    ${file_path}    ${template_data}

    # Navigate to RWS Upload page
    Navigate To RWS Admin RWS Upload Page On Web

    # Create HRCI file from resolved data
    Create HRCI Store Transfer File    ${file_path}    ${template_data}

    # Upload file and verify (log file name extracted from file path)
    Upload HRCI Store Transfer File On Web    ${file_path}

    Log    HRCI Store Transfer upload completed successfully

Build HRCI Store Transfer Data From Template Data
    [Documentation]    Builds HRCI store transfer data row from template data with proper field ordering
    ...
    ...    This ensures deterministic field ordering for HRCI store transfer file generation,
    ...    preventing flaky failures from unpredictable dictionary iteration.
    ...
    ...    | =Arguments= | =Description= |
    ...    | template_data | Dictionary with field names and values |
    ...
    ...    Example usage:
    ...    | ${data_row}= | Build HRCI Store Transfer Data From Template Data | ${template_data} |
    [Arguments]    ${template_data}
    # Validate field_order exists
    ${has_field_order}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${template_data}    field_order
    IF    not ${has_field_order}
        Fail
        ...    Template missing 'field_order' metadata. This is required to ensure correct CSV field ordering. Add 'field_order' array to the template JSON.
    END
    ${field_order}=    Get From Dictionary    ${template_data}    field_order
    # Build HRCI store transfer data row using explicit field order
    VAR    @{field_values}=    @{EMPTY}
    FOR    ${field_name}    IN    @{field_order}
        ${field_value}=    Get From Dictionary    ${template_data}    ${field_name}    default=${EMPTY}
        # Quote the value for CSV format
        VAR    ${quoted_value}=    "${field_value}"
        Append To List    ${field_values}    ${quoted_value}
    END
    # Join fields with commas to create data row
    ${csv_row}=    Catenate    SEPARATOR=,    @{field_values}
    RETURN    ${csv_row}
