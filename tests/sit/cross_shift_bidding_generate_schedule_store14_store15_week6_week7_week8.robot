*** Settings ***
Documentation       SITTC60074 - Cross Shift Bidding - Generate, edit, unallocate, and publish schedule for Store 14 and Store 15
...                 Ensure work patterns are mapped for Store 14 and Store 15 for planning weeks #6, #7, #8.

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Store_Schedule.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Shift_Details.resource
Resource            resources/Mobile/ESS/PagesResources/ShiftTrade/ShiftTrade.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Resource            resources/Mobile/SM/PagesResources/Shift_Request/SM_Shift_Request.resource
Resource            resources/Mobile/SM/PagesResources/Alt_Work_Location_Module/Alternate_Work_Location.resource
Resource            resources/Mobile/ESS/PagesResources/Login_Page/ESSLogin.resource
Library             Collections
Library             pabot.PabotLib

Suite Setup         Run Keywords
...    Pre Setup Schedule For Week 6 SM1Store14 SIT    AND
...    Pre Setup Schedule For Week 7 SM1Store14 SIT    AND
...    Pre Setup Schedule For Week 8 SM1Store14 SIT    AND
...    Pre Setup Schedule For Week 6 SM1Store15 SIT    AND
...    Pre Setup Schedule For Week 7 SM1Store15 SIT    AND
...    Pre Setup Schedule For Week 8 SM1Store15 SIT
Suite Teardown      Run Keyword And Ignore Error    Close Application


*** Test Cases ***
SITTC60074: Cross Shift Bidding - Generate, edit, unallocate, and publish schedule for Store 14 and Store 15
    [Documentation]    Cross Shift Bidding - Generate, edit, unallocate, and publish schedule for Store 14 and Store 15,
    ...    Generate schedule for planning weeks #6, #7 and #8 and verify the generated schedule
    ...    Edit schedule: add a shift for ""Store 14, Associate 07"" on Day 7 from 1:00 PM to 5:00 PM, then unallocate it
    ...    Publish the schedule
    [Tags]    dev:bushra    sittc60074    config:rws    config:weekplan_and_schedule_gen    mobile    sit    schedule_dependent
    ${ess_user}    Get User    ESS7_STORE14
    ${shift_data}    Get Shift Data    shift_add_day=6_6    start_time=13:00    end_time=17:00    task_name=TaskSegmentType.CONTINUED_WORK
    ${shift_day_offset}    Evaluate    "${shift_data}[shift_add_day]"
    Open SM Native Application On Mobile Phone    sittc60074
    Login SM App On Mobile    SM1_STORE14
    Navigate To Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    6_0
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Select Shift On Date For Associate On Store Schedule Page On SM Phone App    ${ess_user}[displayName]
    ...    ${shift_day_offset}
    Add Shift On Selected Date Details Page On SM Phone App    ${shift_data}[start_time]    ${shift_data}[end_time]    ${shift_data}[task_name]
    Verify Shift Saved Successfully On SM Phone App
    Unallocate Shift For Associate On Store Schedule Page On SM Phone App    ${shift_day_offset}
    ...    ${ess_user}[displayName]    ${shift_data}[start_time]
    ...    ${shift_data}[end_time]
    Publish Schedule On Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    7_0
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Publish Schedule On Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    8_0
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Publish Schedule On Store Schedule Page On SM Phone App
    Logout SM App On Mobile

    Login SM App On Mobile    SM1_STORE15
    Navigate To Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    6_0
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Publish Schedule On Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    7_0
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Publish Schedule On Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    8_0
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Publish Schedule On Store Schedule Page On SM Phone App

    [Teardown]    Teardown Test Case    sittc60074_cross_shift_bidding_generate_schedule_store14_store15_week6_week7_week8

SITTC60075: Cross Shift Bidding - Advertise shift, respond from nearby store associate (home not displayed), and approve from SM
    [Documentation]    Cross Shift Bidding - Advertise shift, respond from nearby store associate (home not displayed), and approve from SM
    [Tags]    dev:bushra    sittc60075    config:rws    config:ess    config:advertised_shift_enabled    config:ess_alternate_work_location
    ...    config:weekplan_and_schedule_gen    mobile    sit    schedule_dependent
    Open Mobile ESS App    sittc60075
    ${shift_trade_data}    Get Advertise Shift Data    planning_week_date=6_0    week_trade_day=6_1    shift_start_time=06:00    shift_end_time=13:00
    Login Mobile Ess App    ESS17_STORE14
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Request Give Away Shift On Mobile ESS    ${shift_trade_data}[notes]
    Navigate Back On Mobile ESS
    Logout Mobile ESS App From Top Level Page

    Open Mobile ESS App    sittc60075
    Login Mobile Ess App    ESS21_STORE15
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[week_trade_day]    ${shift_trade_data}[shift_start_time]
    ...    ${shift_trade_data}[shift_end_time]
    Accept Shift Trade Request On Mobile ESS    ${shift_trade_data}[respond_note]
    Navigate Back On Mobile ESS
    Logout Mobile ESS App From Top Level Page

    Login Mobile Ess App    ESS25_STORE15
    Navigate Mobile ESS To Shift Trade Page
    Select Cover Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Verify Shift Request Give Away Label Not Displayed For Respective Day On Mobile ESS    ${shift_trade_data}[week_trade_day]
    Close Mobile Application    sittc60075_ess25_not_visible_advertised_shift_request

    Open SM Native Application On Mobile Phone    sittc60075
    Login SM App On Mobile    SM1_STORE14
    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_trade_data}[week_trade_day]
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${SM_ADVERTISED_SHIFT_REQUEST_LIST}    ESS17_STORE14    ${shift_trade_data}[week_trade_day]
    ...    ${shift_trade_data}[shift_start_time]    ${shift_trade_data}[shift_end_time]
    Approve Responder On SM Mobile    ESS21_STORE15

    [Teardown]    Teardown Test Case    sittc60075_ess_raise_advertised_shift_request

