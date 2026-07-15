*** Settings ***
Documentation       Employee Roster page related keyword implementation

Resource            resources/web/common/common.resource
Variables           resources/web/rws/employee/roster_page.py
Resource            resources/web/common/util_keywords.resource
Library             resources/web/common/utility.py
Variables           resources/web/rws/employee/roster_api.py
Variables           resources/web/common/status_codes.py


*** Keywords ***
Navigate To RWS Employee Roster Page On Web
    [Documentation]    Navigate To RWS -> Employee -> Roster Page
    ...    and verifies roster heading at the top of the page
    Navigate To Specific Page On Web    rws    employee    roster
    ${reporting_hierarchy_enabled}    Get Config Value    key=ENABLE_REPORTING_HIERARCHY
    IF    '${reporting_hierarchy_enabled}' == "Y"
        ${reportee_type}    Get System Value    ReporteeType    MY_LOCATION
        Apply Filter With Associate Criteria On Roster Page On Web
        ...    reportee_type=${reportee_type}
    END

Get First Employee Details On Roster Page On Web
    [Documentation]    This keyword returns first employee details on Employee Roster Page
    ${emp_name}    Get Element Text On Webpage    ${ROSTER_PAGE_FIRST_EMP_NAME}
    ${emp_id}    Get Element Text On Webpage    ${ROSTER_PAGE_FIRST_EMP_ID}
    Capture Screenshot On Webpage
    RETURN    ${emp_name}    ${emp_id}

Click On First Employee Name On Roster Page On Web
    [Documentation]    This keyword clicks on the first employee on the Roster page
    Click Element On Webpage    ${ROSTER_PAGE_FIRST_EMP_NAME}
    Wait Until Page Is Loaded

Navigate To Employee Basic Details Page On Web
    [Documentation]    This keyword helps to navigate to Employee Basic Details page
    Click Element On Webpage    ${ROSTER_PAGE_SUMMARY_DROPDOWN}
    Click Element On Webpage    ${ROSTER_PAGE_BASIC_DETAILS_MENU}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Verify Employee Basic Details On Roster Page On Web
    [Documentation]    This keyword verifies emp data data on Basic Details page
    [Arguments]    ${emp_name}    ${emp_id}
    Capture Screenshot On Webpage
    ${is_display_name_visible}    Is Element Visible On Webpage    ${ROSTER_PAGE_BASIC_EMP_NAME}
    IF    ${is_display_name_visible}
        ${basic_emp_name}    Get Element Text On Webpage    ${ROSTER_PAGE_BASIC_EMP_NAME}
        Should Be Equal    ${emp_name}    ${basic_emp_name}
    END
    ${basic_emp_id}    Get Element Text On Webpage    ${ROSTER_PAGE_BASIC_EMP_ID}
    ${basic_doj}    Get Element Text On Webpage    ${ROSTER_PAGE_BASIC_EMP_DOJ}
    Should Be Equal    ${emp_id}    ${basic_emp_id}
    Should Not Be Empty    ${basic_doj}

Apply Filter On First Name On Roster Page On Web
    [Documentation]    This keyword applies filter on Employee First Name on Roster homepage
    [Arguments]    ${first_name}    ${emp_id}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_ICON}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_FIRST_NAME_TXT}
    Fill Textbox On Webpage    ${ROSTER_PAGE_FILTER_FIRST_NAME_TXT}    ${first_name}
    Fill Textbox On Webpage    ${ROSTER_PAGE_FILTER_ID_TXT}    ${emp_id}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_APPLY_BTN}
    Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_SPINNER_ICON}
    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_FIRST_EMP_NAME}
    ${emp_name}    Get Element Text On Webpage    ${ROSTER_PAGE_FIRST_EMP_NAME}
    ${emp_id}    Get Element Text On Webpage    ${ROSTER_PAGE_FIRST_EMP_ID}
    Capture Screenshot On Webpage
    RETURN    ${emp_name}    ${emp_id}

Click On Filter Icon On Roster Page On Web
    [Documentation]    Clicks on the filter icon to open filter panel on Roster page
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_ICON}
    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_FILTER_ID_TXT}
    Capture Screenshot On Webpage

Filter By Employee ID On Roster Page On Web
    [Documentation]    Fills the employee ID in the filter ID textbox on Roster page
    ...    | =Arguments= | =Description= |
    ...    | emp_id | Employee ID to filter by |
    ...    Example usage:
    ...    | Filter By Employee ID On Roster Page On Web | 12345 |
    [Arguments]    ${emp_id}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_ID_TXT}
    Clear Textbox On Webpage    ${ROSTER_PAGE_FILTER_ID_TXT}
    Fill Textbox On Webpage    ${ROSTER_PAGE_FILTER_ID_TXT}    ${emp_id}
    Capture Screenshot On Webpage

Select Associate Type Filter On Roster Page On Web
    [Documentation]    Selects associate type from the filter dropdown on Roster page
    ...    Associate types are resolved by data provider from template constants
    ...    This is a multi-select dropdown - it clears existing selections before selecting the specified type
    ...    | =Arguments= | =Description= |
    ...    | associate_type | Resolved associate type value from template (e.g., "FT - Full Time") |
    ...    Example usage:
    ...    | ${filter_data}=    Get Roster Filter Data    template_name=filter_criteria_3 |
    ...    | Select Associate Type Filter On Roster Page On Web | ${filter_data}[associate_type] |
    [Arguments]    ${associate_type}

    Click Element On Webpage    ${ROSTER_PAGE_FILTER_ASSOCIATE_TYPE_DROPDOWN}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_ASSOCIATE_TYPE_DROPDOWN_NONE_SELECT}
    # Use the resolved AssociateType value directly to match the dropdown option text
    ${associate_type_option}    Update Locator With Dynamic Values    ${ROSTER_PAGE_FILTER_ASSOCIATE_TYPE_OPTION}
    ...    ASSOCIATE_TYPE_XPATH=contains(text(), '${associate_type}')
    Click Element On Webpage    ${associate_type_option}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_ASSOCIATE_TYPE_DROPDOWN}
    Capture Screenshot On Webpage

Select Employment Status Filter On Roster Page On Web
    [Documentation]    Selects employment status from the filter dropdown on Roster page
    ...    Employment statuses are resolved by data provider from template constants
    ...    This is a multi-select dropdown - it clears existing selections before selecting the specified status
    ...    | =Arguments= | =Description= |
    ...    | status | Resolved employment status value from template (e.g., "Active") |
    ...    Example usage:
    ...    | ${filter_data}=    Get Roster Filter Data    template_name=filter_criteria_4 |
    ...    | Select Employment Status Filter On Roster Page On Web | ${filter_data}[status] |
    [Arguments]    ${status}

    Click Element On Webpage    ${ROSTER_PAGE_FILTER_STATUS_DROPDOWN}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_STATUS_DROPDOWN_NONE_SELECT}
    ${status_option}    Update Locator With Dynamic Values    ${ROSTER_PAGE_FILTER_STATUS_OPTION}    STATUS=${status}
    Click Element On Webpage    ${status_option}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_STATUS_DROPDOWN}
    Capture Screenshot On Webpage

Select Reportee Type Filter On Roster Page On Web
    [Documentation]    Selects reportee type radio button on Roster page filter.
    ...    Reportee types are resolved by data provider from template constants.
    ...    This is a radio button selection - only one can be selected at a time.
    ...    Note: This keyword assumes reportee filter is available.
    ...    Use "Is Reportee Filter Available On Roster Page On Web" to check first.
    ...    | =Arguments= | =Description= |
    ...    | reportee_type | Resolved reportee type value from template (e.g., "Direct", "Indirect", "My Location") |
    ...    Example usage:
    ...    | ${filter_data}=    Get Roster Filter Data    template_name=filter_criteria_5 |
    ...    | Select Reportee Type Filter On Roster Page On Web    ${filter_data}[reportee_type] |
    [Arguments]    ${reportee_type}

    # Map resolved values to locators
    ${reportee_type_my_location}    Get System Value    ReporteeType    MY_LOCATION
    ${reportee_type_direct}    Get System Value    ReporteeType    DIRECT
    ${reportee_type_indirect}    Get System Value    ReporteeType    INDIRECT

    IF    '${reportee_type}' == '${reportee_type_direct}'
        Click Element On Webpage    ${ROSTER_PAGE_FILTER_REPORTEE_TYPE_DIRECT}
    ELSE IF    '${reportee_type}' == '${reportee_type_indirect}'
        Click Element On Webpage    ${ROSTER_PAGE_FILTER_REPORTEE_TYPE_INDIRECT}
    ELSE IF    '${reportee_type}' == '${reportee_type_my_location}'
        Click Element On Webpage    ${ROSTER_PAGE_FILTER_REPORTEE_TYPE_MY_LOCATION}
    ELSE
        Fail    Invalid reportee type: ${reportee_type}. Valid values are: Direct, Indirect, My Location
    END

    Log    Selected reportee type filter: ${reportee_type}    level=INFO
    Capture Screenshot On Webpage

