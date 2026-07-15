# Query to check the queue status of the auto publish schedule job in the database for a specific owner ID.
WEEK_SCHEDULE_QUEUE_STATUS_AUTO_PUBLISH_JOB = """
SELECT
    QUEUE_STATUS
FROM
    RWSUSER.RFX_QUEUE
WHERE
    JOB_TYPE = 'AutoPublishSchedule'
    AND OWNER_ID = '{OWNER_ID}'
"""

# Below 3 queries are to determine if week plan and schedule generation are applicable
WEEK_SCHEDULE_TASK_COUNT_QUERY = """
SELECT 
    COUNT(*) 
FROM 
    RWSUSER.RWS_TASK 
WHERE 
    OWNER_ID = '{OWNER_ID}' 
    AND STATUS_CD ='A'
"""

WEEK_SCHEDULE_METRIC_COUNT_QUERY = """
SELECT 
    COUNT(*) 
FROM 
    RWSUSER.RWS_METRIC 
WHERE 
    OWNER_ID = '{OWNER_ID}' 
    AND METRIC_GEN_TYPE = 'F'
"""

WEEK_SCHEDULE_GEN_SHIFT_COUNT_QUERY = """
SELECT 
    COUNT(*) 
FROM 
    RWSUSER.RWS_GEN_SHIFT 
WHERE 
    OWNER_ID = '{OWNER_ID}' 
    AND ITERATION_TYPE = 5
"""

# Query to check if EDIT_SC (Edit Schedule) event is enabled for the owner (PC00098)
# This determines if shifts are editable in published schedule state (FROM_STATE = 5)
# If EDIT_SC event exists in the result, editing is permitted after publish
CHECK_EDIT_PUBLISHED_SCHEDULE_EVENT_QUERY = """
SELECT 
    EVENT_ID 
FROM 
    RWSUSER.EVENT 
WHERE 
    EVENT_SKEY IN (
        SELECT EVENT_SKEY 
        FROM RWSUSER.TRANSITION 
        WHERE FROM_STATE = 5 
        AND OWNER_ID = '{OWNER_ID}'
    )
"""


# PC00114: Query to determine status and severity for a given alert
ALERT_STATUS_SEVERITY_QUERY = """
SELECT 
    CONSTRAINT_TYPE, 
    STATUS  
FROM 
    RWS_SCH_MPARAMS 
WHERE 
    PARAM_ID = '{PARAM_ID}' 
    AND OWNER_ID = '{OWNER_ID}'
    AND CONSTRAINT_TYPE = 'S'
"""

# PC00115: Query to determine the scheduling engine applicable for the store
SCHEDULING_ENGINE_QUERY = """
SELECT
    rsm.NAME
FROM
    RWS_SCH_MAPPLIES rsm
WHERE
    ((rsm.DOMAIN_TYPE = 'D'
    AND rsm.DOMAIN_SKEY IN (
        SELECT
            rdsm.DIST_LIST_ID
        FROM
            RWS_DIST_STORE_MAP rdsm
        WHERE
            rdsm.UNIT_ID = '{STORE_ID}'
            AND rdsm.EFF_DATESKEY <= {CURRENT_DATE}
            AND rdsm.END_DATESKEY >= {CURRENT_DATE}
            AND rdsm.owner_ID = '{OWNER_ID}'))
    OR (rsm.DOMAIN_TYPE = 'U'
    AND rsm.DOMAIN_SKEY = (SELECT u.unit_SKEY FROM unit u WHERE UNIT_ID = '{STORE_ID}' AND u.owner_ID = '{OWNER_ID}')))
    AND (rsm.MODEL_SKEY = 5 OR rsm.MODEL_SKEY = 1)
    AND rsm.STATUS = 'A' 
    AND rsm.owner_ID = '{OWNER_ID}'
"""

# PC00095: Scheduling rules queries for shift policies and alerts
#
# Purpose: These queries determine if specific scheduling alerts are enabled for an owner.
# When these queries return results indicating alerts are active, certain test assertions
# are performed. However, when using these queries as lookups, the assertion steps are
# skipped because the query itself validates the alert status in the database.
#
# Usage Pattern:
# - If alert is enabled (query returns STATUS = 'A'): Run assertion logic
# - If alert is disabled (query returns no rows or STATUS != 'A'): Skip assertion
# - When using query for lookup PC00095: Skip assertion step (query validates status)

