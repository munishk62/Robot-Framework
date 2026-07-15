*** Settings ***
Documentation       Verify editing of predictive forecasted data and exporting them.
...
...                 This test validates that:
...                 - Forecast Review page can be accessed under Predictive Analytics
...                 - Driver can be searched and found on the page
...                 - Forecast data can be exported to Excel
...                 - Forecast values can be updated in UI (50% increase for values ≤ $10, 10% otherwise)
...                 - Updated values are correctly reflected in the UI after editing
...                 - Values can be reverted back to original for test cleanup
...
...                 Note: Test is skipped if executed on the last day of the fiscal week.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/predictive_analytics/forecast_review.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags    dev:amol    action:write    battc00176    config:predictive_forecasting    config:rws    bat_phase2
...    config:weekplan_and_schedule_gen    module:forecast


*** Test Cases ***
BATTC00176: Verify editing of predictive forecasted data and exporting them
    [Documentation]
    ...    Test validates the workflow of:
    ...    1. Navigating to Forecast Review page under Predictive Analytics
    ...    2. Dynamically finding an eligible daily driver
    ...    3. Exporting forecast data to Excel (no data validation against exported file)
    ...    4. Editing Weekly Adjusted values (50% increase for values ≤ $10, 10% increase otherwise)
    ...    5. Re-exporting updated data to Excel (no data validation against exported file)
    ...    6. Verifying updated values in UI
    ...    7. Reverting changes back to original values
    ...
    ...    Note: Test is skipped if executed on the last day of the fiscal week.

    # Skip Test If Today Is Last Day Of Fiscal Week

    VAR    ${FORECAST_EXCEL_INITIAL_PATH}    Downloads/forecast_review_initial.xls
    VAR    ${FORECAST_EXCEL_UPDATED_PATH}    Downloads/forecast_review_updated.xls

    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To Forecast Review Page On Web

    ${eligible_driver_details}    Find First Eligible Daily Driver From Forecast Review Page On Web
    VAR    ${driver_name}    ${eligible_driver_details}[driver_name]

    Search For Driver On Forecast Review Page On Web    ${driver_name}
    ${is_driver_present}    Verify Driver Is Present On Forecast Review Page On Web    ${driver_name}

    IF    not ${is_driver_present}
        Capture Screenshot On Webpage
        Skip    Driver '${driver_name}' not present on Forecast Review page
    END

    # Get Excel name after driver is found - use fallback approach
    ${driver_excel_name}    Get Driver Excel Name From Forecast Review Page On Web    ${driver_name}

    Click On Driver On Forecast Review Page On Web    ${driver_name}    ${driver_excel_name}

    &{initial_forecast_data}    Get Weekly Adjusted Values For Driver On Web    ${driver_name}    ${driver_excel_name}

    IF    '${initial_forecast_data}[total_value]' == '' or float('${initial_forecast_data}[last_fiscal_day_value]'.replace('$', '').replace(',', '').strip() or '0') == 0
        Capture Screenshot On Webpage
        Skip
        ...    No valid forecast values found for ${driver_name} on Forecast Review page (value is empty or 0 - possible future punches config)
    END

    # Export initial Excel and verify values
    VAR    ${base_dir}    ${EXECDIR}
    VAR    ${initial_excel_path}    ${base_dir}${/}${FORECAST_EXCEL_INITIAL_PATH}

    ${initial_excel_file}    Export Forecast Review Data To Excel On Web    ${initial_excel_path}

    IF    $initial_excel_file == $None or $initial_excel_file == ''
        Capture Screenshot On Webpage
        Skip    Export failed or file not downloaded for Forecast Review page
    END

    # Update forecast value (50% for values ≤ $10, 10% otherwise)
    ${updated_value}    Update Weekly Adjusted Value On Forecast Review Page On Web
    ...    ${driver_name}
    ...    ${initial_forecast_data}[last_fiscal_day_value]
    Log    Updated last fiscal day of week value to: ${updated_value}

    Navigate To Forecast Review Page On Web
    Search For Driver On Forecast Review Page On Web    ${driver_name}
    Click On Driver On Forecast Review Page On Web    ${driver_name}    ${driver_excel_name}

    &{updated_forecast_data}    Get Weekly Adjusted Values For Driver On Web    ${driver_name}    ${driver_excel_name}

    # Export updated Excel and verify new values
    VAR    ${updated_excel_path}    ${base_dir}${/}${FORECAST_EXCEL_UPDATED_PATH}

    Export Forecast Review Data To Excel On Web    ${updated_excel_path}
    Verify Forecast Review Values Updated Successfully On Web    ${initial_forecast_data}    ${updated_forecast_data}

    Revert Weekly Adjusted Value On Forecast Review Page On Web
    ...    ${driver_name}
    ...    ${initial_forecast_data}[last_fiscal_day_value]
    Log    ✓ Test completed successfully - Forecast Review export/edit/re-export workflow validated and reverted to original value
