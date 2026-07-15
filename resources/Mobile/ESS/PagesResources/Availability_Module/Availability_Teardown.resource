*** Settings ***
Documentation    This resource file contains keyword to teardown or setup operations related to availability request.

Library             Collections
Library             DateTime
Resource            resources/web/common/database.resource
Resource            resources/api/api_executor.resource
Resource            resources/Mobile/ESS/DBResources/Availability_Queries.resource
Resource            resources/Mobile/ESS/DBResources/User_Details_Queries.resource
Variables           resources/api/api_endpoints.py


*** Keywords ***
Clean Up Permanent Availability Request
    [Documentation]    Deletes a availability request from the database.
    ...    The request is identified by the system user ID and effective date.
    ...    The request is deleted from the RWS_EMP_AVL_DET table.
    ...    Args:
    ...    ess_user_key: The user key from users.csv file. eg. ESS-USER1.
    ...    sm_user_key: The user key from users.csv file. eg. SM-USER1.
    ...    eff_offset: The effective date in offset for e.g. 1_0.
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${eff_offset}
    ${ess_user}    Get User    ${ess_user_key}
    ${eff_date}    Calculate Date From Week Day Offset    ${eff_offset}    %Y-%m-%d
    ${results}    Select Permanent Availability Request From DB    ${ess_user}[username]    ${eff_date}
    ${list_length}    Get Length    ${results}
    IF    ${list_length} > 0
        ${request_no}    Get From Dictionary    ${results[0]}    REQUEST_NO

        Generate Auth Token With User Credentials    ${sm_user_key}
        Send A Post Request    ${rws_init_session}
        Send A Delete Request    ${sm_delete_availability_request}    ${request_no}
    ELSE
        Log    No request found for ${ess_user}[username] on ${eff_date} to cleanup
    END

Clean Up Temporary Availability Request
    [Documentation]    Deletes a availability request from the database.
    ...    The request is identified by the system user ID and effective date.
    ...    The request is deleted from the RWS_EMP_AVL_DET table.
    ...    Args:
    ...    ess_user_key: The user key from users.csv file. eg. ESS-USER1.
    ...    sm_user_key: The user key from users.csv file. eg. SM-USER1.
    ...    eff_offset: The effective date in offset for e.g. 1_0.
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${eff_offset}
    ${ess_user}    Get User    ${ess_user_key}
    ${eff_date}    Calculate Date From Week Day Offset    ${eff_offset}    %Y-%m-%d
    ${results}    Select Temporary Availability Request From DB    ${ess_user}[username]    ${eff_date}
    ${list_length}    Get Length    ${results}
    IF    ${list_length} > 0
        ${request_no}    Get From Dictionary    ${results[0]}    REQUEST_NO

        Generate Auth Token With User Credentials    ${sm_user_key}
        Send A Post Request    ${rws_init_session}
        Send A Delete Request    ${sm_delete_availability_request}    ${request_no}
    ELSE
        Log    No request found for ${ess_user}[username] on ${eff_date} to cleanup
    END

Approve Permanent Availability Request From API
    [Documentation]    Approve a permanent availability request.
    ...    The request is identified by the system user ID and effective date.
    ...    Args:
    ...    ess_user_key: The user key from users.csv file. eg. ESS-USER1.
    ...    sm_user_key: The user key from users.csv file. eg. SM-USER1.
    ...    eff_offset: The effective date in offset for e.g. 1_0.
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${eff_offset}
    Update Availability Request From API    ${ess_user_key}    ${sm_user_key}    ${eff_offset}    P    A

Approve Temporary Availability Request From API
    [Documentation]    Approve a Temporary availability request.
    ...    The request is identified by the system user ID and effective date.
    ...    Args:
    ...    ess_user_key: The user key from users.csv file. eg. ESS-USER1.
    ...    sm_user_key: The user key from users.csv file. eg. SM-USER1.
    ...    eff_offset: The effective date in offset for e.g. 1_0.
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${eff_offset}
    Update Availability Request From API    ${ess_user_key}    ${sm_user_key}    ${eff_offset}    T    A

