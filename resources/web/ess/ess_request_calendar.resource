*** Settings ***
Documentation       Resource file containing keywords for ESS (Employee Self Service) request calendar functionality.
...                 Provides functions for day off request creation, verification, and management from the ESS user perspective.

Library             DateTime
Library             test_data/TestDataLibrary.py
Variables           resources/web/ess/ess_request_calendar_api.py
Variables           resources/web/ess/ess_request_calendar_page.py
Variables           resources/web/common/menu_page.py
Variables           resources/web/common/status_codes.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/common_date_utility.resource
Resource            resources/web/common/request_calendar_utility.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To ESS Request Calendar Page
    [Documentation]    Navigate To ESS -> Request Calendar -> Request Calendar Page
    ...    and verifies request calendar heading at the top of the page
    Navigate To Specific Page On Web    ess    request_calendar

Navigate To Web My Work Page On Web
    [Documentation]    Navigates to the My Work page in the web application.
    # don't remove the Set Selector Prefix value in this keyword
    Set Selector Prefix    ${NONE}
    Click Element On Webpage    ${MY_WORK_LOCATOR}

Create ESS Day Off Request And Verify API Success
    [Documentation]
    ...    Creates a day off request as ESS and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | start_date    | Start date for the day off request.    |
    ...    | end_date    | End date for the day off request.    |
    ...    | reason_type    | Reason for the day off.    |
    ...    | holiday_hours    | (Optional) Dictionary mapping day numbers (1=Sun to 7=Sat) to holiday hours (e.g., {"2": "8", "3": "5"}).    |
    ...    Example usage:
    ...    | ESS Create Day Off Request And Verify API Success    1_2    1_3    Vacation    {"2": "8", "3": "5"}
    [Arguments]    ${start_date}    ${end_date}    ${reason_type}    ${holiday_hours}=${None}
    Fill Form For ESS Add Day Off Request
    ...    ${start_date}
    ...    ${end_date}
    ...    ${reason_type}
    IF    $holiday_hours != $None
        Enter Holiday Hours For ESS Day Off Request    ${holiday_hours}
    END
    ${promise}    Promise To    Wait For Response    ${ADD_DAY_OFF_API_REGEX_ESS}
    Click Element On Webpage    ${ESS_REQUEST_SAVE_BUTTON}
    ${response_body}    Wait For    ${promise}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    RETURN    ${response_body.body.metaInfo.addedDayoffRequestObject}

Enter Holiday Hours For ESS Day Off Request
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
        ...    ${ESS_REQUEST_CALENDAR_PAGE_HOLIDAY_HOURS_INPUT}
        ...    DAY=${day_num_string}
        Wait Until Element Is Visible On Webpage    ${holiday_hours_input_locator}
        Clear Textbox On Webpage    ${holiday_hours_input_locator}
        Fill Textbox On Webpage    ${holiday_hours_input_locator}    ${hours}
        Log    Entered ${hours} holiday hours for day ${day_num}
    END

Fill Form For ESS Add Day Off Request
    [Documentation]
    ...    Submits a day off request as an ESS user.
    ...    | =Arguments=    | =Description=    |
    ...    | start_date    | Start date for the day off request.    |
    ...    | end_date    | End date for the day off request.    |
    ...    | reason    | Reason for the day off.    |
    ...    Example usage:
    ...    | Fill Form For ESS Add Day Off Request    1_2    1_3    Vacation
    [Arguments]    ${start_date}    ${end_date}    ${reason}
    Click On ESS Add Request Button
    Select Request Type On ESS Request Calendar Page    Day Off
    Input Date In Date Picker Through Input Box    ${ESS_REQUEST_CALENDAR_PAGE_START_DATE}    ${start_date}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    Input Date In Date Picker Through Input Box    ${ESS_REQUEST_CALENDAR_PAGE_END_DATE}    ${end_date}
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    Select Reason Type For ESS Day Off Request    ${reason}
    Verify ESS Add Day OFF Request Default Status As Not Reviewed
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}

