*** Settings ***
Documentation       Period Payroll Release page keywords implementation

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/authentication/login.resource
Variables           resources/web/rta/payroll/period_payroll_release_page.py


*** Keywords ***
Navigate To RTA Payroll Period Payroll Release Page On Web
    [Documentation]    Navigate To RTA -> Payroll Period -> Payroll Release Page
    ...    and verifies payroll release heading at the top of the page
    Navigate To Specific Page On Web    rta    payroll    period_payroll_release
    Wait Until Page Is Loaded

Apply Filter For Week On Period Payroll Release Page On Web
    [Documentation]    This keyword applies filter to get pay file status for week on Period Payroll Release page
    ...    | =Arguments= | =Description= |
    ...    | week_start_date | Week start date to filter |
    ...    | week_end_date | Week end date to filter |
    [Arguments]    ${week_start_date}    ${week_end_date}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${year_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    VAR    ${week_option}    ${week_start_date}-${week_end_date}
    # Get year from start date
    ${year}    Convert Date    ${week_start_date}    result_format=${year_format}    date_format=${date_format}
    ${filter_elements_visible}    Is Element Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_YEAR_DROPDOWN}
    IF    not ${filter_elements_visible}
        Click Element On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_FILTER_BUTTON}
        ...    error_message=Filter icon not found on Period Payroll Release page to apply week filter.
    END
    Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_YEAR_DROPDOWN}    text    ${year}
    Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_QUARTER_DROPDOWN}    text    Show All
    Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_MONTH_DROPDOWN}    text    Show All
    Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_WEEK_DROPDOWN}    text    ${week_option}
    Click Element On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_FILTER_APPLY_BUTTON}
    # Sleep    ${SHORT_TIMEOUT}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Apply Filter For Month For Semi Monthly On Period Payroll Release Page On Web
    [Documentation]    This keyword applies filter to get pay file status for week on Period Payroll Release page
    ...    | =Arguments= | =Description= |
    ...    | week_start_date | Week start date to filter |
    ...    | week_end_date | Week end date to filter |
    [Arguments]    ${week_start_date}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${year_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${month_format}    Get Config Value    DATE_FORMAT_ABBR_MONTH_ONLY

    # Get year    & Month from start date
    ${year}    Convert Date    ${week_start_date}    result_format=${year_format}    date_format=${date_format}
    ${month}    Convert Date    ${week_start_date}    result_format=${month_format}    date_format=${date_format}
    LOg To Console    Applying month filter for Semi Monthly payroll. Month: ${month}, Year: ${year}

    ${filter_elements_visible}    Is Element Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_YEAR_DROPDOWN}
    IF    not ${filter_elements_visible}
        Click Element On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_FILTER_BUTTON}
        ...    error_message=Filter icon not found on Period Payroll Release page to apply week filter.
    END
    Wait Until Page Is Loaded
    Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_YEAR_DROPDOWN}    text    ${year}
    Sleep    2s
    ${month_filter_visible}    Is Element Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_MONTH_DROPDOWN}
    IF    ${month_filter_visible}
        Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_MONTH_DROPDOWN}    text    ${month}
    END
    Wait Until Page Is Loaded
    Click Element On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_FILTER_APPLY_BUTTON}
    Sleep    ${SHORT_TIMEOUT}
    Capture Screenshot On Webpage

Check And Get Status Of Pay File Release On Period Payroll Release Page On Web
    [Documentation]    This keyword checks if payroll file has reopen action on Period Payroll Release page.
    ...    | =Arguments= | =Description= |
    ...    | pay_file_release_expected_status | The status text to check for (e.g., 'Released') |
    ...    | =Returns= | =Description= |
    ...    | status_as_expected | Boolean indicating if the status matches the expected status |
    [Arguments]    ${pay_file_release_expected_status}
    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_RELEASES_STATUS_VALUE}    timeout=${LONG_TIMEOUT}
    ${release_status}    Get Element Text On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_RELEASES_STATUS_VALUE}
    ${status_as_expected}    Run Keyword And Return Status    Should Be Equal    ${release_status}    ${pay_file_release_expected_status}
    RETURN    ${status_as_expected}

