*** Settings ***
Documentation       Test suite for ESS Requests Calendar DB queries

Resource            resources/web/common/common.resource
Resource            resources/web/common/database.resource


*** Keywords ***
Get Number Of Days And Min Lead Time For Day Off Request From DB
    [Documentation]    Get number of days required to be excluded before Day Off Requests can be applied From DB For ESS User
    ...    | =Arguments=    | =Description=    |
    ...    | user_credentials_data    | User credentials data dictionary for username to be fetched    |
    ...    | reason_type    | Reason type (reason text) for which the number of days required needs to be fetched from DB    |
    ...    | =Returns=    | =Description=    |
    ...    | ${day_off_required_days}    | Number of days required for the day off request.    |
    ...    | ${sys_min_lead_time}    | Minimum lead time in days for the day off request.    |
    ...    Example usage:
    ...    | ${day_off_required_days}    ${sys_min_lead_time}    Get Number Of Days And Min Lead Time For Day Off Request From DB    ${user_credentials}    Paid Vacation    |
    [Arguments]    ${user_credentials_data}    ${reason_type}
    ${owner_id}    Get Config Value    key=OWNER_ID
    VAR    ${associate_username}    ${user_credentials_data}[username]
    ${dayoff_db_query}    Catenate    SEPARATOR=${SPACE}
    ...    SELECT VALUE
    ...    FROM RWSUSER.RWS_VAL_CONFIG_VALUE
    ...    WHERE OWNER_ID = '${owner_id}'
    ...    AND CONFIG_ID IN (
    ...        SELECT CONFIG_ID
    ...        FROM RWSUSER.RWS_VALIDATION_CONFIG
    ...        WHERE OWNER_ID = '${owner_id}'
    ...        AND CONFIG_CODE = 'MUST_APPLY_ATLST'
    ...    )
    ...    AND ENTITY_TYPE_ID IN (
    ...        SELECT REQUEST_TYPE_ID
    ...        FROM RWSUSER.RWS_REQUEST_TYPE
    ...        WHERE REQUEST_TYPE_NAME = '${reason_type}'
    ...        AND OWNER_ID = '${owner_id}'
    ...        AND CATEGORY = 'DO'
    ...    )
    ...    AND EMPLOYEE_GROUP_ID IN (
    ...        SELECT GROUP_ID
    ...        FROM RWSUSER.RWS_EMP_GROUP_MAPPING
    ...        WHERE OWNER_ID = '${owner_id}'
    ...        AND PERSON_ID = (
    ...            SELECT re.PERSON_ID
    ...            FROM RWSUSER.RWS_EMPLOYEE re
    ...            WHERE OWNER_ID = '${owner_id}'
    ...            AND re.EMPLOYEE_ID = '${associate_username}'
    ...        )
    ...    )
    ${dayoff_db_result}    Execute Query And Return Result    ${dayoff_db_query}
    IF    $dayoff_db_result
        VAR    ${day_off_required_days}    ${dayoff_db_result}[0][0]
    ELSE
        VAR    ${day_off_required_days}    ${EMPTY}
    END

    ${sys_min_lead_time}    Get System Minimum Lead Time For Requests From DB

    RETURN    ${day_off_required_days}    ${sys_min_lead_time}

