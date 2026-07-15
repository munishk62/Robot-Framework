*** Settings ***
Documentation       This resource contains keyword required for login and registration related features for SM Mobile App.

Library             Process
Library             test_data/TestDataLibrary.py
Library            utils/common_utility/common_utils.py
Resource            resources/Mobile/Common/Mobile_Device_Helper.resource
Variables           resources/Mobile/SM/Locators/SMLogin_Page.py
Variables        resources/Mobile/SM/Locators/SM_More.py


*** Keywords ***
Register Mobile SM App With QR Code
    [Documentation]    Registers the Mobile SM app using the provided QR code.
    ...    Example:
    ...    - Register Mobile SM App With QR Code    <qr_code_value>
    [Arguments]    ${qr_code}
    Wait Until Page Contains Element    ${SM_ENTER_REGISTRATION_BUTTON}    30s
    Click Element    ${SM_ENTER_REGISTRATION_BUTTON}
    Wait Until Page Contains Element    ${SM_ENTER_REGISTRATION_FIELD}
    Run Keyword And Ignore Error    Hide Keyboard
    FOR    ${_}    IN RANGE    10
        Wait Until Page Contains Element    ${SM_ENTER_REGISTRATION_FIELD}
        ${rc}    Run Keyword And Ignore Error    Input Text    ${SM_ENTER_REGISTRATION_FIELD}    ${qr_code}
        IF    '${rc[0]}' == 'PASS'    BREAK
        Sleep    1s
        Run Keyword And Ignore Error    Click Element    ${QR_REGISTRATION_SUBMIT_BUTTON}
        Run Keyword And Ignore Error    Wait Until Page Contains Element    ${SM_LOGIN_SUBMIT_BUTTON}
    END
    Click Element    ${QR_REGISTRATION_SUBMIT_BUTTON}
    ${sm_login_submit_localised}    Get Localised Message From Key For SM    ${SM_LOGIN_SUBMIT_BUTTON_KEY}
    ${sm_login_submit_locator}    Get Message With Arguments    ${SM_LOGIN_SUBMIT_BUTTON}    ${sm_login_submit_localised}
    Wait Until Page Contains Element    ${sm_login_submit_locator}    timeout=60s

Clear Registration Data On Mobile SM App
    [Documentation]    Clears registration data on mobile SM app.
    ...    Example:
    ...    - Clear Registration Data On Mobile SM App
    Accept If App Permissions Popup Displayed On SM IOS App

    # When mobile_chrome_tab_login_enabled is set, the SSO/web login opens in a
    # Chrome Custom Tab. If cleanup starts while that tab is still on top, none of
    # the native SM detectors below can match. Close the tab first so the native
    # launch page (with the Settings gear) reappears, then clear data. Mirrors the
    # ESS `Clear Registration Data On Mobile ESS App` handling.
    ${is_custom_tab_open}    Is Element Present On Mobile    ${SM_CLOSE_CUSTOM_TAB}    timeout=${SHORT_TIMEOUT}
    IF    ${is_custom_tab_open}
        Log To Console    Custom tab is open so closing it
        Click Element    ${SM_CLOSE_CUSTOM_TAB}
        Wait Until Page Does Not Contain Element    ${SM_CLOSE_CUSTOM_TAB}    timeout=${SHORT_TIMEOUT}
        ${is_launch_page}    Is Element Present On Mobile    ${SM_SETTING_BUTTON}    timeout=${SHORT_TIMEOUT}
        IF    ${is_launch_page}
            Log To Console    Login launch page is visible so try to clear data
            Clear Data Mobile SM App
            RETURN
        END
    END

    ${is_registration_page}    Is Element Present On Mobile
    ...    ${SM_ENTER_REGISTRATION_BUTTON}
    ...    timeout=${MEDIUM_TIMEOUT}
    ...    interval=2s
    IF    ${is_registration_page}
        Log To Console    Registration page is visible so no need to clear data
        RETURN
    END

    ${is_logout_page}    Is Element Present On Mobile    ${LOGIN_BACK}    timeout=2s
    IF    ${is_logout_page}
        Log To Console    Logout page is visible so clicking on back button
        Click Element    ${LOGIN_BACK}
        ${sm_login_submit_localised}    Get Localised Message From Key For SM    ${SM_LOGIN_SUBMIT_BUTTON_KEY}
        ${sm_login_submit_locator}    Get Message With Arguments    ${SM_LOGIN_SUBMIT_BUTTON}    ${sm_login_submit_localised}
        Wait Until Page Contains Element    ${sm_login_submit_locator}
        Clear Data Mobile SM App
        RETURN
    END

    ${is_access_denied_page}    Is Element Present On Mobile    ${SM_ACCESS_FORBIDDEN_MESSAGE}    timeout=2s
    IF    ${is_access_denied_page}
        Log To Console    Access denied page is visible, So clicking logout and then clear data
        Click Element    ${SM_LOGOUT}
        Wait Until Page Contains Element    ${LOGIN_BACK}
        Click Element    ${LOGIN_BACK}
        Clear Data Mobile SM App
        RETURN
    END

    ${is_home_page}    Is Element Present On Mobile    ${SM_MORE_BUTTON}    timeout=2s
    IF    ${is_home_page}
        Log To Console    Home page is visible so logging out
        Logout SM App On Mobile
        Clear Data Mobile SM App
        RETURN
    END

    ${is_login_page}    Is Element Present On Mobile    ${SM_SETTING_BUTTON}    timeout=2s
    IF    ${is_login_page}
        Log To Console    Login page is visible so try to clear data
        Clear Data Mobile SM App
        RETURN
    END

