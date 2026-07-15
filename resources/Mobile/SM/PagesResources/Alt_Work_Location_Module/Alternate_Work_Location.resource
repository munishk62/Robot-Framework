*** Settings ***
Documentation       This resource contains keyword required for Alternate work location related features.

Library            DateTime
Resource        resources/Mobile/Common/MobileKeyboardUtils.resource
Resource        resources/Mobile/SM/PagesResources/More/More.resource
Variables        resources/Mobile/SM/Locators/Alternate_Work_Location.py
Resource            resources/Mobile/SM/PagesResources/Shift_Request/SM_Shift_Request.resource
Resource            resources/Mobile/SM/PagesResources/My_Store/SM_My_Store.resource


*** Keywords ***
Navigate To Alternate Work Location Tab On Associate Roster Page On SM Phone App
    [Documentation]   Navigates to alternate work location on SM phone app.
    Tap More Options Icon On Associate Roster Page On SM Phone App
    ${alternate_work_loc_localised}    Get Localised Message From Key For SM    ${ALT_WORK_LOCATION_TAB}
    ${alt_work_loc_more_option_locator}    Get Message With Arguments For SM    ${ROSTER_MORE_OPTIONS_ALT_WORK_LOCATION}    ${alternate_work_loc_localised}
    Wait Until Page Contains Element    ${alt_work_loc_more_option_locator}
    Click Element    ${alt_work_loc_more_option_locator}
    ${alt_work_loc_page_header_locator}    Get Message With Arguments For SM    ${ALT_WORK_LOCATION_TAB_HEADER}    ${alternate_work_loc_localised}
    Wait Until Page Contains Element    ${alt_work_loc_page_header_locator}    error=Alternate Work Location page is not visible after clicking on alternate work location option in more options on associate roster page

Select Alternate Work Location Request List Item On SM Phone App
    [Documentation]   Selects the alternate work location request list item on SM phone app.
    [Arguments]    ${start_date}    ${end_date}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${req_start_date}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}
    ${req_end_date}    Calculate Date From Week Day Offset    ${end_date}    ${date_format}
    ${alt_work_loc_request_list_item_locator}    Get Locator Contains For SM    ${req_start_date} - ${req_end_date}
    Wait Until Page Contains Element    ${alt_work_loc_request_list_item_locator}
    Click Element    ${alt_work_loc_request_list_item_locator}

Open Add Alternate Work Location Page On Mobile SM
    [Documentation]    Taps on Add button on Alternate Work Location module to open add request page.
    Wait Until Element Is Visible    ${ALT_WORK_LOCATION_ADD_BTN}
    Click Element    ${ALT_WORK_LOCATION_ADD_BTN}

Open Status Selection For Alternate Work Location Request On SM Phone App
    [Documentation]    Opens the status selection for alternate work location request on SM phone app.
    Wait Until Page Contains Element    ${ALT_WORK_LOCATION_STATUS}
    Click Element    ${ALT_WORK_LOCATION_STATUS}

Select Edit Status Of Alternate Work Location Request On SM Phone App
    [Documentation]   Selects the edit status of alternate work location request on SM phone app.
    Wait Until Page Contains Element    ${ALT_WORK_LOCATION_EDIT_STATUS}
    Click Element    ${ALT_WORK_LOCATION_EDIT_STATUS}

Add Alternate Work Location Request On Mobile SM
    [Documentation]    Adds alternate work location on mobile SM app. Don't use this method directly, it is a master method used for implementation
    ...    Args:
    ...    ${description}: Description for the request.
    ...    ${request_start_week_day}: Start week date for the request.
    ...    ${request_end_week_day}: End week date for the request.
    ...    ${store_names}: Store full name where associate is requesting to work.
    ...    ${note}: Notes for the request.
    ...    ${status}: Status of the request. Supported values: approved, not reviewed, declined.
    [Arguments]    ${description}    ${request_start_week_day}    ${request_end_week_day}    ${store_names}    ${note}=None    ${status}=not reviewed
    Enter Description Of Alternate Work Location Request On Mobile SM    ${description}
    Select Alternate Work Location Request Start Date On Mobile SM    ${request_start_week_day}
    Select Alternate Work Location Request End Date Directly On Mobile SM    ${request_end_week_day}    ${request_start_week_day}
    IF    '${note}'!='None'
        Enter Note For Alternate Work Location Request On Mobile SM    ${note}
    END
    Tap Add Location To Open Select Alternate Stores On Mobile SM
    Search And Select Multiple Alternate Work Location On Mobile SM    ${store_names}
    Open Status Selection For Alternate Work Location Request On SM Phone App
    Select Alternate Work Location Request Status On Mobile SM    ${status}
    Submit Alternate Work Location Request For Approval On Mobile SM

