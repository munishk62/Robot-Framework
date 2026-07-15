*** Settings ***
Documentation       This resource file contains the common keywords and variables for availability module test cases in mobile ess.

Library            DateTime
Resource        resources/Mobile/ESS/PagesResources/Common/Common.resource
Variables        resources/Mobile/ESS/Locators/Availability.py


*** Keywords ***
Navigate To Availability Module On Mobile ESS
    [Documentation]    Navigates mobile ESS to the aavailability module.
    Navigate Mobile ESS To Module    ${AvailabilityButtonLabel}
    ${request_title_locator}    Get Localised Locator Contains    ${AvailabilityButtonLabel}
    Wait Until Element Is Visible    ${request_title_locator}    error="Availability module is not opened."

Navigate To Add Availability Page On Mobile ESS
    [Documentation]    Navigates mobile ESS to add availability page.
    ${add_availability_button}    Get Localised Locator Exact    availability.add.title
    Select Availability Tab On Mobile ESS
    Wait Until Element Is Visible    ${add_availability_button}
    Click Element    ${add_availability_button}

Select Availability Tab On Mobile ESS
    [Documentation]    Selects availability tab in availability module on mobile ESS.
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    ${localised_semantic}    Get Localised Message From Key    availability.tabs.title.requests
    ${tab_locator}    Get Message With Arguments    ${availability_requests}    ${localised_semantic}
    Wait Until Element Is Visible    ${tab_locator}
    Click Element    ${tab_locator}

Select Availability Permanent Type On Mobile ESS
    [Documentation]    Selects permanent availability type while adding availability on mobile ESS.
    ${permanent_type_locator}    Get Localised Locator Exact    availability.label.permanent
    Wait Until Element Is Visible    ${permanent_type_locator}
    Click Element    ${permanent_type_locator}

Select Availability Temporary Type On Mobile ESS
    [Documentation]    Selects temporary availability type while adding availability on mobile ESS.
    ${temporary_type_locator}    Get Localised Locator Exact    availability.label.temporary
    Wait Until Element Is Visible    ${temporary_type_locator}
    Click Element    ${temporary_type_locator}

Select Availability Start Date On Mobile ESS
    [Documentation]    Selects availability start date while adding availability on mobile ESS.
    ...    Args:
    ...    ${start_date}: The x_y date to be selected on the calendar.
    ...    ${calendar_open_date}: The current open date on the calendar if any selected previously.
    [Arguments]    ${start_date}    ${calendar_open_date}=NA
    ${start_date_locator}    Get Localised Locator Contains    availability.details.label.week_starting
    Select Date On Calendar    ${start_date_locator}    ${start_date}    ${calendar_open_date}

Select Availability End Date On Mobile ESS
    [Documentation]    Selects availability end date while adding availability on mobile ESS.
    ...    Args:
    ...    ${end_date}: The x_y date to be selected on the calendar.
    ...    ${calendar_open_date}: The current open date on the calendar if any selected previously.
    [Arguments]    ${end_date}    ${calendar_open_date}=NA
    ${end_date_locator}    Get Localised Locator Contains    availability.details.label.week_ending
    Select Date On Calendar    ${end_date_locator}    ${end_date}    ${calendar_open_date}

Select Availability Reason On Mobile ESS
    [Documentation]    Selects availability reason while adding availability on mobile ESS.
    ...    Args:
    ...    ${reason}: The availability reason to be selected.
    [Arguments]    ${reason}
    ${reason_locator}    Get Localised Locator Contains    availability.add.label.reason
    ${reason_enabled}    Is Element Present On Mobile    ${reason_locator}
    IF    ${reason_enabled}
        Click Element    ${reason_locator}
        ${reason_value_locator}    Get Locator Contains    ${reason}
        Wait Until Element Is Visible    ${reason_value_locator}
        Click Element    ${reason_value_locator}
    ELSE
        Log    Reasons are not present in the UI skipping this step
    END

Select Entire Week Available On Mobile ESS
    [Documentation]    Selects entire week available toggle while adding availability on mobile ESS.
    ${entire_week_available}    Get Localised Locator Exact    availability.details.label.available
    Swipe Until Visible    ${entire_week_available}
    Click Element    ${entire_week_available}

