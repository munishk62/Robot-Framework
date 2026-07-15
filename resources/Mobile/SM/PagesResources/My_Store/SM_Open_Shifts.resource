*** Settings ***
Documentation       This resource contains keywords required for managing Open Shifts on the My Store page in the SM mobile app.

Library             DateTime
Library             Process
Library             test_data/TestDataLibrary.py
Resource            resources/Mobile/Common/Common_Mobile.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource
Variables           resources/Mobile/SM/Locators/SM_Open_Shifts_Page.py


*** Keywords ***
Add Open Shift On My Store Page On SM Phone App
    [Documentation]    Used to click add open shift button on my store page.
    [Arguments]    ${open_shift_date_offset}    ${open_shift_template}
    Select Week On My Store Page On SM Phone App    ${open_shift_date_offset}
    Click Open Shifts Section On My Store Page On SM Phone App
    Wait Until Element Is Visible    ${SM_MY_STORE_ADD_OPEN_SHIFT_BTN}    error=Add Open Shift button is not visible on open shifts page.
    Click Element    ${SM_MY_STORE_ADD_OPEN_SHIFT_BTN}
    ${overlay_info_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${SM_MY_STORE_OK_ACTION_BTN}
    ...    ${MEDIUM_TIMEOUT}
    IF    ${overlay_info_visible}
        Click Element    ${SM_MY_STORE_OK_ACTION_BTN}
        Wait Until Page Does Not Contain Element    ${SM_MY_STORE_OK_ACTION_BTN}
    END
    ${server_df_format}    Get Config Value    SERVER_DF
    ${calendar_open_date_converted}    Calculate Date From Week Day Offset    ${open_shift_date_offset}    ${server_df_format}
    Wait Until Page Contains Element    ${SM_OPEN_SHIFT_CALENDAR_NAVIGATION}    timeout=${MEDIUM_TIMEOUT}
    ...    error=Calendar navigation button is not visible on open shift details page after clicking add open shift button.
    Click Element    ${SM_OPEN_SHIFT_CALENDAR_NAVIGATION}
    Navigate SM Calendar To    ${open_shift_date_offset}    ${calendar_open_date_converted}
    Click Element    ${SM_OPEN_SHIFT_SELECT_STAFF_GROUP}
    ${staff_group_option_locator}    Get Message With Arguments For SM    ${SM_OPEN_SHIFT_OPTION_IN_STAFF_GROUP_LIST}
    ...    ${open_shift_template}[staff_group]
    Wait Until Element Is Visible    ${staff_group_option_locator}
    ...    error=Staff group option is not visible in staff group dropdown on open shift details page.
    Click Element    ${staff_group_option_locator}
    Select Shift Timings On Open Shift Page On SM Phone App    ${open_shift_template}[start_time]    ${open_shift_template}[end_time]
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_SELECT_TASK}
    ...    error=Task dropdown is not visible on open shift details page after selecting date and time.
    Click Element    ${SM_OPEN_SHIFT_SELECT_TASK}
    ${task_option_locator}    Get Message With Arguments For SM    ${SM_OPEN_SHIFT_OPTION_IN_TASK_LIST}    ${open_shift_template}[task]
    Wait Until Element Is Visible    ${task_option_locator}
    ...    error=Task option is not visible in task dropdown on open shift details page.
    Click Element    ${task_option_locator}
    Save Open Shift Without Meal Break On Open Shift Page On SM Phone App

Click Save For Open Shift On Open Shift Page On SM Phone App
    [Documentation]    Used to click save shift button on open shift details page after entering all the details for open shift.
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_SAVE_SHIFT_BTN}
    ...    error=Save shift button is not visible on open shift details page after selecting task.
    Click Element    ${SM_OPEN_SHIFT_SAVE_SHIFT_BTN}

