*** Settings ***
Documentation       Test case to Verify advanced filter preference in labor forecast

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource
Resource            resources/web/rws/labor_forecast/labor_forecast_db.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           dev:rushikesh    action:read    battc00017    bat_phase1    config:rws
...                 config:weekplan_and_schedule_gen    module:forecast


*** Test Cases ***
BATTC00017: Verify advanced filter preference in labor forecast
    [Documentation]    Test case to Verify advanced filter preference in labor forecast
    ${is_workload_present_for_3_staff_groups}    Check Workload Is Present For Activities For At Least Three Staff Groups From User In DB
    ...    user_key=SM1_STORE1
    Skip If    '${is_workload_present_for_3_staff_groups}'=='False'
    ...    No workload present for activities from at least 3 staff groups for the user, skipping the test steps.
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Labor Forecast Page On Web
    ${schedule_data}    Get Schedule Generation Setup Data    template_name=1_0_sm1_store1
    Select Week Number On Labor Forecast Page On Web    ${schedule_data}[week_start_date]
    ${is_week_in_progress_present}    Check If Week In Progress State For Labor Forecast Page On Web
    Skip If    '${is_week_in_progress_present}'=='False'    Week In Progress state is not present, skipping the test steps.
    ${activity_count_before_filter}    Get Count Of Task Name On Labor Forecast Page On Web
    ${option1}    ${option2}    Get Two Random Activities From Labor Forecast Page On Web
    Capture Screenshot On Webpage
    ${total_hr_before_filter}    Get Total Hours On Labor Forecast Page On Web
    Click On Advance Filter Settings Tab On Labor Forecast Page On Web
    Select Activity In Advanced Filter On Labor Forecast Page On Web    ${option1}    ${option2}
    Click On Advance Filter Apply Button On Labor Forecast Page On Web

    ${activity_count_on_filter}    Get Count Of Task Name On Labor Forecast Page On Web

    ${filter_result}    Evaluate    ${activity_count_on_filter} == 0

    IF    ${filter_result}
        Fail    No task scheduled for the selected activity: ${option1}, ${option2}, to be checked manually
    END
    Should Be True    ${activity_count_on_filter} > 0    There should be some task scheduled for the selected activities
    Should Be True    ${activity_count_on_filter} < ${activity_count_before_filter}
    ...    Filtered activity count should be less than total activity count

    Reset The Advance Filter Settings On Labor Forecast Page On Web
    ${activity_count_on_filter_reset}    Get Count Of Task Name On Labor Forecast Page On Web
    ${total_hr_on_filter_reset}    Get Total Hours On Labor Forecast Page On Web

    Should Be Equal As Numbers    ${activity_count_before_filter}    ${activity_count_on_filter_reset}
    Should Be Equal    ${total_hr_before_filter}    ${total_hr_on_filter_reset}
