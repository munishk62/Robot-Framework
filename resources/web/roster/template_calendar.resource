*** Settings ***
Documentation       Keywords for Template Calendar Page - Work Pattern Management

Library             resources/web/common/utility.py
Library             test_data/TestDataLibrary.py
Variables           resources/web/common/menu_page.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/database.resource
Variables           resources/web/roster/template_calendar_page.py
Variables           resources/web/roster/template_calendar_api.py
Variables           resources/web/roster/template_calendar_db_queries.py
Variables           resources/web/common/status_codes.py
Resource            resources/web/common/common_date_utility.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/schedule/fixed_shifts.resource


*** Keywords ***
Navigate To Corp Template Calendar Page On Web
    [Documentation]    Navigate to RWS Schedule Fixed Shifts Template Calendar Page
    Navigate To CORP RWS Schedule Fixed Shifts Page On Web
    Wait Until Page Is Loaded
    Click Element On Webpage    ${FIXED_SHIFTS_DROPDOWN_ICON}
    Wait Until Element Is Visible On Webpage    ${TEMPLATE_CALENDAR_MENU_OPTION}
    # Use fallback approach as in legacy framework
    Click Element With Fallback On Web    ${TEMPLATE_CALENDAR_MENU_OPTION}    ${TEMPLATE_CALENDAR_MENU_OPTIONAL}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ADD_WORK_PATTERN_BUTTON}

Navigate To Template Calendar Page On Web
    [Documentation]    Navigate to RWS Schedule Fixed Shifts Template Calendar Page
    Navigate To Store RWS Schedule Fixed Shifts Page On Web
    Wait Until Page Is Loaded
    Click Element On Webpage    ${FIXED_SHIFTS_DROPDOWN_ICON}
    Wait Until Element Is Visible On Webpage    ${TEMPLATE_CALENDAR_MENU_OPTION}
    # Use fallback approach as in legacy framework
    Click Element With Fallback On Web    ${TEMPLATE_CALENDAR_MENU_OPTION}    ${TEMPLATE_CALENDAR_MENU_OPTIONAL}
    Wait Until Page Is Loaded

Create New Work Pattern On Web
    [Documentation]    Create a new work pattern with dynamic name generation - following payroll test pattern
    [Arguments]    ${work_pattern_name}
    Click Element On Webpage    ${ADD_WORK_PATTERN_BUTTON}
    Wait Until Element Is Visible On Webpage    ${WORK_PATTERN_NAME_INPUT}    timeout=${PAGE_LOAD_TIMEOUT}
    Fill Textbox On Webpage    ${WORK_PATTERN_NAME_INPUT}    ${work_pattern_name}
    Click Element On Webpage    ${WORK_PATTERN_CHECKBOX}
    Click Element On Webpage    ${WORK_PATTERN_CONFIRM_ADD_BUTTON}
    # Verify successful message (implied from legacy framework)
    Click Element On Webpage    ${WORK_PATTERN_CLOSE_BUTTON}

Get Existing Available Work Pattern Via DB
    [Documentation]    Get existing available work pattern name from database.
    ...    Queries RWS_SCHEDULE_TEMPLATE table to retrieve an active work pattern (template)
    ...    that was created by SYSADMIN. Uses OWNER_ID from config.json.
    ...
    ...    This keyword returns the oldest available work pattern based on LAST_UPDATE_TIME.
    ...    If no work pattern is found, returns 'NONE' instead of failing.
    ...
    ...    | =Returns= | =Description= |
    ...    | work_pattern_name | Name of the available work pattern/template, or 'NONE' if not found |
    ...
    ...    Example usage:
    ...    | ${pattern_name}=    Get Existing Available Work Pattern Via DB
    ...    | IF    '${pattern_name}' != 'NONE'
    ...    |    Log    Available work pattern: ${pattern_name}
    ...    | ELSE
    ...    |    Log    No work pattern found, skipping test steps
    ...    | END
    ${owner_id}=    Get Config Value    key=OWNER_ID
    ${db_query}=    Replace String    ${GET_AVAILABLE_WORK_PATTERN_NAME}    {owner_id}    ${owner_id}
    Log    Executing query to get available work pattern for owner_id: ${owner_id}
    ${result}=    Execute Query And Return Result    ${db_query}
    ${length}=    Get Length    ${result}
    IF    ${length} > 0
        ${first_row}=    Get From List    ${result}    0
        VAR    ${work_pattern_name}=    ${first_row}[0]
        Log    Found work pattern: ${work_pattern_name}
        RETURN    ${work_pattern_name}
    ELSE
        Log    No available work pattern found in database for owner_id: ${owner_id}    level=WARN
        RETURN    NONE
    END

