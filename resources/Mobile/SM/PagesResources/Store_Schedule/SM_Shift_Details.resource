*** Settings ***
Documentation       This resource contains keywords required for shift details page of store schedule module in SM mobile app.

Library             test_data/TestDataLibrary.py
Resource         resources/Mobile/Common/Common_Mobile.resource
Resource         resources/Mobile/SM/PagesResources/Common/Common.resource
Variables        resources/Mobile/SM/Locators/SM_Shift_Details_Page.py
Variables        resources/Mobile/SM/Locators/Common_Page.py


*** Keywords ***
Tap Edit Shift Button On Shift Details Page On SM Phone App
    [Documentation]    Taps on edit shift button on shift details page of store schedule module in SM mobile app.
    Wait Until Page Contains Element    ${EDIT_SHIFT_BUTTON}
    Click Element    ${EDIT_SHIFT_BUTTON}

Add Shift On Selected Date Details Page On SM Phone App
    [Documentation]    Adds shift on selected date from shift details page of store schedule module in SM mobile app.
    [Arguments]    ${shift_start_time}    ${shift_end_time}    ${task_name}
    Select Start Time On Add Shift Page On SM Phone App    ${shift_start_time}
    Select End Time On Add Shift Page On SM Phone App    ${shift_end_time}
    Select Task On Add Shift Page On SM Phone App    ${task_name}
    Save Shift On Add Shift Page On SM Phone App