Save Open Shift Without Meal Break On Open Shift Page On SM Phone App
    [Documentation]    Used to click save shift button on open shift details page after entering all the details for open shift.
    Click Save For Open Shift On Open Shift Page On SM Phone App
    ${shift_addition_success}    Get Localised Message From Key For SM    ${SM_OPEN_SHIFT_ADDED_MESSAGE}
    ${shift_addition_success_locator}    Get Message With Arguments For SM    ${SM_OPEN_SHIFT_NOTIFICATION_MESSAGE}
    ...    ${shift_addition_success}
    ${is_success_message_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${shift_addition_success_locator}
    ...    timeout=${MEDIUM_TIMEOUT}    error=Open shift success message is not visible after creating open shift on my store page.
    IF    not ${is_success_message_visible}
        ${do_not_apply_meal_break_label}    Get Localised Message From Key For SM    ${SM_OPEN_SHIFT_SAVE_DO_NOT_APPLY_MEAL_BREAK}
        ${save_without_meal_break}    Get Message With Arguments For SM    ${SM_OPEN_SHIFT_SAVE_OPTION}    ${do_not_apply_meal_break_label}
        Click Element    ${save_without_meal_break}
        Verify Open Shift Addition Success Message On SM Phone App
    ELSE
        Wait Until Page Does Not Contain Element    ${shift_addition_success_locator}
    END

Select Shift Timings On Open Shift Page On SM Phone App
    [Documentation]    Used to select shift timings while creating open shift on my store page.
    ...    | =Arguments=    | =Description=    |
    ...    | shift_start_time | Start time of the shift. |
    ...    | shift_end_time | End time of the shift. |
    ...    Example usage:
    ...    | Select Shift Timings On Open Shift Page On SM Phone App    14:00    18:00 |
    [Arguments]    ${shift_start_time}    ${shift_end_time}
    Wait Until Page Contains Element    ${SM_OPEN_SHIFT_SELECT_START_TIME}    timeout=10s
    Click Element    ${SM_OPEN_SHIFT_SELECT_START_TIME}
    ${is_scrollable_time_picker_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${TIME_SAVE_BUTTON}    timeout=${SHORT_TIMEOUT}
    IF    ${is_scrollable_time_picker_visible}
        Select Shift Timings On Open Shift Page From Scrollable Time Picker On SM Phone App    ${shift_start_time}    ${shift_end_time}
    ELSE
        Select Shift Timings On Open Shift Page From Non Scrollable Time Picker On SM Phone App    ${shift_start_time}    ${shift_end_time}
    END

Select Shift Timings On Open Shift Page From Non Scrollable Time Picker On SM Phone App
    [Documentation]    Used to select shift timings while creating open shift on my store page.
    ...    | =Arguments=    | =Description=    |
    ...    | shift_start_time | Start time of the shift. |
    ...    | shift_end_time | End time of the shift. |
    ...    Example usage:
    ...    | Select Shift Timings On Open Shift Page From Non Scrollable Time Picker On SM Phone App    14:00    18:00 |
    [Arguments]    ${shift_start_time}    ${shift_end_time}
    ${is_12_hour_format}    Get Config Value    TIME_FORMAT_12_HRS
    IF    ${is_12_hour_format}
        ${start_time}    Convert 24hr Time To 12hr    ${shift_start_time}
        ${start_time_split}    Split String    ${start_time}    ${SPACE}
        ${start_time_hour_and_minute}    Split String    ${start_time_split}[0]    :
        VAR    ${start_time_am_pm}    ${start_time_split}[1]
        ${end_time}    Convert 24hr Time To 12hr    ${shift_end_time}
        ${end_time_split}    Split String    ${end_time}    ${SPACE}
        ${end_time_hour_and_minute}    Split String    ${end_time_split}[0]    :
        VAR    ${end_time_am_pm}    ${end_time_split}[1]
    ELSE
        VAR    ${start_time}    ${shift_start_time}
        ${start_time_hour_and_minute}    Split String    ${start_time}    :
        VAR    ${end_time}    ${shift_end_time}
        ${end_time_hour_and_minute}    Split String    ${end_time}    :
    END
    # start time selection
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_TOGGLE_KEYBOARD}
    Click Element    ${SM_OPEN_SHIFT_TOGGLE_KEYBOARD}
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_HOUR_INPUT}
    Input Text    ${SM_OPEN_SHIFT_HOUR_INPUT}    ${start_time_hour_and_minute}[0]
    Input Text    ${SM_OPEN_SHIFT_MINUTE_INPUT}    ${start_time_hour_and_minute}[1]
    IF    ${is_12_hour_format}
        Click Element    ${SM_OPEN_SHIFT_AM_PM_SELECT}
        Wait Until Page Does Not Contain Element    ${SM_OPEN_SHIFT_AM_PM_SELECT}
        IF    '${start_time_am_pm}' == 'AM'
            Wait Until Element Is Visible    ${SM_OPEN_SHIFT_AM_VALUE_SELECT}    ${MEDIUM_TIMEOUT}
            ...    error=AM/PM select is not visible on open shift details page.
            Click Element    ${SM_OPEN_SHIFT_AM_VALUE_SELECT}
        ELSE
            Wait Until Element Is Visible    ${SM_OPEN_SHIFT_PM_VALUE_SELECT}    ${MEDIUM_TIMEOUT}
            ...    error=AM/PM select is not visible on open shift details page.
            Click Element    ${SM_OPEN_SHIFT_PM_VALUE_SELECT}
        END
    END
    Click Element    ${SM_OPEN_SHIFT_TIME_DIALOG_OK_BTN}
    # end time selection
    Wait Until Page Contains Element    ${SM_OPEN_SHIFT_SELECT_END_TIME}
    Click Element    ${SM_OPEN_SHIFT_SELECT_END_TIME}
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_TOGGLE_KEYBOARD}
    Click Element    ${SM_OPEN_SHIFT_TOGGLE_KEYBOARD}
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_HOUR_INPUT}
    Input Text    ${SM_OPEN_SHIFT_HOUR_INPUT}    ${end_time_hour_and_minute}[0]
    Input Text    ${SM_OPEN_SHIFT_MINUTE_INPUT}    ${end_time_hour_and_minute}[1]
    IF    ${is_12_hour_format}
        Click Element    ${SM_OPEN_SHIFT_AM_PM_SELECT}
        IF    '${end_time_am_pm}' == 'AM'
            Wait Until Element Is Visible    ${SM_OPEN_SHIFT_AM_VALUE_SELECT}    ${MEDIUM_TIMEOUT}
            ...    error=AM/PM select is not visible on open shift details page.
            Click Element    ${SM_OPEN_SHIFT_AM_VALUE_SELECT}
        ELSE
            Wait Until Element Is Visible    ${SM_OPEN_SHIFT_PM_VALUE_SELECT}    ${MEDIUM_TIMEOUT}
            ...    error=AM/PM select is not visible on open shift details page.
            Click Element    ${SM_OPEN_SHIFT_PM_VALUE_SELECT}
        END
    END
    Click Element    ${SM_OPEN_SHIFT_TIME_DIALOG_OK_BTN}

