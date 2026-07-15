*** Settings ***
Documentation       Resource file containing keywords to interact with unit database.

Resource            resources/web/common/database.resource


*** Keywords ***
Get Unit Details From UnitId Via DB
    [Documentation]    Retrieves unit details from the database using the provided unit ID.
    ...    | =Arguments= | =Description= |
    ...    | unit_id | The unique identifier for the unit. |
    [Arguments]    ${unit_id}
    ${owner_id}=    Get Config Value    key=OWNER_ID
    VAR    ${query}=
    ...    SELECT unit_skey, unit_id, unit_name, time_zone FROM unit WHERE    owner_id = '${owner_id}' AND unit_id='${unit_id}';
    ${db_result}=    Execute Query And Return Result    ${query}
    VAR    &{result_dic}=
    ...    unit_skey=${db_result}[0][0]
    ...    unit_id=${db_result}[0][1]
    ...    unit_name=${db_result}[0][2]
    ...    time_zone=${db_result}[0][3]
    Log    Retrieved Unit Details: ${db_result}
    Log    result dictionary : ${result_dic}
    RETURN    ${result_dic}
