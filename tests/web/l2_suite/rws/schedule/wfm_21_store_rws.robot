*** Settings ***
Documentation       This test suite verifies if user is able to generate the schedule using templates based on
...                 work pattern mapping. It also verifies if user is not able to generate schedule if work pattern is not mapped.

Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/all_schedules.resource
Resource            resources/web/rws/schedule/plan_status.resource
Resource            resources/web/rws/schedule/fixed_shifts.resource
Resource            resources/web/rws/schedule/batch_plan_status.resource
Resource            resources/web/roster/template_calendar.resource
Library             test_data/TestDataLibrary.py

Test Setup          Login As Sysadmin And Clean Work Pattern Mapping For Week On Web    8_0

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:write    battc00025    bat_phase1    config:rws    config:weekplan_and_schedule_gen


*** Test Cases ***
BATTC00025: Verify user is not able to generate template schedule when the work pattern is not mapped for the week
    [Documentation]    Test case for verifying whether user is able to not generate schedule via template
    ...    when work pattern is not mapped
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    ${batch_plan_data}=    Get Batch Plan Data    template_name=not_mapped_template
    VAR    ${planning_week_start_date}    ${batch_plan_data}[week_start_date]
    # Calculate fiscal year from planning week start date
    ${actual_date}=    Calculate Date From Week Day Offset    ${planning_week_start_date}
    ${year_format}=    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${fiscal_year}=    Convert Date    ${actual_date}    result_format=${year_format}
    # Calculate fiscal week number from week offset for verification
    ${fiscal_week_number}=    Calculate Fiscal Week Number From Week Day Offset    ${planning_week_start_date}
    Log    Planning week offset: ${planning_week_start_date}, Date: ${actual_date}, Fiscal Week: ${fiscal_week_number}
    # Verify work pattern for the specific week is not mapped using resolved store ID
    # Note: dist_list_id should match the store's distribution list ID in RWS_CALENDAR_ATTR table
    ${store_data}=    Get Store Data
    ${work_pattern_by_week}=    Get Work Pattern By Week Via DB    ${store_data}[store_id]    ${fiscal_year}    ${fiscal_week_number}
    # Skip test if work pattern is already mapped - test requires unmapped state
    Skip If    '${work_pattern_by_week}' != 'NONE'    Work pattern '${work_pattern_by_week}' is already mapped for week ${fiscal_week_number}. Skipping test - requires unmapped state.
    Log    Confirmed: No work pattern mapped for week offset ${planning_week_start_date} (Fiscal Week ${fiscal_week_number})
    Select Week Number On Week Schedule Page On Web    ${planning_week_start_date}
    Navigate To Plan Status Page From Week Schedule Page On Web
    Clear Existing Generated Data On Batch Plan Status Page On Web
    Check Status And Generate Week Plan Forecast On Web    ${batch_plan_data}[regenerate_forecast_required]
    Check Status Generate Workload On Web
    Verify Generate Schedule Using Template Failed Message On Plan Status Page On Web
    Delete Workload On Web
