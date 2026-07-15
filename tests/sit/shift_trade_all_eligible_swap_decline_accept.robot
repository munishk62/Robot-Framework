*** Settings ***
Documentation       SITTC70004 - Verify ESS user is able to decline the all-eligible swap shift request
...                 and another user accepts it from mobile.
...                 ESS7_STORE1_SIT raises a swap-with-all-eligible request on the trade day of planning week 1.
...                 ESS8_STORE1_SIT declines the request from the Cover tab.
...                 ESS16_STORE1_SIT declines the request from the Cover tab.
...                 ESS17_STORE1_SIT accepts the request from the Cover tab.
...                 ESS7_STORE1_SIT verifies ESS8 and ESS16 declined and ESS17 accepted from the Post tab.
...                 Trade day is day offset 1_4 of planning week 1.

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 1 SM1Store1 SIT
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:mitesh    sittc70004    schedule_dependent    config:ess    config:swap_shift_enabled    config:weekplan_and_schedule_gen
...    mobile    sit    sit_v1    sit_r22    sit_epic    decline_swap
...    config:mobile_shift_enabled


*** Test Cases ***
SITTC70004: Verify ESS user is able to decline the all-eligible swap shift request and another user accepts it when requested again from mobile
    [Documentation]    Verify ESS user can decline an all-eligible swap shift request and another user
    ...    accepts it from mobile.
    ...    ESS7_STORE1_SIT raises a swap-with-all-eligible request on the trade day.
    ...    ESS8_STORE1_SIT and ESS16_STORE1_SIT decline the request from the Cover tab.
    ...    ESS17_STORE1_SIT accepts the request from the Cover tab.
    ...    ESS7_STORE1_SIT verifies ESS8 and ESS16 declined and ESS17 accepted, with the request
    ...    now Pending Manager Approval.
    ${shift_trade_data}    Get All Eligible Swap Shift Data    planning_week_date=1_0    week_trade_day=1_4
    ...    shift_start_time=10:00    shift_end_time=17:00    swap_request_notes=Swap with all eligible
    # Select day 4 (Wednesday) on the swap-with-anyone day picker - same day offset as the traded shift.
    VAR    @{request_days}    ${4}

    # Step 1: ESS7 raises a swap-with-all-eligible request
    Open Mobile ESS App    sittc70004
    Login Mobile Ess App    ESS7_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Swap Shift With Anyone On Mobile ESS    ${request_days}    ${shift_trade_data}[swap_request_notes]
    Close Mobile Application    sittc70004_ess7_raise_all_eligible

    # Step 2: ESS8 declines the request from the Cover tab
    Open Mobile ESS App    sittc70004
    Login Mobile Ess App    ESS8_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Decline Shift Trade Request On Mobile ESS
    Close Mobile Application    sittc70004_ess8_decline

    # Step 3: ESS16 declines the request from the Cover tab
    Open Mobile ESS App    sittc70004
    Login Mobile Ess App    ESS16_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Decline Shift Trade Request On Mobile ESS
    Close Mobile Application    sittc70004_ess16_decline

    # Step 4: ESS17 accepts the request from the Cover tab
    Open Mobile ESS App    sittc70004
    Login Mobile Ess App    ESS17_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[swap_response_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Close Mobile Application    sittc70004_ess17_accept

    # Step 5: ESS7 verifies the responders' statuses from the Post tab
    Open Mobile ESS App    sittc70004
    Login Mobile Ess App    ESS7_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Select View Trade Details In Shift Actions PopUp On Mobile ESS
    Verify Swap Request Status On Mobile ESS    ${trade_swap_label_pending_mgr_approval}
    Verify Responder Declined Swap Request On Mobile ESS    ESS8_STORE1_SIT
    Verify Responder Declined Swap Request On Mobile ESS    ESS16_STORE1_SIT
    Verify Responder Accepted Swap Request On Mobile ESS    ESS17_STORE1_SIT

    [Teardown]    Teardown Test Case    sittc70004_ess7_verify_responses
