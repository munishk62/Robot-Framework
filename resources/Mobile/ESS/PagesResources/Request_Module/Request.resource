*** Settings ***
Documentation       This file contains keywords for request module of mobile ESS.

Library             DateTime
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/Common/MobileKeyboardUtils.resource


*** Keywords ***
Navigate To Request Module On Mobile ESS
    [Documentation]    Navigates mobile ESS to the request module.
    Navigate Mobile ESS To Module    ${Request_Button_Label}
    ${request_title_locator}    Get Localised Locator Contains    ${Request_Button_Label}
    Wait Until Element Is Visible    ${request_title_locator}    error="Request module is not opened."

Open Add Request Page On Mobile ESS
    [Documentation]    Used for clicking add request button on mobile ESS app.
    ${request_add_button}    Get Localised Locator Contains    ${requestAddDayOffButton}
    Wait Until Element Is Visible    ${request_add_button}
    ...    error="Add request button is not visible, might be issue in loading page or user might not have permission to add request."
    Click Element    ${request_add_button}

Add Day Off Request On Mobile ESS
    [Documentation]    Adds a day off request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${request_start}    | Start date for the request.    |
    ...    | ${request_end}    | End date for the request.    |
    ...    | ${request_reason}    | Reason for the request.    |
    ...    | ${notes}    | Notes for the request.    |
    ...    | ${holiday_hours}    | Holiday hours for the request, if any.    |
    ...    | ${request_approval_due_by}    | approval due by for the request.    |
    [Arguments]    ${request_start}
    ...    ${request_end}
    ...    ${request_reason}
    ...    ${notes}
    ...    ${holiday_hours}=NA
    ...    ${request_approval_due_by}=NA
    Select Request Start Date On Mobile ESS    ${request_start}
    Select Request End Date Directly On Mobile ESS    ${request_end}    ${request_start}
    Sleep    5s
    Select Request Reason On Mobile ESS    ${request_reason}
    IF    '${request_approval_due_by}'!='NA'
        Select Request Approval Due By On Mobile ESS    ${request_approval_due_by}    ${request_end}
    END
    IF    '${holiday_hours}'!= 'NA'
        Enter Holiday Hours On Mobile ESS    ${holiday_hours}    ${request_start}    ${request_end}
    END
    Enter Request Notes On Mobile ESS    ${notes}
    Sleep    1s
    Submit Request On Mobile ESS
    Run Keyword And Ignore Error    Tap Close Toast Message On Mobile ESS

Edit Day Off Request On Mobile ESS
    [Documentation]    Used for editing existing day off request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${request_start}    | Start date for the request.    |
    ...    | ${request_end}    | End date for the request.    |
    ...    | ${request_reason}    | Reason for the request.    |
    ...    | ${notes}    | Notes for the request.    |
    ...    | ${current_selected_start_date}    | current start date selected.    |
    ...    | ${current_selected_end_date}    | current end date selected.    |
    [Arguments]    ${request_start}=NA    ${current_selected_start_date}=NA    ${request_end}=NA    ${current_selected_end_date}=NA
    ...    ${request_reason}=NA    ${notes}=NA    ${holiday_hours}=NA    ${request_approval_due_by}=NA
    Tap Edit Request On Mobile ESS
    IF    '${request_start}' != "NA" or '${request_end}' != "NA"
        IF    '${request_start}' != "NA" and '${request_end}' != "NA"
            ${server_df_format}    Get Config Value    SERVER_DF
            ${formatted_request_start}    Calculate Date From Week Day Offset    ${request_start}    ${server_df_format}
            ${formatted_current_selected_end_date}    Calculate Date From Week Day Offset    ${current_selected_end_date}    SERVER_DF
            IF    '${formatted_request_start} > ${formatted_current_selected_end_date}'
                Select Request Start Date On Mobile ESS    ${request_start}    ${current_selected_start_date}
                Select Request End Date Directly On Mobile ESS    ${request_end}    ${request_start}
            ELSE
                Select Request Start Date On Mobile ESS    ${request_start}    ${current_selected_start_date}
                Select Request End Date Directly On Mobile ESS    ${request_end}    ${current_selected_end_date}
            END
        ELSE IF    '${request_start}' != "NA"
            Select Request Start Date On Mobile ESS    ${request_start}    ${current_selected_start_date}
        ELSE
            Select Request End Date On Mobile ESS    ${request_end}    ${current_selected_end_date}
        END
    END
    IF    '${request_reason}' != "NA"
        Select Request Reason On Mobile ESS    ${request_reason}
    END
    IF    '${notes}' != "NA"
        Enter Request Notes On Mobile ESS    ${notes}
        Hide Mobile Keyboard
    END
    IF    '${holiday_hours}'!= 'NA'
        Enter Holiday Hours On Mobile ESS    ${holiday_hours}    ${request_start}    ${request_end}
    END
    IF    '${request_approval_due_by}'!='NA'
        Select Request Approval Due By On Mobile ESS    ${request_approval_due_by}    ${request_end}
    END
    Sleep    3s
    Save Request On Mobile ESS
    Run Keyword And Ignore Error    Tap Close Toast Message On Mobile ESS

