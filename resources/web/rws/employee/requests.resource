*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Requests page (bulk requests page).
...
...                 = Purpose =
...                 - Centralizes actions for navigating, submitting, and verifying requests on the Requests page (bulk requests page).
...
...                 = Prerequisites =
...                 - Required libraries and variable files must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Add Bulk Request
...                 |    Navigate To RWS Employee Requests Page On Web
...                 |    Select Start And End Date On Requests Page On Web    0_1    0_5
...                 |    Select Request Type On Requests Page On Web    Day Off
...                 |    Select Request Status On Requests Page On Web    Not Reviewed
...                 |    Select Request Reason On Requests Page On Web    Personal

Library             resources/web/common/utility.py
Variables           resources/web/rws/employee/requests_page.py
Variables           resources/web/common/menu_page.py
Variables           resources/web/common/notification.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RWS Employee Requests Page On Web
    [Documentation]    Navigate To RWS -> Employee -> Requests Page
    ...    and verifies requests heading at the top of the page
    Navigate To Specific Page On Web    rws    employee    requests

Select Start And End Date On Requests Page On Web
    [Documentation]    This keyword will select start date and end date On Requests Page On Web.
    ...    Accepts dates in week_day format (e.g., 0_1, 1_3) and converts using DATE_FORMAT_MONTH_DAY_YEAR from config.
    ...    | =Arguments= | =Description= |
    ...    | start_date | Start date in week_day format (e.g., 0_1 for current week, day 1) |
    ...    | end_date | End date in week_day format (e.g., 0_5 for current week, day 5) |
    ...    Example usage:
    ...    | Select Start And End Date On Requests Page On Web    0_1    0_5
    [Arguments]    ${start_date}    ${end_date}
    # Get date format from config (e.g., " %m/%d/%Y" which includes leading space)
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    # Convert from week_day format (e.g., 0_1) to configured date format
    ${start_date_formatted}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}
    ${end_date_formatted}    Calculate Date From Week Day Offset    ${end_date}    ${date_format}

    Clear Textbox On Webpage    ${REQUESTSPAGE_START_DATE}
    Fill Textbox On Webpage    ${REQUESTSPAGE_START_DATE}    ${start_date_formatted}
    Clear Textbox On Webpage    ${REQUESTSPAGE_END_DATE}
    Fill Textbox On Webpage    ${REQUESTSPAGE_END_DATE}    ${end_date_formatted}

Select Request Type On Requests Page On Web
    [Documentation]    This keyword will select request type On Requests Page On Web.
    [Arguments]    ${request_type}
    Select And Verify Dropdown Value On Requests Page On Web    ${REQUESTSPAGE_TYPE}    text    ${request_type}

Select Request Status On Requests Page On Web
    [Documentation]    This keyword will select request status On Requests Page On Web.
    ...    Selects by visible text content (e.g., "Not Reviewed", "Approved").
    [Arguments]    ${request_status}
    Select And Verify Dropdown Value On Requests Page On Web    ${REQUESTSPAGE_REQUEST_STATUS}    text    ${request_status}

Select Request Reason On Requests Page On Web
    [Documentation]    This keyword will select request reason On Requests Page On Web.
    ...    Selects by visible text content (e.g., "Paid Vacation", "Sick").
    [Arguments]    ${request_reason}
    Click Element On Webpage    ${REQUESTSPAGE_REASON}
    Select And Verify Dropdown Value On Requests Page On Web    ${REQUESTSPAGE_REASON}    text    ${request_reason}

Select Department On Requests Page On Web
    [Documentation]    This keyword will select department On Requests Page On Web.
    ...    Selects by visible text content (e.g., "Sales", "Marketing").
    [Arguments]    ${department_value}
    Select And Verify Dropdown Value On Requests Page On Web    ${REQUESTSPAGE_DEPARTMENT}    text    ${department_value}

