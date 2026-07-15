*** Settings ***
Documentation       This resource file provides keywords for automating the Cognos Authoring and Analysis Reports.

Resource            resources/web/common/common.resource
Variables           resources/web/rta/operations/timecard_page.py
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/authentication/auth_api.resource
# Variables    resources/web/rws/reports/view_reports_page.py
Variables           resources/web/rws/reports/authoring_analysis_reports_page.py
Variables           resources/api/api_endpoints.py
Resource            resources/api/api_executor.resource
Resource            resources/web/common/database.resource
Variables           resources/web/rws/reports/reports_db_queries.py


*** Keywords ***
Navigate To Cognos Authoring And Analysis Page On Web
    [Documentation]    Navigate To RWS -> Reports -> Authoring and Analysis Page On Web
    Navigate To Specific Page On Web    rws    reports    authoring_and_analysis

Validate Cognos Report Content
    [Documentation]
    ...    Validates the IBM Cognos Analytics Reports page and captures a screenshot for verification.
    ...    Also writes a row to ./cognos/test_result.xlsx with columns:
    ...    Report Name | Report Path | REPORT_STATUS | screenshot_path
    ...    | =Arguments= | =Description= |
    ...    | Report Name | Display name of the report |
    ...    | Report Path | Path to the report in Cognos |
    ...    | =Returns= | =Description= |
    ...    | REPORT_STATUS | Status of the report (LOADING, Failed, RE-PROMPT, or Passed) |
    ...    | screenshot_path | Full path to the captured screenshot |
    ...    Example usage:
    ...    | ${status}    ${screenshot}    Validate Cognos Report Content    Sales Report    RFLX > RFLXAAR > RWS > DESKTOP > App > Store > Standard Reports > Weekly Employee Shift Summary
    [Arguments]    ${Report Name}

    # Ensure target directory exists (create only if needed, never delete)
    VAR    ${custom_reports_dir}    ${OUTPUT DIR}${/}screenshots
    ${dir_exists}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${custom_reports_dir}
    IF    not ${dir_exists}
        Create Directory    ${custom_reports_dir}
        Log    Created directory: ${custom_reports_dir}    level=INFO
    ELSE
        Log    Using existing directory: ${custom_reports_dir}    level=INFO
    END

    # Sanitize report name for filename
    ${sanitized_name}    Replace String Using Regexp    ${Report Name}    [^a-zA-Z0-9_-]    _
    VAR    ${screenshot_filename}    ${sanitized_name}.png
    VAR    ${screenshot_path}    ${custom_reports_dir}${/}${screenshot_filename}

    ${is_server_error_displayed}    Is Server Error Displayed On Cognos Reports Page
    IF    ${is_server_error_displayed}
        Take Screenshot
        RETURN    Server_Error    ${screenshot_path}
    END

    ${is_report_loaded_on_time}    Is Cognos Report Page Loaded On Time
    IF    not ${is_report_loaded_on_time}
        Take Screenshot
        Click Element On Webpage    ${REPORTS_PAGE_LONG_LOADING_CANCEL_BTN}
        RETURN    Long-Running-Timeout    ${screenshot_path}
    END

    ${validate_error}    Is Error Message Icon Displayed On Cognos Reports Page
    IF    ${validate_error}
        Take Screenshot
        RETURN    Failed    ${screenshot_path}
    END

    ${validate_re_prompt}    Is OK Button Displayed For Re-prompt On Cognos Reports Page
    IF    ${validate_re_prompt}
        Take Screenshot
        RETURN    Re-Prompt    ${screenshot_path}
    END

    Take Screenshot
    RETURN    Passed    ${screenshot_path}

