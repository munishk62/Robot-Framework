*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Fixed Shifts page.
...
...                 = Purpose =
...                 - Centralizes actions for navigating, creating, and verifying shifts on Fixed Shifts Page.
...
...                 = Prerequisites =
...                 - Required libraries and variable files must be available and imported.

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Resource            resources/web/roster/template_calendar.resource
Variables           resources/web/rws/schedule/fixed_shifts_page.py
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/associate_template.py
Variables           resources/web/rws/schedule/fixed_shifts_page_api.py
Variables           resources/web/common/status_codes.py
Resource            resources/web/rws/schedule/all_schedules.resource
Resource            resources/web/authentication/login.resource


*** Keywords ***
Navigate To CORP RWS Schedule Fixed Shifts Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Fixed Shifts Page
    ...    and verifies fixed shifts heading at the top of the page
    Navigate To Specific Page On Web    rws    schedule    fixed_shifts_corp

Navigate To Store RWS Schedule Fixed Shifts Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Fixed Shifts Page
    ...    and verifies fixed shifts heading at the top of the page
    Navigate To Specific Page On Web    rws    schedule    fixed_shifts

Map Week Pattern With Template
    [Documentation]    This keyword maps week pattern (for the week identified by start date of week)
    ...    with the template (first one) from the options to select.
    ...    | =Arguments= | =Description= |
    ...    | date_of_week    | Date of week through which week pattern can be identified for selecting template |
    ...    | template_index    | Index of the template to be selected (default is 1) |
    [Arguments]    ${date_of_week}    ${template_index}=1
    ${week_map_status_updated_loc}    Update Locator With Dynamic Values
    ...    ${FIXEDSHIFTSPAGE_WEEK_MAP_STATUS_FOR_GIVEN_DATE}    DATEOFWEEK=${date_of_week}
    Click Element On Webpage    ${week_map_status_updated_loc}
    ${work_pattern_template}    Update Locator With Dynamic Values
    ...    ${FIXEDSHIFTSPAGE_SELECT_WORK_PATTERN}    INDEX=${template_index}
    Click Element On Webpage    ${work_pattern_template}
    Click Element On Webpage    ${FIXEDSHIFTSPAGE_APPLY_BTN}
    Click Element On Webpage    ${FIXEDSHIFTSPAGE_SAVE_CHANGES_BTN}

Is Week Pattern Mapped
    [Documentation]    This keyword checks if the week pattern (with provided start date)
    ...    is mapped to generate schedule with template.
    ...    | =Arguments= | =Description= |
    ...    | date_of_week    | Date of week to check if week pattern is mapped |
    [Arguments]    ${date_of_week}
    ${week_map_status_updated_loc}    Update Locator With Dynamic Values
    ...    ${FIXEDSHIFTSPAGE_WEEK_MAP_STATUS_FOR_GIVEN_DATE}    DATEOFWEEK=${date_of_week}
    ${week_map_attribute_value}    Get Attribute    ${week_map_status_updated_loc}    ng-if
    IF    '${week_map_attribute_value}' == '(eachWeekMap.templateId!=0)'
        RETURN    True
    ELSE IF    '${week_map_attribute_value}' == '(eachWeekMap.templateId==0)'
        RETURN    False
    END

Delete Week Pattern Mapping
    [Documentation]    This keyword deletes week pattern mapping for the selected week. Week is selected by
    ...    the starting date of the week which is passed as argument to this keyword.
    ...    | =Arguments= | =Description= |
    ...    | date_of_week    | Date of week to identify week pattern to be deleted |
    [Arguments]    ${date_of_week}
    ${week_map_status_updated_loc}    Update Locator With Dynamic Values
    ...    ${FIXEDSHIFTSPAGE_WEEK_MAP_STATUS_FOR_GIVEN_DATE}    DATEOFWEEK=${date_of_week}
    Click Element On Webpage    ${week_map_status_updated_loc}
    Click Element On Webpage    ${FIXEDSHIFTSPAGE_DELETE_BTN}
    Click Element On Webpage    ${FIXEDSHIFTSPAGE_SAVE_CHANGES_BTN}

Navigate To Associate Template Page On Web
    [Documentation]    Navigate to the Associate Template section under Fixed Shifts
    Navigate To Store RWS Schedule Fixed Shifts Page On Web
    Select Associate Template On Web

Select Associate Template On Web
    [Documentation]    Selects the Associate Template section from the Fixed Shifts dropdown
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_CALENDAR_DROPDOWN}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_FROM_CALENDAR}
    Wait Until Page Is Loaded

Navigate To Reviewed Fixed Shift Page On Web
    [Documentation]    Navigate to the Reviewed Fixed Shift section under Fixed Shifts
    Navigate To Store RWS Schedule Fixed Shifts Page On Web
    Select Reviewed Fixed Template On Web

Get Template Info From API Before Navigate To Review Fixed Shifts On Web
    [Documentation]    Captures template info API response before navigating to Review Fixed Shifts page
    ...    Extracts shift details including day number, start time, end time, assigned associate ID
    ...    | =Arguments= | =Description= |
    ...    | template_number | The template number to fetch info for |
    ...    Returns dictionary with templateShifts and unitDetailsMap from API response
    ...    Example usage:
    ...    | ${template_data}= | Get Template Info From API Before Navigate To Review Fixed Shifts On Web | 2224 |
    [Arguments]    ${template_number}
    # Convert template number to string for API URL replacement
    ${template_number_str}    Convert To String    ${template_number}

    # Update the API regex with actual template number
    VAR    ${template_info_api}    ${GET_TEMPLATE_INFO_API_REGEX}
    ${template_info_api}    Replace String    ${template_info_api}    {TEMP_NUMB}    ${template_number_str}

    # Set up promise before navigation triggers the API call
    ${promise}    Promise To    Wait For Response    ${template_info_api}

    Select Template Preview For Fixed Shift On Web Associate Template Page On Web    ${template_number}

    # Wait for and capture the API response
    ${response_body}    Wait For    ${promise}
    Log    Template Info API Response: ${response_body.body}

    # Validate successful response
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

    # Extract metaInfo containing template shifts and unit details
    ${api_response_meta_info}    Get From Dictionary    ${response_body.body}    metaInfo

    RETURN    ${api_response_meta_info}

