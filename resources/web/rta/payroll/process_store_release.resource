*** Settings ***
Documentation       Process Store Release page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/payroll/process_store_release_page.py
Variables           resources/web/rta/payroll/process_store_release_api.py
Variables           resources/web/common/status_codes.py
Resource            resources/web/common/util_keywords.resource
Library             OperatingSystem


*** Keywords ***
Navigate To RTA Payroll Process Store Release Page On Web
    [Documentation]    Navigate To RTA -> Payroll -> Process Store Release Page
    ...    and verifies Process Store Release heading at the top of the page
    Navigate To Specific Page On Web    rta    payroll    process_store_release

Click Action Dropdown On Process Store Release Page On Web
    [Documentation]    This keyword clicks on Action dropdown on Process Store Release page
    Wait Until Element Is Visible On Webpage    ${PROCESS_STORE_RELEASE_PAGE_ACTION_DROPDOWN}
    ...    error_message=Action dropdown is not visible on Process Store Release page
    Click Element On Webpage    ${PROCESS_STORE_RELEASE_PAGE_ACTION_DROPDOWN}
    ...    error_message=Failed to click on Action dropdown on Process Store Release page

Release Store For Payfile Generation On Process Store Release Page On Web
    [Documentation]    This keyword releases the store for payfile generation with API validation
    ...    Returns API response object for further verification
    ...    | =Returns= | =Description= |
    ...    | response_body | API response object containing status and response data |
    ...    Example Usage:
    ...    | ${response}=    Release Store For Payfile Generation On Process Store Release Page On Web |
    ...    | Should Be Equal As Strings    ${response.status}    200 |
    Click Action Dropdown On Process Store Release Page On Web
    Wait Until Element Is Visible On Webpage    ${PROCESS_STORE_RELEASE_PAGE_RELEASE_OPTION}
    ...    error_message=Release option is not visible in the Action dropdown on Process Store Release page
    Click Element On Webpage    ${PROCESS_STORE_RELEASE_PAGE_RELEASE_OPTION}
    ...    error_message=Failed to click on Release option in the Action dropdown on Process Store Release page
    ${promise}    Promise To    Wait For Response    ${RELEASE_STORE_API_REGEX}
    ${response_body}    Wait For    ${promise}
    Log    API Response Status: ${response_body.status}    INFO
    Log    API Response Body: ${response_body.body}    INFO
    Should Be True    ${response_body.status} in [${HTTP_STATUS_CODES}[OK], ${HTTP_STATUS_CODES}[CREATED]]
    ...    msg=Release action failed: Expected status 200 or 201 but got ${response_body.status}. Response: ${response_body.body}

Reopen Store After Payfile Generation On Process Store Release Page On Web
    [Documentation]    This keyword reopens the store after payfile generation with API validation
    ...    Returns API response object for further verification
    ...    | =Returns= | =Description= |
    ...    | response_body | API response object containing status and response data |
    ...    Example Usage:
    ...    | ${response}=    Reopen Store After Payfile Generation On Process Store Release Page On Web |
    ...    | Should Be Equal As Strings    ${response.status}    200 |
    Click Action Dropdown On Process Store Release Page On Web
    Wait Until Element Is Visible On Webpage    ${PROCESS_STORE_RELEASE_PAGE_REOPEN_OPTION}
    ...    error_message=Reopen option is not visible in the Action dropdown on Process Store Release page
    Click Element On Webpage    ${PROCESS_STORE_RELEASE_PAGE_REOPEN_OPTION}
    ...    error_message=Failed to click on Reopen option in the Action dropdown on Process Store Release page
    ${promise}    Promise To    Wait For Response    ${REOPEN_STORE_API_REGEX}
    ${response_body}    Wait For    ${promise}
    Log    API Response Status: ${response_body.status}    INFO
    Log    API Response Body: ${response_body.body}    INFO
    Should Be True    ${response_body.status} in [${HTTP_STATUS_CODES}[OK], ${HTTP_STATUS_CODES}[CREATED]]
    ...    msg=Reopen action failed: Expected status 200 or 201 but got ${response_body.status}. Response: ${response_body.body}

