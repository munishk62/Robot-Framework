*** Settings ***
Documentation       BATTC00127 - This test case verifies that SM user can add, edit, approve and delete time off request on SM mobile app.

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Clean Up Time Off Request For User On Date    ESS5_STORE2    SM1_STORE2    start_date_offset=6_2

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           dev:kishan    battc00127    mobile    bat_phase2    config:rws    config:ess_add_edit_delete_timeoff
...    config:mobile_sm_enabled


*** Test Cases ***
BATTC00127: Verify SM user is able to add/edit/delete/approve time off requests in mobility
    [Documentation]    Verify SM user can add, edit, approve and delete time off request on SM mobile app
    ${time_off_reason}    Get System Value    TimeOffReasonType    PAID_VACATION
    ${time_off_data}    Get Time Off Data    template_name=edit_timeoff    reason=${time_off_reason}    start_date=6_2
    Open SM Native Application On Mobile Phone    battc00127
    Login SM App On Mobile    SM1_STORE2
    Navigate To Request On SM Phone App
    Add Time Off Details On SM Phone App    ESS5_STORE2    ${time_off_data}[reason]    ${time_off_data}[start_date]
    ...    ${time_off_data}[start_time]    ${time_off_data}[duration]
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]
    Select Request On SM Phone App    ESS5_STORE2
    Edit Time Off Details On SM Phone App    start_time=${time_off_data}[edit_start_time]    duration_time=${time_off_data}[edit_duration]
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]    ${time_off_data}[start_date]
    Select Request On SM Phone App    ESS5_STORE2
    Approve Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${time_off_data}[start_date]    ${time_off_data}[start_date]
    Select Request On SM Phone App    ESS5_STORE2
    Verify Time Off Details On SM Phone App    ${time_off_data}[start_date]    status=${time_off_data}[status_after_approval]
    [Teardown]    Teardown Test Case    battc00127
