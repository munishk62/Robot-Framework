*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Process Simulator page.

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/psa/process_simulator/process_simulator_page.py
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To PSA Process Simulator Page On Web
    [Documentation]    Navigate To PSA -> Process Simulator Page
    ...    and verifies process simulator heading at the top of the page
    Navigate To Specific Page On Web    psa    process_simulator    process_simulator
    Wait Until Page Is Loaded

Select Option From Process Dropdown On Process Simulator Web
    [Documentation]    Select Option From Process Dropdown On Process Simulator Page
    [Arguments]    ${process_option}
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_PROCESS_DROPDOWN}
    ...    error_message=Unable to click on Process dropdown on Process Simulator page
    ${option}    Update Locator With Dynamic Values    ${PROCESS_SIMULATOR_PAGE_PROCESS_OPTION}    OPTION=${process_option}
    Click Element On Webpage    ${option}
    ...    error_message=Unable to select ${process_option} from Process dropdown on Process Simulator page
    Wait Until Page Is Loaded

Select Option From Units Dropdown On Process Simulator Web
    [Documentation]    Select Option From Units Dropdown On Process Simulator Page
    [Arguments]    ${units_option}
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_UNITS_DROPDOWN}
    ...    error_message=Unable to click on Units dropdown on Process Simulator page
    Fill Textbox On Webpage    ${PROCESS_SIMULATOR_PAGE_UNITS_SEARCH_FIELD}    ${units_option}
    ${option}    Update Locator With Dynamic Values    ${PROCESS_SIMULATOR_PAGE_UNITS_OPTION}    UNIT=${units_option}
    Click Element On Webpage    ${option}    error_message=Unable to select ${units_option} from Units dropdown on Process Simulator page
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_UNITS_DROPDOWN}
    Wait Until Page Is Loaded

Select Week Start Date From Dropdown On Process Simulator Web
    [Documentation]    Select Week Start Date From Dropdown On Process Simulator Page
    [Arguments]    ${week_start_date}
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_WEEK_START_DATE_DROPDOWN}
    ...    error_message=Unable to click on Week Start Date dropdown on Process Simulator page
    Fill Textbox On Webpage    ${PROCESS_SIMULATOR_PAGE_WEEK_START_DATE_SEARCH_FIELD}    ${week_start_date}
    ${option}    Update Locator With Dynamic Values    ${PROCESS_SIMULATOR_PAGE_WEEK_START_DATE_OPTION}
    ...    WEEK_START_DATE=${week_start_date}
    Click Element On Webpage    ${option}
    ...    error_message=Unable to select ${week_start_date} from Week Start Date dropdown on Process Simulator page
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_WEEK_START_DATE_DROPDOWN}
    ...    error_message=Unable to click on Week Start Date dropdown to close it on Process Simulator page
    Wait Until Page Is Loaded

Click Simulate Button On Process Simulator Web
    [Documentation]    Click Simulate Button On Process Simulator Page
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_SIMULATE_BUTTON}
    ...    error_message=Unable to click on Simulate button on Process Simulator page
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Click Show Results Button On Process Simulator Web
    [Documentation]    Click Show Results Button On Process Simulator Page
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_SHOW_RESULTS_BUTTON}
    ...    error_message=Unable to click on Show Results button on Process Simulator page
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Select Multiple Units From List On Process Simulator Web
    [Documentation]    Selects multiple units from the provided list on Process Simulator Page.
    [Arguments]    @{units_list}
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_UNITS_DROPDOWN}
    ...    error_message=Unable to click on Units dropdown on Process Simulator page
    Wait Until Page Is Loaded
    FOR    ${unit}    IN    @{units_list}
        Fill Textbox On Webpage    ${PROCESS_SIMULATOR_PAGE_UNITS_SEARCH_FIELD}    ${unit}
        ${option}    Update Locator With Dynamic Values    ${PROCESS_SIMULATOR_PAGE_UNITS_OPTION}    UNIT=${unit}
        Click Element On Webpage    ${option}    error_message=Unable to select ${unit} from Units dropdown on Process Simulator page
        Wait Until Page Is Loaded
    END
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_UNITS_DROPDOWN}
    ...    error_message=Unable to click on Units dropdown to close it on Process Simulator page

