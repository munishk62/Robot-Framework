*** Settings ***
Documentation       This resource file contains keyword related to fetch DB data related to system users.

Resource            resources/web/common/database.resource
Library             Process
Library             String
Library             utils/common_utility/utility.py


*** Keywords ***
Select User Details From DB
    [Documentation]    Select user details from RWS_EMPLOYEE table.
    ...    The request is identified by store_id.
    ...    Args:
    ...    system_user_id (str): The system user ID example 10000005.
    [Arguments]    ${system_user_id}
    ${owner_id}    Get Config Value    key=OWNER_ID
    VAR    ${query}    SELECT * FROM RWS_EMPLOYEE WHERE OWNER_ID=${owner_id}
    ...    AND system_user_id='${system_user_id}';
    ${results}    Execute Query And Return Result In Dictionary JSON    ${query}
    RETURN    ${results}

Select Staff Group ID From DB
    [Documentation]    Select staff group ID from RWS_EMP_STAFF_GRP table.
    ...    The request is identified by store_id.
    ...    Args:
    ...    person_id (str): The person ID example 10000005.
    ...    unit_id (str): The unit ID example STORE14.
    [Arguments]    ${person_id}    ${unit_id}
    ${owner_id}    Get Config Value    key=OWNER_ID
    VAR    ${query}    SELECT STAFF_GROUP_ID FROM RWS_EMP_STAFF_GRP WHERE OWNER_ID=${owner_id}
    ...    AND PERSON_ID='${person_id}'
    ...    AND UNIT_ID='${unit_id}'
    ...    AND HOME='Y';
    ${results}    Execute Query And Return Result In Dictionary JSON    ${query}
    RETURN    ${results}
