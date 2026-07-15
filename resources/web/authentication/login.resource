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
...                 | Perform Direct Login To WFM Using User Credentials    user_key=ESS1_STORE1
...
...                 For more details, see project documentation.

Library             OperatingSystem
Library             CacheLibrary
Library             test_data/TestDataLibrary.py
Library             utils/otp_helper.py
Variables           login_page.py
Variables           resources/web/common/timeout_variables.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/user_profile_menu.resource
Resource            resources/web/common/setup_keywords.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/rws/users/users.resource
Resource            resources/web/rws/admin/rws_upload_api.resource


*** Variables ***
${DEFAULT_APP_URL}                          https://rws4demo05.reflexisinc.com/kernel/views/authenticate/W/REFLEXIS.view
${DEFAULT_KERNAL_URL}                       https://knlcl01sb.reflexisinc.com/kernel/
${DEFAULT_USERID}                           test
# DO NOT SET ALL_CREDENTIALS IN VARIABLE FILE. Loaded via environment variable named ALL_CREDENTIALS -    check credentials.py
&{ALL_CREDENTIALS}                          test={'username': 'test', 'password': 'some_pwd'}
${SECRET_KEY}                               ${EMPTY}
${ISSUER}                                   ${EMPTY}
${SUDO_USERNAME}                            ${EMPTY}
${SUDO_PASSWORD}                            ${EMPTY}
${SUDO_LOGIN_CACHE_EXPIRY_IN_SECONDS}       600    # 10 minutes


*** Keywords ***
Fill And Submit WFM Login Form
    [Documentation]
    ...    Logs in to the WFM application using the given user key.
    ...    | =Arguments= | =Description= |
    ...    | user_key | For dynamic users: key to lookup in SUITE_DYNAMIC_EMPLOYEES (e.g. ESSNH1_STORE2). For regular users: key to lookup in ALL_CREDENTIALS (e.g. SM1_STORE1). |
    ...    | is_dynamic_user | Optional flag to indicate if the test is for a dynamic user. Defaults to False. |
    ...    Example usage:
    ...    | Fill And Submit WFM Login Form    ESS5_STORE1
    ...    | Fill And Submit WFM Login Form    SM1_STORE1
    ...    | Fill And Submit WFM Login Form    ESSNH1_STORE2    is_dynamic_user=True
    [Arguments]    ${user_key}=${DEFAULT_USERID}    ${is_dynamic_user}=False
    IF    ${is_dynamic_user}
        # For dynamic users: user_key is used to lookup in SUITE_DYNAMIC_EMPLOYEES dictionary
        ${dynamic_user}    Get Dynamic Employee    ${user_key}
        Enter Username    ${dynamic_user}[username]
        Enter Password    ${dynamic_user}[password]
    ELSE
        # For regular users: user_key is used to lookup in ALL_CREDENTIALS dictionary
        Enter Username    ${ALL_CREDENTIALS}[${user_key}][username]
        Enter Password    ${ALL_CREDENTIALS}[${user_key}][password]
    END
    Click Login Button
    Wait Until Page Is Loaded

Enter Username
    [Documentation]
    ...    Fills in the username field on the login page.
    ...    | =Arguments= | =Description= |
    ...    | username    | Username to enter in the login form. |
    ...    Example usage:
    ...    | Enter Username    testuser
    [Arguments]    ${username}
    Wait Until Element Is Present On Webpage    ${loginpage_username_txt}    timeout=${MEDIUM_TIMEOUT}
    Type Text    ${loginpage_username_txt}    ${username}

Enter Password
    [Documentation]
    ...    Fills in the password field on the login page.
    ...    | =Arguments= | =Description= |
    ...    | password    | Password to enter in the login form. |
    ...    Example usage:
    ...    | Enter Password    mypassword
    [Arguments]    ${password}
    Type Secret    ${loginpage_password_txt}    $password

Click Login Button
    [Documentation]
    ...    Clicks the Login button on the login page.
    Wait For Elements State    ${loginpage_login_btn}
    Click    ${loginpage_login_btn}

