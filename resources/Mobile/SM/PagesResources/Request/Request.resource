*** Settings ***
Documentation       This resource contains keywords required for Shift Request and related trade/approval flows in the SM phone app.

Library             DateTime
Library             test_data/TestDataLibrary.py
Resource            resources/Mobile/SM/PagesResources/Common/Localised_Locator.resource
Resource            resources/Mobile/SM/PagesResources/Common/Common.resource
Variables           resources/Mobile/SM/Locators/Request.py
Variables           resources/Mobile/SM/Locators/SM_More.py


*** Keywords ***
Navigate To Request On SM Phone App
    [Documentation]   Navigates to request page on SM phone app.
    ${sm_request_locator}    Get Localised Locator Contains For SM    ${REQUEST_TAB}
    Expect Element    ${sm_request_locator}    visible
    Click Element    ${sm_request_locator}

Click Add Request On SM Phone App
    [Documentation]
    ...    Clicks the *Add Request* (+) button on the SM phone app Request page.
    ...
    ...    The button is known to go *stale* intermittently between the visibility check and the
    ...    actual click on its WebDriver element handle — the Request page recomposes between
    ...    `findElement` calls and the old reference is invalidated. To dodge the race, this
    ...    keyword waits for the element to be visible, snapshots its painted location + size
    ...    while the handle is still attached, and dispatches a *coordinate tap* through the
    ...    platform-native gesture (iOS `mobile: tap`, Android `mobile: clickGesture`).
    ...    Coordinate taps do not reference the element handle and are therefore immune to
    ...    stale-element exceptions.
    ...
    ...    A short retry loop covers the corner case where the element goes stale between the
    ...    visibility wait and the coordinate snapshot itself. Fails with actionable context if
    ...    the snapshot keeps failing across all attempts.
    FOR    ${_}    IN RANGE    3
        Expect Element    ${ADD_REQUEST}    visible
        ${size_status}    ${size}    Run Keyword And Ignore Error    Get Element Size    ${ADD_REQUEST}
        IF    '${size_status}' != 'PASS'    CONTINUE
        ${loc_status}    ${location}    Run Keyword And Ignore Error    Get Element Location    ${ADD_REQUEST}
        IF    '${loc_status}' != 'PASS'    CONTINUE
        ${cx}    Evaluate    int($location['x'] + ($size['width'] / 2))
        ${cy}    Evaluate    int($location['y'] + ($size['height'] / 2))
        IF    '${MOBILE_PLATFORM}' == 'ios'
            Execute Script    mobile: tap    x=${cx}    y=${cy}
        ELSE
            Execute Script    mobile: clickGesture    x=${cx}    y=${cy}
        END
        RETURN
    END
    Fail    Add Request button could not be tapped on SM phone app: element kept going stale across 3 visibility + coordinate-snapshot attempts.

Click Pending Requests On SM Phone App
    [Documentation]   Clicks on pending requests button to view pending requests list on SM phone app.
    ...    This keyword navigates to the pending requests view by locating and clicking the pending requests button.
    Expect Element    ${PENDING_REQUESTS_LIST}    visible
    Click Element    ${PENDING_REQUESTS_LIST}

Apply Filter On Pending Requests List On SM Phone App
    [Documentation]   Applies filter on SM pending requests list view.
    ...    | === Arguments === | === Description === |
    ...    | request_type | Request type to select (e.g., Time Off, Day Off). Optional, defaults to `${None}`. |
    ...    | start_date | Start date in week_day offset format (e.g., 1_4). Optional, defaults to `${None}`. |
    ...    | end_date | End date in week_day offset format (e.g., 1_4). Optional, defaults to `${None}`. |
    ...    | my_reports_type | My Reports filter type to select (Direct, Indirect, or My Location). Optional, defaults to `${None}`. |
    ...    | report_to_associate | User key for Reports to Associate filter. Optional, defaults to `${None}`. |
    ...    | calendar_open_date | The current x_y open date on the calendar. Optional, defaults to `${None}`. |
    [Arguments]    ${request_type}=${None}    ${start_date}=${None}    ${end_date}=${None}    ${my_reports_type}=${None}    ${report_to_associate}=${None}
    ...            ${calendar_open_date}=${None}
    ${filter_button_locator}    Get Localised Locator Contains For SM    ${SM_PENDING_REQUEST_FILTER}
    Wait Until Page Contains Element    ${filter_button_locator}
    Click Element    ${filter_button_locator}

    IF    '${request_type}' != '${None}'
        ${request_type_locator}    Get Localised Locator Contains For SM    ${SM_FILTER_REQUEST_TYPE}

        Wait Until Page Contains Element    ${request_type_locator}
        Click Element    ${request_type_locator}
        ${request_type_value_locator}    Get Locator Contains For SM    ${request_type}
        Wait Until Page Contains Element    ${request_type_value_locator}
        Click Element    ${request_type_value_locator}
    END

    IF    '${start_date}' != '${None}'
        Select Date On SM Calendar    ${EDIT_START_DATE_FIELD}    ${start_date}
    END

    IF    '${end_date}' != '${None}'
        Select Date On SM Calendar    ${EDIT_END_DATE_FIELD}    ${end_date}    ${calendar_open_date}
    END

    IF    '${my_reports_type}' != '${None}'
        Select My Reports Filter Type On Pending Requests List On SM Phone App    ${my_reports_type}
    END

    IF    '${report_to_associate}' != '${None}'
        ${report_to_associate_locator}    Get Localised Locator Contains For SM    ${SM_FILTER_REPORTS_ASSOCIATE}
        Swipe Until Visible    ${report_to_associate_locator}
        Click Element    ${report_to_associate_locator}
        ${associate}    Get User    ${report_to_associate}
        Search And Select Associate Name Page On SM Phone App    ${associate}[displayName]
    END

    ${apply_button_locator}    Get Localised Locator Contains For SM    ${SM_FILTER_APPLY_BUTTON}
    Wait Until Page Contains Element    ${apply_button_locator}
    Click Element    ${apply_button_locator}

Select Day Off Request On SM Phone App
    [Documentation]   Select day off request on SM phone app.
    ${day_off_locator}    Get Localised Locator Contains For SM    ${DAY_OFF}
    Expect Element    ${day_off_locator}    visible
    Click Element    ${day_off_locator}

Select Time Off Request On SM Phone App
    [Documentation]   Select time off request on SM phone app.
    ${time_off_locator}    Get Localised Locator Contains For SM    ${TIME_OFF}
    Wait Until Page Contains Element    ${time_off_locator}
    Click Element    ${time_off_locator}

