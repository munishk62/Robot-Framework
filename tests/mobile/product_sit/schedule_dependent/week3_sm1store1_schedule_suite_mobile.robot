*** Settings ***
Documentation       BATTC00226 - Verify the monthly schedule view by using the month navigators for ESS user in mobility

Library             pabot.PabotLib
Resource            resources/Mobile/ESS/PagesResources/Schedule/Schedule_Landing_page.resource
Resource            resources/Mobile/ESS/PagesResources/Schedule/Schedule_Month_Tab.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/common/schedule_setup/common_schedule_setup.resource

Suite Setup         Run Only Once    Pre Setup Schedule For Week 3 SM1Store1
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           week3_sm1store1
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00226: Verify the monthly schedule view by using the month navigators for ESS user in mobility
    [Documentation]    Verify the monthly schedule view by using the month navigators for ESS user in mobility
    [Tags]    dev:bushra    battc00226    bat_phase2    config:ess    config:rws    config:weekplan_and_schedule_gen    mobile
    ...    schedule_dependent    checkschedulesetup
    Open Mobile ESS App    battc00226
    ${week_for_published_schedule}    Get Schedule Generation Setup Data    template_name=3_0_sm1_store1
    ${day_for_no_shift}    Combine Week Offset And Day No    ${week_for_published_schedule}[week_start_date]    3
    Login Mobile Ess App    ESS4_STORE1
    Navigate To ESS Schedule Page On Mobile ESS
    Select Schedule Week Tab On Mobile ESS
    Navigate Mobile ESS Week Schedule To    ${week_for_published_schedule}[week_start_date]
    Select Schedule Month Tab On Mobile ESS
    ${schedule_data}    Get Employee Shift Setup Data    template_name=add012_standard8    ess_user_key=ESS4_STORE1
    Verify Shift Details In Month Tab As Per Schedule On Mobile ESS    ${schedule_data}    ${week_for_published_schedule}[week_start_date]
    Verify Shift Not Present For The Selected Day On Mobile ESS    ${day_for_no_shift}
    Logout Mobile ESS App From Top Level Page

    [Teardown]    Teardown Test Case    battc00226
