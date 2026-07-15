*** Settings ***
Documentation
...                 This resource file provides keywords for interacting with the database to validate
...                 Driver Forecast configuration thresholds in the RWS_FORECAST_LIMIT table.
...
...                 = Purpose =
...                 - Retrieve whether the driver forecast edit threshold condition is met for a given driver
...                 before proceeding with forecast value edits in the Driver Forecast test suite.
...
...                 = Prerequisites =
...                 - Database connection must be configured for the target environment.
...                 - Required resources and variable files must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Verify Driver Forecast Threshold Before Edit
...                 |    ${threshold_met}=    Retrieve Forecast Threshold From Database    ${driver_id}
...                 |    Skip If    not ${threshold_met}    Edit threshold not met for driver ${driver_id}

Resource            resources/web/common/common.resource
Resource            resources/web/common/database.resource


*** Variables ***
${DRIVER_FORECAST_THRESHOLD_QUERY}
...                                     SELECT CONFIG_ID, ORG_LEVEL, MAX_ADJ_WOA
...                                     FROM RWS_FORECAST_LIMIT
...                                     WHERE OWNER_ID = {OWNER_ID}
...                                     AND CONFIG_ID = '{CONFIG_ID}'
...                                     AND ORG_LEVEL = '1'
...                                     AND MAX_ADJ_WOA >= 10
...                                     AND USER_FLD_03 LIKE '%D%'


*** Keywords ***
Retrieve Forecast Threshold From Database
    [Documentation]
    ...    Checks whether the edit threshold condition is met for the given driver ID in the
    ...    RWS_FORECAST_LIMIT table. Returns True if a matching row exists, False otherwise.
    ...    | =Arguments= | =Description= |
    ...    | driver_id | The driver config ID discovered at runtime (maps to CONFIG_ID column) |
    ...    | =Returns= | =Description= |
    ...    | ${True} | When a row satisfying the threshold condition exists for the given driver and owner |
    ...    | ${False} | When no matching row is found (threshold not met) |
    ...    Example usage:
    ...    | ${threshold_met}=    Retrieve Forecast Threshold From Database    ${driver_id}
    [Arguments]    ${driver_id}
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${db_query}    Replace String    ${DRIVER_FORECAST_THRESHOLD_QUERY}    {OWNER_ID}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {CONFIG_ID}    ${driver_id}
    Log    Executing driver forecast threshold check query: ${db_query}
    ${result}    Execute Query And Return Result    ${db_query}
    Log    Driver forecast threshold check result: ${result}
    ${result_length}    Get Length    ${result}
    ${threshold_met}    Evaluate    ${result_length} > 0
    RETURN    ${threshold_met}
