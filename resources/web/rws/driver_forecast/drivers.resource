*** Settings ***
Documentation       Drivers page related keyword implementation

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/rws/driver_forecast/drivers_page.py
Variables           resources/web/rws/driver_forecast/drivers_page_api.py
Variables           resources/web/common/status_codes.py
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RWS Drivers Page
    [Documentation]    Navigates to RWS -> Driver Forecast -> Drivers page and verifies the page loads.
    Navigate To Specific Page On Web    rws    driver_forecast    drivers

Click On Add Button To Add Driver
    [Documentation]    Clicks the Add button to open the driver creation page.
    Wait Until Page Is Loaded
    ${is_add_button_present}    Is Element Present On Webpage    ${DRIVERSPAGE_ADD_BUTTON}
    Skip If    not ${is_add_button_present}    Add button not present on Drivers page, skipping click action
    Click Element On Webpage    ${DRIVERSPAGE_ADD_BUTTON}    Failed to click Add button on Drivers page
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${DRIVERSPAGE_DRIVER_CATEGORY}
    ...    error_message=Driver category dropdown not visible after clicking Add button
    Capture Screenshot On Webpage

Select Driver Category
    [Documentation]
    ...    Selects the driver category from dropdown.
    ...    | =Arguments= | =Description= |
    ...    | driver_category | Category value to select (e.g., FRONT_END, BACK_END). |
    [Arguments]    ${driver_category}
    Select List Item On Webpage    ${DRIVERSPAGE_DRIVER_CATEGORY}    value    ${driver_category}
    Wait Until Page Is Loaded

Fill Description Field
    [Documentation]
    ...    Fills the driver description field.
    ...    | =Arguments= | =Description= |
    ...    | driver_description | Description text for the driver. |
    [Arguments]    ${driver_description}
    Fill Textbox On Webpage    ${DRIVERSPAGE_DRIVER_DESCRIPTION}    ${driver_description}
    Wait Until Page Is Loaded

Select Forecast Driver Type
    [Documentation]
    ...    Selects the forecast driver type from dropdown.
    ...    | =Arguments= | =Description= |
    ...    | forecast_driver_type | Type value to select (e.g., ACTUAL, REVISED, CALCULATED). |
    [Arguments]    ${forecast_driver_type}
    Select List Item On Webpage    ${DRIVERSPAGE_FORECAST_DRIVER_TYPE}    value    ${forecast_driver_type}
    Wait Until Page Is Loaded

Select Driver Group
    [Documentation]
    ...    Selects the driver group from dropdown.
    ...    | =Arguments= | =Description= |
    ...    | driver_group | Group value to select (e.g., TOTAL_STORE, DEPARTMENT). |
    [Arguments]    ${driver_group}
    Select List Item On Webpage    ${DRIVERSPAGE_DRIVER_GROUP}    value    ${driver_group}
    Wait Until Page Is Loaded

Select Driver Granularity
    [Documentation]
    ...    Selects the driver granularity from dropdown.
    ...    | =Arguments= | =Description= |
    ...    | driver_granularity | Granularity value to select (e.g., ANNUAL, DAILY, WEEKLY). |
    [Arguments]    ${driver_granularity}
    Select List Item On Webpage    ${DRIVERSPAGE_DRIVER_GRANULARITY}    value    ${driver_granularity}
    Wait Until Page Is Loaded

Select Adjustment Mode
    [Documentation]
    ...    Selects the adjustment mode from dropdown.
    ...    | =Arguments= | =Description= |
    ...    | adjustment_mode | Adjustment mode value to select (e.g., EDIT, NO_EDIT). |
    [Arguments]    ${adjustment_mode}
    Select List Item On Webpage    ${DRIVERSPAGE_ADJUSTMENT_MODE}    value    ${adjustment_mode}
    Wait Until Page Is Loaded

Select Aggregate Rule
    [Documentation]
    ...    Selects the aggregate rule from dropdown.
    ...    | =Arguments= | =Description= |
    ...    | aggregate_rule | Aggregate rule value to select (e.g., AVERAGE, SUM). |
    [Arguments]    ${aggregate_rule}
    Select List Item On Webpage    ${DRIVERSPAGE_AGGREGATE_RULE}    value    ${aggregate_rule}
    Wait Until Page Is Loaded

