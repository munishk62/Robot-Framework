*** Settings ***
Documentation       BATTC00114 - Verify approval of open shift response in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Resource            resources/Mobile/SM/PagesResources/Shift_Request/SM_Shift_Request.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 5 SM1Store2
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           week5_sm1store2
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
BATTC00114: Verify approval of open shift response in mobility
    [Documentation]    Verify approval of open shift response in mobility
    [Tags]    dev:kishan    battc00114    config:ess    config:rta    config:weekplan_and_schedule_gen    bat_phase2    mobile
    ...    schedule_dependent    checkschedulesetup
    ${shift_trade_data}    Get Open Shift Data    planning_week_date=5_0    week_trade_day=5_6
    ...    respond_note=Automation Respond Note for Open Shift Approval    shift_start_time=08:00    shift_end_time=16:00
    ...    notes=Automation Notes for Shift Advertise

    Open Mobile ESS App    battc00114
    Login Mobile Ess App    ESS5_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]

    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[respond_note]
    Navigate Back On Mobile ESS
    Logout Mobile ESS App From Top Level Page
    Close Mobile Application    battc00114_ess_accept_open_shift

    Open SM Native Application On Mobile Phone    battc00114
    Login SM App On Mobile    SM1_STORE2
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_OPEN_SHIFT_REQUEST_LIST}    ESS5_STORE2    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]

    Approve Responder On SM Mobile    ESS5_STORE2
    Logout SM App On Mobile
    Close Mobile Application    battc00114_sm_approve_open_shift

    Open Mobile ESS App    battc00114
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
    Verify Open Shift Request Detail Page On Mobile ESS    ${trade_label_approved}

    [Teardown]    Teardown Test Case    battc00114_verify_open_shift_assigned
