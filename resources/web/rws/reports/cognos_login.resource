*** Settings ***
Documentation
...                 This resource file provides keywords for automating login functionality in the WFM application.
...
...                 It includes keywords to open the login page, perform login actions, and verify successful authentication.
...
...                 = Purpose =
...                 - Centralize all login-related automation steps for reuse in test cases.
...
...                 = Prerequisites =
...                 - Browser library must be installed and imported.
...                 - Valid credentials must be available in the ALL_CREDENTIALS variable or environment.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Login And Launch WFM Web App    user_key=SM1_STORE1
...                 | Perform Direct Login To WFM Using User Credentials On Web    user_key=ESS1_STORE1
...
...                 For more details, see project documentation.

Library             OperatingSystem
Library             CacheLibrary
Library             test_data/TestDataLibrary.py
Library             utils/otp_helper.py
Variables           resources/web/authentication/login_page.py
Variables           resources/web/common/timeout_variables.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/user_profile_menu.resource
Resource            resources/web/common/setup_keywords.resource


*** Variables ***
&{ALL_CREDENTIALS}                          test={'username': 'test', 'password': 'some_pwd'}
${SECRET_KEY}                               ${EMPTY}
${ISSUER}                                   ${EMPTY}
${SUDO_USERNAME}                            ${EMPTY}
${SUDO_PASSWORD}                            ${EMPTY}
${SUDO_LOGIN_CACHE_EXPIRY_IN_SECONDS}       600
${USER_AUTH_TOKEN}                          ${EMPTY}


*** Keywords ***
Login To WFM Application And Capture Auth Token On Web
    [Documentation]
    ...    Logs in and launches the WFM web application for any user (direct or sudo flow).
    ...    | =Flow= | =Description= |
    ...    | DIRECT_LOGIN True | Launch app_url and perform direct login with username/password. |
    ...    | DIRECT_LOGIN False | Reuse existing sudo session URL or establish new sudo session via kernel. |
    ...    | STRADMN profile | After sudo session, switch to target store profile (STORE_ADMIN). |
    ...    | Session reuse | If LOGIN_SESSION_URL for suite already populated it is reused (faster). |
    ...    | =Arguments= | =Description= |
    ...    | user_key | Key for user credentials (e.g. SM1_STORE1, ESS1_STORE1, SYSADMIN). |
    ...    Example usage:
    ...    | Login And Launch WFM Web App    user_key=SM1_STORE1
    ...    | Login And Launch WFM Web App    user_key=ESS1_STORE1
    ...    | Login And Launch WFM Web App    user_key=SYSADMIN
    [Arguments]    ${user_key}
    ${DIRECT_LOGIN_FLAG}    Get Config Value    DIRECT_LOGIN

    IF    '${DIRECT_LOGIN_FLAG}' == 'True'
        Perform Direct Login To WFM Using User Credentials On Web    ${user_key}
    ELSE
        Perform Login Using Sudo Flow On Web    ${user_key}
    END