Select Shift Timings On Open Shift Page From Scrollable Time Picker On SM Phone App
    [Documentation]    Used to select shift timings while creating open shift on my store page.
    ...    | =Arguments=    | =Description=    |
    ...    | shift_start_time | Start time of the shift. |
    ...    | shift_end_time | End time of the shift. |
    ...    Example usage:
    ...    | Select Shift Timings On Open Shift Page From Scrollable Time Picker On SM Phone App    14:00    18:00 |
    [Arguments]    ${shift_start_time}    ${shift_end_time}
    Select Time On Scrollable Time Picker On SM Phone App    ${shift_start_time}
    Wait Until Page Contains Element    ${SM_OPEN_SHIFT_SELECT_END_TIME}
    Click Element    ${SM_OPEN_SHIFT_SELECT_END_TIME}
    Select Time On Scrollable Time Picker On SM Phone App    ${shift_end_time}

Verify Open Shift Addition Success Message On SM Phone App
    [Documentation]    Used to verify open shift addition success message after creating open shift on my store page
    ${shift_addition_success}    Get Localised Message From Key For SM    ${SM_OPEN_SHIFT_ADDED_MESSAGE}
    ${shift_addition_success_locator}    Get Message With Arguments For SM    ${SM_OPEN_SHIFT_NOTIFICATION_MESSAGE}
    ...    ${shift_addition_success}
    Wait Until Element Is Visible    ${shift_addition_success_locator}    timeout=${LONG_TIMEOUT}
    ...    error=Open shift success message is not visible after creating open shift on my store page.
    Wait Until Page Does Not Contain Element    ${shift_addition_success_locator}

