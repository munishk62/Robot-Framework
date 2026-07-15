*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Forecast Review page functionality within the Predictive Analytics module.
...
...                 = Purpose =
...                 - Centralizes navigation and interaction keywords for the Forecast Review page
...                 - Provides methods to export data to Excel and verify values
...                 - Supports automated testing of predictive forecast editing and validation
...
...                 = Key Features =
...                 - Navigation to Forecast Review page
...                 - Driver search and verification
...                 - Weekly Adjusted value editing and validation
...                 - Excel export and data validation
...
...                 = Prerequisites =
...                 - User must be logged into the WFM application
...                 - Appropriate permissions for accessing Predictive Analytics module
...                 - Required resources and variable files must be available and imported
...
...                 = Dependencies =
...                 - resources/web/common/common.resource: Core navigation and utility functions
...                 - resources/web/common/common_date_utility.resource: Date manipulation utilities
...                 - forecast_review_page.py: Page object variables and locators

Resource            resources/web/common/common.resource
Resource            resources/web/common/calendar_navigation.resource
Variables           resources/web/rws/predictive_analytics/forecast_review_page.py
Variables           resources/web/rws/driver_forecast/predictive_driver_forecast_page.py
Resource            resources/web/common/common_date_utility.resource
Resource            resources/web/rws/schedule/batch_plan_status.resource


*** Keywords ***
Navigate To Forecast Review Page On Web
    [Documentation]
    ...    Navigates to the Forecast Review page under Predictive Analytics and verifies successful page load.
    ...    This keyword handles the complete navigation flow from any starting point in the application
    ...    to the Forecast Review page within the Predictive Analytics module.
    Navigate To Specific Page On Web    rws    predictive_analytics    forecast_review

Search For Driver On Forecast Review Page On Web
    [Documentation]
    ...    Searches for a specific driver by name on the Forecast Review page.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The display name of the driver to search for (e.g., "Driver2 for Forecast") |
    ...    Example usage:
    ...    | Search For Driver On Forecast Review Page On Web    Driver2 for Forecast
    [Arguments]    ${driver_name}

    Wait Until Element Is Visible On Webpage    ${FORECAST_REVIEW_SEARCH_INPUT}
    Clear Textbox On Webpage    ${FORECAST_REVIEW_SEARCH_INPUT}
    Fill Textbox On Webpage    ${FORECAST_REVIEW_SEARCH_INPUT}    ${driver_name}
    # Click on search field to trigger dropdown
    Click Element On Webpage    ${FORECAST_REVIEW_SEARCH_INPUT}
    Keyboard Key    press    Enter
    Wait Until Page Is Loaded

Click On Driver On Forecast Review Page On Web
    [Documentation]
    ...    Clicks on the driver row to expand/activate it on the Forecast Review page.
    ...    Uses the td element from search dropdown which has format: "EXCEL_NAME : Display Name"
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The display name of the driver (e.g., "Driver2 for Forecast") |
    ...    | driver_excel_name | The Excel name of the driver (e.g., "DRIVER2_F") |
    ...    Example usage:
    ...    | Click On Driver On Forecast Review Page On Web    Driver2 for Forecast    DRIVER2_F
    [Arguments]    ${driver_name}    ${driver_excel_name}

    # After search, click on the td element with title "EXCEL_NAME : Driver Name"
    VAR    ${driver_click_locator}
    ...    ${{$FORECAST_REVIEW_DROPDOWN_DRIVER_TD.replace('{DRIVER_EXCEL_NAME}', $driver_excel_name).replace('{DRIVER_NAME}', $driver_name)}}
    Click Element On Webpage    ${driver_click_locator}
    Wait Until Page Is Loaded

Verify Driver Is Present On Forecast Review Page On Web
    [Documentation]
    ...    Verifies that a driver is visible on the Forecast Review page after search.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The display name of the driver to verify (e.g., "Driver2 for Forecast") |
    ...    | =Returns= | =Description= |
    ...    | is_present | Boolean indicating whether the driver is present |
    ...    Example usage:
    ...    | ${is_present}    Verify Driver Is Present On Forecast Review Page On Web    Driver2 for Forecast
    [Arguments]    ${driver_name}

    ${driver_locator}    Update Locator With Dynamic Values    ${FORECAST_REVIEW_DRIVER_ROW_BY_NAME}    DRIVER_NAME=${driver_name}
    ${is_present}    Is Element Visible On Webpage    ${driver_locator}
    RETURN    ${is_present}

