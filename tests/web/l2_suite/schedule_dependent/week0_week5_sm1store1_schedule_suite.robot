*** Settings ***
Documentation       Weeks 0 & 5 - SM1_STORE1 Schedule Suite
...
...                 **PURPOSE:**
...                 This suite consolidates SM1_STORE1 test cases for Week 0 (current week) and Week 5
...                 that share the same schedule setup, enabling efficient parallel execution.
...
...                 Week-1 Day Schedule tests (BATTC00027, BATTC00206) live in week1_sm1store1_schedule_suite.robot.
...
...                 **ONE-TIME SETUP APPROACH:**
...                 Suite Setup calls 'Setup Schedule Weeks 0 And 5 For SM1Store1' wrapped with
...                 'Run Only Once' from pabot.PabotLib so it executes exactly ONCE across all
...                 parallel processes before any test runs.
...
...                 Setup order and rationale:
...                 W0: wip_generate_and_publish_schedule + employee shifts
...                 Publishes week 0 and creates WIP copy — satisfies all W0 tests.
...                 W5: generate_and_publish_schedule + ESS4 shifts
...                 Publishes week 5 — satisfies BATTC00031/030/032/034/094.
...
...                 **TEST CASES INCLUDED (9 total):**
...                 Week 0 tests (SM1_STORE1):
...                 - BATTC00094: Verify My Schedule Page For ESS When Schedule Is Published
...                 - BATTC00158: Verify Scheduled Shift Is Unallocated After Approving Day Off Request With Holiday Hours
...                 - BATTC00026: Verify Add Edit Delete Operations on Week Schedule page
...                 - BATTC00033: Verify Store User Can Filter All Unscheduled Value On Advanced Filters
...                 Week 5 tests (SM1_STORE1):
...                 - BATTC00031: Verify Week Schedule PDF Reports download functionality
...                 - BATTC00030: Verify Display And Sort Preferences On Week Schedule Page
...                 - BATTC00032: Verify Print Operations In Weekly Schedule
...                 - BATTC00034: Verify Advanced Filter Operation Using Task In Weekly Schedule
...
...                 **EXECUTION COMMANDS:**
...
...                 Sequential execution:
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week0_week5_sm1store1_schedule_suite.robot --test-env QA28_B0
...
...                 Parallel execution (recommended, 4 processes):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week0_week5_sm1store1_schedule_suite.robot --test-env QA28_B0 --processes 4
...
...                 With browser visible (for debugging):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week0_week5_sm1store1_schedule_suite.robot --test-env QA28_B0 --show-browser
...
...                 **LOCK FILE CLEANUP:**
...                 If setup appears to be skipped, clean pabot lock files before running:
...                 Remove-Item -Path ".pabot_results" -Recurse -Force -ErrorAction SilentlyContinue

Library             pabot.PabotLib
Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/shift_trade_board.resource
Resource            resources/web/ess/ess_my_schedule.resource
Resource            resources/web/rws/schedule/day_schedule.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/web/roster/template_calendar.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource
Resource            resources/web/rws/schedule/plan_status.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource
Resource            resources/web/rws/driver_forecast/driver_forecast.resource
Resource            resources/web/rws/labor_forecast/labor_forecast_db.resource
Resource            resources/web/ess/ess_request_calendar_db.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource
Variables           test_data/localized_text/rws_localized_text.py

Suite Setup         Run Keywords    Run Only Once    Pre Setup Schedule For Week 0 SM1Store1
...                     AND
...                     Run Only Once    Pre Setup Schedule For Week 5 SM1Store1
Suite Teardown      Log    Weeks 0 & 5 SM1_STORE1 Suite Complete - All tests executed    level=INFO
Test Teardown       Close Browser

Test Tags           bat_phase1    schedule_dependent
# ==============================================================================
# WEEK 0 — SM1_STORE1
# ==============================================================================


*** Test Cases ***
BATTC00094: Verify ESS My Schedule when the schedule is published
    [Documentation]    Test case for verifying whether user is able to see published schedules
    ...    in My Schedule page
    ...    Week: 0 (current), Week: 5
    [Tags]    action:read    dev:ravi    battc00094    config:ess    config:weekplan_and_schedule_gen    om_hr    checkschedulesetup

    # Lookup: #PC00127
    ${is_week_plan_and_schedule_gen_applicable}    Verify Week Plan And Schedule Generation Status In Database
    Skip If    ${is_week_plan_and_schedule_gen_applicable}
    ...    msg=Week plan and schedule generation is not applicable, hence skipping the test case...

    # Setup schedule data for the test is taken care in Suite Setup
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Verify Week In Progress Copy Exists On Week Schedule Page On Web
    Close Browser

    VAR    @{current_week_days}    7
    VAR    @{future_week_days}    1    2    3
    VAR    ${weeks_to_navigate}    5

    Login And Launch WFM Web App    user_key=ESS4_STORE1
    Navigate To ESS My Schedule Page On Web
    Assert Shift Is Present For The Given Day On My Schedule Page On Web    @{current_week_days}

    Navigate To ESS My Schedule Page On Web
    Navigate To Next Week On My Schedule Page On Web    ${weeks_to_navigate}
    Assert Shift Is Present For The Given Day On My Schedule Page On Web    @{future_week_days}