Is Reportee Filter Available On Roster Page On Web
    [Documentation]    Checks if reportee filter is available and which options are present
    ...    This keyword opens filter panel once, checks reportee dropdown and all options, then closes panel
    ...    Returns a dictionary with: available (bool), direct (bool), indirect (bool), my_location (bool)
    ...    This is typically used to conditionally execute reportee-related filter tests
    ...    Example usage:
    ...    | ${reportee_info}=    Is Reportee Filter Available On Roster Page On Web |
    ...    | IF    ${reportee_info}[available] and ${reportee_info}[direct] |
    ...    |    Apply Filter With Associate Criteria On Roster Page On Web... |
    ...    | END |

    # Open filter panel ONCE
    Click On Filter Icon On Roster Page On Web

    # Check if reportee filter dropdown is present
    ${reportee_available}    Is Element Present On Webpage    ${ROSTER_PAGE_REPORTEE_DROPDOWN}

    # If reportee filter is available, check which options are present
    IF    ${reportee_available}
        ${direct_available}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_FILTER_REPORTEE_TYPE_DIRECT}
        ${indirect_available}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_FILTER_REPORTEE_TYPE_INDIRECT}
        ${my_location_available}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_FILTER_REPORTEE_TYPE_MY_LOCATION}
        Log
        ...    Reportee filter available - Direct: ${direct_available}, Indirect: ${indirect_available}, My Location: ${my_location_available}
    ELSE
        # If reportee filter not available, set all options to False
        VAR    ${direct_available}    ${False}
        VAR    ${indirect_available}    ${False}
        VAR    ${my_location_available}    ${False}
        Log    Reportee filter not available - Reporting hierarchy not enabled (PC00067)    level=WARN
    END

    # Close filter panel by clicking Reset
    Apply Filter On Roster Page On Web

    # Return comprehensive dictionary
    VAR    &{reportee_info}
    ...    available=${reportee_available}
    ...    direct=${direct_available}
    ...    indirect=${indirect_available}
    ...    my_location=${my_location_available}

    RETURN    ${reportee_info}

Get Available Reportee Type Options On Roster Page On Web
    [Documentation]    **DEPRECATED** - Use "Is Reportee Filter Available On Roster Page On Web" instead
    ...    This keyword is kept for backward compatibility but will be removed in future versions
    ...    The new keyword returns all information in one call
    Log    WARNING: This keyword is deprecated. Use 'Is Reportee Filter Available On Roster Page On Web' instead    level=WARN
    ${reportee_info}    Is Reportee Filter Available On Roster Page On Web
    # Return just the options part for backward compatibility
    VAR    &{options}
    ...    direct=${reportee_info}[direct]
    ...    indirect=${reportee_info}[indirect]
    ...    my_location=${reportee_info}[my_location]
    RETURN    ${options}

Reset Filter On Roster Page On Web
    [Documentation]    Clicks the reset button to clear all applied filters on Roster page
    ...    After reset, automatically clicks Apply to load the page with reset filters
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_RESET_BTN}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_APPLY_BTN}
    Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_SPINNER_ICON}
    Capture Screenshot On Webpage

Apply Filter On Roster Page On Web
    [Documentation]    Clicks the apply button to apply selected filters on Roster page
    ...    Ensures filter panel is open before clicking Apply

    # Check if Apply button is currently visible (filter panel open)
    ${apply_button_visible}    Is Element Visible On Webpage    ${ROSTER_PAGE_FILTER_APPLY_BTN}

    # If Apply button not visible, filter panel is closed - open it
    IF    not ${apply_button_visible}
        Log    Filter panel is closed, opening it before applying filters    level=DEBUG
        Click Element On Webpage    ${ROSTER_PAGE_FILTER_ICON}
        Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_FILTER_APPLY_BTN}    timeout=5s
    END

    # Add small delay to ensure filter panel is fully rendered
    Sleep    0.5s    # needed as discussed with owner to avoid intermittent issues

    # Click Apply button
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_APPLY_BTN}

    # Wait for page to process the filter
    Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_SPINNER_ICON}
    Capture Screenshot On Webpage

Verify Filtered Associate Data Is Displayed On Roster Page On Web
    [Documentation]    Verifies that the filtered associate row is displayed with the specified associate details
    ...    This keyword dynamically builds the XPath based on associate name, ID, and type to verify filter results
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "Store1, Associate04") |
    ...    | associate_id | Associate ID (e.g., "10000004") |
    ...    | associate_type | Resolved associate type value from template (e.g., "FT - Full Time") |
    ...    Example usage (using template data):
    ...    | ${filter_data}=    Get Roster Filter Data    template_name=filter_criteria_1 |
    ...    | Verify Filtered Associate Data Is Displayed On Roster Page On Web | ${ft_employee}[displayName] | ${ft_employee}[username] | ${filter_data}[associate_type] |
    [Arguments]    ${associate_name}    ${associate_id}    ${associate_type}

    # Resolve display label from constants — env-agnostic (e.g. "Full Time" / "≥30h" for CVS)
    ${ft_type}    Get System Value    AssociateType    FULL_TIME
    ${ft_display}    Get System Value    AssociateTypeDisplay    FULL_TIME
    ${pt_display}    Get System Value    AssociateTypeDisplay    PART_TIME
    IF    '${associate_type}' == '${ft_type}'
        VAR    ${associate_type_display}    ${ft_display}
    ELSE
        VAR    ${associate_type_display}    ${pt_display}
    END
    VAR    ${associate_type_xpath}    contains(@aria-label, '${associate_type_display}')

    # Debug logging
    Log    Building locator with: Name=${associate_name}, ID=${associate_id}, Type=${associate_type_display}    level=INFO

    # Build the dynamic locator with associate_name and resolved associate_type_xpath
    ${filtered_row_locator}    Update Locator With Dynamic Values    ${ROSTER_PAGE_FILTERED_ASSOCIATE_ROW}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    ASSOCIATE_TYPE_XPATH=${associate_type_xpath}

    # Log the built locator
    Log    Built locator: ${filtered_row_locator}    level=INFO

    # Wait for page to load after filter is applied
    Wait Until Page Is Loaded

    # Wait for spinner to disappear (filter processing complete)
    TRY
        Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_SPINNER_ICON}    timeout=${MEDIUM_TIMEOUT}
    EXCEPT
        Log    Spinner did not disappear within timeout, continuing with verification    level=WARN
    END

    # Give a brief moment for DOM to stabilize after filter application
    Sleep    1s      # needed as discussed with owner

    # Check which element is actually visible
    ${associate_visible}    Is Element Visible On Webpage    ${filtered_row_locator}
    ${no_records_visible}    Is Element Visible On Webpage    ${ROSTER_PAGE_FILTER_RESULT_NO_RECORDS_FOUND}

    # Handle the three possible scenarios
    IF    ${associate_visible}
        # Success case: Associate row is visible
        Log    Successfully verified filtered associate: ${associate_name} with ID ${associate_id} and type ${associate_type_display}
        ...    level=INFO
        Capture Screenshot On Webpage
    ELSE IF    ${no_records_visible}
        # Valid case: "No Records Found" message is visible (filter returned no results)
        Log
        ...    Filter returned no results for associate: ${associate_name} (ID: ${associate_id}, Type: ${associate_type_display}). "No associates present" message is displayed.
        ...    level=INFO
        Capture Screenshot On Webpage
    ELSE
        # Failure case: Neither associate nor "No Records Found" is visible (something went wrong)
        Capture Screenshot On Webpage
        Fail
        ...    Filter verification failed: Neither associate row nor "No Records Found" message is visible for ${associate_name} (ID: ${associate_id}, Type: ${associate_type_display}). This indicates a page loading issue. Locator: ${filtered_row_locator}
    END

Reset All Filters On Roster Page On Web
    [Documentation]    Opens filter panel, resets all filters, and applies the reset
    ...    This is a complete action keyword that performs all steps in one call:
    ...    1. Opens filter panel
    ...    2. Clicks Reset button
    ...    3. Clicks Apply button
    ...    4. Waits for page to load
    ...    Example usage:
    ...    | Reset All Filters On Roster Page On Web |
    Click On Filter Icon On Roster Page On Web
    Reset Filter On Roster Page On Web

