*** Settings ***
Documentation       This test verifies pay files comparison for an employee group by reopening, resaving timecards
...                 via ``ResaveTimecardUtilityServlet``, and re-releasing pay files at SYSADMIN level.
...                 When run with --processes parameter, each process handles one employee group row from the Excel file.

Resource            tests/web/payroll_replay/payroll_replay_common.resource
Library             DataDriver    file=${PAYROLL_RECOMPUTE_FILE}

Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           action:write    dev:pankaj    config:rta    config:new_payroll_changes


*** Test Cases ***
WFM-Frequency Pay Files Recompute Comparison For Employee Group ${EMP_GROUP_ID} - ${PAYFILE_CONFIG_NAME} - ${FREQUENCY}
    [Documentation]    Verifies payroll recompute for an employee group by reopening, resaving timecards
    ...    via ``ResaveTimecardUtilityServlet``, and re-releasing pay files at SYSADMIN level.
    [Tags]    45_payroll_replay_emp_group
    [Template]    Process Employee Group Payroll Reopen Recompute And Release


*** Keywords ***
Process Employee Group Payroll Reopen Recompute And Release
    [Documentation]    Processes payroll reopen, servlet resave, and release for an employee group.
    [Arguments]    ${FREQUENCY}    ${PERIOD_START}    ${PERIOD_END}    ${FIRST_WEEK_START}
    ...    ${LAST_WEEK_START}    ${EMP_GROUP_ID}    ${PAYFILE_CONFIG_NAME}    ${REOPEN_FOR_EDITS}
    Set Tags    ${FREQUENCY}

    VAR    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}    ${EXECDIR}/period_payroll_release/pre_recompute_${EMP_GROUP_ID}_unit_pay_data.json
    VAR    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}    ${EXECDIR}/period_payroll_release/post_recompute_${EMP_GROUP_ID}_unit_pay_data.json
    VAR    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}
    ...    ${EXECDIR}/period_payroll_release/pre_recompute_${EMP_GROUP_ID}_ta_cost_segment_data.json
    VAR    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}
    ...    ${EXECDIR}/period_payroll_release/post_recompute_${EMP_GROUP_ID}_ta_cost_segment_data.json
    VAR    ${CORP_UNIT_ID}    CORP
    VAR    ${PAYROLL_FILE_STATUS_DATA_GENERATED}    D
    Log
    ...    Starting payroll recompute process for employee group: ${EMP_GROUP_ID} - ${PAYFILE_CONFIG_NAME}

    @{person_ids}    Get Person IDs For Employee Group Or Skip    ${EMP_GROUP_ID}    ${PERIOD_START}    ${PERIOD_END}

    IF    '${REOPEN_FOR_EDITS}' == 'N'
        VAR    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
        ...    ${EXECDIR}/period_payroll_release/pre_recompute_${EMP_GROUP_ID}_ta_cost_diff_segment_data.json
        VAR    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
        ...    ${EXECDIR}/period_payroll_release/post_recompute_${EMP_GROUP_ID}_ta_cost_diff_segment_data.json

        Collect Pre-Recompute Data With Prior Period For Employee Group    ${EMP_GROUP_ID}    ${PERIOD_START}    ${PERIOD_END}
        ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}    @{person_ids}

        Resave Timecards For Employee Group Via Servlet    ${FIRST_WEEK_START}    ${LAST_WEEK_START}    @{person_ids}
        Update And Validate Unit Group Pay Details File Status To Required Status In DB    ${PERIOD_START}    ${PERIOD_END}
        ...    ${CORP_UNIT_ID}    ${PAYROLL_FILE_STATUS_DATA_GENERATED}    ${EMP_GROUP_ID}

        ${pay_file_release_status_db}    Check Status For 45 Group Pay Files Changed To F From DB    ${PERIOD_START}
        ...    ${PERIOD_END}    ${CORP_UNIT_ID}    ${EMP_GROUP_ID}
        Log    [${EMP_GROUP_ID}] Unit Group Pay Details Status: ${pay_file_release_status_db}
        IF    not ${pay_file_release_status_db}
            Fail    [${EMP_GROUP_ID}] Payroll File Status in DB not changed to 'F' - Cannot proceed with comparison.
        END

        Collect Post-Recompute Data With Prior Period For Employee Group    ${EMP_GROUP_ID}    ${PERIOD_START}    ${PERIOD_END}
        ...    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}    @{person_ids}

        Compare Pre And Post Reopen-Released Pay File With Prior Period Cost Data For Employee Group    ${EMP_GROUP_ID}
        ...    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}
        ...    ${PRE_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_DIFF_SEGMENT_FILE}
    ELSE IF    '${REOPEN_FOR_EDITS}' == 'Y'
        Collect Pre-Recompute Data For Employee Group    ${EMP_GROUP_ID}    ${PERIOD_START}    ${PERIOD_END}
        ...    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    @{person_ids}

        Reopen Recompute And Release Pay File For Employee Group    ${EMP_GROUP_ID}    ${PAYFILE_CONFIG_NAME}    ${FREQUENCY}
        ...    ${PERIOD_START}    ${PERIOD_END}    ${FIRST_WEEK_START}    ${LAST_WEEK_START}    @{person_ids}

        ${pay_file_release_status_db}    Check Status For 45 Group Pay Files Changed To F From DB    ${PERIOD_START}
        ...    ${PERIOD_END}    ${CORP_UNIT_ID}    ${EMP_GROUP_ID}
        Log    [${EMP_GROUP_ID}] Unit Group Pay Details Status: ${pay_file_release_status_db}
        IF    not ${pay_file_release_status_db}
            Fail    [${EMP_GROUP_ID}] Payroll File Status in DB not changed to 'F' - Cannot proceed with comparison.
        END

        Collect Post-Recompute Data For Employee Group    ${EMP_GROUP_ID}    ${PERIOD_START}    ${PERIOD_END}
        ...    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}    @{person_ids}

        Compare Pre And Post Reopen-Released Pay File Data For Store    ${EMP_GROUP_ID}    ${PRE_RECOMPUTE_UNIT_PAYROLL_FILE}
        ...    ${POST_RECOMPUTE_UNIT_PAYROLL_FILE}    ${PRE_RECOMPUTE_TA_COST_SEGMENT_FILE}    ${POST_RECOMPUTE_TA_COST_SEGMENT_FILE}
    END
