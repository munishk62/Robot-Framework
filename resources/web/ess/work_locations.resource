*** Settings ***
Documentation       Resource file for ESS Work Locations page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/ess/work_locations_page.py
Variables           resources/web/ess/work_locations_api.py
Variables           resources/web/common/status_codes.py


*** Keywords ***
Navigate To ESS Work Locations Page On Web
    [Documentation]    Navigates to ESS -> Work Locations page and verifies page load.
    Navigate To Specific Page On Web    ess    work_locations

Add Alternate Work Location Request On Web
    [Documentation]    Adds a new alternate work location request.
    ...
    ...    *Arguments:*
    ...    - ``alternate_work_location_data``: Dictionary containing alternate work location data
    ...
    ...    *Example:*
    ...    | ${awl_data}= | Get Generic Entity Data | alternate_work_location | template_name=default |
    ...    | Add Alternate Work Location Request On Web | ${awl_data} |
    [Arguments]    ${alternate_work_location_data}

    Wait Until Element Is Visible On Webpage    ${WORK_LOCATIONS_PAGE_ADD_BTN}
    ...    error_message=Add Request button not visible on Work Locations page
    Click Element On Webpage    ${WORK_LOCATIONS_PAGE_ADD_BTN}

    Wait Until Element Is Visible On Webpage    ${WORK_LOCATIONS_PAGE_DESCRIPTION}
    ...    error_message=Description input field not visible after clicking Add Request button
    Fill Textbox On Webpage    ${WORK_LOCATIONS_PAGE_DESCRIPTION}    ${alternate_work_location_data}[description]

    Wait Until Element Is Visible On Webpage    ${WORK_LOCATIONS_PAGE_UNIT_DROPDOWN}
    ...    error_message=Unit dropdown not visible on Add Request form
    Click Element On Webpage    ${WORK_LOCATIONS_PAGE_UNIT_DROPDOWN}

    Wait Until Element Is Visible On Webpage    ${WORK_LOCATIONS_PAGE_UNIT_SEARCH}
    ...    error_message=Unit search input not visible after opening Unit dropdown
    Fill Textbox On Webpage    ${WORK_LOCATIONS_PAGE_UNIT_SEARCH}    ${alternate_work_location_data}[unit]

    ${unit_opt}    Update Locator With Dynamic Values    ${WORK_LOCATIONS_PAGE_UNIT_OPTION}    UNIT=${alternate_work_location_data}[unit]
    Wait Until Element Is Visible On Webpage    ${unit_opt}    timeout=${LONG_TIMEOUT}
    ...    error_message=Unit option '${alternate_work_location_data}[unit]' not visible in dropdown search results
    Click Element On Webpage    ${unit_opt}

    Select Date Through Date Picker For ESS Requests On Webpage    ${WORK_LOCATIONS_PAGE_START_DATE_PICKER}
    ...    ${alternate_work_location_data}[start_date]
    Select Date Through Date Picker For ESS Requests On Webpage    ${WORK_LOCATIONS_PAGE_END_DATE_PICKER}
    ...    ${alternate_work_location_data}[end_date]

    ${promise}    Promise To    Wait For Response    ${ADD_ALTERNATE_WORK_LOCATION_API_REGEX}
    Click Element On Webpage    ${WORK_LOCATIONS_PAGE_SAVE_BTN}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Should Be Equal As Strings    ${response_body.body}[statusCode]    1

    ${request_row}    Update Locator With Dynamic Values    ${WORK_LOCATIONS_PAGE_REQUEST_ROW}
    ...    DESCRIPTION=${alternate_work_location_data}[description]
    Wait Until Element Is Visible On Webpage    ${request_row}
    ...    error_message=Newly added alternate work location request '${alternate_work_location_data}[description]' not visible in the list

