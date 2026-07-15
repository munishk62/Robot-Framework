*** Settings ***
Documentation       This test suite verifies if user is able to generate Forecast/Workload/Schedule

Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/all_schedules.resource
Resource            resources/web/rws/schedule/plan_status.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:write


*** Test Cases ***
WFM-20 Verify Whether User Is Able To Generate Forecast/Workload/Schedule
    [Documentation]    Test case for verifying whether user is able to generate forecast/workload/schedule
    [Tags]    generate_fcst_wkld_schd
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${store_data}    Get Store Data
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    ${unpublished_schedule_status}    Get System Value    ScheduleStatus    UNPUBLISHED_SCHEDULE
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    Navigate To RWS Schedule All Schedules Page On Web
    Select Unscheduled Week On All Schedules Page On Web
    Capture Screenshot On Webpage
    Generate Week Plan On Plan Status Page On Web
    Verify If Generate Week Plan Is Completed On Plan Status Page On Web
    Generate Workload On Plan Status Page On Web
    Verify If Generate Workload Is Completed On Plan Status Page On Web
    Generate Optimized Schedule On Plan Status Page On Web
    Verify If Generate Optimized Schedule Is Completed On Plan Status Page On Web
    Go To Schedule Page On Web
    Verify If Schedule Status Is Displayed As Expected On Plan Status Page On Web    ${unpublished_schedule_status}
    Delete Current Schedule On Plan Status Page On Web
    Delete The Workload On Plan Status Page On Web
    Switch To Home From Store On Web
