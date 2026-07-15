*** Settings ***
Documentation       Week 9 - SM1_STORE2 Schedule Suite (Mobile)
...
...                 **PURPOSE:**
...                 This suite consolidates all mobile test cases that require Week 9 schedule data for Store2.
...
...                 **TEST CASES INCLUDED:**
...                 - BATTC00222: Verify shift copy/move/reassign/swap operations
...                 - BATTC00223: Verify open shift add/edit/copy/move/delete operations
...                 - BATTC00204: Verify manager can assign open shift to associate

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Store_Schedule.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Shift_Details.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_Open_Shifts.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 9 SM1Store2
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           week9_sm1store2    bat_phase2    schedule_dependent
...    config:mobile_sm_enabled


*** Test Cases ***
BATTC00222: Verify user is able to perform copy/move/reassign/swap shift operations in mobility
    [Documentation]    Verify user is able to perform copy/move/reassign/swap shift operations in mobility.
    [Tags]    dev:bushra    battc00222    mobile    config:rws    config:weekplan_and_schedule_gen    checkschedulesetup
    Open SM Native Application On Mobile Phone    battc00222
    ${ess_user4}    Get User    user_key=ESS4_STORE2
    ${ess_user5}    Get User    user_key=ESS5_STORE2

    ${shift_data}    Get Shift Data    template_name=verify_shift_operations
    Login SM App On Mobile    SM1_STORE2
    # add shift for user4 to have shifts to copy/move/reassign
    Navigate To Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    ${shift_data}[add_first_shift_start_date]
    Select Shift On Date For Associate On Store Schedule Page On SM Phone App    ${ess_user4}[displayName]
    ...    ${shift_data}[add_first_shift_start_date]
    Add Shift On Selected Date Details Page On SM Phone App    ${shift_data}[add_first_shift_start_time]
    ...    ${shift_data}[add_first_shift_end_time]    ${shift_data}[task_name]
    Verify Shift Saved Successfully On SM Phone App
    # Add shift for user5 to have shifts for both users to perform copy/move operations
    Navigate To Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    ${shift_data}[add_second_shift_start_date]
    Select Shift On Date For Associate On Store Schedule Page On SM Phone App    ${ess_user5}[displayName]
    ...    ${shift_data}[add_second_shift_start_date]
    Add Shift On Selected Date Details Page On SM Phone App    ${shift_data}[add_second_shift_start_time]
    ...    ${shift_data}[add_second_shift_end_time]    ${shift_data}[task_name]
    Verify Shift Saved Successfully On SM Phone App
    # Copy shift added on day 9_2 to day 9_3 and 9_4 for user 4
    Select Shift On Store Schedule Page On SM Phone App    ${ess_user4}[displayName]    ${shift_data}[copy_shift_from_date]
    ...    ${shift_data}[add_first_shift_start_time]    ${shift_data}[add_first_shift_end_time]
    VAR    @{days_to_copy_shift}    ${shift_data}[copy_shift_to_date_first]    ${shift_data}[copy_shift_to_date_second]
    Copy Shift To Target Associate On SM Phone App    ${ess_user4}[displayName]    @{days_to_copy_shift}
    Verify Shift Visible On Store Schedule Page On SM Phone App    ${ess_user4}[displayName]    ${shift_data}[copy_shift_to_date_first]
    ...    ${shift_data}[add_first_shift_start_time]    ${shift_data}[add_first_shift_end_time]
    Verify Shift Visible On Store Schedule Page On SM Phone App    ${ess_user4}[displayName]    ${shift_data}[copy_shift_to_date_second]
    ...    ${shift_data}[add_first_shift_start_time]    ${shift_data}[add_first_shift_end_time]
    # Move shift from day 9_4 to day 9_2 for user5
    VAR    @{days_to_move_shift}    ${shift_data}[move_shift_to_date]
    Select Shift On Store Schedule Page On SM Phone App    ${ess_user5}[displayName]    ${shift_data}[move_shift_from_date]
    ...    ${shift_data}[add_second_shift_start_time]    ${shift_data}[add_second_shift_end_time]
    Move Shift To Target Associate On SM Phone App    ${ess_user5}[displayName]    @{days_to_move_shift}
    Verify Shift Visible On Store Schedule Page On SM Phone App    ${ess_user5}[displayName]    ${shift_data}[move_shift_to_date]
    ...    ${shift_data}[add_second_shift_start_time]    ${shift_data}[add_second_shift_end_time]
    # Reassign shift for user4 from day 9_3 to user5 to 9_3
    Select Shift On Date For Associate On Store Schedule Page On SM Phone App    ${ess_user4}[displayName]
    ...    ${shift_data}[reassign_shift_from_date]
    Reassign Shift To Target Associate On SM Phone App    ${ess_user5}[displayName]
    Verify Shift Visible On Store Schedule Page On SM Phone App    ${ess_user5}[displayName]    ${shift_data}[reassign_shift_to_date]
    ...    ${shift_data}[add_first_shift_start_time]    ${shift_data}[add_first_shift_end_time]
    # Swap shift from user5 on 9_2 to user4 on 9_2
    Select Shift On Date For Associate On Store Schedule Page On SM Phone App    ${ess_user5}[displayName]
    ...    ${shift_data}[swap_shift_from_date]
    Swap Shift To Target Associate On SM Phone App    ${ess_user4}[displayName]
    Verify Shift Visible On Store Schedule Page On SM Phone App    ${ess_user4}[displayName]    ${shift_data}[swap_shift_to_date]
    ...    ${shift_data}[add_second_shift_start_time]    ${shift_data}[add_second_shift_end_time]

    [Teardown]    Teardown Test Case    battc00222