Open Availability Timings Window Details On Mobile ESS
    [Documentation]    Opens availability timings window details while adding availability on mobile ESS.
    ...    Args:
    ...    ${start_time_24_hr}: The availability from time to be added in the timings window.
    ...    ${end_time_24_hr}: The availability to time to be added in the timings window.
    ...    ${working_days}: The working days to be selected in the timings window in 0,1,2,3,4,5,6 format.
    [Arguments]    ${start_time_24_hr}    ${end_time_24_hr}    ${working_days}
    ${start_localised_time}    Format Time String    ${start_time_24_hr}
    ${end_localised_time}    Format Time String    ${end_time_24_hr}
    VAR    ${start_end_time_localised}    ${start_localised_time} - ${end_localised_time}
    # 12:00 am - 12:00 am\nSun, Mon, Tue, Wed, Thu, Fri, Sat
    ${first_day_of_week}    Get Config Value    FISCAL_WEEK_START_DAY
    @{days}    Evaluate    "${working_days}".split(',')
    VAR    @{days_list}    @{EMPTY}
    FOR    ${day}    IN    @{days}
        ${converted_day_key}    Convert Dx To Day   ${day}    MEDIUM    ${first_day_of_week}
        ${localised_day}    Get Localised Message From Key    ${converted_day_key}
        Append To List    ${days_list}    ${localised_day}
    END
    ${comma_separated_days_localised}    Evaluate    ', '.join(${days_list})
    ${availability_timings_locator}    Get Locator Exact    ${start_end_time_localised} ${comma_separated_days_localised}
    Swipe Until Visible    ${availability_timings_locator}
    Click Element    ${availability_timings_locator}

Delete Availability Timings Window On Mobile ESS
    [Documentation]    Deletes availability timings window while adding availability on mobile ESS.
    ${delete_timings_button}    Get Localised Locator Exact    common.label.delete
    Wait Until Element Is Visible    ${delete_timings_button}
    Click Element    ${delete_timings_button}
    Tap Confirm Delete Availability Timings Window On Mobile ESS

Tap Confirm Delete Availability Timings Window On Mobile ESS
    [Documentation]    Used for confirming the delete availability window by accepting popup on mobile ESS.
    ${confirm_delete_title}    Get Localised Locator Exact    availability.window.delete.confirmation.title
    Wait Until Element Is Visible    ${confirm_delete_title}
    ${confirm_delete_message}    Get Localised Locator Exact    availability.window.delete.confirmation.desc
    Wait Until Element Is Visible    ${confirm_delete_message}
    ${confirm_delete_button}    Get Localised Locator Exact    availability.label.delete
    Click Element    ${confirm_delete_button}

Select Total Number Of Rotations On Mobile ESS
    [Documentation]    Selects total number of rotations to be added in availability request.
    ...    Args:
    ...    ${rotation_count}: The total number of rotations to be added in availability request.
    [Arguments]    ${rotation_count}
    ${rotation_count_locator}    Get Localised Locator Contains    availability.details.label.no_of_rotations
    Swipe Until Visible    ${rotation_count_locator}    "up"    2
    Wait Until Element Is Visible    ${rotation_count_locator}
    Click Element    ${rotation_count_locator}
    ${final_count_locator}    Get Locator Contains    ${rotation_count}
    Click Element    ${final_count_locator}

Select Rotation From Rotations Tab On Mobile ESS
    [Documentation]    Selects rotation from rotations tab while adding availability on mobile ESS.
    ...    Args:
    ...    ${rotation_number}: The rotation number to be selected from rotations tab on UI.
    [Arguments]    ${rotation_number}
    ${localise_rotation_word}    Get Localised Message From Key    availability.label.rotations
    ${rotation_tab_locator}    Get Locator Exact   ${localise_rotation_word} ${rotation_number}
    Swipe Until Visible    ${rotation_tab_locator}    "up"
    Wait Until Element Is Visible    ${rotation_tab_locator}
    Click Element    ${rotation_tab_locator}

Toggle Non Working Days On Day Picker On Mobile ESS
    [Documentation]    Toggles non working days on day picker while adding availability on mobile ESS.
    ...    Args:
    ...    ${non_working_days}: The non working days to be toggled in 0,1,2,3,4,5,6 format.
    [Arguments]    ${non_working_days}
    ${non_working_days_locator}    Get Localised Locator Contains    availability.details.label.non_working_days
    Swipe Until Visible    ${non_working_days_locator}
    Toggle Days On Day Picker    ${non_working_days}

