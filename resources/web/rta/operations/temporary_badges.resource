*** Settings ***
Documentation       Temporary Badges page related keyword implementation for RTA Operations

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/rta/operations/temporary_badges_page.py
Variables           resources/web/rta/operations/temporary_badges_page_api.py
Variables           resources/web/common/status_codes.py
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RTA Operations Temporary Badges Page On Web
    [Documentation]
    ...    Navigates to RTA -> Operations -> Temporary Badges page
    ...    and verifies temporary badges heading at the top of the page.
    ...    Example usage:
    ...    | Navigate To RTA Operations Temporary Badges Page On Web
    Navigate To Specific Page On Web    rta    operations    temporary_badges
    Wait Until Page Is Loaded

Select Date On Temporary Badges Page On Web
    [Documentation]
    ...    Selects a date from the date picker on the temporary badges page using framework standard.
    ...    Handles both effective date and end date pickers.
    ...    Accepts both week_day offset format (e.g., 0_4) or actual date string matching the environment-configured DATE_FORMAT_MONTH_DAY_YEAR (e.g., 01/22/2026 or 22/01/2026).
    ...    | =Arguments= | =Description= |
    ...    | date_input_locator | Locator for the date input field |
    ...    | date_value | Date in week_day format (e.g., 0_10) OR actual date string in the configured DATE_FORMAT_MONTH_DAY_YEAR |
    ...    Example usage:
    ...    | Select Date On Temporary Badges Page On Web    ${TEMPORARY_BADGES_PAGE_EFFECTIVE_DATE_INPUT}    0_4
    ...    | Select Date On Temporary Badges Page On Web    ${TEMPORARY_BADGES_PAGE_EFFECTIVE_DATE_INPUT}    01/22/2026
    [Arguments]    ${date_input_locator}    ${date_value}
    ${date_value_str}    Convert To String    ${date_value}
    ${is_week_day_format}    Evaluate    "_" in """${date_value_str}"""

    IF    ${is_week_day_format}
        Input Date In Date Picker Through Input Box    ${date_input_locator}    ${date_value}
    ELSE
        Wait Until Element Is Visible On Webpage    ${date_input_locator}
        Set Date With JavaScript    ${date_input_locator}    ${date_value}
    END

    Evaluate JavaScript    ${date_input_locator}    (elem) => elem.blur()
    Wait Until Page Is Loaded

Enter Temporary Badge ID On Temporary Badges Page On Web
    [Documentation]
    ...    Enters temporary badge ID in the input field.
    ...    | =Arguments= | =Description= |
    ...    | badge_id | The temporary badge ID to enter |
    ...    Example usage:
    ...    | Enter Temporary Badge ID On Temporary Badges Page On Web    002992026001
    [Arguments]    ${badge_id}
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_BADGE_ID_INPUT}
    Clear Textbox On Webpage    ${TEMPORARY_BADGES_PAGE_BADGE_ID_INPUT}
    Fill Textbox On Webpage    ${TEMPORARY_BADGES_PAGE_BADGE_ID_INPUT}    ${badge_id}

Select Existing Associate Radio Button On Temporary Badges Page On Web
    [Documentation]
    ...    Selects the 'Existing Associate' radio button option.
    ...    Example usage:
    ...    | Select Existing Associate Radio Button On Temporary Badges Page On Web
    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_EXISTING_ASSOCIATE_RADIO}
    Wait Until Page Is Loaded

Click Select Associate Button On Temporary Badges Page On Web
    [Documentation]
    ...    Clicks the button to open associate selection popup.
    ...    Example usage:
    ...    | Click Select Associate Button On Temporary Badges Page On Web
    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_SELECT_ASSOCIATE_BUTTON}
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_ASSOCIATE_SEARCH_INPUT}

