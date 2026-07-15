*** Settings ***
Documentation       BATTC00185 - Verify approval of all eligible swap shift request in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Resource            resources/Mobile/SM/PagesResources/Shift_Request/SM_Shift_Request.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store2
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           week3_sm1store2
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
BATTC00116: Verify approval of advertised shift response in mobility
    [Documentation]    Verify approval of advertised shift response in mobility
    [Tags]    dev:kishan    battc00116    config:ess    config:rta    config:advertised_shift_enabled    config:weekplan_and_schedule_gen    bat_phase2    mobile
    ...    schedule_dependent    checkschedulesetup    bug_reported    bugid_wfm_138366_bpdry
    ${shift_trade_data}    Get Advertise Shift Data    notes=Automation Notes for Shift Advertise
    Open Mobile ESS App    battc00116
    Login Mobile Ess App    ESS6_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Give Away Shift On Mobile ESS    ${shift_trade_data}[notes]

    Navigate Back On Mobile ESS

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]

    Verify Give Away Request Detail Page On Mobile ESS    ${trade_label_pending_associate_response}
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]
    Navigate Back On Mobile ESS
    Logout Mobile ESS App From Top Level Page
    Close Mobile Application    battc00116_ess_raise_advertised_shift_request

    Open Mobile ESS App    battc00116
    Login Mobile Ess App    ESS5_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]

    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[respond_note]
    Navigate Back On Mobile ESS

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Give Away Request Detail Page On Mobile ESS    ${trade_swap_label_pending_mgr_approval}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]    requested_by=ESS6_STORE2

    Navigate Back On Mobile ESS
    Logout Mobile ESS App From Top Level Page
    Close Mobile Application    battc00116_ess_accept_advertised_shift_request

    Open SM Native Application On Mobile Phone    battc00116
    Login SM App On Mobile    SM1_STORE2
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_ADVERTISED_SHIFT_REQUEST_LIST}    ESS6_STORE2    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Approve Responder On SM Mobile    ESS5_STORE2
    Logout SM App On Mobile
    Close Mobile Application    battc00116_sm_approve_advertised_shift_request

    Open Mobile ESS App    battc00116
    Login Mobile Ess App    ESS6_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Verify Shift Unassigned And Schedule Is Not Scheduled On Mobile ESS    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]

    Select MyRequest Tab On Mobile ESS
    Select Approved Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Give Away Request Detail Page On Mobile ESS    ${trade_label_approved}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]
    Navigate Back On Mobile ESS
    Logout Mobile ESS App From Top Level Page
    Close Mobile Application    battc00116_ess_verify_shift_swapped

    Open Mobile ESS App    battc00116
    Login Mobile Ess App    ESS5_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Verify Shift On Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Select MyRequest Tab On Mobile ESS
    Select Approved Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Give Away Request Detail Page On Mobile ESS    ${trade_label_approved}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]    requested_by=ESS6_STORE2

    [Teardown]    Teardown Test Case    battc00116_ess_verify_swap_shift_approval