Add Base Availability Timings On Mobile ESS
    [Documentation]    Used for adding the base availability timings
    ...    Args:
    ...    ${start_time_24_hr}: Start time in 24 hour format e.g. 09:00
    ...    ${end_time_24_hr}: End time in 24 hour format e.g. 17:00
    ...    ${working_days_to_select}: Working days to select in comma separated format for example: "1,2,3,..."
    [Arguments]    ${start_time_24_hr}    ${end_time_24_hr}    ${working_days_to_select}
    ${label_base_availability}    Get Localised Message From Key    availability.label.base_availability
    ${base_availability_timings_locator}    Get Localised Locator Contains    availability.add.semantic.addAvailability   ${label_base_availability}
    Swipe Until Visible    ${base_availability_timings_locator}
    Click Element    ${base_availability_timings_locator}
    Add Availability Time In Window On Mobile ESS   ${start_time_24_hr}    ${end_time_24_hr}    ${working_days_to_select}

Add Preferred Availability Timings On Mobile ESS
    [Documentation]    Used for adding the preffered availability timings
    ...    Args:
    ...    ${start_time_24_hr}: Start time in 24 hour format e.g. 09:00
    ...    ${end_time_24_hr}: End time in 24 hour format e.g. 17:00
    ...    ${working_days_to_select}: Working days to select in comma separated format for example: "1,2,3,..."
    [Arguments]    ${start_time_24_hr}    ${end_time_24_hr}    ${working_days_to_select}
    ${label_preferred_availability}    Get Localised Message From Key    availability.label.preferred_availability
    ${preferred_availability_timings_locator}    Get Localised Locator Contains    availability.add.semantic.addAvailability   ${label_preferred_availability}
    Swipe Until Visible    ${preferred_availability_timings_locator}
    Click Element    ${preferred_availability_timings_locator}
    Add Availability Time In Window On Mobile ESS   ${start_time_24_hr}    ${end_time_24_hr}    ${working_days_to_select}

Add On Call Availability Timings On Mobile ESS
    [Documentation]    Used for adding the on call availability timings
    ...    Args:
    ...    ${start_time_24_hr}: Start time in 24 hour format e.g. 09:00
    ...    ${end_time_24_hr}: End time in 24 hour format e.g. 17:00
    ...    ${working_days_to_select}: Working days to select in comma separated format for example: "1,2,3,..."
    [Arguments]    ${start_time_24_hr}    ${end_time_24_hr}    ${working_days_to_select}
    ${label_on_call_availability}    Get Localised Message From Key    availability.label.on_call_availability
    ${on_call_availability_timings_locator}    Get Localised Locator Contains    availability.add.semantic.addAvailability   ${label_on_call_availability}
    Swipe Until Visible    ${on_call_availability_timings_locator}
    Click Element    ${on_call_availability_timings_locator}

Add Availability Time In Window On Mobile ESS
    [Documentation]    Used for adding the availability timings, The add timings sheet
    ...    should be visible to get this keyword working.
    ...    Args:
    ...    ${start_time_24_hr}: Start time in 24 hour format e.g. 09:00
    ...    ${end_time_24_hr}: End time in 24 hour format e.g. 17:00
    ...    ${working_days_to_select}: Working days to select in comma separated format for example: "1, 2, 3,..."
    [Arguments]    ${start_time_24_hr}    ${end_time_24_hr}    ${working_days_to_select}
    Select Availability Start Time In Window On Mobile ESS    ${start_time_24_hr}
    Select Availability End Time In Window On Mobile ESS    ${end_time_24_hr}
    Toggle Days On Day Picker    ${working_days_to_select}
    ${submit_timings_button}    Get Localised Locator Exact    common.label.submit
    Wait Until Element Is Visible    ${submit_timings_button}
    Click Element    ${submit_timings_button}

Select Availability Start Time In Window On Mobile ESS
    [Documentation]    Used for selecting the availability start time
    ...    Args:
    ...    ${start_time_24_hr}: Start time in 24 hour format e.g. 09:00
    [Arguments]    ${start_time_24_hr}    ${prepopulated_time}=NA
    ${start_time_locator}    Get Localised Locator Contains    availability.add.label.start_time
    Wait Until Element Is Visible    ${start_time_locator}
    Click Element    ${start_time_locator}
    Select Time On Time Picker    ${start_time_24_hr}    ${prepopulated_time}