Verify Filtered Associate Data Is Not Displayed On Roster Page On Web
    [Documentation]    Verifies that the filtered associate row is NOT displayed with the specified associate details
    ...    This keyword is used to verify that certain associates are excluded from filter results
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Full display name of the associate (e.g., "Store1, Associate04") |
    ...    | associate_id | Associate ID (e.g., "10000004") |
    ...    | associate_type | Resolved associate type value from template (e.g., "FT - Full Time") |
    ...    Example usage:
    ...    | ${filter_data}=    Get Roster Filter Data    template_name=filter_criteria_5 |
    ...    | Verify Filtered Associate Data Is Not Displayed On Roster Page On Web | ${self_user}[displayName] | ${self_user}[username] | ${filter_data}[associate_type] |
    [Arguments]    ${associate_name}    ${associate_id}    ${associate_type}

    # Resolve display label from constants — env-agnostic (e.g. "Full Time" / "≥30h" for CVS)
    ${ft_type}    Get System Value    AssociateType    FULL_TIME
    ${ft_display}    Get System Value    AssociateTypeDisplay    FULL_TIME
    ${pt_display}    Get System Value    AssociateTypeDisplay    PART_TIME
    IF    '${associate_type}' == '${ft_type}'
        VAR    ${associate_type_display}    ${ft_display}
    ELSE
        VAR    ${associate_type_display}    ${pt_display}
    END
    VAR    ${associate_type_xpath}    contains(@aria-label, '${associate_type_display}')

    # Debug logging
    Log    Verifying associate NOT displayed: Name=${associate_name}, ID=${associate_id}, Type=${associate_type_display}    level=INFO

    # Build the dynamic locator with associate_name and resolved associate_type_xpath
    ${filtered_row_locator}    Update Locator With Dynamic Values    ${ROSTER_PAGE_FILTERED_ASSOCIATE_ROW}
    ...    ASSOCIATE_NAME=${associate_name}
    ...    ASSOCIATE_TYPE_XPATH=${associate_type_xpath}

    # Wait for page to load after filter is applied
    Wait Until Page Is Loaded

    # Wait for spinner to disappear (filter processing complete)
    TRY
        Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_SPINNER_ICON}    timeout=${MEDIUM_TIMEOUT}
    EXCEPT
        Log    Spinner did not disappear within timeout, continuing with verification    level=WARN
    END

    # Give a brief moment for DOM to stabilize after filter application
    Sleep    1s   # needed as discussed with owner

    # Check that associate is NOT visible
    ${associate_visible}    Is Element Visible On Webpage    ${filtered_row_locator}

    IF    ${associate_visible}
        # Failure case: Associate should NOT be visible but is
        Capture Screenshot On Webpage
        Fail
        ...    Verification failed: Associate ${associate_name} (ID: ${associate_id}, Type: ${associate_type_display}) should NOT be displayed in filter results but was found. Locator: ${filtered_row_locator}
    ELSE
        # Success case: Associate is correctly not visible
        Log    Successfully verified associate NOT displayed: ${associate_name} with ID ${associate_id} and type ${associate_type_display}
        ...    level=INFO
        Capture Screenshot On Webpage
    END

Apply Filter With Associate Criteria On Roster Page On Web
    [Documentation]    Opens filter panel, resets previous filters, sets associate ID, type, status, and reportee type, then applies the filter
    ...    This is a complete action keyword that performs all steps in one call:
    ...    1. Opens filter panel
    ...    2. Resets any previous filters
    ...    3. Fills Associate ID (optional)
    ...    4. Selects Associate Type (optional)
    ...    5. Selects Employment Status (optional)
    ...    6. Selects Reportee Type (optional)
    ...    7. Applies the filter
    ...    | =Arguments= | =Description= |
    ...    | associate_id | Associate ID to filter by (optional, use ${EMPTY} to skip) |
    ...    | associate_type | Resolved associate type value from template (e.g., "FT - Full Time") (optional, use ${EMPTY} to skip) |
    ...    | status | Resolved employment status value from template (e.g., "Active") (optional, use ${EMPTY} to skip) |
    ...    | reportee_type | Resolved reportee type value from template (e.g., "Direct") (optional, use ${EMPTY} to skip) |
    ...    Example usage (using template data):
    ...    | ${filter_data}=    Get Roster Filter Data    template_name=filter_criteria_1 |
    ...    | Apply Filter With Associate Criteria On Roster Page On Web | ${filter_data}[associate_id] | ${filter_data}[associate_type] | ${filter_data}[status] | ${filter_data}[reportee_type] |
    [Arguments]    ${associate_id}=${EMPTY}    ${associate_type}=${EMPTY}    ${status}=${EMPTY}    ${reportee_type}=${EMPTY}
    ...    ${status_on_date}=${EMPTY}

    # Open filter panel
    Click On Filter Icon On Roster Page On Web

    # Reset any previous filters first
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_RESET_BTN}

    # Apply Associate ID filter if provided
    IF    '${associate_id}' != '${EMPTY}'
        Filter By Employee ID On Roster Page On Web    ${associate_id}
    END

    # Apply Associate Type filter if provided
    IF    '${associate_type}' != '${EMPTY}'
        Select Associate Type Filter On Roster Page On Web    ${associate_type}
    END

    # Apply Employment Status filter if provided
    IF    '${status}' != '${EMPTY}'
        Select Employment Status Filter On Roster Page On Web    ${status}
    END

    # Apply Reportee Type filter if provided
    IF    '${reportee_type}' != '${EMPTY}'
        Select Reportee Type Filter On Roster Page On Web    ${reportee_type}
    END
    IF    '${status_on_date}' != '${EMPTY}'
        Select Status On Date Filter On Roster Page On Web    ${status_on_date}
    END
    Apply Filter On Roster Page On Web

Select Status On Date Filter On Roster Page On Web
    [Documentation]    Selects status on date from the filter dropdown on Roster page
    ...    Status on date filter is used to filter associates based on their employment status on a specific date
    ...    The keyword clicks on the status on date filter, fills the date, and applies the filter
    ...    | =Arguments= | =Description= |
    ...    | status_on_date | The date to filter by in the format specified by DATE_FORMAT_MONTH_DAY_YEAR (e.g., "12/31/2024") |
    ...    Example usage:
    ...    | ${filter_data}=    Get Roster Filter Data    template_name=filter_criteria_6 |
    ...    | Select Status On Date Filter On Roster Page On Web | ${filter_data}[status_on_date] |
    [Arguments]    ${status_on_date}
    Select Date Through Date Picker For ESS Requests On Webpage    ${ROSTER_PAGE_FILTER_STATUS_AS_DATE}    ${status_on_date}

Navigate To Leave Requests Page On Roster Page On Web
    [Documentation]    This keyword helps to navigate to Leave Requests page
    Click Element On Webpage    ${ROSTER_PAGE_SUMMARY_DROPDOWN}
    Click Element On Webpage    ${ROSTER_PAGE_LEAVE_REQUESTS_MENU}
    Wait Until Page Is Loaded

Get Eligible Leave Request Date From Leave Requests Page On Web
    [Documentation]    This keyword fetches an eligible date for applying leave request from Roster page
    [Arguments]    ${date_format}    @{time_off_dates}
    ${future_dates}    Get Future Days    date_format=${date_format}

    VAR    ${found_leave_date}    None
    FOR    ${leave_date}    IN    @{future_dates}
        ${is_leave_date_displayed}    Is Text Seen On Webpage    ${leave_date}

        IF    not ${is_leave_date_displayed}
            IF    '${leave_date}' not in @{time_off_dates}
                VAR    ${found_leave_date}    ${leave_date}
                BREAK
            END
        END
    END
    IF    '${found_leave_date}' == 'None'
        Skip    No eligible leave date found for leave request. Skipping test.
    ELSE
        RETURN    ${found_leave_date}
    END

