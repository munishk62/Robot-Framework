*** Settings ***
Documentation       Test case for verifying and adding leave balance for the given employee

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/admin/rws_upload.resource

Test Teardown       Close Browser

Test Tags           dev:ravi    action:write    settc00099


*** Test Cases ***
SETTC00099: Verify And Add Leave Balance For Employee Through HRAC Upload
    [Documentation]    Test case for verifying and adding leave balance for the given employee through HRAC upload

    VAR    ${leave_balance_to_add}    01:00
    VAR    ${leave_balance_to_reduce}    00:00
    VAR    ${vacation_leave_balance_json_path}    $[?(@.tmoffCd=="VAC")].total
    VAR    ${is_leave_balance_added}    ${False}

    ${ess_user3}    Get User    user_key=ESS3_STORE1
    VAR    ${associate_id}    ${ess_user3}[username]

    ${date_format}    Get Config Value    SERVER_DF
    ${current_date}    Get Current Date    result_format=${date_format}
    ${leave_balance_type}    Get System Value    HRACLeaveBalanceType    VACATION

    # Check current leave balance
    ${api_response}    Get Accrual Leave Balance For Employee Via API    user_key=ESS3_STORE1
    ${associate_leave_balance}    Get Value For JSONPath    ${api_response}    ${vacation_leave_balance_json_path}
    ${associate_leave_balance}    Evaluate    str(float('${associate_leave_balance}')).rstrip('0').rstrip('.')
    ${is_leave_balance_required}    Evaluate    float('${associate_leave_balance}') <= 0

    # Add leave balance if needed
    IF    ${is_leave_balance_required}
        Login And Launch WFM Web App    user_key=SYSADMIN
        Perform HRAC Upload Operation On Web    ${associate_id}    ${current_date}    ${leave_balance_to_add}    ${leave_balance_type}
        VAR    ${is_leave_balance_added}    ${True}
    ELSE
        Log    Sufficient leave balance (${associate_leave_balance}) available for associate: ${associate_id}
    END

    [Teardown]    Run Keyword And Continue On Failure    Run Keyword    Run Keyword If    ${is_leave_balance_added}
    ...    Perform HRAC Upload Operation On Web    ${associate_id}    ${current_date}    ${leave_balance_to_reduce}    ${leave_balance_type}
