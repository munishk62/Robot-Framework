*** Settings ***
Documentation       Resource file for Schedule Landing Page

Variables           resources/Mobile/ESS/Locators/Schedule.py
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource


*** Keywords ***
Navigate To ESS Schedule Page On Mobile ESS
    [Documentation]    Navigates mobile ESS to the Schedule module.
    ${schedule_localised_message}    Get Localised Message From Key    ${ScheduleButtonLabel}
    # Hardcoding 2 for now need to check if it changes
    ${schedule_tab_locator}    Get Localised Locator Exact    ${BottomTabLabel}    ${schedule_localised_message}    2    5

    Wait Until Element Is Visible    ${schedule_tab_locator}
    Click Element    ${schedule_tab_locator}
    ${schedule_title_locator}    Get Localised Locator Exact    ${ScheduleButtonLabel}
    Wait Until Element Is Visible    ${schedule_title_locator}

Select Schedule Week Tab On Mobile ESS
    [Documentation]    Used for selecting the week tab in the schedule module
    ${week_tab_locator}    Get Localised Locator Contains    ${schedule_tabs_title_week}
    Wait Until Element Is Visible    ${week_tab_locator}
    Click Element    ${week_tab_locator}

Select Schedule Day Tab On Mobile ESS
    [Documentation]    Used for selecting the Schedule Day tab in the schedule module
    ${day_tab_locator}    Get Localised Locator Contains    ${schedule_tabs_title_day}
    Wait Until Element Is Visible    ${day_tab_locator}
    Click Element    ${day_tab_locator}

Select Schedule Month Tab On Mobile ESS
    [Documentation]    Used for selecting the Schedule Month tab in the schedule module
    ${month_tab_locator}    Get Localised Locator Contains    ${schedule_tabs_title_month}
    Wait Until Element Is Visible    ${month_tab_locator}
    Click Element    ${month_tab_locator}

Verify Schedule Not Published On Mobile ESS
    [Documentation]    Verifies the schedule is not published.
    ${no_schedule_published_msg_locator}    Get Localised Locator Exact    ${schedule_publish_status_not_published}
    Wait Until Element Is Visible    ${no_schedule_published_msg_locator}

Verify Schedule Not Published In Monthly Tab On Mobile ESS
    [Documentation]    Verifies the schedule is not published in Monthly tab.
    ${no_schedule_locator}    Get Localised Locator Exact    ${schedule_label_not_published}
    Wait Until Element Is Visible    ${no_schedule_locator}

Verify Shift Timings In Shift Details On Mobile ESS
    [Documentation]    Verifies shift timings in shift details.
    ...    Args:
    ...    ${shift_start_date}: <start date for shift in x_y format where x is week offset and y is day number>
    ...    ${shift_start_time}: <start time for shift in 12 hr format with am/pm>
    ...    ${shift_end_time}: <end time for shift in 12 hr format with am/pm>
    [Arguments]    ${shift_start_date}    ${shift_start_time}    ${shift_end_time}
    ${date_format}    Get Config Value    MONTH_DAY_FORMAT
    ${shift_date_formatted}    Calculate Date From Week Day Offset    ${shift_start_date}    ${date_format}
    VAR    ${formatted_start_time}    ${{ '${shift_start_time}'.lower() }}
    VAR    ${formatted_end_time}    ${{ '${shift_end_time}'.lower() }}
    ${shift_date_time}    Get Locator Contains    ${shift_date_formatted} ${formatted_start_time} - ${formatted_end_time}
    Swipe Until Visible    ${shift_date_time}
    Wait Until Element Is Visible    ${shift_date_time}
