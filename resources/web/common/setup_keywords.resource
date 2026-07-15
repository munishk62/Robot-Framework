*** Settings ***
Documentation       This resource file contains the setup keywords for the WFM test suite

Resource            resources/web/common/util_keywords.resource
Resource            resources/web/authentication/login.resource
Library             test_data/TestDataLibrary.py


*** Variables ***
${RUN_SUITE_SETUP}          ${True}    # Default is True : False only for Development
${USE_DIRECT_LOGIN}         ${EMPTY}
${KERNAL_SUDO_USERNAME}     ${EMPTY}


*** Keywords ***
WFM Sudo Login For Suite Set Up
    [Documentation]    Performs sudo login for the mentioned client via kernel for suite setup
    ...    for the given user role. Default is System Admin.
    ...    The login will be tried for 5 times with 5 seconds interval.
    ...    Should be used only in Suite Setup
    ...    This Should be used only for PP and SB Environment With MYWork Integrated and For QA Environment it will be skipped.
    [Tags]    suite_setup
    [Arguments]    ${login_in_as}=System Admin
    VAR    ${KERNAL_SUDO_USERNAME}    ${login_in_as}    scope=SUITE
    ${USE_DIRECT_LOGIN}    Check To Use Direct Login Or Kernel Login
    IF    ${USE_DIRECT_LOGIN}    RETURN
    Wait Until Keyword Succeeds    6x    30s
    ...    Perform Sudo Login For Respective Kernal User    ${login_in_as}

Conditional Suite Setup For Web Clock Scenarios
    [Documentation]    This keyword is for conditional suite setup to execute test cases or not web clock scenarios.
    [Arguments]    ${client}
    Check Client For Web Clock Applicability    ${client}

Check Client For Web Clock Applicability
    [Documentation]    This keyword will check client.
    [Arguments]    ${client}
    IF    '${client}' == 'SFC'    Skip    Skipping test: As client is SFC

Conditional Skip For Client
    [Documentation]    This keyword is for conditional check for a client.
    [Arguments]    ${client}
    IF    '${client}' == 'BMR'
        Skip    Skipping As Fixed Shifts test Not applicable for BMR
    END

Redirect To Web Clock Landing Page
    [Documentation]    This keyword will redirect to the web clock landing page.
    IF    $web_clock_direct_url in ["None","NA"]
        Skip    Skipping test: As web clock direct URL is not set
    END
    New Page    ${web_clock_direct_url}
    Wait Until Page Is Loaded
    Update Default Language To English On Web Clock Page On Web

Launch And Login As System Admin For Test Setup
    [Documentation]    This keyword will login as system admin for test setup.
    [Tags]    test:setup
    [Arguments]    ${user_key}
    IF    ${USE_DIRECT_LOGIN}
        ${APP_URL}    Get Config Value    key=app_url
        Launch Browser
        Launch WFM Web Application    ${APP_URL}
        Update Default Language To English Of Non Mywork Login Page On Web
        Login To WFM Application As System Admin    ${user_key}
    ELSE
        Launch Browser
        Launch WFM Web Application    ${LOGIN_SESSION_URL}[${SUITE_NAME}]
        Ensure Active Login Session
    END
    # This below section is to ensure that My Work landing page is completely loaded.
    # This is added only as delay to ensure switch option is available, not as a check.
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    '${MY_WORK_INTEGRATED}' == 'True'
        Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage
        ...    ${loginpage_mywork_landing_page}    timeout=15s
    END

    # Perform switch to store, as per sudo username and user profile
    VAR    ${profile}    ${ALL_CREDENTIALS}[${user_key}][profile_name]
    IF    '${ALL_CREDENTIALS}[sudoUsers][${KERNAL_SUDO_USERNAME}]' == 'SYSADMIN' and '${profile}' == 'STRADMN' and '${USE_DIRECT_LOGIN}' == 'False'
        Log To Console    started switch to profile store
        ${store_data}    Get Store Data    template_name=default
        ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
        Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    END

Check To Use Direct Login Or Kernel Login
    [Documentation]    This keyword will check to use kernel login or not.
    ${DIRECT_LOGIN_CONFIG}    Get Config Value    DIRECT_LOGIN
    VAR    ${USE_DIRECT_LOGIN}    ${DIRECT_LOGIN_CONFIG}    scope=GLOBAL
    RETURN    ${USE_DIRECT_LOGIN}
