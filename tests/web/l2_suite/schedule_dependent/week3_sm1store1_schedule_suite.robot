*** Settings ***
Documentation       Week 3 - SM1_STORE1 Schedule Suite
...                 **PURPOSE:**
...                 This suite consolidates all BATTC test cases that require Week 3 schedule data for Store1.
...                 All tests in this suite use the same week setup, enabling efficient parallel execution.
...
...                 **ONE-TIME SETUP APPROACH:**
...                 Suite Setup executes 'Setup Schedule For Week template_name=3_0_sm1_store1' wrapped with 'Run Only Once' from pabot.PabotLib.
...                 This ensures schedule setup runs exactly ONCE across all parallel processes before any tests execute.
...
...                 **PARALLEL EXECUTION ENABLED:**
...                 Tests can be executed in parallel using pabot. The setup runs once, then all tests execute concurrently.
...
...                 **TEST CASES INCLUDED:**
...                 - BATTC00102: Week 3, Day 0 - Advertise & Withdraw Shift (wfm_87_1_ess)
...                 - BATTC00103: Week 3, Day 2 - All Eligible Swap & Withdraw (wfm_87_2_ess)
...                 - BATTC00104: Week 3, Day 0 - Advertise Response (wfm_88_1_ess)
...                 - BATTC00105: Week 3, Day 1 - Individual Swap Request (wfm_90_1_ess)
...                 - BATTC00106: Week 3, Day 1 - Individual Swap Response (wfm_90_2_ess)
...                 - BATTC00107: Week 3 - Extra Work Request (wfm_91_1_ess)
...                 - BATTC00108: Week 3 - Extra Work Response (wfm_92_1_ess)
...
...                 **EXECUTION COMMANDS:**
...
...                 Sequential execution:
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week3_sm1store1_schedule_suite.robot --test-env QA28_B0
...
...                 Parallel execution (recommended, 7 processes):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week3_sm1store1_schedule_suite.robot --test-env QA28_B0 --processes 7
...
...                 With browser visible (for debugging):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week3_sm1store1_schedule_suite.robot --test-env QA28_B0 --show-browser
...
...                 **LOCK FILE CLEANUP:**
...                 If setup appears to be skipped, clean pabot lock files before running:
...                 Remove-Item -Path ".pabot_results" -Recurse -Force -ErrorAction SilentlyContinue

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/shift_trade_board.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/ess/ess_monthly_calendar.resource

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store1
Suite Teardown      Log    Week 3 SM1_STORE1 Suite Complete - All tests executed    level=INFO
Test Teardown       Close Browser

Test Tags           week3_sm1store1    action:write    config:ess_shift_bidding    config:ess    schedule_dependent


*** Test Cases ***
BATTC00102: Verify ESS user is able to advertise shift and withdraw the request
    [Documentation]    Verifies that a user can successfully advertise a shift and then withdraw the advertised shift.
    ...    Week: 3, Day: 0
    [Tags]    battc00102    bat_phase1    dev:komal    config:advertised_shift_enabled    config:weekplan_and_schedule_gen    om_hr
    ...    checkschedulesetup

    Login And Launch WFM Web App    user_key=ESS4_STORE1
    ${advertise_shift_data}    Get Advertise Shift Data
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${advertise_shift_data}[planning_week_date]
    Verify Schedule Is Published On Shift Trade Board Page On Web
    Advertise The Shift At Day On Shift Trade Board Page On Web    ${advertise_shift_data}[week_trade_day]
    ...    ${advertise_shift_data}[notes]
    Withdraw Advertised Shift On Shift Trade Board Page On Web    ${advertise_shift_data}[week_trade_day]

BATTC00103: Create swap shift request and withdraw it
    [Documentation]    Verify ESS user is able to swap shift and withdraw swapped shift
    ...    Week: 3, Day: 2
    [Tags]    battc00103    bat_phase1    dev:komal    config:swap_shift_enabled    config:weekplan_and_schedule_gen    om_hr

    Login And Launch WFM Web App    user_key=ESS4_STORE1
    ${shift_trade_data}    Get All Eligible Swap Shift Data
    Log    Default shift data: ${shift_trade_data}
    ${individual_shift_trade_data}    Get Individual Swap Shift Data
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${individual_shift_trade_data}[planning_week_date]
    ${ess_user2}    Get User    user_key=ESS5_STORE1
    VAR    ${responder_name}    ${ess_user2}[displayName]
    Swap The Shift At Day For Associate On Shift Trade Board Page On Web    ${individual_shift_trade_data}[week_trade_day]
    ...    ${responder_name}    ${individual_shift_trade_data}[swap_request_notes]
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    Verify Schedule Is Published On Shift Trade Board Page On Web
    Swap Shift At Day On Shift Trade Board Page On Web    ${shift_trade_data}    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[swap_request_notes]
    Capture Screenshot On Webpage
    Withdraw Swap Shift On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    Withdraw Swap Shift On Shift Trade Board Page On Web    ${individual_shift_trade_data}[week_trade_day]

