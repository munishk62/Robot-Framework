*** Settings ***
Documentation       WFM-BATTC00133: Verify user is able to define template for new hires and generate schedule
...                 Applicability:
...                 - SM Module is enabled (Lookup: #PC00001)
...                 - At least 1 work pattern is present in the application (Lookup: #PC000074)
...                 - Functions for performing add/edit/delete associate templates are enabled (Lookup: #PC00004)
...                 User Criteria:
...                 - SM1_STORE2: SM User with permissions for add/edit/delete associate templates (Lookup: #UC00003)
...                 - ESS5_STORE2: ESS User (New Hire1)
...                 Prerequisites (@testsuite):
...                 - New employee is hired for the selected store (via HRBA import in __init__.robot Suite Setup)
...                 - Work pattern is mapped for the selected schedule week
...

Resource            resources/web/authentication/login.resource
Resource            resources/web/roster/template_calendar.resource
Resource            resources/web/rws/schedule/fixed_shifts.resource
Resource            resources/web/rws/schedule/batch_plan_status.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rta/operations/temporary_badges.resource
Resource            resources/web/clock/webclock_login.resource
Resource            resources/web/rws/admin/rws_upload.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource
Library             test_data/TestDataLibrary.py
Library             pabot.PabotLib

Suite Setup         Run Only Once    Create Dynamic Employees For New Hire Suite Setup
Suite Teardown      Run Only Once    Terminate Dynamic Employees For New Hire Suite Teardown
Test Teardown       Close Browser

Test Tags           hire    hiretemp    new_hire_dependent


*** Test Cases ***
BATTC00133: Verify user is able to define template for new hires and generate schedule
    [Documentation]    Verify complete lifecycle: create work pattern and associate template for new hire, edit shifts using copy
    ...    functionality, generate schedule, verify shifts appear correctly, then delete template and verify cleanup
    ...
    ...    **Dynamic User:** This test uses a dynamically generated employee (not from .env)
    ...    Each test run creates a unique employee ID based on timestamp to avoid conflicts.
    ...
    ...    Steps:
    ...    1. Get dynamically created new hire user from suite variable
    ...    2. Login as SM1_STORE2
    ...    3. Get work pattern from DB and configure for STORE2 (Week 4)
    ...    4. Navigate to Template Calendar and map work pattern to store
    ...    5. Create associate template for dynamic new hire with Sunday shift (06:00-13:00)
    ...    6. Copy shift from Sunday to Saturday
    ...    7. Lock template and map to work pattern
    ...    8. Navigate to Review Fixed Shifts and regenerate
    ...    9. Verify shifts match API data
    ...    10. Generate forecast, workload, schedule and publish
    ...    11. Verify scheduled shifts appear correctly on Week Schedule page
    ...    12. Cleanup: Delete schedule, template, and verify removal
    [Tags]    dev:azar    action:write    battc00133    config:rws    config:add_edit_delete_schedule_template
    ...    config:add_edit_delete_associate_template_sm    new_hire    config:weekplan_and_schedule_gen
    # Get dynamically generated new hire user from Suite Setup
    [Setup]    Run Keyword And Warn On Failure    Pre Setup Schedule For Week 4 SM1Store2
    ${ess_user_new_hire}=    Get Dynamic Employee    ESSNH1_STORE2
    Log    Using dynamic new hire: ${ess_user_new_hire}[username] (${ess_user_new_hire}[displayName])    level=INFO
    Login And Launch WFM Web App    user_key=SM1_STORE2
    ${work_pattern_name_from_db}=    Get Existing Available Work Pattern Via DB
    Skip If    '${work_pattern_name_from_db}' == 'NONE'    No existing work pattern available in database for this test
    ${setup_data}=    Get Schedule Generation Setup Data    template_name=4_0_sm1store2
    ${store_data}=    Get Store Data    template_name=${setup_data}[store_template]
    ${work_pattern_data}=    Get Work Pattern Data
    ...    work_pattern_name=${work_pattern_name_from_db}
    ...    store_id=${store_data}[store_id]
    ...    planning_week_start_date=4_0
    ...    planning_week_end_date=4_6
    VAR    ${planning_week_start_date}=    ${work_pattern_data}[planning_week_start_date]
    Check And Map Work Pattern On Planning Week On Web    ${planning_week_start_date}    ${work_pattern_data}[work_pattern_name]
    ${fixed_shift_data}=    Get Add Associate Template Data
    ...    week_start_date=${planning_week_start_date}
    # Parse JSON strings into Python objects for shift_day_list and copy_shift_config
    ${shift_day_list}=    Evaluate    json.loads('[{"day_number": "0", "start_time": "06:00", "end_time": "13:00"}]')    json
    ${copy_shift_config}=    Evaluate    json.loads('{"shift_index": "1", "source_day": "0", "copy_to_days": ["6"]}')    json
    Set To Dictionary    ${fixed_shift_data}    shift_day_list=${shift_day_list}
    Set To Dictionary    ${fixed_shift_data}    copy_shift_config=${copy_shift_config}
    ${template_id_ref_number}=    Add New Blank Template Assign Shift By Mapping Work Pattern On Associate Template Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${planning_week_start_date}    ${work_pattern_data}[work_pattern_name]
    ...    ${fixed_shift_data}[shift_day_list]
    Edit Template Copy Shifts Lock And Capture API Data On Web
    ...    ${template_id_ref_number}    ${fixed_shift_data}[copy_shift_config]
    ${parsed_shifts}=    Capture And Parse Template Info From API And Wait For Review Dropdown    ${template_id_ref_number}
    Navigate To Review Fixed Shifts And Regenerate With API Data Verification On Web
    ...    ${planning_week_start_date}
    Search Employee On Week Schedule Page On Web    ${ess_user_new_hire}[displayName]
    Verify Shifts On Review Page Match API Data On Web    ${ess_user_new_hire}[displayName]    ${parsed_shifts}
    ...    ${planning_week_start_date}
    ${batch_plan_data}=    Get Batch Plan Data
    Navigate To Plan Status Page From Review Fixed Shifts Page On Web    ${planning_week_start_date}
    Clear Existing Generated Data On Batch Plan Status Page On Web
    Generate Forecast Workload Schedule And Publish On Batch Plan Status Page On Web    ${batch_plan_data}[regenerate_forecast_required]
    ...    ${batch_plan_data}[schedule_type]    ${batch_plan_data}[do_publish_schedule]
    Verify Scheduled Shift On Week Schedule Page On Web    ${ess_user_new_hire}[displayName]    ${parsed_shifts}
    ...    ${planning_week_start_date}
    Close Browser
    [Teardown]    Run Keywords
    ...    Run Keyword If Test Passed    Clear Generated Schedule And Workload If Exists On Web    SM1_STORE2    ${planning_week_start_date}    AND
    ...    Run Keyword If Test Passed    Close Browser    AND
    ...    Run Keyword If Test Passed    Delete Work Pattern Based Template And Verify Api Success On Web    SM1_STORE2    ${template_id_ref_number}    AND
    ...    Run Keyword If Test Passed    Close Browser    AND
    ...    Run Keyword If Test Passed    Verify Created Shift Removed Post Associate Template Deletion On Review Fixed Shift Page On Web    SM1_STORE2    ${ess_user_new_hire}[displayName]    ${parsed_shifts}    ${planning_week_start_date}    AND
    ...    Run Keyword If Test Passed    Close Browser

BATTC00132: Verify SM user is able to add/edit/delete/approve day off requests for new hires
    [Documentation]    Test case for verifying whether SM user is able to add, edit and delete day off requests for new hired associate.
    [Tags]    action:write    dev:yogesh    battc00132    bat_phase2    config:holiday_hours_disabled
    ...    config:add_edit_delete_dayoff_request_sm    om_hr
    [Setup]    Run Keywords
    ...    Setup HRAC Import For New Hire    leave_type=VACATION    user_key=ESSNH1_STORE2    AND
    ...    Log    Leave balance imported for new hire - ready for paid vacation requests    level=INFO
    ${is_avp_applicable}=    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}
    ...    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${ess_user_nh1}=    Get Dynamic Employee    ESSNH1_STORE2
    ${day_off_data}=    Get Day Off Data    start_date=4_0    reason=DayOffReasonType.PAID_VACATION
    ...    status_before_approval=RequestStatus.NOT_REVIEWED    status_after_approval=RequestStatus.APPROVED    holiday_hours={"0": "8"}
    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user_nh1}    ${day_off_data}[reason]    4_0
    Login And Launch WFM Web App    user_key=SM1_STORE2
    Cleanup Existing ESS Day Off Requests From SM On Request Calendar On Web    ${ess_user_nh1}[displayName]    num_of_weeks=0
    ...    specific_week_offset_day=${day_off_data}[start_date]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web    ${ess_user_nh1}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_before_approval]
    Edit Day Off Request Status And Verify API Success On Request Calendar Page On Web    ${ess_user_nh1}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_before_approval]
    ...    ${day_off_data}[status_after_approval]
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_nh1}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]

