*** Settings ***
Documentation       Web Clock Valid Badge Test - Validates punching with valid badge IDs.
...                 Prerequisites:
...                 - Execute data seeder for needed prerequisites

Resource            resources/web/clock/webclock_login.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags    dev:amol    battc00088    action:write    config:rta    bat_phase1    module:timekeeping


*** Test Cases ***
BATTC00088: Verify webclock meal in/meal out transaction and display of date & time as per unit time zone
    [Documentation]    Validates break start and break end punches with timezone verification and exception management verification.
    ...
    ...    This test validates that a user can perform break start and break end punches in the RTA web clock.
    ...    Before executing the test, it validates database requirements:
    ...    1. Break transaction types (5,6) are configured in TA_STD_TXN_TYPE and TA_UNIT_TXN_TYPE
    ...    2. Employee's contract policy supports breaks with valid network segment types (SSM/SUM/UUM)
    ...
    ...    The test will be skipped if the break functionality is not applicable for the user.

    ${is_break_applicable}    Check Break Applicability For User In DB    user_key=ESS5_STORE1
    Skip If    not ${is_break_applicable}    Break functionality not applicable - DB validation failed for user ESS5_STORE1

    VAR    ${clock_in}    clock_in
    VAR    ${clock_out}    clock_out
    VAR    ${break_start}    break_start
    VAR    ${break_end}    break_end
    ${store_data}    Get Store Data
    ${ess_user}    Get User    user_key=ESS5_STORE1
    VAR    ${employee_badge_id}    ${ess_user}[badgeId]
    ${punch_interval_wait_time}    Get Config Value    key=WEB_CLOCK_PUNCH_INTERVAL_MINUTES
    ${batch_wait_time}    Get Config Value    key=WEB_CLOCK_BATCH_PROCESSING_WAIT_MINUTES
    Skip If Actual Web Clock Punch Already Exists On Web    SM1_STORE1    ${ess_user}[username]
    Initialize Browser For Web Clock
    Navigate And Verify Web Clock Time Matches Store Timezone On Web    ${store_data}[store_id]
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${clock_in}    ${employee_badge_id}
    ...    ${store_data}[store_id]
    Sleep    ${punch_interval_wait_time}m
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${break_start}    ${employee_badge_id}
    ...    ${store_data}[store_id]
    Sleep    ${punch_interval_wait_time}m
    Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${break_end}    ${employee_badge_id}
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
