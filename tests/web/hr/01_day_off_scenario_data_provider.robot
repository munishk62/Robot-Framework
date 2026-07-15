*** Settings ***
Documentation       Test cases for creating day off requests in WFM application

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/employee/request_calendar.resource

Test Teardown       Close Browser

Test Tags           dayoff    data_provider_dayoff


*** Test Cases ***
Verify_ESS_Can_Create_Day_Off_And_SM_Can_Approve
    [Documentation]    Test case for day off request approval scenario
    [Tags]    approval_scenario
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=    Get User    user_key=ESS2_STORE1
    ${day_off_data}=    Get Day Off Data    template_name=unpaid_approved
    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${created_day_off}=    Create ESS Day Off Request And Verify API Success    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    ...    ${day_off_data}[reason]

    Login And Launch WFM Web App    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Approve Day Off Request And Verify API Success On Request Calendar Page On Web    ${ess_user}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status]

    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    Verify ESS Day Off Request Status    ${ess_user}[displayName]    ${day_off_data}[start_date]
    ...    ${day_off_data}[status_after_approval]
    [Teardown]    Run Keyword If Test Passed    Delete SM Day Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[unitID]    ${created_day_off}    A

TC34039_Verify_ESS_Can_Create_Day_Off_And_SM_Can_Decline
    [Documentation]    Test case for day off request DENIAL scenario
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=    Get User    user_key=ESS2_STORE1
    ${day_off_data}=    Get Day Off Data    start_date=1_2    end_date=1_2
    ...    notes=Denial scenario automated test    status_after_decline=RequestStatus.DECLINED
    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${created_day_off}=    Create ESS Day Off Request And Verify API Success    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    ...    ${day_off_data}[reason]

    Login And Launch WFM Web App    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Decline Day Off Request And Verify API Success On Request Calendar Page On Web    ${ess_user}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status]

    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    Verify ESS Day Off Request Status    ${ess_user}[displayName]    ${day_off_data}[start_date]
    ...    ${day_off_data}[status_after_decline]
    [Teardown]    Run Keyword If Test Passed    Delete SM Day Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[unitID]    ${created_day_off}    D

TC34040_Verify_ESS_Can_Create_Day_Off_And_Cancel_After_Approval
    [Documentation]    Test case for day off request approval and cancellation scenario
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=    Get User    user_key=ESS2_STORE1
    ${day_off_data}=    Get Day Off Data    start_date=1_3    end_date=1_3
    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${created_day_off}=    Create ESS Day Off Request And Verify API Success    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    ...    ${day_off_data}[reason]

    Login And Launch WFM Web App    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Approve Day Off Request And Verify API Success On Request Calendar Page On Web    ${ess_user}[displayName]
    ...    ${day_off_data}[start_date]    ${day_off_data}[reason]    ${day_off_data}[status]

    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${approved_status}=    Get System Value    RequestStatus    APPROVED
    # Verify ESS Day Off Request Status    ${ess_user}[displayName]    ${day_off_data}[start_date]    ${approved_status}
    # ESS user cancels the approved day off request
    Cancel ESS Day Off Request And Verify API Success    ${ess_user}[displayName]    ${day_off_data}[start_date]    ${approved_status}
    # Verify the day off request is now cancelled
    ${canceled_status}=    Get System Value    RequestStatus    CANCELED
    Verify ESS Day Off Request Status    ${ess_user}[displayName]    ${day_off_data}[start_date]    ${canceled_status}
    [Teardown]    Run Keyword If Test Passed    Delete SM Day Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[unitID]    ${created_day_off}    C

