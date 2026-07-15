*** Settings ***
Documentation       Weekplan generation from CORP Advanced Settings page for distribution lists

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/advanced_settings/advanced_settings.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource
Resource            resources/web/rws/schedule/week_schedule.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags    dev:amol    battc00243    action:write    config:rws    config:schedule_work_pattern_week_mapping
...    config:weekplan_and_schedule_gen


*** Test Cases ***
BATTC00243: Verify weekplan generation from CORP weekplan generation page for a given distribution list
    [Documentation]
    ...    Comprehensive test for weekplan generation lifecycle from CORP Advanced Settings:
    ...    1. Generates Driver Forecast weekplan for 6 weeks ahead
    ...    2. Generates Workload weekplan for 6 weeks ahead
    ...    3. Generates Schedule weekplan for 6 weeks ahead
    ...    4. Verifies workload activities exist on Labor Forecast page
    ...    5. Verifies schedule is published on Week Schedule page
    ...    6. Cleanup: Deletes workload and schedule

    ${weekplan_data}=    Get Advanced Settings Data
    Login And Launch WFM Web App    SYSADMIN

    # Calculate fiscal year from date and fiscal week via API
    ${target_date}=    Calculate Date From Week Day Offset    ${weekplan_data}[week_offset]
    ${fiscal_year}=    Get Fiscal Year For Date    ${target_date}
    ${fiscal_week}=    Get Fiscal Week Number Via API    ${weekplan_data}[week_offset]    SYSADMIN
    VAR    ${store_group}=    ${weekplan_data}[store_group]

    # Generate Driver Forecast
    Navigate To RWS Advanced Settings Page On Web
    ${forecast_data}=    Get Advanced Settings Data
    Set To Dictionary    ${forecast_data}    fiscal_year=${fiscal_year}    fiscal_week=${fiscal_week}
    Generate Weekplan On Advanced Settings Page On Web    ${forecast_data}

    # Generate Workload
    ${workload_data}=    Get Advanced Settings Data
    ...    description=Workload weekplan with delete & generate operation    type=WeekplanType.WORKLOAD
    Set To Dictionary    ${workload_data}    fiscal_year=${fiscal_year}    fiscal_week=${fiscal_week}
    Generate Weekplan On Advanced Settings Page On Web    ${workload_data}

    # Generate Schedule
    ${schedule_data}=    Get Advanced Settings Data
    ...    description=Schedule weekplan with delete & generate operation    type=WeekplanType.SCHEDULE
    Set To Dictionary    ${schedule_data}    fiscal_year=${fiscal_year}    fiscal_week=${fiscal_week}
    Generate Weekplan On Advanced Settings Page On Web    ${schedule_data}

    # Verify workload exists on Labor Forecast page
    Login And Launch WFM Web App    SM2_STORE2
    Navigate To RWS Labor Forecast Page On Web
    Select Week Number On Labor Forecast Page On Web    ${weekplan_data}[week_offset]
    ${wkld_generated}=    Check If Workload Is Generated On Labor Forecast Page On Web
    Should Be True    ${wkld_generated}    msg=Workload not generated

    # Verify schedule is generated on Week Schedule page
    Navigate To RWS Schedule Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${weekplan_data}[week_offset]
    ${schedule_published}=    Check Employees Availablity Post Schedule Generation On Week Schedule Page On Web
    Should Be True    ${schedule_published}    msg=Schedule not published

    [Teardown]    Run Keywords
    ...    Login And Launch WFM Web App    SYSADMIN
    ...    AND    Navigate To RWS Advanced Settings Page On Web
    ...    AND    Run Keyword And Continue On Failure    Delete Generated Weekplans On Advanced Settings Page On Web    ${fiscal_year}    ${fiscal_week}    ${store_group}
    ...    AND    Run Keyword And Ignore Error    Close Browser