Search And Select Associate On Temporary Badges Page On Web
    [Documentation]
    ...    Searches for an associate by ID and selects from the results.
    ...    | =Arguments= | =Description= |
    ...    | associate_id | The associate ID to search for |
    ...    Example usage:
    ...    | Search And Select Associate On Temporary Badges Page On Web    Z2EMP000001
    [Arguments]    ${associate_id}
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_ASSOCIATE_SEARCH_INPUT}
    Clear Textbox On Webpage    ${TEMPORARY_BADGES_PAGE_ASSOCIATE_SEARCH_INPUT}
    Fill Textbox On Webpage    ${TEMPORARY_BADGES_PAGE_ASSOCIATE_SEARCH_INPUT}    ${associate_id}

    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_ASSOCIATE_SEARCH_APPLY_BUTTON}
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_ASSOCIATE_SEARCH_RESULT_ROW}

    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_ASSOCIATE_SEARCH_RESULT_ROW}
    Wait Until Page Is Loaded

Select Reason From Dropdown On Temporary Badges Page On Web
    [Documentation]
    ...    Selects a reason from the dropdown.
    ...    | =Arguments= | =Description= |
    ...    | reason | Reason value to select or 'first' for first non-empty option |
    ...    Example usage:
    ...    | Select Reason From Dropdown On Temporary Badges Page On Web    first
    ...    | Select Reason From Dropdown On Temporary Badges Page On Web    Forgot
    [Arguments]    ${reason}
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_REASON_DROPDOWN}

    IF    '${reason}' == 'first'
        # Select first non-empty option (index 1)
        Select List Item On Webpage    ${TEMPORARY_BADGES_PAGE_REASON_DROPDOWN}    attribute=index    value=1
    ELSE
        Select List Item On Webpage    ${TEMPORARY_BADGES_PAGE_REASON_DROPDOWN}    label    ${reason}
    END
    Wait Until Page Is Loaded

Click Save Button On Temporary Badges Page On Web
    [Documentation]
    ...    Clicks the Save button and validates API response for temporary badge operations.
    ...    Uses promise-based pattern to capture backend response.
    ...    Example usage:
    ...    | Click Save Button On Temporary Badges Page On Web
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_SAVE_BUTTON}

    ${promise}    Promise To    Wait For Response    ${SAVE_TEMPORARY_BADGE_API}
    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_SAVE_BUTTON}

    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be True    ${response_body.status} in [${HTTP_STATUS_CODES}[OK], 302]
    ...    msg=Expected status 200 or 302 but got ${response_body.status}
    Wait Until Page Is Loaded

Open Filter On Temporary Badges Page On Web
    [Documentation]
    ...    Opens the filter panel by clicking the filter icon.
    ...    Assumes the user is already on the Temporary Badges page.
    ...    Example usage:
    ...    | Open Filter On Temporary Badges Page On Web
    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_FILTER_ICON}
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_FILTER_BADGE_ID_INPUT}

Filter By Badge ID On Temporary Badges Page On Web
    [Documentation]
    ...    Filters temporary badges by badge ID.
    ...    | =Arguments= | =Description= |
    ...    | badge_id | The badge ID to filter by |
    ...    Example usage:
    ...    | Filter By Badge ID On Temporary Badges Page On Web    002992026001
    [Arguments]    ${badge_id}
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_FILTER_BADGE_ID_INPUT}
    Clear Textbox On Webpage    ${TEMPORARY_BADGES_PAGE_FILTER_BADGE_ID_INPUT}
    Fill Textbox On Webpage    ${TEMPORARY_BADGES_PAGE_FILTER_BADGE_ID_INPUT}    ${badge_id}

Select Status Filter On Temporary Badges Page On Web
    [Documentation]
    ...    Selects a status from the filter dropdown using constants.
    ...    | =Arguments= | =Description= |
    ...    | status_label | Status label to select (Active, Inactive) |
    ...    Example usage:
    ...    | Select Status Filter On Temporary Badges Page On Web    Inactive
    [Arguments]    ${status_label}
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_FILTER_STATUS_DROPDOWN}
    Select List Item On Webpage    ${TEMPORARY_BADGES_PAGE_FILTER_STATUS_DROPDOWN}    label    ${status_label}
    Wait Until Page Is Loaded

