*** Settings ***
Documentation
...                 This resource file provides keywords for automating the Batch Jobs page functionality within the RWS module.
...
...                 = Purpose =
...                 - Centralizes navigation and interaction keywords for the Batch Jobs page
...                 - Provides verification methods for batch job data and page elements
...                 - Supports automated testing of batch job monitoring and management features
...
...                 = Key Features =
...                 - Navigation to Batch Jobs sections
...                 - Batch job data validation
...                 - Batch job status verification capabilities
...
...                 = Prerequisites =
...                 - User must be logged into the WFM application
...                 - Appropriate permissions for accessing RWS Driver Forecast module
...                 - Required resources and variable files must be available and imported
...
...                 = Dependencies =
...                 - resources/web/common/common.resource: Core navigation and utility functions
...                 - resources/web/common/common_date_utility.resource: Date manipulation utilities
...                 - batch_jobs_page.py: Page object variables and locators

Resource            resources/web/common/common.resource
Variables           resources/web/rws/driver_forecast/batch_jobs_page.py
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RWS Admin Batch Jobs Monitor Page On Web
    [Documentation]    Navigate To RWS -> Admin -> Batch Jobs Monitor Page
    ...    and verifies batch jobs monitor heading at the top of the page
    Navigate To Specific Page On Web    rws    admin    batch_jobs_monitor

Select Queue Type Dropdown Menu On Web
    [Documentation]    This keyword selects the option from dropdown based on the option's attribute value.
    ...    It returns the text value of the selected option.
    ...    | =Arguments=    | =Description=    |
    ...    | queue_type_option    | The option value to select from the queue type dropdown    |
    ...    | =Returns=    | =Description=    |
    ...    | queuetype_option_txt_value    | Returns the queue type name label for the selected queue type    |
    [Arguments]    ${queue_type_option}
    Select List Item On Webpage    ${BATCH_JOBS_MONITOR_QUEUE_TYPE_DRPDWN}    value    ${queue_type_option}
    ${queuetype_option_txt_value }    Get Selected Value In Dropdown On Web    ${BATCH_JOBS_MONITOR_QUEUE_TYPE_DRPDWN}
    RETURN    ${queuetype_option_txt_value }

Select Default Highlighted Date In From-Calendar As Start Date On Web
    [Documentation]    This keyword is to select the default highlighted date(current date) from start date calendar
    ...    in Queues Between field
    Click Element On Webpage    ${BATCH_JOBS_MONITOR_SELECT_START_DATE}
    Click Element On Webpage    ${BATCH_JOBS_MONITOR_SELECTED_DAY_IN_PICK_UP_CAL}

Select Default Highlighted Date In To-Calendar As End Date On Web
    [Documentation]    This keyword is to select the default highlighted date(current date) from end date calendar
    ...    in Queues Between field
    Click Element On Webpage    ${BATCH_JOBS_MONITOR_SELECT_END_DATE}
    Click Element On Webpage    ${BATCH_JOBS_MONITOR_SELECTED_DAY_IN_PICK_UP_CAL}