Request Calendar Navigation On SM Phone App
    [Documentation]   Navigates through calendar on request page of SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | select_date | Date to be selected in week_day offset format (e.g., 1_4) |
    ...    | calendar_open_date | Date on which calendar is opened in week_day offset format (e.g., 1_4). Optional, defaults to current date. |
    [Arguments]    ${select_date}    ${calendar_open_date}=${None}
    ${server_df_format}    Get Config Value    SERVER_DF
    ${full_df_format}    Get Config Value    SM_CALENDAR_COMMON_DF
    Wait Until Page Contains Element    ${CALENDAR_BTN}
    Click Element    ${CALENDAR_BTN}
    IF    '${calendar_open_date}'=='${None}'
        ${calendar_open_date_converted}    Get Current Date    result_format=${server_df_format}
    ELSE
        ${calendar_open_date_converted}    Calculate Date From Week Day Offset    ${calendar_open_date}    ${server_df_format}
    END
    Navigate SM Calendar To    ${select_date}    ${calendar_open_date_converted}
    ${formatted_date}    Calculate Date From Week Day Offset    ${select_date}    ${full_df_format}
    ${formatted_date_locator}    Get Locator Contains For SM    ${formatted_date}
    Wait Until Page Contains Element    ${formatted_date_locator}
    Click Element    ${formatted_date_locator}

Add Day Off Details On SM Phone App
    [Documentation]    Adds day off details on SM phone app.
    [Arguments]    ${associate_name}    ${reason}    ${start_date}=${None}    ${end_date}=${None}    ${status}=${None}    ${requester_note}=${None}    ${approver_note}=${None}
    Master Add Day Off Details On SM Phone App    ${associate_name}    ${reason}    ${start_date}    ${end_date}    ${status}    ${requester_note}    ${approver_note}

Add Day Off Details With Holiday Hours On SM Phone App
    [Documentation]    Adds day off details with holiday hours on SM phone app.
    [Arguments]    ${associate_name}    ${reason}    ${start_date}=${None}    ${end_date}=${None}    ${status}=${None}    ${requester_note}=${None}    ${approver_note}=${None}    ${holiday_hours}=${None}
    Master Add Day Off Details On SM Phone App    ${associate_name}    ${reason}    ${start_date}    ${end_date}    ${status}    ${requester_note}    ${approver_note}    ${holiday_hours}

Master Add Day Off Details On SM Phone App
    [Documentation]   Adds day off details on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Name of the associate for whom the day off request is being made |
    ...    | reason | Reason for the day off request |
    ...    | start_date | Start date of the day off in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | end_date | End date of the day off in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | status | Status of the request (e.g., Pending, Approved). Optional, defaults to NA. |
    ...    | requester_note | Note from the requester. Optional, defaults to NA. |
    ...    | approver_note | Note from the approver. Optional, defaults to NA. |
    ...    | holiday_hours | Holiday hours to be added in case of day off request with holiday hours. Optional, defaults to NA. |
    [Arguments]    ${associate_name}    ${reason}    ${start_date}=${None}    ${end_date}=${None}    ${status}=${None}    ${requester_note}=${None}    ${approver_note}=${None}    ${holiday_hours}=${None}
    Click Add Request On SM Phone App
    Select Day Off Request On SM Phone App
    Expect Element    ${NAME_DROP_DOWN}    visible
    Click Element    ${NAME_DROP_DOWN}
    ${user}    Get User    ${associate_name}
    VAR    ${associate_name}    ${user}[displayName]
    Search And Select Associate Name Page On SM Phone App    ${associate_name}
    Wait Until Page Contains Element    ${REQUEST_REASON_DROP_DOWN}
    Click Element    ${REQUEST_REASON_DROP_DOWN}
    ${reason_locator}    Get Message With Arguments For SM    ${REASON_VALUE}    ${reason}
    Wait Until Page Contains Element    ${reason_locator}
    Click Element    ${reason_locator}
    IF    '${start_date}' != '${None}'
        Select Date On SM Calendar    ${START_DATE_FIELD}    ${start_date}
    END
    IF    '${end_date}' != '${None}'
        Select Date On SM Calendar    ${END_DATE_FIELD}    ${end_date}    ${start_date}
    END
    IF    '${status}' != '${None}'
        Swipe Until Visible    ${REQUEST_STATUS_DROP_DOWN}
        Click Element    ${REQUEST_STATUS_DROP_DOWN}
        ${status_locator}    Get Locator Contains For SM    ${status}
        Wait Until Page Contains Element    ${status_locator}
        Click Element   ${status_locator}
    END
    IF    '${requester_note}' != '${None}'
        Swipe Until Visible    ${REQUESTER_NOTES}
        Click Element    ${REQUESTER_NOTES}
        Wait Until Page Contains Element    ${NOTES_FIELD}
        Input Text    ${NOTES_FIELD}    ${requester_note}
    END
    IF    '${approver_note}' != '${None}'
        Swipe Until Visible    ${APPROVER_NOTES}
        Click Element    ${APPROVER_NOTES}
        Wait Until Page Contains Element    ${NOTES_FIELD}
        Input Text    ${NOTES_FIELD}    ${approver_note}
    END
    IF    $holiday_hours is not None
        IF    $start_date is None
            Fail    start_date is required when holiday_hours is provided
        END
        ${end_date}    Set Variable If    $end_date is None    ${start_date}    ${end_date}
        Wait Until Page Contains Element    ${SM_HOLIDAY_HOURS_BUTTON}
        Click Element    ${SM_HOLIDAY_HOURS_BUTTON}
        ${holiday_hrs_message}    Get Localised Message From Key For SM    1000000001282
        ${final_locator}    Get Message With Arguments For SM    ${SM_HOLIDAY_HOURS_TITLE}    ${holiday_hrs_message}
        Wait Until Page Contains Element    ${final_locator}
        Input Holiday Hours For Date Range On SM Phone App    ${start_date}    ${end_date}    ${holiday_hours}
        Click Element    ${SM_HOLIDAY_HOURS_DONE_BUTTON}
    END
    Wait Until Page Contains Element    ${REQUEST_SUBMIT_BUTTON}
    Click Element    ${REQUEST_SUBMIT_BUTTON}

