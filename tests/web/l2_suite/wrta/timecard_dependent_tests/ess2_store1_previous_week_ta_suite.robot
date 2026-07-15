*** Settings ***
Documentation       Test Suite to verify ESS2_Store1 Previous Week Timecard related scenarios

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rta/operations/payroll_status.resource
Resource            resources/web/rta/operations/timecard.resource

Test Teardown       Run Keywords    Close Browser

Test Tags           bat_phase1    config:rta    timecard_previous_week


*** Test Cases ***
BATTC00073: Verify user is able to add / remove timecard special pay
    [Documentation]    This test case is to verify pay user able to add / remove timecard special pay
    [Tags]    battc00073    dev:bushra    action:write    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${special_pay_data}    Get Special Pay Data
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${special_pay_data}[sp_date]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${sp_rec_count_before}    Get Special Pay Count For Specific Date On Timecard Page On Web    ${special_pay_data}[sp_date]
    IF    ${sp_rec_count_before} > 0
        Skip    msg=Special Pay data already present for the date. Skipping add special pay step.
    END
    ${spl_pay_status}    Get Status For Special Pay Button Is Present In Timecard On Web
    IF    not ${spl_pay_status}
        Skip    msg=Special Pay button not present. Skipping test.
    END
    ${shift_date_added}    Add Special Pay On Web    ${special_pay_data}
    Log    Special Pay Added For Date: ${shift_date_added}
    ${sp_rec_count_after}    Get Special Pay Count For Specific Date On Timecard Page On Web    ${special_pay_data}[sp_date]
    Should Be Equal As Numbers    ${sp_rec_count_after}    1    msg=Special Pay data not visible after adding special pay.
    Delete Special Pay On Web    ${shift_date_added}
    Log    Special Pay Deleted For Date: ${shift_date_added}
    ${sp_rec_count_after_delete}    Get Special Pay Count For Specific Date On Timecard Page On Web    ${special_pay_data}[sp_date]
    Should Be Equal As Numbers    ${sp_rec_count_after_delete}    0    msg=Special Pay data still visible after deleting special pay.
    Log Out From Web Application

BATTC00074: Verify user is able to add / remove timecard meals
    [Documentation]    Verify Whether User Is Able To Add And Remove Lunch
    ...    This test validates that a user can add and remove lunch in the RTA timecard.
    ...    Before executing the test, it validates database requirements:
    ...    1. Meal transaction types (3,4) are configured in TA_STD_TXN_TYPE and TA_UNIT_TXN_TYPE
    ...    2. Employee's contract policy supports meals with valid network segment types (SSM/SUM/UUM)
    ...    The test will be skipped if the meal functionality is not applicable for the user.
    [Tags]    dev:yogesh    battc00074    action:write    module:timekeeping

    ${is_meal_applicable}    Check Meal Applicability For User In DB    user_key=ESS2_STORE1
    Skip If    not ${is_meal_applicable}    Meal functionality not applicable - DB validation failed for user ESS2_STORE1

    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    ${ess_user_2}    Get User    user_key=ESS2_STORE1
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_2}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${lunch_shift_data}    Get Timecard Shift Data    template_name=lunch
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${lunch_shift_data}[start_date]
    VAR    ${lunch_day}    ${lunch_shift_data}[lunch_day]
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${lunch_day}
    ${day}    Calculate Date From Week Day Offset    weekday_offset=${lunch_day}    date_format=${timecard_date_format}
    ${day_numeric}    Extract Day Numeric From Week String On Web    ${day}
    ${shift_data}    Get Timecard Shift Data    shift_day=-2_0
    Add Shift On Timecard Page On Web    day=${day_numeric}    shift_request_week=${day}    shift_data=${shift_data}
    Add Lunch On Timecard Page On Web    ${day_numeric}    ${lunch_shift_data}
    Remove Shift On Timecard Page On Web    ${day}
    Log Out From Web Application

