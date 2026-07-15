*** Settings ***
Documentation       Pay Recompute DB keywords implementation

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/common/database.resource


*** Keywords ***
Get Unit Pay Details Status From DB
    [Documentation]    Returns unit pay details status from DB for a given unit id and week range
    ...    | =Arguments= | =Description= |
    ...    | week_start | Week start date for the database query (yyyymmdd) |
    ...    | week_end | Week end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to query |
    [Arguments]    ${week_start}    ${week_end}    ${unit_id}
    VAR    ${GET_UNIT_PAY_DETAILS_QUERY_STATUS}
    ...    SELECT tups.LOCK_STATUS, tups.FILE_STATUS FROM TA_UNIT_PAY_STATUS tups WHERE tups.UNIT_ID = '{unit_id}' AND tups.WEEK_START_DATE <= {week_end} AND tups.WEEK_END_DATE >= {week_start}
    ${db_query1}    Replace String    ${GET_UNIT_PAY_DETAILS_QUERY_STATUS}    {week_start}    ${week_start}
    ${db_query2}    Replace String    ${db_query1}    {week_end}    ${week_end}
    ${unit_pay_status_query}    Replace String    ${db_query2}    {unit_id}    ${unit_id}
    Log    Query to execute: ${unit_pay_status_query}
    ${unit_pay_file_status}    Execute Query And Return Result    ${unit_pay_status_query}
    RETURN    ${unit_pay_file_status}

Check Status For Pay Files Changed To F From DB
    [Documentation]    Polls the database until all records have status 'F' or timeout is reached
    ...    | =Arguments= | =Description= |
    ...    | week_start | Week start date for the database query (yyyymmdd) |
    ...    | week_end | Week end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to query |
    ...    | expected_status | Expected final status (default: 'F') |
    ...    | =Returns= | =Description= |
    ...    | all_status_f | Boolean indicating if all records reached status 'F' |
    [Arguments]    ${week_start}    ${week_end}    ${unit_id}    ${expected_status}=F
    ${retry_attempts}    Get Config Value    MAX_RETRY_ATTEMPTS
    Log    Starting to poll database for status '${expected_status}' - Retries: ${retry_attempts}, Interval: ${LONG_TIMEOUT}
    ${status_f}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${retry_attempts}    ${LONG_TIMEOUT}
    ...    Validate All Unit Pay DB Records Have Expected F File Status    ${week_start}    ${week_end}    ${unit_id}
    IF    not ${status_f}
        Log    Warning: Did not reach status '${expected_status}' within ${retry_attempts} attempts.
    END
    RETURN    ${status_f}

Validate All Unit Pay DB Records Have Expected F File Status
    [Documentation]    Validates that all records in the result have the expected status
    ...    | =Arguments= | =Description= |
    ...    | db_result | Database query result as list of tuples |
    ...    | expected_status | Expected status value (e.g., 'F') |
    ...    | =Returns= | =Description= |
    ...    | all_match | Boolean indicating if all records have the expected status |
    [Arguments]    ${week_start}    ${week_end}    ${unit_id}
    ${db_result}    Get Unit Pay Details Status From DB    ${week_start}    ${week_end}    ${unit_id}
    Log    Database query result: ${db_result}
    ${row}    Get From List    ${db_result}    0
    ${file_status}    Get From List    ${row}    1
    IF    '${file_status}' != 'F'
        Fail    Expected status 'F' but found '${file_status}' in database query result
    END

Validate All Unit Pay DB Records Have Expected File Status
    [Documentation]    Validates that all records in the result have the expected status
    ...    | =Arguments= | =Description= |
    ...    | db_result | Database query result as list of tuples |
    ...    | expected_status | | Q for queued for creation |
    ...    | =Returns= | =Description= |
    ...    | all_match | Boolean indicating if all records have the expected status |
    [Arguments]    ${week_start}    ${week_end}    ${unit_id}    ${expected_status}
    ${db_result}    Get Unit Pay Details Status From DB    ${week_start}    ${week_end}    ${unit_id}
    Log    Database query result: ${db_result}
    ${row}    Get From List    ${db_result}    0
    ${file_status}    Get From List    ${row}    1
    IF    '${file_status}' != '${expected_status}'
        Fail    Expected status '${expected_status}' but found '${file_status}' in database query result
    END
    Log    Success: All records have the expected status '${expected_status}'

