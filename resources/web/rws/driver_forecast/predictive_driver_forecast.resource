*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Predictive Driver Forecast page functionality within the RWS module.

Resource            resources/web/common/common.resource
Resource            resources/web/common/calendar_navigation.resource
Resource            resources/web/rws/predictive_analytics/forecast_review.resource
Variables           resources/web/rws/driver_forecast/predictive_driver_forecast_page.py


*** Keywords ***
Navigate To RWS Predictive Driver Forecast Page On Web
    [Documentation]
    ...    Navigates to the RWS Predictive Driver Forecast page and verifies successful page load.
    ...    This keyword handles the complete navigation flow from any starting point in the application
    ...    to the specific Driver Forecast page within the RWS module.
    ...    | =Arguments= | =Description= |
    ...    | None    | This keyword takes no arguments |
    Navigate To Specific Page On Web    rws    predictive_analytics    forecast_review

Verify Forward Week Navigation On Predictive Driver Forecast Page On Web
    [Documentation]
    ...    Navigates forward on predictive driver forecast page using calendar navigator.
    ...    Verifies that the week navigation functions correctly in forward direction by navigating
    ...    forward the specified number of steps.
    ...    | =Arguments= | =Description= |
    ...    | number_of_weeks_to_navigate | Number of weeks to navigate forward |
    ...    Example usage:
    ...    | Verify Forward Week Navigation On Predictive Driver Forecast Page On Web    2
    [Arguments]    ${number_of_weeks_to_navigate}
    ${calendar_navigation_date_format}    Get Config Value    key=DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA
    Navigate Calendar By Weeks And Verify Navigated Week Range
    ...    ${NAVIGATION_DIRECTION_FORWARD}
    ...    ${number_of_weeks_to_navigate}
    ...    ${PREDICTIVE_DRIVER_FORECAST_FORWARD_ARROW}
    ...    ${PREDICTIVE_DRIVER_FORECAST_BACKWARD_ARROW}
    ...    ${PREDICTIVE_DRIVER_FORECAST_SELECTED_WEEK}
    ...    ${calendar_navigation_date_format}

Verify Backward Week Navigation On Predictive Driver Forecast Page On Web
    [Documentation]
    ...    Navigates backward on predictive driver forecast page using calendar navigator.
    ...    Verifies that the week navigation functions correctly in backward direction by navigating
    ...    backward the specified number of steps.
    ...    | =Arguments= | =Description= |
    ...    | number_of_weeks_to_navigate | Number of weeks to navigate backward |
    ...    Example usage:
    ...    | Verify Backward Week Navigation On Predictive Driver Forecast Page On Web    2
    [Arguments]    ${number_of_weeks_to_navigate}
    ${calendar_navigation_date_format}    Get Config Value    key=DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA
    Navigate Calendar By Weeks And Verify Navigated Week Range
    ...    ${NAVIGATION_DIRECTION_BACKWARD}
    ...    ${number_of_weeks_to_navigate}
    ...    ${PREDICTIVE_DRIVER_FORECAST_FORWARD_ARROW}
    ...    ${PREDICTIVE_DRIVER_FORECAST_BACKWARD_ARROW}
    ...    ${PREDICTIVE_DRIVER_FORECAST_SELECTED_WEEK}
    ...    ${calendar_navigation_date_format}

Verify Driver With Totals On Predictive Driver Forecast Page On Web
    [Documentation]
    ...    Verifies that a driver with totals is displayed correctly on the Predictive Driver Forecast page.
    ...    This keyword checks for the presence of the specified driver and validates that the totals
    ...    are displayed as expected.
    ...    | =Arguments= | =Description= |
    ...    | driver_name | The name of the driver to verify |
    ...    Example usage:
    ...    | Verify Driver With Totals On Predictive Driver Forecast Page On Web    Sample Driver Name
    [Arguments]    ${driver_name}
    ${driver_totals_locator}    Update Locator With Dynamic Values    ${PREDICTIVE_DRIVER_FORECAST_TOTALS}    DRIVER=${driver_name}
    ${totals_present}    Is Element Visible On Webpage    ${driver_totals_locator}
    IF    ${totals_present}
        ${driver_totals_text}    Get Element Text On Webpage    ${driver_totals_locator}
        Log    Driver totals displayed for driver: ${driver_name} as expected.
        ${driver_totals_text}    Remove String    ${driver_totals_text}    $    ${SPACE}
        ${driver_totals}    Convert To Number    ${driver_totals_text}
        Should Be True    ${driver_totals} > 0    msg=Driver totals should be greater than zero.
    ELSE
        Capture Screenshot On Webpage
        Fail    Driver totals not displayed for driver: ${driver_name} as expected.
    END