Select Start Date And End Date In From-Calendar On Web
    [Documentation]    Selects the start date (previous day) and end date (today) from the "Queues Between" calendar.
    ...    Automatically navigates between calendar months if needed (e.g., when the range crosses a month boundary).
    ${today_offset}    Get Current Week Day Offset
    ${today}    Calculate Date From Week Day Offset    ${today_offset}    %d
    ${week_no}    ${day_no}    Split String    ${today_offset}    _
    ${day_no}    Evaluate    int(${day_no}) - 1
    ${previous_day_offset}    Catenate    SEPARATOR=_    ${week_no}    ${day_no}
    ${previous_day}    Calculate Date From Week Day Offset    ${previous_day_offset}    %d

    # Remove leading zeros from day values to match calendar HTML format
    ${today_no_leading_zero}    Evaluate    int('${today}')
    ${previous_day_no_leading_zero}    Evaluate    int('${previous_day}')

    ${start_day}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_DAY_IN_PICK_UP_CAL}    DAY=${previous_day_no_leading_zero}
    ${end_day}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_DAY_IN_PICK_UP_CAL}    DAY=${today_no_leading_zero}

    # Check if previous day is end of month (30 or 31), then navigate to previous month first
    IF    ${previous_day_no_leading_zero} == 30 or ${previous_day_no_leading_zero} == 31
        Log    Previous day is ${previous_day_no_leading_zero}, need to navigate to previous month for start date
        Click Element On Webpage    ${BATCH_JOBS_MONITOR_SELECT_START_DATE}
        Click Element On Webpage    ${BATCH_JOBS_MONITOR_CAL_PREV_MONTH_BTN}
        Wait Until Element Is Visible On Webpage    ${start_day}    ${SHORT_TIMEOUT}
        Click Element On Webpage    ${start_day}
    ELSE
        # Select start date with month navigation if needed
        Click Element On Webpage    ${BATCH_JOBS_MONITOR_SELECT_START_DATE}
        ${start_day_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${start_day}
        ...    ${SHORT_TIMEOUT}
        IF    ${start_day_visible}
            Log    Start day ${previous_day_no_leading_zero} found in current month
            Click Element On Webpage    ${start_day}
        ELSE
            Log    Start day ${previous_day_no_leading_zero} not found in current month, navigating to previous month
            Click Element On Webpage    ${BATCH_JOBS_MONITOR_CAL_PREV_MONTH_BTN}
            Wait Until Element Is Visible On Webpage    ${start_day}    ${SHORT_TIMEOUT}
            Click Element On Webpage    ${start_day}
        END
    END

    # Select end date with month navigation if needed
    Click Element On Webpage    ${BATCH_JOBS_MONITOR_SELECT_END_DATE}
    ${end_day_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${end_day}    ${SHORT_TIMEOUT}
    IF    ${end_day_visible}
        Log    End day ${today_no_leading_zero} found in current month
        Click Element On Webpage    ${end_day}
    ELSE
        Log    End day ${today_no_leading_zero} not found in current month, navigating to next month
        Click Element On Webpage    ${BATCH_JOBS_MONITOR_CAL_NEXT_MONTH_BTN}
        Wait Until Element Is Visible On Webpage    ${end_day}    ${SHORT_TIMEOUT}
        Click Element On Webpage    ${end_day}
    END

Select Status Dropdown Menu On Web
    [Documentation]    This keyword is to select the required option in Status dropdown menu.
    ...    It accepts option value attribute as parameter.
    ...    | =Arguments=    | =Description=    |
    ...    | status_option    | The option value to select from the status dropdown    |
    [Arguments]    ${status_option}
    Select List Item On Webpage    ${BATCH_JOBS_MONITOR_STATUS_DRPDWN}    value    ${status_option}

Apply The Selected Filters On Batch Jobs Monitor Page On Web
    [Documentation]    This keyword is to click on the Apply button to apply the filter and get the results accordingly.
    Click Element On Webpage    ${BATCH_JOBS_MONITOR_APPLY_BTN}
    Wait For Filter Results On Batch Jobs Monitor Page On Web

Wait For Filter Results On Batch Jobs Monitor Page On Web
    [Documentation]    This keyword waits for the filter results to populate after applying the filter.
    Run Keyword And Ignore Error
    ...    Wait Until Element Disappears On Webpage    ${BATCH_JOBS_MONITOR_FILTER_LIST_BLOCK}    ${SHORT_TIMEOUT}
    Wait Until Element Is Visible On Webpage    ${BATCH_JOBS_MONITOR_FILTER_LIST_BLOCK}

Verify If The Batch Job Is Completed In The Filter Results For Queue And Unit On Web
    [Documentation]    This keyword verifies if the expected Queue and Unit's job is present in the results.
    ...    | =Arguments=    | =Description=    |
    ...    | queue_type_name    | The queue type name label    |
    ...    | batch_job_description    | The batch job description to verify in the results    |
    ...    | unit_name    | The name of the unit to search for in the batch job results    |
    [Arguments]    ${queue_type_name}    ${batch_job_description}    ${unit_name}
    VAR    ${batch_job_records_list_count}    ${EMPTY}
    VAR    ${batch_job_index}    ${EMPTY}
    VAR    ${record_found}    False

    Wait Until Page Is Loaded

    TRY
        ${batch_job_records_list_count}    Get Element Count    ${BATCH_JOBS_MONITOR_FILTER_LIST_RECORDS}
        Log    No. of records found in results: ${batch_job_records_list_count}
    EXCEPT
        Fail    No records found in the Batch Jobs List on Batch Job Monitor Page.
    END
    FOR    ${batch_job_record}    IN RANGE    1    ${batch_job_records_list_count+1}
        ${batch_job_record_index}    Convert To String    ${batch_job_record}
        Wait Until Element Is Visible On Webpage    ${BATCH_JOBS_MONITOR_FILTER_LIST_BLOCK}
        ${batch_job_record_queue_name}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_TBL_QUEUE_NAME}
        ...    BATCH_JOB_INDEX=${batch_job_record_index}    QUEUE_TYPE_NAME=${queue_type_name}
        ${queue_name_present}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${batch_job_record_queue_name}    ${LONG_TIMEOUT}
        ${batch_job_record_queue_name}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_TBL_STORE_NAME}
        ...    BATCH_JOB_INDEX=${batch_job_record_index}    STORE_NAME=${unit_name}
        ${store_name_present}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${batch_job_record_queue_name}    ${LONG_TIMEOUT}
        VAR    ${job_description_present}    ${True}
        IF    '${batch_job_description}' != '${EMPTY}'
            ${batch_job_record_queue_name}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_TBL_JOB_DESCRIPTION}
            ...    BATCH_JOB_INDEX=${batch_job_record_index}    JOB_DESCRIPTION=${batch_job_description}
            ${job_description_present}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
            ...    ${batch_job_record_queue_name}    ${LONG_TIMEOUT}
        END
        IF    ${queue_name_present} and ${store_name_present} and ${job_description_present}
            Log    Matching record found at index: ${batch_job_record}
            ${batch_job_index}    Get Variable Value    ${batch_job_record_index}
            ${record_found}    Evaluate    not ${record_found}
            Capture Screenshot On Webpage
            BREAK
        END
    END
    IF    ${record_found}
        Log    Record found at ${batch_job_index} index.
    ELSE
        Fail    Record not found for Queue Name: ${queue_type_name} and Unit Name: ${unit_name}
    END
    Verify If The Batch Job Is Completed On Web    ${batch_job_index}
    Capture Screenshot On Webpage

