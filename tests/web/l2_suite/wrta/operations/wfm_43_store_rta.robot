*** Settings ***
Documentation       Test suite for verifying accrual plan management functionality in RTA operations module.
...                 This suite contains test cases to validate the creation and verification of accrual plans.

Resource            resources/web/rta/operations/accrual_plan.resource
Resource            resources/web/authentication/login.resource

# Test Teardown    Close Browser
Test Tags    dev:yogesh    battc00050    action:write    config:rta    bat_phase1    config:add_edit_delete_accrual_plan
...    module:timekeeping


*** Test Cases ***
BATTC00050: Verify user is able add/edit/copy/delete accrual plan
    [Documentation]    This test case verifies the functionality of adding, editing, copying, and deleting an accrual plan in the RTA operations module.
    #    RTA-43-1 Verify Whether User Is Able To Add New Accrual Plan
    ${accrual_data}    Get Accrual Plan Data
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RTA HR Accrual Plan Page On Web
    Cleanup Accrual Plans If Exists On Web    ${accrual_data}[id]    ${accrual_data}[new_accrual_plan_id]
    Click Add New Accrual Plan On Web
    Fill Details In Accrual Plan Page On Web    ${accrual_data}[id]    ${accrual_data}[name]
    ...    ${accrual_data}[description]    ${accrual_data}[status]    ${accrual_data}[term_type]    ${accrual_data}[plan_accrual_frequency]
    ...    ${accrual_data}[created_status_code]
    Navigate To RTA HR Accrual Plan Page On Web
    Verify Accrual Page Is Loaded On Web
    Verify Accrual Plan Is Shown In Accrual Plan Page On Web    ${accrual_data}[id]    ${accrual_data}[name]
    ...    ${accrual_data}[status]    ${accrual_data}[description]

    #    RTA-43-2 Verify Whether User Is Able To Edit Existing Accrual Plan
    Edit Accrual Plan Details On Accrual Plan Page On Web    ${accrual_data}[id]    ${accrual_data}[edit_description]
    ...    ${accrual_data}[ok_status_code]
    Navigate To RTA HR Accrual Plan Page On Web
    Verify Accrual Plan Is Shown In Accrual Plan Page On Web    ${accrual_data}[id]
    ...    ${accrual_data}[name]    ${accrual_data}[status]    ${accrual_data}[edit_description]

    #    Copy the created Accrual Plan
    Copy Accrual Plan By ID On Accrual Plan Page On Web    ${accrual_data}[id]    ${accrual_data}[new_accrual_plan_id]
    ...    ${accrual_data}[new_accrual_plan_name]    ${accrual_data}[created_status_code]

    #    RTA-43-3 Verify Whether User Is Able To Delete Existing Accrual Plan
    Navigate To RTA HR Accrual Plan Page On Web
    Verify Accrual Plan Is Shown In Accrual Plan Page On Web    ${accrual_data}[id]    ${accrual_data}[name]
    ...    ${accrual_data}[status]    ${accrual_data}[edit_description]
    Delete Accrual Plan By ID On Web    ${accrual_data}[id]    ${accrual_data}[ok_status_code]
    #    Added logout and login steps as there is some issue in the web app,
    #    some caching happening due to which the browser is getting closed immediately after the click on the delete button.
    #    we can check for solution later
    Log Out From Web Application
    Close Browser
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RTA HR Accrual Plan Page On Web
    Verify Accrual Plan Is Shown In Accrual Plan Page On Web    ${accrual_data}[new_accrual_plan_id]
    ...    ${accrual_data}[new_accrual_plan_name]    ${accrual_data}[status]    ${accrual_data}[edit_description]
    Delete Accrual Plan By ID On Web    ${accrual_data}[new_accrual_plan_id]    ${accrual_data}[ok_status_code]
    Log Out From Web Application
