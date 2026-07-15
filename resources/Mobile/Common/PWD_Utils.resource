*** Settings ***
Documentation       This resource file contains keywords for PWD date utilities.

Library             DateTime
Library             re
Variables           resources/Mobile/ESS/Locators/common_data.py


*** Keywords ***
Get Week Start Date
    [Documentation]    Used for calculating the start of the week based on the week start day for the env.
    ...    | =Arguments= | =Description= |
    ...    | date | date in date_format %Y-m-%d which is required to calculate the week start date |
    ...    | result_format | date format in which the week start date should be returned |
    ...    | week_start_day | week start day for the environment, default is Sunday |
    [Arguments]    ${date}    ${result_date_format}    ${week_start_day}=Sunday
    ${week_start_numeric}    Convert Date    date=${week_start_day}    date_format=%A    result_format=%u
    ${today_weekday}    Evaluate    (datetime.date(*map(int, '${date}'.split('-'))).isoweekday() % 7) + 1
    ${offset}    Evaluate    (${today_weekday} - ${week_start_numeric}) % 7
    ${target_date}    DateTime.Subtract Time From Date    ${date}    ${offset} days
    ${formatted_date}    Convert Date    ${target_date}    result_format=${result_date_format}
    RETURN    ${formatted_date}

Is Past Date
    [Documentation]    Returns True if ${date} is before today, otherwise False.
    [Arguments]    ${date}
    ${year_month_day_format}    Get Config Value    DATE_FMT_YEAR_MONTH_DAY
    ${formatted_date}    Convert Date    ${date}    ${year_month_day_format}
    ${today}    Evaluate    datetime.date.today().strftime('%Y-%m-%d')
    ${result}    Evaluate    '${formatted_date}' < '${today}'
    RETURN    ${result}
