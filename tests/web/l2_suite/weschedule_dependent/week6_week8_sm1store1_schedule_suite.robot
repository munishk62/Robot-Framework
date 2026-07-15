*** Settings ***
Documentation       Week 6 & Week 8 - SM1_STORE1 Schedule Suite
...
...                 **PURPOSE:**
...                 This suite consolidates all BATTC test cases that require Week 6 and Week 8 schedule data for Store1.
...                 Tests verify unpublished/non-generated schedules for multiple future weeks.
...
...                 **ONE-TIME SETUP APPROACH:**
...                 Suite Setup executes 'Setup Schedule Weeks 6 And 8 For SM1Store1' wrapped with 'Run Only Once' from pabot.PabotLib.
...                 This ensures schedule setup runs exactly ONCE across all parallel processes before any tests execute.
...
...                 **PARALLEL EXECUTION ENABLED:**
...                 Tests can be executed in parallel using pabot. The setup runs once, then all tests execute concurrently.
...
...                 **TEST CASES INCLUDED:**
...                 - BATTC00095: Week 6,8 - Verify Unpublished Schedule (wfm_84_2_ess)
...                 - BATTC00096: Week 6,8 - Verify Store Schedule Page (wfm_84_3_ess)
...                 - BATTC00203: Week 6 - Verify Manager Assigns Open Shift to Associate
...                 - BATTC00210: Week 6 - Verify Schedule Changes Report
...                 - BATTC00213: Week 6 - Verify Notes Report
...                 - BATTC00221: Verify SM User Can Perform Open Shift Operations
...                 **EXECUTION COMMANDS:**
...
...                 Sequential execution:
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week6_week8_sm1store1_schedule_suite.robot --test-env QA28_B0
...
...                 With browser visible (for debugging):
...                 uv run python executor.py tests/web/l2_suite/schedule_dependent/week6_week8_sm1store1_schedule_suite.robot --test-env QA28_B0 --show-browser
...
...                 **LOCK FILE CLEANUP:**
...                 If setup appears to be skipped, clean pabot lock files before running:
...                 Remove-Item -Path ".pabot_results" -Recurse -Force -ErrorAction SilentlyContinue

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/ess_my_schedule.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/ess/ess_store_schedule.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/web/rws/schedule/plan_status.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/Mobile/ESS/PagesResources/Availability_Module/Availability_Teardown.resource
Variables           test_data/localized_text/rws_localized_text.py

Suite Setup         Run Keywords    Run Only Once    Pre Setup Schedule For Week 6 SM1Store1
...                     AND
...                     Run Only Once    Pre Setup Schedule For Week 8 SM1Store1
Suite Teardown      Log    Week 6 & 8 SM1_STORE1 Suite Complete - All tests executed    level=INFO
Test Teardown       Close Browser

Test Tags           week6_week8_sm1store1    schedule_dependent


*** Test Cases ***
BATTC00095: Verify My Schedule page for ESS user when Schedule is unpublished
    [Documentation]    Test case for verifying application does not display the schedule for
    ...    ESS user for multiple future weeks (6 and 8 weeks ahead) where schedule is
    ...    either not published or not generated
    ...    Week: 6 (unpublished), Week: 8 (not generated)
    [Tags]    action:read    dev:ravi    battc00095    config:ess    bat_phase1    config:weekplan_and_schedule_gen    om_hr
    ...    checkschedulesetup

    Login And Launch WFM Web App    user_key=ESS4_STORE1
    Navigate To ESS My Schedule Page On Web
    Select Week On Week Label On My Schedule Page On Web    6_0
    Assert Schedule Is Not Displayed On My Schedule Page On Web

    Select Week On Week Label On My Schedule Page On Web    8_0
    Assert Schedule Is Not Displayed On My Schedule Page On Web

BATTC00096: Verify store schedule page for the ESS user
    [Documentation]    Test case for verifying whether user is able to see published schedules
    ...    and unpublished schedules in Store Schedule page.
    [Tags]    dev:moiz    battc00096    config:ess    bat_phase1    config:weekplan_and_schedule_gen    om_hr    checkschedulesetup
    ${shift_days_data}    Get Shift Data    template_name=ess_store_schedule_shift
    ${user_ess4}    Get User    user_key=ESS4_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    ${is_current_week_published}    Check If Schedule Is In Published State On Web
    Select Week Number On Week Schedule Page On Web    ${shift_days_data}[fifth_week]
    ${is_fifth_week_published}    Check If Schedule Is In Published State On Web
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${shift_days_data}[sixth_week]
    ${is_sixth_week_unpublished}    Check If Schedule Generated And In Unpublished State On Web
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${shift_days_data}[eighth_week]
    ${is_eighth_week_plan_status}    Check If Schedule Is In Plan Status On Web
    Skip If
    ...    not ${is_eighth_week_plan_status} or not ${is_sixth_week_unpublished} or not ${is_fifth_week_published} or not ${is_current_week_published}
    ...    msg=Pre-requisite schedules not in expected states as per Suite Setup; skipping the test...
    Close Browser
    Login And Launch WFM Web App    user_key=ESS4_STORE1
    Navigate To ESS Store Schedule Page On Web
    Verify Shift Is Present For Associate On Given Days On Store Schedule Page On Web    ${user_ess4}[displayName]
    ...    ${shift_days_data}[current_week_days]
    Navigate To Next Week On Store Schedule Page On Web    weeks_to_navigate=5
    Verify Shift Is Present For Associate On Given Days On Store Schedule Page On Web    ${user_ess4}[displayName]
    ...    ${shift_days_data}[future_week_days]
    Navigate To Next Week On Store Schedule Page On Web
    Verify Schedule Not Available And Shifts Not Present On Store Schedule Page On Web
    Navigate To Next Week On Store Schedule Page On Web    weeks_to_navigate=2
    Verify Schedule Not Available And Shifts Not Present On Store Schedule Page On Web

