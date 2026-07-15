*** Settings ***
Documentation
...                 This resource file provides keywords for calendar week navigation functionality across multiple pages.
...
...                 = Purpose =
...                 - Centralizes calendar navigation logic used by Week Schedule, Labor Forecast, and Driver Forecast pages
...                 - Handles forward/backward week navigation with verification
...                 - Provides reusable navigation patterns for calendar-based UI components
...
...                 = Prerequisites =
...                 - Required resources: common.resource, common_date_utility.resource
...                 - Calendar navigation requires page-specific arrow locators and week display templates
...
...                 = Example Usage =
...                 | *** Keywords ***
...                 | Navigate Week Schedule Calendar
...                 |    Navigate Calendar By Weeks And Verify Navigated Week    forward    2    ${FORWARD_ARROW}    ${BACKWARD_ARROW}    ${WEEK_LABEL}

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Library             resources/web/common/utility.py


*** Variables ***
${NAVIGATION_DIRECTION_FORWARD}     forward
${NAVIGATION_DIRECTION_BACKWARD}    backward


*** Keywords ***
Navigate Calendar By Weeks And Verify Navigated Week
    [Documentation]
    ...    Navigates the calendar by specified number of weeks in the given direction (forward/backward)
    ...    and verifies the displayed week after each navigation step.
    ...    The appropriate navigation button is automatically selected based on the direction.
    ...    | =Arguments= | =Description= |
    ...    | navigation_direction | Direction to navigate: forward or backward. |
    ...    | number_of_weeks_to_navigate | Number of week steps to navigate (integer). |
    ...    | forward_button_locator | Locator for the forward/next week arrow button. |
    ...    | backward_button_locator | Locator for the backward/previous week arrow button. |
    ...    | selected_week_locator | Locator template for the currently selected week, containing {WEEK} placeholder used for verification. |
    ...    Example usage:
    ...    | Navigate Calendar By Weeks And Verify Navigated Week    forward    3    ${FORWARD_ARROW}    ${BACKWARD_ARROW}    ${SELECTED_WEEK_LOCATOR}
    [Arguments]    ${navigation_direction}
    ...    ${number_of_weeks_to_navigate}
    ...    ${forward_button_locator}
    ...    ${backward_button_locator}
    ...    ${selected_week_locator}
    ${number_of_weeks_to_navigate}    Convert To Integer    ${number_of_weeks_to_navigate}

    ${CALENDAR_NAVIGATION_DATE_FORMAT}    Get Config Value    key=CALENDAR_NAVIGATION_DATE_FORMAT
    ${WEEK_START_DAY}    Get Config Value    key=FISCAL_WEEK_START_DAY

    ${navigation_base_date_exists}    Run Keyword And Return Status    Variable Should Exist    ${NAVIGATION_BASE_DATE}
    IF    not ${navigation_base_date_exists}
        ${current_week_date}    Get Current Week Start Date    ${CALENDAR_NAVIGATION_DATE_FORMAT}    ${WEEK_START_DAY}
        VAR    ${NAVIGATION_BASE_DATE}    ${current_week_date}    scope=GLOBAL
        VAR    ${CUMULATIVE_WEEKS_DELTA}    ${0}    scope=GLOBAL
    END

    IF    '${navigation_direction}' == '${NAVIGATION_DIRECTION_FORWARD}'
        VAR    ${navigator_button_locator}    ${forward_button_locator}
        VAR    ${weeks_delta_per_step}    ${1}
    ELSE IF    '${navigation_direction}' == '${NAVIGATION_DIRECTION_BACKWARD}'
        VAR    ${navigator_button_locator}    ${backward_button_locator}
        VAR    ${weeks_delta_per_step}    ${-1}
    ELSE
        Fail    Invalid navigation_direction. Use '${NAVIGATION_DIRECTION_FORWARD}' or '${NAVIGATION_DIRECTION_BACKWARD}'.
    END

    FOR    ${_}    IN RANGE    ${number_of_weeks_to_navigate}
        Click Element On Webpage    ${navigator_button_locator}
        ...    error_message=Failed to click ${navigation_direction} navigation button on calendar
        Wait Until Page Is Loaded
        Capture Screenshot On Webpage
        ${updated_cumulative_delta}    Evaluate    ${CUMULATIVE_WEEKS_DELTA} + ${weeks_delta_per_step}
        VAR    ${CUMULATIVE_WEEKS_DELTA}    ${updated_cumulative_delta}    scope=GLOBAL
        ${expected_week_label}    Get Expected Week From Base Date    ${NAVIGATION_BASE_DATE}    ${CUMULATIVE_WEEKS_DELTA}
        Verify Week Label Is Displayed    ${expected_week_label}    ${selected_week_locator}
    END

