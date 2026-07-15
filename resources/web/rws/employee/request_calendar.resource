*** Settings ***
Documentation
...                 This resource file provides keywords for automating the SM Request Calendar page.
...
...                 = Purpose =
...                 - Centralizes actions for navigating, submitting, and verifying requests on the Request Calendar page.
...
...                 = Prerequisites =
...                 - Required libraries and variable files must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Add Day Off Request
...                 |    SM Navigate To RWS Employee Request Calendar Page
...                 |    Add SM Day Off Request
...                 |    Select Associate On SM Request Calendar Page    John Doe
...                 |    Select SM Reason Type For Day Off    Day Off
...                 |    Submit SM Request

Library             resources/web/common/utility.py
Library             test_data/TestDataLibrary.py
Variables           resources/web/rws/employee/request_calendar_page.py
Variables           resources/web/common/menu_page.py
Variables           resources/web/common/notification.py
Variables           resources/web/rws/employee/request_calendar_api.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/request_calendar_utility.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/authentication/auth_api.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/ess_request_calendar.resource
Resource            resources/web/ess/ess_request_calendar_db.resource


*** Keywords ***
Navigate To RWS Employee Request Calendar Page On Web
    [Documentation]    Navigate To RWS -> Employee -> Request Calendar Page
    ...    and verifies request calendar heading at the top of the page
    Navigate To Specific Page On Web    rws    employee    request_calendar

Add New SM Day Off Request On Request Calendar Page On Web
    [Documentation]    Click to add a new day off request
    Wait For Elements State    ${REQUEST_CALENDAR_PAGE_ADD_REQUEST_BUTTON}    visible    timeout=5s
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_REQUEST_BUTTON}
    Wait For Elements State    ${REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS}    visible    timeout=5s
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS}

Select Associate On SM Request Calendar Page On Web
    [Documentation]
    ...    Selects an associate from the dropdown on the Request Calendar page.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name | Name of the associate to select.    |
    ...    Example usage:
    ...    | Select Associate On SM Request Calendar Page On Web    John Doe
    [Arguments]    ${associate_name}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_SELECT_ASSOCIATE_DROPDOWN}
    Wait Until Element Is Visible On Webpage    ${REQUEST_CALENDAR_PAGE_ASSOCIATE_SEARCH_FIELD}
    Fill Textbox On Webpage    ${REQUEST_CALENDAR_PAGE_ASSOCIATE_SEARCH_FIELD}    ${associate_name}
    ${associate_name_input}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_ASSOCIATE_NAME_INPUT}
    ...    ASSOCIATE_NAME=${associate_name}
    Click Element On Webpage    ${associate_name_input}

Select SM Day Off Reason Type On Request Calendar Page On Web
    [Documentation]
    ...    Selects a request type (Availability, Time Off, Day Off) from the dropdown.
    ...    | =Arguments=    | =Description=    |
    ...    | request_type | The type of request to select from dropdown.    |
    ...    Example usage:
    ...    | Select SM Day Off Reason Type On Request Calendar Page On Web    Paid Vacation
    [Arguments]    ${request_type}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_DAY_OFF_REASON_DROPDOWN_BUTTON}
    ${selected}    Select Options By
    ...    ${REQUEST_CALENDAR_PAGE_DAY_OFF_REASON_DROPDOWN_BUTTON}
    ...    label
    ...    ${request_type}
    List Should Contain Value    ${selected}    ${request_type}

Select SM Reason On Request Calendar Page On Web
    [Documentation]
    ...    Selects a specific reason (e.g., Paid Vacation) for the day off request.
    ...    | =Arguments=    | =Description=    |
    ...    | reason_type    | The reason to select from the dropdown.    |
    ...    Example usage:
    ...    | Select SM Reason On Request Calendar Page On Web    Paid Vacation
    [Arguments]    ${reason_type}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_DAY_OFF_REASON_DROPDOWN_BUTTON}
    ${reason_option}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_REASON_OPTION}
    ...    REASON_TYPE=${reason_type}
    Click Element On Webpage    ${reason_option}

Submit SM Request On Request Calendar Page On Web
    [Documentation]    Submits the day off request
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_DAY_OFF_SUBMIT_BUTTON}
    Wait Until Element Disappears On Webpage    ${REQUEST_CALENDAR_PAGE_DAY_OFF_SUBMIT_BUTTON}
    # Wait for submission to complete and page to update

Select SM Request Status On Request Calendar Page On Web
    [Documentation]    Selects the request status from the dropdown.
    ...    Scrolls to the element within the dropdown container if the option is not visible.
    [Arguments]    ${req_status}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_REQUEST_STATUS}
    ${fixed_shift_select_status}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_STATUS_OPTION}
    ...    REQUEST_STATUS=${req_status}
    ${status}    Is Element Visible On Webpage    ${fixed_shift_select_status}
    IF    not ${status}
        Log    Status option '${req_status}' not visible, scrolling to element    level=INFO
        Scroll To Element    ${fixed_shift_select_status}
    END
    Click Element On Webpage    ${fixed_shift_select_status}

Edit Day Off Request Status And Verify API Success On Request Calendar Page On Web
    [Documentation]    Approves a day off request and verifies the API response
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${request_status}
    ...    ${status_to_set}
    # Navigate to the specific planning week day
    Select Day On Request Calendar Page    ${start_date}
    # Find and Click Element On Webpage on the day off request
    ${request_locator}    Build SM Day Off Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${request_status}
    Click Element On Webpage    ${request_locator}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    Select SM Request Status On Request Calendar Page On Web    ${status_to_set}
    ${promise}    Promise To    Wait For Response    ${SM_EDIT_DAY_OFF_API_REGEX}
    Submit SM Request On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Wait Until Spinner Disappears On Request Calendar Page On Web

Approve Day Off Request And Verify API Success On Request Calendar Page On Web
    [Documentation]    Approves a day off request and verifies the API response
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${request_status}
    # Navigate to the specific planning week day
    Select Day On Request Calendar Page    ${start_date}
    # Find and Click Element On Webpage on the day off request
    ${request_locator}    Build SM Day Off Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${request_status}
    Click Element On Webpage    ${request_locator}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    ${promise}    Promise To    Wait For Response    ${APPROVE_DAY_OFF_SM_API_REGEX}
    # Click Element On Webpage approve button
    Click On SM Approve Request Button On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web
    [Documentation]    Delete a day off request as Sm and verifies the API response
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${request_status}
    Select Day On Request Calendar Page    ${start_date}
    Wait Until Spinner Disappears On Request Calendar Page On Web
    ${request_locator}    Build SM Day Off Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${request_status}
    Wait Until Element Is Visible On Webpage    ${request_locator}    timeout=${LONG_TIMEOUT}
    Click Element On Webpage    ${request_locator}
    Wait Until Spinner Disappears On Request Calendar Page On Web
    ${promise}    Promise To    Wait For Response    ${DELETE_DAY_OFF_SM_API_URL}    timeout=${LONG_API_TIMEOUT}
    Click On SM Delete Request Button On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    ...    msg=Failed to delete day off request via SM interface on Request Calendar Page

Decline Day Off Request And Verify API Success On Request Calendar Page On Web
    [Documentation]    Declines a day off request and verifies the API response
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${Pre_status}
    # Navigate to the specific planning week day
    Select Day On Request Calendar Page    ${start_date}
    # Find and Click Element On Webpage on the day off request
    ${request_locator}    Build SM Day Off Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${Pre_status}
    Click Element On Webpage    ${request_locator}
    ${promise}    Promise To    Wait For Response    ${DECLINE_DAY_OFF_SM_API_REGEX}
    # Click Element On Webpage decline button
    Click On SM Decline Request Button On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Click On SM Approve Request Button On Request Calendar Page On Web
    [Documentation]    Click the approve button in the SM interface to approve a day off request
    Wait For Elements State    ${REQUEST_CALENDAR_APPROVE_BUTTON}    visible    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${REQUEST_CALENDAR_APPROVE_BUTTON}

Click On SM Delete Request Button On Request Calendar Page On Web
    [Documentation]    Click the Delete button in the SM interface to delete a day off request
    Wait For Elements State    ${REQUEST_CALENDAR_PAGE_ASSOCIATE_DELETE_BUTTON_DAY_OFF}    visible    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ASSOCIATE_DELETE_BUTTON_DAY_OFF}

Click On SM Decline Request Button On Request Calendar Page On Web
    [Documentation]    Click the decline button in the SM interface to decline a day off request
    Wait For Elements State    ${REQUEST_CALENDAR_DECLINE_BUTTON}    visible    timeout=${MEDIUM_TIMEOUT}
    Click Element On Webpage    ${REQUEST_CALENDAR_DECLINE_BUTTON}

Build SM Day Off Request Locator On Request Calendar Page On Web
    [Documentation]
    ...    Builds a locator for a day off request based on associate, date, reason, and status.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | reason_type    | Reason for the day off.    |
    ...    | request_status    | Status of the request.    |
    ...    Example usage:
    ...    | Build SM Day Off Request Locator On Request Calendar Page On Web    John Doe    1_2    Day Off    Approved
    [Arguments]    ${associate_name}    ${start_date}    ${reason_type}    ${request_status}
    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${day_locator_format}    Get Config Value    key=DATE_FMT_WEEKDAY_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${day_locator_format}
    @{name_parts}    Split String    ${associate_name}    ,
    VAR    ${last_name}    ${name_parts}[1]
    IF    $SPACE in $reason_type
        @{reason_parts}    Split String    ${reason_type}    ${SPACE}
        VAR    ${reason_type}    ${reason_parts}[0]
    END
    ${locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_SM_DAY_OFF_REQUEST_LOCATOR}
    ...    ASSOCIATE_NAME=${last_name}
    ...    REASON_TYPE=${reason_type}
    ...    START_FORMATTED=${start_formatted}
    ...    REQUEST_STATUS=${request_status}
    RETURN    ${locator}

Build SM Day Off Request Locator On Line View On Request Calendar Page On Web
    [Documentation]
    ...    Builds a locator for a day off request in line view based on associate, date, and status.
    ...    This locator uses //tr element for line view instead of //table for card view.
    ...    Includes both start and end dates to support single-day and multi-day requests.
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate (e.g., "StoreZ2, Associate04").    |
    ...    | start_date    | Start date in week-day format (e.g., "1_2" for Monday).    |
    ...    | end_date    | End date in week-day format (optional, defaults to start_date for single-day).    |
    ...    | request_status    | Status of the request (e.g., "Not Reviewed", "Approved").    |
    ...
    ...    **Example:**
    ...    | ${locator}= | Build SM Day Off Request Locator On Line View On Request Calendar Page On Web |
    ...    | ... | StoreZ2, Associate04 | 1_2 | 1_2 | Not Reviewed |
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}    ${request_status}
    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${end_target_date}    Calculate Date From Week Day Offset    ${end_date}
    ${day_locator_format}    Get Config Value    key=DATE_FMT_WEEKDAY_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${day_locator_format}
    ${end_formatted}    Convert Date    ${end_target_date}    result_format=${day_locator_format}
    # Update placeholders - associate name, start date, end date, and request status
    ${locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_SM_DAY_OFF_REQUEST_LINE_VIEW_LOCATOR}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    START_FORMATTED=${start_formatted}
    ...    END_FORMATTED=${end_formatted}
    ...    REQUEST_STATUS=${request_status}
    RETURN    ${locator}