Select Availability End Time In Window On Mobile ESS
    [Documentation]    Used for selecting the availability end time
    ...    Args:
    ...    ${end_time_24_hr}: Start time in 24 hour format e.g. 09:00
    [Arguments]    ${end_time_24_hr}    ${prepopulated_time}=NA
    ${end_time_locator}    Get Localised Locator Contains    availability.add.label.end_time
    Wait Until Element Is Visible    ${end_time_locator}
    Click Element    ${end_time_locator}
    Select Time On Time Picker    ${end_time_24_hr}    ${prepopulated_time}

Add Availability Timing Windows On Mobile ESS
    [Documentation]    Adds availability timing window while adding availability on mobile ESS.
    ...    Args:
    ...    ${rotations}: The availability timing window details to be added in the format of list of dictionaries with start_time, end_time and working_days as keys.
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
        Select Total Number Of Rotations On Mobile ESS    ${rotation_count}
    ELSE
        Log    No rotations to add or availability is being added for temporary availability type.
    END

    FOR    ${rotation}    IN    @{rotations}
        IF    ${rotation_count} > 1 and "${rotations_enabled}" == "Y"
            ${rotation_number}    Get From Dictionary    ${rotation}    rotation_number
            Select Rotation From Rotations Tab On Mobile ESS    ${rotation_number}
        END
        ${non_working_days}    Get From Dictionary    ${rotation}    non_working_days
        Toggle Non Working Days On Day Picker On Mobile ESS    ${non_working_days}

        ${availability_hours}    Get From Dictionary    ${rotation}    availability_hours

        FOR    ${availability_hour}    IN    @{availability_hours}
            ${start_time}    Get From Dictionary    ${availability_hour}    start_time
            ${end_time}    Get From Dictionary    ${availability_hour}    end_time
            ${applicable_days}    Get From Dictionary    ${availability_hour}    applicable_days
            ${availability_options}    Get From Dictionary    ${availability_hour}    availability_option
            IF    "${availability_options}" == "BA"
                Add Base Availability Timings On Mobile ESS    ${start_time}    ${end_time}    ${applicable_days}
            ELSE IF    "${availability_options}" == "PR"
                Add Preferred Availability Timings On Mobile ESS    ${start_time}    ${end_time}    ${applicable_days}
            ELSE IF    "${availability_options}" == "OC"
                Add On Call Availability Timings On Mobile ESS    ${start_time}    ${end_time}    ${applicable_days}
            END

        END

    END

Submit Availability For Approval On Mobile ESS
    [Documentation]    Used for submitting the availability for approval
    ${submit_availability_button}    Get Localised Locator Exact    availability.label.submit
    Wait Until Element Is Visible    ${submit_availability_button}
    Click Element    ${submit_availability_button}

Verify Availability List Item On Mobile ESS
    [Documentation]    Used for verifying the availability request in the list view.
    ...    Args:
    ...    ${availability_data}: Availability data from template.
    [Arguments]    ${availability_data}
    ${start_date}    Get From Dictionary    ${availability_data}    start_date
    ${end_date}    Get From Dictionary    ${availability_data}    end_date
    ${req_type}    Get From Dictionary    ${availability_data}    request_preference
    ${req_status}    Get From Dictionary    ${availability_data}    status
    ${rotation_count}    Get Length    ${availability_data}[rotations]
    ${request_list_item_semantic}    Get Availability Request List Item Semantic On Mobile ESS    ${start_date}    ${req_type}    ${rotation_count}    ${req_status}    ${end_date}
    Swipe Until Visible    ${request_list_item_semantic}

Verify Availability List Item Not Present On Mobile ESS
    [Documentation]    Used for verifying the absence of availability request in the list view.
    ...    Args:
    ...    ${availability_data}: Availability data from template.
    [Arguments]    ${availability_data}
    ${start_date}    Get From Dictionary    ${availability_data}    start_date
    ${end_date}    Get From Dictionary    ${availability_data}    end_date
    ${req_type}    Get From Dictionary    ${availability_data}    request_preference
    ${req_status}    Get From Dictionary    ${availability_data}    status
    ${rotation_count}    Get Length    ${availability_data}[rotations]
    ${request_list_item_semantic}    Get Availability Request List Item Semantic On Mobile ESS    ${start_date}    ${req_type}    ${rotation_count}    ${req_status}    ${end_date}
    Wait Until Page Does Not Contain    ${request_list_item_semantic}

