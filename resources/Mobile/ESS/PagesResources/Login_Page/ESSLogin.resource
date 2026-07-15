*** Settings ***
Documentation       This resource contains keyword required for login and registration related features.

Library             Process
Library             test_data/TestDataLibrary.py
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Home_Module/Home.resource
Resource            resources/web/rws/admin/rws_upload_api.resource
Variables           resources/Mobile/ESS/Locators/common_data.py
Variables           resources/Mobile/ESS/Locators/Login.py


*** Variables ***
${APP_TERMINATION_WAIT_TIME}    2s


*** Keywords ***
Login Mobile Ess App
    [Documentation]    Used to login to ESS Application (Flutter-only).
    ...    Arguments:
    ...    - ${user_key}: User unique key from variation csv sheets.
    ...    - ${tc_id}: Test case id to link the screen recording in lambdaTest, default is None.
    ...    - ${is_new_hire}: Boolean flag to indicate if the user is a new hire, default is False.
    ...    Behavior:
    ...    - Keyword will login with provided credentials.
    ...    Example:
    ...    - Login Mobile Ess App    ESS-USER1    tc_id=battc00224    is_new_hire=False
    [Arguments]    ${user_key}    ${tc_id}=None    ${is_new_hire}=False

    IF    ${is_new_hire}
        ${user}=    Get Dynamic Employee    ${user_key}
        VAR    ${UNIT_ID}=    ${user}[unitID]    scope=TEST
    ELSE
        ${user}=    Get User    ${user_key}    mask_password=False
        VAR    ${UNIT_ID}=    ${user}[unitID]    scope=TEST
    END
    # instead of the in-app hybrid WebView. This is signalled per-environment by the
    # mobile_chrome_tab_login_enabled flag in config.json; when set we use the Chrome-tab
    # locators and flow, otherwise the standard in-app hybrid login runs unchanged.
    ${mobile_chrome_tab_login_enabled}=    Is Config Enabled    mobile_chrome_tab_login_enabled
    IF    ${mobile_chrome_tab_login_enabled}
        Enter Mobile ESS Credentials On Chrome Tab    ${user}
    ELSE
        Enter Mobile ESS Credentials On In App Web View    ${user}
    END
    Accept Location Permission If Asked On Mobile ESS App
    Verify Mobile ESS Associate Name    ${user}[displayName]
    Sleep    10s

Wait For Mobile ESS Login Form
    [Documentation]    Waits until the ESS login form DOM has fulfilled by polling
    ...    Get Source for marker strings that prove username, password and the
    ...    submit row are all rendered.
    ...
    ...    Why source-polling instead of Wait Until Page Contains Element:
    ...    AppiumLibrary's Wait Until Page Contains Element is implemented via
    ...    findElementsByXPath on the Appium server, which on this hybrid
    ...    WebView/Flutter login form intermittently misses elements that
    ...    getPageSource returns in the same instant — concrete evidence from
    ...    run_20 of intermittent_BATTC00112_20260620_003743 where the wait
    ...    timed out at 01:09:24.971 and Get Source 24 ms later returned a tree
    ...    that contained the password EditText.
    ...
    ...    Why a periodic wake-tap recovery:
    ...    Even getPageSource is not always sufficient on this hybrid app —
    ...    run_06 of intermittent_BATTC00112_20260620_012301 polled Get Source
    ...    31 times over 75 s and the returned tree never contained the
    ...    EditText nodes even though the screenshot from the same instant
    ...    showed the form fully painted with the username/password fields
    ...    visible. UiAutomator2 lazy-populates native EditText overlays
    ...    inside a WebView into the accessibility tree only after the
    ...    WebView receives a touch event. We periodically tap the form area
    ...    during the wait so that the a11y tree is refreshed and Get Source
    ...    starts returning the complete tree.
    ...
    ...    Args:
    ...    - ${timeout}: Total time budget. Default 90s.
    ...    - ${poll_interval}: Sleep between source polls. Default 2s.
    ...    - ${wake_every}: Issue a wake-tap every N polls. Default 8 (~16s).
    ...    Example:
    ...    - Wait For Mobile ESS Login Form
    ...    - Wait For Mobile ESS Login Form    timeout=120s    poll_interval=3s
    [Tags]    robot:private
    [Arguments]    ${timeout}=90s    ${poll_interval}=2s    ${wake_every}=8
    ${timeout_s}=    Convert Time    ${timeout}    result_format=number
    ${interval_s}=    Convert Time    ${poll_interval}    result_format=number
    ${max_iters}=    Evaluate    int(${timeout_s} / ${interval_s}) + 1
    VAR    ${ready}    ${False}
    FOR    ${i}    IN RANGE    ${max_iters}
        ${ok}=    Run Keyword And Return Status    All ESS Login Form Markers In Source
        IF    ${ok}
            VAR    ${ready}    ${True}
            BREAK
        END
        IF    ${i} > 0 and (${i} % ${wake_every}) == 0
            Run Keyword And Ignore Error    Wake Mobile ESS Accessibility Tree
        END
        Sleep    ${poll_interval}
    END
    IF    not ${ready}
        Fail    ESS login form did not become DOM-ready within ${timeout}. Last Get Source did not contain the username/password EditText markers — see screenshot in teardown.
    END
    Log    Mobile ESS login form DOM is fulfilled (Get Source contained username, password, and form-container markers at iteration ${i}).