BATTC00011: WFM-99856 Verify Scheduled Shift Is Unallocated After Approving Day Off Request
    [Documentation]    Test case to verify that scheduled shift is unallocated when the SM user approves
    ...    the day off request of the associate without holiday hours.
    ...    As Store manager Create Day Off request for an Associate, verify shift exists, Approve it,
    ...    verify shift moved to open pool, delete open shift and then Delete the day off request.
    ...    Week: 0 (current week)
    [Tags]    config:add_edit_delete_dayoff_request_sm    battc00011    dev:azar    config:rws    config:holiday_hours_disabled
    ...    config:use_leave_hrs_in_ta:n    om_hr
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}
    ...    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${day_off_data}    Get Day Off Data    template_name=unpaid_approved    status=RequestStatus.NOT_REVIEWED
    ${ess_user}    Get User    user_key=ESS2_STORE1
    ${creation_day}    Get Current Week Day Offset

    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user}
    ...    ${day_off_data}[reason]    8_6
    Skip If    ${is_alternate_offset_required}
    ...    msg=Skipping the test execution as the test case is not valid when day offset value is not applicable or not within range.
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Request Calendar Page On Web
    Switch To Week View On Request Calendar Page On Web
    ${ess2_store1_shift_data}    Get Employee Shift Setup Data
    ...    template_name=addtoday_standard8
    ...    ess_user_key=ESS2_STORE1
    ...    _am_pm_format=ap
    ${shift_start_24hr}    Convert Minutes To Timeformat    ${ess2_store1_shift_data['shifts_to_add'][0]['startTime']}
    ${shift_end_24hr}    Convert Minutes To Timeformat    ${ess2_store1_shift_data['shifts_to_add'][0]['endTime']}

    Select Day On Request Calendar Page    ${creation_day}
    VAR    ${associate_name}    ${ess_user}[displayName]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${creation_day}
    ...    ${creation_day}
    ...    ${day_off_data}[reason]
    ...    ${day_off_data}[status]
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${creation_day}
    Verify Any Shift Is Present For Associate On Specific Day On Week Schedule Page On Web    ${ess_user}[personId]    ${creation_day}
    ${initial_open_shift_count}    Get Open Shifts Count On Week Schedule Page On Web
    Navigate To RWS Employee Request Calendar Page On Web
    Edit Day Off Request Status And Verify API Success On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${creation_day}
    ...    ${day_off_data}[reason]
    ...    ${day_off_data}[status]
    ...    ${day_off_data}[status_after_approval]
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${creation_day}
    Verify Any Shift Is Not Present For Associate On Specific Day On Week Schedule Page On Web    ${ess_user}[personId]    ${creation_day}
    ${post_day_off_approved_open_shift_count}    Get Open Shifts Count On Week Schedule Page On Web
    Verify Open Shift Count Not Equal After Day Off Approved On Week Schedule Page On Web    ${initial_open_shift_count}
    ...    ${post_day_off_approved_open_shift_count}
    Delete Open Shift On Week Schedule Page On Web    ${shift_start_24hr}    ${shift_end_24hr}    ${creation_day}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS2_STORE1    SM1_STORE1    ${creation_day}    ${creation_day}    AND
    ...    Close Browser

