*** Settings ***
Documentation       Test cases for creating time off requests in WFM application

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/web/ess/ess_request_calendar.resource

Test Teardown       Close Browser

Test Tags           timeoff    data_provider_timeoff


*** Test Cases ***
TC34042_Time_off_Scenario_With_Approval_Flow
    [Documentation]    Complete test for time off requests with both approval and denial flows
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=    Get User    user_key=ESS1_STORE1
    ${time_off_data}=    Get Time Off Data    template_name=approve_timeoff
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${created_time_off}=    Create ESS Time Off Request And Verify API Success    ${time_off_data}[start_date]
    ...    ${time_off_data}[start_time]    ${time_off_data}[duration]    ${time_off_data}[reason]
    Login To WFM Using Provider    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Approve Time Off Request And Verify API Success On Request Calendar Page On Web    ${ess_user}[displayName]
    ...    ${time_off_data}[start_date]    ${time_off_data}[reason]    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[status]
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    Verify ESS Time Off Request Status    ${ess_user}[displayName]    ${time_off_data}[start_date]
    ...    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${time_off_data}[status_after_approval]
    [Teardown]    Run Keyword If Test Passed    Delete SM Time Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[store_id]    ${created_time_off}    A

TC34044_Time_off_Scenario_With_Denial_Flow
    [Documentation]    Complete test for time off requests with denial flow
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=    Get User    user_key=ESS1_STORE1
    ${time_off_data}=    Get Time Off Data    template_name=decline_timeoff
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${created_time_off}=    Create ESS Time Off Request And Verify API Success
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[duration]    ${time_off_data}[reason]
    Login To WFM Using Provider    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Decline Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user}[displayName]
    ...    ${time_off_data}[start_date]
    ...    ${time_off_data}[reason]
    ...    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]
    ...    ${time_off_data}[status]
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    Verify ESS Time Off Request Status
    ...    ${ess_user}[displayName]    ${time_off_data}[start_date]
    ...    ${time_off_data}[start_time]    ${time_off_data}[end_time]
    ...    ${time_off_data}[status_after_decline]
    [Teardown]    Run Keyword If Test Passed    Delete SM Time Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[store_id]    ${created_time_off}    D

TC34045_Time_off_Scenario_With_Approval_And_Cancel_Flow
    [Documentation]    Complete test for time off requests with approval and cancellation flow
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=    Get User    user_key=ESS1_STORE1
    ${time_off_data}=    Get Time Off Data    start_date=3_3
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${created_time_off}=    Create ESS Time Off Request And Verify API Success
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[duration]    ${time_off_data}[reason]
    Login To WFM Using Provider    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Approve Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user}[displayName]    ${time_off_data}[start_date]    ${time_off_data}[reason]
    ...    ${time_off_data}[start_time]    ${time_off_data}[end_time]    ${time_off_data}[status]
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${approved_status}=    Get System Value    RequestStatus    APPROVED
    Verify ESS Time Off Request Status    ${ess_user}[displayName]
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${approved_status}
    ${time_off_data_approval}=    Get Time Off Data    template_name=approve_timeoff
    Cancel ESS Time Off Request And Verify API Success
    ...    ${ess_user}[displayName]    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${time_off_data_approval}[status_after_approval]
    ${canceled_status}=    Get System Value    RequestStatus    CANCELED
    Verify ESS Time Off Request Status    ${ess_user}[displayName]
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]    ${canceled_status}
    [Teardown]    Run Keyword If Test Passed    Delete SM Time Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[store_id]    ${created_time_off}    C

TC34046_Time_off_Scenario_With_Creation_And_Deletion_Flow
    [Documentation]    Test for time off requests with creation and deletion flow
    ${ess_user}=    Get User    user_key=ESS1_STORE1
    ${time_off_data}=    Get Time Off Data    start_date=3_4
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    Create ESS Time Off Request And Verify API Success
    ...    ${time_off_data}[start_date]    ${time_off_data}[start_time]
    ...    ${time_off_data}[duration]    ${time_off_data}[reason]
    # ESS user now deletes the time off request
    Close Browser
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    Delete ESS Time Off Request And Verify API Success
    ...    ${ess_user}[displayName]
    ...    ${time_off_data}[start_date]
    ...    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]
    ...    ${time_off_data}[status]
    # Verify that the time off request is no longer visible
    Verify ESS Time Off Request Not Present
    ...    ${ess_user}[displayName]
    ...    ${time_off_data}[start_date]
    ...    ${time_off_data}[start_time]
    ...    ${time_off_data}[end_time]
    ...    ${time_off_data}[status]

TC50001_TimeOff_Bulk_Approval_List_View
    [Documentation]    Test case for time off request bulk approval on list view
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=    Get User    user_key=ESS1_STORE1
    ${time_off_data1}=    Get Time Off Data    start_date=3_5
    ${time_off_data2}=    Get Time Off Data    start_date=3_6
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${created_time_off1}=    Create ESS Time Off Request And Verify API Success
    ...    ${time_off_data1}[start_date]    ${time_off_data1}[start_time]
    ...    ${time_off_data1}[duration]    ${time_off_data1}[reason]
    ${created_time_off2}=    Create ESS Time Off Request And Verify API Success
    ...    ${time_off_data2}[start_date]    ${time_off_data2}[start_time]
    ...    ${time_off_data2}[duration]    ${time_off_data2}[reason]
    Login To WFM Using Provider    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Switch To List View Page Followed By Select Date And View All Requests On Request Calendar Page On Web
    ...    ${time_off_data1}[start_date]
    ...    Time Off
    Select Time Off Request Checkbox On List View On Request Calendar Page On Web    ${ess_user}[displayName]
    ...    ${time_off_data1}[start_date]    ${time_off_data1}[reason]    ${time_off_data1}[start_time]    ${time_off_data1}[end_time]
    Select Time Off Request Checkbox On List View On Request Calendar Page On Web    ${ess_user}[displayName]
    ...    ${time_off_data2}[start_date]    ${time_off_data2}[reason]    ${time_off_data2}[start_time]    ${time_off_data2}[end_time]
    Click Approve Button On List View And Verify API Success On Request Calendar Page On Web
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${approved_status}=    Get System Value    RequestStatus    APPROVED
    Verify ESS Time Off Request Status    ${ess_user}[displayName]    ${time_off_data1}[start_date]    ${time_off_data1}[start_time]
    ...    ${time_off_data1}[end_time]    ${approved_status}
    Verify ESS Time Off Request Status    ${ess_user}[displayName]    ${time_off_data2}[start_date]    ${time_off_data2}[start_time]
    ...    ${time_off_data2}[end_time]    ${approved_status}
    [Teardown]    Run Keywords
    ...    Run Keyword If Test Passed    Delete SM Time Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[store_id]    ${created_time_off1}    A
    ...    AND    Run Keyword If Test Passed    Delete SM Time Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[store_id]    ${created_time_off2}    A