Verify Login
    [Documentation]
    ...    Verifies that the user is logged in by checking the presence of the logout button.
    Wait For Elements State    ${loginpage_logout_btn}    attached    timeout=5s

Enter Username On Kernel On Web
    [Documentation]    Fill in the username
    [Arguments]    ${username}
    Fill Textbox On Webpage    ${loginpage_username_txt}    ${username}

Enter Password On Kernel On Web
    [Documentation]    Fill in the password.
    [Arguments]    ${password}
    Fill Secret On Webpage    ${loginpage_password_txt}    ${password}

Enter Password With OTP On Kernel On Web
    [Documentation]    Enters the password with OTP
    ${otp}    Get Otp To Login    ${SECRET_KEY}    ${ISSUER}
    Enter Password On Kernel On Web    ${SUDO_PASSWORD}${otp}

Click Login Button On Kernel On Web
    [Documentation]    Click action on Login button.
    Wait For Elements State    ${loginpage_login_btn}
    Click    ${loginpage_login_btn}

Verify Login Authentication Error Message Is Seen    # Wait For Login Authentication Error Message To Load
    [Documentation]    Waits until login authentication message is loaded.
    Wait Until Element Is Visible On Webpage    ${loginpage_login_authentication_error_msg}

Verify WFM Login Page Is Seen On Web
    [Documentation]    Waits until login page is loaded.
    Wait For Elements State    ${loginpage_username_txt}    visible    timeout=${MEDIUM_TIMEOUT}    message=WFM Login Page Not Seen

Switch To Customer Domain
    [Documentation]    Switch the kenerl domain to customer domain based on domainId from configuration
    Click Element On Webpage    ${loginpage_sudo_kernel_header}
    ${DOMAIN_ID}    Get Config Value    domainId
    Click Element On Webpage    //span[contains(text(),'${DOMAIN_ID} - Flight Director')]

Create Sudo Login Url On Kernel
    [Documentation]    Creates sudo login url on kernel for given username
    ...    | =Arguments= | =Description= |
    ...    | username    | Username for which sudo url is to be created. |
    ...    Returns the generated sudo login URL.
    [Arguments]    ${username}
    Click Element On Webpage    ${loginpage_sudo_loginas_menu}
    Wait Until Element Is Visible On Webpage    ${loginpage_sudo_username_textbox}
    Fill Textbox On Webpage    ${loginpage_sudo_username_textbox}    ${username}
    Click Element On Webpage    ${loginpage_sudo_loginas_button}
    Wait Until Element Is Visible On Webpage    ${loginpage_sudo_loginas_link}
    ${sudo_login_url}    Get Element Text On Webpage    ${loginpage_sudo_loginas_link}
    Launch The Application URL    ${sudo_login_url}
    Wait For Response    **/systemAction.htm
    Wait Until Page Is Loaded
    URL Should Contain    systemAction.htm
    RETURN    ${sudo_login_url}

Get Cache Key For Sudo URL For User
    [Documentation]    Gets cache key for sudo login URL for given user
    ...    | =Arguments= | =Description= |
    ...    | username    | Username for sudo login cache key is to be created. |
    ...    Returns the cache_key.
    [Arguments]    ${username}
    VAR    ${cache_key}    SUDO_LOGIN_SUDO_URL_${username}
    RETURN    ${cache_key}

Cache Sudo URL For User
    [Documentation]    Caches sudo login URL for given user using CacheLibrary
    ...    | =Arguments= | =Description= |
    ...    | username    | Username for authentication. |
    ...    | sudo_url    | Sudo login URL to cache against the username. |
    [Arguments]    ${username}    ${sudo_url}
    ${cache_key}    Get Cache Key For Sudo URL For User    ${username}
    Cache Store Value    ${cache_key}    ${sudo_url}    expire_in_seconds=${SUDO_LOGIN_CACHE_EXPIRY_IN_SECONDS}
    RETURN    ${sudo_url}

Launch WFM Web Application
    [Documentation]    Launches the WFM Web Application
    [Arguments]    ${url}
    Set Selector Prefix    ${None}
    Open New Browser Context With Page    ${url}
    Wait Until Page Is Loaded

