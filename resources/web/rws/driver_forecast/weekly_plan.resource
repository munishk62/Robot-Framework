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
Variables           resources/web/rws/driver_forecast/weekly_plan_page.py
Variables           resources/web/rws/schedule/fixed_shifts_page.py
Resource            resources/web/common/common_date_utility.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RWS Driver Forecast Weekly Plan Page On Web
    [Documentation]    Navigate To RWS -> Driver Forecast -> Weekly Plan Page
    ...    and verifies weekly plan heading at the top of the page
    Navigate To Specific Page On Web    rws    driver_forecast    weekly_plan

Go To The Next Week On Weekly Plan Page On Web
    [Documentation]    This keyword clicks on Next Week button to go to the next week.
    ...    | =Arguments=    | =Description=    |
    ...    | weeks_to_move    | The number of weeks to move forward from the current week    |
    ...    | =Returns=    | =Description=    |
    ...    | planning_week_date    | The date of the planning week after moving forward
    [Arguments]    ${weeks_to_move}=1
    FOR    ${index}    IN RANGE    ${weeks_to_move}
        Click Element On Webpage    ${WEEKLY_PLAN_PAGE_NEXT_WEEK_BTN}
        Wait Until Element Is Visible On Webpage    ${WEEKLY_PLAN_PAGE_CALENDAR_NAV_HEADER}    timeout=${LONG_TIMEOUT}
        ...    error_message=Calendar navigation header not visible after clicking Next Week button
        Log    Clicked on Next Week button ${index} times.
    END
    ${planning_week_txt}    Get Element Text On Webpage    ${WEEKLY_PLAN_PAGE_WEEKLY_PLANNING_WEEK}
    @{planning_week_date}    Split String    ${planning_week_txt}    :    1
    RETURN    ${planning_week_date}[1]

Initialize Forecast On Web
    [Documentation]    This keyword initializes the forecast by clicking on Initialize button.
    ...    | =Returns=    | =Description=    |
    ...    | init_fcst_date    | Returns the date on which forecast was initialized    |
    Click Element On Webpage    ${WEEKLY_PLAN_PAGE_INIT_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKLY_PLAN_PAGE_PENDING_INIT_LABEL}    timeout=${LONG_TIMEOUT}
    ...    error_message=Pending initialization label not visible after clicking Initialize button
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${init_fcst_date}    Get Current Date    result_format=${date_format}
    Capture Screenshot On Webpage
    Wait Until Page Is Loaded
    RETURN    ${init_fcst_date}

Click On View Jobs Button On Weekly Plan Page On Web
    [Documentation]    This keyword clicks on View Jobs button to view the batch jobs.
    Click Element On Webpage    ${WEEKLY_PLAN_PAGE_VIEW_JOBS_BTN}
    Wait Until Element Is Visible On Webpage    ${WEEKLY_PLAN_PAGE_BATCH_JOB_STATUS}
    Capture Screenshot On Webpage

