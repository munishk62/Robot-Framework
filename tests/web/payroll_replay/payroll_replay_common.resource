*** Settings ***
Documentation       Common keywords shared by payroll replay frequency suites.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/payroll/period_payroll_release.resource
Resource            resources/web/rta/test_tools/pay_recompute.resource
Resource            resources/web/rta/test_tools/pay_recompute_db.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/api/rta/payroll.resource
Library             tests/web/payroll_replay/compare_files_and_get_detailed_difference_utility.py


*** Keywords ***
Compare Pre And Post Reopen Payroll Files
    [Documentation]    Compares pre and post reopen-released payroll JSON files and logs the results
    [Arguments]    ${store_id}    ${pre_file_path}    ${post_file_path}    ${message}=Payroll Data Comparison
    ${comparison_result}    Compare Json Files    ${pre_file_path}    ${post_file_path}
    ${comparison_status}    Get Comparison Status    ${pre_file_path}    ${post_file_path}
    VAR    ${mismatch_message}    ${message} - Records are identical - Match
    Log    Comparison Status: ${comparison_status}
    IF    ${comparison_result}[match]
        Log    ${message} - Records are identical - Match
    ELSE
        Log    ${message} - Records do not match - Not Match
        VAR    ${difference_report_file}    ${EXECDIR}/period_payroll_release/payrolldifference_report_all_iterations.txt
        ${difference_report}    Get Difference Report    ${pre_file_path}    ${post_file_path}
        ${compact_difference_message}    Get Compact Difference Message    ${pre_file_path}    ${post_file_path}
        Log    ${difference_report}
        Log    Detailed differences: ${comparison_result}[differences]
        ${mismatch_details}    Catenate    SEPARATOR=${\n}
        ...    ==================================================${\n}
        ...    Store: ${store_id}${\n}
        ...    Message: ${message}${\n}
        ...    Pre file: ${pre_file_path}${\n}
        ...    Post file: ${post_file_path}${\n}
        ...    Difference report: ${difference_report}${\n}
        ...    Detailed differences: ${comparison_result}[differences]${\n}
        Append To File    ${difference_report_file}    ${mismatch_details}
        VAR    ${mismatch_message}    ${compact_difference_message}
        Log    ${message} - mismatch found after reopening and re-releasing pay file. See logs for details.
    END
    RETURN    ${comparison_status}    ${mismatch_message}

Reopen Pay File For Week For Store On Period Payroll Release Page On Web
    [Documentation]    Reopens the pay file for the given store if Re-open action is available
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${week_start_date}    ${week_end_date}
    Log To Console    [${STORE_ID}] Reopening pay file...
    Login And Launch WFM Web App    user_key=SYSADMIN
    Switch To Store With Profile    store_id=${STORE_ID}    store_name=${STORE_NAME}    store_profile_name=${manager_profile}
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Filter For Week On Period Payroll Release Page On Web    ${week_start_date}    ${week_end_date}
    Wait Until Page Is Loaded
    ${reopen_status}    Check And Get Status Of Pay File Reopen Action On Period Payroll Release Page On Web
    IF    not ${reopen_status}
        Close Browser
        Skip    ${STORE_ID} Payroll File does not have Re-open action available - Cannot proceed.
    END
    Reopen Pay File On Period Pay Release Page On Web
    # ${release_status}    Check And Get Status Of Pay File Release Action On Period Payroll Release Page On Web
    # Should Be True    ${release_status}
    # ...    msg=${STORE_ID} Payroll File does not have Release action available for the week - Cannot proceed.
    # Switch To Home From Store On Web
    Log Out From Web Application
    Log    [${STORE_ID}] Pay file reopened successfully. Proceeding with recompute...

Reopen Pay File For Specific Period For Store On Period Payroll Release Page On Web
    [Documentation]    Reopens the pay file for the given store if Re-open action is available
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${period_start_date}    ${period_end_date}
    Log To Console    [${STORE_ID}] Reopening pay file...
    Login And Launch WFM Web App    user_key=SYSADMIN
    Switch To Store With Profile    store_id=${STORE_ID}    store_name=${STORE_NAME}    store_profile_name=${manager_profile}
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Filter For Month For Semi Monthly On Period Payroll Release Page On Web    ${period_start_date}
    Wait Until Page Is Loaded
    ${reopen_status}    Check And Get Status Of Pay File Reopen Action For Semi Monthly On Period Payroll Release Page On Web
    ...    ${period_start_date}    ${period_end_date}
    IF    not ${reopen_status}
        Close Browser
        Skip    ${STORE_ID} Payroll File does not have Re-open action available - Cannot proceed.
    END
    Reopen Pay File For Specific Period For Semi Monthy On Period Pay Release Page On Web    ${period_start_date}    ${period_end_date}
    # ${release_status}    Check And Get Status Of Pay File Release Action For Semi Monthly On Period Payroll Release Page On Web
    # ...    ${period_start_date}    ${period_end_date}
    # Should Be True    ${release_status}
    # ...    msg=${STORE_ID} Payroll File does not have Release action available for the week - Cannot proceed.
    # Switch To Home From Store On Web
    Log Out From Web Application
    Log    [${STORE_ID}] Pay file reopened successfully. Proceeding with recompute...