Click On ESS Add Request Button
    [Documentation]    keyword to click on the Add Request button on ESS Request Calendar Page
    ...    Example usage: | Click On ESS Add Request Button
    ...    Waits for the Add Request button to be visible and clicks it.
    ...    Handles potential delays if MYWORK feature is enabled.
    ${mywork_enabled}    Get Config Value    key=MYWORK_ENABLED
    # added sleep because of delay in loading Add Request button when MYWORK is enabled
    IF    ${mywork_enabled}    # Sleep    3s
        Wait Until Element Is Visible On Webpage    ${ESS_ADD_REQUEST_BUTTON}
    END
    Click Element On Webpage    ${ESS_ADD_REQUEST_BUTTON}    error_message=Failed to click on Add Request button on ESS Request Calendar Page
    ${request_type_options_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${ESS_ADD_REQUEST_TYPE_BUTTON}    timeout=${MEDIUM_TIMEOUT}
    IF    not ${request_type_options_visible}
        Click Element On Webpage    ${ESS_ADD_REQUEST_BUTTON}    error_message=Failed to click on Add Request button on ESS Request Calendar Page
    END

Select Request Type On ESS Request Calendar Page
    [Documentation]
    ...    Selects a request type (Availability, Time Off, Day Off) from the dropdown.
    ...    | =Arguments=    | =Description=    |
    ...    | request_type | The type of request to select from dropdown.    |
    ...    Example usage:
    ...    | Select Request Type On ESS Request Calendar Page    Day Off
    [Arguments]    ${request_type}
    Select List Item On Webpage    ${ESS_REQUEST_TYPE_DROPDOWN}    label    ${request_type}

Select Reason Type For ESS Day Off Request
    [Documentation]
    ...    Selects a reason type (Availability, Time Off, Day Off) from the dropdown.
    ...    | =Arguments=    | =Description=    |
    ...    | reason_type    | The reason to select from dropdown.    |
    ...    Example usage:
    ...    | Select Reason Type For ESS Day Off Request    Vacation
    [Arguments]    ${reason_type}
    Click Element On Webpage    ${ESS_REASON_TYPE_DROPDOWN}
    ${selected}    Select Options By    ${ESS_REASON_TYPE_DROPDOWN}    label    ${reason_type}
    List Should Contain Value    ${selected}    ${reason_type}
    Click Element On Webpage    ${ESS_REASON_TYPE_DROPDOWN}

Verify ESS Add Day OFF Request Default Status As Not Reviewed
    [Documentation]    Verifies the default status of the day off request
    # Wait for the success message to appear
    Wait For Elements State
    ...    ${Add_DAY_OFF_DEFAULT_STATUS_ESS}
    ...    visible
    ...    timeout=${MEDIUM_TIMEOUT}

Click ESS Day Off Request Save Button
    [Documentation]    Clicks the save button for day off request
    ${promise}    Promise To    Wait For Response    ${UPDATE_DAY_OFF_API_REGEX_ESS}
    Click Element On Webpage    ${ESS_REQUEST_SAVE_BUTTON}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Verify ESS Day Off Request Status
    [Documentation]    Verifies the status of the day off request
    [Arguments]    ${associate_name}    ${start_date}    ${request_status}
    Select Day On Request Calendar Page    ${start_date}
    ${request_locator}    Build ESS Day Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${request_status}
    ...    request_type=Day Off
    Click Element On Webpage    ${request_locator}
    Verify Request Status On ESS Request Calendar Page    ${request_status}

Build ESS Day Off Request Locator
    [Documentation]
    ...    Builds a locator for a day off request based on associate, date, status, and request type.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | status    | Status of the request.    |
    ...    | request_type    | Type of the request (e.g., Day Off).    |
    ...    Example usage:
    ...    | Build ESS Day Off Request Locator    John Doe    1_2    Approved    Day Off
    [Arguments]    ${associate_name}    ${start_date}    ${status}    ${request_type}
    @{name_parts}    Split String    ${associate_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    ${target_date}    Calculate Date From Week Day Offset    ${start_date}
    ${formatted_date}    Convert Date    ${target_date}    result_format=%a %b %d %Y
    VAR    ${locator}
    ...    //div[contains(@aria-label, '${status}') and contains(@aria-label, '${request_type}') and contains(@aria-label, '${formatted_date}') and contains(@aria-label, '${first_name}') and contains(@aria-label, '${last_name}')]
    RETURN    ${locator}

Verify Request Status On ESS Request Calendar Page
    [Documentation]
    ...    Verifies if the request status matches the expected status.
    ...    | =Arguments=    | =Description=    |
    ...    | expected_status    | The expected status to verify against.    |
    ...    Example usage:
    ...    | Verify Request Status On ESS Request Calendar Page    Approved
    [Arguments]    ${expected_status}
    ${status_text}    Get Element Text On Webpage    (//td[normalize-space()='${expected_status}'])[1]
    Should Contain
    ...    ${status_text}
    ...    ${expected_status}
    ...    message=Request status should be '${expected_status}' but was '${status_text}'

Create ESS Time Off Request And Verify API Success
    [Documentation]
    ...    Creates a time off request as ESS and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | start_date    | Start date for the time off request.    |
    ...    | start_time    | Start time for the time off.    |
    ...    | duration    | Duration of the time off in hours.    |
    ...    | reason    | Reason for the time off.    |
    ...    | comment    | Comment/note for the manager.    |
    ...    Example usage:
    ...    | ESS Create Time Off Request And Verify API Success    1_2    14:00    2    Medical    Feeling unwell
    [Arguments]    ${start_date}    ${start_time}    ${duration}    ${reason}    ${comment}=employee Comment
    Fill Form For ESS Add Time Off Request    ${start_date}
    ...    ${start_time}
    ...    ${duration}
    ...    ${reason}
    ...    ${comment}
    ${promise}    Promise To    Wait For Response    ${ADD_TIMEOFF_API_REGEX_ESS}
    Click ESS Time Off Request Save Button
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Should Be Equal As Strings    ${response_body.status}    200
    RETURN    ${response_body.body.metaInfo.addedTimeoffRequestObject}

Fill Form For ESS Add Time Off Request
    [Documentation]
    ...    Submits a time off request as ESS user with the provided details.
    ...    | =Arguments=    | =Description=    |
    ...    | start_date    | Start date for the time off request.    |
    ...    | start_time    | Start time for the time off.    |
    ...    | duration    | Duration of the time off in hours.    |
    ...    | reason    | Reason for the time off.    |
    ...    Example usage:
    ...    | Fill Form For ESS Add Time Off Request    1_2    14:00    2    Medical
    [Arguments]    ${start_date}    ${start_time}    ${duration}    ${reason}    ${comment}=employee Comment
    Click On ESS Add Request Button
    Select Request Type On ESS Request Calendar Page    Time Off
    Input Date In Date Picker Through Input Box    ${ESS_REQUEST_CALENDAR_PAGE_START_DATE}    ${start_date}
    # No end date required for Time Off as it's only for one day
    Enter Start Time For ESS Time Off Request    ${start_time}
    Click Element On Webpage    ${ADD_TIME_OFF_DURATION_TIME}
    Enter Duration Time For ESS Time Off Request    ${duration}
    Select Reason Type For ESS Time Off Request    ${reason}
    Enter Note To Manager For ESS Time Off Request    ${comment}
    Verify Add ESS Time OFF Request Default Status As Not Reviewed
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}

Select Reason Type For ESS Time Off Request
    [Documentation]
    ...    Selects the reason for time off request from dropdown.
    ...    | =Arguments=    | =Description=    |
    ...    | reason_type    | The reason to select from dropdown.    |
    ...    Example usage:
    ...    | Select Reason Type For ESS Time Off Request    Medical
    [Arguments]    ${reason_type}
    Click Element On Webpage    ${ESS_REASON_TYPE_DROPDOWN}
    ${selected}    Select Options By    ${ESS_REASON_TYPE_DROPDOWN}    label    ${reason_type}
    List Should Contain Value    ${selected}    ${reason_type}

Click ESS Time Off Request Save Button
    [Documentation]
    ...    Clicks the save button for time off request.
    ...    Used after filling the time off request form to save the request.
    ...    Example usage:
    ...    | Click ESS Time Off Request Save Button
    Click Element On Webpage    ${ESS_REQUEST_SAVE_BUTTON}

Enter Start Time For ESS Time Off Request
    [Documentation]
    ...    Enters the start time for a time off request.
    ...    | =Arguments=    | =Description=    |
    ...    | start_time    | The start time to enter (e.g., 14:00).    |
    ...    Example usage:
    ...    | Enter Start Time For ESS Time Off Request    14:00
    [Arguments]    ${start_time}
    Wait Until Element Is Visible On Webpage    ${ADD_TIME_OFF_START_TIME}
    Clear Textbox On Webpage    ${ADD_TIME_OFF_START_TIME}
    Fill Textbox On Webpage    ${ADD_TIME_OFF_START_TIME}    ${start_time}

Enter Duration Time For ESS Time Off Request
    [Documentation]    Enters the duration time for a time off request.
    ...    | =Arguments=    | =Description=    |
    ...    | duration_time    | The duration in hours to enter.    |
    ...    Example usage:
    ...    | Enter Duration Time For ESS Time Off Request    2
    [Arguments]    ${duration_time}
    Clear Textbox On Webpage    ${ADD_TIME_OFF_DURATION_TIME}
    Type Text    ${ADD_TIME_OFF_DURATION_TIME}    ${duration_time}

Enter Note To Manager For ESS Time Off Request
    [Documentation]    enter note to manager for time off request
    ...    | =Arguments=    | =Description=    |
    ...    | comment    | The comment/note to enter for the manager.    |
    [Arguments]    ${comment}
    Clear Textbox On Webpage    ${ADD_TIME_OFF_NOTE_TO_MANAGER_ESS}
    Type Text    ${ADD_TIME_OFF_NOTE_TO_MANAGER_ESS}    ${comment}

Verify Add ESS Time OFF Request Default Status As Not Reviewed
    [Documentation]
    ...    Verifies the default status of the time off request is "Not Reviewed".
    ...    Waits for the status element to become visible before verification.
    ...    Example usage:
    ...    | Verify Add ESS Time OFF Request Default Status As Not Reviewed
    # Wait for the success message to appear
    Wait For Elements State
    ...    ${Add_TIME_OFF_DEFAULT_STATUS_ESS}
    ...    visible
    ...    timeout=${MEDIUM_TIMEOUT}

Verify ESS Time Off Request Status
    [Documentation]
    ...    Verifies the status of a time off request for a specific associate.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | start_time    | Start time for the time off.    |
    ...    | end_time    | End time for the time off.    |
    ...    | request_status    | Expected status to verify.    |
    ...    Example usage:
    ...    | ESS Verify Time Off Request Status    John Doe    1_2    14:00    16:00    Approved
    [Arguments]    ${associate_name}    ${start_date}    ${start_time}    ${end_time}    ${request_status}
    Select Day On Request Calendar Page    ${start_date}
    ${request_locator}    Build ESS Time Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${request_status}
    ...    request_type=Time Off
    Click Element On Webpage    ${request_locator}
    Verify Request Status On ESS Request Calendar Page    ${request_status}

Build ESS Time Off Request Locator
    [Documentation]
    ...    Builds locator for time off request based on associate and request details.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | start_time    | Start time for the time off.    |
    ...    | end_time    | End time for the time off.    |
    ...    | request_status    | Status of the request.    |
    ...    | request_type    | Type of the request (e.g., Time Off).    |
    ...    *Returns*: Locator string for the time off request element.
    ...    Example usage:
    ...    | Build ESS Time Off Request Locator    John Doe    1_2    14:00    16:00    Approved    Time Off
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${status}
    ...    ${request_type}
    @{name_parts}    Split String    ${associate_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    ${target_date}    Calculate Date From Week Day Offset    ${start_date}
    # Format the date to match the expected format (e.g., "Sun Jul 27 2025")
    ${formatted_date}    Convert Date    ${target_date}    result_format=%a %b %d %Y
    ${start_time_12hr}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
    ${end_time_12hr}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}
    # Remove space from time format (convert "08:00 p" to "08:00p")
    ${converted_start_time}    Replace String    ${start_time_12hr}    ${SPACE}    ${EMPTY}
    ${converted_start_time}    Replace String    ${converted_start_time}    a    ${EMPTY}
    ${converted_start_time}    Replace String    ${converted_start_time}    p    ${EMPTY}
    ${converted_end_time}    Replace String    ${end_time_12hr}    ${SPACE}    ${EMPTY}
    ${converted_end_time}    Replace String    ${converted_end_time}    a    ${EMPTY}
    ${converted_end_time}    Replace String    ${converted_end_time}    p    ${EMPTY}
    VAR    ${locator}
    ...    //div[contains(@aria-label, '${status}') and contains(@aria-label, '${request_type}') and contains(@aria-label, '${formatted_date}') and contains(@aria-label, '${converted_start_time}') and contains(@aria-label, '${converted_end_time}') and contains(@aria-label, '${first_name}') and contains(@aria-label, '${last_name}')]
    RETURN    ${locator}

Cancel ESS Time Off Request And Verify API Success
    [Documentation]
    ...    Cancels a time off request as ESS and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | start_time    | Start time for the time off.    |
    ...    | end_time    | End time for the time off.    |
    ...    | request_status    | Current status of the request.    |
    ...    Example usage:
    ...    | ESS User Cancels Time Off Request And Verify API Success    John Doe    1_2    14:00    16:00    Not Reviewed
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${request_status}
    Select Day On Request Calendar Page    ${start_date}
    ${request_locator}    Build ESS Time Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${request_status}
    ...    request_type=Time Off
    Click Element On Webpage    ${request_locator}
    ${promise}    Promise To    Wait For Response    ${CANCEL_TIMEOFF_API_REGEX_ESS}
    Click Cancel ESS Time Off Request Button
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Click Cancel ESS Time Off Request Button
    [Documentation]
    ...    Clicks the cancel button for time off request.
    ...    Used after navigating to an existing time off request to cancel it.
    ...    Example usage:
    ...    | Click Cancel ESS Time Off Request Button
    Click Element On Webpage    ${ESS_REQUEST_CANCEL_BUTTON}

Delete ESS Time Off Request And Verify API Success
    [Documentation]
    ...    Deletes a time off request as ESS and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | time_off_data    | Dictionary containing time off request details.    |
    ...    Example usage:
    ...    | ESS Delete Time Off Request And Verify API Success    John Doe    ${time_off_data}
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${request_status}
    Navigate To ESS Request Calendar Page
    Select Day On Request Calendar Page    ${start_date}
    ${request_locator}    Build ESS Time Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${request_status}
    ...    request_type=Time Off
    Click Element On Webpage    ${request_locator}
    ${promise}    Promise To    Wait For Response    ${DELETE_TIMEOFF_API_REGEX_ESS}
    Click Delete ESS Time Off Request Button
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Capture Screenshot On Webpage

Click Delete ESS Time Off Request Button
    [Documentation]
    ...    Clicks the delete button for time off request.
    ...    Used after navigating to an existing time off request to delete it permanently.
    ...    Example usage:
    ...    | Click Delete ESS Time Off Request Button
    Click Element On Webpage    ${ESS_REQUEST_DELETE_BUTTON}

Verify ESS Time Off Request Not Present
    [Documentation]
    ...    Verifies that a time off request is not present on the calendar.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | start_time    | Start time for the time off.    |
    ...    | end_time    | End time for the time off.    |
    ...    | not_reviewed_request_status    | Previous status of the request.    |
    ...    Example usage:
    ...    | ESS Verify Time Off Request Not Present    John Doe    1_2    14:00    16:00    Not Reviewed
    [Arguments]    ${associate_name}    ${start_date}    ${start_time}    ${end_time}    ${not_reviewed_request_status}
    Select Day On Request Calendar Page    ${start_date}
    # Try to build the locator but it should not be found
    ${request_locator}    Build ESS Time Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${not_reviewed_request_status}
    ...    request_type=Time Off
    ${is_visible}    Run Keyword And Return Status
    ...    Wait For Elements State
    ...    ${request_locator}
    ...    visible
    ...    timeout=2s
    Should Not Be True    ${is_visible}    Time off request should not be visible

Cancel ESS Day Off Request And Verify API Success
    [Documentation]
    ...    Cancels a day off request as ESS and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | request_status    | Current status of the request.    |
    ...    Example usage:
    ...    | ESS Cancel Day Off Request And Verify API Success    John Doe    1_2    Not Reviewed
    [Arguments]    ${associate_name}    ${start_date}    ${request_status}
    Select Day On Request Calendar Page    ${start_date}
    ${request_locator}    Build ESS Day Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${request_status}
    ...    request_type=Day Off
    Click Element On Webpage    ${request_locator}
    ${promise}    Promise To    Wait For Response    ${CANCEL_DAYOFF_API_REGEX_ESS}
    Click Cancel ESS Day Off Request Button
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification

Click Cancel ESS Day Off Request Button
    [Documentation]
    ...    Clicks the cancel button for day off request.
    ...    Used after navigating to an existing day off request to cancel it.
    ...    Example usage:
    ...    | Click Cancel ESS Day Off Request Button
    Click Element On Webpage    ${ESS_REQUEST_CANCEL_BUTTON}

Delete ESS Day Off Request And Verify API Success
    [Documentation]
    ...    Deletes a day off request as ESS and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | request_status    | Current status of the request.    |
    ...    Example usage:
    ...    | ESS Delete Day Off Request And Verify API Success    John Doe    1_2    Not Reviewed
    [Arguments]    ${associate_name}    ${start_date}    ${request_status}
    Select Day On Request Calendar Page    ${start_date}
    ${request_locator}    Build ESS Day Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${request_status}
    ...    request_type=Day Off
    Click Element On Webpage    ${request_locator}
    ${promise}    Promise To    Wait For Response    ${DELETE_DAY_OFF_API_REGEX_ESS}
    Click Delete ESS Day Off Request Button
    ${response_body}    Wait For    ${promise}
    Log    ${response_body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}

Click Delete ESS Day Off Request Button
    [Documentation]
    ...    Clicks the delete button for day off request.
    ...    Used after navigating to an existing day off request to delete it permanently.
    ...    Example usage:
    ...    | Click Delete ESS Day Off Request Button
    Click Element On Webpage    ${ESS_REQUEST_DELETE_BUTTON}

Verify Ess Day Off Request Not Present
    [Documentation]
    ...    Verifies that a day off request is not present on the calendar.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | not_reviewed_request_status    | Previous status of the request.    |
    ...    Example usage:
    ...    | ESS Verify Day Off Request Not Present    John Doe    1_2    Not Reviewed
    [Arguments]    ${associate_name}    ${start_date}    ${not_reviewed_request_status}
    Select Day On Request Calendar Page    ${start_date}
    # Try to build the locator but it should not be found
    ${request_locator}    Build ESS Day Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${not_reviewed_request_status}
    ...    request_type=Day Off
    ${is_visible}    Run Keyword And Return Status
    ...    Wait For Elements State
    ...    ${request_locator}
    ...    visible
    ...    timeout=2s
    Should Not Be True    ${is_visible}    Day off request should not be visible

Add Holiday Hours For ESS Day Off Leave Period
    [Documentation]
    ...    Adds holiday hours for a specified date range in the leave period.
    ...    | =Arguments=    | =Description=    |
    ...    | start_date    | Start date of the holiday period.    |
    ...    | end_date    | End date of the holiday period.    |
    ...    | hours_per_day    | Number of hours per day to add.    |
    ...    Example usage:
    ...    | Add Holiday Hours For ESS Day Off Leave Period    2025-01-01    2025-01-05    8
    [Arguments]    ${start_date}    ${end_date}    ${hours_per_day}
    ${dates}    Get Date Range For Holiday Hours Of ESS Day Off Request    ${start_date}    ${end_date}
    FOR    ${date}    IN    @{dates}
        # Convert the YYYYMMDD format to MM/DD/YYYY format for the date picker
        ${formatted_date}    Convert Date    ${date}    date_format=%Y%m%d    result_format=%d/%m/%Y

        # Use the date as ID and input the formatted date value
        Wait For Elements State    //input[@id="${date}"]    visible    timeout=5s
        Set Date With JavaScript    //input[@id="${date}"]    ${formatted_date}

        # Input the holiday hours value
        Fill Text    //input[@id="${date}"]    ${hours_per_day}
    END

Get Date Range For Holiday Hours Of ESS Day Off Request
    [Documentation]
    ...    Generates a list of dates between the start and end dates for holiday hours.
    ...    | =Arguments=    | =Description=    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | end_date    | End date in week-day format.    |
    ...    *Returns*: List of dates in YYYYMMDD format.
    ...    Example usage:
    ...    | ${dates}    Get Date Range For Holiday Hours Of ESS Day Off Request    1_1    1_5
    [Arguments]    ${start_date}    ${end_date}

    # Convert PW format dates to actual dates first
    ${start_date_value}    Calculate Date From Week Day Offset    ${start_date}
    ${end_date_value}    Calculate Date From Week Day Offset    ${end_date}

    # Keep dates as datetime objects for calculations
    VAR    ${dates}    @{EMPTY}

    # Convert dates to epoch seconds for calculation
    ${start_epoch}    Convert Date    ${start_date_value}    epoch
    ${end_epoch}    Convert Date    ${end_date_value}    epoch
    ${delta}    Evaluate    int((${end_epoch} - ${start_epoch}) / 86400) + 1

    FOR    ${i}    IN RANGE    ${delta}
        ${date}    Add Time To Date    ${start_date_value}    ${i} days
        ${date_str}    Convert Date    ${date}    result_format=%Y%m%d
        Append To List    ${dates}    ${date_str}
    END
    RETURN    ${dates}

Create ESS Day Off Request With Holiday Hours And Verify API Success
    [Documentation]
    ...    Creates a day off request with holiday hours and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | start_date    | Start date in week-day format.    |
    ...    | end_date    | End date in week-day format.    |
    ...    | reason_type    | Reason for the day off request.    |
    ...    | holiday_hours    | Number of holiday hours per day.    |
    ...    Example usage:
    ...    | ESS Create Day Off Request With Holiday Hours And Verify API Success    1_1    1_5    Vacation    8
    [Arguments]    ${start_date}
    ...    ${end_date}
    ...    ${reason_type}
    ...    ${holiday_hours}
    Fill Form For ESS Add Day Off Request
    ...    ${start_date}
    ...    ${end_date}
    ...    ${reason_type}
    Click Element On Webpage    ${HOLIDAY_HOURS_ICON}
    Wait Until Element Is Visible On Webpage    ${HOLIDAY_HOURS_INPUT_GRID}
    Add Holiday Hours For ESS Day Off Leave Period    ${start_date}    ${end_date}    ${holiday_hours}
    ${promise}    Promise To    Wait For Response    ${ADD_DAY_OFF_API_REGEX_ESS}
    Click ESS Day Off Request Save Button
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Strings    ${response_body.status}    ${status_ok}
    Verify Success Toast Notification
    RETURN    ${response_body.body.metaInfo.addedDayoffRequestObject}

Edit Ess Time Off Request And Verify Api Success
    [Documentation]
    ...    Edits an existing time off request as ESS and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | time_off_data    | Dictionary containing time off request details: start_date, start_time, end_time, status.    |
    ...    | edit_start_time    | New start time to update the request with.    |
    ...    Example usage:
    ...    | ESS Edit Time Off Request And Verify Api Success    John Doe    {'start_date': '1_2', 'start_time': '14:00', 'end_time': '16:00', 'status': 'Not Reviewed'}    15:00
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${status}
    ...    ${edit_start_time}
    Select Day On Request Calendar Page    ${start_date}
    ${request_locator}    Build ESS Time Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${status}
    ...    request_type=Time Off
    # Used hard sleep as of now as per discussion, without that the script was failing.
    # Sleep    5s
    Wait Until Element Is Visible On Webpage    ${request_locator}
    Click Element On Webpage    ${request_locator}
    # Used hard sleep as of now as per discussion, without that the script was failing.
    # Sleep    5s
    Wait Until Element Is Visible On Webpage    ${ESS_REQUEST_CLOSE_BUTTON}
    Enter Start Time For ESS Time Off Request    ${edit_start_time}
    ${promise}    Promise To    Wait For Response    ${EDIT_TIMEOFF_API_REGEX_ESS}
    Click ESS Time Off Request Save Button
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    200
    Capture Screenshot On Webpage

Verify ESS Time Off Request Notification On Web
    [Documentation]
    ...    Verifies the notification message after adding a time off request in ESS.
    ...    | =Arguments=    | =Description=    |
    ...    | request_date    | Date of the time off request in week-day format.
    ...    | start_time    | Start time for the time off request.
    ...    | end_time    | End time for the time off request.
    ...    *Returns*: The notification message text.
    ...    Example usage:
    ...    | Verify ESS Time Off Request Notification    1_2    14:00    16:00
    [Arguments]    ${request_date}
    ...    ${start_time}
    ...    ${end_time}
    ${date_value}    Calculate Date From Week Day Offset    ${request_date}
    ${formatted_date}    Convert Date    ${date_value}    result_format=%m/%d/%Y
    ${time_off_start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
    ${time_off_end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}
    ${request_notification}    Update Locator With Dynamic Values    ${TIME_OFF_REQUEST_NOTIFICATION}    DATE=${formatted_date}
    ...    START_TIME=${time_off_start_time}    END_TIME=${time_off_end_time}

    # First attempt to find the notification
    ${notification_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${request_notification}
    ...    timeout=5s

    # If notification is not visible, reload and navigate to My Work Page, then retry
    IF    not ${notification_visible}
        Log    Notification not visible on current page, reloading and navigating to My Work Page
        Reload Web Page
        Navigate To Web My Work Page On Web
        Wait Until Element Is Visible On Webpage    ${request_notification}
    END

    # Get and return the notification text
    ${notification_text}    Get Element Text On Webpage    ${request_notification}
    RETURN    ${notification_text}

Verify Ess Time Off Request Created On Web
    [Documentation]    verify time off request on web
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate.    |
    ...    | time_off_data    | Dictionary containing time off request details: start_date, start_time, end_time, request_status.    |
    ...    Example usage:
    ...    | ESS Verify Time Off Request Created On Web    John Doe    {'start_date': '1_2', 'start_time': '14:00', 'end_time': '16:00', 'request_status': 'Approved'}
    [Arguments]    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${status}
    Select Day On Request Calendar Page    ${start_date}
    ${request_locator}    Build ESS Time Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${status}
    ...    request_type=Time Off
    Wait Until Element Is Visible On Webpage    ${request_locator}

Verify Day Off Request Details On Requests Calendar Page On Web
    [Documentation]
    ...    Verifies a request on the requests calendar page as ESS user.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | associate name for whom the request is to be verified.    |
    ...    | request_status    | Status of the day off request.    |
    ...    | start_date    | Start date in week_day format.    |
    ...    | end_date    | End date in week_day format.    |
    ...    | reason    | Reason for the day off request.    |
    ...    | holiday_hours    | (Optional) Dictionary mapping day numbers (1=Sun to 7=Sat) to expected holiday hours (e.g., {"2": "8", "3": "5"}).    |
    ...    | due_date    | (Optional) Due date for the day off request.    |
    [Arguments]    ${associate_name}
    ...    ${request_status}
    ...    ${start_date}
    ...    ${end_date}
    ...    ${reason}
    ...    ${holiday_hours}=${None}
    ...    ${due_date}=${None}
    ${request_type}    Get System Value    RCFilterRequestType    DAY_OFF
    Select Day On Request Calendar Page    ${start_date}
    ${request_locator}    Build ESS Day Off Request Locator
    ...    ${associate_name}
    ...    ${start_date}
    ...    ${request_status}
    ...    request_type=${request_type}
    Click Element On Webpage    ${request_locator}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${start_date_value}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}
    ${end_date_value}    Calculate Date From Week Day Offset    ${end_date}    ${date_format}
    Wait Until Element Is Visible On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_START_DATE}
    ${actual_start_date}    Get Element Text On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_START_DATE}
    Should Be Equal As Strings    ${actual_start_date}    ${start_date_value}
    ${actual_end_date}    Get Element Text On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_END_DATE}
    Should Be Equal As Strings    ${actual_end_date}    ${end_date_value}
    ${actual_reason}    Get Selected Value In Dropdown On Web    ${ESS_REQUEST_CALENDAR_REQUEST_SELECTED_REASON}
    Should Be Equal As Strings    ${actual_reason}    ${reason}
    IF    '${due_date}' != '${None}'
        ${due_date_value}    Calculate Date From Week Day Offset    ${due_date}    ${date_format}
        ${actual_due_date}    Get Element Text On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_EDIT_DUE_DATE_TEXTBOX}
        Should Be Equal As Strings    ${actual_due_date}    ${due_date_value}
    END
    ${actual_request_status}    Get Element Text On Webpage    ${ESS_REQUEST_CALENDAR_REQUEST_STATUS}
    ${actual_request_status_trimmed}    Clean Leading And Trailing Space On Text    ${actual_request_status}
    Should Be Equal As Strings    ${actual_request_status_trimmed}    ${request_status}
    IF    $holiday_hours != $None
        Validate Holiday Hours For ESS Day Off Request    ${holiday_hours}
    END
    Click Element On Webpage    ${ESS_REQUEST_CLOSE_BUTTON}

