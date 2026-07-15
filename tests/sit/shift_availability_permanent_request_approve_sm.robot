*** Settings ***
Documentation       SITTC60065 - Requests - Create permanent availability request from ESS and approve from SM monthly calendar

Resource        resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource        resources/Mobile/ESS/PagesResources/Availability_Module/availability.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource    resources/Mobile/ESS/PagesResources/Availability_Module/Availability_Teardown.resource

Suite Setup         Clean Up Permanent Availability Request    ESS4_STORE11    SM1_STORE11    2_0
Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           action:write    dev:ashish    sittc60065    config:ess    config:rws    config:add_edit_delete_availability_ess    mobile    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_shift_enabled    config:mobile_sm_enabled


*** Test Cases ***
SITTC60065: Requests - Create permanent availability request from ESS and approve from SM monthly calendar
    [Documentation]    Requests - Create permanent availability request from ESS and approve from SM monthly calendar
    ${add_availability}    Get Shift Availability Data    template_name=add_availability_#1    start_date=2_0
    Open Mobile ESS App    sittc60065
    Login Mobile Ess App    ESS4_STORE11
    Navigate To Availability Module On Mobile ESS
    Navigate To Add Availability Page On Mobile ESS
    Select Availability Permanent Type On Mobile ESS
    Select Availability Start Date On Mobile ESS    ${add_availability}[start_date]
    Select Availability Reason On Mobile ESS     ${add_availability}[reason]
    Select Entire Week Available On Mobile ESS
    Submit Availability For Approval On Mobile ESS
    Verify Availability List Item On Mobile ESS    ${add_availability}
    Close Mobile Application    sittc60065_ess4_add_permanent_availability_request

    Open SM Native Application On Mobile Phone    sittc60065
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App
    Request Calendar Navigation On SM Phone App    ${add_availability}[start_date]
    Select Specific Permanent Availability Request On SM Phone App    ESS4_STORE11    ${add_availability}[start_date]    ${add_availability}[status]
    Approve Availability Request On SM Phone App

    [Teardown]    Teardown Test Case    sittc60065
