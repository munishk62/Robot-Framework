*** Settings ***
Documentation       Comprehensive test cases demonstrating CSVLibrary usage.
...                 This test suite showcases all major features and use cases
...                 of the CSV Library for Robot Framework.

Library             Collections
Library             OperatingSystem
Library             resources.common.library.CSVLibrary

Suite Setup         Create Test Data Directory
Suite Teardown      Cleanup Test Data Directory


*** Test Cases ***
TC001: Read CSV File With Headers As Dictionaries
    [Documentation]    Verify reading CSV file with headers returns list of dictionaries.
    [Tags]    smoke    read    headers

    Create Test Data Directory

    # Create sample CSV file
    VAR    &{row1}    name=John Doe    email=john@example.com    role=admin
    VAR    &{row2}    name=Jane Smith    email=jane@example.com    role=user
    VAR    &{row3}    name=Bob Johnson    email=bob@example.com    role=user
    VAR    @{sample_data}    ${row1}    ${row2}    ${row3}

    VAR    ${csv_file}    ${TEST_DATA_DIR}/users_with_headers.csv
    Write CSV File    ${csv_file}    ${sample_data}    with_headers=${True}

    # Read and verify
    ${data}    Read CSV File    ${csv_file}    with_headers=${True}

    Should Be Equal As Integers    ${data.__len__()}    3
    Should Be Equal    ${data[0]}[name]    John Doe
    Should Be Equal    ${data[1]}[email]    jane@example.com
    Should Be Equal    ${data[2]}[role]    user

    Log    ${data}

TC002: Read CSV File Without Headers As List Of Lists
    [Documentation]    Verify reading CSV file without headers returns list of lists.
    [Tags]    smoke    read    no-headers

    VAR    ${csv_file}    ${TEST_DATA_DIR}/raw_data.csv

    # Create raw data as list of lists (no headers interpretation)
    VAR    @{row1}    Col1    Col2    Col3
    VAR    @{row2}    Value1    Value2    Value3
    VAR    @{row3}    Value4    Value5    Value6
    VAR    @{raw_data}    ${row1}    ${row2}    ${row3}

    Write CSV File    ${csv_file}    ${raw_data}    with_headers=${False}

    # Read without headers
    ${data}    Read CSV File    ${csv_file}    with_headers=${False}

    Should Be Equal As Integers    ${data.__len__()}    3
    Should Be Equal    ${data[0][0]}    Col1
    Should Be Equal    ${data[1][2]}    Value3

    Log    ${data}

TC003: Write CSV File With Headers From Dictionaries
    [Documentation]    Verify writing CSV file with headers from list of dictionaries.
    [Tags]    smoke    write    headers

    VAR    ${csv_file}    ${TEST_DATA_DIR}/employees.csv

    VAR    &{emp1}    employee_id=EMP001    name=Alice    department=Engineering
    VAR    &{emp2}    employee_id=EMP002    name=Bob    department=Sales
    VAR    &{emp3}    employee_id=EMP003    name=Carol    department=HR
    VAR    @{employees}    ${emp1}    ${emp2}    ${emp3}

    Write CSV File    ${csv_file}    ${employees}    with_headers=${True}

    # Verify file exists and has content
    File Should Exist    ${csv_file}
    ${read_back}    Read CSV File    ${csv_file}

    Should Be Equal As Integers    ${read_back.__len__()}    3
    Should Be Equal    ${read_back[0]}[name]    Alice

    Log    File written successfully: ${csv_file}

TC004: Write CSV File From List Of Lists
    [Documentation]    Verify writing CSV file from list of lists.
    [Tags]    smoke    write

    VAR    ${csv_file}    ${TEST_DATA_DIR}/matrix_data.csv

    VAR    @{row1}    Header1    Header2    Header3
    VAR    @{row2}    Data1    Data2    Data3
    VAR    @{row3}    Data4    Data5    Data6
    VAR    @{data}    ${row1}    ${row2}    ${row3}

    Write CSV File    ${csv_file}    ${data}    with_headers=${False}

    File Should Exist    ${csv_file}
    ${read_back}    Read CSV File    ${csv_file}    with_headers=${False}

    Should Be Equal As Integers    ${read_back.__len__()}    3
    Log    ${read_back}