Restart Mobile SM App
    [Documentation]    Restart Mobile SM App.
    Terminate Application    ${PACKAGE}
    Launch Mobile SM App

Launch Mobile SM App
    [Documentation]    Launches the SM app
    ...    Example:
    ...    - Launch SM app
    Activate Application    ${PACKAGE}
    Sleep    5s

Login SM App On Mobile
    [Documentation]    Used to login to SM Application.
    ...    The SM app serves the same reflexis web login page either inside its own
    ...    WebView (default) or, for environments where the
    ...    ``mobile_chrome_tab_login_enabled`` flag is set in ``config.json``, inside a
    ...    Chrome Custom Tab (``com.android.chrome``). The credential-entry step
    ...    branches on that flag; the post-login wait for the home ``More`` icon is
    ...    common to both paths.
    ...    | === Arguments === | === Description === |
    ...    | user_key | User unique key from credentials |
    [Arguments]    ${user_key}    ${tc_id}=None
    ${user}    Get User    ${user_key}    mask_password=False
    IF    '${CLOUD_PLATFORM}' == 'lambdaTest' and '${tc_id}' != 'None'
        Stop Mobile Screen Recording    ${tc_id}
        Close Application
        Open SM Native Application On Mobile Phone
        Start Mobile Screen Recording
    END
    ${mobile_chrome_tab_login_enabled}    Is Config Enabled    mobile_chrome_tab_login_enabled
    IF    ${mobile_chrome_tab_login_enabled}
        Enter SM Credentials On Chrome Tab    ${user}
    ELSE
        Enter SM Credentials On Native App    ${user}
    END
    Wait Until Page Contains Element    ${MORE_BUTTON}    timeout=${LONG_TIMEOUT}    error=More icon is not visible on SM app home page