Select Start Time On Add Shift Page On SM Phone App
    [Documentation]    Selects start time on add shift page of store schedule module in SM mobile app.
    [Arguments]    ${shift_start_time}
    Wait Until Page Contains Element    ${ADD_SCHEDULE_SHIFT_START_TIME}
    Click Element    ${ADD_SCHEDULE_SHIFT_START_TIME}
    ${is_scrollable_time_picker_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${TIME_SAVE_BUTTON}    timeout=3s
    IF    ${is_scrollable_time_picker_visible}
        Select Time On Scrollable Time Picker On SM Phone App    ${shift_start_time}
    ELSE
        Select Time On Round Time Picker On SM Phone App    ${shift_start_time}
    END

Select End Time On Add Shift Page On SM Phone App
    [Documentation]    Selects end time on add shift page of store schedule module in SM mobile app.
    [Arguments]    ${shift_end_time}
    Wait Until Page Contains Element    ${ADD_SCHEDULE_SHIFT_END_TIME}
    Click Element    ${ADD_SCHEDULE_SHIFT_END_TIME}
    ${is_scrollable_time_picker_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${TIME_SAVE_BUTTON}
    IF    ${is_scrollable_time_picker_visible}
        Select Time On Scrollable Time Picker On SM Phone App    ${shift_end_time}
    ELSE
        Select Time On Round Time Picker On SM Phone App    ${shift_end_time}
    END

Select Task On Add Shift Page On SM Phone App
    [Documentation]    Selects task on add shift page of store schedule module in SM mobile app.
    [Arguments]    ${task_name}
    Wait Until Page Contains Element    ${ADD_TASK}
    Click Element    ${ADD_TASK}
    Search And Select Task From List Picker On SM Phone App    ${task_name}

Save And Apply Meal Break Settings On Add Shift Page On SM Phone App
    [Documentation]    Saves the shift after applying meal break settings on add shift page of store schedule module in SM mobile app.
    Click Element    ${SAVE_SHIFT_BUTTON}
    ${meal_break_apply_message_semantic}    Get Localised Message From Key For SM    1000000001256
    ${meal_break_apply_message_locator}    Get Locator Contains For SM    ${meal_break_apply_message_semantic}
    Wait Until Page Contains Element    ${meal_break_apply_message_locator}
    Click Element    ${meal_break_apply_message_locator}

Save And Dont Apply Meal Break Settings On Add Shift Page On SM Phone App
    [Documentation]    Saves the shift without applying meal break settings on add shift page of store schedule module in SM mobile app.
    Click Element    ${SAVE_SHIFT_BUTTON}
    ${no_meal_break_apply_message_semantic}    Get Localised Message From Key For SM    1000000001257
    ${no_meal_break_apply_message_locator}    Get Locator Contains For SM    ${no_meal_break_apply_message_semantic}
    Wait Until Page Contains Element    ${no_meal_break_apply_message_locator}
    Click Element    ${no_meal_break_apply_message_locator}

Save Shift On Add Shift Page On SM Phone App
    [Documentation]    Saves the shift on add shift page of store schedule module in SM mobile app.
    Wait Until Element Is Visible    ${SAVE_SHIFT_BUTTON}    error=Save button is not visible on add shift page of store schedule module in SM phone app
    Click Element    ${SAVE_SHIFT_BUTTON}
    ${save_semantic}    Get Localised Message From Key For SM    1000000000056
    ${save_locator}    Get Locator Contains For SM    ${save_semantic}
    ${is_actions_save_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${save_locator}
    IF    ${is_actions_save_visible}    Click Element    ${save_locator}

Search And Select Task From List Picker On SM Phone App
    [Documentation]    Searches and selects the task from list picker on add shift page of store schedule module in SM mobile app.
    [Arguments]    ${task_name}
    Wait Until Page Contains Element    ${LIST_PICKER_SEARCH_BOX}
    Input Text    ${LIST_PICKER_SEARCH_BOX}    ${task_name}
    Wait Until Page Contains Element    ${TASK_LIST_ITEM}    timeout=${MEDIUM_TIMEOUT}    error=Task ${task_name} not found in list picker on SM phone app
    Click Element    ${TASK_LIST_ITEM}

Verify Alerts Present For Shift On SM Phone App
    [Documentation]    Verifies HR alerts are present for the shift on store schedule module in SM mobile app.
    Wait Until Page Contains Element    ${ALERTS_HEADER}    error=Alerts header not found on shift details page of store schedule module in SM phone app

Verify No Alerts Present For Shift On SM Phone App
    [Documentation]    Verifies no HR alerts are present for the shift on store schedule module in SM mobile app.
    ${is_alerts_header_present}    Run Keyword And Return Status    Wait Until Page Contains Element    ${ALERTS_HEADER}    timeout=5s
    Should Not Be True    ${is_alerts_header_present}    Alerts header found on shift details page of store schedule module in SM phone app, but was not expected

Select Three Dot Menu For Shift On Store Schedule Page On SM Phone App
    [Documentation]    Used to select three dot menu for a shift on store schedule page.
    Wait Until Element Is Visible    ${SHIFT_DETAILS_MORE_BUTTON}    error=Three dot menu button is not visible for the shift on shift details page of store schedule module in SM phone app
    Click Element    ${SHIFT_DETAILS_MORE_BUTTON}

Select Associate To Copy Shift On Shift Details Page On SM Phone App
    [Documentation]    Used to select associate to copy shift on shift details page of store schedule module in SM mobile app.
    [Arguments]    ${associate_name}
    Wait Until Element Is Visible    ${COPY_TO_ASSOCIATE}    error=Copy to associate field is not visible on shift details page of store schedule module in SM phone app
    Click Element    ${COPY_TO_ASSOCIATE}
    ${search_associate}    Get Localised Locator Contains For SM    ${SHIFT_DETAILS_SEARCH_ASSOCIATE_ICON}
    Wait Until Element Is Visible    ${search_associate}    error=Search associate field is not visible after clicking on copy to associate field on shift details page of store schedule module in SM phone app
    Input Text    ${LIST_PICKER_SEARCH_BOX}    ${associate_name}
    ${associate_locator}    Get Message With Arguments For SM    ${SEARCHED_ASSOCIATE_LIST_ITEM}    ${associate_name}
    Wait Until Page Contains Element    ${associate_locator}    error=Associate ${associate_name} not found in search results after entering name in copy to associate field on shift details page of store schedule module in SM phone app
    Click Element    ${associate_locator}

Select Day To Copy Or Move Shift On Shift Details Page On SM Phone App
    [Documentation]    Used to select day to copy or move shift on shift details page of store schedule module in SM mobile app.
    [Arguments]    @{days}
    ${date_format}    Get Config Value    FIXED_FULL_DATE_WITHOUT_COMMA_DF
    FOR    ${day}    IN    @{days}
        ${target_day}    Calculate Date From Week Day Offset    ${day}    ${date_format}
        ${day_locator}    Get Locator Contains For SM    ${target_day}
        Wait Until Page Contains Element    ${day_locator}    error=Day ${target_day} not found in day selection while copying or moving shift on shift details page of store schedule module in SM phone app
        Click Element    ${day_locator}
    END

Confirm Shift Operation On Shift Details Page On SM Phone App
    [Documentation]    Used to confirm shift operations on shift details page of store schedule module in SM mobile app.
    Wait Until Element Is Visible    ${CONFIRM_SHIFT_OPERATION}    error=Save button is not visible on shift details page of store schedule module in SM phone app
    Click Element    ${CONFIRM_SHIFT_OPERATION}

Copy Shift To Target Associate On SM Phone App
    [Documentation]    Used to copy shift to target associate from shift details page of store schedule module in SM mobile app.
    [Arguments]    ${associate_name}    @{days}
    Select Three Dot Menu For Shift On Store Schedule Page On SM Phone App
    ${copy_button}    Get Localised Locator Contains For SM    ${COPY_SHIFT_BUTTON}
    Click Element    ${copy_button}
    Select Associate To Copy Shift On Shift Details Page On SM Phone App    ${associate_name}
    Select Day To Copy Or Move Shift On Shift Details Page On SM Phone App    @{days}
    Confirm Shift Operation On Shift Details Page On SM Phone App
    Close Snack Bar When Visible On SM Phone App

Move Shift To Target Associate On SM Phone App
    [Documentation]    Used to move shift to target associate from shift details page of store schedule module in SM mobile app.
    [Arguments]    ${associate_name}    @{days}
    Select Three Dot Menu For Shift On Store Schedule Page On SM Phone App
    ${move_button}    Get Localised Locator Contains For SM    ${MOVE_SHIFT_BUTTON}
    Click Element    ${move_button}
    Select Associate To Copy Shift On Shift Details Page On SM Phone App    ${associate_name}
    Select Day To Copy Or Move Shift On Shift Details Page On SM Phone App    @{days}
    Confirm Shift Operation On Shift Details Page On SM Phone App
    Close Snack Bar When Visible On SM Phone App

Reassign Shift To Target Associate On SM Phone App
    [Documentation]    Used to reassign shift to target associate from shift details page of store schedule module in SM mobile app.
    [Arguments]    ${associate_name}
    ${reassign_button}    Get Localised Locator Contains For SM    ${REASSIGN_SHIFT_BUTTON}
    Wait Until Element Is Visible    ${reassign_button}    error=Reassign shift button is not visible in three dot menu options on shift details page of store schedule module in SM phone app
    Click Element    ${reassign_button}
    ${search_associate}    Get Localised Locator Contains For SM    ${SHIFT_DETAILS_SEARCH_ASSOCIATE_ICON}
    Wait Until Element Is Visible    ${search_associate}    error=Search associate field is not visible
    Click Element    ${search_associate}
    Input Text    ${SEARCH_ASSOCIATE_TEXT_FIELD}    ${associate_name}
    ${associate_locator}    Get Message With Arguments For SM    ${ASSOCIATE_REASSIGN_SEARCH_RESULT}    ${associate_name}
    Wait Until Page Contains Element    ${associate_locator}    error=Associate ${associate_name} not found in search results after entering name in copy to associate field on shift details page of store schedule module in SM phone app
    Click Element    ${associate_locator}
    ${assign_button}    Get Localised Locator Contains For SM    ${ASSIGN_SHIFT_BUTTON}
    Wait Until Element Is Visible    ${assign_button}    error=Assign button is not visible after selecting associate to reassign shift on shift details page of store schedule module in SM phone app
    Click Element    ${assign_button}
    Close Snack Bar When Visible On SM Phone App

Swap Shift To Target Associate On SM Phone App
    [Documentation]    Used to swap shift with target associate from shift details page of store schedule module in SM mobile app.
    [Arguments]    ${associate_name}
    ${swap_button}    Get Localised Locator Contains For SM    ${SWAP_SHIFT_BUTTON}
    Wait Until Element Is Visible    ${swap_button}    error=Swap shift button is not visible in three dot menu options on shift details page of store schedule module in SM phone app
    Click Element    ${swap_button}
    ${search_associate}    Get Localised Locator Contains For SM    ${SHIFT_DETAILS_SEARCH_ASSOCIATE_ICON}
    Wait Until Element Is Visible    ${search_associate}    error=Search associate field is not visible
    Click Element    ${search_associate}
    ${formatted_associate_name}    Replace String    ${associate_name}    ,    ${EMPTY}
    Input Text    ${SEARCH_ASSOCIATE_TEXT_FIELD}    ${formatted_associate_name}
    VAR    ${formatted_associate_name_with_space}    ${formatted_associate_name}${SPACE}
    ${associate_locator}    Get Message With Arguments For SM    ${ASSOCIATE_SWAP_SEARCH_RESULT}    ${formatted_associate_name_with_space}
    Wait Until Page Contains Element    ${associate_locator}    error=Associate ${formatted_associate_name} not found in search results after entering name in copy to associate field on shift details page of store schedule module in SM phone app
    Click Element    ${associate_locator}
    ${swap_button}    Get Localised Locator Contains For SM    ${SWAP_SHIFT_BUTTON}
    Wait Until Element Is Visible    ${swap_button}    error=Swap button is not visible after selecting associate to swap shift on shift details page of store schedule module in SM phone app
    Click Element    ${swap_button}
    Close Snack Bar When Visible On SM Phone App

Copy Shift To Selected Day For My Store On SM Phone App
    [Documentation]    Used to copy shift to selected day in SM mobile app.
    [Arguments]    @{days}
    Select Three Dot Menu For Shift On Store Schedule Page On SM Phone App
    ${copy_button}    Get Localised Locator Contains For SM    ${COPY_SHIFT_BUTTON}
    Click Element    ${copy_button}
    Select Day To Copy Or Move Shift On Shift Details Page On SM Phone App    @{days}
    Confirm Shift Operation On Shift Details Page On SM Phone App
    Close Snack Bar When Visible On SM Phone App

Move Shift To Selected Day For My Store On SM Phone App
    [Documentation]    Used to move shift to selected day in SM mobile app.
    [Arguments]    @{days}
    Select Three Dot Menu For Shift On Store Schedule Page On SM Phone App
    ${move_button}    Get Localised Locator Contains For SM    ${MOVE_SHIFT_BUTTON}
    Click Element    ${move_button}
    Select Day To Copy Or Move Shift On Shift Details Page On SM Phone App    @{days}
    Confirm Shift Operation On Shift Details Page On SM Phone App
    Close Snack Bar When Visible On SM Phone App

Verify Shift Saved Successfully On SM Phone App
    [Documentation]    Used to verify shift saved successfully on store schedule page on SM phone app.
    Run Keyword And Ignore Error    ${SHIFT_UPDATE_SUCCESS_MESSAGE}    timeout=${LONG_TIMEOUT}
    ...    error=Shift update success message is not visible on store schedule page after performing action.
    Close Snack Bar When Visible On SM Phone App
