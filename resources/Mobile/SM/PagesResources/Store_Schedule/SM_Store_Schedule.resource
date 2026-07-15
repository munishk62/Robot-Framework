*** Settings ***
Documentation       This resource contains keyword required for login and registration related features.

Library             Process
Library             test_data/TestDataLibrary.py
Resource            resources/Mobile/Common/Common_Mobile.resource
Resource            resources/Mobile/Common/PWD_Utils.resource
Variables           resources/Mobile/SM/Locators/SM_Store_Schedule_Page.py


*** Keywords ***
Navigate To Store Schedule Page On SM Phone App
    [Documentation]    Navigates to store schedule page on SM mobile app.
    ${store_schedule_menu_locator}    Get Localised Locator Contains For SM    ${SM_STORE_SCHEDULE_MENU}
    Wait Until Keyword Succeeds    10 x    ${MEDIUM_TIMEOUT}    Wait Until Element Is Visible    ${store_schedule_menu_locator}
    ...    error=Store Schedule menu is not displayed on mobile.
    Wait Until Keyword Succeeds    10 x    ${MEDIUM_TIMEOUT}    Click Element    ${store_schedule_menu_locator}
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}    Wait Until Element Is Visible    ${SM_STORE_SCHEDULE_PAGE_TITLE}
    ${store_schedule_label_semantic}    Get Localised Message From Key For SM    ${SM_STORE_SCHEDULE_MENU}
    ${store_schedule_page_title}    Get Message With Arguments For SM    ${SM_STORE_DYNAMIC_PAGE_TITLE}    ${store_schedule_label_semantic}
    Wait Until Element Is Visible    ${store_schedule_page_title}    10s

Verify Schedule Generated On Weekly Store Schedule Page On Mobile
    [Documentation]    Verifies that SM user can view the schedule generated on weekly schedule page on mobile.
    Wait Until Page Contains Element    ${SM_STORE_SCHEDULE_PAGE_ASSOCIATE_SCHEDULE_LIST}
    ...    error=Schedule is not generated on store schedule page on mobile.

Generate Schedule On Store Schedule Page On SM Phone App
    [Documentation]
    ...    Triggers the *Generate Schedule* action from the SM mobile Store Schedule page for the
    ...    currently selected week and waits for the generation to complete.
    ...
    ...    Resolves the localised _Generate Schedule_ button at runtime so the keyword keeps
    ...    working across locales and minor UI changes (the self-healing `LocatorInterceptor`
    ...    corrects the underlying XPath wrapper when needed). Embedded verification is
    ...    performed in two layers:
    ...    - the on-screen `Schedule Generated` confirmation must appear, AND
    ...    - the weekly schedule list must become visible.
    ...
    ...    Fails with actionable context if the Generate Schedule button is not present on the
    ...    page or if the generation does not finish inside ``LONG_TIMEOUT``.
    ...
    ...    Example usage:
    ...    | Navigate To Store Schedule Page On SM Phone App
    ...    | Select Week On Store Schedule Page On SM Phone App    5_0
    ...    | Generate Schedule On Store Schedule Page On SM Phone App
    Wait Until Page Contains Element    ${SM_STORE_SCHEDULE_OPTION_BUTTON}
    ...    error=Schedule options button is not visible on Store Schedule page on SM phone app for the selected week.
    Click Element    ${SM_STORE_SCHEDULE_OPTION_BUTTON}
    ${is_regenerate_visible}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    ${SM_STORE_SCHEDULE_REGENERATE_BUTTON}    timeout=${SHORT_TIMEOUT}
    IF    ${is_regenerate_visible}
        Click Element    ${SM_STORE_SCHEDULE_REGENERATE_BUTTON}
    ELSE
        Wait Until Element Is Visible
        ...    ${SM_STORE_SCHEDULE_GENERATE_BUTTON}
        ...    timeout=${LONG_TIMEOUT}
        ...    error=Neither Regenerate nor Generate Schedule option is visible after opening the schedule options menu.
        Click Element    ${SM_STORE_SCHEDULE_GENERATE_BUTTON}
    END

