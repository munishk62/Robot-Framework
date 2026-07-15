*** Settings ***
Documentation       This resource file contains keywords related to ESS -> My Schedule Page.

Library             test_data/TestDataLibrary.py
Variables           resources/web/ess/ess_my_schedule_page.py
Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To ESS My Schedule Page On Web
    [Documentation]    Navigate To ESS -> My Schedule -> My Schedule Page
    ...    and verifies my schedule heading at the top of the page
    Navigate To Specific Page On Web    ess    my_schedule

Navigate Until Schedule Not Published Week Is Seen On Web
    [Documentation]    Navigates to next week in the My Schedule page.
    ...    | =Arguments= | =Description= |
    ...    | week_navigation_count | Count of week navigation. |
    [Arguments]    ${week_navigation_count}
    FOR    ${i}    IN RANGE    1    ${week_navigation_count}
        Click Element On Webpage    ${MY_SCHEDULE_PAGE_NEXT_WEEK_ICON}
        Wait Until Page Is Loaded
        ${schedule_not_published}    Is Element Visible On Webpage
        ...    ${MY_SCHEDULE_PAGE_SCHEDULE_NOT_PUBLISHED_MESSAGE}
        IF    ${schedule_not_published}    BREAK
    END
    ${week_label}    Get Element Text On Webpage    ${MY_SCHEDULE_PAGE_WEEK_LABEL}
    IF    ${schedule_not_published}
        Log    Unpublished schedule is seen for week ${week_label} after ${i} forward navigations
    ELSE
        Skip    Unpublished schedule is not seen for any week till ${week_navigation_count} forward navigations
    END

Navigate Until Published Scheduled Week Is Seen On Web
    [Documentation]    Navigates to next week in the My Schedule page until a published schedule is found.
    ...    | =Arguments= | =Description= |
    ...    | week_navigation_count | Count of week navigation. |
    [Arguments]    ${week_navigation_count}
    FOR    ${i}    IN RANGE    1    ${week_navigation_count}
        Click Element On Webpage    ${MY_SCHEDULE_PAGE_NEXT_WEEK_ICON}
        Wait Until Page Is Loaded
        ${schedule_not_published}    Is Element Visible On Webpage
        ...    ${MY_SCHEDULE_PAGE_SCHEDULE_NOT_PUBLISHED_MESSAGE}
        ${schedule_published}    Evaluate    not ${schedule_not_published}
        IF    ${schedule_published}    BREAK
    END
    ${week_label}    Get Element Text On Webpage    ${MY_SCHEDULE_PAGE_WEEK_LABEL}
    IF    ${schedule_published}
        Log    Published schedule is seen for week ${week_label} after ${i} forward navigations
    ELSE
        Skip    Published schedule is not seen for any week till ${week_navigation_count} forward navigations
    END

Verify If The Schedule Summary Header Fields Are Displayed On Web
    [Documentation]    Verify If The Schedule Summary Header Fields Are Displayed On Web
    VAR    ${all_headers_visible}    False
    VAR    @{missing_headers}    @{EMPTY}
    &{shift_detail_hdrs}    Get All System Values    MyScheduleSummaryHeaders
    FOR    ${hdr_key}    ${hdr_value}    IN    &{shift_detail_hdrs}
        ${hdr_element}    Update Locator With Dynamic Values    ${MY_SCHEDULE_PAGE_SUMMARY_HEADER_FIELD}    HEADER_NAME=${hdr_value}
        ${header_visible}    Is Element Visible On Webpage    ${hdr_element}
        IF    ${header_visible}
            VAR    ${all_headers_visible}    True
        ELSE
            VAR    ${all_headers_visible}    False
            Append To List    ${missing_headers}    ${hdr_key}
        END
    END
    IF    not ${all_headers_visible}
        Fail    Some Schedule Summary Header Fields ${missing_headers} are not displayed on My Schedule page.
    ELSE
        Log    All Schedule Summary Header Fields are displayed on My Schedule page.
    END

