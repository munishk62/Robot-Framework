*** Settings ***
Documentation       This test suite verifies if the user is able to view week level and day level workload values for
...                 the target unit from the Corp as well as from the unit itself.
...                 Workload values to be checked from Labor Forecast menu.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource
Resource            resources/web/rws/labor_forecast/labor_forecast_db.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:read    bat_phase1    config:rws


*** Test Cases ***
BATTC00012: Verify workload values from CORP for week level and daily level
    [Documentation]    Test case for verifying whether user is able to view week level and day level
    ...    workload values for the target unit from the Corp
    [Tags]    battc00012    config:weekplan_and_schedule_gen    module:forecast
    ${store_data}    Get Store Data
    ${is_workload_available}    Check Workload Exists For Next Week In DB For Unit ID    ${store_data}[store_id]
    Skip If    not ${is_workload_available}    No workload found for store ${store_data}[store_id] in next fiscal week - skipping.
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Labor Forecast Page On Web
    Select Week And Store On Labor Forecast Page On Web    1_0    ${store_data}[store_id]
    ${is_workload_value_present}    Check If Workload Is Generated On Labor Forecast Page On Web
    IF    ${is_workload_value_present}
        ${day_index_with_wkld_value}    Get Day Index With Workload Hours On Labor Forecast Page On Web
        ${weekview_total_hrs}    Get Week View Workload Hours For Day On Labor Forecast Page On Web
        ...    ${day_index_with_wkld_value}
        ${weekview_day_label}    Open The Day View In Selected Week On Labor Forecast Page On Web    ${day_index_with_wkld_value}
        ${dayview_total_hrs}
        ...    ${dayview_day_label}
        ...    Get Day View Workload Hours And Label On Labor Forecast Page On Web
        Should Be Equal As Strings    ${weekview_day_label}    ${dayview_day_label}
        ...    Day to be checked doesn't match between Week view and Day view.
        Should Be Equal As Strings    ${weekview_total_hrs}    ${dayview_total_hrs}
        ...    Total Hours for the selected day doesn't match between Week view and Day View.
    ELSE
        Skip    No workload values found for the selected unit for Future week.
    END

BATTC00013: Verify workload values from store for week level and daily level
    [Documentation]    Test case for verifying whether user is able to view week level and day level
    ...    workload values from the Store
    [Tags]    battc00013    config:weekplan_and_schedule_gen    module:forecast
    ${store_data}    Get Store Data
    ${is_workload_available}    Check Workload Exists For Next Week In DB For Unit ID    ${store_data}[store_id]
    Skip If    not ${is_workload_available}    No workload found for store ${store_data}[store_id] in next fiscal week - skipping.
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Labor Forecast Page On Web
    Select Week Number On Labor Forecast Page On Web    1_0
    ${is_workload_value_present}    Check If Workload Is Generated On Labor Forecast Page On Web
    IF    ${is_workload_value_present}
        ${day_index_with_wkld_value}    Get Day Index With Workload Hours On Labor Forecast Page On Web
        ${weekview_total_hrs}    Get Week View Workload Hours For Day On Labor Forecast Page On Web
        ...    ${day_index_with_wkld_value}
        ${weekview_day_label}    Open The Day View In Selected Week On Labor Forecast Page On Web    ${day_index_with_wkld_value}
        ${dayview_total_hrs}
        ...    ${dayview_day_label}
        ...    Get Day View Workload Hours And Label On Labor Forecast Page On Web
        Should Be Equal As Strings    ${weekview_day_label}    ${dayview_day_label}
        ...    Day to be checked doesn't match between Week view and Day view.
        Should Be Equal As Strings    ${weekview_total_hrs}    ${dayview_total_hrs}
        ...    Total Hours for the selected day doesn't match between Week view and Day View.
    ELSE
        Skip    No workload values found for the selected unit for Future week.
    END
