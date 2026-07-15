*** Settings ***
Documentation       WFM Product SIT Test Suite

Resource            resources/web/common/database.resource


*** Keywords ***
Select Punches For User On Date
    [Documentation]    Selects all punches from the database.
    ...    The punches are identified by the system user ID, and effective date.
    ...    Args:
    ...    system_user_id (str): The system user ID example 10000001.
    ...    eff_date (str): The effective date in YYYYMMdd format example 20250323.
    [Arguments]    ${system_user_id}    ${eff_date}

    VAR    ${query}    SELECT * FROM TA_ADJ_PUNCH WHERE OWNER_ID=${DB2_OWNER_ID}
    ...    AND PUNCH_DATE =${eff_date}
    ...    AND PERSON_ID IN (SELECT PERSON_ID FROM RWS_EMPLOYEE WHERE OWNER_ID=${DB2_OWNER_ID}
    ...    AND system_user_id='${system_user_id}');
    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}

Delete Raw Punches For User On Date
    [Documentation]    Selects all punches from the database.
    ...    The punches are identified by the system user ID, and effective date.
    ...    Args:
    ...    system_user_id (str): The system user ID example 10000001.
    ...    eff_date (str): The effective date in YYYYMMdd format example 20250323.
    [Arguments]    ${system_user_id}    ${eff_date}

    VAR    ${query}    DELETE FROM TA_PUNCH WHERE OWNER_ID=${DB2_OWNER_ID}
    ...    AND PUNCH_DATE =${eff_date}
    ...    AND PERSON_ID IN (SELECT PERSON_ID FROM RWS_EMPLOYEE WHERE OWNER_ID=${DB2_OWNER_ID}
    ...    AND system_user_id='${system_user_id}');
    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}
