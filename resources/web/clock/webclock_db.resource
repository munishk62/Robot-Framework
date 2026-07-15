*** Settings ***
Documentation       Web Clock Database Keywords
...
...                 Contains all DB query keywords for web clock functionality.
...                 Each keyword is atomic (one query per keyword) and the SQL query
...                 is defined inline within the keyword for readability.

Resource            resources/web/common/database.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Get Store Timezone From DB
    [Documentation]
    ...    Retrieves timezone configuration for a store from database.
    ...    Queries RAR_UNIT_D table using store_id, owner_id and locale from config.
    ...
    ...    | =Arguments= | =Description= |
    ...    | store_id | Store ID to lookup timezone (e.g., "STORE5") |
    ...
    ...    | =Returns= | =Description= |
    ...    | timezone | Timezone string (e.g., "US/Eastern", "America/New_York") |
    ...
    ...    Example usage:
    ...    | ${timezone}=    Get Store Timezone From DB    STORE5
    [Arguments]    ${store_id}
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${locale}    Get Config Value    key=LOCALE
    VAR    ${query}
    ...    SELECT TIME_ZONE FROM RAR_UNIT_D
    ...    WHERE OWNER_ID = '${owner_id}' AND LOCALE_CODE = '${locale}' AND STORE_ID = '${store_id}'
    Log    Executing timezone query for store: ${store_id} with locale: ${locale}
    ${result}    Execute Query And Return Result    ${query}
    ${length}    Get Length    ${result}
    IF    ${length} > 0
        ${first_row}    Get From List    ${result}    0
        VAR    ${timezone}    ${first_row}[0]
        Log    Retrieved timezone: ${timezone} for store ${store_id}
        RETURN    ${timezone}
    ELSE
        Fail    No timezone found for store_id: ${store_id}
    END

Check Clock Applicability In DB
    [Documentation]
    ...    Validates if clock-in/clock-out functionality is applicable by checking:
    ...    - Clock transaction types (1,2) are configured in TA_STD_TXN_TYPE and TA_UNIT_TXN_TYPE
    ...
    ...    Returns True if clock functionality is applicable, False otherwise.
    ...
    ...    | =Returns= | =Description= |
    ...    | is_clock_applicable | Boolean indicating if clock functionality is applicable |
    ...
    ...    Example usage:
    ...    | ${is_clock_applicable}=    Check Clock Applicability In DB
    ...    | Skip If    not ${is_clock_applicable}    Clock functionality not applicable - DB validation failed
    ${owner_id}    Get Config Value    key=OWNER_ID
    VAR    ${query}
    ...    SELECT 1 FROM SYSIBM.SYSDUMMY1
    ...    WHERE (SELECT COUNT(DISTINCT TXN_TYPE_ID) FROM TA_STD_TXN_TYPE WHERE TXN_TYPE_ID IN (1, 2) AND OWNER_ID = '${owner_id}') = 2
    ...    AND (SELECT COUNT(DISTINCT TXN_TYPE_ID) FROM TA_UNIT_TXN_TYPE WHERE TXN_TYPE_ID IN (1, 2) AND OWNER_ID = '${owner_id}') = 2
    ${result}    Execute Query And Return Result    ${query}
    ${result_count}    Get Length    ${result}
    Log    Clock applicability validation result: ${result_count} matching records found
    ${is_clock_applicable}    Evaluate    ${result_count} > 0
    RETURN    ${is_clock_applicable}