TC005: Convenience Keywords For Reading
    [Documentation]    Test convenience keywords for reading CSV files.
    [Tags]    read    convenience

    VAR    ${csv_file}    ${TEST_DATA_DIR}/products.csv

    VAR    &{p1}    product_id=P001    name=Widget    price=9.99
    VAR    &{p2}    product_id=P002    name=Gadget    price=19.99
    VAR    @{products}    ${p1}    ${p2}

    Write CSV File    ${csv_file}    ${products}

    # Read as dicts (with headers)
    ${dict_data}    Read CSV File As Dicts    ${csv_file}
    Should Be Equal As Integers    ${dict_data.__len__()}    2
    Should Be Equal    ${dict_data[0]}[name]    Widget

    # Read as lists (without headers)
    ${list_data}    Read CSV File As Lists    ${csv_file}    has_headers=${True}
    Should Be Equal As Integers    ${list_data.__len__()}    2

TC006: Convenience Keywords For Writing
    [Documentation]    Test convenience keywords for writing CSV files.
    [Tags]    write    convenience

    VAR    ${csv_file}    ${TEST_DATA_DIR}/departments.csv

    VAR    &{d1}    dept_id=D001    dept_name=Engineering
    VAR    &{d2}    dept_id=D002    dept_name=Sales
    VAR    @{departments}    ${d1}    ${d2}

    # Write using convenience keyword
    Write CSV From List Of Dicts    ${csv_file}    ${departments}

    File Should Exist    ${csv_file}
    ${read_back}    Read CSV File    ${csv_file}
    Should Be Equal    ${read_back[0]}[dept_name]    Engineering

TC007: Append To CSV File
    [Documentation]    Verify appending data to existing CSV file.
    [Tags]    append

    VAR    ${csv_file}    ${TEST_DATA_DIR}/append_test.csv

    # Initial data
    VAR    &{r1}    id=1    value=A
    VAR    &{r2}    id=2    value=B
    VAR    @{initial}    ${r1}    ${r2}

    Write CSV File    ${csv_file}    ${initial}

    # Append more data
    VAR    &{r3}    id=3    value=C
    VAR    &{r4}    id=4    value=D
    VAR    @{additional}    ${r3}    ${r4}

    Append To CSV File    ${csv_file}    ${additional}

    # Verify all data
    ${all_data}    Read CSV File    ${csv_file}
    Should Be Equal As Integers    ${all_data.__len__()}    4
    Should Be Equal    ${all_data[3]}[value]    D

    Log    ${all_data}

TC008: Get CSV Row Count
    [Documentation]    Verify getting row count from CSV file.
    [Tags]    utility    count

    VAR    ${csv_file}    ${TEST_DATA_DIR}/count_test.csv

    VAR    &{r1}    col1=val1    col2=val2
    VAR    &{r2}    col1=val3    col2=val4
    VAR    &{r3}    col1=val5    col2=val6
    VAR    @{data}    ${r1}    ${r2}    ${r3}

    Write CSV File    ${csv_file}    ${data}    with_headers=${True}

    # Count with headers excluded
    ${count}    Get CSV Row Count    ${csv_file}    exclude_headers=${True}
    Should Be Equal As Integers    ${count}    3

    # Count all rows (including header)
    ${total}    Get CSV Row Count    ${csv_file}    exclude_headers=${False}
    Should Be Equal As Integers    ${total}    4

