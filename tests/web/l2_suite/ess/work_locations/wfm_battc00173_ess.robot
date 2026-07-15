*** Settings ***
Documentation       Verify user is able to add/edit/delete alternate location requests.

Resource            resources/web/authentication/login.resource
Resource            resources/web/employee/criteria_configuration.resource
Resource            resources/web/ess/work_locations.resource
Resource            resources/web/ess/work_locations_db.resource

Suite Teardown      Close Browser

Test Tags    battc00173    config:rws    config:ess    config:ess_alternate_work_location    bat_phase2    dev:amol
...    config:weekplan_and_schedule_gen    om_hr


*** Test Cases ***
BATTC00173: Verify user is able to add/edit/delete alternate location requests
    [Documentation]    This test verifies that an ESS user can add, edit, and delete alternate work location requests
    ...    after the necessary criteria configuration is set up by a SYSADMIN.
    ${alternate_work_location_feature_enabled}    Check If Alternate Work Location Feature Enabled For Store In DB
    Skip If    not ${alternate_work_location_feature_enabled}
    ...    msg=Alternate work location feature is not enabled for the store, skipping the test execution.
    ${criteria_data}    Get Criteria Configuration Data
    ${is_share_requests_applicable}    Check If Store Has Alternate Work Location Share Requests In DB    ${criteria_data}[unit]    ${criteria_data}[eff_date]    ${criteria_data}[end_date]
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Employee Criteria Configuration Page On Web
    Delete Criteria If Exists On Criteria Configuration Page On Web    ${criteria_data}[name]
    Add Criteria On Criteria Configuration Page On Web    ${criteria_data}
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS2_STORE2
    Navigate To ESS Work Locations Page On Web
    ${alternate_work_location_data}    Get Alternate Work Location Data
    Delete Alternate Work Location If Exists On Web    ${alternate_work_location_data}[description]
    Delete Alternate Work Location If Exists On Web    ${alternate_work_location_data}[edit_description]
    IF    not ${is_share_requests_applicable}
        Add Alternate Work Location Request On Web    ${alternate_work_location_data}
        Edit Alternate Work Location Request On Web
        ...    old_alt_work_loc_desc=${alternate_work_location_data}[description]
        ...    new_alt_work_loc_desc=${alternate_work_location_data}[edit_description]
        Delete Alternate Work Location Request On Web
        ...    alt_work_loc_desc=${alternate_work_location_data}[edit_description]
    END
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Employee Criteria Configuration Page On Web
    Delete Criteria On Criteria Configuration Page On Web    ${criteria_data}[name]
