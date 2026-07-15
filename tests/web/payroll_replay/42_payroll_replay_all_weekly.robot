*** Settings ***
Documentation       This test case verifies pay files comparison for a single store by reopening, recomputing and re-releasing pay files.
...                 When run with --processes parameter, each process handles one store each from the Excel file.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/payroll/period_payroll_release.resource
Resource            resources/web/rta/test_tools/pay_recompute.resource
Resource            resources/web/rta/test_tools/pay_recompute_db.resource
Library             tests/web/payroll_replay/compare_files_and_get_detailed_difference_utility.py
Library             DataDriver    file=${PAYROLL_RECOMPUTE_FILE}

Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           action:write    dev:moiz    config:rta    payroll_recompute


*** Test Cases ***
WFM-weekly Pay Files Recompute Comparison For Store ${STORE_ID} - ${STORE_NAME}
    [Documentation]    This test verifies payroll recompute for store.
    [Tags]    bat_phase2    pay_recompute_weekly
    [Template]    Process Single Store Payroll Reopen Recompute And Release


*** Keywords ***
Process Single Store Payroll Reopen Recompute And Release
    [Documentation]    Processes payroll reopen, recompute and release for a single store
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${WEEK_START}    ${WEEK_END}
    VAR    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}    ${EXECDIR}/period_payroll_release/pre_recompute_${STORE_ID}_unit_pay_data.json
    VAR    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}    ${EXECDIR}/period_payroll_release/post_recompute_${STORE_ID}_unit_pay_data.json
    VAR    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${EXECDIR}/period_payroll_release/pre_recompute_${STORE_ID}_ta_cost_segment_data.json
    VAR    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${EXECDIR}/period_payroll_release/post_recompute_${STORE_ID}_ta_cost_segment_data.json
    Log    Starting payroll recompute process for store: ${STORE_ID} - ${STORE_NAME}
    ${store_admin}    Get System Value    UserProfiles    STORE_ADMIN
    ${env_specific_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${yyyymmdd_format}    Get Config Value    SERVER_DF
    ${formatted_week_start_date}    Convert Date    ${WEEK_START}    result_format=${env_specific_date_format}
    ...    date_format=${yyyymmdd_format}
    ${formatted_week_end_date}    Convert Date    ${WEEK_END}    result_format=${env_specific_date_format}
    ...    date_format=${yyyymmdd_format}

    # Collect pre-recompute data for the store
    Log To Console    [${STORE_ID}] Collecting pre-recompute data...
    ${duration_and_cost_from_unit_pay_detail}    Get Work Duration And Cost Data By Employee From Unit Pay Detail
    ...    week_start=${WEEK_START}    week_end=${WEEK_END}    unit_id=${STORE_ID}
    Create File    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}    ${duration_and_cost_from_unit_pay_detail}
    ${work_duration_by_emp_from_cost_seg}    Get Work Duration By Employee From Cost Segment
    ...    week_start=${WEEK_START}    week_end=${WEEK_END}    unit_id=${STORE_ID}
    Create File    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${work_duration_by_emp_from_cost_seg}

    # Reopen pay file for this store
    Reopen Pay File For Store On Period Payroll Release Page On Web    ${STORE_ID}    ${STORE_NAME}    ${store_admin}
    ...    ${formatted_week_start_date}    ${formatted_week_end_date}
    # Recompute pay file for this store
    Recompute Pay File For Store On Pay Recompute Page On Web    ${STORE_ID}    ${STORE_NAME}    ${formatted_week_start_date}
    ...    ${formatted_week_start_date}    RELEASED_UNRELEASED_TIMECARD    RESAVE_TIMECARD
    # Release pay file for this store
    Release Pay File For Store On Period Payroll Release Page On Web    ${STORE_ID}    ${STORE_NAME}    ${store_admin}
    ...    ${formatted_week_start_date}    ${formatted_week_end_date}

    # Verify Pay File Status In DB for this store
    ${pay_file_release_status_db}    Check Status For Pay Files Changed To F From DB
    ...    week_start=${WEEK_START}    week_end=${WEEK_END}    unit_id=${STORE_ID}
    Log    [${STORE_ID}] Unit Pay Details Status: ${pay_file_release_status_db}
    IF    not ${pay_file_release_status_db}
        Fail    [${STORE_ID}] Payroll File Status in DB not changed to 'F' - Cannot proceed with comparison.
    END

    # Collect post-recompute data for the store
    Log To Console    [${STORE_ID}] Collecting post-recompute data and performing comparison...
    ${unit_pay_detail_post_recompute}    Get Work Duration And Cost Data By Employee From Unit Pay Detail
    ...    week_start=${WEEK_START}    week_end=${WEEK_END}    unit_id=${STORE_ID}
    Create File    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}    ${unit_pay_detail_post_recompute}
    ${cost_seg_post_recompute}    Get Work Duration By Employee From Cost Segment
    ...    week_start=${WEEK_START}    week_end=${WEEK_END}    unit_id=${STORE_ID}
    Create File    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${cost_seg_post_recompute}

    # Compare Pre And Post Reopen-Released Pay File Data for this store
    Compare Pre And Post Reopen Payroll Files    ${STORE_ID}    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}
    ...    [${STORE_ID}] Unit pay data comparison
    Compare Pre And Post Reopen Payroll Files    ${STORE_ID}    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}
    ...    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    [${STORE_ID}] TA cost segment data comparison
    Log To Console    [${STORE_ID}] Successfully completed payroll recompute and comparison!

