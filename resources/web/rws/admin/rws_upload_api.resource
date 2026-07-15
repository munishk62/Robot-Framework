*** Settings ***
Documentation       RWS Upload API Integration - HRBA & HRCI Data Import Feed APIs
...
...                 This resource provides keywords for data import feed APIs:
...                 - **HRBA API**: Create and manage users
...                 - **HRCI API**: Update user status (rehire, termination, status changes)
...
...                 Both support single or multiple records with direct field overrides.
...
...                 **Key Features:**
...                 - ✅ Create users via HRBA API
...                 - ✅ Update user status via HRCI API
...                 - ✅ Single base template with direct field overrides (no separate templates needed)
...                 - ✅ Reusable payload building
...
...                 **Design Philosophy:**
...                 - ONE base template per API type
...                 - Override specific fields directly for different scenarios
...                 - No need for separate template files
...
...                 **Required Headers:**
...                 - Referer: Base URL
...                 - Content-Type: application/json
...                 - X-reflexis-auth-token-X: Auth token
...                 - X-reflexis-api-key-X: API_KEY_CORP

Library             Collections
Library             DateTime
Library             String
Library             pabot.PabotLib
Library             test_data/TestDataLibrary.py
Resource            resources/api/api_executor.resource
Variables           resources/web/rws/admin/rws_upload_api.py


*** Variables ***
${TEST_USER_PWD_SUFFIX}     @123


*** Keywords ***
Create HRBA Users Via API
    [Documentation]    Creates one or multiple users via HRBA data import feed API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | User credentials key for authentication (e.g., SYSADMIN). |
    ...    | users_data | List of template dictionaries from Get Hrba Api Upload Data. |
    ...    Example usage:
    ...    | ${user1}= | Get Hrba Api Upload Data | partner_id=EMP001 | last_name=Smith | home_store_id=STORE01 |
    ...    | ${user2}= | Get Hrba Api Upload Data | partner_id=EMP002 | last_name=Jones | home_store_id=STORE01 |
    ...    | @{users}= | Create List | ${user1} | ${user2} |
    ...    | ${response}= | Create HRBA Users Via API | SYSADMIN | ${users} |
    [Arguments]    ${user_key}    ${users_data}

    # Build payload from pre-configured templates (reusable for both HRBA and HRCI)
    ${payload}=    Build Data Import Payload    ${users_data}
    ${response}=    Send Data Import Request    ${user_key}    ${payload}    ${DATA_IMPORT_FEED_API_TEMPLATE}    entity_name=HRBA

    RETURN    ${response}

Update HRCI User Status Via API
    [Documentation]    Updates one or multiple user statuses via HRCI data import feed API (termination, rehire, status changes).
    ...    | =Arguments= | =Description= |
    ...    | user_key | User credentials key for authentication (e.g., SYSADMIN). |
    ...    | records_data | List of template dictionaries from Get Hrci Api Upload Data. |
    ...    Example usage - Terminate employee:
    ...    | ${record}= | Get Hrci Api Upload Data | employee_id=2026008008 | effective_date=20260212 | employee_status=T |
    ...    | @{records}= | Create List | ${record} |
    ...    | ${response}= | Update HRCI User Status Via API | SYSADMIN | ${records} |
    [Arguments]    ${user_key}    ${records_data}

    # Build payload from pre-configured templates (reuses same keyword as HRBA)
    ${payload}=    Build Data Import Payload    ${records_data}
    ${response}=    Send Data Import Request    ${user_key}    ${payload}    ${DATA_IMPORT_FEED_API_TEMPLATE}    entity_name=HRCI

    RETURN    ${response}

Build Data Import Payload
    [Documentation]    Builds API payload JSON from pre-configured template dictionaries (works for HRBA, HRCI, HRAC, etc.).
    ...    | =Arguments= | =Description= |
    ...    | records_data | List of template dictionaries from Get Hrba/Hrci Api Upload Data. |
    [Arguments]    ${records_data}

    VAR    @{all_data_arrays}=    @{EMPTY}

    FOR    ${template_data}    IN    @{records_data}
        # Convert template to data array (direct field values only)
        ${data_array}=    Convert Template To Data Array    ${template_data}
        Append To List    ${all_data_arrays}    ${data_array}
    END

    VAR    &{payload}=    data=${all_data_arrays}    metainfo=&{EMPTY}

    RETURN    ${payload}

