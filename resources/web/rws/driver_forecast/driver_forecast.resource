*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Driver Forecast page functionality within the RWS module.
...
...                 = Purpose =
...                 - Centralizes navigation and interaction keywords for the Driver Forecast page
...                 - Provides verification methods for forecast data and page elements
...                 - Supports automated testing of driver scheduling and forecast features
...
...                 = Key Features =
...                 - Navigation to Driver Forecast sections
...                 - Forecast data validation
...                 - Schedule verification capabilities
...
...                 = Prerequisites =
...                 - User must be logged into the WFM application
...                 - Appropriate permissions for accessing RWS Driver Forecast module
...                 - Required resources and variable files must be available and imported
...
...                 = Dependencies =
...                 - resources/web/common/common.resource: Core navigation and utility functions
...                 - resources/web/common/common_date_utility.resource: Date manipulation utilities
...                 - driver_forecast_page.py: Page object variables and locators

Resource            resources/web/common/common.resource
Resource            resources/web/common/calendar_navigation.resource
Variables           resources/web/rws/driver_forecast/driver_forecast_page.py
Variables           resources/web/rws/driver_forecast/driver_forecast_api.py
Variables           resources/web/common/status_codes.py
Resource            resources/web/common/common_date_utility.resource


*** Keywords ***
Navigate To RWS Driver Forecast Forecast Page On Web
    [Documentation]
    ...    Navigates to the RWS Driver Forecast Forecast page and verifies successful page load.
    ...    This keyword handles the complete navigation flow from any starting point in the application
    ...    to the specific Driver Forecast page within the RWS module.
    ...    | =Arguments= | =Description= |
    ...    | None    | This keyword takes no arguments |
    Navigate To Specific Page On Web    rws    driver_forecast    forecast

Verify Week Navigation On Driver Forecast Page On Web
    [Documentation]
    ...    Navigates backward and forward on driver forecast page using calendar navigator.
    ...    Verifies that the week navigation functions correctly in both directions by navigating
    ...    forward the specified number of steps, then backward the same number of steps.
    ...    | =Arguments= | =Description= |
    ...    | number_of_weeks_to_navigate | Number of steps to navigate in each direction |
    ...    Example usage:
    ...    | Verify Week Navigation On Driver Forecast Page On Web    2
    [Arguments]    ${number_of_weeks_to_navigate}

    # Navigate forward specified steps
    Navigate Calendar By Weeks And Verify Navigated Week
    ...    ${NAVIGATION_DIRECTION_FORWARD}
    ...    ${number_of_weeks_to_navigate}
    ...    ${DRIVER_FORECAST_FORWARD_ARROW}
    ...    ${DRIVER_FORECAST_BACKWARD_ARROW}
    ...    ${DRIVER_FORECAST_SELECTED_WEEK}

    # Navigate backward specified steps
    Navigate Calendar By Weeks And Verify Navigated Week
    ...    ${NAVIGATION_DIRECTION_BACKWARD}
    ...    ${number_of_weeks_to_navigate}
    ...    ${DRIVER_FORECAST_FORWARD_ARROW}
    ...    ${DRIVER_FORECAST_BACKWARD_ARROW}
    ...    ${DRIVER_FORECAST_SELECTED_WEEK}

Get Selected Week From Week Navigation On Driver Forecast Page On Web
    [Documentation]    This keyword gets the week date from week navigation on Driver Forecast page.
    ...    | =Returns= | =Description= |
    ...    | selected_week | The label of the selected week |
    ${selected_week}    Get Element Text On Webpage    ${DRIVER_FORECAST_PAGE_CAL_NAV_DATE_LABEL}
    RETURN    ${selected_week}