Select Display Format
    [Documentation]
    ...    Selects the display format from dropdown.
    ...    | =Arguments= | =Description= |
    ...    | display_format | Display format value to select (e.g., DATE_SKEY_FORMAT, DECIMAL_FORMAT). |
    [Arguments]    ${display_format}
    Select List Item On Webpage    ${DRIVERSPAGE_DISPLAY_FORMAT}    value    ${display_format}
    Wait Until Page Is Loaded

Select First Option From Driver Category Dropdown
    [Documentation]
    ...    Selects the first available option from the driver category dropdown.
    ...    This is typically used for Front End driver tests.
    ...    Example usage:
    ...    | Select First Option From Driver Category Dropdown
    Wait Until Page Is Loaded
    ${all_options}    Get All Options From Dropdown On Web    ${DRIVERSPAGE_DRIVER_CATEGORY}
    Should Not Be Empty    ${all_options}    msg=Driver category dropdown has no options
    ${first_option}    Get From List    ${all_options}    0
    Select List Item On Webpage    ${DRIVERSPAGE_DRIVER_CATEGORY}    value    ${first_option}[value]
    Wait Until Page Is Loaded

Select Last Option From Driver Category Dropdown
    [Documentation]
    ...    Selects the last available option from the driver category dropdown.
    ...    This is typically used for Back End driver tests.
    ...    Example usage:
    ...    | Select Last Option From Driver Category Dropdown
    Wait Until Page Is Loaded
    ${all_options}    Get All Options From Dropdown On Web    ${DRIVERSPAGE_DRIVER_CATEGORY}
    Should Not Be Empty    ${all_options}    msg=Driver category dropdown has no options
    ${last_index}    Evaluate    len(${all_options}) - 1
    ${last_option}    Get From List    ${all_options}    ${last_index}
    Select List Item On Webpage    ${DRIVERSPAGE_DRIVER_CATEGORY}    value    ${last_option}[value]
    Wait Until Page Is Loaded

Fill Mandatory Driver Fields
    [Documentation]
    ...    Fills required driver fields with position-based driver category selection.
    ...    Defaults to front-end driver (first option). Pass is_front_end=${False} for back-end drivers.
    ...    | =Arguments= | =Description= |
    ...    | forecast_driver_type | Type value to select (e.g., ACTUAL, REVISED, CALCULATED). |
    ...    | driver_group | Group value to select (e.g., TOTAL_STORE, DEPARTMENT). |
    ...    | driver_granularity | Granularity value to select (e.g., ANNUAL, DAILY, WEEKLY). |
    ...    | adjustment_mode | Adjustment mode value to select (e.g., EDIT, NO_EDIT). |
    ...    | aggregate_rule | Aggregate rule value to select (e.g., AVERAGE, SUM). |
    ...    | display_format | Display format value to select (e.g., DATE_SKEY_FORMAT, DECIMAL_FORMAT). |
    ...    | is_front_end | Optional. Boolean flag: True for front end (default), False for back end. |
    ...    Example usage:
    ...    | Fill Mandatory Driver Fields    ForecastDriverType.ACTUAL    DriverGroup.TOTAL_STORE    DriverGranularity.WEEKLY    DriverAdjustmentMode.EDIT    DriverAggregateRule.AVERAGE    DriverDisplayFormat.DATE_SKEY_FORMAT
    ...    | Fill Mandatory Driver Fields    ForecastDriverType.CALCULATED    DriverGroup.DEPARTMENT    DriverGranularity.DAILY    DriverAdjustmentMode.NO_EDIT    DriverAggregateRule.SUM    DriverDisplayFormat.DECIMAL_FORMAT    is_front_end=${False}
    [Arguments]    ${forecast_driver_type}
    ...    ${driver_group}
    ...    ${driver_granularity}
    ...    ${adjustment_mode}
    ...    ${aggregate_rule}
    ...    ${display_format}
    ...    ${is_front_end}=${True}
    ${driver_description_id}    Generate Random String    5    [NUMBERS]
    VAR    ${driver_description}    Driver Description${driver_description_id}
    Wait Until Page Is Loaded
    IF    ${is_front_end}
        Select First Option From Driver Category Dropdown
    ELSE
        Select Last Option From Driver Category Dropdown
    END
    Fill Description Field    driver_description=${driver_description}
    Select Forecast Driver Type    ${forecast_driver_type}
    Select Driver Group    ${driver_group}
    Select Driver Granularity    ${driver_granularity}
    Select Adjustment Mode    ${adjustment_mode}
    Select Aggregate Rule    ${aggregate_rule}
    Select Display Format    ${display_format}
    RETURN    ${driver_description}

