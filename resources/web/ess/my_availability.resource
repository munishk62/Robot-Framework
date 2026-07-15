*** Settings ***
Documentation       Resource file containing keywords for ESS (Employee Self Service) My Availability page.

Library             DateTime
Library             test_data/TestDataLibrary.py
Variables           resources/web/ess/my_availability_page.py
Variables           resources/web/common/menu_page.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/common_date_utility.resource
Resource            resources/web/common/request_calendar_utility.resource


*** Keywords ***
Navigate To ESS My Availability Page
    [Documentation]    Navigate To ESS -> My Availability Page
    Navigate To Specific Page On Web    ess    my_availability

Add Availability Request On My Availability Page On Web
    [Documentation]    Add ESS My Availability Request on My Availability page.
    ...    | =Arguments= | =Description= |
    ...    | week_date_offset | The week start date for the availability request in offset date format (e.g. 1_1). |
    ...    | preference | The availability preference to select (e.g., "Permanent"). |
    ...    | reason | The reason for the availability request. |
    ...    | availability_data | Availability request data template name from template file. |
    [Arguments]    ${week_date_offset}
    ...    ${preference}
    ...    ${reason}
    ...    ${availability_data}
    ${is_week_start_applicable}    Fill My Availability Request Fields On My Availability Page On Web
    ...    ${week_date_offset}    ${preference}    ${reason}
    Fill Availability Request Weekly Data From Template On My Availability Page On Web    ${availability_data}
    Submit Availability Request On My Availability Page On Web
    Check And Click If Previous Button Is Visible On My Availability Page On Web
    RETURN    ${is_week_start_applicable}

Edit Weekly Data In Availability Request On My Availability Page On Web
    [Documentation]    Edit ESS My Availability Request on My Availability page.
    ...    | =Arguments= | =Description= |
    ...    | effective_date | The week start date for the availability request in offset date format (e.g. 1_1). |
    ...    | availability_data | Availability request data template name from template file. |
    ...    | week_start_applicable | Boolean flag indicating if the week start date field is applicable for the availability request. |
    [Arguments]    ${effective_date}    ${availability_data}    ${week_start_applicable}=False
    Click And Open Availability Request On My Availability Page On Web    ${effective_date}    ${week_start_applicable}
    Fill Availability Request Weekly Data From Template On My Availability Page On Web    ${availability_data}
    Submit Availability Request On My Availability Page On Web
    Check And Click If Previous Button Is Visible On My Availability Page On Web

Click Add Button On My Availability Page On Web
    [Documentation]    Clicks on the "Add Request" button on the ESS My Availability page.
    Click Element On Webpage    ${ESS_MY_AVAILABILITY_PAGE_ADD_BUTTON}
    ...    error_message=Add Request button not found or not clickable on My Availability page.

