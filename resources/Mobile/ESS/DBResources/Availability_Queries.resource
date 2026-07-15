*** Settings ***
Documentation       This resource file contains keyword to perform db operations related to availability request.

Resource            resources/web/common/database.resource


*** Keywords ***
Select Permanent Availability Request From DB
    [Documentation]    Select a request from the database.
    ...    Args:
    ...    system_user_id (str): The system user ID of requester example 10000001.
    ...    eff_date (str): The effective date in YYYY-MM-dd format example 2025-03-23.
    [Arguments]    ${system_user_id}    ${eff_date}
    ${results}    Select Availability Request From DB    ${system_user_id}    ${eff_date}    P
    RETURN    ${results}

Select Temporary Availability Request From DB
    [Documentation]    Select a request from the database.
    ...    Args:
    ...    system_user_id (str): The system user ID of requester example 10000001.
    ...    eff_date (str): The effective date in YYYY-MM-dd format example 2025-03-23.
    [Arguments]    ${system_user_id}    ${eff_date}
    ${results}    Select Availability Request From DB    ${system_user_id}    ${eff_date}    T
    RETURN    ${results}

Select Availability Request From DB
    [Documentation]    Select a request from the database.
    ...    Args:
    ...    system_user_id (str): The system user ID of requester example 10000001.
    ...    eff_date (str): The effective date in YYYY-MM-dd format example 2025-03-23.
    ...    permanent_temp_ind (str): The permanent or temporary indicator P for permanent T for temporary.
    [Tags]    robot:private
    [Arguments]    ${system_user_id}    ${eff_date}    ${permanent_temp_ind}
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${query}    Catenate    SELECT * FROM RWS_EMP_AVL_DET WHERE PERM_TEMP_IND='${permanent_temp_ind}'
    ...    AND PERSON_ID IN (SELECT PERSON_ID FROM RWS_EMPLOYEE WHERE system_user_id='${system_user_id}'
    ...    AND OWNER_ID=${owner_id}) AND DATE(EFF_DATE) = DATE('${eff_date}') AND OWNER_ID=${owner_id};
    ${results}    Execute Query And Return Result In Dictionary JSON    ${query}
    RETURN    ${results}