Get Work Duration And Cost Data By Employee From Unit Pay Detail
    [Documentation]    Returns post compute data from DB for multiple units
    ...    | =Arguments= | =Description= |
    ...    | week_start | Week start date for the database query (yyyymmdd) |
    ...    | week_end | Week end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to query |
    [Arguments]    ${week_start}    ${week_end}    ${unit_id}
    VAR    ${GET_WORK_DURATION_AND_ACTUAL_COST}
    ...    SELECT tupd.EMPLOYEE_ID, sum(tupd.WORK_DURATION),sum(tupd.ACTUAL_COST) FROM TA_UNIT_PAY_DETAIL tupd WHERE tupd.UNIT_ID = '{unit_id}'AND tupd.EVENT_DATE BETWEEN {week_start} AND {week_end} AND tupd.PAY_WEEK_END_DATE = {week_end} GROUP BY tupd.EMPLOYEE_ID ORDER BY tupd.EMPLOYEE_ID;
    ${db_query1}    Replace String    ${GET_WORK_DURATION_AND_ACTUAL_COST}    {week_start}    ${week_start}
    ${db_query2}    Replace String    ${db_query1}    {week_end}    ${week_end}
    ${work_duration_and_actual_cost_query}    Replace String    ${db_query2}    {unit_id}    ${unit_id}
    Log    Query to execute: ${work_duration_and_actual_cost_query}
    ${work_duration_and_cost_data}    Execute Query And Return Result    ${work_duration_and_actual_cost_query}
    VAR    @{column_names}    employee_id    worked_duration    actual_cost
    ${json_string}    Convert DB Results Tuples To JSON String    ${work_duration_and_cost_data}    ${column_names}
    RETURN    ${json_string}

Get Work Duration By Employee From Cost Segment
    [Documentation]    Retrieves work duration data by employee from the cost segment table
    ...    for the given week range and unit ID and returns it as a JSON string.
    [Arguments]    ${week_start}    ${week_end}    ${unit_id}
    VAR    ${GET_RECOMPUTE_JOB_STATUS}
    ...    SELECT RE.EMPLOYEE_ID, SUM(TCS.PAY_DURATION_DEC) AS WORKED_DURATION FROM RWSUSER.TA_COST_SEGMENT TCS, RWSUSER.RHR_EMPLOYEE RE WHERE TCS.SEGMENT_DATE >= {week_start} AND TCS.SEGMENT_DATE <= {week_end} AND TCS.UNIT_ID = '{unit_id}' AND RE.PERSON_ID = TCS.PERSON_ID AND RE.OWNER_ID = TCS.OWNER_ID AND RE.CLIENT_ID = TCS.CLIENT_ID GROUP BY RE.EMPLOYEE_ID ORDER BY RE.EMPLOYEE_ID;
    ${db_query1}    Replace String    ${GET_RECOMPUTE_JOB_STATUS}    {week_start}    ${week_start}
    ${db_query2}    Replace String    ${db_query1}    {week_end}    ${week_end}
    ${work_duration_from_cost_segment_query}    Replace String    ${db_query2}    {unit_id}    ${unit_id}
    Log    Query to execute: ${work_duration_from_cost_segment_query}
    ${work_duration_by_emp}    Execute Query And Return Result    ${work_duration_from_cost_segment_query}
    VAR    @{column_names}    employee_id    worked_duration
    ${json_string}    Convert DB Results Tuples To JSON String    ${work_duration_by_emp}    ${column_names}
    RETURN    ${json_string}

Get Batch Job ID For Recompute Job From DB
    [Documentation]    Retrieves the batch job ID for recompute jobs from the database
    ...    | =Returns= | =Description= |
    ...    | recompute_batch_id | Batch ID for the recompute job |
    [Arguments]    ${job_type}
    IF    '${job_type}' == 'RECOMPUTE_PAY'
        VAR    ${query_job_type}    RECAL
    ELSE IF    '${job_type}' == 'RESAVE_TIMECARD'
        VAR    ${query_job_type}    RESAVETCARD
    ELSE
        Fail    Invalid job type provided: ${job_type}, Expected 'RECOMPUTE_PAY' or 'RESAVE_TIMECARD'.
    END
    VAR    ${GET_BATCH_ID_FOR_RECOMPUTE_JOB}
    ...    SELECT BATCH_STATUS_ID FROM BATCH_STATUS WHERE JOB_TYPE ='{job_type}' ORDER BY TIME_SUBMITTED DESC LIMIT 1;
    ${get_batch_id_query}    Replace String    ${GET_BATCH_ID_FOR_RECOMPUTE_JOB}    {job_type}    ${query_job_type}
    ${recompute_batch_job_id}    Execute Query And Return Result    ${get_batch_id_query}
    ${recompute_batch_id}    Get From List    @{recompute_batch_job_id}    0
    RETURN    ${recompute_batch_id}

