*** Settings ***
Documentation       This test case is to verify warnings on exception management page.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Test Tags           action:write    battc00078    config:rta    dev:yogesh    obsolete    bat_phase1    module:timekeeping


*** Test Cases ***
BATTC00078: Verify review warning details in timecard page
    [Documentation]    Verifies that appropriate warning messages are displayed on the Timecard page
    ...    when specific conditions or validation rules are triggered. This test ensures
    ...    the system shows alerts to potential issues or required actions
    ...    related to timecard shifts
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user_2}    Get User    user_key=ESS2_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    ${shift_data}    Get Timecard Shift Data    shift_day=-2_0
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    ${original_unscheduled_absence}    Get Unscheduled Absence Count Of Specific Employee On Web    emp_name=${ess_user_2}[displayName]
    ${original_unscheduled_work_count}    Get Unscheduled Work Count Of Specific Employee On Web    emp_name=${ess_user_2}[displayName]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_2}[displayName]
    Verify Timecard Page Is Loaded On Web
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${shift_data}[shift_day]
    ${shift_added_date}    ${formatted_start_time}    ${_}    Add Shift On Exception Management Page On Web
    ...    ${shift_data}
    Verify Warning Icon Visible For Specific Shift On Web    ${shift_added_date}    ${formatted_start_time}
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    ${updated_unscheduled_absence}    Get Unscheduled Absence Count Of Specific Employee On Web    emp_name=${ess_user_2}[displayName]
    Should Be Equal    ${updated_unscheduled_absence}    ${original_unscheduled_absence}
    ...    Unscheduled work absence count changed unexpectedly after adding shift.
    ${updated_unscheduled_work}    Get Unscheduled Work Count Of Specific Employee On Web    emp_name=${ess_user_2}[displayName]
    ${expected_unscheduled_work}    Evaluate    ${original_unscheduled_work_count} + 1
    Should Be Equal    ${updated_unscheduled_work}    ${expected_unscheduled_work}
    ...    Unscheduled work count is not incremented by 1 after adding shift.
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_2}[displayName]
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${shift_data}[shift_day]
    Delete Shift On Timecard Page On Web    ${shift_added_date}    ${formatted_start_time}
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    ${absence_count_after_shift_del}    Get Unscheduled Absence Count Of Specific Employee On Web
    ...    emp_name=${ess_user_2}[displayName]
    Should Be Equal    ${original_unscheduled_absence}    ${absence_count_after_shift_del}
    ${unscheduled_work_count_after_shift_del}    Get Unscheduled Work Count Of Specific Employee On Web
    ...    emp_name=${ess_user_2}[displayName]
    Should Be Equal    ${original_unscheduled_work_count}    ${unscheduled_work_count_after_shift_del}
