*** Settings ***
Documentation       This contains keywords related to Timecard List page

Resource            resources/web/common/common.resource
Variables           resources/web/rta/operations/timecard_list_page.py
Resource            resources/web/common/util_keywords.resource
Library             resources/web/common/utility.py


*** Keywords ***
Navigate To RTA Operations Timecard List Page On Web
    [Documentation]    Navigate To RTA -> Operations -> Timecard List Page
    ...    and verifies timecard list heading at the top of the page
    Navigate To Specific Page On Web    rta    operations    timecard_list

Click On The Associate At Required Index On Timecard List Page On Web
    [Documentation]    This keyword clicks on the associate based on the index provided.
    [Arguments]    ${index}
    ${index}    Evaluate    ${index} + 2
    ${index}    Convert To String    ${index}
    ${timecardlistpage_associate_updated}    Update Locator With Dynamic Values    ${TIMECARDLISTPAGE_ASSOCIATE}    INDEX=${index}
    Click Element On Webpage    ${timecardlistpage_associate_updated}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Go To Notes Tab On Timecard List Page On Web
    [Documentation]    This keyword navigates user to Notes Tab.
    TRY
        Click Element On Webpage    ${TIMECARDLISTPAGE_NOTES_TAB}
        ${notes_table_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${TIMECARDLISTPAGE_DAILY_NOTES_TBL}    timeout=${MEDIUM_TIMEOUT}
        IF    not ${notes_table_visible}
            Click Element On Webpage    ${TIMECARDLISTPAGE_NOTES_TAB}
        END
    EXCEPT
        Skip    Notes tab is not available for the associate.
    END
    Wait Until Element Is Visible On Webpage    ${TIMECARDLISTPAGE_DAILY_NOTES_TBL}
    Capture Screenshot On Webpage

Get Note From The Row In Daily Notes Table On Timecard List Page On Web
    [Documentation]    This keyword gets the notes value from the Note column in Daily Notes Table.
    [Arguments]    ${row_num}
    ${row_num}    Evaluate    ${row_num} + 1
    ${row_num}    Convert To String    ${row_num}
    ${daily_notes_tbl_notes_col_updated}    Update Locator With Dynamic Values
    ...    ${TIMECARDLISTPAGE_DAILY_NOTES_TBL_NOTES_COL}    ROW_NUM=${row_num}
    ${daily_notes_tbl_notes}    Get Element Text On Webpage    ${daily_notes_tbl_notes_col_updated}
    RETURN    ${daily_notes_tbl_notes}

Delete Note In Daily Notes Table At Row Number On Timecard List Page On Web
    [Documentation]    This keyword deletes the note at given row.
    [Arguments]    ${row_num}
    ${row_num}    Evaluate    ${row_num} + 1
    ${row_num}    Convert To String    ${row_num}
    ${daily_notes_tbl_notes_col_updated}    Update Locator With Dynamic Values
    ...    ${TIMECARDLISTPAGE_DAILY_NOTES_TBL_NOTES_COL}    ROW_NUM=${row_num}
    Double Click Element On Webpage    ${daily_notes_tbl_notes_col_updated}
    Clear Textbox On Webpage    ${TIMECARDLISTPAGE_TEXT_AREA_FOR_NOTES}
    Capture Screenshot On Webpage
    Save The Added Note On Timecard List Page On Web
    Verify Notification Message Is Displayed On Timecard List Page On Web

Save The Added Note On Timecard List Page On Web
    [Documentation]    This keyword clicks on Save button to save the added/edited/deleted notes.
    Click Element On Webpage    ${TIMECARDLISTPAGE_SAVE_BTN}

Add Note In Daily Notes Table At Row Number On Timecard List Page On Web
    [Documentation]    This keyword adds the note at given row.
    [Arguments]    ${row_num}    ${notes_txt}
    ${row_num}    Evaluate    ${row_num} + 1
    ${row_num}    Convert To String    ${row_num}
    ${daily_notes_tbl_notes_col_updated}    Update Locator With Dynamic Values
    ...    ${TIMECARDLISTPAGE_DAILY_NOTES_TBL_NOTES_COL}    ROW_NUM=${row_num}
    Double Click Element On Webpage    ${daily_notes_tbl_notes_col_updated}
    Fill Textbox On Webpage    ${TIMECARDLISTPAGE_TEXT_AREA_FOR_NOTES}    ${notes_txt}
    Capture Screenshot On Webpage
    Save The Added Note On Timecard List Page On Web
    Verify Notification Message Is Displayed On Timecard List Page On Web

Verify Notification Message Is Displayed On Timecard List Page On Web
    [Documentation]    This keyword waits and checks if notification is displayed after add/edit/delete action.
    Wait Until Element Is Visible On Webpage    ${TIMECARDLISTPAGE_NOTIFICATION_MESSAGE}
    Capture Screenshot On Webpage

Open The Audit From The Row In Daily Notes Table On Timecard List Page On Web
    [Documentation]    This keyword opens the audit table from the given row in Daily Notes Table
    [Arguments]    ${row_num}
    ${row_num}    Evaluate    ${row_num} + 1
    ${row_num}    Convert To String    ${row_num}
    ${daily_notes_tbl_audit_icon_updated}    Update Locator With Dynamic Values
    ...    ${TIMECARDLISTPAGE_DAILY_NOTES_TBL_AUDIT_ICON}    ROW_NUM=${row_num}
    Click Element On Webpage    ${daily_notes_tbl_audit_icon_updated}
    Wait Until Element Is Visible On Webpage    ${TIMECARDLISTPAGE_AUDIT_TBL_BODY}
    Capture Screenshot On Webpage

Get Row Number With Latest Audit Date/Time On Timecard List Page On Web
    [Documentation]    This keyword returns the row number which has latest audit date/time.
    VAR    @{audit_date_time_list}    ${EMPTY}
    VAR    ${latest_audit_date_index}    ${None}
    ${date_format}    Get Config Value    key=DATE_FORMAT_MMDDYYYY_12HR_TIME
    ${row_length}    Get Element Count    ${TIMECARDLISTPAGE_AUDIT_TBL_BODY}/tr
    FOR    ${row}    IN RANGE    2    ${row_length}+1
        ${audit_date_time}    Get Element Text On Webpage    ${TIMECARDLISTPAGE_AUDIT_TBL_BODY}/tr[${row}]/td[1]
        IF    '${audit_date_time}' != '${EMPTY}'
            Append To List    ${audit_date_time_list}    ${audit_date_time}
        END
    END
    ${audit_date_time_latest}    Find Latest Date    ${audit_date_time_list}    ${date_format}
    FOR    ${row}    IN RANGE    2    ${row_length}+1
        ${audit_date_time}    Get Element Text On Webpage    ${TIMECARDLISTPAGE_AUDIT_TBL_BODY}/tr[${row}]/td[1]
        IF    '${audit_date_time_latest}' == '${audit_date_time}'
            ${latest_audit_date_index}    Evaluate    ${row}-1
            BREAK
        END
    END
    RETURN    ${latest_audit_date_index}

Get Value From Notes Audit Table On Timecard List Page On Web
    [Documentation]    This keyword gets the value from the audit table based on the row number and column header
    [Arguments]    ${row_num}    ${header_txt}
    ${row_num}    Evaluate    ${row_num} + 1
    ${col_num}    Get Column Number From Notes Audit Table With Header Name On Timecard List Page On Web    ${header_txt}
    ${cell_value}    Get Element Text On Webpage    ${TIMECARDLISTPAGE_AUDIT_TBL_BODY}/tr[${row_num}]/td[${col_num}]
    RETURN    ${cell_value}

Get Column Number From Notes Audit Table With Header Name On Timecard List Page On Web
    [Documentation]    This keyword gets the column number for the given header name in notes audit table.
    [Arguments]    ${header_txt}
    VAR    ${col_num}    ${None}
    VAR    ${hdr_found}    False
    ${col_length}    Get Element Count    ${TIMECARDLISTPAGE_AUDIT_TBL_HEADER}/td/div
    FOR    ${itr_col}    IN RANGE    1    ${col_length}+1
        ${col_header_txt}    Get Element Text On Webpage    ${TIMECARDLISTPAGE_AUDIT_TBL_HEADER}/td[${itr_col}]/div
        IF    '${header_txt}' in '${col_header_txt}'
            ${col_num}    Get Variable Value    ${itr_col}
            ${hdr_found}    Evaluate    not ${hdr_found}
            BREAK
        END
    END
    IF    ${hdr_found}
        RETURN    ${col_num}
    ELSE
        Fail    No header found with text ${header_txt} in the notes audit table.
    END

Close Notes Audit Table Window On Timecard List Page On Web
    [Documentation]    This keyword is to close notes audit table window.
    Click Element On Webpage    ${TIMECARDLISTPAGE_AUDIT_TBL_CLOSE_BTN}
    Wait Until Element Disappears On Webpage    ${TIMECARDLISTPAGE_AUDIT_TBL}
    Capture Screenshot On Webpage

Get Note From The Weekly Notes Table On Timecard List Page On Web
    [Documentation]    This keyword gets the note value from the Note column in Weekly Notes Table.
    ${weekly_notes_tbl_notes}    Get Element Text On Webpage    ${TIMECARDLISTPAGE_WEEKLY_NOTES_TBL_NOTES_COL}
    ${weekly_note_normalized}    Evaluate    '${weekly_notes_tbl_notes}'.strip().replace('\u00a0', '').replace('&nbsp;', '').strip()
    RETURN    ${weekly_note_normalized}

Delete Note In Weekly Notes Table On Timecard List Page On Web
    [Documentation]    This keyword deletes the note from Weekly Notes Table.
    Double Click Element On Webpage    ${TIMECARDLISTPAGE_WEEKLY_NOTES_TBL_NOTES_COL}
    Clear Textbox On Webpage    ${TIMECARDLISTPAGE_TEXT_AREA_FOR_NOTES}
    Capture Screenshot On Webpage
    Save The Added Note On Timecard List Page On Web
    Verify Notification Message Is Displayed On Timecard List Page On Web

Open The Audit From The Weekly Notes Table On Timecard List Page On Web
    [Documentation]    This keyword opens the audit table from the Weekly Notes Table
    Click Element On Webpage    ${TIMECARDLISTPAGE_WEEKLY_NOTES_TBL_AUDIT_ICON}
    Wait Until Element Is Visible On Webpage    ${TIMECARDLISTPAGE_AUDIT_TBL_BODY}
    Capture Screenshot On Webpage

Add Note In Weekly Notes Table On Timecard List Page On Web
    [Documentation]    This keyword adds the note in Weekly Notes Table
    [Arguments]    ${notes_txt}
    Double Click Element On Webpage    ${TIMECARDLISTPAGE_WEEKLY_NOTES_TBL_NOTES_COL}
    Fill Textbox On Webpage    ${TIMECARDLISTPAGE_TEXT_AREA_FOR_NOTES}    ${notes_txt}
    Capture Screenshot On Webpage
    Save The Added Note On Timecard List Page On Web
    Verify Notification Message Is Displayed On Timecard List Page On Web

Verify And Validate The Notes Audit Data From The Latest Timestamp On Timecard List Page On Web
    [Documentation]    This keyword verifies and validates the notes audit data from the latest timestamp
    ...    after add/edit/delete action on Daily/Weekly Notes Table.
    [Arguments]    ${expected_action}    ${note_before_edit}    ${note_after_edit}
    ${audit_date_latest_index}    Get Row Number With Latest Audit Date/Time On Timecard List Page On Web
    ${original_note}    Get Value From Notes Audit Table On Timecard List Page On Web    ${audit_date_latest_index}    Original Note
    ${changed_note}    Get Value From Notes Audit Table On Timecard List Page On Web    ${audit_date_latest_index}    Changed Note
    ${action}    Get Value From Notes Audit Table On Timecard List Page On Web    ${audit_date_latest_index}    Action
    Should Be Equal As Strings    ${original_note}    ${note_before_edit}
    Should Be Equal As Strings    ${note_after_edit}    ${changed_note}
    Should Be Equal As Strings    ${action}    ${expected_action}

Verify Daily Note Added At Row Number On Timecard List Page On Web
    [Documentation]    This keyword verifies that the note is added at the given row number.
    ...    | Arguments    | Description    |
    ...    | row_num    | Row number in Daily Notes Table    |
    ...    | expected_daily_note    | Expected note to be verified at the given row number in Daily Notes Table |
    [Arguments]    ${row_num}
    ...    ${expected_daily_note}
    ${note_at_row}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    ${row_num}
    Capture Screenshot On Webpage
    Should Be Equal As Strings    ${note_at_row}    ${expected_daily_note}

Verify Daily Note Empty At Row Number On Timecard List Page On Web
    [Documentation]    This keyword verifies that the note is empty at the given row number in Daily Notes Table.
    [Arguments]    ${row_num}
    ${note_at_row}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    ${row_num}
    ${daily_note_normalized}    Evaluate    '${note_at_row}'.strip().replace('\u00a0', '').replace('&nbsp;', '').strip()
    Capture Screenshot On Webpage
    Should Be Empty    ${daily_note_normalized}    msg=Expected daily note to be empty but found: '${note_at_row}'

Verify Note Added In Weekly Notes On Timecard List Page On Web
    [Documentation]    This keyword verifies that the note is added in Weekly Notes Table.
    ...    | Arguments    | Description    |
    ...    | expected_weekly_note    | Expected note to be verified in Weekly Notes Table    |
    [Arguments]    ${expected_weekly_note}
    ${note_in_weekly}    Get Note From The Weekly Notes Table On Timecard List Page On Web
    Capture Screenshot On Webpage
    Should Be Equal As Strings    ${note_in_weekly}    ${expected_weekly_note}
    ...    msg=Expected weekly note to be: ${expected_weekly_note} but found: ${note_in_weekly}

Verify Weekly Note Empty On Timecard List Page On Web
    [Documentation]    This keyword verifies that the note is empty in Weekly Notes Table.
    ${note_in_weekly}    Get Note From The Weekly Notes Table On Timecard List Page On Web
    ${weekly_note_normalized}    Evaluate    '${note_in_weekly}'.strip().replace('\u00a0', '').replace('&nbsp;', '').strip()
    Capture Screenshot On Webpage
    Should Be Empty    ${weekly_note_normalized}    msg=Expected weekly note to be empty but found: '${note_in_weekly}'

Navigate To Previous Week On Timecard List Page On Web
    [Documentation]    This keyword navigates to the previous week using the left arrow button in header.
    Click Element On Webpage    ${TIMECARDLISTPAGE_HEADER_WEEK_LABEL_PREV_BUTTON}
    ${loading_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${TIMECARDLISTPAGE_PLEASE_WAIT_LOADER}    timeout=${MEDIUM_TIMEOUT}
    IF    ${loading_visible}
        Wait Until Element Disappears On Webpage    ${TIMECARDLISTPAGE_PLEASE_WAIT_LOADER}
    END
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Navigate To Next Week On Timecard List Page On Web
    [Documentation]    This keyword navigates to the next week using the right arrow button in header.
    Click Element On Webpage    ${TIMECARDLISTPAGE_HEADER_WEEK_LABEL_NEXT_BUTTON}
    ${loading_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${TIMECARDLISTPAGE_PLEASE_WAIT_LOADER}    timeout=${MEDIUM_TIMEOUT}
    IF    ${loading_visible}
        Wait Until Element Disappears On Webpage    ${TIMECARDLISTPAGE_PLEASE_WAIT_LOADER}
    END
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Cleanup All Existing Daily And Weekly Notes On Timecard List Page On Web
    [Documentation]    This keyword cleans up all existing notes in Daily and Weekly Notes Table.
    ...    | Arguments    | Description    |
    ...    | previous_weeks_to_iterate    | Number of previous weeks to iterate and clean notes for each week. Default is 1.    |
    [Arguments]    ${previous_weeks_to_iterate}=1
    Go To Notes Tab On Timecard List Page On Web
    # Daily Notes
    FOR    ${row}    IN RANGE    1    8
        ${daily_notes_tbl_notes}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    ${row}
        ${normalized_daily_note}    Evaluate    '${daily_notes_tbl_notes}'.strip().replace('\u00a0', '').replace('&nbsp;', '').strip()
        IF    '${normalized_daily_note}' != '${EMPTY}'
            Delete Note In Daily Notes Table At Row Number On Timecard List Page On Web    ${row}
        END
    END
    # Weekly Notes
    ${weekly_notes_tbl_notes}    Get Note From The Weekly Notes Table On Timecard List Page On Web
    ${normalized_weekly_note}    Evaluate    '${weekly_notes_tbl_notes}'.strip().replace('\u00a0', '').replace('&nbsp;', '').strip()
    IF    '${normalized_weekly_note}' != '${EMPTY}'
        Delete Note In Weekly Notes Table On Timecard List Page On Web
    END
    IF    ${previous_weeks_to_iterate} > 0
        FOR    ${_}    IN    ${previous_weeks_to_iterate}
            Navigate To Previous Week On Timecard List Page On Web
            Wait Until Page Is Loaded
            Go To Notes Tab On Timecard List Page On Web
            # Daily Notes
            FOR    ${row}    IN RANGE    1    8
                ${daily_notes_tbl_notes}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    ${row}
                ${normalized_daily_note}    Evaluate
                ...    '${daily_notes_tbl_notes}'.strip().replace('\u00a0', '').replace('&nbsp;', '').strip()
                IF    '${normalized_daily_note}' != '${EMPTY}'
                    Delete Note In Daily Notes Table At Row Number On Timecard List Page On Web    ${row}
                END
            END
            # Weekly Notes
            ${weekly_notes_tbl_notes}    Get Note From The Weekly Notes Table On Timecard List Page On Web
            ${normalized_weekly_note}    Evaluate
            ...    '${weekly_notes_tbl_notes}'.strip().replace('\u00a0', '').replace('&nbsp;', '').strip()
            IF    '${normalized_weekly_note}' != '${EMPTY}'
                Delete Note In Weekly Notes Table On Timecard List Page On Web
            END
        END
        FOR    ${_}    IN    ${previous_weeks_to_iterate}
            Navigate To Next Week On Timecard List Page On Web
        END
        Wait Until Page Is Loaded
        Go To Notes Tab On Timecard List Page On Web
    END