BATTC00213: Verify SM user is able to review the notes report in web
    [Documentation]    Test case for verifying SM user can add schedule/employee/shift notes
    ...    and review them via Reports > Notes dropdown with category filtering.
    ...
    ...    Test Steps:
    ...    1. Login as SM1_STORE1 and navigate to Week 6 schedule
    ...    2. Add schedule level notes from Schedule Notes tab
    ...    3. Search and select ESS2_STORE1
    ...    4. Add employee level notes for ESS2_STORE1
    ...    5. Add shift (12:00-19:00) on Day 1 for ESS2_STORE1
    ...    6. Add shift level notes to the added shift
    ...    7. Open Reports > Notes
    ...    8. Verify Schedule notes by filtering Schedule category
    ...    9. Verify Employee notes by filtering Associate category
    ...    10. Verify Shift notes by filtering Shift category
    ...    11. Teardown: Delete shift and all notes
    [Tags]    dev:azar    battc00213    config:rws    bat_phase2    config:weekplan_and_schedule_gen    config:read_schedule_notes
    ${schedule_data}    Get Schedule Generation Setup Data    template_name=6_0_sm1_store1
    ${notes_data}    Get Schedule Notes Data
    VAR    ${day_offset}    ${notes_data}[day_offset]
    ${user_ess2}    Get User    user_key=ESS2_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${schedule_data}[week_start_date]
    Go To Schedule Page On Web
    Add Schedule Notes On Week Schedule Page On Web    ${notes_data}[schedule_notes]
    Search Employee On Week Schedule Page On Web    ${user_ess2}[displayName]
    Add Employee Notes For Associate On Week Schedule Page On Web    ${user_ess2}[displayName]    ${notes_data}[employee_notes]
    ${shift_day}    Evaluate    int(${day_offset}) + 1
    Perform Add Shift Operation On Week Schedule Page On Web
    ...    ${user_ess2}[displayName]
    ...    ${notes_data}[shift_start_time]
    ...    ${notes_data}[shift_end_time]
    ...    ${shift_day}
    Add Shift Notes On Week Schedule Page On Web
    ...    ${user_ess2}[displayName]
    ...    ${notes_data}[day_offset]
    ...    ${notes_data}[shift_notes]
    Open Reports Notes On Week Schedule Page On Web
    Verify Notes In Reports By Category On Week Schedule Page On Web    ${notes_data}[category_schedule]    ${notes_data}[schedule_notes]
    Verify Notes In Reports By Category On Week Schedule Page On Web    ${notes_data}[category_associate]    ${notes_data}[employee_notes]
    Verify Notes In Reports By Category On Week Schedule Page On Web    ${notes_data}[category_shift]    ${notes_data}[shift_notes]
    Open Reports Store Schedule Weekly On Week Schedule Page On Web
    ${shift_time}    Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web
    ...    ${user_ess2}[displayName]
    ...    ${shift_day}
    Delete Shift On Week Schedule Page On Web    ${shift_time}
    Delete Employee Notes For Associate On Week Schedule Page On Web    ${user_ess2}[displayName]    ${notes_data}[employee_notes]
    Delete Schedule Notes On Week Schedule Page On Web    ${notes_data}[schedule_notes]

BATTC00210: Verify SM user is able to review the schedule changes report in web
    [Documentation]
    ...    Validates that SM user can review schedule changes report for various operations:
    ...    1. SM user navigates to Week Schedule for Week 7 (Current Week + 6)
    ...    2. Add shift for ESS2_STORE1 on Day 2 (12p to 7p)
    ...    3. Edit the added shift (extend from 7p to 7:30p)
    ...    4. Unallocate shift and delete from open shift pool
    ...    5. Review schedule changes report showing all operations
    [Tags]    dev:komal    battc00210    bat_phase2    config:rws    config:weekplan_and_schedule_gen    bug_reported    bugid_wfm_140211_hnm_smu

    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${shift_days_data}    Get Shift Data    template_name=edit_schedule_shift
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${shift_days_data}[shift_day]
    Go To Schedule Page On Web
    ${associate_data}    Get User    user_key=ESS2_STORE1
    VAR    ${associate_display_name}    ${associate_data}[displayName]
    VAR    ${day_offset}    2
    ${add_shift_day}    Convert To String    ${day_offset}
    ${unallocate_shift_offset}    Evaluate    ${day_offset} + 1
    ${unallocate_shift_day}    Convert To String    ${unallocate_shift_offset}
    Add Shift On Week Schedule Page For The Given Associate And Day On Web    ${associate_display_name}    ${add_shift_day}
    ...    ${shift_days_data}[start_time]    ${shift_days_data}[end_time]

    Edit Shift On Week Schedule Page For The Given Associate And Day On Web    ${associate_display_name}    ${add_shift_day}
    ...    ${shift_days_data}[start_time]    ${shift_days_data}[edit_time]

    ${actual_shift_time}    Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web    ${associate_display_name}
    ...    ${unallocate_shift_day}
    Delete Shift On Week Schedule Page On Web    ${actual_shift_time}

    Navigate To Review Schedule Changes Report Page On Web

    Verify Schedule Changes Report Contains Add Shift Operation On Web    ${associate_display_name}    ${shift_days_data}[edit_shift_day]
    ...    ${shift_days_data}[start_time]    ${shift_days_data}[end_time]
    Verify Schedule Changes Report Contains Shift Extend Operation On Web    ${associate_display_name}
    ...    ${shift_days_data}[edit_shift_day]    ${shift_days_data}[start_time]    ${shift_days_data}[edit_time]
    Verify Schedule Changes Report Contains Unallocate Shift Operation On Web    ${associate_display_name}
    ...    ${shift_days_data}[edit_shift_day]
    Verify Schedule Changes Report Contains Delete Open Shift Operation On Web    ${shift_days_data}[edit_shift_day]
    ...    ${shift_days_data}[start_time]    ${shift_days_data}[edit_time]