Is Cognos Report Page Loaded On Time
    [Documentation]
    ...    Verifies that the IBM Cognos Analytics content progress loader disappears within the given timeout.
    ...    | =Arguments= | =Description= |
    ...    | timeout | Optional timeout to wait for the loader to disappear. Defaults to ${COGNOS_REPORT_LONG_LOADING_TIMEOUT}. |
    ...    Example usage:
    ...    | Is Cognos Report Page Loaded On Time    ${COGNOS_REPORT_LONG_LOADING_TIMEOUT}
    [Arguments]    ${timeout}=${COGNOS_REPORT_LONG_LOADING_TIMEOUT}
    ${result}    Run Keyword And Return Status    Wait Until Loader Disappears On Webpage
    ...    ${REPORTS_AUTHORIZING_PAGE_SPINNER_ICON}    timeout=${timeout}
    RETURN    ${result}

Is Error Message Icon Displayed On Cognos Reports Page
    [Documentation]
    ...    Checks whether the error message icon is visible inside the active Cognos iframe for team content reports.
    ...    | =Arguments= | =Description= |
    ...    | iframe | Optional. The active iframe element. If not provided, it will be fetched automatically. |
    ...    Example usage:
    ...    | Is Error Message Icon Displayed On Cognos Reports Page
    ...    | Is Error Message Icon Displayed On Cognos Reports Page    iframe=${my_iframe}
    [Arguments]    ${iframe}=${None}
    IF    '${iframe}' == '${None}'
        ${active_iframe}    Get Active IFrame Element
    ELSE
        VAR    ${active_iframe}    ${iframe}
    END
    ${result}    Verify Visibility Of Frame Element    ${active_iframe}    ${REPORTS_AUTHORIZING_PAGE_ERROR_ICON}
    RETURN    ${result}

Is OK Button Displayed For Re-prompt On Cognos Reports Page
    [Documentation]
    ...    Verifies whether the OK button (used for re-prompting Cognos reports) is visible inside the active iframe.
    ...    | =Arguments= | =Description= |
    ...    | iframe | Optional. The active iframe element. If not provided, it will be fetched automatically. |
    ...    Example usage:
    ...    | Is OK Button Displayed For Re-prompt On Cognos Reports Page
    ...    | Is OK Button Displayed For Re-prompt On Cognos Reports Page    iframe=${my_iframe}
    [Arguments]    ${iframe}=${None}

    IF    '${iframe}' == '${None}'
        ${active_iframe}    Get Active IFrame Element
    ELSE
        VAR    ${active_iframe}    ${iframe}
    END
    ${result}    Verify Visibility Of Frame Element    ${active_iframe}    ${REPORTS_AUTHORIZING_PAGE_RE_PROMPT_OK_BTN}
    RETURN    ${result}

Switch To Window On IBM Cognos Analytics Page
    [Documentation]    Switch To Window On ‘IBM Cognos Analytics’ Page
    ...    | Example |
    ...    | Switch To Window On ‘IBM Cognos Analytics’ Page |
    Switch To New Window On Web
    Wait Until Page Is Loaded    timeout=60s
    Capture Screenshot On Webpage

Wait For IBM Cognos Analytics Progress Loader To Disappear
    [Documentation]    Wait For IBM Cognos Analytics Progress Loader To Disappear from the page.
    ...    |    Example    |
    ...    |    Wait For IBM Cognos Analytics Progress Loader To Disappear    |
    # Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${REPORTS_AUTHORIZING_PAGE_PROGRESS_BAR_LOADER}    timeout=${LONG_TIMEOUT}
    Capture Screenshot On Webpage
    Close Window

Wait Until Loader Disappears On Webpage
    [Documentation]
    ...    Waits until the specified element disappears from the webpage.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element. |
    ...    | timeout    | Maximum time to wait. Optional. |
    ...    Example usage:
    ...    | Wait Until Element Disappears On Webpage    id=loading
    [Arguments]    ${locator}    ${timeout}=${LONG_TIMEOUT}
    ${prefix}    Set Selector Prefix    ${None}
    Wait For Elements State    ${locator}    hidden    timeout=${timeout}
    Set Selector Prefix    ${prefix}