Build SM Time Off Request Locator On Line View On Request Calendar Page On Web
    [Documentation]
    ...    Builds a locator for a time off request in line view based on associate, date, time, and status.
    ...    This locator uses //tr element for line view instead of //table for card view.
    ...    Time off requests only use start_date since they don't span multiple days.
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate (e.g., "StoreZ2, Associate04").    |
    ...    | start_date    | Start date in week-day format (e.g., "8_2" for Monday).    |
    ...    | start_time    | Start time of the request in 24-hour format (e.g., "20:00").    |
    ...    | end_time    | End time of the request in 24-hour format (e.g., "00:00").    |
    ...    | request_status    | Status of the request (e.g., "Not Reviewed", "Approved").    |
    ...
    ...    **Example:**
    ...    | ${locator}= | Build SM Time Off Request Locator On Line View On Request Calendar Page On Web |
    ...    | ... | StoreZ2, Associate04 | 8_2 | 20:00 | 00:00 | Approved |
    [Arguments]    ${associate_name}    ${start_date}    ${start_time}    ${end_time}    ${request_status}
    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${day_locator_format}    Get Config Value    key=DATE_FMT_WEEKDAY_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${day_locator_format}
    # Convert times from 24-hour to 12-hour format and remove spaces/AM/PM indicators
    ${formated_start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
    ${formated_end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}
    # Remove spaces and AM/PM indicators (replace complete strings, not individual characters)
    ${converted_start_time}    Replace String    ${formated_start_time}    ${SPACE}    ${EMPTY}
    ${converted_start_time}    Replace String    ${converted_start_time}    am    ${EMPTY}
    ${converted_start_time}    Replace String    ${converted_start_time}    pm    ${EMPTY}
    ${converted_end_time}    Replace String    ${formated_end_time}    ${SPACE}    ${EMPTY}
    ${converted_end_time}    Replace String    ${converted_end_time}    am    ${EMPTY}
    ${converted_end_time}    Replace String    ${converted_end_time}    pm    ${EMPTY}
    # Update placeholders - associate name, date, times, and request status
    ${locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_SM_TIME_OFF_REQUEST_LINE_VIEW_LOCATOR}
    ...    ASSOCIATE_NAME=${associate_name}    START_FORMATTED=${start_formatted}
    ...    START_TIME=${converted_start_time}    END_TIME=${converted_end_time}
    ...    REQUEST_STATUS=${request_status}
    RETURN    ${locator}

Build SM Availability Request Locator On Line View On Request Calendar Page On Web
    [Documentation]
    ...    Builds a locator for an availability request in line view based on associate, date, reason, and status.
    ...    This locator uses //tr element for line view instead of //table for card view.
    ...    Availability requests only use start_date since they don't span multiple days.
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate (e.g., "StoreZ2, Associate04").    |
    ...    | start_date    | Start date in week-day format (e.g., "8_0" for Monday).    |
    ...    | reason    | Reason for the availability request (e.g., "Busy Week").    |
    ...    | request_status    | Status of the request (e.g., "Not Reviewed", "Approved").    |
    ...
    ...    **Example:**
    ...    | ${locator}= | Build SM Availability Request Locator On Line View On Request Calendar Page On Web |
    ...    | ... | StoreZ2, Associate04 | 8_0 | Busy Week | Approved |
    [Arguments]    ${associate_name}    ${start_date}    ${reason}    ${request_status}
    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${day_locator_format}    Get Config Value    key=DATE_FMT_WEEKDAY_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${day_locator_format}
    # Update placeholders - associate name, reason, start date, and request status
    ${locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_SM_AVAILABILITY_REQUEST_LINE_VIEW_LOCATOR}
    ...    ASSOCIATE_NAME=${associate_name}    REASON=${reason}
    ...    START_FORMATTED=${start_formatted}    REQUEST_STATUS=${request_status}
    RETURN    ${locator}

Build Request Locator For Validate Any Request Exist On Day On Request Calendar Page On Web
    [Documentation]
    ...    Builds a locator for a day off request based on associate, date, reason, and status.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | start_time    | Start time for the time off.    |
    ...    | end_time    | End time for the time off.    |
    ...    | request_status    | Expected status to verify.    |
    ...    Example usage:
    ...    | Build SM Day Off Request Locator On Request Calendar Page On Web    John Doe    1_2    Day Off    Approved
    [Arguments]    ${associate_name}    ${start_date}

    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${day_only_format}    Get Config Value    key=DATE_FMT_WEEKDAY_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${day_only_format}
    ${locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_REQUEST_EXISTS_LOCATOR}
    ...    ASSOCIATE_NAME=${associate_name}    START_FORMATTED=${start_formatted}
    RETURN    ${locator}

Build Day Off Request Checkbox Locator On List View Page On Request Calendar Page On Web
    [Documentation]    Builds locator for day off request based on associate, dates and request details
    [Arguments]    ${associate_name}    ${start_date}    ${reason_type}
    @{name_parts}    Split String    ${associate_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    # Calculate start date
    ${target_date}    Calculate Date From Week Day Offset    ${start_date}
    # Format dates in the required format
    ${day_off_locator_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${target_date}    result_format=${day_off_locator_format}
    # Build the locator string using the template and Update Locator With Dynamic Values
    ${locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_DAY_OFF_CHECKBOX_LOCATOR}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    REASON_TYPE=${reason_type}
    ...    START_FORMATTED=${start_formatted}
    RETURN    ${locator}

Build SM Time Off Request Locator On Request Calendar Page On Web
    [Documentation]    Builds locator for time off request based on associate, date, time and status
    [Arguments]    ${associate_name}    ${start_date}    ${request_reason}    ${start_time}    ${end_time}    ${status}
    ${target_date}    Calculate Date From Week Day Offset    ${start_date}
    # Format the date to match the expected format (e.g., "Sun Jul 27 2025")
    ${day_only_format}    Get Config Value    key=DATE_FMT_WEEKDAY_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${day_only_format}
    ${formated_start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
    ${formated_end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}
    # Remove spaces and AM/PM indicators (replace complete strings, not individual characters)
    ${converted_start_time}    Replace String    ${formated_start_time}    ${SPACE}    ${EMPTY}
    ${converted_start_time}    Replace String    ${converted_start_time}    am    ${EMPTY}
    ${converted_start_time}    Replace String    ${converted_start_time}    pm    ${EMPTY}
    ${converted_end_time}    Replace String    ${formated_end_time}    ${SPACE}    ${EMPTY}
    ${converted_end_time}    Replace String    ${converted_end_time}    am    ${EMPTY}
    ${converted_end_time}    Replace String    ${converted_end_time}    pm    ${EMPTY}
    @{name_parts}    Split String    ${associate_name}    ,
    ${first_name}    Strip String    ${name_parts}[0]
    ${last_name}    Strip String    ${name_parts}[1]
    IF    $SPACE in $request_reason
        @{reason_parts}    Split String    ${request_reason}    ${SPACE}
        VAR    ${request_reason}    ${reason_parts}[0]
    END
    # Build the locator string using the template with three values at a time
    ${locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_SM_TIME_OFF_REQUEST_LOCATOR}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    REQUEST_REASON=${request_reason}
    ...    FORMATTED_DATE=${formatted_date}
    ...    START_TIME=${converted_start_time}
    ...    END_TIME=${converted_end_time}
    ...    STATUS=${status}
    RETURN    ${locator}

Build Time Off Request Checkbox Locator On List View On Request Calendar Page On Web
    [Documentation]
    ...    Builds a locator for a time off request checkbox based on associate, date, time, and reason.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | reason_type    | Reason for the time off.    |
    ...    | start_time    | Start time for the time off.    |
    ...    | end_time    | End time for the time off.    |
    ...    Example usage:
    ...    | Build Time Off Request Checkbox Locator On List View On Request Calendar Page On Web    John Doe    1_2    Break    09:00    10:00
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${start_time}
    ...    ${end_time}
    # Calculate start date
    @{name_parts}    Split String    ${associate_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    ${target_date}    Calculate Date From Week Day Offset    ${start_date}
    # Format dates in the required format
    ${day_off_locator_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${day_off_locator_format}
    ${formated_start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
    ${formated_end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}

    # Build the locator string using the template with three values at a time
    ${locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_TIME_OFF_CHECKBOX_LOCATOR}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    REASON_TYPE=${reason_type}
    ...    FORMATTED_DATE=${formatted_date}
    ...    START_TIME=${formated_start_time}
    ...    END_TIME=${formated_end_time}
    RETURN    ${locator}

Edit Time Off Request Status And Verify API Success On Request Calendar Page On Web
    [Documentation]
    ...    Edit a time off request and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | request_type    | Type of the request (e.g., Time Off).    |
    ...    | start_time    | Start time for the time off.    |
    ...    | end_time    | End time for the time off.    |
    ...    | Pre_status    | Previous status of the request.    |
    ...    | status_to_set    | New status to set for the request (e.g., Approved, Declined).    |
    ...    Example usage:
    ...    | Edit Time Off Request Status And Verify API Success On Request Calendar Page On Web    John Doe    1_2    Time Off    09:00    10:00    Pending    Approved
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${Pre_status}
    ...    ${status_to_set}
    # Navigate to the specific planning week day
    Select Day On Request Calendar Page    ${start_date}
    # Find and Click Element On Webpage on the time off request
    ${request_locator}    Build SM Time Off Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${Pre_status}
    Click Element On Webpage    ${request_locator}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    Select SM Request Status On Request Calendar Page On Web    ${status_to_set}
    ${promise}    Promise To    Wait For Response    ${SM_EDIT_DAY_OFF_API_REGEX}
    Submit SM Request On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}

Approve Time Off Request And Verify API Success On Request Calendar Page On Web
    [Documentation]
    ...    Cancels a time off request as ESS and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | request_type    | Type of the request (e.g., Time Off).    |
    ...    | start_time    | Start time for the time off.    |
    ...    | end_time    | End time for the time off.    |
    ...    | Pre_status    | Previous status of the request.    |
    ...    Example usage:
    ...    | SM Approves Time Off Request And Verify API Success    John Doe    1_2    Time Off    09:00    10:00    Pending
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${Pre_status}
    # Navigate to the specific planning week day
    Select Day On Request Calendar Page    ${start_date}
    # Find and Click Element On Webpage on the time off request
    ${request_locator}    Build SM Time Off Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${Pre_status}
    Click Element On Webpage    ${request_locator}
    ${promise}    Promise To    Wait For Response    ${APPROVE_TIMEOFF_SM_API_REGEX}
    # Click Element On Webpage approve button
    Click Element On Webpage    ${REQUEST_CALENDAR_APPROVE_BUTTON}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Decline Time Off Request And Verify API Success On Request Calendar Page On Web
    [Documentation]
    ...    Declines a time off request and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | request_type    | Type of the request (e.g., Time Off).    |
    ...    | start_time    | Start time for the time off.    |
    ...    | end_time    | End time for the time off.    |
    ...    | Pre_status    | Previous status of the request.    |
    ...    Example usage:
    ...    | SM Declines Time Off Request And Verify API Success    John Doe    1_2    Time Off    09:00    10:00    Pending
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${Pre_status}
    # Navigate to the specific planning week day
    Select Day On Request Calendar Page    ${start_date}
    # Find and Click Element On Webpage on the time off request
    ${request_locator}    Build SM Time Off Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${Pre_status}
    Click Element On Webpage    ${request_locator}
    ${promise}    Promise To    Wait For Response    ${DECLINE_TIMEOFF_SM_API_REGEX}
    # Click Element On Webpage decline button
    Click Element On Webpage    ${REQUEST_CALENDAR_DECLINE_BUTTON}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Set Request Type And Status Filter On Request Calendar Page On Web
    [Documentation]    Sets filter on request calendar page based on request type and status
    [Arguments]    ${request_type}    ${request_status}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_FILTER_BUTTON}
    Wait Until Element Is Visible On Webpage    ${REQUEST_CALENDAR_PAGE_FILTER_PANEL}
    Select SM Filter Request Type From Dropdown On Request Calendar Page On Web    ${request_type}
    Select SM Filter Request Status From Dropdown On Request Calendar Page On Web    ${request_status}
    Click Apply On SM Filter On Request Calendar Page On Web
    Wait Until Element Disappears On Webpage    ${LOAD_SPINNER}

Verify Request By Filter Based On Status And Type On Request Calendar Page On Web
    [Documentation]    Click on quick filter button On sm request calendar And selects request status
    [Arguments]    ${request_type}    ${request_status}
    ${request_count_before_filter}    Get Number Of Requests Count Based On Type And Status On Request Calendar Page On Web
    ...    ${request_type}
    ...    ${request_status}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_FILTER_BUTTON}
    Select SM Filter Request Status From Dropdown On Request Calendar Page On Web    ${request_status}
    Select SM Filter Request Type From Dropdown On Request Calendar Page On Web    ${request_type}
    Click Apply On SM Filter On Request Calendar Page On Web
    Wait Until Element Disappears On Webpage    ${LOAD_SPINNER}
    ${request_count_after_filter}    Get Number Of Requests Count Based On Type And Status On Request Calendar Page On Web
    ...    ${request_type}
    ...    ${request_status}
    Should Be Equal As Integers    ${request_count_before_filter}    ${request_count_after_filter}

Get Number Of Requests Count Based On Type And Status On Request Calendar Page On Web
    [Documentation]    Get the count of requests based on request type and status
    [Arguments]    ${request_type}    ${request_status}
    IF    '${request_type}' == 'Day Off'
        ${requests_count_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_REQUESTS_COUNT_DAY_OFF}
        ...    REQUEST_STATUS=${request_status}
    ELSE IF    '${request_type}' == 'Time Off'
        ${requests_count_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_REQUESTS_COUNT_TIME_OFF}
        ...    REQUEST_STATUS=${request_status}
    ELSE
        ${requests_count_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_REQUESTS_COUNT_AVAILABILITY}
        ...    REQUEST_STATUS=${request_status}
    END
    ${requests_count}    Get Element Count    ${requests_count_locator}
    RETURN    ${requests_count}

Select SM Filter Request Status From Dropdown On Request Calendar Page On Web
    [Documentation]    Selects a specific request status from the dropdown
    [Arguments]    ${request_status}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_FILTER_REQUEST_STATUS_DROPDOWN}
    ${select_request_status_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_FILTER_STATUS_OPTION}
    ...    REQUEST_STATUS=${request_status}
    Click Element On Webpage    ${select_request_status_locator}

Select SM Filter Request Type From Dropdown On Request Calendar Page On Web
    [Documentation]    Selects a specific request type from the dropdown
    [Arguments]    ${request_type}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_FILTER_REQUEST_TYPE_DROPDOWN}
    ${select_request_type_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_FILTER_TYPE_OPTION}
    ...    REQUEST_TYPE=${request_type}
    Click Element On Webpage    ${select_request_type_locator}

Click Apply On SM Filter On Request Calendar Page On Web
    [Documentation]    Click the apply filter button on the request calendar page
    Click Element On Webpage    ${SM_REQUEST_DROPDOWN_APPLY_BUTTON}
    Wait Until Page Is Loaded    timeout=${MEDIUM_TIMEOUT}

Switch To List View On Request Calendar Page On Web
    [Documentation]    Switches the view to list view on the RWS Employee Request Calendar page
    Click Element On Webpage    ${SM_REQUEST_CALENDAR_PAGE_LIST_VIEW_BUTTON}
    Wait Until Page Is Loaded    timeout=${MEDIUM_TIMEOUT}

Select Leave And Availability Panel On List View On Request Calendar Page On Web
    [Documentation]    Selects the Leave & Availability navigation panel on the list view page
    Click Element On Webpage    ${SM_BULK_NAVIGATION_LEAVE_AND_AVAILABILITY}
    Wait Until Page Is Loaded    timeout=${MEDIUM_TIMEOUT}

Select Shift Request Panel On List View On Request Calendar Page On Web
    [Documentation]    Selects the Shift Request navigation panel on the list view page
    Click Element On Webpage    ${SM_BULK_NAVIGATION_SHIFT_REQUEST}
    Wait Until Page Is Loaded    timeout=${MEDIUM_TIMEOUT}

Select Alternate Work Location Panel On List View On Request Calendar Page On Web
    [Documentation]    Selects the Alternate Work Location navigation panel on the list view page
    Click Element On Webpage    ${SM_BULK_NAVIGATION_ALTERNATE_WORK_LOCATION}
    Wait Until Page Is Loaded    timeout=${MEDIUM_TIMEOUT}

Select Employee Profile Panel On List View On Request Calendar Page On Web
    [Documentation]    Selects the Employee Profile navigation panel on the list view page
    Click Element On Webpage    ${SM_BULK_NAVIGATION_EMPLOYEE_PROFILE}
    Wait Until Page Is Loaded    timeout=${MEDIUM_TIMEOUT}

Click On View All Button On List View With Respect To Request Type On Request Calendar Page On Web
    [Documentation]    Selects the "View All" button on the list view page of the request calendar
    [Arguments]    ${request_type}
    # Determine the locator based on the request type
    IF    '${request_type}' == 'Day Off'
        VAR    ${view_all_button_locator}    ${SM_BULK_DAY_OFF_REQUEST_VIEW_ALL_BUTTON}
    ELSE IF    '${request_type}' == 'Time Off'
        VAR    ${view_all_button_locator}    ${SM_BULK_TIME_OFF_REQUEST_VIEW_ALL_BUTTON}
    ELSE
        VAR    ${view_all_button_locator}    ${SM_BULK_AVAILABILITY_REQUEST_VIEW_ALL_BUTTON}
    END
    Click Element On Webpage    ${view_all_button_locator}

Switch To List View Page Followed By Select Date And View All Requests On Request Calendar Page On Web
    [Documentation]    Switches to list view, selects a date on the calendar, and then views all requests
    [Arguments]    ${start_date}    ${request_type}
    # Switch to list view
    Switch To List View On Request Calendar Page On Web
    # Select the date on the calendar
    Select Day On Request Calendar Page    ${start_date}
    # Click Element On Webpage on the "View All" button to see all requests for that date
    Click On View All Button On List View With Respect To Request Type On Request Calendar Page On Web    ${request_type}

Select Day Off Request Checkbox On List View On Request Calendar Page On Web
    [Documentation]    Selects the checkbox of a day off request on the list view page
    [Arguments]    ${associate_name}    ${start_date}    ${reason_type}
    # Find the checkbox locator for the day off request
    ${request_locator}    Build Day Off Request Checkbox Locator On List View Page On Request Calendar Page On Web    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    # Try to find the element and scroll if needed
    ${is_visible}    Run Keyword And Return Status    Get Element States    ${request_locator}    contains    visible
    IF    not ${is_visible}
        VAR    ${list_container}    .gridContent.lineViewDiv
        Wait For Elements State    css=${list_container}    visible    timeout=5s
        # Simple downward scrolling implementation
        VAR    ${max_attempts}    15
        FOR    ${i}    IN RANGE    ${max_attempts}
            # Check if element is now visible
            ${is_visible}    Run Keyword And Return Status
            ...    Get Element States
            ...    ${request_locator}
            ...    contains
            ...    visible
            IF    ${is_visible}    BREAK
            # Log current attempt number and continue scrolling
            ${attempt_num}    Evaluate    ${i} + 1
            Log    Scroll attempt ${attempt_num}/${max_attempts}
            # Explicitly scroll DOWN (positive deltaY value for downward scrolling)
            Mouse Wheel    css=${list_container}    deltaY=250
            Sleep    0.3s  # Needed as discussed with owner
        END
    END
    # Wait for the element to be visible after scrolling
    Wait For Elements State    ${request_locator}    visible    timeout=5s
    # Click Element On Webpage the checkbox to select the request
    Click Element On Webpage    ${request_locator}

Select Time Off Request Checkbox On List View On Request Calendar Page On Web
    [Documentation]    Selects the checkbox of a time off request on the list view page
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${start_time}
    ...    ${end_time}
    # Find the checkbox locator for the time off request
    ${request_locator}    Build Time Off Request Checkbox Locator On List View On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${start_time}
    ...    ${end_time}
    # Try to find the element and scroll if needed
    ${is_visible}    Run Keyword And Return Status    Get Element States    ${request_locator}    contains    visible
    IF    not ${is_visible}
        VAR    ${list_container}    .gridContent.lineViewDiv
        Wait For Elements State    css=${list_container}    visible    timeout=5s
        # Simple downward scrolling implementation
        VAR    ${max_attempts}    15
        FOR    ${i}    IN RANGE    ${max_attempts}
            # Check if element is now visible
            ${is_visible}    Run Keyword And Return Status
            ...    Get Element States
            ...    ${request_locator}
            ...    contains
            ...    visible
            IF    ${is_visible}    BREAK
            # Log current attempt number and continue scrolling
            ${attempt_num}    Evaluate    ${i} + 1
            Log    Scroll attempt ${attempt_num}/${max_attempts}
            # Explicitly scroll DOWN (positive deltaY value for downward scrolling)
            Mouse Wheel    css=${list_container}    deltaY=250
            Sleep    0.3s  # needed as discussed with owner
        END
    END
    # Wait for the element to be visible after scrolling
    Wait For Elements State    ${request_locator}    visible    timeout=5s
    # Click Element On Webpage the checkbox to select the request
    Click Element On Webpage    ${request_locator}

Click Approve Selected Bulk Requests On Request Calendar Page On Web
    [Documentation]    Click the approve button for selected day off requests in bulk
    ...    Waits for the button to be both visible AND enabled before clicking
    # Wait for button to be enabled (it's disabled until checkboxes are selected)
    Wait For Elements State    ${SM_BULK_APPROVE_BUTTON}    enabled    timeout=${SHORT_TIMEOUT}
    Click Element On Webpage    ${SM_BULK_APPROVE_BUTTON}

Click Approve Button On List View And Verify API Success On Request Calendar Page On Web
    [Documentation]    Click the approve button and verifies the API response
    # Find the request locator
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    ${promise}    Promise To    Wait For Response    ${APPROVE_SELECTED_DAY_OFF_BULK_SM_API_REGEX}
    Click Approve Selected Bulk Requests On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Verify Approved Requests Present On Request Calendar Page On Web
    [Documentation]    Verify Approved Requests Present On Request Calendar Page On Web
    ${count}    Get Element Count    ${SM_REQUEST_CALENDAR_PAGE_REQUESTS_PRESENT}
    ${approved_requests}    Get Element Count    ${REQUEST_CALENDAR_PAGE_APPROVED_REQUEST_LOCATOR}
    Should Be Equal As Integers    ${count}    ${approved_requests}

Click Add Day Off Request On Request Calendar Page On Web
    [Documentation]    Clicks to add a new day off request
    Wait Until Spinner Disappears On Request Calendar Page On Web
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_REQUEST_BUTTON}
    Run Keyword And Ignore Error    Wait Until Spinner Disappears On Request Calendar Page On Web
    ${add_day_off_or_time_off}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS}    timeout=${SHORT_TIMEOUT}
    IF    ${add_day_off_or_time_off}
        Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS}
    ELSE
        Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_REQUEST_BUTTON}
        Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS}
    END
    Wait Until Element Is Visible On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_DAYOFF_PAGE_CLOSE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message="Add Request form did not open successfully"
    Capture Screenshot On Webpage

