*** Settings ***
Documentation       Week 3 - SM1_STORE1 SIT Schedule Suite
...                 **PURPOSE:**
...                 This suite consolidates all SIT test cases that require Week 3 schedule data for Store1.
...                 All tests in this suite use the same week setup, enabling efficient parallel execution.
...
...                 **ONE-TIME SETUP APPROACH:**
...                 Suite Setup executes 'Pre Setup Schedule For Week 3 SM1Store1 SIT' wrapped with 'Run Only Once' from pabot.PabotLib.
...                 This ensures schedule setup runs exactly ONCE across all parallel processes before any tests execute.
...
...                 **PARALLEL EXECUTION ENABLED:**
...                 Tests can be executed in parallel using pabot. The setup runs once, then all tests execute concurrently.
...
...                 **TEST CASES INCLUDED:**
...                 - SITTC70001: Decline Individual Swap Shift Request By Responder On Web
...                 - SITTC70002: Swap And Decline Swap Shift Request By Multiple Responders On Web
...
...                 **EXECUTION COMMANDS:**
...
...                 Sequential execution:
...                 uv run python executor.py tests/web/SIT/OM/HR/schedule_dependent/week3_sm1store1_schedule_suite.robot --test-env QA28_B0
...
...                 Parallel execution (recommended, 7 processes):
...                 uv run python executor.py tests/web/SIT/OM/HR/schedule_dependent/week3_sm1store1_schedule_suite.robot --test-env QA28_B0 --processes 7
...
...                 With browser visible (for debugging):
...                 uv run python executor.py tests/web/SIT/OM/HR/schedule_dependent/week3_sm1store1_schedule_suite.robot --test-env QA28_B0 --show-browser
...
...                 **LOCK FILE CLEANUP:**
...                 If setup appears to be skipped, clean pabot lock files before running:
...                 Remove-Item -Path ".pabot_results" -Recurse -Force -ErrorAction SilentlyContinue

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/shift_trade_board.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/web/ess/ess_monthly_calendar.resource

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store1 SIT
Suite Teardown      Log    Week 3 SM1Store1 SIT Suite Complete - All tests executed    level=INFO
Test Teardown       Close Browser

Test Tags    week3_sit_sm1store1    action:write    config:ess_shift_bidding    config:ess    schedule_dependent    sit    web    sit_v1    sit_epic    sit_r22


*** Test Cases ***
SITTC70001: Verify ESS user is able to decline the individual swap shift request and another user accepts it when requested again from web
    [Documentation]    Verify that responder is able to decline the individual swap shift request on web.
    [Tags]    sittc70001    dev:moiz    config:swap_shift_enabled    config:weekplan_and_schedule_gen    om_hr
    ${ess_user1}    Get User    user_key=ESS7_STORE1_SIT
    ${ess_user2}    Get User    user_key=ESS8_STORE1_SIT
    ${ess_user3}    Get User    user_key=ESS16_STORE1_SIT
    ${shift_trade_data}    Get All Eligible Swap Shift Data
    ${declined_status}    Get System Value    RequestStatus    DECLINED
    VAR    ${shift_location}    ${ess_user1}[unitName]

    Login And Launch WFM Web App    user_key=ESS7_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    ${swap_shift_start_time}    ${swap_shift_end_time}    Get Shift Time On Shift Trade Board Page On Web    2
    Swap The Shift At Day For Associate On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${ess_user2}[displayName]    ${shift_trade_data}[swap_request_notes]
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS8_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    ${responder_start_time}    ${responder_end_time}    Get Shift Time On Shift Trade Board Page On Web    2
    Decline Swap Shift Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]    ${ess_user1}[displayName]
    Verify Approval Status For Swap Shift Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${ess_user1}[displayName]    expected_approval_status=${declined_status}
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS7_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    Verify Responses In Raised Swap Shift On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${ess_user2}[displayName]    ${swap_shift_start_time}    ${swap_shift_end_time}
    ...    ${shift_location}    ${declined_status}    ${responder_start_time}    ${responder_end_time}
    Complete Swap Shift Request Withdrawal Workflow On Web
    ...    ESS7_STORE1_SIT    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[week_trade_day]

    Login And Launch WFM Web App    user_key=ESS7_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    Swap The Shift At Day For Associate On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${ess_user3}[displayName]    ${shift_trade_data}[swap_request_notes]
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS16_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    Respond To Swap Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]    ${ess_user1}[displayName]
    ...    ${shift_trade_data}[swap_response_notes]
    Log Out From Web Application
    Close Browser

    [Teardown]    Run Keyword And Ignore Error    Complete Swap Shift Request Withdrawal Workflow On Web
    ...    ESS7_STORE1_SIT    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[week_trade_day]