Enter SM Credentials On Native App
    [Documentation]    Enters SM credentials on the default in-app WebView login form
    ...    (used when ``mobile_chrome_tab_login_enabled`` is not set — see
    ...    `Login SM App On Mobile`). The username/password fields are located by the
    ...    generic ``EditText[@password=...]`` locators and the submit button by its
    ...    localised label. Mirrors `Enter SM Credentials On Chrome Tab`.
    ...    | =Arguments= | =Description= |
    ...    | user | User dict containing ``username`` and ``password`` keys. |
    [Tags]    robot:private
    [Arguments]    ${user}
    Wait Until Element Is Visible    ${SM_LOGIN_USERNAME_FIELD}
    ${sm_login_submit_localised}    Get Localised Message From Key For SM    ${SM_LOGIN_SUBMIT_BUTTON_KEY}
    ${sm_login_submit_locator}    Get Message With Arguments    ${SM_LOGIN_SUBMIT_BUTTON}    ${sm_login_submit_localised}
    Wait Until Page Contains Element    ${sm_login_submit_locator}
    Input Text    ${SM_LOGIN_USERNAME_FIELD}    ${user}[username]
    Sleep    1s
    Input Password    ${SM_LOGIN_USERNAME_PASSWORD}    ${user}[password]
    Sleep    1s
    Click Element    ${sm_login_submit_locator}

Enter SM Credentials On Chrome Tab
    [Documentation]    Enters SM credentials when the login page is served inside a
    ...    Chrome Custom Tab (``com.android.chrome``) instead of the in-app WebView.
    ...    Selected by the ``mobile_chrome_tab_login_enabled`` flag in ``config.json``
    ...    (see `Login SM App On Mobile`). Mirrors the ESS Chrome-tab flow: waits for
    ...    Chrome to populate the web accessibility tree, then clicks the located
    ...    ``EditText`` and types directly. The SM web login page is the same HTML as
    ...    the native WebView, so the existing ``SM_LOGIN_*`` locators are reused.
    ...
    ...    Deliberately does NOT call Hide Keyboard — on a Chrome Custom Tab
    ...    AppiumLibrary's Hide Keyboard falls back to a Back keypress, which closes
    ...    the tab before the form can be submitted. The Login button sits near the
    ...    top of the page (above the keyboard) so it stays reachable.
    ...    | =Arguments= | =Description= |
    ...    | user | User dict containing ``username`` and ``password`` keys. |
    [Tags]    robot:private
    [Arguments]    ${user}
    Wait For SM Chrome Tab Login Form
    Input SM Chrome Field    ${SM_LOGIN_USERNAME_FIELD}    ${user}[username]
    Input SM Chrome Field    ${SM_LOGIN_USERNAME_PASSWORD}    ${user}[password]    secret=${True}
    ${sm_login_submit_localised}    Get Localised Message From Key For SM    ${SM_LOGIN_SUBMIT_BUTTON_KEY}
    ${sm_login_submit_locator}    Get Message With Arguments    ${SM_LOGIN_SUBMIT_BUTTON}    ${sm_login_submit_localised}
    Wait Until Page Contains Element    ${sm_login_submit_locator}    timeout=30s
    Wait Until Keyword Succeeds    5x    3s    Click Element    ${sm_login_submit_locator}

Input SM Chrome Field
    [Documentation]    Types into a Chrome Custom Tab login field by clicking the
    ...    located ``android.widget.EditText`` (to focus it and open the keyboard) and
    ...    then calling Input Text / Input Password, retrying up to ${attempts} times
    ...    because Chrome can briefly re-render the web a11y tree. Never taps blind
    ...    screen coordinates (which risk hitting the adjacent Login button). Mirrors
    ...    `Input Mobile ESS Chrome Field`.
    ...    | =Arguments= | =Description= |
    ...    | locator | AppiumLibrary locator for the Chrome EditText. |
    ...    | text | Text to type into the field. |
    ...    | secret | ${True} -> use Input Password (masks logging). Default False. |
    ...    | attempts | Max retry attempts. Default 5. |
    [Tags]    robot:private
    [Arguments]    ${locator}    ${text}    ${secret}=${False}    ${attempts}=5
    Wait Until Page Contains Element    ${locator}    timeout=30s
    FOR    ${i}    IN RANGE    ${attempts}
        Run Keyword And Ignore Error    Click Element    ${locator}
        Sleep    0.5s
        IF    ${secret}
            ${ok}    Run Keyword And Return Status    Input Password    ${locator}    ${text}
        ELSE
            ${ok}    Run Keyword And Return Status    Input Text    ${locator}    ${text}
        END
        IF    ${ok}
            Log    Typed into ${locator} on attempt ${i+1} (Chrome Custom Tab).
            RETURN
        END
        Sleep    1s
    END
    Fail    Could not type into ${locator} after ${attempts} attempts on the SM Chrome Custom Tab login form.

