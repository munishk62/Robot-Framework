*** Settings ***
Documentation       BATTC00233 - Verify pay details for ESS user in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/More/More.resource
Resource            resources/Mobile/SM/PagesResources/Timecard/Timecard_Add.resource
Resource            resources/Mobile/SM/PagesResources/Timecard/Exception_Management_Page.resource
Resource            resources/Mobile/ESS/PagesResources/More_Module/More.resource
Resource            resources/Mobile/ESS/PagesResources/Timecard_Module/Timecard.resource
Resource            resources/Mobile/ESS/PagesResources/Timecard_Module/Timecard_PayResults.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           bat_phase2    dev:bushra    battc00233    mobile    config:rta    config:sm_wage_display    config:view_pay_results
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
BATTC00233: Verify pay details for ESS user in mobility
    [Documentation]    Verifies that users can view pay details for ESS users in the mobile application.
    ${shift_data}    Get Timecard Shift Data    shift_day=-1_3
    ${employee_id}    Get User    ESS2_STORE2
    Open SM Native Application On Mobile Phone    battc00233
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
    # Toast message cannot be verified, need assertion for shift creation success or failure
    ${is_shift_added}    Verify Shift Added For Specific Date On SM Phone App    ${shift_data}[shift_day]    ${shift_data}[start_time]    ${shift_data}[end_time]
    IF    ${is_shift_added}
        Log    Shift for date ${shift_data}[shift_day] with start time ${shift_data}[start_time] and end time ${shift_data}[end_time] is added successfully.
    ELSE
        Take Mobile Page Screenshot    shift_details_not_matched_battc00233
        Fail    Shift details not displayed as expected for shift on date ${shift_data}[shift_day], shift not added successfully.
    END
    Logout SM App On Mobile
    Close Mobile Application    battc00233_sm_add_shift

    Open Mobile ESS App    battc00233
    Login Mobile Ess App    ESS2_STORE2
    Navigate Mobile ESS To Module    ${timeCardTitle}
    Navigate Timecard Calendar On Mobile ESS    ${shift_data}[shift_day]
    Select Pay Results Tab On Mobile ESS
    Select Day From Displayed Week On Mobile ESS    ${shift_data}[shift_day]
    Verify Shift Timings On Mobile ESS    ${shift_data}[shift_day]    ${shift_data}[start_time]    ${shift_data}[end_time]
    Logout Mobile ESS App
    Close Mobile Application    battc00233_ess_verify_pay_results

    Open SM Native Application On Mobile Phone    battc00233
    Login SM App On Mobile    SM1_STORE2
    Select More Tab On SM Phone App
    Select Timecard From More Tab On SM Phone App
    Select Week On Exception Management Page On SM Phone App    ${shift_data}[shift_day]
    Select Associate On Exception Management Page On SM Phone App    ${employee_id}[username]    ${employee_id}[displayName]
    Remove Shift For TimeCard On SM Phone App    ${shift_data}[shift_day]    ${shift_data}[start_time]    ${shift_data}[end_time]    ${shift_data}[reason_code]

    [Teardown]    Teardown Test Case    battc00233_sm_remove_shift