Navigate Forward And Verify Forecast Week On Predictive Driver Forecast Page On Web
    [Documentation]
    ...    Navigates forward on predictive driver forecast page using calendar navigator.
    ...    Verifies that a driver with totals is displayed correctly on the Predictive Driver Forecast page.
    ...    | =Arguments= | =Description= |
    ...    | weeks | Weeks to navigate |
    ...    Example usage:
    ...    | Navigate Forward And Verify Forecast Week On Predictive Driver Forecast Page On Web    2
    [Arguments]    ${weeks}
    Verify Forward Week Navigation On Predictive Driver Forecast Page On Web    ${weeks}
    ${eligible_driver_details}    Find First Eligible Daily Driver From Forecast Review Page On Web
    VAR    ${driver_name}    ${eligible_driver_details}[driver_name]
    IF    '${driver_name}' != ''
        Log    Driver with totals found for verification on Predictive Driver Forecast page after navigation: ${driver_name}
    ELSE
        Fail    No eligible driver with totals found to verify on Predictive Driver Forecast page after navigation.
    END

Navigate Backward And Verify Forecast Week On Predictive Driver Forecast Page On Web
    [Documentation]
    ...    Navigates backward on predictive driver forecast page using calendar navigator.
    ...    Verifies that a driver with totals is displayed correctly on the Predictive Driver Forecast page.
    ...    | =Arguments= | =Description= |
    ...    | weeks | Weeks to navigate |
    ...    Example usage:
    ...    | Navigate Backward And Verify Forecast Week On Predictive Driver Forecast Page On Web    2
    [Arguments]    ${weeks}
    Verify Backward Week Navigation On Predictive Driver Forecast Page On Web    ${weeks}
    ${eligible_driver_details}    Find First Eligible Daily Driver From Forecast Review Page On Web
    VAR    ${driver_name}    ${eligible_driver_details}[driver_name]
    IF    '${driver_name}' != ''
        Log    Driver with totals found for verification on Predictive Driver Forecast page after navigation: ${driver_name}
    ELSE
        Fail    No eligible driver with totals found to verify on Predictive Driver Forecast page after navigation.
    END

Navigate To RWS Predictive Driver Forecast Weekly Plan Page On Web
    [Documentation]
    ...    Navigates to the RWS Predictive Driver Forecast Weekly Plan page and verifies successful page load.
    ...    This keyword handles the complete navigation flow from any starting point in the application
    ...    to the specific Driver Forecast Weekly Plan page within the RWS module.
    ...    | =Arguments= | =Description= |
    ...    | None    | This keyword takes no arguments |
    Navigate To Specific Page On Web    rws    predictive_analytics    week_plan
    Wait Until Page Is Loaded

Select Location Type And Location On Predictive Driver Forecast Page On Web
    [Documentation]
    ...    Selects location type from the location type dropdown and then selects specific location on Predictive Driver Forecast page.
    ...    This keyword combines location type selection and location selection in a single operation.
    ...    | =Arguments= | =Description= |
    ...    | location_type | Location type to select (e.g., "Unit", "Store", "Region") |
    ...    | location_name | Specific location name to select (e.g., "Store1", "Region North") |
    ...
    ...    Example usage:
    ...    | Select Location Type And Location On Predictive Driver Forecast Page On Web    Unit    Store1
    [Arguments]    ${location_type}    ${location_name}
    Click Element On Webpage    ${PREDICTIVE_DRIVER_FORECAST_LOCATION_TYPE_DROPDOWN}
    ${selected_location_type}    Select Options By    ${PREDICTIVE_DRIVER_FORECAST_LOCATION_TYPE_DROPDOWN}    label    ${location_type}
    List Should Contain Value    ${selected_location_type}    ${location_type}
    Wait Until Element Is Visible On Webpage    ${PREDICTIVE_DRIVER_FORECAST_LOCATION_DROPDOWN}
    ...    error_message=Failed to load location dropdown
    Click Element On Webpage    ${PREDICTIVE_DRIVER_FORECAST_LOCATION_DROPDOWN}
    ...    error_message=Location dropdown not clickable on Predictive Driver Forecast page.
    Wait Until Element Is Visible On Webpage    ${PREDICTIVE_DRIVER_FORECAST_SEARCH_FIELD}
    ...    error_message=Search field not visible after clicking location dropdown on Predictive Driver Forecast page.
    Fill Textbox On Webpage    ${PREDICTIVE_DRIVER_FORECAST_SEARCH_FIELD}    ${location_name}
    ${store_name_input}    Update Locator With Dynamic Values    ${PREDICTIVE_DRIVER_FORECAST_STORE_NAME_INPUT}
    ...    STORE_NAME=${location_name}
    Click Element On Webpage    ${store_name_input}
    ...    error_message=Location not found or not clickable in location dropdown on Predictive Driver Forecast page.