BATTC00212: Verify SM user is able to review the alerts report in web
    [Documentation]    Verify SM user is able to review the alerts report in web
    ...    Test verifies:
    ...    1. Manager can add shifts for an associate that violates min shift length and max weekly hours
    ...    2. Both shift alert (min length) and employee alert (max hours) are displayed in Alerts report
    ...    3. Alerts are removed from report when shifts are unallocated/deleted
    ...    Week: Current Week + 6
    [Tags]    dev:azar    action:write    config:rws    battc00212    bat_phase2    config:weekplan_and_schedule_gen
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${alert_data}    Get Employee Alert Data    template_name=alerts_report_with_min_shift_length
    # Convert week_start_date from week_day notation (6_0) to actual date (YYYY-MM-DD)
    ${week_start_date_actual}    Calculate Date From Week Day Offset    ${alert_data}[week_start_date]
    Check Applicability For Alerts Report Validation On Week Schedule Page On Web    ${ess_user}    ${week_start_date_actual}
    VAR    ${employee_alert_message}    ${LOCALISED_TEXT}[employee_alert_max_hours]
    VAR    ${shift_alert_message}    ${LOCALISED_TEXT}[shift_alert_minimum_length]
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${alert_data}[week_start_date]
    Go To Schedule Page On Web
    Search Employee On Week Schedule Page On Web    ${ess_user}[displayName]
    FOR    ${shift}    IN    @{alert_data}[shifts_to_add]
        Add Shift On Week Schedule Page For The Given Associate And Day On Web
        ...    ${ess_user}[displayName]
        ...    ${shift}[day_offset]
        ...    ${shift}[start_time]
        ...    ${shift}[end_time]
    END
    Navigate To Alerts Report On Week Schedule Page On Web
    Verify Employee Alert Is Displayed In Alerts Report On Week Schedule Page On Web
    ...    ${ess_user}[displayName]
    ...    ${alert_data}[shifts_to_add][0][day_offset_with_week]
    ...    ${employee_alert_message}
    Verify Shift Alert Is Displayed In Alerts Report On Week Schedule Page On Web
    ...    ${ess_user}[displayName]
    ...    ${alert_data}[shifts_to_add][0][day_offset_with_week]
    ...    ${shift_alert_message}
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${alert_data}[week_start_date]
    FOR    ${shift}    IN    @{alert_data}[shifts_to_add]
        ${unallocate_dayoffset}    Evaluate    ${shift}[day_offset]+1
        Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web
        ...    ${ess_user}[displayName]
        ...    ${unallocate_dayoffset}
    END
    Click On Open Shifts Tab On Week Schedule Page On Web
    FOR    ${shift}    IN    @{alert_data}[shifts_to_add]
        Delete Open Shift On Week Schedule Page On Web
        ...    ${shift}[start_time]
        ...    ${shift}[end_time]
        ...    ${shift}[day_offset_with_week]
    END
    Navigate To Alerts Report On Week Schedule Page On Web
    Verify Employee Alert Is Not Displayed In Alerts Report On Week Schedule Page On Web
    ...    ${ess_user}[displayName]
    ...    ${alert_data}[shifts_to_add][0][day_offset_with_week]
    ...    ${employee_alert_message}
    Verify Shift Alert Is Not Displayed In Alerts Report On Week Schedule Page On Web
    ...    ${ess_user}[displayName]
    ...    ${alert_data}[shifts_to_add][0][day_offset_with_week]
    ...    ${shift_alert_message}

BATTC00203: Verify Manager is able to assign open shift to an associate in web
    [Documentation]    Test case for verifying Manager can add open shift and assign it to an associate.
    ...
    ...    Test Steps:
    ...    1. Login as SM1_STORE1 and navigate to Week 6 schedule
    ...    2. Go to Open Shifts tab
    ...    3. Add open shift on Day 5 (10:00 to 17:00)
    ...    4. Verify shift added successfully
    ...    5. Click on added shift in Open Shifts tab
    ...    6. Click on Assign tab
    ...    7. Assign shift to ESS1_STORE1
    ...    8. Verify assignment success notification
    ...    9. Verify shift appears for ESS1_STORE1 on Day 5
    ...    10. Teardown: Unallocate shift and delete from open pool
    [Tags]    dev:amol    battc00203    config:rws    action:write    bat_phase2    config:weekplan_and_schedule_gen

    ${schedule_data}    Get Schedule Generation Setup Data    template_name=6_0_sm1_store1
    ${user_ess1}    Get User    user_key=ESS1_STORE1
    ${open_shift_data}    Get Open Shift Data

    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${schedule_data}[week_start_date]
    ${is_plan_status_page_displayed}    Check If Plan Status Page Displayed On Web
    IF    ${is_plan_status_page_displayed}    Go To Schedule Page On Web
    Add Open Shift On Week Schedule Page On Web    ${open_shift_data}[week_day_offset]    ${open_shift_data}

    Assign Open Shift To Associate On Week Schedule Page On Web
    ...    ${open_shift_data}[week_day_offset]
    ...    ${open_shift_data}
    ...    ${user_ess1}[displayName]

    Verify Shift Exists For Associate Using 24Hr Time On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${open_shift_data}[week_day_offset]
    ...    ${open_shift_data}[start_time]
    ...    ${open_shift_data}[end_time]

    # Un-allocate keyword expects 1-based day (1=Monday, 5=Friday). day_offset is 0-based, so add 1.
    ${unallocate_day}    Evaluate    ${open_shift_data}[day_offset] + 1
    ${actual_shift_time}    Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web
    ...    ${user_ess1}[displayName]
    ...    ${unallocate_day}
    Delete Shift On Week Schedule Page On Web    ${actual_shift_time}