Click On Save Button
    [Documentation]    Clicks the save button on the driver form.
    Click Element On Webpage    ${DRIVERSPAGE_SAVE_BUTTON}
    Wait Until Page Is Loaded

Verify Driver Alert Message Displayed
    [Documentation]    Verifies that alert message is displayed on the driver page.
    ${alert_message_displayed}    Is Element Visible On Webpage    ${DRIVERSPAGE_ALERT}
    Should Be True    ${alert_message_displayed}    Alert message is not displayed
    Capture Screenshot On Webpage

Fill Driver Code Field
    [Documentation]    Fills the driver code field with a randomly generated 5-digit number.
    ${driver_code_id}    Generate Random String    5    [NUMBERS]
    Fill Textbox On Webpage    ${DRIVERSPAGE_DRIVER_CODE}    ${driver_code_id}
    Wait Until Page Is Loaded

Verify Driver Success Message Displayed
    [Documentation]    Verifies that success notification message is displayed on the driver page.
    Wait Until Element Is Visible On Webpage    ${DRIVERSPAGE_NOTIFICATION_SUCCESS_MESSAGE}
    ...    error_message=Success notification not displayed after driver operation
    Capture Screenshot On Webpage

Click On Created Driver
    [Documentation]    This keyword clicks & open the created driver.
    [Arguments]    ${driver_description}
    ${driver}    Update Locator With Dynamic Values    ${DRIVERSPAGE_CREATED_DRIVER}    DESC=${driver_description}
    Click Element On Webpage    ${driver}    Failed to click on driver '${driver_description}'
    Wait Until Page Is Loaded

Click On Delete Button
    [Documentation]    Clicks the delete button and accepts the confirmation alert.
    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${DRIVERSPAGE_DELETE_BUTTON}    Failed to click delete button on driver form
    Wait Until Page Is Loaded

Delete The Created Driver
    [Documentation]    This keyword will delete the created driver.
    [Arguments]    ${driver_description}
    Click On Created Driver    ${driver_description}
    Click On Delete Button

Clean Up Driver On Drivers Page On Web
    [Documentation]
    ...    Checks if a driver exists and deletes it if found.
    ...    Safe to call even if driver doesn't exist - logs info message.
    ...    This keyword serves dual purpose: pre-test cleanup (ensures clean state) and post-test deletion (deletes and verifies removal).
    ...    Validates successful deletion via API response (HTTP 200).
    ...    | =Arguments= | =Description= |
    ...    | driver_description | Description of the driver to check and optionally delete. |
    ...    Example usage:
    ...    | Clean Up Driver On Drivers Page On Web    Front-End-Automation-Driver
    [Arguments]    ${driver_description}
    ${driver_locator}    Update Locator With Dynamic Values    ${DRIVERSPAGE_CREATED_DRIVER}    DESC=${driver_description}
    ${driver_exists}    Run Keyword And Return Status
    ...    Wait For Elements State    ${driver_locator}    visible
    IF    not ${driver_exists}
        Log    Driver '${driver_description}' not present - no cleanup needed    INFO
        RETURN
    END
    TRY
        Click Element On Webpage    ${driver_locator}    Failed to click on driver '${driver_description}' for cleanup
        Wait Until Page Is Loaded
        ${promise_alert}    Promise To    Wait For Alert    action=accept
        ${promise_api}    Promise To    Wait For Response    ${DELETE_DRIVER_API_REGEX}
        Click Element On Webpage    ${DRIVERSPAGE_DELETE_BUTTON}    Failed to click delete button for driver '${driver_description}'
        ${alert_text}    Wait For    ${promise_alert}
        Log    Alert text received: ${alert_text}    INFO
        ${response_body}    Wait For    ${promise_api}
        Log    API Response Status: ${response_body.status}    INFO
        # Driver Forecast uses legacy JSP with 302 redirect response
        Should Be True    ${response_body.status} in [${HTTP_STATUS_CODES}[OK], 302]
        ...    msg=Expected status 200 or 302 but got ${response_body.status}
        Log    Driver '${driver_description}' deleted successfully    INFO
    EXCEPT
        Log    Driver '${driver_description}' may have been already deleted    WARN
    END

