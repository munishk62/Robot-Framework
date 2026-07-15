*** Settings ***
Documentation       This test case verifies the punch import functionality with meal breaks.
...                 Test validates that TA punches (Clock In, Meal In, Meal Out, Clock Out) can be imported
...                 via the Punch Import page and correctly displayed on the associate's timecard.

Library             test_data/TestDataLibrary.py
Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rta/test_tools/punch_import.resource

Test Tags           action:write    bat_phase1    config:rta    dev:amol    battc00048    module:timekeeping


*** Test Cases ***
BATTC00048: Verify punch imports
    [Documentation]    Verifies punch import functionality with meal breaks (BAT Phase 1).
    ...    SYSADMIN imports 4 punches (Clock In, Meal In, Meal Out, Clock Out) for ESS6_STORE1.
    ...    SM1_STORE1 verifies shift on timecard.
    ...    Target: Today's date

    ${ess_user}    Get User    user_key=ESS6_STORE1
    VAR    ${badge_id}    ${ess_user}[badgeId]

    # Get required configuration values
    ${owner_id}    Get Config Value    OWNER_ID
    ${store_data}    Get Store Data
    ${device_id}    Get System Value    PunchImportDevice    DVCSTORE1

    # Use today's date for punch import
    ${server_date_format}    Get Config Value    SERVER_DF
    ${display_date_format}    Get Config Value    DATE_FORMAT_ABBR_WEEKDAY_MDY

    ${punch_date}    Get Current Date    result_format=${server_date_format}
    ${punch_display_date}    Get Current Date    result_format=${display_date_format}

    # Check if punches already exist for target date
    ${punches_exist}    Check If Punches Already Exist For Today From DB
    ...    ${owner_id}
    ...    ${badge_id}
    ...    ${device_id}
    ...    ${store_data}[store_id]
    ...    ${punch_date}

    IF    ${punches_exist}
        Skip    Punches already exist for ${badge_id} on ${punch_display_date}. Test skipped to avoid duplicate data.
    END

    # Login as CORP User and prepare punch import
    Login And Launch WFM Web App    user_key=SYSADMIN

    ${punch_import_data}    Get Punch Import Data

    # Navigate to Punch Import and upload file with 4 punches
    VAR    ${import_file_path}    ${EXECDIR}/${punch_import_data}[file_path]
    Navigate To RTA Test Tools Punch Import Page On Web

    Add Full Day Punch Data With Meal In Punch Import File
    ...    ${import_file_path}
    ...    ${badge_id}
    ...    ${device_id}
    ...    ${store_data}[store_id]
    ...    ${punch_import_data}
    ...    ${punch_date}

    Upload And Import Punch File On Web    ${device_id}    ${import_file_path}

    # Wait for batch processing to complete
    ${batch_wait_minutes}    Get Config Value    WEB_CLOCK_BATCH_PROCESSING_WAIT_MINUTES
    ${batch_wait_seconds}    Evaluate    ${batch_wait_minutes} * 60
    Log    Waiting ${batch_wait_minutes} minutes for batch processing...
    Sleep    ${batch_wait_seconds}

    # Switch to Store Manager to verify shift
    Login And Launch WFM Web App    user_key=SM1_STORE1

    Navigate To RTA Operations Exception Management Page On Web
    Open Employee Timecard On Exception Management Page On Web    ${ess_user}[username]

    ${on_timecard_page}    Check If On Exception Management Timecard Page On Web
    IF    not ${on_timecard_page}
        Login And Launch WFM Web App    user_key=SM1_STORE1
        Navigate To RTA Operations Exception Management Page On Web
        Open Employee Timecard On Exception Management Page On Web    ${ess_user}[username]
    END

    # Verify imported shift on today's timecard
    Verify Imported Shift On Timecard Page On Web    ${punch_display_date}    ${batch_wait_minutes}