Edit Time Off Request On Mobile ESS
    [Documentation]    Used for editing existing time off request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${request_start_date}    | Start date for the request.    |
    ...    | ${request_start_time}    | Start time for the request.    |
    ...    | ${prepopulated_start_time}    | Prepopulated start time on time picker, used for optimization of time picker if time is already prepopulated.    |
    ...    | ${request_end_time}    | End time for the request.    |
    ...    | ${prepopulated_end_time}    | Prepopulated end time on time picker, used for optimization of time picker if time is already prepopulated.    |
    ...    | ${request_reason}    | Reason for the request.    |
    ...    | ${notes}    | Notes for the request.    |
    [Arguments]    ${request_start_date}=NA    ${request_start_time}=NA    ${prepopulated_start_time}=NA    ${request_end_time}=NA
    ...    ${prepopulated_end_time}=NA    ${request_reason}=NA    ${notes}=NA
    Tap Edit Request On Mobile ESS
    IF    '${request_start_date}' != "NA"
        Select Request Start Date On Mobile ESS    ${request_start_date}
    END
    IF    '${request_start_time}' != "NA"
        Select Request Start Time On Mobile ESS    ${request_start_time}    ${prepopulated_start_time}
    END
    IF    '${request_end_time}' != "NA"
        Select Request End Time On Mobile ESS    ${request_end_time}    ${prepopulated_end_time}
    END
    IF    '${request_reason}' != "NA"
        Select Request Reason On Mobile ESS    ${request_reason}
    END
    IF    '${notes}' != "NA"
        Enter Request Notes On Mobile ESS    ${notes}
        Hide Mobile Keyboard
    END
    Save Request On Mobile ESS
    Run Keyword And Ignore Error    Tap Close Toast Message On Mobile ESS

Select Request Start Date On Mobile ESS
    [Documentation]    Used for selecting start date for request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${request_start}    | Start date for the request.    |
    ...    | ${calendar_open_date}    | current open date on calendar, it is used for optimization of calendar navigation if calendar is already open |
    [Arguments]    ${request_start}    ${calendar_open_date}=NA
    ${request_start_date_label}    Get Localised Locator Contains    ${requestStartDate}
    Select Date On Calendar    ${request_start_date_label}    ${request_start}    ${calendar_open_date}

Select Request End Date On Mobile ESS
    [Documentation]    Used for selecting end date for request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${request_end}    | End date for the request.    |
    ...    | ${calendar_open_date}    | current open date on calendar, it is used for optimization of calendar navigation if calendar is already open |
    [Arguments]    ${request_end}    ${calendar_open_date}=NA
    ${request_end_date_label}    Get Localised Locator Contains    ${requestEndDate}
    Select Date On Calendar    ${request_end_date_label}    ${request_end}    ${calendar_open_date}