Parse Template Shifts From API Response
    [Documentation]    Parses template shifts from API meta info to extract shift details
    ...    | =Arguments= | =Description= |
    ...    | api_response_meta_info | The metaInfo dictionary from template info API response |
    ...    Returns list of dictionaries containing parsed shift data
    ...    Each dict has: day_number, start_time, end_time, assigned_to, shift_no
    [Arguments]    ${api_response_meta_info}
    ${template_shifts}    Get From Dictionary    ${api_response_meta_info}    templateShifts
    VAR    @{parsed_shifts}    @{EMPTY}

    FOR    ${shift}    IN    @{template_shifts}
        ${day_no}    Get From Dictionary    ${shift}    dayNo
        ${start_time}    Get From Dictionary    ${shift}    startTime
        ${end_time}    Get From Dictionary    ${shift}    endTime
        ${assigned_to}    Get From Dictionary    ${shift}    assignedTo
        ${shift_no}    Get From Dictionary    ${shift}    shiftNo

        # Convert start and end times from minutes to HH:MM format
        ${start_time_formatted}    Convert Minutes To Time Format    ${start_time}
        ${end_time_formatted}    Convert Minutes To Time Format    ${end_time}

        VAR    &{shift_data}
        ...    day_number=${day_no}
        ...    start_time=${start_time_formatted}
        ...    end_time=${end_time_formatted}
        ...    assigned_to=${assigned_to}
        ...    shift_no=${shift_no}

        Append To List    ${parsed_shifts}    ${shift_data}
        Log    Parsed Shift - Day: ${day_no}, Time: ${start_time_formatted}-${end_time_formatted}, Assigned To: ${assigned_to}
    END

    RETURN    ${parsed_shifts}

Convert Minutes To Time Format
    [Documentation]    Converts minutes since midnight to HH:MM format
    ...    | =Arguments= | =Description= |
    ...    | minutes | Total minutes since midnight (e.g., 600 for 10:00 AM) |
    ...    Returns time in HH:MM 24-hour format
    [Arguments]    ${minutes}
    ${hours}    Evaluate    ${minutes} // 60
    ${mins}    Evaluate    ${minutes} % 60
    ${time_str}    Evaluate    f"{${hours}:02d}:{${mins}:02d}"
    RETURN    ${time_str}

Capture And Parse Template Info From API And Wait For Review Dropdown
    [Documentation]    Captures template info from API, parses the shift data, and waits for Review Fixed Shifts dropdown
    ...    This keyword should be called after editing template and before navigating to Review Fixed Shifts
    ...    | =Arguments= | =Description= |
    ...    | template_number | The template number to fetch info for |
    ...    Returns parsed shift data from API response
    ...    Example usage:
    ...    | ${parsed_shifts}= | Capture And Parse Template Info From API And Wait For Review Dropdown | ${template_number1} |
    [Arguments]    ${template_number}
    # Capture template data from API by clicking template preview
    ${api_response_meta_info}    Get Template Info From API Before Navigate To Review Fixed Shifts On Web    ${template_number}

    # Parse the template shifts
    ${parsed_shifts}    Parse Template Shifts From API Response    ${api_response_meta_info}

    # Wait for Review Fixed Shifts dropdown to be ready for navigation
    Wait Until Element Is Visible On Webpage    ${REVIEW_FIXED_TEMPLATES_FROM_DROPDOWN}    timeout=${LONG_TIMEOUT}

    RETURN    ${parsed_shifts}

Edit Template Copy Shifts Lock And Capture API Data On Web
    [Documentation]    Edits template by copying shifts, mapping work pattern, locking, and capturing template data from API
    ...    This is a comprehensive keyword that combines editing and data capture
    ...    | =Arguments= | =Description= |
    ...    | template_number | The template number to edit |
    ...    | copy_shift_config | Dictionary or list of dictionaries for copy shift configuration |
    ...    Returns parsed shift data from API response
    [Arguments]    ${template_number}    ${copy_shift_config}
    # Step 1: Copy shifts to multiple days
    Edit Template Shifts By Copy To Multiple Days On Web    ${template_number}    ${copy_shift_config}

    Perform Lock On Web Preview Template And Verify API Response On Web
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_CLOSE_PANEL}

Navigate To Review Fixed Shifts And Regenerate With API Data Verification On Web
    [Documentation]    Complete workflow: Navigate to Review Fixed Shifts, select week, regenerate, and verify UI matches API data
    ...    | =Arguments= | =Description= |
    ...    | planning_week_start_date | Planning week start date to select on calendar |
    [Arguments]    ${planning_week_start_date}
    Navigate To Store RWS Schedule Fixed Shifts Page On Web
    Wait Until Page Is Loaded
    ${is_week_in_current_fiscal_year}    Run Keyword And Return Status
    ...    Select And Review Fixed Shift On Template Calendar Page On Web    ${planning_week_start_date}
    IF    not ${is_week_in_current_fiscal_year}
        Select Planning Year On Web    ${planning_week_start_date}
        Wait Until Page Is Loaded
        Select And Review Fixed Shift On Template Calendar Page On Web    ${planning_week_start_date}
    END
    # Step 4 & 5: Capture and parse template data from API
    Regenerate Fixed Shift On Review Fixed Shift Page On Web
    # Verify UI data matches API data

Select Review Fixed Shift On Template Calendar Page On Web
    [Documentation]    Selects the Review Fixed Shift option from the Template Calendar page

    Click Element On Webpage    ${REVIEW_FIXED_TEMPLATES_FROM_DROPDOWN}
    Wait Until Page Is Loaded

