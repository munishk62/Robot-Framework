*** Settings ***
Documentation       Covers mobility new-hire dependent scenarios for BATTC00236 clock transactions, BATTC00283 home-page clock transactions, BATTC00174 alternate work location requests, and BATTC00230 temporary availability with schedule verification.

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Clock_Module/clock.resource
Resource            resources/web/rws/admin/rws_upload_api.resource
Resource            resources/Mobile/Common/mobile_new_hire.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/employee/criteria_configuration.resource
Resource            resources/Mobile/ESS/PagesResources/Alt_Work_Location_Module/Alternate_Work_Location.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Associate_Roster/Availability_Tab.resource
Resource            resources/Mobile/SM/PagesResources/More/More.resource
Resource            resources/Mobile/SM/PagesResources/Timecard/Exception_Management_Page.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Store_Schedule.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Shift_Details.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 0 SM1Store2
Suite Teardown      Run Keywords
...                     Run Only Once    Terminate Dynamic Employees For New Hire Suite Teardown For Mobility    AND
...                     Run Keyword And Ignore Error    Close Application

Test Tags           new_hire_dependent


*** Variables ***
${ROUNDING_POLICY}      900


*** Test Cases ***
BATTC00236: Verify ESS user is able to do clock transactions in mobility
    [Documentation]    BATTC00236: Verify ESS user is able to do clock transactions in mobility
    [Tags]    dev:ashish    battc00236    config:rws    config:ess    config:rta    config:enable_mobile_clock    mobile    bat_phase2
    ...    config:mobile_shift_enabled    bug_reported    bugid_wfm_139441
    Open Shift App On Mobile    battc00236
    ${user}    Get Dynamic Employee    ESSNH7_STORE2
    ${shift_time_clock_data}    Get Shift Time Clock Data
    ${format}    Get Config Value    DATE_FORMAT_YYMMDDHHMM

    Login Mobile Ess App    ESSNH7_STORE2    is_new_hire=True
    Navigate To Clock Module On Mobile ESS
    Verify Device In Store For Mobile ESS    ${user}[unitName]
    Clock In On Mobile ESS
    ...    activity_code=${shift_time_clock_data}[activity_code]
    ...    questionnaire=${shift_time_clock_data}[clock_in_questionnaire]
    ${clock_in_time}    Get Today Date With Timezone    ${format}    ${user}[unitID]
    Log To Console
    ...    Clock in happened on ${clock_in_time}, sleeping for ${ROUNDING_POLICY} seconds to allow rounding policy to take effect
    Sleep    ${ROUNDING_POLICY}s

    Take Meal On Mobile ESS    user_display_name=${user}[displayName]
    ${take_meal_time}    Get Today Date With Timezone    ${format}    ${user}[unitID]
    Log To Console
    ...    Take meal happened on ${take_meal_time}, sleeping for ${ROUNDING_POLICY} seconds to allow rounding policy to take effect
    Sleep    ${ROUNDING_POLICY}s

    Meal End On Mobile ESS
    ...    activity_code=${shift_time_clock_data}[activity_code]
    ...    questionnaire=${shift_time_clock_data}[clock_in_questionnaire]
    ${end_meal_time}    Get Today Date With Timezone    ${format}    ${user}[unitID]
    Log To Console
    ...    Meal end happened on ${end_meal_time}, sleeping for ${ROUNDING_POLICY} seconds to allow rounding policy to take effect
    Sleep    ${ROUNDING_POLICY}s

    Tap For Clock Out On Mobile ESS
    Clock Out On Mobile ESS    questionnaire=${shift_time_clock_data}[clock_in_questionnaire]
    ${clock_out_time}    Get Today Date With Timezone    ${format}    ${user}[unitID]
    Log To Console
    ...    Clock out happened on ${clock_out_time}, sleeping for ${ROUNDING_POLICY} seconds to allow rounding policy to take effect
    Sleep    ${ROUNDING_POLICY}s

    View Clock Punch Card On Mobile ESS
    Verify Clock In Transaction Time In Punch Card On Mobile ESS
    Verify Clock Out Transaction Time In Punch Card On Mobile ESS

    [Teardown]    Teardown Test Case    battc00236