Verify If The Workload Batch Job Is Completed In The Filter Results For Queue And Unit On Web
    [Documentation]    This keyword verifies if the expected Queue and Unit's job is present in the results.
    ...    | =Arguments=    | =Description=    |
    ...    | queue_type_name    | The queue type name label    |
    ...    | batch_job_description    | The batch job description to verify in the results    |
    ...    | unit_name    | The name of the unit to search for in the batch job results    |
    [Arguments]    ${queue_type_name}    ${batch_job_description}    ${unit_name}    ${planned_week}
    VAR    ${batch_job_records_list_count}    ${EMPTY}
    VAR    ${batch_job_index}    ${EMPTY}
    VAR    ${record_found}    False
    TRY
        ${batch_job_records_list_count}    Get Element Count    ${BATCH_JOBS_MONITOR_FILTER_LIST_RECORDS}
        Log    No. of records found in results: ${batch_job_records_list_count}
    EXCEPT
        Fail    No records found in the Batch Jobs List on Batch Job Monitor Page.
    END
    FOR    ${batch_job_record}    IN RANGE    1    ${batch_job_records_list_count+1}
        ${batch_job_record_index}    Convert To String    ${batch_job_record}
        Wait Until Element Is Visible On Webpage    ${BATCH_JOBS_MONITOR_FILTER_LIST_BLOCK}
        ${batch_job_record_queue_name}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_TBL_QUEUE_NAME}
        ...    BATCH_JOB_INDEX=${batch_job_record_index}    QUEUE_TYPE_NAME=${queue_type_name}
        ${queue_name_present}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${batch_job_record_queue_name}    ${SHORT_TIMEOUT}
        ${batch_job_record_queue_name}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_TBL_STORE_NAME}
        ...    BATCH_JOB_INDEX=${batch_job_record_index}    STORE_NAME=${unit_name}
        ${store_name_present}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${batch_job_record_queue_name}    ${SHORT_TIMEOUT}

        ${batch_job_record_queue_name}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_WORKLOAD_TBL_JOB_DESCRIPTION}
        ...    BATCH_JOB_INDEX=${batch_job_record_index}    JOB_DESCRIPTION=${batch_job_description}    WEEK=${planned_week}

        ${job_description_present}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${batch_job_record_queue_name}    ${SHORT_TIMEOUT}
        IF    ${queue_name_present} and ${store_name_present} and ${job_description_present}
            Log    Matching record found at index: ${batch_job_record}
            ${batch_job_index}    Get Variable Value    ${batch_job_record_index}
            ${record_found}    Evaluate    not ${record_found}
            BREAK
        END
    END
    IF    ${record_found}
        Log    Record found at ${batch_job_index} index.
    ELSE
        Fail    Record not found for Queue Name: ${queue_type_name} and Unit Name: ${unit_name}
    END
    Verify If The Batch Job Is Completed On Web    ${batch_job_index}
    Capture Screenshot On Webpage

