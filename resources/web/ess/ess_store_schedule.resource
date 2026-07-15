*** Settings ***
Documentation       This resource file contains keywords related to ESS -> Store Schedule Page.

Library             test_data/TestDataLibrary.py
Variables           resources/web/ess/ess_store_schedule_page.py
Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To ESS Store Schedule Page On Web
    [Documentation]    Navigate To ESS -> Store Schedule Page
    ...    and verifies my schedule heading at the top of the page
    Navigate To Specific Page On Web    ess    store_schedule

Navigate To Next Week On Store Schedule Page On Web
    [Documentation]    Navigates to the next week on Store Schedule page for the given no of weeks
    ...    | =Arguments= | =Description= |
    ...    | weeks_to_navigate | Number of weeks to navigate forward. default is 1 week. |
    [Arguments]    ${weeks_to_navigate}=1
    FOR    ${_}    IN RANGE    ${weeks_to_navigate}
        ${week_label_before}    Get Element Text On Webpage    ${STORE_SCHEDULE_PAGE_WEEK_LABEL}
        Click Element On Webpage    ${STORE_SCHEDULE_PAGE_NEXT_WEEK_ICON}
        ${spinner_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${STORE_SCHEDULE_PAGE_SPINNER}
        ...    timeout=${SHORT_TIMEOUT}
        IF    ${spinner_visible}
            Wait Until Element Disappears On Webpage    ${STORE_SCHEDULE_PAGE_SPINNER}
        END
        Wait Until Page Is Loaded
        ${week_label_after}    Get Element Text On Webpage    ${STORE_SCHEDULE_PAGE_WEEK_LABEL}
        WHILE    '${week_label_before}' == '${week_label_after}'    limit=${LOOP_TIMEOUT}
            Log    Week label has not changed after clicking next week. Waiting and rechecking...
            # Sleep    ${SHORT_TIMEOUT}
            Wait Until Element Is Present On Webpage    ${STORE_SCHEDULE_PAGE_WEEK_LABEL}    ${SHORT_TIMEOUT}
            ${week_label_after}    Get Element Text On Webpage    ${STORE_SCHEDULE_PAGE_WEEK_LABEL}
        END
    END

Verify Shift Is Present For Associate On Given Days On Store Schedule Page On Web
    [Documentation]    This keyword checks if shifts exist for the specified associate on the given days.
    ...    | =Arguments= | =Description= |
    ...    | associate_name | Name of the associate to check shifts for. |
    ...    | days_list | List of day numbers to verify shifts on. |
    [Arguments]    ${associate_name}    ${days_list}
    VAR    @{missing_days}    @{EMPTY}
    FOR    ${day_number}    IN    @{days_list}
        ${update_num_for_locator}    Evaluate    int(${day_number}) + 2
        ${day_num_string}    Convert To String    ${update_num_for_locator}
        ${day_shift_locator}    Update Locator With Dynamic Values
        ...    ${STORE_SCHEDULE_PAGE_ASSOCIATE_DAY_SHIFT_CONTAINER}
        ...    ASSOCIATE_NAME=${associate_name}    DAY=${day_num_string}
        ${shift_present}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${day_shift_locator}
        ...    timeout=${MEDIUM_TIMEOUT}
        IF    not ${shift_present}
            Append To List    ${missing_days}    ${day_number}
        END
    END
    Capture Screenshot On Webpage
    ${missing_count}    Get Length    ${missing_days}
    IF    ${missing_count} > 0
        Fail    Shifts are not present for associate '${associate_name}' on the following days: ${missing_days}
    END

Verify Schedule Not Available And Shifts Not Present On Store Schedule Page On Web
    [Documentation]    Verifies that the schedule is not available and shifts are not present on the Store Schedule page.
    ${is_shift_found}    Is Element Visible On Webpage    ${STORE_SCHEDULE_PAGE_SHIFT_PRESENCE}
    Capture Screenshot On Webpage
    Should Not Be True    ${is_shift_found}    Schedule shifts are unexpectedly present on the Store Schedule page.
    ${not_published_msg}    Is Element Visible On Webpage    ${STORE_SCHEDULE_PAGE_NOT_PUBLISHED_MSG}
    Should Be True    ${not_published_msg}    'Schedule not published...' message is not displayed as expected.

Click On Week Label On Store Schedule Page On Web
    [Documentation]    Clicks on the week label on the Store Schedule page to open the week selection dropdown.
    Click Element On Webpage    ${STORE_SCHEDULE_PAGE_WEEK_LABEL}    error_message=Failed to click on week label on Store Schedule page.
    Wait Until Element Is Visible On Webpage    ${STORE_SCHEDULE_PAGE_WEEK_DROPDOWN}
    ...    error_message=Week selection dropdown did not appear after clicking week label on Store Schedule page.
    Capture Screenshot On Webpage

Click On Print Icon On Store Schedule Page On Web
    [Documentation]    Clicks on the print icon on the Store Schedule page.
    Click Element On Webpage    ${STORE_SCHEDULE_PAGE_PRINT_ICON}    error_message=Failed to click on print icon on Store Schedule page.
    Wait Until Element Is Visible On Webpage    ${STORE_SCHEDULE_PAGE_PRINT_POPUP}
    ...    error_message=Print popup did not appear after clicking print icon on Store Schedule page.
    Capture Screenshot On Webpage

Click On Filter Icon On Store Schedule Page On Web
    [Documentation]    Clicks on the filter icon on the Store Schedule page to open the filter panel.
    Click Element On Webpage    ${STORE_SCHEDULE_PAGE_FILTER_ICON}    error_message=Failed to click on filter icon on Store Schedule page.
    Wait Until Element Is Visible On Webpage    ${STORE_SCHEDULE_PAGE_FILTER_PANEL}
    ...    error_message=Filter panel did not appear after clicking filter icon on Store Schedule page.
    Capture Screenshot On Webpage

Click On Display Preferences Icon On Store Schedule Page On Web
    [Documentation]    Clicks on the display preferences icon on the Store Schedule page to open the display preferences panel.
    Click Element On Webpage    ${STORE_SCHEDULE_PAGE_DISPLAY_PREF_ICON}
    ...    error_message=Failed to click on display preferences icon on Store Schedule page.
    Wait Until Element Is Visible On Webpage    ${STORE_SCHEDULE_PAGE_DISPLAY_PREF_PANEL}
    ...    error_message=Display preferences panel did not appear after clicking display preferences icon on Store Schedule page.
    Capture Screenshot On Webpage

Click On Legend Icon On Store Schedule Page On Web
    [Documentation]    Clicks on the legend icon on the Store Schedule page to open the legend panel.
    Click Element On Webpage    ${STORE_SCHEDULE_PAGE_LEGEND_ICON}    error_message=Failed to click on legend icon on Store Schedule page.
    Wait Until Element Is Visible On Webpage    ${STORE_SCHEDULE_PAGE_LEGEND_PANEL}
    ...    error_message=Legend panel did not appear after clicking legend icon on Store Schedule page.
    Capture Screenshot On Webpage
