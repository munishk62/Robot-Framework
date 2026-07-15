*** Settings ***
Documentation
...                 This resource file provides keywords for interacting with the database to verify the queue status of the
...                 auto publish schedule job, which is a prerequisite for executing certain test cases in the Week 3 SM1_STORE2 Schedule Suite.
...                 It includes a keyword to query the database and determine if the auto publish schedule job is in the expected queue status,
...                 allowing tests to conditionally skip execution if the setup is not applicable.
...
...                 = Purpose =
...                 - Provide a keyword to check the queue status of the auto publish schedule job in the database.
...                 - Enable conditional test execution based on the applicability of the auto publish schedule job status.
...
...                 = Prerequisites =
...                 - Required resources and variable files must be available and properly configured.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Verify Auto Publish Schedule Job Has Expected Queue Status In Database

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/common/database.resource
Variables           resources/web/rws/schedule/week_schedule_db_queries.py


*** Variables ***
${DUAL_SCHEDULING_FLOW_CONSTRAINT_QUERY}
...                                         SELECT CONSTRAINT_TYPE
...                                         FROM RWS_SCH_MPARAMS
...                                         WHERE PARAM_ID = 'DUAL_SCHEDULING_FLOW'
...                                         AND OWNER_ID = '{OWNER_ID}'

# STATE_SKEY reference: 2=REVIEW_FC 3=REVIEW_WD 4=REVIEW_SC 5=SC_PUB 6=SC_STALE 7=PUB_SC_STALE 10=WD_STALE_SC_PUB
${UNIT_PROCESS_STATUS_QUERY}
...                                         SELECT upf.STATE_SKEY
...                                         FROM RWSUSER.UNIT_PROCESS_STATUS_FACT upf
...                                         WHERE upf.OWNER_ID = '{OWNER_ID}'
...                                         AND upf.PROCESS_SKEY = 1
...                                         AND upf.ENTITY_TYPE = 'W'
...                                         AND upf.UNIT_SKEY = (SELECT UNIT_SKEY FROM RWSUSER.UNIT WHERE OWNER_ID = '{OWNER_ID}' AND UNIT_ID = '{UNIT_ID}')
...                                         AND upf.DATE_SKEY = {DATE_SKEY}

${GENERATE_WORKLOAD_CONFIG_FLAG_QUERY}
...                                         SELECT COUNT(t.TRANSITION_SKEY)
...                                         FROM EVENT_ACTION_REL ear
...                                         JOIN TRANSITION t
...                                         ON ear.OWNER_ID = t.OWNER_ID
...                                         AND ear.TRANSITION_SKEY = t.TRANSITION_SKEY
...                                         JOIN STATE sf
...                                         ON sf.STATE_SKEY = t.FROM_STATE
...                                         JOIN STATE st
...                                         ON st.STATE_SKEY = t.TO_STATE
...                                         WHERE ear.OWNER_ID = '{OWNER_ID}'
...                                         AND ear.ACTION_SKEY IN (
...                                         SELECT a.ACTION_SKEY
...                                         FROM ACTION a
...                                         WHERE a.ACTION_ID IN ('HM_WORKLOAD_DISTRIBUTION', 'EDIT_FC')
...                                         )
...                                         AND sf.STATE_ID IN (
...                                         SELECT DISTINCT se.STATE_ID
...                                         FROM PROCESS p
...                                         JOIN STATE se
...                                         ON p.START_STATE = se.STATE_SKEY
...                                         )
...                                         AND st.STATE_ID = 'REVIEW_WD'


*** Keywords ***
Verify Auto Publish Schedule Job Has Expected Queue Status In Database
    [Documentation]    Retrieves the queue status for the auto publish schedule job from the database.
    ...    | =Returns= | =Description= |
    ...    | is_auto_publish_applicable | Indicates whether the auto publish schedule job is in the expected queue status |
    ${owner_id}    Get Config Value    OWNER_ID
    ${db_query}    Replace String    ${WEEK_SCHEDULE_QUEUE_STATUS_AUTO_PUBLISH_JOB}    {OWNER_ID}    ${owner_id}
    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}
    ${first_row}    Get From List    ${result}    0
    ${queue_status}    Get From List    ${first_row}    0
    ${is_auto_publish_applicable}    Run Keyword And Return Status    Should Be Equal    ${queue_status}    R
    ...    msg=Expected queue status 'R' for Auto Publish Schedule Job, but found '${queue_status}'.
    RETURN    ${is_auto_publish_applicable}

