*** Settings ***
Documentation       battc00191 - This test case verifies that SM user can add, edit, approve and delete day off request with holiday hours on SM Phone app.

Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Clean Up Day Off Request For User On Date    ESS5_STORE2    SM1_STORE2    start_date_offset=4_2    end_date_offset=4_2

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:ashish    battc00191    mobile    bat_phase2    config:rws    config:ess_add_edit_delete_dayoff
...    config:holiday_hours_enabled
...    config:mobile_sm_enabled


*** Test Cases ***
BATTC00191: Verify SM user is able to add/edit/delete/approve day off requests with holiday hours in mobility
    [Documentation]    Verify SM user can add, edit, approve and delete day off request with holiday hrs on SM Phone app
    ${day_off_reason}    Get System Value    DayOffReasonType    PAID_VACATION
    ${approved_status}    Get System Value    RequestStatus    APPROVED
    VAR    &{holiday_hrs}    2=8
    ${day_off_data}    Get Day Off Data
    ...    start_date=4_2
    ...    end_date=4_2
    ...    reason=${day_off_reason}
    ...    holiday_hours=${holiday_hrs}
    Open SM Native Application On Mobile Phone    battc00191
    Login SM App On Mobile    SM1_STORE2
    Navigate To Request On SM Phone App
    Add Day Off Details With Holiday Hours On SM Phone App
    ...    ESS5_STORE2
    ...    ${day_off_data}[reason]
    ...    start_date=${day_off_data}[start_date]
    ...    end_date=${day_off_data}[end_date]
    ...    status=${day_off_data}[status]
    ...    holiday_hours=${day_off_data}[holiday_hours]
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]
    Select Specific Day Off Request On SM Phone App    ESS5_STORE2    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[status]
    Approve Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${day_off_data}[start_date]    ${day_off_data}[start_date]
    Select Specific Day Off Request On SM Phone App    ESS5_STORE2    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${approved_status}
    Verify Day Off Details On SM Phone App    ${day_off_data}[start_date]    ${day_off_data}[end_date]    total_days=1    reason=${day_off_data}[reason]    status=${approved_status}

    [Teardown]    Teardown Test Case    battc00191
