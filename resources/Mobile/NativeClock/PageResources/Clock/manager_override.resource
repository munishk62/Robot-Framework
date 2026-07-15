*** Settings ***
Documentation       This resource contains keyword required for clock transaction feature.

Resource            resources/Mobile/Common/Mobile_Device_Helper.resource
Resource            resources/Mobile/NativeClock/PageResources/Clock/clock.resource
Variables           resources/Mobile/NativeClock/PageResources/Locators/manager_override_page.py


*** Keywords ***
Set Override Punch Time With Relative Changes For Manager Override On Tablet Clock App
    [Documentation]
    ...    Sets the override punch time using relative changes from current time.
    ...    | =Arguments= | =Description= |
    ...    | hour_change | Hour change (e.g., 2, -1, 0 for no change) |
    ...    | minute_change | Minute change (e.g., 15, -5, 0 for no change) |
    ...    | am_pm | Target AM/PM (optional, use current if not specified) |
    ...    | day_option | Yesterday, Today, or Tomorrow (default: Today) |
    ...    Example usage:
    ...    | Set Override Punch Time With Relative Changes On Tablet Clock App    -1    30    pm    Today
    ...    | Set Override Punch Time With Relative Changes On Tablet Clock App    0    -5    day_option=Today
    [Arguments]    ${hour_change}    ${minute_change}    ${am_pm}=${EMPTY}    ${day_option}=Today
    Wait Until Element Is Visible    ${OVERRIDE_PUNCH_TIME_DIALOG}    timeout=10s

    # Select day option
    IF    '${day_option}' == 'Yesterday'
        Click Element    ${OVERRIDE_YESTERDAY_RADIO}
    END
    IF    '${day_option}' == 'Today'    Click Element    ${OVERRIDE_TODAY_RADIO}
    IF    '${day_option}' == 'Tomorrow'
        Click Element    ${OVERRIDE_TOMORROW_RADIO}
    END

    # Apply relative changes to time pickers
    Wait Until Element Is Visible    ${OVERRIDE_HOUR_PICKER}    error=Override hour time swipe element did not appear as expected.
    IF    ${hour_change} > 0 or ${hour_change} < 0
        Apply Time Picker Change On Tablet Clock App    hour    ${hour_change}
    END

    IF    ${minute_change} > 0 or ${minute_change} < 0
        Apply Time Picker Change On Tablet Clock App    minute    ${minute_change}
    END

    # Set AM/PM if specified
    IF    '${am_pm}' != '${EMPTY}'
        IF    '${am_pm}' in ['AM', 'am']
            Swipe Time Picker Relative Steps On Manager Override Selector On Tablet Clock App    ${OVERRIDE_AMPM_PICKER}    -1
        ELSE
            Swipe Time Picker Relative Steps On Manager Override Selector On Tablet Clock App    ${OVERRIDE_AMPM_PICKER}    1
        END
    END

Apply Time Picker Change On Tablet Clock App
    [Documentation]
    ...    Applies relative change to a time picker (hour/minute) on the tablet clock app.
    ...    | =Arguments= | =Description= |
    ...    | picker_type | Type of picker (hour, minute) |
    ...    | change_value | Positive for forward/down swipe, negative for backward/up swipe |
    ...    Example usage:
    ...    | Apply Time Picker Change On Tablet Clock App    minute    -5
    ...    | Apply Time Picker Change On Tablet Clock App    hour    +2
    [Arguments]    ${picker_type}    ${change_value}

    # Get the appropriate picker element
    IF    '${picker_type}' == 'hour'
        VAR    ${picker_element}    ${OVERRIDE_HOUR_PICKER}
    ELSE IF    '${picker_type}' == 'minute'
        VAR    ${picker_element}    ${OVERRIDE_MINUTE_PICKER}
    ELSE
        Fail    Invalid picker type: ${picker_type}. Expected 'hour' or 'minute'.
    END

    Wait Until Element Is Visible    ${picker_element}    timeout=5s

    # Convert change value to integer
    ${steps}    Convert To Integer    ${change_value}

    # Perform swipe gestures based on change direction
    Swipe Time Picker Relative Steps On Manager Override Selector On Tablet Clock App    ${picker_element}    ${steps}

