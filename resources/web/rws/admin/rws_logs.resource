*** Settings ***
Documentation       RWS Logs page related keyword implementation for verifying import operations

Resource            resources/web/common/common.resource
Variables           resources/web/rws/admin/rws_logs_page.py
Library             resources/web/common/utility.py
Resource            resources/web/authentication/login.resource


*** Keywords ***
Navigate To RWS Admin RWS Logs Page On Web
    [Documentation]    Navigate to RWS -> Admin -> RWS Logs Page
    ...    and verifies RWS Logs heading at the top of the page
    Navigate To Specific Page On Web    rws    admin    rws_logs

Select Data Type On Logs Page
    [Documentation]    Selects the specified data type from the dropdown on RWS Logs page
    [Arguments]    ${data_type}
    Select Options By    ${RWS_LOGS_PAGE_DATATYPE_DROPDOWN}    text    ${data_type}
    Wait Until Element Is Visible On Webpage    ${RWS_LOGS_PAGE_LOGFILES_DROPDOWN}    timeout=${LONG_PAGE_LOAD_TIMEOUT}

Select Latest Log File By Filter
    [Documentation]
    ...    Selects the latest log file from the dropdown that matches the given filter text.
    ...    Both option retrieval and selection are performed via JavaScript to avoid
    ...    textContent encoding issues with the Browser library.
    ...    Falls back to selecting index 1 if no matching option is found.
    ...    | =Arguments=  | =Description=                                      |
    ...    | filter_text  | Text to filter log files (e.g., file name prefix)  |
    ...
    ...    Example usage:
    ...    | Select Latest Log File By Filter    QA28_B0_STORE2_HRBA_ |
    [Arguments]    ${filter_text}
    Wait Until Element Is Visible On Webpage    ${RWS_LOGS_PAGE_LOGFILES_DROPDOWN}    timeout=${MEDIUM_TIMEOUT}
    TRY
        ${options}=    Get Select Options    ${RWS_LOGS_PAGE_LOGFILES_DROPDOWN}
        Log To Console    Getting log file options from dropdown

        # Filter options containing the specified text
        VAR    @{filtered_options}=    @{EMPTY}
        FOR    ${option}    IN    @{options}
            ${label}=    Get From Dictionary    ${option}    label
            IF    '${filter_text}' in '${label}'
                Append To List    ${filtered_options}    ${label}
            END
        END

        # Get first 14 characters (timestamp) from each filtered option
        VAR    @{timestamp_options}=    @{EMPTY}
        FOR    ${label}    IN    @{filtered_options}
            ${timestamp}=    Get Substring    ${label}    0    14
            Append To List    ${timestamp_options}    ${timestamp}
        END

        # Find the latest timestamp and its corresponding full label
        ${latest_timestamp}=    Evaluate    max($timestamp_options)
        VAR    ${latest_option}=    ${EMPTY}
        FOR    ${label}    IN    @{filtered_options}
            ${current_timestamp}=    Get Substring    ${label}    0    14
            IF    '${current_timestamp}' == '${latest_timestamp}'
                VAR    ${latest_option}=    ${label}
                BREAK
            END
        END

        Log To Console    Selecting latest log file: ${latest_option}
        Wait Until Element Is Visible On Webpage    ${RWS_LOGS_PAGE_LOGFILES_DROPDOWN}    timeout=${MEDIUM_TIMEOUT}
        Select Options By    ${RWS_LOGS_PAGE_LOGFILES_DROPDOWN}    text    ${latest_option}
    EXCEPT
        TRY
            ${js_result}=    Evaluate JavaScript    ${RWS_LOGS_PAGE_LOGFILES_DROPDOWN}
            ...    (selectEl, filterText) => {
            ...        const allOptions = [...selectEl.options].map((o, index) => ({
            ...            label: (o.textContent || '').replace(/[^\x20-\x7E]/g, '').trim(),
            ...            index
            ...        }));
            ...        const filtered = allOptions.filter(o => o.label.includes(filterText));
            ...        if (!filtered.length) {
            ...            return { selected: false, reason: 'No options matched filter: ' + filterText };
            ...        }
            ...        const latest = filtered.reduce((best, curr) =>
            ...            curr.label.slice(0, 14) > best.label.slice(0, 14) ? curr : best
            ...        );
            ...        selectEl.selectedIndex = latest.index;
            ...        selectEl.dispatchEvent(new Event('input', { bubbles: true }));
            ...        selectEl.dispatchEvent(new Event('change', { bubbles: true }));
            ...        return { selected: true, selectedIndex: latest.index, selectedLabel: latest.label };
            ...    }
            ...    ALL    ${filter_text}
            Log    [RWS LOGS] JS selection result: ${js_result}    level=INFO
            Should Be True    ${js_result}[selected]    ${js_result}[reason]
        EXCEPT    AS    ${error}
            Log    [RWS LOGS] Filter selection failed (${error}), falling back to index 1    level=WARN
            Evaluate JavaScript    ${RWS_LOGS_PAGE_LOGFILES_DROPDOWN}
            ...    (selectEl) => {
            ...        if (selectEl.options.length > 1) {
            ...            selectEl.selectedIndex = 1;
            ...            selectEl.dispatchEvent(new Event('input', { bubbles: true }));
            ...            selectEl.dispatchEvent(new Event('change', { bubbles: true }));
            ...        }
            ...    }
        END
    END