Select Request End Date Directly On Mobile ESS
    [Documentation]    Used for selecting end date for request when calendar is already open on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${request_end}    | End date for the request.    |
    ...    | ${calendar_open_date}    | current open date on calendar, it is used for optimization of calendar navigation if calendar is already open |
    [Arguments]    ${request_end}    ${calendar_open_date}
    ${date_format}    Get Config Value    SERVER_DF
    ${calendar_open_date_converted}    Calculate Date From Week Day Offset    ${calendar_open_date}    ${date_format}
    Navigate Calendar To    ${request_end}    ${calendar_open_date_converted}

Tap Edit Request On Mobile ESS
    [Documentation]    Used for tapping edit button on request details page on mobile ESS app.
    ${edit_button_label}    Get Localised Locator Contains    ${requestEdit}
    Expect Element    ${edit_button_label}    visible
    Click Element    ${edit_button_label}
    ${edit_window_title_locator}    Get Localised Locator Exact    ${request_edit_window_title}
    Wait Until Element Is Visible    ${edit_window_title_locator}

Add Time Off Request On Mobile ESS
    [Documentation]    Adds a time off request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | request_start    | Start date for the request.    |
    ...    | request_start_time    | Start time for the request.    |
    ...    | request_end_time    | End time for the request.    |
    ...    | request_reason    | Reason for the request.    |
    ...    | notes    | Notes for the request.    |
    ...    | request_approval_due_by    | approval due by date for the request.    |
    [Arguments]    ${request_start}    ${request_start_time}    ${request_end_time}    ${request_reason}    ${notes}
    ...    ${request_approval_due_by}=NA
    Select Request Start Date On Mobile ESS    ${request_start}
    Select Request Start Time On Mobile ESS    ${request_start_time}
    Select Request End Time Directly On Mobile ESS    ${request_end_time}    ${request_start_time}
    # Wait until submit button is clickable before entering notes, reason and approval due by to avoid any issues with loading screen after time selection.
    ${submit_locator}    Get Localised Locator Contains    ${submitButton}
    Wait Until Mobile Element Is Clickable    ${submit_locator}
    Enter Request Notes On Mobile ESS    ${notes}
    Select Request Reason On Mobile ESS    ${request_reason}
    Select Request Approval Due By On Mobile ESS    ${request_start}    ${request_approval_due_by}
    Submit Request On Mobile ESS
    Run Keyword And Ignore Error    Tap Close Toast Message On Mobile ESS

Select Request Start Time On Mobile ESS
    [Documentation]    Used for selecting start time for request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${start_time}    | Start time for the request.    |
    ...    | ${prepopulated_start_time}    | Prepopulated start time on time picker, used for optimization of time picker if time is already prepopulated.    |
    [Arguments]    ${start_time}    ${prepopulated_start_time}=NA
    ${request_start_time_label}    Get Localised Locator Contains    ${requestStartTime}
    Wait Until Element Is Visible    ${request_start_time_label}
    Click Element    ${request_start_time_label}
    Select Time On Time Picker    ${start_time}    ${prepopulated_start_time}

Select Request End Time On Mobile ESS
    [Documentation]    Used for selecting end time for request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${end_time}    | End time for the request.    |
    ...    | ${prepopulated_end_time}    | Prepopulated end time on time picker, used for optimization of time picker if time is already prepopulated.    |
    [Arguments]    ${end_time}    ${prepopulated_end_time}=NA
    ${request_end_time_label}    Get Localised Locator Contains    ${requestEndTime}
    Wait Until Element Is Visible    ${request_end_time_label}
    Click Element    ${request_end_time_label}
    Select Time On Time Picker    ${end_time}    ${prepopulated_end_time}

Select Request End Time Directly On Mobile ESS
    [Documentation]    Used for selecting end time directly for request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | end_time    | End time for the request.    |
    ...    | prepopulated_end_time    | Prepopulated end time on time picker, used for optimization of time picker if time is already prepopulated.    |
    [Arguments]    ${end_time}    ${prepopulated_end_time}
    Select Time On Time Picker    ${end_time}    ${prepopulated_end_time}

