*** Settings ***
Documentation       This resource file contains keyword to perform db operations related to shift trade.

Resource            resources/web/common/database.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Utility.resource


*** Keywords ***
Get Request Number For Shift
    [Documentation]    Selects Request Number For Particular Shift Of User
    ...    The requests is identified by the system user ID, and effective date.
    ...    Args:
    ...    system_user_id (str): The system user ID example 10000001.
    ...    eff_date (str): The effective date in YYYY-MM-dd format example 2025-03-21.
    ...    request_type (str): The request type example AD(Advertise),AV(Available (Open)),SW(Swap),EW(Extra Work).
    ...    request_status (str): The request status example R.
    [Arguments]    ${system_user_id}    ${eff_date}    ${request_type}    ${request_status}
    VAR    ${query}    SELECT REQUEST_NO FROM ESS_EMP_REQUEST WHERE OWNER_ID=${DB2_OWNER_ID}
    ...    AND REQUEST_TYPE='${request_type}'
    ...    AND REQUESTOR_ID IN (SELECT person_id FROM RWS_EMPLOYEE WHERE OWNER_ID=${DB2_OWNER_ID}
    ...    AND SYSTEM_USER_id='${system_user_id}')
    ...    AND DATE(SHIFT_DATE) = DATE('${eff_date}')
    ...    AND REQUEST_STATUS ='${request_status}';
    ${result}    Execute Query And Return Result    ${query}
    RETURN    ${result}

Get Request Number For Open Shift
    [Documentation]    Selects Request Number For Particular Shift Of User
    ...    The requests is identified by the system user ID, and effective date.
    ...    Args:
    ...    system_user_id (str): The system user ID example 10000001.
    ...    eff_date (str): The effective date in YYYY-MM-dd format example 2025-03-21.
    ...    response_date (str): The response date in YYYY-MM-dd format example 2025-03-21.
    ...    start_time (str): The start time in 24 hour format example 17:15.
    ...    end_time (str): The end time in 24 hour format example 21:15.
    ...    request_type (str): The request type example AD(Advertise),AV(Available (Open)),SW(Swap),EW(Extra Work).
    [Arguments]    ${system_user_id}    ${eff_date}    ${response_date}    ${start_time}    ${end_time}    ${request_type}=AV
    ${start_time_converted}    Convert 24 Hour Time To Total Minutes    ${start_time}
    ${end_time_converted}    Convert 24 Hour Time To Total Minutes    ${end_time}
    VAR    ${query}    SELECT resp.REQUEST_NO FROM ESS_EMP_RESPONSE resp INNER JOIN ESS_EMP_REQUEST req
    ...    ON req.OWNER_ID = resp.OWNER_ID AND req.REQUEST_NO = resp.REQUEST_NO AND req.REQUEST_TYPE ='${request_type}'
    ...    WHERE req.OWNER_ID=${DB2_OWNER_ID}
    ...    AND DATE(req.SHIFT_DATE) = DATE('${eff_date}')
    ...    AND req.START_TIME = ${start_time_converted}
    ...    AND req.END_TIME = ${end_time_converted}
    ...    AND resp.RESPONDER_ID IN (SELECT person_id FROM RWS_EMPLOYEE WHERE OWNER_ID=${DB2_OWNER_ID}
    ...    AND SYSTEM_USER_id='${system_user_id}')
    ...    AND DATE(resp.RESPONSE_DATE) = DATE('${response_date}');
    ${result}    Execute Query And Return Result    ${query}
    RETURN    ${result}