# Query to find all shift policies including minimum shift length as per shift policy
# The SHIFT_TIME column is used to get the allowed shift lengths
SHIFT_POLICY_QUERY = """
SELECT
    A.OWNER_ID as OWNER_ID,
    A.SHIFT_ID AS SHIFT_ID,
    A.SHIFT_CD AS SHIFT_CD,
    A.SHIFT_TMPL_NAME AS SHIFT_TMPL_NAME,
    A.SHIFT_TMPL_DESC AS SHIFT_TMPL_DESC,
    A.DEFAULT_IND AS DEFAULT_IND1,
    A.LAST_UPDATE_TIME AS LAST_UPDATE_TIME1,
    A.LAST_USER AS LAST_USER,
    B.DIST_LIST_ID AS DIST_LIST_ID,
    B.EMP_GROUP_ID AS EMP_GROUP_ID,
    B.EFF_DATE AS EFF_DATE,
    B.END_DATE AS END_DATE,
    B.RANK_ORDER AS RANK_ORDER,
    B.LAST_UPDATE_TIME AS LAST_UPDATE_TIME2,
    B.LAST_USER AS LAST_USER2,
    C.SHIFT_TIME AS SHIFT_TIME,
    C.BREAK_TIME AS BREAK_TIME,
    C.ALLOCATION_PER AS ALLOCATION_PER,
    C.DEFAULT_IND AS DEFAULT_IND2,
    C.AUTO_SCHD_IND AS AUTO_SCHD_IND,
    C.LAST_UPDATE_TIME AS LAST_UPDATE_TIME3,
    C.LAST_USER AS LAST_USER3
FROM
    RWS_SHIFT_BREAK_TMPL A 
    LEFT JOIN RWS_SHIFT_BREAK_APPLIES_TO B 
        ON A.OWNER_ID = B.OWNER_ID 
        AND A.SHIFT_ID = B.SHIFT_ID
    LEFT JOIN RWS_NSHIFT_BREAK C 
        ON C.OWNER_ID = B.OWNER_ID 
        AND C.SHIFT_ID = B.SHIFT_ID
WHERE
    A.OWNER_ID = '{OWNER_ID}'
ORDER BY 
    A.SHIFT_ID, C.SHIFT_TIME
"""

# Query to check if "Shift Alert: Daily: Shift Minimum Length not met" is enabled
# STATUS = 'A' indicates the alert is enabled
# Note: When this query is used for lookup PC00095, assertion steps for shift minimum
# length validation are skipped since the query itself determines alert enablement status
SHIFT_MIN_LENGTH_ALERT_QUERY = """
SELECT 
    * 
FROM 
    RWS_SCH_MPARAMS 
WHERE 
    PARAM_ID = 'S0001' 
    AND OWNER_ID = '{OWNER_ID}'
"""

# Query to check if "HR Alert: Employee Maximum hours per week exceeded" is enabled
# STATUS = 'A' indicates the alert is enabled
# Note: When this query is used for lookup PC00095, assertion steps for employee
# maximum hours validation are skipped since the query itself determines alert status
EMPLOYEE_MAX_WEEKLY_HOURS_ALERT_QUERY = """
SELECT 
    * 
FROM 
    RWS_SCH_MPARAMS 
WHERE 
    PARAM_ID = 'E0012' 
    AND OWNER_ID = '{OWNER_ID}'
"""

# PC00095:
# Minimum and Maximum shift length as per shift policy.
# Shift Alert: Daily: Shift Minimum Length not met for given personId as per active model.
# HR Alert: Employee Maximum hours per week exceeded for given personId as per active model.
EMPLOYEE_SHIFT_LENGTH_QUERY = """
SELECT
    MIN(C.SHIFT_TIME)/60 AS MIN_SHIFT_LENGTH,
    MAX(C.SHIFT_TIME)/60 AS MAX_SHIFT_LENGTH
FROM
    RWS_NSHIFT_BREAK C
    JOIN RWS_SHIFT_BREAK_TMPL A ON A.OWNER_ID = C.OWNER_ID AND A.SHIFT_ID = C.SHIFT_ID
    JOIN RWS_SHIFT_BREAK_APPLIES_TO B ON B.OWNER_ID = A.OWNER_ID AND B.SHIFT_ID = A.SHIFT_ID
    JOIN RWS_EMP_GROUP_MAPPING egm ON egm.GROUP_ID = B.EMP_GROUP_ID AND egm.OWNER_ID = A.OWNER_ID
WHERE
    A.OWNER_ID = {OWNER_ID}
    AND A.DEFAULT_IND = 'N'
    AND B.EFF_DATE <= {EFF_DATE_SKEY}
    AND B.END_DATE >= {END_DATE_SKEY}
    AND egm.PERSON_ID IN ({PERSON_ID})
    AND egm.EFF_DATESKEY <= {EFF_DATE_SKEY}
    AND egm.END_DATESKEY >= {END_DATE_SKEY}
    AND C.AUTO_SCHD_IND IN ('A', 'S');
"""