Fill My Availability Request Fields On My Availability Page On Web
    [Documentation]    Fill dropdown and date fields of ESS My Availability Request.
    ...    | =Arguments= | =Description= |
    ...    | week_date_offset | The week start date for the availability request in offset date format (e.g. 1_1). |
    ...    | preference | The availability preference to select (e.g., "Permanent"). |
    ...    | reason | The reason for the availability request. |
    [Arguments]    ${week_date_offset}    ${preference}    ${reason}
    ${year_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    Click Add Button On My Availability Page On Web
    Wait For Load State    domcontentloaded    timeout=${LONG_TIMEOUT}
    Wait Until Loading Icon Disappears On My Availability Page On Web
    Wait Until Element Is Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_PREFERENCE}
    ...    error_message=Preference dropdown not found on My Availability page after clicking Add Request button.
    Select List Item On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_PREFERENCE}    index    0
    Wait Until Loading Icon Disappears On My Availability Page On Web    loader_timeout=${SHORT_TIMEOUT}
    Select List Item On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_PREFERENCE}    text    ${preference}
    Wait Until Loading Icon Disappears On My Availability Page On Web
    ${week_end_field_disappears}    Run Keyword And Return Status    Wait Until Element Disappears On Webpage
    ...    ${ESS_MY_AVAILABILITY_PAGE_WEEK_END_INPUT}    timeout=${MEDIUM_TIMEOUT}
    ${week_start_field_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER}    timeout=${SHORT_TIMEOUT}
    IF    ${week_start_field_visible}
        ${start_date_selected}    Select Date From Date Picker On My Availability Page On Web
        ...    ${ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER}    ${week_date_offset}
        Log    Selected week start date: ${start_date_selected}
        IF    not ${week_end_field_disappears}
            Wait Until Loading Icon Disappears On My Availability Page On Web
            ${end_date_calculated}    Add Time To Date    ${start_date_selected}    6 days    date_format=${date_format}
            ...    result_format=${date_format}
            ${end_date_selected}    Get Text    ${ESS_MY_AVAILABILITY_PAGE_WEEK_END_INPUT}
            ...    message=End date input field not found or not visible after selecting start date on My Availability page.
            Should Be Equal    ${end_date_selected}    ${end_date_calculated}
            ...    msg=End date ${end_date_selected} does not match expected ${end_date_calculated} based on selected start date ${start_date_selected}.
        END
    ELSE
        Wait Until Element Is Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_YEAR}
        ...    error_message=Year dropdown not found on My Availability page for week-based availability requests.
        ${year_result}    Get Fiscal Year For Date From DB    ${week_date_offset}
        ${year_length}    Get Length    ${year_result}
        IF    ${year_length} > 0
            VAR    ${year}    ${year_result}
        ELSE
            ${year}    Calculate Date From Week Day Offset    ${week_date_offset}    date_format=${year_format}
        END
        Select List Item On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_YEAR}    text    ${year}

        Wait Until Element Is Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK}
        ...    error_message=Week dropdown not found on My Availability page for week-based availability requests.
        ${week_start_date}    Calculate Date From Week Day Offset    ${week_date_offset}    date_format=${date_format}
        Select List Item On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK}    text    ${week_start_date}
    END
    ${is_reason_field_visible}    Is Element Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_AVAILABILITY_REASON}
    IF    ${is_reason_field_visible}
        Select List Item On Webpage    ${ESS_MY_AVAILABILITY_PAGE_AVAILABILITY_REASON}    text    ${reason}
    END
    Click Element On Webpage    ${ESS_MY_AVAILABILITY_PAGE_TOTALLY_AVAILABLE_BUTTON}
    ...    error_message=Totally Available button not found or not clickable on My Availability page after filling availability request fields.
    RETURN    ${week_start_field_visible}

Select Date From Date Picker On My Availability Page On Web
    [Documentation]    Selects the start date for availability on the ESS My Availability page using the date picker.
    ...    | =Arguments= | =Description= |
    ...    | field_locator | The locator for the week start date input field which triggers the date picker when clicked. |
    ...    | week_date_offset | The week start date for the availability request in offset date format (e.g. 1_1). |
    [Arguments]    ${field_locator}    ${week_date_offset}
    VAR    ${month_format}    %b    # Since not available in configs, have declared here. Can be updated once added to configs.
    ${year_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${calendar_date_format}    Get Config Value    DATE_FMT_DAY_NON_ZERO_PADDED
    ${month}    Calculate Week Start Date From Week Day Offset    ${week_date_offset}    date_format=${month_format}
    ${year}    Calculate Week Start Date From Week Day Offset    ${week_date_offset}    date_format=${year_format}
    ${week_start_date}    Calculate Week Start Date From Week Day Offset    ${week_date_offset}    date_format=${calendar_date_format}
    Wait Until Element Is Visible On Webpage    ${field_locator}
    ...    error_message=Week start date input field not found or not visible on My Availability page.
    Click Element On Webpage    ${field_locator}    error_message=Unable to click on week start date input field on My Availability page.
    Wait Until Element Is Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER_YEAR}
    ...    error_message=Week start date picker year dropdown not found on My Availability page.
    Select List Item On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER_YEAR}    text    ${year}
    Select List Item On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER_MONTH}    text    ${month}
    ${date_locator}    Update Locator With Dynamic Values    ${ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER_DATE}
    ...    DATE=${week_start_date}
    Click Element On Webpage    ${date_locator}
    ...    error_message=Unable to select week start date ${week_start_date} from date picker on My Availability page.
    ${date_selected}    Get Text    ${ESS_MY_AVAILABILITY_PAGE_WEEK_START_INPUT}
    ...    message=Week start date input field not found or not visible after selecting date from date picker on My Availability page.
    RETURN    ${date_selected}

Fill Availability Request Weekly Data From Template On My Availability Page On Web
    [Documentation]    Fills in availability request weekly data from template on the ESS My Availability page.
    ...    | =Arguments= | =Description= |
    ...    | availability_request_data | Key to retrieve availability request data from template file. |
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
            Disable Days For Availability Rotation On My Availability Page On Web    ${rotation_num}    @{disabled_days}
        ELSE
            Log    No disabled days for rotation ${rotation_num}
        END
        ${availabilities}    Get From Dictionary    ${rotation_data}    availabilities
        ${availabilities_length}    Get Length    ${availabilities}
        IF    ${availabilities_length} > 0
            Select Values In Week Availability Rows On My Availability Page On Web    ${rotation_num}    @{availabilities}
        ELSE
            Log    No availability rows to populate for rotation ${rotation_num}
        END
    END