Click Open Shift Request On Open Shifts Page On SM Phone App
    [Documentation]    Used to click on shift request for an open shift on open shifts page.
    ...    | =Arguments=    | =Description=    |
    ...    | shift_date_offset    | Week day offset to identify the open shift request to click on. |
    ...    | open_shift_staff_group | Staff group of the open shift for which shift request needs to be clicked. |
    ...    | open_shift_start_time | Start time of the open shift for which shift request needs to be clicked. |
    ...    | open_shift_end_time | End time of the open shift for which shift request needs to be clicked. |
    ...    Example usage:
    ...    | Click Open Shift Request On Open Shifts Page On SM Phone App    1_4    staff_group    start_time    end_time |
    [Arguments]    ${shift_date_offset}    ${open_shift_staff_group}    ${open_shift_start_time}    ${open_shift_end_time}
    ${open_shift_request_date_format}    Get Config Value    DAY_DATE_FORMAT
    ${is_12_hour_format}    Get Config Value    TIME_FORMAT_12_HRS
    ${open_shift_request_date}    Calculate Date From Week Day Offset    ${shift_date_offset}
    ...    ${open_shift_request_date_format}
    IF    ${is_12_hour_format}
        ${12_hour_start_time}    Convert 24hr Time To 12hr    ${open_shift_start_time}
        ${open_shift_start_time}    Convert To Lower Case    ${12_hour_start_time}
        ${12_hour_end_time}    Convert 24hr Time To 12hr    ${open_shift_end_time}
        ${open_shift_end_time}    Convert To Lower Case    ${12_hour_end_time}
    END
    VAR    ${time_range}    ${open_shift_start_time} - ${open_shift_end_time}
    ${open_shift_request_locator}    Get Message With Arguments For SM
    ...    ${SM_OPEN_SHIFT_REQUEST}
    ...    ${open_shift_request_date}
    ...    ${open_shift_staff_group}
    ...    ${time_range}
    Log    Open shift locator: ${open_shift_request_locator}
    Swipe Until Visible    ${open_shift_request_locator}
    Click Element    ${open_shift_request_locator}

