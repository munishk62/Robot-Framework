*** Settings ***
Documentation       This resource contains keywords required for Associate Roster Availability page..

Variables           resources/Mobile/SM/Locators/Associate_Roster_Page.py
Resource            resources/Mobile/SM/PagesResources/Common/Common.resource
Resource            resources/Mobile/Common/Common_Mobile.resource


*** Keywords ***
Tap Add Button On Availability Tab On SM Phone App
    [Documentation]    This keyword is used to tap on add availability button on availability tab on associate roster page
    Wait Until Page Contains Element    ${ADD_AVAILABILITY_BUTTON}
    Click Element    ${ADD_AVAILABILITY_BUTTON}

Select Permanent Availability Type On SM Phone App
    [Documentation]    This keyword is used to select permanent availability type on availability tab on associate roster page
    Wait Until Page Contains Element    ${REDIO_BUTTON_PERMANENT}
    Click Element    ${REDIO_BUTTON_PERMANENT}

Select Temporary Availability Type On SM Phone App
    [Documentation]    This keyword is used to select temporary availability type on availability tab on associate roster page
    Wait Until Page Contains Element    ${REDIO_BUTTON_TEMPORARY}
    Click Element    ${REDIO_BUTTON_TEMPORARY}

Select Start Date For Availability On SM Phone App
    [Documentation]    This keyword is used to select start date for temporary availability on availability tab on associate roster page
    [Arguments]    ${start_date}
    Wait Until Page Contains Element    ${START_DATE_LOCATOR}
    Click Element    ${START_DATE_LOCATOR}
    Select Date From Date List Picker On SM Phone App    ${start_date}

Select Availability Reason On SM Phone App
    [Documentation]    This keyword is used to select availability reason for temporary availability on availability tab on associate roster page
    [Arguments]    ${reason}
    Wait Until Page Contains Element    ${REASON_DROPDOWN}
    Click Element    ${REASON_DROPDOWN}
    Search And Select Option From List Picker On SM Phone App    ${reason}

Select Availability Status On SM Phone App
    [Documentation]    This keyword is used to select availability status for temporary availability on availability tab on associate roster page
    [Arguments]    ${status}
    Wait Until Page Contains Element    ${STATUS_DROPDOWN}
    Click Element    ${STATUS_DROPDOWN}
    Search And Select Option From List Picker On SM Phone App    ${status}

Toggle Available All Week Option On SM Phone App
    [Documentation]    This keyword is used to toggle available all week option for temporary availability on availability tab on associate roster page
    Wait Until Page Contains Element    ${AVAILABLE_ALL_WEEK_TOGGLE}
    Click Element    ${AVAILABLE_ALL_WEEK_TOGGLE}

Add Availability Timing Windows On SM Phone App
    [Documentation]    This keyword is used to add availability timing windows for temporary availability on availability tab on associate roster page
    [Arguments]    ${rotations}
    ${rotation_count}    Get Length    ${rotations}
    ${rotations_enabled}    Get Config Value    EMP_AVL_ROTATION
    IF    "${rotations_enabled}" == "Y"
        Log    Rotation feature is enabled.
        Log    Rotation count: ${rotation_count}
    ELSE
        Log    Rotation feature is disabled.
    END
    IF    ${rotation_count} > 1 and "${rotations_enabled}" == "Y"
        # Select Total number of rotations to be added
        Select Total Number Of Rotations On SM Phone App    ${rotation_count}
    ELSE
        Log    No rotations to add or availability is being added for temporary availability type.
    END

    FOR    ${rotation}    IN    @{rotations}
        IF    ${rotation_count} > 1 and "${rotations_enabled}" == "Y"
            ${rotation_number}    Get From Dictionary    ${rotation}    rotation_number
            Select Rotation From Rotations Tab On SM Phone App    ${rotation_number}
        END
        ${availability_hours}    Get From Dictionary    ${rotation}    availability_hours
        ${count}    Get Length    ${availability_hours}
        IF    ${count} > 0
            Log    Toggling All available to set timings instead of full day.
            Toggle Available All Week Option On SM Phone App
        END
        ${non_working_days}    Get From Dictionary    ${rotation}    non_working_days
        Toggle Availability Non Working Days On SM Phone App    ${non_working_days}

        FOR    ${index}    IN RANGE    ${count}
            ${availability_hour}    Get From List    ${availability_hours}    ${index}
            ${start_time}    Get From Dictionary    ${availability_hour}    start_time
            ${end_time}    Get From Dictionary    ${availability_hour}    end_time
            ${applicable_days}    Get From Dictionary    ${availability_hour}    applicable_days
            ${availability_options}    Get From Dictionary    ${availability_hour}    availability_option

            IF    "${availability_options}" == "BA"
                Add Base Availability Timings On SM Phone App
                ...    ${start_time}
                ...    ${end_time}
                ...    ${applicable_days}
                ...    ${index}
            ELSE IF    "${availability_options}" == "PR"
                Add Preferred Availability Timings On SM Phone App
                ...    ${start_time}
                ...    ${end_time}
                ...    ${applicable_days}
                ...    ${index}
            ELSE IF    "${availability_options}" == "OC"
                Add On Call Availability Timings On SM Phone App
                ...    ${start_time}
                ...    ${end_time}
                ...    ${applicable_days}
                ...    ${index}
            END
        END
    END

