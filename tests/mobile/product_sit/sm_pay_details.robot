*** Settings ***
Documentation       BATTC00241 - Verify pay details for SM user in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/More/More.resource
Resource            resources/Mobile/SM/PagesResources/Timecard/Timecard_Add.resource
Resource            resources/Mobile/SM/PagesResources/Timecard/Exception_Management_Page.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           bat_phase2    dev:bushra    battc00241    mobile    config:rta    config:rws    config:sm_wage_display
...    config:mobile_sm_enabled


*** Test Cases ***
BATTC00241: Verify pay details for SM user in mobility
    [Documentation]    Verify pay details for SM user in mobility.
    ${shift_data}    Get Timecard Shift Data    shift_day=-1_4
    ${employee_id}    Get User    ESS2_STORE2
    Open SM Native Application On Mobile Phone    battc00241
    Login SM App On Mobile    SM1_STORE2
    Select More Tab On SM Phone App
    Select Timecard From More Tab On SM Phone App
    Select Week On Exception Management Page On SM Phone App    ${shift_data}[shift_day]
    Select Associate On Exception Management Page On SM Phone App    ${employee_id}[username]    ${employee_id}[displayName]
    ${if_shift_exists}    Verify Shift Added For Specific Date On SM Phone App    ${shift_data}[shift_day]    ${shift_data}[start_time]    ${shift_data}[end_time]
    IF    ${if_shift_exists}
        Remove Shift For TimeCard On SM Phone App    ${shift_data}[shift_day]    ${shift_data}[start_time]    ${shift_data}[end_time]    ${shift_data}[reason_code]
    END
    Add Shift For TimeCard On SM Phone App    ${shift_data}[shift_day]    ${shift_data}[shift_day]    ${shift_data}[start_time]    ${shift_data}[end_time]
    ...    ${shift_data}[department]    ${shift_data}[reason_code]    ${shift_data}[activity_code]
    ${is_shift_added}    Verify Shift Added For Specific Date On SM Phone App    ${shift_data}[shift_day]    ${shift_data}[start_time]    ${shift_data}[end_time]
    IF    ${is_shift_added}
        Log    Shift for date ${shift_data}[shift_day] with start time ${shift_data}[start_time] and end time ${shift_data}[end_time] is added successfully.
    ELSE
        Take Mobile Page Screenshot    shift_not_visible_battc00241
        Fail    Shift details not displayed as expected for shift on date ${shift_data}[shift_day], shift not added successfully.
    END
    Verify Pay Results For Shift On SM Phone App    ${shift_data}[shift_day]
    # Toast message cannot be verified, need assertion for shift creation success or failure
    Select More Tab On SM Phone App
    Select Timecard From More Tab On SM Phone App
    Select Week On Exception Management Page On SM Phone App    ${shift_data}[shift_day]
    Select Associate On Exception Management Page On SM Phone App    ${employee_id}[username]    ${employee_id}[displayName]
    Remove Shift For TimeCard On SM Phone App    ${shift_data}[shift_day]    ${shift_data}[start_time]    ${shift_data}[end_time]    ${shift_data}[reason_code]
    Verify No Data Present For Selected Date For Pay Results Tab On SM Phone App    ${shift_data}[shift_day]

    [Teardown]    Teardown Test Case    battc00241