Disable Days For Availability Rotation On My Availability Page On Web
    [Documentation]
    ...    Marks specified days (1=Sun .. 7=Sat) disabled for a rotation by toggling checkboxes.
    ...    | =Arguments= | =Description= |
    ...    | rotation_num | Rotation number to disable days for (e.g. 1). |
    ...    | day_numbers | List of day numbers to disable (1=Sun .. 7=Sat). |
    [Arguments]    ${rotation_num}    @{day_numbers}
    FOR    ${day}    IN    @{day_numbers}
        ${day_string}    Convert To String    ${day}
        ${adjusted_day}    Get Day Number Based On Fiscal Week Start Day On Web    ${day_string}
        ${actual_day}    Convert To Integer    ${adjusted_day}
        ${actual_disabled_day}    Evaluate    ${actual_day} + 1
        ${actual_disabled_day_string}    Convert To String    ${actual_disabled_day}

        ${rotation_string}    Convert To String    ${rotation_num}
        ${checkbox_locator}    Update Locator With Dynamic Values
        ...    ${ESS_MY_AVAILABILITY_PAGE_NOT_AVAILABLE_CHECKBOX}
        ...    DAY=${actual_disabled_day_string}    ROTATION=${rotation_string}
        Click Element On Webpage    ${checkbox_locator}
        Log    Disabled day ${day} for rotation ${rotation_num}
    END

Select Values In Week Availability Rows On My Availability Page On Web
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
        Select Value In Specific Availability Row On My Availability Page On Web
        ...    ${rotation_num}
        ...    ${avail_row}
        ...    ${days_map}
    END

Select Value In Specific Availability Row On My Availability Page On Web
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
            ${is_12_hour_format}    Get Config Value    TIME_FORMAT_12_HRS
            IF    not ${is_12_hour_format}
                ${start_time}    Convert Time From 12 Hour To 24 Hour Format For Web    ${start_time}
                ${end_time}    Convert Time From 12 Hour To 24 Hour Format For Web    ${end_time}
            END
            ${day_num_string_actual}    Convert To String    ${day_num}
            ${day_num_for_not_available_check}    Get Day Number Based On Fiscal Week Start Day On Web    ${day_num_string_actual}
            ${rotation_num_string}    Convert To String    ${rotation_num}
            ${avail_row_string}    Convert To String    ${avail_row}
            ${actual_day}    Convert To Integer    ${day_num_for_not_available_check}
            ${actual_disabled_day}    Evaluate    ${actual_day} + 1
            ${actual_disabled_day_string}    Convert To String    ${actual_disabled_day}

            ${not_available_day_locator}    Update Locator With Dynamic Values
            ...    ${ESS_MY_AVAILABILITY_PAGE_NOT_AVAILABLE_CHECKBOX_CHECKED}
            ...    DAY=${actual_disabled_day_string}    ROTATION=${rotation_num_string}
            ${is_disabled_day_checked}    Is Element Visible On Webpage    ${not_available_day_locator}
            IF    ${is_disabled_day_checked}
                ${checkbox_locator}    Update Locator With Dynamic Values
                ...    ${ESS_MY_AVAILABILITY_PAGE_NOT_AVAILABLE_CHECKBOX}
                ...    DAY=${actual_disabled_day_string}    ROTATION=${rotation_num_string}
                Click Element On Webpage    ${checkbox_locator}
            END
            ${day_num_string}    Convert To String    ${day_num}
            ${start_locator}    Update Locator With Dynamic Values
            ...    ${ESS_MY_AVAILABILITY_PAGE_SELECT_DAY_START}
            ...    DAY=${day_num_string}    ROTATION=${rotation_num_string}    AVAIL=${avail_row_string}
            ${end_locator}    Update Locator With Dynamic Values
            ...    ${ESS_MY_AVAILABILITY_PAGE_SELECT_DAY_END}
            ...    DAY=${day_num_string}    ROTATION=${rotation_num_string}    AVAIL=${avail_row_string}
            Wait Until Element Is Visible On Webpage    ${start_locator}    timeout=${MEDIUM_TIMEOUT}
            IF    not ${is_12_hour_format} and '${start_time}' == '00:00'
                TRY
                    Select List Item On Webpage    ${start_locator}    text    ${start_time}
                EXCEPT
                    Select List Item On Webpage    ${start_locator}    text    24:00
                END
            ELSE
                Select List Item On Webpage    ${start_locator}    text    ${start_time}
            END
            IF    not ${is_12_hour_format} and '${end_time}' == '00:00'
                TRY
                    Select List Item On Webpage    ${end_locator}    text    ${end_time}
                EXCEPT
                    Select List Item On Webpage    ${end_locator}    text    24:00
                END
            ELSE
                Select List Item On Webpage    ${end_locator}    text    ${end_time}
            END
            Log    Rotation ${rotation_num} / Availability ${avail_row} / Day ${day_num}: ${start_time}-${end_time}
        END
    END