Check And Get Status For Specific Period Of Pay File Release On Period Payroll Release Page On Web
    [Documentation]    This keyword checks if payroll file has reopen action on Period Payroll Release page.
    ...    | =Arguments= | =Description= |
    ...    | period_start_date | The start date of the semi-monthly period |
    ...    | period_end_date | The end date of the semi-monthly period |
    ...    | pay_file_release_expected_status | The status text to check for (e.g., 'Released') |
    ...    | =Returns= | =Description= |
    ...    | status_as_expected | Boolean indicating if the status matches the expected status |
    [Arguments]    ${period_start_date}    ${period_end_date}    ${action_text}    ${pay_file_release_expected_status}
    VAR    ${period}    ${period_start_date}-${period_end_date}

    ${release_status_element}    Update Locator With Dynamic Values    ${PERIOD_PAYROLL_RELEASE_PAGE_PERIOD_STATUS_VALUE}
    ...    PERIOD=${period}    ACTION=${action_text}
    Wait Until Element Is Visible On Webpage    ${release_status_element}    timeout=${LONG_TIMEOUT}
    ${release_status}    Get Element Text On Webpage    ${release_status_element}
    ${status_as_expected}    Run Keyword And Return Status    Should Be Equal    ${release_status}    ${pay_file_release_expected_status}
    RETURN    ${status_as_expected}

Check If Data Loaded For Pay File Action On Period Payroll Release Page On Web
    [Documentation]    This keyword checks if data is loaded for pay file action on Period Payroll Release page by verifying visibility of status element.
    ...    | =Returns= | =Description= |
    ...    | has_data_loaded | Boolean indicating if the data has loaded and status element is visible |
    ${retry_attempts}    Get Config Value    MIN_RETRY_ATTEMPTS
    ${has_data_loaded}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${retry_attempts}    ${MEDIUM_TIMEOUT}
    ...    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_RELEASES_STATUS_VALUE}
    ...    error_message=Pay file data not found on Period Payroll Release page within timeout.
    RETURN    ${has_data_loaded}

Check And Get Status Of Pay File Reopen Action On Period Payroll Release Page On Web
    [Documentation]    This keyword checks if payroll file has reopen action on Period Payroll Release page.
    ...    | =Arguments= | =Description= |
    ...    | action_text | The action text to check for (e.g., 'Re-Open') |
    ...    | =Returns= | =Description= |
    ...    | has_reopen_action | Boolean indicating if the action is available |
    [Arguments]    ${action_text}=Re-Open
    ${has_data_loaded}    Check If Data Loaded For Pay File Action On Period Payroll Release Page On Web
    IF    not ${has_data_loaded}
        Skip    msg=Data did not load in time for Pay file action on Period Payroll Release page for the given week.
    END

    ${has_reopen_action}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${PERIOD_PAYROLL_RELEASE_PAGE_REOPEN_ACTION}    timeout=${LONG_TIMEOUT}
    ...    error_message=Pay file action '${action_text}' not found on Period Payroll Release page within timeout.
    Capture Screenshot On Webpage
    RETURN    ${has_reopen_action}

Check And Get Status Of Pay File Release Action On Period Payroll Release Page On Web
    [Documentation]    This keyword checks if payroll file has release action on Period Payroll Release page.

    ${has_data_loaded}    Check If Data Loaded For Pay File Action On Period Payroll Release Page On Web
    IF    not ${has_data_loaded}
        Skip    msg=Data did not load in time for Pay file action on Period Payroll Release page for the given week.
    END
    ${has_release_action}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${PERIOD_PAYROLL_RELEASE_PAGE_RELEASE_ACTION}    timeout=${LONG_TIMEOUT}
    ...    error_message=Pay file action 'Release' not found on Period Payroll Release page within timeout.
    Capture Screenshot On Webpage
    RETURN    ${has_release_action}