Select Multiple Start Week From List On Process Simulator Web
    [Documentation]    Selects multiple Start Week from the provided list on Process Simulator Page.
    [Arguments]    @{date_list}
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_WEEK_START_DATE_DROPDOWN}
    ...    error_message=Unable to click on Week Start Date dropdown on Process Simulator page
    Wait Until Page Is Loaded
    FOR    ${week_start_date}    IN    @{date_list}
        Fill Textbox On Webpage    ${PROCESS_SIMULATOR_PAGE_WEEK_START_DATE_SEARCH_FIELD}    ${week_start_date}
        ${option}    Update Locator With Dynamic Values    ${PROCESS_SIMULATOR_PAGE_WEEK_START_DATE_OPTION}
        ...    WEEK_START_DATE=${week_start_date}
        Click Element On Webpage    ${option}
        ...    error_message=Unable to select ${week_start_date} from Week Start Date dropdown on Process Simulator page
        Wait Until Page Is Loaded
    END
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_WEEK_START_DATE_DROPDOWN}
    ...    error_message=Unable to click on Week Start Date dropdown to close it on Process Simulator page
    Capture Screenshot On Webpage

Click View Action On Process Simulator Web
    [Documentation]    Click View Action On Process Simulator Page
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_VIEW_ACTION}
    ...    error_message=Unable to click on View action for the record on Process Simulator page
    Wait Until Page Is Loaded

Click Show Only Mismatch Checkbox On Process Simulator Web
    [Documentation]    Click Show Only Mismatch Checkbox On Process Simulator Page
    Click Element On Webpage    ${PROCESS_SIMULATOR_PAGE_FILTER_MISMATCH_CHECKBOX}
    ...    error_message=Unable to click on Show Only Mismatch checkbox on Process Simulator page
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Is Mismatch Employee Record Displayed On Process Simulator Web
    [Documentation]    Verifies if mismatch employee record is displayed on Process Simulator Page
    ${is_mismatch_records_displayed}    Is Element Visible On Webpage    ${PROCESS_SIMULATOR_PAGE_MISMATCH_EMP_RECORD}
    Capture Screenshot On Webpage
    RETURN    ${is_mismatch_records_displayed}

Verify Mismatch Record For Pay Process Simulator Flow For Multiple Stores And Dates On Web
    [Documentation]
    ...    Performs complete Process Simulator flow for each store-date combination individually.
    ...    Iterates through each store and date, selecting one at a time and clicking simulate.
    ...    | =Arguments= | =Description= |
    ...    | stores_string | String representation of list of store names to select |
    ...    | date_string | String representation of list of dates to select |
    ...    | process_option | The process option to select (e.g., 'Pay') |
    ...    Example usage:
    ...    | ${stores_string}    ['STORE10 - D5Store 10', 'STORE1 - D1Store 1']
    ...    | ${date_string}    ['01/04/2026', '01/11/2026']
    ...    | Verify Mismatch Record For Pay Process Simulator Flow For Multiple Stores And Dates On Web    ${stores_string}    ${date_string}    Pay
    [Arguments]    ${stores_string}    ${date_string}    ${process_option}
    @{stores_list}    Evaluate    ${stores_string}
    @{date_list}    Evaluate    ${date_string}

    # Iterate through each store
    FOR    ${store}    IN    @{stores_list}
        # For each store, iterate through each date
        FOR    ${date}    IN    @{date_list}
            Navigate To PSA Process Simulator Page On Web
            Select Option From Process Dropdown On Process Simulator Web    ${process_option}

            # Select single store
            Select Option From Units Dropdown On Process Simulator Web    ${store}

            # Select single date
            Select Week Start Date From Dropdown On Process Simulator Web    ${date}

            # Click simulate button for this combination
            Click Simulate Button On Process Simulator Web
            Click Show Results Button On Process Simulator Web
            Wait Until Element Is Visible On Webpage    ${PROCESS_SIMULATOR_PAGE_NOTIFICATION_MESSAGE}
            ${is_view_action_displayed}    Is Element Visible On Webpage    ${PROCESS_SIMULATOR_PAGE_VIEW_ACTION}
            Capture Screenshot On Webpage
            IF    '${is_view_action_displayed}' == 'True'
                Click View Action On Process Simulator Web
                Wait Until Page Is Loaded
                Click Show Only Mismatch Checkbox On Process Simulator Web
                ${is_mismatch_records_displayed}    Is Mismatch Employee Record Displayed On Process Simulator Web
                Should Not Be True    ${is_mismatch_records_displayed}
                ...    Mismatch employee record is displayed, but it should not be displayed.
            ELSE
                Log    View action is not displayed for store ${store} and date ${date}. Skipping mismatch record verification.
            END
        END
    END