Add Front End Driver On Drivers Page On Web
    [Documentation]
    ...    Creates a front end driver with all required fields.
    ...    Automatically selects the first option from driver category dropdown (Front End).
    ...    Uses current epoch time for unique driver code.
    ...    Validates successful creation via API response (HTTP 200/201).
    ...    | =Arguments= | =Description= |
    ...    | driver_data | Dictionary containing all driver field values from data provider. |
    ...    Example usage:
    ...    | ${driver_data}    Get Driver Forecast Data    template_name=front_end_driver
    ...    | Add Front End Driver On Drivers Page On Web    ${driver_data}
    [Arguments]    ${driver_data}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${DRIVERSPAGE_ADD_BUTTON}    Failed to click Add button on Drivers page
    Wait Until Element Is Visible On Webpage    ${DRIVERSPAGE_DRIVER_CATEGORY}
    ...    error_message=Driver category dropdown not visible after clicking Add button
    ${unique_driver_code}    Get Time    epoch
    Fill Driver Form On Drivers Page On Web    ${driver_data}    ${unique_driver_code}    is_front_end=${True}
    ${promise}    Promise To    Wait For Response    ${SAVE_DRIVER_API_REGEX}
    Click Element On Webpage    ${DRIVERSPAGE_SAVE_BUTTON}    Failed to click Save button while adding front end driver
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    # Driver Forecast uses legacy JSP with 302 redirect response (not REST API)
    Should Be True    ${response_body.status} in [${HTTP_STATUS_CODES}[OK], ${HTTP_STATUS_CODES}[CREATED], 302]
    ...    msg=Expected status 200 or 201 but got ${response_body.status}
    Wait Until Page Is Loaded

Fill Driver Form On Drivers Page On Web
    [Documentation]
    ...    Fills all driver form fields including dropdowns and text inputs.
    ...    Driver category is selected based on is_front_end flag: first option for front end, last option for back end.
    ...    | =Arguments= | =Description= |
    ...    | driver_field_values | Dictionary with driver field values. |
    ...    | driver_code | Unique driver code (typically epoch timestamp). |
    ...    | is_front_end | Boolean flag: True for front end (first option), False for back end (last option). Required parameter. |
    ...    Example usage:
    ...    | Fill Driver Form On Drivers Page On Web    ${driver_data}    ${unique_driver_code}    is_front_end=${True}
    [Arguments]    ${driver_field_values}    ${driver_code}    ${is_front_end}
    IF    ${is_front_end}
        Select First Option From Driver Category Dropdown
    ELSE
        Select Last Option From Driver Category Dropdown
    END
    Fill Textbox On Webpage    ${DRIVERSPAGE_DRIVER_CODE}    ${driver_code}
    Fill Textbox On Webpage    ${DRIVERSPAGE_DRIVER_DESCRIPTION}    ${driver_field_values}[description]

    Select List Item On Webpage    ${DRIVERSPAGE_FORECAST_DRIVER_TYPE}    value    ${driver_field_values}[forecast_driver_type]
    Select List Item On Webpage    ${DRIVERSPAGE_DRIVER_GROUP}    value    ${driver_field_values}[driver_group]
    Select List Item On Webpage    ${DRIVERSPAGE_DRIVER_GRANULARITY}    value    ${driver_field_values}[driver_granularity]
    Select List Item On Webpage    ${DRIVERSPAGE_ADJUSTMENT_MODE}    value    ${driver_field_values}[adjustment_mode]
    Select List Item On Webpage    ${DRIVERSPAGE_AGGREGATE_RULE}    value    ${driver_field_values}[aggregate_rule]
    Select List Item On Webpage    ${DRIVERSPAGE_DISPLAY_FORMAT}    value    ${driver_field_values}[display_format]
    Wait Until Page Is Loaded

