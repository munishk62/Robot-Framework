*** Settings ***
Documentation       SITTC60084 - Cross Shift Bidding - Generate schedule for Store 14 and verify (planning week #5).
...                 Suite Setup ensures work patterns / forecast / workload are mapped for Store 14 / week 5
...                 (via the shared `Pre Setup Schedule For Week 5 SM1Store14` keyword) without generating the
...                 schedule, so the test itself exercises the SM mobile Generate Schedule flow.
...                 Sibling SIT tests SITTC60082 and SITTC60083 add the pending leave requests that this
...                 generated schedule is expected to reflect.

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Store_Schedule.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource
Library             pabot.PabotLib

Test Tags
...    dev:kishan
...    sittc60084
...    config:rws
...    config:weekplan_and_schedule_gen
...    mobile
...    sit
...    sit_b0
...    sit_v1
...    schedule_dependent
...    suite_d
...    config:mobile_sm_enabled
...    sit_r23


*** Test Cases ***
SITTC60084: Cross Shift Bidding - Generate schedule for Store 14 and verify (planning week #5)
    [Documentation]    Cross Shift Bidding - SM of Store 14 logs into the Manager (SM) mobile app,
    ...    navigates to the Store Schedule page for planning week #5, triggers schedule generation
    ...    and verifies that the schedule for the week is generated successfully.

    Open SM Native Application On Mobile Phone    sittc60084
    Login SM App On Mobile    SM1_STORE14
    Navigate To Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    5_0
    Generate Schedule On Store Schedule Page On SM Phone App
    Sleep    ${SCHEDULE_GENERATION_TIMEOUT}
    Select Week On Store Schedule Page On SM Phone App    4_0    5_0
    Select Week On Store Schedule Page On SM Phone App    5_0    4_0
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile

    [Teardown]    Teardown Test Case    sittc60084_cross_shift_bidding_generate_schedule_store14_week5
