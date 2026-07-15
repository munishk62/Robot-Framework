*** Settings ***
Documentation       This resource file contains keywords which are common for android and iOS devices for performing keyEvent interactions.
...                 To use this resource file, Import this in the settings section as shown below:
...                 | ****** Settings ******
...                 | Resource    resources/Mobile/Common/MobileKeyboardUtils.resource

Resource            resources/Mobile/Common/Mobile_Device_Helper.resource


*** Keywords ***
Press Keycode For Key Event
    [Documentation]    Press keycode based on key event
    ...    Args:
    ...    ${keyCode}: Keycode for key to be pressed.
    [Arguments]    ${key_code}
    Press Keycode    ${key_code}

Press Enter On Mobile Keyboard
    [Documentation]    Press Enter On Mob Keyboard
    Press Keycode For Key Event    66

Press Esc On Mobile Keyboard
    [Documentation]    Press Esc On Mob Keyboard
    Press Keycode For Key Event    111

Hide Mobile Keyboard
    [Documentation]    Hide Mobile Keyboard
    IF    '${MOBILE_PLATFORM}'=='android'
        Hide Keyboard
    ELSE
        Wait Until Page Contains Element    //XCUIElementTypeButton[@name="Done"]
        Click Element    //XCUIElementTypeButton[@name="Done"]
    END

Press Search On IOS Keyboard
    [Documentation]    Press Search On iOS Keyboard
    Wait Until Page Contains Element    //XCUIElementTypeButton[@name="Search"]
    Click Element    //XCUIElementTypeButton[@name="Search"]