Select Request Reason On Mobile ESS
    [Documentation]    Used for selecting reason for request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${reason}    | Reason for request.    |
    [Arguments]    ${reason}
    ${reason_locator}    Get Locator Contains    ${reason}
    ${reason_semantic}    Evaluate    '''${translated_Map['${reasonLabel}']} '''
    ${locator}    Get Locator Contains    ${reason_semantic}
    Wait Until Element Is Visible    ${locator}    error="Reason dropdown is not visible."
    Click Element    ${locator}
    Wait Until Page Contains Element    ${reason_locator}    error="Reason option ${reason} is not visible in dropdown."
    Click Element    ${reason_locator}

Select Request Approval Due By On Mobile ESS
    [Documentation]    Used for selecting Approval Due By for request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${request_approval_due_by}    | Approval Due By for request.    |
    ...    | ${calendar_open_date}    | current open date on calendar, it is used for optimization of calendar navigation if calendar is already open |
    [Arguments]    ${request_approval_due_by}    ${calendar_open_date}=NA
    Log    TODO need to develop this

Enter Holiday Hours On Mobile ESS
    [Documentation]    Used for entering holiday hours for request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${hours}    | Holiday hours for request.    |
    ...    | ${start_date}    | Start date for request, it is used for optimization of entering holiday hours if hours are same for all days of request.    |
    ...    | ${end_date}    | End date for request, if end date is given it will loop from start date to end date to fill all the dates with given holiday hours.    |
    [Arguments]    ${hours}    ${start_date}    ${end_date}=''
    ${date_format}    Get Config Value    SERVER_DF
    ${holiday_hour_date_format}    Get Config Value    FULL_DATE_DF_SHORT
    ${start_date_converted}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}
    IF    '${end_date}' == ''
        VAR    ${end_date}    ${start_date}
    END
    ${end_date_converted}    Calculate Date From Week Day Offset    ${end_date}    ${date_format}
    ${raw_gap_days}    Calculate Date Difference In Days    ${start_date_converted}    ${end_date_converted}    ${date_format}
    IF    ${raw_gap_days} < 0
        Fail    End date ${end_date} resolves before start date ${start_date}.
    END
    ${days_to_fill}    Evaluate    ${raw_gap_days} + 1
    VAR    ${current_date}    ${start_date_converted}

    FOR    ${_}    IN RANGE    ${days_to_fill}
        ${parsed_date}    Convert Date    ${current_date}    date_format=${date_format}    result_format=${holiday_hour_date_format}
        ${holiday_hours_label}    Get Locator Contains    ${parsed_date}
        Wait Until Page Contains Element    ${holiday_hours_label}
        Click Element    ${holiday_hours_label}
        Input Text    ${holiday_hours_label}    ${hours}
        Hide Keyboard
        ${current_date}    Add Time To Date    ${current_date}    1 days    result_format=${date_format}
    END

Enter Request Notes On Mobile ESS
    [Documentation]    Used for entering note for request on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${note_data}    | Note for request.    |
    [Arguments]    ${note_data}
    ${note_locator}    Evaluate    '${translated_Map['${note}']} '
    ${note_label}    Get Locator Contains    ${note_locator}
    Swipe Until Visible    ${note_label}
    Wait Until Page Contains Element    ${note_label}    error="Note field is not visible."
    Click Element    ${note_label}
    Input Text    ${note_label}    ${note_data}
    Sleep    1s
    Hide Mobile Keyboard

Submit Request On Mobile ESS
    [Documentation]    Used for submitting request on mobile ESS app.
    ${submit_button_label}    Get Localised Locator Contains    ${submitButton}
    ${request_add_button}    Get Localised Locator Contains    ${requestAddDayOffButton}
    Wait Until Element Is Visible    ${submit_button_label}
    Click Element    ${submit_button_label}
    Run Keyword And Ignore Error    Confirm Request Conflict On PopUp Window On Mobile ESS
    Wait Until Page Contains Element    ${request_add_button}

Save Request On Mobile ESS
    [Documentation]    Used for saving request after editing on mobile ESS app.
    ${save_button_label}    Get Localised Locator Contains    ${saveButton}
    ${edit_button_label}    Get Localised Locator Contains    ${requestEdit}
    Wait Until Element Is Visible    ${save_button_label}
    Click Element    ${save_button_label}
    Run Keyword And Ignore Error    Confirm Request Conflict On PopUp Window On Mobile ESS
    Wait Until Page Contains Element    ${edit_button_label}