Get Number Of Days And Min Lead Time For Time Off Request From DB
    [Documentation]    Get number of days required to be excluded before Time Off Requests can be applied From DB For ESS User
    ...    | =Arguments=    | =Description=    |
    ...    | user_credentials_data    | User credentials data dictionary for username to be fetched    |
    ...    | reason_type    | Reason type (reason text) for which the number of days required needs to be fetched from DB    |
    ...    | =Returns=    | Number of days required for time off request and minimum lead time in days for time off request fetched from DB.    |
    ...    Example usage:
    ...    | ${time_off_required_days}    ${sys_min_lead_time}    Get Number Of Days And Min Lead Time For Time Off Request From DB    ${user_credentials}    Paid Vacation    |
    [Arguments]    ${user_credentials_data}    ${reason_type}
    ${owner_id}    Get Config Value    key=OWNER_ID
    VAR    ${associate_username}    ${user_credentials_data}[username]
    ${timeoff_db_query}    Catenate    SEPARATOR=${SPACE}
    ...    SELECT VALUE
    ...    FROM RWSUSER.RWS_VAL_CONFIG_VALUE
    ...    WHERE OWNER_ID = '${owner_id}'
    ...    AND CONFIG_ID IN (
    ...        SELECT CONFIG_ID
    ...        FROM RWSUSER.RWS_VALIDATION_CONFIG
    ...        WHERE OWNER_ID = '${owner_id}'
    ...        AND CONFIG_CODE = 'MUST_APPLY_ATLST'
    ...    )
    ...    AND ENTITY_TYPE_ID IN (
    ...        SELECT REQUEST_TYPE_ID
    ...        FROM RWSUSER.RWS_REQUEST_TYPE
    ...        WHERE REQUEST_TYPE_NAME = '${reason_type}'
    ...        AND OWNER_ID = '${owner_id}'
    ...        AND CATEGORY = 'TO'
    ...    )
    ...    AND EMPLOYEE_GROUP_ID IN (
    ...        SELECT GROUP_ID
    ...        FROM RWSUSER.RWS_EMP_GROUP_MAPPING
    ...        WHERE OWNER_ID = '${owner_id}'
    ...        AND PERSON_ID = (
    ...            SELECT re.PERSON_ID
    ...            FROM RWSUSER.RWS_EMPLOYEE re
    ...            WHERE OWNER_ID = '${owner_id}'
    ...            AND re.EMPLOYEE_ID = '${associate_username}'
    ...        )
    ...    )

    Log    Time Off Request DB Query: ${timeoff_db_query}
    ${timeoff_db_result}    Execute Query And Return Result    ${timeoff_db_query}
    IF    $timeoff_db_result
        VAR    ${time_off_required_days}    ${timeoff_db_result}[0][0]
    ELSE
        VAR    ${time_off_required_days}    ${EMPTY}
    END

    ${sys_min_lead_time}    Get System Minimum Lead Time For Requests From DB

    RETURN    ${time_off_required_days}    ${sys_min_lead_time}

Get System Minimum Lead Time For Requests From DB
    [Documentation]    Gets the system minimum lead time (SYS_MIN_LEAD_TIME) in days from DB for the configured owner.
    ...    Returns empty when the value is not configured or is set to 0.
    ...    | =Arguments= | =Description= |
    ...    | None | This keyword does not take any arguments. |
    ...
    ...    | =Returns= | =Description= |
    ...    | value | Minimum lead time in days, or empty when not applicable. |
    ...    Example usage:
    ...    | ${sys_min_lead_time}=    Get System Minimum Lead Time For Requests From DB
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${min_lead_time_query}    Catenate    SEPARATOR=${SPACE}
    ...    SELECT DEFAULT_VALUE
    ...    FROM RWSUSER.RWS_ATTR
    ...    WHERE NAME = 'SYS_MIN_LEAD_TIME'
    ...    AND entity_type = 'C'
    ...    AND OWNER_ID = '${owner_id}'
    ${min_lead_time_result}    Execute Query And Return Result    ${min_lead_time_query}
    IF    $min_lead_time_result and '${min_lead_time_result}[0][0]' != '0'
        RETURN    ${min_lead_time_result}[0][0]
    END
    RETURN    ${EMPTY}

Check If AVP Applicable From DB
    [Documentation]    Check if AVP is applicable for the configured environment owner from DB.
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${avp_db_query}    Catenate    SEPARATOR=${SPACE}
    ...    SELECT
    ...    CASE
    ...    WHEN EXISTS (
    ...    SELECT 1
    ...    FROM RWSUSER.CODE_VALUE cv
    ...    WHERE cv.CODESET_ID = 'ANNUAL_VACATION_REQUEST_TYPE'
    ...      AND cv.CODE_VALUE = 'AV'
    ...      AND cv.OWNER_ID = '${owner_id}'
    ...  )
    ...  AND EXISTS (
    ...    SELECT 1
    ...    FROM RWSUSER.CODE_SET cs
    ...    WHERE cs.CODESET_ID = 'ANNUAL_VACATION_EMP_GROUP'
    ...        AND cs.OWNER_ID = '${owner_id}'
    ...  )
    ...    AND EXISTS (
    ...    SELECT 1
    ...    FROM RWSUSER.RWS_REQUEST_TYPE rt
    ...    WHERE rt.REQUEST_TYPE_CODE = 'AV'
    ...        AND rt.OWNER_ID = '${owner_id}'
    ...  )
    ...    AND EXISTS (
    ...    SELECT 1
    ...    FROM RWSUSER.RVP_VACATION_PLAN p
    ...    WHERE p.OWNER_ID = '${owner_id}'
    ...    )
    ...        THEN 'True'
    ...        ELSE 'False'
    ...    END AS AVP_APPLICABLE
    ...    FROM SYSIBM.SYSDUMMY1
    ${avp_db_result}    Execute Query And Return Result    ${avp_db_query}
    Log    AVP Applicable DB Query: ${avp_db_result}
    RETURN    ${avp_db_result}[0][0]