Add Leave Request On Roster Page On Web
    [Documentation]    This keyword adds leave request with Holiday hours on Roster page.
    ...    | Arguments    | Description |
    ...    | start_date_offset    | The start date offset from current date to apply leave request. E.g., 1_5 for 6th day, next week. |
    ...    | end_date_offset    | The end date offset from current date to apply leave request. E.g., 1_6 for 7th day, next week. |
    ...    | day_off_reason    | The reason for day off. E.g., 'Paid Vacation' |
    ...    | day_off_status    | The status for day off. E.g., 'Approved' |
    ...    | holiday_hours    | (Optional) Dictionary containing day numbers as keys and holiday hours as values. E.g., {1: 8, 2: 4} |
    [Arguments]    ${start_date_offset}
    ...    ${end_date_offset}
    ...    ${day_off_reason}
    ...    ${day_off_status}
    ...    ${holiday_hours}=${None}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${start_date}    Calculate Date From Week Day Offset In Multiple Formats    ${start_date_offset}    ${date_format}
    ${end_date}    Calculate Date From Week Day Offset In Multiple Formats    ${end_date_offset}    ${date_format}
    Click Element On Webpage    ${ROSTER_PAGE_ADD_DAY_OFF_ICON}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_START_DATE}
    Clear Textbox On Webpage    ${ROSTER_PAGE_DAY_OFF_START_DATE}
    Fill Textbox On Webpage    ${ROSTER_PAGE_DAY_OFF_START_DATE}    ${start_date}[0]
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_END_DATE}
    Clear Textbox On Webpage    ${ROSTER_PAGE_DAY_OFF_END_DATE}
    Fill Textbox On Webpage    ${ROSTER_PAGE_DAY_OFF_END_DATE}    ${end_date}[0]
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_REASON_DROPDOWN}
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_REASON}
    Wait Until Page Is Loaded
    ${day_off_reason_option}    Update Locator With Dynamic Values    ${ROSTER_PAGE_DAY_OFF_REASON_OPTION}
    ...    DAY_OFF_REASON_CODE=${day_off_reason}
    Click Element On Webpage    ${day_off_reason_option}
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_STATUS_DROPDOWN}
    ${day_off_status_option}    Update Locator With Dynamic Values    ${ROSTER_PAGE_DAY_OFF_STATUS_OPTION}
    ...    DAY_OFF_STATUS_CODE=${day_off_status}
    Click Element On Webpage    ${day_off_status_option}
    ${is_spinner_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_SPINNER_ICON}
    ...    timeout=${SHORT_TIMEOUT}
    IF    ${is_spinner_visible}
        Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_SPINNER_ICON}    timeout=${LONG_TIMEOUT}
    END
    IF    $holiday_hours != $None
        ${day_numbers}    Get Dictionary Keys    ${holiday_hours}
        FOR    ${day_num}    IN    @{day_numbers}
            ${hours}    Get From Dictionary    ${holiday_hours}    ${day_num}
            ${day_of_week}    Evaluate    ${day_num} + 1
            ${day_num_string}    Convert To String    ${day_of_week}
            ${holiday_hours_input_locator}    Update Locator With Dynamic Values
            ...    ${ROSTER_PAGE_DAY_OFF_HOLIDAY_HOURS}
            ...    DAY=${day_num_string}
            Wait Until Element Is Visible On Webpage    ${holiday_hours_input_locator}
            Clear Textbox On Webpage    ${holiday_hours_input_locator}
            Fill Textbox On Webpage    ${holiday_hours_input_locator}    ${hours}
            Log    Entered ${hours} holiday hours for day ${day_num}
        END
    END
    Capture Screenshot On Webpage
    ${promise}    Promise To    Wait For Response    ${ROSTER_ADD_DAY_OFF_REQUEST_API}
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_SAVE_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Update Leave Request Status On Roster Page On Web
    [Documentation]    This keyword updates leave request status on Roster page
    [Arguments]    ${start_date_offset}    ${day_off_status}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${day_off_date}    Calculate Date From Week Day Offset In Multiple Formats    ${start_date_offset}    ${date_format}
    ${day_off_req_link}    Update Locator With Dynamic Values    ${ROSTER_PAGE_DAY_OFF_REQUEST_DAY}    DAY_OFF_DATE=${day_off_date}[0]
    Click Element On Webpage    ${day_off_req_link}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_STATUS_DROPDOWN}
    ${day_off_status_not_reviewed}    Update Locator With Dynamic Values    ${ROSTER_PAGE_DAY_OFF_STATUS_OPTION}
    ...    DAY_OFF_STATUS_CODE=${day_off_status}
    Click Element On Webpage    ${day_off_status_not_reviewed}
    ${promise}    Promise To    Wait For Response    ${ROSTER_UPDATE_DAY_OFF_REQUEST_API}
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_SAVE_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Delete DayOff Request On Roster Page On Web
    [Documentation]    This keyword deletes day-off request on Roster page
    [Arguments]    ${start_date_offset}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${day_off_date}    Calculate Date From Week Day Offset In Multiple Formats    ${start_date_offset}    ${date_format}
    ${day_off_req_link}    Update Locator With Dynamic Values    ${ROSTER_PAGE_DAY_OFF_REQUEST_DAY}    DAY_OFF_DATE=${day_off_date}[0]
    Click Element On Webpage    ${day_off_req_link}
    Wait Until Page Is Loaded
    ${promise}    Promise To    Wait For Response    ${ROSTER_DELETE_DAY_OFF_REQUEST_API}
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_DELETE_BTN}
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_OK_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    # Wait until notification message disappears to ensure the request is not present while page refresh before invoking API.
    Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_NOTIFICATION_MSG}

Navigate To TimeOff Requests Page On Roster Page On Web
    [Documentation]    This keyword helps to navigate to TimeOff Requests page
    Click Element On Webpage    ${ROSTER_PAGE_SUMMARY_DROPDOWN}
    Click Element On Webpage    ${ROSTER_PAGE_TIME_OFF_REQUESTS_MENU}
    Wait Until Page Is Loaded