Validate Holiday Hours For ESS Day Off Request
    [Documentation]    Validates holiday hours entered for specific days in the week for a day off request.
    ...    | =Arguments= | =Description= |
    ...    | holiday_hours_data | Dictionary mapping day numbers (0=Sun to 6=Sat) to expected holiday hours (e.g., {"2": "8", "3": "5"}). |
    [Arguments]    ${holiday_hours_data}
    ${day_numbers}    Get Dictionary Keys    ${holiday_hours_data}
    FOR    ${day_num}    IN    @{day_numbers}
        ${expected_hours}    Get From Dictionary    ${holiday_hours_data}    ${day_num}
        ${day_of_week}    Evaluate    int(${day_num}) + 1
        ${day_num_string}    Convert To String    ${day_of_week}
        ${holiday_hours_input_locator}    Update Locator With Dynamic Values
        ...    ${ESS_REQUEST_CALENDAR_PAGE_HOLIDAY_HOURS_INPUT}
        ...    DAY=${day_num_string}
        Wait Until Element Is Visible On Webpage    ${holiday_hours_input_locator}
        ${actual_hours}    Get Element Text On Webpage    ${holiday_hours_input_locator}
        Should Be Equal As Strings    ${actual_hours}    ${expected_hours}
        ...    Holiday hours mismatch for day ${day_num}: expected '${expected_hours}' but got '${actual_hours}'
        Log    Validated holiday hours for day ${day_num}: ${expected_hours} hours
    END