Get Recompute Batch Job Status From DB
    [Documentation]    Retrieves the status of recompute batch jobs from the database
    ...    | =Arguments= | =Description= |
    ...    | batch_id | ``BATCH_STATUS_ID`` for the queued recompute batch job |
    [Arguments]    ${batch_id}
    # Previous query: job_type + unit id via PARAM_9 (kept for reference; replaced by BATCH_STATUS_ID).
    # VAR    ${GET_BATCH_RECOMPUTE_JOB_STATUS}
    # ...    SELECT JOB_QSTATUS, JOB_ESTATUS FROM RFX_QUEUE_JOB WHERE JOB_TYPE ='{job_type}' AND PARAM_9 LIKE '%__UNIT_ID__%' ORDER BY QUEUE_IN DESC LIMIT 1;
    VAR    ${GET_BATCH_RECOMPUTE_JOB_STATUS}
    ...    SELECT JOB_QSTATUS, JOB_ESTATUS FROM RFX_QUEUE_JOB WHERE BATCH_STATUS_ID = {batch_id}
    ${get_recompute_job_status_query}    Replace String    ${GET_BATCH_RECOMPUTE_JOB_STATUS}    {batch_id}    ${batch_id}
    Log    Query to execute: ${get_recompute_job_status_query}
    ${recompute_batch_job_status}    Execute Query And Return Result    ${get_recompute_job_status_query}
    RETURN    ${recompute_batch_job_status}

Check Completed Status For Pay Files Recompute From DB
    [Documentation]    Polls the database until all records have qstatus 'C' and estatus 'S' or timeout is reached
    ...    | =Arguments= | =Description= |
    ...    | batch_id | Batch ID for the database query |
    ...    | =Returns= | =Description= |
    ...    | batch_job_success | Boolean indicating if all records reached respective required status |
    [Arguments]    ${batch_id}
    ${retry_attempts}    Get Config Value    MAX_RETRY_ATTEMPTS
    Log    Starting to poll database for required status - Retries: ${retry_attempts}, Interval: ${LONG_TIMEOUT}
    ${batch_job_success}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${retry_attempts}    ${LONG_TIMEOUT}
    ...    Validate Recompute Batch Job Status Is Completed From DB    ${batch_id}
    IF    not ${batch_job_success}
        Log    Warning: Required qstatus 'C' and estatus 'S' not reached within ${retry_attempts}
    END
    RETURN    ${batch_job_success}

Validate Recompute Batch Job Status Is Completed From DB
    [Documentation]    Fails unless all recompute batch job records have qstatus 'C' and estatus 'S'
    [Arguments]    ${batch_id}
    ${recompute_batch_job_status}    Get Recompute Batch Job Status From DB    ${batch_id}
    Log    Database query result: ${recompute_batch_job_status}
    IF    not ${recompute_batch_job_status}
        Fail    No recompute batch job records found in DB for batch id ${batch_id}
    END
    FOR    ${record}    IN    @{recompute_batch_job_status}
        VAR    ${q_status}    ${record}[0]
        VAR    ${e_status}    ${record}[1]
        Should Be Equal    ${q_status}    C
        Should Be Equal    ${e_status}    S
        Log    Success: The job has qstatus 'C' and estatus 'S'
    END

Update And Validate Unit Pay Details File Status To Required Status In DB
    [Documentation]    Updates the unit pay details file status to the specified status in the database for a given unit id and period range
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date for the database query (yyyymmdd) |
    ...    | period_end | Period end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to update |
    ...    | file_status | File status to update | Q for queued for creation
    [Arguments]    ${period_start}    ${period_end}    ${unit_id}    ${file_status}
    VAR    ${UPDATE_UNIT_PAY_DETAILS_FILE_STATUS}
    ...    UPDATE TA_UNIT_PAY_STATUS tups SET tups.FILE_STATUS = '{file_status}', tups.FILE_ID = 0 WHERE tups.UNIT_ID = '{unit_id}' AND tups.WEEK_START_DATE <= {period_end} AND tups.WEEK_END_DATE >= {period_start}
    ${db_query1}    Replace String    ${UPDATE_UNIT_PAY_DETAILS_FILE_STATUS}    {period_start}    ${period_start}
    ${db_query2}    Replace String    ${db_query1}    {period_end}    ${period_end}
    ${db_query3}    Replace String    ${db_query2}    {unit_id}    ${unit_id}
    ${unit_pay_status_query}    Replace String    ${db_query3}    {file_status}    ${file_status}
    Log    Query to execute: ${unit_pay_status_query}
    Execute Query And Return Result    ${unit_pay_status_query}
    Validate All Unit Pay DB Records Have Expected File Status    ${period_start}    ${period_end}    ${unit_id}    ${file_status}