Verify Shifts On Review Page Match API Data On Web
    [Documentation]    Verifies that shifts on Review Fixed Shifts page match the API data
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to verify (e.g., "Associate05, ") |
    ...    | parsed_shifts_from_api | List of parsed shifts from API response |
    ...    | planning_week_start_date | Planning week start date in week_day format (e.g., 1_1) |
    ...    Example usage:
    ...    | Verify Shifts On Review Page Match API Data On Web | Associate05,    | ${parsed_shifts} | 1_1 |
    [Arguments]    ${associate_name}    ${parsed_shifts_from_api}    ${planning_week_start_date}
    Log    Verifying ${parsed_shifts_from_api.__len__()} shifts for ${associate_name}
    # Extract week number from planning_week_start_date (e.g., "3_2" -> "3")
    @{pw_parts}    Split String    ${planning_week_start_date}    _
    VAR    ${week_number}    ${pw_parts}[0]
    # Verify each shift from API data exists on UI with correct times
    ${fiscal_week_start}    Get Config Value    FISCAL_WEEK_START_DAY
    IF    ${fiscal_week_start} > 1
        ${parsed_shifts_from_api}    Apply Reverse Fiscal Day Conversion To Parsed Shifts On Web    ${parsed_shifts_from_api}
    END
    FOR    ${shift}    IN    @{parsed_shifts_from_api}
        ${day_no}    Get From Dictionary    ${shift}    day_number
        ${start_time}    Get From Dictionary    ${shift}    start_time
        ${end_time}    Get From Dictionary    ${shift}    end_time
        ${assigned_to}    Get From Dictionary    ${shift}    assigned_to
        # Convert times to 12-hour format for UI comparison
        ${start_12hr}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
        ${end_12hr}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}
        # Create time formats without spaces for XPath matching (e.g., "09:00 am" -> "09:00am")
        ${start_12hr_no_space}    Replace String    ${start_12hr}    ${SPACE}    ${EMPTY}
        ${end_12hr_no_space}    Replace String    ${end_12hr}    ${SPACE}    ${EMPTY}
        # Example: planning_week_start_date="3_2" + day_no=0 -> "3_0"
        VAR    ${week_day_for_shift}    ${week_number}_${day_no}
        ${shift_date}    Calculate Date From Week Day Offset    ${week_day_for_shift}
        # Convert to the format used in the UI aria-label: "Sunday 23 November"
        ${shift_day_name}    Convert Date    ${shift_date}    result_format=%A %d %B
        Log    Verifying Day ${day_no}: ${start_12hr} - ${end_12hr} on ${shift_day_name} (Assigned to: ${assigned_to})
        # Build locator for shift time text using the REVIEW_FIXED_SHIFTS_SHIFT_DATE template
        # This locator handles both time formats: "09:00 am" OR "09:00am" and "05:00 pm" OR "05:00pm"
        ${shift_time_locator}    Update Locator With Dynamic Values
        ...    ${REVIEW_FIXED_SHIFTS_SHIFT_DATE}    ASSOCIATE_NAME=${associate_name}
        ...    START_TIME=${start_12hr}    START_TIME_NO_SPACE=${start_12hr_no_space}
        ...    END_TIME=${end_12hr}    END_TIME_NO_SPACE=${end_12hr_no_space}
        ...    SHIFT_DAY=${shift_day_name}
        # Verify shift bubble exists
        Wait Until Element Is Visible On Webpage    ${shift_time_locator}    timeout=${MEDIUM_TIMEOUT}
        # Get actual times from UI to validate
        ${actual_text}    Get Element Text On Webpage    ${shift_time_locator}
        # The UI may display "09:00 am" or "09:00am", so check both
        ${start_time_matches}    Run Keyword And Return Status
        ...    Should Contain Any    ${actual_text}    ${start_12hr}    ${start_12hr_no_space}
        Should Be True    ${start_time_matches}
        ...    msg=Day ${day_no} (${shift_day_name}): Expected start time ${start_12hr} or ${start_12hr_no_space} not found. Actual: ${actual_text}
        ${end_time_matches}    Run Keyword And Return Status
        ...    Should Contain Any    ${actual_text}    ${end_12hr}    ${end_12hr_no_space}
        Should Be True    ${end_time_matches}
        ...    msg=Day ${day_no} (${shift_day_name}): Expected end time ${end_12hr} or ${end_12hr_no_space} not found. Actual: ${actual_text}
        Log    ✓ Day ${day_no} verified: ${start_12hr} - ${end_12hr} on ${shift_day_name}
    END
    Log    Successfully verified all ${parsed_shifts_from_api.__len__()} shifts match API data

Verify Shifts Are Not Visible After Template Deletion On Web
    [Documentation]    Verifies that shifts are NOT visible on Review Fixed Shifts page after template deletion
    ...    This keyword is used as a teardown validation to ensure deleted template shifts don't appear on UI
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to verify (e.g., "Associate05, ") |
    ...    | parsed_shifts_from_api | List of parsed shifts from API response that should NOT be visible |
    ...    | planning_week_start_date | Planning week start date in week_day format (e.g., 1_1) |
    ...    Example usage:
    ...    | Verify Shifts Are Not Visible After Template Deletion On Web | Associate05,    | ${parsed_shifts} | 1_1 |
    [Arguments]    ${associate_name}    ${parsed_shifts_from_api}    ${planning_week_start_date}

    Log    Verifying ${parsed_shifts_from_api.__len__()} shifts are NOT visible for ${associate_name} after deletion

    # Extract week number from Planning_Week_Start_Date (e.g., "3_2" -> "3")
    @{pw_parts}    Split String    ${planning_week_start_date}    _
    VAR    ${week_number}    ${pw_parts}[0]

    # Verify each shift from API data does NOT exist on UI with correct times
    ${fiscal_week_start}    Get Config Value    FISCAL_WEEK_START_DAY
    IF    ${fiscal_week_start} > 1
        ${parsed_shifts_from_api}    Apply Reverse Fiscal Day Conversion To Parsed Shifts On Web    ${parsed_shifts_from_api}
    END
    FOR    ${shift}    IN    @{parsed_shifts_from_api}
        ${day_no}    Get From Dictionary    ${shift}    day_number
        ${start_time}    Get From Dictionary    ${shift}    start_time
        ${end_time}    Get From Dictionary    ${shift}    end_time
        ${assigned_to}    Get From Dictionary    ${shift}    assigned_to

        # Convert times to 12-hour format for UI comparison
        ${start_12hr}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
        ${end_12hr}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}

        # Create time formats without spaces for XPath matching
        ${start_12hr_no_space}    Replace String    ${start_12hr}    ${SPACE}    ${EMPTY}
        ${end_12hr_no_space}    Replace String    ${end_12hr}    ${SPACE}    ${EMPTY}

        # Build week_day format by replacing day component with day_no from API
        VAR    ${week_day_for_shift}    ${week_number}_${day_no}

        # Calculate the actual date for this shift
        ${shift_date}    Calculate Date From Week Day Offset    ${week_day_for_shift}

        # Convert to the format used in the UI aria-label: "Sunday 23 November"
        ${shift_day_name}    Convert Date    ${shift_date}    result_format=%A %d %B

        Log    Verifying Day ${day_no}: ${start_12hr} - ${end_12hr} on ${shift_day_name} is NOT visible (was assigned to: ${assigned_to})

        # Build locator for shift time text
        ${shift_time_locator}    Update Locator With Dynamic Values
        ...    ${REVIEW_FIXED_SHIFTS_SHIFT_DATE}    ASSOCIATE_NAME=${associate_name}
        ...    START_TIME=${start_12hr}    START_TIME_NO_SPACE=${start_12hr_no_space}
        ...    END_TIME=${end_12hr}    END_TIME_NO_SPACE=${end_12hr_no_space}
        ...    SHIFT_DAY=${shift_day_name}

        # Verify shift bubble does NOT exist - uses short timeout to avoid long waits
        ${shift_visible}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${shift_time_locator}    timeout=2s

        Should Not Be True    ${shift_visible}
        ...    msg=Day ${day_no} (${shift_day_name}): Shift ${start_12hr} - ${end_12hr} should NOT be visible after template deletion, but it still exists on UI

        Log    ✓ Day ${day_no} verified as NOT visible: ${start_12hr} - ${end_12hr} on ${shift_day_name}
    END

    Log    Successfully verified all ${parsed_shifts_from_api.__len__()} shifts are NOT visible after template deletion