Find First Eligible Daily Driver From Forecast Review Page On Web
    [Documentation]
    ...    Dynamically finds the first eligible daily driver with non-empty Weekly Adjusted total.
    ...    Returns driver details including name and excel name.
    ...    Saturday cell editability is validated during subsequent interactions.
    ...    | =Returns= | =Description= |
    ...    | driver_details | Dictionary containing: driver_name, driver_excel_name |
    ...    Example usage:
    ...    | ${driver_details}= | Find First Eligible Daily Driver From Forecast Review Page On Web |
    ...    | Log | Found driver: ${driver_details}[driver_name] |

    Wait Until Page Is Loaded

    ${driver_table_count}    Get Element Count On Web Page    ${FORECAST_REVIEW_ALL_DRIVER_TABLES}

    FOR    ${table_index}    IN RANGE    1    ${driver_table_count} + 1
        VAR    ${current_table_xpath}    (${FORECAST_REVIEW_ALL_DRIVER_TABLES})[${table_index}]

        # Get granularity indicator to check if it's a daily driver
        VAR    ${granularity_xpath}    ${current_table_xpath}${FORECAST_REVIEW_GRANULARITY_INDICATOR_BY_TABLE}
        ${is_granularity_visible}    Is Element Visible On Webpage    ${granularity_xpath}

        IF    not ${is_granularity_visible}    CONTINUE

        ${granularity_text}    Get Element Text On Webpage    ${granularity_xpath}
        ${granularity_text}    Strip String    ${granularity_text}

        # Skip if not a daily driver
        IF    '${granularity_text}' != 'D'    CONTINUE

        # Get driver name
        VAR    ${driver_name_xpath}    ${current_table_xpath}${FORECAST_REVIEW_DRIVER_NAME_SPAN_BY_TABLE}
        ${is_driver_name_visible}    Is Element Visible On Webpage    ${driver_name_xpath}

        IF    not ${is_driver_name_visible}    CONTINUE

        ${current_driver_name}    Get Element Text On Webpage    ${driver_name_xpath}
        ${current_driver_name}    Strip String    ${current_driver_name}

        # Check Weekly Adjusted Total (try input first, then span)
        VAR    ${weekly_adj_total_input_xpath}    ${current_table_xpath}${FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_INPUT_BY_TABLE}
        VAR    ${weekly_adj_total_span_xpath}    ${current_table_xpath}${FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_SPAN_BY_TABLE}

        ${is_input_visible}    Is Element Visible On Webpage    ${weekly_adj_total_input_xpath}
        ${is_span_visible}    Is Element Visible On Webpage    ${weekly_adj_total_span_xpath}

        IF    not ${is_input_visible} and not ${is_span_visible}    CONTINUE

        # Get total value - try textContent first, then value property
        VAR    ${total_value}    ${EMPTY}
        IF    ${is_input_visible}
            TRY
                ${total_value}    Get Element Text On Webpage    ${weekly_adj_total_input_xpath}
            EXCEPT
                VAR    ${total_value}    ${EMPTY}
            END
            # If text is empty, try value attribute
            IF    '${total_value}' == ''
                TRY
                    ${total_value}    Get Property    ${weekly_adj_total_input_xpath}    value
                EXCEPT
                    VAR    ${total_value}    ${EMPTY}
                END
            END
        END

        # If still empty, try span element
        IF    '${total_value}' == '' and ${is_span_visible}
            TRY
                ${total_value}    Get Element Text On Webpage    ${weekly_adj_total_span_xpath}
            EXCEPT
                VAR    ${total_value}    ${EMPTY}
            END
        END

        ${total_value}    Strip String    ${total_value}
        ${total_value_cleaned}    Evaluate
        ...    '${total_value}'.replace('$', '').replace('&nbsp;', '').replace(',', '').strip()

        ${is_total_valid}    Evaluate
        ...    len('${total_value_cleaned}') > 0 and '${total_value_cleaned}' != '0' and '${total_value_cleaned}' != '0.00'

        IF    not ${is_total_valid}    CONTINUE

        # Driver found - return name only
        VAR    &{eligible_driver_details}    driver_name=${current_driver_name}
        RETURN    &{eligible_driver_details}
    END

    Skip    No eligible daily driver found with non-empty Weekly Adjusted total