Edit Alternate Work Location Request On Web
    [Documentation]
    ...    Edits an existing alternate work location request.
    ...    | =Arguments=    | =Description=    |
    ...    | old_alt_work_loc_desc    | Current description to locate the request    |
    ...    | new_alt_work_loc_desc    | New description to update    |
    ...    Example usage:
    ...    | Edit Alternate Work Location Request On Web | Old Location | New Location |
    [Arguments]    ${old_alt_work_loc_desc}    ${new_alt_work_loc_desc}

    ${req_row}    Update Locator With Dynamic Values    ${WORK_LOCATIONS_PAGE_REQUEST_ROW}    DESCRIPTION=${old_alt_work_loc_desc}
    Wait Until Element Is Visible On Webpage    ${req_row}
    ...    error_message=Alternate work location request '${old_alt_work_loc_desc}' not visible in the list
    Click Element On Webpage    ${req_row}

    Wait Until Element Is Visible On Webpage    ${WORK_LOCATIONS_PAGE_DESCRIPTION_EDIT}
    ...    error_message=Description edit field not visible after clicking the request row
    Clear Textbox On Webpage    ${WORK_LOCATIONS_PAGE_DESCRIPTION_EDIT}
    Fill Textbox On Webpage    ${WORK_LOCATIONS_PAGE_DESCRIPTION_EDIT}    ${new_alt_work_loc_desc}

    ${promise}    Promise To    Wait For Response    ${EDIT_ALTERNATE_WORK_LOCATION_API_REGEX}
    Click Element On Webpage    ${WORK_LOCATIONS_PAGE_UPDATE_BTN}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Should Be Equal As Strings    ${response_body.body}[statusCode]    1

    ${updated_row}    Update Locator With Dynamic Values    ${WORK_LOCATIONS_PAGE_REQUEST_ROW}    DESCRIPTION=${new_alt_work_loc_desc}
    Wait Until Element Is Visible On Webpage    ${updated_row}
    ...    error_message=Updated alternate work location request '${new_alt_work_loc_desc}' not visible in the list

Delete Alternate Work Location Request On Web
    [Documentation]
    ...    Deletes an alternate work location request.
    ...    | =Arguments=    | =Description=    |
    ...    | alt_work_loc_desc    | Description of the request to delete    |
    ...    Example usage:
    ...    | Delete Alternate Work Location Request On Web | My Location |
    [Arguments]    ${alt_work_loc_desc}

    ${req_row}    Update Locator With Dynamic Values    ${WORK_LOCATIONS_PAGE_REQUEST_ROW}    DESCRIPTION=${alt_work_loc_desc}
    Wait Until Element Is Visible On Webpage    ${req_row}
    ...    error_message=Alternate work location request '${alt_work_loc_desc}' not visible in the list
    Click Element On Webpage    ${req_row}

    Wait Until Element Is Visible On Webpage    ${WORK_LOCATIONS_PAGE_DELETE_BTN}
    ...    error_message=Delete button not visible after clicking the request row
    ${promise}    Promise To    Wait For Response    ${DELETE_ALTERNATE_WORK_LOCATION_API_REGEX}
    Click Element On Webpage    ${WORK_LOCATIONS_PAGE_DELETE_BTN}

    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Should Be Equal As Strings    ${response_body.body}[statusCode]    1

Delete Alternate Work Location If Exists On Web
    [Documentation]    Deletes an alternate work location request by description if it exists.
    ...    Safe to call even when the request is not present — used as a pre-test cleanup guard.
    ...    | =Arguments=    | =Description=    |
    ...    | description    | Description of the request to conditionally delete    |
    [Arguments]    ${description}

    ${req_row}    Update Locator With Dynamic Values    ${WORK_LOCATIONS_PAGE_REQUEST_ROW}    DESCRIPTION=${description}
    ${exists}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${req_row}    timeout=${SHORT_TIMEOUT}
    IF    not ${exists}    RETURN
    Click Element On Webpage    ${req_row}

    Wait Until Element Is Visible On Webpage    ${WORK_LOCATIONS_PAGE_DELETE_BTN}
    ...    error_message=Delete button not visible after clicking the request row
    ${promise}    Promise To    Wait For Response    ${DELETE_ALTERNATE_WORK_LOCATION_API_REGEX}
    Click Element On Webpage    ${WORK_LOCATIONS_PAGE_DELETE_BTN}

    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Should Be Equal As Strings    ${response_body.body}[statusCode]    1