Check Meal Applicability For User In DB
    [Documentation]
    ...    Validates if meal functionality is applicable for a user by checking:
    ...    - Employee's contract policy supports meals with valid network segment types (SSM/SUM/UUM)
    ...    - Meal transaction types (3,4) are configured in TA_STD_TXN_TYPE and TA_UNIT_TXN_TYPE (>= 2 each)
    ...    - Meal transaction types (3,4) are available in TA_DVC_GRP_TXN for the owner (>= 2 records)
    ...    - Meal transaction types (3,4) are available in TA_DVC_TXN for the user's store unit (>= 2 records)
    ...
    ...    Returns True if meal functionality is applicable, False otherwise.
    ...
    ...    | =Arguments= | =Description= |
    ...    | user_key | User key to fetch user credentials (e.g., ESS4_STORE1) |
    ...
    ...    | =Returns= | =Description= |
    ...    | is_meal_applicable | Boolean indicating if meal functionality is applicable |
    ...
    ...    Example usage:
    ...    | ${is_meal_applicable}=    Check Meal Applicability For User In DB    user_key=ESS4_STORE1
    ...    | Skip If    not ${is_meal_applicable}    Meal functionality not applicable for user ESS4_STORE1
    [Arguments]    ${user_key}
    ${user}    Get User    user_key=${user_key}
    VAR    ${employee_id}    ${user}[username]
    VAR    ${unit_id}    ${user}[unitID]
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${server_date_format}    Get Config Value    key=SERVER_DF
    ${check_date}    Get Current Date    result_format=${server_date_format}
    VAR    ${query}
    ...    SELECT rec.CONTRACT_ID, ttcp.policy_int_id, rcp.policy_type, nwseg.segment_type
    ...    FROM RHR_EMP_CONTRACT rec
    ...    INNER JOIN rhr_employee re ON (re.person_id=rec.person_id AND re.owner_id=rec.owner_id)
    ...    INNER JOIN RHR_CONTRACT_POLICY rcp ON (rec.contract_id=rcp.contract_id AND rec.owner_id=rcp.owner_id)
    ...    INNER JOIN TA_TIME_COL_PLCY ttcp ON (ttcp.policy_id=rcp.policy_id AND ttcp.owner_id=rcp.owner_id)
    ...    INNER JOIN TA_TC_PLCY_NWSEG nwseg ON (ttcp.policy_int_id=nwseg.policy_int_id AND ttcp.owner_id=nwseg.owner_id)
    ...    WHERE re.owner_id='${owner_id}' AND re.employee_id='${employee_id}'
    ...    AND (rec.end_date>${check_date} OR rec.end_date=0) AND (rcp.end_date>${check_date} OR rcp.end_date=0)
    ...    AND rcp.policy_TYPE='T' AND nwseg.segment_type IN('SSM','SUM','UUM')
    ...    AND (SELECT COUNT(DISTINCT TXN_TYPE_ID) FROM TA_STD_TXN_TYPE WHERE TXN_TYPE_ID IN (3,4) AND OWNER_ID = re.owner_id) >= 2
    ...    AND (SELECT COUNT(DISTINCT TXN_TYPE_ID) FROM TA_UNIT_TXN_TYPE WHERE TXN_TYPE_ID IN (3,4) AND OWNER_ID = re.owner_id) >= 2
    ...    AND (SELECT COUNT(TXN_TYPE_ID) FROM TA_DVC_GRP_TXN WHERE OWNER_ID = '${owner_id}' AND AVAIL_FLAG = 'Y' AND TXN_TYPE_ID IN (3, 4)) >= 2
    ...    AND (SELECT COUNT(tdt.TXN_TYPE_ID) FROM TA_DVC_TXN tdt WHERE tdt.DEVICE_ID IN (SELECT td.DEVICE_ID FROM TA_DEVICE td WHERE td.UNIT_ID = '${unit_id}') AND tdt.OWNER_ID = '${owner_id}' AND tdt.AVAIL_FLAG = 'Y' AND tdt.TXN_TYPE_ID IN (3, 4)) >= 2
    ${result}    Execute Query And Return Result    ${query}
    ${result_count}    Get Length    ${result}
    Log    Meal applicability validation result for employee ${employee_id}: ${result_count} matching records found
    ${is_meal_applicable}    Evaluate    ${result_count} > 0
    RETURN    ${is_meal_applicable}