Filter And Select Badge For Editing On Temporary Badges Page On Web
    [Documentation]
    ...    Complete workflow to filter temporary badges and select for editing.
    ...    Combines: Open Filter -> Filter by Badge ID -> Optional Status Filter -> Apply Filter -> Select Badge Row.
    ...    | =Arguments= | =Description= |
    ...    | badge_id | The badge ID to filter and select |
    ...    | status_filter | Optional status filter (e.g., 'Inactive'). Default is None (Active badges) |
    ...    Example usage:
    ...    | Filter And Select Badge For Editing On Temporary Badges Page On Web    002992026001
    ...    | Filter And Select Badge For Editing On Temporary Badges Page On Web    002992026001    Inactive
    [Arguments]    ${badge_id}    ${status_filter}=None
    Open Filter On Temporary Badges Page On Web
    Filter By Badge ID On Temporary Badges Page On Web    ${badge_id}

    IF    '${status_filter}' != 'None'
        Select Status Filter On Temporary Badges Page On Web    ${status_filter}
    END

    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_FILTER_APPLY_BUTTON}
    Wait Until Page Is Loaded

    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_BADGE_ROW}
    Wait Until Page Is Loaded

Select Status On Edit Form On Temporary Badges Page On Web
    [Documentation]
    ...    Selects status from the dropdown on edit form using constants.
    ...    | =Arguments= | =Description= |
    ...    | status_label | Status label to select (Active, Inactive) |
    ...    Example usage:
    ...    | Select Status On Edit Form On Temporary Badges Page On Web    Inactive
    [Arguments]    ${status_label}
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_STATUS_DROPDOWN}

    IF    '${status_label}' == 'Inactive'
        ${status_value}    Get System Value    TemporaryBadgeStatus    INACTIVE
    ELSE IF    '${status_label}' == 'Active'
        ${status_value}    Get System Value    TemporaryBadgeStatus    ACTIVE
    ELSE
        Fail    Invalid status label: ${status_label}. Expected 'Active' or 'Inactive'.
    END

    Select List Item On Webpage    ${TEMPORARY_BADGES_PAGE_STATUS_DROPDOWN}    value    ${status_value}
    Wait Until Page Is Loaded

Click Delete Button On Temporary Badges Page On Web
    [Documentation]
    ...    Clicks the Delete button, handles browser confirmation, and validates API response.
    ...    Uses promise-based pattern to capture backend response (HTTP 200 or 302 redirect).
    ...    Example usage:
    ...    | Click Delete Button On Temporary Badges Page On Web
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_DELETE_BUTTON}

    ${promise}    Promise To    Wait For Response    ${DELETE_TEMPORARY_BADGE_API}
    Handle Future Dialogs    action=accept
    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_DELETE_BUTTON}

    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be True    ${response_body.status} in [${HTTP_STATUS_CODES}[OK], 302]
    ...    msg=Expected status 200 or 302 but got ${response_body.status}
    Wait Until Page Is Loaded

Add Temporary Badge On Temporary Badges Page On Web
    [Documentation]
    ...    Complete workflow to add a temporary badge with API response validation.
    ...    | =Arguments= | =Description= |
    ...    | badge_data | Dictionary containing badge details (effective_date, end_date, badgeId, associate_id). |
    ...    Also supports legacy key badge_id for backward compatibility.
    ...    Example usage:
    ...    | VAR    ${badge_data}    &{{ effective_date=0_0, end_date=0_10, badgeId=002992026001, associate_id=Z2EMP000001 }}
    ...    | Add Temporary Badge On Temporary Badges Page On Web    ${badge_data}
    [Arguments]    ${badge_data}
    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_ADD_BUTTON}
    Wait Until Page Is Loaded

    Select Date On Temporary Badges Page On Web    ${TEMPORARY_BADGES_PAGE_EFFECTIVE_DATE_INPUT}
    ...    ${badge_data}[effective_date]
    Select Date On Temporary Badges Page On Web    ${TEMPORARY_BADGES_PAGE_END_DATE_INPUT}
    ...    ${badge_data}[end_date]
    ${has_badge_id_new}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${badge_data}    badgeId
    IF    ${has_badge_id_new}
        VAR    ${badge_id}    ${badge_data}[badgeId]
    ELSE
        VAR    ${badge_id}    ${badge_data}[badge_id]
    END
    Enter Temporary Badge ID On Temporary Badges Page On Web    ${badge_id}
    Select Existing Associate Radio Button On Temporary Badges Page On Web
    Click Select Associate Button On Temporary Badges Page On Web
    Search And Select Associate On Temporary Badges Page On Web    ${badge_data}[associate_id]
    Select Reason From Dropdown On Temporary Badges Page On Web    first
    Click Save Button On Temporary Badges Page On Web