Select Alternate Work Location Request Status On Mobile SM
    [Documentation]    Selects alternate work location request status on mobile SM app based on provided status value.
    [Arguments]    ${status}
    ${normalized_status}    Evaluate    "${status}".title()
    IF    '${normalized_status}'=='Approved'
        ${status_label}    Get Localised Message From Key For SM    ${ALT_WORK_LOCATION_STATUS_APPROVED_KEY}
        ${approved_status_locator}    Get Locator Contains For SM    ${status_label}
        Click Element    ${approved_status_locator}
    ELSE IF    '${normalized_status}'=='Declined'
        ${status_label}    Get Localised Message From Key For SM    ${ALT_WORK_LOCATION_STATUS_DECLINED_KEY}
        ${declined_status_locator}    Get Locator Contains For SM    ${status_label}
        Click Element    ${declined_status_locator}
    ELSE IF    '${normalized_status}'=='Not Reviewed'
        ${status_label}    Get Localised Message From Key For SM    ${ALT_WORK_LOCATION_STATUS_NOT_REVIEWED_KEY}
        ${not_reviewed_status_locator}    Get Locator Contains For SM    ${status_label}
        Click Element    ${not_reviewed_status_locator}
    ELSE
        Fail    Unsupported status '${status}'. Supported values are: Approved, Not Reviewed, Declined.
    END

Select Approved Status Of Alternate Work Location Request On SM Phone App
    [Documentation]   Selects the approved status of alternate work location request on SM phone app.
    ${status_label}    Get Localised Message From Key For SM    ${ALT_WORK_LOCATION_STATUS_APPROVED_KEY}
    ${approved_status_locator}    Get Message With Arguments For SM    ${ALT_WORK_LOCATION_STATUS_APPROVED}    ${status_label}
    Click Element    ${approved_status_locator}

Enter Description Of Alternate Work Location Request On Mobile SM
    [Documentation]    Enters description of alternate work location request on mobile ESS app.
    ...    Args:
    ...    ${descriptionData}: <description for request>
    [Arguments]    ${description_data}
    Wait Until Page Contains Element    ${ALT_WORK_LOCATION_DESCRIPTION}
    Click Element    ${ALT_WORK_LOCATION_DESCRIPTION}
    Input Text    ${ALT_WORK_LOCATION_DESCRIPTION}    ${description_data}
    Hide Mobile Keyboard

Select Declined Status Of Alternate Work Location Request On SM Phone App
    [Documentation]   Selects the declined status of alternate work location request on SM phone app.
    ${status_label}    Get Localised Message From Key For SM    ${ALT_WORK_LOCATION_STATUS_DECLINED_KEY}
    ${declined_status_locator}    Get Message With Arguments For SM    ${ALT_WORK_LOCATION_STATUS_DECLINED}    ${status_label}
    Click Element    ${declined_status_locator}

Select Alternate Work Location Request Start Date On Mobile SM
    [Documentation]    Selects start date for alternate work location request on mobile ESS app.
    ...    Args:
    ...    ${request_start}: Start week date for the request.
    ...    ${calendar_open_date}: (optional) Date on which calendar should open. If not provided, calendar will open on current month.
    [Arguments]    ${request_start}    ${calendar_open_date}=${None}
    Select Date On SM Calendar    ${ALT_WORK_LOCATION_START_DATE}    ${request_start}    ${calendar_open_date}

Update Status Of Alternate Work Location Request On SM Phone App
    [Documentation]   Selects the update status of alternate work location request on SM phone app.
    ${update_label}    Get Localised Message From Key For SM    ${ALT_WORK_LOCATION_UPDATE_KEY}
    ${update_status_locator}    Get Message With Arguments For SM    ${ALT_WORK_LOCATION_UPDATE_STATUS}    ${update_label}
    Wait Until Page Contains Element    ${update_status_locator}
    Click Element    ${update_status_locator}

