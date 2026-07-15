*** Settings ***
Documentation       SITTC60067 - Requests - Create permanent availability request from ESS and approve then reject from SM monthly and month views

Resource        resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource        resources/Mobile/ESS/PagesResources/Availability_Module/availability.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource    resources/Mobile/ESS/PagesResources/Availability_Module/Availability_Teardown.resource

Suite Setup         Clean Up Permanent Availability Request    ESS9_STORE11    SM1_STORE11    3_0
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           action:write    dev:ashish    sittc60067    config:ess    config:rws    config:add_edit_delete_availability_ess    mobile    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60067: Requests - Create permanent availability request from ESS and approve then reject from SM monthly and month views
    [Documentation]    Requests - Create permanent availability request from ESS and approve then reject from SM monthly and month views
    ${add_availability}    Get Shift Availability Data    template_name=add_availability_#1    start_date=3_0
    Open Mobile ESS App    sittc60067
    Login Mobile Ess App    ESS9_STORE11
    Navigate To Availability Module On Mobile ESS
    Navigate To Add Availability Page On Mobile ESS
    Select Availability Permanent Type On Mobile ESS
    Select Availability Start Date On Mobile ESS    ${add_availability}[start_date]
    Select Availability Reason On Mobile ESS     ${add_availability}[reason]
    Select Entire Week Available On Mobile ESS
    Submit Availability For Approval On Mobile ESS
    Verify Availability List Item On Mobile ESS    ${add_availability}
    Close Mobile Application    sittc60067_ess9_add_permanent_availability_request

    Open SM Native Application On Mobile Phone    sittc60067
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${add_availability}[start_date]
    Select Specific Permanent Availability Request On SM Phone App    ESS9_STORE11    ${add_availability}[start_date]    ${add_availability}[status]
    Approve Availability Request On SM Phone App

    ${approved_availability}    Get Shift Availability Data    template_name=add_availability_#1    start_date=3_0    status=RequestStatus.APPROVED
    Request Calendar Navigation On SM Phone App    ${add_availability}[start_date]
    Select More Options Of Specific Permanent Availability Request On SM Phone App    ESS9_STORE11    ${approved_availability}[start_date]    ${approved_availability}[status]
    Decline Availability Request From More Options On SM Phone App

    [Teardown]    Teardown Test Case    sittc60067