Swipe Time Picker Relative Steps On Manager Override Selector On Tablet Clock App
    [Documentation]
    ...    Performs swipe gestures based on relative step count.
    ...    | =Arguments= | =Description= |
    ...    | picker_element | The picker element to swipe on |
    ...    | steps | Number of steps - positive=forward/down, negative=backward/up |
    ...    Example usage:
    ...    | Swipe Time Picker Relative Steps On Manager Override Selector On Tablet Clock App    ${MINUTE_PICKER}    -5
    ...    | Swipe Time Picker Relative Steps On Manager Override Selector On Tablet Clock App    ${HOUR_PICKER}    2
    [Arguments]    ${picker_element}    ${steps}

    IF    '${steps}' == '0'
        Log    No change requested, skipping swipe
        RETURN
    END

    # Get picker element coordinates and size
    ${location}    Get Element Location    ${picker_element}
    ${size}    Get Element Size    ${picker_element}

    ${center_x}    Evaluate    int(${location}[x] + ${size}[width] / 2)
    ${center_y}    Evaluate    int(${location}[y] + ${size}[height] / 2)
    ${swipe_distance}    Evaluate    int(${size}[height] * 0.05)    # Swipe distance as 5% of picker height

    ${abs_steps}    Evaluate    abs(${steps})

    # Perform swipe gestures
    FOR    ${i}    IN RANGE    ${abs_steps}
        IF    ${steps} > 0
            ${end_y}    Evaluate    ${center_y} - ${swipe_distance}
            Log    Swiping down (forward) - step ${i+1} of ${abs_steps}
        ELSE
            ${end_y}    Evaluate    ${center_y} + ${swipe_distance}
            Log    Swiping up (backward) - step ${i+1} of ${abs_steps}
        END

        Swipe    start_x=${center_x}    start_y=${center_y}    end_x=${center_x}    end_y=${end_y}    duration=100ms
        Sleep    0.5s    # Allow picker animation to complete
    END

Tap Submit Punch Override Button On Tablet Clock App
    [Documentation]
    ...    Submits the override punch time after setting values.
    ...    This keyword clicks the submit button and waits for the override dialog to close.
    ...    Example usage:
    ...    | Tap Submit Punch Override Button On Tablet Clock App
    Click Element    ${SUBMIT_PUNCH_OVERRIDE_BUTTON}
    Wait Until Page Does Not Contain Element    ${OVERRIDE_PUNCH_TIME_DIALOG}    timeout=10s

Initiate Override On Manager Override On Tablet Clock App
    [Documentation]
    ...    Enters supervisor credentials and submits punch override on manager override screen of tablet clock app.
    ...    | =Arguments= | =Description= |
    ...    | supervisor_user | Supervisor user key from user credentials file |
    ...    Example usage:
    ...    | Initiate Override On Manager Override On Tablet Clock App    supervisor_test
    [Arguments]    ${supervisor_user}
    ${supervisor_credentials}    Get User    ${supervisor_user}    mask_password=false
    Wait Until Element Is Visible    ${SUPERVISOR_ID_FIELD}
    Input Text    ${SUPERVISOR_ID_FIELD}    ${supervisor_credentials}[clock_supervisor_id]
    Input Password    ${SUPERVISOR_PASSWORD_FIELD}    ${supervisor_credentials}[clock_supervisor_password]
    Click Element    ${OVERRIDE_BUTTON}
    Wait Until Element Is Visible    ${VERIFIED_DIALOG_OK_BUTTON}
    Click Element    ${VERIFIED_DIALOG_OK_BUTTON}

Perform Manager Override On Tablet Clock App
    [Documentation]
    ...    Performs manager override for punches from tablet clock app by entering supervisor credentials and setting override punch time.
    ...    | =Arguments= | =Description= |
    ...    | supervisor_user | Supervisor user key from user credentials file |
    ...    | hour_change | Hour change for override punch time (e.g., 2, -1, 0 for no change) |
    ...    | minute_change | Minute change for override punch time (e.g., 15, -5, 0 for no change) |
    ...    | am_pm | Target AM/PM for override punch time (optional, use current if not specified) |
    ...    | day_option | Day option for override punch time: Yesterday, Today, or Tomorrow (default: Today) |
    ...    Example usage:
    ...    | Perform Manager Override On Tablet Clock App    supervisor_test    -1    30    pm    Today
    ...    | Perform Manager Override On Tablet Clock App    supervisor_test    0    -5
    [Arguments]    ${supervisor_user}    ${hour_change}    ${minute_change}    ${am_pm}=${EMPTY}    ${day_option}=Today
    Open Manager Override On Tablet Clock App
    Initiate Override On Manager Override On Tablet Clock App    ${supervisor_user}
    Set Override Punch Time With Relative Changes For Manager Override On Tablet Clock App    ${hour_change}    ${minute_change}    ${am_pm}    ${day_option}
    Tap Submit Punch Override Button On Tablet Clock App

Cancel Manager Override Dialog Or Page If Visible On Tablet Clock App
    [Documentation]
    ...    This keyword will cancel the manager override dialog or page on tablet clock app if it is visible by clicking on cancel button.
    ...    Example usage:
    ...    | Cancel Manager Override Dialog Or Page If Visible On Tablet Clock App
    ${is_dialog_cancel_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${CANCEL_PUNCH_OVERRIDE_BUTTON}
    IF    ${is_dialog_cancel_visible}
        Click Element    ${CANCEL_PUNCH_OVERRIDE_BUTTON}
        Log    Manager override dialog was visible and has been cancelled.
    END
    ${is_page_cancel_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${CANCEL_BUTTON}
    IF    ${is_page_cancel_visible}
        Click Element    ${CANCEL_BUTTON}
        Log    Manager override page was visible and has been cancelled.
    END
