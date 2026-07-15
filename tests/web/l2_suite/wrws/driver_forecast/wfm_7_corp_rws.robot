*** Settings ***
Documentation       Comprehensive test suite for Driver Forecast operations - Add, Edit, Delete
...                 Tests both Front End and Back End driver workflows with data providers

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/driver_forecast/drivers.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           dev:amol    action:write    config:legacy_forecasting    bat_phase1    config:rws


*** Test Cases ***
BATTC00007: Verify add/edit/delete front end driver
    [Documentation]
    ...    Comprehensive test for Front End Driver lifecycle:
    ...    1. Creates new front end driver with all required fields
    ...    2. Edits the driver type (Actual → Revised)
    ...    3. Deletes the driver and verifies it no longer exists (in teardown)
    [Tags]    battc00007    config:weekplan_and_schedule_gen    module:forecast
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${driver_data}    Get Driver Forecast Data    template_name=front_end
    Navigate To RWS Drivers Page
    Add Front End Driver On Drivers Page On Web    ${driver_data}
    Edit Driver On Drivers Page On Web
    ...    ${driver_data}[description]
    ...    ${driver_data}[updated_forecast_driver_type]
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Clean Up Driver On Drivers Page On Web    ${driver_data}[description]
    ...    AND    Run Keyword And Ignore Error    Close Browser

BATTC00008: Verify add/edit/delete backend driver
    [Documentation]
    ...    Comprehensive test for Back End Driver lifecycle:
    ...    1. Creates new back end driver with calculation method
    ...    2. Edits the driver type (Calculated → Revised)
    ...    3. Deletes the driver and verifies it no longer exists (in teardown)
    [Tags]    battc00008    config:weekplan_and_schedule_gen    module:forecast
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${driver_data}    Get Driver Forecast Data    template_name=back_end
    Navigate To RWS Drivers Page
    Add Back End Driver On Drivers Page On Web    ${driver_data}
    Edit Driver On Drivers Page On Web
    ...    ${driver_data}[description]
    ...    ${driver_data}[updated_forecast_driver_type]
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Clean Up Driver On Drivers Page On Web    ${driver_data}[description]
    ...    AND    Run Keyword And Ignore Error    Close Browser
