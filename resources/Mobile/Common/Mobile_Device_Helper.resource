*** Settings ***
Documentation       This resource file contains keywords which are common for android and iOS devices.
...                 To use this resource file, Import this in the settings section as shown below:
...                 | ****** Settings ******
...                 | Resource    robotframework_device_helper/Device_Helper.resource
Library             BuiltIn
Library             Collections
Library             OperatingSystem
Library             Process
Library             AppiumLibrary    timeout=20s
Library             utils/common_utility/utility.py
Library             utils/mobility/cloud_appium.py
Resource         resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource         resources/Mobile/NativeClock/PageResources/Common/common.resource
Resource        resources/Mobile/SM/PagesResources/Common/Common.resource


*** Variables ***
${APPIUM_START_PORT}            4723
${WDA_LOCAL_PORT}               8100    # iOS WebDriverAgent forwarder port; must differ from ${APPIUM_START_PORT}. Override per-shard for parallel runs.
${APPIUM_LOG_LEVEL}             error   # [Use "info" for all details]
${LOCAL_HOST_IP}                http://127.0.0.1
${CLOUD_PLATFORM}               -
${CLOUD_USERNAME}               %{CLOUD_USERNAME}
${CLOUD_TOKEN}                  %{CLOUD_TOKEN}
${MOBILE_PLATFORM}              ${MOBILE_PLATFORM}
${DUT1}                         -
${LATITUDE}                18.51673    # Tower11 Pune Office latitude
${LONGITUDE}               73.92789    # Tower11 Pune Office longitude
${ZTEST_APP_MANAGEMENT_URL}    http://zin111la-lab1.zlab.com:4723/device-farm/apps
${ZTEST_REMOTE_END_POINT}    pune-t11-vm4.zebra.lan:8081/wd/hub
${LAMBDA_TEST_END_POINT}    mobile-hub.lambdatest.com/wd/hub