Wait For SM Chrome Tab Login Form
    [Documentation]    Waits until the SM Chrome Custom Tab login form is DOM-ready by
    ...    polling Get Source for the web login placeholders that Chrome surfaces in
    ...    the accessibility tree, issuing periodic wake-taps to force Chrome to
    ...    (re)populate the web a11y tree. Mirrors `Wait For Mobile ESS Chrome Tab Login Form`.
    ...    | =Arguments= | =Description= |
    ...    | timeout | Total time budget. Default 90s. |
    ...    | poll_interval | Sleep between source polls. Default 2s. |
    ...    | wake_every | Issue a wake-tap every N polls. Default 8 (~16s). |
    [Tags]    robot:private
    [Arguments]    ${timeout}=90s    ${poll_interval}=2s    ${wake_every}=8
    ${timeout_s}    Convert Time    ${timeout}    result_format=number
    ${interval_s}    Convert Time    ${poll_interval}    result_format=number
    ${max_iters}    Evaluate    int(${timeout_s} / ${interval_s}) + 1
    VAR    ${ready}    ${False}
    FOR    ${i}    IN RANGE    ${max_iters}
        ${ok}    Run Keyword And Return Status    All SM Chrome Tab Login Markers In Source
        IF    ${ok}
            VAR    ${ready}    ${True}
            BREAK
        END
        IF    ${i} > 0 and (${i} % ${wake_every}) == 0
            Run Keyword And Ignore Error    Wake SM Accessibility Tree
        END
        Sleep    ${poll_interval}
    END
    IF    not ${ready}
        Fail    SM Chrome Tab login form did not become DOM-ready within ${timeout}. Get Source never contained the username/password placeholders — the Chrome web accessibility tree may not have been populated. See screenshot in teardown.
    END
    Log    SM Chrome Tab login form is ready (Get Source contained the username and password placeholders at iteration ${i}).

All SM Chrome Tab Login Markers In Source
    [Documentation]    Asserts the live accessibility tree (via Get Source) contains the
    ...    Chrome Custom Tab login placeholders (``Enter username`` / ``Enter password``).
    ...    Used as the gate inside `Wait For SM Chrome Tab Login Form`. Kept as a separate
    ...    keyword so it can be wrapped in Run Keyword And Return Status.
    [Tags]    robot:private
    ${src}    Get Source
    Should Contain    ${src}    Enter username    msg=Chrome tab login form not yet rendered: username placeholder missing
    Should Contain    ${src}    Enter password    msg=Chrome tab login form not yet rendered: password placeholder missing

Wake SM Accessibility Tree
    [Documentation]    Forces the Chrome Custom Tab / WebView accessibility tree to
    ...    refresh by issuing a tap gesture near the top of the login form. Native
    ...    EditText overlays inside a WebView are sometimes lazy-populated into the
    ...    accessibility tree only after the WebView receives a touch event, even when
    ...    the fields are painted. The tap targets ~25% from the top (username row on
    ...    the login layout). Mirrors `Wake Mobile ESS Accessibility Tree`.
    [Tags]    robot:private
    ${width}    Get Window Width
    ${height}    Get Window Height
    ${cx}    Evaluate    int(${width} / 2)
    ${cy}    Evaluate    int(${height} * 0.25)
    IF    '${MOBILE_PLATFORM}' == 'ios'
        Execute Script    mobile: tap    x=${cx}    y=${cy}
    ELSE
        Execute Script    mobile: clickGesture    x=${cx}    y=${cy}
    END
    Log    Wake-tap dispatched at (${cx}, ${cy}) to refresh the SM login WebView a11y tree.