Update And Validate Unit Group Pay Details File Status To Required Status In DB
    [Documentation]    Updates the unit group pay details file status to the specified status in the database for a given unit id and period range
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date for the database query (yyyymmdd) |
    ...    | period_end | Period end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to update |
    ...    | file_status | File status to update | Q for queued for creation |
    ...    | dist_list_id | Optional distribution list id (e.g. employee group id) to scope the update |
    [Arguments]    ${period_start}    ${period_end}    ${unit_id}    ${file_status}    ${dist_list_id}=${EMPTY}
    IF    '${dist_list_id}' != '${EMPTY}'
        VAR    ${dist_list_clause}    AND tgps.DIST_LIST_ID = ${dist_list_id}
    ELSE
        VAR    ${dist_list_clause}    ${EMPTY}
    END
    VAR    ${UPDATE_UNIT_GROUP_PAY_FILE_STATUS}
    ...    UPDATE TA_GROUP_PAY_STATUS tgps SET tgps.FILE_STATUS = '{file_status}', tgps.FILE_ID = 0 WHERE tgps.UNIT_ID = '{unit_id}' AND tgps.PERIOD_START_DATE = {period_start} AND tgps.PERIOD_END_DATE = {period_end} {dist_list_clause}
    ${db_query1}    Replace String    ${UPDATE_UNIT_GROUP_PAY_FILE_STATUS}    {period_start}    ${period_start}
    ${db_query2}    Replace String    ${db_query1}    {period_end}    ${period_end}
    ${db_query3}    Replace String    ${db_query2}    {unit_id}    ${unit_id}
    ${db_query4}    Replace String    ${db_query3}    {dist_list_clause}    ${dist_list_clause}
    ${unit_group_pay_status_query}    Replace String    ${db_query4}    {file_status}    ${file_status}
    Log    Query to execute: ${unit_group_pay_status_query}
    Execute Query And Return Result    ${unit_group_pay_status_query}
    Validate Unit Group Pay DB Records Have Expected File Status    ${period_start}    ${period_end}    ${unit_id}    ${file_status}
    ...    ${dist_list_id}

Validate Unit Group Pay DB Records Have Expected File Status
    [Documentation]    Validates that all records in the result have the expected status
    ...    | =Arguments= | =Description= |
    ...    | db_result | Database query result as list of tuples |
    ...    | expected_status | | Q for queued for creation |
    ...    | dist_list_id | Optional distribution list id (e.g. employee group id) to scope the query |
    ...    | =Returns= | =Description= |
    ...    | all_match | Boolean indicating if all records have the expected status |
    [Arguments]    ${period_start}    ${period_end}    ${unit_id}    ${expected_status}    ${dist_list_id}=${EMPTY}
    ${db_result}    Get Unit Group Pay Details File Status From DB    ${period_start}    ${period_end}    ${unit_id}
    ...    ${dist_list_id}
    Log    Database query result: ${db_result}
    ${row}    Get From List    ${db_result}    0
    ${file_status}    Get From List    ${row}    0
    IF    '${file_status}' != '${expected_status}'
        Fail    Expected status '${expected_status}' but found '${file_status}' in database query result
    END
    Log    Success: All records have the expected status '${expected_status}'

Get Unit Group Pay Details File Status From DB
    [Documentation]    Returns unit group pay details file status from DB for a given unit id and period range
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date for the database query (yyyymmdd) |
    ...    | period_end | Period end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to query |
    ...    | dist_list_id | Optional distribution list id (e.g. employee group id) to scope the query |
    [Arguments]    ${period_start}    ${period_end}    ${unit_id}    ${dist_list_id}=${EMPTY}
    IF    '${dist_list_id}' != '${EMPTY}'
        VAR    ${dist_list_clause}    AND tgps.DIST_LIST_ID = ${dist_list_id}
    ELSE
        VAR    ${dist_list_clause}    ${EMPTY}
    END
    VAR    ${GET_UNIT_GROUP_PAY_DETAILS_QUERY_STATUS}
    ...    SELECT FILE_STATUS FROM TA_GROUP_PAY_STATUS tgps WHERE tgps.UNIT_ID = '${unit_id}' AND tgps.PERIOD_START_DATE = ${period_start} AND tgps.PERIOD_END_DATE = ${period_end} {dist_list_clause}
    ${db_query1}    Replace String    ${GET_UNIT_GROUP_PAY_DETAILS_QUERY_STATUS}    {period_start}    ${period_start}
    ${db_query2}    Replace String    ${db_query1}    {period_end}    ${period_end}
    ${db_query3}    Replace String    ${db_query2}    {unit_id}    ${unit_id}
    ${unit_group_pay_status_query}    Replace String    ${db_query3}    {dist_list_clause}    ${dist_list_clause}
    Log    Query to execute: ${unit_group_pay_status_query}
    ${unit_group_pay_file_status}    Execute Query And Return Result    ${unit_group_pay_status_query}
    RETURN    ${unit_group_pay_file_status}