Check And Get Status Of Pay File Reopen Action For Semi Monthly On Period Payroll Release Page On Web
    [Documentation]    This keyword checks if payroll file has reopen action on Period Payroll Release page.
    ...    | =Arguments= | =Description= |
    ...    | period_start_date | The start date of the semi-monthly period |
    ...    | period_end_date | The end date of the semi-monthly period |
    ...    | =Returns= | =Description= |
    ...    | has_reopen_action | Boolean indicating if the action is available |
    [Arguments]    ${period_start_date}    ${period_end_date}
    ${has_data_loaded}    Check If Data Loaded For Pay File Action On Period Payroll Release Page On Web
    IF    not ${has_data_loaded}
        Skip    msg=Data did not load in time for Pay file action on Period Payroll Release page for the given week.
    END
    VAR    ${period}    ${period_start_date}-${period_end_date}

    ${reopen_action}    Update Locator With Dynamic Values    ${PERIOD_PAYROLL_RELEASE_PAGE_REOPEN_ACTION_FOR_PERIOD}    PERIOD=${period}
    ${has_reopen_action}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${reopen_action}
    ...    timeout=${LONG_TIMEOUT}
    ...    error_message=Pay file action Reopen not found on Period Payroll Release page within timeout.
    Capture Screenshot On Webpage
    RETURN    ${has_reopen_action}

Check And Get Status Of Pay File Release Action For Semi Monthly On Period Payroll Release Page On Web
    [Documentation]    This keyword checks if payroll file has release action on Period Payroll Release page.
    ...    | =Arguments= | =Description= |
    ...    | period_start_date | The start date of the semi-monthly period |
    ...    | period_end_date | The end date of the semi-monthly period |
    ...    | =Returns= | =Description= |
    ...    | has_release_action | Boolean indicating if the action is available |
    [Arguments]    ${period_start_date}    ${period_end_date}
    ${has_data_loaded}    Check If Data Loaded For Pay File Action On Period Payroll Release Page On Web
    IF    not ${has_data_loaded}
        Skip    msg=Data did not load in time for Pay file action on Period Payroll Release page for the given week.
    END
    VAR    ${period}    ${period_start_date}-${period_end_date}

    ${release_action}    Update Locator With Dynamic Values    ${PERIOD_PAYROLL_RELEASE_PAGE_RELEASE_ACTION_FOR_PERIOD}    PERIOD=${period}
    ${has_release_action}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${release_action}
    ...    timeout=${LONG_TIMEOUT}
    ...    error_message=Pay file action Release not found on Period Payroll Release page within timeout.
    Capture Screenshot On Webpage
    RETURN    ${has_release_action}

Reopen Pay File On Period Pay Release Page On Web
    [Documentation]    This keyword re-opens the pay file action for the selected week
    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_REOPEN_ACTION}
    ...    error_message=Re-Open action link not found on Period Payroll Release page for the given week within timeout.
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_REOPEN_ACTION}    error_message=Re-Open action link not clickable on Period Payroll Release page for the given week.
    Run Keyword And Ignore Error    Wait For    ${promise}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_NOTIFICATION}    timeout=${LONG_TIMEOUT}
    ${wait_spinner}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_SPINNER}
    IF    ${wait_spinner}
        Wait Until Element Disappears On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_SPINNER}    timeout=${LONG_TIMEOUT}
    END
    Wait For Load State    networkidle    timeout=${LONG_TIMEOUT}

