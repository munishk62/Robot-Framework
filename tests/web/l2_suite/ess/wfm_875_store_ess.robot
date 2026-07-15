*** Settings ***
Documentation       add edit delete time off request and verify notifications

Resource            resources/web/ess/ess_request_calendar.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Suite Setup         Run Keywords
...                 Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS3_STORE1    SM1_STORE1    1_1    1_7
...                 AND    Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS3_STORE1    SM1_STORE1    8_1    8_7
...                 AND    Close Browser
Test Teardown       Run Keywords    Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS3_STORE1    SM1_STORE1    1_1    1_7
...                 AND    Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS3_STORE1    SM1_STORE1    8_1    8_7
...                 AND    Close Browser
Test Tags           battc00099    action:write    dev:yogesh    bat_phase1    config:ess    config:ess_add_edit_delete_timeoff
...                 om_hr


*** Test Cases ***
BATTC00099: Verify that an ESS user is able to add time off requests and receive notifications - Add Time Off Request
    [Documentation]    This test case verifies if a user can add a time off request in the ESS system and checks for appropriate notifications.
    ${time_off_data}    Get Time Off Data
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user}
    ...    ${time_off_data}[reason]    8_1    request_type=Time Off
    IF    ${is_alternate_offset_required}
        ${time_off_data}    Get Time Off Data    start_date=8_1
    END
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    Navigate To ESS Request Calendar Page
    Select Day On Request Calendar Page    ${time_off_data}[start_date]
    Create ESS Time Off Request And Verify API Success    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[duration]    ${time_off_data}[reason]    ${time_off_data}[comment]
    Verify Ess Time Off Request Created On Web    ${ess_user}[displayName]    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status]
    ${my_work_enabled}    Get Config Value    key=MYWORK_ENABLED
    ${timeoff_my_work_notification}    Get Config Value    key=TIMEOFF_MYWORK_NOTIFICATIONS_ENABLED
    IF    ${my_work_enabled} and ${timeoff_my_work_notification}
        Log    Both MYWORK_ENABLED and TIMEOFF_MYWORK_NOTIFICATIONS_ENABLED are True - Verifying notifications level=INFO
        Navigate To Web My Work Page On Web
        Verify ESS Time Off Request Notification On Web
        ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
        Capture Screenshot On Webpage
        Navigate To ESS Request Calendar Page
    ELSE
        Log
        ...    Skipping My Work notification verification - MYWORK_ENABLED: ${my_work_enabled}, TIMEOFF_MYWORK_NOTIFICATIONS_ENABLED: ${timeoff_my_work_notification}
        ...    level=WARN
    END
    ${request_deleted_from_ess}    Run Keyword And Return Status    Delete ESS Time Off Request And Verify API Success
    ...    ${ess_user}[displayName]    ${time_off_data}[start_date]
    ...    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${time_off_data}[status]
    IF    not ${request_deleted_from_ess}    Log    Request was not deleted from ESS, attempting to delete from SM in Test Teardown

BATTC00099: Verify that an ESS user is able to add time off requests and receive notifications - Edit Time Off Request
    [Documentation]    This test case verifies if a user can add and edit a time off request in the ESS system
    ${time_off_data}    Get Time Off Data    template_name=edit_timeoff
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user}
    ...    ${time_off_data}[reason]    8_1    request_type=Time Off
    IF    ${is_alternate_offset_required}
        ${time_off_data}    Get Time Off Data    template_name=edit_timeoff    start_date=8_1
    END
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    Navigate To ESS Request Calendar Page
    Select Day On Request Calendar Page    ${time_off_data}[start_date]
    Create ESS Time Off Request And Verify API Success    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[duration]    ${time_off_data}[reason]    ${time_off_data}[comment]
    Verify Ess Time Off Request Created On Web    ${ess_user}[displayName]    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status]
    Edit Ess Time Off Request And Verify Api Success
    ...    ${ess_user}[displayName]    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status]    ${time_off_data}[edit_start_time]
    ${request_deleted_from_ess}    Run Keyword And Return Status    Delete ESS Time Off Request And Verify API Success
    ...    ${ess_user}[displayName]    ${time_off_data}[start_date]
    ...    ${time_off_data}[edit_start_time]    ${time_off_data}[edit_end_time]    ${time_off_data}[status]
    IF    not ${request_deleted_from_ess}    Log    Request was not deleted from ESS, attempting to delete from SM in Test Teardown

BATTC00099: Verify that an ESS user is able to add time off requests and receive notifications - Add And Delete Time Off Request
    [Documentation]    This test case verifies if a user can add and delete a time off request in the ESS system.
    ${time_off_data}    Get Time Off Data    template_name=delete_timeoff
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user}
    ...    ${time_off_data}[reason]    8_1    request_type=Time Off
    IF    ${is_alternate_offset_required}
        ${time_off_data}    Get Time Off Data    template_name=delete_timeoff    start_date=8_1
    END
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    Navigate To ESS Request Calendar Page
    Select Day On Request Calendar Page    ${time_off_data}[start_date]
    Create ESS Time Off Request And Verify API Success    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[duration]    ${time_off_data}[reason]    ${time_off_data}[comment]
    Verify Ess Time Off Request Created On Web    ${ess_user}[displayName]    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data}[status]
    ${is_ui_delete_success}    Run Keyword And Return Status    Delete ESS Time Off Request And Verify API Success
    ...    ${ess_user}[displayName]    ${time_off_data}[start_date]
    ...    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${time_off_data}[status]
    IF    not ${is_ui_delete_success}    Log    Request was not deleted from ESS, attempting to delete from SM in Test Teardown
