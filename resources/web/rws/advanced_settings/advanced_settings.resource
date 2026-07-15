*** Settings ***
Documentation
...                 This resource file provides keywords for interacting with the Advanced Settings page
...                 in the RWS module. It supports weekplan generation, deletion, and verification operations
...                 for Driver Forecast, Workload, and Schedule types.
...
...                 = Purpose =
...                 - Navigate to Advanced Settings page
...                 - Select weekplan generation parameters (type, store group, fiscal year/week)
...                 - Trigger weekplan generation or deletion operations
...                 - Verify API responses for weekplan operations
...
...                 = Prerequisites =
...                 - User must be logged in with CORP profile (e.g., SYSADMIN)
...                 - Browser must be initialized
...
...                 = Example Usage =
...                 | Navigate To RWS Advanced Settings Page On Web
...                 | Generate Weekplan On Advanced Settings Page On Web    ${weekplan_data}
...                 | Delete Weekplan On Advanced Settings Page On Web    ${weekplan_data}

Library             test_data/TestDataLibrary.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/common_date_utility.resource
Variables           resources/web/rws/advanced_settings/advanced_settings_page.py
Variables           resources/web/rws/advanced_settings/advanced_settings_api.py
Variables           resources/web/common/status_codes.py


*** Keywords ***
Navigate To RWS Advanced Settings Page On Web
    [Documentation]
    ...    Navigates to the RWS Advanced Settings page.
    ...    This keyword handles the complete navigation flow from any starting point in the application
    ...    to the Advanced Settings page within the RWS module.
    ...    Example usage:
    ...    | Navigate To RWS Advanced Settings Page On Web
    Navigate To Specific Page On Web    rws    advanced_settings    advanced_settings

Select Weekplan Type On Advanced Settings Page On Web
    [Documentation]
    ...    Selects weekplan type from the Type dropdown on Advanced Settings page.
    ...    | =Arguments= | =Description= |
    ...    | weekplan_type_value    | Weekplan type value (e.g., FCST, WKLD, SCH) |
    ...    Example usage:
    ...    | Select Weekplan Type On Advanced Settings Page On Web    FCST
    [Arguments]    ${weekplan_type_value}
    Select List Item On Webpage    ${ADVANCEDSETTINGSPAGE_SELECTED_TYPE}    value    ${weekplan_type_value}

Select Store Group On Advanced Settings Page On Web
    [Documentation]
    ...    Selects store group from the Store Group dropdown on Advanced Settings page.
    ...    | =Arguments= | =Description= |
    ...    | store_group_name    | Store group name (e.g., STORE2_TEST) |
    ...    Example usage:
    ...    | Select Store Group On Advanced Settings Page On Web    STORE2_TEST
    [Arguments]    ${store_group_name}
    Select List Item On Webpage    ${ADVANCEDSETTINGSPAGE_SELECTED_STORE_GROUP}    text    ${store_group_name}

Select Fiscal Year On Advanced Settings Page On Web
    [Documentation]
    ...    Selects fiscal year from the Fiscal Year dropdown on Advanced Settings page.
    ...    | =Arguments= | =Description= |
    ...    | fiscal_year_value    | Fiscal year value (e.g., 2026) |
    ...    Example usage:
    ...    | Select Fiscal Year On Advanced Settings Page On Web    2026
    [Arguments]    ${fiscal_year_value}
    Select List Item On Webpage    ${ADVANCEDSETTINGSPAGE_SELECTED_FISCAL_YEAR}    value    ${fiscal_year_value}

Select Fiscal Week On Advanced Settings Page On Web
    [Documentation]
    ...    Selects fiscal week from the Fiscal Week dropdown on Advanced Settings page.
    ...    | =Arguments= | =Description= |
    ...    | fiscal_week_value    | Fiscal week number (e.g., 02, 10) |
    ...    Example usage:
    ...    | Select Fiscal Week On Advanced Settings Page On Web    08
    [Arguments]    ${fiscal_week_value}
    # Convert to 2-digit format if needed
    ${fiscal_week_formatted}=    Evaluate    str(int("${fiscal_week_value}")).zfill(2)
    Select List Item On Webpage    ${ADVANCEDSETTINGSPAGE_SELECTED_FISCAL_WEEK}    value    ${fiscal_week_formatted}

