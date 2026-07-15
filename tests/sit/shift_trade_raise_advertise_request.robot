*** Settings ***
Documentation       SITTC60034 - Shift Trade - Raise advertise request from ESS

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store12
Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60034: Shift Trade - Raise advertise request from ESS
    [Documentation]    Shift Trade - Raise advertise request from ESS
    [Tags]    dev:rashi    sittc60034     config:ess    config:rta    config:weekplan_and_schedule_gen    mobile    sit    sit_b0    sit_v1    sit_r22
    ...    config:mobile_shift_enabled
    Open Mobile ESS App    sittc60034
    ${shift_trade_data}    Get Advertise Shift Data    week_trade_day=3_6    shift_start_time=06:00    shift_end_time=13:00
    Login Mobile Ess App    ESS5_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Give Away Shift On Mobile ESS    ${shift_trade_data}[notes]
    Navigate Back On Mobile ESS
    Verify Shift Request Give Away Label Displayed For Respective Day On Mobile ESS    ${shift_trade_data}[week_trade_day]
    [Teardown]    Teardown Test Case    sittc60034_ess5_raise_advertise_request