Input Holiday Hours For Date Range On SM Phone App
    [Documentation]    Inputs holiday hours for each day in a date range into the holiday hours dialog.
    ...    The dialog must already be open before calling this keyword.
    ...    | === Arguments === | === Description === |
    ...    | start_date | Start date in week_day offset format (e.g., 1_3). |
    ...    | end_date | End date in week_day offset format (e.g., 1_5). |
    ...    | holiday_hours | Hours to input. Single value applied to all days, or a dict keyed by day offset (0-6). |
    [Arguments]    ${start_date}    ${end_date}    ${holiday_hours}
    ${start_week}    Evaluate    int("${start_date}".split('_')[0])
    ${start_day}    Evaluate    int("${start_date}".split('_')[1])
    ${end_week}    Evaluate    int("${end_date}".split('_')[0])
    ${end_day}    Evaluate    int("${end_date}".split('_')[1])
    ${is_dict}    Evaluate    isinstance($holiday_hours, dict)
    ${week_label}    Get Localised Message From Key For SM    1000000000303
    ${day_label}    Get Localised Message From Key For SM    1000000000047
    ${end_week_exclusive}    Evaluate    ${end_week} + 1
    FOR    ${week}    IN RANGE    ${start_week}    ${end_week_exclusive}
        ${day_start}    Set Variable If    ${week} == ${start_week}    ${start_day}    ${0}
        ${day_end}    Set Variable If    ${week} == ${end_week}    ${end_day}    ${6}
        ${day_end_exclusive}    Evaluate    ${day_end} + 1
        FOR    ${day}    IN RANGE    ${day_start}    ${day_end_exclusive}
            VAR    ${current_offset}    ${week}_${day}
            ${actual_date_str}    Calculate Date From Week Day Offset    ${current_offset}    %Y-%m-%d
            ${week_text}    Evaluate    (datetime.datetime.strptime("${actual_date_str}", "%Y-%m-%d") - datetime.timedelta(days=${day})).strftime("%m/%d")    modules=datetime
            ${day_index}    Evaluate    ${day} + 1
            ${hours_locator}    Get Message With Arguments For SM    ${SM_HOLIDAY_HRS_DAY_BY_WEEK_TEXT}    ${week_label}    ${week_text}    ${day_label}    ${day_index}
            IF    ${is_dict}
                VAR    ${has_matching_key}    ${False}
                FOR    ${key}    IN    @{holiday_hours.keys()}
                    ${is_matching_day}    Evaluate    str(${key}) == str(${day})
                    IF    ${is_matching_day}
                        ${hours_to_enter}    Get From Dictionary    ${holiday_hours}    ${key}
                        VAR    ${has_matching_key}    ${True}
                        BREAK
                    END
                END
                IF    ${has_matching_key}
                    Wait Until Page Contains Element    ${hours_locator}
                    Clear Text    ${hours_locator}
                    Input Text    ${hours_locator}    ${hours_to_enter}
                END
            ELSE
                Wait Until Page Contains Element    ${hours_locator}
                Clear Text    ${hours_locator}
                Input Text    ${hours_locator}    ${holiday_hours}
            END
        END
    END

Add Time Off Details On SM Phone App
    [Documentation]   Adds time off details on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Name of the associate for whom the time off request is being made |
    ...    | reason | Reason for the time off request |
    ...    | date_time_off | Date of the time off in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | start_time | Start time of the time off in HH:MM format (e.g., 09:00). Optional, defaults to NA. |
    ...    | duration_time | Duration of the time off in HH:MM format (e.g., 04:00). Optional, defaults to NA. |
    ...    | status | Status of the request (e.g., Pending, Approved). Optional, defaults to NA. |
    ...    | requester_note | Note from the requester. Optional, defaults to NA. |
    ...    | approver_note | Note from the approver. Optional, defaults to NA. |
    [Arguments]    ${associate_name}    ${reason}    ${date_time_off}=${None}    ${start_time}=${None}    ${duration_time}=${None}    ${status}=${None}    ${requester_note}=${None}    ${approver_note}=${None}
    Click Add Request On SM Phone App
    Select Time Off Request On SM Phone App
    Wait Until Page Contains Element    ${NAME_DROP_DOWN}
    Click Element    ${NAME_DROP_DOWN}
    ${user}    Get User    ${associate_name}
    VAR    ${associate_name}    ${user}[displayName]
    Search And Select Associate Name Page On SM Phone App    ${associate_name}
    Wait Until Page Contains Element    ${REQUEST_REASON_DROP_DOWN}
    Click Element    ${REQUEST_REASON_DROP_DOWN}
    ${reason_locator}    Get Message With Arguments For SM    ${REASON_VALUE}    ${reason}
    Wait Until Page Contains Element    ${reason_locator}
    Click Element    ${reason_locator}
    IF    '${date_time_off}' != '${None}'
        Select Date On SM Calendar    ${TIME_OFF_DATE_FIELD}    ${date_time_off}
    END
    IF   '${start_time}' != '${None}'
        Wait Until Page Contains Element     ${START_TIME_FIELD}
        Click Element     ${START_TIME_FIELD}
        Select Time On SM Time Picker    ${start_time}
    END
    IF   '${duration_time}' != '${None}'
        Wait Until Page Contains Element     ${DURATION_TIME_FIELD}
        Click Element     ${DURATION_TIME_FIELD}
        Select Duration On Time Picker On SM Phone App    ${duration_time}
    END
    IF    '${status}' != '${None}'
        Swipe Until Visible    ${REQUEST_STATUS_DROP_DOWN}
        Click Element    ${REQUEST_STATUS_DROP_DOWN}
        ${status_locator}    Get Locator Contains For SM    ${status}
        Wait Until Page Contains Element    ${status_locator}
        Click Element   ${status_locator}
    END
    IF    '${requester_note}' != '${None}'
        Swipe Until Visible    ${REQUESTER_NOTES}
        Click Element    ${REQUESTER_NOTES}
        Wait Until Page Contains Element    ${NOTES_FIELD}
        Input Text    ${NOTES_FIELD}    ${requester_note}
        Wait Until Page Contains Element    ${REQUEST_SAVE_BUTTON}
        Click Element    ${REQUEST_SAVE_BUTTON}
    END
    IF    '${approver_note}' != '${None}'
        Swipe Until Visible    ${APPROVER_NOTES}
        Click Element    ${APPROVER_NOTES}
        Wait Until Page Contains Element    ${NOTES_FIELD}
        Input Text    ${NOTES_FIELD}    ${approver_note}
        Wait Until Page Contains Element    ${REQUEST_SAVE_BUTTON}
        Click Element    ${REQUEST_SAVE_BUTTON}
    END
    Wait Until Page Contains Element    ${REQUEST_SUBMIT_BUTTON}
    Click Element    ${REQUEST_SUBMIT_BUTTON}