BATTC00192: Verify SM user is able to add/edit/delete/approve day off requests for new hires with holiday hours
    [Documentation]    Test case for verifying whether SM user is able to add, edit and delete day off requests with holiday hours for new hired associate.
    [Tags]    action:write    dev:moiz    config:holiday_hours_enabled    battc00192    bat_phase2
    ...    config:add_edit_delete_dayoff_request_sm    om_hr
    [Setup]    Run Keywords
    ...    Setup HRAC Import For New Hire    leave_type=VACATION    user_key=ESSNH1_STORE2    AND
    ...    Log    Leave balance imported for new hire - ready for paid vacation requests    level=INFO
    Login And Launch WFM Web App    user_key=SM1_STORE2
    ${ess_user_nh1}=    Get Dynamic Employee    ESSNH1_STORE2
    ${day_off_data}=    Get Day Off Data    start_date=4_0    reason=DayOffReasonType.PAID_VACATION
    ...    status_before_approval=RequestStatus.NOT_REVIEWED    status_after_approval=RequestStatus.APPROVED    holiday_hours={"0": "8"}
    Cleanup Existing ESS Day Off Requests From SM On Request Calendar On Web    ${ess_user_nh1}[displayName]    num_of_weeks=0
    ...    specific_week_offset_day=${day_off_data}[start_date]
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web    ${ess_user_nh1}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_before_approval]
    ...    ${day_off_data}[holiday_hours]
    Edit Day Off Request Status And Verify API Success On Request Calendar Page On Web    ${ess_user_nh1}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_before_approval]
    ...    ${day_off_data}[status_after_approval]
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_nh1}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status_after_approval]
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESSNH1_STORE2    SM1_STORE2    ${day_off_data}[start_date]    ${day_off_data}[start_date]    AND
    ...    Close Browser

BATTC00134: Verify user is able to add timecard punches for new hires
    [Documentation]    Test case for verifying User Is Able To Add & Remove Timecard Shifts for new hires
    [Tags]    config:rta    battc00134    bat_phase2    new_hire    dev:rushikesh    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RTA Operations Exception Management Page On Web
    ${user}=    Get Dynamic Employee    ESSNH1_STORE2
    VAR    ${employee_name}=    ${user}[displayName]
    Search & Click On Clock For Employee On Exception Management Page On Web    ${employee_name}
    Verify Timecard Page Is Loaded On Web
    ${timecard_date_format}=    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${shift_data}=    Get Timecard Shift Data    shift_day=-1_6    start_time=9:00
    ${today}=    Get Current Date
    ${date}=    Subtract Time From Date    ${today}    1 days
    ${formatted_date}=    Convert Date    ${date}    result_format=${timecard_date_format}
    ${day_numeric}=    Extract Day Numeric From Week String On Web    ${formatted_date}
    Add Shift On Timecard Page On Web    ${day_numeric}    ${formatted_date}    ${shift_data}    shift_to_be_added=Previous_week
    [Teardown]    Run Keyword And Continue On Failure
    ...    Remove Shift On Timecard Page On Web    ${formatted_date}

BATTC00135: Verify user is able to add webclock punches for new hires
    [Documentation]    Validates clock-in and clock-out with timezone verification and exception management verification for new Hires.
    [Tags]    battc00135    action:write    config:rta    bat_phase2    dev:rushikesh    module:timekeeping    bug_reported    bugid_wfm_140164_pbst    bugid_wfm_140066_twg
    ${is_clock_applicable}=    Check Clock Applicability In DB
    Skip If    not ${is_clock_applicable}    Clock functionality not applicable - DB validation failed
    VAR    ${clock_in}=    clock_in
    VAR    ${clock_out}=    clock_out
    ${store_data}=    Get Store Data    template_name=model_store2
    ${ess_user_nh1}=    Get Dynamic Employee    ESSNH1_STORE2
    VAR    ${employee_badge_id}=    ${ess_user_nh1}[username]
    ${punch_interval_wait_time}=    Get Config Value    key=WEB_CLOCK_PUNCH_INTERVAL_MINUTES
    ${batch_wait_time}=    Get Config Value    key=WEB_CLOCK_BATCH_PROCESSING_WAIT_MINUTES

    Initialize Browser For Web Clock
    Navigate And Verify Web Clock Time Matches Store Timezone On Web    ${store_data}[store_id]
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${clock_in}    ${employee_badge_id}
    ...    ${store_data}[store_id]
    Sleep    ${punch_interval_wait_time}m
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${clock_out}    ${employee_badge_id}
    ...    ${store_data}[store_id]
    Sleep    ${batch_wait_time}m
    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RTA Operations Exception Management Page On Web
    Verify Web Clock Actions On Time Card Page On Web    ${employee_badge_id}    ${store_data}[store_id]

    ${on_timecard_page}=    Check If On Exception Management Timecard Page On Web
    IF    not ${on_timecard_page}
        Sleep    ${batch_wait_time}m
        Login And Launch WFM Web App    user_key=SM1_STORE2
        Navigate To RTA Operations Exception Management Page On Web
        Open Employee Timecard On Exception Management Page On Web    ${employee_badge_id}
    END

    [Teardown]    Run Keyword And Ignore Error
    ...    Delete Performed Web Clock Actions From Time Card Page On Web