Verify Week Plan And Schedule Generation Status In Database
    [Documentation]    Retrieves the generation status for the week plan and schedule from the database.
    ...    | =Returns= | =Description= |
    ...    | is_week_plan_schedule_gen_applicable | Indicates whether the week plan and schedule generation is applicable or not |
    ${owner_id}    Get Config Value    OWNER_ID
    ${task_count_db_query}    Replace String    ${WEEK_SCHEDULE_TASK_COUNT_QUERY}    {OWNER_ID}    ${owner_id}
    ${metric_count_db_query}    Replace String    ${WEEK_SCHEDULE_METRIC_COUNT_QUERY}    {OWNER_ID}    ${owner_id}
    ${gen_shift_count_db_query}    Replace String    ${WEEK_SCHEDULE_GEN_SHIFT_COUNT_QUERY}    {OWNER_ID}    ${owner_id}

    Log    Executing database query: ${task_count_db_query}
    ${task_count_db_query_result}    Execute Query And Return Result    ${task_count_db_query}
    Log    Database query result: ${task_count_db_query_result}

    Log    Executing database query: ${metric_count_db_query}
    ${metric_count_db_query_result}    Execute Query And Return Result    ${metric_count_db_query}
    Log    Database query result: ${metric_count_db_query_result}

    Log    Executing database query: ${gen_shift_count_db_query}
    ${gen_shift_count_db_query_result}    Execute Query And Return Result    ${gen_shift_count_db_query}
    Log    Database query result: ${gen_shift_count_db_query_result}

    VAR    ${task_count}    ${task_count_db_query_result}[0][0]
    VAR    ${metric_count}    ${metric_count_db_query_result}[0][0]
    VAR    ${gen_shift_count}    ${gen_shift_count_db_query_result}[0][0]

    ${is_week_plan_schedule_gen_applicable}    Run Keyword And Return Status    Should Be True
    ...    ${task_count} > 0 and ${metric_count} > 0 and ${gen_shift_count} > 0

    RETURN    ${is_week_plan_schedule_gen_applicable}

Get Alert Status And Severity From Database
    [Documentation]    Retrieves the status and severity for a given alert parameter ID from the database.
    ...
    ...    This keyword queries the RWS_SCH_MPARAMS table and returns the alert configuration
    ...    specifically for severe alerts (CONSTRAINT_TYPE = 'S'). If no configuration is found,
    ...    it returns default values indicating the alert is not configured as severe.
    ...
    ...    | =Arguments= | =Description= |
    ...    | param_id | Alert parameter ID to check (e.g., 'E0005') |
    ...
    ...    | =Returns= | =Description= |
    ...    | constraint_type | Alert constraint type ('S' for severe, 'N' if not found) |
    ...    | status | Alert status ('A' for active, 'I' if not found) |
    ...
    ...    Example usage:
    ...    | ${constraint_type}    ${status}=    Get Alert Status And Severity From Database    E0005 |
    [Arguments]    ${param_id}
    ${owner_id}    Get Config Value    OWNER_ID
    ${db_query}    Replace String    ${ALERT_STATUS_SEVERITY_QUERY}    {PARAM_ID}    ${param_id}
    ${db_query}    Replace String    ${db_query}    {OWNER_ID}    ${owner_id}
    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}

    # Check if severe alert configuration exists
    ${result_count}    Get Length    ${result}
    IF    not ${result_count}
        Log
        ...    No severe alert configuration found for parameter ID '${param_id}' and owner ID '${owner_id}' (constraint_type='S'). Returning default values.
        RETURN    N    I
    END

    ${first_row}    Get From List    ${result}    0
    ${constraint_type}    Get From List    ${first_row}    0
    ${status}    Get From List    ${first_row}    1

    Log    Retrieved alert configuration: Parameter ID '${param_id}' has constraint type '${constraint_type}' and status '${status}'
    RETURN    ${constraint_type}    ${status}

Get Scheduling Engine For Store From Database
    [Documentation]    Retrieves the scheduling engine applicable for a given store from the database.
    ...
    ...    This keyword determines whether Core scheduling or Rule scheduling is applied to a store
    ...    by querying the RWS_SCH_MAPPLIES table along with related mapping tables.
    ...
    ...    | =Arguments= | =Description= |
    ...    | store_id | Store unit ID to check (e.g., 'STORE2') |
    ...
    ...    | =Returns= | =Description= |
    ...    | engine_name | Name of the scheduling engine for the store |
    ...
    ...    Example usage:
    ...    | ${engine_name}=    Get Scheduling Engine For Store From Database    STORE2 |
    [Arguments]    ${store_id}
    ${owner_id}    Get Config Value    OWNER_ID
    ${current_date}    Get Current Date    result_format=%Y%m%d

    ${db_query}    Replace String    ${SCHEDULING_ENGINE_QUERY}    {STORE_ID}    ${store_id}
    ${db_query}    Replace String    ${db_query}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {CURRENT_DATE}    ${current_date}

    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}

    Should Not Be Empty    ${result}
    ...    msg=No scheduling engine configuration found for store '${store_id}' and owner ID '${owner_id}'

    ${first_row}    Get From List    ${result}    0
    ${engine_name}    Get From List    ${first_row}    0

    Log    Retrieved scheduling engine: Store '${store_id}' uses '${engine_name}' engine
    RETURN    ${engine_name}