Tap Availability List Item On Mobile ESS
    [Documentation]    Used for Opening the availability request in the list view.
    ...    Args:
    ...    ${availability_data}: Availability data from template.
    [Arguments]    ${availability_data}
    ${start_date}    Get From Dictionary    ${availability_data}    start_date
    ${end_date}    Get From Dictionary    ${availability_data}    end_date
    ${req_type}    Get From Dictionary    ${availability_data}    request_preference
    ${req_status}    Get From Dictionary    ${availability_data}    status
    ${rotation_count}    Get Length    ${availability_data}[rotations]
    ${request_list_item_semantic}    Get Availability Request List Item Semantic On Mobile ESS    ${start_date}    ${req_type}    ${rotation_count}    ${req_status}    ${end_date}
    Swipe Until Visible    ${request_list_item_semantic}
    Click Element    ${request_list_item_semantic}

Get Availability Request List Item Semantic On Mobile ESS
    [Documentation]    Returns the semantic locator for an availability request in the list view.
    ...    Args:
    ...    ${start_date}: The start date of the availability request in format matching environment configuration
    ...    ${req_type}: The request type (e.g., 'Permanent', 'Temporary')
    ...    ${rotation_count}: The number of rotations in the request
    ...    ${req_status}: The status of the request (e.g., 'Pending', 'Approved')
    ...    ${end_date}: (Optional) The end date of the availability request, defaults to NA if not provided
    ...    Returns:
    ...    Locator string for the availability request list item
    [Arguments]    ${start_date}    ${req_type}    ${rotation_count}    ${req_status}    ${end_date}=None
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    IF    '${end_date}' == 'None'
        ${date_text}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}
        ${date_text_localised}    Get Localised Message From Key    availability.list.label.from
        ${date_text_locator}    Get Message With Arguments    ${date_text_localised}    ${date_text}
    ELSE
        ${requestStartText}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}
        ${requestEndText}    Calculate Date From Week Day Offset    ${end_date}    ${date_format}
        VAR    ${date_text_locator}    ${requestStartText} - ${requestEndText}
    END

    ${rotations_enabled}    Get Config Value    EMP_AVL_ROTATION
    ${req_type_permanent_localised}    Get Localised Message From Key    availability.label.permanent
    IF    '${rotations_enabled}' == 'Y' and '${req_type}' == '${req_type_permanent_localised}'
        ${rotations}    Get Localised Message From Key    availability.label.rotations
        ${final_string}    Get Message With Arguments    {0} {1} {2} {3} {4}    ${date_text_locator}    ${req_type}    ${rotations}    ${rotation_count}    ${req_status}
    ELSE
        # Catenate the date and request type has to be separated by a double space.
        ${final_string}    Get Message With Arguments    {0} {1}    ${date_text_locator}    ${req_type}
    END
    ${requestListItemSemantic}    Get Locator Contains     ${final_string}

    RETURN    ${requestListItemSemantic}

Tap Edit Availability Request Details On Mobile ESS
    [Documentation]    Used for tapping the edit button in availability request details screen on mobile ESS.
    ${edit_button}    Get Localised Locator Contains    ${availabilityEditButton}
    Wait Until Page Contains Element    ${edit_button}
    Click Element    ${edit_button}
    ${edit_label}    Get Localised Locator Contains    ${availabilityEditLabel}
    Wait Until Page Contains Element    ${edit_label}

Delete Availability From Request Details On Mobile ESS
    [Documentation]    Used for tapping the delete button in availability request details screen on mobile ESS.
    Tap Delete Availability Request Details On Mobile ESS
    Confirm Availability Delete On Mobile ESS

Tap Delete Availability Request Details On Mobile ESS
    [Documentation]    Used for tapping the delete button in availability request details screen on mobile ESS.
    ${delete_button}    Get Localised Locator Contains    ${availabilityDeleteButton}
    Click Element    ${delete_button}

Confirm Availability Delete On Mobile ESS
    [Documentation]    Confirms the deletion of a availability request by tapping yes on popup on mobile ESS.
    ${delete_button}    Get Localised Locator Exact    ${requestDeleteYes}
    Click Element    ${delete_button}