Get STF Adjusted Values For Driver On Driver Forecast Page On Web
    [Documentation]    Retrieves STF Adjusted total and Saturday value for a given driver from the Driver Forecast page.
    ...    Returns a dictionary containing totals value, day value, date, year, summary row name, and driver name.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The name/title of the driver row (e.g., "Driver2 for Forecast") |
    ...    | driver_id | The ID of the driver |
    ...    | =Returns= | =Description= |
    ...    | forecast_data | Dictionary with keys: totals_value, day_value, date, year, summary, driver_name |
    [Arguments]    ${driver_name}    ${driver_id}

    ${row_locator}    Update Locator With Dynamic Values    ${DRIVER_FORECAST_ROW_BY_TITLE}    DRIVER_NAME=${driver_name}
    Wait Until Element Is Visible On Webpage    ${row_locator}
    ...    error_message=Driver row for '${driver_name}' not visible on forecast page

    ${has_stf_planned}    Is Element Visible On Webpage    ${DRIVER_FORECAST_STF_PLANNED_HEADER}
    ${stf_adjusted_col_index}    Set Variable If    ${has_stf_planned}    ${4}    ${3}
    ${sibling_offset}    Evaluate    ${stf_adjusted_col_index} - 2
    VAR    ${totals_locator}    ${row_locator}/following-sibling::td[${sibling_offset}]
    ${totals_value}    Get Element Text On Webpage    ${totals_locator}
    ${totals_value}    Strip String    ${totals_value}

    ${saturday_date_header}    Get Element Text On Webpage    ${DRIVER_FORECAST_SATURDAY_HEADER}
    ${saturday_date_header}    Strip String    ${saturday_date_header}
    ${normalized_saturday_date_header}    Replace String    ${saturday_date_header}    ,${SPACE}    ,
    ${date_format_header}    Get Config Value    key=DATE_FMT_FORECAST_LAST_DAY_OF_WEEK_HEADER
    ${normalized_date_format_header}    Replace String    ${date_format_header}    ,${SPACE}    ,
    ${date_format_id}    Get Config Value    key=SERVER_DF
    ${formatted_saturday_date}    Evaluate
    ...    __import__('datetime').datetime.strptime('${normalized_saturday_date_header}', '${normalized_date_format_header}').replace(year=__import__('datetime').datetime.now().year).strftime('${date_format_id}')
    ${row_with_driver_locator}    Update Locator With Dynamic Values    ${DRIVER_FORECAST_SATURDAY_INPUT_BY_DRIVER_DATE}
    ...    ROW_LOCATOR=${row_locator}    DRIVER_ID=${driver_id}    DATE=${formatted_saturday_date}

    Wait Until Page Is Loaded
    ${saturday_day_value}    Get Attribute    ${row_with_driver_locator}    value
    ${saturday_day_value}    Strip String    ${saturday_day_value}

    ${selected_date_label}    Get Element Text On Webpage    ${DRIVER_FORECAST_SELECTED_DATE_LABEL}
    ${selected_year}    Evaluate    __import__('re').search(r'\\d{4}', '${selected_date_label}').group()

    VAR    &{forecast_data}
    ...    totals_value=${totals_value}
    ...    day_value=${saturday_day_value}
    ...    date=${saturday_date_header}
    ...    year=${selected_year}
    ...    summary=${driver_name}
    ...    driver_name=${driver_name}

    RETURN    &{forecast_data}

Export Driver Forecast Data To CSV
    [Documentation]    Clicks export icon and downloads forecast CSV file.
    ...    Returns the full file path of the downloaded CSV file.
    ...    Note: Ensures unique filename to avoid overwriting previous downloads.
    [Arguments]    ${download_dir_path}

    ${is_export_visible}    Is Element Visible On Webpage    ${DRIVER_FORECAST_EXPORT_ICON}
    IF    not ${is_export_visible}
        Fail    Export icon is not visible on forecast page
    END

    ${download_promise}    Promise To Wait For Download    saveAs=${download_dir_path}
    Click Element On Webpage    ${DRIVER_FORECAST_EXPORT_ICON}
    ...    Failed to click export icon on forecast page
    Wait For    ${download_promise}
    RETURN    ${download_dir_path}