Select The Org Level Location And Unit On Web
    [Documentation]    This keyword is used to select org level location and the unit from it. It uses
    ...    a robust, multi-stage JavaScript approach to handle all UI complexities including hover
    ...    events and virtual scrolling. This is the definitive solution for this component.
    ...    | =Arguments=    | =Description=    |
    ...    | ${org_level_name} | The name of the organizational level to select (e.g., 'Store') |
    ...    | ${unit_name}    | The name of the unit to select (e.g., 'ZAUTOSTORE001 - 8') |
    [Arguments]    ${org_level_name}    ${unit_name}
    Click Element On Webpage    ${WEEKLY_PLAN_PAGE_LOCATION_DRPDWN}
    Log    Triggering Hover via JavaScript on Org Level: ${org_level_name}
    ${org_level_locator}    Update Locator With Dynamic Values    ${WEEKLY_PLAN_PAGE_ORG_LEVEL_SELECT}    ORG_LEVEL=${org_level_name}
    Wait Until Element Is Visible On Webpage    ${org_level_locator}
    Evaluate JavaScript    ${org_level_locator}
    ...    (element) => {
    ...    if (element) {
    ...    const event = new MouseEvent('mouseover', { 'bubbles': true, 'cancelable': true });
    ...    element.dispatchEvent(event);
    ...    }
    ...    }
    Wait Until Element Is Visible On Webpage    ${WEEKLY_PLAN_PAGE_STORE_DRPDWN}
    Log    Scrolling to and clicking Unit: ${unit_name}
    ${unit_locator}    Update Locator With Dynamic Values    ${WEEKLY_PLAN_PAGE_UNIT_SELECT}    UNIT=${unit_name}
    ${unit_result}    Evaluate JavaScript    ${unit_locator}
    ...    (element) => {
    ...    if (!element) return false;
    ...    element.scrollIntoView({ block: 'center' }); // Ensures the element is on screen
    ...    element.click();
    ...    return true;
    ...    }
    IF    '${unit_result}' != 'True'
        Fail    Failed to scroll to and click the unit option: '${unit_name}'.
    END
    TRY
        Wait Until Element Disappears On Webpage    ${WEEKLY_PLAN_PAGE_SEARCH_FILTER}    ${SHORT_TIMEOUT}
    EXCEPT
        Wait Until Element Is Visible On Webpage    ${WEEKLY_PLAN_PAGE_SEARCH_FILTER}
    END
    Wait Until Page Is Loaded
    Click Element On Webpage    ${WEEKLY_PLAN_PAGE_WEEKLY_PLANNING_WEEK}
    Wait Until Element Is Visible On Webpage    ${WEEKLY_PLAN_PAGE_WEEKLY_PLANNING_WEEK}
    Capture Screenshot On Webpage

Get The Selected Week Number On Weekly Plan Page On Web
    [Documentation]    This keyword returns the selected week number on Weekly Plan Page.
    ...    | =Returns=    | =Description=    |
    ...    | week_number    | The selected week number on the Weekly Plan Page    |
    Click Element On Webpage    ${WEEKLY_PLAN_PAGE_SELECTED_WEEK}
    ${week_number}    Get Element Text On Webpage    ${WEEKLY_PLAN_PAGE_SELECTED_WEEK_NUMBER}
    RETURN    ${week_number}

Verify Week Is Displayed On Weekly Plan Page On Web
    [Documentation]    This keyword verifies that the week is displayed on Weekly Plan Page.
    ...    | =Arguments=    | =Description=    |
    ...    | week    | The week value to be verified on the Weekly Plan Page    |
    [Arguments]    ${week}
    ${week_displayed}    Update Locator With Dynamic Values    ${WEEKLY_PLAN_PAGE_WEEK_DISPLAYED}    WEEK=${week}
    Wait Until Element Is Visible On Webpage    ${week_displayed}    timeout=${LONG_TIMEOUT}

Select Week Number On Weekly Plan Page On Web
    [Documentation]    Selects the week on the Weekly Plan page using the calendar date picker.
    ...    Uses the same shared calendar component (FIXEDSHIFTSPAGE locators) as Labor Forecast.
    ...    | =Arguments= | =Description= |
    ...    | week_day_input | Week-day offset string (e.g., 4_0 for 4 weeks forward, start of week) |
    ...    Example usage:
    ...    | Select Week Number On Weekly Plan Page On Web    4_0
    [Arguments]    ${week_day_input}
    ${target_date}    Calculate Date From Week Day Offset    ${week_day_input}
    ${date_format_year_only}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${date_format_month_only}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${date_format}    Get Config Value    DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA
    ${target_year}    Convert Date    ${target_date}    result_format=${date_format_year_only}
    ${target_month_name}    Convert Date    ${target_date}    result_format=${date_format_month_only}
    ${target_day_formatted}    Convert Date    ${target_date}    result_format=${date_format}
    ${year_last_2_digits}    Evaluate    str('${target_year}')[2:]
    Wait Until Page Is Loaded
    Click Element On Webpage    ${WEEKLY_PLAN_PAGE_SELECTED_WEEK}
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
    Wait Until Page Is Loaded
    Wait Until Element Disappears On Webpage    ${FIXEDSHIFTPAGE_CALENDAR_POP_UP}
