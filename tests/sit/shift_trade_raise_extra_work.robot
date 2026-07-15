*** Settings ***
Documentation       SITTC60032 - Shift Trade - Raise extra work from ESS

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store12
Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60032: Shift Trade - Raise Extra Work Request from ESS
    [Documentation]    Shift Trade - Raise extra work from ESS
    [Tags]    dev:rashi    sittc60032     config:ess    config:rta    config:weekplan_and_schedule_gen    mobile    sit    sit_b0    sit_v1    sit_r22
    ...    config:mobile_shift_enabled
    Open Mobile ESS App    sittc60032
    ${shift_trade_data}    Get Extra Work Shift Data    week_trade_day=3_6
    Login Mobile Ess App    ESS4_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Request Additional Work Shift On Mobile ESS    ${shift_trade_data}[extra_work_request_notes]    ${shift_trade_data}[week_trade_day]
    Verify Additional Work Requested Displayed On Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]
    [Teardown]    Teardown Test Case    sittc60032_ess4_raise_extra_work_shift_request