Search And Select Associate Name Page On SM Phone App
    [Documentation]    Used to search associate name
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Name of the associate to be searched |
    [Arguments]    ${associate_name}
    Wait Until Page Contains Element    ${SEARCH_USER_FIELD}    error=Search icon is not visible on associate roster page
    Click Element    ${SEARCH_USER_FIELD}
    Wait Until Page Contains Element    ${SEARCH_USER_FIELD}
    ...    error=Search textbox is not visible after clicking search icon on associate roster page
    Input Text    ${SEARCH_USER_FIELD}    ${associate_name}
    ${formatted_searched_associate}    Get Message With Arguments For SM    ${SEARCHED_ASSOCIATE}    ${associate_name}
    Wait Until Page Contains Element    ${formatted_searched_associate}
    ...    error=Associate with name ${associate_name} is not visible after searching on associate roster page
    Click Element    ${formatted_searched_associate}

Select Request On SM Phone App
    [Documentation]    Used to select request on request list page of SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | user_key | User unique key from credentials |
    [Arguments]    ${user_key}
    ${user}    Get User    ${user_key}    mask_password=False
    ${request_locator}    Get Message With Arguments For SM    ${REQUEST_LIST}    ${user}[displayName]
    Wait Until Page Contains Element    ${request_locator}
    Click Element    ${request_locator}

Verify Deleted Time Off Request Not Present In List View On SM Phone App
    [Documentation]    Hard assert that a deleted time off request is not visible in SM pending request list view.
    ...    | === Arguments === | === Description === |
    ...    | user_key | User unique key from credentials |
    ...    | request_date | Optional date in week_day offset format (e.g., 4_5) to scope verification to a specific day |
    ...    | request_start_time | Start time (e.g., 09:00). Required when request_date is provided. |
    ...    | request_end_time | End time (e.g., 13:00). Required when request_date is provided. |
    ...    | request_status | Status of request (e.g., Not Reviewed, Approved). Required when request_date is provided. |
    [Arguments]    ${user_key}    ${request_date}    ${request_start_time}    ${request_end_time}    ${request_status}

    ${requestor}    Get User    ${user_key}    mask_password=False
    ${request_date_format}    Get Config Value    FIXED_HYPHEN_DATE_DF
    ${request_date_converted}    Calculate Date From Week Day Offset    ${request_date}    ${request_date_format}
    ${request_date_converted}    Strip Leading Zeros From Date    ${request_date_converted}
    Validate 24 Hour Time Format    ${request_start_time}
    Validate 24 Hour Time Format    ${request_end_time}
    ${start_localised_time}    Format Time String    ${request_start_time}
    ${end_localised_time}    Format Time String    ${request_end_time}
    ${request_locator}    Get Localised Locator Contains For SM    ${SM_TIME_OFF_REQUEST}    ${requestor}[displayName]
    ...    ${request_date_converted}    ${start_localised_time}    ${end_localised_time}    ${request_status}

    Wait Until Keyword Succeeds    30s    2s
    ...    Page Should Not Contain Element
    ...    ${request_locator}
    ...    error=Application did not delete the time off request for ${user_key} on ${request_date} ${request_start_time}-${request_end_time} in SM list view.

Verify Deleted Day Off Request Not Present In List View On SM Phone App
    [Documentation]   Verify deleted day off request is not visible in SM pending request list view.
    ...    | =Arguments= | =Description= |
    ...    | user_key | User unique key from credentials. |
    ...    | requested_date | Day off date in week_day offset format (e.g., 4_5). |
    ...    | request_status | Status of request (e.g., Not Reviewed, Approved). |
    [Arguments]    ${user_key}    ${requested_date}    ${request_status}

    ${requestor}    Get User    ${user_key}    mask_password=False
    ${request_date_format}    Get Config Value    FIXED_HYPHEN_DATE_DF
    ${requested_date_converted}    Calculate Date From Week Day Offset    ${requested_date}    ${request_date_format}
    ${requested_date_converted}    Strip Leading Zeros From Date    ${requested_date_converted}
    ${request_locator}    Get Localised Locator Contains For SM    ${SM_DAY_OFF_REQUEST_SINGLE_DAY}    ${requestor}[displayName]
    ...    ${requested_date_converted}    ${request_status}

    Wait Until Keyword Succeeds    30s    2s
    ...    Page Should Not Contain Element
    ...    ${request_locator}
    ...    error=Application did not delete the day off request for ${user_key} on ${requested_date} in SM list view.

Edit Day Off Details On SM Phone App
    [Documentation]   Edits day off details on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | reason | Reason for the day off request |
    ...    | start_date | Start date of the day off in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | end_date | End date of the day off in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | edit_start_date | New start date to be set on edit in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | edit_end_date | New end date to be set on edit in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | status | Status of the request (e.g., Pending, Approved). Optional, defaults to NA. |
    ...    | approver_note | Note from the approver. Optional, defaults to NA. |
    ...    | holiday_hours | Holiday hours to be updated in case of day off request. Optional, defaults to NA. |
    [Arguments]    ${reason}=${None}    ${start_date}=${None}    ${edit_start_date}=${None}    ${edit_end_date}=${None}    ${status}=${None}    ${approver_note}=${None}    ${holiday_hours}=${None}
    Wait Until Page Contains Element    ${EDIT_BUTTON}
    Click Element    ${EDIT_BUTTON}
    IF    '${reason}' != '${None}'
        Wait Until Page Contains Element    ${EDIT_REQUEST_REASON_DROP_DOWN}
        Click Element    ${EDIT_REQUEST_REASON_DROP_DOWN}
        ${reason_locator}    Get Message With Arguments For SM    ${REASON_VALUE}    ${reason}
        Wait Until Page Contains Element    ${reason_locator}
        Click Element    ${reason_locator}
    END
    IF    '${edit_start_date}' != '${None}'
        Select Date On SM Calendar    ${EDIT_START_DATE_FIELD}    ${edit_start_date}    ${start_date}
    END
    IF    '${edit_end_date}' != '${None}'
        Select Date On SM Calendar    ${EDIT_END_DATE_FIELD}    ${edit_end_date}   ${edit_start_date}
    END
    IF    '${status}' != '${None}'
        Swipe Until Visible    ${EDIT_REQUEST_STATUS_DROP_DOWN}
        Click Element    ${EDIT_REQUEST_STATUS_DROP_DOWN}
        ${status_locator}    Get Locator Contains For SM    ${status}
        Wait Until Page Contains Element    ${status_locator}
        Click Element   ${status_locator}
    END
    IF    '${approver_note}' != '${None}'
        Swipe Until Visible    ${EDIT_APPROVER_NOTE_TEXT}
        Click Element    ${EDIT_APPROVER_NOTE_TEXT}
        Wait Until Page Contains Element    ${NOTES_FIELD}
        Input Text    ${NOTES_FIELD}    ${approver_note}
        Wait Until Page Contains Element    ${REQUEST_SAVE_BUTTON}
        Click Element    ${REQUEST_SAVE_BUTTON}
    END
    IF    $holiday_hours is not None
        ${holiday_start_date}    Set Variable If    '${edit_start_date}' != '${None}'    ${edit_start_date}    ${start_date}
        IF    $holiday_start_date is None
            Fail    start_date or edit_start_date is required when holiday_hours is provided in edit flow
        END
        ${holiday_end_date}    Set Variable If    '${edit_end_date}' != '${None}'    ${edit_end_date}    ${holiday_start_date}
        Wait Until Page Contains Element    ${SM_HOLIDAY_HOURS_BUTTON}
        Click Element    ${SM_HOLIDAY_HOURS_BUTTON}
        ${holiday_hrs_message}    Get Localised Message From Key For SM    1000000001282
        ${final_locator}    Get Message With Arguments For SM    ${SM_HOLIDAY_HOURS_TITLE}    ${holiday_hrs_message}
        Wait Until Page Contains Element    ${final_locator}
        Input Holiday Hours For Date Range On SM Phone App    ${holiday_start_date}    ${holiday_end_date}    ${holiday_hours}
        Click Element    ${SM_HOLIDAY_HOURS_DONE_BUTTON}
    END
    Wait Until Page Contains Element    ${REQUEST_SAVE_BUTTON}
    Click Element    ${REQUEST_SAVE_BUTTON}

