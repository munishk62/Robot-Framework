"""
CSV Library Usage and Examples.

This document provides comprehensive examples and best practices for using
the CSVLibrary in Robot Framework tests.
"""

# ===================================================================
# CSV LIBRARY - COMPREHENSIVE USAGE GUIDE
# ===================================================================

"""
== Introduction ==

The CSV Library provides robust CSV file handling capabilities for Robot 
Framework tests. It supports:

- Reading CSV files with or without headers
- Writing CSV files from structured data
- Appending data to existing CSV files
- Validating CSV file format and content
- Handling various encodings and delimiters
- Comprehensive error handling and logging
- Security checks to prevent directory traversal attacks

== Library Import ==

In your .robot test files, import the library as:

| Library    resources.common.library.CSVLibrary

Or with an alias:

| Library    resources.common.library.CSVLibrary    AS    CSV

== Basic Examples ==

=== Example 1: Reading CSV File with Headers ===

Reading a CSV file where the first row contains column headers:

| *** Test Cases ***
| Read User Data From CSV
|     ${users}=    Read CSV File    data/users.csv
|     Log List    ${users}    # List of dictionaries
|     FOR    ${user}    IN    @{users}
|         Log    Username: ${user}[username]
|         Log    Email: ${user}[email]
|     END

Input CSV file (data/users.csv):
| username,email,role
| john_doe,john@example.com,admin
| jane_smith,jane@example.com,user
| bob_jones,bob@example.com,user

Output (${users}):
| [
|     {'username': 'john_doe', 'email': 'john@example.com', 'role': 'admin'},
|     {'username': 'jane_smith', 'email': 'jane@example.com', 'role': 'user'},
|     {'username': 'bob_jones', 'email': 'bob@example.com', 'role': 'user'}
| ]

=== Example 2: Reading CSV File Without Headers ===

Reading a CSV file as raw list of lists:

| *** Test Cases ***
| Read Raw CSV Data
|     ${data}=    Read CSV File    data/raw_data.csv    with_headers=${False}
|     Log List    ${data}
|     FOR    ${row}    IN    @{data}
|         Log Many    @{row}
|     END

Input CSV file:
| col1,col2,col3
| value1,value2,value3
| value4,value5,value6

Output (${data}):
| [
|     ['col1', 'col2', 'col3'],
|     ['value1', 'value2', 'value3'],
|     ['value4', 'value5', 'value6']
| ]

=== Example 3: Writing CSV File from Test Data ===

Creating a CSV file from test data dictionaries:

| *** Test Cases ***
| Generate CSV File From Test Data
|     ${users}=    Create List
|     ...    &{user1}=username=test_user1    email=test1@example.com    role=admin
|     ...    &{user2}=username=test_user2    email=test2@example.com    role=user
|     Write CSV File    output/generated_users.csv    ${users}    with_headers=${True}
|     ${saved_users}=    Read CSV File    output/generated_users.csv
|     Should Be Equal As Integers    ${saved_users.__len__()}    2

Output file (output/generated_users.csv):
| username,email,role
| test_user1,test1@example.com,admin
| test_user2,test2@example.com,user

=== Example 4: Data-Driven Testing with CSV ===

Using CSV file for data-driven tests (like in validate_wfm_credentials.robot):

| *** Settings ***
| Library    resources.common.library.CSVLibrary    AS    CSV
| Library    DataDriver    dialect=excel    encoding=utf_8    config_keyword=Prepare Test Data

| *** Keywords ***
| Prepare Test Data
|     [Documentation]    Load test data from CSV and configure DataDriver
|     [Arguments]    ${original_config}
|     ${test_data}=    CSV.Read CSV File    test_data/credentials.csv
|     ${csv_file}=    Create Temp CSV File    ${test_data}
|     ${new_config}=    Create Dictionary    file=${csv_file}
|     RETURN    ${new_config}

| Create Temp CSV File
|     [Documentation]    Helper keyword to save data as CSV for DataDriver
|     [Arguments]    ${data}
|     ${temp_file}=    Set Variable    ${TEMP_DIR}/test_data_${RANDOM}.csv
|     CSV.Write CSV File    ${temp_file}    ${data}    with_headers=${True}
|     RETURN    ${temp_file}

| *** Test Cases ***
| TC001: Validate User Credentials For ${username}
|     [Documentation]    Template test case
|     [Template]    Verify User Login
|     Log    Testing user: ${username}

| Verify User Login
|     [Arguments]    ${username}    ${password}
|     Log    Logging in with ${username}

=== Example 5: Appending Data to Existing CSV ===

Adding new records to an existing CSV file:

| *** Test Cases ***
| Append New User Records
|     ${new_users}=    Create List
|     ...    &{user3}=username=test_user3    email=test3@example.com    role=user
|     ...    &{user4}=username=test_user4    email=test4@example.com    role=admin
|     Append To CSV File    output/generated_users.csv    ${new_users}
|     ${all_users}=    Read CSV File    output/generated_users.csv
|     Should Be Equal As Integers    ${all_users.__len__()}    4

Result (output/generated_users.csv now contains 4 users):
| username,email,role
| test_user1,test1@example.com,admin
| test_user2,test2@example.com,user
| test_user3,test3@example.com,user
| test_user4,test4@example.com,admin

=== Example 6: Using Different Delimiters ===

Working with semicolon-delimited files (common in European locales):

| *** Test Cases ***
| Read Semicolon Delimited File
|     ${data}=    Read CSV File    data/european_data.csv    delimiter=;
|     Log List    ${data}
|     FOR    ${record}    IN    @{data}
|         Log    Name: ${record}[name]
|     END

| Write Semicolon Delimited File
|     ${records}=    Create List
|     ...    &{rec1}=name=John    city=Berlin
|     ...    &{rec2}=name=Marie    city=Paris
|     Write CSV File    output/europe_data.csv    ${records}    delimiter=;

=== Example 7: Field Encoding with Special Characters ===

Handling files with various encodings:

| *** Test Cases ***
| Read UTF-8 Encoded File
|     ${data}=    Read CSV File    data/utf8_file.csv    encoding=utf-8
|     Log List    ${data}

| Read Latin-1 Encoded File
|     ${data}=    Read CSV File    data/legacy_file.csv    encoding=latin-1
|     Log List    ${data}

| Write UTF-8 Encoded File
|     ${records}=    Create List
|     ...    &{rec}=name=José    city=México
|     Write CSV File    output/spanish_data.csv    ${records}    encoding=utf-8

=== Example 8: Conditional File Handling ===

Checking file existence before processing:

| *** Test Cases ***
| Process CSV With Safety Check
|     ${exists}=    CSV File Exists    data/test_input.csv
|     Run Keyword If    ${exists}    Process Existing File
|     Run Keyword Unless    ${exists}    Log    File does not exist

| Process Existing File
|     ${is_valid}=    Validate CSV File    data/test_input.csv
|     Run Keyword If    ${is_valid}    
|     ...    Log    File is valid, processing...
|     ...    ELSE
|     ...    Log    File is invalid, skipping process

=== Example 9: Multiple File Operations ===

Combining read, write, and append operations:

| *** Test Cases ***
| Complex CSV Data Pipeline
|     ${source_data}=    Read CSV File    input/source.csv
|     ${filtered}=    Filter Source Data    ${source_data}
|     Write CSV File    output/processed.csv    ${filtered}
|     ${additional}=    Generate Additional Records    3
|     Append To CSV File    output/processed.csv    ${additional}
|     ${final_count}=    Get CSV Row Count    output/processed.csv
|     Log    Final row count: ${final_count}

| Filter Source Data
|     [Arguments]    ${data}
|     ${filtered}=    Create List
|     FOR    ${record}    IN    @{data}
|         Run Keyword If    '${record}[status]' == 'active'
|         ...    Append To List    ${filtered}    ${record}
|     END
|     RETURN    ${filtered}

| Generate Additional Records
|     [Arguments]    ${count}
|     ${records}=    Create List
|     FOR    ${i}    IN RANGE    ${count}
|         ${record}=    Create Dictionary    name=Test User ${i}    status=active
|         Append To List    ${records}    ${record}
|     END
|     RETURN    ${records}

=== Example 10: Header Inspection ===

Getting and validating headers before processing:

| *** Test Cases ***
| Inspect And Process CSV Headers
|     ${headers}=    Get CSV Headers    data/test.csv
|     Log List    ${headers}
|     Should Contain    ${headers}    username
|     Should Contain    ${headers}    email
|     ${count}=    Get CSV Row Count    data/test.csv
|     Log    Headers: ${headers}, Row Count: ${count}

== Common Use Cases ==

=== Use Case 1: Credential Validation Test ===

Similar to validate_wfm_credentials.robot:

| *** Settings ***
| Documentation    Validate user credentials from CSV file
| Library    resources.common.library.CSVLibrary
| Library    SeleniumLibrary

| *** Test Cases ***
| Validate All User Credentials
|     ${users}=    Read CSV File    credentials/test_users.csv
|     FOR    ${user}    IN    @{users}
|         Validate User Access    ${user}[user_id]    ${user}[password]
|     END

| Validate User Access
|     [Arguments]    ${user_id}    ${password}
|     Log    Validating ${user_id}
|     # Add actual login logic here
|     Log    ${user_id} validated successfully

=== Use Case 2: Test Results Export ===

Generate CSV reports from test results:

| *** Test Cases ***
| Export Test Results To CSV
|     ${results}=    Create List
|     ...    &{result1}=test_id=TC001    status=PASS    duration=2.5s
|     ...    &{result2}=test_id=TC002    status=FAIL    duration=1.2s
|     Write CSV File    results/test_results.csv    ${results}

=== Use Case 3: Bulk Data Creation ===

Create test data in CSV format for bulk import:

| *** Test Cases ***
| Create Bulk Employee Records
|     ${employees}=    Generate Employee Data    100
|     Write CSV File    bulk_data/employees.csv    ${employees}
|     # Use CSV file for bulk import test

| Generate Employee Data
|     [Arguments]    ${count}
|     ${data}=    Create List
|     FOR    ${i}    IN RANGE    ${count}
|         ${emp}=    Create Dictionary
|         ...    employee_id=EMP${i}
|         ...    name=Employee ${i}
|         ...    department=IT
|         Append To List    ${data}    ${emp}
|     END
|     RETURN    ${data}

== Security Considerations ==

The CSVLibrary includes security features:

1. Path Validation: File paths are validated to prevent directory traversal
2. Safe File Operations: Uses Python's Path class for safe path handling
3. Encoding Validation: Supports multiple encodings with error handling
4. Permission Checking: Handles permission errors gracefully

Example of secure file operations:

| *** Test Cases ***
| Secure File Operations
|     Log    Library validates all file paths internally
|     Log    No directory traversal attacks possible
|     Log    Proper error handling for permission issues

== Error Handling ==

The library provides comprehensive error handling:

| *** Test Cases ***
| Handle Various Error Conditions
|     Run Keyword And Expect Error    FileNotFoundError*
|     ...    Read CSV File    nonexistent/file.csv
|     
|     Run Keyword And Expect Error    ValueError*
|     ...    Write CSV File    output.csv    invalid_data
|     
|     Run Keyword And Expect Error    PermissionError*
|     ...    Read CSV File    /system/protected/file.csv

== Logging ==

The library includes comprehensive logging:

| *** Test Cases ***
| Logging Examples
|     Log    The library logs all operations (enable DEBUG in RF)
|     Log    Check robot logs for detailed operation information
|     Log    Enable Loglevel DEBUG in test execution for details

== Performance Notes ==

- For large CSV files (>100MB), consider processing in chunks
- The library reads entire files into memory
- For very large files, use stream processing approach
- Headers are cached for efficiency

== Troubleshooting ==

Issue: UnicodeDecodeError
Solution: Specify correct encoding, e.g., encoding=latin-1

Issue: PermissionError on Windows
Solution: Ensure file is not open in another application

Issue: Empty result list
Solution: Check if file exists and has content, verify with CSV File Exists keyword

== Best Practices ==

1. Always validate file existence before operations:
   | ${exists}=    CSV File Exists    output.csv

2. Use meaningful variable names:
   | ${all_users}=    Read CSV File    users.csv
   | NOT: ${x}=    Read CSV File    users.csv

3. Handle errors appropriately:
   | Run Keyword And Ignore Error    Delete CSV File    temp.csv

4. Clean up temporary files:
   | [Teardown]    Delete CSV File    ${temp_file}

5. Use descriptive delimiters in semicolon-separated files:
   | ${data}=    Read CSV File    data.csv    delimiter=;

6. Document CSV file structure in comments:
   | # CSV format: username, email, role
   | ${users}=    Read CSV File    users.csv

7. Keep CSV files small for better performance:
   | # For large datasets, consider pagination

8. Test with sample data first:
   | # Test with sample_data.csv before using production data.csv
"""