BATTC00170: Verify user is able to clock in & clock out from web clock using temporary badge ids
    [Documentation]    Verifies complete lifecycle of temporary badge ID management and web clock operations:
    ...    1. Create unique temporary badge ID for ESS user
    ...    2. Add temporary badge with appropriate effective/end dates
    ...    3. Perform clock-in using temporary badge ID
    ...    4. Perform clock-out using temporary badge ID
    ...    5. Verify clock actions on timecard/exception management
    ...    6. Cleanup: Delete punches and temporary badge
    ...
    ...    Badge ID Format: 00299yymmddhhmm
    ...    - 002: Store number (fixed)
    ...    - 99: Temporary badge indicator (fixed)
    ...    - yymmddhhmm: Timestamp (dynamic)
    ...
    ...    Test users:
    ...    - SM1_STORE2: Store Manager for badge management
    ...    - ESS1_STORE2: ESS user for whom the temporary badge is created
    [Tags]    dev:amol    battc00170    config:rta    config:temporary_badge_permission    bat_phase2    module:timekeeping

    ${is_clock_applicable}=    Check Clock Applicability In DB
    Skip If    not ${is_clock_applicable}    Clock functionality not applicable - DB validation failed

    ${ess_user}=    Get User    user_key=ESSNH2_STORE2
    VAR    ${associate_id}=    ${ess_user}[username]
    ${timestamp_format}=    Get Config Value    DATE_FORMAT_YYMMDDHHMM
    ${timestamp}=    Get Current Date    result_format=${timestamp_format}
    VAR    ${TEMP_BADGE_ID}=    00299${timestamp}

    ${date_format}=    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${today}=    Get Current Date
    ${effective_date}=    Add Time To Date    ${today}    0 days    result_format=${date_format}
    ${end_date}=    Add Time To Date    ${today}    10 days    result_format=${date_format}

    VAR    &{badge_data}=
    ...    effective_date=${effective_date}
    ...    end_date=${end_date}
    ...    badge_id=${TEMP_BADGE_ID}
    ...    associate_id=${associate_id}

    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RTA Operations Temporary Badges Page On Web
    Add Temporary Badge On Temporary Badges Page On Web    ${badge_data}

    VAR    ${clock_in}=    clock_in
    VAR    ${clock_out}=    clock_out
    ${store_data}=    Get Store Data    template_name=model_store2
    ${punch_interval_wait_time}=    Get Config Value    key=WEB_CLOCK_PUNCH_INTERVAL_MINUTES
    ${batch_wait_time}=    Get Config Value    key=WEB_CLOCK_BATCH_PROCESSING_WAIT_MINUTES

    Initialize Browser For Web Clock
    Navigate And Verify Web Clock Time Matches Store Timezone On Web    ${store_data}[store_id]
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${clock_in}    ${TEMP_BADGE_ID}
    ...    ${store_data}[store_id]
    Sleep    ${punch_interval_wait_time}m
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${clock_out}    ${TEMP_BADGE_ID}
    ...    ${store_data}[store_id]
    Sleep    ${batch_wait_time}m

    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RTA Operations Exception Management Page On Web
    Verify Web Clock Actions On Time Card Page On Web    ${associate_id}    ${store_data}[store_id]

    ${on_timecard_page}=    Check If On Exception Management Timecard Page On Web
    IF    not ${on_timecard_page}
        Sleep    ${batch_wait_time}m
        Login And Launch WFM Web App    user_key=SM1_STORE2
        Navigate To RTA Operations Exception Management Page On Web
        Open Employee Timecard On Exception Management Page On Web    ${associate_id}
    END

    Run Keyword And Ignore Error    Delete Performed Web Clock Actions From Time Card Page On Web
    Navigate To RTA Operations Temporary Badges Page On Web
    Update Temporary Badge Status To Inactive On Temporary Badges Page On Web    ${TEMP_BADGE_ID}
    Delete Temporary Badge On Temporary Badges Page On Web    ${TEMP_BADGE_ID}

