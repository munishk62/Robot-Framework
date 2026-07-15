*** Settings ***
Documentation       Verify mobile shift trade approval and withdrawal scenarios for week 2 store 2 schedule

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Resource            resources/Mobile/SM/PagesResources/Shift_Request/SM_Shift_Request.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Pre Setup Schedule For Week 2 SM1Store2
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           week2_sm1store2
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00115: Verify approval of extra work shift response in mobility
    [Documentation]    Verify approval of extra work shift response in mobility
    [Tags]    dev:kishan    battc00115    mobile    config:ess    config:rta    config:weekplan_and_schedule_gen    config:extra_work_shift_enabled    bat_phase2
    ...    schedule_dependent    checkschedulesetup
    ...    config:mobile_sm_enabled
    ${shift_trade_data}    Get Extra Work Shift Data    planning_week_date=2_0
    ...    week_trade_day=2_3    extra_work_shift_length=9:00    extra_work_request_notes=Test Additional Work
    ...    extra_work_response_notes=Responding to extra work request
    Open Mobile ESS App    battc00115
    Login Mobile Ess App    ESS6_STORE2
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

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]
    Verify Extra Work Request Detail Page On Mobile ESS    ${trade_label_pending_associate_response}
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    ...    ${shift_trade_data}[extra_work_shift_length]
    Navigate Back On Mobile ESS

    Logout Mobile ESS App From Top Level Page
    Close Mobile Application    battc00115_ess_raise_extra_work

    Open Mobile ESS App    battc00115
    Login Mobile Ess App    ESS5_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]

    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[extra_work_response_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    Navigate Back On Mobile ESS

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]
    Verify Extra Work Request Detail Page On Mobile ESS    ${trade_swap_label_pending_mgr_approval}
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    ...    ${shift_trade_data}[extra_work_shift_length]    requested_by=ESS6_STORE2

    Navigate Back On Mobile ESS
    Logout Mobile ESS App From Top Level Page
    Close Mobile Application    battc00115_ess_accept_extra_work

    Open SM Native Application On Mobile Phone    battc00115
    Login SM App On Mobile    SM1_STORE2
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_ADDITIONAL_WORK_REQUEST_LIST}    ESS6_STORE2    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    Approve Responder On SM Mobile    ESS5_STORE2
    Logout SM App On Mobile
    Close Mobile Application    battc00115_sm_approve_swap

    Open Mobile ESS App    battc00115
    Login Mobile Ess App    ESS6_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Verify Shift On Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]

    Select MyRequest Tab On Mobile ESS
    Select Approved Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]
    Verify Extra Work Request Detail Page On Mobile ESS    ${trade_label_approved}    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]    ${shift_trade_data}[extra_work_shift_length]
    Navigate Back On Mobile ESS
    Logout Mobile ESS App From Top Level Page
    Close Mobile Application    battc00115_ess_verify_extra_work_assigned

    Open Mobile ESS App    battc00115
    Login Mobile Ess App    ESS5_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Verify Shift Unassigned And Schedule Is Not Scheduled On Mobile ESS    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]

    Select MyRequest Tab On Mobile ESS
    Select Approved Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]
    Verify Extra Work Request Detail Page On Mobile ESS    ${trade_label_approved}    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]    ${shift_trade_data}[extra_work_shift_length]    requested_by=ESS6_STORE2

    [Teardown]    Teardown Test Case    battc00115_ess_verify_shift_removed