Download Cognos CSV Report Content
    [Documentation]
    ...    Downloads a Cognos CSV report and captures a screenshot for verification.
    ...    Creates a new browser context with download support before navigating to the report URL.
    ...    | =Arguments= | =Description= |
    ...    | report_name | Display name of the report |
    ...    | report_url | Full URL to access the report (triggers auto-download) |
    ...    | sequence_no | Unique sequence number for the download filename |
    ...    | =Returns= | =Description= |
    ...    | report_status | Status: Long-Running-Timeout, Failed, Re-Prompt, Report_Downloaded, or Download_Failed |
    ...    Example usage:
    ...    | ${status}=    Download Cognos CSV Report Content    Sales Report    https://cognos.example.com/report    001
    [Arguments]    ${report_name}    ${report_url}    ${sequence_no}

    VAR    ${download_dir}    ${EXECDIR}${/}cognos_downloads
    Create Directory    ${download_dir}

    ${sanitized_name}    Replace String Using Regexp    ${report_name}    [^a-zA-Z0-9_-]    _
    VAR    ${download_file_path}    ${download_dir}${/}${sanitized_name}_${sequence_no}.csv

    ${original_timeout}    Set Browser Timeout    timeout=${COGNOS_REPORT_LONG_LOADING_TIMEOUT}
    VAR    ${report_status}    Unknown

    TRY
        New Context    acceptDownloads=${TRUE}
        New Page
        ${download_promise}    Promise To Wait For Download
        ...    ${download_file_path}    download_timeout=${COGNOS_REPORT_LONG_LOADING_TIMEOUT}
        Go To    ${report_url}
        Wait Until Page Is Loaded

        ${is_loaded_on_time}    Is Cognos Report Page Loaded On Time

        IF    not ${is_loaded_on_time}
            VAR    ${report_status}    Long-Running-Timeout
            Run Keyword And Ignore Error    Click Element On Webpage    ${REPORTS_PAGE_LONG_LOADING_CANCEL_BTN}
        ELSE
            ${active_iframe}    Get Active IFrame Element
            ${has_error}    Is Error Message Icon Displayed On Cognos Reports Page    iframe=${active_iframe}
            ${needs_reprompt}    Is OK Button Displayed For Re-prompt On Cognos Reports Page    iframe=${active_iframe}

            IF    ${has_error}
                VAR    ${report_status}    Failed
            ELSE IF    ${needs_reprompt}
                VAR    ${report_status}    Re-Prompt
            ELSE
                TRY
                    Wait For    ${download_promise}
                    ${file_exists}    Run Keyword And Return Status
                    ...    OperatingSystem.File Should Exist    ${download_file_path}
                    IF    ${file_exists}
                        Log    Successfully downloaded file to: ${download_file_path}    level=INFO
                        VAR    ${report_status}    Report-Downloaded
                    ELSE
                        Log    Download completed but file not found at: ${download_file_path}    level=WARN
                        VAR    ${report_status}    Download-Failed
                    END
                EXCEPT    *    AS    ${download_error}
                    Log    Download failed: ${download_error}    level=WARN
                    VAR    ${report_status}    Download-Failed
                END
            END
        END
    FINALLY
        Take Screenshot
        Set Browser Timeout    ${original_timeout}
    END

    Log    Report: ${report_name} | Status: ${report_status}
    RETURN    ${report_status}

Is Server Error Displayed On Cognos Reports Page
    [Documentation]
    ...    Checks whether the Server error message is visible inside the active Cognos iframe for team content reports.
    ...    | =Arguments= | =Description= |
    ...    | iframe | Optional. The active iframe element. If not provided, it will be fetched automatically. |
    ...    Example usage:
    ...    | Is Server Error Displayed On Cognos Reports Page
    ...    | Is Server Error Displayed On Cognos Reports Page    iframe=${my_iframe}
    [Arguments]    ${iframe}=${None}
    IF    '${iframe}' == '${None}'
        ${active_iframe}    Get Active IFrame Element
    ELSE
        VAR    ${active_iframe}    ${iframe}
    END
    ${result}    Verify Visibility Of Frame Element    ${active_iframe}    ${REPORTS_AUTHORIZING_PAGE_INTERNAL_SERVER_ERROR}
    RETURN    ${result}