Recompute Pay File For Store On Pay Recompute Page On Web
    [Documentation]    Recomputes the pay file for the given store
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${start_week_start_date}    ${end_week_start_date}    ${pay_recompute_mode}
    ...    ${pay_recompute_action}
    Wait Until Page Is Loaded
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RTA Test Tools Pay Recompute Page On Web
    VAR    ${full_store_name}    ${STORE_ID} - ${STORE_NAME}
    Recompute For Given Store & Week On Pay Recompute Page On Web
    ...    ${full_store_name}    ${start_week_start_date}    ${end_week_start_date}
    ...    ${pay_recompute_mode}    ${pay_recompute_action}
    Verify Batch Job Message Displayed On Pay Recompute Page On Web
    Capture Screenshot On Webpage
    ${batch_id}    Get Batch ID From Success Message On Pay Recompute Page On Web
    Log To Console    [${STORE_ID}] Recompute batch id: ${batch_id}
    Log To Console    Waiting for payroll recompute batch job to complete...
    ${recompute_batch_completed}    Check Completed Status For Pay Files Recompute From DB    ${batch_id}
    Log    [${STORE_ID}] Recompute Batch Job Status: ${recompute_batch_completed}
    IF    not ${recompute_batch_completed}
        Fail    Payroll Recompute Batch Job did not complete successfully in stipulated time - Cannot proceed with Release.
    END
    Log To Console    Payroll Recompute batch job completed successfully. Initiating pay file release...

Recompute Pay File For Specific Period For Store On Pay Recompute Page On Web
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
    ${batch_id}    Get Batch ID From Success Message On Pay Recompute Page On Web
    Log To Console    [${STORE_ID}] Recompute batch id: ${batch_id}
    Log To Console    Waiting for payroll recompute batch job to complete...
    ${recompute_batch_completed}    Check Completed Status For Pay Files Recompute From DB    ${batch_id}
    Log    [${STORE_ID}] Recompute Batch Job Status: ${recompute_batch_completed}
    IF    not ${recompute_batch_completed}
        Fail    Payroll Recompute Batch Job did not complete successfully in stipulated time - Cannot proceed with Release.
    END
    Log To Console    Payroll Recompute batch job completed successfully. Initiating pay file release...

Release Pay File For Week For Store On Period Payroll Release Page On Web
    [Documentation]    Releases the pay file for the given store and verifies its status
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${week_start_date}    ${week_end_date}
    Log To Console    [${STORE_ID}] Releasing pay file...
    Switch To Store With Profile    store_id=${STORE_ID}    store_name=${STORE_NAME}    store_profile_name=${manager_profile}
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Filter For Week On Period Payroll Release Page On Web    ${week_start_date}
    ...    ${week_end_date}
    Release Pay File On Period Payroll Release Page On Web
    Sleep    5s
    # ${release_status}    Check And Get Status Of Pay File Release On Period Payroll Release Page On Web    Released
    # IF    not ${release_status}
    #     Log    message=Pay file status did not change to 'Released' after releasing - Cannot proceed.
    #     Fail    [${STORE_ID}] Pay file 'Release' action failed.
    # END
    Close Browser
    Log To Console    [${STORE_ID}] Pay file released successfully. Verifying database status...

Release Pay File For Specific Period For Store On Period Payroll Release Page On Web
    [Documentation]    Releases the pay file for the given store and verifies its status
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${period_start_date}    ${period_end_date}
    Log To Console    [${STORE_ID}] Releasing pay file...
    Switch To Store With Profile    store_id=${STORE_ID}    store_name=${STORE_NAME}    store_profile_name=${manager_profile}
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Filter For Month For Semi Monthly On Period Payroll Release Page On Web    ${period_start_date}
    Release Pay File For Specific Period On Period Payroll Release Page On Web    ${period_start_date}    ${period_end_date}
    Capture Screenshot On Webpage
    Sleep    5s
    # ${release_status}    Check And Get Status For Specific Period Of Pay File Release On Period Payroll Release Page On Web
    # ...    ${period_start_date}    ${period_end_date}    R    Released
    # IF    not ${release_status}
    #     Log    message=Pay file status did not change to 'Released' after releasing - Cannot proceed.
    #     Fail    [${STORE_ID}] Pay file 'Release' action failed.
    # END
    Close Browser
    Log To Console    [${STORE_ID}] Pay file released successfully. Verifying database status...