Select Operation On Advanced Settings Page On Web
    [Documentation]
    ...    Selects the operation type (Delete or Delete & Generate) on Advanced Settings page.
    ...    | =Arguments= | =Description= |
    ...    | weekplan_operation_type    | Operation type from WeekplanOperation constants (DELETE or DELETE_AND_GENERATE) |
    ...    Example usage:
    ...    | Select Operation On Advanced Settings Page On Web    ${delete_generate_operation}
    [Arguments]    ${weekplan_operation_type}
    ${delete_operation_value}=    Get System Value    WeekplanOperation    DELETE
    ${delete_generate_operation_value}=    Get System Value    WeekplanOperation    DELETE_AND_GENERATE
    IF    '${weekplan_operation_type}' == '${delete_operation_value}'
        Click Element On Webpage    ${ADVANCEDSETTINGSPAGE_SELECTED_DELETE_BUTTON}
    ELSE IF    '${weekplan_operation_type}' == '${delete_generate_operation_value}'
        Click Element On Webpage    ${ADVANCEDSETTINGSPAGE_SELECTED_DELETE_GENERATE_BUTTON}
    ELSE
        Fail    Invalid operation: ${weekplan_operation_type}. Must be DELETE or DELETE_AND_GENERATE from WeekplanOperation constants
    END

Select Schedule Preference On Advanced Settings Page On Web
    [Documentation]
    ...    Selects the regeneration "Schedule Preference" for the "Delete & Generate" operation.
    ...    This dropdown only takes effect for the Delete & Generate operation and otherwise defaults to
    ...    "Delete and Generate unedited schedules" — which silently skips edited/published schedules.
    ...    Set it explicitly (e.g. "Delete and Generate based on Store Attribute") so each store honours its
    ...    own attribute during the batch regeneration.
    ...    | =Arguments= | =Description= |
    ...    | schedule_preference    | Visible option text (e.g., Delete and Generate based on Store Attribute) |
    ...    Example usage:
    ...    | Select Schedule Preference On Advanced Settings Page On Web    Delete and Generate based on Store Attribute
    [Arguments]    ${schedule_preference}
    Select List Item On Webpage    ${ADVANCEDSETTINGSPAGE_SELECTED_SCHEDULE_PREFERENCE}    text    ${schedule_preference}