Get Work Pattern By Week Via DB
    [Documentation]    Get work pattern (template) name available for a particular week from database.
    ...    Queries RWS_SCHEDULE_TEMPLATE table to retrieve the template assigned to a specific
    ...    week by matching WEEK_TYPE from RWS_CALENDAR_ATTR. Uses OWNER_ID from config.json.
    ...
    ...    This keyword looks up the work pattern based on the distribution list (store),
    ...    fiscal year, and week number. If no work pattern is found, returns 'NONE' instead of failing.
    ...
    ...    | =Arguments= | =Description= |
    ...    | dist_list_id | Store/distribution list identifier (e.g., 'STORE1'). |
    ...    | fiscal_year | Fiscal year for the calendar (e.g., '2026'). |
    ...    | week | Week number in the fiscal year (e.g., '17'). |
    ...
    ...    | =Returns= | =Description= |
    ...    | work_pattern_name | Name of the work pattern/template for the week, or 'NONE' if not found |
    ...
    ...    Example usage:
    ...    | ${pattern_name}=    Get Work Pattern By Week Via DB    STORE1    2026    17
    ...    | IF    '${pattern_name}' != 'NONE'
    ...    |    Log    Work pattern for week 17: ${pattern_name}
    ...    | ELSE
    ...    |    Log    No work pattern mapped for week 17
    ...    | END
    [Arguments]    ${dist_list_id}    ${fiscal_year}    ${week}
    ${owner_id}=    Get Config Value    key=OWNER_ID
    ${db_query}=    Replace String    ${GET_WORK_PATTERN_BY_WEEK}    {owner_id}    ${owner_id}
    ${db_query}=    Replace String    ${db_query}    {dist_list_id}    ${dist_list_id}
    ${db_query}=    Replace String    ${db_query}    {fiscal_year}    ${fiscal_year}
    ${db_query}=    Replace String    ${db_query}    {week}    ${week}
    Log    Executing query to get work pattern for store ${dist_list_id}, fiscal year ${fiscal_year}, week ${week}
    ${result}=    Execute Query And Return Result    ${db_query}
    ${length}=    Get Length    ${result}
    IF    ${length} > 0
        ${first_row}=    Get From List    ${result}    0
        VAR    ${work_pattern_name}=    ${first_row}[0]
        Log    Found work pattern for week ${week}: ${work_pattern_name}
        RETURN    ${work_pattern_name}
    ELSE
        Log    No work pattern found in database for store ${dist_list_id}, fiscal year ${fiscal_year}, week ${week}    level=WARN
        RETURN    NONE
    END

Select Store For Work Pattern Mapping On Web
    [Documentation]    Select store for work pattern mapping - following payroll test pattern
    [Arguments]    ${store_id}    ${planning_year}=None
    # Navigate back to template calendar page (refresh required as per legacy framework)
    Navigate To Template Calendar Page On Web
    Select Planning Year On Web    ${planning_year}
    Click Element On Webpage    ${SELECT_STORE_DROPDOWN}
    Fill Textbox On Webpage    ${STORE_SEARCH_INPUT}    ${store_id}
    ${store_option_locator}=    Update Locator With Dynamic Values    ${WORK_PATTERN_STORE_OPTION_LOCATOR}    STORE_ID=${store_id}
    Click Element On Webpage    ${store_option_locator}
    Click Element On Webpage    ${CONFIRM_STORE_SEARCH_BUTTON}
    Wait Until Page Is Loaded

