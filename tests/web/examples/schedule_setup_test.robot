*** Settings ***
Documentation       Sample test cases to understand use of some keywords and libraries. To run this locally please remove robot:skip tag

#    Schedule Setup flow
# 1. gather setup flags from template
# 2. WIP logic. TBD later
# 3. get genshift id & status for week. WHY is staus needed here.
# 4. If genshiftid is +ve but not wip
#    - clear Schedule - if publish - unublish and delete
# 5. gen forecast
# 6. generate workload
# 7. if schedule gen required. gen schedule.
#    - wait till schedule gen complete.
#    - hit generate scheule via batch api.
#    - wait till batch completes. by checking genshift id in a loop.
# 8. if modify shifs required
#    unallocate shift for users
#    delete open shifts
#    add shifts
# 9. pre pubishih shift operations - unallocations
# 10. if publish required - publish schedule.
Library             DateTime
Library             Browser
# Use the consolidated test data library
Library             test_data/TestDataLibrary.py
Resource            resources/web/authentication/login.resource
Resource            resources/web/common/common_date_utility.resource
Resource            resources/web/rws/schedule/schedule.resource
Resource            resources/web/rws/schedule/schedule_setup.resource
Resource            resources/web/om/unit_db.resource
Resource            resources/web/rws/employee/roster_db.resource

Test Tags           schedule_setup_new


*** Variables ***
${ZEROTH_WEEK_OFFSET}       12


*** Test Cases ***
Schedule Setup Week1
    [Documentation]    Example of using new parameterized schedule setup keyword.
    [Tags]    week1
    ${WEEK_OFFSET}=    Get Relative Week Offset    1
    ${smuser}=    Get User    SM1_STORE1
    ${workflow}=    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=${WEEK_OFFSET}
    ...    week_offset=${WEEK_OFFSET}    _date_format=%Y%m%d
    ${ess1_store1}=    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS1_STORE1
    ${ess6_store1}=    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS6_STORE1
    VAR    @{employee_operations}=    ${ess1_store1}    ${ess6_store1}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Schedule Setup Week2
    [Documentation]    Example of using new parameterized schedule setup keyword.
    ${smuser}=    Get User    SM1_STORE1
    ${WEEK_OFFSET}=    Get Relative Week Offset    2
    ${workflow}=    Get Schedule Workflow Setup Data    template_name=no_schedule_generation    week_start_date=${WEEK_OFFSET}
    ...    week_offset=${WEEK_OFFSET}    _date_format=%Y%m%d
    VAR    @{employee_operations}=    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Schedule Setup Week3
    [Documentation]    Example of using new parameterized schedule setup keyword.
    ${smuser}=    Get User    SM1_STORE1
    ${WEEK_OFFSET}=    Get Relative Week Offset    3
    ${workflow}=    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=${WEEK_OFFSET}
    ...    week_offset=${WEEK_OFFSET}    _date_format=%Y%m%d
    ${ess5_store1}=    Get Employee Shift Setup Data    template_name=add123_standard8_addunallocate6    ess_user_key=ESS5_STORE1
    ${ess6_store1}=    Get Employee Shift Setup Data    template_name=add012_standard8    ess_user_key=ESS6_STORE1
    ${ess4_store1}=    Get Employee Shift Setup Data    template_name=add012_standard8    ess_user_key=ESS4_STORE1
    VAR    @{employee_operations}=    ${ess5_store1}    ${ess6_store1}    ${ess4_store1}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Schedule Setup Week5
    [Documentation]    Example of using new parameterized schedule setup keyword.
    # 5_0_sm1_store1
    ${smuser}=    Get User    SM1_STORE1
    ${WEEK_OFFSET}=    Get Relative Week Offset    5
    ${workflow}=    Get Schedule Workflow Setup Data    template_name=generate_and_publish_schedule    week_start_date=${WEEK_OFFSET}
    ...    week_offset=${WEEK_OFFSET}    _date_format=%Y%m%d
    ${ess4_store1}=    Get Employee Shift Setup Data    template_name=add012_standard8    ess_user_key=ESS4_STORE1
    VAR    @{employee_operations}=    ${ess4_store1}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}

Schedule Setup Week6 And Week8
    [Documentation]    Example of using new parameterized schedule setup keyword.
    # 6_0_sm1_store1
    ${smuser}=    Get User    SM1_STORE1
    ${WEEK_OFFSET}=    Get Relative Week Offset    6
    ${workflow}=    Get Schedule Workflow Setup Data    template_name=only_generate_schedule    week_start_date=${WEEK_OFFSET}
    ...    week_offset=${WEEK_OFFSET}    _date_format=%Y%m%d
    ${ess4_store1}=    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS4_STORE1
    ${ess2_store1}=    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS2_STORE1
    ${ess1_store1}=    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS1_STORE1
    ${ess5_store1}=    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS5_STORE1
    ${ess6_store1}=    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS6_STORE1
    ${ess3_store1}=    Get Employee Shift Setup Data    template_name=no_shifts_assigned    ess_user_key=ESS3_STORE1
    VAR    @{employee_operations}=
    ...    ${ess4_store1}
    ...    ${ess2_store1}
    ...    ${ess1_store1}
    ...    ${ess5_store1}
    ...    ${ess6_store1}
    ...    ${ess3_store1}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}
    ${WEEK_OFFSET8}=    Get Relative Week Offset    8
    ${workflow}=    Get Schedule Workflow Setup Data    template_name=no_schedule_generation    week_start_date=${WEEK_OFFSET8}
    ...    week_offset=${WEEK_OFFSET8}    _date_format=%Y%m%d
    VAR    @{employee_operations}=    @{EMPTY}
    Pre Setup Store Schedule For Week    ${smuser}    ${workflow}    ${employee_operations}


*** Keywords ***
Get Relative Week Offset
    [Documentation]    Increments the week offset number by 1 and appends _0 to it.
    [Arguments]    ${increment_by}=1
    ${WEEK_OFFSET_NO}=    Evaluate    ${ZEROTH_WEEK_OFFSET} + ${increment_by}
    ${WEEK_OFFSET}=    Evaluate    "${WEEK_OFFSET_NO}" + "_0"
    RETURN    ${WEEK_OFFSET}