Select Alternate Work Location Request End Date Directly On Mobile SM
    [Documentation]    Selects end date for alternate work location request on mobile ESS app by directly tapping on end date field and selecting date from calendar. This keyword should be used when start and end date are in different months and calendar opens on start date month, so that we can directly open calendar on end date month by tapping on end date field.
    ...    Args:
    ...    ${request_end}: End week date for the request.
    ...    ${calendar_open_date}: (optional) Date on which calendar should open. If not provided, calendar will open on current month.
    [Arguments]    ${request_end}    ${calendar_open_date}
    ${date_format}    Get Config Value    SERVER_DF
    Wait Until Page Contains Element    ${ALT_WORK_LOCATION_END_DATE}
    Click Element    ${ALT_WORK_LOCATION_END_DATE}
    ${current_date}    Get Current Date    result_format=${date_format}
    Navigate SM Calendar To    ${request_end}    ${current_date}

Delete Alternate Work Location Request From Details On SM Phone App
    [Documentation]   Deletes the alternate work location request from details on SM phone app.
    ${delete_label}    Get Localised Message From Key For SM    ${ALT_WORK_LOCATION_DELETE_KEY}
    ${delete_button_locator}    Get Message With Arguments For SM    ${ALT_WORK_LOCATION_DELETE_BUTTON}    ${delete_label}
    Wait Until Page Contains Element    ${delete_button_locator}
    Click Element    ${delete_button_locator}

Tap Add Location To Open Select Alternate Stores On Mobile SM
    [Documentation]    Taps on add location button to open select alternate stores screen on mobile ESS app.
    Wait Until Element Is Visible    ${ALT_WORK_LOCATION_ADD_LOCATION}
    Click Element    ${ALT_WORK_LOCATION_ADD_LOCATION}
    Wait Until Element Is Visible    ${ALT_WORK_LOCATION_SELECT_TITLE}

Close Details Page Of Alternate Work Location Request On SM Phone App
    [Documentation]   Closes the details page of alternate work location request on SM phone app.
    Wait Until Page Contains Element    ${ALT_WORK_LOCATION_CANCEL_DETAILS}
    Click Element    ${ALT_WORK_LOCATION_CANCEL_DETAILS}

Search And Select Multiple Alternate Work Location On Mobile SM
    [Documentation]    Searches and selects alternate work location on mobile ESS app. This keyword is used when there are multiple stores with same name and we need to select multiple stores for alternate work location request.
    ...    Args:
    ...    ${store_names}: List of store full names where associate is requesting to work
    [Arguments]    ${store_names}
    FOR    ${store_full_name}    IN    @{store_names}
        Swipe Until Visible    ${ALT_WORK_LOCATION_SEARCH}
        Wait Until Page Contains Element    ${ALT_WORK_LOCATION_SEARCH}
        Click Element    ${ALT_WORK_LOCATION_SEARCH}
        Run Keyword And Ignore Error    Clear Text    ${ALT_WORK_LOCATION_SEARCH}
        ${store_name_search_keyword}    Get Substring    ${store_full_name}    0    -1
        Input Text    ${ALT_WORK_LOCATION_SEARCH}    ${store_name_search_keyword}
        IF    '${MOBILE_PLATFORM}'=='android'
            Hide Mobile Keyboard
        ELSE
            Press Search On IOS Keyboard
        END
        ${store_option}    Get Locator Contains    ${store_full_name}
        Wait Until Element Is Visible    ${store_option}
        Click Element    ${store_option}
    END
    Wait Until Element Is Visible    ${ALT_WORK_LOCATION_DONE}
    Click Element    ${ALT_WORK_LOCATION_DONE}

Verify Request Status Is Approved On SM Phone App
    [Documentation]   Verifies the request status is approved on SM phone app.
    ${status_label}    Get Localised Message From Key For SM    ${ALT_WORK_LOCATION_STATUS_APPROVED_KEY}
    ${approved_status_locator}    Get Message With Arguments For SM    ${ALT_WORK_LOCATION_CURRENT_APPROVED}    ${status_label}
    Wait Until Page Contains Element    ${approved_status_locator}

