*** Settings ***
Documentation       Resource file containing keywords for ESS My Monthly Calendar functionality.
...                 Provides functions for navigating and verifying monthly schedule views from ESS user perspective.

Library             DateTime
Library             test_data/TestDataLibrary.py
Variables           resources/web/ess/ess_monthly_calendar_page.py
Variables           resources/web/common/menu_page.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To ESS My Monthly Calendar Page On Web
    [Documentation]    Navigate to ESS -> My Schedule -> My Monthly Calendar tab
    ...    and verify that the monthly calendar page is displayed successfully.
    ...
    ...    This keyword:
    ...    1. Clicks on My Schedule menu option
    ...    2. Clicks on My Monthly Calendar tab
    ...    3. Verifies Monthly Schedule page title is displayed
    Navigate To Specific Page On Web    ess    my_monthly_calendar
    Wait Until Page Is Loaded

Select Day On My Monthly Calendar Page On Web
    [Documentation]
    ...    Selects a date on the web calendar using a week-day format (e.g., 1_2).
    ...    Navigates through year, month, and day selectors to pick the target date.
    ...    | =Arguments=    | =Description=    |
    ...    | week_day_input    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    ...    Example usage:
    ...    | Select Day On My Monthly Calendar Page On Web    2_3
    [Arguments]    ${week_day_input}
    Wait Until Page Is Loaded
    Select Date Through Date Picker For ESS Requests On Webpage    ${ESS_MONTHLY_CALENDAR_BUTTON}    ${week_day_input}

Verify Shifts Are Displayed For Specified Days In Given Week On ESS Monthly Calendar Page On Web
    [Documentation]    Verify that shifts are displayed for specified days in the current week.
    ...
    ...    Arguments:
    ...    - days_with_shifts: List of day numbers (0-6) that should have shifts
    ...    - week_offset: Week offset number (e.g., 2 for week 2)
    ...
    ...    Example: Verify Shifts Are Displayed For Specified Days In Given Week On ESS Monthly Calendar Page On Web    [0, 1, 2]    2
    [Arguments]    ${days_with_shifts}    ${week_offset}

    # Get date format from config
    ${date_format}=    Get Config Value    key=DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA

    FOR    ${day_offset}    IN    @{days_with_shifts}
        # Construct week_day format: week_offset + "_" + day_offset (e.g., "2_0")
        VAR    ${week_day_format}=    ${week_offset}_${day_offset}
        ${target_date}=    Calculate Date From Week Day Offset    ${week_day_format}    ${date_format}

        # Build the dynamic XPath using framework pattern
        ${shift_locator}=    Update Locator With Dynamic Values    ${ESS_MONTHLY_CALENDAR_SHIFT_CONTAINER_BY_DATE}    DATE=${target_date}

        Log    Checking for shift on day ${day_offset} (${target_date})    level=INFO
        Log    Using XPath: ${shift_locator}    level=DEBUG

        ${is_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${shift_locator}
        Should Be True    ${is_visible}    msg=Shift not found on day ${day_offset} (${target_date}) but should exist

        Log    ✅ Shift found on day ${day_offset} (${target_date})    level=INFO
    END

Verify No Shifts Are Displayed For Specified Days In Given Week On ESS Monthly Calendar Page On Web
    [Documentation]    Verify that no shifts are displayed for days that do NOT have shifts in the current week.
    ...
    ...    Arguments:
    ...    - days_with_shifts: List of day numbers (0-6) that have shifts
    ...    - week_offset: Week offset number (e.g., 2 for week 2)
    ...
    ...    Example: Verify No Shifts Are Displayed For Specified Days In Given Week On ESS Monthly Calendar Page On Web    [0, 1, 2]    2
    [Arguments]    ${days_with_shifts}    ${week_offset}

    # Get date format from config
    ${date_format}=    Get Config Value    key=DATE_FMT_ABBR_MONTH_DAY_YEAR_NO_COMMA

    ${days_without_shifts}=    Evaluate    [day for day in range(7) if day not in ${days_with_shifts}]

    FOR    ${day_offset}    IN    @{days_without_shifts}
        # Construct week_day format: week_offset + "_" + day_offset (e.g., "2_3")
        VAR    ${week_day_format}=    ${week_offset}_${day_offset}
        ${target_date}=    Calculate Date From Week Day Offset    ${week_day_format}    ${date_format}

        Log    Checking that no shift exists on day ${day_offset} (${target_date})    level=INFO

        # Build the dynamic XPath using framework pattern
        ${shift_locator}=    Update Locator With Dynamic Values    ${ESS_MONTHLY_CALENDAR_SHIFT_CONTAINER_BY_DATE}    DATE=${target_date}

        # Verify element is NOT visible
        ${is_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${shift_locator}
        Should Not Be True    ${is_visible}    msg=Shift found on day ${day_offset} (${target_date}) but should not exist

        Log    ✅ No shift found on day ${day_offset} (${target_date}) - as expected    level=INFO
    END

Click On Week Label On ESS Monthly Calendar Page On Web
    [Documentation]    Clicks on the week label on ESS Monthly Calendar page to open the week details popup
    Click Element On Webpage    ${ESS_MONTHLY_CALENDAR_BUTTON}    error_message=Failed to click on week label on ESS Monthly Calendar page
    Wait Until Element Is Visible On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_DATE_PICKER_POPUP}
    ...    error_message=Week details popup did not appear after clicking week label on ESS Monthly Calendar page
    Capture Screenshot On Webpage

Click On Filter Icon On ESS Monthly Calendar Page On Web
    [Documentation]    Clicks on the filter icon on ESS Monthly Calendar page to open the filter menu
    Click Element On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_FILTER_ICON}
    ...    error_message=Failed to click on filter icon on ESS Monthly Calendar page
    Wait Until Element Is Visible On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_FILTER_DIALOG}
    ...    error_message=Filter menu did not appear after clicking filter icon on ESS Monthly Calendar page
    Capture Screenshot On Webpage