Check If Schedule Is Editable In Published State Via DB
    [Documentation]    Checks if schedule is editable in published state by querying EVENT table for EDIT_SC event (PC00098).
    ...    This query checks if the EDIT_SC event is configured for the owner, which allows editing shifts
    ...    even when the schedule is in published state (FROM_STATE = 5).
    ...    | =Returns= | =Description= |
    ...    | is_editable | Boolean indicating whether schedule editing is allowed in published state |
    ...    Example usage:
    ...    | ${is_editable}= | Check If Schedule Is Editable In Published State Via DB |
    ...    | IF | ${is_editable} |
    ...    | | Log | Schedule is editable in published state (EDIT_SC event found) |
    ...    | ELSE |
    ...    | | Log | Schedule is NOT editable in published state (EDIT_SC event not found) |
    ...    | END |
    ${owner_id}    Get Config Value    OWNER_ID
    ${db_query}    Replace String    ${CHECK_EDIT_PUBLISHED_SCHEDULE_EVENT_QUERY}    {OWNER_ID}    ${owner_id}
    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}

    # Check if query returned any results
    ${has_results}    Run Keyword And Return Status    Should Not Be Empty    ${result}
    IF    not ${has_results}
        Log    No events found - schedule is NOT editable in published state    level=INFO
        RETURN    ${False}
    END

    # Check if EDIT_SC event exists in results
    VAR    ${is_editable}    ${False}
    FOR    ${row}    IN    @{result}
        ${event_id}    Get From List    ${row}    0
        IF    '${event_id}' == 'EDIT_SC'
            Log    EDIT_SC event found - schedule IS editable in published state    level=INFO
            VAR    ${is_editable}    ${True}
            BREAK
        END
    END

    IF    not ${is_editable}
        Log    EDIT_SC event not found - schedule is NOT editable in published state    level=INFO
    END

    RETURN    ${is_editable}

Get Shift Policies From Database
    [Documentation]    Retrieves all shift policies including minimum shift length configurations from the database.
    ...
    ...    This keyword queries the RWS_SHIFT_BREAK_TMPL, RWS_SHIFT_BREAK_APPLIES_TO, and RWS_NSHIFT_BREAK tables
    ...    to get comprehensive shift policy information including allowed shift lengths.
    ...
    ...    | =Returns= | =Description= |
    ...    | shift_policies | List of shift policy records with all details including SHIFT_TIME |
    ...
    ...    Example usage:
    ...    | ${shift_policies}=    Get Shift Policies From Database |
    ...    | FOR    ${policy}    IN    @{shift_policies} |
    ...    | |    Log    Shift ID: ${policy}[1], Shift Time: ${policy}[15] |
    ...    | END |
    ${owner_id}    Get Config Value    OWNER_ID
    ${db_query}    Replace String    ${SHIFT_POLICY_QUERY}    {OWNER_ID}    ${owner_id}

    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}

    Log    Retrieved ${result.__len__()} shift policy records for owner ID '${owner_id}'
    RETURN    ${result}

Check Shift Minimum Length Alert Status From Database
    [Documentation]    Checks if the "Shift Alert: Daily: Shift Minimum Length not met" alert is enabled.
    ...
    ...    This keyword queries the RWS_SCH_MPARAMS table for parameter ID 'S0001' to determine
    ...    if the shift minimum length alert is active.
    ...
    ...    | =Returns= | =Description= |
    ...    | is_alert_enabled | Boolean indicating whether the shift minimum length alert is enabled |
    ...    | alert_details | Full alert configuration record if found |
    ...
    ...    Example usage:
    ...    | ${is_enabled}    ${details}=    Check Shift Minimum Length Alert Status From Database |
    ...    | IF    ${is_enabled} |
    ...    | |    Log    Shift minimum length alert is enabled |
    ...    | END |
    ${owner_id}    Get Config Value    OWNER_ID
    ${db_query}    Replace String    ${SHIFT_MIN_LENGTH_ALERT_QUERY}    {OWNER_ID}    ${owner_id}

    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}

    # Check if alert configuration exists
    ${result_count}    Get Length    ${result}
    IF    not ${result_count}
        Log    No shift minimum length alert configuration found for parameter ID 'S0001' and owner ID '${owner_id}'
        RETURN    ${False}    ${EMPTY}
    END

    ${first_row}    Get From List    ${result}    0
    # Assuming STATUS is in a specific column position - adjust index as needed based on actual table structure
    ${is_alert_enabled}    Run Keyword And Return Status    Should Contain    ${first_row}    A

    Log    Shift minimum length alert (S0001) status: ${is_alert_enabled} for owner ID '${owner_id}'
    RETURN    ${is_alert_enabled}    ${first_row}

Check Employee Max Weekly Hours Alert Status From Database
    [Documentation]    Checks if the "HR Alert: Employee Maximum hours per week exceeded" alert is enabled.
    ...
    ...    This keyword queries the RWS_SCH_MPARAMS table for parameter ID 'E0012' to determine
    ...    if the employee maximum weekly hours alert is active.
    ...
    ...    | =Returns= | =Description= |
    ...    | is_alert_enabled | Boolean indicating whether the employee max weekly hours alert is enabled |
    ...    | alert_details | Full alert configuration record if found |
    ...
    ...    Example usage:
    ...    | ${is_enabled}    ${details}=    Check Employee Max Weekly Hours Alert Status From Database |
    ...    | IF    ${is_enabled} |
    ...    | |    Log    Employee max weekly hours alert is enabled |
    ...    | END |
    ${owner_id}    Get Config Value    OWNER_ID
    ${db_query}    Replace String    ${EMPLOYEE_MAX_WEEKLY_HOURS_ALERT_QUERY}    {OWNER_ID}    ${owner_id}

    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}

    # Check if alert configuration exists
    ${result_count}    Get Length    ${result}
    IF    not ${result_count}
        Log    No employee max weekly hours alert configuration found for parameter ID 'E0012' and owner ID '${owner_id}'
        RETURN    ${False}    ${EMPTY}
    END

    ${first_row}    Get From List    ${result}    0
    # Assuming STATUS is in a specific column position - adjust index as needed based on actual table structure
    ${is_alert_enabled}    Run Keyword And Return Status    Should Contain    ${first_row}    A

    Log    Employee max weekly hours alert (E0012) status: ${is_alert_enabled} for owner ID '${owner_id}'
    RETURN    ${is_alert_enabled}    ${first_row}