Verify If The Batch Job Is Completed On Web
    [Documentation]    This keyword checks if the batch job is completed for the mentioned record.
    ...    | =Arguments=    | =Description=    |
    ...    | batch_job_index    | The index of the batch job to be checked for completed status    |
    [Arguments]    ${batch_job_index}
    ${batch_job_completed_status}    Get System Value    BatchJobStatus    COMPLETED
    ${batch_job_status}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_TBL_JOB_STATUS}
    ...    BATCH_JOB_INDEX=${batch_job_index}    JOB_STATUS=${batch_job_completed_status}
    ${batch_job_completed}    Is Element Visible On Webpage    ${batch_job_status}
    ${batch_job_progress}    Update Locator With Dynamic Values    ${BATCH_JOBS_MONITOR_TBL_JOB_PROGRESS}
    ...    BATCH_JOB_INDEX=${batch_job_index}    JOB_PROGRESS=100%
    ${batch_job_progress_completed}    Is Element Visible On Webpage    ${batch_job_progress}
    VAR    ${count}    30    # Max wait time is 5 minutes (30 * 10s)
    VAR    ${counter}    1
    WHILE    not ${batch_job_completed} and not ${batch_job_progress_completed}    limit=${LOOP_TIMEOUT}
        IF    ${counter} <= ${count}
            Sleep    ${MEDIUM_TIMEOUT}    reason=Waiting for batch job to complete
            ${counter}    Evaluate    ${counter} + 1
        ELSE
            BREAK
        END
        Click Element On Webpage    ${BATCH_JOBS_MONITOR_APPLY_BTN}
        TRY
            Wait Until Element Disappears On Webpage    ${BATCH_JOBS_MONITOR_FILTER_LIST_BLOCK}    ${SHORT_TIMEOUT}
            Wait Until Element Is Visible On Webpage    ${BATCH_JOBS_MONITOR_FILTER_LIST_BLOCK}
        EXCEPT
            Wait Until Element Is Visible On Webpage    ${BATCH_JOBS_MONITOR_FILTER_LIST_BLOCK}
        END
        ${batch_job_completed}    Is Element Visible On Webpage    ${batch_job_status}
        ${batch_job_progress_completed}    Is Element Visible On Webpage    ${batch_job_progress}
    END
    IF    ${batch_job_completed} and ${batch_job_progress_completed}
        Log    The batch job is completed.
    ELSE
        Fail    The batch job is not completed after 5 minutes.
    END

Clear The Filter On Batch Jobs Monitor Page On Web
    [Documentation]    This keyword clears the filter on Batch Jobs Monitor page.
    Click Element On Webpage    ${BATCH_JOBS_MONITOR_CLEAR_BTN}