TC009: Get CSV Headers
    [Documentation]    Verify extracting headers from CSV file.
    [Tags]    utility    headers

    VAR    ${csv_file}    ${TEST_DATA_DIR}/headers_test.csv

    VAR    &{r1}    username=user1    email=user1@test.com    role=admin
    VAR    &{r2}    username=user2    email=user2@test.com    role=user
    VAR    @{data}    ${r1}    ${r2}

    Write CSV File    ${csv_file}    ${data}    with_headers=${True}

    ${headers}    Get CSV Headers    ${csv_file}

    Should Contain    ${headers}    username
    Should Contain    ${headers}    email
    Should Contain    ${headers}    role
    Should Be Equal As Integers    ${headers.__len__()}    3

    Log    ${headers}

TC010: Validate CSV File
    [Documentation]    Verify CSV file validation.
    [Tags]    utility    validation

    VAR    ${valid_file}    ${TEST_DATA_DIR}/valid.csv
    VAR    ${invalid_file}    ${TEST_DATA_DIR}/nonexistent.csv

    # Create valid file
    VAR    &{r1}    col1=val1    col2=val2
    VAR    @{data}    ${r1}

    Write CSV File    ${valid_file}    ${data}

    # Test valid file
    ${is_valid}    Validate CSV File    ${valid_file}
    Should Be True    ${is_valid}

    # Test nonexistent file - should return false for missing files
    ${is_invalid}    Validate CSV File    ${invalid_file}
    IF    not ${is_invalid}
        Log    File validation correctly returned False for missing file
    END

TC011: CSV File Exists Check
    [Documentation]    Verify checking if CSV file exists.
    [Tags]    utility    exists

    VAR    ${existing_file}    ${TEST_DATA_DIR}/existing.csv
    VAR    ${missing_file}    ${TEST_DATA_DIR}/missing.csv

    # Create a file
    VAR    &{r1}    col=val
    VAR    @{data}    ${r1}
    Write CSV File    ${existing_file}    ${data}

    # Check existence
    ${exists}    CSV File Exists    ${existing_file}
    Should Be True    ${exists}

    ${missing}    CSV File Exists    ${missing_file}
    IF    not ${missing}
        Log    Missing file correctly reported as not existing
    END

TC012: Different CSV Delimiters
    [Documentation]    Verify handling different delimiters (semicolon, pipe, etc).
    [Tags]    delimiters

    VAR    ${semicolon_file}    ${TEST_DATA_DIR}/semicolon.csv
    VAR    ${pipe_file}    ${TEST_DATA_DIR}/pipe.csv

    VAR    &{r1}    field1=value1    field2=value2    field3=value3
    VAR    &{r2}    field1=value4    field2=value5    field3=value6
    VAR    @{data}    ${r1}    ${r2}

    # Write with semicolon delimiter
    Write CSV File    ${semicolon_file}    ${data}    delimiter=;

    # Write with pipe delimiter
    Write CSV File    ${pipe_file}    ${data}    delimiter=|

    # Read back with correct delimiters
    ${semicolon_data}    Read CSV File    ${semicolon_file}    delimiter=;
    ${pipe_data}    Read CSV File    ${pipe_file}    delimiter=|

    Should Be Equal As Integers    ${semicolon_data.__len__()}    2
    Should Be Equal As Integers    ${pipe_data.__len__()}    2

    Log    ${semicolon_data}
    Log    ${pipe_data}

TC013: Delete CSV File
    [Documentation]    Verify deleting CSV file.
    [Tags]    delete

    VAR    ${csv_file}    ${TEST_DATA_DIR}/delete_test.csv

    # Create file
    VAR    &{row1}    col=val
    VAR    @{data}    ${row1}
    Write CSV File    ${csv_file}    ${data}

    File Should Exist    ${csv_file}

    # Delete file
    Delete CSV File    ${csv_file}

    File Should Not Exist    ${csv_file}