Verify If The Schedule Details Header Fields Are Displayed On Web
    [Documentation]    Verify If The Schedule Details Header Fields Are Displayed On Web
    VAR    ${all_headers_visible}    False
    VAR    @{missing_headers}    @{EMPTY}
    &{shift_detail_hdrs}    Get All System Values    MyScheduleDetailsHeaders
    FOR    ${hdr_key}    ${hdr_value}    IN    &{shift_detail_hdrs}
        ${hdr_element}    Update Locator With Dynamic Values    ${MY_SCHEDULE_PAGE_DETAILS_HEADER_FIELD}    HEADER_NAME=${hdr_value}
        ${header_visible}    Is Element Visible On Webpage    ${hdr_element}
        IF    ${header_visible}
            VAR    ${all_headers_visible}    True
        ELSE
            VAR    ${all_headers_visible}    False
            Append To List    ${missing_headers}    ${hdr_key}
        END
    END
    IF    not ${all_headers_visible}
        Fail    Some Schedule Details Header Fields ${missing_headers} are not displayed on My Schedule page.
    ELSE
        Log    All Schedule Details Header Fields are displayed on My Schedule page.
    END

Is Schedule Not Published Status Seen On My Schedule On Web
    [Documentation]    Check if the selected week schedule is published on My Schedule page
    ${schedule_not_published_msg}    Is Element Visible On Webpage
    ...    ${MY_SCHEDULE_SCHD_NOT_PUBLISHED_MSG}
    RETURN    not ${schedule_not_published_msg}

Get All Elements From Given Locator On Web
    [Documentation]    Get all elements from the given locator and return as list.
    ...    | =Arguments= | =Description= |
    ...    | locator | Locator of the elements |
    ...    | =Returns=    | =Description= |
    ...    | values_list    | List of text values from the elements. |
    [Arguments]    ${locator}
    ${elements}    Get Elements    ${locator}
    VAR    @{values_list}    @{EMPTY}
    FOR    ${element}    IN    @{elements}
        ${text}    Get Element Text On Webpage    ${element}
        IF    $text != ''
            @{text_list}    Split String    ${text}    \n
            VAR    ${text}    ${text_list}[0]
        END
        Append To List    ${values_list}    ${text}
    END
    ${length}    Get Length    ${elements}
    RETURN    ${values_list}[1:${length}]

Assert Shift Is Present For The Given Day On My Schedule Page On Web
    [Documentation]    Asserts that shifts are present for all provided days on My Schedule page.
    ...    This keyword robustly handles textual day names (e.g., Monday), numeric indices (e.g., 7),
    ...    and numeric values passed in a list-like string format (e.g., "['7']").
    ...
    ...    | =Arguments= | =Description= |
    ...    | day_names    | A list of day names or numeric indices to check for shifts. |
    ...
    ...    Example usage:
    ...    | Assert Shift Is Present For The Given Day On My Schedule Page On Web    Monday    7    ['7']
    [Arguments]    @{day_names}

    VAR    @{missing_days}    @{EMPTY}

    FOR    ${day_name}    IN    @{day_names}
        ${day_name_str}    Convert To String    ${day_name}

        # This single regex handles brackets, quotes, and other symbols, turning "['7']" directly into "7".
        ${day_token}    Replace String Using Regexp    ${day_name_str}    [^a-zA-Z0-9]    ${EMPTY}
        ${day_shift_locator}    Update Locator With Dynamic Values    ${MY_SCHEDULE_PAGE_DAY_SHIFT_CONTAINER}    DAY_SHIFT=${day_token}
        Capture Screenshot On Webpage
        ${shift_present}    Is Element Visible On Webpage    ${day_shift_locator}

        IF    not ${shift_present}
            Append To List    ${missing_days}    ${day_token}
        ELSE
            Log    Shift is present for the day '${day_token}' on My Schedule page.
        END
    END

    ${missing_count}    Get Length    ${missing_days}
    IF    ${missing_count} > 0
        Fail    Shifts are not present for the following days: ${missing_days}
    ELSE
        Log    Shifts were confirmed present for all provided days: ${day_names}
    END

Navigate To Next Week On My Schedule Page On Web
    [Documentation]    Navigates to the next week on My Schedule page for the given no of weeks
    ...    | =Arguments= | =Description= |
    ...    | weeks_to_navigate | Number of weeks to navigate forward. If not provided, navigates one week. |
    [Arguments]    ${weeks_to_navigate}=${None}
    IF    '${weeks_to_navigate}' != '${None}'
        FOR    ${_}    IN RANGE    ${weeks_to_navigate}
            Click Element On Webpage    ${MY_SCHEDULE_PAGE_NEXT_WEEK_ICON}
            Run Keyword And Ignore Error    Wait Until Element Is Detached On Webpage    ${MY_SCHEDULE_PAGE_NEXT_WEEK_ICON}
            ...    timeout=${SHORT_TIMEOUT}
            Wait Until Page Is Loaded
        END
    ELSE
        Click Element On Webpage    ${MY_SCHEDULE_PAGE_NEXT_WEEK_ICON}
        Run Keyword And Ignore Error    Wait Until Element Is Detached On Webpage    ${MY_SCHEDULE_PAGE_NEXT_WEEK_ICON}
        ...    timeout=${SHORT_TIMEOUT}
        Wait Until Page Is Loaded
    END

