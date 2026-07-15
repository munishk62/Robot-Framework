*** Settings ***
Documentation       Web Clock Invalid Badge Test - Validates error handling for invalid badge IDs.
...
...                 Prerequisites:
...                 - Web clock device must exist in TA_DEVICE table (DEVICE_TYPE_ID = 11) with Active state

Resource            resources/web/clock/webclock_login.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           battc00090    action:read    dev:amol    config:rta    bat_phase1    module:timekeeping


*** Test Cases ***
BATTC00090: Verify clock in and clock out for invalid badge id
    [Documentation]    Validates web clock error handling for invalid badge ID during clock-in and clock-out.
    VAR    ${clock_in}    clock_in
    VAR    ${clock_out}    clock_out
    ${invalid_badge_id}    Get Config Value    key=INVALID_BADGE_ID
    ${store_data}    Get Store Data

    Initialize Browser For Web Clock
    Perform Clock Action With Invalid Badge On Web Clock Transaction Page On Web    ${clock_in}    ${invalid_badge_id}
    ...    ${store_data}[store_id]
    Verify Error Message On Web Clock Page On Web
    Perform Clock Action With Invalid Badge On Web Clock Transaction Page On Web    ${clock_out}    ${invalid_badge_id}
    ...    ${store_data}[store_id]
    Verify Error Message On Web Clock Page On Web
