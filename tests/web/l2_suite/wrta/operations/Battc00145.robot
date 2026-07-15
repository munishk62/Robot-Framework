*** Settings ***
Documentation       Verify that a payfile is generated for the store using legacy payroll processing.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rta/payroll/process_store_release.resource

Test Tags    config:rta    dev:komal    action:write    battc00145    bat_phase2    config:legacy_payroll_enabled
...    config:payfile_generation    module:timekeeping


*** Test Cases ***
BATTC00145: Verify payfile is generated for the store (legacy payroll)
    [Documentation]    Verify that a payfile is generated for the store using legacy payroll processing.
    ...    This test adds a timecard shift if needed, processes store release, and validates payfile generation.
    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RTA Operations Exception Management Page On Web
    ${ess_user_6}    Get User    user_key=ESS6_STORE2
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_6}[displayName]
    Verify Timecard Page Is Loaded On Web
    ${timecard_date_format}    Get Config Value    key=DATE_FORMAT_ABBR_WEEKDAY_MDY
    ${timecard_shift_data}    Get Timecard Shift Data    shift_day=-2_0
    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${timecard_shift_data}[shift_day]
    VAR    ${shift_day}    ${timecard_shift_data}[shift_day]
    ${day}    Calculate Date From Week Day Offset    weekday_offset=${shift_day}    date_format=${timecard_date_format}
    ${day_numeric}    Extract Day Numeric From Week String On Web    ${day}
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${timecard_shift_data}[shift_day]
    Add Shift On Timecard Page On Web    day=${day_numeric}    shift_request_week=${day}    shift_data=${timecard_shift_data}
    Navigate To RTA Payroll Process Store Release Page On Web
    Navigate To Planning Week From Calendar On Process Store Release Page On Web    ${timecard_shift_data}[shift_day]
    Release Store For Payfile Generation On Process Store Release Page On Web

    # step 8: Validate the payfile generation for the store (This step will be automated in future, currently it is a manual step)

    Navigate To RTA Payroll Process Store Release Page On Web
    Navigate To Planning Week From Calendar On Process Store Release Page On Web    ${timecard_shift_data}[shift_day]
    Reopen Store After Payfile Generation On Process Store Release Page On Web

    [Teardown]    Run Keywords
    ...    Navigate To RTA Operations Exception Management Page On Web
    ...    AND    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user_6}[displayName]
    ...    AND    Verify Timecard Page Is Loaded On Web
    ...    AND    Navigate To Planning Week From Calendar On Timecard List Page On Web    ${timecard_shift_data}[shift_day]
    ...    AND    Delete Shift On Timecard Page On Web    ${day}