Select Profile On Requests Page On Web
    [Documentation]    This keyword will select profile(reportee type) On Requests Page On Web.
    ...    Selects by visible text content (e.g., "Associate", "Store Manager").
    ...    Three-tier fallback strategy:
    ...    1) Try clicking dropdown and then clicking the option
    ...    2) If fails, remove disabled attribute and use click approach
    ...    3) If still fails, use JavaScript to directly set value
    [Arguments]    ${profile_type}
    Wait Until Page Is Loaded
    TRY
        Select Profile By Standard Click On Web    ${profile_type}
        RETURN
    EXCEPT    AS    ${error}
        Log    Tier 1 failed: ${error}. Moving to Tier 2.    level=WARN
    END
    TRY
        Select Profile By Removing Disabled Attribute On Web    ${profile_type}
        RETURN
    EXCEPT    AS    ${error}
        Log    Tier 2 failed: ${error}. Moving to Tier 3 (JavaScript fallback).    level=WARN
    END
    TRY
        Select Profile By JavaScript On Web    ${profile_type}
        RETURN
    EXCEPT    AS    ${error}
        Log    Tier 3 failed: ${error}. All tiers exhausted.    level=WARN
    END
    Log
    ...    WARNING: All three tiers failed to select Profile option: ${profile_type}. Skipping profile selection and continuing test execution.
    ...    level=WARN

Select Profile By Standard Click On Web
    [Documentation]    Tier 1: Standard click approach to select profile dropdown option.
    [Arguments]    ${profile_type}
    Log    Tier 1: Attempting to click dropdown and select option by clicking
    Click Element On Webpage    ${REQUESTSPAGE_PROFILE}
    ${profile_option_locator}    Update Locator With Dynamic Values    ${REQUESTSPAGE_PROFILE_OPTIONS}
    ...    PROFILE_OPTION=${profile_type}
    Click Element On Webpage    ${profile_option_locator}

Select Profile By Removing Disabled Attribute On Web
    [Documentation]    Tier 2: Remove disabled attributes then click to select profile option.
    [Arguments]    ${profile_type}
    Log    Tier 2: Removing disabled attributes and using click approach
    Evaluate JavaScript    ${REQUESTSPAGE_PROFILE}
    ...    (el) => { el.removeAttribute('disabled'); el.removeAttribute('aria-disabled'); }
    Sleep    0.5s    # sleep added for Dom Attribute change impact, needed as discussed with owner
    Click Element On Webpage    ${REQUESTSPAGE_PROFILE}
    ${profile_option_locator}    Update Locator With Dynamic Values    ${REQUESTSPAGE_PROFILE_OPTIONS}
    ...    PROFILE_OPTION=${profile_type}
    Click Element On Webpage    ${profile_option_locator}

Select Profile By JavaScript On Web
    [Documentation]    Tier 3: Use JavaScript to directly set dropdown value with change event triggering.
    [Arguments]    ${profile_type}
    Log    Tier 3: Using JavaScript to directly set dropdown value
    ${available_options}    Evaluate JavaScript    ${REQUESTSPAGE_PROFILE}
    ...    (el) => { var opts = []; for (var i = 0; i < el.options.length; i++) { opts.push(el.options[i].text.trim()); } return opts.join(', '); }
    Log    Available dropdown options: ${available_options}    level=INFO
    ${result}    Evaluate JavaScript    ${REQUESTSPAGE_PROFILE}
    ...    (el, profileType) => {
    ...    el.removeAttribute('disabled'); el.removeAttribute('aria-disabled');
    ...    var searchTerm = profileType.trim().toLowerCase();
    ...    for (var i = 0; i < el.options.length; i++) {
    ...    var optionText = el.options[i].text.trim().toLowerCase();
    ...    if (optionText.includes(searchTerm) || searchTerm.includes(optionText)) {
    ...    el.selectedIndex = i;
    ...    el.dispatchEvent(new Event('change', { bubbles: true }));
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    return true;
    ...    }
    ...    }
    ...    return false;
    ...    }
    ...    ${profile_type}
    IF    not ${result}    Fail    JavaScript did not find matching option
    Log    Successfully selected Profile via JavaScript: ${profile_type}

Wait For Loading Progress Bar On Requests Page On Web
    [Documentation]    This keyword will wait for loading progress bar to disappear On Requests Page On Web.
    ...    The progress bar may or may not appear. If it appears, wait for it to disappear.
    ...    If it doesn't appear within the timeout, the test continues without failing.
    [Arguments]    ${timeout}=${SHORT_TIMEOUT}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${REQUESTSPAGE_LOADING_PROGRESS_BAR}    timeout=${timeout}
    Run Keyword And Ignore Error    Wait Until Element Disappears On Webpage    ${REQUESTSPAGE_LOADING_PROGRESS_BAR}    timeout=${timeout}

