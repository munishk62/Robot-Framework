*** Settings ***
Documentation       WFM Product SIT Test Suite

Resource            resources/web/common/database.resource


*** Keywords ***
Check If Work Pattern Already Exists
    [Documentation]    Check if work pattern already exists in the database.
    ...    The work pattern is identified by template name and status.
    ...    Args:
    ...    ${template_name} (str): The name of the template to be checked.
    ...    ${status} (str): The status of the template.
    [Arguments]    ${template_name}    ${status}
    VAR    ${query}    SELECT TEMPLATE_ID FROM RWS_SCHEDULE_TEMPLATE WHERE OWNER_ID=${DB2_OWNER_ID}
    ...    AND TEMPLATE_NAME ='${template_name}'
    ...    AND STATUS ='${status}';
    ${result}    Execute Query And Return Result    ${query}
    RETURN    ${result}

Check If Template Already Added
    [Documentation]    Check if template already exists in the database.
    ...    The work pattern is identified by template name and status.
    ...    Args:
    ...    ${user_id} (str): The user ID of the employee.
    ...    ${shift_type} (str): The type of shift (e.g. SC).
    ...    ${perm_temp_ind} (str): The indicator for permanent or temporary.
    [Arguments]    ${user_id}    ${work_pattern_id}    ${shift_type}=SC    ${perm_temp_ind}=P
    VAR    ${query}
    ...    SELECT ret.TEMPLATE_NO FROM RWS_EMP_TEMPLATE ret INNER JOIN RWS_TEMPLATE_APPLICABILITY rta ON ret.OWNER_ID = rta.OWNER_ID
    ...    AND RET.TEMPLATE_NO = rta.TEMPLATE_NO WHERE ret.OWNER_ID =${DB2_OWNER_ID}
    ...    AND ret.PERSON_ID IN (SELECT PERSON_ID FROM RWS_EMPLOYEE WHERE OWNER_ID =${DB2_OWNER_ID}
    ...    AND SYSTEM_USER_id='${user_id}')
    ...    AND ret.SHIFT_TYPE ='${shift_type}'
    ...    AND ret.PERM_TEMP_IND ='${perm_temp_ind}'
    ...    AND ret.SYS_DEF_GENERIC_TMPL_NO ='0'
    ...    AND rta.TEMPLATE_ID =${work_pattern_id}
    ...    AND rta.TEMPLATE_TYPE ='E';
    ${result}    Execute Query And Return Result    ${query}
    RETURN    ${result}