BATTC00172: Verify add / edit / delete / approve multiple requests from SM Request calendar list view with holiday hours disabled
    [Documentation]    Test case to verify SM user can add, edit, delete, and approve/decline multiple requests
    ...    (day off, time off, availability) from Request Calendar list view with holiday hours disabled.
    ...
    ...    **Test Flow:**
    ...    1. Login as SM1_STORE2
    ...    2. Navigate to Request Calendar for Week 8 (Current Week + 8)
    ...    3. Switch to Line View for the month
    ...    4. Add 4 day off requests (2 for ESS4_STORE2, 2 for ESSNH2_STORE2)
    ...    5. Add 4 time off requests (2 for ESS4_STORE2, 2 for ESSNH2_STORE2)
    ...    6. Add 2 availability requests (1 for ESS4_STORE2, 1 for ESSNH2_STORE2)
    ...    7. Select and bulk approve 5 requests
    ...    8. Select and bulk decline 5 requests
    ...    9. Filter by approved status and verify only approved requests shown
    ...    10. Filter by declined status and verify only declined requests shown
    ...    11. Teardown: Delete all created requests
    [Tags]    dev:azar    action:write    config:rws    config:ess_add_edit_delete_dayoff    config:add_edit_delete_dayoff_request_sm
    ...    config:add_edit_delete_timeoff_request_sm    config:add_edit_delete_availability_request_sm    battc00172
    ...    config:holiday_hours_disabled    bat_phase2    new_hire    om_hr
    [Setup]    Run Keywords
    ...    Clean Up All Requests For User On Date    ESS4_STORE2    SM1_STORE2    start_date_offset=8_0    end_date_offset=8_7    AND
    ...    Setup HRAC Import For New Hire    leave_balance_days=30:00    leave_type=VAC    AND
    ...    Log    Leave balance imported for new hire - ready for paid vacation requests    level=INFO
    ${ess_user_new_hire}=    Get Dynamic Employee    ESSNH1_STORE2
    Log    Using dynamic new hire: ${ess_user_new_hire}[username] (${ess_user_new_hire}[displayName])    level=INFO
    ${ess_user_existing}=    Get User    user_key=ESS4_STORE2
    ${day_off_request}=    Get System Value    RequestType    DAY_OFF
    ${time_off_request}=    Get System Value    RequestType    TIME_OFF
    ${availability_request}=    Get System Value    RequestType    AVAILABILITY
    ${not_reviewed}=    Get System Value    RequestStatus    NOT_REVIEWED
    ${approved}=    Get System Value    RequestStatus    APPROVED
    ${declined}=    Get System Value    RequestStatus    DECLINED
    ${day_off_data}=    Get Day Off Data
    ${is_avp_applicable}=    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}
    ...    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user_new_hire}    ${day_off_data}[reason]    8_4

    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RWS Employee Request Calendar Page On Web
    Select Day On Request Calendar Page    8_0
    Switch To List View On Request Calendar Page On Web
    Run Keyword And Ignore Error    Select Leave And Availability Panel On List View On Request Calendar Page On Web
    ${day_off_data_1}=    Get Day Off Data    start_date=8_1    end_date=8_1
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${day_off_data_1}[start_date]    ${day_off_data_1}[end_date]
    ...    ${day_off_data_1}[reason]    ${not_reviewed}
    ${day_off_data_2}=    Get Day Off Data    start_date=8_2    end_date=8_2
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${day_off_data_2}[start_date]    ${day_off_data_2}[end_date]
    ...    ${day_off_data_2}[reason]    ${not_reviewed}
    ${day_off_data_3}=    Get Day Off Data    start_date=8_1    end_date=8_1
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${day_off_data_3}[start_date]    ${day_off_data_3}[end_date]
    ...    ${day_off_data_3}[reason]    ${not_reviewed}
    ${day_off_data_4}=    Get Day Off Data    start_date=8_2    end_date=8_2
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${day_off_data_4}[start_date]    ${day_off_data_4}[end_date]
    ...    ${day_off_data_4}[reason]    ${not_reviewed}
    ${time_off_data_1}=    Get Time Off Data    start_date=8_3
    Create SM Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${time_off_data_1}[start_date]
    ...    ${time_off_data_1}[start_time]    ${time_off_data_1}[duration]
    ...    ${time_off_data_1}[reason]    ${not_reviewed}
    ${time_off_data_2}=    Get Time Off Data    start_date=8_4
    Create SM Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${time_off_data_2}[start_date]
    ...    ${time_off_data_2}[start_time]    ${time_off_data_2}[duration]
    ...    ${time_off_data_2}[reason]    ${not_reviewed}
    ${time_off_data_3}=    Get Time Off Data    start_date=8_3
    Create SM Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${time_off_data_3}[start_date]
    ...    ${time_off_data_3}[start_time]    ${time_off_data_3}[duration]
    ...    ${time_off_data_3}[reason]    ${not_reviewed}
    ${time_off_data_4}=    Get Time Off Data    start_date=8_4
    Create SM Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${time_off_data_4}[start_date]
    ...    ${time_off_data_4}[start_time]    ${time_off_data_4}[duration]
    ...    ${time_off_data_4}[reason]    ${not_reviewed}
    ${availability_data_1}=    Get Availability Data    start_date=8_0
    Create SM Availability Request On Request Calendar Page On Web And Verify API Response
    ...    ${ess_user_existing}[displayName]    ${availability_data_1}[request_preference]
    ...    ${availability_data_1}[start_date]    ${availability_data_1}[reason]
    ...    ${availability_data_1}[rotation_number]    ${availability_data_1}[days_availability_hours]
    ...    ${availability_data_1}[split_availability_row_number]    ${availability_data_1}[availability_rotation_number]
    ${availability_data_2}=    Get Availability Data    start_date=8_0
    Create SM Availability Request On Request Calendar Page On Web And Verify API Response
    ...    ${ess_user_new_hire}[displayName]    ${availability_data_2}[request_preference]
    ...    ${availability_data_2}[start_date]    ${availability_data_2}[reason]
    ...    ${availability_data_2}[rotation_number]    ${availability_data_2}[days_availability_hours]
    ...    ${availability_data_2}[split_availability_row_number]    ${availability_data_2}[availability_rotation_number]
    Switch To List View On Request Calendar Page On Web
    Run Keyword And Ignore Error    Select Leave And Availability Panel On List View On Request Calendar Page On Web
    VAR    &{day_off_dict_1}=    associate_name=${ess_user_existing}[displayName]    date=${day_off_data_1}[start_date]
    VAR    &{day_off_dict_2}=    associate_name=${ess_user_new_hire}[displayName]    date=${day_off_data_4}[start_date]
    VAR    @{day_off_approve_list}=    ${day_off_dict_1}    ${day_off_dict_2}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${day_off_request}    ${day_off_approve_list}
    VAR    &{time_off_dict_1}=    associate_name=${ess_user_existing}[displayName]    date=${time_off_data_1}[start_date]
    VAR    &{time_off_dict_2}=    associate_name=${ess_user_new_hire}[displayName]    date=${time_off_data_4}[start_date]
    VAR    @{time_off_approve_list}=    ${time_off_dict_1}    ${time_off_dict_2}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${time_off_request}    ${time_off_approve_list}
    VAR    &{availability_dict_1}=    associate_name=${ess_user_new_hire}[displayName]    date=${NONE}
    VAR    @{availability_approve_list}=    ${availability_dict_1}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${availability_request}
    ...    ${availability_approve_list}
    Click Approve Button On List View And Verify API Success On Request Calendar Page On Web
    Switch To List View On Request Calendar Page On Web
    Run Keyword And Ignore Error    Select Leave And Availability Panel On List View On Request Calendar Page On Web
    VAR    &{day_off_dict_3}=    associate_name=${ess_user_existing}[displayName]    date=${day_off_data_2}[start_date]
    VAR    &{day_off_dict_4}=    associate_name=${ess_user_new_hire}[displayName]    date=${day_off_data_3}[start_date]
    VAR    @{day_off_decline_list}=    ${day_off_dict_3}    ${day_off_dict_4}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${day_off_request}    ${day_off_decline_list}
    VAR    &{time_off_dict_3}=    associate_name=${ess_user_existing}[displayName]    date=${time_off_data_2}[start_date]
    VAR    &{time_off_dict_4}=    associate_name=${ess_user_new_hire}[displayName]    date=${time_off_data_3}[start_date]
    VAR    @{time_off_decline_list}=    ${time_off_dict_3}    ${time_off_dict_4}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${time_off_request}    ${time_off_decline_list}
    VAR    &{availability_dict_2}=    associate_name=${ess_user_existing}[displayName]    date=${NONE}
    VAR    @{availability_decline_list}=    ${availability_dict_2}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${availability_request}
    ...    ${availability_decline_list}
    Click Decline Button On List View And Verify API Success On Request Calendar Page On Web
    Switch To List View On Request Calendar Page On Web
    ${filter_approved}=    Get Request Calendar Filter Data    request_status=BulkRequestStatus.APPROVED
    Apply Request Filter On Request Calendar Page On Web    ${filter_approved}
    Wait Until Page Is Loaded    timeout=${MEDIUM_TIMEOUT}
    Verify SM Day Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${day_off_data_1}[start_date]    ${day_off_data_1}[start_date]    ${approved}
    Verify SM Day Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${day_off_data_4}[start_date]    ${day_off_data_4}[start_date]    ${approved}
    Verify SM Time Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${time_off_data_1}[start_date]
    ...    ${time_off_data_1}[start_time]    ${time_off_data_1}[end_time]    ${approved}
    Verify SM Time Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${time_off_data_4}[start_date]
    ...    ${time_off_data_4}[start_time]    ${time_off_data_4}[end_time]    ${approved}
    Verify SM Availability Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${availability_data_2}[start_date]    ${approved}
    ${filter_declined}=    Get Request Calendar Filter Data    request_status=BulkRequestStatus.DECLINED
    Apply Request Filter On Request Calendar Page On Web    ${filter_declined}
    Wait Until Page Is Loaded    timeout=${MEDIUM_TIMEOUT}
    Verify SM Day Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${day_off_data_2}[start_date]    ${day_off_data_2}[start_date]    ${declined}
    Verify SM Day Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${day_off_data_3}[start_date]    ${day_off_data_3}[start_date]    ${declined}
    Verify SM Time Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${time_off_data_2}[start_date]
    ...    ${time_off_data_2}[start_time]    ${time_off_data_2}[end_time]    ${declined}
    Verify SM Time Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${time_off_data_3}[start_date]
    ...    ${time_off_data_3}[start_time]    ${time_off_data_3}[end_time]    ${declined}
    Verify SM Availability Request On Line View On Request Calendar Page On Web    ${ess_user_existing}[displayName]  # [Teardown]    Run Keywords
    ...    ${availability_data_1}[start_date]    ${declined}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Navigate To RWS Employee Request Calendar Page On Web    AND
    ...    Run Keyword And Ignore Error    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_existing}[displayName]    ${day_off_data_1}[start_date]    ${day_off_data_1}[reason]    ${approved}    AND
    ...    Run Keyword And Ignore Error    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_existing}[displayName]    ${day_off_data_2}[start_date]    ${day_off_data_2}[reason]    ${declined}    AND
    ...    Run Keyword And Ignore Error    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_new_hire}[displayName]    ${day_off_data_3}[start_date]    ${day_off_data_3}[reason]    ${declined}    AND
    ...    Run Keyword And Ignore Error    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_new_hire}[displayName]    ${day_off_data_4}[start_date]    ${day_off_data_4}[reason]    ${approved}    AND
    ...    Run Keyword And Ignore Error    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_existing}[displayName]    ${time_off_data_1}[start_date]    ${time_off_data_1}[reason]    ${time_off_data_1}[start_time]    ${time_off_data_1}[end_time]    ${approved}    AND
    ...    Run Keyword And Ignore Error    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_existing}[displayName]    ${time_off_data_2}[start_date]    ${time_off_data_2}[reason]    ${time_off_data_2}[start_time]    ${time_off_data_2}[end_time]    ${declined}    AND
    ...    Run Keyword And Ignore Error    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_new_hire}[displayName]    ${time_off_data_3}[start_date]    ${time_off_data_3}[reason]    ${time_off_data_3}[start_time]    ${time_off_data_3}[end_time]    ${declined}    AND
    ...    Run Keyword And Ignore Error    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_new_hire}[displayName]    ${time_off_data_4}[start_date]    ${time_off_data_4}[reason]    ${time_off_data_4}[start_time]    ${time_off_data_4}[end_time]    ${approved}    AND
    ...    Run Keyword And Ignore Error    Delete SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_existing}[displayName]    ${availability_data_1}[start_date]    ${availability_data_1}[request_preference]    ${declined}    AND
    ...    Run Keyword And Ignore Error    Delete SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_new_hire}[displayName]    ${availability_data_2}[start_date]    ${availability_data_2}[request_preference]    ${approved}    AND
    ...    Clean Up All Requests For User On Date    ESS4_STORE2    SM1_STORE2    start_date_offset=8_0    end_date_offset=8_7    AND
    ...    Close Browser