TC34041_Verify_ESS_Can_Create_Day_Off_And_Delete_It
    [Documentation]    Test case for day off request creation and deletion scenario
    ${ess_user}=    Get User    user_key=ESS2_STORE1
    ${day_off_data}=    Get Day Off Data    start_date=1_4    end_date=1_4
    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    Create ESS Day Off Request And Verify API Success    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    ...    ${day_off_data}[reason]
    # ESS user logs out and back in as per requirement
    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    # ESS user deletes the day off request
    Delete ESS Day Off Request And Verify API Success    ${ess_user}[displayName]    ${day_off_data}[start_date]
    ...    ${day_off_data}[status]
    # Verify that the day off request is no longer visible
    Verify Ess Day Off Request Not Present    ${ess_user}[displayName]    ${day_off_data}[start_date]    ${day_off_data}[status]

TC50000_Verify_SM_Can_Bulk_Approve_Ess_Day_Off
    [Documentation]    Test case for day off request approval scenario
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=    Get User    user_key=ESS2_STORE1
    ${day_off_data1}=    Get Day Off Data    start_date=1_5    end_date=1_5
    ${day_off_data2}=    Get Day Off Data    start_date=1_6    end_date=1_6
    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${created_day_off1}=    Create ESS Day Off Request And Verify API Success    ${day_off_data1}[start_date]
    ...    ${day_off_data1}[end_date]    ${day_off_data1}[reason]
    ${created_day_off2}=    Create ESS Day Off Request And Verify API Success    ${day_off_data2}[start_date]
    ...    ${day_off_data2}[end_date]    ${day_off_data2}[reason]
    Login And Launch WFM Web App    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Switch To List View Page Followed By Select Date And View All Requests On Request Calendar Page On Web    ${day_off_data1}[start_date]
    ...    Day Off
    Select Day Off Request Checkbox On List View On Request Calendar Page On Web    ${ess_user}[displayName]
    ...    ${day_off_data1}[start_date]    ${day_off_data1}[reason]
    Select Day Off Request Checkbox On List View On Request Calendar Page On Web    ${ess_user}[displayName]
    ...    ${day_off_data2}[start_date]    ${day_off_data2}[reason]
    Click Approve Button On List View And Verify API Success On Request Calendar Page On Web
    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${approved_status}=    Get System Value    RequestStatus    APPROVED
    Verify ESS Day Off Request Status    ${ess_user}[displayName]    ${day_off_data1}[start_date]    ${approved_status}
    Verify ESS Day Off Request Status    ${ess_user}[displayName]    ${day_off_data2}[start_date]    ${approved_status}
    [Teardown]    Run Keywords
    ...    Run Keyword If Test Passed    Delete SM Day Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[unitID]    ${created_day_off1}    A
    ...    AND    Run Keyword If Test Passed    Delete SM Day Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[unitID]    ${created_day_off2}    A

TC34000_Verify_ESS_Can_Create_Day_Off_With_Holiday_Hours_And_SM_Can_Approve
    [Documentation]    Test case for day off request with holiday hours scenario
    [Tags]    config:holiday_hrs
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=    Get User    user_key=ESS2_STORE1
    ${day_off_data}=    Get Day Off Data    start_date=2_2    end_date=2_3
    ...    holiday_hours={"2":"6"}
    ${holiday_hours_value}=    Evaluate    list($day_off_data["holiday_hours"].values())[0]
    Login And Launch WFM Web App    ${ess_user}[user_key]
    Navigate To ESS Request Calendar Page
    ${created_day_off}=    Create ESS Day Off Request With Holiday Hours And Verify API Success
    ...    ${day_off_data}[start_date]    ${day_off_data}[end_date]
    ...    ${day_off_data}[reason]    ${holiday_hours_value}
    Login And Launch WFM Web App    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Approve Day Off Request With Holiday Hours And Verify API Success On Request Calendar Page On Web
    ...    ${ess_user}[displayName]    ${day_off_data}[start_date]    ${day_off_data}[end_date]    ${day_off_data}[reason]
    ...    ${day_off_data}[status]
    [Teardown]    Run Keyword If Test Passed    Delete SM Day Off Request Via API On Request Calendar Page On Web    ${sm_user}[username]    ${sm_user}[unitID]    ${created_day_off}    A
