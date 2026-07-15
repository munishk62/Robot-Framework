*** Settings ***
Documentation       Test cases for verifying individual Cognos Report Functionality
...                 Command to run this test -
...                 Ex: uv run python executor.py web\tests\l2_suite\rws\reports\cognos_custom_reports_smoketest.robot
...                 --test-env WAWA_SB --results cognos --processes 4 --show-browser --testlevelsplit

Library             OperatingSystem
Library             Screenshot
Library             pabot.PabotLib
Library             DataDriver    file=${COGNOS_CUSTOM_REPORTS_FILE}    sheet_name=${SheetName}
Resource            resources/web/rws/reports/authoring_analysis_reports.resource
Resource            resources/web/rws/reports/cognos_login.resource

Suite Setup         Run Setup Only Once
...                     Login And Navigate To Cognos Authoring And Analysis Page    user_key=COGNOS_SYSADMIN
Test Setup          Launch Browser
Test Teardown       Close Browser

Test Tags           config:reports


*** Test Cases ***
Cognos Custom Report Smoketest For ${Sequence No} - ${Report Name}
    [Documentation]    Verify that a Cognos custom report can be run and exported successfully.
    [Tags]    cognos    cognos_custom_reports_smoketest    rws    l2_suite
    # Uncomment this line before execution
    [Template]    Validate Custom Cognos Report


*** Keywords ***
Validate Custom Cognos Report
    [Documentation]    Validate Custom Cognos Report
    [Arguments]    ${Sequence No}
    ...    ${Report ID}
    ...    ${Report Name}
    ...    ${Report Path}
    ...    ${Report URL}

    Log
    ...    Smoke Excel Data: ${Sequence No} : ${Report ID} : ${Report Name} : ${Report Path} : ${Report URL}
    ${Actual_RAR_Gateway_URI}    Get Config Value    RAR_GATEWAY_URI
    TRY
        ${auth_token}    Get Parallel Value For Key    COGNOS_USER_AUTH_TOKEN
        Should Not Be Empty    ${auth_token}
        ${FinalReport_URL}    Replace String    ${Report URL}    {{RAR_GATEWAY_URI}}    ${Actual_RAR_Gateway_URI}
        ${FinalReport_URL}    Replace String    ${FinalReport_URL}    {{AUTH_TOKEN}}    ${auth_token}
        @{Team_Content_Menus}    Split String    ${Report Path}    ${SPACE}>${SPACE}
        Log    Team Content Menus: ${Team_Content_Menus}
        Launch The Cognos Report URL    ${FinalReport_URL}
        Wait Until Page Is Loaded
        ${REPORT_STATUS}    ${screenshot_path}    Validate Cognos Report Content    ${Report Name}
        Set Test Message    ${REPORT_STATUS}    True
        Log    Report Status: ${REPORT_STATUS}
        Log    Screenshot Path: ${screenshot_path}
        Close Window
    EXCEPT    AS    ${error}
        Log    ${error}
        Set Test Message    Some Error Occurred. Check Logs For More Details.    True
    END

Login And Navigate To Cognos Authoring And Analysis Page
    [Documentation]    Login And Navigate To Cognos Authoring And Analysis Page
    [Arguments]    ${user_key}
    Login To WFM Application And Capture Auth Token On Web    user_key=${user_key}
    Navigate To Cognos Authoring And Analysis Page On Web
    Switch To Window On IBM Cognos Analytics Page
    Wait For IBM Cognos Analytics Progress Loader To Disappear
    Switch Back To First Opened Page Tab On Web
    Close Window
    Set Parallel Value For Key    COGNOS_USER_AUTH_TOKEN    ${USER_AUTH_TOKEN}
