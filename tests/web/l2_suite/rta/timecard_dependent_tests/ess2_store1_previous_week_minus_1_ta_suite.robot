*** Settings ***
Documentation       Test Suite to verify ESS2_Store1 Previous Week -1 Timecard related scenarios

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rta/operations/timecard_list.resource

Test Teardown       Run Keywords    Close Browser

Test Tags           bat_phase1    config:rta    timecard_previous_week_minus_1


*** Test Cases ***
BATTC00079: Verify timecard audit details
    [Documentation]    Verify Audit Tab And Audit Reports
    [Tags]    action:write    dev:yogesh    battc00079    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user_2}    Get User    user_key=ESS2_STORE1
    ${store_data}    Get Store Data
    Navigate To RTA Operations Exception Management Page On Web
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_2}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${audit_punch_data}    Get Timecard Punch Data
    ...    week_start_date=-2_0
    ...    shift_start_date=-2_1
    ...    punch_time=13:00
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${audit_punch_data}[week_start_date]
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${audit_punch_data}[shift_start_date]
    Add Punch On Timecard Page On Web    ${audit_punch_data}[shift_start_date]    ${audit_punch_data}[transaction_type]
    ...    ${audit_punch_data}[punch_time]    ${audit_punch_data}[reason_code]    ${audit_punch_data}[activity_code]
    Remove Added Punches And Shifts On Timecard Page On Web
    ${audit_data}    Get Timecard Audit Data
    Verify The Audit Tab Details For The Performed Punch Transactions On Timecard Page On Web    ${audit_data}[start_time]
    ...    ${audit_data}[shift_start_date]    ${store_data}[store_id]
    Log Out From Web Application

BATTC00080: Verify the user is able to review the timecard pay results summary and detail
    [Documentation]    Test case to verify the user is able to review the timecard pay results summary and detail
    [Tags]    action:write    battc00080    dev:bushra    config:rws    config:sm_wage_display    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user}    Get User    user_key=ESS2_STORE1
    ${shift_data}    Get Timecard Shift Data    shift_day=-2_3
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${shift_data}[shift_day]
    ${shift_added_date}    ${formatted_start_time}    ${formatted_end_time}    Add Shift On Exception Management Page On Web
    ...    ${shift_data}
    Log    Shift added with start time: ${formatted_start_time} and end time: ${formatted_end_time} on date: ${shift_added_date}
    Navigate To Pay Results Section On Web
    ${default_view_type}    Get System Value    PayResultsViewType    SUMMARY
    Verify Default View In Pay Results Section On Web    ${default_view_type}
    Verify Summary View Data For Added Shift In Pay Results Section On Web    ${shift_added_date}
    ${detailed_view_type}    Get System Value    PayResultsViewType    DETAILED
    Select View In Pay Results Section On Web    ${detailed_view_type}
    Verify Detailed View Data For Added Shift In Pay Results Section On Web    ${shift_added_date}
    Navigate To Timecard Section On Web
    Delete Shift On Timecard Page On Web    ${shift_added_date}    ${formatted_start_time}
    Navigate To Pay Results Section On Web
    ${is_visible}    Verify Pay Results Data Not Visible For Deleted Shift    ${shift_added_date}
    IF    ${is_visible}
        Fail    Pay results data is still visible for deleted shift on date: ${shift_added_date}
    END

