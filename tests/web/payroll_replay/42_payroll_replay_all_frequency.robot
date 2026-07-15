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

Test Tags           action:write    dev:moiz    config:rta


*** Test Cases ***
WFM-Frequency Pay Files Recompute Comparison For Store ${STORE_ID} - ${STORE_NAME} - ${FREQUENCY}
    [Documentation]    This test verifies payroll recompute for store.
    [Tags]    pay_recompute_frequency
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

Recompute Update And Validate Pay File Status For Data Generated For Store
    [Documentation]    Recomputes the pay file for the store and validates that the Unit Pay Details file status is updated to 'D' (Data Generated) in DB
    [Arguments]    ${STORE_ID}    ${STORE_NAME}    ${start_week_date}    ${end_week_date}    ${period_start}
    ...    ${period_end}    ${recompute_action}    ${data_generated}
    Log To Console    [${STORE_ID}] Recomputing and validating pay file...
    Login And Launch WFM Web App    user_key=SYSADMIN
    Recompute Pay File For Store On Pay Recompute Page On Web    ${STORE_ID}    ${STORE_NAME}    ${start_week_date}
    ...    ${end_week_date}    RELEASED_UNRELEASED_TIMECARD    ${recompute_action}
    Update And Validate Unit Pay Details File Status To Required Status In DB    ${period_start}    ${period_end}    ${STORE_ID}
    ...    ${data_generated}
    ${unit_pay_file_status}    Validate All Unit Pay DB Records Have Expected File Status    ${period_start}
    ...    ${period_end}    ${STORE_ID}    ${data_generated}
    Log    [${STORE_ID}] Unit Pay Details File Status updated to '${data_generated}' in DB: ${unit_pay_file_status}