Collect Pre-Recompute Data For The Store
    [Documentation]    Collects pre-recompute data for the store from Unit Pay Detail and Cost Segment and creates JSON files
    [Arguments]    ${STORE_ID}    ${PERIOD_START}    ${PERIOD_END}    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}
    ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}
    Log To Console    [${STORE_ID}] Collecting pre-recompute data...
    ${duration_and_cost_from_unit_pay_detail}    Get Work Duration And Cost Data By Employee From Unit Pay Detail
    ...    week_start=${PERIOD_START}    week_end=${PERIOD_END}    unit_id=${STORE_ID}
    Create File    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}    ${duration_and_cost_from_unit_pay_detail}
    ${work_duration_by_emp_from_cost_seg}    Get Work Duration By Employee From Cost Segment
    ...    week_start=${PERIOD_START}    week_end=${PERIOD_END}    unit_id=${STORE_ID}
    Create File    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${work_duration_by_emp_from_cost_seg}

Collect Post-Recompute Data For The Store
    [Documentation]    Collects post-recompute data for the store from Unit Pay Detail and Cost Segment and creates JSON files
    [Arguments]    ${STORE_ID}    ${PERIOD_START}    ${PERIOD_END}    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}
    ...    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}
    Log To Console    [${STORE_ID}] Collecting post-recompute data and performing comparison...
    ${unit_pay_detail_post_recompute}    Get Work Duration And Cost Data By Employee From Unit Pay Detail
    ...    week_start=${PERIOD_START}    week_end=${PERIOD_END}    unit_id=${STORE_ID}
    Create File    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}    ${unit_pay_detail_post_recompute}
    ${cost_seg_post_recompute}    Get Work Duration By Employee From Cost Segment
    ...    week_start=${PERIOD_START}    week_end=${PERIOD_END}    unit_id=${STORE_ID}
    Create File    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${cost_seg_post_recompute}

Collect Pre-Recompute Data With Prior Period For The Store
    [Documentation]    Collects pre-recompute data for the store from Unit Pay Detail and Cost Segment and creates JSON files
    [Arguments]    ${STORE_ID}    ${PERIOD_START}    ${PERIOD_END}    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}
    ...    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
    Log To Console    [${STORE_ID}] Collecting pre-recompute data...
    ${work_duration_by_emp_from_cost_seg}    Get Work Duration By Employee From Cost Segment
    ...    week_start=${PERIOD_START}    week_end=${PERIOD_END}    unit_id=${STORE_ID}
    Create File    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${work_duration_by_emp_from_cost_seg}
    ${cost_work_duration_by_emp_from_cost_diff}    Get Work Duration And Cost Data By Employee From Cost Difference Segment
    ...    ${PERIOD_START}    ${PERIOD_END}    ${STORE_ID}
    Create File    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}    ${cost_work_duration_by_emp_from_cost_diff}

Collect Post-Recompute Data With Prior Period For The Store
    [Documentation]    Collects post-recompute data for the store from Unit Pay Detail and Cost Segment and creates JSON files
    [Arguments]    ${STORE_ID}    ${PERIOD_START}    ${PERIOD_END}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}
    ...    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
    Log To Console    [${STORE_ID}] Collecting post-recompute data and performing comparison...
    ${cost_seg_post_recompute}    Get Work Duration By Employee From Cost Segment
    ...    week_start=${PERIOD_START}    week_end=${PERIOD_END}    unit_id=${STORE_ID}
    Create File    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${cost_seg_post_recompute}
    ${cost_work_duration_by_emp_from_cost_diff}    Get Work Duration And Cost Data By Employee From Cost Difference Segment
    ...    ${PERIOD_START}    ${PERIOD_END}    ${STORE_ID}
    Create File    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}    ${cost_work_duration_by_emp_from_cost_diff}

