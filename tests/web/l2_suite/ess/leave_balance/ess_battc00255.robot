*** Settings ***
Documentation       Test case to verify ESS user is able to review the leave balance and accruals with holiday hours enabled

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/leave_balance.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up All Requests For User On Date    ESS6_STORE2    SM1_STORE2    1_1    1_7    AND
...                     Close Browser

Test Tags    dev:bushra    config:ess    config:rws    config:holiday_hours_enabled    config:use_leave_hrs_in_ta:y    battc00255
...    bat_phase2    config:add_edit_delete_dayoff_request_sm    om_hr


*** Test Cases ***
BATTC00255: Verify ESS user is able to review the leave balance and accruals before and after an approved day off request with holiday hours enabled
    [Documentation]    Verify ESS user is able to review the leave balance and accruals before and after an approved day off request with holiday hours enabled.
    ...    1. Check initial balance.
    ...    2. SM creates approved day off.
    ...    3. Check balance is reduced.
    ...    4. SM deletes request.
    ...    5. Check balance is restored.
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${ess_user}    Get User    user_key=ESS6_STORE2
    ${sm_user}    Get User    user_key=SM1_STORE2
    ${accrual_balance_type}    Get System Value    AccrualBalanceReason    LEAVE_BALANCE_TYPE1

    ${day_off_data}    Get Day Off Data    template_name=paid_approved    start_date=1_6    end_date=1_6
    ...    holiday_hours={"6": "8"}

    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user}    ${day_off_data}[reason]    8_6
    IF    ${is_alternate_offset_required}
        ${day_off_data}    Get Day Off Data    template_name=paid_approved    start_date=8_6    end_date=8_6
        ...    holiday_hours={"6": "8"}
    END
    Login And Launch WFM Web App    user_key=${ess_user}[user_key]
    Navigate To ESS Leave Balance Page On Web
    ${initial_accrual_balance}    Get Accrual Balance For Specific Balance Type On Leave Balance Page On Web    ${accrual_balance_type}
    Log    Initial accrual balance is: ${initial_accrual_balance}
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Switch To Week View On Request Calendar Page On Web
    Select Day On Request Calendar Page    ${day_off_data}[start_date]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user}[displayName]
    ...    ${day_off_data}[start_date]
    ...    ${day_off_data}[end_date]
    ...    ${day_off_data}[reason]
    ...    ${day_off_data}[status]
    ...    ${day_off_data}[holiday_hours]
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=${ess_user}[user_key]
    Navigate To ESS Leave Balance Page On Web
    ${reduced_accrual_balance}    Get Accrual Balance For Specific Balance Type On Leave Balance Page On Web    ${accrual_balance_type}
    Log    Reduced accrual balance is: ${reduced_accrual_balance}
    Should Be True    ${reduced_accrual_balance} < ${initial_accrual_balance}
    ...    msg=Accrual balance should be reduced after approved day off request
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Select Day On Request Calendar Page    ${day_off_data}[start_date]
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web
    ...    ${ess_user}[displayName]
    ...    ${day_off_data}[start_date]
    ...    ${day_off_data}[reason]
    ...    ${day_off_data}[status]
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=${ess_user}[user_key]
    Navigate To ESS Leave Balance Page On Web
    ${final_accrual_balance}    Get Accrual Balance For Specific Balance Type On Leave Balance Page On Web    ${accrual_balance_type}
    Log    Final Balance: ${final_accrual_balance}
    Should Be Equal As Numbers    ${final_accrual_balance}    ${initial_accrual_balance}
    ...    msg=Leave balance should be restored after deletion of day off request
    Log Out From Web Application
