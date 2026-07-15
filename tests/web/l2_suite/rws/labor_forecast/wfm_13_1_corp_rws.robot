*** Settings ***
Documentation       Test case to Verify Display Preference On Labor Forecast

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource
Resource            resources/web/rws/labor_forecast/labor_forecast_db.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags    dev:rushikesh    action:read    battc00015    bat_phase1    config:rws    refactoring_required_PC00090
...    config:weekplan_and_schedule_gen    module:forecast


*** Test Cases ***
BATTC00015: Verify display preference in labor forecast
    [Documentation]    Test case to Verify display preference on labor forecast
    ${user}    Get User    user_key=SM1_STORE1
    ${is_workload_available}    Check Workload Exists For Current Week In DB For Unit ID    ${user}[unitID]
    Skip If    not ${is_workload_available}    No workload found for unit ${user}[unitID] in current fiscal week - skipping.
    Login And Launch WFM Web App    ${user}[user_key]
    Navigate To RWS Labor Forecast Page On Web
    ${is_week_in_progress_present}    Check If Week In Progress State For Labor Forecast Page On Web
    Skip If    '${is_week_in_progress_present}'=='False'    Week In Progress state is not present, skipping the test steps.
    Click On Display Preference Icon On Labor Forecast Page On Web
    Set Display Preference With Short Name On Labor Forecast Page On Web
    Verify Display Preference With Short Name Is Visible On Labor Forecast Page On Web
    Reset Display Preference On Labor Forecast Page On Web
