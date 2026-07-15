*** Settings ***
Documentation       BATTC00126 - This test case verifies that SM user can add, edit, approve and delete day off request on SM mobile app.

Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keywords
...        Clean Up Day Off Request For User On Date    ESS5_STORE1    SM1_STORE1    start_date_offset=6_2    end_date_offset=6_2    AND
...        Clean Up Day Off Request For User On Date    ESS5_STORE1    SM1_STORE1    start_date_offset=6_3    end_date_offset=6_5

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:kishan    battc00126    mobile    bat_phase2    config:rws    config:ess_add_edit_delete_dayoff
...    config:holiday_hours_disabled
...    config:mobile_sm_enabled


*** Test Cases ***
BATTC00126: Verify SM user is able to add/edit/delete/approve day off requests in mobility
    [Documentation]    Verify SM user can add, edit, approve and delete day off request on SM mobile app
    ${day_off_reason}    Get System Value    DayOffReasonType    PAID_VACATION
    ${day_off_data1}    Get Day Off Data    reason=${day_off_reason}    start_date=6_1    end_date=6_1    edit_start_date=6_2
    ...    edit_end_date=6_2
    ${day_off_data2}    Get Day Off Data    reason=${day_off_reason}    start_date=6_2    end_date=6_6    edit_start_date=6_3
    ...    edit_end_date=6_5
    Open SM Native Application On Mobile Phone    battc00126
    Login SM App On Mobile    SM1_STORE1
    Navigate To Request On SM Phone App
    Add Day Off Details On SM Phone App    ESS5_STORE1    ${day_off_data1}[reason]    ${day_off_data1}[start_date]
    ...    ${day_off_data1}[end_date]
    Request Calendar Navigation On SM Phone App    ${day_off_data1}[start_date]
    Select Request On SM Phone App    ESS5_STORE1
    Edit Day Off Details On SM Phone App    start_date=${day_off_data1}[start_date]
    ...    edit_start_date=${day_off_data1}[edit_start_date]    edit_end_date=${day_off_data1}[edit_end_date]
    Request Calendar Navigation On SM Phone App    ${day_off_data1}[edit_start_date]    ${day_off_data1}[edit_start_date]
    Select Request On SM Phone App    ESS5_STORE1
    Approve Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${day_off_data1}[edit_start_date]    ${day_off_data1}[edit_start_date]
    Select Request On SM Phone App    ESS5_STORE1
    Verify Day Off Details On SM Phone App    ${day_off_data1}[edit_start_date]    ${day_off_data1}[edit_end_date]    total_days=1    reason=${day_off_data1}[reason]    status=${day_off_data1}[status_after_approval]
    Delete Request On SM Phone App

    Navigate To Request On SM Phone App
    Add Day Off Details On SM Phone App    ESS5_STORE1    ${day_off_data2}[reason]    ${day_off_data2}[start_date]
    ...    ${day_off_data2}[end_date]
    Request Calendar Navigation On SM Phone App    ${day_off_data2}[start_date]
    Select Request On SM Phone App    ESS5_STORE1
    Edit Day Off Details On SM Phone App    start_date=${day_off_data2}[start_date]
    ...    edit_start_date=${day_off_data2}[edit_start_date]    edit_end_date=${day_off_data2}[edit_end_date]
    Request Calendar Navigation On SM Phone App    ${day_off_data2}[edit_start_date]    ${day_off_data2}[edit_start_date]
    Select Request On SM Phone App    ESS5_STORE1
    Approve Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${day_off_data2}[edit_start_date]    ${day_off_data2}[edit_start_date]
    Select Request On SM Phone App    ESS5_STORE1
    Verify Day Off Details On SM Phone App    ${day_off_data2}[edit_start_date]    ${day_off_data2}[edit_end_date]    total_days=3    reason=${day_off_data2}[reason]    status=${day_off_data2}[status_after_approval]

    [Teardown]    Teardown Test Case    battc00126
