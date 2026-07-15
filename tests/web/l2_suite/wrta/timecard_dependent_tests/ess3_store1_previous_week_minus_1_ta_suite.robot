*** Settings ***
Documentation       Test Suite to verify ESS3_Store1 Previous Week -1 Timecard related scenarios

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Test Teardown       Run Keywords    Close Browser

Test Tags           action:write    bat_phase2    config:rta    timecard_previous_week_minus_1    module:timekeeping


*** Test Cases ***
BATTC00197: Verify user is able to add timecard punches crossing the day boundaries
    [Documentation]    Verify user is able to add timecard punches crossing the day boundaries
    [Tags]    dev:yogesh    battc00197
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user_3}    Get User    user_key=ESS3_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_3}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${punch_shift_data}    Get Timecard Punch Data
    ...    week_start_date=-2_0
    ...    shift_start_date=-2_2
    ...    punch_time=21:00
    ${punch_shift_data_2}    Get Timecard Punch Data    template_name=punch_end_data
    ...    week_start_date=-2_0
    ...    shift_start_date=-2_3
    ...    punch_time=04:00
    ${punch_shift_data_3}    Get Timecard Punch Data
    ...    week_start_date=-2_0
    ...    shift_start_date=-2_4
    ...    punch_time=21:00
    ${punch_shift_data_4}    Get Timecard Punch Data    template_name=punch_end_data
    ...    week_start_date=-2_0
    ...    shift_start_date=-2_5
    ...    punch_time=04:00
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${punch_shift_data}[week_start_date]
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web
    ...    ${punch_shift_data}[shift_start_date]    ${punch_shift_data_2}[shift_start_date]
    ...    ${punch_shift_data_3}[shift_start_date]    ${punch_shift_data_4}[shift_start_date]
    Add Punch On Timecard Page On Web    ${punch_shift_data}[shift_start_date]    ${punch_shift_data}[transaction_type]
    ...    ${punch_shift_data}[punch_time]    ${punch_shift_data}[reason_code]    ${punch_shift_data}[activity_code]

    ${is_meal_applicable}    Check Meal Applicability For User In DB    user_key=ESS3_STORE1
    IF    ${is_meal_applicable}
        ${lunch_shift_data_1}    Get Timecard Shift Data    template_name=lunch    week_start_date=-2_0    shift_start_date=-2_3
        ...    lunch_day=3    lunch_start_time=00:00    lunch_end_time=00:30
        ${date_format}    Get Config Value    key=DATE_FMT_DAY_NON_ZERO_PADDED
        ${formatted_date}    Calculate Date From Week Day Offset    ${lunch_shift_data_1}[shift_start_date]    ${date_format}
        Add Lunch On Timecard Page On Web    ${formatted_date}    ${lunch_shift_data_1}
    END

    Add Punch On Timecard Page On Web    ${punch_shift_data_2}[shift_start_date]    ${punch_shift_data_2}[transaction_type]
    ...    ${punch_shift_data_2}[punch_time]    ${punch_shift_data_2}[reason_code]    ${punch_shift_data_2}[activity_code]
    Add Punch On Timecard Page On Web    ${punch_shift_data_3}[shift_start_date]    ${punch_shift_data_3}[transaction_type]
    ...    ${punch_shift_data_3}[punch_time]    ${punch_shift_data_3}[reason_code]    ${punch_shift_data_3}[activity_code]
    Add Punch On Timecard Page On Web    ${punch_shift_data_4}[shift_start_date]    ${punch_shift_data_4}[transaction_type]
    ...    ${punch_shift_data_4}[punch_time]    ${punch_shift_data_4}[reason_code]    ${punch_shift_data_4}[activity_code]
    ${date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY

    ${formatted_date}    Calculate Date From Week Day Offset    ${punch_shift_data}[shift_start_date]    ${date_format}
    ${formatted_punch_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${punch_shift_data}[punch_time]
    Delete Shift On Timecard Page On Web    ${formatted_date}    ${formatted_punch_time}

    ${formatted_date_3}    Calculate Date From Week Day Offset    ${punch_shift_data_3}[shift_start_date]    ${date_format}
    ${formatted_punch_time_1}    Convert Time From 24 Hour To 12 Hour Format For Web    ${punch_shift_data_3}[punch_time]
    Delete Shift On Timecard Page On Web    ${formatted_date_3}    ${formatted_punch_time_1}

BATTC00200: Verify user is able to add timecard punches crossing the week boundaries
    [Documentation]    Verify user is able to add timecard punches crossing the week boundaries
    [Tags]    dev:komal    battc00200
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user_3}    Get User    user_key=ESS3_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_3}[displayName]
    Verify Timecard Page Is Loaded On Web
    Cleanup Cross Week Punches On Timecard Page
    Cleanup Second Cross Week Punch If Visible On Timecard Page
    Navigate To RTA Operations Exception Management Page On Web
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_3}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${punch_shift_data}    Get Timecard Punch Data
    ...    week_start_date=-2_0
    ...    shift_start_date=-2_6
    ...    punch_time=21:00
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${punch_shift_data}[week_start_date]
    Add Punch On Timecard Page On Web    ${punch_shift_data}[shift_start_date]    ${punch_shift_data}[transaction_type]
    ...    ${punch_shift_data}[punch_time]    ${punch_shift_data}[reason_code]    ${punch_shift_data}[activity_code]
    ${punch_shift_data_2}    Get Timecard Punch Data    template_name=punch_end_data
    ...    shift_start_date=-1_0
    ...    punch_time=01:00
    Add Punch On Timecard Page On Web    ${punch_shift_data_2}[shift_start_date]    ${punch_shift_data_2}[transaction_type]
    ...    ${punch_shift_data_2}[punch_time]    ${punch_shift_data_2}[reason_code]    ${punch_shift_data_2}[activity_code]
    ${is_punch_on_original_date}    Is Punch Shift Available On Timecard Page On Web    ${punch_shift_data}[shift_start_date]
    ...    ${punch_shift_data_2}[punch_time]
    IF    ${is_punch_on_original_date}
        Delete Punch On Timecard Page On Web    ${punch_shift_data}[shift_start_date]    ${punch_shift_data}[reason_code]
        ...    ${punch_shift_data_2}[punch_time]
    END
    IF    not ${is_punch_on_original_date}
        Navigate To Planning Week From Calendar On Timecard List Page On Web    ${punch_shift_data_2}[week_start_date]
        ${is_punch_on_second_date}    Is Punch Shift Available On Timecard Page On Web    ${punch_shift_data_2}[shift_start_date]
        ...    ${punch_shift_data_2}[punch_time]
        IF    ${is_punch_on_second_date}
            Delete Punch On Timecard Page On Web    ${punch_shift_data_2}[shift_start_date]    ${punch_shift_data}[reason_code]
            ...    ${punch_shift_data_2}[punch_time]
        END
    ELSE
        VAR    ${is_punch_on_second_date}    ${FALSE}
    END
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${punch_shift_data}[week_start_date]
    Delete Punch On Timecard Page On Web    ${punch_shift_data}[shift_start_date]    ${punch_shift_data}[reason_code]
    ...    ${punch_shift_data}[punch_time]

    ${is_punch_shift_visible}    Is Punch Shift Available On Timecard Page On Web    ${punch_shift_data}[shift_start_date]
    ...    ${punch_shift_data}[punch_time]
    ${is_punch_shift_2_visible_original}    Is Punch Shift Available On Timecard Page On Web    ${punch_shift_data}[shift_start_date]
    ...    ${punch_shift_data_2}[punch_time]
    VAR    ${is_punch_shift_2_visible_second}    ${FALSE}
    IF    ${is_punch_on_second_date}
        ${is_punch_shift_2_visible_second}    Is Punch Shift Available On Timecard Page On Web    ${punch_shift_data_2}[shift_start_date]
        ...    ${punch_shift_data_2}[punch_time]
    END
    Should Be True    not ${is_punch_shift_visible}
    ...    Start punch should have been deleted from timecard
    Should Be True    not ${is_punch_shift_2_visible_original}
    ...    End punch should have been deleted from original date on timecard
    Should Be True    not ${is_punch_shift_2_visible_second}
    ...    End punch should have been deleted from second date on timecard