BATTC00223: Verify user is able to perform add/edit/copy/move/delete open shift operations in mobility
    [Documentation]    Verify user is able to perform add/edit/copy/move/delete open shift operations in mobility.
    [Tags]    dev:bushra    battc00223    mobile    config:rws    config:weekplan_and_schedule_gen
    ${add_edit_open_shift_template}    Get Open Shift Data    template_name=add_edit_open_shift_mobile
    ${ess4_store2}    Get User    user_key=ESS4_STORE2
    ${shift_delete_offset}    Combine Week Offset And Day No    ${add_edit_open_shift_template}[week_day_offset]
    ...    ${add_edit_open_shift_template}[shift_to_delete_day][0]
    Open SM Native Application On Mobile Phone    battc00223
    Login SM App On Mobile    SM1_STORE2
    Navigate To My Store Page On SM Phone App
    Add Open Shift On My Store Page On SM Phone App    ${add_edit_open_shift_template}[week_day_offset]
    ...    ${add_edit_open_shift_template}
    Edit Shift On Open Shifts Page On SM Phone App    ${add_edit_open_shift_template}[week_day_offset]
    ...    ${add_edit_open_shift_template}[staff_group]    ${add_edit_open_shift_template}[start_time]
    ...    ${add_edit_open_shift_template}[end_time]    ${add_edit_open_shift_template}[edit_start_time]
    ...    ${add_edit_open_shift_template}[edit_end_time]
    ${copy_to_date_offset}    Combine Week Offset And Day No    ${add_edit_open_shift_template}[week_day_offset]
    ...    ${add_edit_open_shift_template}[copy_to_day][0]
    VAR    @{days_to_copy_shift}    ${copy_to_date_offset}
    Copy Shift To Selected Day For My Store On SM Phone App    @{days_to_copy_shift}
    Navigate Back On SM Phone App
    Verify Open Shift Is Displayed On Open Shift Page On SM Phone App    ${copy_to_date_offset}
    ...    ${add_edit_open_shift_template}[edit_start_time]    ${add_edit_open_shift_template}[edit_end_time]
    ...    ${add_edit_open_shift_template}[staff_group]
    Assign Open Shift To Associate On SM Phone App    ${add_edit_open_shift_template}[week_day_offset]    ${ess4_store2}[displayName]
    ...    ${add_edit_open_shift_template}[staff_group]    ${add_edit_open_shift_template}[edit_start_time]
    ...    ${add_edit_open_shift_template}[edit_end_time]
    Unallocate Shift For Associate On Store Schedule Page On SM Phone App    ${add_edit_open_shift_template}[week_day_offset]
    ...    ${ess4_store2}[displayName]    ${add_edit_open_shift_template}[edit_start_time]
    ...    ${add_edit_open_shift_template}[edit_end_time]
    Navigate To My Store Page On SM Phone App
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${add_edit_open_shift_template}[week_day_offset]
    Click Open Shifts Section On My Store Page On SM Phone App
    ${move_to_date_offset}    Combine Week Offset And Day No    ${add_edit_open_shift_template}[week_day_offset]
    ...    ${add_edit_open_shift_template}[move_to_day][0]
    VAR    @{days_to_move_shift}    ${move_to_date_offset}
    ${move_from_day}    Combine Week Offset And Day No    ${add_edit_open_shift_template}[week_day_offset]
    ...    ${add_edit_open_shift_template}[move_from_day][0]
    Select Shift On Open Shift Page On SM Phone App    ${move_from_day}    ${add_edit_open_shift_template}[edit_start_time]
    ...    ${add_edit_open_shift_template}[edit_end_time]    ${add_edit_open_shift_template}[staff_group]
    Move Shift To Selected Day For My Store On SM Phone App    @{days_to_move_shift}
    Verify Open Shift Is Displayed On Open Shift Page On SM Phone App    ${move_to_date_offset}
    ...    ${add_edit_open_shift_template}[edit_start_time]    ${add_edit_open_shift_template}[edit_end_time]
    ...    ${add_edit_open_shift_template}[staff_group]
    Delete All Matching Open Shifts On Open Shift Details Page On SM Phone App    ${shift_delete_offset}
    ...    ${add_edit_open_shift_template}[edit_start_time]    ${add_edit_open_shift_template}[edit_end_time]
    ...    ${add_edit_open_shift_template}[staff_group]

    [Teardown]    Teardown Test Case    battc00223

BATTC00204: Verify Manager is able to assign open shift to an associate in mobility
    [Documentation]    Verifies that SM user can assign open shift to an associate from My Store page
    [Tags]    action:write    dev:moiz    battc00204    mobile    config:rws    config:weekplan_and_schedule_gen
    Open SM Native Application On Mobile Phone    tc_id=battc00204
    ${open_shift_assignment_template}    Get Open Shift Data    week_day_offset=9_4
    ${ess1_store2}    Get User    user_key=ESS1_STORE2
    Login SM App On Mobile    SM1_STORE2
    Navigate To My Store Page On SM Phone App
    Add Open Shift On My Store Page On SM Phone App    ${open_shift_assignment_template}[week_day_offset]
    ...    ${open_shift_assignment_template}
    Assign Open Shift To Associate On SM Phone App    ${open_shift_assignment_template}[week_day_offset]    ${ess1_store2}[displayName]
    ...    ${open_shift_assignment_template}[staff_group]    ${open_shift_assignment_template}[start_time]
    ...    ${open_shift_assignment_template}[end_time]

    [Teardown]    Teardown Test Case    battc00204
