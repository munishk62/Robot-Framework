*** Settings ***
Documentation       Verify export, edit, and re-export workflow for Driver Forecast data.
...
...                 This test validates that:
...                 - Forecast data can be exported to CSV
...                 - Forecast values can be updated in UI
...                 - Updated values are correctly reflected in the UI after editing

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/driver_forecast/driver_forecast.resource
Resource            resources/web/rws/driver_forecast/driver_forecast_db.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags    dev:amol    action:write    battc00005    config:legacy_forecasting    bat_phase1    config:rws
...    config:weekplan_and_schedule_gen    module:forecast


*** Test Cases ***
BATTC00005: Verify editing of legacy forecasted data and exporting them
    [Documentation]
    ...    Test validates the workflow of exporting forecast data, editing values,
    ...    and verifying the updated values are correctly reflected in the UI.
    ...    The test dynamically discovers the first eligible driver at runtime and supports
    ...    two scenarios: with export functionality (CSV export only, no data validation) or without (UI-only validation).
    ...    Note: Test is skipped if executed on the last day of the fiscal week to avoid data issues.

    VAR    ${FORECAST_CSV_DOWNLOAD_PATH}    Downloads/forecast_data_initial.csv
    VAR    ${FORECAST_CSV_UPDATED_DOWNLOAD_PATH}    Downloads/forecast_data_updated.csv

    ${dual_scheduling_flow_constraint}    Get Dual Scheduling Flow Constraint Type From Database
    IF    '${dual_scheduling_flow_constraint}' == 'S'
        Skip    Dual scheduling flow is set to Strict (CONSTRAINT_TYPE=S). Skipping test.
    END

    Skip Test If Today Is Last Day Of Fiscal Week
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Driver Forecast Forecast Page On Web

    ${eligible_driver_details}    Find First Eligible Driver From Driver Forecast Page On Web
    VAR    ${driver_name}    ${eligible_driver_details}[driver_name]
    VAR    ${driver_id}    ${eligible_driver_details}[driver_id]

    ${threshold_met}    Retrieve Forecast Threshold From Database    ${driver_id}
    Skip If    not ${threshold_met}    Skipping edit: threshold not met for driver ${driver_name} (id=${driver_id})

    &{initial_forecast_data}    Get STF Adjusted Values For Driver On Driver Forecast Page On Web    ${driver_name}    ${driver_id}
    IF    '${initial_forecast_data}[day_value]' == '' or '${initial_forecast_data}[totals_value]' == ''
        Capture Screenshot On Webpage
        Skip    No forecast values found for ${driver_name} on the forecast page
    END
    ${is_export_functionality_available}    Is Export To Excel Option Available On Driver Forecast Page On Web
    IF    ${is_export_functionality_available}
        VAR    ${base_dir}    ${EXECDIR}
        VAR    ${initial_csv_path}    ${base_dir}${/}${FORECAST_CSV_DOWNLOAD_PATH}

        ${initial_csv_file}    Export Driver Forecast Data To CSV    ${initial_csv_path}

        IF    '${initial_csv_file}' == '${None}'
            Capture Screenshot On Webpage
            Skip    Export icon visible but export operation failed for forecast page
        END
        ${updated_saturday_value}    Update STF Adjusted Value On Driver Forecast Page On Web    ${driver_name}    ${driver_id}
        Navigate To RWS Driver Forecast Forecast Page On Web
        &{updated_forecast_data}    Get STF Adjusted Values For Driver On Driver Forecast Page On Web    ${driver_name}    ${driver_id}
        VAR    ${updated_csv_path}    ${base_dir}${/}${FORECAST_CSV_UPDATED_DOWNLOAD_PATH}
        Export Driver Forecast Data To CSV    ${updated_csv_path}

        Verify Driver Forecast Values Updated Successfully On Web    ${initial_forecast_data}    ${updated_forecast_data}
        Verify Updated STF Adjusted Value Matches As Per Increased Value    ${updated_forecast_data}[day_value]
        ...    ${updated_saturday_value}
        Revert STF Adjusted Value On Driver Forecast Page On Web    ${driver_name}    ${driver_id}    ${initial_forecast_data}[day_value]
    ELSE
        VAR    ${original_saturday_value}    ${initial_forecast_data}[day_value]
        ${updated_saturday_value}    Update STF Adjusted Value On Driver Forecast Page On Web    ${driver_name}    ${driver_id}
        Navigate To RWS Driver Forecast Forecast Page On Web
        &{updated_forecast_data}    Get STF Adjusted Values For Driver On Driver Forecast Page On Web    ${driver_name}    ${driver_id}

        Verify Driver Forecast Values Updated Successfully On Web    ${initial_forecast_data}    ${updated_forecast_data}
        Verify Updated STF Adjusted Value Matches As Per Increased Value    ${updated_forecast_data}[day_value]
        ...    ${updated_saturday_value}
        Revert STF Adjusted Value On Driver Forecast Page On Web    ${driver_name}    ${driver_id}    ${original_saturday_value}
    END