Map Work Pattern To Store On Web
    [Documentation]    Map the created work pattern to the selected store - following payroll test pattern
    ...    Also If the work pattern is already mapped, it will skip the mapping and return False,
    ...    otherwise returns True after successful mapping.
    [Arguments]    ${planning_week_start_date}    ${work_pattern_name}
    ${actual_date}=    Convert Week Day Offset To Date On Web    ${planning_week_start_date}
    ${date_format}=    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${selected_date}=    Convert Date    ${actual_date}    result_format=${date_format}
    # Create XPath for the date element and click it
    ${date_xpath}=    Update Locator With Dynamic Values    ${DATE_XPATH_FOLLOWING_DIV_LOCATOR}    SELECTED_DATE=${selected_date}
    ${is_week_in_current_fiscal_year}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${date_xpath}
    IF    not ${is_week_in_current_fiscal_year}
        Select Planning Year On Web    ${planning_week_start_date}
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${date_xpath}
        ...    error_message=Week start date ${selected_date} is not visible on the page after selecting planning year
    END
    ${mapped_work_pattern}=    Get Element Text On Webpage    ${date_xpath}
    IF    '${mapped_work_pattern.strip()}' != '${work_pattern_name}'
        Click Element On Webpage    ${date_xpath}
        ...    error_message=Failed to click on the date element for mapping work pattern. Date: ${selected_date}
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${WORK_PATTERN_SEARCH_BOX}    timeout=${PAGE_LOAD_TIMEOUT}
        ...    error_message=Work pattern search box did not appear after clicking on the date element for mapping
        ${default_select_icon}=    Run Keyword And Return Status
        ...    Wait Until Element Is Present On Webpage    ${WORK_PATTERN_SELECTED_ICON}
        ...    error_message=Default selected work pattern icon did not appear in mapping popup
        IF    ${default_select_icon}
            Click Element On Webpage    ${WORK_PATTERN_SELECTED_ICON}
            ...    error_message=Failed to click on the default selected work pattern icon in the mapping popup
        END
        Fill Textbox On Webpage    ${WORK_PATTERN_SEARCH_BOX}    ${work_pattern_name}
        # Sleep    3s    # Added Sleep due to application performance to Allow search results to populate
        Wait Until Page Is Loaded    ${SHORT_TIMEOUT}
        ${work_pattern_select_locator}=    Update Locator With Dynamic Values
        ...    ${WORK_PATTERN_SELECT_BY_TITLE_LOCATOR}    WORK_PATTERN_NAME=${work_pattern_name}
        Wait Until Element Is Visible On Webpage    ${work_pattern_select_locator}
        ...    error_message=Work pattern option ${work_pattern_name} did not appear in search results for mapping
        Click Element On Webpage    ${work_pattern_select_locator}
        ...    error_message=Failed to click on the work pattern option ${work_pattern_name} for mapping
        Click Element On Webpage    ${APPLY_WORK_PATTERN_BUTTON}
        ...    error_message=Failed to click on Apply button for work pattern mapping
        Wait Until Element Is Visible On Webpage    ${SAVE_CHANGES_BUTTON}
        ...    error_message=Save Changes button did not appear after applying work pattern mapping
        Click Element On Webpage    ${SAVE_CHANGES_BUTTON}
        ...    error_message=Failed to click on Save Changes button after applying work pattern mapping
        Wait Until Page Is Loaded
        RETURN    ${True}
    ELSE
        RETURN    ${False}
    END

Verify Work Pattern Mapping Success On Web
    [Documentation]    Verify that the work pattern mapping was successful
    Wait Until Element Is Visible On Webpage    ${SUCCESS_NOTIFICATION_MESSAGE}
    Wait Until Element Is Present On Webpage    ${SUCCESS_NOTIFICATION_MESSAGE}
    Log    Work pattern mapping completed successfully

Select Planning Year On Web
    [Documentation]    Select the planning year - if planning_year argument provided, calculates year from it,
    ...    otherwise gets current planning year from the web page.
    ...
    ...    | =Arguments= | =Description= |
    ...    | planning_year | Optional week_day offset (e.g., '4_0') to calculate year from. Default: None |
    ...
    ...    Example:
    ...    | Select Planning Year On Web    # Uses current year from webpage
    ...    | Select Planning Year On Web    planning_year=4_0    # Calculates year from week 4
    [Arguments]    ${planning_year}=None

    # Check if planning_year argument was provided
    IF    '${planning_year}' != 'None'
        # Calculate year from the provided week offset
        ${year_date}=    Calculate Date From Week Day Offset    ${planning_year}
        ${year_date_format}=    Get Config Value    DATE_FORMAT_YEAR_ONLY
        ${current_planning_year}=    Convert Date    ${year_date}    result_format=${year_date_format}
        Log    Calculated planning year from offset ${planning_year}: ${current_planning_year}    level=DEBUG
    ELSE
        # Get current planning year from the webpage
        ${current_planning_year}=    Get Current Planning Year On Web
        Log    Using current planning year from webpage: ${current_planning_year}    level=DEBUG
    END

    # Select the year from dropdown
    Click Element On Webpage    ${SELECTED_YEAR_DROPDOWN}
    ${year_option_locator}=    Update Locator With Dynamic Values    ${YEAR_OPTION_DROPDOWN_LOCATOR}
    ...    CURRENT_PLANNING_YEAR=${current_planning_year}
    Click Element On Webpage    ${year_option_locator}
    # Sleep    3s    # Added Sleep due to application performance to Allow year selection to process
    Wait Until Page Is Loaded