Withdraw Alternate Work Location Request On SM Phone App
    [Documentation]   Withdraws the alternate work location request on SM phone app.
    Wait Until Page Contains Element    ${ALT_WORK_LOCATION_WITHDRAW}
    Click Element    ${ALT_WORK_LOCATION_WITHDRAW}

Enter Note For Alternate Work Location Request On Mobile SM
    [Documentation]    Used for entering note for alternate work location request on mobile ESS app.
    ...    Args:
    ...    ${noteData}: <note for request>
    [Arguments]    ${note_data}
    ${note_label}    Get Localised Locator Contains    ${alternate_work_loc_note}
    Swipe Until Visible    ${note_label}
    Wait Until Page Contains Element    ${note_label}
    Click Element    ${note_label}
    Input Text  ${note_label}    ${note_data}

Submit Alternate Work Location Request For Approval On Mobile SM
    [Documentation]    Used for submitting alternate work location request for approval on mobile ESS app.
    ${is_keyboard_visible}    Run Keyword And Return Status    Is Keyboard Shown
    IF    ${is_keyboard_visible}    Hide Keyboard
    Swipe Until Visible    ${ALT_WORK_LOCATION_SUBMIT_BTN}
    Wait Until Element Is Visible    ${ALT_WORK_LOCATION_SUBMIT_BTN}
    Click Element    ${ALT_WORK_LOCATION_SUBMIT_BTN}

Verify Mobile SM Alternate Work Location Request List Item On Mobile SM App
    [Documentation]    Used for verifying alternate work location request list item in tab on mobile SM App.
    ...    Args:
    ...    ${store_name}: Store Name
    ...    ${start_date}: Start date for the request.
    ...    ${end_date}: End date for the request.
    ...    ${req_status}: Status of the request.
    [Arguments]    ${req_status}    ${store_name}    ${start_date}    ${end_date}
    ${request_list_item_semantic}    Get Alternate Work Location Request List Semantic On Mobile SM App    ${req_status}    ${store_name}    ${start_date}    ${end_date}
    Swipe Until Visible    ${request_list_item_semantic}

Get Alternate Work Location Request List Semantic On Mobile SM App
    [Documentation]    Used for verifying request in list on mobile SM App.
    ...    Args:
    ...    ${req_status}: Status of the request.
    ...    ${store_name}: Store Name
    ...    ${req_start_date}: Start date for the request.
    ...    ${req_end_date}: End date for the request.
    [Arguments]    ${req_status}    ${store_name}    ${req_start_date}    ${req_end_date}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${final_status_label}    Evaluate    "${req_status}".title()
    VAR    ${store_name_value}    ${store_name}[0]
    VAR    ${date_text}    ''
    IF    '${req_start_date}' == '${req_end_date}'
        ${date_text}    Calculate Date From Week Day Offset    ${req_start_date}    ${date_format}
    ELSE
        ${request_start_text}    Calculate Date From Week Day Offset    ${req_start_date}    ${date_format}
        ${request_end_text}    Calculate Date From Week Day Offset    ${req_end_date}    ${date_format}
        VAR    ${date_text}    ${request_start_text} - ${request_end_text}
    END
    ${locator}    Get Message With Arguments For SM    ${ALT_WORK_LOCATION_REQUEST_LIST_ITEM_BY_STORE_DATE_STATUS}    ${store_name_value}    ${date_text}    ${final_status_label}
    RETURN    ${locator}

Tap Alternate Work Location Request List Item On Mobile SM App
    [Documentation]    Used for tapping on alternate work location request list item in tab on mobile SM app to open details page.
    ...    Args:
    ...    ${store_name}: Store Name
    ...    ${start_date}: Start date for the request.
    ...    ${end_date}: End date for the request.
    ...    ${req_status}: Status of the request.
    [Arguments]    ${req_status}    ${store_name}    ${start_date}    ${end_date}
    ${request_list_item_semantic}    Get Alternate Work Location Request List Semantic On Mobile SM App    ${req_status}    ${store_name}    ${start_date}    ${end_date}
    Swipe Until Visible    ${request_list_item_semantic}
    Click Element    ${request_list_item_semantic}