Navigate To Planning Week From Calendar On Process Store Release Page On Web
    [Documentation]    This keyword navigates to the specified planning week from the calendar on the Process Store Release
    ...    | =Arguments= | =Description= |
    ...    | ${week_day_input} | The start date of the week to navigate to (format: mm/dd/yyyy) |
    ...    Example Usage:
    ...    | Navigate To Planning Week From Calendar On Process Store Release Page On Web    09/01/2023 |
    [Arguments]    ${week_day_input}
    ${target_date}    Calculate Date From Week Day Offset    ${week_day_input}
    ${week_label_date_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${week_label_date}    Calculate Week Start Date From Week Day Offset    ${week_day_input}    date_format=${week_label_date_format}
    ${date_format_year_only}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${date_format_month_only}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${date_format}    Get Config Value    DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA
    ${target_year}    Convert Date    ${target_date}    result_format=${date_format_year_only}
    ${target_month_name}    Convert Date    ${target_date}    result_format=${date_format_month_only}
    ${target_day_formatted}    Convert Date    ${target_date}    result_format=${date_format}
    ${year_last_2_digits}    Evaluate    str('${target_year}')[2:]
    Wait Until Page Is Loaded
    # Use dynamic locator templates instead of hardcoded XPath
    Click Element On Webpage    ${PROCESS_STORE_RELEASE_PAGE_CURRENT_WEEK_BUTTON}
    ...    error_message=Failed to click on current week button on Process Store Release page
    Click Element On Webpage    ${PROCESS_STORE_RELEASE_PAGE_CALENDAR_MONTH_YEAR_HEADER}
    ...    error_message=Failed to click on calendar month/year header on Process Store Release page

    ${year_button_locator}    Update Locator With Dynamic Values    ${PROCESS_STORE_RELEASE_PAGE_YEAR_BUTTON_BY_YEAR}
    ...    TARGET_YEAR=${target_year}
    ${is_element_present}    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${year_button_locator}
    IF    ${is_element_present}
        Click Element On Webpage    ${year_button_locator}
        ...    error_message=Failed to click on year button '${target_year}' on Process Store Release page calendar
    ELSE
        Click Element On Webpage    ${PROCESS_STORE_RELEASE_PAGE_YEAR_BUTTON_DYNAMIC_BY_YEAR}
        ...    error_message=Failed to click on dynamic year button on Process Store Release page calendar
    END
    ${year_digits_locator}    Update Locator With Dynamic Values    ${PROCESS_STORE_RELEASE_PAGE_YEAR_DIGITS_BY_LAST_TWO}
    ...    YEAR_LAST_2_DIGITS=${year_last_2_digits}
    Click Element On Webpage    ${year_digits_locator}
    ...    error_message=Failed to click on year digits '${year_last_2_digits}' on Process Store Release page calendar
    ${month_locator}    Update Locator With Dynamic Values    ${PROCESS_STORE_RELEASE_PAGE_MONTH_BUTTON_BY_NAME}
    ...    MONTH_NAME=${target_month_name}

    Click Element On Webpage    ${month_locator}
    ...    error_message=Failed to click on month '${target_month_name}' on Process Store Release page calendar
    ${day_locator}    Update Locator With Dynamic Values    ${PROCESS_STORE_RELEASE_PAGE_DAY_BUTTON_BY_FORMATTED_DATE}
    ...    FORMATTED_DATE=${target_day_formatted}
    Wait Until Element Is Visible On Webpage    ${day_locator}
    ...    error_message=Day button for date '${target_day_formatted}' is not visible in the calendar
    ${week_number_locator}    Update Locator With Dynamic Values    ${PROCESS_STORE_RELEASE_PAGE_WEEK_NUMBER_BUTTON}
    ...    DAY_LOCATOR=${day_locator}

    Click Element On Webpage    ${week_number_locator}
    ...    error_message=Failed to click on week number button for the selected date on Process Store Release page calendar
    Wait Until Element Disappears On Webpage    ${PROCESS_STORE_RELEASE_PAGE_CALENDAR_POP_UP}
    ${week_label_locator}    Update Locator With Dynamic Values    ${PROCESS_STORE_RELEASE_PAGE_HEADER_WEEK_LABEL}
    ...    WEEK=${week_label_date}

    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${week_label_locator}    timeout=${LONG_TIMEOUT}
    ...    error_message=Week label '${week_label_date}' is not visible on the Process Store Release page after navigation
    Capture Screenshot On Webpage

Click On Process Store Release Button On Process Store Release Page On Web
    [Documentation]
    ...    Clicks on the "Process Store Release" button to open the process form.
    ...    Example usage:
    ...    | Click On Process Store Release Button On Process Store Release Page On Web
    ${associates_count}    Get Element Count On Webpage    ${PROCESS_STORE_RELEASE_PAGE_ASSOCIATE_ICONS}
    IF    ${associates_count} > 0
        Click Element On Webpage    (${PROCESS_STORE_RELEASE_PAGE_ASSOCIATE_ICONS})[1]
        Wait Until Page Is Loaded
        Capture Screenshot On Webpage
    ELSE
        Skip    No clickable associate icons were found on the Process Store Release page, so the Add Process Store Release flow cannot be opened.
    END
