*** Settings ***
Documentation       Test Suite to verify ESS2_Store1 Current Week + 1 Timecard related scenarios

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up All Requests For User On Date    ESS2_STORE1    SM1_STORE1    1_0    8_0    AND
...                     Close Browser

Test Tags           bat_phase1    config:rta    timecard_current_week_plus_1


*** Test Cases ***
BATTC00045: Verify timecard special pay
    [Documentation]    This test verifies the display of special pay in timecard pay results for the paid leave requests
    [Tags]    dev:bushra    action:write    battc00045    config:holiday_hours_disabled    config:add_edit_delete_dayoff_request_sm
    ...    config:use_leave_hrs_in_ta:n    module:timekeeping
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}
    ...    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${user}    Get User    user_key=ESS2_STORE1
    ${day_off_data}    Get Day Off Data    start_date=1_0
    ...    reason=DayOffReasonType.PAID_VACATION    status_after_approval=RequestStatus.APPROVED
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${user}    ${day_off_data}[reason]
    ...    8_0
    IF    ${is_alternate_offset_required}
        ${day_off_data}    Get Day Off Data    start_date=8_0
        ...    reason=DayOffReasonType.PAID_VACATION    status_after_approval=RequestStatus.APPROVED
    END
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Cleanup Existing ESS Day Off Requests From SM On Request Calendar On Web    ${user}[displayName]    num_of_weeks=0
    ...    specific_week_offset_day=${day_off_data}[start_date]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web    ${user}[displayName]    ${day_off_data}[start_date]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${day_off_data}[start_date]
    Click On Associate Clock Icon On Exception Management Page On Web    ${user}[displayName]
    Navigate To Pay Results Section On Web
    ${pay_category}    Get System Value    PayCategoryType    PAY_CATEGORY
    Verify Special Pay Section Details For Paid Leave Requests On Web    ${day_off_data}[start_date]    ${pay_category}
    Navigate To RWS Employee Request Calendar Page On Web
    Switch To Week View On Request Calendar Page On Web
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${user}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${day_off_data}[start_date]
    Click On Associate Clock Icon On Exception Management Page On Web    ${user}[displayName]
    Navigate To Pay Results Section On Web
    ${is_special_pay_present}    Is Special Pay Data Visible On Timecard Page On Web    ${day_off_data}[start_date]
    IF    ${is_special_pay_present}
        Fail    Special Pay data visible even after day off request deleted.
    END