Select Planning Week Elements On Web
    [Documentation]    Select planning week elements based on the provided date - updated for current framework
    [Arguments]    ${planning_week_start_date}
    # Convert week_day format to actual date using current framework function
    ${actual_date}=    Convert Week Day Offset To Date On Web    ${planning_week_start_date}
    ${date_format}=    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${selected_date}=    Convert Date    ${actual_date}    result_format=${date_format}
    # Create XPath for the date element and click it
    ${date_xpath}=    Update Locator With Dynamic Values    ${DATE_XPATH_FOLLOWING_DIV_LOCATOR}    SELECTED_DATE=${selected_date}
    Click Element On Webpage    ${date_xpath}

Check And Map Work Pattern On Planning Week On Web
    [Documentation]    Select planning week elements based on the provided date - updated for current framework
    ...    This keyword checks if work pattern is mapped for the current week, and if not,
    ...    maps the work pattern to the store for the current week.
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | planning_week_start_date    | Week offset format (e.g., 4_0) for planning week start    |
    ...    | work_pattern_data    | Work pattern data dictionary with pattern details    |
    ...
    ...    Example usage:
    ...    | Check And Map Work Pattern On Planning Week On Web | 4_0 | ${work_pattern} |
    [Arguments]    ${planning_week_start_date}    ${work_pattern_data}
    Navigate To Template Calendar Page On Web
    Select Planning Year On Web    ${planning_week_start_date}
    Map Work Pattern To Store On Web    ${planning_week_start_date}    ${work_pattern_data}
    Verify Work Pattern Mapping Success On Web

    VAR    ${current_week_start_date}=    0_0
    # Convert to date only for display/locator purposes
    ${actual_date}=    Convert Week Day Offset To Date On Web    ${current_week_start_date}
    ${date_format}=    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${selected_date}=    Convert Date    ${actual_date}    result_format=${date_format}
    ${date_xpath}=    Update Locator With Dynamic Values    ${WORK_PATTERN_MAPPED}    SELECTED_DATE=${selected_date}
    ${mapped_locator_present}=    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${date_xpath}
    IF    not ${mapped_locator_present}
        Select Planning Year On Web    ${current_week_start_date}
        ${wp_mapped_locator_status}=    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${date_xpath}
        IF    ${wp_mapped_locator_status}
            ${work_pattern_mapped_status}=    Get Element Text On Webpage    ${date_xpath}
            IF    '${work_pattern_mapped_status}' == 'Not Mapped Yet'
                Map Work Pattern To Store On Web    ${current_week_start_date}    ${work_pattern_data}
                Verify Work Pattern Mapping Success On Web
            ELSE
                Log    Work pattern already mapped with previous week: ${work_pattern_mapped_status}
            END
        END
    ELSE
        ${work_pattern_mapped_status}=    Get Element Text On Webpage    ${date_xpath}
        IF    '${work_pattern_mapped_status}' == 'Not Mapped Yet'
            Map Work Pattern To Store On Web    ${current_week_start_date}    ${work_pattern_data}
            Verify Work Pattern Mapping Success On Web
        ELSE
            Log    Work pattern already mapped with previous week: ${work_pattern_mapped_status}
        END
    END