ALERT_MESSAGE_STATUS_QUERY = """
SELECT
    mp.STATUS                        AS ALERT_STATUS,
    egm.PERSON_ID,
    egm.GROUP_ID                     AS PERSON_EMP_GROUP_ID,
    ma.MODEL_SKEY,
    ma.MODEL_ID,
    m.MODEL_NAME,
    ma.NAME                          AS MODEL_APPLIES_NAME,
    ma.STATUS                        AS MODEL_STATUS,
    mp.PARAM_ID                      AS ALERT_ID,
    CASE mp.STATUS
        WHEN 'A' THEN 'ACTIVE'
        WHEN 'I' THEN 'INACTIVE'
        WHEN 'H' THEN 'HIDDEN'
        ELSE 'UNKNOWN'
    END                              AS ALERT_STATUS_DESC,
    mp.CONSTRAINT_TYPE,
    mp.DESCRIPTION
FROM RWS_EMP_GROUP_MAPPING egm
INNER JOIN RWS_SCH_MAPPLIES ma
    ON  ma.OWNER_ID     = egm.OWNER_ID
    AND ma.EMP_GROUP_ID = egm.GROUP_ID
    AND ma.STATUS       = 'A'
    AND {DATE_SKEY} BETWEEN ma.EFF_DATE AND ma.END_DATE
INNER JOIN RWS_SCH_MODEL m
    ON  m.OWNER_ID = ma.OWNER_ID
    AND m.MODEL_ID = ma.MODEL_ID
INNER JOIN RWS_SCH_MPARAMS mp
    ON  mp.OWNER_ID   = ma.OWNER_ID
    AND mp.MODEL_SKEY = ma.MODEL_SKEY
    AND mp.PARAM_ID   = '{ALERT_ID}'
WHERE
    egm.OWNER_ID   = {OWNER_ID}
    AND egm.PERSON_ID = {PERSON_ID}
    AND {DATE_SKEY} BETWEEN egm.EFF_DATESKEY AND egm.END_DATESKEY
    AND mp.CONSTRAINT_TYPE != 'S'
ORDER BY ma.RANK ASC;
"""

# PC00096: Determine if shift can be added with less than the defined min/max shift length.
EMPLOYEE_NET_RULES_QUERY = """
SELECT *
FROM RWS_EMP_NET_RULE renr
WHERE
    RULE_ID = '{RULE_ID}'
    AND {DATE_SKEY} BETWEEN EFF_DATE AND END_DATE
    AND PERSON_ID = {PERSON_ID}
    AND OWNER_ID = {OWNER_ID};
"""

# PC00094: Query to retrieve max weekly working hours for an associate from RWS_EMP_STATUS.
# EFF_DATE and END_DATE in RWS_EMP_STATUS are DB2 DATE type columns (not integer date keys).
# The query checks if the employee status record is effective for the given date range.
# Pass week start date as EFF_DATE_SKEY and week end date as END_DATE_SKEY
# to get the employee status that applies to the week being tested.
EMPLOYEE_WORK_RULES_QUERY = """
SELECT
    MAX_NORMAL_HOURS
FROM
    RWSUSER.RWS_EMP_STATUS
WHERE
    OWNER_ID = {OWNER_ID}
    AND PERSON_ID = {PERSON_ID}
    AND EFF_DATE <= DATE('{END_DATE_SKEY}')
    AND END_DATE >= DATE('{EFF_DATE_SKEY}')
"""

# Query to check whether VDI-based workload regeneration is enabled for a store.
# Returns one row with FIXED_WL_STATUS as 'ENABLED' or 'NOT ENABLED'.
VDI_BASED_WORKLOAD_REGENERATION_STATUS_QUERY = """
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM PROCESS_APPLICABILITY pa
            JOIN PROCESS p
                ON p.OWNER_ID = pa.OWNER_ID
                AND p.PROCESS_SKEY = pa.PROCESS_SKEY
            JOIN STATE s
                ON s.STATE_SKEY = p.START_STATE
            JOIN UNIT u
                ON u.OWNER_ID = pa.OWNER_ID
                AND u.UNIT_SKEY = pa.DOMAIN_SKEY
            WHERE pa.OWNER_ID = {OWNER_ID}
                AND pa.DOMAIN_TYPE = 'U'
                AND s.STATE_ID = 'START_STATE_FIXED_WL'
                AND u.UNIT_ID = '{UNIT_ID}'

            UNION ALL

            SELECT 1
            FROM PROCESS_APPLICABILITY pa
            JOIN PROCESS p
                ON p.OWNER_ID = pa.OWNER_ID
                AND p.PROCESS_SKEY = pa.PROCESS_SKEY
            JOIN STATE s
                ON s.STATE_SKEY = p.START_STATE
            JOIN RWS_DIST_STORE_MAP rdsm
                ON rdsm.OWNER_ID = pa.OWNER_ID
                AND rdsm.DIST_LIST_ID = CAST(pa.DOMAIN_SKEY AS VARCHAR(20))
            WHERE pa.OWNER_ID = {OWNER_ID}
                AND pa.DOMAIN_TYPE = 'D'
                AND s.STATE_ID = 'START_STATE_FIXED_WL'
                AND rdsm.UNIT_ID = '{UNIT_ID}'
                AND rdsm.EFF_DATESKEY <= INTEGER(TO_CHAR(CURRENT DATE, 'YYYYMMDD'))
                AND rdsm.END_DATESKEY >= INTEGER(TO_CHAR(CURRENT DATE, 'YYYYMMDD'))
        ) THEN 'ENABLED'
        ELSE 'NOT ENABLED'
    END AS FIXED_WL_STATUS
FROM SYSIBM.SYSDUMMY1
"""