Select Total Number Of Rotations On SM Phone App
    [Documentation]    This keyword is used to select total number of rotations to be added for temporary availability on availability tab on associate roster page
    [Arguments]    ${rotation_count}
    Wait Until Page Contains Element    ${TOTAL_ROTATIONS_DROPDOWN}
    Click Element    ${TOTAL_ROTATIONS_DROPDOWN}
    ${rotation_count_option_locator}    Get Message With Arguments
    ...    ${ROTATION_LIST_ITEM_LOCATOR}
    ...    ${rotation_count}
    Wait Until Page Contains Element    ${rotation_count_option_locator}
    Click Element    ${rotation_count_option_locator}

Select Rotation From Rotations Tab On SM Phone App
    [Documentation]    This keyword is used to select rotation from rotations tab when adding availability with multiple rotations for temporary availability on availability tab on associate roster page
    [Arguments]    ${rotation_number}
    ${rotation_tab_locator}    Get Message With Arguments    ${ROTATION_NUMBER_TAB_LOCATOR}    ${rotation_number}
    Swipe Until Visible   ${rotation_tab_locator}    "up"    3
    Click Element    ${rotation_tab_locator}

Toggle Availability Non Working Days On SM Phone App
    [Documentation]    This keyword is used to toggle non working days for availability hours when adding availability for temporary availability on availability tab on associate roster page
    [Arguments]    ${non_working_days}
    FOR    ${day_index}    IN    @{non_working_days}
        ${day}    Evaluate    ${day_index} + 1
        ${day_locator}    Get Message With Arguments    ${NON_WORKING_DAY_TOGGLE_LOCATOR}    ${day}
        Swipe Until Visible    ${day_locator}
        Click Element    ${day_locator}
    END