Fill Day Off Request Form On Request Calendar Page On Web
    [Documentation]    Creates a day off request with the specified parameters.
    [Arguments]    ${associate_name}
    ...    ${pw_start}
    ...    ${pw_end}
    ...    ${reason_type}
    ...    ${req_status}
    Click Add Day Off Request On Request Calendar Page On Web
    Select Associate On SM Request Calendar Page On Web    ${associate_name}
    Input Date In Date Picker Through Input Box    ${REQUEST_CALENDAR_PAGE_START_DATE}    ${pw_start}
    Wait Until Spinner Disappears On Request Calendar Page On Web
    Input Date In Date Picker Through Input Box    ${REQUEST_CALENDAR_PAGE_END_DATE}    ${pw_end}
    Wait Until Spinner Disappears On Request Calendar Page On Web
    Select SM Reason On Request Calendar Page On Web    ${reason_type}
    Select SM Request Status On Request Calendar Page On Web    ${req_status}

Submit Day Off Request On Request Calendar Page On Web
    [Documentation]    Submits the day off request
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_DAY_OFF_SUBMIT_BUTTON}
    # Wait for submission confirmation if needed

Click Add Time Off Request On Request Calendar Page On Web
    [Documentation]    Clicks to add a new time off request
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_REQUEST_BUTTON}
    ${add_day_off_or_time_off}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS}    timeout=${SHORT_TIMEOUT}
    IF    ${add_day_off_or_time_off}
        Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS}
    ELSE
        Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_REQUEST_BUTTON}
        Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS}
    END
    # Toggle to Time Off mode
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_TIME_OFF_TOGGLE_BUTTON}

Fill Time Off Request Form On Request Calendar Page On Web
    [Documentation]    Fills time off request form with the specified parameters.
    [Arguments]    ${associate_name}
    ...    ${pw_date}
    ...    ${start_time}
    ...    ${duration}
    ...    ${reason_type}
    ...    ${req_status}
    Click Add Time Off Request On Request Calendar Page On Web
    Select Associate On SM Request Calendar Page On Web    ${associate_name}
    Input Date In Date Picker Through Input Box    ${REQUEST_CALENDAR_PAGE_START_DATE}    ${pw_date}
    Wait Until Spinner Disappears On Request Calendar Page On Web
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    # Select start time
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_START_TIME_TIME_OFF}
    ${start_time_option}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_TIME_OFF_SELECT_TIME}
    ...    TIME=${start_time}
    Click Element On Webpage    ${start_time_option}
    # Select duration
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_DURATION_TIME_OFF}
    @{duration_parts}    Split String    ${duration}    :
    ${duration_option}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_TIME_OFF_SELECT_DURATION}
    ...    HRS=${duration_parts}[0]    MIN=${duration_parts}[1]
    Click Element On Webpage    ${duration_option}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    Select SM Reason On Request Calendar Page On Web    ${reason_type}
    Wait Until Spinner Disappears On Request Calendar Page On Web
    Select SM Request Status On Request Calendar Page On Web    ${req_status}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}