*** Keywords ***
Open Mobile ESS App
    [Documentation]    Open Mobile ESS App (Flutter-only)
    ...    Args:
    ...    ${tc_id}: (Optional) Test case ID for the current test run to showup in lambda test dashboard.
    ...    | Usage Example :
    ...    | Open Mobile ESS App
    ...    | Open Mobile ESS App    TC34001
    [Arguments]    ${tc_id}=''
    ${port}    Evaluate    ${APPIUM_START_PORT}
    ${is_android}    Evaluate    '${MOBILE_PLATFORM}' == 'android'
    VAR    ${test_env}    %{TEST_ENVIRONMENT=${EMPTY}}
    Terminate All Processes
    Sleep    2s
    ${build_detail}    Load Yaml    utils/mobility/jFrog/build_details.yaml
    IF    ${is_android}
        VAR    ${app_detail}    ${build_detail['workcloudshift_android']}
        VAR    ${automation_name}    UIAutomator2
        VAR    ${app_path}    ${EXECDIR}/ExternalFiles/APK/NextGenESS/${app_detail["APP_NAME"]}
        VAR    ${run_platform}    Android
        VAR    ${PACKAGE}    ${app_detail["PACKAGE_NAME"]}    scope=GLOBAL
        VAR    ${cloud_device_name}    ${app_detail["CLOUD_DEVICE_NAME"]}
        VAR    ${cloud_platform_version}    ${app_detail["CLOUD_PLATFORM_VERSION"]}
    ELSE
        VAR    ${app_detail}    ${build_detail['workcloudshift_ios']}
        VAR    ${automation_name}    XCUITest
        VAR    ${app_path}    ${EMPTY}    # iOS manual step of installing app on real device using test flight.
        VAR    ${run_platform}    iOS
        VAR    ${PACKAGE}    ${app_detail["PACKAGE_NAME"]}    scope=GLOBAL
        VAR    ${cloud_device_name}    ${app_detail["CLOUD_DEVICE_NAME"]}
        VAR    ${cloud_platform_version}    ${app_detail["CLOUD_PLATFORM_VERSION"]}
    END
    # Capabilities shared by every cloud platform; per-branch keys are added below.
    VAR    &{device_capabilities}
    ...    automationName=${automation_name}
    ...    platformName=${run_platform}
    ...    sessionOverride=true
    IF    '${CLOUD_PLATFORM}' == 'lambdaTest'
        VAR    ${custom_id}    ${app_Detail["BUILD_ID"]}
        ${location_obj}    Evaluate    {'lat': '${LATITUDE}', 'long': '${LONGITUDE}'}
        # Uploading the app to LambdaTest cloud
        Run
        ...    curl -u "${CLOUD_USERNAME}:${CLOUD_TOKEN}" --location --request POST https://manual-api.lambdatest.com/app/upload/realDevice --form custom_id="${custom_id}"
        VAR    ${REMOTE_URL}    https://${CLOUD_USERNAME}:${CLOUD_TOKEN}@${LAMBDA_TEST_END_POINT}
        Set To Dictionary    ${device_capabilities}
        ...    remote_url=${REMOTE_URL}
        ...    visual=True
        ...    devicelog=True
        ...    network=False
        ...    isRealMobile=True
        ...    app=${custom_id}
        ...    platformVersion=${cloud_platform_version}
        ...    deviceName=${cloud_device_name}
        ...    build=${test_env}-Shift-${run_platform}
        ...    name=${tc_id}
        ...    autoGrantPermissions=True
        ...    autoAcceptAlerts=True
        ...    reuseSession=True
        ...    location=${location_obj}
        ...    idleTimeout=1000
    ELSE
        # zTest and local share these appium-server-style capabilities.
        Set To Dictionary    ${device_capabilities}
        ...    bundleId=${PACKAGE}
        ...    appPackage=${PACKAGE}
        ...    newCommandTimeout=10000
        ...    autoAcceptAlerts=true
        ...    autoGrantPermissions=true
        ...    noReset=false
        ...    fullReset=true
        ...    showXCodeLog=true
        IF    '${CLOUD_PLATFORM}' == 'zTest'
            VAR    ${REMOTE_URL}    http://${CLOUD_USERNAME}:${CLOUD_TOKEN}@${ZTEST_REMOTE_END_POINT}
            IF    '${MOBILE_PLATFORM}' == 'android'
                VAR    ${ztest_app_file}    ${ZTEST_APP_MANAGEMENT_URL}/${app_Detail["ZTEST_APP_FILE"]}
            ELSE
                VAR    ${ztest_app_file}    ${EMPTY}
            END
            Set To Dictionary    ${device_capabilities}
            ...    remote_url=${REMOTE_URL}
            ...    app=${ztest_app_file}
            ...    ztf:suite_name=${test_env}
            ...    ztf:test_name=ShiftApp-${tc_id}
            ...    df:build=Flutter${run_platform}ShiftApp
            ...    df:accesskey=${CLOUD_USERNAME}
            ...    df:token=${CLOUD_TOKEN}
            ...    df:release_on_session_end=true
            ...    idleTimeout=180
        ELSE
            # Local execution on appium. Override fullReset from the shared zTest/local defaults so we do
            # not uninstall the app between sessions; noReset=false is inherited so the app state is still
            # cleared on open (bundleId is terminated + reopened) — the app itself stays installed.
            Set To Dictionary    ${device_capabilities}
            ...    remote_url=${LOCAL_HOST_IP}:${port}
            ...    app=${app_path}
            ...    fullReset=false
            # Local iOS: prefer a connected real device, fall back to a simulator when none is attached.
            # wdaLocalPort is the host->device USB-forward port for WebDriverAgent; it must be distinct from the Appium server port (${APPIUM_START_PORT}), otherwise Appium fails with "The port #4723 is occupied by an other process".
            IF    not ${is_android}
                ${udid}    Resolve Local IOS Device Udid
                IF    '${udid}' != ''
                    Set To Dictionary    ${device_capabilities}    udid=${udid}    wdaLocalPort=${WDA_LOCAL_PORT}
                    Log    Local iOS run targeting connected real device: ${udid}
                ELSE
                    Log    No connected iOS real device detected; Appium will fall back to an iOS simulator.    level=WARN
                END
            END
        END
    END
    # Always log the resolved capabilities so failed sessions can be debugged from log.html without re-running.
    Log Dictionary    ${device_capabilities}
    # Open Appium Application (custom) routes credentials through ClientConfig so Selenium does not emit the
    # "Embedding username and password in URL could be insecure" UserWarning on LambdaTest/zTest sessions.
    Open Appium Application    &{device_capabilities}
    Log Appium Session Data
    Prepare Mobile ESS App For Suite Execution
    Start Mobile Screen Recording

