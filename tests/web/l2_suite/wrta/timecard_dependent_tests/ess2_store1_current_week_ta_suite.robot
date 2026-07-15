*** Settings ***
Documentation       Test Suite to verify ESS2_Store1 Current Week Timecard related scenarios

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Test Teardown       Run Keywords    Close Browser

Test Tags           bat_phase1    config:rta    timecard_current_week


*** Test Cases ***
BATTC00101: Verify timecard page for ESS user
    [Documentation]    Verify ESS user is able to land on My Timecard page and all elements are displayed correctly
    [Tags]    action:write    battc00101    dev:bushra    config:ess    module:timekeeping

    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user}    Get User    user_key=ESS2_STORE1
    ${store_data}    Get Store Data
    VAR    ${store_name}    ${store_data}[store_id] - ${store_data}[store_name]
    ${shift_data_previous_week}    Get Timecard Shift Data    shift_day=-1_6
    Navigate To RTA Operations Exception Management Page On Web
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    ${activity_code_present}    Verify Activity Code Field Present In Add Shift On Exception Management Page On Web
    Log    Activity Code field present status: ${activity_code_present}
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data_previous_week}[shift_day]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${shift_data_previous_week}[shift_day]
    ${shift_added_date1}    ${formatted_start_time1}    ${formatted_end_time1}    Add Shift On Exception Management Page On Web
    ...    ${shift_data_previous_week}
    Log
    ...    Shift added on previous week date: ${shift_added_date1} with start time: ${formatted_start_time1} and end time: ${formatted_end_time1}
    ${shift_data_current_week}    Get Timecard Shift Data    shift_day=0_0
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data_current_week}[shift_day]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${shift_data_current_week}[shift_day]
    ${shift_added_date2}    ${formatted_start_time2}    ${formatted_end_time2}    Add Shift On Exception Management Page On Web
    ...    ${shift_data_current_week}
    Log
    ...    Shift added on current week date: ${shift_added_date2} with start time: ${formatted_start_time2} and end time: ${formatted_end_time2}
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS2_STORE1
    Navigate To ESS My Timecard Page On Web
    Verify Timecard Loaded For Current Week On My Timecard Page On Web
    Verify My Timecard Page Legend On Web
    Verify Labels Displayed Under Legend Categories On My Timecard Page On Web
    Close My Timecard Page Legend On Web
    ${is_audit_tab_present}    Switch To Audit Tab On My Timecard Page On Web
    IF    ${is_audit_tab_present}
        ${audit_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
        ${current_date}    Get Current Date As Per Specific Timezone    ${audit_date_format}    ${store_data}[store_id]
        Verify Audit Tab Time Format On My Timecard Page On Web    ${current_date}
        Verify Audit Tab Details For Added Shift On My Timecard Page On Web    ${current_date}    Added
        ...    ${shift_data_current_week}[start_time]    ${store_name}
    ELSE
        Log    Audit tab is not available, skipping audit tab verification.
    END
    Switch To Timecard Tab On My Timecard Page On Web
    Verify My Timecard Page Grid On Web    ${activity_code_present}
    Navigate To Previous Week On My Timecard Page On Web
    Navigate To Next Week On My Timecard Page On Web
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data_previous_week}[shift_day]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Delete Shift On Timecard Page On Web    ${shift_added_date1}    ${formatted_start_time1}

    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data_current_week}[shift_day]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Delete Shift On Timecard Page On Web    ${shift_added_date2}    ${formatted_start_time2}
    Log Out From Web Application

    Login And Launch WFM Web App    user_key=ESS2_STORE1
    Navigate To ESS My Timecard Page On Web
    Verify Timecard Loaded For Current Week On My Timecard Page On Web
    ${punch_count_current_week}    Get Time Card Punch Count For Specific Date On My Timecard Page On Web    ${shift_added_date2}
    ...    ${formatted_start_time2}
    Should Be Equal As Integers    ${punch_count_current_week}    0
    ...    msg=Punches were not deleted for current week date ${shift_added_date2}
    Navigate To Previous Week On My Timecard Page On Web
    ${punch_count_previous_week}    Get Time Card Punch Count For Specific Date On My Timecard Page On Web    ${shift_added_date1}
    ...    ${formatted_start_time1}
    Should Be Equal As Integers    ${punch_count_previous_week}    0
    ...    msg=Punches were not deleted for previous week date ${shift_added_date1}
    Log Out From Web Application