Edit Day Off Request On Requests Calendar Page On Web
    [Documentation]
    ...    Edits a day off request on the requests calendar page as ESS user.
    ...    | =Arguments=    | =Description=    |
    ...    | request_start_date    | Start date of the existing day off request in week_day format.    |
    ...    | edit_start_date    | Start date to be edited in week_day format.    |
    ...    | edit_end_date    | End date to be edited in week_day format.    |
    ...    | reason    | New reason for the day off request.    |
    ...    | due_date    | (Optional) New due date for the day off request.    |
    ...    | requester_comment | (Optional) New requester comment for the day off request.    |
    ...    | edit_holiday_hours | (Optional) Dictionary of holiday hours to edit for specific days.    |
    [Arguments]    ${request_start_date}
    ...    ${edit_start_date}=${None}
    ...    ${edit_end_date}=${None}
    ...    ${reason}=${None}
    ...    ${due_date}=${None}
    ...    ${requester_comment}=${None}
    ...    ${edit_holiday_hours}=${None}
    ${request_type}    Get System Value    RCFilterRequestType    DAY_OFF
    Select Day On Request Calendar Page    ${request_start_date}
    ${request_date_format}    Get Config Value    DATE_FMT_MONTH_DAY
    ${request_date}    Calculate Date From Week Day Offset    ${request_start_date}    ${request_date_format}
    ${request_locator}    Update Locator With Dynamic Values    ${ESS_REQUEST_CALENDAR_REQUEST_ENTRY}    REQUEST_TYPE=${request_type}
    ...    DURATION=${request_date}
    Click Element On Webpage    ${request_locator}
    IF    '${edit_start_date}' != '${None}'
        Select Date Through Date Picker For ESS Requests On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_EDIT_START_DATE_TIMEPICKER}
        ...    ${edit_start_date}
    END
    IF    '${edit_end_date}' != '${None}'
        Select Date Through Date Picker For ESS Requests On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_EDIT_END_DATE_TIMEPICKER}
        ...    ${edit_end_date}
    END
    IF    '${reason}' != '${None}'
        Select Reason Type For ESS Day Off Request    ${reason}
    END
    IF    '${due_date}' != '${None}'
        Select Date Through Date Picker For ESS Requests On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_EDIT_DUE_DATE_TIMEPICKER}
        ...    ${due_date}
    END
    IF    '${requester_comment}' != '${None}'
        Fill Textbox On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_REQUESTER_COMMENT}    ${requester_comment}
    END
    IF    $edit_holiday_hours != $None
        Enter Holiday Hours For ESS Day Off Request    ${edit_holiday_hours}
    END
    ${promise}    Promise To    Wait For Response    ${UPDATE_DAY_OFF_API_REGEX_ESS}
    Click Element On Webpage    ${ESS_REQUEST_SAVE_BUTTON}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Verify Success Notification Toast On ESS Request Calendar Page On Web
    [Documentation]    Verifies the notification toast message on the ESS request calendar page.
    Wait Until Element Is Visible On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_SUCCESS_NOTIFICATION_TEXT}    timeout=${MEDIUM_TIMEOUT}
    Wait Until Element Disappears On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_SUCCESS_NOTIFICATION_TEXT}