Verify New Page Opened
    [Documentation]    Verifies that a new page has opened by comparing page counts
    [Arguments]    ${old_pages}
    ${new_pages}=    Get Page Ids
    ${old_count}=    Get Length    ${old_pages}
    ${new_count}=    Get Length    ${new_pages}
    Should Be True    ${new_count} > ${old_count}    No new page was opened

View And Verify Log File Content
    [Documentation]    Views the log file and verifies its content
    ${old_pages}=    Get Page Ids
    Click Element On Webpage    ${RWS_LOGS_PAGE_VIEW_BTN}
    Wait Until Keyword Succeeds    10x    1s    Verify New Page Opened    ${old_pages}
    ${page_ids}=    Get Page Ids
    ${count}=    Get Length    ${page_ids}
    Log    Page Count: ${count}
    Switch Page    ${page_ids}[0]
    Wait Until Page Is Loaded
    ${current_url}=    Get Url
    Log    Current URL: ${current_url}
    ${old_prefix}=    Set Selector Prefix    ${NONE}
    TRY
        Wait Until Element Is Visible On Webpage    ${RWS_LOGS_PAGE_LOGFILE_DATA}
        ...    timeout=${PAGE_LOAD_TIMEOUT}
        ${properties_text}=    Get Element Text On Webpage    ${RWS_LOGS_PAGE_LOGFILE_DATA}
    FINALLY
        Set Selector Prefix    ${old_prefix}
    END
    ${trimmed_text}=    Strip String    ${properties_text}
    VAR    ${Expected_Pass_Invalid_Count_Zero}=    Invalid : 0
    Should Contain    ${trimmed_text}    ${Expected_Pass_Invalid_Count_Zero}
    ${added_status}=    Run Keyword And Return Status
    ...    Should Not Contain    ${trimmed_text}    Added : 0
    ${updated_status}=    Run Keyword And Return Status
    ...    Should Not Contain    ${trimmed_text}    Updated : 0
    IF    not (${added_status} or ${updated_status})
        Fail    Test failed: Both Added and Updated counts are zero
    END
    Close Page
    ${page_ids}=    Get Page Ids
    ${count}=    Get Length    ${page_ids}
    Log    Page Count: ${count}
    Switch Page    ${page_ids}[0]
    Wait Until Page Is Loaded

Verify HRBA Log Entry On RWS Logs Page
    [Documentation]    Verifies HRBA log entry for the latest file upload
    ...    | =Arguments=    | =Description=    |
    ...    | log_file_name | Name or pattern of the log file to verify    |
    ...
    ...    Example usage:
    ...    | Verify HRBA Log Entry On RWS Logs Page | QA28_B0_STORE2_HRBA_ |
    [Arguments]    ${log_file_name}
    Navigate To RWS Admin RWS Logs Page On Web
    Select Data Type On Logs Page    HR Associate Basic Details Import
    Select Latest Log File By Filter    ${log_file_name}
    View And Verify Log File Content

Verify HRCI Log Entry On RWS Logs Page
    [Documentation]    Verifies HRCI log entry for the latest file upload
    ...    | =Arguments=    | =Description=    |
    ...    | log_file_name | Name or pattern of the log file to verify    |
    ...
    ...    Example usage:
    ...    | Verify HRCI Log Entry On RWS Logs Page | QA28_B0_STORE2_HRCI_ |
    [Arguments]    ${log_file_name}
    Navigate To RWS Admin RWS Logs Page On Web
    Select Data Type On Logs Page    HR Changes Import
    Select Latest Log File By Filter    ${log_file_name}
    View And Verify Log File Content

Verify HRAC Log Entry On RWS Logs Page
    [Documentation]    Verifies HRAC log entry for the latest file upload
    ...    | =Arguments=    | =Description=    |
    ...    | log_file_name | Name or pattern of the log file to verify    |
    ...
    ...    Example usage:
    ...    | Verify HRAC Log Entry On RWS Logs Page | HRAC_2000123 |
    [Arguments]    ${log_file_name}
    ${hrac_upload_data_type}=    Get System Value    RWSUploadDataType    HRAC
    Navigate To RWS Admin RWS Logs Page On Web
    Select Data Type On Logs Page    ${hrac_upload_data_type}
    Select Latest Log File By Filter    ${log_file_name}
    View And Verify Log File Content

Clear HRBA Logs On RWS Logs Page
    [Documentation]    Clears HRBA logs from RWS Logs page
    ...    | =Arguments=    | =Description=    |
    ...    | corp_user_key | Corp user key for login (e.g., SYSADMIN)    |
    ...    | log_file_name | Name or pattern of the log file to clear    |
    ...
    ...    Example usage:
    ...    | Clear HRBA Logs On RWS Logs Page | SYSADMIN | QA28_B0_STORE2_HRBA_ |
    [Arguments]    ${corp_user_key}    ${log_file_name}
    Login And Launch WFM Web App    ${corp_user_key}
    Navigate To RWS Admin RWS Logs Page On Web
    Select Data Type On Logs Page    HR Associate Basic Details Import
    Select Latest Log File By Filter    ${log_file_name}
    Click Element On Webpage    ${RWS_LOGS_PAGE_CLEAR_LOGS_BTN}
    VAR    ${dropdown_text}=    //*[contains(text(),'${log_file_name}')]
    Wait Until Element Disappears On Webpage    ${dropdown_text}    timeout=30s
    Log To Console    HRBA logs cleared successfully
    Close Browser
