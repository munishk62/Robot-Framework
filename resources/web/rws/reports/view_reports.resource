*** Settings ***
Documentation       This resource file provides keywords for automating the Cognos Reports.

Resource            resources/web/common/common.resource
Variables           resources/web/rta/operations/timecard_page.py
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/authentication/auth_api.resource
Variables           resources/web/rws/reports/view_reports_page.py
Variables           resources/api/api_endpoints.py
Resource            resources/api/api_executor.resource
Resource            resources/web/common/database.resource
Variables           resources/web/rws/reports/reports_db_queries.py


*** Keywords ***
Navigate To Reports View Reports Page On Web
    [Documentation]
    ...    Navigate to the Reports -> View Reports page on the web application.
    ...    | =Arguments= | =Description= |
    ...    | None | No arguments required. |
    ...    Example usage:
    ...    | Navigate To Reports View Reports Page On Web
    Navigate To Specific Page On Web    rws    reports    view_reports

Click On Field Level Cognos Report By Name On Web
    [Documentation]
    ...    Clicks on a specific Cognos report by its name on the web application for Field level reports.
    ...    | =Arguments= | =Description= |
    ...    | report_name | Name of the Cognos report to click. |
    ...    | parent_unit_id | Parent unit ID to select for the field report. |
    ...    Example usage:
    ...    | Click On Field Level Cognos Report By Name On Web    Sales Report    DISTRICT1
    [Arguments]    ${report_name}    ${parent_unit_id}
    ${report_link}    Update Locator With Dynamic Values    ${REPORTS_VIEW_REPORTS_REPORT_LINK}    REPORT_NAME=${report_name}
    Click Element On Webpage    ${report_link}

    ${field_id}    Update Locator With Dynamic Values    ${REPORTS_VIEW_REPORTS_FIELD_ID}    REPORT_NAME=${report_name}
    Click Element On Webpage    ${field_id}
    Fill Textbox On Webpage    ${field_id}    ${parent_unit_id}

    ${parent_id_lnk}    Update Locator With Dynamic Values    ${REPORTS_VIEW_REPORTS_FIELD_ID_AUTO_SUGGESTION}
    ...    FIELD_ID=${parent_unit_id}
    Click Element On Webpage    ${parent_id_lnk}

    ${apply_button}    Update Locator With Dynamic Values    ${REPORTS_VIEW_REPORTS_POP_UP_APPLY_BTN}    FIELD_ID=${parent_unit_id}
    Click Element On Webpage    ${apply_button}
    Wait Until Element Disappears On Webpage    ${REPORTS_VIEW_REPORTS_PROGRESS_INDICATOR}

    Wait Until Page Is Loaded    timeout=60s
    Capture Screenshot On Webpage

Click On Store Level Cognos Report By Name On Web
    [Documentation]
    ...    Clicks on a specific Cognos report by its name on the web application for Store level reports.
    ...    | =Arguments= | =Description= |
    ...    | report_name | Name of the Cognos report to click. |
    ...    | store_id | Store ID to select for the store report. |
    ...    Example usage:
    ...    | Click On Store Level Cognos Report By Name On Web    Sales Report    STORE1-Store Name
    [Arguments]    ${report_name}    ${store_id}
    ${report_link}    Update Locator With Dynamic Values    ${REPORTS_VIEW_REPORTS_STORE_REPORT_LINK}    REPORT_NAME=${report_name}
    Click Element On Webpage    ${report_link}

    ${store_id_txt_box}    Update Locator With Dynamic Values    ${REPORTS_VIEW_REPORTS_STORE_ID}    REPORT_NAME=${report_name}
    Click Element On Webpage    ${store_id_txt_box}
    Fill Textbox On Webpage    ${store_id_txt_box}    ${store_id}
    ${apply_button}    Update Locator With Dynamic Values    ${REPORTS_VIEW_REPORTS_STORE_POP_UP_APPLY_BTN}    REPORT_NAME=${report_name}
    Click Element On Webpage    ${apply_button}
    Wait Until Page Is Loaded    timeout=60s
    Wait Until Element Disappears On Webpage    ${REPORTS_VIEW_REPORTS_PROGRESS_INDICATOR}
    Wait Until Element Is Visible On Webpage    ${REPORTS_VIEW_REPORTS_EXPAND_ICON}
    Capture Screenshot On Webpage