Add TimeOff Request On Roster Page On Web
    [Documentation]    This keyword adds Time-off request on Roster page for the given date
    ...    | =Arguments= | =Description= |
    ...    | ${time_off_date} | Date for which time-off request is to be added |
    ...    | ${time_off_reason} | Reason for time-off request |
    ...    | ${time_off_status} | Status for time-off request |
    ...    | ${time_off_start_time} | Start time for time-off request |
    ...    | ${duration} | Duration for time-off request |
    ...    | ${comment} | Comment/note to enter for the manager |
    ...    Example usage:
    ...    | Add TimeOff Request On Roster Page On Web    1_0    Paid Vacation    Pending Approval    20:00    04:00    Need to attend personal work
    [Arguments]    ${time_off_date}    ${time_off_reason}    ${time_off_status}    ${time_off_start_time}    ${duration}    ${comment}
    Click Element On Webpage    ${ROSTER_PAGE_ADD_TIME_OFF_ICON}
    Wait Until Page Is Loaded
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${converted_time_off_date}    Calculate Date From Week Day Offset    ${time_off_date}    ${date_format}
    Clear Textbox On Webpage    ${ROSTER_PAGE_TIME_OFF_DATE}
    Fill Textbox On Webpage    ${ROSTER_PAGE_TIME_OFF_DATE}    ${converted_time_off_date}
    Clear Textbox On Webpage    ${ROSTER_PAGE_TIME_OFF_START_TIME}
    Fill Textbox On Webpage    ${ROSTER_PAGE_TIME_OFF_START_TIME}    ${time_off_start_time}
    Select Duration Time Off On Request Calendar Page On Web    ${duration}
    Enter Note To Manager For ESS Time Off Request    ${comment}
    Click Element On Webpage    ${ROSTER_PAGE_TIME_OFF_REASON_DROPDOWN}
    ${time_off_reason}    Update Locator With Dynamic Values    ${ROSTER_PAGE_TIME_OFF_REASON}    TIME_OFF_REASON_CODE=${time_off_reason}
    Click Element On Webpage    ${time_off_reason}
    Click Element On Webpage    ${ROSTER_PAGE_TIME_OFF_STATUS_DROPDOWN}
    ${time_off_status_code}    Update Locator With Dynamic Values    ${ROSTER_PAGE_TIME_OFF_STATUS_CODE}
    ...    TIME_OFF_STATUS_CODE=${time_off_status}
    Click Element On Webpage    ${time_off_status_code}
    ${promise}    Promise To    Wait For Response    ${ROSTER_ADD_TIME_OFF_REQUEST_API}
    Click Element On Webpage    ${ROSTER_PAGE_TIME_OFF_SAVE_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Get Eligible TimeOff Date On Roster Page On Web
    [Documentation]    This keyword fetches an eligible date for applying Time-off on Roster page
    [Arguments]    ${date_format}    @{leave_dates}
    ${future_dates}    Get Future Days    date_format=${date_format}

    VAR    ${found_time_off_date}    None
    FOR    ${time_off_date}    IN    @{future_dates}
        ${is_time_off_displayed}    Is Text Seen On Webpage    ${time_off_date}

        IF    not ${is_time_off_displayed}
            IF    '${time_off_date}' not in @{leave_dates}
                VAR    ${found_time_off_date}    ${time_off_date}
                BREAK
            END
        END
    END
    IF    '${found_time_off_date}' == 'None'
        Skip    No eligible time-off date found for Time-off request. Skipping test.
    ELSE
        RETURN    ${found_time_off_date}
    END

Get Leave Applied Dates On Roster Page On Web
    [Documentation]    This keyword fetches all the applied leave dates on Roster page
    ${leave_dates_elements}    Get Elements    ${ROSTER_PAGE_LEAVE_DATES}
    VAR    @{leave_dates}    @{EMPTY}
    FOR    ${element}    IN    @{leave_dates_elements}
        ${date}    Get Element Text On Webpage    ${element}
        ${split_date}    Split String    ${date}    -    # Split the date by '-'
        ${first_part}    Strip String    ${split_date}[0]    # Get the first part and trim it
        Append To List    ${leave_dates}    ${first_part}
    END
    RETURN    @{leave_dates}

Update TimeOff Request On Roster Page On Web
    [Documentation]    This keyword updates existing Time-off request status
    ...    | =Arguments= | =Description= |
    ...    | ${time_off_date} | Date for which time-off request is to be updated |
    ...    | ${time_off_status} | Revised status for time-off request |
    ...    Example usage:
    ...    | Update TimeOff Request On Roster Page On Web    09/30/2023    Approved
    [Arguments]    ${time_off_date}    ${time_off_status}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${converted_time_off_date}    Calculate Date From Week Day Offset    ${time_off_date}    ${date_format}
    ${time_off_day_link}    Update Locator With Dynamic Values    ${ROSTER_PAGE_TIME_OFF_REQUEST_DAY}
    ...    TIME_OFF_DATE=${converted_time_off_date}
    Click Element On Webpage    ${time_off_day_link}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${ROSTER_PAGE_TIME_OFF_STATUS_DROPDOWN}
    ${time_off_status_code}    Update Locator With Dynamic Values    ${ROSTER_PAGE_TIME_OFF_STATUS_CODE}
    ...    TIME_OFF_STATUS_CODE=${time_off_status}
    Click Element On Webpage    ${time_off_status_code}
    ${promise}    Promise To    Wait For Response    ${ROSTER_UPDATE_TIME_OFF_REQUEST_API}
    Click Element On Webpage    ${ROSTER_PAGE_TIME_OFF_UPDATE_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Delete TimeOff Request On Roster Page On Web
    [Documentation]    This keyword deletes existing Time-off request
    ...    | =Arguments= | =Description= |
    ...    | ${time_off_date} | Date for which time-off request is to be deleted |
    ...    Example usage:
    ...    | Delete TimeOff Request On Roster Page On Web    09/30/2023
    [Arguments]    ${time_off_date}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${converted_time_off_date}    Calculate Date From Week Day Offset    ${time_off_date}    ${date_format}
    ${time_off_day_link}    Update Locator With Dynamic Values    ${ROSTER_PAGE_TIME_OFF_REQUEST_DAY}
    ...    TIME_OFF_DATE=${converted_time_off_date}
    Click Element On Webpage    ${time_off_day_link}
    Wait Until Page Is Loaded
    ${promise}    Promise To    Wait For Response    ${ROSTER_DELETE_TIME_OFF_REQUEST_API}
    Click Element On Webpage    ${ROSTER_PAGE_TIME_OFF_DELETE_BTN}
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_DELETE_OK_BTN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Get TimeOff Applied Dates On Roster Page On Web
    [Documentation]    This keyword fetches all the applied Time-off dates on Roster page
    ${time_off_dates_elements}    Get Elements    ${ROSTER_PAGE_TIME_OFF_DATES}
    VAR    @{time_off_dates}    @{EMPTY}
    FOR    ${element}    IN    @{time_off_dates_elements}
        ${date}    Get Element Text On Webpage    ${element}
        ${split_date}    Split String    ${date}    -    # Split the date by '-'
        ${first_part}    Strip String    ${split_date}[0]    # Get the first part and trim it
        Append To List    ${time_off_dates}    ${first_part}
    END
    RETURN    @{time_off_dates}

Verify Green Bar Success Notification Message Is Seen On Web
    [Documentation]    This keyword verifies green bar success notification message is seen on web application
    Run Keyword And Ignore Error    Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_SPINNER_ICON}    timeout=${LONG_TIMEOUT}
    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_NOTIFICATION_MSG}
    ...    timeout=${LONG_TIMEOUT}    error_message=Success notification message did not appear within timeout
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_NOTIFICATION_MSG}

Search Employee On Roster Page On Web
    [Documentation]    This keyword searches employee on Roster page using search box
    [Arguments]    ${emp_name}
    Fill Textbox On Webpage    ${ROSTER_PAGE_EMP_SEARCH_BOX}    ${emp_name}
    Click Element On Webpage    ${ROSTER_PAGE_EMP_SEARCH_ICON}
    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_FIRST_EMP_NAME}
    Capture Screenshot On Webpage

Navigate To Release To Store Page On Roster Page On Web
    [Documentation]    This keyword helps to navigate to Release To Store page
    Click Element On Webpage    ${ROSTER_PAGE_SUMMARY_DROPDOWN}
    Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_MENU}
    Wait Until Page Is Loaded

Click On Add Release To Store Icon On Roster Page On Web
    [Documentation]    This keyword clicks on Add Release To Store icon on Roster page
    Click Element On Webpage    ${ROSTER_PAGE_ADD_RELEASE_TO_STORE_ICON}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Search And Select Assigned To Store For Release To Store On Roster Page On Web
    [Documentation]    This keyword searches and selects store on Release To Store on Roster page
    [Arguments]    ${store_name}
    Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_STORE_ASSIGNED_TO_DROPDOWN}
    Fill Textbox On Webpage    ${RELEASE_TO_STORE_STORE_ASSIGNED_TO_SEARCH_FIELD}    ${store_name}
    Click Element On Webpage    ${RELEASE_TO_STORE_STORE_ASSIGNED_TO_STORE}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Select Staff Group For Release To Store On Roster Page On Web
    [Documentation]    This keyword searches and selects store on Release To Store on Roster page
    ${options_visible}    Is Element Visible On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_STAFF_GROUP_FIRST_OPTION}
    IF    not ${options_visible}
        Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_STAFF_GROUP_DROPDOWN}
    END
    Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_STAFF_GROUP_FIRST_OPTION}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Is Select Staff Group For Release To Store Visible On Roster Page On Web
    [Documentation]    This keyword verifies if Select Staff Group For Release To Store is visible on Roster page
    ${is_staff_grp_visible}    Is Element Visible On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_STAFF_GROUP_DROPDOWN}
    Wait Until Page Is Loaded
    RETURN    ${is_staff_grp_visible}

Click On All Days Toggle Button On Release To Store Page On Roster Page On Web
    [Documentation]    This keyword clicks on All Days toggle button on Release To Store page on Roster page
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_FLEX_CONTAINER}
    Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_ALL_DAYS_TOGGLE_BTN}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Select The Reason For Release To Store On Roster Page On Web
    [Documentation]    This keyword selects reason for Release To Store on Roster page
    ${release_to_store_reason}    Get System Value    ReleaseToStoreReason    REASON1
    Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_REASON_DROPDOWN}
    ...    error_message=Reason dropdown for Release To Store not found on the page
    IF    '${release_to_store_reason}' != 'REASON1' and '${release_to_store_reason}' != '${None}'
        ${reason_option_locator}    Update Locator With Dynamic Values    ${ROSTER_PAGE_RELEASE_TO_STORE_SPECIFIC_REASON_OPTION}
        ...    REASON=${release_to_store_reason}
        Click Element On Webpage    ${reason_option_locator}
        ...    error_message=Specified reason option for Release To Store not found on the page. Please check constants for the correct reason value.
    ELSE
        Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_RELEASE_REASON_OPTION}
        ...    error_message=Default reason option for Release To Store not found on the page
    END
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Click On Save Button On Release To Store Page On Roster Page On Web
    [Documentation]    This keyword clicks on Save button on Release To Store page on Roster page
    Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_SAVE_BTN}
    ...    error_message=Save button for Release To Store not found on the page
    Wait Until Page Is Loaded

