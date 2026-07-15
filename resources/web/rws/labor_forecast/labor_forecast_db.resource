*** Settings ***
Documentation       Resource file for labor forecast page related database keywords

Resource            resources/web/common/common.resource
Resource            resources/web/common/database.resource


*** Variables ***
${WORKLOAD_3_STAFF_GROUPS_QUERY}
...                                     SELECT DISTINCT A.TASK_ID, B.NAME, A.DATE_SKEY
...                                     FROM RWS_WORKLOAD_SUMMARY A
...                                     INNER JOIN RWS_TASK B ON A.TASK_ID = B.TASK_ID
...                                     INNER JOIN (
...                                     SELECT S.OWNER_ID, S.DATE_SKEY
...                                     FROM RWS_WORKLOAD_SUMMARY S
...                                     WHERE S.OWNER_ID = '{owner_id}' AND S.UNIT_SKEY = (
...                                     SELECT UNIT_SKEY FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}')
...                                     AND S.ITERATION_TYPE = 5
...                                     AND S.WEEK_IND = (
...                                     SELECT WEEK_IND
...                                     FROM RWS_CALENDAR
...                                     WHERE OWNER_ID = '{owner_id}' AND DATE_SKEY = {check_date} AND CALENDAR_ID = (
...                                     SELECT CALENDAR_ID
...                                     FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}'))
...                                     GROUP BY S.OWNER_ID, S.DATE_SKEY
...                                     HAVING COUNT(DISTINCT S.STAFF_GROUP_ID) >= 3) AS D ON A.OWNER_ID = D.OWNER_ID AND A.DATE_SKEY = D.DATE_SKEY
...                                     WHERE A.OWNER_ID = '{owner_id}' AND A.UNIT_SKEY = (
...                                     SELECT UNIT_SKEY
...                                     FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}')
...                                     AND A.ITERATION_TYPE = 5 AND A.WEEK_IND = (
...                                     SELECT WEEK_IND
...                                     FROM RWS_CALENDAR
...                                     WHERE OWNER_ID = '{owner_id}' AND DATE_SKEY = {check_date} AND CALENDAR_ID = (
...                                     SELECT CALENDAR_ID
...                                     FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}'))
...                                     ORDER BY A.DATE_SKEY

${WORKLOAD_2_STAFF_GROUPS_QUERY}
...                                     SELECT DISTINCT A.TASK_ID, B.NAME
...                                     FROM RWS_WORKLOAD_SUMMARY A
...                                     INNER JOIN RWS_TASK B ON A.TASK_ID = B.TASK_ID
...                                     INNER JOIN (
...                                     SELECT S.OWNER_ID, S.DATE_SKEY
...                                     FROM RWS_WORKLOAD_SUMMARY S
...                                     WHERE S.OWNER_ID = '{owner_id}' AND S.UNIT_SKEY = (
...                                     SELECT UNIT_SKEY FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}')
...                                     AND S.ITERATION_TYPE = 5
...                                     AND S.WEEK_IND = (
...                                     SELECT WEEK_IND
...                                     FROM RWS_CALENDAR
...                                     WHERE OWNER_ID = '{owner_id}' AND DATE_SKEY = {check_date} AND CALENDAR_ID = (
...                                     SELECT CALENDAR_ID
...                                     FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}'))
...                                     GROUP BY S.OWNER_ID, S.DATE_SKEY
...                                     HAVING COUNT(DISTINCT S.STAFF_GROUP_ID) >= 2) AS D ON A.OWNER_ID = D.OWNER_ID AND A.DATE_SKEY = D.DATE_SKEY
...                                     WHERE A.OWNER_ID = '{owner_id}' AND A.UNIT_SKEY = (
...                                     SELECT UNIT_SKEY
...                                     FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}')
...                                     AND A.ITERATION_TYPE = 5 AND A.WEEK_IND = (
...                                     SELECT WEEK_IND
...                                     FROM RWS_CALENDAR
...                                     WHERE OWNER_ID = '{owner_id}' AND DATE_SKEY = {check_date} AND CALENDAR_ID = (
...                                     SELECT CALENDAR_ID
...                                     FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}'))

${WORKLOAD_EXISTS_FOR_UNIT_QUERY}
...                                     SELECT DISTINCT A.TASK_ID, B.NAME, A.DATE_SKEY
...                                     FROM RWS_WORKLOAD_SUMMARY A
...                                     INNER JOIN RWS_TASK B ON A.TASK_ID = B.TASK_ID
...                                     INNER JOIN (
...                                     SELECT S.OWNER_ID, S.DATE_SKEY
...                                     FROM RWS_WORKLOAD_SUMMARY S
...                                     WHERE S.OWNER_ID = '{owner_id}' AND S.UNIT_SKEY = (
...                                     SELECT UNIT_SKEY FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}')
...                                     AND S.ITERATION_TYPE = 5
...                                     AND S.WEEK_IND = (
...                                     SELECT WEEK_IND
...                                     FROM RWS_CALENDAR
...                                     WHERE OWNER_ID = '{owner_id}' AND DATE_SKEY = {check_date} AND CALENDAR_ID = (
...                                     SELECT CALENDAR_ID
...                                     FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}'))
...                                     GROUP BY S.OWNER_ID, S.DATE_SKEY
...                                     HAVING COUNT(DISTINCT S.STAFF_GROUP_ID) >= 1) AS D ON A.OWNER_ID = D.OWNER_ID AND A.DATE_SKEY = D.DATE_SKEY
...                                     WHERE A.OWNER_ID = '{owner_id}' AND A.UNIT_SKEY = (
...                                     SELECT UNIT_SKEY
...                                     FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}')
...                                     AND A.ITERATION_TYPE = 5 AND A.WEEK_IND = (
...                                     SELECT WEEK_IND
...                                     FROM RWS_CALENDAR
...                                     WHERE OWNER_ID = '{owner_id}' AND DATE_SKEY = {check_date} AND CALENDAR_ID = (
...                                     SELECT CALENDAR_ID
...                                     FROM UNIT
...                                     WHERE OWNER_ID = '{owner_id}' AND UNIT_ID = '{unit_id}'))
...                                     ORDER BY A.DATE_SKEY


*** Keywords ***
Check Workload Is Present For Activities For At Least Three Staff Groups From User In DB
    [Documentation]    Validates if workload is present for activities from at least 3 staff groups for a user by checking:
    [Arguments]    ${user_key}
    ${user}    Get User    user_key=${user_key}
    VAR    ${unit_id}    ${user}[unitID]
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${server_date_format}    Get Config Value    key=SERVER_DF
    ${check_date}    Get Current Date    result_format=${server_date_format}
    ${db_query}    Replace String    ${WORKLOAD_3_STAFF_GROUPS_QUERY}    {owner_id}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {unit_id}    ${unit_id}
    ${db_query}    Replace String    ${db_query}    {check_date}    ${check_date}
    ${result}    Execute Query And Return Result    ${db_query}
    ${result_count}    Get Length    ${result}
    ${is_workload_present_for_3_staff_groups}    Evaluate    ${result_count} >= 3
    RETURN    ${is_workload_present_for_3_staff_groups}

Check Workload Is Present For Activities For At Least Two Staff Groups From User In DB
    [Documentation]    Validates if workload is present for activities from at least 2 staff groups for a user by checking:
    [Arguments]    ${user_key}
    ${user}    Get User    user_key=${user_key}
    VAR    ${unit_id}    ${user}[unitID]
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${server_date_format}    Get Config Value    key=SERVER_DF
    ${check_date}    Get Current Date    result_format=${server_date_format}
    ${db_query}    Replace String    ${WORKLOAD_2_STAFF_GROUPS_QUERY}    {owner_id}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {unit_id}    ${unit_id}
    ${db_query}    Replace String    ${db_query}    {check_date}    ${check_date}
    ${result}    Execute Query And Return Result    ${db_query}
    ${result_count}    Get Length    ${result}
    ${is_workload_present_for_2_staff_groups}    Evaluate    ${result_count} >= 2
    RETURN    ${is_workload_present_for_2_staff_groups}

Check Workload Exists For Next Week In DB For Unit ID
    [Documentation]
    ...    Checks whether workload has been generated for the given unit in the next fiscal week (current week + 1).
    ...    Resolves the next week's WEEK_IND by passing today + 7 days as the check_date to WORKLOAD_EXISTS_FOR_UNIT_QUERY.
    ...    Intended as a lightweight pre-condition guard — run this before opening a browser to fail fast
    ...    when no workload exists for the target week, avoiding wasted login and navigation time.
    ...    | =Arguments= | =Description= |
    ...    | unit_id    | Unit ID as configured in the environment (e.g., ZAUTOSTORE001). Maps to UNIT_ID in the UNIT table. |
    ...    | =Returns= | =Description= |
    ...    | ${True}    | When at least one workload row exists for the unit in next fiscal week. |
    ...    | ${False}    | When no workload rows are found for next fiscal week. |
    ...    Example usage:
    ...    | ${is_workload_available}    Check Workload Exists For Next Week In DB For Unit ID    ZAUTOSTORE001
    [Arguments]    ${unit_id}
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${server_date_format}    Get Config Value    key=SERVER_DF
    ${date_fmt_ymd}    Get Config Value    key=DATE_FMT_YEAR_MONTH_DAY
    ${today_iso}    Get Current Date    result_format=${date_fmt_ymd}
    ${check_date}    Add Time To Date    ${today_iso}    7 days    result_format=${server_date_format}    date_format=${date_fmt_ymd}
    ${db_query}    Replace String    ${WORKLOAD_EXISTS_FOR_UNIT_QUERY}    {owner_id}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {unit_id}    ${unit_id}
    ${db_query}    Replace String    ${db_query}    {check_date}    ${check_date}
    Log    Executing workload existence check query for unit: ${unit_id}, next week date skey: ${check_date}: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    ${result_count}    Get Length    ${result}
    ${is_workload_available}    Evaluate    ${result_count} > 0
    RETURN    ${is_workload_available}

Check Workload Exists For Current Week In DB For Unit ID
    [Documentation]
    ...    Checks whether workload has been generated for the given unit in the current fiscal week.
    ...    Intended as a lightweight pre-condition guard — run this before opening a browser to fail fast
    ...    when no workload exists for the current week, avoiding wasted login and navigation time.
    ...    | =Arguments= | =Description= |
    ...    | unit_id    | Unit ID as configured in the environment (e.g., ZAUTOSTORE001). Maps to UNIT_ID in the UNIT table. |
    ...    | =Returns= | =Description= |
    ...    | ${True}    | When at least one workload row exists for the unit in the current fiscal week. |
    ...    | ${False}    | When no workload rows are found for the current fiscal week. |
    ...    Example usage:
    ...    | ${is_workload_available}    Check Workload Exists For Current Week In DB For Unit ID    ZAUTOSTORE001
    [Arguments]    ${unit_id}
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${server_date_format}    Get Config Value    key=SERVER_DF
    ${check_date}    Get Current Date    result_format=${server_date_format}
    ${db_query}    Replace String    ${WORKLOAD_EXISTS_FOR_UNIT_QUERY}    {owner_id}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {unit_id}    ${unit_id}
    ${db_query}    Replace String    ${db_query}    {check_date}    ${check_date}
    Log    Executing workload existence check query for unit: ${unit_id}, current week date skey: ${check_date}: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    ${result_count}    Get Length    ${result}
    ${is_workload_available}    Evaluate    ${result_count} > 0
    RETURN    ${is_workload_available}