Verify Created Shift Removed Post Associate Template Deletion On Review Fixed Shift Page On Web
    [Documentation]    Verifies that created shifts are removed after associate template deletion
    ...    Logs in, navigates to Review Fixed Shift page, and verifies shifts are not visible
    ...    | =Arguments= | =Description= |
    ...    | sm_user_key | User key for Store Manager login |
    ...    | associate_name | Name of the associate to verify |
    ...    | parsed_shifts_from_api | List of shifts that should not be visible |
    ...    | planning_week_start_date | Planning week start date in week_day format |
    [Arguments]    ${sm_user_key}    ${associate_name}    ${parsed_shifts_from_api}    ${planning_week_start_date}
    Login And Launch WFM Web App    user_key=${sm_user_key}
    Navigate To Review Fixed Shifts And Regenerate With API Data Verification On Web    ${planning_week_start_date}
    Verify Shifts Are Not Visible After Template Deletion On Web    ${associate_name}    ${parsed_shifts_from_api}
    ...    ${planning_week_start_date}

Select Reviewed Fixed Template On Web
    [Documentation]    Selects the Associate Template section from the Fixed Shifts dropdown
    ${review_fixed_shift_visible}    Run Keyword And Return Status    Check Review Fixed Shift On Fixed Shift Page Dropdown On Web
    IF    ${review_fixed_shift_visible}
        Click Element On Webpage    ${REVIEW_FIXED_TEMPLATES_FROM_DROPDOWN}
    ELSE
        Click Element On Webpage    ${ASSOCIATE_TEMPLATES_FROM_CALENDAR}
        Click Element On Webpage    ${REVIEW_FIXED_TEMPLATES_FROM_DROPDOWN}
    END

Check Review Fixed Shift On Fixed Shift Page Dropdown On Web
    [Documentation]    Check Review Fixed Shift On Fixed Shift Page Dropdown
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_CALENDAR_DROPDOWN}
    Wait Until Element Is Visible On Webpage    ${REVIEW_FIXED_TEMPLATES_FROM_DROPDOWN}

Perform MapTo Operation On Template Preview And Verify API Response On Web
    [Documentation]    selects Map to option from Template Preview
    [Arguments]    ${work_pattern_name}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_MAP_TO_OPTION}
    ${mapped_to}    Update Locator With Dynamic Values    ${ASSOCIATE_TEMPLATES_MAPPED_TO_OPTION}    WORK_PATTERN_NAME=${work_pattern_name}
    ${already_mapped}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${mapped_to}
    IF    not ${already_mapped}
        Map Work Pattern To Associate Template On Web    ${work_pattern_name}
        Wait Until Element Is Visible On Webpage    ${mapped_to}
    END
    ${promise}    Promise To    Wait For Response    ${MAP_WORK_PATTERN_ASSOCIATE_TEMPLATE_SUCCESSFUL_API_REGEX}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_MAP_TO_SAVE_OPTION}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[CREATED]
    Ensure Success Toast Notification Not Visible On Web

Perform Lock On Web Preview Template And Verify API Response On Web
    [Documentation]    selects shift Lock option from Template Preview
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_LOCK_OPTION}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_LOCK_ALL_SHIFTS}
    ${promise}    Promise To    Wait For Response    ${LOCK_ALL_SHIFT_ASSOCIATE_TEMPLATE_SUCCESSFUL_API_REGEX}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_LOCK_OPTION_SAVE}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Ensure Success Toast Notification Not Visible On Web

Select Template Preview For Fixed Shift On Web Associate Template Page On Web
    [Documentation]    keyword for click Newly created Template
    [Arguments]    ${template_number}
    # Use dynamic locator template with Update Locator With Dynamic Values
    ${template_number_str}    Convert To String    ${template_number}
    ${template_preview_locator}    Update Locator With Dynamic Values    ${ASSOCIATE_TEMPLATES_TEMPLATE_PREVIEW_BY_NUMBER}
    ...    TEMPLATE_NUMBER=${template_number_str}
    Click Element On Webpage    ${template_preview_locator}

Add Shift For Multiple Required Day's And Time On Web Associate Template Page On Web
    [Documentation]    keyword to add shift for multiple required day's and time on web associate template page
    [Arguments]    ${shift_day_list}
    ${shift_days_length}    Get Length    ${shift_day_list}
    FOR    ${index}    IN RANGE    0    ${shift_days_length}
        ${shift_day}    Get From List    ${shift_day_list}    ${index}
        ${day}    Get From Dictionary    ${shift_day}    day_number
        ${start_time}    Get From Dictionary    ${shift_day}    start_time
        ${end_time}    Get From Dictionary    ${shift_day}    end_time
        ${formated_start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
        ${formated_end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}

        Log    Day: ${day}, Start Time: ${formated_start_time}, End Time: ${formated_end_time}
        Enter Time Details In Add Shift On Web    ${formated_start_time}    ${formated_end_time}    ${day}
    END

Enter Time Details In Add Shift On Web
    [Documentation]    keyword for adding time details for Add Shift input 10a - 5.30p Day 2
    [Arguments]    ${start_time}    ${end_time}    ${day}
    ${add_shift_path}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_TEMPLATES_SHIFT_DAY_CONTAINER}    DAY_NUMBER=${day}
    ${start_time_path}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_TEMPLATES_SHIFT_START_TIME_INPUT}    DAY_NUMBER=${day}
    ${end_time_path}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_TEMPLATES_SHIFT_END_TIME_INPUT}    DAY_NUMBER=${day}
    Click Element On Webpage    ${add_shift_path}
    Fill Textbox On Webpage    ${start_time_path}    ${start_time}
    Fill Textbox On Webpage    ${end_time_path}    ${end_time}
    Wait Until Element Is Visible On Webpage    ${ASSOCIATE_TEMPLATES_SHIFT_TIME_TICK_BUTTON}    timeout=${MEDIUM_TIMEOUT}
    ${promise}    Promise To    Wait For Response    ${ADD_EMPLOYEE_TEMPLATE_SHIFT_API_REGEX}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_SHIFT_TIME_TICK_BUTTON}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[CREATED]
    Ensure Success Toast Notification Not Visible On Web