Get Scheduling Rules For Associate From Database
    [Documentation]    Comprehensive keyword to retrieve all scheduling rules for a given associate (PC00095).
    ...
    ...    This keyword combines multiple database queries to get:
    ...    - Minimum shift length as per shift policy
    ...    - Shift minimum length alert status
    ...    - Employee maximum weekly hours alert status
    ...
    ...    | =Returns= | =Description= |
    ...    | shift_policies | List of applicable shift policies with allowed shift lengths |
    ...    | min_length_alert_enabled | Boolean for shift minimum length alert status |
    ...    | max_hours_alert_enabled | Boolean for employee max weekly hours alert status |
    ...
    ...    Example usage:
    ...    | ${policies}    ${min_alert}    ${max_alert}=    Get Scheduling Rules For Associate From Database |
    ...    | Log    Found ${policies.__len__()} shift policies, Min length alert: ${min_alert}, Max hours alert: ${max_alert} |

    # Get shift policies
    ${shift_policies}    Get Shift Policies From Database

    # Check alert statuses
    ${min_length_alert_enabled}    ${_}    Check Shift Minimum Length Alert Status From Database
    ${max_hours_alert_enabled}    ${_}    Check Employee Max Weekly Hours Alert Status From Database

    Log
    ...    Scheduling rules summary: ${shift_policies.__len__()} policies, Min alert: ${min_length_alert_enabled}, Max alert: ${max_hours_alert_enabled}

    RETURN    ${shift_policies}    ${min_length_alert_enabled}    ${max_hours_alert_enabled}

Get Week Plan State For Unit And Week From Database
    [Documentation]    Retrieves the current week plan state for a given unit and week date from UNIT_PROCESS_STATUS_FACT.
    ...
    ...    Returns STATE_SKEY as an integer. Returns 0 if no record exists (week not yet initialized).
    ...    Use STATE_SKEY >= 5 to check if schedule is in published state or beyond.
    ...
    ...    | STATE_SKEY | STATE_ID    | Meaning    |
    ...    | 0    | (none)    | No record - week not yet initialized    |
    ...    | 2    | REVIEW_FC    | Forecast initialized    |
    ...    | 3    | REVIEW_WD    | Workload generated    |
    ...    | 4    | REVIEW_SC    | Schedule generated (not published)    |
    ...    | 5    | SC_PUB    | Schedule published    |
    ...    | 6    | SC_STALE    | Stale schedule    |
    ...    | 7    | PUB_SC_STALE    | Stale published schedule    |
    ...    | 10    | WD_STALE_SC_PUB | Workload stale / schedule published    |
    ...
    ...    | =Arguments= | =Description= |
    ...    | unit_id    | Unit ID to check (e.g., 'ZAUTOSTORE001') |
    ...    | week_date | Week start date in DATE_FORMAT_MONTH_DAY_YEAR config format (e.g., '05/03/2026') |
    ...
    ...    | =Returns= | =Description= |
    ...    | state_skey | Integer STATE_SKEY (0 if not found) |
    ...
    ...    Example usage:
    ...    | ${state}=    Get Week Plan State For Unit And Week From Database    ZAUTOSTORE001    05/03/2026 |
    ...    | IF    ${state} >= 5 |
    ...    | |    Skip    Schedule already published for this week |
    ...    | END |
    [Arguments]    ${unit_id}    ${week_date}
    ${owner_id}    Get Config Value    OWNER_ID
    ${source_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${date_skey}    Convert Date    ${week_date}    result_format=%Y%m%d    date_format=${source_date_format}
    ${db_query}    Replace String    ${UNIT_PROCESS_STATUS_QUERY}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {UNIT_ID}    ${unit_id}
    ${db_query}    Replace String    ${db_query}    {DATE_SKEY}    ${date_skey}
    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}
    ${result_count}    Get Length    ${result}
    IF    not ${result_count}
        Log
        ...    No week plan record found for unit '${unit_id}' and date '${week_date}' (DATE_SKEY=${date_skey}). Returning no records. Initialize forecast is not applicable.
        RETURN    ${0}
    END
    ${first_row}    Get From List    ${result}    0
    ${state_skey}    Get From List    ${first_row}    0
    ${state_skey}    Convert To Integer    ${state_skey}
    Log    Week plan state for unit '${unit_id}' week '${week_date}': STATE_SKEY=${state_skey}
    RETURN    ${state_skey}