Verify Pending Day Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying request in pending status in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}
    Verify Day Off Request List Item On Mobile ESS    ${req_start_date}    ${req_end_date}    ${requestPending}

Verify Day Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying request in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    ...    | ${req_status}    | Status of request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}    ${req_status}
    ${request_list_item_semantic}    Get Day Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_end_date}
    ...    ${req_status}
    Swipe Until Visible    ${request_list_item_semantic}    maxSwipes=10
    Wait Until Page Contains Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and end date ${req_end_date} with status ${req_status} is not visible in request list."

Verify Pending Time Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying time off request in pending status in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date} | Start date for request. |
    ...    | ${req_start_time} | Start time for request. |
    ...    | ${req_end_time} | End time for request. |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}
    Verify Time Off Request List Item On Mobile ESS    ${req_start_date}    ${req_start_time}    ${req_end_time}    ${requestPending}

Verify Time Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying time off request in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date} | Start date for request. |
    ...    | ${req_start_time} | Start time for request. |
    ...    | ${req_end_time} | End time for request. |
    ...    | ${req_status} | Status of request. |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}    ${req_status}
    ${request_list_item_semantic}    Get Time Off Request List Semantic On Mobile ESS    ${req_start_date}
    ...    ${req_start_time}    ${req_end_time}    ${req_status}
    Swipe Until Visible    ${request_list_item_semantic}    maxSwipes=10
    Wait Until Page Contains Element    ${request_list_item_semantic}

Get Day Off Request List Semantic On Mobile ESS
    [Documentation]    Used for verifying request in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    ...    | ${req_status}    | Status of request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}    ${req_status}
    ${date_format}    Get Config Value    DATE_FMT_ABBR_WEEKDAY_MONTH_DAY
    VAR    ${dateText}    ''
    IF    '${req_start_date}' == '${req_end_date}'
        ${dateText}    Calculate Date From Week Day Offset    ${req_start_date}    ${date_format}
    ELSE
        ${requestStartText}    Calculate Date From Week Day Offset    ${req_start_date}    ${date_format}
        ${requestEndText}    Calculate Date From Week Day Offset    ${req_end_date}    ${date_format}
        VAR    ${dateText}    ${requestStartText} - ${requestEndText}
    END
    ${req_status_semantic}    Get Localised Message From Key    ${req_status}
    ${requestListItemSemantic}    Get Localised Locator Contains    ${requestDayOffList}    ${dateText}    ${req_status_semantic}
    RETURN    ${requestListItemSemantic}

Get Time Off Request List Semantic On Mobile ESS
    [Documentation]    Used for verifying request time off in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date} | Start date for request. |
    ...    | ${req_start_time} | Start time for request. |
    ...    | ${req_end_time} | End time for request. |
    ...    | ${req_status} | Status of request. |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}    ${req_status}
    ${format_date_to}    Get Config Value    DATE_FMT_ABBR_WEEKDAY_MONTH_DAY
    ${date_text}    Calculate Date From Week Day Offset    ${req_start_date}    ${format_date_to}
    ${req_status_value}    Get Localised Message From Key    ${req_status}
    ${start_time}    Format Time String    ${req_start_time}
    ${end_time}    Format Time String    ${req_end_time}
    ${request_list_item_semantic}    Get Localised Locator Contains    ${requestTimeOffList}    ${date_text}    ${start_time}
    ...    ${end_time}    ${req_status_value}
    RETURN    ${request_list_item_semantic}

Tap Pending Day Off Request List Item On Mobile ESS
    [Documentation]    Used for tapping on request list item on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}
    Tap Day Off Request List Item On Mobile ESS    ${req_start_date}    ${req_end_date}    ${requestPending}

Tap Day Off Request List Item On Mobile ESS
    [Documentation]    Used for tapping on request list item on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    ...    | ${req_status}    | Status of request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}    ${req_status}
    ${request_list_item_semantic}    Get Day Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_end_date}
    ...    ${req_status}
    Swipe Until Visible    ${request_list_item_semantic}
    Wait Until Page Contains Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and end date ${req_end_date} with status ${req_status} is not visible in request list."
    Click Element    ${request_list_item_semantic}