Verify Success Notification Toast On ESS My Availability Page On Web
    [Documentation]    Verifies the notification toast message on the ESS My Availability page.
    Wait Until Element Is Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SUCCESS_NOTIFICATION}    timeout=${MEDIUM_TIMEOUT}
    Wait Until Element Disappears On Webpage    ${ESS_MY_AVAILABILITY_PAGE_SUCCESS_NOTIFICATION}

Submit Availability Request On My Availability Page On Web
    [Documentation]    Submits the availability request on the ESS My Availability page.
    Click Element On Webpage    ${ESS_MY_AVAILABILITY_PAGE_AVAILABILITY_SUBMIT_BUTTON}
    Verify Success Notification Toast On ESS My Availability Page On Web
    Capture Screenshot On Webpage

Click And Open Availability Request On My Availability Page On Web
    [Documentation]    Clicks and opens an availability request on the ESS My Availability page as ESS user.
    ...    | =Arguments= | =Description= |
    ...    | effective_date_offset | The week start date for the availability request in offset date format (e.g. 1_1). |
    ...    | week_start_applicable | Boolean flag indicating if the week start date field is applicable for the availability request. |
    [Arguments]    ${effective_date_offset}    ${week_start_applicable}=False
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    IF    ${week_start_applicable}
        ${effective_date}    Calculate Week Start Date From Week Day Offset    ${effective_date_offset}    date_format=${date_format}
    ELSE
        ${effective_date}    Calculate Date From Week Day Offset    ${effective_date_offset}    date_format=${date_format}
    END
    ${effective_date_link}    Update Locator With Dynamic Values    ${ESS_MY_AVAILABILITY_PAGE_EFFECTIVE_DATE_LINK}
    ...    EFFECTIVE_DATE=${effective_date}
    Click Element On Webpage    ${effective_date_link}
    ...    error_message=Availability request with effective date ${effective_date} not found or not clickable on My Availability page.
    Wait Until Element Is Present On Webpage    ${ESS_MY_AVAILABILITY_PAGE_TOTALLY_AVAILABLE_BUTTON}
    ...    error_message=Totally Available button not found on opened availability request.

Delete Availability Request On My Availability Page On Web
    [Documentation]    Deletes an availability request on the ESS My Availability page as ESS user.
    ...    | =Arguments= | =Description= |
    ...    | effective_date_offset | The week start date for the availability request in offset date format (e.g. 1_1). |
    ...    | week_start_applicable | Boolean flag indicating if the week start date field is applicable for the availability request. |
    [Arguments]    ${effective_date_offset}    ${week_start_applicable}=False
    Click And Open Availability Request On My Availability Page On Web    ${effective_date_offset}    ${week_start_applicable}
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${ESS_MY_AVAILABILITY_PAGE_DELETE_BUTTON}
    ...    error_message=Delete button not found or not clickable for availability request with effective date offset ${effective_date_offset}
    Wait For    ${promise}
    Verify Success Notification Toast On ESS My Availability Page On Web

