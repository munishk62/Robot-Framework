*** Settings ***
Documentation       Test case to verify accrual balance display in timecard page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                 Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS4_STORE1    SM1_STORE1    1_1    1_1    AND
...                 Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS4_STORE1    SM1_STORE1    8_1    8_1    AND
...                 Close Browser

Test Tags    dev:bushra    action:write    config:rta    config:rws    config:use_leave_hrs_in_ta:n    config:holiday_hours_disabled
...    config:add_edit_delete_dayoff_request_sm    battc00077    bat_phase1    module:timekeeping


*** Test Cases ***
BATTC00077: Verify accrual balances are displayed in timecard
    [Documentation]    Test case to verify accrual balance display in timecard page
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${user}    Get User    user_key=ESS4_STORE1
    ${day_off_data}    Get Day Off Data    start_date=1_1
    ...    reason=DayOffReasonType.PAID_VACATION    status_after_approval=RequestStatus.APPROVED
    ...    accrual_balance_type=AccrualBalanceReason.LEAVE_BALANCE_TYPE1    holiday_hours={"1": "8"}
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${user}    ${day_off_data}[reason]    8_1
    IF    ${is_alternate_offset_required}
        ${day_off_data}    Get Day Off Data    start_date=8_1
        ...    reason=DayOffReasonType.PAID_VACATION    status_after_approval=RequestStatus.APPROVED
        ...    accrual_balance_type=AccrualBalanceReason.LEAVE_BALANCE_TYPE1    holiday_hours={"1": "8"}
    END
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${day_off_data}[start_date]
    Click On Associate Clock Icon On Exception Management Page On Web    ${user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Open And Verify Accrual Balance Tab On Timecard Page On Web
    ${accrual_bal_before_leave}    Get Accrual Balance Value On Timecard Page On Web    ${day_off_data}[accrual_balance_type]
    Log    Accrual balance value before adding leave: ${accrual_bal_before_leave}
    Close Accrual Balance Tab On Timecard Page On Web
    Navigate To RWS Employee Request Calendar Page On Web
    Switch To Week View On Request Calendar Page On Web
    Select Day On Request Calendar Page    ${day_off_data}[start_date]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web    ${user}[displayName]    ${day_off_data}[start_date]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${day_off_data}[start_date]
    Click On Associate Clock Icon On Exception Management Page On Web    ${user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Open And Verify Accrual Balance Tab On Timecard Page On Web
    ${accrual_bal_after_leave}    Get Accrual Balance Value On Timecard Page On Web    ${day_off_data}[accrual_balance_type]
    Log    Accrual balance value after adding leave: ${accrual_bal_after_leave}
    Should Be True    ${accrual_bal_after_leave} < ${accrual_bal_before_leave}    Accrual balance did not decrease after adding leave
    Close Accrual Balance Tab On Timecard Page On Web
    Navigate To RWS Employee Request Calendar Page On Web
    Select Day On Request Calendar Page    ${day_off_data}[start_date]
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${user}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${day_off_data}[start_date]
    Click On Associate Clock Icon On Exception Management Page On Web    ${user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Open And Verify Accrual Balance Tab On Timecard Page On Web
    ${accrual_bal_after_leave_deletion}    Get Accrual Balance Value On Timecard Page On Web    ${day_off_data}[accrual_balance_type]
    Log    Accrual balance value after deleting leave: ${accrual_bal_after_leave_deletion}
    Should Be Equal As Numbers    ${accrual_bal_after_leave_deletion}    ${accrual_bal_before_leave}
    ...    Accrual balance did not restore after deleting leave
    Close Accrual Balance Tab On Timecard Page On Web