Tap Pending Time Off Request List Item On Mobile ESS
    [Documentation]    Taps on pending time off request in the list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date} | Start date for request. |
    ...    | ${req_start_time} | Start time for request. |
    ...    | ${req_end_time} | End time for request. |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}
    Tap Time Off Request List Item On Mobile ESS    ${req_start_date}    ${req_start_time}    ${req_end_time}    ${requestPending}

Tap Time Off Request List Item On Mobile ESS
    [Documentation]    Used for tapping on request list item on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date} | Start date for request. |
    ...    | ${req_start_time} | Start time for request. |
    ...    | ${req_end_time} | End time for request. |
    ...    | ${req_status} | Status of request. |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}    ${req_status}
    ${request_list_item_semantic}    Get Time Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_start_time}
    ...    ${req_end_time}    ${req_status}
    Swipe Until Visible    ${request_list_item_semantic}
    Wait Until Page Contains Element    ${request_list_item_semantic}
    Click Element    ${request_list_item_semantic}

Delete Request On Mobile ESS
    [Documentation]    Deletes a request on mobile ESS app.
    ${delete_button}    Get Localised Locator Contains    ${requestDelete}
    Wait Until Element Is Visible    ${delete_button}
    ...    error="Delete button is not visible, might be issue in loading page or user might not have permission to delete request."
    Click Element    ${delete_button}
    ${delete_button_confirm}    Get Localised Locator Exact    ${requestDelete}
    Click Element    ${delete_button_confirm}

Switch To Time Off Request On Mobile ESS
    [Documentation]    Selects time off request radio on mobile ess.
    ${request_timeoff_label}    Get Localised Locator Contains    ${requestTimeoff}
    Click Element    ${request_timeoff_label}

Verify No Day Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying request is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}
    Verify No Pending Day Off Request List Item On Mobile ESS    ${req_start_date}    ${req_end_date}
    Verify No Approved Day Off Request List Item On Mobile ESS    ${req_start_date}    ${req_end_date}
    Verify No Declined Day Off Request List Item On Mobile ESS    ${req_start_date}    ${req_end_date}
    Verify No Cancelled Day Off Request List Item On Mobile ESS    ${req_start_date}    ${req_end_date}

Verify No Pending Day Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying request in pending status is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}
    ${request_list_item_semantic}    Get Day Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_end_date}
    ...    ${requestPending}
    Page Should Not Contain Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and end date ${req_end_date} with status ${requestPending} is still visible in request list, it might not be deleted successfully."

Verify No Approved Day Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying request in approved status is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}
    ${request_list_item_semantic}    Get Day Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_end_date}
    ...    ${requestApproved}
    Page Should Not Contain Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and end date ${req_end_date} with status ${requestApproved} is still visible in request list, it might not be deleted successfully."

Verify No Declined Day Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying request in declined status is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}
    ${request_list_item_semantic}    Get Day Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_end_date}
    ...    ${requestDeclined}
    Page Should Not Contain Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and end date ${req_end_date} with status ${requestDeclined} is still visible in request list, it might not be deleted successfully."

Verify No Cancelled Day Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying request in cancelled status is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_end_date}    | End date for request.    |
    [Arguments]    ${req_start_date}    ${req_end_date}
    ${request_list_item_semantic}    Get Day Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_end_date}
    ...    ${requestCancelled}
    Page Should Not Contain Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and end date ${req_end_date} with status ${requestCancelled} is still visible in request list, it might not be deleted successfully."

Verify No Time Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying time off request is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date} | Start date for request. |
    ...    | ${req_start_time} | Start time for request. |
    ...    | ${req_end_time} | End time for request. |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}
    Verify No Pending Time Off Request List Item On Mobile ESS    ${req_start_date}    ${req_start_time}    ${req_end_time}
    Verify No Approved Time Off Request List Item On Mobile ESS    ${req_start_date}    ${req_start_time}    ${req_end_time}
    Verify No Declined Time Off Request List Item On Mobile ESS    ${req_start_date}    ${req_start_time}    ${req_end_time}
    Verify No Cancelled Time Off Request List Item On Mobile ESS    ${req_start_date}    ${req_start_time}    ${req_end_time}