Select Blank Template On Web
    [Documentation]    Selects the blank template option when adding a new associate template
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_ADD_TEMPLATE}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_ADD_BLANK_TEMPLATE}

Select Work Pattern For Fixed Shift Template On Web
    [Documentation]    Selects a work pattern for the fixed shift template
    [Arguments]    ${work_pattern_name}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_ADD_WORK_PATTERN}
    Fill Textbox On Webpage    ${ASSOCIATE_TEMPLATES_SEARCH_WORK_PATTERN}    ${work_pattern_name}
    ${work_pattern_option_locator}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_TEMPLATES_WORK_PATTERN_OPTION}    WORK_PATTERN_NAME=${work_pattern_name}
    Click Element On Webpage    ${work_pattern_option_locator}

Map Work Pattern To Associate Template On Web
    [Documentation]    Maps a work pattern to the associate template
    [Arguments]    ${work_pattern_name}
    Fill Textbox On Webpage    ${ASSOCIATE_TEMPLATES_SEARCH_WORK_PATTERN}    ${work_pattern_name}
    ${work_pattern_option_locator}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_TEMPLATES_WORK_PATTERN_SEARCH_RESULT}    WORK_PATTERN_NAME=${work_pattern_name}
    Click Element On Webpage    ${work_pattern_option_locator}

Select Associate For Template On Web
    [Documentation]    Selects an associate from the dropdown for template assignment
    [Arguments]    ${associate_name}
    @{name_parts}    Split String    ${associate_name}    ,
    VAR    ${first_name}    ${name_parts}[0]
    VAR    ${last_name}    ${name_parts}[1]
    ${select_associate_locator}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_TEMPLATES_ASSOCIATE_OPTION}    FIRST_NAME=${first_name}    LAST_NAME=${last_name}
    Fill Text    ${ASSOCIATE_TEMPLATES_ADD_TEMP_EMP}    ${associate_name}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_ADD_TEMP_EMP}
    Click Element On Webpage    ${select_associate_locator}

Delete Associate Template On Web
    [Documentation]    Deletes an associate template by selecting the delete option from the template preview
    [Arguments]    ${template_number}
    ${template_number_str}    Convert To String    ${template_number}
    ${delete_associate_template_locator}    Update Locator With Dynamic Values
    ...    ${ASSOCIATE_TEMPLATES_DELETE_TEMPLATE_BY_NUMBER}    TEMPLATE_NUMBER=${template_number_str}
    ${promise}    Promise To    Wait For Response    ${DELETE_ASSOCIATE_TEMPLATE_API_REGEX}
    Click Element On Webpage    ${delete_associate_template_locator}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_DELETE_CONFIRM}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Ensure Success Toast Notification Not Visible On Web

Delete Work Pattern Based Template And Verify Api Success On Web
    [Documentation]    Clears the associate template by selecting the clear option from the template preview
    [Arguments]    ${sm_user_key}    ${template_number}
    Login And Launch WFM Web App    user_key=${sm_user_key}
    Navigate To Associate Template Page On Web
    Delete Associate Template On Web    ${template_number}

Add New Associate Template On Web
    [Documentation]
    ...    Creates a new associate template and verifies the API response.
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | Name of the associate for the template.    |
    ...    | planning_week    | Planning week for the effective date.    |
    ...    | work_pattern_name    | Name of the work pattern to assign.    |
    ...    *Returns*: Template number from the created associate template.
    ...    Example usage:
    ...    | Add New Associate Template    John Doe    1_1    Standard Pattern
    [Arguments]    ${associate_name}    ${planning_week}    ${work_pattern_name}
    Select Blank Template On Web
    Select Associate For Template On Web    ${associate_name}
    Input Date In Date Picker Through Input Box    ${ASSOCIATE_TEMPLATES_ADD_EFFECTIVE_DATE_INPUT_TEXT_BOX}    ${planning_week}
    Select Work Pattern For Fixed Shift Template On Web    ${work_pattern_name}
    ${promise}    Promise To    Wait For Response    ${ADD_EMPLOYEE_TEMPLATE_API_REGEX}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_SAVE_TEMP}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[CREATED]
    Ensure Success Toast Notification Not Visible On Web
    RETURN    ${response_body.body.metaInfo.createdEmployeeTemplate.templateNo}

Add New Blank Template Assign Shift By Mapping Work Pattern On Associate Template Page On Web
    [Documentation]    Adds a new blank template and assigns shifts by mapping a work pattern
    [Arguments]    ${associate_name}    ${planning_week}    ${work_pattern_name}    ${shift_day_list}
    Navigate To Associate Template Page On Web
    Delete All Existing Associate Templates For Associate On Web    ${associate_name}
    ${template_number}    Add New Associate Template On Web    ${associate_name}    ${planning_week}    ${work_pattern_name}
    Select Template Preview For Fixed Shift On Web Associate Template Page On Web    ${template_number}
    Add Shift For Multiple Required Day's And Time On Web Associate Template Page On Web    ${shift_day_list}
    Perform MapTo Operation On Template Preview And Verify API Response On Web    ${work_pattern_name}
    Perform Lock On Web Preview Template And Verify API Response On Web
    RETURN    ${template_number}

Click On Shift Bubble By Index On Web
    [Documentation]    Clicks on a shift bubble by its index to access shift options
    ...    | =Arguments= | =Description= |
    ...    | shift_index | Index of the shift bubble to click (1-based) |
    [Arguments]    ${shift_index}
    ${shift_bubble_locator}    Update Locator With Dynamic Values    ${ASSOCIATE_TEMPLATES_SHIFT_BUBBLE_BY_INDEX}    INDEX=${shift_index}
    Click Element On Webpage    ${shift_bubble_locator}

Copy Shift To Multiple Days On Web
    [Documentation]    Copies a shift to multiple days by selecting day checkboxes
    ...    | =Arguments= | =Description= |
    ...    | copy_to_days_list | List of day numbers to copy the shift to (e.g., [2, 5] for Tuesday and Friday) |
    [Arguments]    ${copy_to_days_list}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_EDIT_SHIFT}
    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_COPY_SHIFT}

    # Iterate through the list of days to copy to
    FOR    ${day_number}    IN    @{copy_to_days_list}
        ${day_number_str}    Convert To String    ${day_number}
        ${copy_day_locator}    Update Locator With Dynamic Values
        ...    ${ASSOCIATE_TEMPLATES_COPY_DAY_BY_INDEX}    DAY_NUMBER=${day_number_str}
        Click Element On Webpage    ${copy_day_locator}
    END

    Click Element On Webpage    ${ASSOCIATE_TEMPLATES_COPY_SHIFT_SAVE}
    Verify Success Toast Notification

