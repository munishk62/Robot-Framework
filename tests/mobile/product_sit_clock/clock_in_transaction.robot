*** Settings ***
Documentation       BATTC00163 - Verify user is able to clock in & clock out from tablet clock

Resource        resources/Mobile/NativeClock/PageResources/Common/common.resource
Resource        resources/Mobile/NativeClock/PageResources/Clock/clock.resource

Suite Teardown     Run Keyword And Ignore Error    Close Application
Test Tags           action:read    dev:kishan    battc00163


*** Variables ***
${ROUNDING_POLICY_TIME}    60


*** Test Cases ***
BATTC00163: Verify user is able to clock in & clock out from tablet clock
    [Documentation]    BATTC00163 : Verify user is able to clock in & clock out from tablet clock
    ${essUser}    Get User    ESS4_STORE2
    Open Mobile Native Clock Application    tc_id=battc00163
    Clock In For Native Clock    ${essUser}[badgeId]
    Sleep    ${ROUNDING_POLICY_TIME}
    Clock Out For Native Clock    ${essUser}[badgeId]

    [Teardown]    Teardown Test Case    battc00163