Delete And Verify Release To Store Request On Roster Page On Web
    [Documentation]    This keyword deletes existing Release To Store request
    Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_DELETE_BTN}
    ...    error_message=Release To Store delete button not found on the page
    Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_DELETE_OK_BTN}
    ...    error_message=Release To Store delete confirmation OK button not found on the page
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    ${promise}    Promise To    Wait For Response    ${ROSTER_DELETE_RELEASE_TO_STORE_REQUEST_API}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Add And Verify Release To Store Request For Selected Employee
    [Documentation]    This keyword adds a release store request for the selected employee
    [Arguments]    ${store_name}    ${effective_date}
    Navigate To Release To Store Page On Roster Page On Web
    Click On Add Release To Store Icon On Roster Page On Web
    Wait Until Page Is Loaded
    Search And Select Assigned To Store For Release To Store On Roster Page On Web    ${store_name}
    Wait Until Page Is Loaded
    Fill Textbox On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_EFFECTIVE_DATE}    ${effective_date}
    Wait Until Page Is Loaded
    ${is_staff_grp_visible}    Is Select Staff Group For Release To Store Visible On Roster Page On Web
    IF    ${is_staff_grp_visible}
        ${option_selected}    Run Keyword And Return Status
        ...    Wait Until Element Is Present On Webpage    ${ROSTER_PAGE_AVAILABILITY_SELECTED_OPTION}
        IF    not ${option_selected}
            Click Element On Webpage    ${ROSTER_PAGE_RELEASE_TO_STORE_STAFF_GROUP_DROPDOWN}
            ...    error_message=Staff Group dropdown for Release To Store not found on the page
            Select Staff Group For Release To Store On Roster Page On Web
        END
    END
    Click On All Days Toggle Button On Release To Store Page On Roster Page On Web
    Select The Reason For Release To Store On Roster Page On Web
    ${min_daily_hr_displayed}    Is Element Visible On Webpage    ${ROSTER_PAGE_AVAILABILITY_MIN_DAILY_HOURS_INPUT}
    IF    ${min_daily_hr_displayed}
        ${week_min_daily_hr_value}    Get Element Text On Webpage    ${ROSTER_PAGE_AVAILABILITY_MIN_DAILY_HOURS_INPUT}
        ${week_min_daily_hr_value}    Convert To String    ${week_min_daily_hr_value}
        IF    '${week_min_daily_hr_value}' == '0'
            Clear Textbox On Webpage    ${ROSTER_PAGE_AVAILABILITY_MIN_DAILY_HOURS_INPUT}
            Fill Textbox On Webpage    ${ROSTER_PAGE_AVAILABILITY_MIN_DAILY_HOURS_INPUT}    8
        END
    END
    ${min_week_hr_displayed}    Is Element Visible On Webpage    ${ROSTER_PAGE_AVAILABILITY_MIN_WEEK_HOURS_INPUT}
    IF    ${min_week_hr_displayed}
        ${week_min_hr_value}    Get Element Text On Webpage    ${ROSTER_PAGE_AVAILABILITY_MIN_WEEK_HOURS_INPUT}
        ${week_min_hr_value}    Convert To String    ${week_min_hr_value}
        IF    '${week_min_hr_value}' == '0'
            Clear Textbox On Webpage    ${ROSTER_PAGE_AVAILABILITY_MIN_WEEK_HOURS_INPUT}
            Fill Textbox On Webpage    ${ROSTER_PAGE_AVAILABILITY_MIN_WEEK_HOURS_INPUT}    8
        END
    END
    Click On Save Button On Release To Store Page On Roster Page On Web
    ${promise}    Promise To    Wait For Response    ${ROSTER_ADD_RELEASE_TO_STORE_REQUEST_API}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Navigate To Availability Requests Page On Roster Page On Web
    [Documentation]    This keyword helps to navigate to Availability Requests page
    Click Element On Webpage    ${ROSTER_PAGE_SUMMARY_DROPDOWN}
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_REQUESTS_MENU}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_SUMMARY_DROPDOWN}

Get Eligible Date To Add Availability Request On Web
    [Documentation]    This keyword fetches an eligible date for applying Availability request on the Roster page
    [Arguments]    ${date_format}

    ${week_start_day}    Get Config Value    WEEK_START_DAY
    ${future_week_start_dates}    Get Future Weeks Start End Dates    date_format=${date_format}    day_type=start
    ...    week_start_day=${week_start_day}
    ${future_week_end_dates}    Get Future Weeks Start End Dates    date_format=${date_format}    day_type=end
    ...    week_start_day=${week_start_day}

    VAR    ${eligible_available_date}    None
    FOR    ${availability_date}    IN    @{future_week_start_dates}    @{future_week_end_dates}
        ${is_availability_date_displayed}    Is Text Seen On Webpage    ${availability_date}

        IF    not ${is_availability_date_displayed}
            VAR    ${eligible_available_date}    ${availability_date}
            BREAK
        END
    END
    IF    '${eligible_available_date}' == 'None'
        Skip    No eligible availability date found for availability request. Skipping test.
    ELSE
        RETURN    ${eligible_available_date}
    END

Add Availability Request On Roster Page On Web
    [Documentation]    This keyword adds Availability request for the given date on Roster page
    ...    | =Arguments= | =Description= |
    ...    | ${availability_request_date} | Date for which availability request is to be added |
    ...    | ${status} | Status for availability request |
    ...    | ${reason} | Reason for availability request |
    ...    | ${availability_hours_list} | List of availability hours for each day |
    ...    | ${availability_row_number} | Row number for split availability hours |
    ...    | ${availability_rotation_number} | Rotation number for availability hours |
    ...    Example usage:
    ...    | Add Availability Request On Roster Page On Web    1_7    Available    Personal Reasons    ${availability_hours_list}    1    1
    [Arguments]    ${availability_request_date}
    ...    ${status}
    ...    ${reason}
    ...    ${availability_hours_list}
    ...    ${availability_row_number}
    ...    ${availability_rotation_number}
    ...    ${total_rotations}=1
    Wait Until Page Is Loaded
    Click Element On Webpage    ${ROSTER_PAGE_ADD_AVAILABILITY_ICON}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_PERMANENT_CHECKBOX}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${converted_date}    Calculate Date From Week Day Offset    ${availability_request_date}    ${date_format}
    Clear Textbox On Webpage    ${ROSTER_PAGE_AVAILABILITY_EFFECTIVE_WEEK}
    Fill Textbox On Webpage    ${ROSTER_PAGE_AVAILABILITY_EFFECTIVE_WEEK}    ${converted_date}
    ${is_status_dropdown_displayed}    Is Element Present On Webpage    ${ROSTER_PAGE_AVAILABILITY_STATUS_DROPDOWN}
    IF    ${is_status_dropdown_displayed}
        Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_STATUS_DROPDOWN}
        ${availability_status_option}    Update Locator With Dynamic Values    ${ROSTER_PAGE_AVAILABILITY_STATUS}
        ...    AVAILABILITY_STATUS=${status}
        Click Element On Webpage    ${availability_status_option}
    END
    ${is_reason_field_visible}    Is Element Visible On Webpage    ${ROSTER_PAGE_AVAILABILITY_REASON_DROPDOWN}
    IF    ${is_reason_field_visible}
        Select SM Availability Reason On Roster Page On Web    ${reason}
    END
    ${rotation_numeric}    Convert To Integer    ${total_rotations}
    IF    ${rotation_numeric} > 1
        Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_SELECT_ROTATION_DROPDOWN}
        ${availability_rotation_option}    Update Locator With Dynamic Values    ${ROSTER_PAGE_AVAILABILITY_ROTATION_OPTION}
        ...    ROTATION_NUMBER=${total_rotations}
        Click Element On Webpage    ${availability_rotation_option}
    END
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_NEXT_BTN}
    Add Availability Hours On Roster Page On Web    ${availability_hours_list}    ${availability_row_number}
    ...    ${availability_rotation_number}

Save Availability Request On Roster Page On Web
    [Documentation]    This keyword saves the newly added Availability request on Roster page
    ${promise}    Promise To    Wait For Response    ${ROSTER_SM_AVAILABILITY_REQUEST_API}
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_REQUEST_SAVE_BTN}
    Wait Until Page Is Loaded
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Capture Screenshot On Webpage

Edit Availability Request On Roster Page On Web
    [Documentation]    This keyword edits and updates the status of an existing Availability request on the Roster page
    ...    | =Arguments= | =Description= |
    ...    | ${availability_request_date} | Date for which availability request is to be edited |
    ...    | ${availability_hours_list} | List of updated availability hours for each day |
    ...    | ${availability_row_number} | Row number for split availability hours |
    ...    | ${rotation_number} | Rotation number for availability hours |
    ...    Example usage:
    ...    | Edit Availability Request On Roster Page On Web    1_7    ${availability_hours_list}    1    1
    [Arguments]    ${availability_request_date}
    ...    ${availability_hours_list}
    ...    ${availability_row_number}
    ...    ${rotation_number}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${converted_date}    Calculate Date From Week Day Offset    ${availability_request_date}    ${date_format}
    ${availability_request_edit_link}    Update Locator With Dynamic Values    ${ROSTER_PAGE_AVAILABILITY_REQUEST_EDIT_LINK}
    ...    AVAILABILITY_DATE=${converted_date}
    Click Element On Webpage    ${availability_request_edit_link}
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_HOURS_TAB}
    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_TOTALLY_AVAILABLE_LBL}
    Add Availability Hours On Roster Page On Web    ${availability_hours_list}    ${availability_row_number}
    ...    ${rotation_number}
    ${promise}    Promise To    Wait For Response    ${ROSTER_SM_AVAILABILITY_REQUEST_API}
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_REQUEST_SAVE_BTN}
    Wait Until Page Is Loaded
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Capture Screenshot On Webpage