Open Mobile Native Clock Application
    [Documentation]    Open Mobile Native Clock Application
    ...    Args:
    ...    ${tc_id}: (Optional) Test case ID for the current test run to showup in lambda test dashboard.
    ...    | Usage Example :
    ...    | Open Mobile Native Clock Application
    ...    | Open Mobile Native Clock Application    TC34001
    [Arguments]    ${user}=SM1_STORE2    ${clock_registration_template}=${None}    ${tc_id}=''
    ${port}    Evaluate    ${APPIUM_START_PORT}
    ${is_android}    Evaluate    '${MOBILE_PLATFORM}' == 'android'
    Terminate All Processes
    Sleep    2s
    ${build_detail}    Load Yaml    utils/mobility/jFrog/build_details.yaml
    IF    ${is_android}
        VAR    ${app_detail}    ${build_detail['native_clock_android']}
        VAR    ${automation_name}    UIAutomator2
        VAR    ${app_path}    ${EXECDIR}/ExternalFiles/APK/NativeClock/${app_detail["APP_NAME"]}
        VAR    ${run_platform}    Android
        VAR    ${PACKAGE}    ${app_detail["PACKAGE_NAME"]}    scope=GLOBAL
        VAR    ${cloud_device_name}    ${app_detail["CLOUD_DEVICE_NAME"]}
        VAR    ${cloud_platform_version}    ${app_detail["CLOUD_PLATFORM_VERSION"]}
    ELSE
        VAR    ${app_detail}    ${build_detail['native_clock_ios']}
        VAR    ${automation_name}    XCUITest
        VAR    ${app_path}    ${EMPTY}    # iOS manual step of installing app on real device using test flight.
        VAR    ${run_platform}    iOS
        VAR    ${PACKAGE}    ${app_detail["PACKAGE_NAME"]}    scope=GLOBAL
        VAR    ${cloud_device_name}    ${app_detail["CLOUD_DEVICE_NAME"]}
        VAR    ${cloud_platform_version}    ${app_detail["CLOUD_PLATFORM_VERSION"]}
    END
    IF    '${CLOUD_PLATFORM}' == 'lambdaTest'
        VAR    ${custom_id}    ${app_Detail["BUILD_ID"]}
        # Uploading the app to LambdaTest cloud
        Run     curl -u "${CLOUD_USERNAME}:${CLOUD_TOKEN}" --location --request POST https://manual-api.lambdatest.com/app/upload/realDevice --form custom_id="${custom_id}"
        VAR    ${REMOTE_URL}    https://${CLOUD_USERNAME}:${CLOUD_TOKEN}@${LAMBDA_TEST_END_POINT}
        Open Appium Application    remote_url=${REMOTE_URL}
        ...    automationName=${automation_name}
        ...    platformName=${run_platform}
        ...    sessionOverride=true
        ...    visual=True
        ...    network=False
        ...    isRealMobile=True
        ...    app=${custom_id}
        ...    platformVersion=${cloud_platform_version}
        ...    deviceName=${cloud_device_name}
        ...    build=Native${run_platform}ClockApp
        ...    autoGrantPermissions=True
        ...    reuseSession=True
        # Lambda test does not support multiple tests in a single session, so preparing the app for suite execution
        Prepare Mobile Native Clock App For Suite Execution    ${user}    ${clock_registration_template}
    ELSE IF    '${CLOUD_PLATFORM}' == 'zTest'
        VAR    ${REMOTE_URL}    ${ZTEST_REMOTE_END_POINT}
        IF    '${MOBILE_PLATFORM}' == 'android'
            VAR    ${ztest_app_file}    ${ZTEST_APP_MANAGEMENT_URL}/${app_Detail["ZTEST_APP_FILE"]}
        ELSE
            VAR    ${ztest_app_file}    ${EMPTY}
        END
        Open Appium Application    remote_url=${REMOTE_URL}
        ...    automationName=${automation_name}
        ...    platformName=${run_platform}    sessionOverride=true
        ...    bundleId=${PACKAGE}
        ...    app=${ztest_app_file}
        ...    appPackage=${PACKAGE}
        ...    newCommandTimeout=10000
        ...    autoAcceptAlerts=true
        ...    autoGrantPermissions=true
        ...    noReset=false
        ...    fullReset=true
        ...    showXCodeLog=true
        ...    df:build=Flutter${run_platform}ShiftApp
        ...    df:accesskey=${CLOUD_USERNAME}
        ...    df:token=${CLOUD_TOKEN}
        ...    df:release_on_session_end=true
        ...    idleTimeout=180
        Prepare Mobile Native Clock App For Suite Execution    ${user}    ${clock_registration_template}
    ELSE
        # Local execution on appium.
        VAR    &{local_capabilities}
        ...    automationName=${automation_name}
        ...    platformName=${run_platform}
        ...    sessionOverride=true
        ...    bundleId=${PACKAGE}
        ...    app=${app_path}
        ...    newCommandTimeout=10000
        ...    autoGrantPermissions=true
        ...    noReset=true
        ...    fullReset=false
        ...    showXCodeLog=true
        IF    ${is_android}
            Set To Dictionary    ${local_capabilities}    udid=${DUT1}
        ELSE
            # Local iOS: prefer a connected real device, fall back to a simulator when none is attached.
            # wdaLocalPort is the host->device USB-forward port for WebDriverAgent; it must be distinct from the Appium server port (${APPIUM_START_PORT}), otherwise Appium fails with "The port #4723 is occupied by an other process".
            ${udid}    Resolve Local IOS Device Udid
            IF    '${udid}' != ''
                Set To Dictionary    ${local_capabilities}    udid=${udid}    wdaLocalPort=${WDA_LOCAL_PORT}
                Log    Local iOS run targeting connected real device: ${udid}
            ELSE
                Log    No connected iOS real device detected; Appium will fall back to an iOS simulator.    level=WARN
            END
        END
        Open Appium Application    remote_url=${LOCAL_HOST_IP}:${port}    &{local_capabilities}
    END
    IF    "${tc_id}" != "''"
        Prepare Mobile Native Clock App For Suite Execution    ${user}    ${clock_registration_template}
    END
    Start Mobile Screen Recording