SITTC70002: Verify ESS user is able to decline the all-eligible swap shift request and another user accepts it when requested again from web
    [Documentation]    Verify that responder is able to decline and swap the individual swap shift request on web.
    [Tags]    sittc70002    dev:moiz    config:swap_shift_enabled    config:weekplan_and_schedule_gen    om_hr
    ${ess_user1}    Get User    user_key=ESS7_STORE1_SIT
    ${ess_user2}    Get User    user_key=ESS8_STORE1_SIT
    ${ess_user3}    Get User    user_key=ESS16_STORE1_SIT
    ${ess_user4}    Get User    user_key=ESS17_STORE1_SIT

    ${shift_trade_data}    Get All Eligible Swap Shift Data
    ${declined_status}    Get System Value    RequestStatus    DECLINED
    ${approved_status}    Get System Value    RequestStatus    APPROVED
    VAR    ${shift_location}    ${ess_user1}[unitName]

    Login And Launch WFM Web App    user_key=ESS7_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    ${swap_shift_start_time}    ${swap_shift_end_time}    Get Shift Time On Shift Trade Board Page On Web    2
    Swap Shift At Day On Shift Trade Board Page On Web    ${shift_trade_data}    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[swap_request_notes]
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS8_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    ${ess_user2_start_time}    ${ess_user2_end_time}    Get Shift Time On Shift Trade Board Page On Web    2
    Decline Swap Shift Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]    ${ess_user1}[displayName]
    Verify Approval Status For Swap Shift Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${ess_user1}[displayName]    expected_approval_status=${declined_status}
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS17_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    ${ess_user4_start_time}    ${ess_user4_end_time}    Get Shift Time On Shift Trade Board Page On Web    2
    Decline Swap Shift Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]    ${ess_user1}[displayName]
    Verify Approval Status For Swap Shift Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${ess_user1}[displayName]    expected_approval_status=${declined_status}
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS16_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    ${ess_user3_start_time}    ${ess_user3_end_time}    Get Shift Time On Shift Trade Board Page On Web    2
    Respond To Swap Request On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]    ${ess_user1}[displayName]
    ...    ${shift_trade_data}[swap_response_notes]
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS7_STORE1_SIT
    Navigate To ESS Shift Trade Board Page On Web
    Select Week Number On Shift Trade Board Calendar Page On Web    ${shift_trade_data}[planning_week_date]
    Verify Responses In Raised Swap Shift On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${ess_user2}[displayName]    ${swap_shift_start_time}    ${swap_shift_end_time}
    ...    ${shift_location}    ${declined_status}    ${ess_user2_start_time}    ${ess_user2_end_time}
    Verify Responses In Raised Swap Shift On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${ess_user3}[displayName]    ${swap_shift_start_time}    ${swap_shift_end_time}
    ...    ${shift_location}    ${approved_status}    ${ess_user3_start_time}    ${ess_user3_end_time}
    Verify Responses In Raised Swap Shift On Shift Trade Board Page On Web    ${shift_trade_data}[week_trade_day]
    ...    ${ess_user4}[displayName]    ${swap_shift_start_time}    ${swap_shift_end_time}
    ...    ${shift_location}    ${declined_status}    ${ess_user4_start_time}    ${ess_user4_end_time}
    Log Out From Web Application
    Close Browser

    [Teardown]    Run Keyword And Ignore Error    Complete Swap Shift Request Withdrawal Workflow On Web
    ...    ESS7_STORE1_SIT    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[week_trade_day]