Get Dual Scheduling Flow Constraint Type From Database
    [Documentation]    Retrieves the CONSTRAINT_TYPE for the DUAL_SCHEDULING_FLOW parameter from the RWS_SCH_MPARAMS table.
    ...    Returns the constraint type value, or an empty string if no record is found.
    ...
    ...    | =Returns= | =Description= |
    ...    | constraint_type | CONSTRAINT_TYPE value (e.g., 'S') or empty string if not configured |
    ...
    ...    Example usage:
    ...    | ${constraint_type}=    Get Dual Scheduling Flow Constraint Type From Database |
    ...    | IF    '${constraint_type}' == 'S' |
    ...    | |    Skip    Dual scheduling flow is set to Strict (CONSTRAINT_TYPE=S). Skipping test. |
    ...    | END |
    ${owner_id}    Get Config Value    OWNER_ID
    ${db_query}    Replace String    ${DUAL_SCHEDULING_FLOW_CONSTRAINT_QUERY}    {OWNER_ID}    ${owner_id}
    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}
    ${result_count}    Get Length    ${result}
    IF    not ${result_count}
        Log    No DUAL_SCHEDULING_FLOW configuration found for owner ID '${owner_id}'. Returning empty string.
        RETURN    ${EMPTY}
    END
    ${first_row}    Get From List    ${result}    0
    ${constraint_type}    Get From List    ${first_row}    0
    Log    DUAL_SCHEDULING_FLOW CONSTRAINT_TYPE for owner ID '${owner_id}': ${constraint_type}
    RETURN    ${constraint_type}

Get Minimum And Maximum Shift Length In Hours For Associate From Database
    [Documentation]    Retrieves minimum and maximum shift length (in hours) for a specific associate from the database.
    ...
    ...    | =Arguments= | =Description= |
    ...    | person_id | Associate person ID used to fetch applicable shift length limits |
    ...    | week_start_date | Optional week start date (in YYYY-MM-DD format) to determine effective shift length limits for that week.
    ...    If not provided, current date is used. |
    ...    | =Returns= | =Description= |
    ...    | min_shift_length | Minimum allowed shift length in hours |
    ...    | max_shift_length | Maximum allowed shift length in hours |
    ...    Example usage:
    ...    | ${min_shift_length}    ${max_shift_length}=    Get Minimum And Maximum Shift Length In Hours For Associate From Database    1052    2026-04-13 |
    [Arguments]    ${person_id}    ${week_start_date}
    ${owner_id}    Get Config Value    OWNER_ID
    ${date_format}    Get Config Value    SERVER_DF
    # Calculate week end date from week start
    ${week_end_date}    Add Time To Date    ${week_start_date}    6 days    result_format=${date_format}
    # Convert dates to YYYYMMDD integer format expected by DB2
    ${eff_date_skey}    Convert Date    ${week_start_date}    result_format=${date_format}
    ${end_date_skey}    Convert Date    ${week_end_date}    result_format=${date_format}
    ${db_query}    Replace String    ${EMPLOYEE_SHIFT_LENGTH_QUERY}    {PERSON_ID}    ${person_id}
    ${db_query}    Replace String    ${db_query}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {EFF_DATE_SKEY}    ${eff_date_skey}
    ${db_query}    Replace String    ${db_query}    {END_DATE_SKEY}    ${end_date_skey}
    ${result}    Execute Query And Return Result    ${db_query}
    VAR    ${min_shift_length}    ${result}[0][0]
    VAR    ${max_shift_length}    ${result}[0][1]
    RETURN    ${min_shift_length}    ${max_shift_length}

Get Shift Alert Status Of Daily Minimum Shift Length Not Met Alert From Database
    [Documentation]    Retrieves status of daily minimum shift length alert (S0001) for a specific associate.
    ...
    ...    | =Arguments= | =Description= |
    ...    | person_id | Associate person ID used to check alert status |
    ...
    ...    | =Returns= | =Description= |
    ...    | alert_status | Alert status code returned from database (for example, 'A', 'I', or 'H') |
    ...
    ...    Example usage:
    ...    | ${alert_status}=    Get Shift Alert Status Of Daily Minimum Shift Length Not Met Alert From Database    1052 |
    [Arguments]    ${person_id}
    VAR    ${alert_id}    S0001
    ${owner_id}    Get Config Value    OWNER_ID
    ${date_format}    Get Config Value    SERVER_DF
    ${current_date}    Get Current Date    result_format=${date_format}
    ${db_query}    Replace String    ${ALERT_MESSAGE_STATUS_QUERY}    {PERSON_ID}    ${person_id}
    ${db_query}    Replace String    ${db_query}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {DATE_SKEY}    ${current_date}
    ${db_query}    Replace String    ${db_query}    {ALERT_ID}    ${alert_id}
    ${result}    Execute Query And Return Result    ${db_query}
    ${result_count}    Get Length    ${result}
    IF    ${result_count} > 0
        RETURN    ${result}[0][0]
    ELSE
        Skip
        ...    No alert status found for Daily Minimum Shift Length Not Met Alert (S0001) for person ID ${person_id}. Alert may not be configured.
    END

Get HR Alert Status Of Employee Maximum Weekly Hours Exceeded Alert From Database
    [Documentation]    Retrieves status of employee maximum weekly hours exceeded alert (E0012) for a specific associate.
    ...
    ...    | =Arguments= | =Description= |
    ...    | person_id | Associate person ID used to check alert status |
    ...
    ...    | =Returns= | =Description= |
    ...    | alert_status | Alert status code returned from database (for example, 'A', 'I', or 'H') |
    ...
    ...    Example usage:
    ...    | ${alert_status}=    Get HR Alert Status Of Employee Maximum Weekly Hours Exceeded Alert From Database    1052 |
    [Arguments]    ${person_id}
    VAR    ${alert_id}    E0012
    ${owner_id}    Get Config Value    OWNER_ID
    ${date_format}    Get Config Value    SERVER_DF
    ${current_date}    Get Current Date    result_format=${date_format}
    ${db_query}    Replace String    ${ALERT_MESSAGE_STATUS_QUERY}    {PERSON_ID}    ${person_id}
    ${db_query}    Replace String    ${db_query}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {DATE_SKEY}    ${current_date}
    ${db_query}    Replace String    ${db_query}    {ALERT_ID}    ${alert_id}
    ${result}    Execute Query And Return Result    ${db_query}
    ${result_count}    Get Length    ${result}
    IF    ${result_count} > 0
        RETURN    ${result}[0][0]
    ELSE
        Skip
        ...    No alert status found for Employee Maximum Weekly Hours Exceeded Alert (E0012) for person ID ${person_id}. Alert may not be configured.
    END