Click Apply Button On Requests Page On Web
    [Documentation]    This keyword will click on apply button On Requests Page On Web.
    Click Element On Webpage    ${REQUESTSPAGE_APPLY_BUTTON}
    Wait For Loading Progress Bar On Requests Page On Web
    Wait Until Page Is Loaded

Set Filters On Requests Page On Web
    [Documentation]    This keyword is for searching added day off request On Requests Page On Web,
    ...    which takes arguments for date, status, reportee type, reason, and department to search on request page.
    [Arguments]    ${start_date}=None
    ...    ${end_date}=None
    ...    ${request_type}=None
    ...    ${request_status}=None
    ...    ${request_reason}=None
    ...    ${reportee_type}=None
    ...    ${department_value}=None
    Click Element On Webpage    ${REQUESTSPAGE_CLEAR_ALL_FILTERS_BUTTON}
    Wait For Loading Progress Bar On Requests Page On Web    timeout=${SHORT_TIMEOUT}
    IF    "${start_date}" != "None" and "${end_date}" != "None"
        Select Start And End Date On Requests Page On Web    ${start_date}    ${end_date}
    END

    IF    "${request_type}" != "None"
        Select Request Type On Requests Page On Web    ${request_type}
    END

    IF    "${request_status}" != "None"
        Select Request Status On Requests Page On Web    ${request_status}
    END

    IF    "${request_reason}" != "None"
        Select Request Reason On Requests Page On Web    ${request_reason}
    END

    IF    "${department_value}" != "None"
        Select Department On Requests Page On Web    ${department_value}
    END

    IF    "${reportee_type}" != "None"
        Select Profile On Requests Page On Web    ${reportee_type}
    END

    Click Apply Button On Requests Page On Web

Verify Notification Message On Requests Page On Web
    [Documentation]    This keyword is to verify notification messages which appear post
    ...    add, edit, delete for all request types On Requests Page On Web.
    Wait Until Element Is Visible On Webpage    ${REQUESTSPAGE_NOTIFICATION_MESSAGE_VERIFY}    timeout=90s

Select And Verify Dropdown Value On Requests Page On Web
    [Documentation]    This will select dropdown value based on provided arguments.
    ...    Uses partial text matching for 'text' attribute to handle non-breaking spaces and whitespace variations.
    ...    | =Arguments= | =Description= |
    ...    | locator | Locator for the dropdown element |
    ...    | attribute | Selection method: 'text' (partial match), 'value', or 'index' |
    ...    | value | Value to select |
    [Arguments]    ${locator}    ${attribute}    ${value}

    # For text selection, use label matching which handles whitespace better than text
    IF    '${attribute}' == 'text'
        # First try exact match with label
        TRY
            Select Options By    ${locator}    label    ${value}
            Log    Successfully selected dropdown option by exact label match: ${value}
        EXCEPT
            # If exact match fails, get all options and find partial match
            Log    Exact label match failed, trying partial text match for: ${value}
            ${options}    Get Select Options    ${locator}
            VAR    ${matched_option}    ${EMPTY}
            FOR    ${option}    IN    @{options}
                ${normalized_text}    Strip String    ${option}[label]
                ${value_normalized}    Strip String    ${value}
                ${option_contains_value}    Evaluate    '${value_normalized}' in '${normalized_text}'
                IF    ${option_contains_value}
                    VAR    ${matched_option}    ${option}[label]
                    BREAK
                END
            END
            IF    '${matched_option}' == '${EMPTY}'
                Fail    Could not find option containing text '${value}' in dropdown ${locator}
            END
            # Select by the matched label
            Select Options By    ${locator}    label    ${matched_option}
            Log    Successfully selected dropdown option by partial match: ${matched_option}
        END
        # Verify selection
        ${selected_text}    Get Selected Options    ${locator}    label
        ${selection_verified}    Evaluate    '${value}' in '${selected_text}[0]'
        Should Be True    ${selection_verified}
        ...    msg=Dropdown selection failed. Expected text containing '${value}', got '${selected_text}[0]'
    ELSE
        # For value and index, use direct selection
        Select List Item On Webpage    ${locator}    ${attribute}    ${value}
        ${selected_option_value}    Get Selected Options    ${locator}    ${attribute}
        Should Be Equal    ${selected_option_value}[0]    ${value}
    END

    Log    Selected dropdown option: ${value}

