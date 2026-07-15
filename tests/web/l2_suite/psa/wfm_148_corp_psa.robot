*** Settings ***
Documentation       Test case to Verify Pay Simulator For Multiple Stores, Multiple Weeks, Dst Weeks, Holiday Weeks, Special Pay Weeks

Resource            resources/web/authentication/login.resource
Resource            resources/web/psa/process_simulator/process_simulator.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:read    battc00148    config:psa    config:rta    bat_phase2    module:timekeeping


*** Test Cases ***
BATTC00148: Run pay simulator for multiple stores, weeks (incl dst weeks, holiday weeks, special pay weeks)
    [Documentation]    Test case to Verify Pay Simulator For Multiple Stores, Multiple Weeks, Dst Weeks, Holiday Weeks, Special Pay Weeks
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${process_option}    Get System Value    ProcessSimulatorProcess    PAY
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${store_list}    Get Config Value    key=UNIT_LIST_PAY_PROCESS_SIMULATOR
    ${date_offsets_input}    Get Config Value    key=WEEK_LIST_PAY_PROCESS_SIMULATOR
    @{date_offsets}    Evaluate    ${date_offsets_input}
    ${calculated_dates}    Evaluate    []
    FOR    ${date}    IN    @{date_offsets}
        ${date_value}    Calculate Date From Week Day Offset    ${date}    ${date_format}
        Append To List    ${calculated_dates}    ${date_value}
    END
    ${date_list}    Convert To String    ${calculated_dates}
    Navigate To PSA Process Simulator Page On Web
    Verify Mismatch Record For Pay Process Simulator Flow For Multiple Stores And Dates On Web    ${store_list}    ${date_list}
    ...    ${process_option}