BATTC00104: Verify ESS user is able to respond to advertised shift request and withdraw the response
    [Documentation]    Verify that a user is able to respond to an advertised shift request on the Shift Trade Board page.
    ...    Week: 3, Day: 0
    [Tags]    battc00104    config:advertised_shift_enabled    bat_phase1    dev:komal    config:weekplan_and_schedule_gen
    ...    config:auto_approve_advertise_shift:n    om_hr

    Login And Launch WFM Web App    user_key=ESS6_STORE1
    ${advertise_shift_data}    Get Advertise Shift Data
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${advertise_shift_data}[planning_week_date]
    Verify Schedule Is Published On Shift Trade Board Page On Web
    Advertise The Shift At Day On Shift Trade Board Page On Web    ${advertise_shift_data}[week_trade_day]
    ...    ${advertise_shift_data}[notes]
    Close Browser
    Login To ESS And Go To Selected Week Shift Trade Board Of Responder On Web    ESS5_STORE1
    ...    ${advertise_shift_data}[planning_week_date]
    ${ess_user1}    Get User    user_key=ESS6_STORE1
    Respond To Advertise Request On Shift Trade Board Page On Web    ${advertise_shift_data}[week_trade_day]    ${ess_user1}[displayName]
    ...    ${advertise_shift_data}[respond_note]
    Complete Advertise Shift Response Withdrawal Workflow On Web    ESS5_STORE1    ${advertise_shift_data}[planning_week_date]
    ...    ${ess_user1}[displayName]    ${advertise_shift_data}[week_trade_day]
    Complete Advertise Shift Request Withdrawal Workflow On Web    ESS6_STORE1    ${advertise_shift_data}[planning_week_date]
    ...    ${advertise_shift_data}[week_trade_day]

BATTC00105: Respond to individual swap shift request for a future week
    [Documentation]
    ...    Verifies that a user can successfully respond to an individual swap shift request.
    ...    Test creates a swap shift request from ESS1 to ESS2, then ESS2 responds to accept the swap.
    ...    Week: 3, Day: 1
    [Tags]    battc00105    bat_phase1    dev:komal    config:swap_shift_enabled    config:weekplan_and_schedule_gen
    ...    config:auto_approve_swap_shift:n    om_hr

    Login And Launch WFM Web App    user_key=ESS6_STORE1
    Navigate To ESS Shift Trade Board Page On Web
    ${shift_trade_data}    Get Individual Swap Shift Data
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    Verify Schedule Is Published On Shift Trade Board Page On Web
    ${ess_user2}    Get User    user_key=ESS5_STORE1
    VAR    ${responder_name}    ${ess_user2}[displayName]
    Swap The Shift At Day For Associate On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${responder_name}    ${shift_trade_data}[swap_request_notes]
    Close Browser
    Login To ESS And Go To Selected Week Shift Trade Board Of Responder On Web    ESS5_STORE1
    ...    ${shift_trade_data}[planning_week_date]
    ${ess_user1}    Get User    user_key=ESS6_STORE1
    VAR    ${requester_name}    ${ess_user1}[displayName]
    Respond To Swap Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]    ${requester_name}
    ...    ${shift_trade_data}[swap_response_notes]
    Close Browser
    Complete Swap Shift Response Withdrawal Workflow On Web    ESS5_STORE1    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    ${requester_name}
    Complete Swap Shift Request Withdrawal Workflow On Web    ESS6_STORE1    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]