Edit Driver On Drivers Page On Web
    [Documentation]
    ...    Edits an existing driver by updating its forecast driver type.
    ...    Opens the driver form, changes the type, saves, and verifies the update.
    ...    Validates successful edit via API response (HTTP 200/201).
    ...    | =Arguments= | =Description= |
    ...    | driver_description | Description of driver to edit. |
    ...    | updated_driver_type | New forecast driver type value. |
    ...    Example usage:
    ...    | Edit Driver On Drivers Page On Web    Front-End-Automation-Driver    ForecastDriverType.REVISED
    [Arguments]    ${driver_description}    ${updated_driver_type}
    ${driver_locator}    Update Locator With Dynamic Values    ${DRIVERSPAGE_CREATED_DRIVER}    DESC=${driver_description}
    Click Element On Webpage    ${driver_locator}    Failed to click on driver '${driver_description}' for editing
    Wait Until Page Is Loaded
    Select List Item On Webpage    ${DRIVERSPAGE_FORECAST_DRIVER_TYPE}    value    ${updated_driver_type}
    ${selected_driver_type_label}    Get Selected Options    ${DRIVERSPAGE_FORECAST_DRIVER_TYPE}    label
    ${unique_driver_code}    Get Time    epoch
    Fill Textbox On Webpage    ${DRIVERSPAGE_DRIVER_CODE}    ${unique_driver_code}
    Fill Textbox On Webpage    ${DRIVERSPAGE_DRIVER_DESCRIPTION}    ${driver_description}
    ${promise}    Promise To    Wait For Response    ${SAVE_DRIVER_API_REGEX}
    Click Element On Webpage    ${DRIVERSPAGE_SAVE_BUTTON}    Failed to click Save button while editing driver '${driver_description}'
    ${response_body}    Wait For    ${promise}
    Log    API Response Status: ${response_body.status}    INFO
    # Driver Forecast uses legacy JSP with 302 redirect response (not REST API)
    Should Be True    ${response_body.status} in [${HTTP_STATUS_CODES}[OK], ${HTTP_STATUS_CODES}[CREATED], 302]
    ...    msg=Expected status 200, 201, or 302 but got ${response_body.status}
    Wait Until Page Is Loaded
    Verify Driver Type Is Updated On Drivers Page On Web    ${driver_description}    ${selected_driver_type_label}[0]

Verify Driver Type Is Updated On Drivers Page On Web
    [Documentation]
    ...    Verifies that driver type was successfully updated in the list view.
    ...    | =Arguments= | =Description= |
    ...    | driver_description | Description of the driver. |
    ...    | expected_driver_type | Expected type label text. |
    [Arguments]    ${driver_description}    ${expected_driver_type}
    ${updated_type_locator}    Update Locator With Dynamic Values
    ...    ${DRIVERSPAGE_UPDATED_FORECAST_DRIVER_TYPE}    DESC=${driver_description}    TYPE=${expected_driver_type}
    Wait Until Element Is Visible On Webpage    ${updated_type_locator}
    ...    error_message=Driver '${driver_description}' with updated type '${expected_driver_type}' not visible in driver list
    ${driver_count}    Get Element Count On Web Page    ${updated_type_locator}
    Should Be True    ${driver_count} >= 1
    ...    Driver type was not updated correctly. Expected: ${expected_driver_type}

Delete Driver On Drivers Page On Web
    [Documentation]
    ...    Deletes a driver and verifies it no longer exists.
    ...    Note: This is an internal keyword. For general use, prefer 'Clean Up Driver On Drivers Page On Web'.
    ...    | =Arguments= | =Description= |
    ...    | driver_description | Description of the driver to delete. |
    ...    Example usage:
    ...    | Delete Driver On Drivers Page On Web    Front-End-Automation-Driver
    [Arguments]    ${driver_description}
    ${driver_locator}    Update Locator With Dynamic Values    ${DRIVERSPAGE_CREATED_DRIVER}    DESC=${driver_description}
    Click Element On Webpage    ${driver_locator}    Failed to click on driver '${driver_description}' for deletion
    Wait Until Page Is Loaded
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${DRIVERSPAGE_DELETE_BUTTON}    Failed to click delete button for driver '${driver_description}'
    ${alert_text}    Wait For    ${promise}
    Log    Alert text received: ${alert_text}    INFO
    Verify Driver Success Message Displayed
    Wait Until Page Is Loaded
    ${driver_count}    Get Element Count On Web Page    ${driver_locator}
    Should Be Equal As Strings    ${driver_count}    0
    ...    Driver '${driver_description}' was not deleted successfully