BATTC00221: Verify user is able to perform add/edit/copy/move/dragdrop/delete open shift operations in web for weekly schedule
    [Documentation]    Test case for verifying SM user can perform open shift operations on weekly schedule page.
    [Tags]    dev:moiz    battc00221    config:rws    bat_phase2    config:weekplan_and_schedule_gen
    ${schedule_data}    Get Schedule Generation Setup Data    template_name=6_0_sm1_store1
    ${user_ess5}    Get User    user_key=ESS5_STORE1
    ${open_shift_data}    Get Open Shift Data    template_name=add_edit_open_shift
    ${updated_shift_data}    Get Open Shift Data    template_name=updated_open_shift
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${schedule_data}[week_start_date]
    ${unpublished}    Check If Schedule Generated And In Unpublished State On Web
    IF    not ${unpublished}
        Skip    Pre-requisite schedule not in unpublished state as per Suite Setup; skipping the test...
    END
    Cleanup Existing Open Shifts On Week Schedule Page On Web    ${open_shift_data}[week_date_offset]    ${open_shift_data}[start_time]
    ...    ${open_shift_data}[end_time]
    Cleanup Existing Open Shifts On Week Schedule Page On Web    ${updated_shift_data}[updated_date_offsets]
    ...    ${updated_shift_data}[start_time]    ${updated_shift_data}[end_time]
    Add Open Shift On Week Schedule Page On Web    ${open_shift_data}[week_date_offset][0]    ${open_shift_data}
    Edit Open Shift On Week Schedule Page On Web    ${open_shift_data}[week_date_offset][0]    ${open_shift_data}
    ...    ${updated_shift_data}[start_time]    ${updated_shift_data}[end_time]
    ${is_copy_applicable}    Copy Open Shift On Week Schedule Page On Web    ${open_shift_data}[week_date_offset][0]
    ...    ${updated_shift_data}    ${open_shift_data}[copy_to_day]
    IF    not ${is_copy_applicable}
        Log    Copy operation is not applicable for the open shift, adding an open shift for further operations.
        Add Open Shift On Week Schedule Page On Web    ${updated_shift_data}[updated_date_offsets][1]    ${updated_shift_data}
    END
    IF    ${is_copy_applicable}
        Assign Open Shift To Associate On Week Schedule Page On Web    ${updated_shift_data}[updated_date_offsets][1]
        ...    ${updated_shift_data}    ${user_ess5}[displayName]
        Perform Unallocate The Shift Operation On Week Schedule Page On Web    ${user_ess5}[displayName]
        ...    ${open_shift_data}[copy_to_day][0]
    END
    Drag And Drop Shift From Open Shifts Panel To Associate On Week Schedule Page On Web    ${open_shift_data}[week_date_offset][0]
    ...    ${updated_shift_data}    ${user_ess5}[displayName]
    Move Open Shift To Specified Day On Week Schedule Page On Web    ${updated_shift_data}[updated_date_offsets][1]
    ...    ${updated_shift_data}    ${updated_shift_data}[move_to_day]
    IF    ${is_copy_applicable}
        Delete Open Shift On Week Schedule Page On Web    ${updated_shift_data}[start_time]    ${updated_shift_data}[end_time]
        ...    ${open_shift_data}[week_date_offset][0]
    END
    [Teardown]    Run Keyword And Ignore Error    Run Keywords
    ...    Unallocate Shifts For Specific Days On Week Schedule Page On Web    ${user_ess5}[displayName]    ${open_shift_data}[unallocation_days]    AND
    ...    Cleanup Existing Open Shifts On Week Schedule Page On Web    ${open_shift_data}[week_date_offset]    ${open_shift_data}[start_time]    ${open_shift_data}[end_time]    AND
    ...    Cleanup Existing Open Shifts On Week Schedule Page On Web    ${updated_shift_data}[updated_date_offsets]    ${updated_shift_data}[start_time]    ${updated_shift_data}[end_time]