Click On Legend Icon On ESS Monthly Calendar Page On Web
    [Documentation]    Clicks on the legend icon on ESS Monthly Calendar page to open the legend
    Click Element On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_LEGEND_ICON}
    ...    error_message=Failed to click on legend icon on ESS Monthly Calendar page
    Wait Until Element Is Visible On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_LEGEND_POPUP}
    ...    error_message=Legend popup did not appear after clicking legend icon on ESS Monthly Calendar page
    Capture Screenshot On Webpage

Click On Action Icon On ESS Monthly Calendar Page On Web
    [Documentation]    Clicks on the action icon on ESS Monthly Calendar page to open the action menu
    Click Element On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_ACTION_BUTTON}
    ...    error_message=Failed to click on action icon on ESS Monthly Calendar page
    Wait Until Element Is Visible On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_ACTION_BUTTON_MENU}
    ...    error_message=Action menu did not appear after clicking action icon on ESS Monthly Calendar page
    Capture Screenshot On Webpage

Click On Balance Date Picker On ESS Monthly Calendar Page On Web
    [Documentation]    Clicks on the balance date picker on ESS Monthly Calendar page to open the date picker
    Click Element On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_BALANCE_DATE_PICKER}
    ...    error_message=Failed to click on balance date picker on ESS Monthly Calendar page
    Wait Until Element Is Visible On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_BALANCE_DATE_PICKER_POPUP}
    ...    error_message=Balance date picker did not appear after clicking balance date picker on ESS Monthly Calendar page
    Capture Screenshot On Webpage

Click On Schedule Link On ESS Monthly Calendar Page On Web
    [Documentation]    Clicks on the schedule link on ESS Monthly Calendar page to navigate to the schedule details page
    Click Element On Webpage    ${ESS_MONTHLY_CALENDAR_PAGE_SCHEDULE_LNK}
    ...    error_message=Failed to click on schedule link on ESS Monthly Calendar page
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