Login To WFM Application For Reset Password Page
    [Documentation]    Logs into the WFM application
    [Arguments]    ${username}    ${password}
    Enter Username    ${username}
    Enter Password    ${password}
    Click Login Button
    Wait Until Page Is Loaded
    ${reset_password_status}    Run Keyword And Return Status
    ...    Wait Until Element Is Present On Webpage    ${reset_password_page_container}    timeout=${LONG_TIMEOUT}
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    '${reset_password_status}' == 'False' and "${MY_WORK_INTEGRATED}" == 'True'
        Wait Until Element Is Visible On Webpage    ${loginpage_mywork_landing_page}
    ELSE IF    '${reset_password_status}' == 'False'
        Wait Until Element Is Visible On Webpage    ${loginpage_nonmywork_landing_page}
    END

Check And Capture WFM Login Page Screenshot For SSO Login Page
    [Documentation]    Short description.
    @{element_states}    Get Element States    ${loginpage_username_txt}
    IF    'visible' in ${element_states}    RETURN
    Capture Screenshot On Webpage
    Pass Execution    Test Case Passed as SSO Login Page is seen

Log Out From Web Application
    [Documentation]    Logs out from the WFM application
    Set Selector Prefix    ${NONE}
    Click Profile Icon
    Click Logout Link On Web
    Verify WFM Login Page Is Seen On Web

Ensure Active Login Session
    [Documentation]    This keyword ensures if the login session url is active. If inactive, sudo login is performed
    ...    again and to generate new login session url for target suite.
    [Arguments]    ${login_in_as}=System Admin
    # Run Keyword And Ignore Error
    # ...    Verify WFM Home Page Is Seen
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    ${MY_WORK_INTEGRATED}
        ${is_profile_icon_visible}    Is Element Visible On Webpage    ${MYWORK_USERPROFILEMENU_PROFILE_ICON}
    ELSE
        ${is_profile_icon_visible}    Is Element Visible On Webpage    ${USERPROFILEMENU_PROFILE_ICON}
    END
    IF    ${is_profile_icon_visible}
        No Operation
    ELSE
        ${sudo_url}    Generate Sudo Login Url For User    ${login_in_as}
        Launch WFM Web Application    ${sudo_url}
    END

Ensure Active Login Session For SUDO USER
    [Documentation]    This keyword ensures if the login session url is active. If inactive, sudo login is performed
    ...    again and to generate new login session url for target suite.
    [Arguments]    ${login_in_as}=System Admin
    Run Keyword And Ignore Error
    ...    Verify WFM Home Page Is Seen
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    ${MY_WORK_INTEGRATED}
        ${is_profile_icon_visible}    Is Element Visible On Webpage    ${MYWORK_USERPROFILEMENU_PROFILE_ICON}
    ELSE
        ${is_profile_icon_visible}    Is Element Visible On Webpage    ${USERPROFILEMENU_PROFILE_ICON}
    END
    IF    ${is_profile_icon_visible}
        No Operation
    ELSE
        ${sudo_url}    Generate Sudo Login Url For User    ${login_in_as}
        Launch WFM Web Application    ${sudo_url}
    END

Verify WFM Logged Out Page Is Seen
    [Documentation]    Waits until logged out page is loaded.
    Wait For Elements State
    ...    ${loginpage_after_logout_username_txtbox}
    ...    visible
    ...    timeout=${LONG_TIMEOUT}
    ...    message=WFM Logged Out Page Not Seen

Update Default Language To English Of Non Mywork Login Page On Web
    [Documentation]    This keyword will update the default language to English on login page if enabled for the environment.
    [Tags]    test:setup
    ${SWITCH_TO_ENGLISH}    Get Config Value    SWITCH_TO_ENGLISH    default=False
    IF    not ${SWITCH_TO_ENGLISH}    RETURN
    Wait Until Element Is Visible On Webpage    ${loginpage_login_btn}
    Click Element On Webpage    ${loginpage_laug_icon}
    Click Element On Webpage    ${loginpage_Eng_US}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${loginpage_laug_icon}${loginpage_Eng_US}

