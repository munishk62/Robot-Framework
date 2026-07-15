*** Settings ***
Documentation       This test suite verifies if user is able to generate Forecast/Workload/Schedule

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/driver_forecast/batch_jobs.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource
Resource            resources/web/rws/schedule/plan_status.resource
Resource            resources/web/rws/driver_forecast/predictive_driver_forecast.resource

Test Teardown       Close Browser

Test Tags    dev:komal    action:write    battc00171    config:predictive_forecasting    bat_phase2    config:weekplan_and_schedule_gen
...    module:forecast


*** Test Cases ***
BATTC00171: Verify user is able to generate predictive forecast, workload and schedule and review the generation process using batch job monitoring
    [Documentation]
    ...    Verifies that a user can generate predictive forecast, workload, and schedule, and review the generation process using batch job monitoring.
    ...    The test covers the complete workflow from forecast initialization through workload generation to schedule creation and cleanup.
    Clear Generated Schedule And Workload On Plan Status Page On Web    SM1_STORE1    4_0
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Predictive Driver Forecast Weekly Plan Page On Web
    ${org_level_store}    Get System Value    OrganizationLevel    UNIT
    ${store_data}    Get Store Data
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    Select Location Type And Location On Predictive Driver Forecast Page On Web    ${org_level_store}
    ...    ${store_data}[store_id] - ${store_data}[store_name]
    ${planned_week}    Select Week Number On Predictive Driver Forecast Page On Web    4_0
    Initialize Forecast On Predictive Driver Forecast Page On Web
    Verify Predictive Forecast Job Is Completed On Admin Batch Jobs Monitor Page On Web
    ...    ${store_data}[store_id] - ${store_data}[store_name]
    Navigate To RWS Labor Forecast Page On Web
    Navigate To The Mentioned Week On Labor Forecast Page On Web    ${planned_week}
    Select Store To Search Workload Values On Labor Forecast Page On Web    ${store_data}[store_name]
    Generate Workload On Labor Forecast Page On Web
    Verify Workload Job Is Completed On Admin Batch Jobs Monitor Page On Web    ${planned_week}    ${store_data}[store_name]
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    Navigate To Mentioned Week On Plan Status Page On Web    ${planned_week}
    Generate Optimized Schedule On Plan Status Page On Web
    Verify If Generate Optimized Schedule Is Completed On Plan Status Page On Web
    Delete Schedule On Plan Status Page On Web
    Delete The Workload On Plan Status Page On Web
    Switch To Home From Store On Web
    Verify Schedule Generation Job Is Completed On Admin Batch Jobs Monitor Page On Web    ${planned_week}    ${store_data}[store_name]