BATTC00158: Verify the scheduled shift is unallocated after approving the day off request with holiday hours
    [Documentation]    Test case to verify that scheduled shift is unallocated when the SM user approves
    ...    the day off request for an associate who has holiday hours configured (holiday hours available).
    ...    As Store manager, create a day off request for an associate who has holiday hours configured, verify shift exists,
    ...    approve the request, verify the shift moves to the open pool, delete the open shift, and then delete the day off request.
    ...    Week: 0 (current week)
    [Tags]    dev:azar    action:write    battc00158    config:holiday_hours_enabled    config:use_leave_hrs_in_ta:y    config:rws    om_hr
    ...    config:add_edit_delete_dayoff_request_sm
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${ess_user}    Get User    user_key=ESS2_STORE1
    ${creation_day}    Get Current Week Day Offset
    # Extract day number from creation_day (e.g., extract "1" from "0_1")
    ${day_number}    Get Day Number    ${creation_day}
    # Override holiday_hours to use current day number dynamically (expects 8 hours instead of template's day 5)
    ${holiday_hours_override}    Evaluate    {${day_number}: "8"}
    ${day_off_data}    Get Day Off Data    template_name=unpaid_approved    holiday_hours=${holiday_hours_override}
    ...    status=RequestStatus.NOT_REVIEWED

    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user}    ${day_off_data}[reason]    ${creation_day}
    Skip If    ${is_alternate_offset_required}
    ...    msg=Skipping the test execution as the test case is not valid when day offset value is not applicable or not within range.

    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Request Calendar Page On Web
    Switch To Week View On Request Calendar Page On Web
    # Get shift times from schedule setup template for today (0_0)
    ${ess2_store1_shift_data}    Get Employee Shift Setup Data
    ...    template_name=addtoday_standard8
    ...    ess_user_key=ESS2_STORE1
    ...    _am_pm_format=ap
    ${shift_start_24hr}    Convert Minutes To Timeformat    ${ess2_store1_shift_data['shifts_to_add'][0]['startTime']}
    ${shift_end_24hr}    Convert Minutes To Timeformat    ${ess2_store1_shift_data['shifts_to_add'][0]['endTime']}
    # Get current day offset to determine which day of the week it is
    Select Day On Request Calendar Page    ${creation_day}
    VAR    ${associate_name}    ${ess_user}[displayName]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${creation_day}
    ...    ${creation_day}
    ...    ${day_off_data}[reason]
    ...    ${day_off_data}[status]
    ...    ${day_off_data}[holiday_hours]
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${creation_day}
    Verify Shift Exists For Associate On Specific Day On Week Schedule Page On Web
    ...    ${associate_name}
    ...    ${creation_day}
    ...    ${shift_start_24hr}
    ...    ${shift_end_24hr}
    ${initial_open_shift_count}    Get Open Shifts Count On Week Schedule Page On Web
    Navigate To RWS Employee Request Calendar Page On Web
    Edit Day Off Request Status And Verify API Success On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${creation_day}
    ...    ${day_off_data}[reason]
    ...    ${day_off_data}[status]
    ...    ${day_off_data}[status_after_approval]
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${creation_day}
    Verify Shift Not Exists For Associate On Specific Day On Week Schedule Page On Web
    ...    ${associate_name}
    ...    ${creation_day}
    ...    ${shift_start_24hr}
    ...    ${shift_end_24hr}
    ${post_day_off_approved_open_shift_count}    Get Open Shifts Count On Week Schedule Page On Web
    Verify Open Shift Count Not Equal After Day Off Approved On Week Schedule Page On Web    ${initial_open_shift_count}
    ...    ${post_day_off_approved_open_shift_count}
    Delete Open Shift On Week Schedule Page On Web    ${shift_start_24hr}    ${shift_end_24hr}    ${creation_day}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS2_STORE1    SM1_STORE1    ${creation_day}    ${creation_day}    AND
    ...    Close Browser

BATTC00026: Verify schedule operations on the week schedule page, including add/edit/unallocate/undo and delete operations
    [Documentation]    Test case for verifying Add, Edit & Delete operations on Week Schedule page
    ...    Week: 0 (WIP copy required)
    [Tags]    dev:ravi    action:write    battc00026    config:rws    config:weekplan_and_schedule_gen

    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${associate_data}    Get User    user_key=ESS1_STORE1
    VAR    ${associate_display_name}    ${associate_data}[displayName]
    VAR    ${day_offset}    6
    ${shift_day}    Convert To String    ${day_offset}

    # Unallocate shift offset with the actual shift row is introduced because the way Add Shift and Unallocate shift are implemented.
    # In Add shift, shift column is adjusted by incrementing its value by 1, same is not done in Unallocate shift which is causing issue in unallocating the shift added in this test case, hence adjusting the day column value for unallocate shift by incrementing the day offset value by 1.
    VAR    ${unallocate_shift_offset}    7
    ${unallocate_shift_day}    Convert To String    ${unallocate_shift_offset}

    ${shift_data}    Get Shift Data
    Navigate To RWS Schedule Week Schedule Page On Web

    Add Shift On Week Schedule Page For The Given Associate And Day On Web    ${associate_display_name}    ${shift_day}
    ...    ${shift_data}[start_time]    ${shift_data}[end_time]

    Edit Shift On Week Schedule Page For The Given Associate And Day On Web    ${associate_display_name}    ${shift_day}
    ...    ${shift_data}[start_time]    ${shift_data}[edit_time]
    Perform Undo On Week Schedule Page On Web
    ${actual_shift_time}    Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web    ${associate_display_name}
    ...    ${unallocate_shift_day}
    Delete Shift On Week Schedule Page On Web    ${actual_shift_time}

