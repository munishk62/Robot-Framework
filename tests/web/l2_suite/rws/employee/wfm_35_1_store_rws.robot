*** Settings ***
Documentation       Test case for verifying Add/Edit/Delete Availability On Roster Page

Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/authentication/login.resource
Resource            resources/Mobile/ESS/PagesResources/Availability_Module/Availability_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up Permanent Availability Request    ESS4_STORE1    SM1_STORE1    2_0    AND
...                     Close Browser

Test Tags    dev:yogesh    action:write    battc00044    bat_phase1    config:add_edit_delete_availability_request_sm    config:rws
...    bug_reported    bug_id:wfm-127796    bug_id:wfm-130315    om_hr


*** Test Cases ***
BATTC00044: Verify add/edit/delete availability in roster
    [Documentation]    Test case for verifying Add/Edit/Delete Availability On Roster Page
    ${ess_user_4}    Get User    user_key=ESS4_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Roster Page On Web
    Click On Associate On Roster Page On Web    ${ess_user_4}[displayName]
    Navigate To Availability Requests Page On Roster Page On Web
    ${availability_data}    Get Availability Data    start_date=2_0
    Add Availability Request On Roster Page On Web
    ...    ${availability_data}[start_date]    ${availability_data}[status]    ${availability_data}[reason]
    ...    ${availability_data}[days_availability_hours]    ${availability_data}[split_availability_row_number]
    ...    ${availability_data}[availability_rotation_number]
    Save Availability Request On Roster Page On Web
    ${edit_availability_data}    Get Availability Data    template_name=edit_availability
    Edit Availability Request On Roster Page On Web    ${availability_data}[start_date]
    ...    ${edit_availability_data}[days_availability_hours]    ${edit_availability_data}[split_availability_row_number]
    ...    ${availability_data}[availability_rotation_number]
    Delete Availability Request On Roster Page On Web    ${availability_data}[start_date]
    ${emp_rotation_enabled}    Get Config Value    EMP_AVL_ROTATION
    ${staff_rotation_enabled}    Get Config Value    STAFF_ROTATION
    IF    '${emp_rotation_enabled}' == 'Y' and '${staff_rotation_enabled}' == 'Y'
        ${rotation_availability_data_1}    Get Availability Data    template_name=add_availability_rotation_1
        ${rotation_availability_data_2}    Get Availability Data    template_name=add_availability_rotation_2
        Add Availability Request On Roster Page On Web
        ...    ${availability_data}[start_date]    ${availability_data}[status]    ${availability_data}[reason]
        ...    ${rotation_availability_data_1}[days_availability_hours]    ${availability_data}[split_availability_row_number]
        ...    ${rotation_availability_data_1}[rotation_number]    total_rotations=${rotation_availability_data_2}[availability_rotation_number]
        Add Availability Hours On Roster Page On Web    ${rotation_availability_data_2}[days_availability_hours]
        ...    ${availability_data}[split_availability_row_number]    ${rotation_availability_data_2}[availability_rotation_number]
        Save Availability Request On Roster Page On Web
        Delete Availability Request On Roster Page On Web    ${availability_data}[start_date]
    END