Verify No Pending Time Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying time off request in pending status is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_start_time}    | Start time for request.    |
    ...    | ${req_end_time}    | End time for request.    |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}
    ${request_list_item_semantic}    Get Time Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_start_time}
    ...    ${req_end_time}    ${requestPending}
    Page Should Not Contain Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and start time ${req_start_time} and end time ${req_end_time} with status ${requestPending} is still visible in request list, it might not be deleted successfully."

Verify No Approved Time Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying time off request in approved status is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_start_time}    | Start time for request.    |
    ...    | ${req_end_time}    | End time for request.    |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}
    ${request_list_item_semantic}    Get Time Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_start_time}
    ...    ${req_end_time}    ${requestApproved}
    Page Should Not Contain Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and start time ${req_start_time} and end time ${req_end_time} with status ${requestPending} is still visible in request list, it might not be deleted successfully."

Verify No Declined Time Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying time off request in declined status is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_start_time}    | Start time for request.    |
    ...    | ${req_end_time}    | End time for request.    |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}
    ${request_list_item_semantic}    Get Time Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_start_time}
    ...    ${req_end_time}    ${requestDeclined}
    Page Should Not Contain Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and start time ${req_start_time} and end time ${req_end_time} with status ${requestPending} is still visible in request list, it might not be deleted successfully."

Verify No Cancelled Time Off Request List Item On Mobile ESS
    [Documentation]    Used for verifying time off request in cancelled status is not present in list on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${req_start_date}    | Start date for request.    |
    ...    | ${req_start_time}    | Start time for request.    |
    ...    | ${req_end_time}    | End time for request.    |
    [Arguments]    ${req_start_date}    ${req_start_time}    ${req_end_time}
    ${request_list_item_semantic}    Get Time Off Request List Semantic On Mobile ESS    ${req_start_date}    ${req_start_time}
    ...    ${req_end_time}    ${requestCancelled}
    Page Should Not Contain Element    ${request_list_item_semantic}
    ...    error="Request with start date ${req_start_date} and start time ${req_start_time} and end time ${req_end_time} with status ${requestPending} is still visible in request list, it might not be deleted successfully."

Confirm Request Conflict On PopUp Window On Mobile ESS
    [Documentation]    Confirms request conflict on popup window if it appears after submitting request on mobile ESS app.
    ${req_conflict_label}    Get Localised Locator Contains    ${requestConflictLabel}
    Wait Until Element Is Visible    ${req_conflict_label}
    ${req_conflict_confirm_label}    Get Localised Locator Contains    ${confirmButton}
    Wait Until Element Is Visible    ${req_conflict_confirm_label}
    Click Element    ${req_conflict_confirm_label}

Verify Toast Message Appears On Mobile ESS
    [Documentation]    Verifies toast message appears on mobile ESS app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${message_key}    | Localisation key of toast message to verify.    |
    ...    | ${timeout}    | Maximum wait time for toast message visibility.    |
    [Arguments]    ${message_key}    ${timeout}=10s
    ${toast_message_locator}    Get Localised Locator Contains    ${message_key}
    Wait Until Page Contains Element    ${toast_message_locator}    timeout=${timeout}

Verify Invalid Error Data Message On Mobile ESS
    [Documentation]    Verifies invalid error data message on ESS app
    Verify Toast Message Appears On Mobile ESS  ${COMMON_ERROR_INVALID_DATA}

Click Submit Request On Mobile ESS
    [Documentation]    Submitting the request on ESS app
    ${submit_button_label}    Get Localised Locator Contains    ${submitButton}
    Click Element    ${submit_button_label}

Swipe To Request Start Date On Mobile ESS
    [Documentation]    Used for swiping to start date field on time off request page on mobile ESS app, it is used when start date field is not visible on screen.
    ${request_start_date_label}    Get Localised Locator Contains    ${requestStartDate}
    Swipe Until Visible    ${request_start_date_label}    direction="up"
