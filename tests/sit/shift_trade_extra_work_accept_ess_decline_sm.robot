*** Settings ***
Documentation       SITTC60031 - Shift Trade - Raise extra work from ESS, Respond from another ESS and decline from SM

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

Test Tags    dev:bushra    sittc60031    mobile    config:ess    config:rws    config:weekplan_and_schedule_gen    config:extra_work_shift_enabled    schedule_dependent    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60031: Shift Trade - Raise extra work from ESS, Respond from another ESS and decline from SM
    [Documentation]    Shift Trade - Raise extra work from ESS, Respond from another ESS and decline from SM
    Open Mobile ESS App    sittc60031
    ${shift_trade_data}    Get Extra Work Shift Data    week_trade_day=3_3    extra_work_start_time=8:00    extra_work_end_time=16:00
    Login Mobile Ess App    ESS2_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Request Additional Work Shift On Mobile ESS    ${shift_trade_data}[extra_work_request_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    ...    ${shift_trade_data}[extra_work_shift_length]
    Select Additional Work Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    Verify Extra Work Request Detail Page On Mobile ESS    ${trade_label_pending_associate_response}
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    ...    ${shift_trade_data}[extra_work_shift_length]
    Navigate Back On Mobile ESS
    Close Mobile Application    sittc60031_ess2_raise_extra_work_shift_request

    Open Mobile ESS App    sittc60031
    Login Mobile Ess App    ESS4_STORE12
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[extra_work_response_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    Navigate Back On Mobile ESS
    Close Mobile Application    sittc60031_ess4_respond_extra_work_shift_request

    Open SM Native Application On Mobile Phone    sittc60031
    Login SM App On Mobile    SM1_STORE12
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_ADDITIONAL_WORK_REQUEST_LIST}    ESS2_STORE12    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    Decline Request On SM Mobile

    [Teardown]    Teardown Test Case    sittc60031_ess_raise_extra_work_shift_request