Reopen Recompute And Release Pay File For Specific Period For Store
    [Documentation]    Reopens, recomputes and releases the pay file for specific period (GM , SM frequency)
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${period_start_date}    ${period_end_date}    ${first_week_start_date}
    ...    ${last_week_start_date}    ${recompute_action}
    ${manager_profile}    Get System Value    UserProfiles    STORE_ADMIN
    Reopen Pay File For Specific Period For Store On Period Payroll Release Page On Web    ${STORE_ID}    ${STORE_NAME}
    ...    ${manager_profile}    ${period_start_date}    ${period_end_date}
    Recompute Pay File For Store On Pay Recompute Page On Web    ${STORE_ID}    ${STORE_NAME}    ${first_week_start_date}
    ...    ${last_week_start_date}    RELEASED_UNRELEASED_TIMECARD    ${recompute_action}
    Release Pay File For Specific Period For Store On Period Payroll Release Page On Web    ${STORE_ID}    ${STORE_NAME}
    ...    ${manager_profile}    ${period_start_date}    ${period_end_date}

Reopen Recompute And Release Pay File For Week For Store
    [Documentation]    Reopens, recomputes and releases the pay file for weekly frequency
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${week_start_date}    ${week_end_date}
    ...    ${recompute_action}
    Reopen Pay File For Week For Store On Period Payroll Release Page On Web    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}
    ...    ${week_start_date}    ${week_end_date}
    Recompute Pay File For Store On Pay Recompute Page On Web    ${STORE_ID}    ${STORE_NAME}    ${week_start_date}
    ...    ${week_start_date}    RELEASED_UNRELEASED_TIMECARD    ${recompute_action}
    Release Pay File For Week For Store On Period Payroll Release Page On Web    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}
    ...    ${week_start_date}    ${week_end_date}

Compare Pre And Post Reopen-Released Pay File Data For Store
    [Documentation]    Compares the pre and post reopen-released pay file data for the store and logs the results
    [Arguments]    ${STORE_ID}    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}
    ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}
    ${comparison_result_unit_pay}    ${unit_pay_mismatch_message}    Compare Pre And Post Reopen Payroll Files    ${STORE_ID}
    ...    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}    [${STORE_ID}] Unit pay data comparison
    ${comparison_result_ta_cost_segment}    ${ta_cost_segment_mismatch_message}    Compare Pre And Post Reopen Payroll Files    ${STORE_ID}
    ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    [${STORE_ID}] TA cost segment data comparison
    Log To Console    [${STORE_ID}] Successfully completed payroll recompute and comparison!

    ${all_mismatch_fail_messages}    Catenate    SEPARATOR=${\n}${\n}    ${EMPTY}
    IF    '${comparison_result_unit_pay}' != 'Match'
        ${all_mismatch_fail_messages}    Catenate    SEPARATOR=${\n}${\n}    ${all_mismatch_fail_messages}    ${unit_pay_mismatch_message}
    END
    IF    '${comparison_result_ta_cost_segment}' != 'Match'
        ${all_mismatch_fail_messages}    Catenate    SEPARATOR=${\n}${\n}    ${all_mismatch_fail_messages}
        ...    ${ta_cost_segment_mismatch_message}
    END
    IF    '${comparison_result_unit_pay}' != 'Match' or '${comparison_result_ta_cost_segment}' != 'Match'
        Fail    ${all_mismatch_fail_messages}
    END

Compare Pre And Post Reopen-Released Pay File With Prior Period Data For Store
    [Documentation]    Compares the pre and post reopen-released pay file data with prior period data for the store and logs the results
    [Arguments]    ${STORE_ID}
    ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
    ...    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
    ${comparison_result_ta_cost_segment}    ${ta_cost_segment_mismatch_message}    Compare Pre And Post Reopen Payroll Files    ${STORE_ID}
    ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    [${STORE_ID}] TA cost segment data comparison
    ${comparison_result_ta_cost_diff_segment}    ${ta_cost_diff_segment_mismatch_message}    Compare Pre And Post Reopen Payroll Files
    ...    ${STORE_ID}    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
    ...    [${STORE_ID}] TA cost diff segment data comparison
    Log To Console    [${STORE_ID}] Successfully completed payroll recompute and comparison!

    ${all_mismatch_fail_messages}    Catenate    SEPARATOR=${\n}${\n}    ${EMPTY}
    IF    '${comparison_result_ta_cost_segment}' != 'Match'
        ${all_mismatch_fail_messages}    Catenate    SEPARATOR=${\n}${\n}    ${all_mismatch_fail_messages}
        ...    ${ta_cost_segment_mismatch_message}
    END
    IF    '${comparison_result_ta_cost_diff_segment}' != 'Match'
        ${all_mismatch_fail_messages}    Catenate    SEPARATOR=${\n}${\n}    ${all_mismatch_fail_messages}
        ...    ${ta_cost_diff_segment_mismatch_message}
    END
    IF    '${comparison_result_ta_cost_segment}' != 'Match' or '${comparison_result_ta_cost_diff_segment}' != 'Match'
        Fail    ${all_mismatch_fail_messages}
    END

