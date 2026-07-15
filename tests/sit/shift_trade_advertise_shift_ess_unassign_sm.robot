*** Settings ***
Documentation       SITTC60025 - Shift Trade - Raise advertise shift from ESS and Unassign from SM

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Resource            resources/Mobile/SM/PagesResources/Shift_Request/SM_Shift_Request.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Store_Schedule.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store12
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:bushra    sittc60025    mobile    config:ess    config:rws    config:weekplan_and_schedule_gen    config:advertised_shift_enabled    schedule_dependent    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60025: Shift Trade - Raise advertise shift from ESS and Unassign from SM
    [Documentation]    Shift Trade - Raise advertise shift from ESS and Unassign from SM
    Open Mobile ESS App    sittc60025
    ${shift_trade_data}    Get Advertise Shift Data    week_trade_day=3_6    shift_start_time=06:00    shift_end_time=13:00
    ${ess_user}    Get User    user_key=ESS1_STORE12
    Login Mobile Ess App    ESS1_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Post Tab On Mobile ESS
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Give Away Shift On Mobile ESS    ${shift_trade_data}[notes]
    Select View Trade Details In Shift Actions PopUp On Mobile ESS
    Verify Give Away Request Detail Page On Mobile ESS    ${trade_label_pending_associate_response}
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]
    Navigate Back On Mobile ESS
    Close Mobile Application    sittc60025_ess1_raise_advertised_shift_request

    Open SM Native Application On Mobile Phone    sittc60025
    Login SM App On Mobile    SM1_STORE12
    Navigate To Store Schedule Page On SM Phone App
    Unassign Shift For Associate On Store Schedule Page On SM Phone App    ${shift_trade_data}[week_trade_day]    ${ess_user}[displayName]    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]

    [Teardown]    Teardown Test Case    sittc60025_ess_raise_advertised_shift_request