TC014: Handle Empty CSV Files
    [Documentation]    Verify handling empty CSV files.
    [Tags]    edge-cases    empty

    VAR    ${empty_file}    ${TEST_DATA_DIR}/empty.csv

    # Create empty file
    Create File    ${empty_file}    ${EMPTY}

    # Try to read empty file
    ${data}    Read CSV File    ${empty_file}    with_headers=${True}
    Should Be Equal As Integers    ${data.__len__()}    0

    ${count}    Get CSV Row Count    ${empty_file}
    Should Be Equal As Integers    ${count}    0

TC015: Data-Driven Test Using CSV
    [Documentation]    Demonstrate data-driven testing using CSV data.
    [Tags]    data-driven

    VAR    ${creds_file}    ${TEST_DATA_DIR}/credentials.csv

    # Create test credentials CSV
    VAR    &{cred1}    username=admin    password=pass123    expected_role=admin
    VAR    &{cred2}    username=user1    password=pass456    expected_role=user
    VAR    &{cred3}    username=user2    password=pass789    expected_role=user
    VAR    @{credentials}    ${cred1}    ${cred2}    ${cred3}

    Write CSV File    ${creds_file}    ${credentials}    with_headers=${True}

    # Load and iterate through test data
    ${test_data}    Read CSV File    ${creds_file}

    FOR    ${test_case}    IN    @{test_data}
        Log    Testing user: ${test_case}[username] with expected role: ${test_case}[expected_role]
    END

    Should Be Equal As Integers    ${test_data.__len__()}    3

TC016: Complex Data Pipeline
    [Documentation]    Demonstrate complex CSV data pipeline operations.
    [Tags]    pipeline

    VAR    ${source_file}    ${TEST_DATA_DIR}/source_pipeline.csv
    VAR    ${filtered_file}    ${TEST_DATA_DIR}/filtered_pipeline.csv
    VAR    ${final_file}    ${TEST_DATA_DIR}/final_pipeline.csv

    # Create source data
    VAR    &{r1}    name=Alice    status=active    score=90
    VAR    &{r2}    name=Bob    status=inactive    score=75
    VAR    &{r3}    name=Carol    status=active    score=88
    VAR    &{r4}    name=David    status=inactive    score=70
    VAR    @{source_data}    ${r1}    ${r2}    ${r3}    ${r4}

    Write CSV File    ${source_file}    ${source_data}

    # Read source
    ${data}    Read CSV File    ${source_file}

    # Filter active records by condition
    VAR    @{filtered}    @{EMPTY}
    FOR    ${record}    IN    @{data}
        ${is_active}    Evaluate    '${record}[status]' == 'active'
        IF    ${is_active}    Append To List    ${filtered}    ${record}
    END

    Write CSV File    ${filtered_file}    ${filtered}

    # Add processed flag and save final
    VAR    @{final}    @{EMPTY}
    FOR    ${record}    IN    @{filtered}
        ${name}    Get From Dictionary    ${record}    name
        ${status}    Get From Dictionary    ${record}    status
        ${score}    Get From Dictionary    ${record}    score
        VAR    &{updated}    name=${name}    status=${status}    score=${score}    processed=yes
        Append To List    ${final}    ${updated}
    END

    Write CSV File    ${final_file}    ${final}

    # Verify pipeline results
    ${final_data}    Read CSV File    ${final_file}
    Should Be Equal As Integers    ${final_data.__len__()}    2
    Should Be Equal    ${final_data[0]}[processed]    yes

TC017: Different Encoding Support
    [Documentation]    Verify support for different file encodings.
    [Tags]    encoding

    VAR    ${utf8_file}    ${TEST_DATA_DIR}/utf8_data.csv

    # Create data with special characters
    VAR    &{r1}    name=JosÃ©    city=MÃ©xico    language=espaÃ±ol
    VAR    &{r2}    name=FranÃ§ois    city=Paris    language=franÃ§ais
    VAR    @{data}    ${r1}    ${r2}

    # Write with UTF-8 encoding
    Write CSV File    ${utf8_file}    ${data}    encoding=utf-8

    # Read back with UTF-8
    ${read_data}    Read CSV File    ${utf8_file}    encoding=utf-8

    Should Be Equal    ${read_data[0]}[name]    JosÃ©
    Should Be Equal    ${read_data[1]}[city]    Paris

