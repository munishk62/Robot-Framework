*** Settings ***
Documentation       This resource contains common keywords and variables for Mobile Native Clock App.

Resource            resources/Mobile/NativeClock/PageResources/LoginPage/native_clock_login.resource
Variables           resources/Mobile/NativeClock/PageResources/Locators/clock.py
Resource            resources/Mobile/NativeClock/PageResources/Registration/registration.resource


*** Variables ***
${LOCATION_PERMISSION_COARSE}       android.permission.ACCESS_COARSE_LOCATION
${LOCATION_PERMISSION_FINE}         android.permission.ACCESS_FINE_LOCATION


*** Keywords ***
Prepare Mobile Native Clock App For Suite Execution
    [Documentation]    This keyword will prepare the Mobile Native Clock App for the test suite execution by registering the app with QR code if not registered already.
    ...    | =Arguments=    | =Description=    |
    ...    | user_key   | User unique key from variation env file.    |
    ...    | clock_registration_template | Clock registration template from base template sheet in variation csv.
    ...    | qr_code | QR code for registration, if not passed it will take from config variable.    |
    ...    Example Usage:
    ...    Prepare Mobile Native Clock App For Suite Execution    ESS-STORE15    clock_registration_template=Template1    qr_code=QR_CODE1
    [Arguments]    ${user_key}    ${clock_registration_template}=${None}    ${qr_code}=${None}
    IF    '${qr_code}' == '${None}'
        ${qr_code}    Get Config Value    qr_code
    END
    Clear Registration Data On Mobile Clock App    ${user_key}
    Register Mobile Clock App With QR Code    ${qr_code}
    IF    '${clock_registration_template}' != '${None}'
        ${clock_template_data}    Get Native Clock Register Data    ${clock_registration_template}
    ELSE
        ${clock_template_data}    Get Native Clock Register Data
    END
    Login Mobile Native Clock App    ${user_key}
    Register With Supervisor On Tablet Clock    ${user_key}    ${clock_template_data}

Clear Registration Data On Mobile Clock App
    [Documentation]    This keyword will clear the registration data from the Mobile Native Clock App if already registered.
    ...    | =Arguments=    | =Description=    |
    ...    | supervisor_user   | Supervisor user unique key from variation env file.   |
    ...    Example Usage:
    ...    Clear Registration Data On Mobile Clock App    ESS-STORE15
    [Arguments]    ${supervisor_user}
    ${CUSTOM_TAB_LOGIN}    Get Config Value    CUSTOM_TAB_LOGIN
    ${is_transaction_page}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible   ${clock_in_button_native_clock}    timeout=10s
    IF    ${is_transaction_page}
        Log To Console    Transaction page is visible
        Clear Data From Transaction Screen    ${supervisor_user}
    ELSE IF    ${CUSTOM_TAB_LOGIN}
        IF    '${MOBILE_PLATFORM}' != 'android'
                Sleep    2s
                Run Keyword And Ignore Error    Click Alert Button    Continue
        END
        Sleep    2s
        Run Keyword And Ignore Error    Click Element    ${close_registration_logout}
    END
    ${is_logout_page}    Run Keyword And Return Status
    ...    Expect Element    ${LOG_BACK_IN_NATIVE_CLOCK}    visible

    ${is_login_page}    Run Keyword And Return Status
    ...    Expect Element    ${settings_button_native_clock}    visible
    IF    ${is_login_page}
        Log To Console    Login page is visible
        Clear Data From Login Screen
    ELSE IF    ${is_logout_page}
        Log To Console    Logout page is visible
        Click Element    ${LOG_BACK_IN_NATIVE_CLOCK}
        Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON_NATIVE_CLOCK}
        Clear Data From Login Screen
    ELSE
        Log To Console    No page is visible so considering as QR code screen
    END

Register Mobile Clock App With QR Code
    [Documentation]    This keyword will register the Mobile Native Clock App with QR code if not registered already by checking the visibility of transaction page.
    ...    Arguments:
    ...    - ${qr_code}: QR code for registration, if not passed it will take from config variable.
    ...    Behavior:
    ...    - Keyword will check if the app is already registered by checking the visibility of transaction page, if visible then it will consider app is registered, if not then it will register the app with QR code.
    ...    Example:
    ...    -    Register Mobile Clock App With QR Code    QR_CODE1
    [Arguments]    ${qr_code}
    ${CUSTOM_TAB_LOGIN}    Get Config Value    CUSTOM_TAB_LOGIN
    IF    '${MOBILE_PLATFORM}' != 'android' and ${CUSTOM_TAB_LOGIN}
       Sleep    2s
       Run Keyword And Ignore Error    Click Alert Button    Allow
    END
    Wait Until Page Contains Element    ${ENTER_REGISTRATION_BUTTON_NATIVE_CLOCK}    30s
    Click Element    ${ENTER_REGISTRATION_BUTTON_NATIVE_CLOCK}
    Wait Until Element Is Visible    ${ENTER_REGISTRATION_FIELD_NATIVE_CLOCK}
    Input Text    ${ENTER_REGISTRATION_FIELD_NATIVE_CLOCK}    ${qr_code}
    IF    '${CLOUD_PLATFORM}' == 'lambdaTest'
        Click Element    ${REGISTRATION_SUBMIT_BUTTON_NATIVE_CLOCK}
    ELSE
        ${is_submit_visible}    Run Keyword And Return Status
        ...    Expect Element    ${REGISTRATION_SUBMIT_BUTTON_NATIVE_CLOCK}    visible
        IF    ${is_submit_visible}
            Log To Console    submit visible
        ELSE
            IF    '${MOBILE_PLATFORM}' == 'android'
                Press Keycode    4
            ELSE
                Click Element    xpath=//XCUIElementTypeButton[@name="Back"]
            END
        END
        Click Element    ${REGISTRATION_SUBMIT_BUTTON_NATIVE_CLOCK}
    END
    IF    '${MOBILE_PLATFORM}' != 'android' and ${CUSTOM_TAB_LOGIN}
       Sleep    2s
       Run Keyword And Ignore Error    Click Alert Button    Continue
    END
    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON_NATIVE_CLOCK}    timeout=60s