Copy Shift From Config On Web
    [Documentation]    Copies a shift based on configuration dictionary
    ...    | =Arguments= | =Description= |
    ...    | copy_config | Dictionary with keys: shift_index, source_day, copy_to_days |
    ...    Example config: {'shift_index': 1, 'source_day': 0, 'copy_to_days': [2, 5]}
    [Arguments]    ${copy_config}
    ${shift_index}    Get From Dictionary    ${copy_config}    shift_index
    ${copy_to_days}    Get From Dictionary    ${copy_config}    copy_to_days

    Click On Shift Bubble By Index On Web    ${shift_index}
    Copy Shift To Multiple Days On Web    ${copy_to_days}

Edit Template Shifts By Copy To Multiple Days On Web
    [Documentation]    Edits an existing template by copying shifts to multiple days
    ...    This keyword selects an existing template and applies copy shift operations
    ...    | =Arguments= | =Description= |
    ...    | template_number | The template number to edit |
    ...    | copy_shift_config | Dictionary or list of dictionaries for copy shift configuration |
    ...    Example usage:
    ...    | Edit Template Shifts By Copy To Multiple Days On Web | ${template_number1} | ${copy_shift_config} |
    [Arguments]    ${template_number}    ${copy_shift_config}
    Select Template Preview For Fixed Shift On Web Associate Template Page On Web    ${template_number}

    # Handle copy shift configuration - can be single dict or list of dicts
    ${is_list}    Evaluate    isinstance($copy_shift_config, list)
    IF    ${is_list}
        FOR    ${config}    IN    @{copy_shift_config}
            Copy Shift From Config On Web    ${config}
        END
    ELSE
        Copy Shift From Config On Web    ${copy_shift_config}
    END

Edit Template Copy Shifts Map And Lock On Web
    [Documentation]    Wrapper keyword to edit template by copying shifts, then map work pattern and lock all shifts
    ...    This combines three operations: Copy shifts to days, Map to work pattern, Lock all shifts
    ...    | =Arguments= | =Description= |
    ...    | template_number | The template number to edit |
    ...    | copy_shift_config | Dictionary or list of dictionaries for copy shift configuration |
    ...    | work_pattern_name | Name of the work pattern to map |
    ...    Example usage:
    ...    | Edit Template Copy Shifts Map And Lock On Web | ${template_number1} | ${copy_shift_config} | Standard Pattern |
    [Arguments]    ${template_number}    ${copy_shift_config}    ${work_pattern_name}
    Edit Template Shifts By Copy To Multiple Days On Web    ${template_number}    ${copy_shift_config}
    Perform MapTo Operation On Template Preview And Verify API Response On Web    ${work_pattern_name}
    Perform Lock On Web Preview Template And Verify API Response On Web

Get Shift Days From Template Data On Web
    [Documentation]    Extracts all days that have shifts from template data
    ...    Returns a list of day numbers (as strings) that contain shifts
    ...    | =Arguments= | =Description= |
    ...    | shift_day_list | List of shift dictionaries from template data |
    ...    | copy_shift_config | Copy shift configuration (single dict or list) |
    ...    Returns list of day numbers like ["0", "2", "5"] for Sunday, Tuesday, Friday
    [Arguments]    ${shift_day_list}    ${copy_shift_config}
    # Get the original shift days
    VAR    @{all_days}    @{EMPTY}
    FOR    ${shift}    IN    @{shift_day_list}
        ${day_num}    Get From Dictionary    ${shift}    day_number
        Append To List    ${all_days}    ${day_num}
    END

    # Add copy_to_days from copy config
    ${is_list}    Evaluate    isinstance($copy_shift_config, list)
    IF    ${is_list}
        FOR    ${config}    IN    @{copy_shift_config}
            ${copy_days}    Get From Dictionary    ${config}    copy_to_days
            FOR    ${day}    IN    @{copy_days}
                Append To List    ${all_days}    ${day}
            END
        END
    ELSE
        ${copy_days}    Get From Dictionary    ${copy_shift_config}    copy_to_days
        FOR    ${day}    IN    @{copy_days}
            Append To List    ${all_days}    ${day}
        END
    END

    # Remove duplicates and sort
    ${unique_days}    Remove Duplicates    ${all_days}
    Sort List    ${unique_days}
    RETURN    ${unique_days}

Get Expected Shift Times From Template Data On Web
    [Documentation]    Extracts start and end times from the first shift in template data
    ...    Assumes all shifts have the same times (copied shifts)
    ...    | =Arguments= | =Description= |
    ...    | shift_day_list | List of shift dictionaries from template data |
    ...    Returns dictionary with 'start_time' and 'end_time' keys
    [Arguments]    ${shift_day_list}
    ${first_shift}    Get From List    ${shift_day_list}    0
    ${start_time}    Get From Dictionary    ${first_shift}    start_time
    ${end_time}    Get From Dictionary    ${first_shift}    end_time

    # Convert to 12-hour format for comparison
    ${start_12hr}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
    ${end_12hr}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}

    VAR    &{times}    start_time=${start_12hr}    end_time=${end_12hr}
    RETURN    ${times}

