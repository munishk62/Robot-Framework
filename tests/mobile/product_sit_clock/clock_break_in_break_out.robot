*** Settings ***
Documentation       BATTC00165 - Verify User Can Perform Break In And Break Out Transactions On Tablet Clock

Resource        resources/Mobile/NativeClock/PageResources/Common/common.resource
Resource        resources/Mobile/NativeClock/PageResources/Clock/clock.resource
Resource        resources/Web/clock/webclock_login.resource

Test Setup         Check Break Applicability For Environment From DB
Suite Teardown     Run Keyword And Ignore Error    Close Application
Test Tags          action:write    dev:moiz    battc00165


*** Variables ***
${ROUNDING_POLICY_TIME}    60


*** Test Cases ***
BATTC00165: Verify user is able to break in & break out from tablet clock
    [Documentation]    Verify User Can Perform Break In And Break Out Transactions On Tablet Clock
    ${essUser}    Get User    ESS3_STORE2    # original user mentioned is ESSNH3_STORE2 but raised for using normal ESS user instead.
    Open Mobile Native Clock Application    tc_id=battc00165
    Clock In For Native Clock    ${essUser}[badgeId]
    Sleep    ${ROUNDING_POLICY_TIME}
    Perform Break In With Badge ID On Tablet Clock    ${essUser}[badgeId]
    Sleep    ${ROUNDING_POLICY_TIME}
    Perform Break Out With Badge ID On Tablet Clock    ${essUser}[badgeId]

    [Teardown]    Teardown Test Case    battc00165


*** Keywords ***
Check Break Applicability For Environment From DB
    [Documentation]    This keyword will check the break applicability for the user by fetching the details from DB.
    # #PC00080 - Check applicability of Break transactions
    ${is_break_applicable}    Check Break Applicability For User In DB    user_key=SM1_STORE2
    Skip If    not ${is_break_applicable}    Break transactions are not applicable for this env. Skipping test execution.