Navigate To Next Week By Next Arrow On Store Schedule Page On Mobile
    [Documentation]    Navigates to next week on store schedule page on SM mobile app.
    Wait Until Page Contains Element    ${SM_STORE_SCHEDULE_PAGE_NEXT_WEEK_BUTTON}
    ...    error=Next week arrow button is not displayed on store schedule page on mobile.
    ${calendar_date_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${week_start_date_before}    Get Week Start Date From Week Label On Store Schedule Page On Mobile
    Click Element    ${SM_STORE_SCHEDULE_PAGE_NEXT_WEEK_BUTTON}
    ${next_week_date}    Add Time To Date    ${week_start_date_before}    7 days
    ...    result_format=${calendar_date_format}    date_format=${calendar_date_format}
    ${week_start_date_after}    Get Week Start Date From Week Label On Store Schedule Page On Mobile
    Should Be Equal    ${next_week_date}    ${week_start_date_after}
    ...    msg=After clicking on next week arrow button, week start date on store schedule page is not updated to next week.

Navigate To Previous Week By Previous Arrow On Store Schedule Page On Mobile
    [Documentation]    Navigates to previous week on store schedule page on SM mobile app.
    Wait Until Element Is Visible    ${SM_STORE_SCHEDULE_PAGE_PREVIOUS_WEEK_BUTTON}
    ...    error=Previous week arrow button is not displayed on store schedule page on mobile.
    Click Element    ${SM_STORE_SCHEDULE_PAGE_PREVIOUS_WEEK_BUTTON}

Get Week Start Date From Week Label On Store Schedule Page On Mobile
    [Documentation]    Gets the week start date from week label on store schedule page.
    Wait Until Keyword Succeeds    10 x    ${MEDIUM_TIMEOUT}
    ...    Wait Until Element Is Visible    ${SM_STORE_SCHEDULE_PAGE_WEEK_LABEL}
    Click Element    ${SM_STORE_SCHEDULE_PAGE_WEEK_LABEL}
    ${week_label_date_locator}    Get Localised Locator Contains For SM    ${SM_STORE_SCHEDULE_SELECTED_WEEK_DATE}
    Wait Until Page Contains Element    ${week_label_date_locator}
    ${week_start_date}    AppiumLibrary.Get Text    ${week_label_date_locator}
    ${week_start_month}    AppiumLibrary.Get Text    ${SM_STORE_SCHEDULE_PAGE_DATE_WINDOW_MONTH}
    ${week_start_year}    AppiumLibrary.Get Text    ${SM_STORE_SCHEDULE_PAGE_DATE_WINDOW_YEAR}
    ${ymd_format}    Get Config Value    DATE_FMT_YEAR_MONTH_DAY
    ${ymd_date}    Convert Date    date=${week_start_date} ${week_start_month} ${week_start_year}
    ...    result_format=${ymd_format}    date_format=%d %B %Y
    ${calendar_date_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${week_label_start_date}    Get Week Start Date    ${ymd_date}    ${calendar_date_format}
    Click Element    ${SM_STORE_SCHEDULE_PAGE_OUTSIDE_AREA}
    RETURN    ${week_label_start_date}

Select Week On Store Schedule Page On SM Phone App
    [Documentation]    Used to select target week on the calendar using a week-day format (e.g., 1_2).
    ...    | =Arguments=    | =Description=    |
    ...    | week_day_input    | Date in week-day format (e.g., 1_2 for 1 week from current, 3rd day from weekstart). |
    ...    Example usage:
    ...    | Select Week On STore Schedule Page On SM Phone App    2_3
    [Arguments]    ${week_day_input}    ${calendar_open_date}=${None}
    Wait Until Page Does Not Contain Element    ${SPINNER_LOCATOR}    timeout=30s    error=Loading spinner is still visible on store schedule page
    ${server_df_format}    Get Config Value    SERVER_DF
    IF    $calendar_open_date is $None or '${calendar_open_date}' == ''
        ${today}    Get Current Date    result_format=%Y-%m-%d
        ${week_start}    Calculate Week Start    ${today}
        ${calendar_open_date_converted}    Convert Date    ${week_start}    ${server_df_format}
    ELSE
        ${calendar_open_date_converted}    Calculate Date From Week Day Offset    ${calendar_open_date}    ${server_df_format}
    END
    Wait Until Page Contains Element    ${CALENDAR_NAVIGATION}    timeout=20s
    Click Element    ${CALENDAR_NAVIGATION}
    Navigate SM Calendar To    ${week_day_input}    ${calendar_open_date_converted}

Search And Select Associate On Store Schedule Page On SM Phone App
    [Documentation]    Used to search associate name on store schedule page.
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Name of the associate to be searched |
    [Arguments]    ${associate_name}
    Wait Until Element Is Visible    ${SM_STORE_SCHEDULE_PAGE_TITLE}    error=Store schedule page screen is not loaded completely
    Wait Until Page Contains Element    ${SEARCH_ASSOCIATE_ICON}    timeout=20s    error=Search icon is not visible on store schedule page
    Click Element    ${SEARCH_ASSOCIATE_ICON}
    Wait Until Page Contains Element    ${SEARCH_ASSOCIATE_EDIT_TEXT}
    ...    error=Search textbox is not visible after clicking search icon on store schedule page
    Input Text    ${SEARCH_ASSOCIATE_EDIT_TEXT}    ${associate_name}

Select Shift On Date For Associate On Store Schedule Page On SM Phone App
    [Documentation]    Used to select shift on a particular date for an associate on store schedule page.
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Associate display name from users|
    ...    | shift_date | date of shift in week day format like 1_1|
    [Arguments]    ${associate_name}    ${shift_date}
    Select Date On Horizontal Calendar On Store Schedule Page On SM Phone App    ${shift_date}
    Search And Select Associate On Store Schedule Page On SM Phone App    ${associate_name}
    Wait Until Page Contains Element    ${ASSOCIATE_SHIFT_LOCATOR}    error=Shift for associate ${associate_name} is not displayed on store schedule page
    Click Element    ${ASSOCIATE_SHIFT_LOCATOR}

Select Date On Horizontal Calendar On Store Schedule Page On SM Phone App
    [Documentation]    Used to select date on horizontal calendar.
    ...    | === Arguments === | === Description === |
    ...    | shift_date | date of shift in week day format like 1_1|
    [Arguments]    ${shift_date}
    ${day_only_date_format}    Get Config Value    DATE_FMT_DAY_ONLY
    ${shift_date_converted}    Calculate Date From Week Day Offset    ${shift_date}    ${day_only_date_format}
    ${shift_date_converted}    Strip Leading Zeros From Date    ${shift_date_converted}
    ${calendar_day_locator}    Get Message With Arguments For SM    ${HORIZONTAL_CALENDAR_DAY_LOCATOR}    ${shift_date_converted}
    Wait Until Page Contains Element    ${calendar_day_locator}    error= Provided date is not displayed in horizontal calendar on store schedule page
    Click Element    ${calendar_day_locator}

Select Shift On Store Schedule Page On SM Phone App
    [Documentation]    Used to select shift on store schedule page.
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Associate display name from users|
    ...    | shift_date | date of shift in week day format like 1_1|
    ...    | shift_start_time | start time of the shift|
    ...    | shift_end_time | end time of the shift|
    [Arguments]    ${associate_name}    ${shift_date}    ${shift_start_time}    ${shift_end_time}
    ${formatted_start_time}    Format Time String    ${shift_start_time}
    ${formatted_end_time}    Format Time String    ${shift_end_time}
    Select Date On Horizontal Calendar On Store Schedule Page On SM Phone App    ${shift_date}
    Search And Select Associate On Store Schedule Page On SM Phone App    ${associate_name}
    ${shift_locator_msg}    Get Localised Message From Key For SM    ${SM_STORE_SCHEDULE_PAGE_SHIFT_ITEM}
    ${formatted_shift_msg}    Get Message With Arguments For SM    ${shift_locator_msg}    ${associate_name}    ${formatted_start_time}    ${formatted_end_time}
    ${shift_locator}    Get Locator Contains For SM    ${formatted_shift_msg}
    Wait Until Page Contains Element    ${shift_locator}    error= Shift for associate ${associate_name} with start time ${formatted_start_time} and end time ${formatted_end_time} is not displayed on store schedule page
    Click Element    ${shift_locator}

Get Shift Semantic On Store Schedule Page On SM Phone App
    [Documentation]    Used to verify shift is present on store schedule page.
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Associate display name from users|
    ...    | shift_start_time | start time of the shift|
    ...    | shift_end_time | end time of the shift|
    [Arguments]    ${associate_name}    ${shift_start_time}    ${shift_end_time}
    ${formatted_start_time}    Format Time String    ${shift_start_time}
    ${formatted_end_time}    Format Time String    ${shift_end_time}
    ${shift_locator_msg}    Get Localised Message From Key For SM    ${SM_STORE_SCHEDULE_PAGE_SHIFT_ITEM}
    ${formatted_shift_semantic}    Get Message With Arguments For SM    ${shift_locator_msg}    ${associate_name}    ${formatted_start_time}    ${formatted_end_time}
    RETURN    ${formatted_shift_semantic}

Verify Shift Visible On Store Schedule Page On SM Phone App
    [Documentation]    Used to verify shift is copied successfully on store schedule page after performing copy shift operation.
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Associate display name from users|
    ...    | copied_shift_date | date on which shift is copied in week day format like 1_1|
    ...    | shift_start_time | start time of the shift|
    ...    | shift_end_time | end time of the shift|
    [Arguments]    ${associate_name}    ${copied_shift_date}    ${shift_start_time}    ${shift_end_time}
    Select Date On Horizontal Calendar On Store Schedule Page On SM Phone App    ${copied_shift_date}
    Search And Select Associate On Store Schedule Page On SM Phone App    ${associate_name}
    ${shift_semantic}    Get Shift Semantic On Store Schedule Page On SM Phone App    ${associate_name}    ${shift_start_time}    ${shift_end_time}
    ${shift_locator}    Get Locator Contains For SM    ${shift_semantic}
    Wait Until Page Contains Element    ${shift_locator}    error= Shift for associate ${associate_name} with start time ${shift_start_time} and end time ${shift_end_time} is not displayed on store schedule page
    Run Keyword And Ignore Error    Hide Keyboard

Unallocate Shift For Associate On Store Schedule Page On SM Phone App
    [Documentation]    Used to unallocate shift for an associate on store schedule page on SM phone app.
    ...    | =Arguments=    | =Description=    |
    ...    | shift_day_offset | Week day offset to identify the shift to unallocate. |
    ...    | associate_name | Name of the associate for whom shift needs to be unallocated. |
    ...    | shift_start_time | Start time of the shift which needs to be unallocated. |
    ...    | shift_end_time | End time of the shift which needs to be unallocated. |
    ...    Example usage:
    ...    | Unallocate Shift For Associate On Store Schedule Page On SM Phone App    1_4    ess1_store2[displayName]    start_time    end_time |
    [Arguments]    ${shift_day_offset}    ${associate_name}    ${shift_start_time}    ${shift_end_time}
    Perform Shift Action For Associate On Store Schedule Page On SM Phone App
    ...    ${shift_day_offset}    ${associate_name}    ${shift_start_time}    ${shift_end_time}
    ...    ${SM_STORE_SCHEDULE_PAGE_UNALLOCATE_LABEL}

Unassign Shift For Associate On Store Schedule Page On SM Phone App
    [Documentation]    Used to unassign shift for an associate on store schedule page on SM phone app.
    ...    | =Arguments=    | =Description=    |
    ...    | shift_day_offset | Week day offset to identify the shift to unassign. |
    ...    | associate_name | Name of the associate for whom shift needs to be unassigned. |
    ...    | shift_start_time | Start time of the shift which needs to be unassigned. |
    ...    | shift_end_time | End time of the shift which needs to be unassigned. |
    ...    Example usage:
    ...    | Unassign Shift For Associate On Store Schedule Page On SM Phone App    1_4    ess1_store2[displayName]    start_time    end_time |
    [Arguments]    ${shift_day_offset}    ${associate_name}    ${shift_start_time}    ${shift_end_time}
    Perform Shift Action For Associate On Store Schedule Page On SM Phone App
    ...    ${shift_day_offset}    ${associate_name}    ${shift_start_time}    ${shift_end_time}
    ...    ${SM_STORE_SCHEDULE_PAGE_UNASSIGN_LABEL}

Perform Shift Action For Associate On Store Schedule Page On SM Phone App
    [Documentation]    Used to perform shift action for an associate on store schedule page on SM phone app.
    ...    | =Arguments=    | =Description=    |
    ...    | shift_day_offset | Week day offset to identify the shift. |
    ...    | associate_name | Name of the associate for whom shift action needs to be performed. |
    ...    | shift_start_time | Start time of the shift on which action needs to be performed. |
    ...    | shift_end_time | End time of the shift on which action needs to be performed. |
    ...    | shift_action_label_key | Localized label key for shift action option in more menu. |
    [Arguments]    ${shift_day_offset}    ${associate_name}    ${shift_start_time}    ${shift_end_time}    ${shift_action_label_key}
    ${is_12_hour_format}    Get Config Value    TIME_FORMAT_12_HRS
    Navigate To Store Schedule Page On SM Phone App
    Select Week On Store Schedule Page On SM Phone App    ${shift_day_offset}
    IF    ${is_12_hour_format}
        ${12_hour_start_time}    Convert 24hr Time To 12hr    ${shift_start_time}
        ${shift_start_time}    Convert To Lower Case    ${12_hour_start_time}
        ${12_hour_end_time}    Convert 24hr Time To 12hr    ${shift_end_time}
        ${shift_end_time}    Convert To Lower Case    ${12_hour_end_time}
    END
    VAR    ${time_range}    ${shift_start_time} - ${shift_end_time}
    ${shift_request_locator}    Get Message With Arguments For SM    ${SM_STORE_SCHEDULE_PAGE_ASSOCIATE_SHIFT}    ${associate_name}
    ...    ${time_range}
    Search And Select Associate On Store Schedule Page On SM Phone App    ${associate_name}
    Swipe Until Visible    ${shift_request_locator}
    Click Element    ${shift_request_locator}
    Wait Until Element Is Visible    ${SM_STORE_SCHEDULE_PAGE_SHIFT_MORE_ICON}
    Click Element    ${SM_STORE_SCHEDULE_PAGE_SHIFT_MORE_ICON}
    ${shift_action_text}    Get Localised Message From Key For SM    ${shift_action_label_key}
    ${shift_action_option_locator}    Get Message With Arguments For SM    ${SM_STORE_SCHEDULE_PAGE_SHIFT_MORE_OPTION}    ${shift_action_text}
    Wait Until Element Is Visible    ${shift_action_option_locator}
    Click Element    ${shift_action_option_locator}
    Wait Until Element Is Visible    ${SM_STORE_SCHEDULE_PAGE_CONFIRM_BUTTON}
    Click Element    ${SM_STORE_SCHEDULE_PAGE_CONFIRM_BUTTON}
    Verify Notification Appears On Store Schedule Page On SM Phone App

Verify Notification Appears On Store Schedule Page On SM Phone App
    [Documentation]    Used to verify notification appears on store schedule page on SM phone app after performing an action.
    Wait Until Element Is Visible    ${SM_STORE_SCHEDULE_PAGE_GENERIC_NOTIFICATION}    timeout=${LONG_TIMEOUT}
    ...    error=Notification message is not visible on store schedule page after performing action.
    Wait Until Page Does Not Contain Element    ${SM_STORE_SCHEDULE_PAGE_GENERIC_NOTIFICATION}

Publish Schedule On Store Schedule Page On SM Phone App
    [Documentation]    Used to publish schedule on store schedule page on SM phone app.
    Wait Until Page Contains Element    ${SM_STORE_SCHEDULE_PUBLISH_BUTTON}
    ...    error=Schedule publish button is not visible on Store Schedule page on SM phone app for the selected week.
    Click Element    ${SM_STORE_SCHEDULE_PUBLISH_BUTTON}
    Log    Schedule publish button clicked on Store Schedule page on SM phone app for the selected week.