Get Scheduling Net Rules For Employee From Database
    [Documentation]    Retrieves scheduling net rule records for a specific associate and rule ID from the database.
    ...
    ...    | =Arguments= | =Description= |
    ...    | person_id | Associate person ID used to filter scheduling net rules |
    ...    | rule_id | Rule identifier to query (for example, 'MIN_SHIFT_LENGTH' or 'MAX_SHIFT_LENGTH') |
    ...
    ...    | =Returns= | =Description= |
    ...    | result | List of matching scheduling net rule records |
    ...
    ...    Example usage:
    ...    | ${rules}=    Get Scheduling Net Rules For Employee From Database    1052    MIN_SHIFT_LENGTH |
    [Arguments]    ${person_id}    ${rule_id}
    ${owner_id}    Get Config Value    OWNER_ID
    ${date_format}    Get Config Value    SERVER_DF
    ${current_date}    Get Current Date    result_format=${date_format}
    ${db_query}    Replace String    ${EMPLOYEE_NET_RULES_QUERY}    {PERSON_ID}    ${person_id}
    ${db_query}    Replace String    ${db_query}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {DATE_SKEY}    ${current_date}
    ${db_query}    Replace String    ${db_query}    {RULE_ID}    ${rule_id}
    ${result}    Execute Query And Return Result    ${db_query}
    RETURN    ${result}

Check Applicability For Shift Alert Validation On Week Schedule Page On Web
    [Documentation]    Determines whether shift alert validation is applicable for an associate on the Week Schedule page.
    ...
    ...    This keyword validates applicability by checking shift length boundaries,
    ...    required alert statuses, and presence of scheduling net rules.
    ...    If criteria are not met, execution is skipped with a descriptive message.
    ...
    ...    | =Arguments= | =Description= |
    ...    | emp_user_data | Employee user data dictionary containing personId |
    ...    | week_start_date | Week start date in YYYY-MM-DD format used to determine effective shift length limits |
    ...    Example usage:
    ...    | Check Applicability For Shift Alert Validation On Week Schedule Page On Web    ${emp_user_data}    ${week_start_date} |
    [Arguments]    ${emp_user_data}    ${week_start_date}
    ${person_ID}    Get From Dictionary    ${emp_user_data}    personId
    ${min_shift_length}    ${max_shift_length}
    ...    Get Minimum And Maximum Shift Length In Hours For Associate From Database    ${person_ID}    ${week_start_date}
    ${daily_min_shift_length_alert}
    ...    Get Shift Alert Status Of Daily Minimum Shift Length Not Met Alert From Database    ${person_ID}
    ${employee_max_weekly_hours_alert}
    ...    Get HR Alert Status Of Employee Maximum Weekly Hours Exceeded Alert From Database    ${person_ID}
    ${min_shift_length_net_rule}
    ...    Get Scheduling Net Rules For Employee From Database    ${person_ID}    MIN_SHIFT_LENGTH
    ${max_shift_length_net_rule}
    ...    Get Scheduling Net Rules For Employee From Database    ${person_ID}    MAX_SHIFT_LENGTH
    ${is_expected_shift_length}    Evaluate
    ...    ${min_shift_length} != None and ${max_shift_length} != None and ${min_shift_length} >= 1 and ${max_shift_length} <= 22
    ${is_alerts_active}    Evaluate    '${daily_min_shift_length_alert}' == 'A' and '${employee_max_weekly_hours_alert}' == 'A'
    ${is_net_rules_applicable}    Evaluate    len(${min_shift_length_net_rule}) > 0 and len(${max_shift_length_net_rule}) > 0
    ${is_applicable}    Evaluate    ${is_expected_shift_length} and ${is_alerts_active} and ${is_net_rules_applicable}
    Skip If    not ${is_applicable}
    ...    Shift alert validation is not applicable for employee with person ID ${person_ID} due to shift length, alert status, or net rule conditions not being met.

