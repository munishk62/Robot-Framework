*** Settings ***
Documentation       BATTC00166 - Verify user is able to do manager override for punches from tablet clock

Resource            resources/Mobile/NativeClock/PageResources/Common/common.resource
Resource            resources/Mobile/NativeClock/PageResources/Clock/clock.resource
Resource            resources/Mobile/NativeClock/PageResources/Clock/manager_override.resource
Resource            resources/Web/clock/webclock_login.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application
Test Setup          Check Clock Applicability For Environment On Tablet Clock App

Test Tags           action:write    dev:moiz    battc00166


*** Variables ***
${ROUNDING_POLICY_TIME}     60s
${MAX_TRANSACTION_INTERVAL_TIME}       180s


*** Test Cases ***
BATTC00166: Verify user is able to do manager override for punches from tablet clock
    [Documentation]    BATTC00166 : Verify user is able to do manager override for punches from tablet clock
    ${essUser}    Get User    ESS6_STORE2
    Open Mobile Native Clock Application    tc_id=battc00166
    Clock In For Native Clock    ${essUser}[badgeId]
    Sleep    ${ROUNDING_POLICY_TIME}
    Perform Manager Override On Tablet Clock App    SM1_STORE2    0    30
    Verify Turn Off Override Button Displayed On Tablet Clock App
    Sleep    ${MAX_TRANSACTION_INTERVAL_TIME}
    [Teardown]    Run Keywords    Cancel Manager Override Dialog Or Page If Visible On Tablet Clock App    AND
    ...    Run Keyword And Ignore Error    Clock Out For Native Clock    ${essUser}[badgeId]    AND
    ...    Teardown Test Case    battc00166


*** Keywords ***
Check Clock Applicability For Environment On Tablet Clock App
    [Documentation]
    ...    Checks if the clock application is applicable for the current environment.
    ...    If not applicable, the test will be skipped.
    ${is_clock_transaction_applicable}    Check Clock Applicability In DB
    Skip If    not ${is_clock_transaction_applicable}    Clock transactions are not applicable for this environment.