Edit Temporary Badge End Date On Temporary Badges Page On Web
    [Documentation]
    ...    Edits the end date of an existing temporary badge with API validation.
    ...    | =Arguments= | =Description= |
    ...    | badge_id | The badge ID to filter and edit |
    ...    | new_end_date | New end date in week_day format (e.g., 0_20) OR actual date (MM/DD/YYYY) |
    ...    Example usage:
    ...    | Edit Temporary Badge End Date On Temporary Badges Page On Web    002992026001    0_20
    ...    | Edit Temporary Badge End Date On Temporary Badges Page On Web    002992026001    02/11/2026
    [Arguments]    ${badge_id}    ${new_end_date}
    Filter And Select Badge For Editing On Temporary Badges Page On Web    ${badge_id}

    ${current_effective_date}    Get Property    ${TEMPORARY_BADGES_PAGE_EFFECTIVE_DATE_INPUT}    value
    Select Date On Temporary Badges Page On Web    ${TEMPORARY_BADGES_PAGE_EFFECTIVE_DATE_INPUT}    ${current_effective_date}

    Select Date On Temporary Badges Page On Web    ${TEMPORARY_BADGES_PAGE_END_DATE_INPUT}    ${new_end_date}
    Click Save Button On Temporary Badges Page On Web

Update Temporary Badge Status To Inactive On Temporary Badges Page On Web
    [Documentation]
    ...    Updates temporary badge status to Inactive with API validation.
    ...    | =Arguments= | =Description= |
    ...    | badge_id | The badge ID to filter and update |
    ...    Example usage:
    ...    | Update Temporary Badge Status To Inactive On Temporary Badges Page On Web    002992026001
    [Arguments]    ${badge_id}
    ${inactive_label}    Get System Value    TemporaryBadgeStatus    INACTIVE_LABEL
    Filter And Select Badge For Editing On Temporary Badges Page On Web    ${badge_id}
    Select Status On Edit Form On Temporary Badges Page On Web    ${inactive_label}
    Click Save Button On Temporary Badges Page On Web

Delete Temporary Badge On Temporary Badges Page On Web
    [Documentation]
    ...    Deletes a temporary badge (must be in Inactive status) with API validation.
    ...    | =Arguments= | =Description= |
    ...    | badge_id | The badge ID to delete |
    ...    Example usage:
    ...    | Delete Temporary Badge On Temporary Badges Page On Web    002992026001
    [Arguments]    ${badge_id}
    ${inactive_label}    Get System Value    TemporaryBadgeStatus    INACTIVE_LABEL
    Filter And Select Badge For Editing On Temporary Badges Page On Web    ${badge_id}    ${inactive_label}
    Click Delete Button On Temporary Badges Page On Web

Click On Add Temporary Badge Button On Temporary Badges Page On Web
    [Documentation]
    ...    Clicks on the "Add Temporary Badge" button to open the add form.
    ...    Example usage:
    ...    | Click On Add Temporary Badge Button On Temporary Badges Page On Web
    Click Element On Webpage    ${TEMPORARY_BADGES_PAGE_ADD_BUTTON}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${TEMPORARY_BADGES_PAGE_PREVIOUS_BUTTON}
    Capture Screenshot On Webpage
