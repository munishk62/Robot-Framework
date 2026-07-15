*** Settings ***
Documentation       BATTC00225 - Verify the schedule when the week is not published for ESS user in mobility

Library             pabot.PabotLib
Resource            resources/Mobile/ESS/PagesResources/Schedule/Schedule_Landing_page.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Home_Module/Home.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource

Suite Setup         Run Keywords    Pre Setup Schedule For Week 6 SM1Store1
...                     AND
...                     Run Only Once    Pre Setup Schedule For Week 8 SM1Store1
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           week6_8_sm1store1
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00225: Verify the schedule when the week is not published for ESS user in mobility
    [Documentation]    Verify the schedule when the week is not published for ESS user in mobility
    [Tags]    dev:bushra    battc00225    bat_phase2    config:ess    mobile    schedule_dependent    config:weekplan_and_schedule_gen
    ...    checkschedulesetup
    Open Mobile ESS App    battc00225
    ${week_for_unpublished_schedule}    Get Schedule Generation Setup Data    template_name=6_0_sm1_store1
    ${week_for_no_schedule}    Get Schedule Generation Setup Data    template_name=8_0_sm1_store1
    Login Mobile Ess App    ESS4_STORE1
    Navigate To ESS Schedule Page On Mobile ESS
    Select Schedule Week Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${week_for_unpublished_schedule}[week_start_date]
    Verify Schedule Not Published On Mobile ESS
    Select Schedule Day Tab On Mobile ESS
    Verify Schedule Not Published On Mobile ESS
    Select Schedule Month Tab On Mobile ESS
    Verify Schedule Not Published In Monthly Tab On Mobile ESS
    Navigate Mobile ESS To Home Page
    Navigate To ESS Schedule Page On Mobile ESS
    Select Schedule Week Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${week_for_no_schedule}[week_start_date]
    Verify Schedule Not Published On Mobile ESS
    Select Schedule Day Tab On Mobile ESS
    Verify Schedule Not Published On Mobile ESS
    Select Schedule Month Tab On Mobile ESS
    Verify Schedule Not Published In Monthly Tab On Mobile ESS
    Logout Mobile ESS App From Top Level Page

    [Teardown]    Teardown Test Case    battc00225