Compare Pre And Post Reopen Payroll Files
    [Documentation]    Compares pre and post reopen-released payroll JSON files and logs the results
    [Arguments]    ${store_id}    ${pre_file_path}    ${post_file_path}    ${message}=Payroll Data Comparison
    ${comparison_result}    Compare Json Files    ${pre_file_path}    ${post_file_path}
    ${comparison_status}    Get Comparison Status    ${pre_file_path}    ${post_file_path}
    Log    Comparison Status: ${comparison_status}
    IF    ${comparison_result}[match]
        Log    ${message} - Records are identical - Match
    ELSE
        Log    ${message} - Records do not match - Not Match
        ${timestamp}    Get Current Date    result_format=%Y%m%d%H%M
        ${difference_report}    Get Difference Report    ${pre_file_path}    ${post_file_path}
        Log    ${difference_report}
        Log    Detailed differences: ${comparison_result}[differences]
        Create File    ${EXECDIR}/period_payroll_release/payrolldifference_${store_id}_report_${timestamp}.txt
        ...    ${difference_report}${\n}Detailed differences: ${comparison_result}[differences]
        Fail    ${message} - mismatch found after reopening and re-releasing pay file. See logs for details.
    END

Reopen Pay File For Store On Period Payroll Release Page On Web
    [Documentation]    Reopens the pay file for the given store if Re-open action is available
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${week_start_date}    ${week_end_date}
    Log To Console    [${STORE_ID}] Reopening pay file...
    Login And Launch WFM Web App    user_key=SYSADMIN
    Switch To Store With Profile    store_name=${STORE_NAME}    store_profile_name=${manager_profile}
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Filter For Week On Period Payroll Release Page On Web    ${week_start_date}    ${week_end_date}
    ${reopen_status}    Check And Get Status Of Pay File Action On Period Payroll Release Page On Web
    IF    not ${reopen_status}
        Close Browser
        Skip    ${STORE_ID} Payroll File does not have Re-open action available - Cannot proceed.
    END
    Reopen Pay File On Period Pay Release Page On Web
    ${release_status}    Check And Get Status Of Pay File Action On Period Payroll Release Page On Web    action_text=Release
    Should Be True    ${release_status}
    ...    msg=${STORE_ID} Payroll File does not have Release action available for the week - Cannot proceed.
    Switch To Home From Store On Web
    Log    [${STORE_ID}] Pay file reopened successfully. Proceeding with recompute...

Recompute Pay File For Store On Pay Recompute Page On Web
    [Documentation]    Recomputes the pay file for the given store
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${start_week_start_date}    ${end_week_start_date}    ${pay_recompute_mode}
    ...    ${pay_recompute_action}
    Navigate To RTA Test Tools Pay Recompute Page On Web
    VAR    ${full_store_name}    ${STORE_ID} - ${STORE_NAME}
    Recompute For Given Store & Week On Pay Recompute Page On Web
    ...    ${full_store_name}    ${start_week_start_date}    ${end_week_start_date}
    ...    ${pay_recompute_mode}    ${pay_recompute_action}
    Verify Batch Job Message Displayed On Pay Recompute Page On Web
    Capture Screenshot On Webpage
    Log To Console    Waiting for payroll recompute batch job to complete...
    ${batch_id}    Get Batch Job ID For Recompute Job From DB    ${pay_recompute_action}
    ${recompute_batch_completed}    Check Completed Status For Pay Files Recompute From DB    ${batch_id}
    Log    [${STORE_ID}] Recompute Batch Job Status: ${recompute_batch_completed}
    IF    not ${recompute_batch_completed}
        Fail    Payroll Recompute Batch Job did not complete successfully in stipulated time - Cannot proceed with Release.
    END
    Log To Console    Payroll Recompute batch job completed successfully. Initiating pay file release...

Release Pay File For Store On Period Payroll Release Page On Web
    [Documentation]    Releases the pay file for the given store and verifies its status
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${week_start_date}    ${week_end_date}
    Log To Console    [${STORE_ID}] Releasing pay file...
    # assuming already logged in as SYSADMIN
    Switch To Store With Profile    store_name=${STORE_NAME}    store_profile_name=${manager_profile}
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Filter For Week On Period Payroll Release Page On Web    ${week_start_date}
    ...    ${week_end_date}
    Release Pay File On Period Payroll Release Page On Web
    ${release_status}    Check And Get Status Of Pay File Release On Period Payroll Release Page On Web    Released
    IF    not ${release_status}
        Log    message=Pay file status did not change to 'Released' after releasing - Cannot proceed.
        Fail    [${STORE_ID}] Pay file 'Release' action failed.
    END
    Close Browser
    Log To Console    [${STORE_ID}] Pay file released successfully. Verifying database status...
