*** Settings ***
Documentation       This resource file contains keyword to perform db operations related to requests.

Resource            resources/web/common/database.resource


*** Keywords ***
Select Requests For User On Date From DB
    [Documentation]    Selects all requests from the database.
    ...    The requests are identified by the system user ID, effective date and end date.
    ...    Args:
    ...    system_user_id (str): The system user ID example 10000001.
    ...    eff_date (str): The effective date in YYYY-MM-dd format example 2025-03-21.
    ...    end_date (str): The end date in YYYY-MM-dd format example 2025-03-22.
    [Arguments]    ${system_user_id}    ${eff_date}    ${end_date}=${None}
    ${owner_id}    Get Config Value    key=OWNER_ID
    IF    $end_date == $None
        VAR    ${query}    SELECT PERSON_ID, EFF_DATE, START_TIME, REQ_STATUS_CD, REQUEST_NO
        ...    FROM RWS_EMP_AVAILABLE
        ...    WHERE PERSON_ID IN (SELECT PERSON_ID FROM RWS_EMPLOYEE
        ...    WHERE SYSTEM_USER_ID='${system_user_id}' AND OWNER_ID='${owner_id}')
        ...    AND DATE(EFF_DATE) = DATE('${eff_date}')
        ...    AND OWNER_ID='${owner_id}'
    ELSE
        VAR    ${query}    SELECT PERSON_ID, EFF_DATE, START_TIME, REQ_STATUS_CD, REQUEST_NO
        ...    FROM RWS_EMP_AVAILABLE
        ...    WHERE PERSON_ID IN (SELECT PERSON_ID FROM RWS_EMPLOYEE
        ...    WHERE SYSTEM_USER_ID='${system_user_id}' AND OWNER_ID='${owner_id}')
        ...    AND DATE(EFF_DATE) BETWEEN DATE('${eff_date}') AND DATE('${end_date}')
        ...    AND OWNER_ID='${owner_id}'
    END
    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}

Select Time Off Request From DB
    [Documentation]    Select specific time off request from the database.
    ...    Args:
    ...    ESS_PERSON_ID (str): Person id of user.
    ...    eff_date (str): The effective date in %Y-%m-%d format example 2025-03-21.
    ...    start_time (str): Start time of request.
    [Arguments]    ${ESS_PERSON_ID}    ${eff_date}    ${start_time}
    ${owner_id}    Get Config Value    OWNER_ID
    VAR    ${query}    SELECT REQUEST_NO FROM RWS_EMP_AVAILABLE
    ...    WHERE OWNER_ID=${owner_id}
    ...    AND
    ...    AVAIL_CD='T'
    ...    AND
    ...    REQ_STATUS_CD='R'
    ...    and
    ...    person_id=${ESS_PERSON_ID}
    ...    AND date(EFF_DATE)=DATE('${eff_date}')
    ...    AND START_TIME=('${start_time}');
    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}

Select Day Off Request From DB
    [Documentation]    Select specific day off request from the database.
    ...    Args:
    ...    ESS_PERSON_ID (str): Person id of user.
    ...    eff_date (str): The effective date in %Y-%m-%d format example 2025-03-21.
    [Arguments]    ${ESS_PERSON_ID}    ${eff_date}
    ${owner_id}    Get Config Value    OWNER_ID
    VAR    ${query}    SELECT REQUEST_NO FROM RWS_EMP_AVAILABLE
    ...    WHERE OWNER_ID=${owner_id}
    ...    AND
    ...    AVAIL_CD='D'
    ...    AND
    ...    REQ_STATUS_CD='R'
    ...    and
    ...    person_id=${ESS_PERSON_ID}
    ...    AND date(EFF_DATE)=DATE('${eff_date}');
    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}
