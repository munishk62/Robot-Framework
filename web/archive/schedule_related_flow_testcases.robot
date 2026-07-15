*** Settings ***
Documentation       Test Case to Verify Schedule Generation And Edit Shift Operations For Two Associates

Resource            resources/web/authentication/login.resource
Resource            resources/web/roster/template_calendar.resource
Resource            resources/web/rws/schedule/fixed_shifts.resource
Resource            resources/web/rws/schedule/batch_plan_status.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/rws/schedule/all_schedules.resource


*** Test Cases ***
Verify Schedule Generation And Edit Shift Operations For Two Associates
    [Documentation]    Verify Schedule Generation And Edit Shift Operations For Two Associates
    ...    create and map work pattern to store in Template Calendar,
    ...    create two templates by mapping work pattern to store,
    ...    generate workload and schedule,
    ...    perform edit shift operation on week schedule page for two associates.
    [Tags]    dev:yogesh    config:rta    action:write

    ${corp_user}=    Get User    user_key=SYSADMIN
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user3}=    Get User    user_key=ESS1_STORE5
    ${ess_user4}=    Get User    user_key=ESS4_STORE5

    # Get test data from JSON templates - following payroll test pattern
    ${work_pattern_data}=    Get Work Pattern Data

    # Test execution steps - pass individual data elements like payroll test

    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To Template Calendar Page On Web
    Create New Work Pattern On Web    work_pattern_name=${work_pattern_data}[work_pattern_name]
    Select Store For Work Pattern Mapping On Web    store_id=${work_pattern_data}[store_id]
    Map Work Pattern To Store On Web    planning_week_start_date=${work_pattern_data}[planning_week_start_date]
    ...    work_pattern_name=${work_pattern_data}[work_pattern_name]
    Verify Work Pattern Mapping Success On Web
    Close Browser

    # Associate template new blank template map workpatern create shift lock all

    ${fixed_shift_data}=    Get Add Associate Template Data
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${template_number1}=    Add New Blank Template Assign Shift By Mapping Work Pattern On Associate Template Page On Web
    ...    ${ess_user3}[displayName]    ${fixed_shift_data}[week_start_date]    ${work_pattern_data}[work_pattern_name]
    ...    ${fixed_shift_data}[shift_days]
    ${fixed_shift_data_associate2}=    Get Add Associate Template Data    template_name=associate2_shift_details
    ${template_number2}=    Add New Blank Template Assign Shift By Mapping Work Pattern On Associate Template Page On Web
    ...    ${ess_user4}[displayName]    ${fixed_shift_data_associate2}[week_start_date]    ${work_pattern_data}[work_pattern_name]
    ...    ${fixed_shift_data_associate2}[shift_days]
    Navigate To Review Fixed Shifts Page And Regenerate The Latest Shift Times For Required Planning Week On Web
    ...    ${work_pattern_data}[planning_week_start_date]
    Close Browser

    # create workload ,forcast and generate template schedule then edit shift and publish it

    ${batch_plan_data}=    Get Batch Plan Data
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To All Schedule Page Switch To Plan Status Page For Given Planning Week On Web    ${batch_plan_data}[week_start_date]
    Clear Existing Generated Data On Batch Plan Status Page On Web
    Generate Forecast Workload Schedule And Publish On Batch Plan Status Page On Web    ${batch_plan_data}[regenerate_forecast_required]
    ...    ${batch_plan_data}[schedule_type]    ${batch_plan_data}[do_publish_schedule]
    Close Browser
    # perform edit operation on week schedule page

    ${edit_shift_data}=    Get Schedule Shift Data
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Perform Shift Edit Operation On Week Schedule Page On Web    ${edit_shift_data}[week_start_date]    ${ess_user4}[displayName]
    ...    ${ess_user3}[displayName]    ${edit_shift_data}[shift_start_time]    ${edit_shift_data}[shift_end_time]
    ...    ${edit_shift_data}[edit_shift_start_time]    ${edit_shift_data}[edit_shift_end_time]    ${edit_shift_data}[shift_add_day]

    # then shift tradeboard operation like swap shift,assign open shift,unassign shift    then unpublish it

    [Teardown]    Run Keyword And Continue On Failure
    ...    Delete Work Pattern Based Template And Verify Api Success On Web    ${sm_user}[user_key]    ${template_number1}    Close Browser    AND
    ...    Delete Work Pattern Based Template And Verify Api Success On Web    ${sm_user}[user_key]    ${template_number2}    Close Browser    AND
    ...    Clear Generated Schedule And Workload If Exists On Web    ${sm_user}[user_key]    ${work_pattern_data}[planning_week_start_date]    Close Browser    AND
    ...    Unmap Work Pattern From Planning Week And Verify Api Success On Web    ${corp_user}[user_key]    ${work_pattern_data}[planning_week_start_date]    ${work_pattern_data}[work_pattern_name]    ${work_pattern_data}[store_id]    Close Browser    AND
    ...    Delete Work Pattern And Verify APi Success On Web    ${corp_user}[user_key]    ${work_pattern_data}[work_pattern_name]    Close Browser
