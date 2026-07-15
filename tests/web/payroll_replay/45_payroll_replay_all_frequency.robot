*** Settings ***
Documentation       This test case verifies pay files comparison for a single store by reopening, recomputing and re-releasing pay files.
...                 When run with --processes parameter, each process handles one store each from the Excel file.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/payroll/period_payroll_release.resource
Resource            resources/web/rta/test_tools/pay_recompute.resource
Resource            resources/web/rta/test_tools/pay_recompute_db.resource
Resource            resources/web/common/util_keywords.resource
Resource            tests/web/payroll_replay/payroll_replay_common.resource
Library             tests/web/payroll_replay/compare_files_and_get_detailed_difference_utility.py
Library             DataDriver    file=${PAYROLL_RECOMPUTE_FILE}

Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           action:write    dev:rushikesh    config:rta


*** Test Cases ***
WFM-Frequency Pay Files Recompute Comparison For Store ${STORE_ID} - ${STORE_NAME} - ${FREQUENCY}
    [Documentation]    This test verifies payroll recompute for store.
    [Tags]    45_payroll_replay
    [Template]    Process Single Store Payroll Reopen Recompute And Release


*** Keywords ***
Process Single Store Payroll Reopen Recompute And Release
    [Documentation]    Processes payroll reopen, recompute and release for a single store
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${FREQUENCY}    ${PERIOD_START}    ${PERIOD_END}    ${FIRST_WEEK_START}
    ...    ${LAST_WEEK_START}    ${REOPEN_FOR_EDITS}
    Set Tags    ${FREQUENCY}

    VAR    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${EXECDIR}/period_payroll_release/pre_recompute_${STORE_ID}_ta_cost_segment_data.json
    VAR    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${EXECDIR}/period_payroll_release/post_recompute_${STORE_ID}_ta_cost_segment_data.json
    Log    Starting payroll recompute process for store: ${STORE_ID} - ${STORE_NAME}
    ${manager_profile}    Get System Value    UserProfiles    STORE_ADMIN
    ${env_specific_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${yyyymmdd_format}    Get Config Value    SERVER_DF
    ${recompute_action}    Get Config Value    RECOMPUTE_ACTION
    VAR    ${data_generated}    D

    ${formatted_first_week_start_date}    Convert Date    ${FIRST_WEEK_START}    result_format=${env_specific_date_format}
    ...    date_format=${yyyymmdd_format}
    ${formatted_last_week_start_date}    Convert Date    ${LAST_WEEK_START}    result_format=${env_specific_date_format}
    ...    date_format=${yyyymmdd_format}
    ${formatted_period_start_date}    Convert Date    ${PERIOD_START}    result_format=${env_specific_date_format}
    ...    date_format=${yyyymmdd_format}
    ${formatted_period_end_date}    Convert Date    ${PERIOD_END}    result_format=${env_specific_date_format}
    ...    date_format=${yyyymmdd_format}

    IF    '${REOPEN_FOR_EDITS}' == 'N'
        VAR    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
        ...    ${EXECDIR}/period_payroll_release/pre_recompute_${STORE_ID}_ta_cost_diff_segment_data.json
        VAR    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
        ...    ${EXECDIR}/period_payroll_release/post_recompute_${STORE_ID}_ta_cost_diff_segment_data.json

        Collect Pre-Recompute Data With Prior Period For The Store    ${STORE_ID}    ${PERIOD_START}    ${PERIOD_END}
        ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}

        Recompute Update And Validate Pay File Status For Data Generated For Store    ${STORE_ID}    ${STORE_NAME}
        ...    ${formatted_first_week_start_date}    ${formatted_last_week_start_date}    ${PERIOD_START}    ${PERIOD_END}
        ...    ${recompute_action}    ${data_generated}

        # Verify Pay File Status In DB for this store
        ${pay_file_release_status_db}    Check Status For Pay Files Changed To F From DB
        ...    week_start=${PERIOD_START}    week_end=${PERIOD_END}    unit_id=${STORE_ID}
        Log    [${STORE_ID}] Unit Pay Details Status: ${pay_file_release_status_db}
        IF    not ${pay_file_release_status_db}
            Fail    [${STORE_ID}] Payroll File Status in DB not changed to 'F' - Cannot proceed with comparison.
        END

        Collect Post-Recompute Data With Prior Period For The Store    ${STORE_ID}    ${PERIOD_START}    ${PERIOD_END}
        ...    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}

        Compare Pre And Post Reopen-Released Pay File With Prior Period Data For Store    ${STORE_ID}
        ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}
        ...    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
    ELSE IF    '${REOPEN_FOR_EDITS}' == 'Y'
        VAR    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}    ${EXECDIR}/period_payroll_release/pre_recompute_${STORE_ID}_unit_pay_data.json
        VAR    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}    ${EXECDIR}/period_payroll_release/post_recompute_${STORE_ID}_unit_pay_data.json

        # Collect pre-recompute data for the store
        Collect Pre-Recompute Data For The Store    ${STORE_ID}    ${PERIOD_START}    ${PERIOD_END}    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}
        ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}

        IF    '${FREQUENCY}' == 'GM' or '${FREQUENCY}' == 'SM'
            Reopen Recompute And Release Pay File For Specific Period For Store    ${STORE_ID}    ${STORE_NAME}
            ...    ${formatted_period_start_date}    ${formatted_period_end_date}    ${formatted_first_week_start_date}
            ...    ${formatted_last_week_start_date}    ${recompute_action}
        ELSE IF    '${FREQUENCY}' == 'WK'
            Reopen Recompute And Release Pay File For Week For Store    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}
            ...    ${formatted_period_start_date}    ${formatted_period_end_date}    ${recompute_action}
        ELSE IF    '${FREQUENCY}' == 'BW'
            Reopen Recompute And Release Pay File For BiWeek For Store    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}
            ...    ${formatted_first_week_start_date}    ${formatted_last_week_start_date}    ${recompute_action}
        END

        # Verify Pay File Status In DB for this store
        ${pay_file_release_status_db}    Check Status For Pay Files Changed To F From DB
        ...    week_start=${PERIOD_START}    week_end=${PERIOD_END}    unit_id=${STORE_ID}
        Log    [${STORE_ID}] Unit Pay Details Status: ${pay_file_release_status_db}
        IF    not ${pay_file_release_status_db}
            Fail    [${STORE_ID}] Payroll File Status in DB not changed to 'F' - Cannot proceed with comparison.
        END

        Collect Post-Recompute Data For The Store    ${STORE_ID}    ${PERIOD_START}    ${PERIOD_END}    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}
        ...    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}

        Compare Pre And Post Reopen-Released Pay File Data For Store    ${STORE_ID}    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}
        ...    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}
    END

