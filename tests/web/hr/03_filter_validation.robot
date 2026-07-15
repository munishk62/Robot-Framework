*** Settings ***
Documentation       Test cases for creating time off requests in WFM application

Library             test_data/TestDataLibrary.py
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/web/ess/ess_request_calendar.resource

Suite Setup         PreRequest Setup Of Requests Creation For TC34047
Test Teardown       Close Browser
Test Template       Verify SM Can Apply Filter Based On Request Type And Request Status On Request Calendar Page

Test Tags           data_driven    request_filter


*** Test Cases ***
TC34047_Verify_SM_Can_Apply_Filter
    [Template]    Verify SM Can Apply Filter Based On Request Type And Request Status On Request Calendar Page
    2_1    RCFilterRequestType.TIME_OFF    RequestStatus.APPROVED
    2_2    RCFilterRequestType.TIME_OFF    RequestStatus.NOT_REVIEWED
    2_3    RCFilterRequestType.DAY_OFF    RequestStatus.APPROVED
    2_4    RCFilterRequestType.DAY_OFF    RequestStatus.NOT_REVIEWED


*** Keywords ***
PreRequest Setup Of Requests Creation For TC34047
    [Documentation]    Create and approve a time off request for TC34047
    ${ess_user}=    Get User    user_key=ESS1_STORE1
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${time_off1}=    Get Time Off Data    start_date=2_1
    ${time_off2}=    Get Time Off Data    start_date=2_2
    ${day_off1}=    Get Day Off Data    start_date=2_3    end_date=2_3
    ${day_off2}=    Get Day Off Data    start_date=2_4    end_date=2_4
    Login To WFM Using Provider    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    Create ESS Time Off Request And Verify API Success
    ...    ${time_off1}[start_date]    ${time_off1}[start_time]
    ...    ${time_off1}[duration]    ${time_off1}[reason]
    Create ESS Time Off Request And Verify API Success
    ...    ${time_off2}[start_date]    ${time_off2}[start_time]
    ...    ${time_off2}[duration]    ${time_off2}[reason]
    Create ESS Day Off Request And Verify API Success
    ...    ${day_off1}[start_date]    ${day_off1}[end_date]
    ...    ${day_off1}[reason]
    Create ESS Day Off Request And Verify API Success
    ...    ${day_off2}[start_date]    ${day_off2}[end_date]
    ...    ${day_off2}[reason]

    Login To WFM Using Provider    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Approve Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user}[displayName]    ${time_off1}[start_date]
    ...    ${time_off1}[reason]    ${time_off1}[start_time]
    ...    ${time_off1}[end_time]    ${time_off1}[status]
    Decline Time Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user}[displayName]    ${time_off2}[start_date]
    ...    ${time_off2}[reason]    ${time_off2}[start_time]
    ...    ${time_off2}[end_time]    ${time_off2}[status]
    Approve Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user}[displayName]    ${day_off1}[start_date]
    ...    ${day_off1}[reason]    ${day_off1}[status]
    Decline Day Off Request And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user}[displayName]    ${day_off2}[start_date]
    ...    ${day_off2}[reason]    ${day_off2}[status]

Verify SM Can Apply Filter Based On Request Type And Request Status On Request Calendar Page
    [Documentation]    Validate the request calendar filter functionality for different request types and statuses
    [Arguments]    ${start_date}    ${request_type}    ${request_status}
    ${filter_data}=    Get Request Calendar Filter Data    request_type=${request_type}    request_status=${request_status}
    ${sm_user}=    Get User    user_key=SM1_STORE1
    Login To WFM Using Provider    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Select Day On Request Calendar Page    ${start_date}
    Verify Request By Filter Based On Status And Type On Request Calendar Page On Web    ${filter_data}[request_type]
    ...    ${filter_data}[request_status]