Cleanup Existing ESS Day Off Requests On Web
    [Documentation]    Cleans up existing day off requests for the logged-in ESS user on the requests calendar page.
    ...    | =Arguments=    | =Description=    |
    ...    | num_of_weeks    | Number of weeks to check for existing day off requests. Default is 1 week.    |
    [Arguments]    ${num_of_weeks}=2
    Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_TAB}
    VAR    ${index}    0
    FOR    ${index}    IN RANGE    ${num_of_weeks}
        IF    ${index} > 0
            Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_NEXT_WEEK_ICON}
            Wait Until Page Is Loaded
            Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_TAB}
        END
        ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_REQUEST}
        WHILE    ${is_request_visible}    limit=${LOOP_LIMIT}
            Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_REQUEST}
            Click Delete ESS Day Off Request Button
            Verify Success Notification Toast On ESS Request Calendar Page On Web
            ${is_request_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
            ...    ${ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_REQUEST}
        END
    END
    VAR    ${reverse_index}    0
    FOR    ${reverse_index}    IN RANGE    ${num_of_weeks}
        IF    ${reverse_index} > 0
            Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_PREVIOUS_WEEK_ICON}
            Wait Until Page Is Loaded
        END
    END

Get Count Of Rotations Available On Availability Request On Request Calendar Page On Web
    [Documentation]    Get count of rotations available on availability request on request calendar page.
    ...    | Returns: | Number of rotation elements found.
    Click On ESS Add Request Button
    ${availability}    Get System Value    RCFilterRequestType    AVAILABILITY
    Select Request Type On ESS Request Calendar Page    ${availability}
    Wait Until Element Is Visible On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_PREFERENCE}
    ${rotation_elements_count}    Get Element Count On Web Page    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_ROTATIONS_ELEMENTS}
    Click Element On Webpage    ${ESS_REQUEST_CLOSE_BUTTON}
    RETURN    ${rotation_elements_count}

Add Availability Request On Request Calendar Page On Web
    [Documentation]    Add ESS My Availability Request on request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | week_date_offset | The week start date for the availability request in offset date format (e.g. 1_1). |
    ...    | preference | The availability preference to select (e.g., "Permanent"). |
    ...    | reason | The reason for the availability request. |
    ...    | availability_data | Availability request data template name from template file. |
    [Arguments]    ${week_date_offset}
    ...    ${preference}
    ...    ${reason}
    ...    ${availability_data}
    Fill My Availability Request Fields On Request Calendar Page On Web
    ...    ${week_date_offset}    ${preference}    ${reason}
    Fill Availability Request Weekly Data From Template On Request Calendar Page On Web    ${availability_data}
    Submit Availability Request On Request Calendar Page On Web