Convert Week Day Offset To Date On Web
    [Documentation]    Convert week day offset (e.g., 1_0) to actual date format (YYYY-MM-DD) using current framework
    ...    Example: 1_0 -> 2024-06-02 (if current week starts on 2024-06-02)
    [Arguments]    ${week_day_offset}
    # Check if it's already in date format
    ${is_date_format}=    Run Keyword And Return Status    Should Match Regexp    ${week_day_offset}    \\d{4}-\\d{2}-\\d{2}
    IF    ${is_date_format}    RETURN    ${week_day_offset}

    # Convert 1_0 format to actual date using TestDataLibrary function
    TRY
        ${actual_date}=    Calculate Date From Week Day Offset    ${week_day_offset}
        RETURN    ${actual_date}
    EXCEPT
        # Fallback to current date if conversion fails
        ${date_format}=    Get Config Value    DATE_FMT_YEAR_MONTH_DAY
        ${current_date}=    Get Current Date    result_format=${date_format}
        RETURN    ${current_date}
    END

Remove Work Pattern From Planning Week On Associate Template Page On Web
    [Documentation]    Remove Work Pattern From Planning Week On Associate Template Page
    [Arguments]    ${week_start_date}    ${work_pattern_name}
    ${week_date}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${date_format}=    Get Config Value    DATE_FMT_WEEKDAY_MONTH_DAY_YEAR
    ${formatted_date}=    Convert Date    ${week_date}    result_format=${date_format}
    ${mapped_to}=    Update Locator With Dynamic Values    ${WORK_PATTERN_MAPPED_TO}    WORK_PATTERN_NAME=${work_pattern_name}
    ...    FORMATTED_DATE=${formatted_date}
    Click Element On Webpage    ${mapped_to}
    Click Element On Webpage    ${TEMPLATE_CALENDAR_DELETE_BUTTON}
    ${promise}=    Promise To    Wait For Response    ${UNMAP_WORK_PATTERN_TEMPLATE_CALENDAR_SUCCESSFUL_API_REGEX}
    Click Element On Webpage    ${SAVE_CHANGES_BUTTON}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Unmap Work Pattern From Planning Week And Verify Api Success On Web
    [Documentation]    Unmap Work Pattern From Planning Week On Template Calendar Page
    [Arguments]    ${corp_user_key}    ${week_start_date}    ${work_pattern_name}    ${store_id}
    Login And Launch WFM Web App    user_key=${corp_user_key}
    Select Store For Work Pattern Mapping On Web    ${store_id}
    Remove Work Pattern From Planning Week On Associate Template Page On Web    ${week_start_date}    ${work_pattern_name}

Delete Work Pattern And Verify API Success On Web
    [Documentation]    Delete Work Pattern And Verify Via API
    [Arguments]    ${corp_user_key}    ${work_pattern_name}
    Login And Launch WFM Web App    user_key=${corp_user_key}
    Navigate To Template Calendar Page On Web
    Click Element On Webpage    ${ADD_WORK_PATTERN_BUTTON}
    ${work_pattern_select_locator}=    Update Locator With Dynamic Values    ${WORK_PATTERN_DELETE_BY_ARIA_LABEL_LOCATOR}
    ...    WORK_PATTERN_NAME=${work_pattern_name}
    Wait Until Element Is Visible On Webpage    ${work_pattern_select_locator}
    ${promise}=    Promise To    Wait For Response    ${DELETE_WORK_PATTERN}
    Click Element On Webpage    ${work_pattern_select_locator}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Select Corp Store For Work Pattern Mapping On Web
    [Documentation]    Select store for work pattern mapping - following payroll test pattern
    [Arguments]    ${store_id}    ${planning_year}=None
    # Navigate back to template calendar page (refresh required as per legacy framework)
    Navigate To Corp Template Calendar Page On Web
    Select Planning Year On Web    ${planning_year}
    Click Element On Webpage    ${SELECT_STORE_DROPDOWN}
    Fill Textbox On Webpage    ${STORE_SEARCH_INPUT}    ${store_id}
    ${store_option_locator}=    Update Locator With Dynamic Values    ${WORK_PATTERN_STORE_OPTION_LOCATOR}    STORE_ID=${store_id}
    Click Element On Webpage    ${store_option_locator}
    Click Element On Webpage    ${CONFIRM_STORE_SEARCH_BUTTON}
    Wait Until Page Is Loaded