Click On Corporate Level Cognos Report By Name On Web
    [Documentation]
    ...    Clicks on a specific Cognos report by its name on the web application for Corporate level reports.
    ...    | =Arguments= | =Description= |
    ...    | report_name | Name of the Cognos report to click. |
    ...    Example usage:
    ...    | Click On Corporate Level Cognos Report By Name On Web    Sales Report
    [Arguments]    ${report_name}
    ${report_link}    Update Locator With Dynamic Values    ${REPORTS_VIEW_REPORTS_CORPORATE_REPORT_LINK}    REPORT_NAME=${report_name}
    Click Element On Webpage    ${report_link}

    ${apply_button}    Update Locator With Dynamic Values    ${REPORTS_VIEW_REPORTS_CORPORATE_POP_UP_APPLY_BTN}
    ...    REPORT_NAME=${report_name}
    Click Element On Webpage    ${apply_button}
    Wait Until Page Is Loaded    timeout=60s
    Wait Until Element Disappears On Webpage    ${REPORTS_VIEW_REPORTS_PROGRESS_INDICATOR}
    Wait Until Element Is Visible On Webpage    ${REPORTS_VIEW_REPORTS_EXPAND_ICON}
    Capture Screenshot On Webpage

Assert Cognos Report Is Loaded Successfully On Web
    [Documentation]
    ...    Asserts that the specified Cognos report is loaded successfully on the web application based on report type.
    ...    | =Arguments= | =Description= |
    ...    | report_name | Name of the Cognos report to verify. |
    ...    | report_type | Type of report (Corporate, Store, or Field). |
    ...    Example usage:
    ...    | Assert Cognos Report Is Loaded Successfully On Web    Sales Plan Accuracy    Field
    [Arguments]    ${report_name}    ${report_type}

    Capture Screenshot On Webpage

    IF    '${report_type}' == 'Corporate'
        VAR    ${report_name_locator}    ${REPORTS_VIEW_REPORTS_CORPORATE_REPORT_TITLE}
    ELSE IF    '${report_type}' == 'Store'
        VAR    ${report_name_locator}    ${REPORTS_VIEW_REPORTS_STORE_REPORT_TITLE}
    ELSE IF    '${report_type}' == 'Field'
        VAR    ${report_name_locator}    ${REPORTS_VIEW_REPORTS_FIELD_REPORT_TITLE}
    ELSE
        Fail    Unsupported report type: ${report_type}. Supported types are: Corporate, Store, Field
    END

    ${actual_report_name}    Get Element Text On Webpage    ${report_name_locator}

    Log    Expected Report Name: ${report_name}
    Log    Actual Report Name: ${actual_report_name}
    Log    Report Type: ${report_type}
    Log    Used Locator: ${report_name_locator}

    # Verify the report name matches
    Should Be Equal    ${report_name}    ${actual_report_name}
    ...    msg=Expected report name to be '${report_name}' but found '${actual_report_name}' for ${report_type} report

Get Common Standard Report Data
    [Documentation]
    ...    Fetches common standard report data by making API call and processing response.
    ...    | =Arguments= | =Description= |
    ...    | None | No arguments required. |
    ...    Returns a list of common reports data with name and folder_type information.
    ...    Example usage:
    ...    | ${reports_data}    Get Common Standard Report Data

    Generate Auth Token With User Credentials    user_key=SYSADMIN
    VAR    ${api_endpoint}    ${COGNOS_STANDARD_REPORT_LIST}
    ${api_response}    Send A Post Request    ${api_endpoint}    ${API_AUTH_TOKEN}

    VAR    ${response_json_data}    ${api_response}

    # Read standard reports from JSON file
    VAR    ${base_dir}    ${EXECDIR}
    ${std_reports_file_path}    Get Config Value    COGNOS_REPORT_FILE_PATH
    ${standard_reports_content}    OperatingSystem.Get File    ${base_dir}/${std_reports_file_path}
    ${standard_reports_json}    Evaluate    json.loads('''${standard_reports_content}''')    json
    ${standard_report_names}    Get Dictionary Values    ${standard_reports_json}

    # Process all common reports and create test data
    VAR    @{reports_data}    @{EMPTY}
    ${report_list}    Get From Dictionary    ${response_json_data}    reportList

    FOR    ${folder}    IN    @{report_list}
        ${folder_name}    Get From Dictionary    ${folder}    folderName
        ${folder_reports}    Get From Dictionary    ${folder}    reportList
        FOR    ${report}    IN    @{folder_reports}
            ${report_name}    Get From Dictionary    ${report}    name
            ${is_common}    Run Keyword And Return Status    List Should Contain Value    ${standard_report_names}    ${report_name}
            IF    ${is_common}
                VAR    &{report_data}    name=${report_name}    folder_type=${folder_name}
                Append To List    ${reports_data}    ${report_data}
                Log    ✓ COMMON REPORT FOUND: ${report_name} (${folder_name})
            END
        END
    END

    Log    \n=================== Report Summary ===================
    Log    Total Common Reports Found: ${reports_data.__len__()}
    FOR    ${report_data}    IN    @{reports_data}
        Log    - ${report_data}[name] (${report_data}[folder_type])
    END

    RETURN    ${reports_data}