BATTC00117: Verify approval of individual swap shift response in mobility
    [Documentation]    Verify approval of individual swap shift request in mobility
    [Tags]    dev:kishan    battc00117    config:ess    config:rta    config:swap_shift_enabled    config:weekplan_and_schedule_gen    bat_phase2    mobile
    ...    schedule_dependent
    ...    config:mobile_sm_enabled
    ${shift_trade_data}    Get Individual Swap Shift Data    planning_week_date=2_0    week_trade_day=2_1
    ...    swap_request_notes=Automation Notes for Shift Advertise
    Open Mobile ESS App    battc00117
    Login Mobile Ess App    ESS6_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Direct Swap For My Store Shift On Mobile ESS    ${shift_trade_data}[swap_request_notes]    ESS5_STORE2
    ...    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[swap_shift_start_time]    ${shift_trade_data}[swap_shift_end_time]
    Navigate Back On Mobile ESS

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Swap Request Detail Page On Mobile ESS    ${trade_label_pending_associate_response}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]
    Close Mobile Application    battc00117_ess_raise_swap

    Open Mobile ESS App    battc00117
    Login Mobile Ess App    ESS5_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[swap_shift_start_time]
    ...    ${shift_trade_data}[swap_shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[swap_response_notes]
    Navigate Back On Mobile ESS

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[swap_shift_start_time]
    ...    ${shift_trade_data}[swap_shift_end_time]
    Verify Swap Request Detail Page On Mobile ESS    ${trade_swap_label_pending_mgr_approval}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]    requested_by=ESS6_STORE2
    Close Mobile Application    battc00117_ess_accept_swap

    Open SM Native Application On Mobile Phone    battc00117
    Login SM App On Mobile    SM1_STORE2
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_SWAP_SHIFT_REQUEST_LIST}    ESS6_STORE2    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Approve Responder On SM Mobile    ESS5_STORE2
    Close Mobile Application    battc00117_sm_approve_swap

    Open Mobile ESS App    battc00117
    Login Mobile Ess App    ESS6_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]

    Select MyRequest Tab On Mobile ESS
    Select Approved Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[swap_shift_start_time]
    ...    ${shift_trade_data}[swap_shift_end_time]
    Verify Swap Request Detail Page On Mobile ESS    ${trade_label_approved}    ${shift_trade_data}[swap_shift_start_time]
    ...    ${shift_trade_data}[swap_shift_end_time]    ${shift_trade_data}[week_trade_day]
    Close Mobile Application    battc00117_ess_verify_swapped_shift

    Open Mobile ESS App    battc00117
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
    Verify Swap Request Detail Page On Mobile ESS    ${trade_label_approved}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]    requested_by=ESS6_STORE2
    [Teardown]    Teardown Test Case    battc00117_ess_verify_swap_shift_approval

BATTC00185: Verify approval of all eligible swap shift response in mobility
    [Documentation]    Verify approval of all eligible swap shift request in mobility
    [Tags]    dev:kishan    battc00185    config:ess    config:rta    config:swap_shift_enabled    config:weekplan_and_schedule_gen    bat_phase2    mobile
    ...    schedule_dependent
    ...    config:mobile_sm_enabled
    ${shift_trade_data}    Get All Eligible Swap Shift Data    planning_week_date=2_0    week_trade_day=2_2
    ...    swap_request_notes=Automation Notes for Shift Advertise
    Open Mobile ESS App    battc00185
    Login Mobile Ess App    ESS6_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Swap Shift With Anyone On Mobile ESS    ${shift_trade_data}[work_days]    ${shift_trade_data}[swap_request_notes]
    Navigate Back On Mobile ESS

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Swap Request Detail Page On Mobile ESS    ${trade_label_pending_associate_response}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]
    Close Mobile Application    battc00185_ess_raise_all_eligible

    Open Mobile ESS App    battc00185
    Login Mobile Ess App    ESS5_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[swap_response_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Navigate Back On Mobile ESS

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Swap Request Detail Page On Mobile ESS    ${trade_swap_label_pending_mgr_approval}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]    requested_by=ESS6_STORE2
    Close Mobile Application    battc00185_ess_accept_all_eligible

    Open SM Native Application On Mobile Phone    battc00185
    Login SM App On Mobile    SM1_STORE2
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_SWAP_SHIFT_REQUEST_LIST}    ESS6_STORE2    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Approve Responder On SM Mobile    ESS5_STORE2
    Close Mobile Application    battc00185_sm_approve_all_eligible

    Open Mobile ESS App    battc00185
    Login Mobile Ess App    ESS6_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]

    Select MyRequest Tab On Mobile ESS
    Select Approved Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Verify Swap Request Detail Page On Mobile ESS    ${trade_label_approved}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]
    Close Mobile Application    battc00185_ess_verify_swapped_shift

    Open Mobile ESS App    battc00185
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
    Verify Swap Request Detail Page On Mobile ESS    ${trade_label_approved}    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]    ${shift_trade_data}[week_trade_day]    requested_by=ESS6_STORE2
    [Teardown]    Teardown Test Case    battc00185_ess_verify_swap_shift_approval