Get Driver Excel Name From Forecast Review Page On Web
    [Documentation]
    ...    Extracts the Excel name for a given driver from the Forecast Review page.
    ...    Searches for a td element containing the driver name in its title attribute.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The display name of the driver (e.g., "Driver2 for Forecast") |
    ...    | =Returns= | =Description= |
    ...    | driver_excel_name | The Excel identifier (e.g., "DRIVER2_F") |
    ...    Example usage:
    ...    | ${excel_name}    Get Driver Excel Name From Forecast Review Page On Web    Driver2 for Forecast
    [Arguments]    ${driver_name}

    # After search, the dropdown shows td with title = "EXCEL_NAME : Display Name"
    VAR    ${td_locator}    ${{$FORECAST_REVIEW_DROPDOWN_TD_BY_DRIVER.replace('{DRIVER_NAME}', $driver_name)}}
    Wait Until Element Is Visible On Webpage    ${td_locator}
    ${td_title}    Get Attribute    ${td_locator}    title
    ${driver_excel_name}    Evaluate    '${td_title}'.split(' : ')[0].strip()
    RETURN    ${driver_excel_name}

Get Weekly Adjusted Values For Driver On Web
    [Documentation]
    ...    Retrieves Weekly Adjusted total and last fiscal day of week value for a given driver.
    ...    Returns dictionary containing total value, last fiscal day value, and date column name.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The display name of the driver (e.g., "Driver2 for Forecast") |
    ...    | driver_excel_name | The Excel name of the driver (e.g., "DRIVER2_F") |
    ...    | =Returns= | =Description= |
    ...    | forecast_data | Dictionary with keys: total_value, last_fiscal_day_value, last_fiscal_day_column, driver_name, driver_excel_name |
    ...    Example usage:
    ...    | &{data}    Get Weekly Adjusted Values For Driver On Web    Driver2 for Forecast    DRIVER2_F
    [Arguments]    ${driver_name}    ${driver_excel_name}

    ${driver_table_locator}    Update Locator With Dynamic Values    ${FORECAST_REVIEW_DRIVER_TABLE_BY_NAME}    DRIVER_NAME=${driver_name}
    Wait Until Element Is Visible On Webpage    ${driver_table_locator}

    ${total_input_locator}    Evaluate    "${driver_table_locator}${FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_INPUT}"
    ${total_span_locator}    Evaluate    "${driver_table_locator}${FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_SPAN}"

    ${is_input_visible}    Is Element Visible On Webpage    ${total_input_locator}
    ${is_span_visible}    Is Element Visible On Webpage    ${total_span_locator}

    IF    ${is_input_visible}
        # Try to get text content from input element
        ${total_value}    Get Element Text On Webpage    ${total_input_locator}
        ${total_value}    Strip String    ${total_value}
        # If text is empty, try getting property value using JavaScript
        IF    '${total_value}' == ''
            ${total_value}    Get Property    ${total_input_locator}    textContent
            ${total_value}    Strip String    ${total_value}
        END
    ELSE IF    ${is_span_visible}
        ${total_value}    Get Element Text On Webpage    ${total_span_locator}
    ELSE
        Fail    Neither input nor span element found for Weekly Adjusted total
    END

    ${total_value}    Strip String    ${total_value}

    # Get last fiscal day of week date from header
    ${last_fiscal_day_header}    Get Element Text On Webpage    ${FORECAST_REVIEW_LAST_FISCAL_DAY_HEADER}
    ${last_fiscal_day_header}    Strip String    ${last_fiscal_day_header}

    ${last_fiscal_day_header_format}    Get Config Value    key=DATE_FMT_ABBR_WEEKDAY_DAY_MONTH
    ${server_date_format}    Get Config Value    key=SERVER_DF
    ${year}    Evaluate    __import__('datetime').datetime.now().year
    ${last_fiscal_day_column}    Evaluate
    ...    __import__('datetime').datetime.strptime('${last_fiscal_day_header}', '${last_fiscal_day_header_format}').replace(year=${year}).strftime('${server_date_format}')

    # Get last fiscal day of week input value using aria-label with dynamic date from header
    ${last_fiscal_day_input_locator}    Update Locator With Dynamic Values    ${FORECAST_REVIEW_WEEKLY_ADJUSTED_LAST_FISCAL_DAY_INPUT}
    ...    DRIVER_NAME=${driver_name}    LAST_DAY_OF_WEEK=${last_fiscal_day_header}
    Wait Until Element Is Visible On Webpage    ${last_fiscal_day_input_locator}
    ${last_fiscal_day_value}    Get Property    ${last_fiscal_day_input_locator}    value
    ${last_fiscal_day_value}    Strip String    ${last_fiscal_day_value}

    VAR    &{forecast_data}
    ...    total_value=${total_value}
    ...    last_fiscal_day_value=${last_fiscal_day_value}
    ...    last_fiscal_day_column=${last_fiscal_day_column}
    ...    last_fiscal_day_header=${last_fiscal_day_header}
    ...    driver_name=${driver_name}
    ...    driver_excel_name=${driver_excel_name}

    RETURN    &{forecast_data}

