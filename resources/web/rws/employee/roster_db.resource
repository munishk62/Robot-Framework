*** Settings ***
Documentation       Resource file containing keywords to interact with unit database.

Resource            resources/web/common/common.resource
Resource            resources/web/common/database.resource
Variables           resources/web/rws/employee/roster_db_queries.py


*** Keywords ***
Get Associate StaffGroupId From PersonId Via DB
    [Documentation]    Retrieves staff group ID from the database using the provided person ID.
    ...    Returns ${None} if no matching record is found, allowing the calling test to decide
    ...    whether to Skip, Fail, or handle the missing data appropriately.
    ...
    ...    | =Arguments= | =Description= |
    ...    | person_id | The unique identifier for the person. |
    ...
    ...    | =Returns= | =Description= |
    ...    | staff_group_id | Staff group ID if found, or ${None} if no record exists for the person ID |
    ...
    ...    | =Example Usage= |
    ...    | ${staff_group_id}= | Get Associate StaffGroupId From PersonId Via DB | 12345 |
    ...    | IF | ${staff_group_id} is not ${None} |
    ...    | | Log | Staff group ID: ${staff_group_id} |
    ...    | ELSE |
    ...    | | Skip | No staff group found for person ID 12345 |
    ...    | END |
    [Arguments]    ${person_id}
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${db_query}    Replace String    ${ROSTER_STAFF_GROUP_ID_BY_PERSON_ID}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {PERSON_ID}    ${person_id}
    ${db_result}    Execute Query And Return Result    ${db_query}
    Log    Retrieved staffgroup id for person_id ${person_id}: ${db_result}

    # Check if query returned any results
    IF    not ${db_result}
        Log    No staff group found for person_id ${person_id}
        RETURN    ${None}
    END

    RETURN    ${db_result}[0][0]

Check If Reporting Hierarchy Enabled From DB
    [Documentation]    Keyword to execute query to fetch whether reporting hierarchy is enabled from DB
    ${owner_id}    Get Config Value    OWNER_ID
    VAR    ${reporting_hierarchy_query}
    ...    SELECT FEATURE_VALUE FROM PRODUCT_FEATURE WHERE FEATURE_ID IN ('ENABLE_REPORTING_HIERARCHY')
    ...    AND OWNER_ID = '${owner_id}'
    ${report_hierarchy_db_result}    Execute Query And Return Result    ${reporting_hierarchy_query}
    # Return False when the feature flag is not configured for the owner.
    IF    not ${report_hierarchy_db_result}
        Log
        ...    Reporting hierarchy feature flag row was not found for owner_id ${owner_id}. Returning False.
        RETURN    False
    END
    ${first_row}    Get From List    ${report_hierarchy_db_result}    0
    ${report_hierarchy_value}    Get From List    ${first_row}    0
    Log    Retrieved reporting hierarchy feature flag value for owner_id ${owner_id}: ${report_hierarchy_value}
    ${is_reporting_hierarchy_enabled}    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${report_hierarchy_value}    Y
    RETURN    ${is_reporting_hierarchy_enabled}