BATTC00033: Verify advanced filter operation using "All Unscheduled" in Weekly Schedule
    [Documentation]    Verify that the store user can filter All Unscheduled value
    ...    using advanced filters on the week schedule page
    [Tags]    battc00033    dev:moiz    action:read    config:rws    config:weekplan_and_schedule_gen
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    ${scheduled_shifts_exists}    Check One Or More Shift Scheduled On Week Schedule Page On Web
    IF    ${scheduled_shifts_exists}
        ${scheduled_shifts_count}    Get Shifts Count On Week Schedule Page On Web
        Filter By All Unscheduled Shifts On Week Schedule Page On Web
        Verify No Scheduled Shift On Week Schedule Page On Web
        ${unscheduled_shifts_count}    Get Shifts Count On Week Schedule Page On Web
        Should Be True    ${unscheduled_shifts_count} != ${scheduled_shifts_count}
        ...    msg=Unscheduled shifts count should not be equal to scheduled shifts count
        Clear Advanced Filter Search On Week Schedule Page On Web
        ${shifts_count_after_clear_filter}    Get Shifts Count On Week Schedule Page On Web
        Should Be Equal As Numbers    ${scheduled_shifts_count}    ${shifts_count_after_clear_filter}
        ...    msg=Shifts count after clearing filter is not equal to original shifts count
    ELSE
        Skip    No scheduled shifts are present to perform All Unscheduled filter operation
    END

# ==============================================================================
# WEEK 5 — SM1_STORE1
# ==============================================================================

BATTC00031: Verify PDF data for weekly schedule views
    [Documentation]    Test case for verifying Week Schedule PDF Reports download functionality.
    ...    This script will download Weekly Schedule PDF Reports and verify the presence of PDF file
    [Tags]    dev:ravi    action:write    battc00031    config:rws    config:weekplan_and_schedule_gen    checkschedulesetup

    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${user}    Get User    user_key=ESS4_STORE1
    ${schedule_data}    Get Schedule Generation Setup Data    template_name=5_0_sm1_store1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${schedule_data}[week_start_date]
    Go To Schedule Page On Web
    Download And Verify Weekly Schedule Summary PDF Report On Web
    Download And Verify Weekly Schedule Detail PDF Report On Web
    Download And Verify Weekly Associate Summary PDF Report On Web    ${user}[displayName]
    Download And Verify Weekly Associate Detail PDF Report On Web    ${user}[displayName]
    Download And Verify Period Associate Summary PDF Report On Web    ${user}[displayName]    ${schedule_data}[week_start_date]
    ...    ${schedule_data}[week_start_date]
    Download And Verify Period Associate Detail PDF Report On Web    ${user}[displayName]    ${schedule_data}[week_start_date]
    ...    ${schedule_data}[week_start_date]

BATTC00030: Verify display and sort preferences for weekly schedule
    [Documentation]    Test case for verifying display preference detailed view functionality on Week Schedule page
    ...    and verifying sort preferences functionality including Group By Department and Group By Staff Group on Week Schedule page.
    [Tags]    dev:moiz    action:read    battc00030    config:rws    config:weekplan_and_schedule_gen
    ${display_preferences_data}    Get Display Preferences Data
    ${display_detailed_off_data}    Get Display Preferences Data    template_name=summary_view
    ${department_text}    Get System Value    SortPreference    FIRST_DEPARTMENT
    ${staff_group_text}    Get System Value    SortPreference    FIRST_STAFF_GROUP
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${display_preferences_data}[fifth_week]
    Go To Schedule Page On Web
    ${is_published}    Check If Schedule Is In Published State On Web
    Skip If    not ${is_published}    msg=Schedule is not published for fifth week, hence skipping the test case...
    ${total_emp_count}    Get Total Employees Count On Week Schedule Page On Web
    Apply Display Preferences On Week Schedule Page On Web    ${display_preferences_data}
    Verify Detailed View Is Visible On Week Schedule Page On Web    start_time_displayed=True    end_time_displayed=False
    ...    shift_details_displayed=True
    ${emp_count_after_pref}    Get Total Employees Count On Week Schedule Page On Web
    Should Be Equal As Numbers    ${emp_count_after_pref}    ${total_emp_count}
    Apply Display Preferences On Week Schedule Page On Web    ${display_detailed_off_data}
    Verify Detailed View Is Not Visible On Week Schedule Page On Web    start_time_displayed=True    end_time_displayed=True
    ...    shift_details_displayed=False
    ${emp_count_after_reset}    Get Total Employees Count On Week Schedule Page On Web
    Should Be Equal As Numbers    ${emp_count_after_reset}    ${total_emp_count}
    Perform Group By None Sorting On Sort Preferences On Week Schedule Page On Web
    Verify Group By Header Not Visible On Week Schedule Page On Web
    Perform Group By Department Sorting On Sort Preferences On Week Schedule Page On Web
    Verify Group By Header Visible On Week Schedule Page On Web    ${department_text}
    Perform Group By None Sorting On Sort Preferences On Week Schedule Page On Web
    Perform Group By Staff Group Sorting On Sort Preferences On Week Schedule Page On Web
    Verify Group By Header Visible On Week Schedule Page On Web    ${staff_group_text}