Delete Availability Request On Roster Page On Web
    [Documentation]    This keyword deletes an existing Availability request on the Roster page
    ...    | =Arguments= | =Description= |
    ...    | ${availability_request_date} | Date for which availability request is to be deleted |
    ...    Example usage:
    ...    | Delete Availability Request On Roster Page On Web    1_7
    [Arguments]    ${availability_request_date}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${converted_date}    Calculate Date From Week Day Offset    ${availability_request_date}    ${date_format}
    ${availability_request_delete_btn}    Update Locator With Dynamic Values    ${ROSTER_PAGE_AVAILABILITY_REQUEST_DELETE_BTN}
    ...    AVAILABILITY_DATE=${converted_date}
    ${promise}    Promise To    Wait For Response    ${ROSTER_SM_AVAILABILITY_REQUEST_API}
    Click Element On Webpage    ${availability_request_delete_btn}
    Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_OK_BTN}
    Wait Until Page Is Loaded
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Capture Screenshot On Webpage

Get Id For The Given Associate On Roster Page On Web
    [Documentation]    Retrieves the employee ID for a specified associate on the Employee Roster page.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to get ID for. |
    ...    | =Returns= | =Description= |
    ...    | emp_id | Employee ID of the specified associate. |
    ...    Example usage:
    ...    | ${employee_id}    Get Id For The Given Associate On Roster Page On Web    John Doe
    [Arguments]    ${associate_name}
    ${associate_id}    Update Locator With Dynamic Values    ${ROSTER_PAGE_ASSOCIATE_ID}    ASSOCIATE_NAME=${associate_name}
    ${emp_id}    Get Element Text On Webpage    ${associate_id}
    Capture Screenshot On Webpage
    RETURN    ${emp_id}

Apply Filter On Associate Id On Roster Page On Web
    [Documentation]    Applies a filter on Associate ID on the Roster homepage and returns the filtered employee ID.
    ...    | =Arguments= | =Description= |
    ...    | associate_id | Associate ID to filter by. |
    ...    | =Returns= | =Description= |
    ...    | emp_id | Employee ID from the filtered result. |
    ...    Example usage:
    ...    | ${filtered_id}    Apply Filter On Associate Id On Roster Page On Web    12345
    [Arguments]    ${associate_id}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_ICON}
    Fill Textbox On Webpage    ${ROSTER_PAGE_FILTER_ID_TXT}    ${associate_id}
    Click Element On Webpage    ${ROSTER_PAGE_FILTER_APPLY_BTN}
    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_FILTER_ON_ICON}
    Sleep    ${SHORT_TIMEOUT}    # This sleep is essential as filter result does not appear immediately after applying filter , needed as discussed with owner
    Wait Until Element Disappears On Webpage    ${ROSTER_PAGE_SPINNER_ICON}
    Wait Until Element Is Visible On Webpage    ${ROSTER_PAGE_FIRST_EMP_NAME}
    ${emp_id}    Get Element Text On Webpage    ${ROSTER_PAGE_FIRST_EMP_ID}
    Capture Screenshot On Webpage
    RETURN    ${emp_id}

Cleanup Existing Leave Requests On Roster Page On Web
    [Documentation]    This keyword cleans up existing leave requests with holiday hours on Roster page.
    ...    | Arguments    | Description |
    ...    | start_date_offset    | The start date offset from current date to delete leave requests. E.g., 1_5 for 6th day, next week. |
    [Arguments]    ${start_date_offset}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${start_date}    Calculate Date From Week Day Offset In Multiple Formats    ${start_date_offset}    ${date_format}
    ${day_off_req_link}    Update Locator With Dynamic Values    ${ROSTER_PAGE_DAY_OFF_REQUEST_DAY}    DAY_OFF_DATE=${start_date}[0]
    ${requests}    Get Elements    ${day_off_req_link}
    ${prefix}    Set Selector Prefix    ${None}
    FOR    ${request}    IN    @{requests}
        ${is_leave_request_present}    Is Element Present On Webpage    ${request}
        IF    ${is_leave_request_present}
            Click Element On Webpage    ${request}
            Wait Until Page Is Loaded
            Set Selector Prefix    ${prefix}
            ${promise}    Promise To    Wait For Response    ${ROSTER_DELETE_DAY_OFF_REQUEST_API}
            Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_DELETE_BTN}
            Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_OK_BTN}
            ${response_body}    Wait For    ${promise}
            Log    ${response_body.body}
            Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
            Log    Deleted leave request for date: ${start_date}[0]
        ELSE
            Log    No leave request found for date: ${start_date}[0]
        END
    END
    Set Selector Prefix    ${prefix}

Click On Associate On Roster Page On Web
    [Documentation]    This keyword clicks on the associate on Roster page using associate name
    ...    | =Arguments=    | =Description=    |
    ...    | associate_name    | The full name of the associate in "FirstName, LastName" format.    |
    ...    Example usage:
    ...    | Click On Associate On Roster Page On Web    John, Doe
    [Arguments]    ${associate_name}
    @{name_parts}    Split String    ${associate_name}    ,
    ${first_name}    Strip String    ${name_parts}[0]
    ${last_name}    Strip String    ${name_parts}[1]
    ${roster_page_associate}    Update Locator With Dynamic Values
    ...    ${ROSTER_PAGE_SELECT_ASSOCIATE}    FIRST_NAME=${first_name}    LAST_NAME=${last_name}
    Click Element On Webpage    ${roster_page_associate}
    Wait Until Page Is Loaded

Select Duration Time Off On Request Calendar Page On Web
    [Documentation]    This keyword selects duration time off on Request Calendar page
    ...    | =Arguments=    | =Description=    |
    ...    | duration    | The duration to select in HH:MM format.    |
    ...    Example usage:
    ...    | Select Duration Time Off On Request Calendar Page On Web    08:30
    [Arguments]    ${duration}
    Click Element On Webpage    ${ROSTER_PAGE_TIME_OFF_DURATION_DROPDOWN}
    @{duration_parts}    Split String    ${duration}    :
    ${duration_option}    Update Locator With Dynamic Values    ${ROSTER_PAGE_TIME_OFF_SELECT_DURATION}
    ...    HRS=${duration_parts}[0]    MIN=${duration_parts}[1]
    Click Element On Webpage    ${duration_option}

Enter Note To Manager For ESS Time Off Request
    [Documentation]    Enter note to manager for time off request
    ...    | =Arguments=    | =Description=    |
    ...    | comment    | The comment/note to enter for the manager.    |
    ...    Example usage:
    ...    | Enter Note To Manager For ESS Time Off Request    Need time off for personal reasons
    [Arguments]    ${comment}
    Clear Textbox On Webpage    ${ROSTER_PAGE_TIME_OFF_ADD_COMMENT}
    Fill Textbox On Webpage    ${ROSTER_PAGE_TIME_OFF_ADD_COMMENT}    ${comment}

Add Availability Hours On Roster Page On Web
    [Documentation]    Add availability hours on roster page
    ...    | =Arguments= | =Description= |
    ...    | availability_hours_list    | List of availability hours details for each day. |
    ...    | availability_row_number    | The row number for availability entry (usually 0 or 1). |
    ...    | rotation_number    | Rotation number for availability hours. |
    ...    Example usage:
    ...    | Add Availability Hours On Roster Page On Web    @{availability_hours_list}    0    1
    [Arguments]    ${availability_hours_list}    ${availability_row_number}    ${rotation_number}

    # Reorder the days based on fiscal week start while preserving timing patterns
    ${reordered_days}    Reorder Days By Fiscal Week    ${availability_hours_list}    day_number

    ${availability_days_length}    Get Length    ${reordered_days}
    FOR    ${index}    IN RANGE    0    ${availability_days_length}
        ${shift_day}    Get From List    ${reordered_days}    ${index}
        ${data_day_number}    Get From Dictionary    ${shift_day}    day_number
        ${day}    Evaluate    int(${data_day_number})
        ${start_time}    Get From Dictionary    ${shift_day}    start_time
        ${end_time}    Get From Dictionary    ${shift_day}    end_time
        # Check if start_time and end_time are "Null"
        IF    '${start_time}' == 'Null' and '${end_time}' == 'Null'
            # Use availability type from template
            ${availability_type}    Get From Dictionary    ${shift_day}    availability
            Set Availability Type On Availability Hours For Day On Roster Page On Web    ${day}    ${availability_type}
            ...    ${availability_row_number}    ${rotation_number}
        ELSE
            # Use time-based availability
            ${formatted_start_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
            ${converted_start_time}    Replace String    ${formatted_start_time}    ${SPACE}    ${EMPTY}
            ${formatted_end_time}    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}
            ${converted_end_time}    Replace String    ${formatted_end_time}    ${SPACE}    ${EMPTY}
            Set Start And End Time For Availability Hours On Roster Page On Web    ${day}    ${converted_start_time}
            ...    ${converted_end_time}    ${availability_row_number}    ${rotation_number}
        END
    END