Export Forecast Review Data To Excel On Web
    [Documentation]
    ...    Exports forecast review data to Excel file by clicking More icon and Export To Excel option.
    ...    Returns the path of the downloaded Excel file.
    ...    | =Arguments= | =Description= |
    ...    | download_dir_path | Directory path where Excel file will be downloaded |
    ...    | =Returns= | =Description= |
    ...    | excel_file_path | Full path to the downloaded Excel file |
    ...    Example usage:
    ...    | ${file}    Export Forecast Review Data To Excel On Web    ${EXECDIR}/Downloads
    [Arguments]    ${download_dir_path}

    ${is_more_visible}    Is Element Visible On Webpage    ${FORECAST_REVIEW_MORE_ICON}
    IF    not ${is_more_visible}
        Fail    More icon is not visible on Forecast Review page
    END

    Click Element On Webpage    ${FORECAST_REVIEW_MORE_ICON}
    Wait Until Element Is Visible On Webpage    ${FORECAST_REVIEW_EXPORT_TO_EXCEL}

    ${download_promise}    Promise To Wait For Download    saveAs=${download_dir_path}
    Click Element On Webpage    ${FORECAST_REVIEW_EXPORT_TO_EXCEL}
    ${download_info}    Wait For    ${download_promise}

    ${excel_file_path}    Evaluate    $download_info["saveAs"]
    Log    Forecast Review Excel exported to: ${excel_file_path}
    RETURN    ${excel_file_path}

Update Weekly Adjusted Value On Forecast Review Page On Web
    [Documentation]
    ...    Updates Weekly Adjusted last fiscal day of week value for a specific driver with percentage increase.
    ...    Uses conditional logic: 50% increase for values ≤ $10, 10% increase for values > $10.
    ...    This ensures meaningful updates after integer rounding for small currency values.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The display name of the driver |
    ...    | current_value | Current last fiscal day of week value to be updated |
    ...    | =Returns= | =Description= |
    ...    | new_value_formatted | The new formatted value after percentage increase |
    ...    Example usage:
    ...    | ${new_val}    Update Weekly Adjusted Value On Forecast Review Page On Web    Driver2 for Forecast    $ 40
    [Arguments]    ${driver_name}    ${current_value}

    # Calculate new value with conditional percentage based on value threshold
    ${numeric_value}    Evaluate    float('${current_value}'.replace('$', '').replace(',', '').strip())

    # Use 50% for small values (≤ $10) to ensure meaningful change after rounding, 10% otherwise
    ${percentage_increase}    Evaluate    50 if ${numeric_value} <= 10 else 10

    ${new_value}    Evaluate    ${numeric_value} * (1 + ${percentage_increase} / 100.0)
    ${new_value_rounded}    Evaluate    round(${new_value})

    # Get last fiscal day of week date from header for dynamic locator
    ${last_fiscal_day_header}    Get Element Text On Webpage    ${FORECAST_REVIEW_LAST_FISCAL_DAY_HEADER}
    ${last_fiscal_day_header}    Strip String    ${last_fiscal_day_header}

    # Get last fiscal day of week input locator using aria-label with dynamic date
    ${last_fiscal_day_input_locator}    Update Locator With Dynamic Values    ${FORECAST_REVIEW_WEEKLY_ADJUSTED_LAST_FISCAL_DAY_INPUT}
    ...    DRIVER_NAME=${driver_name}    LAST_DAY_OF_WEEK=${last_fiscal_day_header}

    # Update the value
    Wait Until Element Is Visible On Webpage    ${last_fiscal_day_input_locator}
    Clear Textbox On Webpage    ${last_fiscal_day_input_locator}
    Fill Textbox On Webpage    ${last_fiscal_day_input_locator}    ${new_value_rounded}
    Keyboard Key    press    Tab

    # Wait for success message
    Wait Until Element Is Visible On Webpage    ${FORECAST_REVIEW_SUCCESS_MESSAGE}
    Wait Until Element Disappears On Webpage    ${FORECAST_REVIEW_SUCCESS_MESSAGE}

    RETURN    ${new_value_rounded}

