*** Settings ***
Documentation       SITTC60037 - Shift Trade - Raise Swap request from ESS

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store12
Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60037: Shift Trade - Raise Swap request (many - all eligible) from ESS
    [Documentation]    Shift Trade - Raise Swap request from ESS
    [Tags]    dev:rashi    sittc60037     config:ess    config:rta    config:weekplan_and_schedule_gen    mobile    sit    sit_b0    sit_v1    sit_r22
    ...    config:mobile_shift_enabled
    Open Mobile ESS App    sittc60037
    ${shift_trade_data}    Get Individual Swap Shift Data    planning_week_date=3_0    week_trade_day=3_3    shift_start_time=06:00    shift_end_time=13:00
    VAR    @{request_days}    ${3}

    Login Mobile Ess App    ESS7_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Swap Shift With Anyone On Mobile ESS    ${request_days}    ${shift_trade_data}[swap_request_notes]
    Navigate Back On Mobile ESS
    Verify Swap Label Displayed On Mobile ESS    ${shift_trade_data}[week_trade_day]
    [Teardown]    Teardown Test Case    sittc60037_ess7_raise_swap_request