Reopen Pay File For Specific Period For Semi Monthy On Period Pay Release Page On Web
    [Documentation]    This keyword re-opens the pay file action for the selected week
    ...    | =Arguments= | =Description= |
    ...    | period_start_date | The start date of the semi-monthly period |
    ...    | period_end_date | The end date of the semi-monthly period |
    [Arguments]    ${period_start_date}    ${period_end_date}
    VAR    ${period}    ${period_start_date}-${period_end_date}

    ${reopen_action_link}    Update Locator With Dynamic Values    ${PERIOD_PAYROLL_RELEASE_PAGE_REOPEN_ACTION_FOR_PERIOD}
    ...    PERIOD=${period}
    Wait Until Element Is Visible On Webpage    ${reopen_action_link}
    ...    error_message=Re-Open action link not found on Period Payroll Release page for the given week within timeout.
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${reopen_action_link}    error_message=Re-Open action link not clickable on Period Payroll Release page for the given week.
    Run Keyword And Ignore Error    Wait For    ${promise}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_NOTIFICATION}    timeout=${LONG_TIMEOUT}
    ${wait_spinner}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_SPINNER}
    IF    ${wait_spinner}
        Wait Until Element Disappears On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_SPINNER}    timeout=${LONG_TIMEOUT}
    END
    Wait For Load State    networkidle    timeout=${LONG_TIMEOUT}

Release Pay File On Period Payroll Release Page On Web
    [Documentation]    This keyword releases the pay file action for the selected week
    ${has_data_loaded}    Check If Data Loaded For Pay File Action On Period Payroll Release Page On Web
    IF    not ${has_data_loaded}
        Skip    msg=Data did not load in time for Pay file action on Period Payroll Release page for the given week.
    END
    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_RELEASE_ACTION}
    ...    error_message=Release action link not found on Period Payroll Release page for the given week within timeout.
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_RELEASE_ACTION}
    ...    error_message=Release action link not clickable on Period Payroll Release page for the given week.
    Run Keyword And Ignore Error    Wait For    ${promise}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_NOTIFICATION}    timeout=${LONG_TIMEOUT}
    ${wait_spinner}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_SPINNER}
    IF    ${wait_spinner}
        Wait Until Element Disappears On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_SPINNER}    timeout=${LONG_TIMEOUT}
    END
    Sleep    ${SHORT_TIMEOUT}
    Wait For Load State    networkidle    timeout=${LONG_TIMEOUT}

Release Pay File On Period Payroll Release Page With Distribution List Configured On Web
    [Documentation]    Clicks the release button for the given payfile name on Period Payroll Release page and handles distribution list dialog if it appears.
    ...    | =Arguments= | =Description= |
    ...    | payfile_name | The name of the payfile to release |
    ...    This keyword will fail if the payfile release success message is not found on the Period Payroll Release page within the timeout
    [Arguments]    ${payfile_name}
    ${release_button_locator}    Update Locator With Dynamic Values    ${PAYROLL_RELEASE_BUTTON_LOCATOR}    PAYFILE_NAME=${payfile_name}
    Wait Until Element Is Visible On Webpage    ${release_button_locator}
    ...    error_message=Release button for payfile '${payfile_name}' not found on Period Payroll Release page within timeout.
    Handle Future Dialogs    action=Accept
    Click Element On Webpage    ${release_button_locator}
    ...    error_message=Release button for payfile '${payfile_name}' not found on Period Payroll Release page within timeout.
    Wait Until Page Is Loaded
    ${pay_release_success_message}    Update Locator With Dynamic Values    ${PAYROLL_RELEASE_SUCCESS_MESSAGE}
    ...    PAYFILE_NAME=${payfile_name}
    Wait Until Element Is Visible On Webpage    ${pay_release_success_message}    timeout=${LONG_TIMEOUT}
    ...    error_message=Pay file release success message for '${payfile_name}' not found on Period Payroll Release page within timeout.