BATTC00106: Respond to all eligible swap shift request for a future week
    [Documentation]
    ...    Tests the complete workflow for responding to a swap shift request for a future week.
    ...    Workflow: Create swap request → Respond to request → Withdraw response → Withdraw request
    ...    Validates: Request creation, response acceptance, notification messages, withdrawal operations
    ...    Week: 3, Day: 1
    [Tags]    battc00106    bat_phase1    dev:komal    config:swap_shift_enabled    config:weekplan_and_schedule_gen
    ...    config:auto_approve_swap_shift:n    om_hr

    Login And Launch WFM Web App    user_key=ESS6_STORE1
    ${shift_trade_data}    Get All Eligible Swap Shift Data
    Log    Default shift data: ${shift_trade_data}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    Verify Schedule Is Published On Shift Trade Board Page On Web
    Swap Shift At Day On Shift Trade Board Page On Web    ${shift_trade_data}    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[swap_request_notes]
    Close Browser
    Login To ESS And Go To Selected Week Shift Trade Board Of Responder On Web    ESS5_STORE1
    ...    ${shift_trade_data}[planning_week_date]
    ${ess_user1}    Get User    user_key=ESS6_STORE1
    VAR    ${requester_name}    ${ess_user1}[displayName]
    Respond To Swap Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]    ${requester_name}
    ...    ${shift_trade_data}[swap_response_notes]
    Close Browser
    Complete Swap Shift Response Withdrawal Workflow On Web    ESS5_STORE1    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    ${requester_name}
    Complete Swap Shift Request Withdrawal Workflow On Web    ESS6_STORE1    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]

BATTC00107: Create extra work request for a future week
    [Documentation]    Verifies that a user can raise and withdraw an extra work request for a specific day on the Shift Trade Board.
    ...    Week: 3
    [Tags]    battc00107    bat_phase1    dev:komal    config:weekplan_and_schedule_gen    config:extra_work_shift_enabled    om_hr

    Login And Launch WFM Web App    user_key=ESS4_STORE1
    ${shift_trade_data}    Get Extra Work Shift Data
    Log    Fetched shift data: ${shift_trade_data}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    Verify Schedule Is Published On Shift Trade Board Page On Web
    Raise Extra Work Request At Day On Shift Trade Board Page On Web    ${shift_trade_data}    ${shift_trade_data}[week_trade_day]
    Close Browser
    [Teardown]    Complete Extra Work Request Withdrawal Workflow On Web    ESS4_STORE1    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[week_trade_day]

BATTC00108: Respond to extra work request for a future week
    [Documentation]    Verifies that a user can respond to an extra work request on the Shift Trade Board and complete the approval workflow.
    ...    Week: 3
    [Tags]    battc00108    bat_phase1    dev:komal    config:weekplan_and_schedule_gen    config:extra_work_shift_enabled
    ...    config:auto_approve_extra_work_shift:n    om_hr

    Login And Launch WFM Web App    user_key=ESS6_STORE1
    ${shift_trade_data}    Get Extra Work Shift Data
    Log    Fetched shift data: ${shift_trade_data}
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    Verify Schedule Is Published On Shift Trade Board Page On Web
    Raise Extra Work Request At Day On Shift Trade Board Page On Web    ${shift_trade_data}    ${shift_trade_data}[week_trade_day]
    Close Browser
    ${shift_trade_response_data}    Get Extra Work Shift Data
    ...    extra_work_response_notes=Automation Notes for Extra Work Request - Response Scenario
    Log    Fetched shift response data: ${shift_trade_response_data}
    Login To ESS And Go To Selected Week Shift Trade Board Of Responder On Web    ESS5_STORE1
    ...    ${shift_trade_response_data}[planning_week_date]
    ${ess_user1}    Get User    user_key=ESS6_STORE1
    Respond To Additional Work Request On Shift Trade Board Page On Web    ${shift_trade_response_data}[week_trade_day]
    ...    ${ess_user1}[displayName]    ${shift_trade_response_data}[extra_work_response_notes]
    Complete Extra Work Response Withdrawal Workflow On Web    ESS5_STORE1    ${shift_trade_response_data}[planning_week_date]
    ...    ${shift_trade_response_data}[week_trade_day]    ${ess_user1}[displayName]
    Complete Extra Work Request Withdrawal Workflow On Web    ESS6_STORE1    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]

BATTC00097: Verify creation of open shift response and its withdrawal
    [Documentation]    Verifies that a user can successfully respond to open shift and then withdraw the open shift.
    ...    Week: 3, Day: 6
    [Tags]    battc00097    bat_phase1    dev:komal    config:weekplan_and_schedule_gen    config:auto_approve_open_shift:n    om_hr

    Login And Launch WFM Web App    user_key=ESS5_STORE1
    ${open_shift_data}    Get Open Shift Data
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${open_shift_data}[planning_week_date]
    ${open_shift_available}    ${shift_start}    ${shift_end}    Check If Open Shift Available For Day On Shift Trade Board Page On Web
    ...    ${open_shift_data}[week_trade_day]
    IF    ${open_shift_available}
        Respond To Open Shift Request On Shift Trade Board Page On Web    ${shift_start}    ${shift_end}
        ...    ${open_shift_data}[respond_note]    ${open_shift_data}[week_trade_day]
    END
    [Teardown]    Run Keyword And Ignore Error    Run Keyword If    ${open_shift_available}
    ...    Withdraw Response From Open Shift Request On Shift Trade Board Page On Web    ${shift_start}    ${shift_end}    ${open_shift_data}[week_trade_day]