Login To WFM Application And Navigate To Reports Page
    [Documentation]
    ...    Performs one-time login to WFM application and navigates to reports page.
    ...    | =Arguments= | =Description= |
    ...    | None | No arguments required. |
    ...    This keyword is used in Suite Setup to establish browser session and navigate to reports page once.
    ...    Example usage:
    ...    | Login To WFM Application And Navigate To Reports Page
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To Reports View Reports Page On Web
    Capture Screenshot On Webpage

Test Individual Report With Error Handling
    [Documentation]
    ...    Tests individual Cognos report functionality with comprehensive error handling that prevents test execution from stopping.
    ...    | =Arguments= | =Description= |
    ...    | report_name | Name of the Cognos report to test. |
    ...    | folder_type | Type of report folder (Store, Field, or Corporate). |
    ...    Returns True if the report test passed, False otherwise.
    ...    Example usage:
    ...    | ${result}    Test Individual Report With Error Handling    Sales Report    Store
    [Arguments]    ${report_name}    ${folder_type}

    ${unit_data}    Fetch Unit Id Unit Name And Parent Unit Id From DB
    VAR    ${UNIT_ID}    ${unit_data}[unitID]
    VAR    ${UNIT_NAME}    ${unit_data}[unitName]
    VAR    ${PARENT_UNIT_ID}    ${unit_data}[parentUnitID]

    Log    \n=================== Testing ${folder_type} Report: ${report_name} ===================

    # Initialize result tracking variables
    VAR    ${click_result}    ${FALSE}
    VAR    ${verify_result}    ${FALSE}

    # Step 1: Click on the report with comprehensive error handling
    TRY
        IF    '${folder_type}' == 'Store'
            Click On Store Level Cognos Report By Name On Web    ${report_name}    ${UNIT_ID}-${UNIT_NAME}
        ELSE IF    '${folder_type}' == 'Field'
            Click On Field Level Cognos Report By Name On Web    ${report_name}    ${PARENT_UNIT_ID}
        ELSE IF    '${folder_type}' == 'Corporate'
            Click On Corporate Level Cognos Report By Name On Web    ${report_name}
        ELSE
            Log    Unknown folder type: ${folder_type} for report: ${report_name}    level=ERROR
            RETURN    ${FALSE}
        END
        VAR    ${click_result}    ${TRUE}
        Log    ✓ Successfully clicked on ${folder_type} report: ${report_name}
    EXCEPT    AS    ${click_error}
        Log    ✗ Failed to click on report ${report_name}: ${click_error}    level=ERROR
        VAR    ${click_result}    ${FALSE}
    END

    # Step 2: Verify the report loads (only if click was successful)
    IF    ${click_result}
        TRY
            Capture Screenshot On Webpage
            Assert Cognos Report Is Loaded Successfully On Web    ${report_name}    ${folder_type}
            VAR    ${verify_result}    ${TRUE}
            Log    ✓ Successfully verified ${folder_type} report: ${report_name}
        EXCEPT    AS    ${verify_error}
            Log    ✗ Failed to verify report ${report_name}: ${verify_error}    level=ERROR
            Capture Screenshot On Webpage
            VAR    ${verify_result}    ${FALSE}
        END
    ELSE
        Log    ⚠️ Skipping verification for ${report_name} due to click failure    level=WARN
        VAR    ${verify_result}    ${FALSE}
    END

    # Determine overall result
    ${overall_result}    Evaluate    ${click_result} and ${verify_result}

    # Log final result
    IF    ${overall_result}
        Log    ✓ Successfully tested ${folder_type} report: ${report_name}
    ELSE
        Log    ✗ Test failed for ${folder_type} report: ${report_name} (Click: ${click_result}, Verify: ${verify_result})    level=ERROR
    END

    RETURN    ${overall_result}

Fetch Unit Id Unit Name And Parent Unit Id From DB
    [Documentation]
    ...    Fetches Unit ID, Unit Name and Parent Unit ID from database for report testing.
    ...    | =Arguments= | =Description= |
    ...    | None | No arguments required. |
    ...    Returns a dictionary containing standardized keys unitID, unitName, and parentUnitID.
    ...    Backward-compatible aliases (unit_id, unit_name, parent_unit_id) are also included.
    ...    Example usage:
    ...    | ${unit_data}    Fetch Unit Id Unit Name And Parent Unit Id From DB

    VAR    ${db_query}    ${GET_UNIT_PARENT_UNIT_IDS}
    Log    Query to execute: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}

    # Extract first row of results
    ${row}    Get From List    ${result}    0
    VAR    &{unit_data}
    ...    unitID=${row}[1]
    ...    unit_id=${row}[1]
    ...    unitName=${row}[2]
    ...    unit_name=${row}[2]
    ...    parentUnitID=${row}[3]
    ...    parent_unit_id=${row}[3]

    Log    Unit ID: ${unit_data}[unitID]
    Log    Unit Name: ${unit_data}[unitName]
    Log    Parent Unit ID: ${unit_data}[parentUnitID]

    RETURN    ${unit_data}