Validate 45 Group Pay DB Records Have Expected F File Status
    [Documentation]    Validates that the 45 Group Pay record in ``TA_GROUP_PAY_STATUS`` has file status ``F``.
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date for the database query (yyyymmdd) |
    ...    | period_end | Period end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to query |
    ...    | dist_list_id | 45 Group Pay id (``DIST_LIST_ID``) to scope the query |
    [Arguments]    ${period_start}    ${period_end}    ${unit_id}    ${dist_list_id}
    ${db_result}    Get Unit Group Pay Details File Status From DB    ${period_start}    ${period_end}    ${unit_id}
    ...    ${dist_list_id}
    Log    Database query result: ${db_result}
    ${row}    Get From List    ${db_result}    0
    ${file_status}    Get From List    ${row}    0
    IF    '${file_status}' != 'F'
        Fail    Expected status 'F' but found '${file_status}' in database query result for 45 Group Pay '${dist_list_id}'
    END

Check Status For 45 Version Group Pay Files Changed To F From DB
    [Documentation]    Polls ``TA_GROUP_PAY_STATUS`` until the 45 Group Pay record reaches status ``F`` or timeout is reached.
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date for the database query (yyyymmdd) |
    ...    | period_end | Period end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to query |
    ...    | dist_list_id | 45 Group Pay id (``DIST_LIST_ID``) to scope the query |
    ...    | expected_status | Expected final status (default: ``F``) |
    ...    | =Returns= | =Description= |
    ...    | all_status_f | Boolean indicating if the record reached status ``F`` |
    [Arguments]    ${period_start}    ${period_end}    ${unit_id}    ${dist_list_id}    ${expected_status}=F
    ${retry_attempts}    Get Config Value    MAX_RETRY_ATTEMPTS
    Log
    ...    Starting to poll database for 45 Group Pay '${dist_list_id}' status '${expected_status}' - Retries: ${retry_attempts}, Interval: ${LONG_TIMEOUT}
    ${status_f}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${retry_attempts}    ${LONG_TIMEOUT}
    ...    Validate 45 Group Pay DB Records Have Expected F File Status    ${period_start}    ${period_end}    ${unit_id}
    ...    ${dist_list_id}
    IF    not ${status_f}
        Log    Warning: Did not reach status '${expected_status}' for 45 Group Pay '${dist_list_id}' within ${retry_attempts} attempts.
    END
    RETURN    ${status_f}

Check Status For Unit Group Pay Files Changed To File Generated From DB
    [Documentation]    Polls the database until all records have status 'F' or timeout is reached
    ...    | =Arguments= | =Description= |
    ...    | week_start | Week start date for the database query (yyyymmdd) |
    ...    | week_end | Week end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to query |
    ...    | expected_status | Expected final status (default: 'F') |
    ...    | =Returns= | =Description= |
    ...    | all_status_f | Boolean indicating if all records reached status 'F' |
    [Arguments]    ${week_start}    ${week_end}    ${unit_id}    ${expected_status}=F
    ${retry_attempts}    Get Config Value    MAX_RETRY_ATTEMPTS
    Log    Starting to poll database for status '${expected_status}' - Retries: ${retry_attempts}, Interval: ${LONG_TIMEOUT}
    ${status_f}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${retry_attempts}    ${LONG_TIMEOUT}
    ...    Validate Unit Group Pay DB Records Have Expected File Status    ${week_start}    ${week_end}    ${unit_id}    ${expected_status}
    IF    not ${status_f}
        Log    Warning: Did not reach status '${expected_status}' within ${retry_attempts} attempts.
    END
    RETURN    ${status_f}