BATTC00075: Verify user is able to add / remove timecard breaks
    [Documentation]    This test case is to verify if the user is able to add, edit and delete Break
    [Tags]    dev:moiz    battc00075    action:write    module:timekeeping
    # #PC00080 - Check applicability of Break transactions
    ${is_break_applicable}    Check Break Applicability For User In DB    user_key=SM1_STORE1
    Skip If    not ${is_break_applicable}    Break transactions are not applicable for this env. Skipping test execution.
    ${break_shift_data}    Get Timecard Shift Data    template_name=break
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${user}    Get User    user_key=ESS2_STORE1
    VAR    ${employee_name}    ${user}[displayName]
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Search & Click On Clock For Employee On Exception Management Page On Web    ${employee_name}
    Verify Timecard Page Is Loaded On Web
    Shift To Previous Week Timecard Of User
    ${day}    Calculate Date From Week Day Offset    weekday_offset=${break_shift_data}[break_day]    date_format=${timecard_date_format}
    VAR    ${is_shift_added}    False
    ${is_shift_present}    Verify Shift Is Present In Timecard For Day Page On Web    ${day}
    ${day_numeric}    Extract Day Numeric From Week String On Web    ${day}
    IF    not ${is_shift_present}
        ${shift_data}    Get Timecard Shift Data    shift_day=-2_0
        Add Shift On Timecard Page On Web    day=${day_numeric}    shift_request_week=${day}    shift_data=${shift_data}
        VAR    ${is_shift_added}    True
    END
    Add Break For Shift On Timecard Page On Web    ${day_numeric}    ${break_shift_data}

    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Run Keyword If    ${is_break_applicable}    Delete Break For Shift On Timecard Page On Web
    ...    ${day}    ${break_shift_data}[reason_code]    ${break_shift_data}[break_end_time]    AND
    ...    Run Keyword And Ignore Error    Run Keyword If    ${is_break_applicable} and ${is_shift_added}
    ...    Remove Shift On Timecard Page On Web    ${day}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If    ${is_break_applicable}    Log Out From Web Application    AND
    ...    Run Keyword And Ignore Error    Close Browser

BATTC00076: Verify user is able to add / remove timecard punches
    [Documentation]    Verify Whether User Is Able To Add And Remove Punch
    [Tags]    dev:yogesh    battc00076    action:write    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user_2}    Get User    user_key=ESS2_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_2}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${punch_shift_data}    Get Timecard Punch Data
    ...    week_start_date=-1_0
    ...    shift_start_date=-1_3
    ...    punch_time=13:00
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${punch_shift_data}[week_start_date]
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${punch_shift_data}[week_start_date]
    Add Punch On Timecard Page On Web    ${punch_shift_data}[shift_start_date]    ${punch_shift_data}[transaction_type]
    ...    ${punch_shift_data}[punch_time]    ${punch_shift_data}[reason_code]    ${punch_shift_data}[activity_code]

    Navigate To RTA Operations Exception Management Page On Web
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_2}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${punch_shift_data_2}    Get Timecard Punch Data    template_name=punch_end_data
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${punch_shift_data_2}[week_start_date]
    Add Punch On Timecard Page On Web    ${punch_shift_data_2}[shift_start_date]    ${punch_shift_data_2}[transaction_type]
    ...    ${punch_shift_data_2}[punch_time]    ${punch_shift_data_2}[reason_code]    ${punch_shift_data_2}[activity_code]

    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Remove Added Punches And Shifts On Timecard Page On Web    AND
    ...    Run Keyword And Continue On Failure    Log Out From Web Application    AND
    ...    Run Keyword And Ignore Error    Close Browser

BATTC00071: Verify export and print of timecard details
    [Documentation]    This test case verifies printing data from exception management and exporting timecard details from timecard page
    [Tags]    battc00071    dev:bushra    action:read    config:export_print_timecard    config:print_actuals    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user}    Get User    user_key=ESS2_STORE1
    ${shift_data}    Get Timecard Shift Data    shift_day=-1_4
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${is_export_button_visible}    Is Export Button Visible On Timecard Page On Web
    IF    not ${is_export_button_visible}
        Skip    msg=Export button is not available as expected on timecard page.
    END
    Verify Export Button Functionality On Timecard Page On Web
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    Verify PDF Export Button On Web
    Verify Print Summary On Exception Management Page On Web

BATTC00072: Verify user is able to add / remove timecard shifts
    [Documentation]    Test case for verifying User Is Able To Add & Remove Timecard Shifts
    [Tags]    dev:rushikesh    action:write    battc00072    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    ${user}    Get User    user_key=ESS2_STORE1
    VAR    ${employee_name}    ${user}[displayName]
    ${shift_data}    Get Timecard Shift Data    shift_day=-1_6    start_time=9:00
    VAR    ${shift_day}    ${shift_data}[shift_day]
    Search & Click On Clock For Employee On Exception Management Page On Web    ${employee_name}
    Verify Timecard Page Is Loaded On Web
    Shift To Previous Week Timecard Of User
    Verify Week Navigator Bar Of Expected Date Displayed On Timecard Page On Web    ${shift_day}
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${day}    Calculate Date From Week Day Offset    weekday_offset=${shift_day}    date_format=${timecard_date_format}
    ${day_numeric}    Extract Day Numeric From Week String On Web    ${day}
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${shift_day}
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${shift_day}
    Add Shift On Timecard Page On Web    ${day_numeric}    ${day}    ${shift_data}    shift_to_be_added=Previous_week

    [Teardown]    Run Keywords    Run Keyword And Continue On Failure    Remove Shift On Timecard Page On Web    ${day}    AND
    ...    Run Keyword And Ignore Error    Close Browser

