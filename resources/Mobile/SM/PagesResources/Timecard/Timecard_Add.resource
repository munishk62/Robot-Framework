*** Settings ***
Documentation       Resource file for Timecard Add Page

Library             DateTime
Variables           resources/Mobile/SM/Locators/Timecard_Page.py
Variables           resources/Mobile/SM/Locators/Exception_Management_Page.py
Variables           resources/Mobile/SM/Locators/Common_Page.py
Resource            resources/Mobile/SM/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Common/Localised_Locator.resource


*** Keywords ***
Select Add Shift Option On SM Phone App
    [Documentation]    Used for selecting add shift option from actions on mobile SM app.
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    TRY
        Wait Until Element Is Visible    ${ACTIONS_BUTTON}
    EXCEPT
        Log    Actions button not visible within timeout    WARN
        Wait Until Element Is Visible    ${ACTIONS_BUTTON}
    END
    Click Element    ${ACTIONS_BUTTON}
    Wait Until Element Is Visible    ${ADD_SHIFT_BUTTON}
    Click Element    ${ADD_SHIFT_BUTTON}
    Wait Until Element Is Visible    ${ADD_SHIFT_SCREEN_HEADER}

Add Shift For TimeCard On SM Phone App
    [Documentation]    Adds a shift punch on mobile SM app.
    ...    Args:
    ...    ${shift_start_date}: The date when the shift begins.
    ...    ${shift_end_date}: The date when the shift ends.
    ...    ${shift_start_time}: The time when the shift starts.
    ...    ${shift_end_time}: The time when the shift ends.
    ...    ${department}: The department or team associated with the shift.
    ...    ${reason}: The reason for the shift.
    ...    ${activity}: The primary task or activity for the shift.
    ...    ${location}: The specific location or area within the base or facility where the shift is assigned.
    [Arguments]    ${shift_start_date}
    ...    ${shift_end_date}
    ...    ${shift_start_time}
    ...    ${shift_end_time}
    ...    ${department}
    ...    ${reason}
    ...    ${activity}=${None}
    ...    ${location}=${None}
    Select Add Shift Option On SM Phone App
    Select Timecard Shift Start And End Date On SM Phone App    ${shift_start_date}    ${shift_end_date}
    Select Timecard Shift Start And End Time On SM Phone App    ${shift_start_time}    ${shift_end_time}
    Select Timecard Shift Department On SM Phone App    ${department}
    Select Timecard Shift Reason On SM Phone App    ${reason}
    IF    '${location}' != ''
        Log    Selecting location: ${location} yet to be implemented
    END
    IF    '${activity}' != ''
        Select Timecard Shift Activity On SM Phone App    ${activity}
    END
    Save Timecard Shift On SM Phone App

Select Timecard Shift Start And End Date On SM Phone App
    [Documentation]    Used for selecting shift start and end date timecard on SM phone app.
    ...    Args:
    ...    ${shift_start_date}: The date when the shift begins.
    ...    ${shift_end_date}: The date when the shift ends.
    [Arguments]    ${shift_start_date}    ${shift_end_date}
    Wait Until Page Contains Element    ${ADD_SHIFT_START_DATE}
    Select Date On SM Calendar    ${ADD_SHIFT_START_DATE}    ${shift_start_date}
    Wait Until Page Contains Element    ${ADD_SHIFT_END_DATE}
    Select Date On SM Calendar    ${ADD_SHIFT_END_DATE}    ${shift_end_date}    ${shift_start_date}    True

Select Timecard Shift Start And End Time On SM Phone App
    [Documentation]    Used for selecting shift start and end time for timecard on SM phone app.
    ...    Args:
    ...    ${shift_start_time}: The time when the shift starts.
    ...    ${shift_end_time}: The time when the shift ends.
    [Arguments]    ${shift_start_time}    ${shift_end_time}
    Wait Until Element Is Visible    ${ADD_SHIFT_START_TIME}
    Click Element    ${ADD_SHIFT_START_TIME}
    Select Time On Round Time Picker On SM Phone App    ${shift_start_time}
    Wait Until Element Is Visible    ${ADD_SHIFT_END_TIME}
    Click Element    ${ADD_SHIFT_END_TIME}
    Select Time On Round Time Picker On SM Phone App    ${shift_end_time}