BATTC00253: Verify add / edit / delete / approve multiple requests from SM Request calendar list view with holiday hours enabled
    [Documentation]    Test case to verify SM user can add, edit, delete, and approve/decline multiple requests
    ...    (day off, time off, availability) from Request Calendar list view with holiday hours enabled.
    ...
    ...    **Applicability:**
    ...    - RWS license is enabled
    ...    - Functions for add/edit/delete day off, time off, availability requests are enabled
    ...    - Holiday Hours grid is enabled (Lookup: #PC00073)
    ...
    ...    **Test Users:**
    ...    - SM1_STORE2: Store Manager
    ...    - ESS4_STORE2: Existing ESS associate
    ...    - ESSNH2_STORE2: New Hire ESS associate
    ...
    ...    **Test Flow:**
    ...    1. Login as SM1_STORE2
    ...    2. Navigate to Request Calendar for Week 8 (Current Week + 8)
    ...    3. Switch to Line View for the month
    ...    4. Add 4 day off requests with holiday hours with 8 hours
    ...    5. Add 4 time off requests (no holiday hours support for time off)
    ...    6. Add 2 availability requests (1 for each associate)
    ...    7. Select and bulk approve 5 requests (1 day off, 1 time off, 1 availability per associate mix)
    ...    8. Select and bulk decline 5 requests (remaining requests)
    ...    9. Filter by approved status and verify only approved requests shown
    ...    10. Filter by declined status and verify only declined requests shown
    ...    11. Teardown: Delete all created requests
    ...
    ...    **Holiday Hours Pattern:**
    ...    - #Add_day_off_1: Associate1, Day 1, Holiday Hours=8
    ...    - #Add_day_off_2: Associate1, Day 2, No Holiday Hours
    ...    - #Add_day_off_3: Associate2, Day 1, Holiday Hours=8
    ...    - #Add_day_off_4: Associate2, Day 2, No Holiday Hours
    ...
    ...    **Approval Pattern:**
    ...    - Approve: #Add_day_off_1, #Add_day_off_4, #Add_time_off_1, #Add_time_off_4, #Add_availability_2
    ...    - Decline: #Add_day_off_2, #Add_day_off_3, #Add_time_off_2, #Add_time_off_3, #Add_availability_1
    [Tags]    dev:azar    action:write    battc00253    config:rws    config:holiday_hours_enabled    config:ess_add_edit_delete_dayoff
    ...    config:add_edit_delete_dayoff_request_sm    config:add_edit_delete_timeoff_request_sm
    ...    config:add_edit_delete_availability_request_sm    bat_phase2    new_hire    om_hr
    [Setup]    Run Keywords
    ...    Clean Up All Requests For User On Date    ESS4_STORE2    SM1_STORE2    start_date_offset=8_0    end_date_offset=8_7    AND
    ...    Setup HRAC Import For New Hire    leave_type=VAC    leave_balance_days=30:00
    ${ess_user_new_hire}=    Get Dynamic Employee    user_key=ESSNH2_STORE2
    ${ess_user_existing}=    Get User    user_key=ESS4_STORE2
    ${day_off_request}=    Get System Value    RequestType    DAY_OFF
    ${time_off_request}=    Get System Value    RequestType    TIME_OFF
    ${availability_request}=    Get System Value    RequestType    AVAILABILITY
    ${not_reviewed}=    Get System Value    RequestStatus    NOT_REVIEWED
    ${approved}=    Get System Value    RequestStatus    APPROVED
    ${declined}=    Get System Value    RequestStatus    DECLINED
    ${day_off_data}=    Get Day Off Data
    ${time_off_data}=    Get Time Off Data
    ${is_alternate_offset_required}=    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user_existing}
    ...    ${day_off_data}[reason]    8_2
    IF    ${is_alternate_offset_required}
        Skip    Day offset value not applicable for existing user - skipping the test case.
    END
    ${is_alternate_offset_required}=    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user_new_hire}
    ...    ${day_off_data}[reason]    8_2
    IF    ${is_alternate_offset_required}
        Skip    Day offset value not applicable for new hire user - skipping the test case.
    END
    ${is_alternate_offset_required}=    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user_existing}
    ...    ${time_off_data}[reason]    8_4    ${time_off_request}
    IF    ${is_alternate_offset_required}
        Skip    Day offset value not applicable for existing user - skipping the test case.
    END
    ${is_alternate_offset_required}=    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user_new_hire}
    ...    ${time_off_data}[reason]    8_4    ${time_off_request}
    IF    ${is_alternate_offset_required}
        Skip    Day offset value not applicable for new hire user - skipping the test case.
    END

    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RWS Employee Request Calendar Page On Web
    Select Day On Request Calendar Page    8_0
    Switch To List View On Request Calendar Page On Web
    Run Keyword And Ignore Error    Select Leave And Availability Panel On List View On Request Calendar Page On Web
    VAR    &{holiday_hours_1}=    1=8
    ${day_off_data_1}=    Get Day Off Data    start_date=8_1    end_date=8_1    holiday_hours=${holiday_hours_1}
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${day_off_data_1}[start_date]    ${day_off_data_1}[end_date]
    ...    ${day_off_data_1}[reason]    ${not_reviewed}    holiday_hours=${holiday_hours_1}
    VAR    &{holiday_hours_2}=    2=8
    ${day_off_data_2}=    Get Day Off Data    start_date=8_2    end_date=8_2    holiday_hours=${holiday_hours_2}
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${day_off_data_2}[start_date]    ${day_off_data_2}[end_date]
    ...    ${day_off_data_2}[reason]    ${not_reviewed}    holiday_hours=${holiday_hours_2}
    VAR    &{holiday_hours_3}=    1=8
    ${day_off_data_3}=    Get Day Off Data    start_date=8_1    end_date=8_1    holiday_hours=${holiday_hours_3}
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${day_off_data_3}[start_date]    ${day_off_data_3}[end_date]
    ...    ${day_off_data_3}[reason]    ${not_reviewed}    holiday_hours=${holiday_hours_3}
    VAR    &{holiday_hours_4}=    2=8
    ${day_off_data_4}=    Get Day Off Data    start_date=8_2    end_date=8_2    holiday_hours=${holiday_hours_4}
    Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${day_off_data_4}[start_date]    ${day_off_data_4}[end_date]
    ...    ${day_off_data_4}[reason]    ${not_reviewed}    holiday_hours=${holiday_hours_4}
    ${time_off_data_1}=    Get Time Off Data    start_date=8_3
    Create SM Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${time_off_data_1}[start_date]
    ...    ${time_off_data_1}[start_time]    ${time_off_data_1}[duration]
    ...    ${time_off_data_1}[reason]    ${not_reviewed}
    ${time_off_data_2}=    Get Time Off Data    start_date=8_4
    Create SM Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${time_off_data_2}[start_date]
    ...    ${time_off_data_2}[start_time]    ${time_off_data_2}[duration]
    ...    ${time_off_data_2}[reason]    ${not_reviewed}
    ${time_off_data_3}=    Get Time Off Data    start_date=8_3
    Create SM Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${time_off_data_3}[start_date]
    ...    ${time_off_data_3}[start_time]    ${time_off_data_3}[duration]
    ...    ${time_off_data_3}[reason]    ${not_reviewed}
    ${time_off_data_4}=    Get Time Off Data    start_date=8_4
    Create SM Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${time_off_data_4}[start_date]
    ...    ${time_off_data_4}[start_time]    ${time_off_data_4}[duration]
    ...    ${time_off_data_4}[reason]    ${not_reviewed}
    ${availability_data_1}=    Get Availability Data    start_date=8_0
    Create SM Availability Request On Request Calendar Page On Web And Verify API Response
    ...    ${ess_user_existing}[displayName]    ${availability_data_1}[request_preference]
    ...    ${availability_data_1}[start_date]    ${availability_data_1}[reason]
    ...    ${availability_data_1}[rotation_number]    ${availability_data_1}[days_availability_hours]
    ...    ${availability_data_1}[split_availability_row_number]    ${availability_data_1}[availability_rotation_number]
    ${availability_data_2}=    Get Availability Data    start_date=8_0
    Create SM Availability Request On Request Calendar Page On Web And Verify API Response
    ...    ${ess_user_new_hire}[displayName]    ${availability_data_2}[request_preference]
    ...    ${availability_data_2}[start_date]    ${availability_data_2}[reason]
    ...    ${availability_data_2}[rotation_number]    ${availability_data_2}[days_availability_hours]
    ...    ${availability_data_2}[split_availability_row_number]    ${availability_data_2}[availability_rotation_number]
    Switch To List View On Request Calendar Page On Web
    Run Keyword And Ignore Error    Select Leave And Availability Panel On List View On Request Calendar Page On Web
    VAR    &{day_off_dict_1}=    associate_name=${ess_user_existing}[displayName]    date=${day_off_data_1}[start_date]
    VAR    &{day_off_dict_2}=    associate_name=${ess_user_new_hire}[displayName]    date=${day_off_data_4}[start_date]
    VAR    @{day_off_approve_list}=    ${day_off_dict_1}    ${day_off_dict_2}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${day_off_request}    ${day_off_approve_list}
    VAR    &{time_off_dict_1}=    associate_name=${ess_user_existing}[displayName]    date=${time_off_data_1}[start_date]
    VAR    &{time_off_dict_2}=    associate_name=${ess_user_new_hire}[displayName]    date=${time_off_data_4}[start_date]
    VAR    @{time_off_approve_list}=    ${time_off_dict_1}    ${time_off_dict_2}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${time_off_request}    ${time_off_approve_list}
    VAR    &{availability_dict_1}=    associate_name=${ess_user_new_hire}[displayName]    date=${NONE}
    VAR    @{availability_approve_list}=    ${availability_dict_1}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${availability_request}
    ...    ${availability_approve_list}
    Click Approve Button On List View And Verify API Success On Request Calendar Page On Web
    Switch To List View On Request Calendar Page On Web
    Run Keyword And Ignore Error    Select Leave And Availability Panel On List View On Request Calendar Page On Web
    VAR    &{day_off_dict_3}=    associate_name=${ess_user_existing}[displayName]    date=${day_off_data_2}[start_date]
    VAR    &{day_off_dict_4}=    associate_name=${ess_user_new_hire}[displayName]    date=${day_off_data_3}[start_date]
    VAR    @{day_off_decline_list}=    ${day_off_dict_3}    ${day_off_dict_4}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${day_off_request}    ${day_off_decline_list}
    VAR    &{time_off_dict_3}=    associate_name=${ess_user_existing}[displayName]    date=${time_off_data_2}[start_date]
    VAR    &{time_off_dict_4}=    associate_name=${ess_user_new_hire}[displayName]    date=${time_off_data_3}[start_date]
    VAR    @{time_off_decline_list}=    ${time_off_dict_3}    ${time_off_dict_4}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${time_off_request}    ${time_off_decline_list}
    VAR    &{availability_dict_2}=    associate_name=${ess_user_existing}[displayName]    date=${NONE}
    VAR    @{availability_decline_list}=    ${availability_dict_2}
    Select Multiple Requests By Request Type On List View Request Calendar Page On Web    ${availability_request}
    ...    ${availability_decline_list}
    Click Decline Button On List View And Verify API Success On Request Calendar Page On Web
    Switch To List View On Request Calendar Page On Web
    ${filter_approved}=    Get Request Calendar Filter Data    request_status=BulkRequestStatus.APPROVED
    Apply Request Filter On Request Calendar Page On Web    ${filter_approved}
    Verify SM Day Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${day_off_data_1}[start_date]    ${day_off_data_1}[start_date]    ${approved}
    Verify SM Day Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${day_off_data_4}[start_date]    ${day_off_data_4}[start_date]    ${approved}
    Verify SM Time Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${time_off_data_1}[start_date]
    ...    ${time_off_data_1}[start_time]    ${time_off_data_1}[end_time]    ${approved}
    Verify SM Time Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${time_off_data_4}[start_date]
    ...    ${time_off_data_4}[start_time]    ${time_off_data_4}[end_time]    ${approved}
    Verify SM Availability Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${availability_data_2}[start_date]    ${approved}
    ${filter_declined}=    Get Request Calendar Filter Data    request_status=BulkRequestStatus.DECLINED
    Apply Request Filter On Request Calendar Page On Web    ${filter_declined}
    Verify SM Day Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${day_off_data_2}[start_date]    ${day_off_data_2}[start_date]    ${declined}
    Verify SM Day Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${day_off_data_3}[start_date]    ${day_off_data_3}[start_date]    ${declined}
    Verify SM Time Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${time_off_data_2}[start_date]
    ...    ${time_off_data_2}[start_time]    ${time_off_data_2}[end_time]    ${declined}
    Verify SM Time Off Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_new_hire}[displayName]    ${time_off_data_3}[start_date]
    ...    ${time_off_data_3}[start_time]    ${time_off_data_3}[end_time]    ${declined}
    Verify SM Availability Request On Line View On Request Calendar Page On Web
    ...    ${ess_user_existing}[displayName]    ${availability_data_1}[start_date]    ${declined}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Navigate To RWS Employee Request Calendar Page On Web    AND
    ...    Run Keyword And Ignore Error    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_existing}[displayName]    ${day_off_data_1}[start_date]    ${day_off_data_1}[reason]    ${approved}    AND
    ...    Run Keyword And Ignore Error    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_existing}[displayName]    ${day_off_data_2}[start_date]    ${day_off_data_2}[reason]    ${declined}    AND
    ...    Run Keyword And Ignore Error    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_new_hire}[displayName]    ${day_off_data_3}[start_date]    ${day_off_data_3}[reason]    ${declined}    AND
    ...    Run Keyword And Ignore Error    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_new_hire}[displayName]    ${day_off_data_4}[start_date]    ${day_off_data_4}[reason]    ${approved}    AND
    ...    Run Keyword And Ignore Error    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_existing}[displayName]    ${time_off_data_1}[start_date]    ${time_off_data_1}[reason]    ${time_off_data_1}[start_time]    ${time_off_data_1}[end_time]    ${approved}    AND
    ...    Run Keyword And Ignore Error    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_existing}[displayName]    ${time_off_data_2}[start_date]    ${time_off_data_2}[reason]    ${time_off_data_2}[start_time]    ${time_off_data_2}[end_time]    ${declined}    AND
    ...    Run Keyword And Ignore Error    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_new_hire}[displayName]    ${time_off_data_3}[start_date]    ${time_off_data_3}[reason]    ${time_off_data_3}[start_time]    ${time_off_data_3}[end_time]    ${declined}    AND
    ...    Run Keyword And Ignore Error    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${ess_user_new_hire}[displayName]    ${time_off_data_4}[start_date]    ${time_off_data_4}[reason]    ${time_off_data_4}[start_time]    ${time_off_data_4}[end_time]    ${approved}    AND
    ...    Run Keyword And Ignore Error    Delete SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_existing}[displayName]    ${availability_data_1}[start_date]    ${availability_data_1}[request_preference]    ${declined}    AND
    ...    Run Keyword And Ignore Error    Delete SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_new_hire}[displayName]    ${availability_data_2}[start_date]    ${availability_data_2}[request_preference]    ${approved}    AND
    ...    Clean Up All Requests For User On Date    ESS4_STORE2    SM1_STORE2    start_date_offset=8_0    end_date_offset=8_7    AND
    ...    Close Browser