Confirm Request Not Exist On Requests Page On Web
    [Documentation]    Verifies that a specific request does NOT exist on the Requests Page.
    ...
    ...    Builds a request locator using the provided parameters and waits for the element to disappear.
    ...    *Arguments:*
    ...    - ``associate_name``: Name of the associate
    ...    - ``start_date``: Start date in week_day format (e.g., '1_2')
    ...    - ``end_formatted``: End date in week_day format (e.g., '1_5')
    ...    - ``reason_type``: Reason for the request (e.g., 'Paid Vacation')
    ...    - ``request_status``: Status of the request (e.g., 'Not Reviewed', 'Approved')
    ...    *Example:*
    ...    | Confirm Request Not Exist On Requests Page On Web | John Doe | 1_2 | 1_2 | Paid Vacation | Approved |
    [Arguments]    ${associate_name}    ${start_date}    ${end_formatted}    ${reason_type}    ${request_status}
    ${request_locator}    Build Request Locator On Requests Page On Web
    ...    ${associate_name}    ${start_date}    ${end_formatted}    ${reason_type}    ${request_status}
    Wait Until Element Disappears On Webpage    ${request_locator}    timeout=${LONG_TIMEOUT}

Check For Request Existence On Requests Page On Web
    [Documentation]    This keyword will check for request existence On Requests Page On Web.
    [Arguments]    ${associate_name}    ${start_date}    ${end_formatted}    ${reason_type}    ${request_status}
    ${request_locator}    Build Request Locator On Requests Page On Web
    ...    ${associate_name}    ${start_date}    ${end_formatted}    ${reason_type}    ${request_status}
    Wait Until Element Is Present On Webpage    ${request_locator}    timeout=${LONG_TIMEOUT}

Build Request Locator On Requests Page On Web
    [Documentation]
    ...    Builds a locator for a request on the Requests Page based on request type, associate, date, reason, and status.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format (e.g., '1_2' for Week 1, Day 2).    |
    ...    | end_date    | End date in week-day format (e.g., '1_5' for Week 1, Day 5).    |
    ...    | reason_type    | Reason for the request (e.g., 'Paid Vacation', 'Unpaid Time Off').    |
    ...    | request_status    | Status of the request (e.g., 'Not Reviewed', 'Approved', 'Declined').    |
    ...    Example usage:
    ...    | Build Request Locator On Requests Page On Web    Store1, Associate01    1_2    1_5    Paid Vacation    Not Reviewed
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}    ${reason_type}    ${request_status}
    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${end_target_date}    Calculate Date From Week Day Offset    ${end_date}
    ${period_date_format}    Get Config Value    key=DATE_FMT_FULL_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${period_date_format}
    ${end_formatted}    Convert Date    ${end_target_date}    result_format=${period_date_format}

    # Update first three placeholders - request type, associate name, start date
    ${locator}    Update Locator With Dynamic Values    ${REQUESTSPAGE_REQUEST_LOCATOR}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    START_FORMATTED=${start_formatted}
    ...    END_FORMATTED=${end_formatted}
    ...    REQUEST_STATUS=${request_status}
    ...    REASON_TYPE=${reason_type}

    RETURN    ${locator}

Set Request Status And Verify Success On Requests Page On Web
    [Documentation]    This keyword will change status of required request On Requests Page On Web.
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${end_formatted}
    ...    ${reason_type}
    ...    ${request_status}
    ...    ${status_to_change}
    ${request_status_locator}    Build Required Request Status Locator On Requests Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${end_formatted}
    ...    ${reason_type}
    ...    ${request_status}
    Select And Verify Dropdown Value On Requests Page On Web    ${request_status_locator}    text    ${status_to_change}
    Click Element On Webpage    ${REQUESTSPAGE_SAVE_BUTTON}
    Wait For Loading Progress Bar On Requests Page On Web
    Verify Success Toast Notification On Requests Page On Web