Edit Weekly Data In Availability Request On Request Calendar Page On Web
    [Documentation]    Edit ESS My Availability Request on request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | availability_data | Availability request data template name from template file. |
    [Arguments]    ${availability_data}
    Click And Open Availability Request On Requests Calendar Page On Web
    Fill Availability Request Weekly Data From Template On Request Calendar Page On Web    ${availability_data}
    Submit Availability Request On Request Calendar Page On Web

Verify Availability Request Values On Request Calendar Page On Web
    [Documentation]    Verify ESS My Availability Request values on request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | expected_preference | Expected availability preference value. |
    ...    | expected_store_id | Expected store ID value. |
    ...    | expected_status | Expected availability status value. |
    ...    | expected_reason | Expected reason for availability request. |
    ...    | rotation_num | Rotation number to validate. |
    ...    | availability_num | Availability number within the rotation to validate. |
    ...    | availability_data | Availability request data template name from template file. |
    [Arguments]    ${expected_preference}
    ...    ${expected_store_id}
    ...    ${expected_status}
    ...    ${expected_reason}
    ...    ${rotation_num}
    ...    ${availability_num}
    ...    ${availability_data}
    Click And Open Availability Request On Requests Calendar Page On Web
    Validate My Availability Request Details On Request Calendar Page On Web    ${expected_preference}
    ...    ${expected_store_id}    ${expected_status}    ${expected_reason}
    Validate Specific Availability Row For Rotation On Request Calendar Page On Web    ${availability_data}
    ...    ${rotation_num}    ${availability_num}
    Validate Disabled Days For Availability On Request Calendar Page On Web    ${availability_data}
    ...    ${rotation_num}    ${availability_num}
    Validate Totally Available Days For Availability On Request Calendar Page On Web    ${availability_data}
    ...    ${rotation_num}    ${availability_num}
    Click Element On Webpage    ${ESS_REQUEST_CLOSE_BUTTON}

Fill My Availability Request Fields On Request Calendar Page On Web
    [Documentation]    Fill dropdown and date fields of ESS My Availability Request.
    ...    | =Arguments= | =Description= |
    ...    | week_date_offset | The week start date for the availability request in offset date format (e.g. 1_1). |
    ...    | preference | The availability preference to select (e.g., "Permanent"). |
    ...    | reason | The reason for the availability request. |
    [Arguments]    ${week_date_offset}    ${preference}    ${reason}
    Click On ESS Add Request Button
    ${availability}    Get System Value    RCFilterRequestType    AVAILABILITY
    Select Request Type On ESS Request Calendar Page    ${availability}
    Wait Until Element Is Visible On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_PREFERENCE}
    Select List Item On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_PREFERENCE}    text    ${preference}
    Wait Until Element Is Visible On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_WEEK_START}
    Select Date Through Date Picker For ESS Requests On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_WEEK_START_DATEPICKER}
    ...    ${week_date_offset}
    ${is_reason_field_visible}    Is Element Visible On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON}
    IF    ${is_reason_field_visible}
        Select List Item On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON}    text    ${reason}
    END
    Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_TOTALLY_AVAILABLE_BUTTON}

Validate My Availability Request Details On Request Calendar Page On Web
    [Documentation]    Validate ESS My Availability Request details on request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | expected_preference | Expected availability preference value. |
    ...    | expected_store_id | Expected store ID value. |
    ...    | expected_status | Expected availability status value. |
    ...    | expected_reason | Expected reason for availability request. |
    [Arguments]    ${expected_preference}    ${expected_store_id}    ${expected_status}    ${expected_reason}
    ${actual_preference}    Get Element Text On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_PREFERENCE_VALUE}
    Should Be Equal As Strings    ${actual_preference}    ${expected_preference}
    ${actual_store_id}    Get Element Text On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_STORE_ID}
    Should Be Equal As Strings    ${actual_store_id}    ${expected_store_id}
    ${is_availability_status_visible}    Is Element Visible On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_STATUS}
    IF    ${is_availability_status_visible}
        ${actual_status}    Get Element Text On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_STATUS}
        Should Be Equal As Strings    ${actual_status}    ${expected_status}
    END
    ${is_reason_field_visible}    Is Element Visible On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON}
    IF    ${is_reason_field_visible}
        ${actual_reason}    Get Selected Value In Dropdown On Web    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON}
        Should Be Equal As Strings    ${actual_reason}    ${expected_reason}
    END

Fill Availability Request Weekly Data From Template On Request Calendar Page On Web
    [Documentation]    Fills in availability request weekly data from template on the ESS request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | availability_request_data_key | Key to retrieve availability request data from template file. |
    [Arguments]    ${availability_request_data}
    ${rotations_dict}    Get From Dictionary    ${availability_request_data}    rotations
    ${rotation_numbers}    Get Dictionary Keys    ${rotations_dict}
    FOR    ${rotation_num}    IN    @{rotation_numbers}
        ${rotation_data}    Get From Dictionary    ${rotations_dict}    ${rotation_num}
        VAR    @{disabled_days}    @{EMPTY}
        ${all_keys}    Get Dictionary Keys    ${rotation_data}
        FOR    ${key}    IN    @{all_keys}
            IF    '${key}' != 'availabilities'
                ${day_data}    Get From Dictionary    ${rotation_data}    ${key}
                ${has_not_available}    Run Keyword And Return Status    Dictionary Should Contain Key    ${day_data}    not_available
                IF    ${has_not_available}
                    ${is_not_available}    Get From Dictionary    ${day_data}    not_available
                    IF    ${is_not_available}
                        Append To List    ${disabled_days}    ${key}
                    END
                END
            END
        END
        ${disabled_days_length}    Get Length    ${disabled_days}
        IF    ${disabled_days_length} > 0
            Disable Days For Availability Rotation On Request Calendar Page On Web    ${rotation_num}    @{disabled_days}
        ELSE
            Log    No disabled days for rotation ${rotation_num}
        END
        ${availabilities}    Get From Dictionary    ${rotation_data}    availabilities
        ${availabilities_length}    Get Length    ${availabilities}
        IF    ${availabilities_length} > 0
            Populate Week Availability Rows For Rotation On Request Calendar Page On Web    ${rotation_num}    @{availabilities}
        ELSE
            Log    No availability rows to populate for rotation ${rotation_num}
        END
    END

Disable Days For Availability Rotation On Request Calendar Page On Web
    [Documentation]
    ...    Marks specified days (1=Sun .. 7=Sat) disabled for a rotation by toggling checkboxes.
    ...    | =Arguments= | =Description= |
    ...    | rotation_num | Rotation number to disable days for (e.g. 1). |
    ...    | day_numbers | List of day numbers to disable (1=Sun .. 7=Sat). |
    [Arguments]    ${rotation_num}    @{day_numbers}
    FOR    ${day}    IN    @{day_numbers}
        ${day_string}    Convert To String    ${day}
        ${rotation_string}    Convert To String    ${rotation_num}
        ${checkbox_locator}    Update Locator With Dynamic Values
        ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_NOT_AVAILABLE_CHECKBOX}
        ...    DAY=${day_string}    ROTATION=${rotation_string}
        Click Element On Webpage    ${checkbox_locator}
        Log    Disabled day ${day} for rotation ${rotation_num}
    END

Populate Week Availability Rows For Rotation On Request Calendar Page On Web
    [Documentation]
    ...    Fills data for days in a given Availability row for a specific rotation.
    ...    | =Arguments= | =Description= |
    ...    | rotation_num | Rotation number to fill data for (e.g. 1). |
    ...    | availability_objects | List of availability objects containing day-wise availability data. |
    [Arguments]    ${rotation_num}    @{availability_objects}
    FOR    ${availability_object}    IN    @{availability_objects}
        ${avail_row}    Get From Dictionary    ${availability_object}    availability_number
        Log    Populating Availability ${avail_row} for Rotation ${rotation_num}
        VAR    &{days_map}    &{EMPTY}
        ${all_keys}    Get Dictionary Keys    ${availability_object}
        FOR    ${key}    IN    @{all_keys}
            IF    '${key}' != 'availability_number'
                ${value}    Get From Dictionary    ${availability_object}    ${key}
                Set To Dictionary    ${days_map}    ${key}    ${value}
            END
        END
        Populate Specific Availability Row For Rotation On Request Calendar Page On Web
        ...    ${rotation_num}
        ...    ${avail_row}
        ...    ${days_map}
    END