All ESS Login Form Markers In Source
    [Documentation]    Asserts the live accessibility tree (via Get Source)
    ...    contains the markers for username, password and the form container.
    ...    Used as the gate inside Wait For Mobile ESS Login Form. Kept as a
    ...    separate keyword so it can be wrapped in Run Keyword And Return Status.
    ...
    ...    The username/password placeholder markers (``Enter username`` /
    ...    ``Enter password``) appear on both platforms. The form-container
    ...    marker is platform-specific: Android exposes the WebView resource-id
    ...    ``primaryAuthenticationContainer``, which does not exist in the iOS
    ...    XCUITest tree; on iOS the equivalent proof that the form is rendered
    ...    and interactive is the ``XCUIElementTypeSecureTextField`` password
    ...    node (evidence: run in results_QA29_V1 where Get Source contained
    ...    both placeholders and the secure text field but never the Android
    ...    container id).
    [Tags]    robot:private
    ${src}=    Get Source
    Should Contain    ${src}    Enter username    msg=Login form not yet rendered: username field markers missing
    Should Contain    ${src}    Enter password    msg=Login form not yet rendered: password field markers missing
    IF    '${MOBILE_PLATFORM}' == 'ios'
        Should Contain    ${src}    XCUIElementTypeSecureTextField    msg=Login form not yet rendered: iOS secure text field node missing
    ELSE
        Should Contain    ${src}    primaryAuthenticationContainer    msg=Login form not yet rendered: form container marker missing
    END