Verify Shifts On Review Fixed Shifts Page For Associate On Web
    [Documentation]    Verifies that shifts appear on correct days with correct times on Review Fixed Shifts page
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to verify (e.g., "Associate05, ") |
    ...    | shift_day_list | List of shift dictionaries from template data |
    ...    | copy_shift_config | Copy shift configuration used when creating shifts |
    ...    Example usage:
    ...    | Verify Shifts On Review Fixed Shifts Page For Associate On Web | Associate05,    | ${shift_day_list} | ${copy_shift_config} |
    [Arguments]    ${associate_name}    ${shift_day_list}    ${copy_shift_config}

    # Get all days that should have shifts
    ${shift_days}    Get Shift Days From Template Data On Web    ${shift_day_list}    ${copy_shift_config}

    # Get expected shift times
    ${expected_times}    Get Expected Shift Times From Template Data On Web    ${shift_day_list}
    ${expected_start}    Get From Dictionary    ${expected_times}    start_time
    ${expected_end}    Get From Dictionary    ${expected_times}    end_time

    Log    Verifying shifts for ${associate_name} on days: ${shift_days}
    Log    Expected times - Start: ${expected_start}, End: ${expected_end}

    # Verify each day has a shift with correct times
    FOR    ${day_index}    IN    @{shift_days}
        ${shift_bubble_locator}    Update Locator With Dynamic Values
        ...    ${REVIEW_FIXED_SHIFTS_ASSOCIATE_SHIFT_IN_DAY}    ASSOCIATE_NAME=${associate_name}
        ${shift_bubble_locator}    Update Locator With Dynamic Values
        ...    ${shift_bubble_locator}    DAY_INDEX=${day_index}

        Wait Until Element Is Visible On Webpage    ${shift_bubble_locator}    timeout=${MEDIUM_TIMEOUT}

        # Get and verify start time
        ${start_time_locator}    Update Locator With Dynamic Values
        ...    ${REVIEW_FIXED_SHIFTS_SHIFT_TIME_TEXT}    ASSOCIATE_NAME=${associate_name}
        ${start_time_locator}    Update Locator With Dynamic Values
        ...    ${start_time_locator}    DAY_INDEX=${day_index}

        ${actual_times}    Get Element Text On Webpage    ${start_time_locator}
        Should Contain    ${actual_times}    ${expected_start}
        ...    msg=Day ${day_index}: Expected start time ${expected_start} not found. Actual: ${actual_times}
        Should Contain    ${actual_times}    ${expected_end}
        ...    msg=Day ${day_index}: Expected end time ${expected_end} not found. Actual: ${actual_times}

        Log    ✓ Day ${day_index} verified: ${expected_start} - ${expected_end}
    END

    Log    Successfully verified ${expected_start} - ${expected_end} shifts on ${shift_days.__len__()} days