Get Max Weekly Working Hours For Associate From Database
    [Documentation]    Retrieves the maximum weekly working hours for a specific associate from the RWS_EMP_STATUS table (PC00094).
    ...
    ...    Queries for the employee status record effective during the specified date range and extracts MAX_NORMAL_HOURS.
    ...    Returns None if no active record is found for the given person during the date range.
    ...
    ...    | =Arguments= | =Description= |
    ...    | person_id | Associate person ID to check |
    ...    | week_start_date | Week start date in YYYY-MM-DD format (REQUIRED) |
    ...
    ...    | =Returns= | =Description= |
    ...    | max_weekly_hours | Maximum normal weekly working hours, or None if not configured |
    ...
    ...    Example usage:
    ...    | ${max_weekly_hours}=    Get Max Weekly Working Hours For Associate From Database    1052    2026-04-13 |
    [Arguments]    ${person_id}    ${week_start_date}
    ${owner_id}    Get Config Value    OWNER_ID
    # Calculate week end date from week start
    ${date_format}    Get Config Value    SERVER_DF
    ${week_end_date}    Add Time To Date    ${week_start_date}    6 days    result_format=${date_format}
    # Convert dates to YYYYMMDD format expected by DB2
    ${eff_date_skey}    Convert Date    ${week_start_date}    result_format=${date_format}
    ${end_date_skey}    Convert Date    ${week_end_date}    result_format=${date_format}
    ${db_query}    Replace String    ${EMPLOYEE_WORK_RULES_QUERY}    {PERSON_ID}    ${person_id}
    ${db_query}    Replace String    ${db_query}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {EFF_DATE_SKEY}    ${eff_date_skey}
    ${db_query}    Replace String    ${db_query}    {END_DATE_SKEY}    ${end_date_skey}
    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}
    ${result_count}    Get Length    ${result}
    IF    not ${result_count}
        Log
        ...    No effective employee status record found for person ID '${person_id}' and owner ID '${owner_id}' for date range ${week_start_date} to ${week_end_date}. MAX_NORMAL_HOURS not configured.
        RETURN    ${None}
    END
    ${first_row}    Get From List    ${result}    0
    ${max_weekly_hours}    Get From List    ${first_row}    0
    Log    MAX_NORMAL_HOURS for person ID '${person_id}' (${week_start_date} to ${week_end_date}): ${max_weekly_hours}
    RETURN    ${max_weekly_hours}

Check Applicability For Alerts Report Validation On Week Schedule Page On Web
    [Documentation]    Determines whether alerts report validation is applicable for an associate on the Week Schedule page.
    ...
    ...    This keyword validates the BATTC00212 applicability criteria by checking:
    ...    - Max weekly working hours is configured and == 50 for the associate (PC00094)
    ...    - Minimum shift length from shift policy is == 1 hr (PC00095)
    ...    - Shift minimum length alert (S0001) is active for the associate (PC00095)
    ...    - Employee max weekly hours alert (E0012) is active for the associate (PC00095)
    ...
    ...    If any criteria are not met, execution is skipped with a descriptive message.
    ...
    ...    Note: RWS license (PC00001) is validated via the config:rws tag.
    ...    Note: Week plan and schedule generation (PC00127) is validated via the config:weekplan_and_schedule_gen tag.
    ...
    ...    | =Arguments= | =Description= |
    ...    | emp_user_data | Employee user data dictionary containing personId |
    ...    | week_start_date | Week start date in YYYY-MM-DD format (REQUIRED) |
    ...
    ...    Example usage:
    ...    | Check Applicability For Alerts Report Validation On Week Schedule Page On Web    ${ess_user}    2026-04-13 |
    [Arguments]    ${emp_user_data}    ${week_start_date}
    ${person_id}    Get From Dictionary    ${emp_user_data}    personId

    # PC00094: Max weekly working hours must be configured and == 50
    ${max_weekly_hours}    Get Max Weekly Working Hours For Associate From Database    ${person_id}    ${week_start_date}
    # PC00095: Minimum shift length from shift policy must be == 1 hr
    ${min_shift_length}    ${_}    Get Minimum And Maximum Shift Length In Hours For Associate From Database    ${person_id}
    ...    ${week_start_date}
    # PC00095: Shift minimum length alert (S0001) must be active for this associate
    ${shift_min_alert_status}    Get Shift Alert Status Of Daily Minimum Shift Length Not Met Alert From Database    ${person_id}
    # PC00095: Employee max weekly hours alert (E0012) must be active for this associate
    ${max_hours_alert_status}    Get HR Alert Status Of Employee Maximum Weekly Hours Exceeded Alert From Database    ${person_id}
    # Evaluate all applicability conditions
    # BATTC00212 requires: max weekly working hours == 50hrs, min shift length == 1hr,
    # and both alerts active (E0012 and S0001)
    ${is_max_weekly_hours_configured}    Evaluate    ${max_weekly_hours} != None and ${max_weekly_hours} == 50
    ${is_min_shift_length_valid}    Evaluate    ${min_shift_length} != None and ${min_shift_length} == 1
    ${is_alerts_active}    Evaluate    '${shift_min_alert_status}' == 'A' and '${max_hours_alert_status}' == 'A'
    ${is_applicable}    Evaluate    ${is_max_weekly_hours_configured} and ${is_min_shift_length_valid} and ${is_alerts_active}
    Skip If    not ${is_applicable}
    ...    Alerts report validation is not applicable for employee with person ID ${person_id}: expected max_weekly_hours=50 (got ${max_weekly_hours}), expected min_shift_length=1hr (got ${min_shift_length}), shift_min_alert=${shift_min_alert_status}, max_hours_alert=${max_hours_alert_status}.