Handle Workload Confirmation Popup On Advanced Settings Page On Web
    [Documentation]
    ...    Handles the confirmation popup that appears when workload/schedule generation is triggered.
    ...    Waits for popup to appear and clicks OK button if present.
    ...    Example usage:
    ...    | Handle Workload Confirmation Popup On Advanced Settings Page On Web
    ${popup_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${ADVANCEDSETTINGSPAGE_POPUP_WINDOW_OK_BUTTON}    timeout=3s
    IF    ${popup_visible}
        Click Element On Webpage    ${ADVANCEDSETTINGSPAGE_POPUP_WINDOW_OK_BUTTON}
    END

Fill Weekplan Form On Advanced Settings Page On Web
    [Documentation]
    ...    Fills all weekplan generation form fields on Advanced Settings page.
    ...    | =Arguments= | =Description= |
    ...    | weekplan_data    | Dictionary containing weekplan parameters (type, store_group, fiscal_year, fiscal_week, operation) |
    ...    Example usage:
    ...    | Fill Weekplan Form On Advanced Settings Page On Web    ${weekplan_data}
    [Arguments]    ${weekplan_data}
    Select Weekplan Type On Advanced Settings Page On Web    ${weekplan_data}[type]
    Select Store Group On Advanced Settings Page On Web    ${weekplan_data}[store_group]
    Select Fiscal Year On Advanced Settings Page On Web    ${weekplan_data}[fiscal_year]
    Select Fiscal Week On Advanced Settings Page On Web    ${weekplan_data}[fiscal_week]
    Select Operation On Advanced Settings Page On Web    ${weekplan_data}[operation]
    # Optional: only callers that need a specific Delete & Generate preference pass this key. When omitted the
    # page keeps its default ("Delete and Generate unedited schedules"), preserving existing callers' behaviour.
    IF    'schedule_preference' in $weekplan_data
        Select Schedule Preference On Advanced Settings Page On Web    ${weekplan_data}[schedule_preference]
    END

Generate Weekplan On Advanced Settings Page On Web
    [Documentation]
    ...    Generates weekplan by filling form and clicking Queue button.
    ...    Handles workload confirmation popup if applicable.
    ...    | =Arguments= | =Description= |
    ...    | weekplan_data    | Dictionary containing weekplan parameters |
    ...    Example usage:
    ...    | Generate Weekplan On Advanced Settings Page On Web    ${weekplan_data}
    [Arguments]    ${weekplan_data}
    Fill Weekplan Form On Advanced Settings Page On Web    ${weekplan_data}
    Click Element On Webpage    ${ADVANCEDSETTINGSPAGE_SELECT_QUEUE}

    # Handle workload confirmation popup immediately after Queue button click
    ${workload_type}=    Get System Value    WeekplanType    WORKLOAD
    ${schedule_type}=    Get System Value    WeekplanType    SCHEDULE
    IF    '${weekplan_data}[type]' == '${workload_type}' or '${weekplan_data}[type]' == '${schedule_type}'
        Handle Workload Confirmation Popup On Advanced Settings Page On Web
    END
    ${wait_time}=    Get Config Value    WEEKPLAN_GENERATION_WAIT_TIME
    Log    Waiting ${wait_time} seconds for weekplan generation batch processing to complete
    Sleep    ${wait_time}s  # needed as discussed with owner

Delete Weekplan On Advanced Settings Page On Web
    [Documentation]
    ...    Deletes weekplan by filling form with delete operation and clicking Queue button.
    ...    Handles workload confirmation popup if applicable.
    ...    | =Arguments= | =Description= |
    ...    | weekplan_data    | Dictionary containing weekplan parameters with operation=del |
    ...    Example usage:
    ...    | Delete Weekplan On Advanced Settings Page On Web    ${weekplan_data}
    [Arguments]    ${weekplan_data}
    Fill Weekplan Form On Advanced Settings Page On Web    ${weekplan_data}
    Click Element On Webpage    ${ADVANCEDSETTINGSPAGE_SELECT_QUEUE}

    # Handle workload confirmation popup immediately after Queue button click
    ${workload_type}=    Get System Value    WeekplanType    WORKLOAD
    ${schedule_type}=    Get System Value    WeekplanType    SCHEDULE
    IF    '${weekplan_data}[type]' == '${workload_type}' or '${weekplan_data}[type]' == '${schedule_type}'
        Handle Workload Confirmation Popup On Advanced Settings Page On Web
    END
    ${wait_time}=    Get Config Value    WEEKPLAN_GENERATION_WAIT_TIME
    Log    Waiting ${wait_time} seconds for weekplan deletion batch processing to complete
    Sleep    ${wait_time}s    # needed as discussed with owner

Delete Generated Weekplans On Advanced Settings Page On Web
    [Documentation]
    ...    Deletes workload and schedule weekplans generated during test execution.
    ...    Used in teardown to clean up test data.
    ...    | =Arguments= | =Description= |
    ...    | fiscal_year_value    | Fiscal year for deletion |
    ...    | fiscal_week_value    | Fiscal week for deletion |
    ...    | store_group_name    | Store group for deletion |
    ...    Example usage:
    ...    | Delete Generated Weekplans On Advanced Settings Page On Web    2026    08    STORE2_TEST
    [Arguments]    ${fiscal_year_value}    ${fiscal_week_value}    ${store_group_name}
    # Get constant values
    ${workload_type}=    Get System Value    WeekplanType    WORKLOAD
    ${schedule_type}=    Get System Value    WeekplanType    SCHEDULE
    ${delete_operation_value}=    Get System Value    WeekplanOperation    DELETE

    # Delete Workload
    VAR    &{workload_delete_data}=
    ...    type=${workload_type}
    ...    store_group=${store_group_name}
    ...    fiscal_year=${fiscal_year_value}
    ...    fiscal_week=${fiscal_week_value}
    ...    operation=${delete_operation_value}
    Delete Weekplan On Advanced Settings Page On Web    ${workload_delete_data}

    # Delete Schedule
    VAR    &{schedule_delete_data}=
    ...    type=${schedule_type}
    ...    store_group=${store_group_name}
    ...    fiscal_year=${fiscal_year_value}
    ...    fiscal_week=${fiscal_week_value}
    ...    operation=${delete_operation_value}
    Delete Weekplan On Advanced Settings Page On Web    ${schedule_delete_data}
