*** Settings ***
Documentation       Test case for verifying that user is able to generate forecast, workload and schedule from RWS Driver Forecast Weekly Plan page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/driver_forecast/weekly_plan.resource
Resource            resources/web/rws/driver_forecast/batch_jobs.resource
Resource            resources/web/rws/schedule/all_schedules.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource
Resource            resources/web/rws/schedule/plan_status.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource

Test Teardown       Close Browser

Test Tags    dev:rushikesh    action:write    battc00010    bat_phase1    config:legacy_forecasting    config:rws
...    config:weekplan_and_schedule_gen    module:forecast


*** Test Cases ***
BATTC00010: Verify user is able to generate forecast, workload and schedule and review the generation process using batch job monitoring
    [Documentation]    Test case for verifying that user is able to generate forecast, workload and schedule
    ...    from RWS Driver Forecast Weekly Plan page
    ${dual_scheduling_flow_constraint}    Get Dual Scheduling Flow Constraint Type From Database
    IF    '${dual_scheduling_flow_constraint}' == 'S'
        Skip    Dual scheduling flow is set to Strict (CONSTRAINT_TYPE=S). Skipping test.
    END
    ${org_level_store}    Get System Value    OrganizationLevel    STORE
    ${store_data}    Get Store Data
    ${date_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${planned_week_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${week_data}    Get Schedule Generation Setup Data    template_name=4_0_sm1store2
    ${week}    ${planned_week}    Calculate Date From Week Day Offset In Multiple Formats    ${week_data}[week_start_date]
    ...    ${date_format}    ${planned_week_date_format}
    ${week_plan_state}    Get Week Plan State For Unit And Week From Database    ${store_data}[store_id]    ${planned_week}
    IF    ${week_plan_state} >= 5 or ${week_plan_state} <= 0
        Skip    Schedule is already in published state (STATE_SKEY=${week_plan_state}) for week ${planned_week}. Skipping test.
    END
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Driver Forecast Weekly Plan Page On Web
    Select Week Number On Weekly Plan Page On Web    ${week_data}[week_start_date]
    Verify Week Is Displayed On Weekly Plan Page On Web    ${week}
    Select The Org Level Location And Unit On Web    ${org_level_store}    ${store_data}[store_id] - ${store_data}[store_name]
    Initialize Forecast On Web
    Verify Forecast Job Is Completed On Admin Batch Jobs Monitor Page On Web    ${store_data}
    Navigate To RWS Labor Forecast Page On Web
    Select Week Number On Labor Forecast Page On Web    ${week_data}[week_start_date]
    Select Store To Search Workload Values On Labor Forecast Page On Web    ${store_data}[store_name]
    Generate Workload On Labor Forecast Page On Web
    Verify Workload Job Is Completed On Admin Batch Jobs Monitor Page On Web    ${planned_week}    ${store_data}[store_name]
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Plan Status Page On Web
    Select Week Number On Plan Status Page On Web    ${week_data}[week_start_date]
    Generate Optimized Schedule On Plan Status Page On Web
    Login And Launch WFM Web App    user_key=SYSADMIN
    Verify Schedule Generation Job Is Completed On Admin Batch Jobs Monitor Page On Web    ${planned_week}    ${store_data}[store_name]
    Close Browser
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Plan Status Page On Web
    Select Week Number On Plan Status Page On Web    ${week_data}[week_start_date]
    ${is_delete_workload_visible}    Delete Schedule On Plan Status Page On Web
    IF    ${is_delete_workload_visible}
        Delete The Workload On Plan Status Page On Web
    END
    Close Browser