Select Timecard Shift Department On SM Phone App
    [Documentation]    Used for selecting shift department for timecard on SM phone app.
    ...    Args:
    ...    ${department}: The department or team associated with the shift.
    [Arguments]    ${department}
    Wait Until Element Is Visible    ${ADD_SHIFT_DEPARTMENT}
    Click Element    ${ADD_SHIFT_DEPARTMENT}
    Wait Until Element Is Visible    ${ADD_SHIFT_VALUE_SEARCH_FIELD}
    Click Element    ${ADD_SHIFT_VALUE_SEARCH_FIELD}
    Input Text    ${ADD_SHIFT_VALUE_SEARCH_FIELD}    ${department}
    ${department_option_locator}    Get Message With Arguments For SM    ${ADD_SHIFT_DEPARTMENT_OPTION}    ${department}
    Wait Until Element Is Visible    ${department_option_locator}
    Click Element    ${department_option_locator}

Select Timecard Shift Reason On SM Phone App
    [Documentation]    Used for selecting shift reason for timecard on SM phone app.
    ...    Args:
    ...    ${reason}: The reason for the shift.
    [Arguments]    ${reason}
    Wait Until Element Is Visible    ${ADD_SHIFT_REASON}
    Click Element    ${ADD_SHIFT_REASON}
    ${reason_locator}    Get Locator Contains    ${reason}
    Wait Until Element Is Visible    ${reason_locator}
    Click Element    ${reason_locator}