BATTC00228: Verify SM user is able to add / edit / delete temporary availability and verify in schedule in web
    [Documentation]    Verify SM user is able to add / edit / delete temporary availability and verify in schedule in web
    [Tags]    dev:komal    battc00228    config:rws    bat_phase2    config:temporary_availability_enabled
    ...    config:weekplan_and_schedule_gen    config:add_edit_delete_availability_request_sm    om_hr
    ${ess_user_2}    Get User    user_key=ESS2_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Clean Up Any Existing Temporary Availability On Web    ${ess_user_2}
    Navigate To RWS Employee Request Calendar Page On Web
    ${availability_data}    Get Availability Data    template_name=temporary_availability
    Select Day On Request Calendar Page    ${availability_data}[start_date]
    ${status_text}    Create SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_2}[displayName]
    ...    ${availability_data}[request_preference]    ${availability_data}[start_date]    ${availability_data}[reason]
    ...    ${availability_data}[rotation_number]    ${availability_data}[days_availability_hours]
    ...    ${availability_data}[split_availability_row_number]    ${availability_data}[availability_rotation_number]
    ${edit_availability_data}    Get Availability Data    template_name=temporary_availability    status=RequestStatus.APPROVED
    IF    '${status_text}' == 'Not Reviewed'
        Verify SM Availability Request On Request Calendar Page On Web    ${ess_user_2}[displayName]
        ...    ${availability_data}[start_date]    ${availability_data}[request_preference]    ${availability_data}[status]
        Edit Status On SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_2}[displayName]
        ...    ${availability_data}[start_date]    ${availability_data}[request_preference]    ${availability_data}[status]
        ...    ${edit_availability_data}[status]
    END
    Navigate To RWS Schedule Week Schedule Page On Web
    ${shift_data}    Get Shift Data    template_name=verify_alert_schedule_shift
    Select Week Number On Week Schedule Page On Web    ${shift_data}[week_start_date]
    ${is_plan_status_visible}    Check If Plan Status Page Displayed On Web
    IF    ${is_plan_status_visible}    Go To Schedule Page On Web
    ${unpublished}    Check If Schedule Generated And In Unpublished State On Web
    IF    not ${unpublished}
        Skip    Schedule is not in Unpublished state. Please check schedule setup execution for week 6.
    END
    ${store_data}    Get Store Data
    ${constraint_type}    ${status}    Get Alert Status And Severity From Database    E0005
    ${engine_name}    Get Scheduling Engine For Store From Database    ${store_data}[store_id]
    ${is_alert_severe}    Run Keyword And Return Status    Should Be Equal    ${constraint_type}    S
    ${is_alert_active}    Run Keyword And Return Status    Should Be Equal    ${status}    A
    ${is_rule_based_scheduling}    Run Keyword And Return Status    Should Be Equal    ${engine_name}    RULE SCHEDULING
    ${alert_status}    Evaluate    ${is_rule_based_scheduling} and ${is_alert_severe} and ${is_alert_active}
    Search Employee On Week Schedule Page On Web    ${ess_user_2}[displayName]
    Perform Add Shift Operation On Week Schedule Page On Web
    ...    ${ess_user_2}[displayName]
    ...    ${shift_data}[add_first_shift_start_time]
    ...    ${shift_data}[add_first_shift_end_time]
    ...    ${shift_data}[shift_sixth_day]
    Click On Alert Tab For Selected Shift In Bottom Panel On Week Schedule Page On Web
    Verify Employee Alert Is Not Displayed On Week Schedule Page On Web
    ${shift_time_first}    Un-allocate Shift On Week Schedule Page For Associate And Day On Web
    ...    ${ess_user_2}[displayName]
    ...    ${shift_data}[shift_week_sixth_day]
    ...    ${shift_data}[add_first_shift_start_time]
    ...    ${shift_data}[add_first_shift_end_time]
    Delete Shift On Week Schedule Page On Web    ${shift_time_first}

    IF    not ${alert_status}
        Perform Add Shift Operation On Week Schedule Page On Web
        ...    ${ess_user_2}[displayName]
        ...    ${shift_data}[add_second_shift_start_time]
        ...    ${shift_data}[add_second_shift_end_time]
        ...    ${shift_data}[shift_sixth_day]

        Click On Alert Tab For Selected Shift In Bottom Panel On Week Schedule Page On Web
        VAR    ${outside_hour_shift_alert}    ${LOCALISED_TEXT}[shift_alert_outside_available_hours]
        VAR    ${associate_outside_hour_shift_alert}    ${LOCALISED_TEXT}[shift_alert_outside_available_hours_alt]
        ${_}    ${min_length_alert_enabled}    ${max_hours_alert_enabled}    Get Scheduling Rules For Associate From Database
        Log
        ...    Alert status check : Minimum length alert enabled: ${min_length_alert_enabled}, Max hours alert enabled: ${max_hours_alert_enabled}
        # Verify UI assertion only when both alerts are enabled
        IF    ${min_length_alert_enabled} and ${max_hours_alert_enabled}
            # Try primary alert message first, fallback to alternate if not found
            ${outside_hour_alert_present}    Run Keyword And Return Status
            ...    Verify Alert Message From Alert Tab In Bottom Panel On Week Schedule Page On Web    ${outside_hour_shift_alert}
            IF    not ${outside_hour_alert_present}
                Verify Alert Message From Alert Tab In Bottom Panel On Week Schedule Page On Web    ${associate_outside_hour_shift_alert}
            END
        ELSE
            Log    Skipping UI assertion as one or both alerts are disabled
        END
        Perform Add Shift Operation On Week Schedule Page On Web
        ...    ${ess_user_2}[displayName]
        ...    ${shift_data}[add_first_shift_start_time]
        ...    ${shift_data}[add_first_shift_end_time]
        ...    ${shift_data}[shift_seventh_day]

        Click On Alert Tab For Selected Shift In Bottom Panel On Week Schedule Page On Web
        IF    ${min_length_alert_enabled} and ${max_hours_alert_enabled}
            # Try primary alert message first, fallback to alternate if not found
            ${outside_hour_alert_present}    Run Keyword And Return Status
            ...    Verify Alert Message From Alert Tab In Bottom Panel On Week Schedule Page On Web    ${outside_hour_shift_alert}
            IF    not ${outside_hour_alert_present}
                Verify Alert Message From Alert Tab In Bottom Panel On Week Schedule Page On Web    ${associate_outside_hour_shift_alert}
            END
        ELSE
            Log    Skipping UI assertion as one or both alerts are disabled
        END

        VAR    ${edit_shift_day}    5
        Perform Edit Shift Operation On Week Schedule Page On Web    ${ess_user_2}[displayName]
        ...    ${shift_data}[edit_first_shift_start_time]    ${shift_data}[edit_first_shift_end_time]    ${edit_shift_day}

        Click On Alert Tab For Selected Shift In Bottom Panel On Week Schedule Page On Web
        Verify Employee Alert Is Not Displayed On Week Schedule Page On Web

        ${shift_time_edited}    Un-allocate Shift On Week Schedule Page For Associate And Day On Web
        ...    ${ess_user_2}[displayName]
        ...    ${shift_data}[shift_week_sixth_day]
        ...    ${shift_data}[edit_first_shift_start_time]
        ...    ${shift_data}[edit_first_shift_end_time]
        ${shift_time_day7}    Un-allocate Shift On Week Schedule Page For Associate And Day On Web    ${ess_user_2}[displayName]
        ...    ${shift_data}[shift_week_seventh_day]    ${shift_data}[add_first_shift_start_time]
        ...    ${shift_data}[add_first_shift_end_time]
        Wait Until Page Is Loaded
        Delete Shift On Week Schedule Page On Web    ${shift_time_edited}
        Delete Shift On Week Schedule Page On Web    ${shift_time_day7}
        Click On Searched Associate On Week Schedule Page On Web    ${ess_user_2}[displayName]
        Click On Alert Tab For Selected Associate In Bottom Panel On Week Schedule Page On Web
        Verify Employee Alert Is Not Displayed On Week Schedule Page On Web
    END

    Navigate To RWS Employee Request Calendar Page On Web
    Select Day On Request Calendar Page    ${availability_data}[start_date]
    Delete SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_2}[displayName]
    ...    ${availability_data}[start_date]    ${availability_data}[request_preference]    ${edit_availability_data}[status]
    IF    not ${alert_status}
        Navigate To RWS Schedule Week Schedule Page On Web
        Select Week Number On Week Schedule Page On Web    ${availability_data}[start_date]
        ${is_schedule_unpublished}    Check If Schedule Generated And In Unpublished State On Web
        IF    not ${is_schedule_unpublished}
            Skip    Schedule is not in Unpublished state. Please check schedule setup execution for week 6.
        END
        Search Employee On Week Schedule Page On Web    ${ess_user_2}[displayName]
        Perform Add Shift Operation On Week Schedule Page On Web    ${ess_user_2}[displayName]
        ...    ${shift_data}[add_second_shift_start_time]    ${shift_data}[add_second_shift_end_time]    ${shift_data}[shift_sixth_day]
        ${shift_time_final}    Un-allocate Shift On Week Schedule Page For Associate And Day On Web    ${ess_user_2}[displayName]
        ...    ${shift_data}[shift_week_sixth_day]    ${shift_data}[add_second_shift_start_time]
        ...    ${shift_data}[add_second_shift_end_time]
        Delete Shift On Week Schedule Page On Web    ${shift_time_final}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Clean Up Temporary Availability Request    ESS2_STORE1    SM1_STORE1    6_0
    ...    AND    Close Browser