Submit Time Off Request On Request Calendar Page On Web
    [Documentation]    Submits the time off request
    Wait Until Element Is Visible On Webpage    ${REQUEST_CALENDAR_PAGE_DAY_OFF_SUBMIT_BUTTON}
    Click    ${REQUEST_CALENDAR_PAGE_DAY_OFF_SUBMIT_BUTTON}
    # Wait for submission confirmation if needed

Create SM Time Off Request And Verify API Success On Request Calendar Page On Web
    [Documentation]    Creates a time off request and verifies the API response.
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${duration}
    ...    ${reason}
    ...    ${status}
    Fill Time Off Request Form On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${duration}
    ...    ${reason}
    ...    ${status}
    ${promise}    Promise To    Wait For Response    ${SM_ADD_TIME_OFF_API_REGEX}
    Submit Time Off Request On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    RETURN    ${response_body.body.metaInfo.addedTimeoffRequestObject}

SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web
    [Documentation]    Delete a time off request as SM and verify the API response
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${request_status}
    # Navigate to the specific planning week day
    Select Day On Request Calendar Page    ${start_date}
    # Find and Click Element On Webpage on the time off request
    ${request_locator}    Build SM Time Off Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${request_status}
    Click Element On Webpage    ${request_locator}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    ${promise}    Promise To    Wait For Response    ${DELETE_TIME_OFF_SM_API_URL}
    # Click Element On Webpage delete button
    Click On SM Delete Request Button On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Create SM Day Off Request And Verify API Success On Request Calendar Page On Web
    [Documentation]    Creates a day off request and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | end_date    | End date in week-day format.    |
    ...    | reason    | Reason for the day off.    |
    ...    | status    | Status of the request (e.g., Approved, Pending).    |
    ...    | holiday_hours    | (Optional) Dictionary mapping day numbers (1=Sun to 7=Sat) to holiday hours (e.g., {"2": "8", "3": "5"}).    |
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${end_date}
    ...    ${reason}
    ...    ${status}
    ...    ${holiday_hours}=${None}
    Skip If Request Is Present On Day For Employee On Request Calendar Page On Web
    ...    ${associate_name}    ${start_date}
    Fill Day Off Request Form On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${end_date}    ${reason}    ${status}
    IF    $holiday_hours != $None
        Enter Holiday Hours For ESS Day Off Request From SM On Request Calendar Page On Web    ${holiday_hours}
    END
    ${promise}    Promise To    Wait For Response    ${SM_ADD_DAY_OFF_API_REGEX}    timeout=${LONG_API_TIMEOUT}
    Submit Day Off Request On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    RETURN    ${response_body.body.metaInfo.addedDayoffRequestObject}

Enter Holiday Hours For ESS Day Off Request From SM On Request Calendar Page On Web
    [Documentation]    Fills in the holiday hours for each specified day.
    ...    | =Arguments= | =Description= |
    ...    | holiday_hours_data | Dictionary mapping day numbers (0=Sun to 6=Sat) to holiday hours (e.g., {"2": "8", "3": "5"}). |
    [Arguments]    ${holiday_hours_data}
    ${day_numbers}    Get Dictionary Keys    ${holiday_hours_data}
    FOR    ${day_num}    IN    @{day_numbers}
        ${hours}    Get From Dictionary    ${holiday_hours_data}    ${day_num}
        ${day_of_week}    Evaluate    ${day_num} + 1
        ${day_num_string}    Convert To String    ${day_of_week}
        ${holiday_hours_input_locator}    Update Locator With Dynamic Values
        ...    ${REQUEST_CALENDAR_PAGE_HOLIDAY_HOURS_INPUT}
        ...    DAY=${day_num_string}
        Wait Until Element Is Visible On Webpage    ${holiday_hours_input_locator}
        Clear Textbox On Webpage    ${holiday_hours_input_locator}
        Fill Textbox On Webpage    ${holiday_hours_input_locator}    ${hours}
        Log    Entered ${hours} holiday hours for day ${day_num}
    END

Delete SM Day Off Request Via UI On Request Calendar Page On Web
    [Documentation]    Store Manager Deletes a given day off request via the UI.
    [Arguments]    ${day_off_request}
    ${day_off_element}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_DAY_OFF_REQUEST_TEMPLATE}
    ...    REQUEST_NO=${day_off_request}[requestNo]
    Click Element On Webpage    ${day_off_element}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    ${promise}    Promise To    Wait For Response    ${SM_DELETE_DAY_OFF_API_REGEX}
    # Click delete button
    Click    ${REQUEST_CALENDAR_PAGE_DELETE_DAY_OFF_REQUEST_BUTTON}
    # Note: As per manual test template, there is no confirmation dialog
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}

Delete SM Day Off Request Via API On Request Calendar Page On Web
    [Documentation]    Deletes a day off request via API and verifies the response
    [Arguments]    ${user_id}    ${users_store_id}    ${day_off_request}    ${request_status}=${day_off_request}[reqStatusCd]
    ${base_url}    Get Config Value    base_url
    # Send the delete request via API
    ${auth_token}    Request New Auth Token    ${user_id}    ${users_store_id}
    VAR    &{auth_headers}
    ...    X-reflexis-auth-token-X=${auth_token}
    ...    Content-Type=application/json
    ...    Referer=${base_url}
    VAR    ${personId}    ${day_off_request}[personId]
    VAR    ${start_date_skey}    ${day_off_request}[effDateSkey]
    VAR    ${request_status_code}    ${request_status}
    VAR    ${request_no}    ${day_off_request}[requestNo]
    VAR    ${delete_day_off_url}
    ...    ${base_url}/${DELETE_DAY_OFF_SM_API_URL}/${personId}/${start_date_skey}/${request_status_code}/${request_no}.json
    Create Session    delete_session    ${base_url}    verify=True
    ${first_response}    DELETE On Session
    ...    delete_session
    ...    ${delete_day_off_url}
    ...    headers=${auth_headers}
    ...    expected_status=anything
    ${second_response}    DELETE On Session
    ...    delete_session
    ...    ${delete_day_off_url}
    ...    headers=${auth_headers}
    ...    expected_status=200
    Log    ${first_response}
    Log    ${second_response}

Delete Multiple SM Day Off Request Via API On Request Calendar Page On Web
    [Documentation]    Deletes one or more day off requests via API and verifies the response for each
    [Arguments]    ${user_id}    ${users_store_id}    @{day_off_requests}
    ${base_url}    Get Config Value    base_url
    ${auth_token}    Request New Auth Token    ${user_id}    ${users_store_id}
    VAR    &{auth_headers}
    ...    X-reflexis-auth-token-X=${auth_token}
    ...    Content-Type=application/json
    ...    Referer=${base_url}
    VAR    ${SKIP_DUPLICATE_DELETE}    False
    Create Session    delete_session    ${base_url}    verify=True
    FOR    ${day_off_request}    IN    @{day_off_requests}
        VAR    ${personId}    ${day_off_request}[personId]
        VAR    ${start_date_skey}    ${day_off_request}[effDateSkey]
        VAR    ${request_status_code}    ${day_off_request}[currentReqStatusCd]
        VAR    ${request_no}    ${day_off_request}[requestNo]
        VAR    ${delete_day_off_url}
        ...    ${base_url}/${DELETE_DAY_OFF_SM_API_URL}/${personId}/${start_date_skey}/${request_status_code}/${request_no}.json
        IF    not ${SKIP_DUPLICATE_DELETE}    # Skip duplicate delete if set to True
            ${first_response}    DELETE On Session
            ...    delete_session
            ...    ${delete_day_off_url}
            ...    headers=${auth_headers}
            ...    expected_status=anything
        END
        VAR    ${SKIP_DUPLICATE_DELETE}    True
        ${second_response}    DELETE On Session
        ...    delete_session
        ...    ${delete_day_off_url}
        ...    headers=${auth_headers}
        ...    expected_status=200
        Log    ${first_response}
        Log    ${second_response}
    END

Create SM Day Off Request And Verify Success
    [Documentation]    Creates a day off request for SM user with all required parameters
    ...    and verifies successful submission
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}    ${reason}    ${status}

    # Click on add request button and select day off request type
    Add New SM Day Off Request On Request Calendar Page On Web

    # Select associate name
    Select Associate On SM Request Calendar Page On Web    ${associate_name}

    # Input start and end dates
    Input Date In Date Picker Through Input Box    ${REQUEST_CALENDAR_PAGE_START_DATE}    ${start_date}
    Input Date In Date Picker Through Input Box    ${REQUEST_CALENDAR_PAGE_END_DATE}    ${end_date}

    # Select reason
    Select SM Reason On Request Calendar Page On Web    ${reason}

    # Select status
    Select SM Request Status On Request Calendar Page On Web    ${status}

    # Click submit button
    Submit SM Request On Request Calendar Page On Web

    # Verify success notification
    Verify Success Toast Notification

Approve Day Off Request With Holiday Hours And Verify API Success On Request Calendar Page On Web
    [Documentation]    Approves a day off request with holiday hours and verifies the API response
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${end_date}
    ...    ${reason_type}
    ...    ${request_status}
    # Navigate to the specific planning week day
    Select Day On Request Calendar Page    ${start_date}
    # Find and Click Element On Webpage on the day off request
    ${request_locator}    Build SM Day Off Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${request_status}
    Click Element On Webpage    ${request_locator}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    Verify Holiday Hours For SM Day Off Request Before Approving On Request Calendar Page On Web    ${start_date}    ${end_date}
    ${promise}    Promise To    Wait For Response    ${APPROVE_DAY_OFF_SM_API_REGEX}
    # Click Element On Webpage approve button
    Click On SM Approve Request Button On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Verify Holiday Hours For SM Day Off Request Before Approving On Request Calendar Page On Web
    [Documentation]    Verifies holiday hours for a day off request before approving it
    [Arguments]    ${start_date}    ${end_date}

    # Calculate the difference between start and end dates for iteration
    ${start_date_value}    Calculate Date From Week Day Offset    ${start_date}
    ${end_date_value}    Calculate Date From Week Day Offset    ${end_date}
    ${start_epoch}    Convert Date    ${start_date_value}    epoch
    ${end_epoch}    Convert Date    ${end_date_value}    epoch
    ${number_of_days}    Evaluate    int((${end_epoch} - ${start_epoch}) / 86400) + 1

    # Iterate through the date range for holiday hours
    FOR    ${num}    IN RANGE    ${number_of_days}
        ${current_xpath_day}    Evaluate    int(${day_number}) + ${num} + 1
        ${week_hours_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_WEEK_HOURS_XPATH}
        ...    XPATH_DAY_INDEX=${current_xpath_day}
        Wait For Elements State    ${week_hours_locator}    visible    timeout=${MEDIUM_TIMEOUT}
    END

Delete SM Time Off Request Via API On Request Calendar Page On Web
    [Documentation]    Deletes a day off request via API and verifies the response
    [Arguments]    ${user_id}    ${users_store_id}    ${time_off_request}    ${request_status}=${time_off_request}[reqStatusCd]
    ${base_url}    Get Config Value    base_url
    # Send the delete request via API
    ${auth_token}    Request New Auth Token    ${user_id}    ${users_store_id}
    VAR    &{auth_headers}
    ...    X-reflexis-auth-token-X=${auth_token}
    ...    Content-Type=application/json
    ...    Referer=${base_url}
    VAR    ${personId}    ${time_off_request}[personId]
    VAR    ${start_date_skey}    ${time_off_request}[effDateSkey]
    VAR    ${request_status_code}    ${request_status}
    VAR    ${request_no}    ${time_off_request}[requestNo]
    VAR    ${start_time}    ${time_off_request}[startTime]
    VAR    ${delete_time_off_url}
    ...    ${base_url}/${DELETE_TIME_OFF_SM_API_URL}/${personId}/${start_date_skey}/${start_time}/${request_status_code}/${request_no}.json
    Create Session    delete_toff_session    ${base_url}    verify=True
    ${first_response}    DELETE On Session
    ...    delete_toff_session
    ...    ${delete_time_off_url}
    ...    headers=${auth_headers}
    ...    expected_status=anything
    ${second_response}    DELETE On Session
    ...    delete_toff_session
    ...    ${delete_time_off_url}
    ...    headers=${auth_headers}
    ...    expected_status=200
    Log    ${first_response}
    Log    ${second_response}