Assign Open Shift To Associate On SM Phone App
    [Documentation]    Used to assign open shift to an associate on SM phone app after clicking on shift request for the open shift.
    ...    | =Arguments=    | =Description=    |
    ...    | shift_date_offset | Week day offset to identify the open shift request to click on. |
    ...    | associate_name | Name of the associate to whom open shift needs to be assigned. |
    ...    | open_shift_staff_group | Staff group of the open shift which is being assigned. |
    ...    | open_shift_start_time | Start time of the open shift which is being assigned. |
    ...    | open_shift_end_time | End time of the open shift which is being assigned. |
    ...    Example usage:
    ...    | Assign Open Shift To Associate On SM Phone App    1_4    ess1_store2[displayName]    staff_group    start_time    end_time |
    [Arguments]    ${shift_date_offset}    ${associate_name}    ${open_shift_staff_group}    ${open_shift_start_time}
    ...    ${open_shift_end_time}
    Click Open Shift Request On Open Shifts Page On SM Phone App    ${shift_date_offset}    ${open_shift_staff_group}
    ...    ${open_shift_start_time}    ${open_shift_end_time}
    ${assign_text}    Get Localised Message From Key For SM    ${SM_OPEN_SHIFT_ASSIGN_TEXT}
    ${assign_tab_locator}    Get Message With Arguments For SM    ${SM_OPEN_SHIFT_TAB}    ${assign_text}
    Wait Until Element Is Visible    ${assign_tab_locator}    timeout=${MEDIUM_TIMEOUT}
    ...    error=Assign Tab is not visible after clicking on shift request for open shift.
    Click Element    ${assign_tab_locator}
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_ASSIGN_MY_STORE_BTN}
    ...    error=Assign My Store button is not visible on assign open shift page.
    Click Element    ${SM_OPEN_SHIFT_ASSIGN_MY_STORE_BTN}
    Search And Select Associate Name In Open Shifts Page On SM Phone App    ${associate_name}
    ${assign_locator}    Get Message With Arguments For SM    ${SM_OPEN_SHIFT_ASSIGN_SHIFT}    ${assign_text}
    Wait Until Element Is Visible    ${assign_locator}
    ...    error=Assign button is not visible after selecting associate for open shift assignment.
    Click Element    ${assign_locator}
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}    timeout=${LONG_TIMEOUT}
    ...    error=Notification message is not visible after assigning open shift to associate.
    Wait Until Page Does Not Contain Element    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}

Delete Open Shift On Open Shifts Page On SM Phone App
    [Documentation]    Used to delete an open shift from my store page on SM phone app.
    ...    | =Arguments=    | =Description=    |
    ...    | shift_day_offset | Week day offset to identify the open shift to be deleted |
    ...    | open_shift_staff_group | Staff group of the open shift to be deleted |
    ...    | open_shift_start_time | Start time of the open shift to be deleted |
    ...    | open_shift_end_time | End time of the open shift to be deleted |
    [Arguments]    ${shift_day_offset}    ${open_shift_staff_group}    ${open_shift_start_time}    ${open_shift_end_time}
    Navigate To My Store Page On SM Phone App
    Select Week On My Store Page On SM Phone App    ${shift_day_offset}
    Click Open Shifts Section On My Store Page On SM Phone App
    Click Open Shift Request On Open Shifts Page On SM Phone App    ${shift_day_offset}    ${open_shift_staff_group}
    ...    ${open_shift_start_time}    ${open_shift_end_time}
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_DELETE_OPEN_SHIFT_BTN}
    ...    error=Delete open shift button is not visible on open shift details page.
    Click Element    ${SM_OPEN_SHIFT_DELETE_OPEN_SHIFT_BTN}
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_DIALOG_CONFIRM_BTN}
    ...    error=Confirmation dialog is not visible after clicking delete open shift button on open shift details page.
    Click Element    ${SM_OPEN_SHIFT_DIALOG_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}    timeout=${LONG_TIMEOUT}
    ...    error=Notification message is not visible after deleting open shift.
    Wait Until Page Does Not Contain Element    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}

Edit Shift On Open Shifts Page On SM Phone App
    [Documentation]    Used to edit an open shift on open shifts page based on week day offset and shift timings.
    [Arguments]    ${shift_date_offset}    ${staff_group}    ${shift_start_time}    ${shift_end_time}    ${shift_edit_start_time}    ${shift_edit_end_time}
    Click Open Shift Request On Open Shifts Page On SM Phone App    ${shift_date_offset}    ${staff_group}    ${shift_start_time}    ${shift_end_time}
    Wait Until Element Is Visible    ${SM_MY_STORE_PAGE_EDIT_SHIFT_TIMING}    error=Edit shift option is not visible on open shift details page.
    Click Element    ${SM_MY_STORE_PAGE_EDIT_SHIFT_TIMING}
    Select Shift Timings On Open Shift Page On SM Phone App    ${shift_edit_start_time}    ${shift_edit_end_time}
    Save Edit Shift Without Meal Break On Open Shift Page On SM Phone App