Edit Time Off Details On SM Phone App
    [Documentation]   Edits time off details on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | reason | Reason for the time off request |
    ...    | date_time_off | Date of the time off in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | start_time | Start time of the time off in HH:MM format (e.g., 09:00). Optional, defaults to NA. |
    ...    | duration_time | Duration of the time off in hours (e.g., 4). Optional, defaults to NA. |
    ...    | status | Status of the request (e.g., Pending, Approved). Optional, defaults to NA. |
    ...    | approver_note | Note from the approver. Optional, defaults to NA. |
    ...    | calendar_open_date | The current x_y open date on the calendar. |
    [Arguments]    ${reason}=${None}    ${date_time_off}=${None}    ${start_time}=${None}    ${duration_time}=${None}    ${status}=${None}    ${approver_note}=${None}
    ...            ${calendar_open_date}=${None}
    Wait Until Page Contains Element    ${EDIT_BUTTON}
    Click Element    ${EDIT_BUTTON}
    IF    '${reason}' != '${None}'
        Wait Until Page Contains Element    ${EDIT_REQUEST_REASON_DROP_DOWN}
        Click Element    ${EDIT_REQUEST_REASON_DROP_DOWN}
        ${reason_locator}    Get Message With Arguments For SM    ${REASON_VALUE}    ${reason}
        Wait Until Page Contains Element    ${reason_locator}
        Click Element    ${reason_locator}
    END
    IF    '${date_time_off}' != '${None}'
        Select Date On SM Calendar    ${EDIT_TIME_OFF_DATE_FIELD}    ${date_time_off}    ${calendar_open_date}
    END
    IF   '${start_time}' != '${None}'
        Wait Until Page Contains Element     ${EDIT_START_TIME_FIELD}
        Click Element     ${EDIT_START_TIME_FIELD}
        Select Time On SM Time Picker    ${start_time}
    END
    IF   '${duration_time}' != '${None}'
        Wait Until Page Contains Element     ${EDIT_DURATION_TIME_FIELD}
        Click Element     ${EDIT_DURATION_TIME_FIELD}
        Select Duration On Time Picker On SM Phone App    ${duration_time}
    END
    IF    '${status}' != '${None}'
        Swipe Until Visible    ${TIME_OFF_REQUEST_STATUS_DROP_DOWN}
        Click Element    ${TIME_OFF_REQUEST_STATUS_DROP_DOWN}
        ${status_locator}    Get Locator Contains For SM    ${status}
        Wait Until Page Contains Element    ${status_locator}
        Click Element   ${status_locator}
    END
    IF    '${approver_note}' != '${None}'
        Swipe Until Visible    ${EDIT_APPROVER_NOTE_TEXT}
        Click Element    ${EDIT_APPROVER_NOTE_TEXT}
        Wait Until Page Contains Element    ${NOTES_FIELD}
        Input Text    ${NOTES_FIELD}    ${approver_note}
        Wait Until Page Contains Element    ${REQUEST_SAVE_BUTTON}
        Click Element    ${REQUEST_SAVE_BUTTON}
    END
    Wait Until Page Contains Element    ${REQUEST_SAVE_BUTTON}
    Click Element    ${REQUEST_SAVE_BUTTON}

Approve Availability Request On SM Phone App
    [Documentation]   Approves availability request on SM phone app.
    Wait Until Page Contains Element    ${AVAIL_APPROVE_BUTTON}
    Click Element    ${AVAIL_APPROVE_BUTTON}

Decline Availability Request From More Options On SM Phone App
    [Documentation]   Declines availability request on SM phone app.
    ${decline_semantic}    Get Localised Locator Contains For SM    ${SM_REQUEST_DECLINE_OPTION}
    Wait Until Page Contains Element    ${decline_semantic}
    Click Element    ${decline_semantic}

Delete Availability Request On SM Phone App
    [Documentation]   Deletes availability request on SM phone app.
    Wait Until Page Contains Element    ${AVAIL_DELETE_BUTTON}
    Click Element    ${AVAIL_DELETE_BUTTON}
    Wait Until Page Contains Element    ${POSITIVE_CONFIRM_BUTTON}
    Click Element    ${POSITIVE_CONFIRM_BUTTON}

Approve Request On SM Phone App
    [Documentation]   Approves request on SM phone app.
    ${localised_message}    Get Localised Message From Key For SM    ${APPROVE_LOCALISED}
    ${locator}    Get Message With Arguments For SM    ${APPROVE_BUTTON}    ${localised_message}
    Wait Until Page Contains Element    ${locator}
    Click Element    ${locator}
    Click Positive Confirm Button On SM Phone App