SITTC60076: Cross Shift Bidding - Verify open shift display for home vs nearby associates, respond, and approve from SM
    [Documentation]    Cross Shift Bidding - Verify open shift display for home vs nearby associates, respond, and approve from SM
    [Tags]    dev:rashi    sittc60076    config:rws    config:ess    config:ess_alternate_work_location    config:weekplan_and_schedule_gen    mobile    sit

    ${shift_trade_data}    Get Open Shift Data    planning_week_date=6_6    start_time=06:00    end_time=13:00    week_trade_day=6_6
    Open Mobile ESS App    sittc60076
    Login Mobile Ess App    ESS17_STORE14
    Navigate Mobile ESS To Shift Trade Page
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Filter Option On Shift Trade Screen On Mobile ESS    Home Stores
    Verify Open Shift Is Visible On Cover Tab On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]
    Deselect Filter Option On Shift Trade Screen On Mobile ESS    Home Stores
    Select Filter Option On Shift Trade Screen On Mobile ESS    Nearby Stores
    Verify Shift Request Not Displayed For Respective Day On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]

    Open Mobile ESS App    sittc60076
    Login Mobile Ess App    ESS21_STORE15
    Navigate Mobile ESS To Shift Trade Page
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Filter Option On Shift Trade Screen On Mobile ESS    Nearby Stores
    Verify Open Shift Is Visible On Cover Tab On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]
    Respond To Open Shift As Nearby Associate On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]    Responding as nearby associate

    Open SM Native Application On Mobile Phone    sittc60076
    Login SM App On Mobile    SM1_STORE14
    Navigate To My Store Page On SM Phone App
    Approve Shift Bid Response On SM Phone App    Open    ESS21_STORE15    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]

    Open Mobile ESS App    sittc60076
    Login Mobile Ess App    ESS21_STORE15
    Navigate Mobile ESS To Shift Trade Page
    Select MyRequest Tab On Mobile ESS
    Select Approved Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[week_trade_day]    28
    Verify Request Status On MyRequest Tab On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]    Approved

    [Teardown]    Teardown Test Case    sittc60076_cross_shift_bidding_open_shift_home_vs_nearby

SITTC60077: Cross Shift Bidding - Create extra work request, verify home not displayed, respond from nearby, and approve from SM
    [Documentation]    Cross Shift Bidding - Create extra work request, verify home not displayed, respond from nearby, and approve from SM
    [Tags]    dev:rashi    sittc60077    config:rws    config:ess    config:ess_alternate_work_location    config:weekplan_and_schedule_gen    config:extra_work_shift_enabled    mobile    sit

    ${shift_trade_data}    Get Extra Work Shift Data    planning_week_date=6_2    week_trade_day=6_2    start_time=00:00    end_time=00:00
    Open Mobile ESS App    sittc60077
    Login Mobile Ess App    ESS21_STORE15
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Request Additional Work Shift On Mobile ESS    ${shift_trade_data}[extra_work_request_notes]    ${shift_trade_data}[week_trade_day]
    Select Cover Tab On Mobile ESS
    Select Filter Option On Shift Trade Screen On Mobile ESS    Home Stores
    Verify Additional Work Requested Not Displayed On Cover Tab On Mobile ESS    ${shift_trade_data}[week_trade_day]

    Open Mobile ESS App    sittc60077
    Login Mobile Ess App    ESS18_STORE14
    Navigate Mobile ESS To Shift Trade Page
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data}[planning_week_date]
    Select Filter Option On Shift Trade Screen On Mobile ESS    Nearby Stores
    Verify Open Shift Is Visible On Cover Tab On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]
    Respond To Extra Work Shift As Nearby Associate On Mobile ESS     Responding as nearby associate    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]

    Open SM Native Application On Mobile Phone    sittc60077
    Login SM App On Mobile    SM1_STORE15
    Navigate To My Store Page On SM Phone App
    Approve Shift Bid Response On SM Phone App    Additional    ESS21_STORE15    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]    ESS18_STORE14

    Open Mobile ESS App    sittc60077
    Login Mobile Ess App    ESS21_STORE15
    Navigate Mobile ESS To Shift Trade Page
    Select MyRequest Tab On Mobile ESS
    Select Approved Status In MyRequest Filter On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[week_trade_day]    28
    Verify Request Status On MyRequest Tab On Mobile ESS    ${shift_trade_data}[planning_week_date]    ${shift_trade_data}[start_time]    ${shift_trade_data}[end_time]    Approved

    [Teardown]    Teardown Test Case    sittc60077_cross_shift_bidding_extra_work_nearby_response_sm_approval