BATTC00187: Verify withdrawal of extra work shift request in mobility
    [Documentation]    Verify withdrawal of extra work shift request in mobility
    [Tags]    dev:kishan    battc00187    config:ess    config:rta    config:weekplan_and_schedule_gen    config:extra_work_shift_enabled    bat_phase2    mobile
    ${shift_trade_data}    Get Extra Work Shift Data    planning_week_date=2_0    week_trade_day=2_3
    ...    extra_work_request_notes=Test Additional Work
    Open Mobile ESS App    battc00187
    Login Mobile Ess App    ESS4_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Request Additional Work Shift On Mobile ESS    ${shift_trade_data}[extra_work_request_notes]    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    ...    ${shift_trade_data}[extra_work_shift_length]
    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[extra_work_start_time]
    ...    ${shift_trade_data}[extra_work_end_time]
    Withdraw Shift Request On Mobile ESS
    Verify Shift Request Not Displayed For Respective Day On Mobile ESS    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[extra_work_start_time]    ${shift_trade_data}[extra_work_end_time]
    [Teardown]    Teardown Test Case    battc00187

BATTC00188: Verify withdrawal of advertised shift request in mobility
    [Documentation]    Verify withdrawal of advertised shift request in mobility
    [Tags]    dev:kishan    battc00188    config:ess    config:rta    config:weekplan_and_schedule_gen    config:advertised_shift_enabled    bat_phase2    mobile
    ${shift_trade_data}    Get Advertise Shift Data    planning_week_date=2_0    week_trade_day=2_0
    ...    notes=Automation Notes for Shift Advertise
    Open Mobile ESS App    battc00188
    Login Mobile Ess App    ESS4_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Give Away Shift On Mobile ESS    ${shift_trade_data}[notes]

    Navigate Back On Mobile ESS

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Withdraw Shift Request On Mobile ESS

    Verify Shift Request Give Away Label Not Displayed For Respective Day On Mobile ESS    ${shift_trade_data}[week_trade_day]
    [Teardown]    Teardown Test Case    battc00188

BATTC00189: Verify withdrawal of individual swap shift request in mobility
    [Documentation]    Verify withdrawal of individual swap shift request in mobility
    [Tags]    dev:kishan    battc00189    config:ess    config:rta    config:swap_shift_enabled    config:weekplan_and_schedule_gen    bat_phase2    mobile
    ${shift_trade_data}    Get Individual Swap Shift Data    planning_week_date=2_0    week_trade_day=2_1
    ...    swap_request_notes=Automation Notes for Shift Advertise
    Open Mobile ESS App    battc00189
    Login Mobile Ess App    ESS4_STORE2
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Direct Swap For My Store Shift On Mobile ESS    ${shift_trade_data}[swap_request_notes]    ESS5_STORE2
    ...    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[swap_shift_start_time]    ${shift_trade_data}[swap_shift_end_time]

    Navigate Back On Mobile ESS

    Select MyRequest Tab On Mobile ESS
    Select Pending Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]
    ...    ${shift_trade_data}[week_trade_day]    28
    Select Shift From My Requests On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Withdraw Shift Request On Mobile ESS

    Verify Shift Request Give Away Label Not Displayed For Respective Day On Mobile ESS    ${shift_trade_data}[week_trade_day]
    [Teardown]    Teardown Test Case    battc00189
