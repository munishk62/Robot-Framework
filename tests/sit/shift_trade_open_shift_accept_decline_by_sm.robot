*** Settings ***
Documentation       SITTC60030 - Shift Trade - Respond to open Shift request from two ESS users, decline one and approve another from SM

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

Test Tags    dev:bushra    sittc60030    mobile    config:ess    config:rws    config:weekplan_and_schedule_gen    schedule_dependent    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60030: Shift Trade - Respond to open Shift request from two ESS users, decline one and approve another from SM
    [Documentation]    Shift Trade - Respond to open Shift request from two ESS users, decline one and approve another from SM
    Open Mobile ESS App    sittc60030
    ${shift_trade_data}    Get Open Shift Data    start_time=08:00    end_time=16:00
    ${ess_user3}    Get User    ESS3_STORE12
    Login Mobile Ess App    ESS2_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[start_time]
    ...    ${shift_trade_data}[end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[respond_note]
    Navigate Back On Mobile ESS
    Close Mobile Application    sittc60030_ess2_accept_open_shift_request

    Open Mobile ESS App    sittc60030
    Login Mobile Ess App    ESS3_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[start_time]
    ...    ${shift_trade_data}[end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[respond_note]
    Navigate Back On Mobile ESS
    Close Mobile Application    sittc60030_ess3_accept_open_shift_request

    Open SM Native Application On Mobile Phone    sittc60030
    Login SM App On Mobile    SM1_STORE12
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_OPEN_SHIFT_REQUEST_LIST}    ESS2_STORE12    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]
    Decline Responder On SM Mobile    ESS2_STORE12
    Select Trade Request On SM Mobile    ${SM_OPEN_SHIFT_REQUEST_LIST}    ESS3_STORE12    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]
    Approve Responder On SM Mobile    ESS3_STORE12
    Navigate To Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    ${shift_trade_data}[planning_week_date]
    Verify Shift Visible On Store Schedule Page On SM Phone App    ${ess_user3}[displayName]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]

    [Teardown]    Teardown Test Case    sittc60030_ess_raise_open_shift_request
