*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Day Schedule page functionality.
...
...                 = Purpose =
...                 - Centralizes actions for navigating, filtering, and verifying schedules on the Day Schedule page.
...
...                 = Prerequisites =
...                 - Required resources and variable files must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Verify Navigation To Day Schedule Page
...                 |    Navigate To RWS Schedule Day Schedule Page On Web

Resource            resources/web/common/common.resource
Variables           resources/web/rws/schedule/day_schedule_page.py
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/rws/schedule/plan_status.resource
Variables           resources/web/common/status_codes.py
Variables           resources/web/rws/schedule/day_schedule_api.py


*** Keywords ***
Navigate To RWS Schedule Day Schedule Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Day Schedule Page
    Navigate To Specific Page On Web    rws    schedule    day_schedule
    Wait Until Page Is Loaded

Get Vacant Shift Data On Day Schedule Page
    [Documentation]    This keyword returns the vacant shift where a schedule can be added or
    ...    skips the test if not found
    ${emp_shift_rows}    Get Elements    ${DAY_SCHEDULE_SCHEDULE_ROWS}
    ${row_length}    Get Length    ${emp_shift_rows}
    VAR    ${row_found}    False
    ${end}    Evaluate    ${row_length}+1
    FOR    ${row}    IN RANGE    1    ${end}
        ${row_str}    Convert To String    ${row}
        ${shift_row}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_SHIFT_TEXT}    ROW_NUM=${row_str}
        ${shift_row_text}    Get Element Text On Webpage    ${shift_row}
        IF    not $shift_row_text or $shift_row_text.strip() == ''
            ${vacant_shift_row}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_SHIFT_ROW}    ROW_NUM=${row_str}
            ${is_visible}    Is Element Present On Webpage    ${vacant_shift_row}
            IF    ${is_visible}
                VAR    ${row_found}    True
                RETURN    ${row}
            END
        END
    END
    IF    not ${row_found}
        Skip    No vacant rows found on the day schedule page
    END

Add Shift On Day Schedule Page On Web
    [Documentation]    This keyword adds shift on Day Schedule page
    [Arguments]    ${vacant_shift_row_no}    ${day_shift_start_time}=09:00    ${day_shift_end_time}=15:00
    ${row_str}    Convert To String    ${vacant_shift_row_no}
    ${shift_add_row}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_SHIFT_VACANT_ROW}    ROW_NUM=${row_str}
    Mouse Move Relative To    ${shift_add_row}    x=0    y=5
    Mouse Button    click
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_STARTTIME_TXT}
    Clear Textbox On Webpage    ${DAY_SCHEDULE_SHIFT_STARTTIME_TXT}
    Fill Textbox On Webpage    ${DAY_SCHEDULE_SHIFT_STARTTIME_TXT}    ${day_shift_start_time}
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_ENDTIME_TXT}
    Clear Textbox On Webpage    ${DAY_SCHEDULE_SHIFT_ENDTIME_TXT}
    Fill Textbox On Webpage    ${DAY_SCHEDULE_SHIFT_ENDTIME_TXT}    ${day_shift_end_time}
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_ADD_ICON}
    ${ntf_msg_status}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${DAY_SCHEDULE_NOTIFICATION_MSG}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${DAY_SCHEDULE_NOTIFICATION_MSG}
    IF    not ${ntf_msg_status}
        Fail    Failed to add shift: notification message was not displayed
    END

Edit Shift On Day Schedule Page On Web
    [Documentation]    This keyword edits schedule on Day Schedule page
    [Arguments]    ${shift_row_to_edit}    ${edit_shift_end_time}=15:00
    ${is_edit_btn_visible}    Is Element Visible On Webpage    ${DAY_SCHEDULE_SHIFT_EDIT_BTN}
    IF    not ${is_edit_btn_visible}
        ${shift_row_str}    Convert To String    ${shift_row_to_edit}
        ${shift_edit_col}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_SHIFT_ROW}    ROW_NUM=${shift_row_str}
        Mouse Move Relative To    ${shift_edit_col}    x=0    y=20
        Mouse Button    click
    END
    Click Element On Webpage    ${DAY_SCHEDULE_TIMEPICKER_ENDTIME_TXT}
    Clear Textbox On Webpage    ${DAY_SCHEDULE_TIMEPICKER_ENDTIME_TXT}
    Fill Textbox On Webpage    ${DAY_SCHEDULE_TIMEPICKER_ENDTIME_TXT}    ${edit_shift_end_time}
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_EDIT_SAVE_BTN}
    ${ntf_msg_status}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${DAY_SCHEDULE_NOTIFICATION_MSG}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${DAY_SCHEDULE_NOTIFICATION_MSG}
    IF    not ${ntf_msg_status}
        Fail    Failed to edit shift: notification message was not displayed
    END