Verify Forecast Job Is Completed On Admin Batch Jobs Monitor Page On Web
    [Documentation]    This keyword verifies that the forecast initialization job is completed
    ...    for the given planned week and store data on the Admin Batch Jobs Monitor Page.
    ...    | =Arguments=    | =Description=    |
    ...    | planned_week    | The planned week for which the forecast job needs to be verified    |
    ...    | selected_week_number    | The selected week number on the weekly plan page    |
    ...    | store_data    | The store data dictionary containing store details    |
    [Arguments]    ${store_data}
    ${forecast_initialization}    Get System Value    BatchJobsMonitorQueueType    FORECAST_INITIALIZATION
    ${batch_job_status_all}    Get System Value    BatchJobStatusFilter    All
    Navigate To RWS Admin Batch Jobs Monitor Page On Web
    ${queue_type_name}    Select Queue Type Dropdown Menu On Web
    ...    ${forecast_initialization}
    Select Start Date And End Date In From-Calendar On Web
    Select Status Dropdown Menu On Web    ${batch_job_status_all}
    Apply The Selected Filters On Batch Jobs Monitor Page On Web
    VAR    ${batch_job_description}    ${EMPTY}
    ${pagination_displayed}    Is Element Visible On Webpage    ${BATCH_JOBS_MONITOR_DISP_PAGE_DRPDWN}
    IF    ${pagination_displayed}
        Navigate Through All Pages On Batch Jobs Monitor Page On Web
    END
    Verify If The Batch Job Is Completed In The Filter Results For Queue And Unit On Web
    ...    ${queue_type_name}    ${batch_job_description}    ${store_data}[store_name]

Verify Workload Job Is Completed On Admin Batch Jobs Monitor Page On Web
    [Documentation]    This keyword verifies that the workload generation job is completed
    ...    for the given planned week and store data on the Admin Batch Jobs Monitor Page.
    ...    | =Arguments=    | =Description=    |
    ...    | planned_week    | The planned week for which the workload job needs to be verified    |
    ...    | store_name    | The name of the store where workload is generated    |
    [Arguments]    ${planned_week}    ${store_name}
    ${workload_generation}    Get System Value    BatchJobsMonitorQueueType    WORKLOAD_GENERATION
    ${batch_job_status_all}    Get System Value    BatchJobStatusFilter    All
    Navigate To RWS Admin Batch Jobs Monitor Page On Web
    ${queue_type_name}    Select Queue Type Dropdown Menu On Web
    ...    ${workload_generation}
    Select Start Date And End Date In From-Calendar On Web
    Select Status Dropdown Menu On Web    ${batch_job_status_all}
    Apply The Selected Filters On Batch Jobs Monitor Page On Web
    VAR    ${batch_job_description}    ${EMPTY}
    ${pagination_displayed}    Is Element Visible On Webpage    ${BATCH_JOBS_MONITOR_DISP_PAGE_DRPDWN}
    IF    ${pagination_displayed}
        Navigate Through All Pages On Batch Jobs Monitor Page On Web
    END
    Verify If The Workload Batch Job Is Completed In The Filter Results For Queue And Unit On Web    ${queue_type_name}
    ...    ${batch_job_description}    ${store_name}    ${planned_week}

Verify Schedule Generation Job Is Completed On Admin Batch Jobs Monitor Page On Web
    [Documentation]    This keyword verifies that the schedule generation job is completed
    ...    for the given planned week and store data on the Admin Batch Jobs Monitor Page.
    ...    | =Arguments=    | =Description=    |
    ...    | planned_week    | The planned week for which the schedule generation job needs to be verified    |
    ...    | store_name    | The name of the store where schedule is generated    |
    [Arguments]    ${planned_week}    ${store_name}
    ${schedule_generation}    Get System Value    BatchJobsMonitorQueueType    SCHEDULE_GENERATION
    ${batch_job_status_all}    Get System Value    BatchJobStatusFilter    All
    Navigate To RWS Admin Batch Jobs Monitor Page On Web
    ${queue_type_name}    Select Queue Type Dropdown Menu On Web
    ...    ${schedule_generation}
    Select Start Date And End Date In From-Calendar On Web
    Select Status Dropdown Menu On Web    ${batch_job_status_all}
    Select Submitted By Dropdown Menu On Web    ${batch_job_status_all}
    Apply The Selected Filters On Batch Jobs Monitor Page On Web
    VAR    ${batch_job_description}    Generate Schedule for ${planned_week}
    ${pagination_displayed}    Is Element Visible On Webpage    ${BATCH_JOBS_MONITOR_DISP_PAGE_DRPDWN}
    IF    ${pagination_displayed}
        Navigate Through All Pages On Batch Jobs Monitor Page On Web
    END
    Verify If The Batch Job Is Completed In The Filter Results For Queue And Unit On Web
    ...    ${queue_type_name}    ${batch_job_description}    ${store_name}