BATTC00085: Verify payroll status for the store
    [Documentation]    This test verifies the SM user ability to review payroll status for the store for the selected week
    [Tags]    action:read    battc00085    dev:bushra    config:status_payroll    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user}    Get User    user_key=ESS2_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    ${all_emp_count}    Get All Employee Count On Web
    Log    total employee count is ${all_emp_count}
    ${dept_name}    Get Department Name Of Specific Employee On Web    ${ess_user}[displayName]
    ${store_data}    Get Store Data
    VAR    ${store_name}    ${store_data}[store_id] - ${store_data}[store_name]
    ${date_format_payroll_status}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${payroll_data1}    Get Payroll Data    pay_period_start_date=-1_0
    ${start_date}    Convert Date    ${payroll_data1}[pay_period_start_date]    result_format=${date_format_payroll_status}
    ${payroll_data2}    Get Payroll Data    pay_period_end_date=-1_6
    ${end_date}    Calculate Date From Week Day Offset    ${payroll_data2}[pay_period_end_date]    ${date_format_payroll_status}
    VAR    ${week_range}    ${start_date} - ${end_date}
    Select Day On Exception Management Page On Web    ${payroll_data2}[pay_period_end_date]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Navigate To RTA Payroll Status Page On Web
    Apply Filter On Payroll Status Page On Web    week=${week_range}
    ${open_count}    Get Count Of Associates With Open Status In Payroll Status Page On Web    ${store_name}    ${start_date} - ${end_date}
    Log    Open count is ${open_count}
    Should Be True    ${open_count} >= 1    msg=Open count should be at least 1
    ${total_count}    Get Total Count For Release Status In Payroll Status Page On Web    ${store_name}    ${start_date} - ${end_date}
    Log    Total count is ${total_count}
    Should Be True    ${total_count} >= 1    msg=Total count should be at least 1
    ${release_status}    Get System Value    PayRollStatus    RELEASED
    Navigate To RTA Payroll Status Page On Web
    Apply Filter On Payroll Status Page On Web    week=${week_range}    release_status=${release_status}
    ${released_count}    Get Count Of Associates With Released Status In Payroll Status Page On Web    ${store_name}
    ...    ${start_date} - ${end_date}
    Should Be Equal As Numbers    ${released_count}    0    msg=Released count should be 0
    ${release_status}    Get System Value    PayRollStatus    OPEN
    Navigate To RTA Payroll Status Page On Web
    Apply Filter On Payroll Status Page On Web    week=${week_range}    release_status=${release_status}
    ${open_count}    Get Count Of Associates With Open Status In Payroll Status Page On Web    ${store_name}    ${start_date} - ${end_date}
    Log    Open count is ${open_count}
    Should Be True    ${open_count} >= 1    msg=Open count should be at least 1
    ${total_count}    Get Total Count For Release Status In Payroll Status Page On Web    ${store_name}    ${start_date} - ${end_date}
    Log    Total count is ${total_count}
    Should Be True    ${total_count} >= 1    msg=Total count should be at least 1
    Click On Unit Link On Payroll Status Page On Web    ${store_name}    ${start_date} - ${end_date}
    Click On Store Name Link On Payroll Status Page On Web    ${store_data}[store_name]    ${start_date} - ${end_date}
    Expand Department On Payroll Status Page On Web    ${dept_name}
    ${associate_count}    Get Associates Count On Payroll Status Page On Web
    Log    Count of associates in department ${dept_name} is ${associate_count}
    Should Be True    ${associate_count} >= 1


*** Keywords ***
Remove Added Punches And Shifts On Timecard Page On Web
    [Documentation]    This keyword will remove added punches and shifts on timecard page
    ${punch_shift_data}    Get Timecard Punch Data
    ...    week_start_date=-1_0
    ...    shift_start_date=-1_3
    ...    punch_time=13:00
    ${punch_shift_data_2}    Get Timecard Punch Data    template_name=punch_end_data
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${day}    Calculate Date From Week Day Offset    weekday_offset=${punch_shift_data}[shift_start_date]
    ...    date_format=${timecard_date_format}
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${punch_shift_data}[week_start_date]
    Delete Punch On Timecard Page On Web    ${punch_shift_data}[shift_start_date]    ${punch_shift_data}[reason_code]
    ...    ${punch_shift_data}[punch_time]
    Delete Punch On Timecard Page On Web    ${punch_shift_data_2}[shift_start_date]    ${punch_shift_data_2}[reason_code]
    ...    ${punch_shift_data_2}[punch_time]
    Remove Shift On Timecard Page On Web    ${day}
