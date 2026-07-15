*** Settings ***
Documentation       BATTC00169 - Verify add/edit/delete of temporary badge IDs

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/temporary_badges.resource

Test Teardown       Close Browser

Test Tags    action:write    dev:amol    battc00169    config:rta    config:temporary_badge_permission    bat_phase2    module:timekeeping


*** Test Cases ***
BATTC00169: Verify add/edit/delete of temporary badge ids
    [Documentation]
    ...    Verifies the complete lifecycle of temporary badge management:
    ...    1. Login as Store Manager
    ...    2. Generate unique temporary badge ID (format: 00299yymmddhhmm)
    ...    3. Add a new temporary badge with today as effective date and today+10 as end date
    ...    4. Edit the badge to update end date to today+20
    ...    5. Update the badge status to Inactive
    ...    6. Delete the temporary badge
    ...
    ...    Badge ID Format: 00299yymmddhhmm
    ...    - 002: Store number (fixed)
    ...    - 99: Temporary badge indicator (fixed)
    ...    - yymmddhhmm: Timestamp (dynamic - year, month, day, hour, minute)
    ...
    ...    Test users:
    ...    - SM1_STORE2: Store Manager who manages temporary badges
    ...    - ESS1_STORE2: ESS user for whom the badge is created

    ${ess_user}    Get User    user_key=ESS1_STORE2
    VAR    ${associate_id}    ${ess_user}[username]
    ${timestamp_format}    Get Config Value    DATE_FORMAT_YYMMDDHHMM
    ${timestamp}    Get Current Date    result_format=${timestamp_format}
    VAR    ${TEMP_BADGE_ID}    00299${timestamp}

    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${today}    Get Current Date
    ${effective_date}    Add Time To Date    ${today}    0 days    result_format=${date_format}
    ${end_date}    Add Time To Date    ${today}    10 days    result_format=${date_format}
    ${edit_end_date}    Add Time To Date    ${today}    20 days    result_format=${date_format}

    VAR    &{badge_data}
    ...    effective_date=${effective_date}
    ...    end_date=${end_date}
    ...    badge_id=${TEMP_BADGE_ID}
    ...    associate_id=${associate_id}

    Login And Launch WFM Web App    user_key=SM1_STORE2
    Navigate To RTA Operations Temporary Badges Page On Web
    Add Temporary Badge On Temporary Badges Page On Web    ${badge_data}
    Edit Temporary Badge End Date On Temporary Badges Page On Web    ${TEMP_BADGE_ID}    ${edit_end_date}
    Update Temporary Badge Status To Inactive On Temporary Badges Page On Web    ${TEMP_BADGE_ID}
    Delete Temporary Badge On Temporary Badges Page On Web    ${TEMP_BADGE_ID}