Start Mobile Screen Recording
    [Documentation]    Used for starting mobile recording
    # Skipping video recording for lambda test as it crashing with error: The screen capture process 'ffmpeg' died unexpectedly
    IF    '${CLOUD_PLATFORM}' != 'lambdaTest'
        Start Screen Recording    timeLimit=1800s    videoSize=1280x720    bitRate=500000
    END

Stop Mobile Screen Recording
    [Documentation]    Used for stopping mobile recording and storing the video in the specified location
    ...    Args:
    ...    ${tc_id}: Ticket ID for the video
    [Arguments]    ${tc_id}
    VAR    ${recording_directory}    ${OUTPUT DIR}/mobile/Recording
    OperatingSystem.Create Directory    ${recording_directory}
    VAR    ${path}    ${recording_directory}/${tc_id}
    Stop Screen Recording    filename=${path}
    Log
    ...    <video width="360" controls><source src="./mobile/Recording/${tc_id}.mp4" type="video/mp4">Browser does not support the video.</video>
    ...    html=True

Take Mobile Page Screenshot
    [Documentation]    Used for capturing mobile page screenshot and storing the image in the specified location
    ...    Args:
    ...    ${tc_id}: Ticket ID for the screenshot
    [Arguments]    ${tc_id}
    Dump All Visible Elements
    VAR    ${screenshot_directory}    ${OUTPUT DIR}/mobile/Screenshots
    Create Directory    ${screenshot_directory}
    VAR    ${path}    ${screenshot_directory}/${tc_id}.png
    Run Keyword And Ignore Error    Capture Page Screenshot    ${path}
    Log    <img src="./mobile/Screenshots/${tc_id}.png" width="600">    html=True