Check For Pay File Creation Status In Period Payroll Release Page On Web
    [Documentation]    Checks the status of the given payfile on Period Payroll Release Page on Web
    ...    by clicking refresh button at intervals until the expected status appears.
    ...    | =Arguments= | =Description= |
    ...    | ${payfile_name} | The name of the payfile to check status for |
    ...    | ${expected_status} | The expected status to wait for (e.g. File Created, Processing, Completed) |
    ...    | ${max_attempts} | (Optional) Maximum number of refresh attempts. Default: 10 |
    ...    | ${interval} | (Optional) Interval in seconds between refresh attempts. Default: 5 |
    ...    Example:
    ...    | Check For Pay File Creation Status In Period Payroll Release Page On Web    Payfile_2024-08-01_to_2024-08-07    File Created
    ...    | Check For Pay File Creation Status In Period Payroll Release Page On Web    Payfile_2024-08-01_to_2024-08-07    Completed    max_attempts=25    interval=150
    [Arguments]    ${payfile_name}    ${expected_status}    ${max_attempts}=25    ${interval}=150
    ${payfile_status_locator}    Update Locator With Dynamic Values    ${PAYROLL_RELEASE_STATUS}    PAYFILE_NAME=${payfile_name}
    ...    EXPECTED_STATUS=${expected_status}
    Wait Until Element Appears With Refresh On Web    ${payfile_status_locator}    ${PAYROLL_REFRESH_BUTTON}
    ...    max_attempts=${max_attempts}    interval=${interval}

Release Pay File For Specific Period On Period Payroll Release Page On Web
    [Documentation]    This keyword releases the pay file action for the selected week
    ...    | =Arguments= | =Description= |
    ...    | period_start_date | The start date of the semi-monthly period |
    ...    | period_end_date | The end date of the semi-monthly period |
    [Arguments]    ${period_start_date}    ${period_end_date}
    VAR    ${period}    ${period_start_date}-${period_end_date}

    ${release_action_link}    Update Locator With Dynamic Values    ${PERIOD_PAYROLL_RELEASE_PAGE_RELEASE_ACTION_FOR_PERIOD}
    ...    PERIOD=${period}

    ${has_data_loaded}    Check If Data Loaded For Pay File Action On Period Payroll Release Page On Web
    IF    not ${has_data_loaded}
        Skip    msg=Data did not load in time for Pay file action on Period Payroll Release page for the given week.
    END
    Wait Until Element Is Visible On Webpage    ${release_action_link}
    ...    error_message=Release action link not found on Period Payroll Release page for the given week within timeout.
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${release_action_link}    error_message=Release action link not clickable on Period Payroll Release page for the given week.
    Run Keyword And Ignore Error    Wait For    ${promise}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_NOTIFICATION}    timeout=${LONG_TIMEOUT}
    ${wait_spinner}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_SPINNER}
    IF    ${wait_spinner}
        Wait Until Element Disappears On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_SPINNER}    timeout=${LONG_TIMEOUT}
    END
    Sleep    ${SHORT_TIMEOUT}
    Wait For Load State    networkidle    timeout=${LONG_TIMEOUT}

Apply Filter For BiWeek On Period Payroll Release Page On Web
    [Documentation]    This keyword applies filter to get pay file status for bi-week on Period Payroll Release page
    ...    | =Arguments= | =Description= |
    ...    | week_start_date | Week start date to filter |
    [Arguments]    ${week_start_date}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${year_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${future_days}    Get Future Days    start_date_str=${week_start_date}    date_format=${date_format}    num_days=6
    ${week_end_date}    Get From List    ${future_days}    -1
    VAR    ${week_option}    ${week_start_date}-${week_end_date}
    # Get year from start date
    ${year}    Convert Date    ${week_start_date}    result_format=${year_format}    date_format=${date_format}
    ${filter_elements_visible}    Is Element Visible On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_YEAR_DROPDOWN}
    IF    not ${filter_elements_visible}
        Click Element On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_FILTER_BUTTON}
        ...    error_message=Filter icon not found on Period Payroll Release page to apply week filter.
    END
    Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_YEAR_DROPDOWN}    text    ${year}
    Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_QUARTER_DROPDOWN}    text    Show All
    Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_MONTH_DROPDOWN}    text    Show All
    Select List Item On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_WEEK_DROPDOWN}    text    ${week_option}
    Click Element On Webpage    ${PERIOD_PAYROLL_RELEASE_PAGE_FILTER_APPLY_BUTTON}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