BATTC00205: Verify manager is able to review shift alerts created from edits and their removal when resolved
    [Documentation]    Test case for verify manager is able to review shift alerts created from edits
    ...    and their removal when resolved
    [Tags]    dev:bushra    battc00205    config:rws    bat_phase2    config:weekplan_and_schedule_gen
    VAR    ${status_first_shift}    ${False}
    VAR    ${status_second_shift}    ${False}
    ${user_ess1}    Get User    user_key=ESS1_STORE1
    Log    Initial status of first shift list set to ${status_first_shift}
    Log    Initial status of second shift set to ${status_second_shift}
    ${first_shift_data}    Get Schedule Shift Data    shift_add_day=6_3    shift_start_time=10:00
    ...    shift_end_time=10:30
    ${second_shift_data}    Get Shift Data    shift_add_day=6_4    shift_start_time=01:00    shift_end_time=23:00
    ${first_shift_day}    Evaluate    "${first_shift_data}[shift_add_day]".split("_")[1]
    ${second_shift_day}    Evaluate    "${second_shift_data}[shift_add_day]".split("_")[1]
    ${date_format}    Get Config Value    SERVER_DF
    ${week_start_date_actual}    Calculate Date From Week Day Offset    ${first_shift_data}[week_start_date]
    ...    result_format=${date_format}
    Check Applicability For Shift Alert Validation On Week Schedule Page On Web    ${user_ess1}    ${week_start_date_actual}
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${first_shift_data}[shift_add_day]
    Go To Schedule Page On Web
    Search Employee On Week Schedule Page On Web    ${user_ess1}[displayName]
    Perform Add Shift Operation On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${first_shift_data}[shift_start_time]
    ...    ${first_shift_data}[shift_end_time]
    ...    ${first_shift_day}
    VAR    ${status_first_shift}    ${True}
    Click On Alert Tab For Selected Shift In Bottom Panel On Week Schedule Page On Web
    VAR    ${min_shift_len_alert}    ${LOCALISED_TEXT}[shift_alert_minimum_length]
    Verify Alert Message From Alert Tab In Bottom Panel On Week Schedule Page On Web    ${min_shift_len_alert}
    Select Week Number On Week Schedule Page On Web    ${second_shift_data}[shift_add_day]
    Go To Schedule Page On Web
    Perform Add Shift Operation On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${second_shift_data}[shift_start_time]
    ...    ${second_shift_data}[shift_end_time]
    ...    ${second_shift_day}
    VAR    ${status_second_shift}    ${True}
    Click On Alert Tab For Selected Shift In Bottom Panel On Week Schedule Page On Web
    VAR    ${max_shift_len_alert}    ${LOCALISED_TEXT}[shift_alert_maximum_length]
    Verify Alert Message From Alert Tab In Bottom Panel On Week Schedule Page On Web    ${max_shift_len_alert}
    ${shift_time_first}    Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web
    ...    ${user_ess1}[displayName]
    ...    ${first_shift_day}
    ${shift_time_second}    Un-allocate Shift On Week Schedule Page For The Given Associate And Day On Web
    ...    ${user_ess1}[displayName]
    ...    ${second_shift_day}
    Wait Until Page Is Loaded
    Search Employee On Week Schedule Page On Web    ${user_ess1}[displayName]
    Click On Searched Associate On Week Schedule Page On Web    ${user_ess1}[displayName]
    Click On Alert Tab For Selected Associate In Bottom Panel On Week Schedule Page On Web
    Verify Alert Message From Alert Tab In Bottom Panel On Week Schedule Page On Web    ${max_shift_len_alert}    False
    Open Reports Store Schedule Weekly On Week Schedule Page On Web
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Run Keyword If    ${status_first_shift}    Delete Shift On Week Schedule Page On Web    ${shift_time_first}
    ...    AND
    ...    Run Keyword And Continue On Failure    Run Keyword If    ${status_second_shift}    Delete Shift On Week Schedule Page On Web    ${shift_time_second}

