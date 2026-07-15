*** Settings ***
Documentation       This resource contains keyword required for login and registration related features.

Library             Process
Resource            resources/Mobile/Common/Mobile_Device_Helper.resource
Variables           resources/Mobile/NativeClock/PageResources/Locators/login.py


*** Keywords ***
Login Mobile Native Clock App
    [Documentation]    Used to login of Mobile Native Clock Application.
    ...    Arguments:
    ...    - ${user_key}: User unique key from master users sheet.
    ...    - ${tc_id}: Test case id, used for logging purpose.
    ...    Behavior:
    ...    - Keyword will always try to clear data and fresh register to ensure right registration for every run.
    ...    Example:
    ...    - Login Mobile Native Clock App    ESS-LOGIN-USER1
    [Arguments]    ${user_key}    ${tc_id}=None
    IF    '${MOBILE_PLATFORM}' == 'android'
        Login Mobile Native Android Clock App    ${user_key}
    ELSE
        Login Mobile Native IOS Clock App    ${user_key}
    END

Login Mobile Native Android Clock App
    [Documentation]    Used to login of NextGen Application.
    ...    | =Arguments=    | =Description=    |
    ...    | user_key   | User unique key from env.    |
    [Arguments]    ${user_key}
    ${user}=    Get User    ${user_key}    mask_password=False
    FOR    ${_}    IN RANGE    2
        ${rc}=    Run Keyword And Ignore Error    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}    30s
        IF    '${rc[0]}' == 'PASS'    BREAK
        Sleep    1s
    END
    FOR    ${_}    IN RANGE    2
        Wait Until Element Is Visible    ${LOGIN_USERNAME_FIELD}
        ${rc}=    Run Keyword And Ignore Error    Input Text    ${LOGIN_USERNAME_FIELD}    ${user}[username]
        IF    '${rc[0]}' == 'PASS'    BREAK
        Sleep    1s
    END
    FOR    ${_}    IN RANGE    2
        Wait Until Element Is Visible    ${LOGIN_USERNAME_PASSWORD}
        ${rc}=    Run Keyword And Ignore Error    Input Password    ${LOGIN_USERNAME_PASSWORD}    ${user}[password]
        IF    '${rc[0]}' == 'PASS'    BREAK
        Sleep    1s
    END
    FOR    ${_}    IN RANGE    2
        ${rc}=    Run Keyword And Ignore Error    Click Element    ${LOGIN_SUBMIT_BUTTON}
        IF    '${rc[0]}' == 'PASS'    BREAK
        Sleep    1s
    END

Login Mobile Native IOS Clock App
    [Documentation]    Used to login of Mobile Native IOS Clock Application.
    ...    Arguments:
    ...    - ${user_key}: User unique key from master users sheet.
    ...    Behavior:
    ...    - Keyword will always try to clear data and fresh register to ensure right registration for every run.
    ...    Example:
    ...    - Login Mobile Native IOS Clock App    ESS-LOGIN-USER1
    [Arguments]    ${user_key}
    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON_NATIVE}    timeout=60s
    ${user}=    Get User    ${user_key}
    Wait Until Element Is Visible    ${LOGIN_USERNAME_FIELD_NATIVE}    60s
    Input Text    ${LOGIN_USERNAME_FIELD_NATIVE}    ${user}[username]
    Sleep    2s
    Click Element    ${LOGIN_USERNAME_PASSWORD_NATIVE}
    Sleep    2s
    Input Password    ${LOGIN_USERNAME_PASSWORD_NATIVE}    ${user}[password]
    Click Element    ${LOGIN_SUBMIT_BUTTON_NATIVE}

Allow Location Access For Native Clock App
    [Documentation]    This keyword is used to allow location access for IOS Native ESS App.
    IF    '${MOBILE_PLATFORM}'=='ios' and '${CLOUD_PLATFORM}' == 'lambdaTest'
        # NOTE: For iOS, System permission popup is not handled by Appium, so need to handle it manually by tapping on the screen.
        # This is a temporary solution until we find a better way to handle permission popups in iOS.
        Sleep    5s
        ${width}=    Get Window Width
        ${height}=    Get Window Height
        ${x}=    Evaluate    ${width} / 2
        ${y}=    Evaluate    ${height} * 0.75
        Execute Script    mobile: tap    x=${x}    y=${y}
    END

Clear Data From Login Screen
    [Documentation]    This keyword will clear the data from login screen of Native Clock App.
    ...    Behavior:
    ...    - Keyword will clear the data from login screen.
    ...    Example:
    ...    -    Clear Data From Login Screen
    Wait Until Element Is Visible    ${settings_button_native_clock}
    Click Element    ${settings_button_native_clock}
    Swipe Until Visible    ${clear_data_button_native_clock}
    Click Element    ${clear_data_button_native_clock}
    IF    '${MOBILE_PLATFORM}' != 'android'
        Wait Until Element Is Visible    ${continue_button_native_clock}
        Click Element    ${continue_button_native_clock}
    END
    Wait Until Element Is Visible    ${ENTER_REGISTRATION_BUTTON_NATIVE_CLOCK}

Clear Data From Transaction Screen
    [Documentation]    This keyword will clear the data from transaction screen of Native Clock App.
    ...    Arguments:
    ...    - ${user_key}: User unique key from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will clear the data from transaction screen.
    ...    Example:
    ...    -    Clear Data From transaction Screen
    [Arguments]    ${user_key}
    ${CUSTOM_TAB_LOGIN}=    Get Config Value    CUSTOM_TAB_LOGIN
    Wait Until Element Is Visible    ${settings_button_native_clock}
    Click Element    ${settings_button_native_clock}
    IF    ${CUSTOM_TAB_LOGIN} and '${MOBILE_PLATFORM}' != 'android'
        Sleep    2s
        Run Keyword And Ignore Error    Click Alert Button    Continue
    END
    Login Mobile Native Clock App    ${user_key}
    Wait Until Element Is Visible    ${reset_application}
    Click Element    ${reset_application}
    Wait Until Element Is Visible    ${reset_application_option}
    Click Element    ${reset_application_option}
    Wait Until Element Is Visible    ${reset_proceed_button}
    Click Element    ${reset_proceed_button}
    IF    ${CUSTOM_TAB_LOGIN}
        IF    '${MOBILE_PLATFORM}' != 'android'
            Sleep    2s
            Run Keyword And Ignore Error    Click Alert Button    Continue
        END
        Click Element    ${close_registration_logout}
    END
    Wait Until Element Is Visible    ${LOG_BACK_IN_NATIVE_CLOCK}
    Click Element    ${LOG_BACK_IN_NATIVE_CLOCK}
    IF    ${CUSTOM_TAB_LOGIN}
        IF    '${MOBILE_PLATFORM}' != 'android'
            Sleep    2s
            Run Keyword And Ignore Error    Click Alert Button    Continue
        END
        Wait Until Element Is Visible    ${close_registration_logout}
        Click Element    ${close_registration_logout}
    END
    Clear Data From Login Screen
