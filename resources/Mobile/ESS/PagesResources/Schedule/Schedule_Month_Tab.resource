*** Settings ***
Documentation       Resource file for Schedule Month Tab Page

Resource            resources/Mobile/ESS/PagesResources/Schedule/Schedule_Landing_page.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Variables           resources/Mobile/ESS/Locators/Schedule.py
Library             test_data/TestDataLibrary.py


*** Keywords ***
Select Date In Calender On Month Tab On Mobile ESS
    [Documentation]    Select date in calender on month tab on mobile ESS.
    ...    Args:
    ...    ${date}: <date to be selected in calender in format x_y>
    [Arguments]    ${date}
    # Sunday, April 5, 2026
    ${month_only_format}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${weekday_only_format}    Get Config Value    DATE_FORMAT_WEEK_DAY_ONLY
    ${date_only_format}    Get Config Value    DATE_FMT_DAY_ONLY
    ${year_only_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${formatted_date}    Calculate Date From Week Day Offset In Multiple Formats    ${date}    ${month_only_format}
    ...    ${weekday_only_format}    ${date_only_format}    ${year_only_format}
    VAR    ${year}    ${formatted_date}[3]
    VAR    ${month}    ${formatted_date}[0]
    VAR    ${day}    ${formatted_date}[2]
    VAR    ${week_day}    ${formatted_date}[1]
    ${single_digit_day}    Convert To Integer    ${day}
    VAR    ${full_target_date}    ${week_day}, ${month} ${single_digit_day}, ${year}
    ${date_locator}    Get Locator Exact    ${full_target_date}
    Wait Until Element Is Visible    ${date_locator}
    Click Element    ${date_locator}

Verify Shift Details In Month Tab As Per Schedule On Mobile ESS
    [Documentation]    Verifies shift timings in shift details on mobile ESS app.
    ...    Args:
    ...    ${schedule}: <schedule data>
    ...    ${week_offset}: <week offset for schedule generation>
    [Arguments]    ${schedule}    ${week_offset}
    # schedule is in format 'dayNo': '0', 'startTime': 480, 'duration': 480, 'endTime': 960, 'uiStartTime': '08:00 AM', 'uiEndTime': '04:00 PM', 'description': '8:00 AM - 4:00 PM'
    FOR    ${shift}    IN    @{schedule}[shifts_to_add]
        ${shift_day}    Combine Week Offset And Day No    ${week_offset}    ${shift}[dayNo]
        Select Date In Calender On Month Tab On Mobile ESS    ${shift_day}
        Click On Expand Shift Details For The Selected Day On Mobile ESS
        Verify Shift Timings In Shift Details On Mobile ESS    ${shift_day}    ${shift}[uiStartTime]    ${shift}[uiEndTime]
        Click On Collapse Shift Details For The Selected Day On Mobile ESS
    END

Verify Shift Not Present For The Selected Day On Mobile ESS
    [Documentation]    Verifies shift is not present for the day.
    ...    Args:
    ...    ${target_day}: <start date for shift in x_y format where x is week offset and y is day number>
    [Arguments]    ${target_day}
    Select Date In Calender On Month Tab On Mobile ESS    ${target_day}
    Log    Verifying no shift is present for the selected day: ${target_day}
    ${no_schedule_semantic}    Get Localised Message From Key    ${schedule_label_not_scheduled}
    ${no_schedule_locator}    Get Locator Exact    ${no_schedule_semantic}
    Wait Until Element Is Visible    ${no_schedule_locator}

Click On Expand Shift Details For The Selected Day On Mobile ESS
    [Documentation]    Expand shift details for the selected day on mobile ESS.
    ${collapse_button_message}    Get Localised Message From Key    ${common_label_collapse}
    ${collapse_button_locator}    Get Locator Exact    ${collapse_button_message}
    Wait Until Element Is Visible    ${collapse_button_locator}
    Click Element    ${collapse_button_locator}

Click On Collapse Shift Details For The Selected Day On Mobile ESS
    [Documentation]    Collapse shift details for the selected day on mobile ESS.
    ${expand_button_message}    Get Localised Message From Key    ${common_label_expand}
    ${expand_button_locator}    Get Locator Exact    ${expand_button_message}
    Click Element    ${expand_button_locator}