Get Batch ID From Success Message On Pay Recompute Page On Web
    [Documentation]
    ...    Reads the batch status id from the success banner on the Pay Recompute page after submit.
    ...    *Returns*: Batch status id as a string.
    ...    Example usage:
    ...    | ${batch_id}=    Get Batch ID From Success Message On Pay Recompute Page On Web
    ${success_message_text}    Get Element Text On Webpage    ${PAY_RECOMPUTE_PAGE_SUCCESS_MESSAGE}
    Log    Pay Recompute success message: ${success_message_text}
    ${matches}    Get Regexp Matches    ${success_message_text}    batch status id\\s+(\\d+)    1
    Should Not Be Empty    ${matches}
    ...    msg=Could not parse batch status id from Pay Recompute success message: '${success_message_text}'
    ${batch_id}    Get From List    ${matches}    0
    RETURN    ${batch_id}

Apply Period Payroll Release Filter On Period Payroll Release Page From CORP On Web
    [Documentation]    Applies pay-frequency filters on Period Payroll Release page from CORP (SYSADMIN level).
    ...    | =Arguments= | =Description= |
    ...    | frequency | Pay frequency code (``WK``, ``BW``, ``GM``, ``SM``). |
    ...    | period_start_date | Formatted period start date. |
    ...    | period_end_date | Formatted period end date. |
    ...    | first_week_start_date | Formatted first week start date. |
    ...    Example usage:
    ...    | Apply Period Payroll Release Filter On Period Payroll Release Page From CORP On Web    ${frequency}    ${period_start_date}    ${period_end_date}    ${first_week_start_date}
    [Arguments]    ${frequency}    ${period_start_date}    ${period_end_date}    ${first_week_start_date}
    IF    '${frequency}' == 'GM' or '${frequency}' == 'SM'
        Apply Filter For Month For Semi Monthly On Period Payroll Release Page On Web    ${period_start_date}
    ELSE IF    '${frequency}' == 'WK'
        Apply Filter For Week On Period Payroll Release Page On Web    ${period_start_date}    ${period_end_date}
    ELSE IF    '${frequency}' == 'BW'
        Apply Filter For BiWeek On Period Payroll Release Page On Web    ${first_week_start_date}
    ELSE
        Fail    Unsupported frequency '${frequency}' for CORP payroll replay.
    END

Reopen Pay File On Period Payroll Release Page From CORP On Web
    [Documentation]    Reopens the pay file on Period Payroll Release page from CORP (SYSADMIN level).
    ...    Uses ``Apply Period Payroll Release Filter On Period Payroll Release Page From CORP On Web`` and period-specific reopen locators.
    ...    | =Arguments= | =Description= |
    ...    | emp_group_id | Optional context id for logging (e.g. employee group id). |
    ...    | payfile_config_name | Pay file configuration name. |
    ...    | frequency | Pay frequency code (``WK``, ``BW``, ``GM``, ``SM``). |
    ...    | period_start_date | Formatted period start date. |
    ...    | period_end_date | Formatted period end date. |
    ...    | first_week_start_date | Formatted first week start date. |
    ...    Example usage:
    ...    | Reopen Pay File On Period Payroll Release Page From CORP On Web    ${emp_group_id}    ${payfile_config_name}    ${frequency}    ${period_start_date}    ${period_end_date}    ${first_week_start_date}
    [Arguments]    ${emp_group_id}    ${payfile_config_name}    ${frequency}    ${period_start_date}    ${period_end_date}
    ...    ${first_week_start_date}
    Log To Console    [${emp_group_id}] Reopening pay file '${payfile_config_name}'...
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Period Payroll Release Filter On Period Payroll Release Page From CORP On Web    ${frequency}    ${period_start_date}
    ...    ${period_end_date}    ${first_week_start_date}
    Wait Until Page Is Loaded
    ${reopen_status}    Check And Get Status Of Pay File Reopen Action For Semi Monthly On Period Payroll Release Page On Web
    ...    ${period_start_date}    ${period_end_date}
    IF    not ${reopen_status}
        Close Browser
        Skip    [${emp_group_id}] Pay file '${payfile_config_name}' does not have Re-open action available - Cannot proceed.
    END
    Reopen Pay File For Specific Period For Semi Monthy On Period Pay Release Page On Web    ${period_start_date}    ${period_end_date}
    ${release_status}    Check And Get Status Of Pay File Release Action For Semi Monthly On Period Payroll Release Page On Web
    ...    ${period_start_date}    ${period_end_date}
    Should Be True    ${release_status}
    ...    msg=[${emp_group_id}] Pay file '${payfile_config_name}' does not have Release action available for the period - Cannot proceed.
    Log    [${emp_group_id}] Pay file '${payfile_config_name}' reopened successfully. Proceeding with recompute...