Get Expected Week From Base Date
    [Documentation]
    ...    Calculates the expected week label based on a base date and cumulative weeks offset.
    ...    This approach maintains proper navigation state across multiple navigation sequences.
    ...    | =Arguments= | =Description= |
    ...    | base_date | The base week start date to calculate from. |
    ...    | cumulative_weeks_delta | Total weeks offset from base date (positive = forward, negative = backward). |
    ...    | =Returns= | =Description= |
    ...    | expected_week_label | Formatted week label string for UI verification (includes "Week Of " prefix). |
    ...    Example usage:
    ...    | ${week_label} =    Get Expected Week From Base Date    ${base_date}    ${delta}
    [Arguments]    ${base_date}    ${cumulative_weeks_delta}
    ${CALENDAR_NAVIGATION_DATE_FORMAT}    Get Config Value    key=CALENDAR_NAVIGATION_DATE_FORMAT

    ${navigated_date}    Evaluate
    ...    (datetime.datetime.strptime('${base_date}', '${CALENDAR_NAVIGATION_DATE_FORMAT}') + datetime.timedelta(weeks=${cumulative_weeks_delta})).strftime('${CALENDAR_NAVIGATION_DATE_FORMAT}')
    ...    modules=datetime
    VAR    ${expected_week_label}    Week Of ${navigated_date}

    RETURN    ${expected_week_label}

Verify Week Label Is Displayed
    [Documentation]
    ...    Verifies that the calendar UI displays the expected week label.
    ...    Constructs the locator from template and verifies the element is visible.
    ...    | =Arguments= | =Description= |
    ...    | expected_week_label | Week label string to verify (e.g., "Week Of Oct 05, 2025"). |
    ...    | week_locator_template | Locator template containing {WEEK} placeholder to be replaced. |
    ...    Example usage:
    ...    | Verify Week Label Is Displayed    Week Of Oct 05, 2025    ${WEEK_LABEL_TEMPLATE}
    [Arguments]    ${expected_week_label}    ${week_locator_template}
    ${week_label_locator}    Update Locator With Dynamic Values
    ...    ${week_locator_template}
    ...    WEEK=${expected_week_label}
    Wait Until Element Is Visible On Webpage    ${week_label_locator}
    ...    error_message=Expected week label '${expected_week_label}' not visible on page

