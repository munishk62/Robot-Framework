*** Settings ***
Documentation       SITTC60033 - Shift Trade - Raise extra work from ESS, respond from two ESS users, decline one and approve another from SM

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
SITTC60033: Shift Trade - Raise extra work from ESS, respond from two other ESS and approve one and decline another from SM
    [Documentation]    Shift Trade - Raise extra work from ESS, respond from two ESS users, decline one and approve another from SM
    [Tags]    dev:ashish    sittc60033    config:ess    config:rta    config:weekplan_and_schedule_gen    schedule_dependent    mobile    sit    sit_b0    sit_v1    sit_r22
    ...    config:mobile_shift_enabled    config:mobile_sm_enabled
    Open Mobile ESS App    sittc60033
    ${shift_trade_data}    Get Extra Work Shift Data    planning_week_date=3_0
    ...    week_trade_day=3_5    extra_work_shift_length=9:00    extra_work_request_notes=Test Additional Work
    ...    extra_work_response_notes=Responding to extra work request

    Login Mobile Ess App    ESS5_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Request Additional Work Shift On Mobile ESS    ${shift_trade_data}[extra_work_request_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    ...    ${shift_trade_data}[extra_work_shift_length]
    Close Mobile Application    sittc60033_ess5_raise_extra_work_shift_request

    Open Mobile ESS App    sittc60033
    Login Mobile Ess App    ESS1_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[extra_work_response_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    Close Mobile Application    sittc60033_ess1_respond_extra_work_shift_request

    Open Mobile ESS App    sittc60033
    Login Mobile Ess App    ESS2_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[extra_work_response_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    Close Mobile Application    sittc60033_ess2_respond_extra_work_shift_request

    Open SM Native Application On Mobile Phone    sittc60033
    Login SM App On Mobile    SM1_STORE12
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_ADDITIONAL_WORK_REQUEST_LIST}    ESS5_STORE12    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    Decline Responder On SM Mobile    ESS1_STORE12
    Select Trade Request On SM Mobile    ${SM_ADDITIONAL_WORK_REQUEST_LIST}    ESS5_STORE12    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    Approve Responder On SM Mobile    ESS2_STORE12

    [Teardown]    Teardown Test Case    sittc60033_ess_raise_extra_work_shift_request
