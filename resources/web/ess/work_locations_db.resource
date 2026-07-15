*** Settings ***
Documentation       Resource file for ESS Work Locations page DB queries.

Resource            resources/web/common/database.resource


*** Keywords ***
Check If Store Has Alternate Work Location Share Requests In DB
    [Documentation]    Checks if there are any alternate work location share requests for the store in the database.
    ...    | =Arguments=    | =Description=    |
    ...    | store_unit    | Store unit for which to check alternate work location share requests    |
    ...    | effective_date_offset    | Effective date offset in offset week_date format to check against    |
    ...    | end_date_offset    | End date offset in offset week_date format to check against    |
    [Arguments]    ${store_unit}    ${effective_date_offset}    ${end_date_offset}
    ${db_date_format}    Get Config Value    key=SERVER_DF
    ${effective_date}    Calculate Date From Week Day Offset    ${effective_date_offset}    ${db_date_format}
    ${end_date}    Calculate Date From Week Day Offset    ${end_date_offset}    ${db_date_format}
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${alternate_location_share_request_query}    Catenate    SEPARATOR=${SPACE}
    ...    SELECT *
    ...    FROM RWSUSER.RWS_EMP_SHARE_REQUEST_DETAILS resr
    ...    WHERE OWNER_ID = ${owner_id}
    ...    AND REQUEST_NO IN (
    ...        SELECT REQUEST_NO
    ...        FROM RWSUSER.RWS_EMP_SHARE_REQUEST_DETAILS resrd
    ...        WHERE OWNER_ID = ${owner_id}
    ...        AND UNIT_ID = '${store_unit}'
    ...        AND EFF_DATE_SKEY < ${effective_date}
    ...        AND END_DATE_SKEY > ${end_date}
    ...    )

    ${alternate_location_share_request_result}    Execute Query And Return Result    ${alternate_location_share_request_query}
    ${result_length}    Get Length    ${alternate_location_share_request_result}
    IF    ${result_length} > 0    RETURN    True
    RETURN    False

Check If Alternate Work Location Feature Enabled For Store In DB
    [Documentation]    Checks if the alternate work location feature is enabled for the store in the database.
    ...    | =Arguments=    | =Description=    |
    ...    | store_unit    | Store unit for which to check alternate work location feature status    |
    ${owner_id}    Get Config Value    key=OWNER_ID
    ${alternate_location_feature_query}    Catenate    SEPARATOR=${SPACE}
    ...    SELECT FEATURE_VALUE
    ...    FROM RWSUSER.PRODUCT_FEATURE
    ...    WHERE FEATURE_ID = 'ENABLE_CROSS_SITE'
    ...    AND OWNER_ID = '${owner_id}'
    ${alternate_location_feature_result}    Execute Query And Return Result    ${alternate_location_feature_query}
    ${result_length}    Get Length    ${alternate_location_feature_result}
    IF    ${result_length} > 0
        VAR    ${feature_value}    ${alternate_location_feature_result}[0][0]
        IF    '${feature_value}' == 'Y'
            RETURN    True
        ELSE
            RETURN    False
        END
    ELSE
        RETURN    False
    END