Add Availability Timings Details On SM Phone App
    [Documentation]    This keyword is used to add availability timings details like start time, end time and applicable days when adding availability for temporary availability on availability tab on associate roster page
    [Arguments]    ${start_time}    ${end_time}    ${applicable_days}    ${index_of_hour_window}
    IF    ${index_of_hour_window} > 0
        Swipe Until Visible    ${AVAIL_WINDOW_ADD_BUTTON}    maxSwipes=8
        Click Element    ${AVAIL_WINDOW_ADD_BUTTON}
    END
    # first disable all day toggle to avoid any pre-filled values and then enter the timings details
    Wait Until Page Contains Element    ${AVAILABLE_ALL_DAY_TOGGLE}
    ${index_of_hour_window}    Evaluate    ${index_of_hour_window} + 1
    FOR    ${day_index}    IN    @{applicable_days}
        ${day}    Evaluate    ${day_index} + 1
        # Create List of days like sun, mon and shift items of them according to first day of week.
        VAR    @{days_list}    tsu    tmo    ttu    twe    tth    tfr    tsa
        @{days_list}    Shift List Items According To First Day Of Week    ${days_list}
        # Get the respective day from the list according to the day index and use it to create the locator for that day to click and select it as applicable day for the availability timings.
        ${day}    Get From List    @{days_list}    ${day_index}
        IF    ${index_of_hour_window} > 1
            # If there are multiple hour windows for the availability, then the day locator will have an index to identify the respective day toggle for that hour window, so pass the index of hour window to get the correct locator.
            ${day_locator}    Get Message With Arguments
            ...    ${AVAIL_APPLICABLE_DAYS_WITH_INDEX}
            ...    ${day}
            ...    ${index_of_hour_window}
        ELSE
            ${day_locator}    Get Message With Arguments    ${AVAIL_APPLICABLE_DAYS}    ${day}
        END
        Swipe Until Visible    ${AVAIL_WINDOW_ADD_BUTTON}    maxSwipes=8
        Click Element    ${day_locator}
    END
    IF    ${index_of_hour_window} > 1
        # If there are multiple hour windows for the availability, then the start time and end time locators will have an index to identify the respective start time and end time input fields for that hour window, so pass the index of hour window to get the correct locators.
        ${available_all_day_toggle_locator}    Get Message With Arguments
        ...    ${AVAILABLE_ALL_DAY_TOGGLE_WITH_INDEX}
        ...    ${index_of_hour_window}
        ${start_time_input_locator}    Get Message With Arguments
        ...    ${START_TIME_INPUT_WITH_INDEX}
        ...    ${index_of_hour_window}
        ${end_time_input_locator}    Get Message With Arguments
        ...    ${END_TIME_INPUT_WITH_INDEX}
        ...    ${index_of_hour_window}
    ELSE
        VAR    ${available_all_day_toggle_locator}    ${AVAILABLE_ALL_DAY_TOGGLE}
        VAR    ${start_time_input_locator}    ${START_TIME_INPUT}
        VAR    ${end_time_input_locator}    ${END_TIME_INPUT}
    END
    IF    "${start_time}" == "00:00" and "${end_time}" == "24:00"
        Swipe Until Visible    ${AVAIL_WINDOW_ADD_BUTTON}
        Click Element    ${available_all_day_toggle_locator}
    ELSE
        Swipe Until Visible    ${AVAIL_WINDOW_ADD_BUTTON}
        Click Element    ${start_time_input_locator}
        Select Time On Round Time Picker On SM Phone App    ${start_time}

        Swipe Until Visible    ${AVAIL_WINDOW_ADD_BUTTON}
        Click Element    ${end_time_input_locator}
        Select Time On Round Time Picker On SM Phone App    ${end_time}
    END
    Click Element    ${TIMING_DONE_BUTTON}

Add Base Availability Timings On SM Phone App
    [Documentation]    This keyword is used to add base availability timings when adding availability on availability tab on associate roster page
    [Arguments]    ${start_time}    ${end_time}    ${applicable_days}    ${index_of_hour_window}
    ${first_applicable_day}    Evaluate    ${applicable_days}[0] + 1
    ${avail_time_base_locator}    Get Message With Arguments    ${AVAIL_BASE_TIMING_LOCATOR}    ${first_applicable_day}
    Swipe In Container Until Visible    ${AVAILABILITY_TIMING_CONTAINER}    ${avail_time_base_locator}    max_swipes=10
    Click Element    ${avail_time_base_locator}
    Add Availability Timings Details On SM Phone App
    ...    ${start_time}
    ...    ${end_time}
    ...    ${applicable_days}
    ...    ${index_of_hour_window}

Add Preferred Availability Timings On SM Phone App
    [Documentation]    This keyword is used to add preferred availability timings when adding availability on availability tab on associate roster page
    [Arguments]    ${start_time}    ${end_time}    ${applicable_days}    ${index_of_hour_window}
    ${first_applicable_day}    Evaluate    ${applicable_days}[0] + 1
    ${avail_time_pref_locator}    Get Message With Arguments    ${AVAIL_PREF_TIMING_LOCATOR}    ${first_applicable_day}
    Swipe Until Visible    ${avail_time_pref_locator}
    Click Element    ${avail_time_pref_locator}
    Add Availability Timings Details On SM Phone App
    ...    ${start_time}
    ...    ${end_time}
    ...    ${applicable_days}
    ...    ${index_of_hour_window}