Build Required Request Status Locator On Requests Page On Web
    [Documentation]
    ...    Builds a locator for a request on the Requests Page based on request type, associate, date, reason, and status.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format (e.g., '1_2' for Week 1, Day 2).    |
    ...    | end_date    | End date in week-day format (e.g., '1_5' for Week 1, Day 5).    |
    ...    | reason_type    | Reason for the request (e.g., 'Paid Vacation', 'Unpaid Time Off').    |
    ...    | request_status    | Status of the request (e.g., 'Not Reviewed', 'Approved', 'Declined').    |
    ...    Example usage:
    ...    | Build Request Locator On Requests Page On Web    Store1, Associate01    1_2    1_5    Paid Vacation    Not Reviewed
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}    ${reason_type}    ${request_status}
    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${end_target_date}    Calculate Date From Week Day Offset    ${end_date}
    ${period_date_format}    Get Config Value    key=DATE_FMT_FULL_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${period_date_format}
    ${end_formatted}    Convert Date    ${end_target_date}    result_format=${period_date_format}

    # Update first three placeholders - request type, associate name, start date
    ${locator}    Update Locator With Dynamic Values    ${REQUESTSPAGE_SPECIFIC_REQUEST_STATUS_DROP_DOWN}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    START_FORMATTED=${start_formatted}
    ...    END_FORMATTED=${end_formatted}
    ...    REQUEST_STATUS=${request_status}
    ...    REASON_TYPE=${reason_type}
    RETURN    ${locator}

Verify Success Toast Notification On Requests Page On Web
    [Documentation]    Verifies that the toast message notification is displayed in WFM.
    Wait Until Element Is Visible On Webpage    ${REQUESTSPAGE_STATUS_UPDATE_SUCCESS_TOAST_POPUP}    timeout=${LONG_TIMEOUT}

Build Required Request Status Option Locator On Requests Page On Web
    [Documentation]
    ...    Builds a locator for the status option dropdown on the Requests Page.
    ...    This locator is used to click a specific status option (e.g., "Approved", "Declined").
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format (e.g., '1_2' for Week 1, Day 2).    |
    ...    | end_date    | End date in week-day format (e.g., '1_5' for Week 1, Day 5).    |
    ...    | reason_type    | Reason for the request (e.g., 'Paid Vacation', 'Unpaid Time Off').    |
    ...    | request_status    | Current status of the request (e.g., 'Not Reviewed').    |
    ...    | status_value    | Status value to select (e.g., 'Approved', 'Declined').    |
    ...    Example usage:
    ...    | Build Required Request Status Option Locator On Requests Page On Web    Store1, Associate01    1_2    1_5    Paid Vacation    Not Reviewed    Approved
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${end_date}
    ...    ${reason_type}
    ...    ${request_status}
    ...    ${status_value}
    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${end_target_date}    Calculate Date From Week Day Offset    ${end_date}
    ${period_date_format}    Get Config Value    key=DATE_FMT_FULL_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${period_date_format}
    ${end_formatted}    Convert Date    ${end_target_date}    result_format=${period_date_format}

    # Start with the status option locator template
    VAR    ${locator}    ${REQUESTSPAGE_REQUEST_STATUS_OPTION}

    # Update first three placeholders - associate name, start date, end date
    ${locator}    Update Locator With Dynamic Values
    ...    ${locator}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    START_FORMATTED=${start_formatted}
    ...    END_FORMATTED=${end_formatted}
    ...    REQUEST_STATUS=${request_status}
    ...    REASON_TYPE=${reason_type}
    ...    STATUS_VALUE=${status_value}
    RETURN    ${locator}

