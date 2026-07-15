*** Settings ***
Documentation       This test verifies the payfile is generated for the store

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rta/payroll/period_payroll_release.resource

Test Teardown       Run Keywords    Close Browser

Test Tags           action:write    battc00146    dev:yogesh    config:rta    config:distribution_list_enabled
...                 payroll_execution    module:timekeeping


*** Test Cases ***
BATTC00146: Verify payfile is generated for the store (new payroll - distribution list)
    [Documentation]    This test verifies the payfile is generated for the store
    Login And Launch WFM Web App    user_key=SM1_STORE2
    ${ess_user_6}    Get User    user_key=ESS6_STORE2
    Navigate To RTA Operations Exception Management Page On Web
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_6}[displayName]
    ${shift_data}    Get Timecard Shift Data    shift_day=-2_0
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${shift_data}[shift_day]
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    VAR    ${shift_day}    ${shift_data}[shift_day]
    ${day}    Calculate Date From Week Day Offset    weekday_offset=${shift_day}    date_format=${timecard_date_format}
    ${day_numeric}    Extract Day Numeric From Week String On Web    ${day}
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${shift_day}
    Add Shift On Timecard Page On Web    ${day_numeric}    ${day}    ${shift_data}
    Log Out From Web Application
    Close Browser
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RTA Payroll Period Payroll Release Page On Web
    ${payroll_data}    Get Payroll Data    template_name=payroll_release
    # Convert week_day offset format (e.g., "2_0") to actual date format (e.g., "MM/DD/YYYY")
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${week_start_date}    Calculate Date From Week Day Offset    weekday_offset=${payroll_data}[payroll_week_start_date]
    ...    date_format=${date_format}
    ${week_end_date}    Calculate Date From Week Day Offset    weekday_offset=${payroll_data}[payroll_week_end_date]
    ...    date_format=${date_format}
    Apply Filter For Week On Period Payroll Release Page On Web    ${week_start_date}    ${week_end_date}
    Release Pay File On Period Payroll Release Page With Distribution List Configured On Web    ${payroll_data}[pay_file_name]
    Check For Pay File Creation Status In Period Payroll Release Page On Web    ${payroll_data}[pay_file_name]    File Created
    Reopen Pay File On Period Pay Release Page On Web

    [Teardown]    Run Keywords
    ...    Login And Launch WFM Web App    user_key=SM1_STORE2    AND
    ...    Navigate To RTA Operations Exception Management Page On Web    AND
    ...    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_6}[displayName]    AND
    ...    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${shift_data}[shift_day]    AND
    ...    Remove Shift On Timecard Page On Web    ${day}