*** Keywords ***
Create Dynamic Employees For New Hire Suite Setup
    [Documentation]    Creates 2 dynamic employees via HRBA API in Suite Setup for New Hire test cases.
    ...    This runs ONCE per suite and creates:
    ...    - ESSNH1_STORE2 (dynamic employee_id in STORE2)
    ...    - ESSNH2_STORE2 (dynamic employee_id in STORE2)
    ...    Employees are stored in pabot-shared cache for parallel execution safety.
    ...    Note: Uses 'Run Only Once' wrapper in Suite Setup for parallel execution safety
    Create Dynamic Employees Via HRBA API

Create Dynamic Employees Via HRBA API
    [Documentation]    Creates 2 dynamic employees via HRBA API in Suite Setup.
    ...
    ...    This runs ONCE per suite and creates:
    ...    - ESSNH1_STORE2 (dynamic employee_id in STORE2)
    ...    - ESSNH2_STORE2 (dynamic employee_id in STORE2)
    ...
    ...    Employees are stored in pabot-shared cache for parallel execution safety.
    ...
    ...    Note: Uses 'Run Only Once' wrapper in Suite Setup for parallel execution safety
    ${store_data}=    Get Store Data    template_name=model_store2
    ${staff_group_id}=    Get System Value    HRBAStaffGroupId    NEWHIRE_STORE2_SG_1
    ${department_id}=    Get System Value    HRBADepartmentId    NEWHIRE_STORE2_DEPT_1
    ${job_code}=    Get System Value    HRBAJobCode    NEWHIRE_STORE2_JOB_CODE_1
    ${job_title}=    Get System Value    HRBAJobTitle    NEWHIRE_STORE2_JOB_TITLE_1
    ${contract_group}=    Get System Value    HRBAContractGroup    NEWHIRE_STORE2_CONTRACT_GROUP_1
    ${state_code}=    Get System Value    HRBAStateCode    NEWHIRE_STORE2_STATE_CODE_1
    ${country_code}=    Get System Value    HRBACountryCode    NEWHIRE_STORE2_COUNTRY_CODE_1
    ${full_time_part_time_indicator}=    Get System Value    HRBAFullTimePartTimeIndicator    NEWHIRE_STORE2_FT_PT_INDICATOR_1
    ${salaried_hourly}=    Get System Value    HRBASalariedHourly    NEWHIRE_STORE2_SALARIED_HOURLY_1
    ${partner_role_code}=    Get System Value    HRBAPartnerRoleCode    NEWHIRE_STORE2_PARTNER_ROLE_CODE_1
    ${additional_field}=    Get System Value    HRBAAdditionalField    NEWHIRE_STORE2_ADDITIONAL_FIELD_1
    ${date_format}=    Get Config Value    SERVER_DF
    ${current_day_date}=    Get Current Date    result_format=${date_format}
    ${current_day_date}=    Subtract Time From Date    ${current_day_date}    1 day    result_format=${date_format}
    ${current_week_start_date}=    Calculate Date From Week Day Offset    0_0    date_format=${date_format}
    ${essnh1_store2}=    Generate Dynamic Employee    user_key=ESSNH1_STORE2    store_data=${store_data}    profile_type=ASSOCIATE
    ${essnh2_store2}=    Generate Dynamic Employee    user_key=ESSNH2_STORE2    store_data=${store_data}    profile_type=ASSOCIATE
    ${hrba_essnh1_store2}=    Get Hrba Api Upload Data
    ...    employee_id=${essnh1_store2}[employee_id]
    ...    associate_id=${essnh1_store2}[employee_id]
    ...    colleague_id=${essnh1_store2}[employee_id]
    ...    record_effective_from=${current_day_date}
    ...    last_name=${essnh1_store2}[lastName]
    ...    first_name=${essnh1_store2}[firstName]
    ...    job_title=${job_title}
    ...    job_code=${job_code}
    ...    job_effective_date=${current_day_date}
    ...    date_of_hire=${current_week_start_date}
    ...    home_store_id=${store_data}[store_id]
    ...    home_staff_group_id=${staff_group_id}    home_job_id=${staff_group_id}
    ...    home_department_id=${department_id}
    ...    home_department_effective_date=${current_week_start_date}
    ...    full_time_part_time_indicator=${full_time_part_time_indicator}    gte_30_lt_30h_indicator=${full_time_part_time_indicator}
    ...    salaried_hourly=${salaried_hourly}
    ...    contract_group=${contract_group}
    ...    contract_effective_date=${current_day_date}
    ...    state_code=${state_code}
    ...    country_code=${country_code}
    ...    base_wage_effective_date=${current_week_start_date}
    ...    badge_number=${essnh1_store2}[employee_id]
    ...    badge_effective_date=${current_day_date}
    ...    status_effective_date=${current_day_date}
    ...    partner_role_code=${partner_role_code}
    ...    additional_field=${additional_field}
    ...    supervisor_employee_id=${EMPTY}
    ...    full_time_date=${EMPTY}    gte_30_date=${EMPTY}
    ${hrba_essnh2_store2}=    Get Hrba Api Upload Data
    ...    employee_id=${essnh2_store2}[employee_id]
    ...    associate_id=${essnh2_store2}[employee_id]
    ...    colleague_id=${essnh2_store2}[employee_id]
    ...    record_effective_from=${current_day_date}
    ...    last_name=${essnh2_store2}[lastName]
    ...    first_name=${essnh2_store2}[firstName]
    ...    job_title=${job_title}
    ...    job_code=${job_code}
    ...    job_effective_date=${current_day_date}
    ...    date_of_hire=${current_week_start_date}
    ...    home_store_id=${store_data}[store_id]
    ...    home_staff_group_id=${staff_group_id}    home_job_id=${staff_group_id}
    ...    home_department_id=${department_id}
    ...    home_department_effective_date=${current_week_start_date}
    ...    full_time_part_time_indicator=${full_time_part_time_indicator}    gte_30_lt_30h_indicator=${full_time_part_time_indicator}
    ...    salaried_hourly=${salaried_hourly}
    ...    contract_group=${contract_group}
    ...    contract_effective_date=${current_day_date}
    ...    state_code=${state_code}
    ...    country_code=${country_code}
    ...    base_wage_effective_date=${current_week_start_date}
    ...    badge_number=${essnh2_store2}[employee_id]
    ...    badge_effective_date=${current_day_date}
    ...    status_effective_date=${current_day_date}
    ...    partner_role_code=${partner_role_code}
    ...    additional_field=${additional_field}
    ...    supervisor_employee_id=${EMPTY}
    ...    full_time_date=${EMPTY}    gte_30_date=${EMPTY}
    VAR    @{users}=    ${hrba_essnh1_store2}    ${hrba_essnh2_store2}
    Create HRBA Users Via API
    ...    user_key=SYSADMIN
    ...    users_data=${users}
    Log    ✅ Successfully created ESSNH1_STORE2: Employee ID=${essnh1_store2}[employee_id] (${store_data}[store_name])    level=INFO
    Log    ✅ Successfully created ESSNH2_STORE2: Employee ID=${essnh2_store2}[employee_id] (${store_data}[store_name])    level=INFO

    # Store in pabot-shared cache (works across parallel processes)
    Set Dynamic Employee    ESSNH1_STORE2    ${essnh1_store2}
    Set Dynamic Employee    ESSNH2_STORE2    ${essnh2_store2}

    Finish New Hire First Login Setup If Required On Web    ESSNH1_STORE2
    Finish New Hire First Login Setup If Required On Web    ESSNH2_STORE2

    Log    📋 Suite Setup Complete: 2 employees created and available for tests    level=INFO