Check Applicability For Employee Max Weekly Hours Alert Validation On Week Schedule Page On Web
    [Documentation]    Determines whether employee max weekly hours alert validation is applicable for an associate on the Week Schedule page.
    ...
    ...    This keyword validates the BATTC00206 applicability criteria by checking:
    ...    - Max weekly working hours is configured and > 0 for the associate (PC00094)
    ...    - Employee max weekly hours alert (E0012) is active for the associate (PC00095)
    ...    - MAX_WKLY_HRS and MAX_WKLY_DAYS scheduling net rules are defined for the associate (PC00096)
    ...
    ...    PC00096 determines whether the associate's shifts can be added while violating max weekly
    ...    hours/days. Net rules must be defined for the employee so the system recognises the
    ...    violations and the employee alert fires correctly.
    ...
    ...    If any criteria are not met, execution is skipped with a descriptive message.
    ...
    ...    Note: RWS license (PC00001) is validated via the config:rws tag.
    ...    Note: Week plan and schedule generation (PC00127) is validated via the config:weekplan_and_schedule_gen tag.
    ...
    ...    | =Arguments= | =Description= |
    ...    | emp_user_data | Employee user data dictionary containing personId |
    ...    | week_start_date | Week start date in YYYY-MM-DD format to check employee status |
    ...
    ...    Example usage:
    ...    | Check Applicability For Employee Max Weekly Hours Alert Validation On Week Schedule Page On Web    ${ess_user}    2026-04-21 |
    [Arguments]    ${emp_user_data}    ${week_start_date}
    ${person_id}    Get From Dictionary    ${emp_user_data}    personId
    # PC00094: Max weekly working hours must be configured and > 0
    ${max_weekly_hours}    Get Max Weekly Working Hours For Associate From Database    ${person_id}    ${week_start_date}
    # PC00095: Employee max weekly hours alert (E0012) must be active for this associate
    ${max_hours_alert_status}    Get HR Alert Status Of Employee Maximum Weekly Hours Exceeded Alert From Database    ${person_id}
    # PC00096: MAX_WKLY_HRS and MAX_WKLY_DAYS net rules must be defined so the system enforces
    # the weekly limits and the employee alert fires when shifts violate those constraints
    ${max_wkly_hrs_net_rule}
    ...    Get Scheduling Net Rules For Employee From Database    ${person_id}    MAX_WKLY_HRS
    ${max_wkly_days_net_rule}
    ...    Get Scheduling Net Rules For Employee From Database    ${person_id}    MAX_WKLY_DAYS
    # Evaluate all applicability conditions
    ${is_max_weekly_hours_configured}    Evaluate    ${max_weekly_hours} != None and ${max_weekly_hours} > 0
    ${is_alert_active}    Evaluate    '${max_hours_alert_status}' == 'A'
    ${is_net_rules_applicable}    Evaluate    len(${max_wkly_hrs_net_rule}) > 0 and len(${max_wkly_days_net_rule}) > 0
    ${is_applicable}    Evaluate    ${is_max_weekly_hours_configured} and ${is_alert_active} and ${is_net_rules_applicable}
    Skip If    not ${is_applicable}
    ...    Employee max weekly hours alert validation is not applicable for employee with person ID ${person_id}: max_weekly_hours=${max_weekly_hours}, max_hours_alert=${max_hours_alert_status}, max_wkly_hrs_rule_count=${max_wkly_hrs_net_rule.__len__()}, max_wkly_days_rule_count=${max_wkly_days_net_rule.__len__()}.

Get Generate Workload Config Flag Status From Database
    [Documentation]    Retrieves Generate workload config flag status 1 or 0, so it can be used to determine if a specific workload configuration is enabled or disabled for the given environment.

    ${owner_id}    Get Config Value    OWNER_ID
    ${db_query}    Replace String    ${GENERATE_WORKLOAD_CONFIG_FLAG_QUERY}    {OWNER_ID}    ${owner_id}
    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    ${result_count}    Get Length    ${result}
    IF    ${result_count} > 0
        RETURN    ${result}[0][0]
    ELSE
        Skip
        ...    No Generate workload config flag status found for owner ID ${owner_id}. Configuration may not be set.
    END

Get VDI Based Workload Regeneration Status For Store From Database
    [Documentation]    Checks whether VDI-based workload regeneration is enabled for a specific store from DB.
    ...    The query evaluates both unit-level (DOMAIN_TYPE='U') and distribution-level (DOMAIN_TYPE='D') process applicability
    ...    for start state `START_STATE_FIXED_WL` and returns `ENABLED` or `NOT ENABLED`.
    ...    | =Arguments= | =Description= |
    ...    | store_id | Store unit ID (for example, ZSITSTORE006). |
    ...    | =Returns= | =Description= |
    ...    | status | `ENABLED` or `NOT ENABLED`. |
    ...    | is_enabled | Boolean derived from status (`True` only when status is `ENABLED`). |
    ...    Example usage:
    ...    | ${status}    ${is_enabled}=    Get VDI Based Workload Regeneration Status For Store From Database    ZSITSTORE006 |
    [Arguments]    ${store_id}
    ${owner_id}    Get Config Value    OWNER_ID
    ${db_query}    Replace String    ${VDI_BASED_WORKLOAD_REGENERATION_STATUS_QUERY}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {UNIT_ID}    ${store_id}
    Log    Executing database query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Database query result: ${result}
    ${result_count}    Get Length    ${result}
    IF    not ${result_count}
        Fail
        ...    VDI-based workload regeneration status query returned no rows for store '${store_id}' and owner ID '${owner_id}'.
    END
    ${first_row}    Get From List    ${result}    0
    ${status}    Get From List    ${first_row}    0
    ${is_enabled}    Run Keyword And Return Status    Should Be Equal    ${status}    ENABLED
    RETURN    ${status}    ${is_enabled}
