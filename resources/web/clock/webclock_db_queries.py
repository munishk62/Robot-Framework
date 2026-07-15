GET_ACTIVE_WEB_CLOCK_DEVICE_IDS = "SELECT DEVICE_ID FROM TA_DEVICE WHERE DEVICE_TYPE_ID = 11 and STATUS = 'A' and UNIT_ID = '{store_id}' and OWNER_ID = '{owner_id}'"

# Query to retrieve timezone configuration for a store from RAR_UNIT_D table.
# Returns: Single row with TIME_ZONE column (e.g., 'US/Eastern', 'America/New_York').
# Filters by: OWNER_ID, LOCALE_CODE='en_US', and STORE_ID to ensure correct locale and store context.
GET_STORE_TIMEZONE = "SELECT TIME_ZONE FROM RAR_UNIT_D WHERE OWNER_ID = '{owner_id}' AND LOCALE_CODE = '{locale}' AND STORE_ID = '{store_id}'"

# Query to validate clock-in/clock-out functionality applicability.
# Validates that clock transaction types (TXN_TYPE_ID 1 and 2) are configured
# in both TA_STD_TXN_TYPE and TA_UNIT_TXN_TYPE tables.
#
# Uses SYSIBM.SYSDUMMY1 for simple validation query with subqueries to check:
# - TA_STD_TXN_TYPE table has both transaction types (1=clock_in, 2=clock_out)
# - TA_UNIT_TXN_TYPE table has both transaction types
#
# Returns matching record only if both transaction types exist.
#
# Parameters:
# - owner_id: System owner ID
CHECK_CLOCK_APPLICABILITY = """SELECT 1
FROM SYSIBM.SYSDUMMY1
WHERE
    (
        SELECT COUNT(DISTINCT TXN_TYPE_ID)
        FROM TA_STD_TXN_TYPE
        WHERE TXN_TYPE_ID IN (1, 2) AND OWNER_ID = '{owner_id}'
    ) = 2
    AND (
        SELECT COUNT(DISTINCT TXN_TYPE_ID)
        FROM TA_UNIT_TXN_TYPE
        WHERE TXN_TYPE_ID IN (1, 2) AND OWNER_ID = '{owner_id}'
    ) = 2"""

# Query to validate meal functionality applicability for an employee.
# Validates that meal transaction types (TXN_TYPE_ID 3 and 4) are configured
# and employee's contract policy supports meal operations via network segment types (SSM, SUM, UUM).
#
# All of the following conditions must be satisfied:
# - Employee has active contract with Time Collection Policy (policy_type='T')
# - Policy has valid network segment types (SSM/SUM/UUM)
# - TA_STD_TXN_TYPE has >= 2 distinct meal TXN types (3,4)
# - TA_UNIT_TXN_TYPE has >= 2 distinct meal TXN types (3,4)
# - TA_DVC_GRP_TXN has >= 2 available meal TXN types (3,4) for the owner
# - TA_DVC_TXN has >= 2 available meal TXN types (3,4) on devices for the user's store unit
# - Contract and policy are active on check_date
#
# Parameters:
# - owner_id: System owner ID
# - employee_id: Employee identifier
# - check_date: Date to validate contract (format: yyyymmdd)
# - unit_id: Store unit ID from user credentials (e.g., ZAUTOSTORE001)
CHECK_MEAL_APPLICABILITY = """SELECT rec.CONTRACT_ID, ttcp.policy_int_id, rcp.policy_type, nwseg.segment_type
FROM RHR_EMP_CONTRACT rec
INNER JOIN rhr_employee re ON (re.person_id=rec.person_id AND re.owner_id=rec.owner_id)
INNER JOIN RHR_CONTRACT_POLICY rcp ON (rec.contract_id=rcp.contract_id AND rec.owner_id=rcp.owner_id)
INNER JOIN TA_TIME_COL_PLCY ttcp ON (ttcp.policy_id=rcp.policy_id AND ttcp.owner_id=rcp.owner_id)
INNER JOIN TA_TC_PLCY_NWSEG nwseg ON (ttcp.policy_int_id=nwseg.policy_int_id AND ttcp.owner_id=nwseg.owner_id)
WHERE re.owner_id='{owner_id}' AND re.employee_id='{employee_id}'
    AND (rec.end_date>{check_date} OR rec.end_date=0)
    AND (rcp.end_date>{check_date} OR rcp.end_date=0)
    AND rcp.policy_TYPE='T'
    AND nwseg.segment_type IN('SSM','SUM','UUM')
    AND (
        SELECT COUNT(DISTINCT TXN_TYPE_ID)
        FROM TA_STD_TXN_TYPE
        WHERE TXN_TYPE_ID IN (3,4) AND OWNER_ID = re.owner_id
    ) >= 2
    AND (
        SELECT COUNT(DISTINCT TXN_TYPE_ID)
        FROM TA_UNIT_TXN_TYPE
        WHERE TXN_TYPE_ID IN (3,4) AND OWNER_ID = re.owner_id
    ) >= 2
    AND (
        SELECT COUNT(TXN_TYPE_ID)
        FROM TA_DVC_GRP_TXN
        WHERE OWNER_ID = '{owner_id}'
            AND AVAIL_FLAG = 'Y'
            AND TXN_TYPE_ID IN (3, 4)
    ) >= 2
    AND (
        SELECT COUNT(tdt.TXN_TYPE_ID)
        FROM TA_DVC_TXN tdt
        WHERE tdt.DEVICE_ID IN (
            SELECT td.DEVICE_ID FROM TA_DEVICE td WHERE td.UNIT_ID = '{unit_id}'
        )
            AND tdt.OWNER_ID = '{owner_id}'
            AND tdt.AVAIL_FLAG = 'Y'
            AND tdt.TXN_TYPE_ID IN (3, 4)
    ) >= 2"""