Click Positive Confirm Button On SM Phone App
    [Documentation]   Clicks the positive/confirm button on the confirmation popup.
    ${confirm_localised}    Get Localised Message From Key For SM    ${POSITIVE_CONFIRM_LOCALISED}
    ${confirm_locator}    Get Message With Arguments For SM    ${POSITIVE_CONFIRM_BUTTON}    ${confirm_localised}
    Wait Until Page Contains Element    ${confirm_locator}
    Click Element    ${confirm_locator}

Decline Request On SM Phone App
    [Documentation]   Declines request on SM phone app.
    ${localised_message}    Get Localised Message From Key For SM    ${DECLINE_LOCALISED}
    ${locator}    Get Message With Arguments For SM    ${DECLINE_BUTTON}    ${localised_message}
    Wait Until Page Contains Element    ${locator}
    Click Element    ${locator}
    Click Positive Confirm Button On SM Phone App

Delete Request On SM Phone App
    [Documentation]   Deletes request on SM phone app.
    Wait Until Page Contains Element    ${EDIT_BUTTON}
    Click Element    ${EDIT_BUTTON}
    Wait Until Page Contains Element    ${DELETE_BUTTON}
    Click Element    ${DELETE_BUTTON}
    Click Positive Confirm Button On SM Phone App

Verify Day Off Details On SM Phone App
    [Documentation]   Verifies day off details on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | start_date | Start date of the day off in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | end_date | End date of the day off in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | total_days | Total days of the day off. Optional, defaults to NA. |
    ...    | reason | Reason for the day off request. Optional, defaults to NA. |
    ...    | status | Status of the request (e.g., Pending, Approved). Optional, defaults to NA. |
    ...    | requester_note | Note from the requester. Optional, defaults to NA. |
    ...    | approver_note | Note from the approver. Optional, defaults to NA. |
    [Arguments]    ${start_date}=${None}    ${end_date}=${None}    ${total_days}=${None}    ${reason}=${None}    ${status}=${None}
    ...    ${requester_note}=${None}    ${approver_note}=${None}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    IF    '${start_date}' != '${None}'
        ${start_date_converted}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}
        ${start_date_locator}    Get Locator Contains For SM    ${start_date_converted}
        Wait Until Page Contains Element    ${start_date_locator}
    END
    IF    '${end_date}' != '${None}'
        ${end_date_converted}    Calculate Date From Week Day Offset    ${end_date}    ${date_format}
        ${end_date_locator}    Get Locator Contains For SM    ${end_date_converted}
        Wait Until Page Contains Element    ${end_date_locator}
    END
    IF    '${total_days}' != '${None}'
        ${total_days_label}    Get Localised Message From Key For SM    ${SM_REQ_DAY_OFF_TOTAL_DAYS_LABEL}
        VAR    ${total_days_text}    ${total_days} ${total_days_label}
        ${total_days_locator}    Get Message With Arguments For SM    ${SM_REQ_DAY_OFF_TOTAL_DAYS}    ${total_days_text}
        Wait Until Page Contains Element    ${total_days_locator}
    END
    IF    '${status}' != '${None}'
        ${status_locator}    Get Locator Contains For SM    ${status}
        Wait Until Page Contains Element    ${status_locator}
    END
    IF    '${requester_note}' != '${None}'
        ${requester_note_locator}    Get Locator Contains For SM    ${requester_note}
        Wait Until Page Contains Element    ${requester_note_locator}
    END
    IF    '${approver_note}' != '${None}'
        ${approver_note_locator}    Get Locator Contains For SM    ${approver_note}
        Wait Until Page Contains Element    ${approver_note_locator}
    END
    IF    '${reason}' != '${None}'
        ${reason_locator}    Get Locator Contains For SM    ${reason}
        Wait Until Page Contains Element    ${reason_locator}
    END

Verify Holiday Hours Details On SM Phone App
    [Documentation]   Verifies holiday hours details on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | holiday_hours | Holiday hours in case of day off request with holiday hours. Optional, defaults to NA. |
    [Arguments]    ${holiday_hours}
    Wait Until Page Contains Element    ${SM_HOLIDAY_HOURS_BUTTON}
    Click Element    ${SM_HOLIDAY_HOURS_BUTTON}
    ${holiday_hours_display}    Evaluate    str(float($holiday_hours))
    ${hours_locator}    Get Message With Arguments For SM    ${SM_HOLIDAY_HOURS_TOTAL}    ${holiday_hours_display}
    Wait Until Page Contains Element    ${hours_locator}
    Element Text Should Be    ${hours_locator}    ${holiday_hours_display}

Close Holiday Hours Details On SM Phone App
    [Documentation]   Closes holiday hours details on SM phone app.
    Tap Cancel On SM Phone App

Verify Time Off Details On SM Phone App
    [Documentation]   Verifies time off details on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | start_date | Start date of the time off in week_day offset format (e.g., 1_4). Optional, defaults to NA. |
    ...    | reason | Reason for the time off request. Optional, defaults to NA. |
    ...    | status | Status of the request (e.g., Pending, Approved). Optional, defaults to NA. |
    ...    | requester_note | Note from the requester. Optional, defaults to NA. |
    ...    | approver_note | Note from the approver. Optional, defaults to NA. |
    [Arguments]    ${start_date}=${None}    ${reason}=${None}    ${status}=${None}
    ...    ${requester_note}=${None}    ${approver_note}=${None}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    IF    '${start_date}' != '${None}'
        ${start_date_converted}    Calculate Date From Week Day Offset    ${start_date}    ${date_format}
        ${start_date_locator}    Get Value Locator Contains For SM    ${start_date_converted}
        Wait Until Page Contains Element    ${start_date_locator}
    END
    IF    '${status}' != '${None}'
        ${status_locator}    Get Value Locator Contains For SM    ${status}
        Wait Until Page Contains Element    ${status_locator}
    END
    IF    '${requester_note}' != '${None}'
        ${requester_note_locator}    Get Value Locator Contains For SM    ${requester_note}
        Wait Until Page Contains Element    ${requester_note_locator}
    END
    IF    '${approver_note}' != '${None}'
        ${approver_note_locator}    Get Value Locator Contains For SM    ${approver_note}
        Wait Until Page Contains Element    ${approver_note_locator}
    END
    IF    '${reason}' != '${None}'
        ${reason_locator}    Get Value Locator Contains For SM    ${reason}
        Wait Until Page Contains Element    ${reason_locator}
    END