Convert Template To Data Array
    [Documentation]    Converts template dictionary to ordered array of field values using explicit field_order metadata.
    ...    This ensures correct field ordering for HRBA/HRCI API requirements (matching CSV column order).
    ...    | =Arguments= | =Description= |
    ...    | template_data | Dictionary with field names, values, and field_order metadata from Get Hrba/Hrci Api Upload Data. |
    ...    *Important*: The template MUST include a 'field_order' key (list of field names in correct order).
    ...    This prevents flaky failures caused by unpredictable dictionary iteration order.
    [Arguments]    ${template_data}

    VAR    @{data_array}=    @{EMPTY}

    # Extract field_order metadata (required for deterministic ordering)
    ${has_field_order}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${template_data}    field_order

    IF    not ${has_field_order}
        Fail
        ...    Template missing 'field_order' metadata. This is required to ensure correct API field ordering. Add 'field_order' array to the template JSON.
    END

    ${field_order}=    Get From Dictionary    ${template_data}    field_order

    # Build data array using explicit field order (prevents flaky ordering issues)
    # Note: Metadata fields (test_id, environment, entity_type, field_order) are automatically
    # excluded because they're not in the field_order list
    FOR    ${field_name}    IN    @{field_order}
        # Get field value (use empty string if field missing)
        ${field_value}=    Get From Dictionary    ${template_data}    ${field_name}    default=${EMPTY}
        Append To List    ${data_array}    ${field_value}
    END

    RETURN    ${data_array}

Send Data Import Request
    [Documentation]    Sends data import POST request to API with automatic validation (works for HRBA, HRCI, HRAC, etc.).
    ...    | =Arguments= | =Description= |
    ...    | user_key | User credentials key for authentication (e.g., SYSADMIN). |
    ...    | payload | Dictionary payload with 'data' and 'metainfo' keys. |
    ...    | endpoint_template | Endpoint URL template (e.g., DATA_IMPORT_FEED_API_TEMPLATE). |
    ...    | entity_name | Entity name for logging (e.g., HRBA, HRCI, HRAC). |
    ...    Example usage:
    ...    | ${payload}= | Build Data Import Payload | ${records_data} |
    ...    | ${response}= | Send Data Import Request | SYSADMIN | ${payload} | ${DATA_IMPORT_FEED_API_TEMPLATE} | HRBA |
    [Arguments]    ${user_key}    ${payload}    ${endpoint_template}    ${entity_name}

    # Get base URL from config
    ${base_url}=    Get Config Value    key=base_url

    # Construct the endpoint URL using the template variable (replace {BASE_URL} placeholder)
    ${endpoint}=    Replace String    ${endpoint_template}    {BASE_URL}    ${base_url}

    # Set API key header (required for data import endpoints)
    VAR    ${api_key}=    API_KEY_CORP
    VAR    &{custom_headers}=    X-reflexis-api-key-X=${api_key}

    # Send POST request with automatic auth token caching and custom headers
    ${response}=    Send A WFM POST Request    ${user_key}    ${base_url}    ${endpoint}    body=${payload}
    ...    custom_headers=${custom_headers}

    # Validate response automatically (reuses same validation for all entity types)
    ${validation_passed}=    Run Keyword And Return Status    Validate Data Import Response    ${response}    ${entity_name}

    IF    not ${validation_passed}
        Log    ❌ ${entity_name} Import Failed - Response: ${response}    level=ERROR
        Fail    ${entity_name} import validation failed - check logs for details
    END

    Log    ✅ ${entity_name} Import Successful - Response validated    level=INFO

    RETURN    ${response}

