*** Settings ***
Documentation       Verify Display Preference Detailed View On Week Schedule Page

Resource            resources/web/rws/schedule/week_schedule.resource

Test Teardown       Close Browser

Test Tags           dev:moiz    action:write


*** Test Cases ***
WFM-24-2 Verify Display Preference Detailed View On Week Schedule Page
    [Documentation]    Test case for verifying display preference detailed view functionality on Week Schedule page,
    ...    including sorting by display preferences and resetting sorting.
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${store_data}    Get Store Data
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    ${preferences_data}    Get Display Preferences Data    template_name=full_range_view
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    Navigate To RWS Schedule Week Schedule Page On Web
    # Pre-requisite: if no shift present on week schedule page, add shift before sorting by Display Preference
    ${element_count}    Get Element Count On Web Page    ${WEEK_SCHEDULE_SHIFT_COUNT}
    VAR    ${delete_shift_on_week_schedule_page}    False
    IF    $element_count == 0
        ${week_schedule_shift_row}    ${week_schedule_shift_col}    Get Vacant Day Cell On Week Schedule Page On Web
        ${shift_data}    Get Shift Data
        Add Shift On Week Schedule Page On Web    ${week_schedule_shift_row}    ${week_schedule_shift_col}    ${shift_data}[start_time]
        ...    ${shift_data}[end_time]
        Click Element On Webpage    ${WEEK_SCHEDULE_SHIFT_CLOSE_BTN}
        VAR    ${delete_shift_on_week_schedule_page}    True
    END
    Apply Display Preferences On Week Schedule Page On Web    ${preferences_data}
    # After sort, verify detailed view appears
    Verify Detailed View Is Visible On Week Schedule Page On Web
    # Reset sorting
    Perform Reset For Display Preferences On Week Schedule Page On Web
    Verify Detailed View Is Not Visible On Week Schedule Page On Web
    [Teardown]    Run Keyword And Continue On Failure    Run Keyword If    ${delete_shift_on_week_schedule_page}
    ...    Un-allocate Shift On Week Schedule Page On Web    ${week_schedule_shift_row}    ${week_schedule_shift_col}