Get Work Duration And Cost Data By Employee From Cost Difference Segment
    [Documentation]    Returns work duration and cost data by employee from the cost difference segment table for a given unit id and period end date
    ...    | =Arguments= | =Description= |
    ...    | period_end | Period end date for the database query (yyyymmdd) |
    ...    | unit_id | Unit ID to query |
    [Arguments]    ${period_start}    ${period_end}    ${unit_id}
    VAR    ${GET_COST_DIFFERENCE_FROM_COST_SEGMENT}
    ...    SELECT RE.EMPLOYEE_ID, SUM(TCSD.WORK_DURATION), SUM(TCSD.ACTUAL_COST) FROM RWSUSER.TA_COST_SEG_DIFF TCSD, RWSUSER.RHR_EMPLOYEE RE WHERE TCSD.UNIT_ID = '${unit_id}' AND tcsd.EVENT_DATE BETWEEN
    ...    ${period_start} AND ${period_end} AND RE.PERSON_ID = TCSD.PERSON_ID AND RE.OWNER_ID = TCSD.OWNER_ID AND RE.CLIENT_ID = TCSD.CLIENT_ID GROUP BY RE.EMPLOYEE_ID ORDER BY RE.EMPLOYEE_ID
    ${db_query1}    Replace String    ${GET_COST_DIFFERENCE_FROM_COST_SEGMENT}    {period_start}    ${period_start}
    ${db_query2}    Replace String    ${db_query1}    {period_end}    ${period_end}
    ${cost_diff_from_cost_segment_query}    Replace String    ${db_query2}    {unit_id}    ${unit_id}
    Log    Query to execute: ${cost_diff_from_cost_segment_query}
    ${work_duration_by_emp}    Execute Query And Return Result    ${cost_diff_from_cost_segment_query}
    VAR    @{column_names}    employee_id    worked_duration    actual_cost
    ${json_string}    Convert DB Results Tuples To JSON String    ${work_duration_by_emp}    ${column_names}
    RETURN    ${json_string}

Get Person IDs From Employee Group Mapping
    [Documentation]    Returns distinct person IDs for an employee group active in the given period.
    ...    | =Arguments= | =Description= |
    ...    | emp_group_id | Employee group id (``GROUP_ID`` in ``RWS_EMP_GROUP_MAPPING``). |
    ...    | period_start | Period start date key (yyyymmdd). |
    ...    | period_end | Period end date key (yyyymmdd). |
    ...    | =Returns= | =Description= |
    ...    | person_ids | List of person id strings. |
    [Arguments]    ${emp_group_id}    ${period_start}    ${period_end}
    VAR    ${GET_PERSON_IDS_FROM_EMP_GROUP_MAPPING}
    ...    SELECT DISTINCT egm.PERSON_ID FROM RWSUSER.RWS_EMP_GROUP_MAPPING egm WHERE egm.GROUP_ID = {emp_group_id} AND egm.EFF_DATESKEY <= {period_end} AND egm.END_DATESKEY >= {period_start}
    ${db_query1}    Replace String    ${GET_PERSON_IDS_FROM_EMP_GROUP_MAPPING}    {emp_group_id}    ${emp_group_id}
    ${db_query2}    Replace String    ${db_query1}    {period_start}    ${period_start}
    ${person_ids_query}    Replace String    ${db_query2}    {period_end}    ${period_end}
    Log    Query to execute: ${person_ids_query}
    ${person_id_rows}    Execute Query And Return Result    ${person_ids_query}
    VAR    @{person_ids}    @{EMPTY}
    FOR    ${row}    IN    @{person_id_rows}
        ${person_id}    Convert To String    ${row}[0]
        ${person_id}    Evaluate    $person_id.strip()
        Append To List    ${person_ids}    ${person_id}
    END
    RETURN    ${person_ids}

Build Person Id In Clause From List
    [Documentation]    Builds a quoted comma-separated IN-clause value list from person ids.
    ...    | =Arguments= | =Description= |
    ...    | person_ids | List of person id strings. |
    ...    | =Returns= | =Description= |
    ...    | in_clause | Quoted comma-separated ids for SQL IN clause. |
    [Tags]    robot:private
    [Arguments]    @{person_ids}
    VAR    @{quoted_ids}    @{EMPTY}
    FOR    ${person_id}    IN    @{person_ids}
        Append To List    ${quoted_ids}    '${person_id}'
    END
    ${in_clause}    Evaluate    ",".join($quoted_ids)
    RETURN    ${in_clause}

Split Person Id List Into DB Query Batches
    [Documentation]    Splits person ids into fixed-size batches for DB IN-clause queries.
    ...    | =Arguments= | =Description= |
    ...    | batch_size | Maximum person ids per batch. |
    ...    | person_ids | Person id list. |
    ...    | =Returns= | =Description= |
    ...    | batches | List of person id sublists. |
    [Arguments]    ${batch_size}    @{person_ids}
    VAR    @{batches}    @{EMPTY}
    VAR    @{current_batch}    @{EMPTY}
    FOR    ${person_id}    IN    @{person_ids}
        Append To List    ${current_batch}    ${person_id}
        ${current_batch_count}    Get Length    ${current_batch}
        IF    ${current_batch_count} == ${batch_size}
            Append To List    ${batches}    ${current_batch}
            VAR    @{current_batch}    @{EMPTY}
        END
    END
    ${remaining_count}    Get Length    ${current_batch}
    IF    ${remaining_count} > 0
        Append To List    ${batches}    ${current_batch}
    END
    RETURN    ${batches}