Validate Data Import Response
    [Documentation]    Validates data import API response (works for HRBA, HRCI, HRAC, etc.).
    ...    | =Arguments= | =Description= |
    ...    | response | API response JSON from data import request. |
    ...    | entity_name | Entity name for logging (e.g., HRBA, HRCI, HRAC). |
    [Arguments]    ${response}    ${entity_name}

    # Validate statusCode
    Should Be Equal As Integers    ${response}[statusCode]    1
    ...    msg=${entity_name} API returned error status code: ${response}[statusCode]

    # Extract record summary
    ${record_summary}=    Get From Dictionary    ${response}[metaInfo][summary]    recordSummary
    ${added}=    Get From Dictionary    ${record_summary}    added
    ${updated}=    Get From Dictionary    ${record_summary}    updated
    ${deleted}=    Get From Dictionary    ${record_summary}    deleted
    ${invalid}=    Get From Dictionary    ${record_summary}    invalid
    ${total_processed}=    Get From Dictionary    ${record_summary}    totalProcessed

    # Validate: added OR updated OR deleted should be > 0
    ${successful_records}=    Evaluate    ${added} + ${updated} + ${deleted}
    Should Be True    ${successful_records} > 0
    ...    msg=❌ No records were processed successfully (Added=${added}, Updated=${updated}, Deleted=${deleted})

    # Validate: invalid should always be 0 - if not, extract detailed error information
    IF    ${invalid} > 0
        ${error_details}=    Extract Record Error Details    ${response}    ${entity_name}

        # Log detailed error summary
        Log    ❌ ${entity_name} Import Failed - ${invalid} invalid records found    level=ERROR
        Log    📋 Error Details:\n${error_details}    level=ERROR

        # Fail with detailed error message
        Fail    ❌ ${entity_name} import validation failed - ${invalid} invalid records found\n\n${error_details}
    END

    # Log success summary
    Log    📊 ${entity_name} Import: Added=${added}, Updated=${updated}, Deleted=${deleted}, Invalid=${invalid}, Total=${total_processed}
    ...    level=INFO

Extract Record Error Details
    [Documentation]    Extracts detailed error information from recordsStatus array for failed records.
    ...    | =Arguments= | =Description= |
    ...    | response | API response JSON containing recordsStatus array. |
    ...    | entity_name | Entity name for logging (e.g., HRBA, HRCI, HRAC). |
    [Arguments]    ${response}    ${entity_name}

    ${has_records_status}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${response}[metaInfo][summary]    recordsStatus

    IF    not ${has_records_status}
        RETURN    ❌ No detailed error information available
    END

    ${records_status}=    Get From Dictionary    ${response}[metaInfo][summary]    recordsStatus
    VAR    @{error_lines}=    ${entity_name} IMPORT ERRORS

    FOR    ${record_status}    IN    @{records_status}
        ${status}=    Get From Dictionary    ${record_status}    status    default=UNKNOWN
        IF    '${status}' == 'ERROR'
            ${record_no}=    Get From Dictionary    ${record_status}    recordNo    default=?

            # Get reference record (contains employee ID and detailed reason)
            ${reference_record}=    Get From Dictionary    ${record_status}    referenceRecord    default=@{EMPTY}
            ${reference_info}=    Set Variable If    ${reference_record}    ${reference_record}[0]    No reference info

            # Get error code
            ${errors}=    Get From Dictionary    ${record_status}    errors    default=@{EMPTY}
            ${error_code}=    Set Variable If    ${errors}    ${errors}[0][errorCode]    UNKNOWN
            Append To List    ${error_lines}    Record ${record_no}: ${error_code} - ${reference_info}
        END
    END

    ${error_details}=    Catenate    SEPARATOR=\n    @{error_lines}

    RETURN    ${error_details}

# ============================================================================
# DYNAMIC EMPLOYEE GENERATOR - Runtime Employee ID Generation
# ============================================================================