Release Pay File On Period Payroll Release Page From CORP On Web
    [Documentation]    Releases the pay file on Period Payroll Release page from CORP (SYSADMIN level).
    ...    Assumes an active SYSADMIN browser session and applies frequency filters before release.
    ...    | =Arguments= | =Description= |
    ...    | emp_group_id | Optional context id for logging (e.g. employee group id). |
    ...    | payfile_config_name | Pay file configuration name. |
    ...    | frequency | Pay frequency code (``WK``, ``BW``, ``GM``, ``SM``). |
    ...    | period_start_date | Formatted period start date. |
    ...    | period_end_date | Formatted period end date. |
    ...    | first_week_start_date | Formatted first week start date. |
    ...    Example usage:
    ...    | Release Pay File On Period Payroll Release Page From CORP On Web    ${emp_group_id}    ${payfile_config_name}    ${frequency}    ${period_start_date}    ${period_end_date}    ${first_week_start_date}
    [Arguments]    ${emp_group_id}    ${payfile_config_name}    ${frequency}    ${period_start_date}    ${period_end_date}
    ...    ${first_week_start_date}
    Log To Console    [${emp_group_id}] Releasing pay file '${payfile_config_name}'...
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Period Payroll Release Filter On Period Payroll Release Page From CORP On Web    ${frequency}    ${period_start_date}
    ...    ${period_end_date}    ${first_week_start_date}
    Release Pay File For Specific Period On Period Payroll Release Page On Web    ${period_start_date}    ${period_end_date}
    Close Browser
    Log To Console    [${emp_group_id}] Pay file '${payfile_config_name}' released successfully.

Get Person IDs For Employee Group Or Skip
    [Documentation]    Returns person ids for an employee group in the period, or skips when none are mapped.
    ...    | =Arguments= | =Description= |
    ...    | emp_group_id | Employee group id. |
    ...    | period_start | Period start date key (yyyymmdd). |
    ...    | period_end | Period end date key (yyyymmdd). |
    ...    *Returns:* ``list`` of person id strings.
    [Arguments]    ${emp_group_id}    ${period_start}    ${period_end}
    @{person_ids}    Get Person IDs From Employee Group Mapping    ${emp_group_id}    ${period_start}    ${period_end}
    ${person_count}    Get Length    ${person_ids}
    IF    not ${person_count}
        Skip    [${emp_group_id}] No person ids found in group mapping for period ${period_start}-${period_end}.
    END
    Log    [${emp_group_id}] Found ${person_count} person ids for recompute and comparison.
    RETURN    @{person_ids}

Resave Timecards For Employee Group Via Servlet
    [Documentation]    Resaves timecards for employee group person ids via ``ResaveTimecardUtilityServlet`` at SYSADMIN level.
    ...    Person ids are submitted in batches of ``PAYROLL_RECOMPUTE_EMP_GROUP_BATCH_SIZE`` (default 100).
    ...    | =Arguments= | =Description= |
    ...    | first_week_start_yyyymmdd | First week start date key (``YYYYMMDD``). |
    ...    | last_week_start_yyyymmdd | Last week start date key (``YYYYMMDD``). |
    ...    | person_ids | Person ids for the servlet ``personIdCsv`` parameter. |
    [Arguments]    ${first_week_start_yyyymmdd}    ${last_week_start_yyyymmdd}    @{person_ids}
    ${batch_size}    Get Config Value    PAYROLL_RECOMPUTE_EMP_GROUP_BATCH_SIZE    100
    @{batches}    Split Person Id List Into DB Query Batches    ${batch_size}    @{person_ids}
    ${total_batches}    Get Length    ${batches}
    VAR    ${batch_index}    ${0}
    FOR    ${batch}    IN    @{batches}
        ${batch_index}    Evaluate    ${batch_index} + 1
        ${batch_count}    Get Length    ${batch}
        Log To Console    Resaving timecards via servlet: batch ${batch_index}/${total_batches} (${batch_count} person ids)...
        Resave Timecard Utility Via Servlet And Validate Output    SYSADMIN    ${first_week_start_yyyymmdd}    ${last_week_start_yyyymmdd}
        ...    @{batch}
    END