Add On Call Availability Timings On SM Phone App
    [Documentation]    This keyword is used to add on call availability timings when adding availability on availability tab on associate roster page
    [Arguments]    ${start_time}    ${end_time}    ${applicable_days}    ${index_of_hour_window}
    ${first_applicable_day}    Evaluate    ${applicable_days}[0] + 1
    ${avail_time_oncall_locator}    Get Message With Arguments
    ...    ${AVAIL_ONCALL_TIMING_LOCATOR}
    ...    ${first_applicable_day}
    Swipe Until Visible    ${avail_time_oncall_locator}
    Click Element    ${avail_time_oncall_locator}
    Add Availability Timings Details On SM Phone App
    ...    ${start_time}
    ...    ${end_time}
    ...    ${applicable_days}
    ...    ${index_of_hour_window}

Shift List Items According To First Day Of Week
    [Documentation]    This keyword is used to shift list items according to first day of week configuration value
    [Arguments]    @{list}
    ${first_day_of_week}    Get Config Value    key=FISCAL_WEEK_START_DAY
    # first_day_of_week is expected as 1..7 (1=first item in given list)
    ${first_day_index}    Evaluate    int(${first_day_of_week}) - 1
    ${length}    Get Length    ${list}

    # Normalize index for safety (handles values outside 1..7)
    ${first_day_index}    Evaluate    ${first_day_index} % ${length}

    ${head}    Get Slice From List    ${list}    ${first_day_index}    ${length}
    ${tail}    Get Slice From List    ${list}    0    ${first_day_index}
    ${shifted}    Combine Lists    ${head}    ${tail}

    RETURN    @{shifted}

Tap Submit Availability Request On SM Phone App
    [Documentation]    This keyword is used to tap on submit button after filling all details when adding availability on availability tab on associate roster page
    Wait Until Page Contains Element    ${AVAILABILITY_SUBMIT}
    Click Element    ${AVAILABILITY_SUBMIT}

Tap Save To Edited Availability Request On SM Phone App
    [Documentation]    This keyword is used to tap on save button after editing availability request details on availability tab on associate roster page
    Wait Until Page Contains Element    ${AVAILABILITY_SAVE}
    Click Element    ${AVAILABILITY_SAVE}

Verify Availability List Item On SM Phone App
    [Documentation]    This keyword is used to verify the availability list item on availability tab on associate roster page after adding availability
    [Arguments]    ${availability_data}    ${requested_by_user_key}
    ${start_date}    Get From Dictionary    ${availability_data}    start_date
    ${end_date}    Get From Dictionary    ${availability_data}    end_date
    ${request_list_item_semantic}    Get Availability Request List Item Semantic On SM Phone App
    ...    ${start_date}
    ...    ${end_date}
    ...    ${requested_by_user_key}
    Swipe Until Visible    ${request_list_item_semantic}

Verify Availability List Item Not Present On SM Phone App
    [Documentation]    This keyword is used to verify the availability list item is not present on availability tab on associate roster page
    [Arguments]    ${availability_data}    ${requested_by_user_key}
    ${start_date}    Get From Dictionary    ${availability_data}    start_date
    ${end_date}    Get From Dictionary    ${availability_data}    end_date
    ${request_list_item_semantic}    Get Availability Request List Item Semantic On SM Phone App
    ...    ${start_date}
    ...    ${end_date}
    ...    ${requested_by_user_key}
    Wait Until Page Does Not Contain Element    ${request_list_item_semantic}

Tap Availability List Item On SM Phone App
    [Documentation]    This keyword is used to tap the availability list item on availability tab on associate roster page after adding availability
    [Arguments]    ${availability_data}    ${requested_by_user_key}
    ${start_date}    Get From Dictionary    ${availability_data}    start_date
    ${end_date}    Get From Dictionary    ${availability_data}    end_date
    ${request_list_item_semantic}    Get Availability Request List Item Semantic On SM Phone App
    ...    ${start_date}
    ...    ${end_date}
    ...    ${requested_by_user_key}
    Swipe Until Visible    ${request_list_item_semantic}
    Click Element    ${request_list_item_semantic}

