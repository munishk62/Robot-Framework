*** Settings ***
Documentation
...                 This resource file provides utility keywords specifically for Request Calendar UI interactions.
...
...                 = Purpose =
...                 - Centralizes Request Calendar-specific date selection and navigation actions.
...                 - Shared between ESS and RWS/SM request calendar implementations.
...
...                 = Prerequisites =
...                 - Required libraries: DateTime, String, Browser.
...                 - The common.resource file must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Select Calendar Day
...                 |    Select Day On Request Calendar Page    1_2

Library             DateTime
Library             String
Resource            resources/web/common/common.resource


*** Keywords ***
Select Day On Request Calendar Page
    [Documentation]
    ...    Selects a date on the web calendar using a week-day format (e.g., 1_2).
    ...    Navigates through year, month, and day selectors to pick the target date.
    ...    | =Arguments=    | =Description=    |
    ...    | week_day_input    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    ...    Example usage:
    ...    | Select Day On Request Calendar Page    2_3
    [Arguments]    ${week_day_input}
    ${is_header_icons_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${REQUEST_CALENDAR_PAGE_HEADER_ICONS}    timeout=${SHORT_TIMEOUT}
    IF    ${is_header_icons_visible}
        ${is_selected_view_weekly}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${REQUEST_CALENDAR_PAGE_SELECTED_VIEW_WEEKLY}    timeout=${SHORT_TIMEOUT}
        IF    not ${is_selected_view_weekly}
            Click Element On Webpage    ${REQUEST_CALENDAR_PAGE_WEEKLY_VIEW_BUTTON}
            ...    error_message=Weekly view button not found on Request Calendar page.
        END
    END
    Select Date Through Date Picker For ESS Requests On Webpage    ${REQUEST_CALENDAR_PAGE_CALENDAR_MONTH_AND_YEAR}    ${week_day_input}
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}
    ...    Verify Header Week Start Date On Week Label On Web    ${week_day_input}    ${REQUEST_CALENDAR_PAGE_CALENDAR_MONTH_AND_YEAR}