Collect Pre-Recompute Data For Employee Group
    [Documentation]    Collects pre-recompute unit pay and cost segment data for employee group members.
    [Arguments]    ${emp_group_id}    ${period_start}    ${period_end}    ${pre_recompute_unit_payroll_file}
    ...    ${pre_recompute_ta_cost_segment_file}    @{person_ids}
    Log To Console    [${emp_group_id}] Collecting pre-recompute data...
    ${duration_and_cost_from_unit_pay_detail}    Get Work Duration And Cost Data By Person IDs From Unit Pay Detail    ${period_start}
    ...    ${period_end}    @{person_ids}
    Create File    ${pre_recompute_unit_payroll_file}    ${duration_and_cost_from_unit_pay_detail}
    ${work_duration_by_emp_from_cost_seg}    Get Work Duration By Person IDs From Cost Segment    ${period_start}    ${period_end}
    ...    @{person_ids}
    Create File    ${pre_recompute_ta_cost_segment_file}    ${work_duration_by_emp_from_cost_seg}

Collect Post-Recompute Data For Employee Group
    [Documentation]    Collects post-recompute unit pay and cost segment data for employee group members.
    [Arguments]    ${emp_group_id}    ${period_start}    ${period_end}    ${post_recompute_unit_payroll_file}
    ...    ${post_recompute_ta_cost_segment_file}    @{person_ids}
    Log To Console    [${emp_group_id}] Collecting post-recompute data and performing comparison...
    ${unit_pay_detail_post_recompute}    Get Work Duration And Cost Data By Person IDs From Unit Pay Detail    ${period_start}
    ...    ${period_end}    @{person_ids}
    Create File    ${post_recompute_unit_payroll_file}    ${unit_pay_detail_post_recompute}
    ${cost_seg_post_recompute}    Get Work Duration By Person IDs From Cost Segment    ${period_start}    ${period_end}
    ...    @{person_ids}
    Create File    ${post_recompute_ta_cost_segment_file}    ${cost_seg_post_recompute}

Collect Pre-Recompute Data With Prior Period For Employee Group
    [Documentation]    Collects pre-recompute ``TA_COST_SEGMENT`` and ``TA_COST_SEG_DIFF`` data for employee group members.
    [Arguments]    ${emp_group_id}    ${period_start}    ${period_end}    ${pre_recompute_ta_cost_segment_file}
    ...    ${pre_recompute_ta_cost_diff_segment_file}    @{person_ids}
    Log To Console    [${emp_group_id}] Collecting pre-recompute TA cost segment and TA cost seg diff data...
    ${work_duration_by_emp_from_cost_seg}    Get Work Duration By Person IDs From Cost Segment    ${period_start}    ${period_end}
    ...    @{person_ids}
    Create File    ${pre_recompute_ta_cost_segment_file}    ${work_duration_by_emp_from_cost_seg}
    ${cost_work_duration_by_emp_from_cost_diff}    Get Work Duration And Cost Data By Person IDs From Cost Difference Segment
    ...    ${period_start}    ${period_end}    @{person_ids}
    Create File    ${pre_recompute_ta_cost_diff_segment_file}    ${cost_work_duration_by_emp_from_cost_diff}

Collect Post-Recompute Data With Prior Period For Employee Group
    [Documentation]    Collects post-recompute ``TA_COST_SEGMENT`` and ``TA_COST_SEG_DIFF`` data for employee group members.
    [Arguments]    ${emp_group_id}    ${period_start}    ${period_end}    ${post_recompute_ta_cost_segment_file}
    ...    ${post_recompute_ta_cost_diff_segment_file}    @{person_ids}
    Log To Console    [${emp_group_id}] Collecting post-recompute TA cost segment and TA cost seg diff data...
    ${cost_seg_post_recompute}    Get Work Duration By Person IDs From Cost Segment    ${period_start}    ${period_end}
    ...    @{person_ids}
    Create File    ${post_recompute_ta_cost_segment_file}    ${cost_seg_post_recompute}
    ${cost_work_duration_by_emp_from_cost_diff}    Get Work Duration And Cost Data By Person IDs From Cost Difference Segment
    ...    ${period_start}    ${period_end}    @{person_ids}
    Create File    ${post_recompute_ta_cost_diff_segment_file}    ${cost_work_duration_by_emp_from_cost_diff}

