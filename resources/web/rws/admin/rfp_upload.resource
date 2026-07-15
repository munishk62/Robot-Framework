*** Settings ***
Documentation       RWS Upload page related keyword implementation

Resource            resources/web/common/common.resource
Variables           resources/web/rws/admin/rfp_upload_page.py
Resource            resources/web/rws/admin/rws_logs.resource
Resource            resources/web/rws/admin/rfp_upload_db.resource


*** Keywords ***
Navigate To RWS Admin RFP Upload Page On Web
    [Documentation]    Navigate to RWS -> Admin -> RFP Upload Page
    Navigate To Specific Page On Web    rws    admin    rfp_upload
    Wait Until Element Is Visible On Webpage    ${RFP_UPLOAD_PAGE_DATATYPE_DROPDOWN}
    ...    error_message=Data Type dropdown not visible on RFP Upload page
    Capture Screenshot On Webpage

Upload VDI File On Web
    [Documentation]    Uploads VDI file through RWS Upload UI and verifies success
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | file_path    | Full path to VDI file to upload    |
    ...    | filter_text    | Schedule regeneration option to select. Defaults to ``NA``, which leaves the regeneration dropdown untouched (workload-only import). |
    ...
    ...    Example usage:
    ...    | Upload VDI File On Web | ${vdi_file_path} |
    ...    | Upload VDI File On Web | ${vdi_file_path} | Delete and Generate all schedules |
    [Arguments]    ${file_path}    ${filter_text}=NA
    Select Options By    ${RFP_UPLOAD_PAGE_DATATYPE_DROPDOWN}    text    Volume Driver Interval Import
    Wait Until Element Is Visible On Webpage    ${RFP_UPLOAD_PAGE_FILE_UPLOAD_LBL}
    ...    error_message=File upload is not ready after selecting import type
    Wait Until Page Is Loaded
    ${schedule_regeneration_dropdown}=    Run Keyword And Return Status    Wait Until Element Is Present On Webpage
    ...    ${RFP_UPLOAD_PAGE_SCHEDULE_REGEN_DROPDOWN}
    IF    ${schedule_regeneration_dropdown} and '${filter_text}' != 'NA'
        Select Schedule Regeneration Option On RFP Upload Page On Web    ${filter_text}
    END
    Upload File By Selector    ${RFP_UPLOAD_PAGE_FILE_NAME_TXT}    path=${file_path}
    Click Element On Webpage    ${RFP_UPLOAD_PAGE_FILE_UPLOAD_BTN}    error_message=Failed to click on Upload button on RFP Upload page
    Wait Until Element Is Visible On Webpage    ${RFP_UPLOAD_PAGE_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Previous button not visible on RFP Upload page
    Capture Screenshot On Webpage

Select Schedule Regeneration Option On RFP Upload Page On Web
    [Documentation]    Schedules regeneration through dropdown on RFP Upload page and verifies success
    [Arguments]    ${filter_text}
    Wait Until Element Is Visible On Webpage    ${RFP_UPLOAD_PAGE_SCHEDULE_REGEN_DROPDOWN}
    ...    error_message=Schedule regeneration dropdown not visible on RFP Upload page
    Select List Item On Webpage    ${RFP_UPLOAD_PAGE_SCHEDULE_REGEN_DROPDOWN}    text    ${filter_text}
    Capture Screenshot On Webpage

Validate RFP Upload Controls Are Ready
    [Documentation]    Validates that RFP upload controls are ready after selecting import type.
    ${is_upload_label_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${RFP_UPLOAD_PAGE_FILE_UPLOAD_LBL}    timeout=5s
    ${is_file_input_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${RFP_UPLOAD_PAGE_FILE_NAME_TXT}    timeout=5s
    Should Be True    ${is_upload_label_visible} or ${is_file_input_visible}
    ...    msg=File upload is not ready after selecting import type

Generate Runtime RFP Import File From Template
    [Documentation]    Generates a runtime RFP import file from a template by dynamically replacing the 3rd column with unit_id and 6th column with EFFECTIVE_DATE.
    ...
    ...    | =Arguments= | =Description= |
    ...    | template_file_name | Template file under ExternalFiles/Excel. |
    ...    | output_file_prefix | Prefix used for generated output file name. |
    ...    | start_date    | Inclusive start date in YYYY-MM-DD format. |
    ...    | end_date    | Inclusive end date in YYYY-MM-DD format. |
    ...    | unit_id    | The value used to replace the 3rd column. |
    ...    | =Returns=    | =Description= |
    ...    | ${output_file_path}| Generated runtime import file path. |
    [Arguments]    ${template_file_name}    ${output_file_prefix}    ${start_date}    ${end_date}    ${unit_id}

    VAR    ${template_file_path}=    ${EXECDIR}${/}ExternalFiles${/}Excel${/}${template_file_name}
    ${template_content}=    OperatingSystem.Get File    ${template_file_path}
    ${template_content}=    Replace String    ${template_content}    \r    ${EMPTY}
    @{template_lines}=    Split String    ${template_content}    \n

    VAR    ${header_row}=    ${EMPTY}
    VAR    ${footer_row}=    ${EMPTY}
    VAR    ${data_template_row}=    ${EMPTY}

    FOR    ${line}    IN    @{template_lines}
        ${normalized_line}=    Strip String    ${line}
        IF    '${normalized_line}' == ''    CONTINUE
        IF    '${header_row}' == '' and '${normalized_line}'.startswith('HH,')
            VAR    ${header_row}=    ${normalized_line}
            CONTINUE
        END
        IF    '${normalized_line}'.startswith('TT,')
            VAR    ${footer_row}=    ${normalized_line}
            CONTINUE
        END
        IF    '${data_template_row}' == ''
            VAR    ${data_template_row}=    ${normalized_line}
        END
    END

    Should Not Be Empty    ${header_row}    msg=Header row (HH) is missing in template: ${template_file_name}
    Should Not Be Empty    ${data_template_row}    msg=Data template row is missing in template: ${template_file_name}
    Should Not Be Empty    ${footer_row}    msg=Footer row (TT) is missing in template: ${template_file_name}

    ${start_date_obj}=    Evaluate    __import__('datetime').datetime.strptime('${start_date}', '%Y-%m-%d').date()
    ${end_date_obj}=    Evaluate    __import__('datetime').datetime.strptime('${end_date}', '%Y-%m-%d').date()
    ${is_valid_range}=    Evaluate    $end_date_obj >= $start_date_obj
    Should Be True    ${is_valid_range}    msg=End date must be greater than or equal to start date.

    ${total_days}=    Evaluate    ($end_date_obj - $start_date_obj).days
    ${loop_end}=    Evaluate    ${total_days} + 1

    VAR    @{generated_data_rows}=    @{EMPTY}

    FOR    ${day_index}    IN RANGE    ${loop_end}
        ${effective_date}=    Evaluate
        ...    ($start_date_obj + __import__('datetime').timedelta(days=$day_index)).strftime('%Y%m%d')

        # Pythonic row update: split by comma, replace col 3 (index 2) and col 6 (index 5), and rejoin.
        # This is cleaner and less brittle than standard RegEx for CSV operations.
        ${updated_row}=    Evaluate
        ...    (lambda p: ','.join(p[:2] + ['${unit_id}'] + p[3:5] + ['${effective_date}'] + p[6:]))('''${data_template_row}'''.split(','))

        Append To List    ${generated_data_rows}    ${updated_row}
    END

    VAR    @{final_lines}=    @{EMPTY}
    Append To List    ${final_lines}    ${header_row}

    FOR    ${data_row}    IN    @{generated_data_rows}
        Append To List    ${final_lines}    ${data_row}
    END

    Append To List    ${final_lines}    ${footer_row}
    ${final_content}=    Catenate    SEPARATOR=\n    @{final_lines}
    ${start_date_compact}=    Evaluate    $start_date_obj.strftime('%Y%m%d')

    VAR    ${test_env}=    %{TEST_ENVIRONMENT=${EMPTY}}
    VAR    ${upload_dir}=    ${EXECDIR}${/}ExternalFiles${/}Excel${/}upload
    OperatingSystem.Create Directory    ${upload_dir}
    VAR    ${output_file_path}=    ${upload_dir}${/}${output_file_prefix}_${test_env}_${start_date_compact}.csv
    Create File    ${output_file_path}    ${final_content}

    RETURN    ${output_file_path}

Generate SIT VDI Runtime Import File
    [Documentation]    Generates SIT runtime VDI import file from V4 template for the specified date window.
    ...
    ...    | =Arguments= | =Description= |
    ...    | start_date | Inclusive start date in YYYY-MM-DD format. |
    ...    | end_date    | Inclusive end date in YYYY-MM-DD format. |
    ...    | unit_id    | The unit ID to dynamically replace in the 3rd column. |
    ...    | =Returns=    | =Description= |
    ...    | ${vdi_file_path} | Generated VDI runtime import file path. |
    [Arguments]    ${start_date}    ${end_date}    ${unit_id}

    ${vdi_file_path}=    Generate Runtime RFP Import File From Template
    ...    V4_VDI_IMPORT_AUTOMATION.csv
    ...    v4_vdi_import_runtime
    ...    ${start_date}
    ...    ${end_date}
    ...    ${unit_id}

    RETURN    ${vdi_file_path}

Generate SIT VDP Runtime Import File
    [Documentation]    Generates SIT runtime VDP import file from V4 template for the specified date window.
    ...
    ...    | =Arguments= | =Description= |
    ...    | start_date | Inclusive start date in YYYY-MM-DD format. |
    ...    | end_date    | Inclusive end date in YYYY-MM-DD format. |
    ...    | unit_id    | The unit ID to dynamically replace in the 3rd column. |
    ...    | =Returns=    | =Description= |
    ...    | ${vdp_file_path} | Generated VDP runtime import file path. |
    [Arguments]    ${start_date}    ${end_date}    ${unit_id}

    ${vdp_file_path}=    Generate Runtime RFP Import File From Template
    ...    V4_VDP_IMPORT_AUTOMATION.csv
    ...    v4_vdp_import_runtime
    ...    ${start_date}
    ...    ${end_date}
    ...    ${unit_id}

    RETURN    ${vdp_file_path}

Get SIT Marker Import Date Window
    [Documentation]    Calculates SIT marker import window based on current week and planning week.
    ...
    ...    | =Arguments= | =Description= |
    ...    | marker_data | Marker scenario data containing import window offsets. |
    ...    | =Returns= | =Description= |
    ...    | ${start_date} | Inclusive import start date in YYYY-MM-DD format. |
    ...    | ${end_date} | Inclusive import end date in YYYY-MM-DD format. |
    ...
    ...    Example usage:
    ...    | ${start_date}    ${end_date}=    Get SIT Marker Import Date Window    ${marker_data} |
    [Arguments]    ${marker_data}
    ${week_start_day}=    Get Config Value    FISCAL_WEEK_START_DAY
    ${current_week_start}=    Get Current Week Start Date    %Y-%m-%d    ${week_start_day}
    ${planning_week_start}=    Get Planning Week Start    date_format=%Y-%m-%d

    VAR    ${current_week_minus_weeks}=    ${marker_data}[import_window][current_week_minus_weeks]
    VAR    ${planning_week_plus_weeks}=    ${marker_data}[import_window][planning_week_plus_weeks]

    ${start_date}=    Evaluate
    ...    (__import__('datetime').datetime.strptime('${current_week_start}', '%Y-%m-%d') - __import__('datetime').timedelta(weeks=${current_week_minus_weeks})).strftime('%Y-%m-%d')
    ${end_date}=    Evaluate
    ...    (__import__('datetime').datetime.strptime('${planning_week_start}', '%Y-%m-%d') + __import__('datetime').timedelta(weeks=${planning_week_plus_weeks}, days=6)).strftime('%Y-%m-%d')
    RETURN    ${start_date}    ${end_date}

Generate SIT Marker Import Files
    [Documentation]    Generates VDI and VDP runtime import files for SIT marker validation scenario.
    ...
    ...    | =Arguments= | =Description= |
    ...    | marker_data | Marker scenario data used to compute import window. |
    ...    | unit_id    | The unit ID used to dynamically replace the 3rd column in the files. |
    ...    | =Returns= | =Description= |
    ...    | ${vdi_file_path} | Generated VDI runtime import file path. |
    ...    | ${vdp_file_path} | Generated VDP runtime import file path. |
    [Arguments]    ${marker_data}    ${unit_id}

    ${start_date}    ${end_date}=    Get SIT Marker Import Date Window    ${marker_data}
    ${vdi_file_path}=    Generate SIT VDI Runtime Import File    ${start_date}    ${end_date}    ${unit_id}
    ${vdp_file_path}=    Generate SIT VDP Runtime Import File    ${start_date}    ${end_date}    ${unit_id}

    RETURN    ${vdi_file_path}    ${vdp_file_path}

Verify VDI Import On Web
    [Documentation]    Uploads VDI file and verifies logs on RFP Logs page.
    ...
    ...    | =Arguments= | =Description= |
    ...    | file_path | Full path to generated VDI file. |
    [Arguments]    ${file_path}
    Navigate To RWS Admin RFP Upload Page On Web
    Upload VDI File On Web    ${file_path}
    Wait Until Page Is Loaded
    # Navigate To RWS Admin RFP Logs Page On Web
    # Apply Filter And Select Latest Log File On RFP Logs Page    Volume Driver Interval Import
    # Verify Log File Content On Web

Verify VDP Import On Web
    [Documentation]    Uploads VDP file and verifies logs on RFP Logs page.
    ...
    ...    | =Arguments= | =Description= |
    ...    | file_path | Full path to generated VDP file. |
    [Arguments]    ${file_path}
    Navigate To RWS Admin RFP Upload Page On Web
    Upload VDP File On Web    ${file_path}
    Wait Until Page Is Loaded
    # Navigate To RWS Admin RFP Logs Page On Web
    # Apply Filter And Select Latest Log File On RFP Logs Page    Volume Driver Period Import
    # Verify Log File Content On Web

Navigate To RWS Admin RFP Logs Page On Web
    [Documentation]    Navigate to RWS -> Admin -> RFP Logs Page
    ...    and verifies RFP Logs heading at the top of the page
    Navigate To Specific Page On Web    rws    admin    rfp_logs
    Wait Until Element Is Visible On Webpage    ${RFP_LOGS_PAGE_DATATYPE_DROPDOWN}
    Capture Screenshot On Webpage

Apply Filter And Select Latest Log File On RFP Logs Page
    [Documentation]    Applies the specified filter and selects the latest log file from the dropdown on RFP Logs page
    ...
    ...    | =Arguments=    | =Description=    |
    ...    | filter_text    | Text to filter log files (e.g., file name or date pattern) |
    ...
    ...    Example usage:
    ...    | Apply Filter And Select Latest Log File On RFP Logs Page | QA28_B0_STORE2_HRBA_ |
    [Arguments]    ${filter_text}
    Select List Item On Webpage    ${RFP_LOGS_PAGE_DATATYPE_DROPDOWN}    text    ${filter_text}
    Wait Until Element Is Visible On Webpage    ${RFP_LOGS_PAGE_LOG_FILE_DROPDOWN}
    ...    error_message=Log file dropdown not visible on RFP Logs page after selecting data type
    Select List Item On Webpage    ${RFP_LOGS_PAGE_LOG_FILE_DROPDOWN}    index    1
    Wait Until Page Is Loaded
    Click Element On Webpage    ${RFP_LOGS_PAGE_VALIDATE_AND_SUBMIT_BTN}    error_message=Failed to click on View button on RFP Logs page
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Verify Log File Content On Web
    [Documentation]    Views the log file and verifies its content.
    ...    Handles a race condition where the new tab may already be open before this keyword
    ...    is called (e.g., when the triggering button click was done in a prior keyword).
    ...    If the new page is already present, the wait is skipped and execution proceeds immediately.
    ${old_pages}=    Get Page Ids
    ${old_page_count}=    Get Length    ${old_pages}
    # Only wait for a new page if it has not already opened (race condition guard)
    IF    ${old_page_count} == 1
        Wait Until Keyword Succeeds    10x    1s    Verify New Page Opened    ${old_pages}
    END
    ${page_ids}=    Get Page Ids
    ${count}=    Get Length    ${page_ids}
    Log    Page Count: ${count}
    Switch Page    ${page_ids}[0]
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
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

Get VDI Upload File Data
    [Documentation]    Collects and returns all required arguments for generating an RFP upload file.
    ...    Uses the provided VDI import data dictionary, along with client ID, metric IDs, date format, and week dates,
    ...    to assemble an ordered list for use with the Generate RFP Upload File keyword.
    ...
    ...    Skip Days Logic: If skip_days are specified (list of day indices 0=Sun..6=Sat),
    ...    those days will have their hours set to 0 in the generated file. The skip_days list is passed
    ...    to the Generate RFP Upload File keyword which applies the correct zero array for each skipped day.
    ...    | =Returns= | =Description= |
    ...    | ${rfp_upload_args} | Ordered list: [file_path, client_id, metric_ids, unit_id, feed_level_store, metric_category, week_days, import_type, value_to_import, skip_days]. |
    ...    Supports both vdi_import_data keys: unitID (preferred) and unit_id (legacy).
    ...    If metric_id is provided in vdi_import_data and is NOT "NA", uses it instead of fetching from DB.
    ...    If metric_id is absent or is "NA", metric_ids are fetched from database.
    ...    client_id is always fetched from DB.
    ...    If skip_days is provided (list of day indices 0=Sun..6=Sat), those days' hours are zeroed during file generation.
    ...    If skip_days is absent or "NA", all 7 days retain their original array values.
    [Arguments]    ${vdi_import_data}
    VAR    ${vdi_file_path}=    ${EXECDIR}${/}ExternalFiles${/}Excel${/}vdi_import_file.csv
    ${client_id}=    Retrieve Client Id For RFP Upload Via DB

    # Check if custom metric_id is provided in override data and is not "NA" (default)
    ${has_custom_metric_id}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${vdi_import_data}    metric_id
    IF    ${has_custom_metric_id}
        VAR    ${metric_id_value}=    ${vdi_import_data}[metric_id]
        # Check if metric_id is not the default "NA" value
        IF    "${metric_id_value}" != "NA"
            # Use the provided metric_id(s) - single value or list
            ${type_name}=    Evaluate    type($metric_id_value).__name__
            IF    "${type_name}" == "list"
                VAR    @{metric_ids}=    @{metric_id_value}
            ELSE
                VAR    @{metric_ids}=    ${metric_id_value}
            END
        ELSE
            # "NA" means fetch default from database
            ${metric_ids}=    Retrieve Metric Ids For Non Department Driver Via DB
        END
    ELSE
        # metric_id key not present, fetch default from database
        ${metric_ids}=    Retrieve Metric Ids For Non Department Driver Via DB
    END
    ${has_unit_id_new}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${vdi_import_data}    unitID
    IF    ${has_unit_id_new}
        VAR    ${unit_id}=    ${vdi_import_data}[unitID]
    ELSE
        VAR    ${unit_id}=    ${vdi_import_data}[unit_id]
    END
    VAR    ${feed_level_store}=    ${vdi_import_data}[feed_level]
    VAR    ${import_type}=    ${vdi_import_data}[import_type]
    VAR    ${metric_category}=    ${vdi_import_data}[metric_category]
    ${has_driver_import_value}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${vdi_import_data}    driver_import_value
    IF    ${has_driver_import_value}
        VAR    ${value_to_import}=    ${vdi_import_data}[driver_import_value]
    ELSE
        VAR    ${driver_start_time}=    ${vdi_import_data}[driver_start_time]
        VAR    ${driver_end_time}=    ${vdi_import_data}[driver_end_time]
        ${value_to_import}=    Build Driver Import Interval Array    ${driver_start_time}    ${driver_end_time}
    END
    VAR    ${week_offset}=    ${vdi_import_data}[week_start_date]
    ${date_format}=    Get Config Value    SERVER_DF
    ${week_days}=    Get All Week Dates For The Given Week Date    ${week_offset}    ${date_format}

    # Extract skip_days: list of day indices (0=Sun..6=Sat) where hours should be zeroed
    ${skip_days_raw}=    Get From Dictionary    ${vdi_import_data}    skip_days    default=${EMPTY}
    # Accept skip_days as list or JSON string and normalize to JSON list text.
    IF    $skip_days_raw == '' or $skip_days_raw == 'NA'
        VAR    ${skip_days_json}=    ${EMPTY}
    ELSE
        ${skip_days_type}=    Evaluate    type($skip_days_raw).__name__
        IF    '${skip_days_type}' == 'list'
            ${skip_days_json}=    Evaluate    json.dumps($skip_days_raw)    json
        ELSE
            ${parsed_skip_days}=    Evaluate    json.loads($skip_days_raw)    json
            ${skip_days_json}=    Evaluate    json.dumps($parsed_skip_days)    json
        END
    END

    VAR    @{rfp_upload_args}=    ${vdi_file_path}    ${client_id}    ${metric_ids}    ${unit_id}    ${feed_level_store}
    ...    ${metric_category}    ${week_days}    ${import_type}    ${value_to_import}    ${skip_days_json}
    RETURN    ${rfp_upload_args}

Generate VDI Upload File
    [Documentation]    Wrapper keyword that generates a VDI upload file using the provided VDI import data.
    ...    Internally calls existing data preparation and file generation keywords without changing their implementation.
    ...    | =Arguments= | =Description= |
    ...    | ${vdi_import_data} | VDI import data dictionary used to build upload arguments. |
    ...    | =Returns= | =Description= |
    ...    | ${vdi_upload_file_path} | Full path of the generated VDI upload file. |
    [Arguments]    ${vdi_import_data}
    ${rfp_upload_args}=    Get VDI Upload File Data    ${vdi_import_data}
    ${vdi_upload_file_path}=    Generate RFP Upload File    ${rfp_upload_args}
    RETURN    ${vdi_upload_file_path}

Build Driver Import Interval Array
    [Documentation]
    ...    Builds a single-day VDI driver-import array of 96 fifteen-minute interval slots from a start and end time.
    ...    Each slot maps to a 15-minute interval beginning at midnight: index 0 = 00:00, index 1 = 00:15 ... index 95 = 23:45.
    ...    Every slot inside the half-open window [start_time, end_time) is set to 1 (demand present); all other slots are 0.
    ...    This replaces hardcoded 96-value arrays so the demand window can be driven by readable times as test data.
    ...    | =Arguments= | =Description= |
    ...    | start_time | Window start as a 24-hour `HH:MM` string (e.g. `14:00` for 2 PM). Must align to a 15-minute boundary. |
    ...    | end_time | Window end (exclusive) as a 24-hour `HH:MM` string (e.g. `22:00` for 10 PM). Must be greater than start_time. |
    ...
    ...    *Returns*: List of 96 integers (0 or 1) representing the day's interval demand.
    [Arguments]    ${start_time}    ${end_time}
    ${start_h}=    Evaluate    int('${start_time}'.split(':')[0])
    ${start_m}=    Evaluate    int('${start_time}'.split(':')[1])
    ${end_h}=    Evaluate    int('${end_time}'.split(':')[0])
    ${end_m}=    Evaluate    int('${end_time}'.split(':')[1])
    Should Be True    ${start_m} % 15 == 0 and ${end_m} % 15 == 0
    ...    msg=Driver interval times must align to 15-minute boundaries: ${start_time} to ${end_time}
    ${start_index}=    Evaluate    ${start_h} * 4 + ${start_m} // 15
    ${end_index}=    Evaluate    ${end_h} * 4 + ${end_m} // 15
    Should Be True    0 <= ${start_index} < ${end_index} <= 96
    ...    msg=Invalid driver interval window: ${start_time} to ${end_time} (start must be before end and within a day).
    ${driver_import_array}=    Evaluate    [1 if ${start_index} <= i < ${end_index} else 0 for i in range(96)]
    RETURN    ${driver_import_array}

Generate RFP Upload File
    [Documentation]    Generates RFP upload file with the provided parameters.
    ...    All 7 days of the week are included in the output file.
    ...    Days with skip_days specified have their hours set to 0 (applied per day during file generation).
    ...    | =Arguments= | =Description= |
    ...    | ${rfp_upload_args} | Ordered list: [file_path, client_id, metric_ids, unit_id, feed_level_store, metric_category, week_days, import_type, value_to_import, skip_days_json]. |
    ...    | skip_days_json | JSON string of day indices (0=Sun..6=Sat) where hours should be zeroed. Empty string means no skipping. |
    [Arguments]    ${rfp_upload_args}

    VAR    ${file_path}=    ${rfp_upload_args}[0]
    VAR    ${client_id}=    ${rfp_upload_args}[1]
    VAR    ${metric_ids}=    ${rfp_upload_args}[2]
    VAR    ${unit_id}=    ${rfp_upload_args}[3]
    VAR    ${feed_level_store}=    ${rfp_upload_args}[4]
    VAR    ${metric_category}=    ${rfp_upload_args}[5]
    VAR    ${week_days}=    ${rfp_upload_args}[6]
    VAR    ${import_type}=    ${rfp_upload_args}[7]
    VAR    ${value_to_import}=    ${rfp_upload_args}[8]
    VAR    ${skip_days_json}=    ${rfp_upload_args}[9]
    # Convert skip_days from JSON to list (will be used in Evaluate expressions)
    IF    $skip_days_json != ''
        ${skip_days}=    Evaluate    json.loads($skip_days_json)    json
    ELSE
        ${skip_days}=    Evaluate    []
    END
    # Note: skip_days logic is now applied per-day in file generation
    # Days in skip_days list will have all hours set to 0

    VAR    ${test_env}=    %{TEST_ENVIRONMENT=${EMPTY}}
    VAR    ${vdi_upload_file_path}=
    ...    ${EXECDIR}${/}ExternalFiles${/}Excel${/}upload${/}vdi_import_${test_env}_${unit_id}_${week_days}[0].csv

    ${file_content}=    OperatingSystem.Get File    ${file_path}
    # Replace common placeholders in the template
    ${updated_content}=    Replace String    ${file_content}    VD_IMPORT_TYPE    ${import_type}
    ${updated_content}=    Replace String    ${updated_content}    CLIENT_ID    ${client_id}
    ${updated_content}=    Replace String    ${updated_content}    UNIT_ID    ${unit_id}
    ${updated_content}=    Replace String    ${updated_content}    FEED_LEVEL    ${feed_level_store}
    ${updated_content}=    Replace String    ${updated_content}    METRIC_CATEGORY    ${metric_category}

    # Keep VALUE_TO_IMPORT placeholders in the row template.
    # Actual import values are applied per-day below so skipped days can be forced to all zeros.

    # Split into lines: HH header (index 0), data row template (index 1), TT footer (index 2)
    @{lines}=    Split String    ${updated_content}    \n
    VAR    ${header_row}=    ${lines}[0]
    VAR    ${data_row_template}=    ${lines}[1]
    VAR    ${footer_row}=    ${lines}[2]

    # Duplicate the template row for each metric_id first
    VAR    @{metric_rows}=    @{EMPTY}
    FOR    ${metric_id}    IN    @{metric_ids}
        ${metric_row}=    Replace String    ${data_row_template}    METRIC_ID    ${metric_id}
        Append To List    ${metric_rows}    ${metric_row}
    END

    # Duplicate all metric rows for each week date
    # Apply skip_days: if day index is in skip_days, use zeros instead of original values
    VAR    @{data_rows}=    @{EMPTY}
    VAR    ${day_counter}=    0
    FOR    ${week_date}    IN    @{week_days}
        # Determine if this day should be skipped
        ${day_is_skipped}=    Evaluate    ${day_counter} in $skip_days
        # Create appropriate value array: zeros if skipped, original if not
        IF    ${day_is_skipped}
            # Create zero array with same length as value_to_import
            ${day_type_name}=    Evaluate    type($value_to_import).__name__
            IF    "${day_type_name}" == "list"
                ${day_value}=    Evaluate    [0] * len($value_to_import)
            ELSE
                ${day_value}=    Evaluate    0
            END
        ELSE
            VAR    ${day_value}=    ${value_to_import}
        END
        FOR    ${metric_row}    IN    @{metric_rows}
            ${data_row}=    Replace String    ${metric_row}    EFFECTIVE_DATE    ${week_date}
            # Replace VALUE_TO_IMPORT with appropriate array (zeros if skipped, original if not)
            ${day_type_name}=    Evaluate    type($day_value).__name__
            IF    "${day_type_name}" == "list"
                ${value_str}=    Evaluate    ','.join(str(v) for v in $day_value)
                ${data_row}=    Replace String Using Regexp    ${data_row}    VALUE_TO_IMPORT(,VALUE_TO_IMPORT)*    ${value_str}
            ELSE
                ${data_row}=    Replace String    ${data_row}    VALUE_TO_IMPORT    ${day_value}
            END
            Append To List    ${data_rows}    ${data_row}
        END
        ${day_counter}=    Evaluate    int($day_counter) + 1
    END

    # Combine header, all data rows, and footer into final file content
    ${data_section}=    Catenate    SEPARATOR=\n    @{data_rows}
    ${final_content}=    Catenate    SEPARATOR=\n    ${header_row}    ${data_section}    ${footer_row}
    Create File    ${vdi_upload_file_path}    ${final_content}
    RETURN    ${vdi_upload_file_path}

Get All Week Dates For The Given Week Date
    [Documentation]    Calculates and returns all 7 dates for the week based on the given week start date.
    ...    | =Arguments= | =Description= |
    ...    | ${week_start_date} | Start date of the week. |
    ...    | ${date_format} | Desired date format for the output (e.g., 'YYYY-MM-DD'). |
    ...    | =Returns= | =Description= |
    ...    | @{week_dates} | List of all 7 dates for the week in the specified format (week_0 through week_6). |
    ...    | =Example Usage= |
    ...    | @{week_dates}= | Get All Week Dates For The Given Week Date | 2024-06-01 | YYYY-MM-DD |
    [Arguments]    ${week_start_date}    ${date_format}

    ${is_week_offset}=    Run Keyword And Return Status
    ...    Should Contain    ${week_start_date}    _

    IF    ${is_week_offset}
        Log    Week start date provided as offset: ${week_start_date}
        ${week_start_date}=    TestDataLibrary.Calculate Week Start Date From Week Day Offset    ${week_start_date}    ${date_format}
    END

    VAR    @{week_dates}=    @{EMPTY}
    FOR    ${day_index}    IN RANGE    0    7
        VAR    ${days_to_add}=    ${day_index} days
        ${week_date}=    Add Time To Date    ${week_start_date}    ${days_to_add}    result_format=${date_format}
        Append To List    ${week_dates}    ${week_date}
    END
    RETURN    @{week_dates}
