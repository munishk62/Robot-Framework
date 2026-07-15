*** Settings ***
Documentation       BATTC00251 - Verify mobile app registration for SM and login, logout

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           action:read    dev:moiz    battc00251    mobile    bat_phase2    config:rws
...    config:mobile_sm_enabled


*** Test Cases ***
BATTC00251: Verify mobile app registration for SM
    [Documentation]    Verifies that users can successfully register for the SM mobile application using QR code registration.
    Open SM Native Application On Mobile Phone    battc00251
    Login SM App On Mobile    SM1_STORE1
    Verify User Name On Header Profile On My Store Page On Mobile    SM1_STORE1
    Logout SM App On Mobile

    [Teardown]    Teardown Test Case    battc00251