Dump All Visible Elements
    [Documentation]    Used for dumping all the visible elements on the mobile screen which can be helpful in debugging the failed test cases.
    ${source}    Get Source
    Log    ${source}

Update Test Status
    [Documentation]    Updates the test status by executing a script through the Appium driver.
    ...    Args:
    ...    ${status}: Status of the test, either "passed" or "failed".
    [Arguments]    ${status}
    IF    '${CLOUD_PLATFORM}' == 'lambdaTest'
        ${driver}    Get Library Instance    AppiumLibrary
        Evaluate    $driver._current_application().execute_script("lambda-status=${status}")
    END

Open SM Native Application On Mobile Phone
    [Documentation]    Open SM Native Application on Mobile Phone
    ...    | Usage Example :
    ...    | Open SM Native Application on Mobile Phone
    [Arguments]    ${tc_id}=''
    Open SM Native Application On Mobile    phone    ${tc_id}
    Log    Opening SM Native App on Mobile phone ${MOBILE_PLATFORM}

Open SM Native Application On Mobile Tablet
    [Documentation]    Open SM Native Application on Mobile Tablet
    ...    | Usage Example :
    ...    | Open SM Native Application on Mobile Tablet
    [Arguments]    ${tc_id}=''
    Open SM Native Application On Mobile    tablet    ${tc_id}
    Log    Opening SM Native App on Mobile tablet ${MOBILE_PLATFORM}

