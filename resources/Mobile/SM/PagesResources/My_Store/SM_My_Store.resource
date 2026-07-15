*** Settings ***
Documentation       This resource contains keyword required for login and registration related features.

Library             DateTime
Library             Process
Library             test_data/TestDataLibrary.py
Resource            resources/Mobile/Common/Common_Mobile.resource
Variables          resources/Mobile/SM/Locators/SM_My_Store_Page.py


*** Keywords ***
Navigate To My Store Page On SM Phone App
    [Documentation]    Navigates to My Store page on SM mobile app.
    ${my_store_menu_locator}    Get Localised Locator Contains For SM    ${SM_MY_STORE_MENU}
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}    Wait Until Element Is Visible    ${my_store_menu_locator}
    ...    error=My Store menu is not displayed on mobile.
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}    Click Element    ${my_store_menu_locator}
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}    Wait Until Element Is Visible    ${SM_MY_STORE_PAGE_TITLE}
    ${my_store_label_semantic}    Get Localised Message From Key For SM    ${SM_MY_STORE_MENU}
    ${my_store_page_title}    Get Message With Arguments For SM    ${SM_MY_STORE_DYNAMIC_PAGE_TITLE}    ${my_store_label_semantic}
    Wait Until Element Is Visible    ${my_store_page_title}    10s

Navigate Calendar To Target Week On SM Schedule Page On Mobile
    [Documentation]
    ...    Navigates the SM calendar to the week containing the target date.
    ...    Calculates the number of weeks between the current open date and target date, then clicks
    ...    the next or previous week arrow button accordingly.
    ...    | =Arguments= | =Description= |
    ...    | target_date | Target date in week_day offset format (e.g., 1_4). |
    ...    | calendar_open_date | Current open date in week_day offset format. Defaults to today if not provided. |
    ...    Example usage:
    ...    | Navigate Calendar To Target Week On SM Store Schedule Page On Mobile    1_4
    ...    | Navigate Calendar To Target Week On SM Store Schedule Page On Mobile    2_1    calendar_open_date=0_3
    [Arguments]    ${target_date}    ${calendar_open_date}=TODAY
    ${calendar_date_format}    Get Config Value    DATE_FMT_YEAR_MONTH_DAY
    # Resolve current open date — use today if not provided
    IF    '${calendar_open_date}' == 'TODAY'
        ${current_date_iso}    Get Current Date    result_format=${calendar_date_format}
    ELSE
        ${current_date_iso}    Calculate Date From Week Day Offset    ${calendar_open_date}    ${calendar_date_format}
    END
    # Resolve target date from week_day format
    ${target_date_iso}    Calculate Date From Week Day Offset    ${target_date}    ${calendar_date_format}
    # Calculate week start dates for both
    ${current_week_start}    Calculate Week Start    ${current_date_iso}
    ${target_week_start}    Calculate Week Start    ${target_date_iso}
    # Calculate difference in weeks
    ${diff_seconds}    Subtract Date From Date    ${target_week_start}    ${current_week_start}
    ${weeks_diff}    Evaluate    int(${diff_seconds} / (7 * 24 * 3600))
    Log To Console    Calendar navigation: current week start=${current_week_start}, target week start=${target_week_start}, weeks to navigate=${weeks_diff}
    # Navigate forward or backward
    IF    ${weeks_diff} > 0
        FOR    ${_}    IN RANGE    ${weeks_diff}
            Sleep    2s
            Wait Until Page Contains Element    ${SM_SCHEDULE_PAGE_NEXT_WEEK_BUTTON}    30s
            ...    error=Next week arrow button is not displayed on store schedule page.
            Click Element    ${SM_SCHEDULE_PAGE_NEXT_WEEK_BUTTON}
        END
    ELSE IF    ${weeks_diff} < 0
        ${abs_weeks}    Evaluate    abs(${weeks_diff})
        FOR    ${_}    IN RANGE    ${abs_weeks}
            Sleep    2s
            Wait Until Page Contains Element    ${SM_SCHEDULE_PAGE_PREVIOUS_WEEK_BUTTON}    30s
            ...    error=Previous week arrow button is not displayed on store schedule page.
            Click Element    ${SM_SCHEDULE_PAGE_PREVIOUS_WEEK_BUTTON}
        END
    ELSE
        Log To Console    Target date is already in the current week — no navigation needed.
    END

Verify User Name On Header Profile On My Store Page On Mobile
    [Documentation]    Used to verify user name on header profile on my store page.
    ...    | === Arguments === | === Description === |
    ...    | user_key | User unique key from credentials |
    [Arguments]    ${user_key}
    ${user}    Get User    ${user_key}    mask_password=False
    Wait Until Page Contains Element    ${SM_MY_STORE_PROFILE_ICON}    timeout=60s
    Click Element    ${SM_MY_STORE_PROFILE_ICON}
    ${profile_name_label}    Get Message With Arguments For SM    ${SM_MY_STORE_PROFILE_NAME}    ${user}[username]
    Wait Until Page Contains Element    ${profile_name_label}    error=Header profile does not contain expected username
    Click Element    ${SM_MY_STORE_PROFILE_DIALOG_CLOSE_BTN}

Click Open Shifts Section On My Store Page On SM Phone App
    [Documentation]    Used to click open shifts section on my store page.
    ${my_store_open_shifts_label}    Get Localised Message From Key For SM   ${SM_MY_STORE_OPEN_SHIFTS}
    ${my_store_open_shifts_locator}    Get Locator Contains For SM    ${my_store_open_shifts_label}
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}    Click Element    ${my_store_open_shifts_locator}
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}    Wait Until Element Is Visible    ${SM_MY_STORE_PAGE_TITLE}
    ${my_store_page_title}    Get Message With Arguments For SM    ${SM_MY_STORE_DYNAMIC_PAGE_TITLE}    ${my_store_open_shifts_label}
    Wait Until Element Is Visible    ${my_store_page_title}    10s

Select Week On My Store Page On SM Phone App
    [Documentation]    Used to select target week on the calendar using a week-day format (e.g., 1_2).
    ...    | =Arguments=    | =Description=    |
    ...    | week_day_offset    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    ...    | calendar_open_date | Current open date in week_day offset format. Defaults to today if not provided. |
    ...    Example usage:
    ...    | Select Week On My Store Page On SM Phone App    1_4    calendar_open_date=0_2 |
    [Arguments]    ${week_day_offset}    ${calendar_open_date}=${None}
    Select Date On SM Calendar    ${CALENDAR_NAVIGATION}    ${week_day_offset}    ${calendar_open_date}