Populate Specific Availability Row For Rotation On Request Calendar Page On Web
    [Documentation]
    ...    Fills in start and end times for a specific rotation's availability row.
    ...    | =Arguments= | =Description= |
    ...    | rotation_num | Rotation number to fill data for (e.g. 1). |
    ...    | avail_row | Availability row number inside the rotation (e.g. 2). |
    ...    | days_map | Dictionary mapping day numbers (1=Sun .. 7=Sat) to start/end time entries. |
    [Arguments]    ${rotation_num}    ${avail_row}    ${days_map}
    ${day_keys}    Get Dictionary Keys    ${days_map}
    FOR    ${day_num}    IN    @{day_keys}
        ${entry}    Get From Dictionary    ${days_map}    ${day_num}
        ${has_timings}    Run Keyword And Return Status    Dictionary Should Contain Key    ${entry}    start
        IF    ${has_timings}
            ${start_time}    Get From Dictionary    ${entry}    start
            ${end_time}    Get From Dictionary    ${entry}    end
            ${day_num_string}    Convert To String    ${day_num}
            ${rotation_num_string}    Convert To String    ${rotation_num}
            ${avail_row_string}    Convert To String    ${avail_row}
            ${not_available_day_locator}    Update Locator With Dynamic Values
            ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_NOT_AVAILABLE_CHECKBOX_CHECKED}
            ...    DAY=${day_num_string}    ROTATION=${rotation_num_string}
            ${is_disabled_day_checked}    Is Element Visible On Webpage    ${not_available_day_locator}
            IF    ${is_disabled_day_checked}
                Click Element On Webpage    ${not_available_day_locator}
            END
            ${start_locator}    Update Locator With Dynamic Values
            ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DAY_START_INPUT}
            ...    DAY=${day_num_string}    ROTATION=${rotation_num_string}    AVAIL=${avail_row_string}
            ${end_locator}    Update Locator With Dynamic Values
            ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DAY_END_INPUT}
            ...    DAY=${day_num_string}    ROTATION=${rotation_num_string}    AVAIL=${avail_row_string}
            Click Element On Webpage    ${start_locator}
            Clear Textbox On Webpage    ${start_locator}
            Fill Textbox On Webpage    ${start_locator}    ${start_time}
            Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_ROTATION_HEADING}
            Clear Textbox On Webpage    ${end_locator}
            Fill Textbox On Webpage    ${end_locator}    ${end_time}
            Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_ROTATION_HEADING}
            Log    Rotation ${rotation_num} / Availability ${avail_row} / Day ${day_num}: ${start_time}-${end_time}
        END
    END

Validate Specific Availability Row For Rotation On Request Calendar Page On Web
    [Documentation]
    ...    Validates that the entered start/end times for a specific rotation's availability row.
    ...    | =Arguments= | =Description= |
    ...    | availability_request_data_key | Dict containing 'rotations' dictionary with all availability data to be validated. |
    ...    | rotation_num | Rotation number to validate (e.g. 1). |
    ...    | availability_row | Availability row number inside the rotation (e.g. 2). |
    [Arguments]    ${availability_request_data}    ${rotation_num}    ${availability_row}
    ${rotations_dict}    Get From Dictionary    ${availability_request_data}    rotations
    ${rotation_num_str}    Convert To String    ${rotation_num}
    ${rotation_data}    Get From Dictionary    ${rotations_dict}    ${rotation_num_str}
    ${availabilities}    Get From Dictionary    ${rotation_data}    availabilities
    FOR    ${availability}    IN    @{availabilities}
        ${a_row}    Get From Dictionary    ${availability}    availability_number
        IF    ${a_row} == ${availability_row}
            VAR    ${target_avail}    ${availability}
            BREAK
        END
    END
    VAR    &{days_map}    &{EMPTY}
    ${all_keys}    Get Dictionary Keys    ${target_avail}
    FOR    ${key}    IN    @{all_keys}
        IF    '${key}' != 'availability_number'
            ${value}    Get From Dictionary    ${target_avail}    ${key}
            Set To Dictionary    ${days_map}    ${key}    ${value}
        END
    END
    ${day_keys}    Get Dictionary Keys    ${days_map}
    FOR    ${day_num}    IN    @{day_keys}
        ${entry}    Get From Dictionary    ${days_map}    ${day_num}
        ${has_timings}    Run Keyword And Return Status    Dictionary Should Contain Key    ${entry}    start
        IF    ${has_timings}
            ${expected_start}    Get From Dictionary    ${entry}    start
            ${expected_end}    Get From Dictionary    ${entry}    end
            ${day_str}    Convert To String    ${day_num}
            ${rotation_str}    Convert To String    ${rotation_num}
            ${availability_str}    Convert To String    ${availability_row}
            ${start_locator}    Update Locator With Dynamic Values
            ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DAY_START_INPUT}
            ...    DAY=${day_str}    ROTATION=${rotation_str}    AVAIL=${availability_str}
            ${end_locator}    Update Locator With Dynamic Values
            ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DAY_END_INPUT}
            ...    DAY=${day_str}    ROTATION=${rotation_str}    AVAIL=${availability_str}
            Wait Until Element Is Visible On Webpage    ${start_locator}
            ${actual_start}    Get Element Text On Webpage    ${start_locator}
            IF    'a' not in $actual_start and 'p' not in $actual_start
                ${expected_start}    Convert Time From 12 Hour To 24 Hour Format For Web    ${expected_start}
            END
            ${actual_end}    Get Element Text On Webpage    ${end_locator}
            IF    'a' not in $actual_end and 'p' not in $actual_end
                ${expected_end}    Convert Time From 12 Hour To 24 Hour Format For Web    ${expected_end}
            END
            Should Be Equal As Strings    ${actual_start}    ${expected_start}
            ...    Wrong start time for Day ${day_num} (Rotation ${rotation_num} / Availability ${availability_row})
            Should Be Equal As Strings    ${actual_end}    ${expected_end}
            ...    Wrong end time for Day ${day_num} (Rotation ${rotation_num} / Availability ${availability_row})
        END
    END
    Log    Validation successful for Rotation ${rotation_num} Availability ${availability_row}

Validate Disabled Days For Availability On Request Calendar Page On Web
    [Documentation]
    ...    Validates that all disabled (non-available) days for a specific availability row (within a rotation)
    ...    are marked as "Not Available" on the request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | availability_request_data_key | Dict containing 'rotations' dictionary with all availability data to be validated. |
    ...    | rotation_num | Rotation number to validate (e.g. 1). |
    ...    | avail_num | Availability row number inside the rotation (e.g. 1). |
    [Arguments]    ${availability_request_data}    ${rotation_num}    ${avail_num}
    ${not_available_text}    Get System Value    AvailabilityDayStatus    NOT_AVAILABLE
    ${rotations_dict}    Get From Dictionary    ${availability_request_data}    rotations
    ${rotation_num_str}    Convert To String    ${rotation_num}
    ${rotation_data}    Get From Dictionary    ${rotations_dict}    ${rotation_num_str}
    VAR    @{disabled_days}    @{EMPTY}
    ${all_keys}    Get Dictionary Keys    ${rotation_data}
    FOR    ${key}    IN    @{all_keys}
        IF    '${key}' != 'availabilities'
            ${day_data}    Get From Dictionary    ${rotation_data}    ${key}
            ${has_not_available}    Run Keyword And Return Status    Dictionary Should Contain Key    ${day_data}    not_available
            IF    ${has_not_available}
                ${is_not_available}    Get From Dictionary    ${day_data}    not_available
                IF    ${is_not_available}
                    Append To List    ${disabled_days}    ${key}
                END
            END
        END
    END
    ${disabled_days_length}    Get Length    ${disabled_days}
    IF    not ${disabled_days_length} > 0
        Log    No disabled days defined for rotation ${rotation_num}
        RETURN
    END
    ${rotation_string}    Convert To String    ${rotation_num}
    ${avail_string}    Convert To String    ${avail_num}
    FOR    ${day}    IN    @{disabled_days}
        ${day_string}    Convert To String    ${day}
        ${start_locator}    Update Locator With Dynamic Values
        ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DAY_START_INPUT}
        ...    DAY=${day_string}    ROTATION=${rotation_string}    AVAIL=${avail_string}
        ${actual_not_available_text}    Get Element Text On Webpage    ${start_locator}
        Should Be Equal As Strings    ${actual_not_available_text}    ${not_available_text}
        Log    Validated disabled day ${day} for rotation ${rotation_num}
    END
    Log    All disabled days validated for rotation ${rotation_num}

