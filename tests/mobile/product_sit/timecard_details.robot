*** Settings ***
Documentation       BATTC00232 - Verify timecard details (punches, warning, audit) for ESS user in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/More/More.resource
Resource            resources/Mobile/SM/PagesResources/Timecard/Timecard_Add.resource
Resource            resources/Mobile/SM/PagesResources/Timecard/Exception_Management_Page.resource
Resource            resources/Mobile/ESS/PagesResources/More_Module/More.resource
Resource            resources/Mobile/ESS/PagesResources/Timecard_Module/Timecard.resource
Resource            resources/Mobile/ESS/PagesResources/Timecard_Module/Timecard_Audit.resource
Resource            resources/Mobile/ESS/PagesResources/Timecard_Module/Timecard_Warnings.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           bat_phase2    dev:bushra    battc00232    mobile    config:rta    config:ess
...    config:mobile_shift_enabled    config:mobile_sm_enabled    bug_reported    bugid_wfm_139956


*** Test Cases ***
BATTC00232: Verify timecard details (punches, warning, audit) for ESS user in mobility
    [Documentation]    Verifies that users can view timecard details, including punches, warnings, and audit information, for ESS users in the mobile application.
    ${shift_data}    Get Timecard Shift Data    shift_day=-1_1
    ${audit_data}    Get Timecard Audit Data
    ${warning_data}    Get Timecard Warning Data
    ${smuser}    Get User    SM1_STORE1
    ${employee_id}    Get User    ESS4_STORE1
    Open SM Native Application On Mobile Phone    battc00232
    Login SM App On Mobile    SM1_STORE1
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
        Take Mobile Page Screenshot    battc00232_shift_not_added_${shift_data}[shift_day]
        Fail    Shift details not displayed as expected for shift on date ${shift_data}[shift_day], shift not added successfully.
    END
    Close Mobile Application    battc00232_sm_add_shift

    Open Mobile ESS App    battc00232
    Login Mobile Ess App    ESS4_STORE1
    Navigate Mobile ESS To Module    ${timeCardTitle}
    Navigate Timecard Calendar On Mobile ESS    ${shift_data}[shift_day]
    Select Day From Displayed Week On Mobile ESS    ${shift_data}[shift_day]
    Verify Timecard Actual Punch On Mobile ESS    ${shift_data}[start_time]
    Verify Timecard Actual Punch On Mobile ESS    ${shift_data}[end_time]
    Select Audit Tab On Mobile ESS
    Select All Tab On Mobile ESS
    Select Day From Displayed Week On Mobile ESS    ${shift_data}[shift_day]
    Verify Audit List Item On Mobile ESS
    ...    ${audit_data}[audit_changelog_type]    ${audit_data}[audit_action]    ${shift_data}[start_time]
    ...    ${smuser}[username]
    Verify Audit List Item On Mobile ESS
    ...    ${audit_data}[audit_changelog_type]    ${audit_data}[audit_action]    ${shift_data}[end_time]
    ...    ${smuser}[username]
    ${is_warning_tab_enabled}    Is Config Enabled    review_warnings_timecard
    IF    ${is_warning_tab_enabled}
        Select Warnings Tab On Mobile ESS
        Select All Tab On Mobile ESS
        Select Day From Displayed Week On Mobile ESS    ${shift_data}[shift_day]
        Tap First Warning Item Found For Given Criteria On Mobile ESS    ${warning_data}[description]    ${warning_data}[status]
        Verify Timecard Warning Details On Mobile ESS    ${warning_data}[description]    ${shift_data}[shift_day]    ${shift_data}[start_time]
    END
    Close Mobile Application    battc00232_ess_verify_shift

    Open SM Native Application On Mobile Phone    battc00232
    Login SM App On Mobile    SM1_STORE1
    Select More Tab On SM Phone App
    Select Timecard From More Tab On SM Phone App
    Select Week On Exception Management Page On SM Phone App    ${shift_data}[shift_day]
    Select Associate On Exception Management Page On SM Phone App    ${employee_id}[username]    ${employee_id}[displayName]
    Remove Shift For TimeCard On SM Phone App    ${shift_data}[shift_day]    ${shift_data}[start_time]    ${shift_data}[end_time]    ${shift_data}[reason_code]
    Logout SM App On Mobile

    [Teardown]    Teardown Test Case    battc00232_sm_remove_shift