Select Timecard Shift Activity On SM Phone App
    [Documentation]    Used for selecting shift activity for timecard on SM phone app.
    ...    Args:
    ...    ${activity}: The activity for the shift.
    [Arguments]    ${activity}
    ${is_activity_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${ADD_SHIFT_ACTIVITY}    timeout=5s
    IF    ${is_activity_visible}
        Click Element    ${ADD_SHIFT_ACTIVITY}
        ${is_activity_selectable}    Run Keyword And Return Status    Wait Until Element Is Visible    ${ADD_SHIFT_VALUE_SEARCH_FIELD}    timeout=5s
        IF    ${is_activity_selectable}
            Click Element    ${ADD_SHIFT_VALUE_SEARCH_FIELD}
            Input Text    ${ADD_SHIFT_VALUE_SEARCH_FIELD}    ${activity}
            ${activity_option_locator}    Get Message With Arguments For SM    ${ADD_SHIFT_ACTIVITY_OPTION}    ${activity}
            Wait Until Element Is Visible    ${activity_option_locator}
            Click Element    ${activity_option_locator}
        ELSE
            Log    Activity field is not selectable, skipping activity selection step.    WARN
        END
    ELSE
        Log    Activity field is not visible, skipping activity selection step.    WARN
    END

Save Timecard Shift On SM Phone App
    [Documentation]    Used for saving add shift on SM phone app.
    Wait Until Element Is Visible    ${ADD_SHIFT_SAVE_BUTTON}
    Click Element    ${ADD_SHIFT_SAVE_BUTTON}
    ${is_error_message_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${ADD_SHIFT_ERROR_MESSAGE}    timeout=5s
    IF    ${is_error_message_visible}
        ${error_message}    AppiumLibrary.Get Text    ${ADD_SHIFT_ERROR_MESSAGE}
        Fail    Failed to add shift: ${error_message}
    ELSE
        Log    Shift added successfully.
    END
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}

Delete Shift Details On SM Phone App
    [Documentation]    Used for deleting shift details on SM phone app.
    ...    Args:
    ...    ${shift_date}: The date of the shift to be deleted.
    ...    ${reason}: The reason for deleting the shift.
    [Arguments]    ${shift_date}    ${reason}
    Wait Until Element Is Visible    ${SHIFT_DETAILS_DELETE_BUTTON}
    Click Element    ${SHIFT_DETAILS_DELETE_BUTTON}
    ${reason_locator}    Get Message With Arguments For SM    ${SHIFT_DETAILS_DELETE_REASON}    ${reason}
    ${is_reason_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${reason_locator}    timeout=10s
    IF    not ${is_reason_visible}
        Log    Reason "${reason}" not visible in delete shift details screen for shift on date ${shift_date}, proceeding to delete shift without selecting reason.
    ELSE
        Log    Reason "${reason}" is visible in delete shift details screen for shift on date ${shift_date}.
        Wait Until Element Is Visible    ${reason_locator}
        Click Element    ${reason_locator}
        Wait Until Element Is Visible    ${SHIFT_DETAILS_DELETE}
        Click Element    ${SHIFT_DETAILS_DELETE}
    END
    Wait Until Element Is Visible    ${SHIFT_DETAILS_DELETE_CONFIRMATION_BUTTON}
    Click Element    ${SHIFT_DETAILS_DELETE_CONFIRMATION_BUTTON}
    Log    Shift on date ${shift_date} deleted successfully.

Remove Shift For TimeCard On SM Phone App
    [Documentation]    Used for deleting shift punch on SM phone app.
    ...    Args:
    ...    ${shift_date}: The date of the shift to be deleted.
    ...    ${shift_start_time}: The start time of the shift to be deleted.
    ...    ${shift_end_time}: The end time of the shift to be deleted.
    ...    ${reason}: The reason for deleting the shift.
    [Arguments]    ${shift_date}    ${shift_start_time}    ${shift_end_time}    ${reason}
    ${month_day_year_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${shift_date_on_details_screen_value}    Calculate Date From Week Day Offset    ${shift_date}    ${month_day_year_date_format}
    ${shift_date_on_details_screen_locator}    Get Message With Arguments For SM    ${SHIFT_DETAILS_DATE}    ${shift_date_on_details_screen_value}
    ${shift_start_time_formatted}    Format Time String    ${shift_start_time}
    ${shift_end_time_formatted}    Format Time String    ${shift_end_time}
    ${shift_start_row}    Get Message With Arguments For SM    ${SHIFT_ROW_BY_TIME}    ${shift_start_time_formatted}
    ${shift_end_row}    Get Message With Arguments For SM    ${SHIFT_ROW_BY_TIME}    ${shift_end_time_formatted}
    ${shift_day}    Evaluate    "${shift_date}".split('_')[-1]
    ${actual_shift_day}    Evaluate    ${shift_day} + 1
    ${selected_day_locator}    Get Message With Arguments For SM    ${TIMECARD_DAY_CELL}    ${actual_shift_day}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    Wait Until Keyword Succeeds    10 x    ${MEDIUM_TIMEOUT}    Wait Until Page Contains Element    ${selected_day_locator}
    Wait Until Keyword Succeeds    10 x    ${MEDIUM_TIMEOUT}    Click Element    ${selected_day_locator}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    ${is_shift_start_row_present}    Run Keyword And Return Status    Swipe Until Visible    ${shift_start_row}
    IF    ${is_shift_start_row_present}
        Click Element    ${shift_start_row}
        Wait Until Element Is Visible    ${shift_date_on_details_screen_locator}
        Delete Shift Details On SM Phone App    ${shift_date}    ${reason}
        Log    Shift start row deleted successfully, checking for shift end row.
    END
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}    timeout=${MEDIUM_TIMEOUT}
    ${is_shift_end_row_present}    Run Keyword And Return Status    Swipe Until Visible    ${shift_end_row}
    IF    ${is_shift_end_row_present}
        Click Element    ${shift_end_row}
        Delete Shift Details On SM Phone App    ${shift_date}    ${reason}
        Log    Shift end row deleted successfully.
    END

Select Day From Displayed Week On SM Phone App
    [Documentation]    Used for selecting the day from displayed week on SM app.
    ...    Args:
    ...    ${shift_date}: The date of the shift which needs to be selected in format x_y.
    [Arguments]    ${shift_date}
    ${shift_day}    Evaluate    int("${shift_date}".split('_')[-1])
    ${actual_shift_day}    Evaluate    ${shift_day} + 1
    ${selected_day_locator}    Get Message With Arguments For SM    ${TIMECARD_DAY_CELL}    ${actual_shift_day}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    Wait Until Keyword Succeeds    10 x    ${MEDIUM_TIMEOUT}    Wait Until Element Is Visible    ${selected_day_locator}
    Wait Until Keyword Succeeds    10 x    ${MEDIUM_TIMEOUT}    Click Element    ${selected_day_locator}

Select Pay Results Tab On SM Phone App
    [Documentation]    Used for selecting pay results tab on SM phone app.
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    ${pay_results_tab_locator}    Get Localised Locator Contains For SM    ${PAY_RESULTS_TAB_BUTTON}
    ${is_pay_results_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${pay_results_tab_locator}    timeout=2s
    VAR    ${swipe_attempts}    0
    WHILE    not ${is_pay_results_visible} and ${swipe_attempts} < 5
        Swipe Right On Element    ${TABS_CONTAINER}
        ${swipe_attempts}    Evaluate    ${swipe_attempts} + 1
        ${is_pay_results_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${pay_results_tab_locator}    timeout=2s
    END
    IF    not ${is_pay_results_visible}
        Fail    Pay Results tab not visible after swiping tabs container 5 times.
    END
    Click Element    ${pay_results_tab_locator}

Verify Pay Results For Shift On SM Phone App
    [Documentation]    Used for verifying pay results for the shift on SM phone app.
    ...    Args:
    ...    ${shift_day}: The day for which pay results need to be verified.
    [Arguments]    ${shift_day}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    Select Day From Displayed Week On SM Phone App    ${shift_day}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    Select Pay Results Tab On SM Phone App
    Wait Until Element Is Visible    ${PAY_RESULTS_PAY_CATEGORY_LABEL}
    Wait Until Element Is Visible    ${PAY_RESULTS_PAY_CATEGORY_DETAILS}
    Log    Pay results for shift on day ${shift_day} are displayed.

Verify No Data Present For Selected Date For Pay Results Tab On SM Phone App
    [Documentation]    Used for verifying that no data is present for selected date on pay results tab of SM phone app.
    ...    Args:
    ...    ${shift_day}: The day for which pay results need to be verified.
    [Arguments]    ${shift_day}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    Select Day From Displayed Week On SM Phone App    ${shift_day}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    Select Pay Results Tab On SM Phone App
    Wait Until Element Is Visible    ${PAY_RESULTS_NO_DATA_PRESENT_MSG}
    Log    No data present message is displayed for shift on day ${shift_day} as expected.

Verify Shift Added For Specific Date On SM Phone App
    [Documentation]    Used for verifying shift punch added successfully on SM phone app and return True if shift is added, False otherwise.
    ...    Args:
    ...    ${shift_date}: The date of the shift to be verified.
    ...    ${shift_start_time}: The start time of the shift to be verified.
    ...    ${shift_end_time}: The end time of the shift to be verified.
    [Arguments]    ${shift_date}    ${shift_start_time}    ${shift_end_time}
    ${shift_start_time_formatted}    Format Time String    ${shift_start_time}
    ${shift_end_time_formatted}    Format Time String    ${shift_end_time}
    ${shift_start_row}    Get Message With Arguments For SM    ${SHIFT_ROW_BY_TIME}    ${shift_start_time_formatted}
    ${shift_end_row}    Get Message With Arguments For SM    ${SHIFT_ROW_BY_TIME}    ${shift_end_time_formatted}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    Select Day From Displayed Week On SM Phone App    ${shift_date}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}
    ${is_shift_start_time_present}    Run Keyword And Return Status    Swipe Until Visible    ${shift_start_row}
    ${is_shift_end_time_present}    Run Keyword And Return Status    Swipe Until Visible    ${shift_end_row}
    IF    ${is_shift_start_time_present} or ${is_shift_end_time_present}
        RETURN    True
    ELSE
        RETURN    False
    END