Save Edit Shift Without Meal Break On Open Shift Page On SM Phone App
    [Documentation]    Used to click save shift button on open shift details page after entering all the details for open shift.
    Click Save For Open Shift On Open Shift Page On SM Phone App
    ${is_success_message_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}    timeout=${MEDIUM_TIMEOUT}
    ...    error=Open shift success message is not visible after editing open shift.
    IF    not ${is_success_message_visible}
        ${do_not_apply_meal_break_label}    Get Localised Message From Key For SM    ${SM_OPEN_SHIFT_SAVE_DO_NOT_APPLY_MEAL_BREAK}
        ${save_without_meal_break}    Get Message With Arguments For SM    ${SM_OPEN_SHIFT_SAVE_OPTION}    ${do_not_apply_meal_break_label}
        Click Element    ${save_without_meal_break}
        Verify Open Shift Edit Success Message On SM Phone App
    ELSE
        Wait Until Page Does Not Contain Element    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}
    END

Verify Open Shift Edit Success Message On SM Phone App
    [Documentation]    Used to verify open shift edit success message after editing open shift on my store page
    Wait Until Element Is Visible    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}    timeout=${LONG_TIMEOUT}
    ...    error=Open shift edit success message is not visible after editing open shift on my store page.
    Wait Until Page Does Not Contain Element    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}

Get Semantic For Open Shift On Open Shift Details Page On SM Phone App
    [Documentation]    Used to get semantic for open shift on open shift details page.
    ...    | === Arguments === | === Description === |
    ...    | shift_date_offset | Week day offset to identify the shift to select. |
    ...    | shift_start_time | start time of the shift|
    ...    | shift_end_time | end time of the shift|
    ...    | staff_group | staff group of the shift |
    [Arguments]    ${shift_date_offset}    ${shift_start_time}    ${shift_end_time}    ${staff_group}
    # Sat, Jun 06     02:30 pm - 06:30 pm
    Log    ${shift_date_offset}
    ${open_shift_date_format}    Get Config Value    DAY_DATE_FORMAT
    ${shift_day_label}    Calculate Date From Week Day Offset    ${shift_date_offset}    ${open_shift_date_format}
    ${formatted_start_time}    Format Time String    ${shift_start_time}
    ${formatted_end_time}    Format Time String    ${shift_end_time}
    VAR    ${shift_time_label}    ${formatted_start_time} - ${formatted_end_time}
    ${shift_item_locator}    Get Message With Arguments For SM
    ...    ${SM_OPEN_SHIFT_REQUEST}
    ...    ${shift_day_label}
    ...    ${staff_group}
    ...    ${shift_time_label}
    RETURN    ${shift_item_locator}

Select Shift On Open Shift Page On SM Phone App
    [Documentation]    Used to select shift on open shift page.
    ...    | === Arguments === | === Description === |
    ...    | shift_date_offset | Week day offset to identify the shift to select. |
    ...    | shift_start_time | start time of the shift|
    ...    | shift_end_time | end time of the shift|
    ...    | staff_group | staff group of the shift |
    [Arguments]    ${shift_date_offset}    ${shift_start_time}    ${shift_end_time}    ${staff_group}
    # Sat, Jun 06     02:30 pm - 06:30 pm
    ${shift_semantic}    Get Semantic For Open Shift On Open Shift Details Page On SM Phone App    ${shift_date_offset}    ${shift_start_time}    ${shift_end_time}    ${staff_group}
    Swipe Until Visible    ${shift_semantic}    maxSwipes=10
    Wait Until Page Contains Element    ${shift_semantic}    error= Shift with start time ${shift_start_time} and end time ${shift_end_time} is not displayed on open shift page
    Click Element    ${shift_semantic}