BATTC00283: Verify ESS user is able to do clock transactions from Home page
    [Documentation]
    ...    BATTC00283: Verify ESS user is able to perform clock in, take meal, meal end, and clock out from the ESS home page in mobility.
    ...
    ...    *Setup*: Web schedule generation publishes the current week and assigns today's shift to the ESSNH7 new hire before the mobile flow starts.
    ...
    ...    *ESS home-page flow*: Clock transactions are driven from the home feed (not the clock module). After each punch, the test sleeps for ``${ROUNDING_POLICY}`` seconds so rounding can apply. Post-action home-feed checks are:
    ...    - Clock in → ``Shift Start: {clock-in time}``
    ...    - Take meal → end meal visible
    ...    - Meal end → take meal visible
    ...    - Clock out → via home more-options navigation to the clock screen
    ...
    ...    *ESS punch card*: After opening the punch card from the clock module, verifies Shift Start, Meal Start, Meal End, and Shift End transaction types are present on the page (type-only ``Page Contains`` check; time is not asserted).
    ...
    ...    *SM timecard*: Opens the associate timecard for today (no week navigation). Hard assert on transaction type; soft assert on review alert text in ``{type} at {time}`` form with light swipe-down retry when the alert is off-screen.
    [Tags]    dev:sai    battc00283    config:rws    config:ess    config:rta    config:enable_mobile_clock    mobile    bat_phase2
    ...    schedule_dependent
    ...    config:mobile_shift_enabled    config:mobile_sm_enabled    bug_reported    bugid_wfm_139441
    Open Shift App On Mobile    battc00283
    ${user}    Get Dynamic Employee    ESSNH7_STORE2
    ${shift_time_clock_data}    Get Shift Time Clock Data
    ${format}    Get Config Value    DATE_FORMAT_YYMMDDHHMM

    Login Mobile Ess App    ESSNH7_STORE2    is_new_hire=True
    ${clock_in_time}    Clock In From Home Screen On Mobile ESS
    ...    activity_code=${shift_time_clock_data}[activity_code]
    ...    questionnaire=${shift_time_clock_data}[clock_in_questionnaire]
    ...    unit_id=${user}[unitID]
    Log To Console
    ...    Clock in happened on ${clock_in_time}, sleeping for ${ROUNDING_POLICY} seconds to allow rounding policy to take effect
    Sleep    ${ROUNDING_POLICY}s

    Take Meal From Home Screen On Mobile ESS
    ${take_meal_time}    Get Today Date With Timezone    ${format}    ${user}[unitID]
    Log To Console
    ...    Take meal happened on ${take_meal_time}, sleeping for ${ROUNDING_POLICY} seconds to allow rounding policy to take effect
    Sleep    ${ROUNDING_POLICY}s

    Meal End From Home Screen On Mobile ESS
    ...    activity_code=${shift_time_clock_data}[activity_code]
    ...    questionnaire=${shift_time_clock_data}[clock_in_questionnaire]
    ${end_meal_time}    Get Today Date With Timezone    ${format}    ${user}[unitID]
    Log To Console
    ...    Meal end happened on ${end_meal_time}, sleeping for ${ROUNDING_POLICY} seconds to allow rounding policy to take effect
    Sleep    ${ROUNDING_POLICY}s

    Complete Clock Out From Home Screen On Mobile ESS
    ...    questionnaire=${shift_time_clock_data}[clock_in_questionnaire]
    ${clock_out_time}    Get Today Date With Timezone    ${format}    ${user}[unitID]
    Log To Console
    ...    Clock out happened on ${clock_out_time}, sleeping for ${ROUNDING_POLICY} seconds to allow rounding policy to take effect
    Sleep    ${ROUNDING_POLICY}s

    Navigate To Clock Module On Mobile ESS
    Verify Device In Store For Mobile ESS    ${user}[unitName]
    View Clock Punch Card On Mobile ESS
    Verify Clock In Transaction Time In Punch Card On Mobile ESS
    Verify Clock Out Transaction Time In Punch Card On Mobile ESS
    Close Mobile Application    battc00283

    Open SM App On Mobile    battc00283_sm
    Login SM App On Mobile    SM1_STORE2
    Select More Tab On SM Phone App
    Select Timecard From More Tab On SM Phone App
    Select Associate On Exception Management Page On SM Phone App    ${user}[username]    ${user}[displayName]
    Verify Today Is Displayed On SM Timecard On SM Phone App
    Verify Clock Punch Transaction On Timecard On SM Phone App    SHIFT_START
    Verify Soft Timecard Alert Message For Punch On SM Phone App    SHIFT_START    ${clock_in_time}
    Verify Clock Punch Transaction On Timecard On SM Phone App    MEAL_START
    Verify Soft Timecard Alert Message For Punch On SM Phone App    MEAL_START    ${take_meal_time}
    Verify Clock Punch Transaction On Timecard On SM Phone App    MEAL_END
    Verify Soft Timecard Alert Message For Punch On SM Phone App    MEAL_END    ${end_meal_time}
    Verify Clock Punch Transaction On Timecard On SM Phone App    SHIFT_END
    Verify Soft Timecard Alert Message For Punch On SM Phone App    SHIFT_END    ${clock_out_time}

    [Teardown]    Teardown Test Case     battc00283

