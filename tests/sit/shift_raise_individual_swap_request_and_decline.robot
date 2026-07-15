*** Settings ***
Documentation       SITTC60036 - Verify decline of individual swap shift response in mobility.
...                 ESS6_STORE12 raises individual swap request to ESS7_STORE12.
...                 ESS7_STORE12 accepts the swap request.
...                 SM1_STORE12 declines the swap shift response.

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Resource            resources/Mobile/SM/PagesResources/Shift_Request/SM_Shift_Request.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store12
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           dev:kishan    sittc60036    schedule_dependent    config:ess    config:rta    config:weekplan_and_schedule_gen    config:swap_shift_enabled    mobile    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60036: Shift Trade - Raise swap request (same day-1:1) from ESS, respond from another ESS and decline from SM
    [Documentation]    Verify decline of swap 1:1 shift response in mobile.
    ...    ESS6_STORE12 raises an individual swap request to ESS7_STORE12 on Day 5 of planning week 3.
    ...    ESS7_STORE12 accepts the swap request from the Cover tab.
    ...    SM1_STORE12 declines the swap shift response from Shift Request page.
    ...    ESS6_STORE12 verifies the request shows as Declined.
    ${shift_trade_data}    Get Individual Swap Shift Data    planning_week_date=3_0    week_trade_day=3_4
    ...    swap_shift_start_time=06:00    swap_shift_end_time=13:00
    ...    swap_request_notes=Automation Notes for Individual Swap Decline

    # Step 1: ESS6_STORE12 raises individual swap request
    Open Mobile ESS App    sittc60036
    Login Mobile Ess App    ESS6_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Direct Swap For My Store Shift On Mobile ESS    ${shift_trade_data}[swap_request_notes]    ESS7_STORE12
    ...    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[swap_shift_start_time]    ${shift_trade_data}[swap_shift_end_time]
    Navigate Back On Mobile ESS

    # Verify request shows as Pending Associate Response in My Requests
    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Swap Request Detail Page On Mobile ESS    ${trade_label_pending_associate_response}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]
    Close Mobile Application    sittc60036_ess_raise_swap

    # Step 2: ESS7_STORE12 accepts the swap request from Cover tab
    Open Mobile ESS App    sittc60036
    Login Mobile Ess App    ESS7_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[swap_response_notes]
    Navigate Back On Mobile ESS

    # Verify request shows as Pending Manager Approval in ESS7's My Requests
    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Swap Request Detail Page On Mobile ESS    ${trade_swap_label_pending_mgr_approval}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]    requested_by=ESS6_STORE12
    Close Mobile Application    sittc60036_ess_accept_swap

    # Step 3: SM1_STORE12 declines the swap shift response
    Open SM Native Application On Mobile Phone    sittc60036
    Login SM App On Mobile    SM1_STORE12
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_SWAP_SHIFT_REQUEST_LIST}    ESS6_STORE12    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Decline Responder On SM Mobile    ESS7_STORE12
    Close Mobile Application    sittc60036_sm_decline_swap

    # Step 4: ESS6_STORE12 verifies the request is Declined
    Open Mobile ESS App    sittc60036
    Login Mobile Ess App    ESS6_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select MyRequest Tab On Mobile ESS
    Select Dates In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Swap Request Status On Mobile ESS    ${trade_label_declined}

    [Teardown]    Teardown Test Case    sittc60036_ess_verify_declined
