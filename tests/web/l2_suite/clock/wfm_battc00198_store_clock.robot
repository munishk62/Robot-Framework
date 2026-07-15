*** Settings ***
Documentation       Verify the user is able to do all categories
...                 (Clock In, Meal In, Meal End, Break In, Break Out, Clock Out) of punch transaction for a single day (WFM-110491)

Resource            resources/web/clock/webclock_login.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           dev:amol    battc00198    config:rta    bat_phase2    module:timekeeping


*** Test Cases ***
BATTC00198: Verify the user is able to do all categories (Clock In, Meal In, Meal End, Break In, Break Out, Clock Out) of punch transaction for a single day
    [Documentation]    Verify the user is able to do all categories (Clock In, Meal In, Meal End, Break In, Break Out, Clock Out) of punch transaction for a single day
    ...
    ...    This test validates that a user can perform all punch types (clock, meal, break) in a single day.
    ...    Before executing the test, it validates database requirements:
    ...    1. Clock transaction types (1,2) are configured in TA_STD_TXN_TYPE and TA_UNIT_TXN_TYPE
    ...    2. Meal transaction types (3,4) are configured and employee's contract supports meals (SSM/SUM/UUM)
    ...    3. Break transaction types (5,6) are configured and employee's contract supports breaks (SSB/SUB/UUB)
    ...
    ...    The test will be skipped if any of the required functionalities are not applicable.

    # Validate all applicability checks before proceeding with test
    ${is_clock_applicable}    Check Clock Applicability In DB
    Skip If    not ${is_clock_applicable}    Clock functionality not applicable - DB validation failed

    ${is_meal_applicable}    Check Meal Applicability For User In DB    user_key=ESS3_STORE2
    Skip If    not ${is_meal_applicable}    Meal functionality not applicable - DB validation failed for user ESS3_STORE2

    ${is_break_applicable}    Check Break Applicability For User In DB    user_key=ESS3_STORE2
    Skip If    not ${is_break_applicable}    Break functionality not applicable - DB validation failed for user ESS3_STORE2

    VAR    ${clock_in}    clock_in
    VAR    ${clock_out}    clock_out
    VAR    ${meal_start}    meal_start
    VAR    ${meal_end}    meal_end
    VAR    ${break_start}    break_start
    VAR    ${break_end}    break_end
    ${store_data}    Get Store Data    template_name=model_store2
    ${ess_user}    Get User    user_key=ESS3_STORE2
    VAR    ${employee_badge_id}    ${ess_user}[badgeId]
    ${punch_interval_wait_time}    Get Config Value    key=WEB_CLOCK_PUNCH_INTERVAL_MINUTES
    ${batch_wait_time}    Get Config Value    key=WEB_CLOCK_BATCH_PROCESSING_WAIT_MINUTES
    Skip If Actual Web Clock Punch Already Exists On Web    SM1_STORE2    ${ess_user}[username]
    Initialize Browser For Web Clock
    Navigate And Verify Web Clock Time Matches Store Timezone On Web    ${store_data}[store_id]
    FOR    ${action}    IN    ${clock_in}    ${meal_start}    ${meal_end}    ${break_start}    ${break_end}    ${clock_out}
        Perform Clock Action With Valid Badge Id On Web Clock Transaction Page On Web    ${action}    ${employee_badge_id}
        ...    ${store_data}[store_id]
        IF    '${action}' != '${clock_out}'
            Sleep    ${punch_interval_wait_time}m
        END
    END
    Sleep    ${batch_wait_time}m
    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RTA Operations Exception Management Page On Web
    Verify Web Clock Actions On Time Card Page On Web    ${ess_user}[username]    ${store_data}[store_id]

    ${on_timecard_page}    Check If On Exception Management Timecard Page On Web
    IF    not ${on_timecard_page}
        Sleep    ${batch_wait_time}m
        Login And Launch WFM Web App    user_key=SM1_STORE2
        Navigate To RTA Operations Exception Management Page On Web
        Open Employee Timecard On Exception Management Page On Web    ${ess_user}[username]
    END
    Run Keyword And Ignore Error    Delete Performed Web Clock Actions From Time Card Page On Web
