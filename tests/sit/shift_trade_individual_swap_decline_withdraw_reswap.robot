*** Settings ***
Documentation       SITTC70003 - Verify ESS user decline individual swap request, withdraw, and another user accepts from mobile.
...                 ESS7_STORE1_SIT raises individual swap request with ESS8_STORE1_SIT on Day 3 of planning week 1.
...                 ESS8_STORE1_SIT declines the swap request from the Cover tab.
...                 ESS7_STORE1_SIT verifies decline, withdraws the request, and raises new swap with ESS16_STORE1_SIT.
...                 ESS16_STORE1_SIT accepts the swap request from the Cover tab.
...                 ESS7_STORE1_SIT verifies the request shows as Pending Manager Approval.

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 1 SM1Store1 SIT
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:mitesh    sittc70003    schedule_dependent    config:ess    config:swap_shift_enabled    config:weekplan_and_schedule_gen
...    mobile    sit    sit_v1    sit_r22    sit_epic    decline_swap
...    config:mobile_shift_enabled


*** Test Cases ***
SITTC70003: Verify ESS user is able to decline the individual swap shift request and another user accepts it when requested again from mobile
    [Documentation]    Verify ESS user can decline individual swap shift request, requestor withdraws,
    ...    then raises new request with another user who accepts from mobile.
    ...    ESS7_STORE1_SIT raises individual swap request with ESS8_STORE1_SIT on day 3.
    ...    ESS8_STORE1_SIT declines the swap request from the Cover tab.
    ...    ESS7_STORE1_SIT verifies decline, withdraws, raises new swap with ESS16_STORE1_SIT.
    ...    ESS16_STORE1_SIT accepts the swap request.
    ...    ESS7_STORE1_SIT verifies the request is now Pending Manager Approval.
    ${shift_trade_data}    Get Individual Swap Shift Data    planning_week_date=1_0    week_trade_day=1_3
    ...    shift_start_time=10:00    shift_end_time=17:00
    ...    swap_shift_start_time=11:00    swap_shift_end_time=18:00
    ${shift_trade_data2}    Get Individual Swap Shift Data    planning_week_date=1_0    week_trade_day=1_3
    ...    shift_start_time=11:00    shift_end_time=18:00
    ...    swap_shift_start_time=10:00    swap_shift_end_time=17:00

    # Step 1: ESS7 raises individual swap request with ESS8
    Open Mobile ESS App    sittc70003
    Login Mobile Ess App    ESS7_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Direct Swap For My Store Shift On Mobile ESS    ${shift_trade_data}[swap_request_notes]    ESS8_STORE1_SIT
    ...    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[swap_shift_start_time]    ${shift_trade_data}[swap_shift_end_time]
    Close Mobile Application    sittc70003_ess7_raise_swap_with_ess8

    # Step 2: ESS8 declines the swap request
    Open Mobile ESS App    sittc70003
    Login Mobile Ess App    ESS8_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data2}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data2}[week_trade_day]    ${shift_trade_data2}[swap_shift_start_time]
    ...    ${shift_trade_data2}[swap_shift_end_time]
    Decline Shift Trade Request On Mobile ESS
    Close Mobile Application    sittc70003_ess8_decline_swap

    # Step 3: ESS7 verifies decline and withdraws the request
    Open Mobile ESS App    sittc70003
    Login Mobile Ess App    ESS7_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Select View Trade Details In Shift Actions PopUp On Mobile ESS
    Verify Responder Declined Swap Request On Mobile ESS    ESS8_STORE1_SIT
    Withdraw Shift Request On Mobile ESS
    Navigate Back On Mobile ESS

    # Step 4: ESS7 raises new individual swap request with ESS16
    ${shift_trade_data_ess16}    Get Individual Swap Shift Data    planning_week_date=1_0    week_trade_day=1_3
    ...    shift_start_time=10:00    shift_end_time=17:00
    ...    swap_shift_start_time=12:00    swap_shift_end_time=19:00
    ${shift_trade_data_ess16_2}    Get Individual Swap Shift Data    planning_week_date=1_0    week_trade_day=1_3
    ...    shift_start_time=12:00    shift_end_time=19:00
    ...    swap_shift_start_time=10:00    swap_shift_end_time=17:00
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data_ess16}[planning_week_date]
    ...    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data_ess16}[week_trade_day]    ${shift_trade_data_ess16}[shift_start_time]
    ...    ${shift_trade_data_ess16}[shift_end_time]
    Request Direct Swap For My Store Shift On Mobile ESS    ${shift_trade_data_ess16}[swap_request_notes]    ESS16_STORE1_SIT
    ...    ${shift_trade_data_ess16}[week_trade_day]    ${shift_trade_data_ess16}[swap_shift_start_time]
    ...    ${shift_trade_data_ess16}[swap_shift_end_time]
    Close Mobile Application    sittc70003_ess7_raise_swap_with_ess16

    # Step 5: ESS16 accepts the swap request
    Open Mobile ESS App    sittc70003
    Login Mobile Ess App    ESS16_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data_ess16_2}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data_ess16_2}[week_trade_day]
    ...    ${shift_trade_data_ess16_2}[swap_shift_start_time]    ${shift_trade_data_ess16_2}[swap_shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data_ess16}[swap_response_notes]
    Close Mobile Application    sittc70003_ess16_accept_swap

    # Step 6: ESS7 verifies the request is now Pending Manager Approval
    Open Mobile ESS App    sittc70003
    Login Mobile Ess App    ESS7_STORE1_SIT
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data_ess16}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data_ess16}[week_trade_day]    ${shift_trade_data_ess16}[shift_start_time]
    ...    ${shift_trade_data_ess16}[shift_end_time]
    Select View Trade Details In Shift Actions PopUp On Mobile ESS
    Verify Swap Request Detail Page On Mobile ESS    ${trade_swap_label_pending_mgr_approval}
    ...    ${shift_trade_data_ess16}[shift_start_time]    ${shift_trade_data_ess16}[shift_end_time]
    ...    ${shift_trade_data_ess16}[week_trade_day]

    [Teardown]    Teardown Test Case    sittc70003_ess7_verify_accepted