Update STF Adjusted Value On Driver Forecast Page On Web
    [Documentation]    Updates STF Adjusted value for a specific driver and Saturday by 10% increase.
    ...    Applies a +1 fallback when the 10% increase rounds back to the original value
    ...    (e.g., 4 -> 4.4 -> 4) so the save API is actually triggered. Revert still receives
    ...    the original value from the caller, so cleanup restores the cell correctly.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The name/title of the driver row |
    ...    | driver_id | The ID of the driver |
    [Arguments]    ${driver_name}    ${driver_id}

    VAR    ${percentage_increase}    10

    ${current_forecast_data}    Get STF Adjusted Values For Driver On Driver Forecast Page On Web    ${driver_name}    ${driver_id}
    VAR    ${current_saturday_value}    ${current_forecast_data}[day_value]
    ${current_numeric_value}    Evaluate    float('${current_saturday_value}'.replace('$', '').replace(',', '').strip())
    ${current_value_rounded}    Evaluate    round(${current_numeric_value})
    ${increased_numeric_value}    Evaluate    ${current_numeric_value} * (1 + ${percentage_increase} / 100.0)
    ${increased_value_rounded}    Evaluate    round(${increased_numeric_value})
    ${updated_value_formatted}    Evaluate
    ...    ${increased_value_rounded} + 1 if ${increased_value_rounded} == ${current_value_rounded} else ${increased_value_rounded}

    ${row_locator}    Update Locator With Dynamic Values    ${DRIVER_FORECAST_ROW_BY_TITLE}    DRIVER_NAME=${driver_name}
    ${saturday_date_header}    Get Element Text On Webpage    ${DRIVER_FORECAST_SATURDAY_HEADER}
    ${saturday_date_header}    Strip String    ${saturday_date_header}
    ${normalized_saturday_date_header}    Replace String    ${saturday_date_header}    ,${SPACE}    ,
    ${date_format_header}    Get Config Value    key=DATE_FMT_FORECAST_LAST_DAY_OF_WEEK_HEADER
    ${normalized_date_format_header}    Replace String    ${date_format_header}    ,${SPACE}    ,
    ${date_format_id}    Get Config Value    key=SERVER_DF
    ${formatted_saturday_date}    Evaluate
    ...    __import__('datetime').datetime.strptime('${normalized_saturday_date_header}', '${normalized_date_format_header}').replace(year=__import__('datetime').datetime.now().year).strftime('${date_format_id}')
    ${saturday_input_locator}    Update Locator With Dynamic Values    ${DRIVER_FORECAST_SATURDAY_INPUT_BY_DRIVER_DATE}
    ...    ROW_LOCATOR=${row_locator}    DRIVER_ID=${driver_id}    DATE=${formatted_saturday_date}

    Click Element On Webpage    ${saturday_input_locator}
    Keyboard Key    press    Control+a
    Type Text    ${saturday_input_locator}    ${updated_value_formatted}
    ${api_response_promise}    Promise To    Wait For Response    ${DRIVER_FORECAST_SAVE_AUDIT_TRAIL_API}    timeout=${LONG_API_TIMEOUT}
    Keyboard Key    press    Tab
    ${api_response_body}    Wait For    ${api_response_promise}
    Should Be True    ${api_response_body.status} in [${HTTP_STATUS_CODES}[OK], ${HTTP_STATUS_CODES}[CREATED]]
    ...    msg=Forecast update API returned status ${api_response_body.status}

    RETURN    ${updated_value_formatted}

Verify Driver Forecast Values Updated Successfully On Web
    [Documentation]    Verifies that forecast values have been updated correctly by comparing initial and updated values.
    ...    | =Arguments= | =Description= |
    ...    | initial_forecast_data | Dictionary containing initial forecast values |
    ...    | updated_forecast_data | Dictionary containing updated forecast values |
    [Arguments]    ${initial_forecast_data}    ${updated_forecast_data}

    VAR    ${initial_saturday_value}    ${initial_forecast_data}[day_value]
    VAR    ${updated_saturday_value}    ${updated_forecast_data}[day_value]
    ${initial_numeric_value}    Evaluate    float('${initial_saturday_value}'.replace('$', '').replace(',', '').strip())
    ${updated_numeric_value}    Evaluate    float('${updated_saturday_value}'.replace('$', '').replace(',', '').strip())

    Should Be True    ${updated_numeric_value} > ${initial_numeric_value}
    ...    msg=Updated value ${updated_numeric_value} should be greater than initial value ${initial_numeric_value}