Cleanup Existing Availability Requests On My Availability Page On Web
    [Documentation]    Cleans up existing availability requests on My Availability page as ESS user.
    ...    | =Arguments= | =Description= |
    ...    | effective_date_offsets | List of effective date offsets for availability requests to delete. |
    [Arguments]    @{effective_date_offsets}
    VAR    @{effective_date_offsets_pending}    @{EMPTY}
    ${prefix}    Set Selector Prefix    ${None}
    FOR    ${eff_date}    IN    @{effective_date_offsets}
        ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
        ${effective_date}    Calculate Date From Week Day Offset    ${eff_date}    date_format=${date_format}
        ${effective_date_link}    Update Locator With Dynamic Values    ${ESS_MY_AVAILABILITY_PAGE_EFFECTIVE_DATE_LINK}
        ...    EFFECTIVE_DATE=${effective_date}
        ${is_request_present}    Is Element Visible On Webpage    ${effective_date_link}
        IF    ${is_request_present}
            Set Selector Prefix    ${prefix}
            Delete Availability Request On My Availability Page On Web    ${eff_date}
        ELSE
            Append To List    ${effective_date_offsets_pending}    ${eff_date}
        END
    END
    # check and clear for week start date based requests if week start date field is applicable
    FOR    ${eff_date}    IN    @{effective_date_offsets_pending}
        ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
        ${week_start_date}    Calculate Week Start Date From Week Day Offset    ${eff_date}    ${date_format}
        ${effective_date_link}    Update Locator With Dynamic Values    ${ESS_MY_AVAILABILITY_PAGE_EFFECTIVE_DATE_LINK}
        ...    EFFECTIVE_DATE=${week_start_date}
        ${is_request_present}    Is Element Visible On Webpage    ${effective_date_link}
        IF    ${is_request_present}
            Set Selector Prefix    ${prefix}
            Delete Availability Request On My Availability Page On Web    ${eff_date}    week_start_applicable=True
        END
    END
    Set Selector Prefix    ${prefix}

Check And Click If Previous Button Is Visible On My Availability Page On Web
    [Documentation]    Checks if the Previous button is visible on the ESS My Availability page and clicks it if present.
    ${is_previous_button_visible}    Is Element Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_PREVIOUS_BUTTON}
    IF    ${is_previous_button_visible}
        Click Element On Webpage    ${ESS_MY_AVAILABILITY_PAGE_PREVIOUS_BUTTON}
        ...    error_message=Previous button not found or not clickable on My Availability page.
        Wait Until Page Is Loaded
    END

Wait Until Loading Icon Disappears On My Availability Page On Web
    [Documentation]    Waits until the page loading indicator disappears on the ESS My Availability page.
    [Arguments]    ${loader_timeout}=${LONG_TIMEOUT}
    ${loading_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${ESS_MY_AVAILABILITY_PAGE_LOADING_ICON}    timeout=${loader_timeout}
    IF    ${loading_visible}
        Wait Until Element Disappears On Webpage    ${ESS_MY_AVAILABILITY_PAGE_LOADING_ICON}    timeout=${loader_timeout}
    END

Click On First Availability Request Effective Date Link On My Availability Page On Web
    [Documentation]    Clicks on the effective date link of the first availability request listed on the ESS My Availability page.
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_FIRST_EFFECTIVE_DATE_LINK}
    ...    timeout=${SHORT_TIMEOUT}
    ${is_element_visible}    Is Element Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_FIRST_EFFECTIVE_DATE_LINK}
    IF    not ${is_element_visible}
        Log    Effective date link for the first availability request not found or not visible on My Availability page.
        Capture Screenshot On Webpage
        RETURN
    END
    Click Element On Webpage    ${ESS_MY_AVAILABILITY_PAGE_FIRST_EFFECTIVE_DATE_LINK}
    ...    error_message=Effective date link for the first availability request not found or not clickable on My Availability page.
    Wait Until Element Is Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_PREVIOUS_BUTTON}
    ...    error_message=Previous button not found on Employee Self Service page, page may not have loaded properly after clicking effective date link on My Availability page.
    Capture Screenshot On Webpage

Click On Filter Icon On My Availability Page On Web
    [Documentation]    Clicks on the filter icon on the ESS My Availability page to open the filter menu.
    Click Element On Webpage    ${ESS_MY_AVAILABILITY_PAGE_FILTER_ICON}
    ...    error_message=Filter icon not found or not clickable on My Availability page.
    Wait Until Element Is Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_FILTER_MENU}
    ...    error_message=Filter menu not visible after clicking filter icon on My Availability page.
    Capture Screenshot On Webpage

Click On Add Availability Icon On My Availability Page On Web
    [Documentation]    Clicks on the "Add Availability" icon on the ESS My Availability page to start creating a new availability request.
    Click Element On Webpage    ${ESS_MY_AVAILABILITY_PAGE_ADD_AVAILABILITY_ICON}
    ...    error_message=Add Availability icon not found or not clickable on My Availability page.
    Wait Until Element Is Visible On Webpage    ${ESS_MY_AVAILABILITY_PAGE_PREVIOUS_BUTTON}
    ...    error_message=Previous button not visible after clicking Add Availability icon on My Availability page.
    Capture Screenshot On Webpage