Delete All Matching Open Shifts On Open Shift Details Page On SM Phone App
    [Documentation]    Used to delete all matching open shifts on open shift details page.
    ...    | === Arguments === | === Description === |
    ...    | shift_date_offset | Week day offset to identify the shift to delete. |
    ...    | shift_start_time | start time of the shift|
    ...    | shift_end_time | end time of the shift|
    ...    | staff_group | staff group of the shift |
    [Arguments]    ${shift_date_offset}    ${shift_start_time}    ${shift_end_time}    ${staff_group}
    ${shift_semantic}    Get Semantic For Open Shift On Open Shift Details Page On SM Phone App    ${shift_date_offset}    ${shift_start_time}    ${shift_end_time}    ${staff_group}
    VAR    ${max_attempts}    5
    WHILE    ${max_attempts} > 0
        ${is_shift_present}    Run Keyword And Return Status    Wait Until Page Contains Element    ${shift_semantic}
        IF    not ${is_shift_present}
            BREAK
        END
        @{elements}    Get Webelements    ${shift_semantic}
        Click Element    ${elements}[0]
        Wait Until Element Is Visible    ${SM_OPEN_SHIFT_DELETE_OPEN_SHIFT_BTN}    error=Delete open shift button is not visible on open shift details page.
        Click Element    ${SM_OPEN_SHIFT_DELETE_OPEN_SHIFT_BTN}
        Wait Until Element Is Visible    ${SM_OPEN_SHIFT_DIALOG_CONFIRM_BTN}
        ...    error=Confirmation dialog is not visible after clicking delete open shift button on open shift details page.
        Click Element    ${SM_OPEN_SHIFT_DIALOG_CONFIRM_BTN}
        Wait Until Element Is Visible    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}    timeout=${LONG_TIMEOUT}
        ...    error=Notification message is not visible after deleting open shift.
        Wait Until Page Does Not Contain Element    ${SM_OPEN_SHIFT_GENERIC_NOTIFICATION}
        ${max_attempts}    Evaluate    ${max_attempts} - 1
    END

Verify Open Shift Is Displayed On Open Shift Page On SM Phone App
    [Documentation]    Used to verify open shift is displayed on open shift page based on week day offset and open shift template.
    ...    | === Arguments === | === Description === |
    ...    | shift_date_offset | Week day offset to identify the shift to select. |
    ...    | shift_start_time | start time of the shift|
    ...    | shift_end_time | end time of the shift|
    ...    | staff_group | staff group of the shift |
    [Arguments]    ${shift_date_offset}    ${shift_start_time}    ${shift_end_time}    ${staff_group}
    ${shift_semantic}    Get Semantic For Open Shift On Open Shift Details Page On SM Phone App    ${shift_date_offset}    ${shift_start_time}    ${shift_end_time}    ${staff_group}
    Swipe Until Visible    ${shift_semantic}    maxSwipes=10
    Wait Until Page Contains Element    ${shift_semantic}    error= Shift with start time ${shift_start_time} and end time ${shift_end_time} is not displayed on open shift page

Search And Select Associate Name In Open Shifts Page On SM Phone App
    [Documentation]    Used to search associate name
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Name of the associate to be searched |
    [Arguments]    ${associate_name}
    Wait Until Page Contains Element    ${SM_OPEN_SHIFT_SEARCH_ICON}    error=Search icon is not visible on open shifts page
    Click Element    ${SM_OPEN_SHIFT_SEARCH_ICON}
    Wait Until Page Contains Element    ${SM_OPEN_SHIFT_SEARCH_ASSOCIATE_FIELD}
    ...    error=Search textbox is not visible after clicking search icon on open shifts page
    Input Text    ${SM_OPEN_SHIFT_SEARCH_ASSOCIATE_FIELD}    ${associate_name}
    ${associate_locator}    Get Message With Arguments For SM    ${SM_OPEN_SHIFT_ASSOCIATE_OPTION}    ${associate_name}
    Wait Until Page Contains Element    ${associate_locator}    error=Associate with name ${associate_name} is not visible after searching on open shifts page
    Click Element    ${associate_locator}