Navigate Calendar By Weeks And Verify Navigated Week Range
    [Documentation]
    ...    Navigates the calendar by specified number of weeks in the given direction (forward/backward)
    ...    and verifies the displayed week range after each navigation step.
    ...    The appropriate navigation button is automatically selected based on the direction.
    ...    | =Arguments= | =Description= |
    ...    | navigation_direction | Direction to navigate: forward or backward. |
    ...    | number_of_weeks_to_navigate | Number of week steps to navigate (integer). |
    ...    | forward_button_locator | Locator for the forward/next week arrow button. |
    ...    | backward_button_locator | Locator for the backward/previous week arrow button. |
    ...    | selected_week_range_locator | Locator template for the currently selected week range, containing {WEEK_RANGE} placeholder used for verification. |
    ...    | calendar_navigation_date_format | Date format string used for formatting dates. |
    ...    Example usage:
    ...    | Navigate Calendar By Weeks And Verify Navigated Week Range    backward    1    ${forward_button_locator}    ${backward_button_locator}    ${selected_week_range_locator}    ${calendar_navigation_date_format}
    [Arguments]    ${navigation_direction}
    ...    ${number_of_weeks_to_navigate}
    ...    ${forward_button_locator}
    ...    ${backward_button_locator}
    ...    ${selected_week_range_locator}
    ...    ${calendar_navigation_date_format}
    ${WEEK_START_DAY}    Get Config Value    key=FISCAL_WEEK_START_DAY
    ${navigation_base_date_exists}    Run Keyword And Return Status    Variable Should Exist    ${NAVIGATION_BASE_DATE}
    IF    not ${navigation_base_date_exists}
        ${current_week_date}    Get Current Week Start Date    ${calendar_navigation_date_format}    ${WEEK_START_DAY}
        VAR    ${NAVIGATION_BASE_DATE}    ${current_week_date}    scope=GLOBAL
        VAR    ${CUMULATIVE_WEEKS_DELTA}    ${0}    scope=GLOBAL
    END

    IF    '${navigation_direction}' == '${NAVIGATION_DIRECTION_FORWARD}'
        VAR    ${navigator_button_locator}    ${forward_button_locator}
        VAR    ${weeks_delta_per_step}    ${1}
    ELSE IF    '${navigation_direction}' == '${NAVIGATION_DIRECTION_BACKWARD}'
        VAR    ${navigator_button_locator}    ${backward_button_locator}
        VAR    ${weeks_delta_per_step}    ${-1}
    ELSE
        Fail    Invalid navigation_direction. Use '${NAVIGATION_DIRECTION_FORWARD}' or '${NAVIGATION_DIRECTION_BACKWARD}'.
    END

    ${number_of_weeks_to_navigate}    Convert To Integer    ${number_of_weeks_to_navigate}
    FOR    ${_}    IN RANGE    ${number_of_weeks_to_navigate}
        Click Element On Webpage    ${navigator_button_locator}
        ...    error_message=Failed to click ${navigation_direction} navigation button on calendar
        Wait Until Page Is Loaded
        Capture Screenshot On Webpage
        ${updated_cumulative_delta}    Evaluate    ${CUMULATIVE_WEEKS_DELTA} + ${weeks_delta_per_step}
        VAR    ${CUMULATIVE_WEEKS_DELTA}    ${updated_cumulative_delta}    scope=GLOBAL
        ${expected_week_range_label}    Get Expected Week Range From Base Date    ${NAVIGATION_BASE_DATE}    ${CUMULATIVE_WEEKS_DELTA}
        ...    ${calendar_navigation_date_format}
        Verify Week Label Is Displayed    ${expected_week_range_label}    ${selected_week_range_locator}
    END

Get Expected Week Range From Base Date
    [Documentation]
    ...    Returns a single formatted label string containing both the start and end dates of the week for UI verification.
    ...    | =Arguments= | =Description= |
    ...    | base_date | The base week start date to calculate from. |
    ...    | cumulative_weeks_delta | Total weeks offset from base date (positive = forward, negative = backward). |
    ...    | calendar_navigation_date_format | Date format string used for formatting dates. |
    ...    | =Returns= | =Description= |
    ...    | expected_week_label | Formatted week range label string: "from {start_date} to {end_date}" (e.g., "from 12/21/2025 to 12/27/2025"). |
    ...    Example usage:
    ...    | ${expected_week_label} =    Get Expected Week Range From Base Date    ${base_date}    ${cumulative_weeks_delta}    ${calendar_navigation_date_format}
    [Arguments]    ${base_date}    ${cumulative_weeks_delta}    ${calendar_navigation_date_format}
    ${week_start_date}    Evaluate
    ...    (datetime.datetime.strptime('${base_date}', '${calendar_navigation_date_format}') + datetime.timedelta(weeks=${cumulative_weeks_delta})).strftime('${calendar_navigation_date_format}')
    ...    modules=datetime
    ${week_end_date}    Evaluate
    ...    (datetime.datetime.strptime('${base_date}', '${calendar_navigation_date_format}') + datetime.timedelta(weeks=${cumulative_weeks_delta}, days=6)).strftime('${calendar_navigation_date_format}')
    ...    modules=datetime
    VAR    ${expected_week_start_date}    ${week_start_date}
    VAR    ${expected_week_end_date}    ${week_end_date}
    VAR    ${expected_week_label}    from ${expected_week_start_date} to ${expected_week_end_date}
    RETURN    ${expected_week_label}