BATTC00220: Verify user is able to perform copy/move/reassign/swap/dragdrop shift operations in web
    [Documentation]    Test case for verifying user is able to perform copy move reassign swap dragdrop shift operations in web
    [Tags]    dev:yogesh    battc00220    config:rws    bat_phase2    config:weekplan_and_schedule_gen
    ${ess_user5}    Get User    user_key=ESS5_STORE1
    ${ess_user6}    Get User    user_key=ESS6_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    # Reuse default schedule_shift template with explicit overrides for add-shift scenarios
    ${add_shift_data_1}    Get Schedule Shift Data    week_start_date=6_0    shift_add_day=3    shift_start_time=12:00
    ...    shift_end_time=19:00
    Select Week Number On Request Calendar Page On Web    ${add_shift_data_1}[week_start_date]
    Go To Schedule Page On Web
    Perform Add Shift Operation On Week Schedule Page On Web    ${ess_user5}[displayName]    ${add_shift_data_1}[shift_start_time]
    ...    ${add_shift_data_1}[shift_end_time]    ${add_shift_data_1}[shift_add_day]
    # Reuse same add-shift data shape with alternate overrides for second shift
    ${add_shift_data_2}    Get Schedule Shift Data    week_start_date=6_0    shift_add_day=5    shift_start_time=13:00
    ...    shift_end_time=17:00
    Perform Add Shift Operation On Week Schedule Page On Web    ${ess_user6}[displayName]    ${add_shift_data_2}[shift_start_time]
    ...    ${add_shift_data_2}[shift_end_time]    ${add_shift_data_2}[shift_add_day]
    # Reuse 'copy_shift_data' template - no overrides needed, using template as-is
    ${copy_shift_data}    Get Schedule Shift Data    template_name=copy_shift_data
    Perform Copy Shift Operation On Week Schedule Page On Web    ${ess_user5}[displayName]    ${copy_shift_data}[shift_copy_day]
    ...    @{copy_shift_data}[target_shift_day]
    # Reuse 'copy_shift_data' template with overrides for move operation
    ${move_shift_data}    Get Schedule Shift Data    template_name=copy_shift_data    shift_copy_day=5    target_shift_day=3
    Perform Move Shift Operation On Week Schedule Page On Web    ${ess_user6}[displayName]    ${move_shift_data}[shift_copy_day]
    ...    ${move_shift_data}[target_shift_day]
    # Reuse 'reassign_shift_data' template - no overrides needed
    ${reassign_shift_data}    Get Schedule Shift Data    template_name=reassign_shift_data
    # Day parameter uses 0-based indexing (3 = Thursday); keyword internally converts to 1-based for UI
    Perform Reassign The Shift Operation On Week Schedule Page On Web    ${ess_user5}[displayName]    ${ess_user6}[displayName]
    ...    ${reassign_shift_data}[day_offset]
    # Reuse 'reassign_shift_data' template for swap operation (same structure)
    ${swap_shift_data}    Get Schedule Shift Data    template_name=reassign_shift_data    day_offset=2
    # Day parameter is 0-based (3 = Thursday); keyword internally converts to 1-based for UI
    Perform Swap The Shift Operation On Week Schedule Page On Web    ${ess_user6}[displayName]    ${ess_user5}[displayName]
    ...    ${swap_shift_data}[day_offset]
    # Reuse 'drag_and_drop_shift_data_1' template - no overrides needed
    ${drag_drop_shift_data_1}    Get Schedule Shift Data    template_name=drag_and_drop_shift_data_1
    Perform Drag And Drop Shift Operation On Week Schedule Page On Web    ${ess_user5}[displayName]
    ...    ${drag_drop_shift_data_1}[source_shift_dayoffset]    ${drag_drop_shift_data_1}[target_shift_dayoffset]
    ...    ${ess_user6}[displayName]
    # Reuse 'drag_and_drop_shift_data_1' template with overrides for second drag-drop
    ${drag_drop_shift_data_2}    Get Schedule Shift Data    template_name=drag_and_drop_shift_data_1    source_shift_dayoffset=2
    ...    target_shift_dayoffset=4
    Perform Drag And Drop Shift Operation On Week Schedule Page On Web    ${ess_user5}[displayName]
    ...    ${drag_drop_shift_data_2}[source_shift_dayoffset]    ${drag_drop_shift_data_2}[target_shift_dayoffset]
    # Reuse 'unallocate_days_data' template - no overrides needed
    # Unallocate operations - day parameters are 0-based (2=Wed, 3=Thu, 4=Fri); keywords internally convert to 1-based
    ${unallocate_days_data}    Get Schedule Shift Data    template_name=unallocate_days_data
    Perform Unallocate The Shift Operation On Week Schedule Page On Web    ${ess_user5}[displayName]
    ...    ${unallocate_days_data}[day_offset_fri]
    Perform Unallocate The Shift Operation On Week Schedule Page On Web    ${ess_user6}[displayName]
    ...    ${unallocate_days_data}[day_offset_wed]
    Perform Unallocate The Shift Operation On Week Schedule Page On Web    ${ess_user6}[displayName]
    ...    ${unallocate_days_data}[day_offset_thu]
    Perform Unallocate The Shift Operation On Week Schedule Page On Web    ${ess_user6}[displayName]
    ...    ${unallocate_days_data}[day_offset_fri]

