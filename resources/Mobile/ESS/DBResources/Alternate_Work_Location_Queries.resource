*** Settings ***
Documentation       This resource file contains keyword to perform db operations related to alternate work location request.

Resource            resources/web/common/database.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Utility.resource


*** Keywords ***
Select Alternate Work Location Request From DB
    [Documentation]    Select a request from the database.
    ...    Args:
    ...    system_user_id (str): The system user ID example 10000001.
    ...    eff_date (str): The effective date in YYYYMMdd format example 20250321.
    ...    end_date (str): The end date in YYYYMMdd format example 20250321.
    [Arguments]    ${system_user_id}    ${eff_date}    ${end_date}
    VAR    ${query}
    ...    SELECT DET.*
    ...    FROM RWS_EMP_SHARE_REQUEST REQ
    ...    INNER JOIN RWS_EMP_SHARE_REQUEST_DETAILS DET
    ...    ON REQ.OWNER_ID = DET.OWNER_ID
    ...    AND REQ.REQUEST_NO = DET.REQUEST_NO
    ...    WHERE REQ.OWNER_ID = ${DB2_OWNER_ID}
    ...    AND DET.EFF_DATE_SKEY = ${eff_date}
    ...    AND DET.END_DATE_SKEY = ${end_date}
    ...    AND REQ.PERSON_ID = (
    ...    SELECT PERSON_ID
    ...    FROM RWS_EMPLOYEE
    ...    WHERE system_user_id = '${system_user_id}'
    ...    AND OWNER_ID = ${DB2_OWNER_ID}
    ...    );
    ...    separator=${SPACE}

    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}

Update Alternate Work Location Request In DB
    [Documentation]    Update a request in the database.
    ...    Args:
    ...    req_no (str): The request number from DB.
    ...    mapping_no (str): The mapping number from DB.
    ...    source_store_status (str): The source store status to update 'A' for approved 'D' for declined.
    ...    destination_store_status (str): The destination store status to update 'A' for approved 'D' for declined default N in case of 2 step approval is disabled.
    [Arguments]    ${req_no}    ${mapping_no}    ${source_store_status}    ${destination_store_status}=N

    VAR    ${query}
    ...    UPDATE RWS_EMP_SHARE_REQUEST_DETAILS DET
    ...    SET DET.SOURCE_STORE_STATUS='${source_store_status}',DET.DEST_STORE_STATUS ='${destination_store_status}'
    ...    WHERE DET.OWNER_ID = ${DB2_OWNER_ID}
    ...    AND DET.REQUEST_NO= ${req_no}
    ...    AND DET.MAPPING_NO =${mapping_no};

    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}

Approve Partially Alternate Work Location For All Store Request On DB
    [Documentation]    Approves a alternate work location request which is raised only for 1 store to work, also wirth 1 step approval.
    ...    Args:
    ...    ess_user_key (str): user key of the ess user of request.
    ...    eff_pwd (PWD): the start date of request.
    ...    end_pwd (PWD): the end date of request.
    ...    is_two_step_approval (bool): True if 2 step approval is enabled, False if 2 step approval is disabled.
    [Arguments]    ${ess_user_key}    ${eff_pwd}    ${end_pwd}
    ${ess_user}    Get User    ${ess_user_key}
    ${eff_date_skey}    Get Formatted Date    ${eff_pwd}    SERVER_DF
    ${end_date_skey}    Get Formatted Date    ${end_pwd}    SERVER_DF
    ${results}    Select Alternate Work Location Request From DB    ${ess_user}[USER_ID]    ${eff_date_skey}    ${end_date_skey}
    ${list_length}    Get Length    ${results}
    IF    ${list_length} > 0
        FOR    ${index}    IN RANGE    ${list_length}
            ${result}    Get From List    ${results}    ${index}
            ${request_no}    Get From Dictionary    ${result}    REQUEST_NO
            ${mapping_no}    Get From Dictionary    ${result}    MAPPING_NO
            ${status}    Set Variable If    ${index} % 2 == 0    A    D
            Update Alternate Work Location Request In DB    ${request_no}    ${mapping_no}    ${status}    ${status}
        END
    ELSE
        Log    No request found for ${ess_user}[USER_ID] on ${eff_date_skey} to approve.
    END

Decline Partially Alternate Work Location For Single Store Request On DB
    [Documentation]    Decline a alternate work location request which is raised only for 1 store to work, also wirth 1 step approval.
    ...    Args:
    ...    ess_user_key (str): user key of the ess user of request.
    ...    eff_pwd (PWD): the start date of request.
    ...    end_pwd (PWD): the end date of request.
    ...    is_two_step_approval (bool): True if 2 step approval is enabled, False if 2 step approval is disabled.
    [Arguments]    ${ess_user_key}    ${eff_pwd}    ${end_pwd}
    ${ess_user}    Get User    ${ess_user_key}
    ${eff_date_skey}    Get Formatted Date    ${eff_pwd}    SERVER_DF
    ${end_date_skey}    Get Formatted Date    ${end_pwd}    SERVER_DF
    ${results}    Select Alternate Work Location Request From DB    ${ess_user}[USER_ID]    ${eff_date_skey}    ${end_date_skey}
    ${list_length}    Get Length    ${results}
    IF    ${list_length} > 0
        ${request_no}    Get From Dictionary    ${results[0]}    REQUEST_NO
        ${mapping_no}    Get From Dictionary    ${results[0]}    MAPPING_NO
        Update Alternate Work Location Request In DB    ${request_no}    ${mapping_no}    D    D
    ELSE
        Log    No request found for ${ess_user}[USER_ID] on ${eff_date_skey} to decline.
    END

