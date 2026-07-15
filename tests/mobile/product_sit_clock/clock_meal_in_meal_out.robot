*** Settings ***
Documentation       BATTC00164 - Verify User Can Perform Meal In And Meal Out Transactions On Tablet Clock

Resource        resources/Mobile/NativeClock/PageResources/Common/common.resource
Resource        resources/Mobile/NativeClock/PageResources/Clock/clock.resource

Suite Teardown     Run Keyword And Ignore Error    Close Application
Test Tags          action:write    dev:moiz    battc00164


*** Variables ***
${ROUNDING_POLICY_TIME}    60


*** Test Cases ***
BATTC00164: Verify user is able to meal in & meal out from tablet clock
    [Documentation]    Verify User Can Perform Meal In And Meal Out Transactions On Tablet Clock
    ${essUser}    Get User    ESS5_STORE2
    Open Mobile Native Clock Application    tc_id=battc00164
    Clock In For Native Clock    ${essUser}[badgeId]
    Sleep    ${ROUNDING_POLICY_TIME}
    Perform Meal Start With Badge ID On Tablet Clock    ${essUser}[badgeId]
    Sleep    ${ROUNDING_POLICY_TIME}
    Perform Meal End With Badge ID On Tablet Clock    ${essUser}[badgeId]
    [Teardown]    Run Keyword And Ignore Error    Clock Out For Native Clock    ${essUser}[badgeId]    AND
    ...    Teardown Test Case    battc00164
