*** Settings ***
Documentation       Test to verify Add, Edit, Delete Day Off Request On Requests Calendar Page As ESS User

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/ess_request_calendar.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Tags           action:write    dev:moiz    bat_phase1    config:ess    om_hr


*** Test Cases ***
BATTC00098: Verify that an ESS user is able to add day off requests and receive notifications
    [Documentation]    Test to verify Add Day Off Request On Requests Calendar Page As ESS User
    [Tags]    config:ess_add_edit_delete_dayoff    battc00098    config:use_leave_hrs_in_ta:n    config:holiday_hours_disabled
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${day_off_data}    Get Day Off Data    start_date=1_3    reason=DayOffReasonType.PAID_VACATION
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user}    ${day_off_data}[reason]    8_3
    IF    ${is_alternate_offset_required}
        ${day_off_data}    Get Day Off Data    start_date=8_3    reason=DayOffReasonType.PAID_VACATION
    END
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Cleanup All Existing ESS Requests From SM On Request Calendar On Web
    ...    ${ess_user}[displayName]    num_of_weeks=0    specific_week_offset_day=${day_off_data}[start_date]
    Close Browser Tab On Web
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    Navigate To ESS Request Calendar Page
    Create ESS Day Off Request And Verify API Success    ${day_off_data}[start_date]    ${day_off_data}[start_date]
    ...    ${day_off_data}[reason]
    Verify Day Off Request Details On Requests Calendar Page On Web    ${ess_user}[displayName]    ${day_off_data}[status]
    ...    ${day_off_data}[start_date]    ${day_off_data}[start_date]    ${day_off_data}[reason]
    ${my_work_enabled}    Get Config Value    key=MYWORK_ENABLED
    ${dayoff_my_work_notification}    Get Config Value    key=DAYOFF_MYWORK_NOTIFICATIONS_ENABLED
    IF    ${my_work_enabled} and ${dayoff_my_work_notification}
        Log    Both MYWORK_ENABLED and DAYOFF_MYWORK_NOTIFICATIONS_ENABLED are True
        Navigate To Web My Work Page On Web
        Verify ESS Day Off Request Notification On My Work On Web    ${day_off_data}[start_date]
        Capture Screenshot On Webpage
        Navigate To ESS Request Calendar Page
    END
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS3_STORE1    SM1_STORE1    ${day_off_data}[start_date]    ${day_off_data}[start_date]    AND
    ...    Close Browser

BATTC00149: Verify that an ESS user is able to edit day off requests
    [Documentation]    Test to verify Edit Day Off Request On Requests Calendar Page As ESS User
    [Tags]    config:ess_add_edit_delete_dayoff    battc00149    config:use_leave_hrs_in_ta:n    config:holiday_hours_disabled
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${day_off_edit_data}    Get Day Off Data    start_date=1_4    end_date=1_5
    ...    reason=DayOffReasonType.PAID_VACATION    status_after_approval=RequestStatus.APPROVED
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user}    ${day_off_edit_data}[reason]    8_5
    IF    ${is_alternate_offset_required}
        ${day_off_edit_data}    Get Day Off Data    start_date=8_4    end_date=8_5
        ...    reason=DayOffReasonType.PAID_VACATION    status_after_approval=RequestStatus.APPROVED
    END
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Cleanup All Existing ESS Requests From SM On Request Calendar On Web
    ...    ${ess_user}[displayName]    num_of_weeks=0    specific_week_offset_day=${day_off_edit_data}[start_date]
    Close Browser Tab On Web
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    Navigate To ESS Request Calendar Page
    Create ESS Day Off Request And Verify API Success    ${day_off_edit_data}[start_date]    ${day_off_edit_data}[end_date]
    ...    ${day_off_edit_data}[reason]
    Edit Day Off Request On Requests Calendar Page On Web    ${day_off_edit_data}[start_date]
    ...    edit_start_date=${day_off_edit_data}[end_date]
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS3_STORE1    SM1_STORE1    ${day_off_edit_data}[start_date]    ${day_off_edit_data}[end_date]    AND
    ...    Close Browser

BATTC00150: Verify that an ESS user is able to delete day off requests without holiday hours functionality
    [Documentation]    Test to verify Delete Day Off Request On Requests Calendar Page As ESS User
    [Tags]    config:ess_add_edit_delete_dayoff    battc00150    config:use_leave_hrs_in_ta:n    config:holiday_hours_disabled
    ${is_avp_applicable}    Check If AVP Applicable From DB
    Skip If    ${is_avp_applicable}    msg=AVP is applicable for the env, skipping the test execution as the test case is not valid when AVP is applied.
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    ${ess_user}    Get User    user_key=ESS3_STORE1
    ${day_off_delete_data}    Get Day Off Data    start_date=1_6    reason=DayOffReasonType.PAID_VACATION
    ${is_alternate_offset_required}    Check If Day Offset Value Applicable And Within Range On Web    ${ess_user}    ${day_off_delete_data}[reason]    8_6
    IF    ${is_alternate_offset_required}
        ${day_off_delete_data}    Get Day Off Data    start_date=8_6    reason=DayOffReasonType.PAID_VACATION
    END
    Navigate To ESS Request Calendar Page
    Cleanup Existing ESS Day Off Requests On Web
    Create ESS Day Off Request And Verify API Success    ${day_off_delete_data}[start_date]    ${day_off_delete_data}[start_date]
    ...    ${day_off_delete_data}[reason]
    Verify Day Off Request Details On Requests Calendar Page On Web    ${ess_user}[displayName]    ${day_off_delete_data}[status]
    ...    ${day_off_delete_data}[start_date]    ${day_off_delete_data}[start_date]    ${day_off_delete_data}[reason]
    Delete ESS Day Off Request And Verify API Success    ${ess_user}[displayName]    ${day_off_delete_data}[start_date]
    ...    ${day_off_delete_data}[status]
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Clean Up All Requests For User On Date    ESS3_STORE1    SM1_STORE1    ${day_off_delete_data}[start_date]    ${day_off_delete_data}[start_date]    AND
    ...    Close Browser