Approve All Alternate Work Location Request For Stores On DB
    [Documentation]    Approves a alternate work location request which is raised for multiple stores to work, also wirth 2 step approval.
    ...    Args:
    ...    ess_user_key (str): user key of the ess user of request.
    ...    eff_pwd (PWD): the start date of request.
    ...    end_pwd (PWD): the end date of request.
    ...    is_two_step_approval (bool): True if 2 step approval is enabled, False if 2 step approval is disabled.
    [Arguments]    ${ess_user_key}    ${eff_pwd}    ${end_pwd}
    ${ess_user}    Get User    ${ess_user_key}
    ${eff_date_skey}    Get Formatted Date    ${eff_pwd}    SERVER_DF
    ${end_date_skey}    Get Formatted Date    ${end_pwd}    SERVER_DF
    ${results}    Select Alternate Work Location Request From DB    ${ess_user}[USER_ID]    ${eff_date_skey}    ${end_date_skey}
    ${list_length}    Get Length    ${results}
    FOR    ${result}    IN    @{results}
        ${request_no}    Get From Dictionary    ${result}    REQUEST_NO
        ${mapping_no}    Get From Dictionary    ${result}    MAPPING_NO
        Update Alternate Work Location Request In DB    ${request_no}    ${mapping_no}    A    A
    END
    IF    ${list_length} = 0
        Log    No request found for ${ess_user}[USER_ID] on ${eff_date_skey} to approve.
    END

Decline All Alternate Work Location Request For Stores On DB
    [Documentation]    Decline a alternate work location request which is raised for multiple stores to work, also wirth 2 step approval.
    ...    Args:
    ...    ess_user_key (str): user key of the ess user of request.
    ...    eff_pwd (PWD): the start date of request.
    ...    end_pwd (PWD): the end date of request.
    ...    is_two_step_approval (bool): True if 2 step approval is enabled, False if 2 step approval is disabled.
    [Arguments]    ${ess_user_key}    ${eff_pwd}    ${end_pwd}
    ${ess_user}    Get User    ${ess_user_key}
    ${eff_date_skey}    Get Formatted Date    ${eff_pwd}    SERVER_DF
    ${end_date_skey}    Get Formatted Date    ${end_pwd}    SERVER_DF
    ${results}    Select Alternate Work Location Request From DB    ${ess_user}[USER_ID]    ${eff_date_skey}    ${end_date_skey}
    FOR    ${result}    IN    @{results}
        ${request_no}    Get From Dictionary    ${result}    REQUEST_NO
        ${mapping_no}    Get From Dictionary    ${result}    MAPPING_NO
        Update Alternate Work Location Request In DB    ${request_no}    ${mapping_no}    D    D
    END
    ${list_length}    Get Length    ${results}
    IF    ${list_length} = 0
        Log    No request found for ${ess_user}[USER_ID] on ${eff_date_skey} to decline.
    END

Approve Decline And Keep Pending Alternate Work Location For All Store Request On DB
    [Documentation]    Keeps location at 0th index pending, Approves and Declines rest (1 step approval).
    ...    Args:
    ...    ess_user_key (str): user key of the ess user of request.
    ...    eff_pwd (PWD): the start date of request.
    ...    end_pwd (PWD): the end date of request.
    ...    is_two_step_approval (bool): True if 2 step approval is enabled, False if 2 step approval is disabled.
    [Arguments]    ${ess_user_key}    ${eff_pwd}    ${end_pwd}
    ${ess_user}    Get User    ${ess_user_key}
    ${eff_date_skey}    Get Formatted Date    ${eff_pwd}    SERVER_DF
    ${end_date_skey}    Get Formatted Date    ${end_pwd}    SERVER_DF
    ${results}    Select Alternate Work Location Request From DB    ${ess_user}[USER_ID]    ${eff_date_skey}    ${end_date_skey}
    ${list_length}    Get Length    ${results}
    IF    ${list_length} > 0
        FOR    ${index}    IN RANGE    ${list_length}
            ${result}    Get From List    ${results}    ${index}
            IF    ${index} = 0    CONTINUE
            ${request_no}    Get From Dictionary    ${result}    REQUEST_NO
            ${mapping_no}    Get From Dictionary    ${result}    MAPPING_NO
            ${status}    Set Variable If    ${index} % 2 = 0    A    D
            Update Alternate Work Location Request In DB    ${request_no}    ${mapping_no}    ${status}    ${status}
        END
    ELSE
        Log    No request found for ${ess_user}[USER_ID] on ${eff_date_skey} to approve.
    END