Decline Permanent Availability Request From API
    [Documentation]    Decline a Permanent availability request.
    ...    The request is identified by the system user ID and effective date.
    ...    Args:
    ...    ess_user_key: The user key from users.csv file. eg. ESS-USER1.
    ...    sm_user_key: The user key from users.csv file. eg. SM-USER1.
    ...    eff_offset: The effective date in offset for e.g. 1_0.
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${eff_offset}
    Update Availability Request From API    ${ess_user_key}    ${sm_user_key}    ${eff_offset}    P    D

Decline Temporary Availability Request From API
    [Documentation]    Decline a Temporary availability request.
    ...    The request is identified by the system user ID and effective date.
    ...    Args:
    ...    ess_user_key: The user key from users.csv file. eg. ESS-USER1.
    ...    sm_user_key: The user key from users.csv file. eg. SM-USER1.
    ...    eff_offset: The effective date in offset for e.g. 1_0.
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${eff_offset}
    Update Availability Request From API    ${ess_user_key}    ${sm_user_key}    ${eff_offset}    T    D

Update Availability Request From API
    [Documentation]    Approve a availability request.
    ...    The request is identified by the system user ID and effective date.
    ...    Args:
    ...    ess_user_key: The user key from users.csv file. eg. ESS-USER1.
    ...    sm_user_key: The user key from users.csv file. eg. SM-USER1.
    ...    eff_offset: The effective date in offset for e.g. 1_0.
    ...    permanent_temp_ind (str): The permanent or temporary indicator P for permanent T for temporary.
    ...    request_status (str): The request status to be set in the request. A for approved, D for declined.
    [Tags]    robot:private
    [Arguments]    ${ess_user_key}    ${sm_user_key}    ${eff_offset}    ${permanent_temp_ind}    ${request_status}
    ${ess_user}    Get User    ${ess_user_key}
    ${eff_date_in_format}    Calculate Date From Week Day Offset    ${eff_offset}    %Y-%m-%d
    ${results}    Select Availability Request From DB    ${ess_user}[username]    ${eff_date_in_format}    ${permanent_temp_ind}
    ${list_length}    Get Length    ${results}
    IF    ${list_length} > 0
        ${request_no}    Get From Dictionary    ${results[0]}    REQUEST_NO

        Generate Auth Token With User Credentials    ${sm_user_key}
        Send A Post Request    ${rws_init_session}
        ${response}    Send A Get Request    ${sm_availability_details}    ${request_no}
        # Updating json to approve the request
        ${length}    Get Length    ${response}
        FOR    ${i}    IN RANGE    ${length}
            ${item}    Get From List    ${response}    ${i}
            Set To Dictionary    ${item}    reqStatusCd=${request_status}
            ${effDate}    Get From Dictionary    ${item}    effDate
            ${effDateStr}    Evaluate    datetime.datetime.utcfromtimestamp(${effDate} / 1000).strftime("%Y-%m-%dT09:09:24.000Z")    datetime
            Set To Dictionary    ${item}    effDate=${effDateStr}

            ${endDate}    Get From Dictionary    ${item}    endDate
            ${endDateStr}    Evaluate    datetime.datetime.utcfromtimestamp(${endDate} / 1000).strftime("%Y-%m-%dT09:09:24.000Z")    datetime
            Set To Dictionary    ${item}    endDate=${endDateStr}

            Remove From Dictionary    ${item}    apprDecBy
            Remove From Dictionary    ${item}    apprDecOn
            Remove From Dictionary    ${item}    approveDeclineAllowedToCurrentUser
            Remove From Dictionary    ${item}    clientId
            Remove From Dictionary    ${item}    displayApprDecOn
            Remove From Dictionary    ${item}    displayRequestedOn
            Remove From Dictionary    ${item}    editAllowedToCurrentUser
            Remove From Dictionary    ${item}    lastUpdateTime
            Remove From Dictionary    ${item}    lastUser
            Remove From Dictionary    ${item}    notApprovedComments
            Remove From Dictionary    ${item}    ownerId
            Remove From Dictionary    ${item}    personId
            Remove From Dictionary    ${item}    requestedOn
            Remove From Dictionary    ${item}    unitId
        END

        ${user_details}    Select User Details From DB    ${ess_user}[username]
        ${person_id}    Get From Dictionary    ${user_details[0]}    PERSON_ID
        Send A Post Request    ${sm_update_availability_request}    ${person_id}    ${ess_user}[UNIT_ID]    body=${response}
    ELSE
        Fail    No request found for ${ess_user}[username] on ${eff_date_in_format} to approve
    END
