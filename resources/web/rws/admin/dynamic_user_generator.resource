*** Settings ***
Documentation       Dynamic User Generator - Creates unique employee credentials for new hire tests
...
...                 This resource provides keywords to generate unique employee IDs and user data
...                 for test runs where employees cannot be deleted (only status changed).
...
...                 Each test run generates a new employee ID based on timestamp to avoid conflicts.

Library             Collections
Library             DateTime
Library             OperatingSystem
Library             String
Library             pabot.PabotLib
Library             test_data/TestDataLibrary.py


*** Keywords ***
Generate Dynamic New Hire User Data
    [Documentation]    Generates dynamic user credentials for new hire based on timestamp to ensure unique employee IDs.
    ...    | =Arguments= | =Description= |
    ...    | store_unit_id | Store UNIT_ID from database (e.g., ZAUTOSTORE002, STORE1). NOT the UNIT_NAME. |
    ...    Example usage:
    ...    | ${new_hire_user}= | Generate Dynamic New Hire User Data | ZAUTOSTORE002 |
    ...    | Log | Employee ID: ${new_hire_user}[username] |
    ...    | Log | Display Name: ${new_hire_user}[displayName] |
    [Arguments]    ${store_unit_id}

    # Validate store_unit_id is provided
    Should Not Be Empty    ${store_unit_id}    msg=store_unit_id is MANDATORY! Must provide store UNIT_ID like ZAUTOSTORE002

    # Extract store number from last digit of store_unit_id (UNIT_ID, not UNIT_NAME!)
    # ZAUTOSTORE002 → 2, ZAUTOSTORE001 → 1, STORE2 → 2
    ${store_number}=    Get Substring    ${store_unit_id}    -1

    # Get current timestamp in DDMMHHMM format (no year)
    ${DATE_FORMAT_DDMMHHMM}=    Get Config Value    DATE_FORMAT_DDMMHHMM
    ${current_time}=    Get Current Date    result_format=${DATE_FORMAT_DDMMHHMM}
    # Generate unique employee ID: store_number + DDMMHHMM
    # Store 2: 2 + 19121253 = 219121253 (9 digits)
    # Store 1: 1 + 19121253 = 119121253 (9 digits)
    # Store 22: 22 + 19121253 = 2219121253 (10 digits)
    ${employee_id}=    Catenate    SEPARATOR=${EMPTY}    ${store_number}    ${current_time}

    # Create password: {employee_id}@123
    ${password}=    Catenate    SEPARATOR=${EMPTY}    ${employee_id}    @123

    # Create display name using store UNIT_ID code
    # Example: "ZAUTOSTORE002, 202021058"
    ${display_name}=    Catenate    SEPARATOR=${EMPTY}    ${store_unit_id}    ,${SPACE}    ${employee_id}

    # Build user data dictionary (no user_key needed - dynamic users aren't looked up by key)
    VAR    &{user_data}=
    ...    username=${employee_id}
    ...    password=${password}
    ...    profile_name=ASSOCIATE
    ...    displayName=${display_name}
    ...    personId=${EMPTY}
    ...    unitID=${EMPTY}
    ...    unitName=${EMPTY}

    Log    Generated dynamic new hire user: ${employee_id} (${display_name})    level=INFO
    Log    Timestamp: ${current_time}, Store: ${store_number}    level=DEBUG

    RETURN    ${user_data}

Set Dynamic New Hire User As Suite Variable
    [Documentation]    Generates dynamic user and stores it as suite-level SUITE_NEW_HIRE_USER variable.
    ...    | =Arguments= | =Description= |
    ...    | store_unit_id | Store UNIT_ID from database (e.g., ZAUTOSTORE002, STORE1). NOT the UNIT_NAME. |
    ...    Example usage:
    ...    | Set Dynamic New Hire User As Suite Variable | ZAUTOSTORE002 |
    ...    | ${user}= | Get Variable Value | ${SUITE_NEW_HIRE_USER} |
    ...    | Log | ${user}[username] |
    [Arguments]    ${store_unit_id}

    ${new_hire_user}=    Generate Dynamic New Hire User Data    ${store_unit_id}
    VAR    ${SUITE_NEW_HIRE_USER}=    ${new_hire_user}    scope=SUITE

    Log    Dynamic new hire user stored as suite variable: SUITE_NEW_HIRE_USER    level=INFO
    Log    Employee ID: ${new_hire_user}[username], Display Name: ${new_hire_user}[displayName]    level=INFO

    RETURN    ${new_hire_user}
