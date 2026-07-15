*** Settings ***
Documentation       Resource file for Timecard Screen

Library             DateTime
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/Common/PWD_Utils.resource


*** Keywords ***
Navigate Timecard Calendar On Mobile ESS
    [Documentation]    Used for navigation of calendar based on current open date of calendar and required date.
    ...
    ...    Args:
    ...    ${date_offset}: Date in offset format
    ...    ${calendar_open_date}: current selected date range
    [Arguments]    ${date_offset}    ${calendar_open_date}=${None}
    ${format_for_current_open_date}    Get Config Value    DATE_FMT_YEAR_MONTH_DAY
    IF    '${calendar_open_date}' == ''
        ${current_selected_date}    Calculate Date From Week Day Offset    ${calendar_open_date}    ${format_for_current_open_date}
        ${week_start}    Calculate Week Start    ${current_selected_date}
    ELSE
        ${today}    Get Current Date    result_format=${format_for_current_open_date}
        ${week_start}    Calculate Week Start    ${today}
    END
    ${year_only_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${week_end_date_format}    Convert Date    ${week_start}    ${format_for_current_open_date}
    ${week_end}    Add Time To Date    ${week_end_date_format}    6 days
    ${start_year}    Convert Date    ${week_start}    ${year_only_format}
    ${end_year}      Convert Date    ${week_end}      ${year_only_format}
    ${month_date_year_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${month_date_format}    Get Config Value    MONTH_DAY_FORMAT
    IF    '${start_year}' == '${end_year}'
        ${week_start_date}    Convert Date    ${week_start}    ${month_date_format}
        ${week_start_date}    Strip Leading Zeros From Date    ${week_start_date}
        ${week_end_date}    Convert Date    ${week_end}    ${month_date_format}
        ${week_end_date}    Strip Leading Zeros From Date    ${week_end_date}
        ${date_picker_locator}    Get Localised Locator Exact    requests.details.label.start_to_end_day
        ...    ${week_start_date}    ${week_end_date}
    ELSE
        ${week_start_date}    Convert Date    ${week_start}    ${month_date_year_format}
        ${week_end_date}    Convert Date    ${week_end}    ${month_date_year_format}
        ${date_picker_locator}    Get Localised Locator Exact    requests.details.label.start_to_end_day
        ...    ${week_start_date}    ${week_end_date}
    END

    Wait Until Page Contains Element    ${date_picker_locator}
    Click Element    ${date_picker_locator}
    ${server_df_format}    Get Config Value    SERVER_DF
    ${offset_date_formated}    Calculate Date From Week Day Offset    ${date_offset}    ${server_df_format}
    ${is_date_before_today}    Is Past Date    ${offset_date_formated}
    # Single digit logic
    ${full_date_format}    Get Config Value    FULL_DATE_DF_MONTH_SHORT
    ${complete_date}    Calculate Date From Week Day Offset    ${date_offset}    ${full_date_format}
    ${complete_date_without_zero}    Strip Leading Zeros From Date    ${complete_date}
    ${pwd_final_locator}    Get Locator Contains    ${complete_date_without_zero}
    IF    ${is_date_before_today}
        Swipe Until Visible    ${pwd_final_locator}    "up"
    ELSE
        Swipe Until Visible    ${pwd_final_locator}
    END
    Click Element    ${pwd_final_locator}
    ${apply_locator}    Get Localised Locator Exact    ${applyOnCalender}
    Click Element    ${apply_locator}

Verify Timecard Actual Punch On Mobile ESS
    [Documentation]    Used for verifying the Timecard Tab Punch Item on Mobile ESS.
    ...    Args:
    ...    ${punch_item}: punch item
    [Arguments]    ${punch_item}
    Validate 24 Hour Time Format    ${punch_item}
    ${start_localised_time}    Format Time String    ${punch_item}
    ${locator}    Get Locator Contains    ${start_localised_time}
    Swipe Until Visible    ${locator}

Select Day From Displayed Week On Mobile ESS
    [Documentation]    Used for selecting the day from displayed week on mobile ESS app.
    ...    Args:
    ...    ${shift_day}: The day of the shift which needs to be selected.
    [Arguments]    ${shift_day}
    ${full_date_format}    Get Config Value    SHIFT_HORIZONTAL_CALENDAR_FULL_DATE
    ${readable_date}    Calculate Date From Week Day Offset    ${shift_day}    ${full_date_format}
    ${readable_date_without_zero}    Strip Leading Zeros From Date    ${readable_date}
    ${shift_day_locator}    Get Locator Contains    ${readable_date_without_zero}
    Wait Until Page Contains Element    ${shift_day_locator}
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}    Click Element    ${shift_day_locator}

Select All Tab On Mobile ESS
    [Documentation]    Used for selecting the All tab on mobile ESS app
    ${all_tab_locator}    Get Localised Locator Contains    ${common_label_select_all}
    Swipe Until Visible    ${all_tab_locator}    "up"
    Wait Until Element Is Visible    ${all_tab_locator}
    Click Element    ${all_tab_locator}