Select Week Number On Predictive Driver Forecast Page On Web
    [Documentation]    Selects week number on Predictive Driver Forecast page on web using week_day format
    ...    | =Arguments=    | =Description= |
    ...    | week_day_input    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    ...    Example usage:
    ...    | Select Week Number On Predictive Driver Forecast Page On Web    1_2
    [Arguments]    ${week_day_input}
    ${target_date}    Calculate Date From Week Day Offset    ${week_day_input}
    ${week_label_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${week_label_date}    Calculate Week Start Date From Week Day Offset    ${week_day_input}    date_format=${week_label_date_format}
    ${date_format_year_only}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${date_format_month_only}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${date_format}    Get Config Value    DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA
    ${target_year}    Convert Date    ${target_date}    result_format=${date_format_year_only}
    ${target_month_name}    Convert Date    ${target_date}    result_format=${date_format_month_only}
    ${target_day_formatted}    Convert Date    ${target_date}    result_format=${date_format}
    ${year_last_2_digits}    Evaluate    str('${target_year}')[2:]
    Wait Until Page Is Loaded
    Click Element On Webpage    ${PREDICTIVE_DRIVER_FORECAST_CALENDER_ICON}
    ...    error_message=Calendar icon element not clickable on Predictive Driver Forecast page.
    Click Element On Webpage    ${PREDICTIVE_DRIVER_FORECAST_CALENDAR_MONTH_YEAR_HEADER}
    ...    error_message=Month and Year header not found on calendar pop-up of Predictive Driver Forecast page.
    ${year_button_locator}    Update Locator With Dynamic Values    ${PREDICTIVE_DRIVER_FORECAST_YEAR_BUTTON_BY_YEAR}
    ...    TARGET_YEAR=${target_year}
    ${is_element_present}    Run Keyword And Return Status    Wait Until Element Is Present On Webpage    ${year_button_locator}
    IF    ${is_element_present}
        Click Element On Webpage    ${year_button_locator}
        ...    error_message=Year button for target yearelement not clickable on calendar pop-up.
    ELSE
        Click Element On Webpage    ${PREDICTIVE_DRIVER_FORECAST_YEAR_BUTTON_DYNAMIC}
        ...    error_message=Year selector button not clickable on calendar pop-up for selecting year.
    END
    ${year_digits_locator}    Update Locator With Dynamic Values    ${PREDICTIVE_DRIVER_FORECAST_YEAR_DIGITS_BY_LAST_TWO}
    ...    YEAR_LAST_2_DIGITS=${year_last_2_digits}
    Click Element On Webpage    ${year_digits_locator}
    ...    error_message=Year button with last 2 digits not clickable on calendar pop-up.
    ${month_locator}    Update Locator With Dynamic Values    ${PREDICTIVE_DRIVER_FORECAST_MONTH_BUTTON_BY_NAME}
    ...    MONTH_NAME=${target_month_name}
    Click Element On Webpage    ${month_locator}
    ...    error_message=Month button for month not clickable on calendar pop-up.
    ${day_locator}    Update Locator With Dynamic Values    ${PREDICTIVE_DRIVER_FORECAST_DAY_BUTTON_BY_FORMATTED_DATE}
    ...    FORMATTED_DATE=${target_day_formatted}
    Wait Until Element Is Visible On Webpage    ${day_locator}
    ...    error_message=Day button for target day not visible on calendar pop-up of Predictive Driver Forecast page.
    ${week_number_locator}    Update Locator With Dynamic Values    ${PREDICTIVE_DRIVER_FORECAST_WEEK_NUMBER_BUTTON}
    ...    DAY_LOCATOR=${day_locator}
    Click Element On Webpage    ${week_number_locator}
    ...    error_message=Week number button not clickable on calendar pop-up of Predictive Driver Forecast page.
    Wait Until Element Disappears On Webpage    ${PREDICTIVE_DRIVER_FORECAST_CALENDAR_POP_UP}
    RETURN    ${week_label_date}

Initialize Forecast On Predictive Driver Forecast Page On Web
    [Documentation]    This keyword initializes the forecast by clicking on the Initialize button if it is visible; otherwise, it skips the test.
    ...    | =Arguments= | =Description= |
    ...    | None    | This keyword takes no arguments |
    Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage    ${PREDICTIVE_DRIVER_FORECAST_INIT_BTN}
    ${forecast_button_visible}    Is Element Visible On Webpage    ${PREDICTIVE_DRIVER_FORECAST_INIT_BTN}
    IF    ${forecast_button_visible}
        Click Element On Webpage    ${PREDICTIVE_DRIVER_FORECAST_INIT_BTN}
        ...    error_message=Initialize button not clickable on Predictive Driver Forecast page.
        Capture Screenshot On Webpage
    ELSE
        Skip    No forecast button available to generate forecast
    END