Switch User Locale Before Login
    [Documentation]    This keyword will switch user locale to any locale on login page
    [Arguments]    ${locale}
    Wait Until Element Is Visible On Webpage    ${loginpage_login_btn}
    ${locale_locator}    Update Locator With Dynamic Values    ${loginpage_locale_option}    locale=${locale}
    Click Element On Webpage    ${loginpage_laug_icon}
    Click Element On Webpage    ${locale_locator}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${loginpage_laug_icon}

Perform Direct Login To WFM Using User Credentials
    [Documentation]    Logs into the WFM application using provided user credentials.
    ...    | =Arguments= | =Description= |
    ...    | user_key | Key for user credentials (e.g. SM1_STORE1, ESS1_STORE1, SYSADMIN). |
    [Arguments]    ${user_key}    ${is_dynamic_user}=False    ${locale}=${None}
    ${APP_URL}    Get Config Value    key=app_url
    Launch Browser
    Launch WFM Web Application    ${APP_URL}
    Update Default Language To English Of Non Mywork Login Page On Web
    IF    ${{$locale is not None}}
        Switch User Locale Before Login    ${locale}
    END
    Fill And Submit WFM Login Form    ${user_key}    ${is_dynamic_user}

Login And Launch WFM Web App
    [Documentation]
    ...    Logs in and launches the WFM web application for any user (direct or sudo flow).
    ...    | =Flow= | =Description= |
    ...    | DIRECT_LOGIN True | Launch app_url and perform direct login with username/password. |
    ...    | DIRECT_LOGIN False | Reuse existing sudo session URL or establish new sudo session via kernel. |
    ...    | STRADMN profile | After sudo session, switch to target store profile (STORE_ADMIN). |
    ...    | Session reuse | If LOGIN_SESSION_URL for suite already populated it is reused (faster). |
    ...    | =Arguments= | =Description= |
    ...    | user_key | Key for user credentials (e.g. SM1_STORE1, ESS1_STORE1, SYSADMIN). |
    ...    | is_dynamic_user | Optional flag to indicate if the test is for a dynamic user. Defaults to False. |
    ...    | locale | Locale to switch to on login page. e.g es_MX, en_US, etc|
    ...    Example usage:
    ...    | Login And Launch WFM Web App    user_key=SM1_STORE1
    ...    | Login And Launch WFM Web App    user_key=ESS1_STORE1
    ...    | Login And Launch WFM Web App    user_key=SYSADMIN
    ...    | Login And Launch WFM Web App    user_key=SM1_STORE1    locale=es_MX
    [Arguments]    ${user_key}    ${is_dynamic_user}=False    ${locale}=${None}
    ${DIRECT_LOGIN_FLAG}    Get Config Value    DIRECT_LOGIN
    IF    '${DIRECT_LOGIN_FLAG}' == 'True'
        Perform Direct Login To WFM Using User Credentials    ${user_key}    ${is_dynamic_user}    ${locale}
    ELSE
        Perform Login Using Sudo Flow    ${user_key}
    END
    Verify Successful Login To WFM Application

Verify Successful Login To WFM Application
    [Documentation]    Verifies successful login to WFM application by checking for user profile icon.
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    ${MY_WORK_INTEGRATED}
        Wait Until Element Is Visible On Webpage    ${MYWORK_USERPROFILEMENU_PROFILE_ICON}    timeout=${LONG_TIMEOUT}
        ...    error_message=User Profile Icon Not Seen After Login. Login might have failed.
    ELSE
        Wait Until Element Is Visible On Webpage    ${USERPROFILEMENU_PROFILE_ICON}    timeout=${LONG_TIMEOUT}
        ...    error_message=User Profile Icon Not Seen After Login. Login might have failed.
    END
    Wait Until Page Is Loaded