BATTC00032: Verify print operations in weekly schedule
    [Documentation]    Verifies print operations in weekly schedule
    [Tags]    action:read    battc00032    dev:bushra    config:rws    config:sm_print_weekly_schedule    config:weekplan_and_schedule_gen
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${user}    Get User    user_key=ESS4_STORE1
    ${schedule_data}    Get Schedule Generation Setup Data    template_name=5_0_sm1_store1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${schedule_data}[week_start_date]
    Go To Schedule Page On Web
    ${is_wss_verified}    Verify Print Weekly Schedule Summary
    ${is_wsd_verified}    Verify Print Weekly Schedule Detail
    ${is_was_verified}    Verify Print Weekly Associate Summary    ${user}[displayName]
    ${is_wad_verified}    Verify Print Weekly Associate Detail    ${user}[displayName]
    ${is_pas_verified}    Verify Print Period Associate Summary    ${user}[displayName]    ${schedule_data}[week_start_date]
    ...    ${schedule_data}[week_start_date]
    ${is_pad_verified}    Verify Print Period Associate Detail    ${user}[displayName]    ${schedule_data}[week_start_date]
    ...    ${schedule_data}[week_start_date]
    ${is_atleast_one_print_verified}    Evaluate
    ...    ${is_wss_verified} or ${is_wsd_verified} or ${is_was_verified} or ${is_wad_verified} or ${is_pas_verified} or ${is_pad_verified}
    IF    not ${is_atleast_one_print_verified}
        Fail    No print operation is verified
    END

BATTC00034: Verify advanced filter operation using task in Weekly Schedule
    [Documentation]    Verify advanced filter operation using task in Weekly Schedule
    [Tags]    battc00034    action:read    dev:bushra    config:rws    config:weekplan_and_schedule_gen
    ${is_workload_present_for_2_staff_groups}    Check Workload Is Present For Activities For At Least Two Staff Groups From User In DB
    ...    user_key=SM1_STORE1
    Skip If    not ${is_workload_present_for_2_staff_groups}
    ...    msg=Workload is not present for activities for at least two staff groups, hence skipping the test case.
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    week_day_input=5_0
    Go To Schedule Page On Web
    ${is_published}    Check If Schedule Is In Published State On Web
    Skip If    not ${is_published}    msg=Schedule is not published hence skipping the test case
    ${total_emp_count}    Get Total Employees Count On Week Schedule Page On Web
    Open Advanced Filter Panel On Week Schedule Page On Web
    @{tasks_list}    Get Tasks In Advanced Filter On Week Schedule Page On Web
    ${task_1}    ${task_2}    Pick Two Random Tasks From Task List    @{tasks_list}
    Select Task In Advanced Filter On Week Schedule Page On Web    ${task_1}    ${task_2}
    Fetch And Apply Advanced Filter On Week Schedule Page On Web
    ${task_filtered_emp_count}    Get Total Employees Count On Week Schedule Page On Web
    IF    ${task_filtered_emp_count} < 1
        Log    No employees scheduled for the selected tasks: ${task_1} and ${task_2}
        Fail    No employees scheduled for the selected tasks: ${task_1} and ${task_2} to be checked manually
    END
    Should Be True    ${task_filtered_emp_count} < ${total_emp_count}    Filtered employee count should be less than total employee count
    Clear Advanced Filter Search On Week Schedule Page On Web
    ${task_unfiltered_emp_count}    Get Total Employees Count On Week Schedule Page On Web
    Should Be Equal As Numbers    ${task_unfiltered_emp_count}    ${total_emp_count}
    ...    msg=Employee count after clearing filter is not equal to total employee count