Perform Navigation To Next Week On Request Calendar Page On Web
    [Documentation]    To Perform Navigation To Next Week On Request Calendar Page On Web.
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_CALENDAR_RIGHT_ARROW}
    Wait Until Page Is Loaded

Switch To Week View On Request Calendar Page On Web
    [Documentation]    This will Switch To Week View On Request Calendar Page On Web
    ${is_week_view}    Get Element States    ${REQUEST_CALENDAR_PAGE_WEEK_LABEL}    then    bool(value & visible)
    Log    Week View is already selected: ${is_week_view}
    IF    not ${is_week_view}
        Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_WEEK_LABEL}
        Wait Until Page Is Loaded
        Capture Screenshot On Webpage
    END

Add Week In Week Day Format On Web
    [Documentation]
    ...    Increments the week part of a planning week format string by specified number.
    ...    | =Arguments= | =Description= |
    ...    | week_day_string    | Planning week format string (e.g., "2_0") where first number is week and second is day. |
    ...    | weeks_to_add    | Number of weeks to add (default: 1). |
    ...    Example usage:
    ...    | ${new_week_day}    Add Week In Week Day Format On Web    2_0    1
    ...    | # Returns: 3_0
    [Arguments]    ${week_day_string}    ${weeks_to_add}=1
    @{day_parts}    Split String    ${week_day_string}    _
    VAR    ${week_number}    ${day_parts}[0]
    VAR    ${day_number}    ${day_parts}[1]
    ${new_week_number}    Evaluate    int(${week_number}) + int(${weeks_to_add})
    VAR    ${new_week_day_string}    ${new_week_number}_${day_number}
    RETURN    ${new_week_day_string}

Select First Employee Dynamically On Request Calendar Page On Web
    [Documentation]    Select first employee from dropdown dynamically for day off request checking
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_REQUEST_BUTTON}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_SELECT_ASSOCIATE_DROPDOWN}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_SELECT_FIRST_ASSOCIATE}
    Wait Until Page Is Loaded

Get First Employee On Request Calendar Page On Web
    [Documentation]    Get first employee name from select associate dropdown on request calendar page
    Select First Employee Dynamically On Request Calendar Page On Web
    ${first_employee_name}    Get Element Text On Webpage    ${REQUEST_CALENDAR_PAGE_SELECT_ASSOCIATE_DROPDOWN}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_DAY_OFF_CLOSE_BUTTON}
    ${formated_first_employee_name}    Clean Leading And Trailing Space On Text    ${first_employee_name}
    RETURN    ${formated_first_employee_name}

Get Request Status Text On Request Calendar Page On Web
    [Documentation]    Retrieves the status text from the request calendar page
    ...    This keyword waits for the status text element to be visible and returns its text content.
    ...    **Returns:**
    ...    - Status text from the request (e.g., "Approved", "Declined", "Not Reviewed")
    ...    **Example:**
    ...    | ${status_text} = | Get Request Status Text On Request Calendar Page On Web |
    ...    | Should Be Equal | ${status_text} | Approved |
    Wait Until Element Is Visible On Webpage    ${REQUEST_CALENDAR_PAGE_STATUS_TEXT}
    ...    error_message="Status text element not visible on Request Calendar Page within timeout"
    ${status_text}    Get Element Text On Webpage    ${REQUEST_CALENDAR_PAGE_STATUS_TEXT}
    ${formatted_status_text}    Clean Leading And Trailing Space On Text    ${status_text}
    RETURN    ${formatted_status_text}

Find Next Available Day Without Any Existing Requests On Request Calendar Page On Web
    [Documentation]    Finds the next available day for creating a new request on the Request Calendar.
    ...
    ...    Loops through remaining days in a week starting from the specified day and increments week if all days are occupied.
    ...    Clicks next week button on UI to navigate between weeks.
    ...    *Example:* If start_date is "0_3", it checks from day 3 to 6 in week 0, then day 0 to 6 in week 1.
    ...    *Arguments:*
    ...    - ``first_employee_name``: Name of the employee to check availability for
    ...    - ``start_date``: Start date for checking availability in week_day format (e.g., "0_3")
    ...    *Returns:* Available date in week_day format (e.g., "1_2")
    ...    *Example:*
    ...    | ${available_day} = | Find Next Available Day Without Any Existing Requests On Request Calendar Page On Web | ${employee_name} | 0_0 |
    [Arguments]    ${first_employee_name}    ${start_date}
    # Parse the initial week and day from start_date (format: week_day like "2_3")
    @{date_parts}    Split String    ${start_date}    _
    VAR    ${current_week}    ${date_parts}[0]
    VAR    ${start_day}    ${date_parts}[1]
    VAR    ${max_weeks_to_check}    2    # Limit to prevent infinite loop
    # Loop through weeks to find an available slot
    FOR    ${week_offset}    IN RANGE    ${max_weeks_to_check}
        ${week_to_check}    Evaluate    ${week_offset} + ${current_week}
        # For the first week, start from the specified day; for subsequent weeks, start from day 0
        ${day_to_start}    Evaluate    ${start_day} if ${week_offset} == 0 else 0
        ${available_day}    Find Available Day In Current Week On Web    ${first_employee_name}    ${week_to_check}    ${day_to_start}

        IF    '${available_day}' != '${EMPTY}'
            VAR    ${available_date}    ${week_to_check}_${available_day}
            Log    Selected date: ${available_date}
            RETURN    ${available_date}
        ELSE
            Log    Week ${week_to_check} is fully occupied from day ${day_to_start}, checking next week
            # Click next week button to navigate to next week on UI (only if not the last week to check)
            IF    ${week_offset} < ${max_weeks_to_check} - 1
                Perform Navigation To Next Week On Request Calendar Page On Web
            END
        END
    END
    # If no available slot found within limit, return original date
    Log    Warning: No available slot found within ${max_weeks_to_check} weeks. Using original date: ${start_date}
    RETURN    ${start_date}

Find Available Day In Current Week On Web
    [Documentation]    Searches for an available day within a specific week starting from the specified day
    ...    Returns immediately when first available day is found, without checking remaining days
    ...    | =Arguments= | =Description= |
    ...    | employee_name | Name of the employee to check availability for |
    ...    | week_number | Week number to check |
    ...    | start_day | Day number to start checking from (0-6), defaults to 0 |
    ...    Example usage:
    ...    | ${day}    Find Available Day In Current Week On Web    John Doe    2    3
    ...    | # Returns first available day starting from day 3 of week 2
    [Arguments]    ${employee_name}    ${week_number}    ${start_day}=0
    ${start_day_int}    Convert To Integer    ${start_day}
    FOR    ${day}    IN RANGE    ${start_day_int}    7
        VAR    ${date_to_check}    ${week_number}_${day}
        ${request_locator}    Build Request Locator For Validate Any Request Exist On Day On Request Calendar Page On Web
        ...    ${employee_name}
        ...    ${date_to_check}
        ${element_exists}    Is Element Present On Webpage    ${request_locator}
        IF    not ${element_exists}
            Log    Found available slot for ${employee_name} on ${date_to_check}
            RETURN    ${day}
        ELSE
            Log    Day off request already present for ${employee_name} on ${date_to_check}
        END
    END
    # No available day found in this week
    RETURN    ${EMPTY}

Delete Time Off Request From SM On Web
    [Documentation]    Delete time off request via SM UI if deletion is required and verify API success.
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate. |
    ...    | start_date    | Start date in week-day format. |
    ...    | reason_type    | Reason type for the time off. |
    ...    | start_time    | Start time for the time off. |
    ...    | end_time    | End time for the time off. |
    ...    | request_status    | Status of the request. |
    ...    Example usage:
    ...    | Delete Time Off Request From SM    John Doe    1_2    Vacation    09:00    10:00    Approved
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${request_status}
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Request Calendar Page On Web
    SM Delete Time Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${associate_name}
    ...    ${start_date}    ${reason_type}    ${start_time}    ${end_time}    ${request_status}

Delete Day Off Request From SM On Web
    [Documentation]    Delete day off request via SM UI if deletion is required and verify API success.
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate. |
    ...    | start_date    | Start date in week-day format. |
    ...    | request_status    | Status of the request. |
    ...    | user_key    | (Optional) User key for login. |
    ...    Example usage:
    ...    | Delete Day Off Request From SM    John Doe    1_2    Personal    Approved    SM1_STORE1
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${reason_type}
    ...    ${request_status}
    ...    ${user_key}=${None}
    IF    '${user_key}' != '${None}'
        Login And Launch WFM Web App    user_key=${user_key}
    END
    Navigate To RWS Employee Request Calendar Page On Web
    SM Delete Day Off Request Via UI On Request Calendar Page And Verify API Success On Web    ${associate_name}    ${start_date}
    ...    ${reason_type}    ${request_status}

Cleanup Existing ESS Day Off Requests From SM On Request Calendar On Web
    [Documentation]    Cleans up existing day off requests for the logged-in ESS user on the requests calendar page.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate in "LastName, FirstName" format.    |
    ...    | num_of_weeks    | Number of weeks to check for existing day off requests. Default is 1 week.    |
    ...    | specific_week_offset_day    | (Optional) Specific day to check in week-day format (e.g., "1_2").|
    [Arguments]    ${associate_name}
    ...    ${num_of_weeks}=2
    ...    ${specific_week_offset_day}=${None}
    Navigate To RWS Employee Request Calendar Page On Web
    @{name_parts}    Split String    ${associate_name}    ,
    ${last_name}    Strip String    ${name_parts}[1]
    ${day_off_request}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_DAY_OFF_REQUESTS}    ASSOCIATE_NAME=${last_name}
    IF    '${specific_week_offset_day}' != '${None}'
        Select Day On Request Calendar Page    ${specific_week_offset_day}
        Wait Until Page Is Loaded
    END
    ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${day_off_request}
    WHILE    ${is_request_visible}    limit=${LOOP_LIMIT}
        Click Element On Webpage    ${day_off_request}
        Click Delete ESS Day Off Request Button
        Verify Success Notification Toast On ESS Request Calendar Page On Web
        ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${day_off_request}
    END
    VAR    ${index}    0
    FOR    ${index}    IN RANGE    ${num_of_weeks}
        IF    ${index} > 0
            Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_NEXT_WEEK}
            Wait Until Page Is Loaded
        END
        ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${day_off_request}
        WHILE    ${is_request_visible}    limit=${LOOP_LIMIT}
            Click Element On Webpage    ${day_off_request}
            Click Delete ESS Day Off Request Button
            Verify Success Notification Toast On ESS Request Calendar Page On Web
            ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${day_off_request}
        END
    END

Verify ESS Day Off Request Notification On My Work On Web
    [Documentation]
    ...    Verifies the notification message after adding a day off request in ESS.
    ...    | =Arguments=    | =Description=    |
    ...    | request_date    | Date of the time off request in week-day format.    |
    ...    | next_week_iteration    | Number of times to click "Next Week" to find the notification. Default is 1.    |
    ...    *Returns*: The notification message text.
    ...    Example usage:
    ...    | Verify ESS Time Off Request Notification    1_2    14:00    16:00
    [Arguments]    ${request_date}    ${next_week_iteration}=1
    ${date_format}    Get Config Value    SERVER_DF
    ${formatted_date}    Calculate Date From Week Day Offset In Multiple Formats    ${request_date}    ${date_format}
    ${request_notification}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_DAY_OFF_MY_WORK_NOTIFICATION}
    ...    DATE=${formatted_date}[0]
    ${notification_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${request_notification}
    ...    timeout=${SHORT_TIMEOUT}
    # If notification is not visible, reload and navigate to My Work Page, then retry
    IF    not ${notification_visible}
        Log    Notification not visible on current page, reloading and navigating to My Work Page
        Reload Web Page
        Wait Until Element Is Visible On Webpage    ${request_notification}
    END
    IF    ${next_week_iteration} > 0
        FOR    ${_}    IN RANGE    ${next_week_iteration}
            Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_DAY_OFF_MY_WORK_NEXT_WEEK}
            Wait Until Page Is Loaded
            ${notification_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${request_notification}
            ...    timeout=${SHORT_TIMEOUT}
        END
    END

Select SM Availability Number Of Rotation On Request Calendar Page On Web
    [Documentation]    Selects the number of rotation option for availability on the request calendar page
    ...    | =Arguments= | =Description= |
    ...    | rotation_option    | The rotation option to select (e.g., "1", "2"). |
    ...    Example usage:
    ...    | Select SM Availability Number Of Rotation On Request Calendar Page On Web    1
    [Arguments]    ${rotation_option}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_CALENDAR_AVAILABILITY_ROTATION_DROPDOWN}
    ${rotation_option}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_ROTATION_OPTION}
    ...    ROTATION_TYPE=${rotation_option}
    Click Element On Webpage    ${rotation_option}

