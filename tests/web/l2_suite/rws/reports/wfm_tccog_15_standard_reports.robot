*** Settings ***
Documentation       Test cases for verifying individual Cognos Report Functionality

Resource            resources/web/rws/reports/view_reports.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Library             OperatingSystem
Library             Screenshot

Suite Setup         Run Keywords
...                     Set Common Reports Data    AND
...                     Create Cognos Result Directories    AND
...                     Login To WFM Application And Navigate To Reports Page
Suite Teardown      Close Browser

Test Tags           config:reports    dev:ravi    action:read    tccog_15


*** Variables ***
@{COMMON_REPORTS_DATA}      @{EMPTY}    # Will be populated in Suite Setup
@{FAILED_REPORTS}           @{EMPTY}    # Track failed reports
@{PASSED_REPORTS}           @{EMPTY}    # Track passed reports
${MAX_REPORTS_TO_TEST}      3    # Set to 0 to test all reports, or specific number to limit


*** Test Cases ***
TCCOG-15 Verify Standard Reports Page UI
    [Documentation]    Verify individual Cognos reports UI functionality for standard reports (Store, Field, Corporate)

    ${total_available}    Get Length    ${COMMON_REPORTS_DATA}
    IF    not ${total_available}    Fail    No common reports available to test

    ${reports_to_test}    Evaluate    min(${total_available}, ${MAX_REPORTS_TO_TEST})

    Log    \n=================== Testing All ${reports_to_test} Common Reports ===================

    FOR    ${index}    IN RANGE    ${reports_to_test}
        ${report_data}    Get From List    ${COMMON_REPORTS_DATA}    ${index}
        ${report_name}    Get From Dictionary    ${report_data}    name
        ${folder_type}    Get From Dictionary    ${report_data}    folder_type
        ${current_test}    Evaluate    ${index} + 1

        Log    \n--- Testing Report ${current_test}/${reports_to_test}: ${report_name} (${folder_type}) ---

        # Navigate to reports page before each test (except the first one which is already on reports page)
        IF    ${index} > 0
            ${nav_result}    Run Keyword And Return Status    Navigate To Reports View Reports Page On Web
            IF    not ${nav_result}
                Log    ⚠️ Failed to navigate to reports page for: ${report_name}    level=WARN
                Append To List    ${FAILED_REPORTS}    ${report_name}
                Capture Report Screenshot    ${report_name}    ${folder_type}    failed
                Log    ❌ FAILED: ${report_name} (${folder_type}) - Navigation failed    level=ERROR
                CONTINUE
            END
            Log    ✓ Navigated to reports page for report: ${report_name}
        END

        # Test individual report with comprehensive error handling
        ${test_result}    Test Individual Report With Error Handling    ${report_name}    ${folder_type}

        # Capture screenshot and track results for final summary
        IF    ${test_result}
            Append To List    ${PASSED_REPORTS}    ${report_name}
            Capture Report Screenshot    ${report_name}    ${folder_type}    passed
            Log    ✅ PASSED: ${report_name} (${folder_type})    level=INFO
        ELSE
            Append To List    ${FAILED_REPORTS}    ${report_name}
            Capture Report Screenshot    ${report_name}    ${folder_type}    failed
            Log    ❌ FAILED: ${report_name} (${folder_type})    level=ERROR
        END
    END

    # Final summary and overall test result
    ${passed_count}    Get Length    ${PASSED_REPORTS}
    ${failed_count}    Get Length    ${FAILED_REPORTS}

    Log    \n=================== Final Test Results Summary ===================    level=INFO
    Log    Total Reports Tested: ${reports_to_test}    level=INFO
    Log    Passed Reports: ${passed_count}    level=INFO
    Log    Failed Reports: ${failed_count}    level=INFO

    IF    ${passed_count} > 0
        Log    \n✅ PASSED REPORTS (${passed_count}):    level=INFO
        FOR    ${passed_report}    IN    @{PASSED_REPORTS}
            Log    ✓ ${passed_report}    level=INFO
        END
    END

    IF    ${failed_count} > 0
        Log    \n❌ FAILED REPORTS (${failed_count}):    level=ERROR
        FOR    ${failed_report}    IN    @{FAILED_REPORTS}
            Log    ✗ ${failed_report}    level=ERROR
        END
    END

    # Fail the overall test if any individual reports failed
    IF    ${failed_count} > 0
        Fail    ${failed_count} out of ${reports_to_test} reports failed. Check individual test logs for details.
    ELSE
        Log    🎉 All ${reports_to_test} tested reports passed successfully!    level=INFO
    END


*** Keywords ***
Set Common Reports Data
    [Documentation]
    ...    Suite setup keyword to fetch and set common report data.
    ...    | =Arguments= | =Description= |
    ...    | None | No arguments required. |
    ...    Calls the Get Common Standard Report Data keyword and sets the suite variable.
    ...    Only sets MAX_REPORTS_TO_TEST to total count if it's currently 0 (test all reports).
    ...    Example usage:
    ...    | Set Common Reports Data
    ${reports_data}    Get Common Standard Report Data
    VAR    @{COMMON_REPORTS_DATA}    @{reports_data}    scope=SUITE
    ${total_reports}    Get Length    ${reports_data}

    # Only override MAX_REPORTS_TO_TEST if it's set to 0 (meaning test all reports)
    ${reports_count}    Evaluate    ${MAX_REPORTS_TO_TEST} == 0
    IF    ${reports_count}
        VAR    ${MAX_REPORTS_TO_TEST}    ${total_reports}    scope=SUITE
        Log    ✓ Set MAX_REPORTS_TO_TEST to ${total_reports} (all available common reports)    level=INFO
    ELSE
        Log    ✓ Using configured MAX_REPORTS_TO_TEST value: ${MAX_REPORTS_TO_TEST} (out of ${total_reports} available)    level=INFO
    END
