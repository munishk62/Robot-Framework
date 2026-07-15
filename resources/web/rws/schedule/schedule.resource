*** Settings ***
Documentation       Resource file containing keywords for schedule page functionality.
...                 Provides functions for workload generation and schedule creation from the schedule page.

Library             String
Library             pabot.PabotLib
Resource            resources/api/api_executor.resource
Variables           resources/web/rws/schedule/schedule_api.py


*** Keywords ***
Get Latest GenShiftId For Week Via API
    [Documentation]    Retrieves the latest generated shift ID for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_skey | unit skey for the store whose genshift is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_skey}    ${week_start_date}
    ${base_url}=    Get Config Value    key=base_url
    ${get_genshift_url}=    Format String    ${GET_GENSHIFT_ID_API}    BASE_URL=${base_url}    UNIT_SKEY=${unit_skey}
    ...    WEEK_START_DATE=${week_start_date}
    ${response}=    Send A WFM GET Request    ${user_key}    ${base_url}    ${get_genshift_url}
    Log    Response Body: ${response}
    RETURN    ${response}

Schedule Should Be Generated For Week
    [Documentation]    Checks if the schedule is generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_skey | unit skey for the store whose schedule status is to be checked |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_skey}    ${week_start_date}
    ${fetched_gen_shift_id}=    Get Latest GenShiftId For Week Via API    ${unit_skey}    ${week_start_date}    ${user_key}
    Log    ${fetched_gen_shift_id}
    Should Not Be Equal As Integers    ${fetched_gen_shift_id}    0
    ...    msg=Schedule is NOT generated for week starting on ${week_start_date} for unit ${unit_skey}

Get Shift Details For Associates Via API
    [Documentation]    Retrieves the latest generated shift ID for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | gen_shift_id | generated shift id for the store & week |
    [Arguments]    ${user_key}    ${gen_shift_id}    ${list_of_person_ids}
    ${base_url}=    Get Config Value    key=base_url
    ${get_associate_shift_map_url}=    Format String    ${GET_ASSOCIATE_SHIFT_MAP_API}    BASE_URL=${base_url}
    ...    GEN_SHIFT_ID=${gen_shift_id}
    ${response}=    Send A WFM POST Request    ${user_key}    ${base_url}    ${get_associate_shift_map_url}    ${list_of_person_ids}
    Log    Response Body: ${response}
    RETURN    ${response}

Add Shift Via API
    [Documentation]    Unallocates a single shift via API (POST with JSON body)
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store where shift is to be added |
    ...    | gen_shift_id | generated shift id for the store & week |
    ...    | shift_object | JSON object representing the shift to be added. This will be the request body for add shift api |
    [Arguments]    ${user_key}    ${unit_id}    ${gen_shift_id}    ${shift_object}
    ${base_url}=    Get Config Value    key=base_url
    ${add_shift_url}=    Format String    ${ADD_SHIFT_WEB_API}    BASE_URL=${base_url}    UNIT_ID=${unit_id}
    ...    GEN_SHIFT_ID=${gen_shift_id}
    VAR    ${lock_key}=    unallocate_${user_key}
    # acquiring lock as there is a deadlock issue in TaEmpTimeWeekDB.deleteTaEmpTimeWeek
    # when multiple unallocate requests are sent simultaneously with same user
    Acquire Lock    ${lock_key}
    ${response}=    Send A WFM POST Request    ${user_key}    ${base_url}    ${add_shift_url}    ${shift_object}
    Release Lock    ${lock_key}
    Log    Response Body: ${response}
    RETURN    ${response}