Set Availability Type On Availability Hours For Day On Web
    [Documentation]    Selects availability type for a specific day on the request calendar page
    ...    | =Arguments= | =Description= |
    ...    | day_number    | The day number (0-6) representing the day of the week. |
    ...    | availability_type    | The type of availability to set (e.g., "Totally Available"). |
    ...    | availability_row_number    | The row number for availability entry (usually 0 or 1). |
    ...    Example usage:
    ...    | Set Availability Type On Availability Hours For Day On Web    2    Totally Available    0
    [Arguments]    ${day_number}    ${availability_type}    ${availability_row_number}    ${rotation_number}
    # Construct the locator for availability type dropdown for the specific day
    ${rotation_value}    Evaluate    ${rotation_number} - 1
    ${rotation_value_str}    Convert To String    ${rotation_value}
    ${totally_available_input_day_final}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_START_INPUT}
    ...    ROTATION_VALUE=${rotation_value_str}
    ...    DAY_NUMBER=${day_number}
    ...    ROW_NUMBER=${availability_row_number}
    Click Element On Webpage    ${totally_available_input_day_final}
    Clear Textbox On Webpage    ${totally_available_input_day_final}
    Fill Textbox On Webpage    ${totally_available_input_day_final}    ${availability_type}
    # Change focus from dropdown
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_HOURS_TEXT}

Set Start And End Time For Availability Hours On Web
    [Documentation]    keyword to set start and end availability time on web page
    ...    | =Arguments= | =Description= |
    ...    | day_number    | The day number (0-6) representing the day of the week. |
    ...    | from_time    | The start time to set (e.g., "09:00 AM"). |
    ...    | to_time    | The end time to set (e.g., "05:00 PM"). |
    ...    | availability_row_number    | The row number for availability entry (usually 0 or 1). |
    ...    Example usage:
    ...    | Set Start And End Time For Availability Hours On Web    3    09:00 AM    05:00 PM    0
    [Arguments]    ${day_number}    ${from_time}    ${to_time}    ${availability_row_number}    ${rotation_number}
    # Click on Specific Day on request Calendar for adding Availability
    ${rotation_value}    Evaluate    ${rotation_number} - 1
    ${rotation_value_str}    Convert To String    ${rotation_value}
    ${totally_available_start_input}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_START_INPUT}
    ...    ROTATION_VALUE=${rotation_value_str}
    ...    DAY_NUMBER=${day_number}
    ...    ROW_NUMBER=${availability_row_number}
    Click Element On Webpage    ${totally_available_start_input}
    Clear Textbox On Webpage    ${totally_available_start_input}
    Fill Textbox On Webpage    ${totally_available_start_input}    ${from_time}
    # below code is to change focus from input - otherwise element not visible
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_HOURS_TEXT}
    ${totally_available_duration_input}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_DURATION_INPUT}
    ...    ROTATION_VALUE=${rotation_value_str}
    ...    DAY_NUMBER=${day_number}
    ...    ROW_NUMBER=${availability_row_number}
    Clear Textbox On Webpage    ${totally_available_duration_input}
    Fill Textbox On Webpage    ${totally_available_duration_input}    ${to_time}
    # below code is to change focus from input - otherwise element not visible
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_HOURS_TEXT}

Add Availability Hours On Request Calendar Page On Web
    [Documentation]    Add availability hours on request calendar page
    ...    | =Arguments= | =Description= |
    ...    | availability_hours_list    | List of availability hours details for each day. |
    ...    | availability_row_number    | The row number for availability entry (usually 0 or 1). |
    ...    | rotation_number    | Rotation number for availability hours. |
    ...    Example usage:
    ...    | Add Availability Hours On Request Calendar Page On Web    @{availability_hours}    0    1
    [Arguments]    ${availability_hours_list}    ${availability_row_number}    ${rotation_number}

    # Reorder the days based on fiscal week start while preserving timing patterns
    ${reordered_days}    Reorder Days By Fiscal Week    ${availability_hours_list}    day_number

    ${availability_days_length}    Get Length    ${reordered_days}
    FOR    ${index}    IN RANGE    0    ${availability_days_length}
        ${shift_day}    Get From List    ${reordered_days}    ${index}
        ${data_day_number}    Get From Dictionary    ${shift_day}    day_number
        ${day}    Evaluate    int(${data_day_number})
        ${start_time}    Get From Dictionary    ${shift_day}    start_time
        ${end_time}    Get From Dictionary    ${shift_day}    end_time
        # Check if start_time and end_time are "Null"
        IF    '${start_time}' == 'Null' and '${end_time}' == 'Null'
            # Use availability type from template
            ${availability_type}    Get From Dictionary    ${shift_day}    availability
            Set Availability Type On Availability Hours For Day On Web    ${day}    ${availability_type}    ${availability_row_number}
            ...    ${rotation_number}
        ELSE
            # Use time-based availability
            ${formated_start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
            ${converted_start_time}    Replace String    ${formated_start_time}    ${SPACE}    ${EMPTY}
            ${formated_end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}
            ${converted_end_time}    Replace String    ${formated_end_time}    ${SPACE}    ${EMPTY}
            Set Start And End Time For Availability Hours On Web    ${day}    ${converted_start_time}    ${converted_end_time}
            ...    ${availability_row_number}    ${rotation_number}
        END
    END

Click Add Availability Request On Request Calendar Page On Web
    [Documentation]    Clicks to add a new availability request on the request calendar page
    ...    Example usage:
    ...    | Click Add Availability Request On Request Calendar Page On Web
    Wait Until Spinner Disappears On Request Calendar Page On Web
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_REQUEST_BUTTON}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_AVAILABILITY_REQUEST}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ASSOCIATE_START_DATE_AVAILABILITY}
    Wait Until Element Is Visible On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}

Select SM Availability Reason On Request Calendar Page On Web
    [Documentation]    Selects the reason for availability on the request calendar page
    ...    | =Arguments= | =Description= |
    ...    | reason_type    | The reason type to select for availability. |
    ...    Example usage:
    ...    | Select SM Availability Reason On Request Calendar Page On Web    Personal
    [Arguments]    ${reason_type}
    ${status}    Is Element Visible On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON_DROPDOWN}
    IF    ${status}
        Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON_DROPDOWN}
        ${reason_option}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON_OPTION}
        ...    REASON_TYPE=${reason_type}
        Click Element On Webpage    ${reason_option}
    END

Fill Availability Request Form On Request Calendar Page On Web
    [Documentation]    Fills the availability request form on the request calendar page and returns the status text.
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate. |
    ...    | start_date    | Start date in week-day format. |
    ...    | reason    | Reason for the availability request. |
    ...    | rotation_number    | Rotation number for the availability. |
    ...    | availability_hours_list    | List of availability hours details for each day. |
    ...    | availability_row_number    | The row number for availability entry (usually 0 or 1). |
    ...    | availability_rotation_number    | Rotation number for availability hours. |
    ...
    ...    **Returns:**
    ...    - Status text from the request (e.g., "Approved", "Declined", "Not Reviewed")
    ...
    ...    Example usage:
    ...    | ${status} = | Fill Availability Request Form On Request Calendar Page On Web | John Doe | 2_3 | Personal | 1 | @{availability_hours} | 0 | 1 |
    [Arguments]    ${associate_name}
    ...    ${preference_option_availability}
    ...    ${pw_date}
    ...    ${reason_type}
    ...    ${rotation_number}
    ...    ${availability_hours_list}
    ...    ${availability_row_number}
    ...    ${availability_rotation_number}
    Click Add Availability Request On Request Calendar Page On Web
    Select Associate On SM Request Calendar Page On Web    ${associate_name}
    Select Request Preference On SM Request Calendar Page On Web    ${preference_option_availability}
    Input Date In Date Picker Through Input Box    ${REQUEST_CALENDAR_PAGE_START_DATE}    ${pw_date}
    ${status_text}    Get Request Status Text On Request Calendar Page On Web
    Select SM Availability Reason On Request Calendar Page On Web    ${reason_type}
    ${is_rotation_dropdown_visible}    Is Element Visible On Webpage    ${REQUEST_CALENDAR_PAGE_CALENDAR_AVAILABILITY_ROTATION_DROPDOWN}
    IF    '${preference_option_availability}' == 'Permanent' and ${is_rotation_dropdown_visible}
        Select SM Availability Number Of Rotation On Request Calendar Page On Web    ${rotation_number}
    END
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}
    Add Availability Hours On Request Calendar Page On Web    ${availability_hours_list}    ${availability_row_number}
    ...    ${availability_rotation_number}
    RETURN    ${status_text}

Submit Availability Request On Request Calendar Page On Web And Verify API Response
    [Documentation]    Submits the availability request on the request calendar page and verifies the API response
    ...    Example usage:
    ...    | Submit Availability Request On Request Calendar Page On Web And Verify API Response
    ${promise}    Promise To    Wait For Response    ${SM_ADD_AVAILABILITY_API_REGEX}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_ASSOCIATE_SUBMIT_BUTTON_AVAILABILITY}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification
    Wait Until Spinner Disappears On Request Calendar Page On Web

Create SM Availability Request On Request Calendar Page On Web And Verify API Response
    [Documentation]    Creates an availability request, verifies the API response, and returns the status text.
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate. |
    ...    | start_date    | Start date in week-day format (e.g., "2_3"). |
    ...    | reason    | Reason for the availability. |
    ...    | rotation_number    | Rotation number for the availability. |
    ...    | availability_hours_list    | List of availability hours details for each day. |
    ...    | availability_row_number    | The row number for availability entry (usually 0 or 1). |
    ...    | availability_rotation_number    | Rotation number for availability hours. |
    ...
    ...    **Returns:**
    ...    - Status text from the request (e.g., "Approved", "Declined", "Not Reviewed")
    ...
    ...    Example usage:
    ...    | ${status} = | Create SM Availability Request On Request Calendar Page On Web And Verify API Response | John Doe | 2_3 | Personal | 1 | @{hours} | 0 | 1 |
    [Arguments]    ${associate_name}
    ...    ${preference_option_availability}
    ...    ${start_date}
    ...    ${reason}
    ...    ${rotation_number}
    ...    ${availability_hours_list}
    ...    ${availability_row_number}
    ...    ${availability_rotation_number}
    ${status_text}    Fill Availability Request Form On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${preference_option_availability}
    ...    ${start_date}
    ...    ${reason}
    ...    ${rotation_number}
    ...    ${availability_hours_list}
    ...    ${availability_row_number}
    ...    ${availability_rotation_number}
    Submit Availability Request On Request Calendar Page On Web And Verify API Response
    RETURN    ${status_text}

Verify SM Availability Request On Request Calendar Page On Web
    [Documentation]    Verify a specific availability request on the request calendar page based on given parameters.
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate in "FirstName,LastName" format. |
    ...    | start_date    | Start date in week-day format (e.g., "2_3"). |
    ...    | request_type    | Type of the availability request. |
    ...    | Pre_status    | Status of the availability request. |
    ...    Example usage:
    ...    | Verify SM Availability Request On Request Calendar Page On Web    John,Doe    2_3    Personal    Approved
    [Arguments]    ${associate_name}    ${start_date}    ${request_type}    ${Pre_status}
    Wait Until Page Is Loaded
    ${request_locator}    Build SM Availability Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${Pre_status}
    Wait Until Element Is Visible On Webpage    ${request_locator}    timeout=${LONG_TIMEOUT}
    ...    error_message=Availability request not visible on calendar page within timeout