Delete Alternate Work Location Request If Present For Any Status On Mobile SM App
    [Documentation]    Deletes existing alternate work location requests for the same date range by checking supported statuses one-by-one.
    ...    Args:
    ...    ${store_name}: Store name list used in request list semantic.
    ...    ${start_date}: Start date offset in PW_D format.
    ...    ${end_date}: End date offset in PW_D format.
    [Arguments]    ${store_name}    ${start_date}    ${end_date}
    VAR    @{request_status_list}    Declined    Not Reviewed    Approved    Partially Reviewed
    FOR    ${existing_status}    IN    @{request_status_list}
        ${is_same_request_present}    Run Keyword And Return Status
        ...    Verify Mobile SM Alternate Work Location Request List Item On Mobile SM App    ${existing_status}    ${store_name}
        ...    ${start_date}    ${end_date}
        IF    ${is_same_request_present}
            Tap Alternate Work Location Request List Item On Mobile SM App    ${existing_status}    ${store_name}    ${start_date}
            ...    ${end_date}
            Delete Alternate Work Location Request From Details On SM Phone App
        END
    END

Verify Alternate Work Location Request List Item On SM Phone App
    [Documentation]   Selects the alternate work location request list item on SM phone app.
    [Arguments]    ${start_date}    ${end_date}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${req_start_date}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}
    ${req_end_date}    Calculate Date From Week Day Offset    ${end_date}    ${date_format}
    ${alt_work_loc_request_list_item_locator}    Get Locator Contains For SM    ${req_start_date} - ${req_end_date}
    Swipe Until Visible    ${alt_work_loc_request_list_item_locator}

Navigate Back From Alternate Work Location On SM Phone App
    [Documentation]    Navigates back on mobile SM app by tapping on back arrow.
    Wait Until Element Is Visible    ${ALT_WORK_LOCATION_BACK_BTN}
    Click Element    ${ALT_WORK_LOCATION_BACK_BTN}

Approve Shift Bid Response On SM Phone App
    [Documentation]
    ...    Approves a shift bid response (Open, Additional Work, or Swap) from a nearby associate on the SM mobile app.
    ...
    ...    | =Arguments= | =Description= |
    ...    | request_type | Type of shift request: 'open', 'additional', or 'swap'. |
    ...    | requestor_user_key | User key of the associate who initiated the request (e.g., ESS20_STORE15). |
    ...    | shift_week_day | Week-day offset of the shift (e.g., 6_6 for week 6 day 7). |
    ...    | start_time_24_hr | Shift start time in 24-hour format (e.g., 08:00). |
    ...    | end_time_24_hr | Shift end time in 24-hour format (e.g., 16:00). |
    ...    | responder_user_key | (Optional) User key of the nearby associate responding (Required ONLY for 'swap' and 'additional' requests). |
    [Arguments]    ${request_type}    ${requestor_user_key}    ${shift_week_day}    ${start_time_24_hr}    ${end_time_24_hr}    ${responder_user_key}=${None}

    ${req_type_lower}    Evaluate    $request_type.lower()

    IF    $req_type_lower == "open"
        VAR    ${target_list}    ${SM_OPEN_SHIFT_REQUEST_LIST}
    ELSE IF    $req_type_lower == "additional"
        VAR    ${target_list}    ${SM_ADDITIONAL_WORK_REQUEST_LIST}
    ELSE IF    $req_type_lower == "swap"
        VAR    ${target_list}    ${SM_SWAP_SHIFT_REQUEST_LIST}
    ELSE
        Fail    Invalid request_type provided: '${request_type}'. Expected 'open', 'additional', or 'swap'.
    END

    Navigate Calendar To Target Week On SM Schedule Page On Mobile    ${shift_week_day}
    Navigate To Shift Request On SM Mobile
    Select Trade Request On SM Mobile    ${target_list}    ${requestor_user_key}    ${shift_week_day}    ${start_time_24_hr}    ${end_time_24_hr}

    IF    $req_type_lower == "open"
        # Open shift approves the target key directly
        Approve Responder On SM Mobile    ${requestor_user_key}
    ELSE IF    $req_type_lower in ["swap", "additional"]
        # Swap and Additional Work require verifying the relationship between initiator and responder
        IF    $responder_user_key is None
            Fail    For '${request_type}' requests, you must provide a 'responder_user_key'.
        END
        Approve Responder Nearby Location On SM Mobile    ${requestor_user_key}    ${responder_user_key}
    END