Verify Forecast Review Values Updated Successfully On Web
    [Documentation]
    ...    Verifies that forecast values have been updated correctly by comparing initial and updated values.
    ...    | =Arguments= | =Description= |
    ...    | initial_forecast_data | Dictionary containing initial forecast values |
    ...    | updated_forecast_data | Dictionary containing updated forecast values |
    ...    Example usage:
    ...    | Verify Forecast Review Values Updated Successfully On Web    ${initial_data}    ${updated_data}
    [Arguments]    ${initial_forecast_data}    ${updated_forecast_data}

    ${initial_value}    Evaluate    $initial_forecast_data["last_fiscal_day_value"]
    ${updated_value}    Evaluate    $updated_forecast_data["last_fiscal_day_value"]

    ${initial_numeric}    Evaluate    float('${initial_value}'.replace('$', '').replace(',', '').strip())
    ${updated_numeric}    Evaluate    float('${updated_value}'.replace('$', '').replace(',', '').strip())

    Should Be True    ${updated_numeric} > ${initial_numeric}
    ...    msg=Updated value ${updated_numeric} should be greater than initial value ${initial_numeric}

Apply Drivers Filter On Forecast Review Page On Web
    [Documentation]
    ...    Applies Forecast Review filter for the provided driver codes.
    ...    | =Arguments= | =Description= |
    ...    | first_driver_code | First driver code to select in Drivers filter (e.g., PRE_VDPDRIVER01). |
    ...    | second_driver_code | Second driver code to select in Drivers filter (e.g., PRE_VDIDRIVER01). |
    ...    Example usage:
    ...    | Apply Drivers Filter On Forecast Review Page On Web    PRE_VDPDRIVER01    PRE_VDIDRIVER01
    [Arguments]    ${first_driver_code}    ${second_driver_code}

    Wait Until Element Is Visible On Webpage    ${FORECAST_REVIEW_FILTER_ICON}
    Click Element On Webpage    ${FORECAST_REVIEW_FILTER_ICON}
    Wait Until Element Is Visible On Webpage    ${FORECAST_REVIEW_DRIVER_FILTER_BUTTON}
    Click Element On Webpage    ${FORECAST_REVIEW_DRIVER_FILTER_BUTTON}

    ${first_driver_option}    Update Locator With Dynamic Values
    ...    ${FORECAST_REVIEW_DRIVER_FILTER_OPTION_BY_CODE}
    ...    DRIVER_CODE=${first_driver_code}
    ${second_driver_option}    Update Locator With Dynamic Values
    ...    ${FORECAST_REVIEW_DRIVER_FILTER_OPTION_BY_CODE}
    ...    DRIVER_CODE=${second_driver_code}

    Wait Until Element Is Visible On Webpage    ${first_driver_option}
    Click Element On Webpage    ${first_driver_option}
    Wait Until Element Is Visible On Webpage    ${second_driver_option}
    Click Element On Webpage    ${second_driver_option}

    Click Element On Webpage    ${FORECAST_REVIEW_APPLY_FILTER_BUTTON}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Normalize Forecast Value To Integer
    [Documentation]
    ...    Normalizes forecast value string by removing currency/formatting and returning rounded integer.
    ...    | =Arguments= | =Description= |
    ...    | value | Raw UI value (e.g., "$ 5,200" or "1000"). |
    ...    | =Returns= | =Description= |
    ...    | ${normalized_value} | Rounded integer value after cleanup. |
    [Arguments]    ${value}
    ${normalized_value}    Evaluate
    ...    int(round(float('${value}'.replace('$', '').replace(',', '').replace('\xa0', '').strip() or '0')))
    RETURN    ${normalized_value}