Enter Mobile ESS Credentials On In App Web View
    [Documentation]    Enters ESS credentials on the standard in-app hybrid
    ...    WebView/Flutter login form (the default flow used when
    ...    ``mobile_chrome_tab_login_enabled`` is not set in ``config.json`` — see
    ...    `Login Mobile Ess App`). Selects the language first when ``LOCALE`` is not
    ...    ``en_US``, then uses the coordinate wake-tap input strategy required by the
    ...    hybrid WebView's lazy accessibility overlays (see `Tap And Input Mobile ESS
    ...    Field`). Mirrors `Enter Mobile ESS Credentials On Chrome Tab`.
    ...    | =Arguments= | =Description= |
    ...    | user | User dict containing ``username`` and ``password`` keys. |
    [Tags]    robot:private
    [Arguments]    ${user}
    ${LANG_CODE}=    Get Config Value    LOCALE
    Log    Read language code as: ${LANG_CODE}
    IF    '${LANG_CODE}' != 'en_US'
        Log    Language code is ${LANG_CODE} and selecting language on app
        Select Language On Mobile ESS App    language=${LANG_CODE}
    END
    Wait For Mobile ESS Login Form
    Tap And Input Mobile ESS Field    ${LOGIN_USERNAME_FIELD}    ${user}[username]    tap_y_ratio=0.25
    Tap And Input Mobile ESS Field    ${LOGIN_USERNAME_PASSWORD}    ${user}[password]    tap_y_ratio=0.32    secret=${True}
    Run Keyword And Ignore Error    Hide Keyboard
    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}    timeout=30s
    Wait Until Keyword Succeeds    5x    3s    Click Mobile ESS Login Button

Enter Mobile ESS Credentials On Chrome Tab
    [Documentation]    Enters ESS credentials when the login page is served inside a
    ...    Chrome Custom Tab (``com.android.chrome``) instead of the in-app hybrid
    ...    WebView. Selected by the ``CHROME_TAB_LOGIN_ENABLED`` flag in ``config.json``
    ...    (see `Login Mobile Ess App`). Uses the Chrome-tab-specific locators that
    ...    target the web inputs as Chrome surfaces them in the accessibility tree.
    ...
    ...    Unlike the in-app hybrid WebView, once Chrome populates the web a11y tree
    ...    the inputs are real, stable ``android.widget.EditText`` nodes (confirmed by a
    ...    live PNQPILOT06 page source), so this flow clicks the located element and
    ...    types directly instead of doing blind coordinate wake-taps — a coordinate
    ...    tap on the compact Chrome layout can land on the adjacent Login button and
    ...    submit the form prematurely.
    ...    | =Arguments= | =Description= |
    ...    | user | User dict containing ``username`` and ``password`` keys. |
    [Tags]    robot:private
    [Arguments]    ${user}
    Wait For Mobile ESS Chrome Tab Login Form
    Input Mobile ESS Chrome Field    ${LOGIN_USERNAME_FIELD_CHROME}    ${user}[username]
    Input Mobile ESS Chrome Field    ${LOGIN_USERNAME_PASSWORD_CHROME}    ${user}[password]    secret=${True}
    # Intentionally NOT calling Hide Keyboard here: on a Chrome Custom Tab
    # AppiumLibrary's Hide Keyboard falls back to a Back keypress, which closes the
    # tab before the form can be submitted. The Login button sits near the top of
    # the page (well above the keyboard), so it stays reachable with the keyboard up.
    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON_CHROME}    timeout=30s
    Wait Until Keyword Succeeds    5x    3s    Click Element    ${LOGIN_SUBMIT_BUTTON_CHROME}

Input Mobile ESS Chrome Field
    [Documentation]    Types into a Chrome Custom Tab login field by clicking the
    ...    located ``android.widget.EditText`` (to focus it and open the keyboard)
    ...    and then calling Input Text / Input Password. Retries up to ${attempts}
    ...    times because Chrome can briefly re-render the web a11y tree.
    ...
    ...    Unlike `Tap And Input Mobile ESS Field` this never taps blind screen
    ...    coordinates — the Chrome web nodes are stable and directly locatable, and a
    ...    coordinate tap risks hitting the adjacent Login button.
    ...    | =Arguments= | =Description= |
    ...    | locator | AppiumLibrary locator for the Chrome EditText. |
    ...    | text | Text to type into the field. |
    ...    | secret | ${True} -> use Input Password (masks logging). Default False. |
    ...    | attempts | Max retry attempts. Default 5. |
    ...    Example:
    ...    | Input Mobile ESS Chrome Field    ${LOGIN_USERNAME_FIELD_CHROME}    user1
    [Tags]    robot:private
    [Arguments]    ${locator}    ${text}    ${secret}=${False}    ${attempts}=5
    Wait Until Page Contains Element    ${locator}    timeout=30s
    FOR    ${i}    IN RANGE    ${attempts}
        Run Keyword And Ignore Error    Click Element    ${locator}
        Sleep    0.5s
        IF    ${secret}
            ${ok}=    Run Keyword And Return Status    Input Password    ${locator}    ${text}
        ELSE
            ${ok}=    Run Keyword And Return Status    Input Text    ${locator}    ${text}
        END
        IF    ${ok}
            Log    Typed into ${locator} on attempt ${i+1} (Chrome Custom Tab).
            RETURN
        END
        Sleep    1s
    END
    Fail    Could not type into ${locator} after ${attempts} attempts on the Chrome Custom Tab login form.

Wait For Mobile ESS Chrome Tab Login Form
    [Documentation]    Chrome Custom Tab variant of `Wait For Mobile ESS Login Form`.
    ...    Polls Get Source for the web login placeholders that Chrome surfaces in the
    ...    accessibility tree once the page has loaded, issuing periodic wake-taps to
    ...    force Chrome to (re)populate the web a11y tree (the same lazy-population
    ...    behaviour as the in-app hybrid WebView).
    ...    | =Arguments= | =Description= |
    ...    | timeout | Total time budget. Default 90s. |
    ...    | poll_interval | Sleep between source polls. Default 2s. |
    ...    | wake_every | Issue a wake-tap every N polls. Default 8 (~16s). |
    ...    Example:
    ...    | Wait For Mobile ESS Chrome Tab Login Form
    [Tags]    robot:private
    [Arguments]    ${timeout}=90s    ${poll_interval}=2s    ${wake_every}=8
    ${timeout_s}=    Convert Time    ${timeout}    result_format=number
    ${interval_s}=    Convert Time    ${poll_interval}    result_format=number
    ${max_iters}=    Evaluate    int(${timeout_s} / ${interval_s}) + 1
    VAR    ${ready}    ${False}
    FOR    ${i}    IN RANGE    ${max_iters}
        ${ok}=    Run Keyword And Return Status    All ESS Chrome Tab Login Markers In Source
        IF    ${ok}
            VAR    ${ready}    ${True}
            BREAK
        END
        IF    ${i} > 0 and (${i} % ${wake_every}) == 0
            Run Keyword And Ignore Error    Wake Mobile ESS Accessibility Tree
        END
        Sleep    ${poll_interval}
    END
    IF    not ${ready}
        Fail    ESS Chrome Tab login form did not become DOM-ready within ${timeout}. Get Source never contained the username/password placeholders — the Chrome web accessibility tree may not have been populated. See screenshot in teardown.
    END
    Log    Mobile ESS Chrome Tab login form is ready (Get Source contained the username and password placeholders at iteration ${i}).

All ESS Chrome Tab Login Markers In Source
    [Documentation]    Asserts the live accessibility tree (via Get Source) contains the
    ...    Chrome Custom Tab login placeholders (``Enter username`` / ``Enter password``).
    ...    Used as the gate inside `Wait For Mobile ESS Chrome Tab Login Form`. Kept as a
    ...    separate keyword so it can be wrapped in Run Keyword And Return Status.
    [Tags]    robot:private
    ${src}=    Get Source
    Should Contain    ${src}    Enter username    msg=Chrome tab login form not yet rendered: username placeholder missing
    Should Contain    ${src}    Enter password    msg=Chrome tab login form not yet rendered: password placeholder missing

Wake Mobile ESS Accessibility Tree
    [Documentation]    Forces the hybrid WebView's accessibility tree to refresh
    ...    by issuing a click gesture at the form area of the login screen. On
    ...    hybrid Android apps, native EditText overlays inside a WebView are
    ...    sometimes lazy-populated into the accessibility tree only after
    ...    the WebView receives a touch event — even when the fields are
    ...    fully rendered visually. Used as a recovery action inside
    ...    Wait For Mobile ESS Login Form.
    ...    The tap targets ~25% from the top, which lands inside the username
    ...    EditText area on the standard ESS login layout. The tap is harmless
    ...    if it lands inside the username field (focuses it) or on a label
    ...    (no-op).
    [Tags]    robot:private
    ${width}=    Get Window Width
    ${height}=    Get Window Height
    ${cx}=    Evaluate    int(${width} / 2)
    ${cy}=    Evaluate    int(${height} * 0.25)
    IF    '${MOBILE_PLATFORM}' == 'ios'
        Execute Script    mobile: tap    x=${cx}    y=${cy}
    ELSE
        Execute Script    mobile: clickGesture    x=${cx}    y=${cy}
    END
    Log    Wake-tap dispatched at (${cx}, ${cy}) to refresh hybrid WebView a11y tree.

Tap And Input Mobile ESS Field
    [Documentation]    Robust input keyword for the Mobile ESS hybrid login form.
    ...    Each attempt: taps the field's painted coordinates first (which makes
    ...    UiAutomator2 refresh the WebView's accessibility-overlay nodes for
    ...    that area), then calls Input Text / Input Password. Retries up to
    ...    ${attempts} times.
    ...
    ...    Why: findElementsByXPath on this hybrid app intermittently fails to
    ...    locate native EditText overlays inside a WebView even when Get
    ...    Source confirms they're in the accessibility tree. Concrete evidence
    ...    from run_09 of intermittent_BATTC00112_20260620_020440 — Wait For
    ...    Mobile ESS Login Form (Get Source) confirmed the password and
    ...    username markers were present at 02:17:49.887, but every Input Text
    ...    attempt for the next ~17 s failed with "Element locator … did not
    ...    match any elements". A click-gesture at the field's coordinates
    ...    forces the OS to refresh the a11y overlays for that area, after
    ...    which findElements locates the EditText on the next try.
    ...
    ...    Args:
    ...    - ${locator}: AppiumLibrary locator string for the EditText.
    ...    - ${text}: Text to type into the field.
    ...    - ${tap_y_ratio}: Vertical position of the field as fraction of
    ...      screen height. 0.25 ≈ username row, 0.32 ≈ password row on the
    ...      standard ESS layout.
    ...    - ${secret}: ${True} → use Input Password (masks logging). Default False.
    ...    - ${attempts}: Max retry attempts. Default 10.
    ...    - ${tap_x_ratio}: Horizontal position of the field as fraction of
    ...      screen width. Default 0.7 (right-side EditText column on the ESS layout).
    ...
    ...    Example:
    ...    - Tap And Input Mobile ESS Field    ${LOGIN_USERNAME_FIELD}    user1
    ...    - Tap And Input Mobile ESS Field    ${LOGIN_USERNAME_PASSWORD}    pw    tap_y_ratio=0.32    secret=${True}
    [Tags]    robot:private
    [Arguments]    ${locator}    ${text}    ${tap_y_ratio}=0.25    ${secret}=${False}    ${attempts}=10    ${tap_x_ratio}=0.7
    ${width}=    Get Window Width
    ${height}=    Get Window Height
    ${cx}=    Evaluate    int(${width} * ${tap_x_ratio})
    ${cy}=    Evaluate    int(${height} * ${tap_y_ratio})
    FOR    ${i}    IN RANGE    ${attempts}
        IF    '${MOBILE_PLATFORM}' == 'ios'
            Run Keyword And Ignore Error    Execute Script    mobile: tap    x=${cx}    y=${cy}
        ELSE
            Run Keyword And Ignore Error    Execute Script    mobile: clickGesture    x=${cx}    y=${cy}
        END
        Sleep    0.5s
        IF    ${secret}
            ${ok}=    Run Keyword And Return Status    Input Password    ${locator}    ${text}
        ELSE
            ${ok}=    Run Keyword And Return Status    Input Text    ${locator}    ${text}
        END
        IF    ${ok}
            Log    Typed into ${locator} on attempt ${i+1} (after wake-tap at (${cx}, ${cy})).
            RETURN
        END
        Sleep    1s
    END
    Fail    Could not type into ${locator} after ${attempts} tap-and-input attempts. The hybrid WebView's a11y overlay never exposed this EditText to findElements within the retry budget.

Click Mobile ESS Login Button
    [Documentation]    Clicks the ESS login submit button using the most specific
    ...    target available in the current DOM. The hybrid WebView/Flutter login
    ...    screen exposes the button in three different ways across renders:
    ...    - native android.widget.Button[@resource-id="loginButton"] (small, right-aligned, clickable=true)
    ...    - android.view.View[@text="Login"] in the right half of the row
    ...    - unlabeled android.view.View parent of the row (full-width, button painted in its right portion)
    ...
    ...    A naive Click Element on the broad LOGIN_SUBMIT_BUTTON union returns
    ...    elements in XPath document order — the full-width parent comes first
    ...    and its geometric center sits in dead space well to the left of the
    ...    actual painted button. The tap silently misses, AppiumLibrary reports
    ...    success, login never happens, and the next step (verify home page)
    ...    times out 2 minutes later.
    ...
    ...    This keyword tries the narrow targets first and uses
    ...    Execute Script  mobile: clickGesture (Android) / mobile: tap (iOS)
    ...    with computed coordinates so the tap always lands on the painted
    ...    button — even when only the unlabeled structural parent is present
    ...    we aim at the right-half center of its bounds.
    [Tags]    robot:private
    VAR    @{strategies}
    ...    //android.widget.Button[@resource-id="loginButton"]
    ...    //*[@name="Login" and @type="XCUIElementTypeButton"]
    ...    //android.view.View[@text="Login"]
    ...    //*[@resource-id="primaryAuthenticationContainer"]/following-sibling::android.view.View[1]
    FOR    ${xpath}    IN    @{strategies}
        ${matched}=    Run Keyword And Return Status    Page Should Contain Element    ${xpath}
        IF    not ${matched}    CONTINUE
        ${loc}=    Get Element Location    ${xpath}
        ${size}=    Get Element Size    ${xpath}
        VAR    ${left}    ${loc}[x]
        VAR    ${top}    ${loc}[y]
        VAR    ${width}    ${size}[width]
        VAR    ${height}    ${size}[height]
        IF    ${width} > 600
            ${cx}=    Evaluate    ${left} + (${width} * 3 / 4)
        ELSE
            ${cx}=    Evaluate    ${left} + (${width} / 2)
        END
        ${cy}=    Evaluate    ${top} + (${height} / 2)
        Log    ESS login click strategy=${xpath} bounds=(${left},${top},${width}x${height}) tap=(${cx},${cy})
        IF    '${MOBILE_PLATFORM}' == 'ios'
            Execute Script    mobile: tap    x=${cx}    y=${cy}
        ELSE
            Execute Script    mobile: clickGesture    x=${cx}    y=${cy}
        END
        RETURN
    END
    Fail    No ESS login submit-button strategy matched the current DOM.

Logout Mobile ESS App
    [Documentation]    Used to logout the application (Flutter-only).
    ...    Behavior:
    ...    - Keyword will always kill and reopen application to come on home page and then proceed to logout.
    ...    Example:
    ...    - Logout Ess App
    Terminate Application    ${PACKAGE}
    Sleep    ${APP_TERMINATION_WAIT_TIME}
    Launch Mobile ESS App
    Logout Mobile ESS App From Top Level Page

Logout Mobile ESS App From Top Level Page
    [Documentation]    Used to logout the application from top level page (Flutter-only).
    ...    Behavior:
    ...    - Keyword will work from top level pages of ess modules and then proceed to logout.
    ...    Example:
    ...    - Logout Mobile ESS App From Top Level Page
    ${drawer}=    Get Localised Locator Exact    ${HOME_DRAWER}
    ${log_out_button}=    Get Localised Locator Exact    ${LOG_OUT}
    Wait Until Page Contains Element    ${drawer}
    Click Element    ${drawer}
    Wait Until Page Contains Element    ${log_out_button}
    Click Element    ${log_out_button}
    ${mobile_chrome_tab_login_enabled}=    Is Config Enabled    mobile_chrome_tab_login_enabled
    IF    ${mobile_chrome_tab_login_enabled}
        Log To Console    Custom tab is open so no need to click on Log Back In Button
    ELSE
        Wait Until Page Contains Element    ${LOG_BACK_IN}
        Click Element    ${LOG_BACK_IN}
    END

Clear Data Mobile ESS App
    [Documentation]    Clears registration    on flutter app
    ...    Behavior:
    ...    - Keyword waits page contains login button and then proceed to clear data.
    ...    Precondition:
    ...    - App should be on login page and settings button should be visible.
    ...    Example:
    ...    - Clear Data Mobile ESS App
    Run Keyword And Ignore Error    Click Element    ${SETTING_BUTTON}
    Run Keyword And Ignore Error    Tap Slightly Above Element    ${SETTING_BUTTON_TYPE_1}
    Run Keyword And Ignore Error    Tap Slightly Above Element    ${SETTING_BUTTON_TYPE_2}
    Run Keyword And Ignore Error    Tap Slightly Above Element    ${SETTING_BUTTON_TYPE_3}
    Wait Until Page Contains Element    ${CLEAR_DATA_BUTTON}
    Click Element    ${CLEAR_DATA_BUTTON}
    Wait Until Page Contains Element    ${YES_BUTTON}
    Click Element    ${YES_BUTTON}
    Wait Until Page Contains Element    ${ENTER_REGISTRATION_BUTTON}

Tap Slightly Above Element
    [Documentation]    Taps slightly above the element to its temporary fix for the issue of tapping on the "Manage Setting".
    ...    Arguments:
    ...    - ${locator}: Locator of the element to tap on.
    ...    - ${offset_percentage}: Percentage of the element's height to offset the tap position.
    ...    Example:
    ...    - Tap Slightly Above Element    ${SETTING_BUTTON_TYPE_1}
    ...    - Tap Slightly Above Element    ${SETTING_BUTTON_TYPE_2}    0.2
    [Tags]    robot:private
    [Arguments]    ${locator}    ${offset_percentage}=0.2
    ${location}=    Get Element Location    ${locator}
    ${size}=    Get Element Size    ${locator}
    VAR    ${location_x}=    ${location['x']}
    VAR    ${location_y}=    ${location['y']}
    VAR    ${size_height}=    ${size['height']}
    VAR    ${size_width}=    ${size['width']}
    ${center_x}=    Evaluate    ${location_x} + (${size_width} / 2)
    ${center_y}=    Evaluate    ${location_y} + (${size_height} / 2)
    ${offset_y}=    Evaluate    ${center_y} - (${size_height} * ${offset_percentage})
    IF    '${MOBILE_PLATFORM}'=='ios'
        Execute Script    mobile: tap    x=${center_x}    y=${offset_y}
    ELSE
        Execute Script    mobile: clickGesture    x=${center_x}    y=${offset_y}
    END

Accept Location Permission If Asked On Mobile ESS App
    [Documentation]    Accepts location permission if asked on Mobile ESS App.
    ...    Behavior:
    ...    - Keyword will accept location permission if asked on mobile ess app.
    ...    Example:
    ...    - Accept Location permission if asked on Mobile ESS App
    # This keyword is used for both native and flutter apps since the behavior is same for both.
    Run Keyword And Ignore Error    Accept Or Allow A Permission On Mobile ESS App

Accept Or Allow A Permission On Mobile ESS App
    [Documentation]    Accepts or allows permission popup if asked on Mobile ESS App This is common keyword for both native and flutter apps.
    ...    Behavior:
    ...    - Keyword will accept or allow permission will not check whether permission is asked or not and directly click on the accept or allow button.
    ...    Example:
    ...    - Accept Or Allow Permission On Mobile ESS App
    [Tags]    robot:private
    IF    '${MOBILE_PLATFORM}'=='ios' and '${CLOUD_PLATFORM}' == 'lambdaTest'
        # For iOS, System permission popup is not handled by Appium, so need to handle it manually by tapping on the screen.
        # This is a temporary solution until we find a better way to handle permission popups in iOS.
        Sleep    5s
        ${width}=    Get Window Width
        ${height}=    Get Window Height
        ${x}=    Evaluate    ${width} / 2
        ${y}=    Evaluate    ${height} * 0.75
        Execute Script    mobile: tap    x=${x}    y=${y}
        Navigate Mobile ESS To Home Page
    ELSE
        Log    Android we are using autoGrantPermissions=true capability ignoring the permission popup.
    END

Login With PingID On Mobile ESS App
    [Documentation]    Used to login with PingID on NextGen Mobile ESS App.
    ...    Arguments:
    ...    - ${user_key}: User unique key from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will login with provided credentials and wait 60 sec for manually allow on configured ping id devices.
    ...    Example:
    ...    - Login With PingID On Mobile NextGen ESS App    ESS-USER1
    [Arguments]    ${user_key}
    ${user}=    Get User    ${user_key}    mask_password=False
    # Only iOS asks for confirmation to open chrome tab for sso login
    IF    '${MOBILE_PLATFORM}' == 'ios'
        Wait Until Page Contains Element    ${ios_web_open_popup_text}
        Click Element    ${ios_continue_button}
    END
    Input Text    ${ping_id_username}    ${user}[USER_ID]
    Input Password    ${ping_id_password}    ${user}[PASSWORD]
    Click Element    ${ping_id_sign_in}
    ${ping_id_otp_required}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element
    ...    ${ping_id_otp_field}
    IF    '${ping_id_otp_required}' == 'True'
        Log To Console
        ...    Waiting for PingID approval on configured devices manually go and put OTP in device where test is running.
        Sleep    60s
    ELSE
        Log To Console    PingID OTP field is not visible, proceeding considering already authenticated.
    END
    Accept Location Permission If Asked On Mobile ESS App
    Sleep    10s
    Verify Mobile ESS Associate Name    ${user}[displayName]

Select Language On Mobile ESS App
    [Documentation]    Selects the language on mobile ESS app.
    ...    It clicks the language dropdown and swipes within the language selection container
    ...    until the requested language is visible,
    ...    then selects it.
    ...    It calculates swipe coordinates from the container size so the
    ...    swipe stays within the dropdown area while searching for the
    ...    requested language option and once the language elements location is gets
    ...    within the container boundaries it clicks on it.
    ...    | =Arguments= | =Description= |
    ...    | ${language} | Language code to select on mobile ESS app. |
    ...    Example usage:
    ...    | Select Language On Mobile ESS App    "en_US"
    [Arguments]    ${language}
    Wait Until Page Contains Element    ${LANGUAGE_SELECTION_DROPDOWN}    30s
    Click Element    ${LANGUAGE_SELECTION_DROPDOWN}
    Wait Until Element Is Visible    ${LANGUAGE_SELECTION_FLAG}    timeout=10s
    Log    Got language value inside is ${language}
    ${expected_language_to_select}=    Get Locator Contains    ${language}
    Swipe In Container Until Visible    ${LANGUAGE_SELECTION_BOX}    ${expected_language_to_select}    max_swipes=10
    Click Element    ${expected_language_to_select}
    Wait Until Element Is Visible    ${LANGUAGE_SELECTION_FLAG}    timeout=10s