Check And Delete Mapped Work Pattern For Week On Template Calendar Page On Web
    [Documentation]
    ...    Navigates to the Template Calendar page, selects the store, and checks whether
    ...    a work pattern is already mapped for the given planning week.
    ...    If a mapping exists (i.e. the week does not show "Not Mapped Yet"), the mapped
    ...    work pattern is removed so the week is left in an unmapped state.
    ...    Use this keyword in teardown for test cases that validate schedule-via-template
    ...    failure when work pattern is NOT mapped, to ensure a clean state for the next run.
    ...
    ...    | =Arguments= | =Description= |
    ...    | week_start_date | Week offset string (e.g., "8_0") identifying the planning week to check. |
    ...
    ...    Example usage:
    ...    | [Teardown]    Run Keywords
    ...    | ...    Login And Launch WFM Web App    user_key=SYSADMIN    AND
    ...    | ...    Check And Delete Mapped Work Pattern For Week On Template Calendar Page On Web    8_0    AND
    ...    | ...    Close Browser
    [Arguments]    ${week_start_date}
    ${store_data}=    Get Store Data
    Select Corp Store For Work Pattern Mapping On Web    store_id=${store_data}[store_id]    planning_year=${week_start_date}
    # Resolve the week start date to a formatted date string for locating the element on the calendar
    ${actual_date}=    Convert Week Day Offset To Date On Web    ${week_start_date}
    ${date_format}=    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${selected_date}=    Convert Date    ${actual_date}    result_format=${date_format}
    # Check if a work pattern is mapped for this week
    ${mapped_locator}=    Update Locator With Dynamic Values    ${WORK_PATTERN_MAPPED}    SELECTED_DATE=${selected_date}
    ${is_element_present}=    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${mapped_locator}
    IF    not ${is_element_present}
        # Week may be in a different fiscal year; try selecting the year explicitly
        Select Planning Year On Web    ${week_start_date}
        ${is_element_present}=    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${mapped_locator}
    END
    IF    ${is_element_present}
        ${mapped_work_pattern}=    Get Element Text On Webpage    ${mapped_locator}
        ${mapped_work_pattern}=    Strip String    ${mapped_work_pattern}
        IF    '${mapped_work_pattern}' != 'Not Mapped Yet' and '${mapped_work_pattern}' != ''
            Log    Work pattern '${mapped_work_pattern}' is mapped for week ${week_start_date}. Removing it.    level=INFO
            Remove Work Pattern From Planning Week On Associate Template Page On Web
            ...    ${week_start_date}    ${mapped_work_pattern}
            Log    Successfully removed work pattern mapping for week ${week_start_date}.    level=INFO
        ELSE
            Log    No work pattern mapped for week ${week_start_date}. Nothing to remove.    level=INFO
        END
    ELSE
        Log    Could not locate the mapping element for week ${week_start_date} on the Template Calendar page.    level=WARN
    END

Login As Sysadmin And Clean Work Pattern Mapping For Week On Web
    [Documentation]
    ...    Logs in to the WFM application as SYSADMIN, navigates to the Template Calendar page,
    ...    and removes any existing work pattern mapping for the specified planning week.
    ...    Closes the browser on completion. Safe to call when no mapping exists.
    ...
    ...    Designed to be used as both a *[Setup]* and *[Teardown]* step for test cases that
    ...    require the planning week to be in an unmapped state (e.g. tests that validate
    ...    schedule-via-template failure when no work pattern is mapped).
    ...
    ...    | =Arguments= | =Description= |
    ...    | week_start_date | Week offset string (e.g., "8_0") or YYYY-MM-DD date identifying the planning week to clean. |
    ...
    ...    Example usage (setup and teardown):
    ...    | [Setup]    Login As Sysadmin And Clean Work Pattern Mapping For Week On Web    8_0
    ...    | [Teardown]    Login As Sysadmin And Clean Work Pattern Mapping For Week On Web    8_0
    ...
    ...    Or inside a Run Keywords block:
    ...    | [Teardown]    Run Keywords
    ...    | ...    Login As Sysadmin And Clean Work Pattern Mapping For Week On Web    8_0    AND
    ...    | ...    Close Browser
    [Arguments]    ${week_start_date}
    Login And Launch WFM Web App    user_key=SYSADMIN
    Check And Delete Mapped Work Pattern For Week On Template Calendar Page On Web    ${week_start_date}
    Close Browser