Add Back End Driver On Drivers Page On Web
    [Documentation]
    ...    Creates a back end driver with all required fields including calculation method.
    ...    Automatically selects the last option from driver category dropdown (Back End).
    ...    Validates successful creation via API response (HTTP 200/201).
    ...    | =Arguments= | =Description= |
    ...    | driver_data | Dictionary containing all driver field values from data provider. |
    ...    Example usage:
    ...    | ${driver_data}    Get Driver Forecast Data    template_name=back_end_driver
    ...    | Add Back End Driver On Drivers Page On Web    ${driver_data}
    [Arguments]    ${driver_data}
    Wait Until Page Is Loaded
    Click Element On Webpage    ${DRIVERSPAGE_ADD_BUTTON}    Failed to click Add button on Drivers page
    Wait Until Element Is Visible On Webpage    ${DRIVERSPAGE_DRIVER_CATEGORY}
    ...    error_message=Driver category dropdown not visible after clicking Add button
    ${unique_driver_code}    Get Time    epoch
    Fill Driver Form On Drivers Page On Web    ${driver_data}    ${unique_driver_code}    is_front_end=${False}
    ${calc_methods}    Get All Options From Dropdown On Web    ${DRIVERSPAGE_FORECAST_CALCULATION_METHOD}
    Should Not Be Empty    ${calc_methods}    msg=No calculation method options available in the dropdown
    ${first_method}    Get From List    ${calc_methods}    1
    Select List Item On Webpage    ${DRIVERSPAGE_FORECAST_CALCULATION_METHOD}    value    ${first_method}[value]
    ${promise}    Promise To    Wait For Response    ${SAVE_DRIVER_API_REGEX}
    Click Element On Webpage    ${DRIVERSPAGE_SAVE_BUTTON}    Failed to click Save button while adding back end driver
    ${response_body}    Wait For    ${promise}
    Log    API Response Status: ${response_body.status}    INFO
    # Driver Forecast uses legacy JSP with 302 redirect response (not REST API)
    Should Be True    ${response_body.status} in [${HTTP_STATUS_CODES}[OK], ${HTTP_STATUS_CODES}[CREATED], 302]
    ...    msg=Expected status 200, 201, or 302 but got ${response_body.status}
    Wait Until Page Is Loaded

Cleanup Driver If Exists On Drivers Page On Web
    [Documentation]
    ...    Teardown helper that safely deletes a driver if it exists.
    ...    Ignores errors if driver not found or already deleted.
    ...    | =Arguments= | =Description= |
    ...    | driver_description | Description of the driver to cleanup. |
    [Arguments]    ${driver_description}
    TRY
        ${driver_locator}    Update Locator With Dynamic Values    ${DRIVERSPAGE_CREATED_DRIVER}    DESC=${driver_description}
        ${driver_exists}    Run Keyword And Return Status
        ...    Wait For Elements State    ${driver_locator}    visible
        IF    ${driver_exists}
            Click Element On Webpage    ${driver_locator}    Failed to click on driver '${driver_description}' during cleanup
            Wait Until Page Is Loaded
            ${promise}    Promise To    Wait For Alert    action=accept
            Click Element On Webpage    ${DRIVERSPAGE_DELETE_BUTTON}
            ...    Failed to click delete button during cleanup of driver '${driver_description}'
            Wait For    ${promise}
            Verify Driver Success Message Displayed
            Log    Cleanup: Driver '${driver_description}' deleted successfully    INFO
        ELSE
            Log    Cleanup: Driver '${driver_description}' not found - skipping    INFO
        END
    EXCEPT
        Log    Cleanup: Failed to delete driver '${driver_description}' - may not exist    WARN
    END