TC018: CSV File Overwrite Control
    [Documentation]    Verify overwrite control when writing CSV files.
    [Tags]    overwrite-control

    VAR    ${csv_file}    ${TEST_DATA_DIR}/overwrite_test.csv

    # Create initial file
    VAR    &{r1}    col=initial_value
    VAR    @{initial_data}    ${r1}
    Write CSV File    ${csv_file}    ${initial_data}    overwrite=${True}

    # Try to write with overwrite=True (should succeed)
    VAR    &{r2}    col=new_value
    VAR    @{new_data}    ${r2}
    Write CSV File    ${csv_file}    ${new_data}    overwrite=${True}

    ${verify}    Read CSV File    ${csv_file}    with_headers=${True}
    Should Be Equal    ${verify[0]}[col]    new_value

TC019: Handle Large Records
    [Documentation]    Verify handling records with many columns.
    [Tags]    edge-cases    large-records

    VAR    ${large_file}    ${TEST_DATA_DIR}/large_record.csv

    # Create record with many fields
    VAR    &{large_record}    field_0=value_0
    FOR    ${i}    IN RANGE    1    50
        Set To Dictionary    ${large_record}    field_${i}    value_${i}
    END

    VAR    @{data}    ${large_record}

    Write CSV File    ${large_file}    ${data}    with_headers=${True}

    ${read_back}    Read CSV File    ${large_file}
    Dictionary Should Contain Key    ${read_back[0]}    field_0
    Dictionary Should Contain Key    ${read_back[0]}    field_49

TC020: CSVLibrary Integration With Test Framework
    [Documentation]    Demonstrate integration with test framework and logging.
    [Tags]    integration

    VAR    ${data_file}    ${TEST_DATA_DIR}/integration_test.csv

    # Create test data
    VAR    &{t1}    test_id=TC001    test_name=Login Test    status=Pass
    VAR    &{t2}    test_id=TC002    test_name=User Creation    status=Pass
    VAR    &{t3}    test_id=TC003    test_name=Data Validation    status=Fail
    VAR    @{test_data}    ${t1}    ${t2}    ${t3}

    Write CSV File    ${data_file}    ${test_data}
    Log    Test data file created: ${data_file}

    ${all_tests}    Read CSV File    ${data_file}
    Log    ${all_tests}

    ${row_count}    Get CSV Row Count    ${data_file}
    Log    Total test cases: ${row_count}

    FOR    ${test}    IN    @{all_tests}
        Log    ${test}[test_id]: ${test}[test_name] - ${test}[status]
    END

# DB Integration example commented out for now since it depends on specific DB setup and data.
# But the lib has keywords for converting to csv

# TC021: CSVLibrary Integration With DB Tuples
#    [Documentation]    Demonstrate writing database query results (list of tuples) to CSV.
#    ${result}=    Get Store Details From DB
#    ${headers}=    Create List    store_id    store_name    store_code    timezone
#    ${count}=    Write CSV From List Of Tuples
#    ...    stores.csv    ${result}    headers=${headers}

#    # Without headers (just data)
#    ${result}=    Get Store Details From DB
#    ${count}=    Write CSV From List Of Tuples
#    ...    stores_no_header.csv    ${result}


*** Keywords ***
Create Test Data Directory
    [Documentation]    Create temporary test data directory for this suite.
    ${test_dir}    Normalize Path    ${EXECDIR}/csv_library_tests
    Create Directory    ${test_dir}
    VAR    ${TEST_DATA_DIR}    ${test_dir}    scope=SUITE
    Log    Test data directory: ${test_dir}

Cleanup Test Data Directory
    [Documentation]    Remove test data directory after suite execution.
    Run Keyword And Ignore Error    Remove Directory    ${TEST_DATA_DIR}    recursive=True
