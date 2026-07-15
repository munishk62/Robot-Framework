*** Settings ***
Documentation       BATTC00250 - Verify mobile app registration for ESS

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           action:read    dev:ashish    battc00250    mobile    bat_phase2
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00250: Verify mobile app registration for ESS
    [Documentation]    Verifies that users can successfully register for the ESS mobile application using QR code registration.
    ${qr_code}    Get Config Value    qr_code
    Open Mobile ESS App    battc00250
    Clear Registration Data On Mobile ESS App
    Register Mobile ESS App With QR Code    ${qr_code}

    [Teardown]    Teardown Test Case    battc00250
