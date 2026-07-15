*** Settings ***
Documentation       This test suite verifies if user is able to generate Forecast/Workload/Schedule

Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/rws/driver_forecast/driver_forecast.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource
Resource            resources/web/rws/schedule/schedule_setup.resource

Test Setup          Clear Generated Schedule And Workload On Plan Status Page On Web    SM1_STORE1    9_0
Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:write    battc00023    bat_phase1    config:rws    config:weekplan_and_schedule_gen


*** Test Cases ***
BATTC00023: Verify user is able to generate forecast, workload and schedule from batch plan status
    [Documentation]    Test case for verifying whether user is able to generate forecast/workload/schedule
    ...    If Generate Workload config flag status is 1, perform VDI import precondition before login.
    ${store_data}    Get System Value    StoreEntity    MODEL_STORE1
    ${dual_scheduling_flow_constraint}    Get Dual Scheduling Flow Constraint Type From Database
    IF    '${dual_scheduling_flow_constraint}' == 'S'
        Skip    Dual scheduling flow is set to Strict (CONSTRAINT_TYPE=S). Skipping test.
    END
    ${generate_workload_config_flag_status}    Get Generate Workload Config Flag Status From Database
    IF    ${generate_workload_config_flag_status} == 1
        Generate Workload From VDI Import    9_0    ${store_data}[UNIT_ID]
    END
    ${date_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${planned_week_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${week}    ${planned_week}    Calculate Date From Week Day Offset In Multiple Formats    9_0    ${date_format}
    ...    ${planned_week_date_format}
    Log    Week and planned week returned: ${week} and ${planned_week}
    ${week_plan_state}    Get Week Plan State For Unit And Week From Database    ${store_data}[UNIT_ID]    ${planned_week}
    IF    ${week_plan_state} >= 5 or ${week_plan_state} <= 0
        Skip    Schedule is already in published state (STATE_SKEY=${week_plan_state}) for week ${planned_week}. Skipping test.
    END
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    9_0
    ${is_plan_status_displayed}    Check If Plan Status Page Displayed On Web
    Skip If    '${is_plan_status_displayed}'=='False'    Publish Schedule On Week Schedule Page On Web
    ${selected_week_plan_status}    Get Selected Week From Week Navigation On Plan Status Page On Web
    Delete Workload If Already Generated On Plan Status Page On Web
    IF    str($generate_workload_config_flag_status) != '1' and str($week_plan_state) != '0'
        Generate Week Plan On Plan Status Page On Web
        Verify If Generate Week Plan Is Completed On Plan Status Page On Web
    END
    Go To The Forecast Page On Plan Status Page On Web
    ${selected_week_forecast}    Get Selected Week From Week Navigation On Driver Forecast Page On Web
    Should Be Equal As Strings    ${selected_week_plan_status}    ${selected_week_forecast}
    ${is_plan_status_displayed}    Check If Plan Status Page Displayed On Web
    IF    not ${is_plan_status_displayed}
        Return To Plan Status Page From RailRoad Option On Web
    END
    Generate Workload On Plan Status Page On Web
    Verify If Generate Workload Is Completed On Plan Status Page On Web
    Go To The Workload Page On Plan Status Page On Web
    ${selected_week_workload}    Get Selected Week From Week Navigation On Labor Forecast Page On Web
    Should Be Equal As Strings    ${selected_week_plan_status}    ${selected_week_workload}
    Return To Plan Status Page From RailRoad Option On Web
    Generate Optimized Schedule On Plan Status Page On Web
    Verify If Generate Optimized Schedule Is Completed On Plan Status Page On Web
    Go To Schedule Page On Web
    ${selected_week_schedule}    Get Selected Week From Week Navigation On Schedule Page On Web
    Should Be Equal As Strings    ${selected_week_plan_status}    ${selected_week_schedule}
    Delete Current Schedule On Plan Status Page On Web
    Delete The Workload On Plan Status Page On Web
