*** Settings ***
Documentation       Test case for verifying Functionality Of Release From Store On Roster Page

Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/week_schedule.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:write    battc00046    config:add_edit_delete_release_to_store    bat_phase1
...                 config:weekplan_and_schedule_gen    om_hr


*** Test Cases ***
BATTC00046: Verify release of associate from one store to another from roster page
    [Documentation]    Test case for verifying Functionality Of Release From Store On Roster Page
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Schedule Week Schedule Page On Web
    Wait Until Page Is Loaded
    Navigate To RWS Employee Roster Page On Web
    ${user}    Get User    user_key=ESS3_STORE1
    VAR    ${employee_name}    ${user}[displayName]
    Search Employee On Roster Page On Web    ${employee_name}
    Click On First Employee Name On Roster Page On Web
    ${release_store_details}    Get Store Data    template_name=model_store2
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${shift_data}    Get Schedule Generation Setup Data    template_name=8_0_sm1_store1
    VAR    ${eff_day}    ${shift_data}[week_start_date]
    ${day}    Calculate Date From Week Day Offset    weekday_offset=${eff_day}    date_format=${timecard_date_format}
    Add And Verify Release To Store Request For Selected Employee    store_name=${release_store_details}[store_id]    effective_date=${day}
    [Teardown]    Run Keyword And Ignore Error    Delete And Verify Release To Store Request On Roster Page On Web
