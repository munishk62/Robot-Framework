*** Settings ***
Documentation       SITTC60026 - Shift Trade - Raise advertise from ESS, respond from another ESS and decline from SM

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Resource            resources/Mobile/SM/PagesResources/Shift_Request/SM_Shift_Request.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Store_Schedule.resource
Variables           resources/Mobile/SM/Locators/Request.py
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store12
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:bushra    sittc60026    mobile    config:ess    config:rws    config:weekplan_and_schedule_gen    config:advertised_shift_enabled    schedule_dependent    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60026: Shift Trade - Raise advertise from ESS, respond from another ESS and decline from SM
    [Documentation]    Shift Trade - Raise advertise from ESS, respond from another ESS and decline from SM
    Open Mobile ESS App    sittc60026
    ${shift_trade_data}    Get Advertise Shift Data    week_trade_day=3_3    shift_start_time=06:00    shift_end_time=13:00
    Login Mobile Ess App    ESS3_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Give Away Shift On Mobile ESS    ${shift_trade_data}[notes]
    Close Mobile Application    sittc60026_ess3_raise_advertised_shift_request

    Open Mobile ESS App    sittc60026
    Login Mobile Ess App    ESS5_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[respond_note]
    Navigate Back On Mobile ESS
    Close Mobile Application    sittc60026_ess5_respond_advertised_shift_request

    Open SM Native Application On Mobile Phone    sittc60026
    Login SM App On Mobile    SM1_STORE12
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_ADVERTISED_SHIFT_REQUEST_LIST}    ESS3_STORE12    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Decline Request On SM Mobile

    [Teardown]    Teardown Test Case    sittc60026_ess_raise_advertised_shift_request