Assert Schedule Is Not Displayed On My Schedule Page On Web
    [Documentation]    Asserts that schedule is not displayed on My Schedule page
    ${schedule_not_published_msg}    Is Element Visible On Webpage
    ...    ${MY_SCHEDULE_PAGE_SCHEDULE_NOT_PUBLISHED_MESSAGE}
    Capture Screenshot On Webpage
    IF    not ${schedule_not_published_msg}
        Fail    Schedule is displayed on My Schedule page when it is expected to be not published.
    ELSE
        Log    Schedule is not displayed on My Schedule page as expected.
    END

Click On Week Label On My Schedule Page On Web
    [Documentation]    Clicks on the week label on My Schedule page to open the week details popup
    Click Element On Webpage    ${MY_SCHEDULE_PAGE_WEEK_LABEL}
    Wait Until Element Is Visible On Webpage    ${MY_SCHEDULE_PAGE_DATE_PICKER_POPUP}
    Capture Screenshot On Webpage

Click On Print Icon On My Schedule Page On Web
    [Documentation]    Clicks on the print icon on My Schedule page to open the print menu
    Click Element On Webpage    ${MY_SCHEDULE_PAGE_PRINT_ICON}
    Wait Until Element Is Visible On Webpage    ${MY_SCHEDULE_PAGE_PRINT_BUTTON_MENU}
    Capture Screenshot On Webpage

Click On PDF Icon On My Schedule Page On Web
    [Documentation]    Clicks on the PDF icon on My Schedule page to open the PDF menu
    Click Element On Webpage    ${MY_SCHEDULE_PAGE_PDF_ICON}
    Wait Until Element Is Visible On Webpage    ${MY_SCHEDULE_PAGE_PDF_BUTTON_MENU}
    Capture Screenshot On Webpage

Click On Line View Icon On My Schedule Page On Web
    [Documentation]    Clicks on the line view icon on My Schedule page to switch to line view
    Click Element On Webpage    ${MY_SCHEDULE_PAGE_LINE_VIEW_ICON}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Click On List View Icon On My Schedule Page On Web
    [Documentation]    Clicks on the list view icon on My Schedule page to switch to list view
    Click Element On Webpage    ${MY_SCHEDULE_PAGE_LIST_VIEW_ICON}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Click On Legend Icon On My Schedule Page On Web
    [Documentation]    Clicks on the legend icon on My Schedule page to open the legend
    Click Element On Webpage    ${MY_SCHEDULE_PAGE_LEGEND_ICON}
    Wait Until Element Is Visible On Webpage    ${MY_SCHEDULE_PAGE_LEGEND_POPUP}
    Capture Screenshot On Webpage

Navigate To Timecard Page From ESS My Schedule Page On Web
    [Documentation]    Navigates to Timecard page from My Schedule page by clicking on the timecard link in the left navigation menu
    Click Element On Webpage    ${MY_SCHEDULE_PAGE_TIMECARD_LNK}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Select Week On Week Label On My Schedule Page On Web
    [Documentation]
    ...    Selects the week on My Schedule page by clicking on the week label and selecting the date from date picker.
    ...    | =Arguments= | =Description= |
    ...    | week_day_input | The date to select in the date picker. week_day format accepted (e.g. 1_0 for current week + 1, first day) |
    [Arguments]    ${week_day_input}
    Select Date Through Date Picker For ESS Requests On Webpage    ${MY_SCHEDULE_PAGE_WEEK_LABEL}    ${week_day_input}
    Wait Until Page Is Loaded
    Wait Until Keyword Succeeds    10x    ${MEDIUM_TIMEOUT}
    ...    Verify Header Week Start Date On Week Label On Web    ${week_day_input}    ${MY_SCHEDULE_PAGE_WEEK_LABEL}
