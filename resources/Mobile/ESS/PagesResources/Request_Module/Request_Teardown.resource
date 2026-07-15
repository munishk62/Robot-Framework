*** Settings ***
Documentation       This resource file contains teardown keywords for cleaning up request test data.
...                 It queries DB for existing requests and deletes them via API to ensure a clean state.

Library             Collections
Library             DateTime
Resource            resources/web/common/database.resource
Resource            resources/api/api_executor.resource
Resource            resources/Mobile/ESS/DBResources/Request_Queries.resource
Variables           resources/api/api_endpoints.py


*** Keywords ***
Clean Up All Requests For User On Date
    [Documentation]    Gets request data from Database and deletes each request via API.
    ...    Uses SM user credentials to authenticate and delete requests for the given ESS user.
    ...    | =Arguments= | =Description= |
    ...    | ess_user_key | The ESS user key from credentials (e.g., ESS5_STORE1). |
    ...    | sm_user_key | The SM user key for API authentication (e.g., SM1_STORE1). |
    ...    | start_date_offset | The start date in week_day offset format (e.g., 6_1). |
    ...    | end_date_offset | The end date in week_day offset format (e.g., 6_3). Optional, defaults to `${None}`. |
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${start_date_offset}    ${end_date_offset}=${None}

    ${ess_user}    Get User    ${ess_user_key}    mask_password=False
    ${eff_date}    Calculate Date From Week Day Offset    ${start_date_offset}    %Y-%m-%d
    IF    $end_date_offset != $None
        ${end_date}    Calculate Date From Week Day Offset    ${end_date_offset}    %Y-%m-%d
    ELSE
        VAR    ${end_date}    ${None}
    END

    ${results}    Select Requests For User On Date From DB    ${ess_user}[username]    ${eff_date}    ${end_date}
    ${list_length}    Get Length    ${results}
    IF    ${list_length} > 0
        Generate Auth Token With User Credentials    ${sm_user_key}
        Send A Post Request    ${RWS_INIT_SESSION}
        FOR    ${row}    IN    @{results}
            VAR    ${person_id}    ${row}[0]
            ${request_eff_date}    Convert Date    ${row}[1]    result_format=%Y%m%d
            VAR    ${start_time}    ${row}[2]
            VAR    ${req_status_cd}    ${row}[3]
            VAR    ${request_no}    ${row}[4]
            IF    ${start_time}
                Send A Delete Request    ${sm_delete_time_off_request}    ${person_id}    ${request_eff_date}
                ...    ${start_time}    ${req_status_cd}    ${request_no}
            ELSE
                Send A Delete Request    ${SM_DELETE_DAY_OFF_REQUEST}    ${person_id}    ${request_eff_date}
                ...    ${req_status_cd}    ${request_no}
            END
        END
    ELSE
        Log    No requests found for ${ess_user}[username] on ${eff_date} to cleanup
    END

Clean Up Day Off Request For User On Date
    [Documentation]    Cleans up day off requests for a user on a date range.
    ...    Queries the DB for all requests between start and end date, filters day-off (START_TIME=0), and deletes via API.
    ...    | =Arguments= | =Description= |
    ...    | ess_user_key | The ESS user key from credentials (e.g., ESS5_STORE1). |
    ...    | sm_user_key | The SM user key for API authentication (e.g., SM1_STORE1). |
    ...    | start_date_offset | The start date in week_day offset format (e.g., 6_1). |
    ...    | end_date_offset | The end date in week_day offset format (e.g., 6_3). Optional, defaults to `${None}`. |
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${start_date_offset}    ${end_date_offset}=${None}

    ${ess_user}    Get User    ${ess_user_key}    mask_password=False
    ${eff_date}    Calculate Date From Week Day Offset    ${start_date_offset}    %Y-%m-%d
    IF    $end_date_offset != $None
        ${end_date}    Calculate Date From Week Day Offset    ${end_date_offset}    %Y-%m-%d
    ELSE
        VAR    ${end_date}    ${None}
    END

    ${results}    Select Requests For User On Date From DB    ${ess_user}[username]    ${eff_date}    ${end_date}

    ${list_length}    Get Length    ${results}
    IF    ${list_length} > 0
        Generate Auth Token With User Credentials    ${sm_user_key}
        Send A Post Request    ${RWS_INIT_SESSION}
        FOR    ${row}    IN    @{results}
            VAR    ${start_time}    ${row}[2]
            IF    not ${start_time}
                VAR    ${person_id}    ${row}[0]
                ${request_eff_date}    Convert Date    ${row}[1]    result_format=%Y%m%d
                VAR    ${req_status_cd}    ${row}[3]
                VAR    ${request_no}    ${row}[4]
                Send A Delete Request    ${SM_DELETE_DAY_OFF_REQUEST}    ${person_id}    ${request_eff_date}
                ...    ${req_status_cd}    ${request_no}
            END
        END
    ELSE
        Log    No day off request found for ${ess_user}[username] on ${eff_date} to cleanup
    END

Clean Up Time Off Request For User On Date
    [Documentation]    Cleans up time off requests for a user on a date range.
    ...    Queries the DB for all requests between start and end date, filters time-off (START_TIME!=0), and deletes via API.
    ...    | =Arguments= | =Description= |
    ...    | ess_user_key | The ESS user key from credentials (e.g., ESS5_STORE1). |
    ...    | sm_user_key | The SM user key for API authentication (e.g., SM1_STORE1). |
    ...    | start_date_offset | The start date in week_day offset format (e.g., 6_2). |
    ...    | end_date_offset | The end date in week_day offset format (e.g., 6_5). Optional, defaults to ${None}. |
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${start_date_offset}    ${end_date_offset}=${None}

    ${ess_user}    Get User    ${ess_user_key}    mask_password=False
    ${eff_date}    Calculate Date From Week Day Offset    ${start_date_offset}    %Y-%m-%d
    IF    $end_date_offset != $None
        ${end_date}    Calculate Date From Week Day Offset    ${end_date_offset}    %Y-%m-%d
    ELSE
        VAR    ${end_date}    ${None}
    END

    ${results}    Select Requests For User On Date From DB    ${ess_user}[username]    ${eff_date}    ${end_date}

    ${list_length}    Get Length    ${results}
    IF    ${list_length} > 0
        Generate Auth Token With User Credentials    ${sm_user_key}
        Send A Post Request    ${RWS_INIT_SESSION}
        FOR    ${row}    IN    @{results}
            VAR    ${start_time}    ${row}[2]
            IF    ${start_time}
                VAR    ${person_id}    ${row}[0]
                ${request_eff_date}    Convert Date    ${row}[1]    result_format=%Y%m%d
                VAR    ${req_status_cd}    ${row}[3]
                VAR    ${request_no}    ${row}[4]
                Send A Delete Request    ${sm_delete_time_off_request}    ${person_id}    ${request_eff_date}
                ...    ${start_time}    ${req_status_cd}    ${request_no}
            END
        END
    ELSE
        Log    No time off request found for ${ess_user}[username] on ${eff_date} to cleanup
    END