Terminate Dynamic Employees For New Hire Suite Teardown
    [Documentation]    Terminates all dynamic employees via HRCI API in Suite Teardown for New Hire test cases.
    ...    This runs ONCE at the end of the suite to clean up all created employees.
    Terminate Users Via HRCI For Suite Teardown

Terminate Users Via HRCI For Suite Teardown
    [Documentation]    Terminates all dynamic employees via HRCI API in Suite Teardown.
    ...
    ...    This runs ONCE at the end of the suite to clean up all created employees.

    Log    🧹 Suite Teardown: Terminating dynamic employees via HRCI API...    level=INFO

    # Get date configuration from environment (not hardcoded!)
    ${date_format}=    Get Config Value    SERVER_DF
    ${current_day_date}=    Get Current Date    result_format=${date_format}
    ${termination_date}=    Add Time To Date    ${current_day_date}    2 days    result_format=${date_format}

    # Get employees from suite variable
    ${essnh1_store2}=    Get Dynamic Employee    ESSNH1_STORE2
    ${essnh2_store2}=    Get Dynamic Employee    ESSNH2_STORE2

    # Create HRCI records for termination
    ${hrci_essnh1_store2}=    Get Hrci Api Upload Data
    ...    employee_id=${essnh1_store2}[employee_id]
    ...    effective_date=${termination_date}

    ${hrci_essnh2_store2}=    Get Hrci Api Upload Data
    ...    employee_id=${essnh2_store2}[employee_id]
    ...    effective_date=${termination_date}

    # Terminate both employees via HRCI API (single API call for both)
    VAR    @{records}=    ${hrci_essnh1_store2}    ${hrci_essnh2_store2}
    Update HRCI User Status Via API
    ...    user_key=SYSADMIN
    ...    records_data=${records}

    Log    ✅ Successfully terminated ESSNH1_STORE2: Employee ID=${essnh1_store2}[employee_id]    level=INFO
    Log    ✅ Successfully terminated ESSNH2_STORE2: Employee ID=${essnh2_store2}[employee_id]    level=INFO
    Log    🧹 Suite Teardown Complete    level=INFO