BATTC00174: Verify user is able to add/edit/delete alternate location requests in mobility
    [Documentation]    Verify ESS user is able to add/edit/delete alternate work location requests in mobility
    [Tags]    dev:ashish    battc00174    config:ess    config:ess_alternate_work_location    config:weekplan_and_schedule_gen    mobile
    ...    bat_phase2
    ...    config:mobile_shift_enabled
    # Web Setup Flow
    Add Alternate Work Location Criteria If Not Present
    # Mobile Test Flow
    ${work_location_data}    Get Alternate Work Location Data
    Open Shift App On Mobile    battc00174
    Login Mobile Ess App    ESSNH3_STORE2    is_new_hire=True
    Navigate To ESS Work Locations Page On Mobile ESS
    Select Alternate Work Location Requests Tab On Mobile ESS

    # Delete any existing requests for same duration to avoid conflicts
    ${is_same_request_present}    Run Keyword And Return Status
    ...    Verify Mobile ESS Alternate Work Location Request List Item On Mobile ESS    ${work_location_data}[unit_ids]
    ...    ${work_location_data}[start_date]    ${work_location_data}[end_date]    ${work_location_data}[status]
    IF    ${is_same_request_present}
        Tap Alternate Work Location Request List Item On Mobile ESS    ${work_location_data}[unit_ids]    ${work_location_data}[start_date]
        ...    ${work_location_data}[end_date]    ${work_location_data}[status]
        Delete Alternate Work Location Request From Details On Mobile ESS
    END

    Open Add Alternate Work Location Page On Mobile ESS
    Add Alternate Work Location Request On Mobile ESS    ${work_location_data}[description]    ${work_location_data}[start_date]
    ...    ${work_location_data}[end_date]    ${work_location_data}[unit_ids]    ${work_location_data}[note]
    Select Alternate Work Location Requests Tab On Mobile ESS
    Verify Mobile ESS Alternate Work Location Request List Item On Mobile ESS    ${work_location_data}[unit_ids]
    ...    ${work_location_data}[start_date]    ${work_location_data}[end_date]    ${work_location_data}[status]

    # Edit flow
    Tap Alternate Work Location Request List Item On Mobile ESS    ${work_location_data}[unit_ids]    ${work_location_data}[start_date]
    ...    ${work_location_data}[end_date]    ${work_location_data}[status]
    Tap Edit Alternate Work Location Request Page On Mobile ESS
    Edit Description Of Alternate Work Location Request On Mobile ESS    ${work_location_data}[description]
    ...    ${work_location_data}[edit_description]
    Resubmit Alternate Work Location Request For Approval On Mobile ESS

    # Delete
    Delete Alternate Work Location Request From Details On Mobile ESS

    [Teardown]    Run Keywords    Teardown Test Case    battc00174    AND    Delete Alternate Work Location Criteria If Present