Get Work Duration And Cost Data By Person IDs From Unit Pay Detail Page
    [Documentation]    Returns unit pay detail rows for the given person ids.
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date (yyyymmdd). |
    ...    | period_end | Period end date (yyyymmdd). |
    ...    | person_ids_in_clause | Quoted comma-separated person ids for SQL IN clause. |
    [Tags]    robot:private
    [Arguments]    ${period_start}    ${period_end}    ${person_ids_in_clause}
    VAR    ${GET_WORK_DUR_COST_BY_PERSON_IDS}
    ...    SELECT RE.EMPLOYEE_ID, sum(tupd.WORK_DURATION), sum(tupd.ACTUAL_COST) FROM TA_UNIT_PAY_DETAIL tupd, RWSUSER.RHR_EMPLOYEE RE WHERE RE.PERSON_ID IN ({person_ids_in_clause}) AND tupd.EVENT_DATE BETWEEN {period_start} AND {period_end} AND tupd.PAY_WEEK_END_DATE = {period_end} AND RE.EMPLOYEE_ID = tupd.EMPLOYEE_ID AND RE.OWNER_ID = tupd.OWNER_ID AND RE.CLIENT_ID = tupd.CLIENT_ID GROUP BY RE.EMPLOYEE_ID ORDER BY RE.EMPLOYEE_ID
    ${db_query1}    Replace String    ${GET_WORK_DUR_COST_BY_PERSON_IDS}    {period_start}    ${period_start}
    ${db_query2}    Replace String    ${db_query1}    {period_end}    ${period_end}
    ${work_duration_query}    Replace String    ${db_query2}    {person_ids_in_clause}    ${person_ids_in_clause}
    Log    Query to execute: ${work_duration_query}
    ${work_duration_and_cost_data}    Execute Query And Return Result    ${work_duration_query}
    RETURN    ${work_duration_and_cost_data}

Get Work Duration By Person IDs From Cost Segment Page
    [Documentation]    Returns cost segment rows for the given person ids.
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date (yyyymmdd). |
    ...    | period_end | Period end date (yyyymmdd). |
    ...    | person_ids_in_clause | Quoted comma-separated person ids for SQL IN clause. |
    [Tags]    robot:private
    [Arguments]    ${period_start}    ${period_end}    ${person_ids_in_clause}
    VAR    ${GET_WORK_DUR_COST_SEG_BY_PERSON_IDS}
    ...    SELECT RE.EMPLOYEE_ID, SUM(TCS.PAY_DURATION_DEC) AS WORKED_DURATION FROM RWSUSER.TA_COST_SEGMENT TCS, RWSUSER.RHR_EMPLOYEE RE WHERE TCS.SEGMENT_DATE >= {period_start} AND TCS.SEGMENT_DATE <= {period_end} AND RE.PERSON_ID IN ({person_ids_in_clause}) AND RE.PERSON_ID = TCS.PERSON_ID AND RE.OWNER_ID = TCS.OWNER_ID AND RE.CLIENT_ID = TCS.CLIENT_ID GROUP BY RE.EMPLOYEE_ID ORDER BY RE.EMPLOYEE_ID
    ${db_query1}    Replace String    ${GET_WORK_DUR_COST_SEG_BY_PERSON_IDS}    {period_start}    ${period_start}
    ${db_query2}    Replace String    ${db_query1}    {period_end}    ${period_end}
    ${work_duration_query}    Replace String    ${db_query2}    {person_ids_in_clause}    ${person_ids_in_clause}
    Log    Query to execute: ${work_duration_query}
    ${work_duration_by_emp}    Execute Query And Return Result    ${work_duration_query}
    RETURN    ${work_duration_by_emp}

Get Work Duration And Cost Data By Person IDs From Cost Difference Segment Page
    [Documentation]    Returns cost difference segment rows for the given person ids.
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date (yyyymmdd). |
    ...    | period_end | Period end date (yyyymmdd). |
    ...    | person_ids_in_clause | Quoted comma-separated person ids for SQL IN clause. |
    [Tags]    robot:private
    [Arguments]    ${period_start}    ${period_end}    ${person_ids_in_clause}
    VAR    ${GET_COST_DIFF_SEG_BY_PERSON_IDS}
    ...    SELECT RE.EMPLOYEE_ID, SUM(TCSD.WORK_DURATION), SUM(TCSD.ACTUAL_COST) FROM RWSUSER.TA_COST_SEG_DIFF TCSD, RWSUSER.RHR_EMPLOYEE RE WHERE RE.PERSON_ID IN ({person_ids_in_clause}) AND TCSD.EVENT_DATE BETWEEN {period_start} AND {period_end} AND RE.PERSON_ID = TCSD.PERSON_ID AND RE.OWNER_ID = TCSD.OWNER_ID AND RE.CLIENT_ID = TCSD.CLIENT_ID GROUP BY RE.EMPLOYEE_ID ORDER BY RE.EMPLOYEE_ID
    ${db_query1}    Replace String    ${GET_COST_DIFF_SEG_BY_PERSON_IDS}    {period_start}    ${period_start}
    ${db_query2}    Replace String    ${db_query1}    {period_end}    ${period_end}
    ${cost_diff_query}    Replace String    ${db_query2}    {person_ids_in_clause}    ${person_ids_in_clause}
    Log    Query to execute: ${cost_diff_query}
    ${work_duration_by_emp}    Execute Query And Return Result    ${cost_diff_query}
    RETURN    ${work_duration_by_emp}