SITTC60078: Cross Shift Bidding - Verify swap restrictions, create cross-store swap request, respond from nearby, and approve from SM
    [Documentation]    Cross Shift Bidding - Verify swap restrictions, create cross-store swap request, respond from nearby, and approve from SM
    [Tags]    dev:rashi    sittc60078    config:rws    config:ess    config:ess_alternate_work_location    config:weekplan_and_schedule_gen    config:swap_shift_enabled    mobile    sit

    ${shift_trade_data1}    Get Individual Swap Shift Data    planning_week_date=6_3    week_trade_day=6_3   start_time=10:00    end_time=17:00
    ${shift_trade_data2}    Get Individual Swap Shift Data    planning_week_date=6_2    week_trade_day=6_2   start_time=10:00    end_time=17:00

    Open Mobile ESS App    sittc60078
    Login Mobile Ess App    ESS18_STORE15
    Navigate Mobile ESS To Shift Trade Page
    Select Post Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data1}[planning_week_date]
    Select Shift From Post List On Mobile ESS    ${shift_trade_data1}[week_trade_day]    ${shift_trade_data1}[start_time]    ${shift_trade_data1}[end_time]
    Verify Associate Has No Shifts Available To Swap On Mobile ESS    ESS20_STORE15    My Store
    Verify Associate Has No Shifts Available To Swap On Mobile ESS    ESS21_STORE15    My Store
    Navigate Back On Mobile ESS
    Select Shift From Post List On Mobile ESS    ${shift_trade_data2}[week_trade_day]    ${shift_trade_data2}[start_time]    ${shift_trade_data2}[end_time]
    Verify Associate Has No Shifts Available To Swap On Mobile ESS    ESS18_STORE14    Nearby Store    Store 14
    Navigate Back On Mobile ESS
    Select Shift From Post List On Mobile ESS    ${shift_trade_data1}[week_trade_day]    ${shift_trade_data1}[start_time]    ${shift_trade_data1}[end_time]
    Request Direct Swap For Nearby Store Shift On Mobile ESS    Note    ESS18_STORE14    ${shift_trade_data1}[week_trade_day]    ${shift_trade_data1}[start_time]    ${shift_trade_data1}[end_time]    Store 14
    Navigate Back On Mobile ESS
    Select Cover Tab On Mobile ESS
    Select Filter Option On Shift Trade Screen On Mobile ESS    Home Stores
    Verify Shift Request Not Displayed For Respective Day On Mobile ESS    ${shift_trade_data1}[planning_week_date]    ${shift_trade_data1}[start_time]    ${shift_trade_data1}[end_time]

    Open Mobile ESS App    sittc60078
    Login Mobile Ess App    ESS18_STORE14
    Navigate Mobile ESS To Shift Trade Page
    Navigate Mobile ESS Week Schedule To    ${shift_trade_data1}[planning_week_date]
    Select Filter Option On Shift Trade Screen On Mobile ESS    Nearby Stores
    Verify Open Shift Is Visible On Cover Tab On Mobile ESS    ${shift_trade_data1}[planning_week_date]    ${shift_trade_data1}[start_time]    ${shift_trade_data1}[end_time]
    Select Shift From Cover List On Mobile ESS    ${shift_trade_data1}[planning_week_date]    ${shift_trade_data1}[start_time]    ${shift_trade_data1}[end_time]
    Respond To Extra Work Shift As Nearby Associate On Mobile ESS    Responding as nearby associate

    Open SM Native Application On Mobile Phone    sittc60078
    Login SM App On Mobile    SM1_STORE15
    Navigate To My Store Page On SM Phone App
    Approve Shift Bid Response On SM Phone App    Swap    ESS18_STORE15    ${shift_trade_data1}[planning_week_date]    ${shift_trade_data1}[start_time]    ${shift_trade_data1}[end_time]    ESS18_STORE14

    Open Mobile ESS App    sittc60078
    Login Mobile Ess App    ESS18_STORE15
    Navigate Mobile ESS To Shift Trade Page
    Select MyRequest Tab On Mobile ESS
    Select Approved Status In MyRequest Filter On Mobile ESS    ${shift_trade_data1}[planning_week_date]    ${shift_trade_data1}[week_trade_day]    28
    Verify Request Status On MyRequest Tab On Mobile ESS    ${shift_trade_data1}[planning_week_date]    ${shift_trade_data1}[start_time]    ${shift_trade_data1}[end_time]    Approved

    [Teardown]    Teardown Test Case    sittc60078_cross_shift_bidding_swap_nearby_response_sm_approval
