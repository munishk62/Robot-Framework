*** Settings ***
Documentation       Test case for verifying All Mandatory Fields For Driver Creation

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/driver_forecast/drivers.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:write    battc00009    config:legacy_forecasting    bat_phase1    module:forecast


*** Test Cases ***
BATTC00009: Verify saving of driver with and without data for mandatory fields
    [Documentation]    Test case for verifying all mandatory fields for driver creation
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${driver_forecast_data}    Get Driver Forecast Data
    Navigate To RWS Drivers Page
    Click On Add Button To Add Driver
    ${driver_description}    Fill Mandatory Driver Fields
    ...    ${driver_forecast_data}[forecast_driver_type]    ${driver_forecast_data}[driver_group]
    ...    ${driver_forecast_data}[driver_granularity]    ${driver_forecast_data}[adjustment_mode]
    ...    ${driver_forecast_data}[aggregate_rule]    ${driver_forecast_data}[display_format]
    Click On Save Button
    Verify Driver Alert Message Displayed
    Fill Driver Code Field
    Click On Save Button
    Verify Driver Success Message Displayed
    Delete The Created Driver    ${driver_description}
    Verify Driver Success Message Displayed