Validate Totally Available Days For Availability On Request Calendar Page On Web
    [Documentation]
    ...    Validates days marked as Totally Available.
    ...    | =Arguments= | =Description= |
    ...    | availability_request_data_key | Dict containing 'rotations' dictionary with all availability data to be validated. |
    ...    | rotation_num | Rotation number to target (e.g. 1). |
    ...    | avail_num | Availability row number inside the rotation (e.g. 1). |
    [Arguments]    ${availability_request_data}    ${rotation_num}    ${avail_num}
    ${totally_available_text}    Get System Value    AvailabilityDayStatus    TOTALLY_AVAILABLE
    ${rotations_dict}    Get From Dictionary    ${availability_request_data}    rotations
    ${rotation_num_str}    Convert To String    ${rotation_num}
    ${rotation_data}    Get From Dictionary    ${rotations_dict}    ${rotation_num_str}
    ${availabilities}    Get From Dictionary    ${rotation_data}    availabilities
    FOR    ${availability}    IN    @{availabilities}
        ${avail_row}    Get From Dictionary    ${availability}    availability_number
        IF    ${avail_row} == ${avail_num}
            VAR    ${target_availability}    ${availability}
            BREAK
        END
    END
    VAR    &{days_map}    &{EMPTY}
    ${all_keys}    Get Dictionary Keys    ${target_availability}
    FOR    ${key}    IN    @{all_keys}
        IF    '${key}' != 'availability_number'
            ${value}    Get From Dictionary    ${target_availability}    ${key}
            Set To Dictionary    ${days_map}    ${key}    ${value}
        END
    END
    ${day_keys}    Get Dictionary Keys    ${days_map}
    FOR    ${day_num}    IN    @{day_keys}
        ${entry}    Get From Dictionary    ${days_map}    ${day_num}
        ${has_availability}    Run Keyword And Return Status    Dictionary Should Contain Key    ${entry}    totally_available
        IF    ${has_availability}
            ${is_totally_available}    Get From Dictionary    ${entry}    totally_available
            IF    ${is_totally_available}
                ${day_str}    Convert To String    ${day_num}
                ${rotation_str}    Convert To String    ${rotation_num}
                ${availability_str}    Convert To String    ${avail_num}
                ${start_locator}    Update Locator With Dynamic Values
                ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DAY_START_INPUT}
                ...    DAY=${day_str}    ROTATION=${rotation_str}    AVAIL=${availability_str}
                Wait Until Element Is Visible On Webpage    ${start_locator}
                ${available_day_text}    Get Element Text On Webpage    ${start_locator}
                Should Be Equal As Strings    ${available_day_text}    ${totally_available_text}
                Log    Validated totally available day ${day_num} for rotation ${rotation_num}
            END
        END
    END
    Log    All totally available days validated for Rotation ${rotation_num} Availability ${avail_num}

Submit Availability Request On Request Calendar Page On Web
    [Documentation]    Submits the availability request on the request calendar page.
    ${promise}    Promise To    Wait For Response    ${AVAILABILITY_NOTIFICATION_API_REGEX_ESS}
    Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_SUBMIT_BUTTON}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Verify Success Notification Toast On ESS Request Calendar Page On Web

Click And Open Availability Request On Requests Calendar Page On Web
    [Documentation]    Clicks and opens an availability request on the requests calendar page as ESS user.
    Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUESTS_TAB}
    Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_ENTRY}
    Wait Until Element Is Present On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_TOTALLY_AVAILABLE_BUTTON}

Delete Availability Request On Requests Calendar Page On Web
    [Documentation]    Deletes an availability request on the requests calendar page as ESS user.
    Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DELETE_BUTTON}
    Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_CONFIRMATION_OK_BUTTON}
    Verify Success Notification Toast On ESS Request Calendar Page On Web

Cleanup Existing Availability Requests On Requests Calendar Page On Web
    [Documentation]    Cleans up existing availability requests on the requests calendar page as ESS user.
    ...    | =Arguments= | =Description= |
    ...    | times_to_navigate_next_week | Number of weeks to navigate forward to check for existing requests. Default is 2. |
    [Arguments]    ${times_to_navigate_next_week}=2
    Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUESTS_TAB}
    ${availability_request_exists}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_ENTRY}    timeout=${SHORT_TIMEOUT}
    IF    ${availability_request_exists}
        Click And Open Availability Request On Requests Calendar Page On Web
        Delete Availability Request On Requests Calendar Page On Web
    END
    FOR    ${_}    IN RANGE    ${times_to_navigate_next_week}
        Navigate To Next Week On Request Calendar Page On Web
        Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUESTS_TAB}
        ${availability_request_exists}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_ENTRY}    timeout=${SHORT_TIMEOUT}
        IF    ${availability_request_exists}
            Click And Open Availability Request On Requests Calendar Page On Web
            Delete Availability Request On Requests Calendar Page On Web
        END
    END

Navigate To Next Week On Request Calendar Page On Web
    [Documentation]    Navigates to the next week on the request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | times_to_navigate | Number of weeks to navigate forward. If not provided, navigates one week. |
    [Arguments]    ${times_to_navigate}=${None}
    IF    '${times_to_navigate}' != '${None}'
        FOR    ${_}    IN RANGE    ${times_to_navigate}
            Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_NEXT_WEEK_ICON}
            Wait Until Page Is Loaded
        END
    ELSE
        Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_NEXT_WEEK_ICON}
        Wait Until Page Is Loaded
    END

Navigate To Previous Week On Request Calendar Page On Web
    [Documentation]    Navigates to the previous week on the request calendar page.
    ...    | =Arguments= | =Description= |
    ...    | times_to_navigate | Number of weeks to navigate backward. If not provided, navigates one week. |
    [Arguments]    ${times_to_navigate}=${None}
    IF    '${times_to_navigate}' != '${None}'
        FOR    ${_}    IN RANGE    ${times_to_navigate}
            Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_PREVIOUS_WEEK_ICON}
            Wait Until Page Is Loaded
        END
    ELSE
        Click Element On Webpage    ${ESS_REQUEST_CALENDAR_PAGE_PREVIOUS_WEEK_ICON}
        Wait Until Page Is Loaded
    END

Verify ESS Availability Request Notification On Web
    [Documentation]    Verifies the ESS availability request notification for a given date.
    ...    | =Arguments= | =Description= |
    ...    | request_date    | The date of the availability request in offset date format (e.g. 1_1).    |
    ...    *Returns*: The notification text for the given date.
    ...    Example usage:
    ...    | ${notification_text}    Verify ESS Availability Request Notification On Web    1_1
    [Arguments]    ${request_date}
    ${date_value}    Calculate Date From Week Day Offset    ${request_date}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${date_value}    result_format=${date_format}
    ${request_notification}    Update Locator With Dynamic Values    ${AVAILABILITY_REQUEST_NOTIFICATION}    DATE=${formatted_date}

    # First attempt to find the notification
    ${notification_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${request_notification}
    ...    timeout=5s

    # If notification is not visible, reload and navigate to My Work Page, then retry
    IF    not ${notification_visible}
        Log    Notification not visible on current page, reloading and navigating to My Work Page
        Reload Web Page
        Navigate To Web My Work Page On Web
        Wait Until Element Is Visible On Webpage    ${request_notification}
    END

    # Get and return the notification text
    ${notification_text}    Get Element Text On Webpage    ${request_notification}
    RETURN    ${notification_text}