Fill And Submit WFM Login Form And Capture Auth Token On Web
    [Documentation]
    ...    Logs in to the WFM application and returns the user's auth token.
    ...
    ...    This keyword waits for the correct API response after login to capture
    ...    the 'x-reflexis-csrf-token-x' header.
    ...
    ...    | =Arguments= | =Description= |
    ...    | user_key | Key to select user credentials from ALL_CREDENTIALS (e.g. SM1_STORE1, ESS5_STORE1). |
    ...
    ...    *=Returns=*
    ...    | The captured authentication token. |
    ...
    ...    Example usage:
    ...    | ${token}=    Fill And Submit WFM Login Form And Capture Auth Token On Web    ESS5_STORE1
    [Arguments]    ${user_key}

    ${is_my_work_env}    Get Config Value    key=MYWORK_ENABLED
    IF    ${is_my_work_env}
        VAR    ${api_end_point_pattern}    **/systemAction.htm
    ELSE
        VAR    ${api_end_point_pattern}    **/RWS4/rosom/orgstructure/**
    END

    Enter Username    ${ALL_CREDENTIALS}[${user_key}][username]
    Enter Password    ${ALL_CREDENTIALS}[${user_key}][password]
    Click Login Button
    ${response}    Browser.Wait For Response    ${api_end_point_pattern}    60s

    Should Be Equal As Strings    ${response.status}    200
    ...    msg=Login failed! API response was ${response.status}, not 200.

    VAR    ${USER_AUTH_TOKEN}    ${response.headers['x-reflexis-csrf-token-x']}    scope=SUITE
    Should Not Be Empty    ${USER_AUTH_TOKEN}
    ...    msg=Login succeeded but the auth token was not found in the response headers.

Create Sudo Login Url On Kernel On Web
    [Documentation]
    ...    Creates a sudo login URL on the kernel for the given username.
    ...    | =Arguments= | =Description= |
    ...    | username    | Username for which the sudo URL is to be created. |
    ...    Returns the generated sudo login URL.
    ...    Example usage:
    ...    | ${sudo_url}=    Create Sudo Login Url On Kernel On Web    username=jdoe
    [Arguments]    ${username}

    ${is_my_work_env}    Get Config Value    key=MYWORK_ENABLED
    IF    ${is_my_work_env}
        VAR    ${api_end_point_pattern}    **/systemAction.htm
    ELSE
        VAR    ${api_end_point_pattern}    **/RWS4/rosom/orgstructure/**
    END

    Click Element On Webpage    ${loginpage_sudo_loginas_menu}
    Wait Until Element Is Visible On Webpage    ${loginpage_sudo_username_textbox}
    Fill Textbox On Webpage    ${loginpage_sudo_username_textbox}    ${username}
    Click Element On Webpage    ${loginpage_sudo_loginas_button}
    Wait Until Element Is Visible On Webpage    ${loginpage_sudo_loginas_link}
    ${sudo_login_url}    Get Element Text On Webpage    ${loginpage_sudo_loginas_link}
    Launch The Application URL    ${sudo_login_url}
    ${response}    Browser.Wait For Response    ${api_end_point_pattern}
    Wait Until Page Is Loaded

    IF    ${is_my_work_env}
        URL Should Contain    systemAction.htm
    ELSE
        URL Should Contain    orgstructure
    END

    # Extract auth token from response headers
    VAR    ${USER_AUTH_TOKEN}    ${response.headers['x-reflexis-csrf-token-x']}    scope=SUITE
    Should Not Be Empty    ${USER_AUTH_TOKEN}
    ...    msg=Sudo login succeeded but the auth token was not found in the response headers.

    RETURN    ${sudo_login_url}

Perform Direct Login To WFM Using User Credentials On Web
    [Documentation]
    ...    Logs into the WFM application using provided user credentials.
    ...    | =Arguments= | =Description= |
    ...    | user_key | Key for user credentials (e.g. SM1_STORE1, ESS1_STORE1, SYSADMIN). |
    ...    Example usage:
    ...    | Perform Direct Login To WFM Using User Credentials On Web    user_key=ESS5_STORE1
    [Arguments]    ${user_key}
    ${APP_URL}    Get Config Value    key=app_url
    Launch Browser
    Launch WFM Web Application    ${APP_URL}
    Update Default Language To English Of Non Mywork Login Page On Web
    Fill And Submit WFM Login Form And Capture Auth Token On Web    ${user_key}

Perform Login Using Sudo Flow On Web
    [Documentation]
    ...    Orchestrates the sudo login flow and selects an authentication strategy based on available credentials.
    ...    | =Arguments= | =Description= |
    ...    | user_key | Key for user credentials. |
    ...    Example usage:
    ...    | Perform Login Using Sudo Flow On Web    user_key=SYSADMIN
    [Arguments]    ${user_key}
    ${user}    Get User    user_key=${user_key}
    VAR    ${sudo_target_username}    ${user}[username]

    # Try cached URL first for performance
    ${cache_successful}    Try Launch With Cached Sudo URL    ${sudo_target_username}
    IF    ${cache_successful}    RETURN

    # Determine which sudo login path to take
    IF    '${sudo_target_username}' != '' and '${ALL_CREDENTIALS}[${user_key}][password]' != ''
        Perform Direct Login To WFM Using User Credentials On Web    ${user_key}
    ELSE IF    '${sudo_target_username}' != '' and '${ALL_CREDENTIALS}[${user_key}][password]' == ''
        Perform Sudo Login With Username Only    ${sudo_target_username}
    ELSE IF    '${sudo_target_username}' == '' and '${ALL_CREDENTIALS}[${user_key}][profile_name]' == 'STRADMN' and '${ALL_CREDENTIALS}[${user_key}][switch_store_id]' != ''
        Perform Sudo Login As Sysadmin And Switch Store    ${ALL_CREDENTIALS}[${user_key}][switch_store_id]
    ELSE
        Fail
        ...    Invalid user configuration for key '${user_key}': Unable to determine login method. Check username, password, and switch_store_id settings.
    END

Perform Sudo Login With Username Only
    [Documentation]
    ...    Generates and uses a sudo URL when only a username is available (no password).
    ...    Captures the authentication token from the API response after login.
    ...    | =Arguments= | =Description= |
    ...    | username | Username to generate the sudo URL for. |
    ...    Example usage:
    ...    | Perform Sudo Login With Username Only    username=jdoe
    [Arguments]    ${username}
    ${sudo_url}    Generate Sudo Login Url For User On Web    ${username}
    Launch WFM Web Application    ${sudo_url}

Perform Sudo Login As Sysadmin And Switch Store
    [Documentation]
    ...    Logs in as SYSADMIN via sudo, then switches to the specified store admin profile.
    ...    | =Arguments= | =Description= |
    ...    | switch_store_id | Store ID to switch to. |
    ...    Example usage:
    ...    | Perform Sudo Login As Sysadmin And Switch Store    switch_store_id=STORE123
    [Arguments]    ${switch_store_id}
    ${sudo_url}    Generate Sudo Login Url For User On Web    ${ALL_CREDENTIALS}[SYSADMIN][username]
    Launch WFM Web Application    ${sudo_url}
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    Check And Switch To Store With Profile    ${switch_store_id}    ${store_profile_name}

Generate Sudo Login Url For User On Web
    [Documentation]
    ...    Generates a sudo login URL for the given username via kernel.
    ...    This keyword uses `issuer`, `secret`, `password`, and `username` fields from the `SUDO_USER` configuration.
    ...    The `USER_CREDENTIALS` environment variable should contain `SUDO_USER` details for this to work.
    ...    | =Arguments= | =Description= |
    ...    | login_as_username | Username to impersonate within the client application. |
    ...    Example usage:
    ...    | ${url}=    Generate Sudo Login Url For User On Web    login_as_username=jdoe
    [Arguments]    ${login_as_username}
    ${KERNEL_URL}    Get Config Value    key=kernel_url    default=${DEFAULT_KERNAL_URL}
    Launch Browser
    Launch The Application URL    ${KERNEL_URL}
    Verify WFM Login Page Is Seen On Web
    VAR    ${SECRET_KEY}    ${ALL_CREDENTIALS}[SUDO_USER][secret]    scope=SUITE
    VAR    ${ISSUER}    ${ALL_CREDENTIALS}[SUDO_USER][issuer]    scope=SUITE
    VAR    ${SUDO_USERNAME}    ${ALL_CREDENTIALS}[SUDO_USER][username]    scope=SUITE
    VAR    ${SUDO_PASSWORD}    ${ALL_CREDENTIALS}[SUDO_USER][password]    scope=SUITE
    Enter Username On Kernel On Web    ${SUDO_USERNAME}
    Enter Password With OTP On Kernel On Web
    Click Login Button On Kernel On Web
    Wait Until Element Disappears On Webpage    ${loginpage_login_btn}    timeout=${LONG_TIMEOUT}
    Wait Until Page Is Loaded
    Switch To Customer Domain
    ${sudo_url}    Create Sudo Login Url On Kernel On Web    ${login_as_username}
    Cache Sudo URL For User    ${login_as_username}    ${sudo_url}
    RETURN    ${sudo_url}
    [Teardown]    Close Context    ALL

Open New Browser Context For Cognos Report URL
    [Documentation]    Open a new browser context with the given web page url.
    ...    | Usage Example :
    ...    | Open New Browser Context For Cognos Report URL    https://www.google.com
    [Arguments]    ${url_to_use}    ${storage_state}=${NONE}
    Set Library Search Order    Browser
    IF    ${ENABLE_BROWSER_HEADLESS_MODE}
        VAR    ${viewport_dimensions}    ${VIEWPORT_DIMENSIONS_HEADLESS}
    ELSE
        VAR    ${viewport_dimensions}    ${NONE}
    END
    IF    $BROWSER_RECORDED_VIDEO_FILES_FOLDER != None
        VAR    ${video_record_folder}    ${BROWSER_RECORDED_VIDEO_FILES_FOLDER}
    ELSE
        VAR    ${video_record_folder}    ${DEFAULT_RECORDED_VIDEO_FILES_FOLDER}
    END
    Set To Dictionary    ${VIDEO_RECORD_ARGS}    dir=${video_record_folder}
    New Context    viewport=${viewport_dimensions}    recordVideo=${VIDEO_RECORD_ARGS}    storageState=${storage_state}    bypassCSP=True
    ${original_timeout}    Set Browser Timeout    timeout=${COGNOS_REPORT_LONG_LOADING_TIMEOUT}
    &{output}    New Page    url=${url_to_use}
    Set Browser Timeout    ${original_timeout}
    VAR    ${VIDEO_PATH}    ${output}[video_path]    scope=SUITE

Launch The Cognos Report URL
    [Documentation]    Launch the application URL
    [Arguments]    ${app_url}
    Open New Browser Context For Cognos Report URL    ${app_url}