Open SM Native Application On Mobile
    [Documentation]
    ...    Opens the SM native app on cloud or local Appium for phone or tablet.
    ...    Local iOS on a real device requires ``${DUT1}`` (set ``--device`` on the executor) and the app installed on the device; ``bundleId`` is taken from build details.
    ...    If Appium/Xcode fails with a missing Simulator SDK (for example 18.2), pass ``--variable IOS_LOCAL_PLATFORM_VERSION:18.3`` using an SDK version installed on the Mac (`xcrun simctl list runtimes`).
    ...    | =Arguments= | =Description= |
    ...    | device_type | ``phone`` or ``tablet``; used for cloud device name patterns. |
    ...    | tc_id | Optional id used as the session ``build`` name. |
    ...    Example usage:
    ...    | Open SM Native Application On Mobile Phone    battc00126
    [Tags]    robot:private
    [Arguments]    ${device_type}=phone    ${tc_id}=''
    Terminate All Processes
    Sleep    2s
    VAR    ${test_env}    %{TEST_ENVIRONMENT=${EMPTY}}
    ${port}    Evaluate    ${APPIUM_START_PORT}
    ${build_detail}    Load Yaml    utils/mobility/jFrog/build_details.yaml
    ${is_android}    Evaluate    '${MOBILE_PLATFORM}' == 'android'
    IF    ${is_android}
        VAR    ${app_detail}    ${build_detail['native_sm_android']}
        VAR    ${automation_name}    UIAutomator2
        VAR    ${app_path}    ${EXECDIR}/ExternalFiles/APK/SM45/${app_detail["APP_NAME"]}
        IF    '${device_type}' == 'phone'
            VAR    ${cloud_device_name}    ^.*Galaxy (S|A|M).*$
        ELSE
            VAR    ${cloud_device_name}    (?i).*tab.*
        END
        VAR    ${run_platform}    Android
        VAR    ${PACKAGE}    ${app_detail["PACKAGE_NAME"]}    scope=GLOBAL
        VAR    ${appActivity}    com.reflexis.android.storemanager.login.RSMSplashActivity
        VAR    ${appium_version}    latest
    ELSE
        VAR    ${app_detail}    ${build_detail['native_sm_ios']}
        VAR    ${automation_name}    XCUITest
        VAR    ${app_path}    ${EMPTY}
        IF    '${device_type}' == 'phone'
            VAR    ${cloud_device_name}    iPhone.*
        ELSE
            VAR    ${cloud_device_name}    iPad.*
        END
        VAR    ${run_platform}    iOS
        VAR    ${PACKAGE}    ${app_detail["PACKAGE_NAME"]}    scope=GLOBAL
        VAR    ${appium_version}    latest
    END
    # Capabilities shared by every cloud platform; per-branch keys are added below.
    VAR    &{device_capabilities}
    ...    automationName=${automation_name}
    ...    platformName=${run_platform}
    ...    sessionOverride=true
    IF    '${CLOUD_PLATFORM}' == 'lambdaTest'
        # LambdaTest requires the app to be uploaded on their cloud before launching the app on real device, so uploading the app using API call. This requires the app file to be present locally in the specified path.
        VAR    ${custom_id}    ${app_Detail["BUILD_ID"]}
        ${location_obj}    Evaluate    {'lat': '${LATITUDE}', 'long': '${LONGITUDE}'}
        Run
        ...    curl -u "${CLOUD_USERNAME}:${CLOUD_TOKEN}" --location --request POST https://manual-api.lambdatest.com/app/upload/realDevice --form name="EssNative_App" --form appFile=@"${app_path}" --form custom_id="${custom_id}"
        VAR    ${REMOTE_URL}    https://${CLOUD_USERNAME}:${CLOUD_TOKEN}@${LAMBDA_TEST_END_POINT}
        Set To Dictionary    ${device_capabilities}
        ...    remote_url=${REMOTE_URL}
        ...    visual=True
        ...    devicelog=True
        ...    network=False
        ...    isRealMobile=True
        ...    app=${custom_id}
        ...    appiumVersion=${appium_version}
        ...    deviceName=${cloud_device_name}
        ...    build=${test_env}-SM45-${run_platform}
        ...    name=${tc_id}
        ...    autoGrantPermissions=True
        ...    autoAcceptAlerts=false
        ...    fullReset=True
        ...    idleTimeout=600
        ...    location=${location_obj}
        # LambdaTest's resignApp=false requires the IPA to be signed as an Enterprise app, which the SM IPA is not. Letting LambdaTest re-sign with their own profile is the default and what iOS needs. Android keeps the original resignApp=False.
        IF    ${is_android}
            Set To Dictionary    ${device_capabilities}    resignApp=False
        END
    ELSE
        # zTest and local share these appium-server-style capabilities.
        Set To Dictionary    ${device_capabilities}
        ...    bundleId=${PACKAGE}
        ...    appPackage=${PACKAGE}
        ...    newCommandTimeout=10000
        ...    autoGrantPermissions=true
        ...    noReset=false
        ...    adbExecTimeout=120000
        # appActivity is android-only; ${appActivity} is unset on iOS.
        IF    ${is_android}
            Set To Dictionary    ${device_capabilities}    appActivity=${appActivity}
        END
        IF    '${CLOUD_PLATFORM}' == 'zTest'
            # ZTest does not have API to upload app, so using direct app file url to launch the app on cloud device. This requires the app to be already uploaded on ZTest App management console.
            VAR    ${REMOTE_URL}    http://${CLOUD_USERNAME}:${CLOUD_TOKEN}@${ZTEST_REMOTE_END_POINT}
            VAR    ${ztest_app_file}    ${ZTEST_APP_MANAGEMENT_URL}/${app_Detail["ZTEST_APP_FILE"]}
            Set To Dictionary    ${device_capabilities}
            ...    remote_url=${REMOTE_URL}
            ...    app=${ztest_app_file}
            ...    showXCodeLog=true
            ...    ztf:suite_name=${test_env}
            ...    ztf:test_name=SM45-${tc_id}
            ...    df:build=${run_platform}SMApp
            ...    df:accesskey=${CLOUD_USERNAME}
            ...    df:token=${CLOUD_TOKEN}
            ...    df:release_on_session_end=true
            ...    idleTimeout=180
            # iOS: keep the already-installed/trusted ipa; only Android needs fullReset for clean state.
            IF    ${is_android}
                Set To Dictionary    ${device_capabilities}    fullReset=true
            ELSE
                Set To Dictionary    ${device_capabilities}
                ...    fullReset=false
                ...    noReset=false
                ...    useNewWDA=false
                ...    usePrebuiltWDA=true
                ...    shouldTerminateApp=true
                ...    forceAppLaunch=true
                ...    appPushTimeout=120000
                ...    wdaLaunchTimeout=100000
                ...    wdaStartupRetries=2
            END
        ELSE
            # Local execution on appium
            Set To Dictionary    ${device_capabilities}
            ...    remote_url=${LOCAL_HOST_IP}:${port}
            ...    app=${app_path}
            ...    name=SMNativeApp
            ...    build=${tc_id}
            ...    fullReset=false
            ...    isRealMobile=True
            ...    network=True
            ...    idleTimeout=600
            # Local iOS: prefer a connected real device, fall back to a simulator when none is attached.
            # wdaLocalPort is the host->device USB-forward port for WebDriverAgent; it must be distinct from the Appium server port (${APPIUM_START_PORT}), otherwise Appium fails with "The port #4723 is occupied by an other process".
            IF    not ${is_android}
                ${udid}    Resolve Local IOS Device Udid
                IF    '${udid}' != ''
                    Set To Dictionary    ${device_capabilities}    udid=${udid}    wdaLocalPort=${WDA_LOCAL_PORT}
                    Log    Local iOS run targeting connected real device: ${udid}
                ELSE
                    Log    No connected iOS real device detected; Appium will fall back to an iOS simulator.    level=WARN
                END
            END
        END
    END
    # Always log the resolved capabilities so failed sessions can be debugged from log.html without re-running.
    Log Dictionary    ${device_capabilities}
    # Open Appium Application (custom) routes credentials through ClientConfig so Selenium does not emit the
    # "Embedding username and password in URL could be insecure" UserWarning on LambdaTest/zTest sessions.
    Open Appium Application    &{device_capabilities}
    # Accept app permissions popup if displayed on SM iOS app as it might block the execution if not handled.
    Log Appium Session Data
    Accept If App Permissions Popup Displayed On SM IOS App
    Prepare Mobile SM App For Suite Execution
    Start Mobile Screen Recording

