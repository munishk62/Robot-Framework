*** Settings ***
Documentation       Test cases for downloading individual Cognos Reports in CSV format.

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
Cognos Custom Report Download CSV For ${Sequence No} - ${Report Name}
    [Documentation]    Verify that a Cognos custom report can be run and exported successfully.
    [Tags]    cognos    cognos_custom_reports_download    rws    l2_suite
    [Template]    Download Custom Cognos Report


*** Keywords ***
Download Custom Cognos Report
    [Documentation]
    ...    Downloads a custom Cognos report by constructing the final URL with auth token and gateway URI.
    ...    Captures the download status and logs any errors encountered during the process.
    ...    | =Arguments= | =Description= |
    ...    | sequence_no | Sequence number for tracking the report download |
    ...    | report_id | Unique identifier for the report |
    ...    | report_name | Display name of the report |
    ...    | report_path | Path to the report in Cognos |
    ...    | report_url | Template URL with placeholders for gateway URI and auth token |
    [Arguments]    ${Sequence No}
    ...    ${Report ID}
    ...    ${Report Name}
    ...    ${Report Path}
    ...    ${Report URL}

    Log    Processing Report: ${Sequence No} | ID: ${Report ID} | Name: ${Report Name} | Path: ${Report Path}    level=INFO

    ${gateway_uri}    Get Config Value    RAR_GATEWAY_URI
    TRY
        ${auth_token}    Get Parallel Value For Key    COGNOS_USER_AUTH_TOKEN
        Should Not Be Empty    ${auth_token}    msg=Auth token is empty. Ensure login was successful.

        ${final_url}    Replace String    ${Report URL}    {{RAR_GATEWAY_URI}}    ${gateway_uri}
        ${final_url}    Replace String    ${final_url}    {{AUTH_TOKEN}}    ${auth_token}

        ${report_status}    Download Cognos CSV Report Content
        ...    ${Report Name}    ${final_url}    ${Sequence No}

        Set Test Message    ${report_status}    append=True
        Log    Report Status: ${report_status}    level=INFO
    EXCEPT    AS    ${error}
        Log    Failed to download report '${Report Name}': ${error}    level=ERROR
        Set Test Message    Download failed for ${Report Name}: ${error}    append=True
        Fail    Report download failed: ${error}
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