Set Availability Type On Availability Hours For Day On Roster Page On Web
    [Documentation]    Selects availability type on availability hours for specific day on roster page on web
    ...    | =Arguments= | =Description= |
    ...    | day_number    | The day number (0-6) representing the day of the week. |
    ...    | availability_type    | The availability type to select (e.g., "Available", "Unavailable"). |
    ...    | availability_row_number    | The row number for availability entry (usually 0 or 1). |
    ...    | rotation_number    | Rotation number for availability hours. |
    ...    Example usage:
    ...    | Set Availability Type On Availability Hours For Day On Roster Page On Web    2    Available    0    1
    [Arguments]    ${day_number}    ${availability_type}    ${availability_row_number}    ${rotation_number}
    # Construct the locator for availability type dropdown for the specific day
    ${rotation_value}    Evaluate    ${rotation_number} - 1
    ${rotation_value_str}    Convert To String    ${rotation_value}
    ${availability_type_input}    Update Locator With Dynamic Values    ${ROSTER_PAGE_AVAILABILITY_START_INPUT}
    ...    ROTATION_VALUE=${rotation_value_str}
    ...    DAY_NUMBER=${day_number}
    ...    ROW_NUMBER=${availability_row_number}
    Click Element On Webpage    ${availability_type_input}
    Clear Textbox On Webpage    ${availability_type_input}
    Fill Textbox On Webpage    ${availability_type_input}    ${availability_type}
    # Change focus from dropdown
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_HOURS_TEXT}

Set Start And End Time For Availability Hours On Roster Page On Web
    [Documentation]    keyword to set start and end time for availability hours on roster page on web
    ...    | =Arguments= | =Description= |
    ...    | day_number    | The day number (0-6) representing the day of the week. |
    ...    | from_time    | The start time in HH:MM AM/PM format. |
    ...    | to_time    | The end time in HH:MM AM/PM format. |
    ...    | availability_row_number    | The row number for availability entry (usually 0 or 1). |
    ...    | rotation_number    | Rotation number for availability hours. |
    ...    Example usage:
    ...    | Set Start And End Time For Availability Hours On Roster Page On Web    3    09:00AM    05:00PM    0    1
    [Arguments]    ${day_number}    ${from_time}    ${to_time}    ${availability_row_number}    ${rotation_number}
    # Click on Specific Day on request Calendar for adding Availability
    ${rotation_value}    Evaluate    ${rotation_number} - 1
    ${rotation_value_str}    Convert To String    ${rotation_value}
    ${availability_start_input}    Update Locator With Dynamic Values    ${ROSTER_PAGE_AVAILABILITY_START_INPUT}
    ...    ROTATION_VALUE=${rotation_value_str}
    ...    DAY_NUMBER=${day_number}
    ...    ROW_NUMBER=${availability_row_number}
    Click Element On Webpage    ${availability_start_input}
    Clear Textbox On Webpage    ${availability_start_input}
    Fill Textbox On Webpage    ${availability_start_input}    ${from_time}
    # below code is to change focus from input - otherwise element not visible
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_HOURS_TEXT}
    ${availability_end_input}    Update Locator With Dynamic Values    ${ROSTER_PAGE_AVAILABILITY_DURATION_INPUT}
    ...    ROTATION_VALUE=${rotation_value_str}
    ...    DAY_NUMBER=${day_number}
    ...    ROW_NUMBER=${availability_row_number}
    Clear Textbox On Webpage    ${availability_end_input}
    Fill Textbox On Webpage    ${availability_end_input}    ${to_time}
    # below code is to change focus from input - otherwise element not visible
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_HOURS_TEXT}

Select SM Availability Reason On Roster Page On Web
    [Documentation]    Selects the reason for availability on the roster page
    ...    | =Arguments= | =Description= |
    ...    | reason_type    | The reason type to select for availability. |
    ...    Example usage:
    ...    | Select SM Availability Reason On Roster Page On Web    Personal
    [Arguments]    ${reason_type}
    Click Element On Webpage    ${ROSTER_PAGE_AVAILABILITY_REASON_DROPDOWN}
    ${reason_option}    Update Locator With Dynamic Values    ${ROSTER_AVAILABILITY_REASON_OPTION}    REASON_TYPE=${reason_type}
    Click Element On Webpage    ${reason_option}

Verify Employee Is Listed On Roster Page On Web
    [Documentation]    Verifies that the employee is listed on the Roster page
    ...
    ...    | =Arguments= | =Description= |
    ...    | employee_name | Employee display name to verify |
    ...    | employee_id | Employee ID to verify |
    ...
    ...    Example usage:
    ...    | Verify Employee Is Listed On Roster Page On Web | Store2, Associate05 | 10000005 |
    [Arguments]    ${employee_name}    ${employee_id}

    # Wait for page to load completely
    Wait Until Page Is Loaded

    # Check if employee row is visible
    ${employee_visible}    Is Element Visible On Webpage    ${ROSTER_PAGE_FIRST_EMP_NAME}

    IF    ${employee_visible}
        ${displayed_name}    Get Element Text On Webpage    ${ROSTER_PAGE_FIRST_EMP_NAME}
        ${displayed_id}    Get Element Text On Webpage    ${ROSTER_PAGE_FIRST_EMP_ID}

        Should Contain    ${displayed_name}    ${employee_name}
        ...    msg=Expected employee name '${employee_name}' not found in displayed name '${displayed_name}'
        Should Be Equal    ${displayed_id}    ${employee_id}
        ...    msg=Expected employee ID '${employee_id}' does not match displayed ID '${displayed_id}'

        Log    ✅ Successfully verified employee: ${employee_name} (ID: ${employee_id})    level=INFO
        Capture Screenshot On Webpage
    ELSE
        ${no_records_visible}    Is Element Visible On Webpage    ${ROSTER_PAGE_FILTER_RESULT_NO_RECORDS_FOUND}
        IF    ${no_records_visible}
            Fail    Employee '${employee_name}' (ID: ${employee_id}) not found on Roster page - No associates present
        ELSE
            Fail    Unable to verify employee on Roster page - page did not load properly
        END
    END

Cleanup Existing TimeOff Requests On Roster Page On Web
    [Documentation]    This keyword cleans up existing timeoff requests with holiday hours on Roster page.
    ...    | Arguments    | Description |
    ...    | start_date_offset    | The start date offset from current date to delete timeoff requests. E.g., 1_5 for 6th day, next week. |
    [Arguments]    ${start_date_offset}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${start_date}    Calculate Date From Week Day Offset In Multiple Formats    ${start_date_offset}    ${date_format}
    ${time_off_req_link}    Update Locator With Dynamic Values    ${ROSTER_PAGE_TIME_OFF_REQUEST_DAY}    TIME_OFF_DATE=${start_date}[0]
    ${requests}    Get Elements    ${time_off_req_link}
    ${prefix}    Set Selector Prefix    ${None}
    TRY
        FOR    ${request}    IN    @{requests}
            ${is_leave_request_present}    Is Element Visible On Webpage    ${request}
            IF    ${is_leave_request_present}
                Click Element On Webpage    ${request}    Failed to click on existing timeoff request link
                Wait Until Page Is Loaded
                Set Selector Prefix    ${prefix}
                ${promise}    Promise To    Wait For Response    ${ROSTER_DELETE_TIME_OFF_REQUEST_API}
                Click Element On Webpage    ${ROSTER_PAGE_TIME_OFF_DELETE_BTN}    Failed to click on delete button for timeoff request
                Click Element On Webpage    ${ROSTER_PAGE_DAY_OFF_DELETE_OK_BTN}
                ...    Failed to click on OK button for timeoff request deletion
                ${response_body}    Wait For    ${promise}
                Log    ${response_body.body}
                Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
                Log    Deleted timeoff request for date: ${start_date}[0]
            ELSE
                Log    No timeoff request found for date: ${start_date}[0]
            END
        END
    FINALLY
        Set Selector Prefix    ${prefix}
    END