Perform Login Using Sudo Flow
    [Documentation]
    ...    Orchestrates sudo login flow with multiple authentication strategies.
    ...    | =Arguments= | =Description= |
    ...    | user_key | Key for user credentials. |
    [Arguments]    ${user_key}
    ${user}    Get User    user_key=${user_key}
    VAR    ${sudo_target_username}    ${user}[username]

    # Try cached URL first for performance
    ${cache_successful}    Try Launch With Cached Sudo URL    ${sudo_target_username}
    IF    ${cache_successful}    RETURN

    # Determine which sudo login path to take
    IF    '${sudo_target_username}' != '' and '${ALL_CREDENTIALS}[${user_key}][password]' != ''
        Perform Direct Login To WFM Using User Credentials    ${user_key}
    ELSE IF    '${sudo_target_username}' != '' and '${ALL_CREDENTIALS}[${user_key}][password]' == ''
        Perform Sudo Login With Username Only    ${sudo_target_username}
    ELSE IF    '${sudo_target_username}' == '' and '${ALL_CREDENTIALS}[${user_key}][profile_name]' == 'STRADMN' and '${ALL_CREDENTIALS}[${user_key}][switch_store_id]' != ''
        Perform Sudo Login As Sysadmin And Switch Store    ${ALL_CREDENTIALS}[${user_key}][switch_store_id]
    ELSE
        Fail
        ...    Invalid user configuration for key '${user_key}': Unable to determine login method. Check username, password, and switch_store_id settings.
    END

Try Launch With Cached Sudo URL
    [Documentation]
    ...    Attempts to launch WFM using cached sudo URL for faster login.
    ...    | =Arguments= | =Description= |
    ...    | username | Username to retrieve cached sudo URL for. |
    ...    Returns True if cache hit and launch successful, False otherwise.
    [Arguments]    ${username}
    ${cache_key}    Get Cache Key For Sudo URL For User    ${username}
    ${cached_sudo_url}    Cache Retrieve Value    ${cache_key}

    IF    $cached_sudo_url is $None    RETURN    ${False}

    Launch Browser
    Launch WFM Web Application    ${cached_sudo_url}
    Ensure Active Login Session For SUDO USER
    #    Add explicit validation that page loaded successfully (not error screen)
    RETURN    ${True}

Perform Sudo Login With Username Only
    [Documentation]
    ...    Generates and uses sudo URL when only username is available (no password).
    ...    | =Arguments= | =Description= |
    ...    | username | Username to generate sudo URL for. |
    [Arguments]    ${username}
    ${sudo_url}    Generate Sudo Login Url For User    ${username}
    Launch WFM Web Application    ${sudo_url}

Perform Sudo Login As Sysadmin And Switch Store
    [Documentation]
    ...    Logs in as SYSADMIN via sudo, then switches to store admin profile.
    ...    | =Arguments= | =Description= |
    ...    | switch_store_id | Store ID to switch to. |
    [Arguments]    ${switch_store_id}
    ${sudo_url}    Generate Sudo Login Url For User    ${ALL_CREDENTIALS}[SYSADMIN][username]
    Launch WFM Web Application    ${sudo_url}
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    Check And Switch To Store With Profile    ${switch_store_id}    ${store_profile_name}

Generate Sudo Login Url For User
    [Documentation]    Generates sudo login URL for the given username via kernel.
    ...    This keyword utilizes issuer, secret, password, and username fields from the SUDO_USER configuration.
    ...    USER_CREDENTIALS env variable should have SUDO_USER details for this to work.
    ...    | =Arguments= | =Description= |
    ...    | login_as_username | Username to impersonate within the client application. |
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
    ${sudo_url}    Create Sudo Login Url On Kernel    ${login_as_username}
    Cache Sudo URL For User    ${login_as_username}    ${sudo_url}
    RETURN    ${sudo_url}
    [Teardown]    Close Context    ALL

Finish New Hire First Login Setup If Required On Web
    [Documentation]
    ...    Resets the password for a new user on the web application.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The newly hired users user key, which set while Set Dynamic Employee |
    [Arguments]    ${user_key}
    ${employee}    Get Dynamic Employee    ${user_key}
    ${app_url}    Get Config Value    key=app_url
    Launch Browser
    Launch WFM Web Application    ${app_url}
    Update Default Language To English Of Non Mywork Login Page On Web
    # Perform initial login with employee_id as username and password
    Enter Username    ${employee}[employee_id]
    Enter Password    ${employee}[employee_id]
    Click Login Button
    Wait Until Page Is Loaded
    Finish New Hire Setup If Required On Web    ${user_key}
    Close Browser