Select Specific Day Off Request On SM Phone App
    [Documentation]   Selects specific day off request on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | request_start_date | Start date of the day off request in week_day offset format (e.g., 1_4) |
    ...    | request_end_date | End date of the day off request in week_day offset format (e.g., 1_4) |
    ...    | request_status | Status of the day off request (e.g., Pending, Approved) |
    ...    | user_key | User raising the day off request |
    [Arguments]    ${user_key}    ${request_start_date}    ${request_end_date}    ${request_status}
    ${requestor}    Get User    ${user_key}    mask_password=False
    ${request_date_format}    Get Config Value    FIXED_HYPHEN_DATE_DF
    ${request_start_date_converted}    Calculate Date From Week Day Offset    ${request_start_date}    ${request_date_format}
    ${request_start_date_converted}    Strip Leading Zeros From Date    ${request_start_date_converted}
    ${request_end_date_converted}    Calculate Date From Week Day Offset    ${request_end_date}    ${request_date_format}
    ${request_end_date_converted}    Strip Leading Zeros From Date    ${request_end_date_converted}
    IF    ${request_start_date}==${request_end_date}
        ${day_off_locator}    Get Localised Locator Contains For SM    ${SM_DAY_OFF_REQUEST_SINGLE_DAY}    ${requestor}[displayName]
        ...    ${request_start_date_converted}    ${request_status}
    ELSE
        ${day_off_locator}    Get Localised Locator Contains For SM    ${SM_DAY_OFF_REQUEST_MULTIPLE_DAYS}    ${requestor}[displayName]
        ...    ${request_start_date_converted}    ${request_end_date_converted}    ${request_status}
    END
    Swipe Until Visible    ${day_off_locator}
    Click Element    ${day_off_locator}

Select Specific Time Off Request On SM Phone App
    [Documentation]   Selects specific time off request on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | request_date | Start date of the time off request in week_day offset format (e.g., 1_4) |
    ...    | request_start_time | Start time of the time off request (e.g., 09:00) |
    ...    | request_end_time | End time of the time off request (e.g., 13:00) |
    ...    | request_status | Status of the time off request (e.g., Not Reviewed, Approved) |
    ...    | user_key | User raising the time off request |
    [Arguments]    ${user_key}    ${request_date}    ${request_start_time}    ${request_end_time}    ${request_status}
    ${requestor}    Get User    ${user_key}    mask_password=False
    ${request_date_format}    Get Config Value    FIXED_HYPHEN_DATE_DF
    ${request_date_converted}    Calculate Date From Week Day Offset    ${request_date}    ${request_date_format}
    ${request_date_converted}    Strip Leading Zeros From Date    ${request_date_converted}
    Validate 24 Hour Time Format    ${request_start_time}
    Validate 24 Hour Time Format    ${request_end_time}
    ${start_localised_time}    Format Time String    ${request_start_time}
    ${end_localised_time}    Format Time String    ${request_end_time}
    ${time_off_locator}    Get Localised Locator Contains For SM    ${SM_TIME_OFF_REQUEST}    ${requestor}[displayName]
    ...    ${request_date_converted}    ${start_localised_time}    ${end_localised_time}    ${request_status}
    Swipe Until Visible    ${time_off_locator}
    Click Element    ${time_off_locator}

Select More Options Of Specific Permanent Availability Request On SM Phone App
    [Documentation]   Selects more options of specific permanent availability request on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | request_day | Day of the request (e.g., Monday, Tuesday) |
    ...    | request_status | Status of the request (e.g., Not Reviewed, Approved) |
    ...    | user_key | User raising the request |
    [Arguments]    ${user_key}    ${request_date}    ${request_status}
    ${requestor}    Get User    ${user_key}    mask_password=False
    ${more_drop_down_semantic}    Get Localised Message From Key For SM    ${SM_DROPDOWN_MORE_OPTIONS}
    ${list_item_semantic}    Get Localised Message From Key For SM    ${SM_PERMANENT_AVAILABILITY_REQUEST}
    ${date_format}    Get Config Value    FIXED_HYPHEN_DATE_DF
    ${week_start_date}    Calculate Week Start Date From Week Day Offset    ${request_date}    ${date_format}
    ${week_start_date}    Strip Leading Zeros From Date    ${week_start_date}
    ${final_list_item_semantic}    Get Message With Arguments For SM    ${list_item_semantic}    ${requestor}[displayName]    ${week_start_date}    ${request_status}
    ${temp_avail_locator}    Get Message With Arguments For SM    {0} {1}    ${final_list_item_semantic}    ${more_drop_down_semantic}
    ${final_locator}    Get Locator Contains For SM    ${temp_avail_locator}
    Swipe Until Visible    ${final_locator}
    Click Element    ${final_locator}

Select Specific Permanent Availability Request On SM Phone App
    [Documentation]   Selects specific permanent availability request on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | request_date | Date of the request in week_day offset format (e.g., 1_4) |
    ...    | request_status | Status of the request (e.g., Not Reviewed, Approved) |
    ...    | user_key | User raising the availability request |
    [Arguments]    ${user_key}    ${request_date}    ${request_status}
    ${requestor}    Get User    ${user_key}    mask_password=False
    ${date_format}    Get Config Value    FIXED_HYPHEN_DATE_DF
    ${week_start_date}    Calculate Week Start Date From Week Day Offset    ${request_date}    ${date_format}
    ${week_start_date}    Strip Leading Zeros From Date    ${week_start_date}
    ${perm_avail_locator}    Get Localised Locator Contains For SM    ${SM_PERMANENT_AVAILABILITY_REQUEST}
    ...    ${requestor}[displayName]    ${week_start_date}    ${request_status}
    Swipe Until Visible    ${perm_avail_locator}
    Click Element    ${perm_avail_locator}

Select More Options Of Specific Temporary Availability Request On SM Phone App
    [Documentation]   Selects more options of specific temporary availability request on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | request_day | Day of the request (e.g., Monday, Tuesday) |
    ...    | request_status | Status of the request (e.g., Not Reviewed, Approved) |
    ...    | user_key | User raising the request |
    [Arguments]    ${user_key}    ${request_date}    ${request_status}
    ${requestor}    Get User    ${user_key}    mask_password=False
    ${more_drop_down_semantic}    Get Localised Message From Key For SM    ${SM_DROPDOWN_MORE_OPTIONS}
    ${list_item_semantic}    Get Localised Message From Key For SM    ${SM_TEMPORARY_AVAILABILITY_REQUEST}
    ${date_format}    Get Config Value    FIXED_HYPHEN_DATE_DF
    ${week_start_date}    Calculate Week Start Date From Week Day Offset    ${request_date}    ${date_format}
    ${week_start_date}    Strip Leading Zeros From Date    ${week_start_date}
    ${final_list_item_semantic}    Get Message With Arguments For SM    ${list_item_semantic}    ${requestor}[displayName]    ${week_start_date}    ${request_status}
    ${temp_avail_locator}    Get Message With Arguments For SM    {0} {1}    ${final_list_item_semantic}    ${more_drop_down_semantic}
    ${final_locator}    Get Locator Contains For SM    ${temp_avail_locator}
    Swipe Until Visible    ${final_locator}
    Click Element    ${final_locator}

