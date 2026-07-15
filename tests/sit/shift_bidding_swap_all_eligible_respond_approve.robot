*** Settings ***
Documentation       SITTC60035: Shift Trade - Raise swap request (many - all eligible) from ESS, respond from another ESS and approve from SM

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Resource            resources/Mobile/SM/PagesResources/Shift_Request/SM_Shift_Request.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store12
Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60035: Shift Trade - Raise swap request (many - all eligible) from ESS, respond from another ESS and approve from SM
    [Documentation]    Shift Trade - Raise swap request (many - all eligible) from ESS, respond from another ESS and approve from SM
    [Tags]    dev:ashish    sittc60035    config:ess    config:rta    config:weekplan_and_schedule_gen    schedule_dependent    mobile    sit    sit_b0    sit_v1    sit_r22
    ...    config:mobile_shift_enabled    config:mobile_sm_enabled
    ${shift_trade_data}    Get All Eligible Swap Shift Data    planning_week_date=3_0    week_trade_day=3_2
    ...    swap_request_notes=Automation Notes for Swap Request All Eligible    swap_response_notes=Automation Notes for Swap Response All Eligible

    Open Mobile ESS App    sittc60035
    Login Mobile Ess App    ESS6_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Swap Shift With Anyone On Mobile ESS    ${shift_trade_data}[work_days]    ${shift_trade_data}[swap_request_notes]
    Close Mobile Application    sittc60035_ess6_raise_swap_all_eligible_request

    Open Mobile ESS App    sittc60035
    Login Mobile Ess App    ESS7_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[swap_response_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Close Mobile Application    sittc60035_ess7_respond_swap_all_eligible_request

    Open SM Native Application On Mobile Phone    sittc60035
    Login SM App On Mobile    SM1_STORE12
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_SWAP_SHIFT_REQUEST_LIST}    ESS6_STORE12    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Approve Responder On SM Mobile    ESS7_STORE12

    [Teardown]    Teardown Test Case    sittc60035_ess_raise_swap_all_eligible_request