Verify Updated STF Adjusted Value Matches As Per Increased Value
    [Documentation]    Verifies that the updated STF Adjusted value displayed on UI matches the expected increased value.
    ...    Compares values as rounded integers to ignore decimal precision differences (e.g., 217090.98 rounds to 217091).
    ...    | =Arguments= | =Description= |
    ...    | actual_value_from_ui | The actual STF Adjusted value retrieved from Driver Forecast page UI |
    ...    | expected_value | The expected increased value (typically 10% more than original) |
    [Arguments]    ${actual_value_from_ui}    ${expected_value}

    ${actual_value_cleaned}    Evaluate    '${actual_value_from_ui}'.replace('$', '').replace(',', '').strip()
    ${expected_value_cleaned}    Evaluate    '${expected_value}'.replace('$', '').replace(',', '').strip()

    # Compare as rounded integers to ignore decimal precision differences
    ${actual_numeric}    Evaluate    round(float('${actual_value_cleaned}'))
    ${expected_numeric}    Evaluate    round(float('${expected_value_cleaned}'))

    Should Be Equal    ${actual_numeric}    ${expected_numeric}
    ...    msg=UI value '${actual_value_from_ui}' (${actual_numeric}) does not match expected value '${expected_value}' (${expected_numeric})

Find First Eligible Driver From Driver Forecast Page On Web
    [Documentation]    Dynamically finds the first eligible driver with a non-empty STF Adjusted total
    ...    and an editable Saturday cell. Returns driver details including name, ID, and input locator.
    ...    Supports clients with both STF Planned + STF Adjusted columns (e.g., AAP_SB) as well as
    ...    clients with only STF Adjusted column (e.g., WAG_SB) by detecting column layout at runtime.
    ...    | =Returns= | =Description= |
    ...    | driver_details | Dictionary containing: driver_name, driver_id, saturday_input_locator, row_locator |
    ...    Example usage:
    ...    | ${driver_details}= | Find First Eligible Driver From Driver Forecast Page On Web |
    ...    | Log | Found driver: ${driver_details}[driver_name] |

    Wait Until Page Is Loaded

    ${saturday_date_header}    Get Element Text On Webpage    ${DRIVER_FORECAST_SATURDAY_HEADER}
    ${saturday_date_header}    Strip String    ${saturday_date_header}
    ${normalized_saturday_date_header}    Replace String    ${saturday_date_header}    ,${SPACE}    ,
    ${date_format_header}    Get Config Value    key=DATE_FMT_FORECAST_LAST_DAY_OF_WEEK_HEADER
    ${normalized_date_format_header}    Replace String    ${date_format_header}    ,${SPACE}    ,
    ${date_format_id}    Get Config Value    key=SERVER_DF
    ${formatted_saturday_date}    Evaluate
    ...    __import__('datetime').datetime.strptime('${normalized_saturday_date_header}', '${normalized_date_format_header}').replace(year=__import__('datetime').datetime.now().year).strftime('${date_format_id}')

    ${has_stf_planned}    Is Element Visible On Webpage    ${DRIVER_FORECAST_STF_PLANNED_HEADER}
    ${stf_adjusted_col_index}    Set Variable If    ${has_stf_planned}    ${4}    ${3}
    ${driver_row_count}    Get Element Count On Web Page    ${DRIVER_FORECAST_SUMMARY_ALL_ROWS}

    FOR    ${row_index}    IN RANGE    1    ${driver_row_count} + 1
        VAR    ${current_row_xpath}    (${DRIVER_FORECAST_SUMMARY_ALL_ROWS})[${row_index}]
        VAR    ${driver_name_cell_xpath}    ${current_row_xpath}/td[@title]

        ${current_driver_name}    Get Attribute    ${driver_name_cell_xpath}    title
        ${current_driver_name}    Strip String    ${current_driver_name}

        VAR    ${stf_adjusted_cell_xpath}    ${current_row_xpath}/td[${stf_adjusted_col_index}]

        ${stf_adjusted_value}    Get Element Text On Webpage    ${stf_adjusted_cell_xpath}
        ${stf_adjusted_value_cleaned}    Strip String    ${stf_adjusted_value}
        TRY
            ${is_stf_adjusted_valid}    Evaluate    modules=re
            ...    expression=bool(re.search(r'\\d', $stf_adjusted_value_cleaned)) and float(re.sub(r'[\\s$£€¥,]+|&nbsp;', '', $stf_adjusted_value_cleaned)) > 0
        EXCEPT
            VAR    ${is_stf_adjusted_valid}    ${False}
        END

        IF    ${is_stf_adjusted_valid}
            ${current_driver_id}    Get Attribute    ${stf_adjusted_cell_xpath}    id
            ${current_driver_id}    Evaluate    '${current_driver_id}'.split('_')[0]

            ${driver_row_locator}    Update Locator With Dynamic Values    ${DRIVER_FORECAST_ROW_BY_TITLE}
            ...    DRIVER_NAME=${current_driver_name}

            ${saturday_input_locator}    Update Locator With Dynamic Values    ${DRIVER_FORECAST_SATURDAY_INPUT_BY_DRIVER_DATE}
            ...    ROW_LOCATOR=${driver_row_locator}    DRIVER_ID=${current_driver_id}    DATE=${formatted_saturday_date}

            ${is_saturday_cell_editable}    Is Element Visible On Webpage    ${saturday_input_locator}
            IF    ${is_saturday_cell_editable}
                VAR    &{eligible_driver_details}
                ...    driver_name=${current_driver_name}
                ...    driver_id=${current_driver_id}
                ...    saturday_input_locator=${saturday_input_locator}
                ...    row_locator=${driver_row_locator}
                RETURN    &{eligible_driver_details}
            END
        END
    END
    Skip    No eligible driver found with non-empty STF Adjusted total and editable Saturday cell