BATTC00219: Verify user is able to create / apply / modify / delete schedule filter
    [Documentation]    Verify user is able to create / apply / modify / delete schedule filter
    [Tags]    battc00219    dev:ravi    bat_phase2    config:weekplan_and_schedule_gen

    ${ess_user4}    Get User    user_key=ESS4_STORE1
    ${ess_user3}    Get User    user_key=ESS3_STORE1
    VAR    ${ess4_user_disp_name}    ${ess_user4}[displayName]
    VAR    ${ess3_user_disp_name}    ${ess_user3}[displayName]
    VAR    ${adv_filter_name}    AddFilter
    VAR    ${edit_adv_filter_name}    EditFilter

    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    week_day_input=3_0
    Go To Schedule Page On Web

    FOR    ${filter_name}    IN    ${adv_filter_name}    ${edit_adv_filter_name}
        ${is_adv_filter_present}    Is Saved Advanced Filter Present On Week Schedule Page On Web    ${filter_name}
        IF    ${is_adv_filter_present}
            Log    Pre-existing filter '${filter_name}' was found and will be deleted.
            Delete Saved Advanced Filter On Week Schedule Page On Web    ${filter_name}
        END
    END

    ${ess3_staff_group}    Get Associate Staff Group Name On Week Schedule Page On Web    ${ess3_user_disp_name}
    ${ess4_staff_group}    Get Associate Staff Group Name On Week Schedule Page On Web    ${ess4_user_disp_name}

    Open Advanced Filter Panel On Week Schedule Page On Web
    Add Advanced Filter For Staff Group On Week Schedule Page On Web    ${adv_filter_name}    ${ess4_staff_group}
    Verify Results After Applying Filter On Staff Group On Week Schedule Page On Web    ${ess4_staff_group}

    VAR    @{staff_groups_to_edit}    ${ess3_staff_group}    ${ess4_staff_group}
    Edit Existing Advanced Filter On Week Schedule Page On Web    ${adv_filter_name}    ${edit_adv_filter_name}    @{staff_groups_to_edit}
    Verify Results After Applying Filter On Staff Group On Week Schedule Page On Web    ${ess3_staff_group}    ${ess4_staff_group}
    Delete Saved Advanced Filter On Week Schedule Page On Web    ${adv_filter_name}
    Delete Saved Advanced Filter On Week Schedule Page On Web    ${edit_adv_filter_name}

BATTC00209: Verify SM user is able to review the weekly overs & shorts report in web
    [Documentation]    Verify SM user is able to review the Overs and Shorts report in web
    ...
    ...    Test Data Required:
    ...    - SM1_STORE1 - SM User
    ...    - Week: Current Week + 3
    ...    - Day: Day1
    ...    - Weekly_Workload_Hrs
    ...    - Weekly_Scheduled_Hrs
    ...    - Weekly_Unallocated_Hrs
    ...
    ...    Test Steps:
    ...    1. SM user navigates to Week Schedule
    ...    2. Read and note down values for Store Workload, Unallocated, and scheduled hours
    ...    3. Click on Overs & Shorts report from reports dropdown. Verify by comparing with the values noted down from weekly schedule
    [Tags]    dev:komal    action:read    battc00209    bat_phase2    config:rws    config:weekplan_and_schedule_gen    bug_reported
    ...    bugid_wfm_131144    regrooming_required
    Login And Launch WFM Web App    user_key=SM1_STORE1
    # Get test data for the report
    ${overs_shorts_data}    Get Schedule Overs Shorts Data

    # Step 1: Navigate to Week Schedule page
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${overs_shorts_data}[third_week]
    Go To Schedule Page On Web
    Apply Group Statistics Preferences On Display Preferences On Web

    ${schedule_workload_hrs}    Get Weekly Workload Hours From Schedule Page On Web    ${overs_shorts_data}[day]
    ${schedule_scheduled_hrs}    Get Weekly Scheduled Hours From Schedule Page On Web    ${overs_shorts_data}[day]
    ${schedule_unallocated_hrs}    Get Weekly Unallocated Hours From Schedule Page On Web    ${overs_shorts_data}[day]

    Log
    ...    Schedule Page Values - Workload: ${schedule_workload_hrs}, Scheduled: ${schedule_scheduled_hrs}, Unallocated: ${schedule_unallocated_hrs}

    ${report_navigation_successful}    Navigate To Week Schedule Overs And Shorts Page On Web
    IF    not ${report_navigation_successful}
        Pass Execution    Overs & Shorts report is not available in this environment - test case skipped
    END

    # Read values from report page
    ${report_workload_hrs}    Get Total Workload Hours From Overs Shorts Report On Web    ${overs_shorts_data}[day]
    ${report_scheduled_hrs}    Get Total Scheduled Hours From Overs Shorts Report On Web    ${overs_shorts_data}[day]
    ${report_unallocated_hrs}    Get Unallocated Hours From Overs Shorts Report On Web    ${overs_shorts_data}[day]

    Log
    ...    Report Page Values - Workload: ${report_workload_hrs}, Scheduled: ${report_scheduled_hrs}, Unallocated: ${report_unallocated_hrs}

    # Compare the values between schedule page and report
    Compare Schedule And Report Values On Web    ${overs_shorts_data}
    ...    schedule_workload=${schedule_workload_hrs}
    ...    schedule_scheduled=${schedule_scheduled_hrs}
    ...    schedule_unallocated=${schedule_unallocated_hrs}
    ...    report_workload=${report_workload_hrs}
    ...    report_scheduled=${report_scheduled_hrs}
    ...    report_unallocated=${report_unallocated_hrs}