Delete Shift On Day Schedule Page On Web
    [Documentation]    This keyword deletes shift on Day Schedule page
    [Arguments]    ${shift_row_to_delete}
    ${row_str}    Convert To String    ${shift_row_to_delete}
    ${shift_delete_row}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_SHIFT_DELETE_ROW}    ROW_NUM=${row_str}
    Click Element On Webpage    ${shift_delete_row}
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_DELETE_BTN}
    Click Element On Webpage    ${DAY_SCHEDULE_DELETE_OK_BTN}
    ${ntf_msg_status}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${DAY_SCHEDULE_NOTIFICATION_MSG}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${DAY_SCHEDULE_NOTIFICATION_MSG}
    IF    not ${ntf_msg_status}
        Fail    Failed to delete shift: notification message was not displayed
    END

Perform Undo Operation On Day Schedule Page After Adding Shift On Web
    [Documentation]    This keyword undo operation on Day Schedule page after adding a shift
    [Arguments]    ${shift_row_no}    ${day_shift_start_time}=09:00    ${day_shift_end_time}=15:00
    Add Shift On Day Schedule Page On Web    ${shift_row_no}    ${day_shift_start_time}    ${day_shift_end_time}
    Click Element On Webpage    ${DAY_SCHEDULE_UNDO_ICON}
    ${ntf_msg_status}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${DAY_SCHEDULE_NOTIFICATION_MSG}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${DAY_SCHEDULE_NOTIFICATION_MSG}
    IF    not ${ntf_msg_status}
        Fail    Shift undo operation is not successful
    END

Navigate To Day Level Schedule From Week Schedule Page For The Given Day On Web
    [Documentation]    Navigates to Day Level Schedule from Week Schedule page for a specific day.
    ...    | =Arguments= | =Description= |
    ...    | schedule_day | Day offset or identifier for navigation (e.g., 0=Monday, 1=Tuesday). |
    ...    Example usage:
    ...    | Navigate To Day Level Schedule From Week Schedule Page For The Given Day On Web    2
    [Arguments]    ${schedule_day}
    Wait Until Page Is Loaded
    ${day_offset}    Convert To String    ${schedule_day}
    ${day_schedule_link}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_DAY_OFFSET}    DAY_OFFSET=${day_offset}
    Go To Schedule Page On Web
    Click Element On Webpage    ${day_schedule_link}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Add Shift For The Given Associate On Day Schedule Page On Web
    [Documentation]    Adds a shift for a specific associate on the Day Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to add shift for. |
    ...    | day_shift_start_time | Start time of the shift (e.g., "09:00"). |
    ...    | day_shift_end_time | End time of the shift (e.g., "15:00"). |
    ...    Example usage:
    ...    | Add Shift For The Given Associate On Day Schedule Page On Web    John Doe    09:00    17:00
    [Arguments]    ${associate_name}    ${day_shift_start_time}    ${day_shift_end_time}
    ${shift_add_row}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_ASSOCIATE_SHIFT}    ASSOCIATE_NAME=${associate_name}
    Mouse Move Relative To    ${shift_add_row}    x=0    y=10
    Mouse Button    click
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_STARTTIME_TXT}
    Clear Textbox On Webpage    ${DAY_SCHEDULE_SHIFT_STARTTIME_TXT}
    Fill Textbox On Webpage    ${DAY_SCHEDULE_SHIFT_STARTTIME_TXT}    ${day_shift_start_time}
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_ENDTIME_TXT}
    Clear Textbox On Webpage    ${DAY_SCHEDULE_SHIFT_ENDTIME_TXT}
    Fill Textbox On Webpage    ${DAY_SCHEDULE_SHIFT_ENDTIME_TXT}    ${day_shift_end_time}

    ${promise}    Promise To    Wait For Response    ${DAY_SCHEDULE_ADD_SHIFT_API}
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_ADD_ICON}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Capture Screenshot On Webpage
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[CREATED]

