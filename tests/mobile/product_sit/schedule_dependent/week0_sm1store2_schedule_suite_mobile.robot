*** Settings ***
Documentation       BATTC00224 - Verify the home page in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Home_Module/Home.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 0 SM1Store2
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           week0_sm1store2
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00224: Verify the home page in mobility
    [Documentation]    Verify the home page in mobility
    [Tags]    dev:bushra    battc00224    bat_phase2    config:rws    config:ess    mobile    config:weekplan_and_schedule_gen    schedule_dependent
    Open Mobile ESS App    battc00224
    ${shift_day}    Get System Value    SanityCheck    PLANNING_WEEK_END_DATE
    ${time_off_balance_total_hours}    Get System Value    TimeOffBalanceData    TOTAL_HOURS
    Login Mobile Ess App    ESS5_STORE2
    Verify At Least Two Top Options Visible On Home Screen On Mobile ESS
    ${is_rta_enabled}    Is Config Enabled    rta
    IF    ${is_rta_enabled}
        Verify Time Off Balance Label On Home Screen On Mobile ESS
        ${reason}    Get System Value    AccrualBalanceReason    LEAVE_BALANCE_TYPE2
        Verify Time Off Balance Total Hours For Reason On Home Screen On Mobile ESS    ${reason}    ${time_off_balance_total_hours}
    END

    ${is_shift_present}    Verify Shift Present For Associate On Home Screen On Mobile ESS    ${shift_day}
    IF    not ${is_shift_present}
        Take Mobile Page Screenshot    shift_not_visible_battc00224
        Fail    Expected shift not visible on home screen.
    END

    Verify At Least One Shortcut Visible On Home Screen On Mobile ESS

    Verify Home Menu Option Visible On Home Screen On Mobile ESS    True
    Verify Schedule Menu Option Visible On Home Screen On Mobile ESS    True
    Verify Requests Menu Option Visible On Home Screen On Mobile ESS    True
    Verify More Menu Option Visible On Home Screen On Mobile ESS    True

    [Teardown]    Teardown Test Case    battc00224
