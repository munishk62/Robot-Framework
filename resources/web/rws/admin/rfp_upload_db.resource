*** Settings ***
Documentation       Resource file containing keywords to interact with unit database.

Resource            resources/web/common/common.resource
Resource            resources/web/common/database.resource


*** Variables ***
${CLIENT_ID_BY_STORE_METRIC_GROUP}          SELECT CLIENT_ID FROM RWS_METRIC rm WHERE rm.OWNER_ID = {OWNER_ID} AND rm.METRIC_GRANLRTY = 'Minute' AND rm.METRIC_GROUP ='Store' AND rm.METRIC_CATEGORY != 'E';
${METRIC_ID_FOR_NON_DEPARTMENT_DRIVER}      SELECT METRIC_ID FROM RWS_METRIC rm WHERE rm.OWNER_ID={OWNER_ID} AND rm.METRIC_GRANLRTY = 'Minute' AND rm.METRIC_GROUP ='Store' AND rm.METRIC_CATEGORY != 'E';


*** Keywords ***
Retrieve Client Id For RFP Upload Via DB
    [Documentation]    Retrieves client ID for RFP upload from the database.
    ...    Returns ${None} if no matching record is found, allowing the calling test to decide
    ...    whether to Skip, Fail, or handle the missing data appropriately.
    ...
    ...    | =Arguments= | =Description= |
    ...    | None | This keyword does not require any arguments. |
    ...
    ...    | =Returns= | =Description= |
    ...    | client_id | Client ID for RFP upload if found, or ${None} if no record exists |
    ...
    ...    | =Example Usage= |
    ...    | ${client_id}= | Retrieve Client Id For RFP Upload Via DB |
    ...    | IF | ${client_id} is not ${None} |
    ...    | | Log | Client ID: ${client_id} |
    ...    | ELSE |
    ...    | | Skip | No client ID found for RFP upload |
    ...    | END |
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${db_query}    Replace String    ${CLIENT_ID_BY_STORE_METRIC_GROUP}    {OWNER_ID}    ${owner_id}
    ${db_result}    Execute Query And Return Result    ${db_query}
    Log    Retrieved client id for RFP upload: ${db_result}

    # Check if query returned any results
    IF    not ${db_result}
        Log    No client ID found for RFP upload
        Skip    No client ID found for RFP upload
    END

    RETURN    ${db_result}[0][0]

Retrieve Metric Ids For Non Department Driver Via DB
    [Documentation]    Retrieves metric IDs for non-department driver from the database.
    ...    Returns ${None} if no matching record is found, allowing the calling test to decide
    ...    whether to Skip, Fail, or handle the missing data appropriately.
    ...
    ...    | =Arguments= | =Description= |
    ...    | None | This keyword does not require any arguments. |
    ...
    ...    | =Returns= | =Description= |
    ...    | metric_id | Metric ID for non-department driver if found, or ${None} if no record exists |
    ...
    ...    | =Example Usage= |
    ...    | ${metric_ids}= | Retrieve Metric Ids For Non Department Driver Via DB |
    ...    | IF | ${metric_id} is not ${None} |
    ...    | | Log | Metric ID: ${metric_id} |
    ...    | ELSE |
    ...    | | Skip | No metric ID found for non-department driver |
    ...    | END |
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${db_query}    Replace String    ${METRIC_ID_FOR_NON_DEPARTMENT_DRIVER}    {OWNER_ID}    ${owner_id}
    ${db_result}    Execute Query And Return Result    ${db_query}
    Log    Retrieved metric id for non-department driver: ${db_result}

    # Check if query returned any results
    IF    not ${db_result}
        Log    No metric ID found for non-department driver
        Skip    No metric ID found for non-department driver
    END
    ${metric_ids}    Evaluate    [row[0] for row in $db_result]
    RETURN    ${metric_ids}