Compare Pre And Post Reopen-Released Pay File With Prior Period Cost Data For Employee Group
    [Documentation]    Compares pre and post reopen-released ``TA_COST_SEGMENT`` and ``TA_COST_SEG_DIFF`` data for an employee group.
    [Arguments]    ${emp_group_id}    ${pre_recompute_ta_cost_segment_file}    ${post_recompute_ta_cost_segment_file}
    ...    ${pre_recompute_ta_cost_diff_segment_file}    ${post_recompute_ta_cost_diff_segment_file}
    ${comparison_result_ta_cost_segment}    ${ta_cost_segment_mismatch_message}    Compare Pre And Post Reopen Payroll Files
    ...    ${emp_group_id}    ${pre_recompute_ta_cost_segment_file}    ${post_recompute_ta_cost_segment_file}
    ...    [${emp_group_id}] TA cost segment data comparison
    ${comparison_result_ta_cost_diff_segment}    ${ta_cost_diff_segment_mismatch_message}    Compare Pre And Post Reopen Payroll Files
    ...    ${emp_group_id}    ${pre_recompute_ta_cost_diff_segment_file}    ${post_recompute_ta_cost_diff_segment_file}
    ...    [${emp_group_id}] TA cost diff segment data comparison
    Log To Console    [${emp_group_id}] Successfully completed payroll recompute and comparison!
    ${all_mismatch_fail_messages}    Catenate    SEPARATOR=${\n}${\n}    ${EMPTY}
    IF    '${comparison_result_ta_cost_segment}' != 'Match'
        ${all_mismatch_fail_messages}    Catenate    SEPARATOR=${\n}${\n}    ${all_mismatch_fail_messages}
        ...    ${ta_cost_segment_mismatch_message}
    END
    IF    '${comparison_result_ta_cost_diff_segment}' != 'Match'
        ${all_mismatch_fail_messages}    Catenate    SEPARATOR=${\n}${\n}    ${all_mismatch_fail_messages}
        ...    ${ta_cost_diff_segment_mismatch_message}
    END
    IF    '${comparison_result_ta_cost_segment}' != 'Match' or '${comparison_result_ta_cost_diff_segment}' != 'Match'
        Fail    ${all_mismatch_fail_messages}
    END

Reopen Recompute And Release Pay File For Employee Group
    [Documentation]    Reopens, resaves timecards via servlet, and releases the pay file at SYSADMIN level without store switching.
    ...    Accepts date keys (``YYYYMMDD``) and converts them for CORP UI actions internally.
    ...    Orchestrates ``Reopen Pay File On Period Payroll Release Page From CORP On Web``,
    ...    ``Resave Timecards For Employee Group Via Servlet``, and
    ...    ``Release Pay File On Period Payroll Release Page From CORP On Web``.
    ...    | =Arguments= | =Description= |
    ...    | emp_group_id | Employee group id for logging. |
    ...    | payfile_config_name | Pay file configuration name. |
    ...    | frequency | Pay frequency code (``WK``, ``BW``, ``GM``, ``SM``). |
    ...    | period_start | Period start date key (yyyymmdd). |
    ...    | period_end | Period end date key (yyyymmdd). |
    ...    | first_week_start | First week start date key (yyyymmdd). |
    ...    | last_week_start | Last week start date key (yyyymmdd). |
    ...    | person_ids | Person ids for ``ResaveTimecardUtilityServlet``. |
    ...    Example usage:
    ...    | Reopen Recompute And Release Pay File For Employee Group    ${emp_group_id}    ${payfile_config_name}    ${frequency}    ${period_start}    ${period_end}    ${first_week_start}    ${last_week_start}    @{person_ids}
    [Arguments]    ${emp_group_id}    ${payfile_config_name}    ${frequency}    ${period_start}    ${period_end}
    ...    ${first_week_start}    ${last_week_start}    @{person_ids}
    ${env_specific_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${yyyymmdd_format}    Get Config Value    SERVER_DF
    ${formatted_period_start_date}    Convert Date    ${period_start}    result_format=${env_specific_date_format}
    ...    date_format=${yyyymmdd_format}
    ${formatted_period_end_date}    Convert Date    ${period_end}    result_format=${env_specific_date_format}
    ...    date_format=${yyyymmdd_format}
    ${formatted_first_week_start_date}    Convert Date    ${first_week_start}    result_format=${env_specific_date_format}
    ...    date_format=${yyyymmdd_format}
    Reopen Pay File On Period Payroll Release Page From CORP On Web    ${emp_group_id}    ${payfile_config_name}
    ...    ${frequency}    ${formatted_period_start_date}    ${formatted_period_end_date}    ${formatted_first_week_start_date}
    Resave Timecards For Employee Group Via Servlet    ${first_week_start}    ${last_week_start}    @{person_ids}
    Release Pay File On Period Payroll Release Page From CORP On Web    ${emp_group_id}    ${payfile_config_name}
    ...    ${frequency}    ${formatted_period_start_date}    ${formatted_period_end_date}    ${formatted_first_week_start_date}