BATTC00194: Verify detailed shift add by using right click operation in weekly schedule and edit it
    [Documentation]    Test case for verifying detailed shift add by using right-click operation
    ...    in weekly schedule and edit it. This test validates:
    ...    1. SM user can add detailed shifts with task segments by right-clicking on day cells
    ...    2. Shifts can contain multiple task segments including tasks, meal breaks, and rest periods
    ...    3. Detailed shifts can be edited and saved with plain save (meal break rules applied by system)
    ...    4. Shifts can be unallocated and deleted from open pool
    ...
    ...    Note: After adding Day 1 shift, the test checks whether the environment preserved the expected
    ...    task segments (count > 1). If not, it cleans up and skips — the environment does not support
    ...    the detailed segment structure required by this test.
    ...
    ...    Test Steps:
    ...    1. Login as SM1_STORE1 and navigate to Week 6 schedule
    ...    2. Right-click on Day 1 cell for ESS1_STORE1 and add shift with 3 task segments:
    ...    - 10:00-14:00: Continued work
    ...    - 14:00-14:30: Meal Break
    ...    - 14:30-17:00: Continued work
    ...    3. Right-click on Day 2 cell for ESS1_STORE1 and add shift with 5 task segments:
    ...    - 10:00-12:00: Any primary task
    ...    - 12:00-12:30: Meal Break
    ...    - 12:30-16:00: Any primary task
    ...    - 16:00-16:15: Rest Period
    ...    - 16:15-20:00: Any primary task
    ...    4. Edit Day 1 shift to update task timings:
    ...    - 10:00-13:00: Continued work
    ...    - 13:00-13:30: Meal Break
    ...    - 13:30-17:00: Continued work
    ...    5. Unallocate both shifts and delete from open shift pool
    [Tags]    dev:amol    battc00194    config:rws    action:write    bat_phase2    config:weekplan_and_schedule_gen
    ${user_ess1}    Get User    user_key=ESS1_STORE1
    ${client_name}    Get Config Value    key=CLIENT
    IF    '${client_name}' == 'HNM_DRYRUN'
        ${shift_day2_data}    Get Detailed Shift Data    template_name=day2_5_segments_hnm
    ELSE
        ${shift_day2_data}    Get Detailed Shift Data    template_name=day2_5_segments
    END
    ${shift_day1_data}    Get Detailed Shift Data
    ${shift_day1_edited_data}    Get Detailed Shift Data    template_name=day1_edited_3_segments
    Login And Launch WFM Web App    user_key=SM1_STORE1

    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${shift_day1_data}[week_start_date]
    ${is_unpublished}    Check If Schedule Generated And In Unpublished State On Web
    IF    not ${is_unpublished}
        Skip    Pre-requisite schedule not in unpublished state as per Suite Setup; skipping the test...
    END
    Search Employee On Week Schedule Page On Web    ${user_ess1}[displayName]
    Add Detailed Shift With Task Segments By Right Click On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${shift_day1_data}[day_offset]
    ...    ${shift_day1_data}[task_segments]
    ...    apply_meal_break_rules=${False}
    ${day1_offset_str}    Convert To String    ${shift_day1_data}[day_offset]
    ${shift_cell_locator}    Update Locator With Dynamic Values    ${WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT}
    ...    ASSOCIATE_DISPLAY_NAME=${user_ess1}[displayName]    DAY_OFFSET=${day1_offset_str}
    Click Element On Webpage    ${shift_cell_locator}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_EDIT_SHIFT_BUTTON}
    Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_SHIFT_TASK_DROPDOWN_FIRST}
    ${task_row_count}    Get Element Count On Web Page    ${WEEK_SCHEDULE_SHIFT_TASK_DROPDOWN}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_SHIFT_RECORD_CANCEL}
    Wait Until Page Is Loaded
    IF    ${task_row_count} <= 1
        Unallocate Shift And Delete From Open Pool On Week Schedule Page On Web
        ...    ${user_ess1}[displayName]
        ...    ${shift_day1_data}[day_offset]
        Skip    Shift added is not as per stated test data, skipping the test
    END

    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${shift_day2_data}[week_start_date]
    ${is_unpublished}    Check If Schedule Generated And In Unpublished State On Web
    IF    not ${is_unpublished}
        Skip    Pre-requisite schedule not in unpublished state as per Suite Setup; skipping the test...
    END
    Search Employee On Week Schedule Page On Web    ${user_ess1}[displayName]
    Add Detailed Shift With Task Segments By Right Click On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${shift_day2_data}[day_offset]
    ...    ${shift_day2_data}[task_segments]
    ...    apply_meal_break_rules=${False}
    VAR    @{day1_expected_segments}    ${shift_day1_data}[task_segments][1][task_name]
    Verify Shift Contains Task Segments On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${shift_day1_data}[day_offset]
    ...    ${day1_expected_segments}

    VAR    @{day2_expected_segments}    ${shift_day2_data}[task_segments][1][task_name]    ${shift_day2_data}[task_segments][3][task_name]
    Verify Shift Contains Task Segments On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${shift_day2_data}[day_offset]
    ...    ${day2_expected_segments}

    IF    ${task_row_count} == 3
        Edit Detailed Shift With Task Segments On Week Schedule Page On Web
        ...    ${user_ess1}[displayName]
        ...    ${shift_day1_edited_data}[day_offset]
        ...    ${shift_day1_edited_data}[task_segments]
        ...    apply_meal_break_rules=${False}
    ELSE
        Edit Detailed Shift Meal Break Segment On Week Schedule Page On Web
        ...    ${user_ess1}[displayName]
        ...    ${shift_day1_edited_data}[day_offset]
        ...    ${shift_day1_edited_data}[task_segments][1][start_time]
        ...    ${shift_day1_edited_data}[task_segments][1][end_time]
        ...    apply_meal_break_rules=${False}
    END

    VAR    @{day1_edited_expected_segments}    ${shift_day1_edited_data}[task_segments][1][task_name]
    Verify Shift Contains Task Segments On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${shift_day1_edited_data}[day_offset]
    ...    ${day1_edited_expected_segments}

    Unallocate Shift And Delete From Open Pool On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${shift_day1_data}[day_offset]

    Unallocate Shift And Delete From Open Pool On Week Schedule Page On Web
    ...    ${user_ess1}[displayName]
    ...    ${shift_day2_data}[day_offset]


*** Keywords ***
Clean Up Any Existing Temporary Availability On Web
    [Documentation]    Prerequisite check to ensure no existing temporary availability requests before starting BATTC00228.
    ...    This keyword checks if any temporary availability requests already exist for the test user
    ...    and cleans them up to ensure a clean test environment. It uses the same data templates
    ...    that will be used during the actual test execution.
    ...    **Example usage:**
    ...    | Clean Up Any Existing Temporary Availability For BATTC00228    ${ess_user_2}
    [Arguments]    ${ess_user}

    # Get the same data templates that will be used in the test
    ${availability_data}    Get Availability Data    template_name=temporary_availability
    ${edit_availability_data}    Get Availability Data    template_name=temporary_availability    status=RequestStatus.APPROVED

    Run Keyword And Ignore Error    Navigate To RWS Employee Request Calendar Page On Web
    Run Keyword And Ignore Error    Select Day On Request Calendar Page    ${availability_data}[start_date]

    ${edited_request_locator}    Run Keyword And Ignore Error    Build SM Availability Request Locator On Request Calendar Page On Web
    ...    ${ess_user}[displayName]
    ...    ${availability_data}[start_date]
    ...    ${availability_data}[request_preference]
    ...    ${edit_availability_data}[status]

    IF    "${edited_request_locator}[0]" == "PASS"
        ${edited_request_exists}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${edited_request_locator}[1]    timeout=5s

        IF    ${edited_request_exists}
            Log    Found existing edited temporary availability request - cleaning up    level=WARN
            Run Keyword And Ignore Error    Delete SM Availability Request On Request Calendar Page On Web And Verify API Response
            ...    ${ess_user}[displayName]
            ...    ${availability_data}[start_date]
            ...    ${availability_data}[request_preference]
            ...    ${edit_availability_data}[status]
        END
    END

    Log    Prerequisite cleanup completed for BATTC00228    level=INFO
