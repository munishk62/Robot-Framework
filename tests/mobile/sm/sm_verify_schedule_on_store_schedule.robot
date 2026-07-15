*** Settings ***
Documentation       BATTC00124 - This test case verifies that SM user can view the schedule generated on weekly schedule page on mobile.

Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Store_Schedule/SM_Store_Schedule.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application
Test Setup          Run Keywords    Run Only Once    Pre Setup Schedule For Week 0 SM1Store2
...                     AND
...                     Run Only Once    Pre Setup Schedule For Week 1 SM1Store2
...                     AND
...                     Run Only Once    Pre Setup Schedule For Week 2 SM1Store2

Test Tags           action:read    dev:moiz    battc00124    mobile    bat_phase2    config:rws
...    config:mobile_sm_enabled


*** Test Cases ***
BATTC00124: Verify the schedule from Weekly Schedule page in mobility
    [Documentation]    Verifies that SM user can edit the basic details of an associate on the associate roster page
    Open SM Native Application On Mobile Phone    battc00124
    Start Mobile Screen Recording
    Login SM App On Mobile    SM1_STORE2
    Navigate To Store Schedule Page On SM Phone App
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Navigate To Next Week By Next Arrow On Store Schedule Page On Mobile
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Navigate To Next Week By Next Arrow On Store Schedule Page On Mobile
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Navigate To Previous Week By Previous Arrow On Store Schedule Page On Mobile
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    Navigate To Previous Week By Previous Arrow On Store Schedule Page On Mobile
    Verify Schedule Generated On Weekly Store Schedule Page On Mobile

    [Teardown]    Teardown Test Case    battc00124