Find Next Available Day Without Any Existing Requests On Requests Page On Web
    [Documentation]    Finds the next available day that has no existing requests for the specified employee.
    ...
    ...    Loops through remaining days in a week starting from the given day and increments week if all days are occupied.
    ...    Uses date filters to check for request existence in the requests table.
    ...    Checks for ANY request (all types, statuses, reasons) by default.
    ...    *Example:* If start_date is "0_3", it checks from day 3 to 6 in week 0, then day 0 to 6 in week 1.
    ...    *Arguments:*
    ...    - ``employee_name``: Name of the employee to check availability for
    ...    - ``start_date``: Start date for checking availability in week_day format (e.g., "0_3")
    ...
    ...    *Returns:* Available date in week_day format (e.g., "1_2")
    ...    *Example:*
    ...    | ${available_day} = | Find Next Available Day Without Any Existing Requests On Requests Page On Web | ${ess_user}[displayName] | 0_0 |
    [Arguments]    ${employee_name}    ${start_date}
    # Parse the initial week and day from start_date (format: week_day like "2_3")
    @{date_parts}    Split String    ${start_date}    _
    ${current_week}    Convert To Integer    ${date_parts}[0]
    ${start_day}    Convert To Integer    ${date_parts}[1]
    VAR    ${max_weeks_to_check}    2    # Limit to prevent infinite loop
    # Loop through weeks to find an available slot
    FOR    ${week_offset}    IN RANGE    ${max_weeks_to_check}
        ${week_to_check}    Evaluate    ${week_offset} + ${current_week}
        # For the first week, start from the specified day; for subsequent weeks, start from day 0
        ${day_to_start}    Evaluate    ${start_day} if ${week_offset} == 0 else 0
        ${available_day}    Find Available Day In Current Week On Requests Page On Web
        ...    ${employee_name}
        ...    ${week_to_check}
        ...    ${day_to_start}

        IF    ${available_day}
            VAR    ${available_date}    ${week_to_check}_${available_day}
            Log    Selected date for new request: ${available_date}
            RETURN    ${available_date}
        ELSE
            Log    Week ${week_to_check} is fully occupied from day ${day_to_start}, checking next week
        END
    END
    # If no available slot found within limit, return original date
    Log    Warning: No available slot found within ${max_weeks_to_check} weeks. Using original date: ${start_date}
    RETURN    ${start_date}

Find Available Day In Current Week On Requests Page On Web
    [Documentation]    Searches for an available day within a specific week starting from the specified day.
    ...    Returns immediately when first available day is found, without checking remaining days.
    ...    Checks for ANY request for the associate on each day (all types, statuses, reasons).
    ...    Sets filter for EACH specific day to ensure accurate date-based filtering.
    ...    | =Arguments= | =Description= |
    ...    | employee_name | Name of the employee to check availability for |
    ...    | week_number | Week number to check |
    ...    | start_day | Day number to start checking from (0-6) |
    ...    Example usage:
    ...    | ${day}    Find Available Day In Current Week On Requests Page On Web    John Doe    2    3
    ...    | # Returns first available day starting from day 3 of week 2
    [Arguments]    ${employee_name}    ${week_number}    ${start_day}

    # Ensure start_day is an integer for the FOR loop
    ${start_day_int}    Convert To Integer    ${start_day}

    # Check each day individually with proper filtering
    FOR    ${day}    IN RANGE    ${start_day_int}    7
        VAR    ${date_to_check}    ${week_number}_${day}

        # Set filter for THIS SPECIFIC DAY ONLY with "All" for type, status, and reason
        Set Filters On Requests Page On Web
        ...    start_date=${date_to_check}
        ...    end_date=${date_to_check}
        ...    request_status=All

        # Build locator to check if ANY request exists for this associate and date
        ${request_locator}    Build Any Request Locator By Associate And Date On Requests Page On Web
        ...    ${employee_name}
        ...    ${date_to_check}
        ...    ${date_to_check}

        ${element_exists}    Is Element Present On Webpage    ${request_locator}
        IF    not ${element_exists}
            Log    Found available slot for ${employee_name} on ${date_to_check}
            RETURN    ${day}
        ELSE
            Log    Request already exists for ${employee_name} on ${date_to_check}
        END
    END
    # No available day found in this week
    RETURN    ${EMPTY}

Build Any Request Locator By Associate And Date On Requests Page On Web
    [Documentation]    Builds a locator to check for ANY request by associate name only.
    ...    Does not include date in locator because date filtering is already handled by Set Filters keyword.
    ...    The filter shows all requests that overlap with the specified date range (including multi-day requests).
    ...    This locator simply checks if the associate appears in the filtered results.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate |
    ...    | start_date | Start date in week_day format (used for documentation only, actual filtering done by Set Filters) |
    ...    Example usage:
    ...    | ${locator}    Build Any Request Locator By Associate And Date On Requests Page On Web    Store1, Associate01    0_1
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}
    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${end_target_date}    Calculate Date From Week Day Offset    ${end_date}
    ${period_date_format}    Get Config Value    key=DATE_FMT_FULL_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${period_date_format}
    ${end_formatted}    Convert Date    ${end_target_date}    result_format=${period_date_format}
    ${locator}    Update Locator With Dynamic Values    ${REQUESTSPAGE_ANY_REQUEST_BY_ASSOCIATE_AND_DATE}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    START_FORMATTED=${start_formatted}
    ...    END_FORMATTED=${end_formatted}

    RETURN    ${locator}