Logout SM App On Mobile
    [Documentation]    Used to logout the application from top level page (Flutter-only).
    ...    Behavior:
    ...    - Keyword will work from top level pages of sm modules and then proceed to logout.
    ...    Example:
    ...    - Logout SM App On Mobile
    Sleep    3s
    Wait Until Page Contains Element    ${SM_MORE_BUTTON}
    Click Element    ${SM_MORE_BUTTON}
    ${localised_logout_text}    Get Localised Message From Key For SM    1000000000022
    ${localised_logout_locator}    Get Message With Arguments    ${SM_LOGOUT_BTN}    ${localised_logout_text}
    Wait Until Page Contains Element    ${localised_logout_locator}
    Click Element    ${localised_logout_locator}
    Wait Until Page Contains Element    ${SM_LOGOUT_YES}
    Click Element    ${SM_LOGOUT_YES}
    Expect Element   ${LOGIN_BACK}    state=visible    timeout=${PAGE_LOAD_TIMEOUT}    retry_interval=${SHORT_TIMEOUT}    message=Login back button is not visible after logout
    Click Element    ${LOGIN_BACK}
    # The logged-out screen and its "click here to login" button (LOGIN_BACK) are
    # native on both paths. When mobile_chrome_tab_login_enabled is set, tapping it
    # relaunches the web login inside a Chrome Custom Tab, so confirm we are back at
    # login via the Chrome web form; otherwise confirm via the native submit button.
    ${mobile_chrome_tab_login_enabled}    Is Config Enabled    mobile_chrome_tab_login_enabled
    IF    ${mobile_chrome_tab_login_enabled}
        Wait For SM Chrome Tab Login Form
    ELSE
        ${sm_login_submit_localised}    Get Localised Message From Key For SM    ${SM_LOGIN_SUBMIT_BUTTON_KEY}
        ${sm_login_submit_locator}    Get Message With Arguments    ${SM_LOGIN_SUBMIT_BUTTON}    ${sm_login_submit_localised}
        Wait Until Page Contains Element    ${sm_login_submit_locator}    timeout=${PAGE_LOAD_TIMEOUT}
    END

Clear Data Mobile SM App
    [Documentation]    Clears registration    on flutter app
    ...    Behavior:
    ...    - Keyword waits page contains login button and then proceed to clear data.
    ...    Precondition:
    ...    - App should be on login page and settings button should be visible.
    ...    Example:
    ...    - Clear Data Mobile SM App
    ${sm_login_submit_localised}    Get Localised Message From Key For SM    ${SM_LOGIN_SUBMIT_BUTTON_KEY}
    ${sm_login_submit_locator}    Get Message With Arguments    ${SM_LOGIN_SUBMIT_BUTTON}    ${sm_login_submit_localised}
    Wait Until Page Contains Element    ${sm_login_submit_locator}
    Wait Until Page Contains Element    ${SM_SETTING_BUTTON}
    Click Element    ${SM_SETTING_BUTTON}
    Wait Until Page Contains Element    ${SM_CLEAR_DATA_BUTTON}
    Click Element    ${SM_CLEAR_DATA_BUTTON}
    # Android does not show confirmation pop up but iOS shows confirmation pop up to clear data, so handling that flow here.
    ${is_confirm_popup_visible}    Is Element Present On Mobile    ${SM_CONFIRM_CLEAR_DATA}    timeout=5s
    IF    ${is_confirm_popup_visible}
        Click Element    ${SM_CONFIRM_CLEAR_DATA}
    END
    Wait Until Page Contains Element    ${SM_ENTER_REGISTRATION_BUTTON}

Accept If App Permissions Popup Displayed On SM IOS App
    [Documentation]    Accept SM app permissions if permission pop up is displayed this is specific to iOS as it shows permission pop up on app launch.
    ...    Example:
    ...    - Accept If App Permissions Popup Displayed On SM IOS App
    ${is_android}    Evaluate    '${MOBILE_PLATFORM}' == 'android'
    IF    not ${is_android}
        Run Keyword And Ignore Error    Execute Script    mobile: alert    action=accept    buttonLabel=Allow
        Run Keyword And Ignore Error    Execute Script    mobile: alert    action=accept    buttonLabel=OK
    END