Get Work Duration And Cost Data By Person IDs From Unit Pay Detail
    [Documentation]    Returns aggregated unit pay detail JSON for person ids, querying in batches of ``PAYROLL_RECOMPUTE_DB_PAGE_SIZE`` (default 1000).
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date (yyyymmdd). |
    ...    | period_end | Period end date (yyyymmdd). |
    ...    | person_ids | List of person id strings. |
    [Arguments]    ${period_start}    ${period_end}    @{person_ids}
    ${batch_size}    Get Config Value    PAYROLL_RECOMPUTE_DB_PAGE_SIZE    1000
    @{batches}    Split Person Id List Into DB Query Batches    ${batch_size}    @{person_ids}
    VAR    @{all_results}    @{EMPTY}
    FOR    ${batch}    IN    @{batches}
        ${person_ids_in_clause}    Build Person Id In Clause From List    @{batch}
        ${batch_results}    Get Work Duration And Cost Data By Person IDs From Unit Pay Detail Page    ${period_start}
        ...    ${period_end}    ${person_ids_in_clause}
        ${all_results}    Combine Lists    ${all_results}    ${batch_results}
    END
    VAR    @{column_names}    employee_id    worked_duration    actual_cost
    ${json_string}    Convert DB Results Tuples To JSON String    ${all_results}    ${column_names}
    RETURN    ${json_string}

Get Work Duration By Person IDs From Cost Segment
    [Documentation]    Returns aggregated cost segment JSON for person ids, querying in batches of ``PAYROLL_RECOMPUTE_DB_PAGE_SIZE`` (default 1000).
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date (yyyymmdd). |
    ...    | period_end | Period end date (yyyymmdd). |
    ...    | person_ids | List of person id strings. |
    [Arguments]    ${period_start}    ${period_end}    @{person_ids}
    ${batch_size}    Get Config Value    PAYROLL_RECOMPUTE_DB_PAGE_SIZE    1000
    @{batches}    Split Person Id List Into DB Query Batches    ${batch_size}    @{person_ids}
    VAR    @{all_results}    @{EMPTY}
    FOR    ${batch}    IN    @{batches}
        ${person_ids_in_clause}    Build Person Id In Clause From List    @{batch}
        ${batch_results}    Get Work Duration By Person IDs From Cost Segment Page    ${period_start}    ${period_end}
        ...    ${person_ids_in_clause}
        ${all_results}    Combine Lists    ${all_results}    ${batch_results}
    END
    VAR    @{column_names}    employee_id    worked_duration
    ${json_string}    Convert DB Results Tuples To JSON String    ${all_results}    ${column_names}
    RETURN    ${json_string}

Get Work Duration And Cost Data By Person IDs From Cost Difference Segment
    [Documentation]    Returns aggregated cost difference segment JSON for person ids, querying in batches of ``PAYROLL_RECOMPUTE_DB_PAGE_SIZE`` (default 1000).
    ...    | =Arguments= | =Description= |
    ...    | period_start | Period start date (yyyymmdd). |
    ...    | period_end | Period end date (yyyymmdd). |
    ...    | person_ids | List of person id strings. |
    [Arguments]    ${period_start}    ${period_end}    @{person_ids}
    ${batch_size}    Get Config Value    PAYROLL_RECOMPUTE_DB_PAGE_SIZE    1000
    @{batches}    Split Person Id List Into DB Query Batches    ${batch_size}    @{person_ids}
    VAR    @{all_results}    @{EMPTY}
    FOR    ${batch}    IN    @{batches}
        ${person_ids_in_clause}    Build Person Id In Clause From List    @{batch}
        ${batch_results}    Get Work Duration And Cost Data By Person IDs From Cost Difference Segment Page    ${period_start}
        ...    ${period_end}    ${person_ids_in_clause}
        ${all_results}    Combine Lists    ${all_results}    ${batch_results}
    END
    VAR    @{column_names}    employee_id    worked_duration    actual_cost
    ${json_string}    Convert DB Results Tuples To JSON String    ${all_results}    ${column_names}
    RETURN    ${json_string}