Generate Dynamic Employee
    [Documentation]    Generates dynamic employee data with unique timestamp-based employee ID.
    ...    | =Arguments= | =Description= |
    ...    | user_key | Reference key for retrieval (e.g., ESSNH1_STORE2, SM1_STORE2). |
    ...    | store_data | Store configuration dictionary from Get Store Data. |
    ...    | profile_type | Profile constant key (REQUIRED). Options: ASSOCIATE, STORE_ADMIN. |
    ...    Example usage - Create Associate:
    ...    | ${store_data}= | Get Store Data | template_name=model_store2 |
    ...    | ${employee}= | Generate Dynamic Employee | ESSNH1_STORE2 | ${store_data} | ASSOCIATE |
    ...    Example usage - Create Store Admin:
    ...    | ${store_data}= | Get Store Data | template_name=model_store2 |
    ...    | ${admin}= | Generate Dynamic Employee | SM1_STORE2 | ${store_data} | STORE_ADMIN |
    [Arguments]    ${user_key}    ${store_data}    ${profile_type}

    # Extract number from user_key (e.g., ESSNH1_STORE2 → 1, ESSNH12_STORE2 → 12)
    # Use regex to find all digits in the user_key and extract the first sequence
    ${matches}=    Get Regexp Matches    ${user_key}    \\d+
    ${user_number}=    Get From List    ${matches}    0

    # Zero-pad the user number to 2 digits (1 → 01, 12 → 12)
    ${padded_user_number}=    Evaluate    str(${user_number}).zfill(2)

    # Generate timestamp components: yy (last 2 digits of year), mm (month), dd (day), mm (minutes)
    ${year_yy}=    Get Current Date    result_format=%y
    ${month}=    Get Current Date    result_format=%m
    ${day}=    Get Current Date    result_format=%d
    ${minute}=    Get Current Date    result_format=%M

    # Build employee ID: {user_key_number}{yy}mmddmm
    # Example: ESSNH1_STORE2 → 01 + 26 + 02 + 16 + 15 = 0126021615
    ${employee_id}=    Catenate    SEPARATOR=${EMPTY}    ${padded_user_number}    ${year_yy}    ${month}    ${day}    ${minute}
    ${password}=    Catenate    SEPARATOR=${EMPTY}    ${employee_id}    ${TEST_USER_PWD_SUFFIX}

    # Auto-generate display_name and names from user_key
    # Format: ESSNH1_STORE2 → "ESSNH1, {employee_id}"
    # Example: "ESSNH1, 0126030244"
    @{parts}=    Split String    ${user_key}    _
    ${first_name}=    Get From List    ${parts}    0
    VAR    ${last_name}=    ${employee_id}
    ${display_name}=    Catenate    SEPARATOR=,${SPACE}    ${last_name}    ${first_name}

    # Get environment-specific profile name from constants based on profile_type parameter
    ${profile_name}=    Get System Value    UserProfileName    ${profile_type}

    # Build complete employee data dictionary (use store_id and store_name from store_data)
    VAR    &{employee_data}=
    ...    user_key=${user_key}
    ...    employee_id=${employee_id}
    ...    username=${employee_id}
    ...    password=${password}
    ...    first_name=${first_name}
    ...    firstName=${first_name}
    ...    last_name=${last_name}
    ...    lastName=${last_name}
    ...    displayName=${display_name}
    ...    badge_id=${employee_id}
    ...    badgeId=${employee_id}
    ...    profile_name=${profile_name}
    ...    unit_id=${store_data}[store_id]
    ...    unitID=${store_data}[store_id]
    ...    unit_name=${store_data}[store_name]
    ...    unitName=${store_data}[store_name]
    ...    personId=${EMPTY}

    Log    Generated dynamic employee: ${user_key} (${profile_type}) - ID: ${employee_id}, Profile: ${profile_name}    level=DEBUG
    RETURN    ${employee_data}

Set Dynamic Employee
    [Documentation]    Stores a dynamic employee in pabot-shared cache for parallel execution safety.
    ...    | =Arguments= | =Description= |
    ...    | user_key | Reference key to store employee under (e.g., ESSNH1_STORE2, ESSNH2_STORE2). |
    ...    | employee_data | Employee dictionary containing employee_id, displayName, etc. |
    ...    Example usage:
    ...    | Set Dynamic Employee | ESSNH1_STORE2 | ${essnh1_data} |
    [Arguments]    ${user_key}    ${employee_data}

    VAR    ${cache_key}=    DYNAMIC_EMPLOYEE_${user_key}
    Set Parallel Value For Key    ${cache_key}    ${employee_data}
    Log    Stored dynamic employee in cache: ${user_key} → Employee ID: ${employee_data}[employee_id]    level=DEBUG

Get Dynamic Employee
    [Documentation]    Retrieves a dynamic employee by user_key from pabot-shared cache.
    ...    | =Arguments= | =Description= |
    ...    | user_key | Reference key to retrieve employee data (e.g., ESSNH1_STORE2, ESSNH2_STORE2). |
    ...    Example usage:
    ...    | ${essnh1}= | Get Dynamic Employee | ESSNH1_STORE2 |
    ...    | Log | Employee ID: ${essnh1}[employee_id] |
    ...    | Log | Display Name: ${essnh1}[displayName] |
    [Arguments]    ${user_key}

    VAR    ${cache_key}=    DYNAMIC_EMPLOYEE_${user_key}
    ${employee}=    Get Parallel Value For Key    ${cache_key}

    IF    $employee is $None
        Fail    User key '${user_key}' not found in dynamic employee cache. Ensure Suite Setup ran successfully.
    END

    Log    Retrieved dynamic employee from cache: ${user_key} → Employee ID: ${employee}[employee_id]    level=DEBUG

    RETURN    ${employee}
