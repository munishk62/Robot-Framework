*** Settings ***
Documentation       This resource contains keyword required for clock transaction feature.

Resource            resources/Mobile/Common/Mobile_Device_Helper.resource
Variables           resources/Mobile/NativeClock/PageResources/Locators/clock.py


*** Keywords ***
Clock Transaction For Native Clock
    [Documentation]    This keyword will perform clock transaction in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${transaction_type}: Transaction type
    ...    - ${employee_id}: Employee ID from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will perform clock transaction.
    ...    Example:
    ...    -    Clock Transaction For Native Clock    Clock In
    [Arguments]    ${transaction_type}    ${employee_id}
    Enter Employee ID For Native Clock    ${employee_id}
    Swipe Until Visible    ${transaction_type}
    Wait Until Element Is Visible    ${transaction_type}
    Click Element    ${transaction_type}
    ${is_activity_visible}    Run Keyword And Return Status
    ...    Wait Until Page Contains Element    ${ACTIVITY_CODE_NATIVE_CLOCK}

    IF    ${is_activity_visible}
        Select First Activity From DropDown On Native Clock
        Click Element    ${SUBMIT_PUNCH_ACTIVITY_CODE_NATIVE_CLOCK}
        Wait Until Element Is Visible    ${SUBMIT_PUNCH_SUCCESSFULLY}
        Click Element    ${SUBMIT_PUNCH_SUCCESSFULLY}
        ${end_session_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${END_SESSION_BUTTON_NATIVE_CLOCK}
        ...    timeout=5s
        IF    ${end_session_visible}    End Session For Native Clock
    ELSE
        Wait Until Element Is Visible    ${SUBMIT_PUNCH_SUCCESSFULLY}
        Click Element    ${SUBMIT_PUNCH_SUCCESSFULLY}
        ${end_session_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${END_SESSION_BUTTON_NATIVE_CLOCK}
        ...    timeout=5s
        IF    ${end_session_visible}    End Session For Native Clock
    END

Select First Activity From DropDown On Native Clock
    [Documentation]    Selects first clickable activity row.
    Click Element    ${ACTIVITY_CODE_NATIVE_CLOCK}
    Wait Until Page Contains Element    ${SELECT_ACTIVITY_CODE_NATIVE_CLOCK}
    ${rows}    Get WebElements    ${SELECT_ACTIVITY_CODE_NATIVE_CLOCK}
    ${count}    Get Length    ${rows}
    Log To Console    Found ${count} activity rows

    IF    ${count} > 0
        Log To Console    Clicking first activity row
        Click Element    xpath=(${SELECT_ACTIVITY_CODE_NATIVE_CLOCK})[1]
    ELSE
        Go Back From Activity Screen
    END

Go Back From Activity Screen
    [Documentation]    This keyword will navigate back from activity code screen if activity code options are not available.
    IF    '${MOBILE_PLATFORM}' == 'android'
        Press Keycode    4
    ELSE
        Click Element    xpath=//XCUIElementTypeNavigationBar/XCUIElementTypeButton[1]
    END

Verify Transaction Option Displayed
    [Documentation]    This keyword will verify transaction options are displayed in the Mobile Native Clock App.
    ...    Behavior:
    ...    - Keyword will verify transaction options are displayed.
    ...    Example:
    ...    -    Verify transaction option displayed
    Wait Until Element Is Visible    ${CLOCK_IN_BUTTON_NATIVE_CLOCK}

Clock In For Native Clock
    [Documentation]    This keyword will perform clock in transaction in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${employee_id}: Employee ID from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will perform clock in transaction.
    ...    Example:
    ...    -    Clock In For Native Clock
    [Arguments]    ${employee_id}
    Clock Transaction For Native Clock    ${CLOCK_IN_BUTTON_NATIVE_CLOCK}    ${employee_id}

Clock Out For Native Clock
    [Documentation]    This keyword will perform clock out transaction in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${employee_id}: Employee ID from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will perform clock out transaction.
    ...    Example:
    ...    -    Clock Out For Native Clock
    [Arguments]    ${employee_id}
    Clock Transaction For Native Clock    ${CLOCK_OUT_BUTTON_NATIVE_CLOCK}    ${employee_id}

Enter Employee ID For Native Clock
    [Documentation]    This keyword will enter employee ID for clock transaction in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${employee_id}: Employee ID from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will enter employee ID for clock transaction.
    ...    Example:
    ...    -    Enter Employee ID For Native Clock    ESS-EMPLOYEE1
    [Arguments]    ${employee_id}
    Wait Until Element Is Visible    ${BADGE_ID_NATIVE_CLOCK}
    Input Text    ${BADGE_ID_NATIVE_CLOCK}    ${employee_id}

End Session For Native Clock
    [Documentation]    This keyword will end the session for clock transaction in the Mobile Native Clock App.
    ...    Behavior:
    ...    - Keyword will end the session for clock transaction.
    ...    Example:
    ...    -    End Session For Native Clock
    Wait Until Element Is Visible    ${END_SESSION_BUTTON_NATIVE_CLOCK}
    Click Element    ${END_SESSION_BUTTON_NATIVE_CLOCK}

Perform Meal Start With Badge ID On Tablet Clock
    [Documentation]    Meal Start operation on Clock on Mobile
    [Arguments]    ${badge_id}
    Clock Transaction For Native Clock    transaction_type=${MEAL_START_BUTTON_NATIVE_CLOCK}    employee_id=${badge_id}

Perform Meal End With Badge ID On Tablet Clock
    [Documentation]    Meal End operation on Clock on Mobile
    [Arguments]    ${badge_id}
    Clock Transaction For Native Clock    transaction_type=${MEAL_END_BUTTON_NATIVE_CLOCK}    employee_id=${badge_id}

Perform Break In With Badge ID On Tablet Clock
    [Documentation]    Break In operation on Clock on Mobile
    [Arguments]    ${badge_id}
    Clock Transaction For Native Clock    transaction_type=${BREAK_IN_BUTTON_NATIVE_CLOCK}    employee_id=${badge_id}

Perform Break Out With Badge ID On Tablet Clock
    [Documentation]    Break Out operation on Clock on Mobile
    [Arguments]    ${badge_id}
    Clock Transaction For Native Clock    transaction_type=${BREAK_OUT_BUTTON_NATIVE_CLOCK}    employee_id=${badge_id}

Open Manager Override On Tablet Clock App
    [Documentation]    This keyword will open manager override screen on tablet clock app.
    ...    Behavior:
    ...    - Keyword will open manager override screen on tablet clock app.
    ...    Example:
    ...    -    Open Manager Override On Tablet Clock App
    Wait Until Element Is Visible    ${MANAGER_OVERRIDE_BUTTON_NATIVE_CLOCK}
    Click Element    ${MANAGER_OVERRIDE_BUTTON_NATIVE_CLOCK}

Verify Turn Off Override Button Displayed On Tablet Clock App
    [Documentation]
    ...    This keyword will verify that turn off override button is displayed on tablet clock app which indicates that override is active.
    Wait Until Element Is Visible    ${TURN_OFF_OVERRIDE_BUTTON_NATIVE_CLOCK}