BATTC00081: Verify the ability to review legends, add/edit/delete notes in timecard
    [Documentation]    This test case is to verify Timecard page Legends and to add, edit and delete Daily and Weekly Notes.
    [Tags]    dev:moiz    action:write    battc00081    config:timecard_edit_notes    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${user}    Get User    user_key=ESS2_STORE1
    ${timecard_notes_data}    Get Timecard Notes Data
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${timecard_notes_data}[start_date]
    Search & Click On Clock For Employee On Exception Management Page On Web    ${user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Verify My Timecard Page Legend On Web
    Verify Labels Displayed Under Legend Categories On My Timecard Page On Web
    Close My Timecard Page Legend On Web
    # Cleanup existing notes
    Cleanup All Existing Daily And Weekly Notes On Timecard List Page On Web
    # Daily Notes
    Add Note In Daily Notes Table At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_1]
    ...    ${timecard_notes_data}[notes_day_1]
    Verify Daily Note Added At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_1]
    ...    ${timecard_notes_data}[notes_day_1]
    Add Note In Daily Notes Table At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_2]
    ...    ${timecard_notes_data}[notes_day_2]
    Verify Daily Note Added At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_2]
    ...    ${timecard_notes_data}[notes_day_2]
    # Weekly Notes
    Add Note In Weekly Notes Table On Timecard List Page On Web    ${timecard_notes_data}[weekly_notes]
    Verify Note Added In Weekly Notes On Timecard List Page On Web    ${timecard_notes_data}[weekly_notes]
    Add Note In Weekly Notes Table On Timecard List Page On Web    ${timecard_notes_data}[edited_weekly_notes]${user}[displayName]
    Verify Note Added In Weekly Notes On Timecard List Page On Web
    ...    ${timecard_notes_data}[edited_weekly_notes]${user}[displayName]
    Navigate To Previous Week On Timecard List Page On Web
    Go To Notes Tab On Timecard List Page On Web
    Verify Daily Note Empty At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_1]
    Verify Daily Note Empty At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_2]
    Verify Weekly Note Empty On Timecard List Page On Web
    Navigate To Next Week On Timecard List Page On Web
    Go To Notes Tab On Timecard List Page On Web
    Verify Daily Note Added At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_1]
    ...    ${timecard_notes_data}[notes_day_1]
    Verify Daily Note Added At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_2]
    ...    ${timecard_notes_data}[notes_day_2]
    Verify Note Added In Weekly Notes On Timecard List Page On Web
    ...    ${timecard_notes_data}[edited_weekly_notes]${user}[displayName]
    Delete Note In Weekly Notes Table On Timecard List Page On Web
    Verify Weekly Note Empty On Timecard List Page On Web
    Delete Note In Daily Notes Table At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_2]
    Verify Daily Note Empty At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_2]
    Delete Note In Daily Notes Table At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_1]
    Verify Daily Note Empty At Row Number On Timecard List Page On Web    ${timecard_notes_data}[day_1]

BATTC00069: Verify pay statistics on exception management page
    [Documentation]    This test case is to verify pay statistics on exception management page
    [Tags]    dev:bushra    action:write    battc00069    config:display_pay_statistics    module:timekeeping
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user}    Get User    user_key=ESS2_STORE1
    ${shift_data}    Get Timecard Shift Data    shift_day=-2_4
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    ${warning_count_of_emp}    Get Warning Count Of Specific Employee On Web    ${ess_user}[displayName]
    Log    Warning count of employee ${ess_user}[displayName]: ${warning_count_of_emp}
    Verify Bottom Tabs Visible On Exception Management Page On Web
    ${total_hours_before_adding_shift}    Capture Total Hours On Exception Management Page On Web
    Log    Total hours before adding shift: ${total_hours_before_adding_shift}
    Verify Total Hours Count In Bottom Tab On Exception Management Page On Web    ${total_hours_before_adding_shift}
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${shift_added_date}    ${formatted_start_time}    ${formatted_end_time}    Add Shift On Exception Management Page On Web
    ...    ${shift_data}
    Log    Shift Created For Date: ${shift_added_date}, Start Time: ${formatted_start_time}, End Time: ${formatted_end_time}
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    ${total_hours_after_adding_shift}    Capture Total Hours On Exception Management Page On Web
    Log    Total hours after adding shift: ${total_hours_after_adding_shift}
    Verify Total Hours Count In Bottom Tab On Exception Management Page On Web    ${total_hours_after_adding_shift}
    Should Be True    ${total_hours_after_adding_shift} > ${total_hours_before_adding_shift}
    ...    Total hours on Exception Management page did not increase after adding shift.
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Delete Shift On Timecard Page On Web    ${shift_added_date}    ${formatted_start_time}
    Log    Shift deleted for date: ${shift_added_date}, Start Time: ${formatted_start_time}
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    ${total_hours_after_deleting_shift}    Capture Total Hours On Exception Management Page On Web
    Log    Total hours after deleting shift: ${total_hours_after_deleting_shift}
    Should Be Equal As Numbers    ${total_hours_after_deleting_shift}    ${total_hours_before_adding_shift}
    ...    Total hours on Exception Management page did not return to original value after deleting shift.


*** Keywords ***
Remove Added Punches And Shifts On Timecard Page On Web
    [Documentation]    This keyword will remove added punches and shifts on timecard page
    ${audit_punch_data}    Get Timecard Punch Data
    ...    week_start_date=-2_0
    ...    shift_start_date=-2_1
    ...    punch_time=13:00
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${day}    Calculate Date From Week Day Offset    weekday_offset=${audit_punch_data}[shift_start_date]
    ...    date_format=${timecard_date_format}
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${audit_punch_data}[week_start_date]
    Delete Punch On Timecard Page On Web    ${audit_punch_data}[shift_start_date]    ${audit_punch_data}[reason_code]
    ...    ${audit_punch_data}[punch_time]
    Remove Shift On Timecard Page On Web    ${day}