Edit Shift For The Given Associate On Day Schedule Page On Web
    [Documentation]    Edits an existing shift for a specific associate on the Day Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate whose shift to edit. |
    ...    | day_shift_end_time | New end time for the shift (e.g., "18:00"). |
    ...    Example usage:
    ...    | Edit Shift For The Given Associate On Day Schedule Page On Web    John Doe    18:00
    [Arguments]    ${associate_name}    ${day_shift_end_time}
    ${shift_add_row}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_ASSOCIATE_SHIFT}    ASSOCIATE_NAME=${associate_name}
    Mouse Move Relative To    ${shift_add_row}    x=0    y=10
    Mouse Button    click
    Click Element On Webpage    ${DAY_SCHEDULE_TIMEPICKER_ENDTIME_TXT}
    Clear Textbox On Webpage    ${DAY_SCHEDULE_TIMEPICKER_ENDTIME_TXT}
    Fill Textbox On Webpage    ${DAY_SCHEDULE_TIMEPICKER_ENDTIME_TXT}    ${day_shift_end_time}

    ${promise}    Promise To    Wait For Response    ${DAY_SCHEDULE_EDIT_SHIFT_API}
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_EDIT_SAVE_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Capture Screenshot On Webpage
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Un-allocate Shift For The Given Associate On Day Schedule Page On Web
    [Documentation]    Un-allocates (removes) a shift for a specific associate on the Day Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate whose shift to un-allocate. |
    ...    Example usage:
    ...    | Un-allocate Shift For The Given Associate On Day Schedule Page On Web    John Doe
    [Arguments]    ${associate_name}
    ${shift_delete_row}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_ASSOCIATE_SHIFT}    ASSOCIATE_NAME=${associate_name}
    Mouse Move Relative To    ${shift_delete_row}    x=0    y=10
    Mouse Button    click

    ${promise}    Promise To    Wait For Response    ${DAY_SCHEDULE_UNALLOCATE_SHIFT_API}
    Click Element On Webpage    ${DAY_SCHEDULE_SHIFT_DELETE_BTN}
    Click Element On Webpage    ${DAY_SCHEDULE_DELETE_OK_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Capture Screenshot On Webpage
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Perform Undo Operation On Day Schedule Page On Web
    [Documentation]    Performs an undo operation on the Day Schedule page to revert the last action.
    ...    Example usage:
    ...    | Perform Undo Operation On Day Schedule Page On Web

    ${promise}    Promise To    Wait For Response    ${DAY_SCHEDULE_UNDO_SHIFT_API}
    Click Element On Webpage    ${DAY_SCHEDULE_UNDO_ICON}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Capture Screenshot On Webpage
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Delete Shift For The Given Associate On Day Schedule Page On Web
    [Documentation]    Deletes a shift from the open shifts tab on Day Schedule page.
    ...    Converts 24-hour format times to 12-hour format and trims AM/PM indicators for locator matching.
    ...    | =Arguments= | =Description= |
    ...    | day_shift_start_time | Start time of the shift to delete in 24-hour format (e.g., "09:00"). |
    ...    | day_shift_end_time | End time of the shift to delete in 24-hour format (e.g., "17:00"). |
    ...    Example usage:
    ...    | Delete Shift For The Given Associate On Day Schedule Page On Web    09:00    17:00
    [Arguments]    ${day_shift_start_time}    ${day_shift_end_time}
    ${start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${day_shift_start_time}
    ${end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${day_shift_end_time}

    # Trim trailing space and AM/PM indicator (e.g., "10:00 a" -> "10:00")
    ${start_time}    Replace String Using Regexp    ${start_time}    \\s[ap]$    ${EMPTY}
    ${end_time}    Replace String Using Regexp    ${end_time}    \\s[ap]$    ${EMPTY}

    ${shift_to_delete}    Update Locator With Dynamic Values    ${DAY_SCHEDULE_SHIFT_TO_DELETE}    SHIFT_START_TIME=${start_time}
    ...    SHIFT_END_TIME=${end_time}

    Click Element On Webpage    ${DAY_SCHEDULE_OPEN_SHIFTS_TAB}
    Click Element On Webpage    ${shift_to_delete}

    ${promise}    Promise To    Wait For Response    ${DAY_SCHEDULE_DELETE_SHIFT_API}
    Click Element On Webpage    ${DAY_SCHEDULE_OPEN_SHIFTS_DELETE_TAB}
    Click Element On Webpage    ${DAY_SCHEDULE_DELETE_OK_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Capture Screenshot On Webpage
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