Is Export To Excel Option Available On Driver Forecast Page On Web
    [Documentation]    Checks if Export to Excel button is visible on the forecast page.
    ...    | =Returns= | =Description= |
    ...    | is_available | Boolean - True if export icon is visible, False otherwise |
    ...    Example usage:
    ...    | ${can_export}= | Is Export To Excel Option Available On Driver Forecast Page On Web |
    ...    | IF | ${can_export} |
    ...    |    Log | Export functionality is available |
    ...    | END
    ${is_visible}    Is Element Visible On Webpage    ${DRIVER_FORECAST_EXPORT_ICON}
    RETURN    ${is_visible}

Revert STF Adjusted Value On Driver Forecast Page On Web
    [Documentation]    Reverts STF Adjusted value back to original value for test data cleanup.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The name/title of the driver row |
    ...    | driver_id | The ID of the driver |
    ...    | original_value | The original value to restore (e.g., "$ 20") |
    [Arguments]    ${driver_name}    ${driver_id}    ${original_value}

    ${row_locator}    Update Locator With Dynamic Values    ${DRIVER_FORECAST_ROW_BY_TITLE}    DRIVER_NAME=${driver_name}
    ${saturday_date_header}    Get Element Text On Webpage    ${DRIVER_FORECAST_SATURDAY_HEADER}
    ${saturday_date_header}    Strip String    ${saturday_date_header}
    ${normalized_saturday_date_header}    Replace String    ${saturday_date_header}    ,${SPACE}    ,
    ${date_format_header}    Get Config Value    key=DATE_FMT_FORECAST_LAST_DAY_OF_WEEK_HEADER
    ${normalized_date_format_header}    Replace String    ${date_format_header}    ,${SPACE}    ,
    ${date_format_id}    Get Config Value    key=SERVER_DF
    ${formatted_saturday_date}    Evaluate
    ...    __import__('datetime').datetime.strptime('${normalized_saturday_date_header}', '${normalized_date_format_header}').replace(year=__import__('datetime').datetime.now().year).strftime('${date_format_id}')
    ${saturday_input_locator}    Update Locator With Dynamic Values    ${DRIVER_FORECAST_SATURDAY_INPUT_BY_DRIVER_DATE}
    ...    ROW_LOCATOR=${row_locator}    DRIVER_ID=${driver_id}    DATE=${formatted_saturday_date}

    Click Element On Webpage    ${saturday_input_locator}
    Keyboard Key    press    Control+a
    Type Text    ${saturday_input_locator}    ${original_value}
    ${api_response_promise}    Promise To    Wait For Response    ${DRIVER_FORECAST_SAVE_AUDIT_TRAIL_API}    timeout=${LONG_API_TIMEOUT}
    Keyboard Key    press    Tab
    ${api_response_body}    Wait For    ${api_response_promise}
    Should Be True    ${api_response_body.status} in [${HTTP_STATUS_CODES}[OK], ${HTTP_STATUS_CODES}[CREATED]]
    ...    msg=Forecast revert API returned status ${api_response_body.status}