Select Specific Temporary Availability Request On SM Phone App
    [Documentation]   Selects specific temporary availability request on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | request_date | Date of the request in week_day offset format (e.g., 1_4) |
    ...    | request_status | Status of the request (e.g., Not Reviewed, Approved) |
    ...    | user_key | User raising the request |
    [Arguments]    ${user_key}    ${request_date}    ${request_status}
    ${requestor}    Get User    ${user_key}    mask_password=False
    ${date_format}    Get Config Value    FIXED_HYPHEN_DATE_DF
    ${week_start_date}    Calculate Week Start Date From Week Day Offset    ${request_date}    ${date_format}
    ${week_start_date}    Strip Leading Zeros From Date    ${week_start_date}
    ${temp_avail_locator}    Get Localised Locator Contains For SM    ${SM_TEMPORARY_AVAILABILITY_REQUEST}
    ...    ${requestor}[displayName]    ${week_start_date}    ${request_status}
    Swipe Until Visible    ${temp_avail_locator}
    Click Element    ${temp_avail_locator}

Verify Snackbar Is Visible On SM Phone App
    [Documentation]    Verifies that the snackbar is visible on the mobile app.
    ...    | =Arguments=    | =Description=    |
    ...    | ${timeout}    | Maximum wait time for snackbar visibility.    |
    [Arguments]    ${timeout}=10s
    Wait Until Page Contains Element    ${SM_CROSS_DAY_ERROR_SNACKBAR_TITLE}    timeout=${timeout}

Open More Actions Navigation Drawer On SM Phone App
    [Documentation]    Opens the more actions navigation drawer on SM phone app.
    ${more_options_drawer_locator}    Get Localised Locator Contains For SM    ${SM_MORE_OPTIONS_ARROW}
    Wait Until Page Contains Element    ${more_options_drawer_locator}
    Click Element    ${more_options_drawer_locator}

Decline Request From More Actions Navigation Drawer On SM Phone App
    [Documentation]    Declines request from more actions navigation drawer on SM phone app.
    ${decline_request_locator}    Get Localised Locator Contains For SM    ${SM_DECLINE_REQUEST_LABEL}
    Wait Until Page Contains Element    ${decline_request_locator}
    Click Element    ${decline_request_locator}

Navigate Back From Request Details On SM Phone App
    [Documentation]    Navigates back on mobile SM app by tapping on back arrow.
    Wait Until Element Is Visible    ${SM_REQUEST_DETAILS_BACK_BUTTON}
    Click Element    ${SM_REQUEST_DETAILS_BACK_BUTTON}

Select Dropdown For Specific Day Off Request On SM Phone App
    [Documentation]   Selects specific day off request dropdown on SM phone app.
    ...    | === Arguments === | === Description === |
    ...    | request_start_date | Start date of the day off request in week_day offset format (e.g., 1_4) |
    ...    | request_end_date | End date of the day off request in week_day offset format (e.g., 1_4) |
    ...    | request_status | Status of the day off request (e.g., Pending, Approved) |
    ...    | user_key | User raising the day off request |
    [Arguments]    ${user_key}    ${request_start_date}    ${request_end_date}    ${request_status}
    ${requestor}    Get User    ${user_key}    mask_password=False
    ${request_date_format}    Get Config Value    FIXED_HYPHEN_DATE_DF
    ${request_start_date_converted}    Calculate Date From Week Day Offset    ${request_start_date}    ${request_date_format}
    ${request_start_date_converted}    Strip Leading Zeros From Date    ${request_start_date_converted}
    ${request_end_date_converted}    Calculate Date From Week Day Offset    ${request_end_date}    ${request_date_format}
    ${request_end_date_converted}    Strip Leading Zeros From Date    ${request_end_date_converted}
    IF    ${request_start_date}==${request_end_date}
        ${day_off_locator}    Get Localised Locator Contains For SM    ${SM_DAY_OFF_REQUEST_SINGLE_DAY_DROPDOWN}    ${requestor}[displayName]
        ...    ${request_start_date_converted}    ${request_status}
    ELSE
        ${day_off_locator}    Get Localised Locator Contains For SM    ${SM_DAY_OFF_REQUEST_MULTIPLE_DAYS_DROPDOWN}    ${requestor}[displayName]
        ...    ${request_start_date_converted}    ${request_end_date_converted}    ${request_status}
    END
    Swipe Until Visible    ${day_off_locator}
    Click Element    ${day_off_locator}

Select My Reports Filter Type On Pending Requests List On SM Phone App
    [Documentation]    Selects a specific My Reports filter type on pending requests list.
    ...    | === Arguments === | === Description === |
    ...    | filter_type | Filter type to select (Direct, Indirect, or My Location). |
    [Arguments]    ${filter_type}
    ${my_reports_locator}    Get Localised Locator Contains For SM    ${SM_FILTER_MY_REPORTS}
    Wait Until Page Contains Element    ${my_reports_locator}
    Click Element    ${my_reports_locator}
    ${normalized_filter_type}    Evaluate    str($filter_type).strip().lower()
    IF    '${normalized_filter_type}' == 'direct'
        VAR    ${filter_type_key}    ${SM_FILTER_MY_REPORTS_DIRECT}
    ELSE IF    '${normalized_filter_type}' == 'indirect'
        VAR    ${filter_type_key}    ${SM_FILTER_MY_REPORTS_INDIRECT}
    ELSE IF    '${normalized_filter_type}' == 'my location'
        VAR    ${filter_type_key}    ${SM_FILTER_MY_REPORTS_MY_LOCATION}
    ELSE
        Fail    Unsupported my_reports_type '${filter_type}'. Use Direct, Indirect, or My Location.
    END
    ${filter_type_locator}    Get Localised Locator Contains For SM    ${filter_type_key}
    Wait Until Page Contains Element    ${filter_type_locator}
    Click Element    ${filter_type_locator}