# Query to validate break functionality applicability for an employee.
# Validates that break transaction types (TXN_TYPE_ID 5 and 6) are configured
# and employee's contract policy supports break operations via network segment types (SSB, SUB, UUB).
#
# All of the following conditions must be satisfied:
# - Employee has active contract with Time Collection Policy (policy_type='T')
# - Policy has valid network segment types (SSB/SUB/UUB)
# - TA_STD_TXN_TYPE has >= 2 distinct break TXN types (5,6)
# - TA_UNIT_TXN_TYPE has >= 2 distinct break TXN types (5,6)
# - TA_DVC_GRP_TXN has >= 2 available break TXN types (5,6) for the owner
# - TA_DVC_TXN has >= 2 available break TXN types (5,6) on devices for the user's store unit
# - Contract and policy are active on check_date
#
# Parameters:
# - owner_id: System owner ID
# - employee_id: Employee identifier
# - check_date: Date to validate contract (format: yyyymmdd)
# - unit_id: Store unit ID from user credentials (e.g., ZAUTOSTORE001)
CHECK_BREAK_APPLICABILITY = """SELECT rec.CONTRACT_ID, ttcp.policy_int_id, rcp.policy_type, nwseg.segment_type
FROM RHR_EMP_CONTRACT rec
INNER JOIN rhr_employee re ON (re.person_id=rec.person_id AND re.owner_id=rec.owner_id)
INNER JOIN RHR_CONTRACT_POLICY rcp ON (rec.contract_id=rcp.contract_id AND rec.owner_id=rcp.owner_id)
INNER JOIN TA_TIME_COL_PLCY ttcp ON (ttcp.policy_id=rcp.policy_id AND ttcp.owner_id=rcp.owner_id)
INNER JOIN TA_TC_PLCY_NWSEG nwseg ON (ttcp.policy_int_id=nwseg.policy_int_id AND ttcp.owner_id=nwseg.owner_id)
WHERE re.owner_id='{owner_id}' AND re.employee_id='{employee_id}'
    AND (rec.end_date>{check_date} OR rec.end_date=0)
    AND (rcp.end_date>{check_date} OR rcp.end_date=0)
    AND rcp.policy_TYPE='T'
    AND nwseg.segment_type IN('SSB','SUB','UUB')
    AND (
        SELECT COUNT(DISTINCT TXN_TYPE_ID)
        FROM TA_STD_TXN_TYPE
        WHERE TXN_TYPE_ID IN (5,6) AND OWNER_ID = re.owner_id
    ) >= 2
    AND (
        SELECT COUNT(DISTINCT TXN_TYPE_ID)
        FROM TA_UNIT_TXN_TYPE
        WHERE TXN_TYPE_ID IN (5,6) AND OWNER_ID = re.owner_id
    ) >= 2
    AND (
        SELECT COUNT(TXN_TYPE_ID)
        FROM TA_DVC_GRP_TXN
        WHERE OWNER_ID = '{owner_id}'
            AND AVAIL_FLAG = 'Y'
            AND TXN_TYPE_ID IN (5, 6)
    ) >= 2
    AND (
        SELECT COUNT(tdt.TXN_TYPE_ID)
        FROM TA_DVC_TXN tdt
        WHERE tdt.DEVICE_ID IN (
            SELECT td.DEVICE_ID FROM TA_DEVICE td WHERE td.UNIT_ID = '{unit_id}'
        )
            AND tdt.OWNER_ID = '{owner_id}'
            AND tdt.AVAIL_FLAG = 'Y'
            AND tdt.TXN_TYPE_ID IN (5, 6)
    ) >= 2"""
