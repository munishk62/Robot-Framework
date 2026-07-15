*** Settings ***
Documentation       Web Clock Valid Badge Test - Validates punching with valid badge IDs.
...                 Prerequisites:
...                 - Execute data seeder for needed prerequisites

Resource            resources/web/clock/webclock_login.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           dev:amol    battc00089    action:write    config:rta    bat_phase1    refactoring_required_PC00134    module:timekeeping


*** Test Cases ***
BATTC00089: Verify webclock break in/break out transaction and display of date & time as per unit time zone
    [Documentation]    Validates meal start and meal end punches with timezone verification and exception management verification.
    ...
    ...    This test validates that a user can perform meal start and meal end punches in the RTA web clock.
    ...    Before executing the test, it validates database requirements:
    ...    1. Meal transaction types (3,4) are configured in TA_STD_TXN_TYPE and TA_UNIT_TXN_TYPE
    ...    2. Employee's contract policy supports meals with valid network segment types (SSM/SUM/UUM)
    ...
    ...    The test will be skipped if the meal functionality is not applicable for the user.

    ${is_meal_applicable}    Check Meal Applicability For User In DB    user_key=ESS4_STORE1
    Skip If    not ${is_meal_applicable}    Meal functionality not applicable - DB validation failed for user ESS4_STORE1

    VAR    ${clock_in}    clock_in
    VAR    ${clock_out}    clock_out
    VAR    ${meal_start}    meal_start
    VAR    ${meal_end}    meal_end
    ${store_data}    Get Store Data
    ${ess_user}    Get User    user_key=ESS4_STORE1
    VAR    ${employee_badge_id}    ${ess_user}[badgeId]
    ${punch_interval_wait_time}    Get Config Value    key=WEB_CLOCK_PUNCH_INTERVAL_MINUTES
    ${batch_wait_time}    Get Config Value    key=WEB_CLOCK_BATCH_PROCESSING_WAIT_MINUTES
    Skip If Actual Web Clock Punch Already Exists On Web    SM1_STORE1    ${ess_user}[username]
    Initialize Browser For Web Clock
    Navigate And Verify Web Clock Time Matches Store Timezone On Web    ${store_data}[store_id]
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${clock_in}    ${employee_badge_id}
    ...    ${store_data}[store_id]
    Sleep    ${punch_interval_wait_time}m
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${meal_start}    ${employee_badge_id}
    ...    ${store_data}[store_id]
    Sleep    ${punch_interval_wait_time}m
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${meal_end}    ${employee_badge_id}
    ...    ${store_data}[store_id]
    Sleep    ${punch_interval_wait_time}m
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${clock_out}    ${employee_badge_id}
    ...    ${store_data}[store_id]
    Sleep    ${batch_wait_time}m
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Verify Web Clock Actions On Time Card Page On Web    ${ess_user}[username]    ${store_data}[store_id]

    ${on_timecard_page}    Check If On Exception Management Timecard Page On Web
    IF    not ${on_timecard_page}
        Sleep    ${batch_wait_time}m
        Login And Launch WFM Web App    user_key=SM1_STORE1
        Navigate To RTA Operations Exception Management Page On Web
        Open Employee Timecard On Exception Management Page On Web    ${ess_user}[username]
    END
    Run Keyword And Ignore Error    Delete Performed Web Clock Actions From Time Card Page On Web