*** Keywords ***
Cleanup Cross Week Punches On Timecard Page
    [Documentation]    This keyword will cleanup any remaining cross-week punches and shifts created during test execution
    ${punch_shift_data}    Get Timecard Punch Data
    ...    week_start_date=-2_0
    ...    shift_start_date=-2_6
    ...    punch_time=21:00
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${punch_shift_data}[week_start_date]
    ${start_punch_visible}    Is Punch Shift For Start Available On Timecard Page On Web    ${punch_shift_data}[shift_start_date]
    ...    ${punch_shift_data}[punch_time]
    IF    ${start_punch_visible}
        Delete Punch On Timecard Page On Web    ${punch_shift_data}[shift_start_date]    ${punch_shift_data}[reason_code]
        ...    ${punch_shift_data}[punch_time]
        Log    Cross-week Start punch cleanup completed successfully
    END
    ${is_punch_on_first_date}    Is Punch Shift Available On Timecard Page On Web    ${punch_shift_data}[shift_start_date]
    ...    ${punch_shift_data}[punch_time]
    IF    ${is_punch_on_first_date}
        Delete Punch On Timecard Page On Web    ${punch_shift_data}[shift_start_date]    ${punch_shift_data}[reason_code]
        ...    ${punch_shift_data}[punch_time]
        Log    Cross-week End punch cleanup completed successfully
    END
    TRY
        VAR    ${shift_day}    ${punch_shift_data}[shift_start_date]
        ${day}    Calculate Date From Week Day Offset    weekday_offset=${shift_day}    date_format=${timecard_date_format}
        Delete Shift On Timecard Page On Web    ${day}
        Log    First week Shift cleanup completed successfully
    EXCEPT
        Log    Failed to cleanup Shift    level=WARN
    END

Cleanup Second Cross Week Punch If Visible On Timecard Page
    [Documentation]    This keyword will cleanup the second cross-week punch if visible on timecard page
    ${punch_shift_data_2}    Get Timecard Punch Data    template_name=punch_end_data
    ...    shift_start_date=-1_0
    ...    punch_time=01:00
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${punch_shift_data_2}[week_start_date]
    ${is_punch_on_second_date}    Is Punch Shift Available On Timecard Page On Web    ${punch_shift_data_2}[shift_start_date]
    ...    ${punch_shift_data_2}[punch_time]
    IF    ${is_punch_on_second_date}
        Delete Punch On Timecard Page On Web    ${punch_shift_data_2}[shift_start_date]    ${punch_shift_data_2}[reason_code]
        ...    ${punch_shift_data_2}[punch_time]
        Log    Second punch cleanup completed successfully
    END
    TRY
        VAR    ${shift_day}    ${punch_shift_data_2}[shift_start_date]
        ${day}    Calculate Date From Week Day Offset    weekday_offset=${shift_day}    date_format=${timecard_date_format}
        Delete Shift On Timecard Page On Web    ${day}
        Log    Second cross-week Shift cleanup completed successfully
    EXCEPT
        Log    Failed to cleanup second cross-week Shift    level=WARN
    END