Edit SM Availability Request On Request Calendar Page On Web And Verify API Response
    [Documentation]    Edits an existing availability request and verifies the API response.
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate in "FirstName,LastName" format. |
    ...    | start_date    | Start date in week-day format (e.g., "2_3"). |
    ...    | request_type    | Type of the availability request. |
    ...    | Pre_status    | Status of the availability request. |
    ...    | availability_hours_list    | List of availability hours details for each day. |
    ...    | availability_row_number    | The row number for availability entry (usually 0 or 1). |
    ...    | rotation_number    | Rotation number for the availability. |
    ...    Example usage:
    ...    | Edit SM Availability Request On Request Calendar Page On Web And Verify API Response
    ...    John,Doe    2_3    Personal    Approved    @{availability_hours}    0    1
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${Pre_status}
    ...    ${availability_hours_list}
    ...    ${availability_row_number}
    ...    ${rotation_number}
    # Click on existing availability request to edit
    Click SM Availability Request On Request Calendar Page On Web
    ...    ${associate_name}    ${start_date}    ${request_type}    ${Pre_status}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}
    Add Availability Hours On Request Calendar Page On Web    ${availability_hours_list}    ${availability_row_number}
    ...    ${rotation_number}
    Submit Availability Request On Request Calendar Page On Web And Verify API Response

Click SM Availability Request On Request Calendar Page On Web
    [Documentation]    Clicks on a specific availability request on the request calendar page based on given parameters.
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate in "FirstName,LastName" format. |
    ...    | start_date    | Start date in week-day format (e.g., "2_3"). |
    ...    | request_type    | Type of the availability request. |
    ...    | Pre_status    | Status of the availability request. |
    ...    Example usage:
    ...    | Click SM Availability Request On Request Calendar Page On Web    John,Doe    2_3    Personal    Approved
    [Arguments]    ${associate_name}    ${start_date}    ${request_type}    ${Pre_status}
    ${request_locator}    Build SM Availability Request Locator On Request Calendar Page On Web
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${Pre_status}
    Click Element On Webpage    ${request_locator}
    Wait Until Spinner Disappears On Request Calendar Page On Web

Build SM Availability Request Locator On Request Calendar Page On Web
    [Documentation]    Builds the locator for a specific availability request on the request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate in "FirstName,LastName" format. |
    ...    | start_date    | Start date in week-day format (e.g., "2_3"). |
    ...    | request_reason    | Reason for the availability request. |
    ...    | status    | Status of the availability request. |
    ...    Example usage:
    ...    | ${locator}    Build SM Availability Request Locator On Request Calendar Page On Web
    ...    John,Doe    2_3    Personal    Approved
    [Arguments]    ${associate_name}    ${start_date}    ${request_reason}    ${status}
    @{name_parts}    Split String    ${associate_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    ${target_date}    Calculate Date From Week Day Offset    ${start_date}
    # Format the date to match the expected format (e.g., "Sun Jul 27 2025")
    ${day_only_format}    Get Config Value    key=DATE_FMT_WEEKDAY_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${target_date}    result_format=${day_only_format}
    # Build the locator string using the template with three values at a time
    ${locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_SM_AVAILABILITY_REQUEST_LOCATOR}
    ...    FIRST_NAME=${first_name}
    ...    LAST_NAME=${last_name}
    ...    REQUEST_REASON=${request_reason}
    ...    FORMATTED_DATE=${formatted_date}
    ...    STATUS=${status}
    RETURN    ${locator}

Delete SM Availability Request On Request Calendar Page On Web And Verify API Response
    [Documentation]    Deletes an availability request and verifies the API response.
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate in "FirstName,LastName" format. |
    ...    | start_date    | Start date in week-day format (e.g., "2_3"). |
    ...    | request_type    | Type of the availability request. |
    ...    | Pre_status    | Status of the availability request. |
    ...    Example usage:
    ...    | Delete SM Availability Request On Request Calendar Page On Web And Verify API Response
    ...    John,Doe    2_3    Personal    Approved
    [Arguments]    ${associate_name}    ${start_date}    ${request_type}    ${Pre_status}
    # Click on existing availability request to delete
    Click SM Availability Request On Request Calendar Page On Web
    ...    ${associate_name}    ${start_date}    ${request_type}    ${Pre_status}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}
    ${promise}    Promise To    Wait For Response    ${DELETE_SM_AVAILABILITY_API_URL}
    Delete Availability Request On Request Calendar On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Delete Availability Request On Request Calendar On Web
    [Documentation]    Delete availability request on request calendar page on web
    ...    Example usage:
    ...    | Delete Availability Request On Request Calendar On Web
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_CALENDAR_AVAILABILITY_DELETE}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_CALENDAR_AVAILABILITY_DELETE_CONFIRM}

Wait Until Spinner Disappears On Request Calendar Page On Web
    [Documentation]    Waits until the loading spinner disappears on the request calendar page.
    ${spinner_wait}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${spinner}    timeout=${SHORT_TIMEOUT}
    IF    ${spinner_wait}
        Wait Until Element Disappears On Webpage    ${spinner}
    END

Cleanup All Existing ESS Requests From SM On Request Calendar On Web
    [Documentation]    Cleans up all requests for the specified ESS user on the requests calendar page.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate in "LastName, FirstName" format.    |
    ...    | num_of_weeks    | Number of weeks to check for existing day off requests. Default is 2 weeks.    |
    ...    | specific_week_offset_day    | (Optional) Specific day to check in week-day format (e.g., "1_2").|
    [Arguments]    ${associate_name}
    ...    ${num_of_weeks}=2
    ...    ${specific_week_offset_day}=${None}
    Navigate To RWS Employee Request Calendar Page On Web
    @{name_parts}    Split String    ${associate_name}    ,
    ${last_name}    Strip String    ${name_parts}[1]
    ${all_request}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_ALL_REQUESTS}    ASSOCIATE_NAME=${last_name}
    IF    '${specific_week_offset_day}' != '${None}'
        Select Day On Request Calendar Page    ${specific_week_offset_day}
        Wait Until Page Is Loaded
    END
    Wait Until Spinner Disappears On Request Calendar Page On Web
    ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${all_request}
    WHILE    ${is_request_visible}    limit=${LOOP_LIMIT}
        Click Element On Webpage    ${all_request}
        ${next_button}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}    timeout=${SHORT_TIMEOUT}
        IF    ${next_button}
            Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}
            Delete Availability Request On Request Calendar On Web
        ELSE
            Click Delete ESS Day Off Request Button
        END
        Verify Success Toast Notification
        ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${all_request}
    END
    VAR    ${index}    0
    FOR    ${index}    IN RANGE    ${num_of_weeks}
        IF    ${index} > 0
            Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_NEXT_WEEK}
            Wait Until Page Is Loaded
        END
        Wait Until Spinner Disappears On Request Calendar Page On Web
        ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${all_request}
        WHILE    ${is_request_visible}    limit=${LOOP_LIMIT}
            Click Element On Webpage    ${all_request}
            ${next_button}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
            ...    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}    timeout=${SHORT_TIMEOUT}
            IF    ${next_button}
                Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}
                Delete Availability Request On Request Calendar On Web
            ELSE
                Click Delete ESS Day Off Request Button
            END
            Verify Success Toast Notification
            ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${all_request}
        END
    END

Select Request Preference On SM Request Calendar Page On Web
    [Documentation]    Selects the request preference option by clicking the corresponding radio button on the SM Request Calendar page.
    ...    | =Arguments=    | =Description= |
    ...    | preference_option    | The preference option to select (e.g., "Available", "Unavailable", etc.) |
    ...    Example usage:
    ...    | Select Request Preference On SM Request Calendar Page On Web    ${preference_option_availability}
    [Arguments]    ${preference_option}
    ${preference_radio_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_CATEGORY_RADIO}
    ...    CATEGORY=${preference_option}
    Click Element On Webpage    ${preference_radio_locator}
    Log    Selected request preference: ${preference_option}

Edit Status On SM Availability Request On Request Calendar Page On Web And Verify API Response
    [Documentation]    Edits the status of an existing availability request and verifies the API response.
    ...    This keyword performs the following actions:
    ...    1. Clicks on the specified availability request
    ...    2. Waits for the request details to load
    ...    3. Changes the status to the specified value
    ...    4. Submits the request and verifies the API response
    ...
    ...    | =Arguments= | =Description= |
    ...    | associate_name    | Name of the associate in "FirstName,LastName" format. |
    ...    | start_date    | Start date in week-day format (e.g., "2_3"). |
    ...    | request_type    | Type of the availability request. |
    ...    | current_status    | Current status of the availability request. |
    ...    | status_to_set    | New status to set for the request (e.g., Approved, Declined). |
    ...
    ...    Example usage:
    ...    | Edit Status On SM Availability Request On Request Calendar Page On Web And Verify API Response
    ...    | ...    John,Doe    2_3    Temporary    Pending    Approved
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${request_type}
    ...    ${current_status}
    ...    ${status_to_set}
    Click SM Availability Request On Request Calendar Page On Web
    ...    ${associate_name}    ${start_date}    ${request_type}    ${current_status}
    Select SM Availability Request Status On Request Calendar Page On Web    ${status_to_set}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}
    Submit Availability Request On Request Calendar Page On Web And Verify API Response
    Log    Successfully changed availability request status from '${current_status}' to '${status_to_set}'

Select SM Availability Request Status On Request Calendar Page On Web
    [Documentation]    Selects the status for availability request from the dropdown.
    ...    This keyword clicks on the status dropdown and selects the specified status option.
    ...    | =Arguments= | =Description= |
    ...    | status | The status to select from dropdown (e.g., Not Reviewed, Approved, Declined) |
    ...
    ...    Example usage:
    ...    | Select SM Availability Request Status On Request Calendar Page On Web | Approved |
    [Arguments]    ${status}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_SELECT_STATUS_VALUE}
    ${status_option_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_STATUS_OPTION}
    ...    STATUS=${status}
    Click Element On Webpage    ${status_option_locator}

Click Decline Selected Bulk Requests On Request Calendar Page On Web
    [Documentation]    Click the decline button for selected requests in bulk
    Wait For Elements State    ${SM_BULK_DECLINE_BUTTON}    enabled    timeout=${SHORT_TIMEOUT}
    Click Element On Webpage    ${SM_BULK_DECLINE_BUTTON}

Click Decline Button On List View And Verify API Success On Request Calendar Page On Web
    [Documentation]    Click the decline button and verifies the API response
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    ${promise}    Promise To    Wait For Response    ${APPROVE_SELECTED_DAY_OFF_BULK_SM_API_REGEX}
    Click Decline Selected Bulk Requests On Request Calendar Page On Web
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Build Availability Request Checkbox Locator On List View On Request Calendar Page On Web
    [Documentation]    Builds the locator for an availability request checkbox on list view
    [Arguments]    ${associate_name}    ${start_date}    ${reason_type}
    ${date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${formatted_date}    Calculate Date From Week Day Offset In Multiple Formats    ${start_date}    ${date_format}
    VAR    ${locator}
    ...    xpath=//div[contains(@aria-label, '${associate_name}') and contains(@aria-label, 'Availability') and contains(@aria-label, '${reason_type}') and contains(@aria-label, '${formatted_date}[0]')]//input[@type='checkbox']
    RETURN    ${locator}

Apply Request Filter On Request Calendar Page On Web
    [Documentation]    Applies the request filter on the request calendar page based on the given filter criteria.
    ...    | =Arguments= | =Description= |
    ...    | filter_data | Dictionary containing filter criteria (request_type and request_status) |
    ...    Example usage:
    ...    | VAR    &{filter_data}    request_type=BulkRequestType.ALL    request_status=BulkRequestStatus.APPROVED
    ...    | Apply Request Filter On Request Calendar Page On Web    ${filter_data}
    [Arguments]    ${filter_data}
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_FILTER_BUTTON}

    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_FILTER_REQUEST_TYPE_DROPDOWN}
    ${type_option}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_FILTER_TYPE_OPTION}
    ...    REQUEST_TYPE=${filter_data}[request_type]
    Click Element On Webpage    ${type_option}

    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_FILTER_REQUEST_STATUS_DROPDOWN}
    ${status_option}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_FILTER_STATUS_OPTION}
    ...    REQUEST_STATUS=${filter_data}[request_status]
    Click Element On Webpage    ${status_option}

    Click Element On Webpage    ${SM_REQUEST_DROPDOWN_APPLY_BUTTON}
    Wait Until Page Is Loaded    timeout=${MEDIUM_TIMEOUT}