Get Availability Request List Item Semantic On SM Phone App
    [Documentation]    This keyword is used to get the semantic of availability request list item on availability tab on associate roster page
    [Arguments]    ${start_date}    ${end_date}    ${requested_by_user_key}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${start_date_value}    Calculate Date From Week Day Offset    ${start_date}
    ${formatted_start_date}    Convert Date    ${start_date_value}    result_format=${date_format}

    IF    ${end_date} != None
        ${end_date_value}    Calculate Date From Week Day Offset    ${end_date}
        ${formatted_end_date}    Convert Date    ${end_date_value}    result_format=${date_format}
    ELSE
        ${formatted_end_date}    Convert Date    2099-12-31 00:00:00.000000    result_format=${date_format}
    END

    ${user}    Get User    user_key=${requested_by_user_key}
    ${requested_by_user_name}    Get From Dictionary    ${user}    username

    # 05/17/2026 - 05/23/2026 Active Now Requested by 210000001 On 03/16/2026    Button
    ${semantic}    Get Message With Arguments For SM
    ...    ${AVAILABILITY_LIST_ITEM_SEMANTIC}
    ...    ${formatted_start_date}
    ...    ${formatted_end_date}
    ...    ${requested_by_user_name}
    RETURN    ${semantic}

Verify Availability Request Details On SM Phone App
    [Documentation]    This keyword is used to verify the availability request details on availability request details page after tapping on availability list item on availability tab on associate roster page
    [Arguments]    ${availability_data}
    ${start_date}    Get From Dictionary    ${availability_data}    start_date
    ${end_date}    Get From Dictionary    ${availability_data}    end_date
    ${reason}    Get From Dictionary    ${availability_data}    reason
    ${status}    Get From Dictionary    ${availability_data}    status

    ${start_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR

    # Verify the details of availability request like start date, end date, reason and status on availability request details page
    IF    '${availability_data}[request_preference]' == 'Temporary'
        Wait Until Page Contains Element    ${AVAILABILITY_DETAILS_TEMPORARY}
    ELSE
        Wait Until Page Contains Element    ${AVAILABILITY_DETAILS_PERMANENT}
    END
    ${week_start_value}    Calculate Date From Week Day Offset    ${start_date}    ${start_date_format}
    ${start_date_locator}    Get Message With Arguments For SM
    ...    ${AVAILABILITY_DETAILS_START_DATE}
    ...    ${week_start_value}
    Wait Until Page Contains Element    ${start_date_locator}
    IF    '${end_date}' != 'None'
        ${week_end_value}    Calculate Date From Week Day Offset    ${end_date}    ${start_date_format}
        ${end_date_locator}    Get Message With Arguments For SM
        ...    ${AVAILABILITY_DETAILS_END_DATE}
        ...    ${week_end_value}
        Wait Until Page Contains Element    ${end_date_locator}
    END
    IF    '${reason}' != 'None'
        ${reason_locator}    Get Message With Arguments For SM    ${AVAILABILITY_DETAILS_REASON}    ${reason}
        Wait Until Page Contains Element    ${reason_locator}
    END
    ${status_locator}    Get Message With Arguments For SM    ${AVAILABILITY_DETAILS_STATUS}    ${status}
    Wait Until Page Contains Element    ${status_locator}

Tap Edit Availability Request Details On SM Phone App
    [Documentation]    This keyword is used to tap on edit details button after clicking on availability list item to edit the availability request on availability tab on associate roster page
    Wait Until Page Contains Element    ${EDIT_DETAILS_BUTTON}
    Click Element    ${EDIT_DETAILS_BUTTON}

Delete Availability Request On SM Phone App
    [Documentation]    This keyword is used to tap on delete button after clicking on availability list item to delete the availability request on availability tab on associate roster page
    Wait Until Page Contains Element    ${DELETE_AVAILABILITY_BUTTON}
    Click Element    ${DELETE_AVAILABILITY_BUTTON}
    Wait Until Page Contains Element    ${DELETE_CONFIRM_BUTTON}
    Click Element    ${DELETE_CONFIRM_BUTTON}