BATTC00230: Verify SM user is able to add / edit / approve /delete temporary availability and verify in schedule in mobility
    [Documentation]    Verify SM user is able to add / edit / approve /delete temporary availability and verify in schedule in mobility
    [Tags]    action:read    dev:ashish    battc00230    mobile    bat_phase2    config:rws
    ...    config:add_edit_delete_availability_request_sm    config:temporary_availability_enabled    schedule_dependent
    ...    config:mobile_sm_enabled
    ${ess_user}    Get Dynamic Employee    ESSNH3_STORE2
    ${availability_add_data}    Get Shift Availability Data    template_name=sm_add_temp_availability
    Open SM App On Mobile    battc00230
    Login SM App On Mobile    SM1_STORE2
    Navigate To Associate Roster Module On SM Phone App
    Search And Select Associate Name On Associate Roster Page On SM Phone App    ${ess_user}[displayName]
    Navigate To Availability Tab On Associate Roster Page On SM Phone App
    Tap Add Button On Availability Tab On SM Phone App
    Select Temporary Availability Type On SM Phone App
    Select Start Date For Availability On SM Phone App    ${availability_add_data}[start_date]
    Select Availability Reason On SM Phone App    ${availability_add_data}[reason]
    Select Availability Status On SM Phone App    ${availability_add_data}[status]
    Add Availability Timing Windows On SM Phone App    ${availability_add_data}[rotations]
    Tap Submit Availability Request On SM Phone App
    Verify Availability List Item On SM Phone App    ${availability_add_data}    SM1_STORE2
    Tap Availability List Item On SM Phone App    ${availability_add_data}    SM1_STORE2
    Tap Edit Availability Request Details On SM Phone App
    ${availability_edit_data}    Get Shift Availability Data    template_name=sm_edit_temp_availability
    Select Availability Status On SM Phone App    ${availability_edit_data}[status]
    Tap Save To Edited Availability Request On SM Phone App
    Verify Availability List Item On SM Phone App    ${availability_add_data}    SM1_STORE2
    Close Mobile Application    battc00230

    Setup Schedule For Availability Request    ${availability_add_data}

    Open SM App On Mobile    battc00230
    Login SM App On Mobile    SM1_STORE2
    Navigate To Store Schedule Page On SM Phone App
    ${shift_date}    Combine Week Offset And Day No    ${availability_add_data}[start_date]    6
    ${add_shift_2}    Get Shift Data    shift_date=${shift_date}    start_time=09:00    end_time=17:00
    ...    task_name=TaskSegmentType.CONTINUED_WORK

    Select Week On Store Schedule Page On SM Phone App    ${availability_add_data}[start_date]
    Select Shift On Date For Associate On Store Schedule Page On SM Phone App    ${ess_user}[displayName]    ${shift_date}
    Add Shift On Selected Date Details Page On SM Phone App    ${add_shift_2}[start_time]    ${add_shift_2}[end_time]
    ...    ${add_shift_2}[task_name]
    Verify Shift Saved Successfully On SM Phone App
    Select Shift On Date For Associate On Store Schedule Page On SM Phone App    ${ess_user}[displayName]    ${shift_date}

    ${constraint_type}    ${status}    Get Alert Status And Severity From Database    E0005
    ${engine_name}    Get Scheduling Engine For Store From Database    ${ess_user}[unitID]
    ${is_alert_severe}    Run Keyword And Return Status    Should Be Equal    ${constraint_type}    S
    ${is_alert_active}    Run Keyword And Return Status    Should Be Equal    ${status}    A
    ${is_rule_based_scheduling}    Run Keyword And Return Status    Should Be Equal    ${engine_name}    RULE SCHEDULING
    ${is_alert_enabled}    Evaluate    ${is_rule_based_scheduling} and ${is_alert_severe} and ${is_alert_active}
    IF    ${is_alert_enabled}
        Verify Alerts Present For Shift On SM Phone App
    ELSE
        Verify No Alerts Present For Shift On SM Phone App
    END

    [Teardown]    Teardown Test Case    battc00230


*** Keywords ***
Open Shift App On Mobile
    [Documentation]    Setup for mobile test case: initializes necessary resources and performs login before each test case.
    ...    Arguments:
    ...    - ${tc_id}: Test case ID to link the screen recording and screenshot.
    ...    Example:
    ...    - Setup Test Case    battc00236
    [Arguments]    ${tc_id}
    Open Mobile ESS App    ${tc_id}
    Start Mobile Screen Recording

Open SM App On Mobile
    [Documentation]    Setup for mobile test case: initializes necessary resources and performs login before each test case.
    ...    Arguments:
    ...    - ${tc_id}: Test case ID to link the screen recording and screenshot.
    ...    Example:
    ...    - Setup Test Case    battc00236
    [Arguments]    ${tc_id}
    Open SM Native Application On Mobile Phone    ${tc_id}
    Start Mobile Screen Recording

Add Alternate Work Location Criteria If Not Present
    [Documentation]    Adds criteria for alternate work location if not already present to ensure the test
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Employee Criteria Configuration Page On Web
    ${criteria_data}    Get Criteria Configuration Data
    Delete Criteria If Exists On Criteria Configuration Page On Web    ${criteria_data}[name]
    Add Criteria On Criteria Configuration Page On Web    ${criteria_data}
    Log Out From Web Application
    Close Browser

Delete Alternate Work Location Criteria If Present
    [Documentation]    Deletes criteria for alternate work location if already present to clean up after the test
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Employee Criteria Configuration Page On Web
    ${criteria_data}    Get Criteria Configuration Data
    Delete Criteria If Exists On Criteria Configuration Page On Web    ${criteria_data}[name]
    Log Out From Web Application
    Close Browser

Setup Schedule For Availability Request
    [Documentation]    Executes schedule setup for the availability request created in BATTC00230.
    [Arguments]    ${availability_add_data}
    ${sm_user_schedule_gen}    Get User    SM1_STORE2
    ${workflow}    Get Schedule Workflow Setup Data
    ...    template_name=only_generate_schedule
    ...    week_start_date=${availability_add_data}[start_date]
    ...    week_offset=${availability_add_data}[start_date]
    ...    _date_format=%Y%m%d
    ${essnh3_store2}    Get Employee Shift Setup Data    template_name=add123_standard8_addunallocate6    ess_user_key=ESSNH3_STORE2
    VAR    @{employee_operations}    ${essnh3_store2}
    Pre Setup Store Schedule For Week    ${sm_user_schedule_gen}    ${workflow}    ${employee_operations}