Resolve Local IOS Device Udid
    [Documentation]
    ...    Resolves the UDID to use for a *local* iOS Appium session.
    ...    Precedence: an explicit ``--device`` value (``${DUT1}``) always wins; otherwise the
    ...    first physically connected real iOS device is auto-detected via ``xctrace``.
    ...    Returns an empty string when no real device is attached, so the caller can fall
    ...    back to an iOS simulator. This keyword is only meant for local (non-cloud) runs.
    ...    *Returns*: UDID of the target real device, or empty string for simulator fallback.
    ...    Example usage:
    ...    | ${udid}=    Resolve Local IOS Device Udid
    [Tags]    robot:private
    IF    '${DUT1}' != '-'    RETURN    ${DUT1}
    ${udid}    Get Connected Ios Device Udid
    RETURN    ${udid}

Close Mobile Application
    [Documentation]    Close any mobile application running on current appium session
    ...    | Usage Example :
    ...    | Close Mobile Application    TC34001
    [Arguments]    ${tc_id}
    Run Keyword And Ignore Error    Stop Mobile Screen Recording    ${tc_id}
    AppiumLibrary.Close Application

Log Appium Session Data
    [Documentation]    Log Appium session data for current appium session. Can be used to debug failed sessions.
    ${lib}    Get Library Instance    AppiumLibrary
    ${driver}    Evaluate    $lib._current_application()
    ${caps}    Evaluate    $driver.capabilities
    ${udid}            Evaluate    $caps.get('udid') or $caps.get('deviceName')
    ${platform}        Evaluate    $caps.get('platformName')
    ${version}         Evaluate    $caps.get('platformVersion')
    ${device_name}     Evaluate    $caps.get('deviceName')
    ${session_id}      Evaluate    str($driver.session_id)

    VAR    &{session_data}     sessionId=${session_id}    udid=${udid}    deviceName=${device_name}    platformName=${platform}    platformVersion=${version}

    ${pretty_json}    Evaluate    json.dumps($session_data, indent=2)    json
    Log    ${pretty_json}