Click Group By Button On Request Calendar Page On Web
    [Documentation]    Clicks the Group By button to group selected requests.
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_GROUP_BY_BUTTON}
    Wait Until Element Disappears On Webpage    ${REQUEST_CALENDAR_PAGE_GROUP_BY_BUTTON}
    Log    Clicked Group By button    level=INFO

Select Multiple Requests By Request Type On List View Request Calendar Page On Web
    [Documentation]    High-level wrapper to select multiple requests of the same type and group them.
    ...    Consolidates the repetitive pattern of: View All -> Select Checkboxes -> Group By.
    ...
    ...    Arguments:
    ...    - request_type: Type of request (Day Off, Time Off, Availability)
    ...    - request_selections: List of dictionaries containing 'associate_name' and 'date' keys
    ...
    ...    Each dictionary in request_selections should have:
    ...    - associate_name: Display name of the associate
    ...    - date: Date for the request (use ${NONE} for availability requests)
    ...
    ...    Example:
    ...    | ${day_off_selections}= | Create List |
    ...    | ... | &{dict1} | associate_name=${user1}[displayName] | date=8_1 |
    ...    | ... | &{dict2} | associate_name=${user2}[displayName] | date=8_2 |
    ...    | Group Multiple Requests By Type On Request Calendar | ${day_off_request} | ${day_off_selections} |
    [Arguments]    ${request_type}    ${request_selections}
    Click View All For Request Type On Request Calendar Page On Web    ${request_type}

    # Iterate through list and select each request checkbox
    FOR    ${selection}    IN    @{request_selections}
        Select Request Checkbox Dynamically On Request Calendar Page On Web
        ...    ${selection}[associate_name]    ${selection}[date]
    END

    Click Group By Button On Request Calendar Page On Web
    ${count}    Get Length    ${request_selections}
    Log    Selected and grouped ${count} request(s) for ${request_type}    level=INFO

Click View All For Request Type On Request Calendar Page On Web
    [Documentation]    Clicks the View All button for a specific request type.
    ...    Uses dynamic locator based on request type name.
    ...
    ...    Arguments:
    ...    - request_type: Type of request (Day Off, Time Off, Availability)
    ...
    ...    Example:
    ...    | Click View All For Request Type On Request Calendar Page On Web | Day Off |
    [Arguments]    ${request_type}
    ${view_all_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_VIEW_ALL_BY_REQUEST_TYPE}
    ...    REQUEST_TYPE=${request_type}
    Click Element On Webpage    ${view_all_locator}
    Wait Until Element Disappears On Webpage    ${view_all_locator}
    Log    Clicked View All for ${request_type} requests    level=INFO

Select Request Checkbox Dynamically On Request Calendar Page On Web
    [Documentation]    Selects a request checkbox by associate name and optionally date using dynamic locator.
    ...    Formats the date and builds dynamic xpath to find checkbox.
    ...    For availability requests, date is not required (pass ${NONE} or omit).
    ...
    ...    Arguments:
    ...    - associate_name: Full display name of the associate
    ...    - start_date: Date in week_day format (e.g., '2_3') or ${NONE} for availability
    ...
    ...    Examples:
    ...    | Select Request Checkbox Dynamically On Request Calendar Page On Web | StoreZ2, Associate04 | 2_3 |
    ...    | Select Request Checkbox Dynamically On Request Calendar Page On Web | StoreZ2, Associate04 | ${NONE} |
    [Arguments]    ${associate_name}    ${start_date}=${NONE}
    IF    $start_date == $NONE
        # Availability request - no date needed
        ${checkbox_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_CHECKBOX_DYNAMIC}
        ...    ASSOCIATE_NAME=${associate_name}
        Log    Using availability checkbox locator (no date) for ${associate_name}    level=INFO
    ELSE
        # Day Off or Time Off request - date needed
        ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
        ${formatted_date}    Calculate Date From Week Day Offset    ${start_date}    date_format=${date_format}
        ${checkbox_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_REQUEST_CHECKBOX_DYNAMIC}
        ...    ASSOCIATE_NAME=${associate_name}    DATE=${formatted_date}
        Log    Using date-based checkbox locator for ${associate_name} on ${formatted_date}    level=INFO
    END
    Click Element On Webpage    ${checkbox_locator}
    Log    Selected request checkbox for ${associate_name}    level=INFO

Verify SM Day Off Request On Line View On Request Calendar Page On Web
    [Documentation]    Verifies a day off request is visible on line view by building locator and checking visibility.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "StoreZ2, Associate04"). |
    ...    | start_date | Start date in week-day format (e.g., "8_1"). |
    ...    | end_date | End date in week-day format (e.g., "8_1"). |
    ...    | request_status | Status of the request (e.g., "Approved", "Declined", "Not Reviewed"). |
    ...    Example usage:
    ...    | Verify SM Day Off Request On Line View On Request Calendar Page On Web | John, Doe | 8_1 | 8_1 | Approved |
    [Arguments]    ${associate_name}    ${start_date}    ${end_date}    ${request_status}
    ${locator}    Build SM Day Off Request Locator On Line View On Request Calendar Page On Web
    ...    ${associate_name}    ${start_date}    ${end_date}    ${request_status}
    Wait Until Element Is Visible On Webpage    ${locator}
    Log    Verified Day Off request for ${associate_name} on ${start_date} with status ${request_status}    level=INFO

Verify SM Time Off Request On Line View On Request Calendar Page On Web
    [Documentation]    Verifies a time off request is visible on line view by building locator and checking visibility.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "StoreZ2, Associate04"). |
    ...    | start_date | Start date in week-day format (e.g., "8_1"). |
    ...    | start_time | Start time of the time off (e.g., "20:00"). |
    ...    | end_time | End time of the time off (e.g., "00:00"). |
    ...    | request_status | Status of the request (e.g., "Approved", "Declined", "Not Reviewed"). |
    ...    Example usage:
    ...    | Verify SM Time Off Request On Line View On Request Calendar Page On Web | John, Doe | 8_1 | 20:00 | 00:00 | Approved |
    [Arguments]    ${associate_name}    ${start_date}    ${start_time}    ${end_time}    ${request_status}
    ${locator}    Build SM Time Off Request Locator On Line View On Request Calendar Page On Web
    ...    ${associate_name}    ${start_date}    ${start_time}    ${end_time}    ${request_status}
    Wait Until Element Is Visible On Webpage    ${locator}
    Log    Verified Time Off request for ${associate_name} on ${start_date} with status ${request_status}    level=INFO

Verify SM Availability Request On Line View On Request Calendar Page On Web
    [Documentation]    Verifies an availability request is visible on line view by building locator and checking visibility.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "StoreZ2, Associate04"). |
    ...    | start_date | Start date in week-day format (e.g., "8_0"). |
    ...    | request_status | Status of the request (e.g., "Approved", "Declined", "Not Reviewed"). |
    ...    Example usage:
    ...    | Verify SM Availability Request On Line View On Request Calendar Page On Web | John, Doe | 8_0 | Approved |
    [Arguments]    ${associate_name}    ${start_date}    ${request_status}
    # Get the reason from availability data - assuming it's "Busy Week" as per the default template
    ${reason}    Get System Value    AvailabilityReasonType    BUSY_WEEK
    ${locator}    Build SM Availability Request Locator On Line View On Request Calendar Page On Web
    ...    ${associate_name}    ${start_date}    ${reason}    ${request_status}
    Wait Until Element Is Visible On Webpage    ${locator}
    Log    Verified Availability request for ${associate_name} starting ${start_date} with status ${request_status}    level=INFO

Skip If Request Is Present On Day For Employee On Request Calendar Page On Web
    [Documentation]    Skips the test if a request is already present on the specified day for the employee on the request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "StoreZ2, Associate04"). |
    ...    | start_date | Start date in week-day format (e.g., "8_1"). |
    ...    Example usage:
    ...    | Skip If Request Is Present On Day For Employee On Request Calendar Page On Web | John, Doe | 8_1 |
    [Arguments]    ${associate_name}    ${start_date}
    ${start_target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${day_locator_format}    Get Config Value    key=DATE_FMT_WEEKDAY_MONTH_DAY_YEAR
    ${start_formatted}    Convert Date    ${start_target_date}    result_format=${day_locator_format}
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${LOAD_SPINNER}
    Wait Until Element Disappears On Webpage    ${LOAD_SPINNER}    timeout=${LONG_TIMEOUT}
    ${day_request_locator}    Update Locator With Dynamic Values    ${REQUEST_CALENDAR_PAGE_DAY_REQUEST}
    ...    EMP_NAME=${associate_name}    START_DATE=${start_formatted}
    ${is_request_already_present_on_day}    Is Element Present On Webpage    ${day_request_locator}
    Skip If    ${is_request_already_present_on_day}
    ...    Day off request for ${associate_name} on ${start_formatted} is already present on the calendar, skipping creation.

Check If Day Offset Value Applicable And Within Range On Web
    [Documentation]    Skips the test if the number of days required for a day off request is out of the specified range.
    ...    | =Arguments= | =Description= |
    ...    | user_credentials_data | User credentials data of the associate. |
    ...    | reason | Reason type for the request being validated (for example, "Paid Vacation"). |
    ...    | offset_value_to_be_checked | Week day offset value to validate against configured required days or SYS_MIN_LEAD_TIME (for example, "1_7"). |
    ...    | request_type | Type of request to validate. Supported values are "Day Off" and "Time Off". Default is "Day Off". |
    ...    | =Returns= | =Description= |
    ...    | is_within_range | True if the number of days required for a request is within the range of the week day offset value; otherwise, the test is skipped. |
    ...    Example usage:
    ...    | ${is_within_range}    Check If Day Offset Value Applicable And Within Range On Web    ${user_credentials_data}    Paid Vacation    1_7    Time Off |
    [Arguments]    ${user_credentials_data}    ${reason}    ${offset_value_to_be_checked}    ${request_type}=Day Off
    IF    '${request_type}' == 'Day Off'
        ${number_of_days}    ${sys_min_lead_time}    Get Number Of Days And Min Lead Time For Day Off Request From DB   ${user_credentials_data}    ${reason}
    ELSE IF    '${request_type}' == 'Time Off'
        ${number_of_days}    ${sys_min_lead_time}    Get Number Of Days And Min Lead Time For Time Off Request From DB   ${user_credentials_data}    ${reason}
    ELSE
        Log    Request type is not Day Off or Time Off; skipping offset check.    level=WARN
        RETURN    False
    END
    VAR    ${offset_within_range}    False
    VAR    ${min_lead_time_within_range}    False
    IF    '${number_of_days}' != '${EMPTY}'
        ${days_within_range_of_offset}    Is Number Of Days Within Range Of Week Day Offset Value On Web    ${number_of_days}    ${offset_value_to_be_checked}
        IF    not ${days_within_range_of_offset}
            Skip
            ...    msg=Number of days required for ${request_type} request is not within range of week day offset value provided; skipping the test execution. Required number of days: ${number_of_days}
        ELSE
            VAR    ${offset_within_range}    True
        END
    END
    IF    '${sys_min_lead_time}' != '${EMPTY}'
        ${lead_time_within_range_of_offset}    Is Number Of Days Within Range Of Week Day Offset Value On Web    ${sys_min_lead_time}    ${offset_value_to_be_checked}
        IF    not ${lead_time_within_range_of_offset}
            Skip
            ...    msg=System minimum lead time for ${request_type} request is not within range of week day offset value provided; skipping the test execution. Minimum lead time: ${sys_min_lead_time}
        ELSE
            VAR    ${min_lead_time_within_range}    True
        END
    END
    VAR    ${is_offset_check_applicable}    False
    IF    ${offset_within_range} or ${min_lead_time_within_range}
        VAR    ${is_offset_check_applicable}    True
    END
    RETURN    ${is_offset_check_applicable}

Click On Next Button In Request Calendar Add Availability Request Page On Web
    [Documentation]    Clicks the next button in the add availability request form on the request calendar page
    ...    Example usage:
    ...    | Click On Next Button In Request Calendar Add Availability Request Page On Web
    Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON}
    ...    error_message="Next button not clickable on Add Availability Request form within timeout"
    Wait Until Element Is Visible On Webpage    ${REQUEST_CALENDAR_PAGE_ADD_AVAILABILITY_PAGE_HOURS_TAB_ACTIVE}    timeout=${LONG_TIMEOUT}
    ...    error_message="Availability hours not visible after clicking Next button on Add Availability Request form within timeout"