Get Weekly Adjusted Values For Driver On Forecast Review Page On Web
    [Documentation]
    ...    Gets Weekly Adjusted total and day-wise values for a driver from Forecast Review grid.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | Driver display name in Forecast Review grid (e.g., PRE VDI Store Driver01). |
    ...    | =Returns= | =Description= |
    ...    | &{driver_values} | Dictionary with keys total, day_1 to day_7. |
    [Arguments]    ${driver_name}

    ${total_input_locator}    Update Locator With Dynamic Values
    ...    ${FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_INPUT_BY_DRIVER}
    ...    DRIVER_NAME=${driver_name}
    ${is_total_input_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${total_input_locator}
    ...    timeout=${SHORT_TIMEOUT}
    IF    not ${is_total_input_visible}
        ${driver_row_locator}    Update Locator With Dynamic Values
        ...    ${FORECAST_REVIEW_DRIVER_ROW_BY_NAME}
        ...    DRIVER_NAME=${driver_name}
        ${is_driver_row_visible}    Is Element Visible On Webpage    ${driver_row_locator}
        IF    ${is_driver_row_visible}
            Click Element On Webpage    ${driver_row_locator}
            ...    error_message=Unable to click driver row for ${driver_name} on Forecast Review page
        END
        ${is_total_input_visible}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${total_input_locator}
        ...    timeout=${SHORT_TIMEOUT}
    END
    VAR    ${total_value}    ${EMPTY}
    IF    ${is_total_input_visible}
        ${total_value}    Get Property    ${total_input_locator}    value
        IF    '${total_value}' == ''
            ${total_value}    Get Element Text On Webpage    ${total_input_locator}
        END
    ELSE
        Log    Weekly Adjusted total input not visible for '${driver_name}'. Falling back to computed total from day values.    WARN
    END

    VAR    @{day_values}    @{EMPTY}
    FOR    ${day_index}    IN RANGE    1    8
        VAR    ${day_header_locator}    (${FORECAST_REVIEW_WEEK_DAY_HEADERS})[${day_index}]
        ${day_header}    Get Element Text On Webpage    ${day_header_locator}
        ${day_header}    Strip String    ${day_header}
        ${day_input_locator}    Update Locator With Dynamic Values
        ...    ${FORECAST_REVIEW_WEEKLY_ADJUSTED_DAY_INPUT_BY_DRIVER_AND_DAY}
        ...    DRIVER_NAME=${driver_name}
        ...    DAY_HEADER=${day_header}
        Wait Until Element Is Visible On Webpage    ${day_input_locator}
        ${day_value}    Get Property    ${day_input_locator}    value
        IF    '${day_value}' == ''
            ${day_value}    Get Element Text On Webpage    ${day_input_locator}
        END
        Append To List    ${day_values}    ${day_value}
    END

    IF    '${total_value}' == ''
        ${total_value}    Evaluate
        ...    int(round(sum(float(str(v).replace('$', '').replace(',', '').replace('\xa0', '').strip() or '0') for v in $day_values)))
    END

    VAR    &{driver_values}
    ...    total=${total_value}
    ...    day_1=${day_values}[0]
    ...    day_2=${day_values}[1]
    ...    day_3=${day_values}[2]
    ...    day_4=${day_values}[3]
    ...    day_5=${day_values}[4]
    ...    day_6=${day_values}[5]
    ...    day_7=${day_values}[6]
    RETURN    &{driver_values}

Verify Weekly Adjusted Values For Driver On Forecast Review Page On Web
    [Documentation]
    ...    Verifies Weekly Adjusted total and all day-wise values for a specific driver.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | Driver display name in Forecast Review grid. |
    ...    | expected_values | Dictionary keys: total, day_1, day_2, day_3, day_4, day_5, day_6, day_7. |
    [Arguments]    ${driver_name}    ${expected_values}

    &{actual_driver_values}    Get Weekly Adjusted Values For Driver On Forecast Review Page On Web    ${driver_name}

    ${actual_total}    Normalize Forecast Value To Integer    ${actual_driver_values}[total]
    ${actual_day_1}    Normalize Forecast Value To Integer    ${actual_driver_values}[day_1]
    ${actual_day_2}    Normalize Forecast Value To Integer    ${actual_driver_values}[day_2]
    ${actual_day_3}    Normalize Forecast Value To Integer    ${actual_driver_values}[day_3]
    ${actual_day_4}    Normalize Forecast Value To Integer    ${actual_driver_values}[day_4]
    ${actual_day_5}    Normalize Forecast Value To Integer    ${actual_driver_values}[day_5]
    ${actual_day_6}    Normalize Forecast Value To Integer    ${actual_driver_values}[day_6]
    ${actual_day_7}    Normalize Forecast Value To Integer    ${actual_driver_values}[day_7]

    Should Be Equal As Integers    ${actual_total}    ${expected_values}[total]
    ...    msg=Weekly Adjusted total mismatch for driver '${driver_name}'.
    Should Be Equal As Integers    ${actual_day_1}    ${expected_values}[day_1]
    ...    msg=Day 1 value mismatch for driver '${driver_name}'.
    Should Be Equal As Integers    ${actual_day_2}    ${expected_values}[day_2]
    ...    msg=Day 2 value mismatch for driver '${driver_name}'.
    Should Be Equal As Integers    ${actual_day_3}    ${expected_values}[day_3]
    ...    msg=Day 3 value mismatch for driver '${driver_name}'.
    Should Be Equal As Integers    ${actual_day_4}    ${expected_values}[day_4]
    ...    msg=Day 4 value mismatch for driver '${driver_name}'.
    Should Be Equal As Integers    ${actual_day_5}    ${expected_values}[day_5]
    ...    msg=Day 5 value mismatch for driver '${driver_name}'.
    Should Be Equal As Integers    ${actual_day_6}    ${expected_values}[day_6]
    ...    msg=Day 6 value mismatch for driver '${driver_name}'.
    Should Be Equal As Integers    ${actual_day_7}    ${expected_values}[day_7]
    ...    msg=Day 7 value mismatch for driver '${driver_name}'.

Generate Forecast For Marker Validation Weeks Via API
    [Documentation]
    ...    Generates forecast via API for all weeks defined in marker scenario data.
    ...    | =Arguments= | =Description= |
    ...    | marker_data | Marker scenario data containing forecast week offsets. |
    ...    | sm_user | Store manager user dictionary used for forecast generation. |
    ...    Example usage:
    ...    | Generate Forecast For Marker Validation Weeks Via API    ${marker_data}    ${sm_user}
    [Arguments]    ${marker_data}    ${sm_user}

    ${server_date_format}    Get Config Value    SERVER_DF
    FOR    ${forecast_week}    IN    @{marker_data}[forecast_weeks]
        VAR    ${week_offset}    ${forecast_week}[week_offset]
        ${week_start_date}    Calculate Week Start Date From Week Day Offset    ${week_offset}    date_format=${server_date_format}
        Generate Forecast Via API    ${sm_user}[unitID]    ${week_offset}    ${sm_user}[user_key]
        ${retry}    ${retry_interval}    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
        Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Forecast Generated For Week
        ...    ${sm_user}[user_key]
        ...    ${sm_user}[unitID]
        ...    ${week_start_date}
    END

Verify Marker Forecast Review Values On Web
    [Documentation]
    ...    Validates Forecast Review values for all weeks and both drivers defined in marker scenario data.
    ...    | =Arguments= | =Description= |
    ...    | marker_data | Marker scenario data containing week expectations and driver metadata. |
    ...    Example usage:
    ...    | Verify Marker Forecast Review Values On Web    ${marker_data}
    [Arguments]    ${marker_data}

    FOR    ${forecast_week}    IN    @{marker_data}[forecast_weeks]
        VAR    ${week_offset}    ${forecast_week}[week_offset]
        VAR    ${expected_values}    ${forecast_week}[expected_values]
        Navigate To Forecast Review Page On Web
        Select Week Number On Forecast Review Page On Web    ${week_offset}
        Apply Drivers Filter On Forecast Review Page On Web
        ...    ${marker_data}[driver_codes][vdp]
        ...    ${marker_data}[driver_codes][vdi]

        Verify Weekly Adjusted Values For Driver On Forecast Review Page On Web
        ...    ${marker_data}[driver_names][vdp]
        ...    ${expected_values}
        Verify Weekly Adjusted Values For Driver On Forecast Review Page On Web
        ...    ${marker_data}[driver_names][vdi]
        ...    ${expected_values}
        Capture Screenshot On Webpage
    END

Select Week Number On Forecast Review Page On Web
    [Documentation]    Selects week number on Week Schedule page on web using week_day format
    ...    | =Arguments=    | =Description= |
    ...    | week_day_input    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    [Arguments]    ${week_day_input}
    ${target_date}    Calculate Date From Week Day Offset    ${week_day_input}
    ${week_label_date_format}    Get Config Value    DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA
    ${week_label_date}    Calculate Week Start Date From Week Day Offset    ${week_day_input}    date_format=${week_label_date_format}
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
        Click Element On Webpage    ${FIXEDSHIFTSPAGE_YEAR_BUTTON_DYNAMIC_BY_YEAR}
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
    Wait Until Element Disappears On Webpage    ${FIXEDSHIFTPAGE_CALENDAR_POP_UP}
    ${week_label_locator}    Update Locator With Dynamic Values    ${WEEKSCHEDULEPAGE_HEADER_WEEK_LABEL}    WEEK=${week_label_date}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${week_label_locator}    timeout=${LONG_TIMEOUT}
    Capture Screenshot On Webpage

Revert Weekly Adjusted Value On Forecast Review Page On Web
    [Documentation]
    ...    Reverts Weekly Adjusted last fiscal day of week value back to original value for test data cleanup.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The display name of the driver |
    ...    | original_value | The original value to restore |
    ...    Example usage:
    ...    | Revert Weekly Adjusted Value On Forecast Review Page On Web    Driver2 for Forecast    40
    [Arguments]    ${driver_name}    ${original_value}

    # Get last fiscal day of week date from header for dynamic locator
    ${last_fiscal_day_header}    Get Element Text On Webpage    ${FORECAST_REVIEW_LAST_FISCAL_DAY_HEADER}
    ${last_fiscal_day_header}    Strip String    ${last_fiscal_day_header}

    # Get last fiscal day of week input locator using aria-label with dynamic date
    ${last_fiscal_day_input_locator}    Update Locator With Dynamic Values    ${FORECAST_REVIEW_WEEKLY_ADJUSTED_LAST_FISCAL_DAY_INPUT}
    ...    DRIVER_NAME=${driver_name}    LAST_DAY_OF_WEEK=${last_fiscal_day_header}

    # Restore original value
    Wait Until Element Is Visible On Webpage    ${last_fiscal_day_input_locator}
    Clear Textbox On Webpage    ${last_fiscal_day_input_locator}
    Fill Textbox On Webpage    ${last_fiscal_day_input_locator}    ${original_value}
    Keyboard Key    press    Tab

    Wait Until Element Is Visible On Webpage    ${FORECAST_REVIEW_SUCCESS_MESSAGE}
    Wait Until Element Disappears On Webpage    ${FORECAST_REVIEW_SUCCESS_MESSAGE}

Expand Markers Tab On Forecast Review Page On Web
    [Documentation]
    ...    Expands the Markers tab on the Forecast Review page to display existing markers.
    ...    Verifies that the markers section is visible after clicking the tab.
    ...    Example usage:
    ...    | Expand Markers Tab On Forecast Review Page On Web |
    Click Element On Webpage    ${FORECAST_REVIEW_MARKERS_TAB}
    ...    error_message=Failed to click on Markers tab on Forecast Review page
    Wait Until Element Is Visible On Webpage    ${FORECAST_REVIEW_MARKERS_TAB}.active-tab
    ...    error_message=Markers tab did not become active on Forecast Review page
    Capture Screenshot On Webpage

Expand Add Marker Tab On Forecast Review Page On Web
    [Documentation]
    ...    Expands the Add Marker tab on the Forecast Review page to allow adding a new marker.
    ...    Verifies that the add marker form is visible after clicking the tab.
    ...    Example usage:
    ...    | Expand Add Marker Tab On Forecast Review Page On Web |
    Click Element On Webpage    ${FORECAST_REVIEW_ADD_MARKER_TAB}
    ...    error_message=Failed to click on Add Marker tab on Forecast Review page
    Wait Until Element Is Visible On Webpage    ${FORECAST_REVIEW_ADD_MARKER_TAB}.active-tab
    ...    error_message=Add Marker tab did not become active on Forecast Review page
    Capture Screenshot On Webpage