Reopen Pay File For BiWeek For Store On Period Payroll Release Page On Web
    [Documentation]    Reopens the pay file for biweekly frequency if Re-open action is available
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${week_start_date}
    Log To Console    [${STORE_ID}] Reopening pay file...
    Login And Launch WFM Web App    user_key=SYSADMIN
    Switch To Store With Profile    store_id=${STORE_ID}    store_name=${STORE_NAME}    store_profile_name=${manager_profile}
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Filter For BiWeek On Period Payroll Release Page On Web    ${week_start_date}
    Wait Until Page Is Loaded
    ${reopen_status}    Check And Get Status Of Pay File Reopen Action On Period Payroll Release Page On Web
    IF    not ${reopen_status}
        Close Browser
        Skip    ${STORE_ID} Payroll File does not have Re-open action available - Cannot proceed.
    END
    Reopen Pay File On Period Pay Release Page On Web
    ${release_status}    Check And Get Status Of Pay File Release Action On Period Payroll Release Page On Web
    Should Be True    ${release_status}
    ...    msg=${STORE_ID} Payroll File does not have Release action available for the week - Cannot proceed.
    Switch To Home From Store On Web
    Log    [${STORE_ID}] Pay file reopened successfully. Proceeding with recompute...

Release Pay File For BiWeek For Store On Period Payroll Release Page On Web
    [Documentation]    Releases the pay file for biweekly frequency and verifies its status
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${week_start_date}
    Log To Console    [${STORE_ID}] Releasing pay file...
    # assuming already logged in as SYSADMIN
    Switch To Store With Profile    store_id=${STORE_ID}    store_name=${STORE_NAME}    store_profile_name=${manager_profile}
    Navigate To RTA Payroll Period Payroll Release Page On Web
    Apply Filter For BiWeek On Period Payroll Release Page On Web    ${week_start_date}
    Release Pay File On Period Payroll Release Page On Web
    ${release_status}    Check And Get Status Of Pay File Release On Period Payroll Release Page On Web    Released
    IF    not ${release_status}
        Log    message=Pay file status did not change to 'Released' after releasing - Cannot proceed.
        Fail    [${STORE_ID}] Pay file 'Release' action failed.
    END
    Close Browser
    Log To Console    [${STORE_ID}] Pay file released successfully. Verifying database status...

Reopen Recompute And Release Pay File For BiWeek For Store
    [Documentation]    Reopens, recomputes and releases the pay file for biweekly frequency
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}    ${first_week_start_date}    ${last_week_start_date}
    ...    ${recompute_action}
    # Reopen pay file for this store
    Reopen Pay File For BiWeek For Store On Period Payroll Release Page On Web    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}
    ...    ${first_week_start_date}
    # Recompute pay file for this store
    Recompute Pay File For Store On Pay Recompute Page On Web    ${STORE_ID}    ${STORE_NAME}    ${first_week_start_date}
    ...    ${last_week_start_date}    RELEASED_UNRELEASED_TIMECARD    ${recompute_action}
    # Release pay file for this store
    Release Pay File For BiWeek For Store On Period Payroll Release Page On Web    ${STORE_ID}    ${STORE_NAME}    ${manager_profile}
    ...    ${first_week_start_date}

Recompute Update And Validate Pay File Status For Data Generated For Store
    [Documentation]    Recomputes the pay file for the store and validates that the Unit Pay Details file status is updated to 'D' (Data Generated) in DB
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${first_week_start_date}    ${last_week_start_date}    ${period_start}
    ...    ${period_end}    ${recompute_action}    ${data_generated}
    Log To Console    [${STORE_ID}] Recomputing and validating pay file...
    Login And Launch WFM Web App    user_key=SYSADMIN
    Recompute Pay File For Store On Pay Recompute Page On Web    ${STORE_ID}    ${STORE_NAME}    ${first_week_start_date}
    ...    ${last_week_start_date}    RELEASED_UNRELEASED_TIMECARD    ${recompute_action}
    Update And Validate Unit Group Pay Details File Status To Required Status In DB    ${period_start}    ${period_end}    ${STORE_ID}
    ...    ${data_generated}
    Update And Validate Unit Pay Details File Status To Required Status In DB    ${period_start}    ${period_end}    ${STORE_ID}
    ...    ${data_generated}