Regenerate Fixed Shift On Review Fixed Shift Page On Web
    [Documentation]    Keyword to perform regenerate fixed shift
    Click Element On Webpage    ${FIXEDSHIFT_REVIEW_REVIEWSHIFT_ACTION_ICON}
    Click Element On Webpage    ${FIXEDSHIFT_REVIEW_REVIEWSHIFT_ACTION_REGENERATE_WEEK}
    Click Element On Webpage    ${FIXEDSHIFT_REVIEW_REVIEWSHIFT_ACTION_ALERT_BUTTON}
    ${is_first_Progress_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${FIXEDSHIFT_REVIEW_REVIEWSHIFT_LOADING_PROGRESS_BAR}    timeout=${PAGE_LOAD_TIMEOUT}
    IF    ${is_first_Progress_visible}
        Wait Until Element Disappears On Webpage    ${FIXEDSHIFT_REVIEW_REVIEWSHIFT_LOADING_PROGRESS_BAR}    timeout=${PAGE_LOAD_TIMEOUT}
        Wait Until Page Is Loaded
    END
    Sleep    5s    # Added sleep to handle intermittent loading issues , needed as discussed with owner
    ${is_second_Progress_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${FIXEDSHIFT_REVIEW_REVIEWSHIFT_LOADING_PROGRESS_BAR}    timeout=${PAGE_LOAD_TIMEOUT}
    IF    ${is_second_Progress_visible}
        Wait Until Element Disappears On Webpage    ${FIXEDSHIFT_REVIEW_REVIEWSHIFT_LOADING_PROGRESS_BAR}    timeout=${PAGE_LOAD_TIMEOUT}
        Wait Until Page Is Loaded
    END

Navigate To Review Fixed Shifts Page And Regenerate The Latest Shift Times For Required Planning Week On Web
    [Documentation]    Navigate to Review Fixed Shifts Page and regenerate the latest shift times for Planning Week #2
    [Arguments]    ${planning_week_start_date}
    Navigate To Reviewed Fixed Shift Page On Web
    Select Week Number On Request Calendar Page On Web    ${planning_week_start_date}
    Regenerate Fixed Shift On Review Fixed Shift Page On Web

Select Week Number On Request Calendar Page On Web
    [Documentation]    select week number on request calendar page on web using week_day format
    ...    | =Arguments=    | =Description=    |
    ...    | week_day_input    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    [Arguments]    ${week_day_input}
    ${current_date}    Get Current Date
    ${year_result_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${current_year}    Convert Date    ${current_date}    result_format=${year_result_format}
    ${target_date}    Calculate Date From Week Day Offset    ${week_day_input}
    ${date_format_year_only}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${date_format_month_only}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${date_format}    Get Config Value    DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA
    ${target_year}    Convert Date    ${target_date}    result_format=${date_format_year_only}
    ${target_month_name}    Convert Date    ${target_date}    result_format=${date_format_month_only}
    ${target_day_formatted}    Convert Date    ${target_date}    result_format=${date_format}
    ${year_last_2_digits}    Evaluate    str('${target_year}')[2:]
    Wait Until Page Is Loaded
    # Use dynamic locator templates instead of hardcoded XPath
    Click Element On Webpage    ${FIXEDSHIFTSPAGE_CALENDAR_BUTTON}
    Click Element On Webpage    ${FIXEDSHIFTSPAGE_CALENDAR_MONTH_YEAR_HEADER}
    ${year_button_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_YEAR_BUTTON_BY_YEAR}    TARGET_YEAR=${target_year}
    ${is_element_present}    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${year_button_locator}
    IF    ${is_element_present}
        Click Element On Webpage    ${year_button_locator}
    ELSE
        ${year_button_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_YEAR_BUTTON_BY_YEAR}
        ...    TARGET_YEAR=${current_year}
        Click Element On Webpage    ${year_button_locator}
    END
    ${year_digits_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_YEAR_DIGITS_BY_LAST_TWO}
    ...    YEAR_LAST_2_DIGITS=${year_last_2_digits}
    Click Element On Webpage    ${year_digits_locator}
    ${month_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_MONTH_BUTTON_BY_NAME}    MONTH_NAME=${target_month_name}
    Click Element On Webpage    ${month_locator}
    ${day_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_DAY_BUTTON_BY_FORMATTED_DATE}
    ...    FORMATTED_DATE=${target_day_formatted}
    Wait Until Element Is Visible On Webpage    ${day_locator}
    ${week_number_locator}    Update Locator With Dynamic Values    ${FIXEDSHIFTSPAGE_WEEK_NUMBER_BUTTON}    DAY_LOCATOR=${day_locator}
    Click Element On Webpage    ${week_number_locator}
    Wait Until Page Is Loaded

Switch To Plan Status From Review Fixed Shifts Page On Web
    [Documentation]    Check if the schedule is published for the specified week in All Schedules page
    ${rail_road_button_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${FIXEDSHIFTS_RAILROAD_DROPDOWN_ICON_BUTTON}    timeout=${PAGE_LOAD_TIMEOUT}
    IF    ${rail_road_button_visible}
        Click Element On Webpage    ${FIXEDSHIFTS_RAILROAD_DROPDOWN_ICON_BUTTON}
        Click Element On Webpage    ${PLAN_STATUS_RAILROAD_DROPDOWN_ITEM}
        Wait Until Page Is Loaded
    ELSE
        Fail    No option to navigate found to navigate to Plan Status from Review Fixed Shifts Page
    END
    RETURN    ${rail_road_button_visible}

Select And Review Fixed Shift On Template Calendar Page On Web
    [Documentation]    Selects and reviews a fixed shift schedule on the template calendar page for a specific planning week start date
    ...    | =Arguments= | =Description= |
    ...    | planning_week_start_date | Planning week start date in week_day offset format (e.g., 1_1) used to locate the fixed shift schedule |
    [Arguments]    ${planning_week_start_date}
    ${actual_date}    Convert Week Day Offset To Date On Web    ${planning_week_start_date}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${selected_date}    Convert Date    ${actual_date}    result_format=${date_format}
    ${shift_schedule_locator}    Update Locator With Dynamic Values
    ...    ${FIXEDSHIFTS_TEMPLATE_CALENDAR_SHIFT_SCHEDULE_BY_DATE}    PLANNING_WEEK_START_DATE=${selected_date}
    Click Element On Webpage    ${shift_schedule_locator}
    Wait Until Page Is Loaded

Navigate To Plan Status Page From Review Fixed Shifts Page On Web
    [Documentation]    Navigates to Plan Status page from Review Fixed Shifts page
    ...    Attempts navigation via railroad dropdown, falls back to All Schedules navigation if unavailable
    ...    | =Arguments= | =Description= |
    ...    | planning_week_start_date | Planning week start date in week_day format (e.g., 1_1) |
    [Arguments]    ${planning_week_start_date}
    ${landed_on_plan_status_page}    Run Keyword And Return Status    Switch To Plan Status From Review Fixed Shifts Page On Web
    IF    not ${landed_on_plan_status_page}
        Navigate To All Schedule Page Switch To Plan Status Page For Given Planning Week On Web    ${planning_week_start_date}
    END

Delete All Existing Associate Templates For Associate On Web
    [Documentation]    Deletes all existing associate templates for a given associate to ensure a clean state before test execution
    ...    This keyword dynamically locates all delete icons for the associate's templates and deletes them one by one,
    ...    verifying API responses for each deletion
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate whose templates are to be deleted |
    [Arguments]    ${associate_name}
    ${temp_del_icon_locator}    Update Locator With Dynamic Values
    ...    ${REVIEW_FIXED_SHIFTS_EMP_TEMP_DELETE_ICONS}    ASSOCIATE_NAME=${associate_name}
    ${elements_count}    Get Element Count On Web Page    ${temp_del_icon_locator}
    IF    ${elements_count}
        Wait Until Element Is Visible On Webpage    (${temp_del_icon_locator})[1]
        ...    error_message=No delete icon found for ${associate_name}'s template
        Log    Found ${elements_count} existing templates for ${associate_name}. Deleting them to ensure a clean state.
        FOR    ${index}    IN RANGE    1    ${elements_count + 1}
            ${promise}    Promise To    Wait For Response    ${DELETE_ASSOCIATE_TEMPLATE_API_REGEX}
            Click Element On Webpage    (${temp_del_icon_locator})[1]
            ...    error_message=Failed to click delete icon for template ${index} of ${associate_name}
            Wait Until Element Is Visible On Webpage    ${ASSOCIATE_TEMPLATES_DELETE_CONFIRM}
            ...    error_message=Delete confirmation not visible for template ${index} of ${associate_name}
            Click Element On Webpage    ${ASSOCIATE_TEMPLATES_DELETE_CONFIRM}
            ...    error_message=Failed to confirm deletion for template ${index} of ${associate_name}
            ${response_body}    Wait For    ${promise}
            Log    ${response_body.body}
            Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
            Ensure Success Toast Notification Not Visible On Web
        END
        Log    Successfully deleted all existing templates for ${associate_name}
    END

Ensure Success Toast Notification Not Visible On Web
    [Documentation]    Ensures that a success toast notification is not visible on the webpage
    ${visible_toast_count}    Get Element Count On Web Page    ${FIXEDSHIFTS_NOTIFICATION_CLOSE_BTN}
    FOR    ${index}    IN RANGE    ${visible_toast_count}
        ${invert_index}    Evaluate    ${visible_toast_count} - ${index}
        Run Keyword And Ignore Error
        ...    Click Element On Webpage    (${FIXEDSHIFTS_NOTIFICATION_CLOSE_BTN})[${invert_index}]
    END

Click On Add Template Button In Corporate Fixed Shifts Page On Web
    [Documentation]    Clicks on the "Add Template" button in the Corporate Fixed Shifts page to initiate the process of creating a new associate template
    Click Element On Webpage    ${FIXEDSHIFTS_ADD_TEMPLATE_BTN}
    ...    error_message=Failed to click on Add Template button in Corporate Fixed Shifts page
    Wait Until Element Is Visible On Webpage    ${FIXEDSHIFTS_ADD_TEMPLATE_SAVE_BTN}
    ...    error_message=Add Template Save button not visible after clicking Add Template button in Corporate Fixed Shifts page
    Capture Screenshot On Webpage

Apply Reverse Fiscal Day Conversion To Parsed Shifts On Web
    [Documentation]    Applies reverse fiscal day conversion to all shifts in parsed shift list.
    ...    Converts day_number field in each shift dictionary from fiscal week format back to original format.
    ...    | =Arguments= | =Description= |
    ...    | parsed_shifts | List of shift dictionaries containing 'day_number' field to be converted. |
    ...    | =Returns= | =Description= |
    ...    | converted_shifts | List of shift dictionaries with reversed day_number values. |
    [Arguments]    ${parsed_shifts}
    VAR    @{converted_shifts}    @{EMPTY}
    FOR    ${shift}    IN    @{parsed_shifts}
        ${original_day_num}    Reverse Day Number Based On Fiscal Week Start Day On Web    ${shift}[day_number]
        ${shift_copy}    Copy Dictionary    ${shift}
        Set To Dictionary    ${shift_copy}    day_number    ${original_day_num}
        Append To List    ${converted_shifts}    ${shift_copy}
        Log    Converted shift - Original fiscal day: ${shift}[day_number], Reversed day: ${original_day_num}
    END
    RETURN    ${converted_shifts}
