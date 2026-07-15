*** Settings ***
Documentation       Example test demonstrating time field processing in data providers

Library             String
Library             test_data/TestDataLibrary.py

Test Tags           example    time_fields


*** Test Cases ***
Example: Get Shift Pattern With Time Conversion
    [Documentation]    Demonstrates how time fields are automatically converted from minutes to time strings
    ${shift_8hr1}=    Get Shift Time Pattern Data    template_name=standard_8hr    startTime=${1020}
    ${shift_8hr2}=    Get Shift Time Pattern Data    template_name=standard_8hr    startTime=${1020}    _am_pm_format=ap
    ${shift_8hr3}=    Get Shift Time Pattern Data    template_name=standard_8hr    _am_pm_format=-ap
    Log    Start Time with default format: ${shift_8hr1}
    Log    Start Time with "ap" format: ${shift_8hr2}
    Log    Start Time with "-ap" format: ${shift_8hr3}
    # Get shift pattern data - startTime will be converted automatically
    ${shift_8hr}=    Get Shift Time Pattern Data    template_name=standard_8hr    _am_pm_format=a/p

    # uiStartTime is converted from 480 minutes to "08:00" or "08:00 AM" based on config
    Log    Start Time: ${shift_8hr}[uiStartTime]
    Log    Duration (minutes): ${shift_8hr}[duration]
    Log    Description: ${shift_8hr}[description]

    # Verify the conversion happened
    Should Not Be Equal    ${shift_8hr}[uiStartTime]    ${480}
    Should Contain Any    ${shift_8hr}[uiStartTime]    8:00    08:00

    # Duration should remain as integer
    Should Be Equal As Integers    ${shift_8hr}[startTime]    480

Example: Employee Shift Setup With Template References
    [Documentation]    Shows time conversion working with template references (nested structures)
    # Get employee shift setup - uses template references for shift patterns
    ${setup}=    Get Employee Shift Setup Data    template_name=add012_standard8

    Log    Employee: ${setup}[ess_user_key]
    Log    Number of shifts: ${setup}[shifts_to_add].__len__()

    # Each shift in the list will have startTime converted
    VAR    ${first_shift}=    ${setup}[shifts_to_add][0]

    Log    First Shift Day: ${first_shift}[dayNo]
    Log    First Shift Start Time: ${first_shift}[startTime]
    Log    First Shift Duration: ${first_shift}[duration]

    # Verify time conversion happened in nested structure
    Should Contain Any    ${first_shift}[uiStartTime]    08:00    08:00 AM
    Should Be Equal As Integers    ${first_shift}[duration]    480

Example: Different Shift Patterns
    [Documentation]    Compare different shift patterns with varying start times
    # Standard shifts
    ${shift_8hr}=    Get Shift Time Pattern Data    template_name=standard_8hr
    ${shift_9hr}=    Get Shift Time Pattern Data    template_name=standard_9hr

    # Early and late shifts
    ${early_shift}=    Get Shift Time Pattern Data    template_name=early_morning_8hr
    ${closing_shift}=    Get Shift Time Pattern Data    template_name=closing_shift

    # Log all the converted times
    Log    Standard 8hr starts at: ${shift_8hr}[uiStartTime]
    Log    Standard 9hr starts at: ${shift_9hr}[uiStartTime]
    Log    Early morning starts at: ${early_shift}[uiStartTime]
    Log    Closing shift starts at: ${closing_shift}[uiStartTime]

    # All should be time strings, not integers
    Should Be String    ${shift_8hr}[uiStartTime]
    Should Be String    ${early_shift}[uiStartTime]

Example: Override Time Fields
    [Documentation]    Shows how to override time fields with custom values
    # Get with custom override - providing minutes will be converted
    ${custom_shift}=    Get Shift Time Pattern Data
    ...    template_name=standard_8hr
    ...    uiStartTime=${600}
    ...    duration=${420}

    # startTime should be converted from 600 minutes to "10:00" or "10:00 AM"
    Log    Custom UiStart Time: ${custom_shift}[uiStartTime]
    Should Contain Any    ${custom_shift}[uiStartTime]    10:00    10:00 AM

    # Duration stays as provided (integer)
    Should Be Equal As Integers    ${custom_shift}[duration]    420
