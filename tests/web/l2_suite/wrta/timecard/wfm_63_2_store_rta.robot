*** Settings ***
Documentation       Test case to verify accrual balance displayed in timecard page for day off with holiday hours.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                     Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS4_STORE1    SM1_STORE1    1_1    1_7    AND
...                     Close Browser

Test Tags    dev:moiz    action:write    config:rta    battc00157    bat_phase1    config:holiday_hours_enabled
...    config:use_leave_hrs_in_ta:y    module:timekeeping    config:add_edit_delete_dayoff_request_sm


*** Test Cases ***
BATTC00157: Verify accrual balances are displayed in timecard with holiday hours
    [Documentation]    Test case to verify accrual balance display in timecard page for day off with holiday hours
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${user}    Get User    user_key=ESS4_STORE1
    ${day_off_data}    Get Day Off Data    start_date=1_1
    ...    reason=DayOffReasonType.PAID_VACATION    status_after_approval=RequestStatus.APPROVED
    ...    accrual_balance_type=AccrualBalanceReason.LEAVE_BALANCE_TYPE1    holiday_hours={"1": "8"}
    Cleanup Existing ESS Day Off Requests From SM On Request Calendar On Web    ${user}[displayName]    num_of_weeks=1
    ...    specific_week_offset_day=${day_off_data}[start_date]
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${day_off_data}[start_date]
    Search & Click On Clock For Employee On Exception Management Page On Web    ${user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Open And Verify Accrual Balance Tab On Timecard Page On Web
    ${accrual_bal_before_leave}    Get Accrual Balance Value On Timecard Page On Web    ${day_off_data}[accrual_balance_type]
    Close Accrual Balance Tab On Timecard Page On Web
    Navigate To RWS Employee Request Calendar Page On Web
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web    ${user}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[start_date]    ${day_off_data}[reason]
    ...    ${day_off_data}[status_after_approval]    ${day_off_data}[holiday_hours]
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${day_off_data}[start_date]
    Search & Click On Clock For Employee On Exception Management Page On Web    ${user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Open And Verify Accrual Balance Tab On Timecard Page On Web
    ${accrual_bal_after_leave}    Get Accrual Balance Value On Timecard Page On Web    ${day_off_data}[accrual_balance_type]
    Should Be True    ${accrual_bal_after_leave} < ${accrual_bal_before_leave}    Accrual balance did not decrease after adding leave
    Close Accrual Balance Tab On Timecard Page On Web
    Navigate To RWS Employee Request Calendar Page On Web
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${user}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${day_off_data}[start_date]
    Search & Click On Clock For Employee On Exception Management Page On Web    ${user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Open And Verify Accrual Balance Tab On Timecard Page On Web
    ${accrual_bal_after_leave_deletion}    Get Accrual Balance Value On Timecard Page On Web    ${day_off_data}[accrual_balance_type]
    Should Be Equal As Numbers    ${accrual_bal_after_leave_deletion}    ${accrual_bal_before_leave}
    ...    Accrual balance did not restore after deleting leave