Check Break Applicability For User In DB
    [Documentation]
    ...    Validates if break functionality is applicable for a user by checking:
    ...    - Employee's contract policy supports breaks with valid network segment types (SSB/SUB/UUB)
    ...    - Break transaction types (5,6) are configured in TA_STD_TXN_TYPE and TA_UNIT_TXN_TYPE (>= 2 each)
    ...    - Break transaction types (5,6) are available in TA_DVC_GRP_TXN for the owner (>= 2 records)
    ...    - Break transaction types (5,6) are available in TA_DVC_TXN for the user's store unit (>= 2 records)
    ...
    ...    Returns True if break functionality is applicable, False otherwise.
    ...
    ...    | =Arguments= | =Description= |
    ...    | user_key | User key to fetch user credentials (e.g., ESS5_STORE1) |
    ...
    ...    | =Returns= | =Description= |
    ...    | is_break_applicable | Boolean indicating if break functionality is applicable |
    ...
    ...    Example usage:
    ...    | ${is_break_applicable}=    Check Break Applicability For User In DB    user_key=ESS5_STORE1
    ...    | Skip If    not ${is_break_applicable}    Break functionality not applicable for user ESS5_STORE1
    [Arguments]    ${user_key}
    ${user}    Get User    user_key=${user_key}
    VAR    ${employee_id}    ${user}[username]
    VAR    ${unit_id}    ${user}[unitID]
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${server_date_format}    Get Config Value    key=SERVER_DF
    ${check_date}    Get Current Date    result_format=${server_date_format}
    VAR    ${query}
    ...    SELECT rec.CONTRACT_ID, ttcp.policy_int_id, rcp.policy_type, nwseg.segment_type
    ...    FROM RHR_EMP_CONTRACT rec
    ...    INNER JOIN rhr_employee re ON (re.person_id=rec.person_id AND re.owner_id=rec.owner_id)
    ...    INNER JOIN RHR_CONTRACT_POLICY rcp ON (rec.contract_id=rcp.contract_id AND rec.owner_id=rcp.owner_id)
    ...    INNER JOIN TA_TIME_COL_PLCY ttcp ON (ttcp.policy_id=rcp.policy_id AND ttcp.owner_id=rcp.owner_id)
    ...    INNER JOIN TA_TC_PLCY_NWSEG nwseg ON (ttcp.policy_int_id=nwseg.policy_int_id AND ttcp.owner_id=nwseg.owner_id)
    ...    WHERE re.owner_id='${owner_id}' AND re.employee_id='${employee_id}'
    ...    AND (rec.end_date>${check_date} OR rec.end_date=0) AND (rcp.end_date>${check_date} OR rcp.end_date=0)
    ...    AND rcp.policy_TYPE='T' AND nwseg.segment_type IN('SSB','SUB','UUB')
    ...    AND (SELECT COUNT(DISTINCT TXN_TYPE_ID) FROM TA_STD_TXN_TYPE WHERE TXN_TYPE_ID IN (5,6) AND OWNER_ID = re.owner_id) >= 2
    ...    AND (SELECT COUNT(DISTINCT TXN_TYPE_ID) FROM TA_UNIT_TXN_TYPE WHERE TXN_TYPE_ID IN (5,6) AND OWNER_ID = re.owner_id) >= 2
    ...    AND (SELECT COUNT(TXN_TYPE_ID) FROM TA_DVC_GRP_TXN WHERE OWNER_ID = '${owner_id}' AND AVAIL_FLAG = 'Y' AND TXN_TYPE_ID IN (5, 6)) >= 2
    ...    AND (SELECT COUNT(tdt.TXN_TYPE_ID) FROM TA_DVC_TXN tdt WHERE tdt.DEVICE_ID IN (SELECT td.DEVICE_ID FROM TA_DEVICE td WHERE td.UNIT_ID = '${unit_id}') AND tdt.OWNER_ID = '${owner_id}' AND tdt.AVAIL_FLAG = 'Y' AND tdt.TXN_TYPE_ID IN (5, 6)) >= 2
    ${result}    Execute Query And Return Result    ${query}
    ${result_count}    Get Length    ${result}
    Log    Break applicability validation result for employee ${employee_id}: ${result_count} matching records found
    ${is_break_applicable}    Evaluate    ${result_count} > 0
    RETURN    ${is_break_applicable}
