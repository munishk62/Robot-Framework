*** Settings ***
Documentation       BATTC00162 - Verify user is able to register tablet clock device

Resource            resources/Mobile/NativeClock/PageResources/Common/common.resource
Resource            resources/Mobile/NativeClock/PageResources/Clock/clock.resource
Resource            resources/Mobile/Common/Mobile_Device_Helper.resource
Resource            resources/Mobile/NativeClock/PageResources/LoginPage/native_clock_login.resource
Resource            resources/Mobile/NativeClock/PageResources/Registration/registration.resource

Suite Teardown     Run Keyword And Ignore Error    Close Application
Test Tags           action:read    dev:kishan    battc00162


*** Test Cases ***
BATTC00162: Verify user is able to register tablet clock device
    [Documentation]    BATTC00162 - Verify user is able to register tablet clock device
    ${user}    Get User    SM1_STORE2
    VAR    ${store_name}    ${user}[unitID]    -    ${user}[unitName]
    ${data}    Get Native Clock Register Data
    Open Mobile Native Clock Application    tc_id=battc00162
    Login Mobile Native Clock App    SM1_STORE2
    Select Store For Registration For Native Clock    ${store_name}
    Enter Device ID For Registration For Native Clock
    Select Device Location For Registration For Native Clock    ${data}[device_location]
    Enable Location For Registration For Native Clock    ${data}[enable_location_services]
    Submit Registration For Native Clock    ${data}[enable_location_services]
    Finish Registration For Native Clock
    Verify Transaction Option Displayed

    [Teardown]    Teardown Test Case    battc00162