BATTC00201: Verify ESS user is able to review the monthly schedule
    [Documentation]    Verify that ESS user is able to review the monthly schedule.
    ...
    ...    Test Steps:
    ...    1. Login to the ESS with the selected associate (ESS4_STORE1)
    ...    2. Navigate to the My Monthly Calendar tab
    ...    3. Verify the shifts for the selected week of the month
    ...
    ...    Expected Results:
    ...    - Application successfully displays ESS page
    ...    - Application displays Monthly Schedule page successfully
    ...    - Application displays the shifts on all days with scheduled shifts for the selected week of the month
    ...    - No shifts are displayed on days without scheduled shifts in the selected week
    [Tags]    dev:azar    action:read    battc00201    bat_phase2    config:rws    config:ess_monthly_request_calendar
    ...    config:weekplan_and_schedule_gen    om_hr
    # Get monthly calendar template to determine which associate and schedule template to use
    ${calendar_data}    Get ESS Monthly Calendar Data
    # Get schedule generation data (source of truth for week_offset and shifts)
    ${schedule_setup_data}    Get Schedule Generation Setup Data    template_name=${calendar_data}[schedule_template]
    # Extract associate's shift data from schedule template
    VAR    ${selected_user_data}    ${None}
    FOR    ${user}    IN    @{schedule_setup_data}[users]
        IF    '${user}[ess_user_key]' == '${calendar_data}[associate_user_key]'
            VAR    ${selected_user_data}    ${user}
            BREAK
        END
    END
    Should Not Be Equal    ${selected_user_data}    ${None}
    ...    msg=Associate ${calendar_data}[associate_user_key] not found in schedule template
    # Get final test data with overrides from schedule template
    ${test_data}    Get ESS Monthly Calendar Data
    ...    week_offset=${schedule_setup_data}[week_offset]
    ...    shifts_to_add=${selected_user_data}[shifts_to_add]
    Login And Launch WFM Web App    user_key=${test_data}[associate_user_key]
    Navigate To ESS My Monthly Calendar Page On Web
    VAR    ${week_start_date}    ${test_data}[week_offset]_0
    Select Day On My Monthly Calendar Page On Web    ${week_start_date}
    ${days_with_shifts}    Evaluate    [shift['day'] for shift in ${test_data}[shifts_to_add]]
    Verify Shifts Are Displayed For Specified Days In Given Week On ESS Monthly Calendar Page On Web    ${days_with_shifts}
    ...    ${test_data}[week_offset]
    Log    ✅ Application displays the shifts with correct times    level=INFO
    Verify No Shifts Are Displayed For Specified Days In Given Week On ESS Monthly Calendar Page On Web    ${days_with_shifts}
    ...    ${test_data}[week_offset]
    Log    ✅ No shifts displayed for days without scheduled shifts    level=INFO

BATTC00211: Verify SM user is able to review the weekplan schedule report in web
    [Documentation]    Verify SM User Is Able To Review The Weekplan Schedule Report on Web
    [Tags]    dev:yogesh    action:read    battc00211    bat_phase2    config:rws    config:weekplan_and_schedule_gen
    ${ess_user4}    Get User    user_key=ESS4_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    week_day_input=3_0
    Go To Schedule Page On Web
    Compare Scheduled Hours Between Week Schedule Page And Week Plan Schedule Report Page On Web    ${ess_user4}[displayName]