Get Cognos Result Directory Paths
    [Documentation]
    ...    Returns the directory paths for Cognos test results organization.
    ...    | =Arguments= | =Description= |
    ...    | None | No arguments required. |
    ...    Returns a dictionary containing cognos_result_dir, passed_reports_dir, and failed_reports_dir paths.
    ...    Example usage:
    ...    | ${dirs}    Get Cognos Result Directory Paths

    VAR    ${cognos_result_dir}    ${EXECDIR}${/}cognos_test_result
    VAR    ${passed_reports_dir}    ${cognos_result_dir}${/}passed_reports
    VAR    ${failed_reports_dir}    ${cognos_result_dir}${/}failed_reports

    VAR    &{directory_paths}
    ...    cognos_result_dir=${cognos_result_dir}
    ...    passed_reports_dir=${passed_reports_dir}
    ...    failed_reports_dir=${failed_reports_dir}

    RETURN    ${directory_paths}

Create Cognos Result Directories
    [Documentation]
    ...    Creates the cognos_test_result directory structure with passed_reports and failed_reports subdirectories.
    ...    | =Arguments= | =Description= |
    ...    | None | No arguments required. |
    ...    Creates directories at runtime for organizing screenshot results. Cleans up existing directories first.
    ...    Example usage:
    ...    | Create Cognos Result Directories

    ${dirs}    Get Cognos Result Directory Paths

    # Clean up existing directories if they exist
    ${dir_exists}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${dirs}[cognos_result_dir]
    IF    ${dir_exists}
        Log    Cleaning up existing cognos result directory: ${dirs}[cognos_result_dir]    level=INFO
        Remove Directory    ${dirs}[cognos_result_dir]    recursive=True
        Log    ✓ Removed existing directory: ${dirs}[cognos_result_dir]    level=INFO
    END

    Log    Creating cognos result directories...    level=INFO
    Create Directory    ${dirs}[cognos_result_dir]
    Create Directory    ${dirs}[passed_reports_dir]
    Create Directory    ${dirs}[failed_reports_dir]
    Log    ✓ Created directories: ${dirs}[cognos_result_dir], ${dirs}[passed_reports_dir], ${dirs}[failed_reports_dir]    level=INFO

Capture Report Screenshot
    [Documentation]
    ...    Captures a screenshot for the current report and saves it to the appropriate directory.
    ...    | =Arguments= | =Description= |
    ...    | report_name | Name of the report being tested |
    ...    | report_type | Type/category of the report (folder_type) |
    ...    | result_status | Either 'passed' or 'failed' to determine target directory |
    ...    Screenshot filename format: {report_name}-{report_type}.png
    ...    Example usage:
    ...    | Capture Report Screenshot | Daily Sales Report | Store | passed |
    [Arguments]    ${report_name}    ${report_type}    ${result_status}

    ${dirs}    Get Cognos Result Directory Paths

    # Sanitize report name for filename (remove special characters)
    ${sanitized_name}    Replace String Using Regexp    ${report_name}    [^a-zA-Z0-9_-]    _
    ${sanitized_type}    Replace String Using Regexp    ${report_type}    [^a-zA-Z0-9_-]    _

    # Determine target directory based on result status
    IF    '${result_status}' == 'passed'
        VAR    ${target_dir}    ${dirs}[passed_reports_dir]
    ELSE
        VAR    ${target_dir}    ${dirs}[failed_reports_dir]
    END

    # Create screenshot filename
    VAR    ${screenshot_filename}    ${sanitized_name}-${sanitized_type}.png
    VAR    ${screenshot_path}    ${target_dir}${/}${screenshot_filename}

    # Capture screenshot with error handling
    ${screenshot_result}    Run Keyword And Return Status    Take Screenshot    ${screenshot_path}

    IF    ${screenshot_result}
        Log    📸 Screenshot captured: ${screenshot_path}    level=INFO
    ELSE
        Log    ⚠️ Failed to capture screenshot for: ${report_name} (${report_type})    level=WARN
        # Attempt to capture with default Robot Framework screenshot as fallback
        VAR    ${fallback_path}    ${target_dir}${/}fallback_${screenshot_filename}
        Run Keyword And Ignore Error    Take Screenshot    ${fallback_path}
    END