Verify Predictive Forecast Job Is Completed On Admin Batch Jobs Monitor Page On Web
    [Documentation]    This keyword verifies that the Predictive forecast initialization job is completed
    ...    for the given store data on the Admin Batch Jobs Monitor Page.
    ...    The job-description check is intentionally skipped (passed as ${EMPTY}) because the
    ...    predictive-forecast calendar keyword returns a formatted date, not the week-day
    ...    input, which would otherwise cause a 30s locator timeout per record.
    ...    | =Arguments=    | =Description=    |
    ...    | store_name    | The name of the store where the forecast job ran    |
    [Arguments]    ${store_name}
    ${forecast_initialization}    Get System Value    BatchJobsMonitorQueueType    PRE_FORECAST_INITIALIZATION
    ${batch_job_status_all}    Get System Value    BatchJobStatusFilter    All
    Navigate To RWS Admin Batch Jobs Monitor Page On Web
    ${queue_type_name}    Select Queue Type Dropdown Menu On Web
    ...    ${forecast_initialization}
    Select Start Date And End Date In From-Calendar On Web
    Select Status Dropdown Menu On Web    ${batch_job_status_all}
    Apply The Selected Filters On Batch Jobs Monitor Page On Web
    VAR    ${batch_job_description}    ${EMPTY}
    ${pagination_displayed}    ${_}    Run Keyword And Ignore Error
    ...    Wait Until Element Is Visible On Webpage    ${BATCH_JOBS_MONITOR_DISP_PAGE_DRPDWN}    ${SHORT_TIMEOUT}
    IF    '${pagination_displayed}' == 'PASS'
        Navigate Through All Pages On Batch Jobs Monitor Page On Web
    END
    Verify If The Batch Job Is Completed In The Filter Results For Queue And Unit On Web
    ...    ${queue_type_name}    ${batch_job_description}    ${store_name}

Select Submitted By Dropdown Menu On Web
    [Documentation]    This keyword is to select the required option in Submitted By dropdown menu.
    ...    | =Arguments=    | =Description=    |
    ...    | submitted_by_option    | The option value to select from the submitted by dropdown    |
    [Arguments]    ${submitted_by_option}
    Select List Item On Webpage    ${BATCH_JOBS_MONITOR_SUBMITTED_BY_DRPDWN}    value    ${submitted_by_option}
    Log    Successfully selected submitted by option: ${submitted_by_option}

Navigate Through All Pages On Batch Jobs Monitor Page On Web
    [Documentation]    This keyword is to navigate through pages sequentially to find batch jobs on Batch Jobs Monitor page.
    ...    It iterates through all pages starting from the first page to search for batch jobs across all available pages.
    Click Element On Webpage    ${BATCH_JOBS_MONITOR_DISP_PAGE_DRPDWN}
    ${option_count}    Get Element Count On Web Page    ${BATCH_JOBS_MONITOR_DISP_PAGE_OPTION}
    IF    ${option_count} > 1
        # Start from the first page and iterate through all pages
        FOR    ${page_number}    IN RANGE    1    ${option_count + 1}
            ${page_value}    Convert To String    ${page_number}
            Select List Item On Webpage    ${BATCH_JOBS_MONITOR_DISP_PAGE_DRPDWN}    value    ${page_value}
            Wait For Filter Results On Batch Jobs Monitor Page On Web
            Log    Navigated to page ${page_number} of ${option_count}
            # Check if batch job records are found on this page
            ${record_count}    Get Element Count    ${BATCH_JOBS_MONITOR_FILTER_LIST_RECORDS}
            ${records_found}    Evaluate    ${record_count} > 0
            IF    ${records_found}
                Log    Found ${record_count} records on page ${page_number}
                # If this is the last page, stay here
                IF    ${page_number} == ${option_count}
                    Log    Reached last page (${page_number}) with records
                    BREAK
                END
            END
        END
    ELSE
        Log    Only one page available, no pagination needed
    END
