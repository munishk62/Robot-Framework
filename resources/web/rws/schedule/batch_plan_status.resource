*** Settings ***
Documentation       Resource file containing keywords for batch plan status page functionality.
...                 Provides functions for workload generation and schedule creation from the batch plan status page.

Library             pabot.PabotLib
Library             test_data/TestDataLibrary.py
Resource            resources/web/common/common.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/common/database.resource
Resource            resources/web/rws/schedule/all_schedules.resource
Variables           resources/web/rws/schedule/week_schedule_page.py
Variables           resources/web/rws/schedule/batch_plan_api.py
Variables           resources/web/rws/schedule/batch_job_status_page.py
Variables           resources/web/common/status_codes.py
Resource            resources/api/api_executor.resource
Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/rws/admin/rws_upload_api.resource
Resource            resources/web/rws/schedule/week_schedule_db.resource


*** Keywords ***
Get User With Person Id Fallback
    [Documentation]    Gets user data with person_id. If person_id is not found in credentials,
    ...    fetches it from the database using employee_id (username).
    ...
    ...    This keyword handles both:
    ...    1. Existing users: person_id available in .env/credentials
    ...    2. New hires: person_id must be fetched from database
    ...    3. Dynamic users: users created at runtime
    ...
    ...    Arguments:
    ...    - user_key: User key (e.g., ESS5_STORE1, ESSNH1_STORE2)
    ...
    ...    Returns:
    ...    - user_data: Dictionary with all user fields including personId
    ...
    ...    Example:
    ...    | ${user}=    Get User With Person Id Fallback    user_key=ESSNH1_STORE2
    ...    | Log    Person ID: ${user}[personId]
    [Arguments]    ${user_key}

    # Check if user exists in credentials first
    ${available_users}=    Get Available Users
    ${user_in_credentials}=    Run Keyword And Return Status    List Should Contain Value    ${available_users}    ${user_key}

    IF    ${user_in_credentials}
        ${user_data}=    Get User    user_key=${user_key}
        Log    Retrieved user from credentials: ${user_key}    level=DEBUG
    ELSE
        # Try to retrieve from dynamic employees (stored in PabotLib cache)
        ${status}    ${user_data}=    Run Keyword And Ignore Error    Get Dynamic Employee    ${user_key}
        IF    '${status}' == 'PASS'
            Log    Retrieved dynamic user from cache: ${user_key}    level=INFO
        ELSE
            Fail    User key '${user_key}' not found in either credentials or dynamic employees
        END
    END

    # Check if personId exists and is not empty
    ${has_person_id}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${user_data}    personId

    IF    ${has_person_id}
        ${person_id_value}=    Get From Dictionary    ${user_data}    personId
        # Check if person_id is empty, 'None' string, or None object
        # Convert to string for consistent comparison
        ${person_id_str}=    Convert To String    ${person_id_value}
        IF    '${person_id_str}' == '' or '${person_id_str}' == 'None'
            VAR    ${has_person_id}=    ${False}
        END
    END

    # If personId not found or empty, fetch from database
    IF    not ${has_person_id}
        Log    Person ID not found in user data for ${user_key}, fetching from database    level=INFO

        # Get employee_id (username) and owner_id
        ${employee_id}=    Get From Dictionary    ${user_data}    username
        ${owner_id}=    Get Config Value    key=OWNER_ID

        # Query database for person_id using the correct query
        VAR    ${db_query}=
        ...    SELECT PERSON_ID FROM RWS_EMPLOYEE WHERE EMPLOYEE_ID = '${employee_id}' AND OWNER_ID = '${owner_id}'

        Log    Fetching person_id from DB for employee_id: ${employee_id}    level=DEBUG

        ${result}=    Execute Query And Return Result    ${db_query}

        ${length}=    Get Length    ${result}
        IF    ${length} > 0
            ${first_row}=    Get From List    ${result}    0
            VAR    ${person_id}=    ${first_row}[0]
            Log    Found person_id from DB: ${person_id} for ${user_key}    level=INFO

            # Add person_id to user_data dictionary
            Set To Dictionary    ${user_data}    personId=${person_id}
        ELSE
            Fail
            ...    No person_id found in database for employee_id: ${employee_id} and owner_id: ${owner_id}. User may not exist or HRBA import failed.
        END
    ELSE
        Log    Using person_id from credentials for ${user_key}: ${user_data}[personId]    level=DEBUG
    END

    RETURN    ${user_data}

Generate New Week Plan Forecast On Web
    [Documentation]    Generates a week plan on the web interface.
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_WEEK_PLAN_BUTTON}
    ${promise}=    Promise To    Wait For Response    ${GENERATE_WEEK_PLAN_FORECAST_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_WEEK_PLAN_BUTTON}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}
    Confirm Batch Process Successful On Web

Regenerate Week Plan Forecast On Web
    [Documentation]    Regenerates a week plan on the web interface.
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_WEEK_PLAN_CHECK}
    ${promise}=    Promise To    Wait For Response    ${GENERATE_WEEK_PLAN_FORECAST_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_WEEK_PLAN_BUTTON}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}
    Confirm Batch Process Successful On Web

Generate Week Plan Forecast On Web
    [Documentation]    Generates a week plan forecast on the web interface.
    ...    | =Arguments=    | =Description=    |
    ...    | regenerate    | Boolean flag to indicate if the forecast should be regenerated    |
    ...    | new_forecast    | Boolean flag to indicate if a new forecast should be generated    |
    ...    Example usage:
    ...    | Generate Week Plan Forecast On Web    True    False
    ...    | Generate Week Plan Forecast On Web    False    True
    ...    | Generate Week Plan Forecast On Web    False    False
    [Arguments]    ${regenerate}    ${new_forecast}
    IF    $regenerate and not $new_forecast
        Regenerate Week Plan Forecast On Web
    ELSE IF    not $regenerate and $new_forecast
        Generate New Week Plan Forecast On Web
    END

Generate Workload On Web
    [Documentation]    Generates workload for a specific planning week on the web interface.
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_WORKLOAD_BUTTON}
    ${promise}=    Promise To    Wait For Response    ${GENERATE_WORKLOAD_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_WORKLOAD_BUTTON}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}
    Confirm Batch Process Successful On Web
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_PAGE_WORKLOAD_GENERATED_TEXT}    timeout=${SCHEDULE_GENERATION_TIMEOUT}

Check Status Generate Workload On Web
    [Documentation]    Check Status Generate Workload
    ...    This keyword checks if the workload generation status is "Not Started" and generates the workload if needed.
    ...    Example usage:
    ...    | Check Status Generate Workload
    ${regenerate_forecast_is_enabled}=    Does Element State Contain Value On Webpage
    ...    ${WEEKSCHEDULEPAGE_GENERATE_WEEK_PLAN_CHECK}    enabled
    ${generate_workload_is_enabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_WORKLOAD_BUTTON}
    ...    enabled
    IF    ${regenerate_forecast_is_enabled} and ${generate_workload_is_enabled}
        Generate Workload On Web
    ELSE IF    ${generate_workload_is_enabled}
        Generate Workload On Web
    END

Check Status And Generate Schedule On Web
    [Documentation]    Check Status And Generate Schedule
    ...    This keyword checks if the schedule generation options are available and generates the schedule accordingly.
    ...    Example usage:
    ...    | Check Status And Generate Schedule
    [Arguments]    ${schedule_type}
    ${optimized_schedule_is_enabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_OPTIMIZE_SCH}
    ...    enabled
    ${template_schedule_is_enabled}=    Does Element State Contain Value On Webpage
    ...    ${WEEKSCHEDULE_SCHEDULE_GENERATE_USING_TEMPLATE}    enabled
    ${delete_workload_is_enabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULEPAGE_DELETE_WORKLOAD}    enabled
    IF    ${optimized_schedule_is_enabled} or ${template_schedule_is_enabled} and ${delete_workload_is_enabled}
        Generate Schedule On Batch Plan Status Page On Web    ${schedule_type}
    END

Generate Optimized Schedule On Web
    [Documentation]
    ...    Generates optimized schedule for a specific planning week on the web interface.
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_OPTIMIZE_SCH}
    ${promise}=    Promise To    Wait For Response    ${GENERATE_OPTIMIZED_SCHEDULE_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_OPTIMIZE_SCH}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}
    Confirm Batch Process Successful On Web
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_PAGE_SCHEDULE_GENERATED_TEXT}

Generate Forecast Workload Schedule And Publish On Batch Plan Status Page On Web
    [Documentation]    Generates workload and schedule for a specific planning week on the batch plan status page, then publishes the schedule.
    ...    | =Arguments=    | =Description=    |
    ...    | schedule_type    | The type of schedule to generate (Optimized or Template)    |
    ...    Example usage:
    ...    | Generate Forecast Workload And Schedule And Publish On Batch Plan Status Page    Optimized
    ...    | Generate Forecast Workload And Schedule And Publish On Batch Plan Status Page    Template
    [Arguments]    ${regenerate_forecast}    ${schedule_type}    ${publish_schedule}
    Check Status And Generate Week Plan Forecast On Web    ${regenerate_forecast}
    Check Status Generate Workload On Web
    Check Status And Generate Schedule On Web    ${schedule_type}
    IF    ${publish_schedule}    Check Status And Publish Schedule On Web

Check Status And Generate Week Plan Forecast On Web
    [Documentation]    Check Status And Generate Week Plan Forecast
    ...    This keyword checks if the "Regenerate Forecast" option is available and generates or regenerates the week plan forecast accordingly.
    ...    Example usage:
    ...    | Check Status And Generate Week Plan Forecast
    [Arguments]    ${regenerate_forecast}
    ${regenerate_forecast_is_visible}=    Run Keyword And Return Status    Does Element State Contain Value On Webpage
    ...    ${WEEKSCHEDULEPAGE_GENERATE_WEEK_PLAN_CHECK}    visible
    IF    ${regenerate_forecast_is_visible}
        # Regenerate option is visible, use the passed parameter
        VAR    ${new_forecast}=    ${FALSE}
        Generate Week Plan Forecast On Web    ${regenerate_forecast}    ${new_forecast}
    ELSE
        # Regenerate option not visible, generate new forecast
        VAR    ${new_forecast}=    ${TRUE}
        VAR    ${regenerate_forecast}=    ${FALSE}
        Generate Week Plan Forecast On Web    ${regenerate_forecast}    ${new_forecast}
    END

Generate Schedule On Batch Plan Status Page On Web
    [Documentation]
    ...    Generates schedule for a specific planning week on the batch plan status page.
    ...    | =Arguments=    | =Description=    |
    ...    | planning_week_date    | The planning week date for schedule generation    |
    ...    | schedule_type    | The type of schedule to generate (Optimized or Template)    |
    ...    Example usage:
    ...    | Generate Schedule On Batch Plan Status Page    Optimized
    ...    | Generate Schedule On Batch Plan Status Page    Template
    [Arguments]    ${schedule_type}
    IF    $schedule_type=="Optimized"
        Generate Optimized Schedule On Web
    ELSE IF    $schedule_type=="Template"
        Generate Schedule Using Templates
    ELSE
        Fail    Invalid schedule type: ${schedule_type}. Must be 'Optimized' or 'Template'.
    END

Generate Schedule Using Templates
    [Documentation]    Generates optimized schedule for a specific planning week on the web interface.
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULE_SCHEDULE_GENERATE_USING_TEMPLATE}
    ${promise}=    Promise To    Wait For Response    ${GENERATE_OPTIMIZED_SCHEDULE_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULE_SCHEDULE_GENERATE_USING_TEMPLATE}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}
    Confirm Batch Process Successful On Web
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_PAGE_SCHEDULE_GENERATED_TEXT}    timeout=${SCHEDULE_GENERATION_TIMEOUT}

Confirm Batch Process Successful On Web
    [Documentation]    Confirms that a process completed successfully by checking for a success message.
    ...
    ...    This keyword handles flaky batch status elements by:
    ...    - Using extended timeout for initial element appearance
    ...    - Retrying with page refresh if element doesn't appear
    ...    - Gracefully handling cases where process completes before status appears
    ${batch_plan_data}=    Get Batch Plan Data    template_name=default

    # Try to wait for "Not Started" status with extended timeout (may already be completed)
    ${status_appeared}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${BATCH_PLAN_NOT_STARTED_STATUS}    timeout=${SCHEDULE_GENERATION_TIMEOUT}

    IF    ${status_appeared}
        # Status element found - wait for it to disappear (process completion)
        Log    Batch process status 'Not Started' found - waiting for completion    level=INFO
        Wait Until Element Disappears With Refresh    ${BATCH_PLAN_NOT_STARTED_STATUS}    ${WEEK_SCHEDULE_PAGE_REFRESH_BUTTON}
        ...    ${batch_plan_data}[max_attempts]    ${batch_plan_data}[intervals]
    ELSE
        # Status didn't appear - either already completed or taking longer
        Log    Status 'Not Started' not visible - attempting page refresh    level=WARN

        # Refresh page and check again
        Click Element On Webpage    ${WEEK_SCHEDULE_PAGE_REFRESH_BUTTON}
        Sleep    2s    # Allow page to refresh , needed as discussed with owner

        # Check if status appears after refresh
        ${status_after_refresh}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage    ${BATCH_PLAN_NOT_STARTED_STATUS}    timeout=30s

        IF    ${status_after_refresh}
            # Found after refresh - wait for disappearance
            Log    Status found after refresh - waiting for completion    level=INFO
            Wait Until Element Disappears With Refresh    ${BATCH_PLAN_NOT_STARTED_STATUS}    ${WEEK_SCHEDULE_PAGE_REFRESH_BUTTON}
            ...    ${batch_plan_data}[max_attempts]    ${batch_plan_data}[intervals]
        ELSE
            # Process likely already completed before we could see status
            Log    Status never appeared - batch process may have completed quickly    level=INFO
        END
    END

Publish Schedule On Web
    [Documentation]    Publishes the schedule
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_PUBLISH_BUTTON}
    ${promise}=    Promise To    Wait For Response    ${PUBLISH_SCHEDULE_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_PUBLISH_BUTTON}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}

Check Status And Publish Schedule On Web
    [Documentation]    Check Status And Publish Schedule
    ...    This keyword checks if the "Publish" option is available and publishes the schedule if needed.
    ...    Example usage:
    ...    | Check Status And Publish Schedule
    ${publish_is_enabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULEPAGE_PUBLISH_BUTTON}    enabled
    ${unpublish_is_disabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULEPAGE_UNPUBLISH_BUTTON}    disabled
    IF    ${publish_is_enabled} and ${unpublish_is_disabled}
        Publish Schedule On Web
    END

UnPublish Schedule On Web
    [Documentation]    Unpublishes the schedule
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_UNPUBLISH_BUTTON}
    ${promise}=    Promise To    Wait For Response    ${UNPUBLISH_SCHEDULE_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_UNPUBLISH_BUTTON}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}

Delete Schedule On Web
    [Documentation]    Deletes the schedule
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_DLTSCHEDULE_BUTTON}
    ${promise}=    Promise To    Wait For Response    ${DELETE_SCHEDULE_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_DLTSCHEDULE_BUTTON}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_DLT_CONFIRM_BUTTON}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}
    Wait Until Element Disappears On Webpage    ${PLAN_STATUS_PAGE_SCHEDULE_GENERATED_TEXT}

Delete Workload On Web
    [Documentation]    Deletes the workload
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_DELETE_WORKLOAD}
    ${promise}=    Promise To    Wait For Response    ${DELETE_SCHEDULE_AND_WORKLOAD_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_DELETE_WORKLOAD}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_DLT_CONFIRM_BUTTON}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}
    Wait Until Element Disappears On Webpage    ${PLAN_STATUS_PAGE_WORKLOAD_GENERATED_TEXT}

Delete Schedule And Workload On Web
    [Documentation]    Deletes the schedule and workload
    Wait Until Element Is Visible On Webpage    ${WEEKSCHEDULEPAGE_DELETE_SCHEDULE_AND_WORKLOAD}
    ${promise}=    Promise To    Wait For Response    ${DELETE_SCHEDULE_AND_WORKLOAD_API_REGEX}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_DELETE_SCHEDULE_AND_WORKLOAD}
    Click Element On Webpage    ${WEEKSCHEDULEPAGE_DLT_CONFIRM_BUTTON}
    ${response_body}=    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Wait Until Element Disappears On Webpage    ${JOB_QUEUE_NOTIFICATION}
    Wait Until Element Disappears On Webpage    ${PLAN_STATUS_PAGE_WORKLOAD_GENERATED_TEXT}

Clear Generated Schedule And Workload If Exists On Web
    [Documentation]    Deletes the generated schedule and workload if they exist
    [Arguments]    ${sm_user_key}    ${week_start_date}
    Login And Launch WFM Web App    user_key=${sm_user_key}
    Navigate To All Schedule Page Switch To Plan Status Page For Given Planning Week On Web    ${week_start_date}
    Clear Existing Generated Data On Batch Plan Status Page On Web

Clear Generated Schedule And Workload On Plan Status Page On Web
    [Documentation]    Deletes the generated schedule and workload if they exist on the plan status page
    [Arguments]    ${user_key}    ${week_start_date}
    Login And Launch WFM Web App    user_key=${user_key}
    Navigate To RWS Schedule Week Schedule Page On Web
    Navigate To Plan Status Page From Week Schedule Page On Web
    Select Week Number On Week Schedule Page On Web    ${week_start_date}
    Clear Existing Generated Data On Batch Plan Status Page On Web

Clear Existing Generated Data On Batch Plan Status Page On Web
    [Documentation]    Clear Existing Generated Data On Batch Plan Status Page
    ...    This keyword performs prerequisite setup steps before generating and publish a schedule.
    ...    It ensures the necessary workload is generated and the schedule is created before publish.
    ...    Example usage:
    ...    | Clear Existing Generated Data On Batch Plan Status Page
    ${unpublish_is_enabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULEPAGE_UNPUBLISH_BUTTON}    enabled
    ${publish_is_enabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULEPAGE_PUBLISH_BUTTON}    enabled
    ${optimized_btn_visible}=    Is Element Visible On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_OPTIMIZE_SCH}
    ${template_btn_visible}=    Is Element Visible On Webpage    ${WEEKSCHEDULE_SCHEDULE_GENERATE_USING_TEMPLATE}

    IF    ${optimized_btn_visible}
        ${optimized_schedule_is_enabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULEPAGE_GENERATE_OPTIMIZE_SCH}
        ...    enabled
    ELSE
        VAR    ${optimized_schedule_is_enabled}=    ${False}
    END

    IF    ${template_btn_visible}
        ${template_schedule_is_enabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULE_SCHEDULE_GENERATE_USING_TEMPLATE}
        ...    enabled
    ELSE
        VAR    ${template_schedule_is_enabled}=    ${False}
    END
    ${workload_delete_is_enabled}=    Does Element State Contain Value On Webpage    ${WEEKSCHEDULEPAGE_DELETE_WORKLOAD}    enabled
    IF    ${unpublish_is_enabled}
        UnPublish Schedule On Web
        Delete Schedule And Workload On Web
    ELSE IF    ${publish_is_enabled}
        Delete Schedule And Workload On Web
    ELSE IF    ${workload_delete_is_enabled} and (${optimized_schedule_is_enabled} or ${template_schedule_is_enabled})
        Delete Workload On Web
    END

Generate Workload Via API
    [Documentation]    Triggers workload generation for a given store and date via API using api_executor (PUT with no body)
    [Arguments]    ${store}    ${week_start_date}    ${user_key}
    ${date_value}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_of_freq}=    Convert Date    ${date_value}    result_format=${resultant_format}
    ${week_start_date_formated}=    Convert To Integer    ${start_of_freq}
    ${week_start_date_formated}=    Convert To String    ${week_start_date_formated}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${GENERATE_WORKLOAD_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", STORE="${store}", WEEK_START_DATE="${week_start_date_formated}")
    ${response}=    Send A WFM Put Request    ${user_key}    ${base_url}    ${endpoint}
    Log    Response Body: ${response}
    RETURN    ${response}

Generate Schedule Via API
    [Documentation]
    ...    Triggers schedule generation for a given store and date via API using api_executor (POST with JSON body).
    ...
    ...    The ``SCHEDULE_GEN_TYPE`` sent in the request body is resolved from the ``schedule_generation_type``
    ...    config key (``Y`` = Optimized, ``N`` = Template). If the key is absent the default is ``Y``.
    ...
    ...    The caller may override the resolved value by passing ``schedule_gen_type`` explicitly.
    ...
    ...    | =Arguments= | =Description= |
    ...    | store | The store/unit ID for which to generate the schedule. |
    ...    | week_start_date | Week start date in yyyymmdd format. |
    ...    | user_key | User key for authentication. |
    ...    | schedule_gen_type | Optional override (Y=optimized, N=template). When omitted the value is read from config key ``schedule_generation_type``. |
    [Arguments]    ${store}    ${week_start_date}    ${user_key}    ${schedule_gen_type}=${NONE}
    ${base_url}=    Get Config Value    key=base_url
    IF    $schedule_gen_type is None
        ${schedule_gen_type}=    Get Config Value    key=schedule_generation_type    default=Y
        ${schedule_gen_type}=    Convert To Upper Case    ${schedule_gen_type}
    END
    Log    Schedule Gen Type: ${schedule_gen_type} Started Schedule Generation    console=yes
    ${endpoint}=    Format String    ${GENERATE_SCHEDULE_API_TEMPLATE}    ENVIRONMENT=${base_url}    STORE=${store}
    ...    WEEK_START_DATE=${week_start_date}
    ${body}=    Evaluate
    ...    {"FISCAL_YEAR": ${0}, "FISCAL_WEEK": ${0}, "SCHEDULE_GEN_TYPE": "${schedule_gen_type}"}
    # ${response}=    Send A Post Request    ${endpoint}    ${store}    ${week_start_date_formated}    body=${body}
    ${response}=    Send A WFM Post Request    ${user_key}    ${base_url}    ${endpoint}    body=${body}
    Log    Response Body: ${response}
    RETURN    ${response}

Generate Schedule Via API And Wait For Completion
    [Documentation]    Generates schedule via API and waits until batch job completes and schedule data is available.
    ...
    ...    This keyword combines schedule generation triggering with completion verification.
    ...    It ensures the batch job has completed and schedule data is reflected in the system
    ...    before proceeding with UI operations or further test steps.
    ...
    ...    *Use this keyword when:*
    ...    - Tests need to navigate to Week Schedule Page immediately after generation
    ...    - Tests need to verify schedule data in UI
    ...    - Tests perform operations on the generated schedule
    ...
    ...    *Retry Logic:*
    ...    - Polls schedule data endpoint up to 30 times
    ...    - Waits 15 seconds between attempts
    ...    - Maximum wait time: 7.5 minutes
    ...    - Fails explicitly if schedule data not available after all attempts
    ...
    ...    | =Arguments= | =Description= |
    ...    | store | Store identifier for which to generate the schedule |
    ...    | week_start_date | Week start date offset (e.g., "2_0") |
    ...    | user_key | User key for authentication |
    ...
    ...    Returns: Schedule data dictionary containing schBasicDetails with shifts and metadata
    ...
    ...    Example usage:
    ...    | ${scheduleData}= | Generate Schedule Via API And Wait For Completion | STORE1 | 2_0 | SM1_STORE1 |
    ...    | Navigate To Week Schedule Page | # Now safe - schedule data is ready |
    [Arguments]    ${store}    ${week_start_date}    ${user_key}
    # Step 1: Trigger schedule generation
    Log    Triggering schedule generation for store ${store}, week ${week_start_date}    level=INFO
    Generate Schedule Via API    ${store}    ${week_start_date}    ${user_key}
    Log    Schedule generation triggered successfully    level=INFO
    Wait For Schedule Generation To Complete    ${week_start_date}    ${user_key}

    # Step 2: Wait for batch job completion by fetching schedule data with retry logic
    Log    Waiting for batch job completion and schedule data availability...    level=INFO
    ${endpoint}    ${_}=    Prepare Shift Details Endpoint    ${week_start_date}
    ${full_response}=    Fetch Generated Schedule Data Via API On Week Schedule Page    ${endpoint}    ${week_start_date}
    ${scheduleData}=    Get From Dictionary    ${full_response}    schBasicDetails
    Log    Schedule generation completed and data is available for week ${week_start_date}    level=INFO
    RETURN    ${scheduleData}

Generate Forecast Via API
    [Documentation]    Triggers forecast generation for a given store and date via API using api_executor (POST with JSON body)
    ...
    ...    This keyword generates a weekly forecast in batch mode for the specified store and week.
    ...
    ...    | =Arguments= | =Description= |
    ...    | store | Store identifier for which to generate the forecast |
    ...    | week_start_date | Week start date offset (e.g., "2_0") |
    ...    | user_key | User key for authentication |
    ...
    ...    Returns: API response object
    ...
    ...    Example usage:
    ...    | ${response}= | Generate Forecast Via API | STORE1 | 2_0 | SM1_STORE1 |
    [Arguments]    ${store}    ${week_start_date}    ${user_key}
    ${date_value}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_of_freq}=    Convert Date    ${date_value}    result_format=${resultant_format}
    ${week_start_date_formated}=    Convert To Integer    ${start_of_freq}
    ${week_start_date_formated}=    Convert To String    ${week_start_date_formated}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${GENERATE_FORECAST_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", STORE="${store}", WEEK_START_DATE="${week_start_date_formated}")
    # Create JSON body for forecast generation
    ${body}=    Evaluate
    ...    {"FORECAST_TYPE": "WEEKLY", "locationType": "U", "fcstGenMode": "BATCH", "planType": "WEEKPLAN", "debugMode": "N"}
    ${response}=    Send A WFM Post Request    ${user_key}    ${base_url}    ${endpoint}    body=${body}
    Log    Response Body: ${response}
    RETURN    ${response}

Get Fiscal Week Number Via API
    [Documentation]    Retrieves the fiscal week number for a given week start date from the mobile weeks calendar API
    [Arguments]    ${week_start_date}    ${user_key}
    ${date_value}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_of_freq}=    Convert Date    ${date_value}    result_format=${resultant_format}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate    "${GET_FISCAL_WEEK_NUMBER_API_TEMPLATE}".format(ENVIRONMENT="${base_url}")
    # ${body}=    Evaluate    {"fetchMobileWeeksCalendar": True}
    ${body}=    Evaluate
    ...    {"appId": "STORE_MGR", "appVersion": "4.5.20", "pkgName": "com.reflexisinc.reflexissm43", "DEVICE_TOKEN" : "", "osName": "ios", "osVersion": "15.2"}
    ${response}=    Send A WFM Post Request    ${user_key}    ${base_url}    ${endpoint}    body=${body}
    ${mobile_weeks}=    Get From Dictionary    ${response}    mobileWeeksCalendar
    FOR    ${week}    IN    @{mobile_weeks}
        ${wsd}=    Get From Dictionary    ${week}    weekStartDate
        ${wsd_str}=    Convert To String    ${wsd}
        IF    '${wsd_str}' == '${start_of_freq}'
            ${fiscal_week}=    Get From Dictionary    ${week}    fiscalWeek
            RETURN    ${fiscal_week}
        END
    END
    Fail    Fiscal week not found for ${week_start_date}

Get Generated Shift Id And Schedule Status Via API
    [Documentation]    Retrieves the latest generated shift ID and store schedule published status for a given week via API.
    ...    Returns a dictionary with:
    ...    - latestGenShiftId: The latest generated shift ID
    ...    - store_schedule_published: Boolean indicating if store schedule is published
    ...    - currentScheduleStatus: Current schedule status (NOT_GENERATED, GENERATED, PUBLISHED, etc.)
    ...
    ...    | =Arguments= | =Description= |
    ...    | week_start_date | Week offset (e.g., "3_0", "0_0") |
    ...    | user_key | User credentials key for authentication |
    ...
    ...    Example usage:
    ...    | ${result}= | Get Generated Shift Id And Schedule Status Via API | 3_0 | SM1_STORE1 |
    ...    | Log | Latest Gen Shift ID: ${result}[latestGenShiftId] |
    ...    | Log | Published Status: ${result}[store_schedule_published] |
    ...    | Log | Schedule Status: ${result}[currentScheduleStatus] |
    [Arguments]    ${week_start_date}    ${user_key}
    Generate Auth Token With User Credentials    ${user_key}
    ${date_value}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_of_freq}=    Convert Date    ${date_value}    result_format=${resultant_format}
    ${week_start_date_formated}=    Convert To Integer    ${start_of_freq}
    ${week_start_date_formated}=    Convert To String    ${week_start_date_formated}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${GET_SHIFT_ID_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", WEEK_START_DATE="${week_start_date_formated}")
    ${response}=    Send A Get Request    ${endpoint}
    Log    Response Body: ${response}

    # Extract latestGenShiftId
    ${latest_gen_shift_id}=    Get From Dictionary    ${response}    latestGenShiftId

    # Extract STORE_SCHEDULE_PUBLISHED status from schedulePublishStatusMap
    ${schedule_publish_status_map}=    Get From Dictionary    ${response}    schedulePublishStatusMap
    ${store_schedule_published}=    Get From Dictionary    ${schedule_publish_status_map}    STORE_SCHEDULE_PUBLISHED

    # Derive current schedule status from available fields
    # Logic: Check if API response has currentScheduleStatus field, otherwise derive it
    ${has_status_field}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${response}    currentScheduleStatus

    IF    ${has_status_field}
        ${current_schedule_status}=    Get From Dictionary    ${response}    currentScheduleStatus
    ELSE
        # Derive status from latestGenShiftId and store_schedule_published
        ${gen_shift_id_int}=    Convert To Integer    ${latest_gen_shift_id}
        ${gen_shift_id_str}=    Convert To String    ${gen_shift_id_int}

        IF    ${gen_shift_id_int} == -1
            VAR    ${current_schedule_status}=    NOT_GENERATED
        ELSE IF    ${store_schedule_published}
            VAR    ${current_schedule_status}=    PUBLISHED
        ELSE IF    '${gen_shift_id_str}'[0] == '7'
            VAR    ${current_schedule_status}=    WEEK_IN_PROGRESS
        ELSE
            VAR    ${current_schedule_status}=    GENERATED
        END

        Log
        ...    Derived schedule status: ${current_schedule_status} (from genShiftId=${latest_gen_shift_id}, published=${store_schedule_published})
        ...    level=INFO
    END

    # Create result dictionary
    VAR    &{result}=
    ...    latestGenShiftId=${latest_gen_shift_id}
    ...    store_schedule_published=${store_schedule_published}
    ...    currentScheduleStatus=${current_schedule_status}

    Log    Latest Gen Shift ID: ${latest_gen_shift_id}
    Log    Store Schedule Published: ${store_schedule_published}
    Log    Current Schedule Status: ${current_schedule_status}

    RETURN    ${result}

Wait For Schedule Generation To Complete
    [Documentation]    Polls the schedule status API until schedule generation is complete.
    ...    Waits for schedule status to become GENERATED (or PUBLISHED if already published).
    ...
    ...    **POLLING LOGIC:**
    ...    - Polls every 2 seconds
    ...    - Maximum wait time: 2 minutes (60 iterations)
    ...    - Success conditions: Status is GENERATED, PUBLISHED, or WEEK_IN_PROGRESS
    ...    - Failure conditions: Status remains NOT_GENERATED, GENERATING, or gen_shift_id is -1 after timeout
    ...
    ...    | =Arguments= | =Description= |
    ...    | week_start_date | Week offset (e.g., "3_0", "0_0") |
    ...    | user_key | User credentials key for authentication |
    ...    | timeout_seconds | Maximum wait time in seconds (default: 120) |
    ...
    ...    Returns: Dictionary with schedule status information
    ...
    ...    Example usage:
    ...    | ${status}= | Wait For Schedule Generation To Complete | 3_0 | SM1_STORE1 |
    [Arguments]    ${week_start_date}    ${user_key}    ${timeout_seconds}=${SCHEDULE_GENERATION_TIMEOUT}

    ${timeout_numeric}=    Evaluate    '${timeout_seconds}'.rstrip('s')
    ${max_iterations}=    Evaluate    int(${timeout_numeric}) / 10
    Log    Waiting for schedule generation to complete (max wait: ${timeout_seconds}s)...    level=INFO

    FOR    ${iteration}    IN RANGE    1    ${max_iterations} + 1
        ${schedule_status}=    Get Generated Shift Id And Schedule Status Via API    ${week_start_date}    ${user_key}
        ${current_status}=    Get From Dictionary    ${schedule_status}    currentScheduleStatus
        ${gen_shift_id}=    Get From Dictionary    ${schedule_status}    latestGenShiftId
        ${gen_shift_id_int}=    Convert To Integer    ${gen_shift_id}

        Log    Poll ${iteration}/${max_iterations}: Status=${current_status}, GenShiftId=${gen_shift_id}    level=INFO

        # Check if schedule generation is complete
        IF    '${current_status}' == 'GENERATED' or '${current_status}' == 'PUBLISHED' or '${current_status}' == 'WEEK_IN_PROGRESS'
            Log    Schedule generation completed successfully. Status: ${current_status}    level=INFO
            RETURN    ${schedule_status}
        END

        # Check for valid gen_shift_id (not -1) - indicates schedule exists
        IF    ${gen_shift_id_int} != -1 and '${current_status}' != 'NOT_GENERATED'
            Log    Schedule generation appears complete. GenShiftId: ${gen_shift_id}, Status: ${current_status}    level=INFO
            RETURN    ${schedule_status}
        END

        # Still generating - wait before next poll
        IF    ${iteration} < ${max_iterations}    Sleep    2s
    END

    # Timeout reached - get final status
    ${final_status}=    Get Generated Shift Id And Schedule Status Via API    ${week_start_date}    ${user_key}
    ${final_current_status}=    Get From Dictionary    ${final_status}    currentScheduleStatus
    ${final_gen_shift_id}=    Get From Dictionary    ${final_status}    latestGenShiftId

    Fail
    ...    Schedule generation did not complete within ${timeout_seconds}s. Final status: ${final_current_status}, GenShiftId: ${final_gen_shift_id}

Publish Schedule Via API
    [Documentation]    Publishes the schedule for a given store and week start date via API
    ...    This keyword sends a GET request to publish the schedule and returns the response.
    ...    The user_type parameter typically represents the role (e.g., MANAGER, ADMIN).
    ...
    ...    | =Arguments= | =Description= |
    ...    | store | The store identifier for which to publish the schedule |
    ...    | week_start_date | The week start date (e.g., current_week_start_date, next_week_start_date) |
    ...    | user_key | The user credentials key for authentication |
    ...    | user_type | The user type/role for the publish operation (default: MANAGER) |
    ...
    ...    Example usage:
    ...    | Publish Schedule Via API | STORE1 | current_week_start_date | manager_user_key |
    ...    | Publish Schedule Via API | STORE1 | next_week_start_date | admin_user_key | ADMIN |
    [Arguments]    ${store}    ${week_start_date}    ${user_key}    ${user_type}=MANAGER
    Log    publish schedule started for unit ${store} week starting on ${week_start_date} by user type ${user_type}    console=yes
    ${date_value}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_of_freq}=    Convert Date    ${date_value}    result_format=${resultant_format}
    ${week_start_date_formated}=    Convert To Integer    ${start_of_freq}
    ${week_start_date_formated}=    Convert To String    ${week_start_date_formated}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${PUBLISH_SCHEDULE_MOBILE_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", STORE="${store}", WEEK_START_DATE="${week_start_date_formated}", USER_TYPE="${user_type}")
    ${response}=    Send A WFM Get Request    ${user_key}    ${base_url}    ${endpoint}
    Log    Response Body: ${response}
    Log    publish schedule completed for unit ${store} week starting on ${week_start_date} by user type ${user_type}    console=yes
    RETURN    ${response}

Get Shift Details Via API
    [Documentation]    Retrieves shift details for a specific associate and days.
    ...    Returns dict with gen_shift_id, shift_seq_numbers, staff_group_id.
    ...    Example: {"gen_shift_id": 62548, "shift_seq_numbers": [1,2,3]}
    [Arguments]    ${week_start_date}    ${user_key}    ${personId}    ${days_to_unallocate}
    Generate Auth Token With User Credentials    ${user_key}
    ${endpoint}    ${start_date_int}=    Prepare Shift Details Endpoint    ${week_start_date}
    ${full_response}=    Fetch Generated Schedule Data Via API On Week Schedule Page    ${endpoint}    ${week_start_date}
    ${scheduleData}=    Get From Dictionary    ${full_response}    schBasicDetails
    ${shift_details}=    Extract Shift Details On Week Schedule Page    ${scheduleData}    ${start_date_int}    ${personId}
    ...    ${days_to_unallocate}    ${week_start_date}
    RETURN    ${shift_details}

UnAllocate Required Shift Via API
    [Documentation]    Unallocates required shifts via API (POST with JSON body)
    ...    ${shift_details} should be a dictionary: {"gen_shift_id": xxx, "shift_seq_numbers": [1,2,3], "staff_group_id": "xxx"}
    [Arguments]    ${shift_details}    ${store}    ${user_key}
    VAR    @{responses}=    @{EMPTY}
    ${gen_shift_id}=    Get From Dictionary    ${shift_details}    gen_shift_id
    ${shift_seq_numbers}=    Get From Dictionary    ${shift_details}    shift_seq_numbers
    FOR    ${shift_seq_no}    IN    @{shift_seq_numbers}
        ${response}=    Unallocate Shift Via API    ${user_key}    ${store}    ${gen_shift_id}    ${shift_seq_no}
        Append To List    ${responses}    ${response}
    END
    RETURN    ${responses}

Unallocate Shift Via API
    [Documentation]    Unallocates a single shift via API (POST with JSON body)
    [Arguments]    ${user_key}    ${unit_id}    ${gen_shift_id}    ${shift_seq_no}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${UNALLOCATE_SHIFT_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", GEN_SHIFT_ID="${gen_shift_id}", STORE="${unit_id}", SHIFT_SEQ_NO="${shift_seq_no}")
    VAR    ${lock_key}=    unallocate_${user_key}
    # acquiring lock as there is a deadlock issue in TaEmpTimeWeekDB.deleteTaEmpTimeWeek
    # when multiple unallocate requests are sent simultaneously with same user
    Acquire Lock    ${lock_key}
    ${response}=    Send A WFM Post Request    ${user_key}    ${base_url}    ${endpoint}
    Release Lock    ${lock_key}
    Log    Response Body: ${response}
    RETURN    ${response}

Delete Required Open Shift Via API
    [Documentation]    Deletes open shifts via API (DELETE request)
    ...    ${shift_details} should be a dictionary: {"gen_shift_id": xxx, "shift_seq_numbers": [1,2,3], "staff_group_id": "xxx"}
    ...
    ...    Note: This keyword handles 422 errors gracefully. When unallocating shifts, some may be automatically
    ...    deleted by the system. If a shift is not found (422 error), it's logged as a warning and treated as success.
    [Arguments]    ${shift_details}    ${store}    ${user_key}
    VAR    @{responses}=    @{EMPTY}
    ${gen_shift_id}=    Get From Dictionary    ${shift_details}    gen_shift_id
    ${shift_seq_numbers}=    Get From Dictionary    ${shift_details}    shift_seq_numbers
    FOR    ${shift_seq_no}    IN    @{shift_seq_numbers}
        ${response}=    Delete Open Shift Via API    ${user_key}    ${store}    ${gen_shift_id}    ${shift_seq_no}
        Append To List    ${responses}    ${response}
    END
    RETURN    ${responses}

Delete Open Shift Via API
    [Documentation]    Deletes a single shift via API (DELETE request)
    ...    Handles 422 errors gracefully by logging a warning and treating as success.
    ...    This is particularly important for handling UnexpectedRollbackException errors
    ...    where the shift was already deleted or is being deleted by another process.
    [Arguments]    ${user_key}    ${unit_id}    ${gen_shift_id}    ${shift_seq_no}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${DELETE_OPEN_SHIFT_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", STORE="${unit_id}", GEN_SHIFT_ID="${gen_shift_id}", SHIFT_SEQ_NO="${shift_seq_no}")
    VAR    ${lock_key}=    delete_${user_key}
    # Handle case where shift was already deleted during unallocation
    Acquire Lock    ${lock_key}
    TRY
        ${response}=    Send A WFM Delete Request    ${user_key}    ${base_url}    ${endpoint}
        Log    Successfully deleted shift ${shift_seq_no}    level=INFO
    EXCEPT    *API failure with status 422*
        # Shift not found (422 status) - likely auto-deleted during unallocation or due to transaction rollback
        Log    Shift ${shift_seq_no} deletion returned 422 status (likely auto-deleted or marked for rollback). Treating as success.
        ...    level=WARN
        VAR    ${response}=    status_code=422    message=Shift already deleted    shift_seq_no=${shift_seq_no}
    EXCEPT    AS    ${error}
        Log    Unexpected error during shift deletion: ${error}    level=ERROR
        Fail    Unexpected error during shift deletion: ${error}
    FINALLY
        Release Lock    ${lock_key}
    END
    RETURN    ${response}

Delete Schedule Via API
    [Documentation]    Deletes the schedule for a given store and week start date via API (PUT request)
    ...    This keyword sends a PUT request to delete the schedule.
    ...
    ...    | =Arguments= | =Description= |
    ...    | store | The store identifier for which to delete the schedule |
    ...    | week_start_date | The week start date offset (e.g., "3_0", "0_0") |
    ...    | user_key | The user credentials key for authentication |
    ...    | schedule_iteration | schedule_iteration (default: MANAGER) |
    ...
    ...    Example usage:
    ...    | Delete Schedule Via API | STORE1 | 3_0 | SM1_STORE1 |
    [Arguments]    ${store}    ${week_start_date}    ${user_key}    ${schedule_iteration}=MANAGER

    ${date_value}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_of_freq}=    Convert Date    ${date_value}    result_format=${resultant_format}
    ${week_start_date_formated}=    Convert To Integer    ${start_of_freq}
    ${week_start_date_formated}=    Convert To String    ${week_start_date_formated}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${DELETE_SCHEDULE_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", STORE="${store}", WEEK_START_DATE="${week_start_date_formated}", SCHEDULE_ITERATION="${schedule_iteration}")
    VAR    &{EMPTY_JSON_PAYLOAD}=    &{EMPTY}
    ${response}=    Send A WFM POST Request    ${user_key}    ${base_url}    ${endpoint}    ${EMPTY_JSON_PAYLOAD}
    Log    Response Body: ${response}
    RETURN    ${response}

Delete Workload Via API
    [Documentation]    Deletes the workload for a given store and week start date via API.
    ...    This keyword sends a POST request with an empty JSON body to trigger the DELETE_WL event.
    ...
    ...    | =Arguments= | =Description= |
    ...    | store | The store identifier for which to delete the workload. |
    ...    | week_start_date | The week start date offset (e.g., "3_0", "0_0"). |
    ...    | user_key | The user credentials key for authentication. |
    ...    | schedule_iteration | Schedule iteration sent in the endpoint path (default: NONE). |
    ...
    ...    Example usage:
    ...    | Delete Workload Via API | STORE1 | 3_0 | SM1_STORE1 |
    [Arguments]    ${store}    ${week_start_date}    ${user_key}

    ${date_value}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_of_freq}=    Convert Date    ${date_value}    result_format=${resultant_format}
    ${week_start_date_formated}=    Convert To Integer    ${start_of_freq}
    ${week_start_date_formated}=    Convert To String    ${week_start_date_formated}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${DELETE_WORKLOAD_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", STORE="${store}", WEEK_START_DATE="${week_start_date_formated}")
    VAR    &{EMPTY_JSON_PAYLOAD}=    &{EMPTY}
    ${response}=    Send A WFM POST Request    ${user_key}    ${base_url}    ${endpoint}    ${EMPTY_JSON_PAYLOAD}
    Log    Response Body: ${response}
    RETURN    ${response}

Delete Schedule Via API And Wait For Completion
    [Documentation]    Deletes the schedule via API and waits until the schedule is deleted and no longer available.
    ...    This keyword combines schedule deletion with completion verification.
    ...    It ensures that after triggering the delete action, the system reflects the deleted status for the schedule before proceeding with UI operations or further test steps.
    ...    *Use this keyword when:*
    ...    - Tests need to verify deleted status in UI after deletion
    ...    - Tests perform operations that require the schedule to be deleted
    ...    *Retry Logic:*
    ...    - Polls schedule status API up to 30 times
    ...    - Waits 15 seconds between attempts
    ...    - Maximum wait time: 7.5 minutes
    ...    - Fails explicitly if schedule status does not reflect deleted after all attempts
    [Arguments]    ${store}    ${week_start_date}    ${week_offset}    ${user_key}    ${schedule_iteration}=MANAGER
    Delete Schedule Via API    ${store}    ${week_offset}    ${user_key}    ${schedule_iteration}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Schedule Not Generated For Week    ${user_key}
    ...    ${store}    ${week_start_date}

Delete Workload Via API And Wait For Completion
    [Documentation]    Deletes the workload via API and waits until the workload is no longer generated.
    ...    This keyword combines workload deletion with completion verification.
    ...    It ensures that after triggering DELETE_WL, the system reflects the workload-not-generated status before proceeding.
    ...    *Use this keyword when:*
    ...    - Tests need workload cleanup after deleting a schedule
    ...    - Tests perform operations that require workload regeneration from a clean state
    ...    *Retry Logic:*
    ...    - Polls schedule status API up to the configured number of attempts
    ...    - Waits for the configured retry interval between attempts
    ...    - Fails explicitly if workload status still shows generated after all attempts
    [Arguments]    ${store}    ${week_start_date}    ${week_offset}    ${user_key}
    Delete Workload Via API    ${store}    ${week_offset}    ${user_key}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Workload Not Generated For Week    ${user_key}
    ...    ${store}    ${week_start_date}

Unlock Schedule Via API
    [Documentation]    Unlocks the schedule for a given store and week start date via API (PUT request)
    ...    This keyword sends a PUT request to unlock the schedule from plan status page.
    ...    | =Arguments= | =Description= |
    ...    | store | The store identifier (unit id) for which to unpublish the schedule |
    ...    | week_start_date | in yyyymmdd format |
    ...    | user_key | The user credentials key for authentication |
    ...    | schedule_iteration | schedule_iteration (default: MANAGER) |
    ...    Example usage:
    ...    | Unlock Schedule Via API | STORE1 | 20260301 | SM1_STORE1 |
    [Arguments]    ${store}    ${week_start_date}    ${user_key}    ${schedule_iteration}=MANAGER
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${UNLOCK_SCHEDULE_API_TEMPLATE}".format(BASE_URL="${base_url}", STORE="${store}", WEEK_START_DATE="${week_start_date}", SCHEDULE_ITERATION="${schedule_iteration}")
    VAR    &{EMPTY_JSON_PAYLOAD}=    &{EMPTY}
    ${response}=    Send A WFM POST Request    ${user_key}    ${base_url}    ${endpoint}    ${EMPTY_JSON_PAYLOAD}
    Log    Response Body: ${response}
    RETURN    ${response}

Lock Schedule Via API
    [Documentation]    Locks the schedule for a given store and week start date via API (PUT request)
    ...    This keyword sends a PUT request to lock the schedule from plan status page.
    ...    | =Arguments= | =Description= |
    ...    | store | The store identifier (unit id) for which to lock the schedule |
    ...    | week_start_date | in yyyymmdd format |
    ...    | user_key | The user credentials key for authentication |
    ...    | schedule_iteration | schedule_iteration (default: MANAGER) |
    ...    Example usage:
    ...    | Lock Schedule Via API | STORE1 | 20260301 | SM1_STORE1 |
    [Arguments]    ${store}    ${week_start_date}    ${user_key}    ${schedule_iteration}=MANAGER
    Log    Locking schedule for store ${store}, week ${week_start_date} Started    console=yes
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${LOCK_SCHEDULE_API_TEMPLATE}".format(BASE_URL="${base_url}", STORE="${store}", WEEK_START_DATE="${week_start_date}", SCHEDULE_ITERATION="${schedule_iteration}")
    VAR    &{EMPTY_JSON_PAYLOAD}=    &{EMPTY}
    ${response}=    Send A WFM POST Request    ${user_key}    ${base_url}    ${endpoint}    ${EMPTY_JSON_PAYLOAD}
    Log    Response Body: ${response}
    RETURN    ${response}

Lock Schedule Via API And Wait For Completion
    [Documentation]    Locks the schedule via API and waits until the schedule status reflects the locked state.
    ...    This keyword combines schedule locking with completion verification.
    ...    It ensures that after triggering the lock action, the system reflects the locked status for the schedule before proceeding with UI operations or further test steps.
    ...    *Use this keyword when:*
    ...    - Tests need to verify locked status in UI after locking
    ...    - Tests perform operations that require the schedule to be locked
    ...    *Retry Logic:*
    ...    - Polls schedule status API up to 30 times
    ...    - Waits 15 seconds between attempts
    ...    - Maximum wait time: 7.5 minutes
    ...    - Fails explicitly if schedule status does not reflect locked after all attempts
    [Arguments]    ${store}    ${week_start_date}    ${user_key}    ${schedule_iteration}=MANAGER
    Log    Lock schedule is enabled. Locking schedule before publication.    console=yes
    Lock Schedule Via API    ${store}    ${week_start_date}    ${user_key}    ${schedule_iteration}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be Can Publish Schedule For Week    ${user_key}
    ...    ${store}    ${week_start_date}
    Log    Schedule locked for store ${store}, week ${week_start_date}    console=yes

Unlock Schedule Via API And Wait For Completion
    [Documentation]    Unlocks the schedule via API and waits until the schedule status reflects the unlocked state.
    ...    This keyword combines schedule unlocking with completion verification.
    ...    It ensures that after triggering the unlock action, the system reflects the unlocked status for the schedule before proceeding with UI operations or further test steps.
    ...    *Use this keyword when:*
    ...    - Tests need to verify unlocked status in UI after unlocking
    ...    - Tests perform operations that require the schedule to be unlocked
    ...    *Retry Logic:*
    ...    - Polls schedule status API up to 30 times
    ...    - Waits 15 seconds between attempts
    ...    - Maximum wait time: 7.5 minutes
    ...    - Fails explicitly if schedule status does not reflect unlocked after all attempts
    [Arguments]    ${store}    ${week_start_date}    ${user_key}    ${schedule_iteration}=MANAGER
    Log    Unlocking schedule for store ${store}, week ${week_start_date} Started    console=yes
    Unlock Schedule Via API    ${store}    ${week_start_date}    ${user_key}    ${schedule_iteration}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Schedule Unlocked For Week    ${user_key}
    ...    ${store}    ${week_start_date}
    Log    Schedule unlocked for store ${store}, week ${week_start_date}    console=yes

Unit Status Should Be Can Publish Schedule For Week
    [Documentation]    Verifies that the schedule status for a given week allows publishing (i.e., status is GENERATED and not already published).
    ...    This keyword checks the current schedule status via API and asserts that it is in a state where publishing can be performed.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The user credentials key for authentication |
    ...    | store | The store identifier |
    ...    | week_start_date | The week start date offset (e.g., "3_0", "0_0") |
    ...
    ...    Example usage:
    ...    | Unit Status Should Be Can Publish Schedule For Week | SM1_STORE1 | STORE1 | 3_0 |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Be True    ${unit_schedule_states_map}[can_publish_schedule]
    ...    msg=Schedule not able to publish for week starting on ${week_start_date} for unit ${unit_id}

Unpublish Schedule Via API
    [Documentation]    Unpublishes the schedule for a given store and week start date via API (PUT request)
    ...    This keyword sends a PUT request to unpublish the schedule from plan status page.
    ...    | =Arguments= | =Description= |
    ...    | store | The store identifier for which to unpublish the schedule |
    ...    | week_start_date | The week start date offset (e.g., "3_0", "0_0") |
    ...    | user_key | The user credentials key for authentication |
    ...    | schedule_iteration | schedule_iteration (default: MANAGER) |
    ...    Example usage:
    ...    | Unpublish Schedule Via API | STORE1 | 3_0 | SM1_STORE1 |
    [Arguments]    ${store}    ${week_start_date}    ${user_key}    ${schedule_iteration}=MANAGER
    ${date_value}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_of_freq}=    Convert Date    ${date_value}    result_format=${resultant_format}
    ${week_start_date_formated}=    Convert To Integer    ${start_of_freq}
    ${week_start_date_formated}=    Convert To String    ${week_start_date_formated}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${UNPUBLISH_SCHEDULE_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", STORE="${store}", WEEK_START_DATE="${week_start_date_formated}", SCHEDULE_ITERATION="${schedule_iteration}")
    VAR    &{EMPTY_JSON_PAYLOAD}=    &{EMPTY}
    ${response}=    Send A WFM POST Request    ${user_key}    ${base_url}    ${endpoint}    ${EMPTY_JSON_PAYLOAD}
    Log    Response Body: ${response}
    RETURN    ${response}

Unpublish Schedule And Wait For Completion Via API
    [Documentation]    Unpublishes the schedule via API and waits until the schedule status reflects the unpublished state.
    ...    This keyword combines schedule unpublishing with completion verification.
    ...    It ensures that after triggering the unpublish action, the system reflects the unpublished status for the schedule before proceeding with UI operations or further test steps.
    ...    *Use this keyword when:*
    ...    - Tests need to verify unpublished status in UI after unpublishing
    ...    - Tests perform operations that require the schedule to be unpublished
    ...    *Retry Logic:*
    ...    - Polls schedule status API up to 30 times
    ...    - Waits 15 seconds between attempts
    ...    - Maximum wait time: 7.5 minutes
    ...    - Fails explicitly if schedule status does not reflect unpublished after all attempts
    [Arguments]    ${store}    ${week_start_date}    ${week_offset}    ${user_key}    ${schedule_iteration}=MANAGER
    Log    Unpublishing schedule for store ${store}, week ${week_start_date} Started    console=yes
    Unpublish Schedule Via API    ${store}    ${week_offset}    ${user_key}    ${schedule_iteration}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Schedule Unpublished For Week    ${user_key}
    ...    ${store}    ${week_start_date}
    Log    Schedule unpublished for store ${store}, week ${week_start_date}    console=yes

Clear Existing Schedule Based On Status Via API
    [Documentation]    Checks the schedule status and conditionally unpublishes/deletes the schedule based on latestGenShiftId and publish status.
    ...
    ...    Logic:
    ...    - If latestGenShiftId != -1 AND store_schedule_published = true → Unpublish then Delete Schedule
    ...    - If latestGenShiftId != -1 AND store_schedule_published = false → Delete Schedule only
    ...    - If latestGenShiftId = -1 → Skip (no schedule exists)
    ...
    ...    | =Arguments= | =Description= |
    ...    | store | The store identifier |
    ...    | week_start_date | The week start date in yyyymmdd format |
    ...    | week_offset | The week start date offset (e.g., "3_0", "0_0") |
    ...    | schedule_status | Schedule status dictionary from Get Generated Shift Id And Schedule Status Via API |
    ...    | user_key | The user credentials key for authentication |
    ...    | user_type | The user type/role (default: MANAGER) |
    ...
    ...    Example usage:
    ...    | ${schedule_status}= | Get Generated Shift Id And Schedule Status Via API | 3_0 | SM1_STORE1 |
    ...    | Clear Existing Schedule Based On Status Via API | STORE1 | 20260301 | 3_0 | ${schedule_status} | SM1_STORE1 |
    [Arguments]    ${store}    ${week_start_date}    ${week_offset}    ${schedule_status}    ${user_key}    ${user_type}=MANAGER
    # Extract schedule status from provided dictionary
    ${latest_gen_shift_id}=    Get From Dictionary    ${schedule_status}    latestGenShiftId
    ${is_published}=    Get From Dictionary    ${schedule_status}    store_schedule_published
    Log    Latest Gen Shift ID: ${latest_gen_shift_id}
    Log    Store Schedule Published: ${is_published}
    # Convert to integer for comparison
    ${gen_shift_id_int}=    Convert To Integer    ${latest_gen_shift_id}
    # Check conditions and perform appropriate actions
    IF    ${gen_shift_id_int} != -1 and ${is_published}
        Log    Schedule exists and is published. Unpublishing then deleting...    level=INFO
        Unpublish Schedule And Wait For Completion Via API    ${store}    ${week_start_date}    ${week_offset}    ${user_key}
        ...    ${user_type}
        Delete Schedule Via API And Wait For Completion    ${store}    ${week_start_date}    ${week_offset}    ${user_key}    ${user_type}
        Log    Schedule unpublished and deleted successfully    level=INFO
    ELSE IF    ${gen_shift_id_int} != -1 and not ${is_published}
        Log    Schedule exists but is not published. Deleting schedule...    level=INFO
        Delete Schedule Via API And Wait For Completion    ${store}    ${week_start_date}    ${week_offset}    ${user_key}    ${user_type}
        Log    Schedule deleted successfully    level=INFO
    ELSE IF    ${gen_shift_id_int} == -1
        Log    No schedule exists (latestGenShiftId = -1). Skipping deletion.    level=WARN
    ELSE
        Log    Unexpected condition: gen_shift_id=${gen_shift_id_int}, is_published=${is_published}    level=WARN
    END

Resolve Day Value
    [Documentation]    Resolves day value from template - supports both numeric (0-6) and "today" keyword.
    ...
    ...    Supported values:
    ...    - "today" - Current day relative to week start date
    ...    - Numeric values 0-6 (Sunday=0, Monday=1, ... Saturday=6)
    ...
    ...    | =Arguments= | =Description= |
    ...    | day_value | Day value from template (can be number 0-6 or string "today") |
    ...    | week_start_date | Week start date offset (e.g., "3_0") |
    ...
    ...    Returns: Integer day number (0-6)
    ...
    ...    Example:
    ...    | ${day}= | Resolve Day Value | today | 0_0 |
    ...    | ${day}= | Resolve Day Value | 1 | 3_0 |
    [Arguments]    ${day_value}    ${week_start_date}
    # Convert day_value to string for comparison
    ${day_str}=    Convert To String    ${day_value}
    # Check if it's "today" keyword
    IF    '${day_str}' == 'today'
        # Calculate today's day number relative to week start
        ${week_start_date_formated}=    Calculate Date From Week Day Offset    ${week_start_date}
        ${today_date}=    Get Current Date
        ${day_diff_seconds}=    Subtract Date From Date    ${today_date}    ${week_start_date_formated}    result_format=number
        # Convert seconds to days (86400 seconds = 1 day)
        ${day_number}=    Evaluate    int(${day_diff_seconds} / 86400)
        Log    Resolved 'today' to day ${day_number} in week ${week_start_date}
        RETURN    ${day_number}
    ELSE
        # It's a numeric value, just convert and return
        ${day_number}=    Convert To Integer    ${day_value}
        RETURN    ${day_number}
    END

Prepare Shift API Request Body
    [Documentation]    Prepares the JSON body for adding a shift via API.
    ...    Takes shift details, calculates target date, and constructs the request payload.
    [Arguments]    ${shift}    ${personId}    ${staff_group_id}    ${week_start_date_obj}    ${day}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_time}=    Get From Dictionary    ${shift}    start_time
    ${end_time}=    Get From Dictionary    ${shift}    end_time
    ${formatted_start_time}=    Convert Time From 24 Hour To 12 Hour Format For Web    ${start_time}
    ${formatted_end_time}=    Convert Time From 24 Hour To 12 Hour Format For Web    ${end_time}
    ${start_minutes}=    Convert Time To Minutes    ${formatted_start_time}
    ${end_minutes}=    Convert Time To Minutes    ${formatted_end_time}
    ${duration}=    Evaluate    ${end_minutes} - ${start_minutes}
    # Calculate target date correctly using the pre-calculated week_start_date_obj
    ${target_date_obj}=    Add Time To Date    ${week_start_date_obj}    ${day}d
    ${target_date_formatted}=    Convert Date    ${target_date_obj}    result_format=${resultant_format}
    ${target_date_int}=    Convert To Integer    ${target_date_formatted}
    ${target_date_str}=    Convert To String    ${target_date_int}
    Log
    ...    Target date calculation: week_start_date_offset=${week_start_date_obj}, day_offset=${day}, calculated_target_date=${target_date_str} (format: YYYYMMDD)
    ${personId_int}=    Convert To Integer    ${personId}
    ${duration_int}=    Convert To Integer    ${duration}
    ${start_minutes_int}=    Convert To Integer    ${start_minutes}
    ${wtask}=    Evaluate
    ...    {"activityType": "U", "duration": ${duration_int}, "projectSkey": 0, "rolePreference": 1, "staffGroupId": "${staff_group_id}", "startTime": ${start_minutes_int}, "taskId": 0, "taskSkey": 0}
    ${body}=    Evaluate
    ...    {"applyBreakRules": "DEFAULT", "assignedTo": ${personId_int}, "dedicated": False, "duration": ${duration_int}, "reasonCd": None, "shiftLock": None, "shiftSource": "M", "staffGroupId": "${staff_group_id}", "startDate": ${target_date_int}, "startDateSkey": ${target_date_int}, "startTime": ${start_minutes_int}, "wtasks": [${wtask}]}
    RETURN    ${body}

Execute Add Shift API Call
    [Documentation]    Executes the Add Shift API call with retry logic for transient errors.
    ...    Uses Wait Until Keyword Succeeds with retry values derived from the default batch plan config:
    ...    - max_attempts divided by 10 (e.g. 30 / 10 = 3 attempts)
    ...    - intervals divided by 15 to get seconds (e.g. 15 / 15 = 1s interval)
    ...    This avoids hardcoding while keeping the retry scope small and proportional.
    ...    Returns the API response.
    [Arguments]    ${endpoint}    ${body}
    ${batch_plan_data}=    Get Batch Plan Data    template_name=default
    ${retry_attempts}=    Evaluate    int(${batch_plan_data}[max_attempts] / 10)
    ${retry_interval_secs}=    Evaluate    int(${batch_plan_data}[intervals] / 15)
    ${response}=    Wait Until Keyword Succeeds    ${retry_attempts}x    ${retry_interval_secs}s
    ...    Send A Post Request    ${endpoint}    body=${body}
    Log    Response Body: ${response}
    RETURN    ${response}

Calculate Week Progress Info
    [Documentation]    Calculates the current day number within the week and determines if the week is in progress.
    ...    Returns a dictionary with current_day_number and is_week_in_progress keys.
    [Arguments]    ${week_start_date}
    ${week_start_date_obj}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${today_date}=    Get Current Date
    ${day_diff_seconds}=    Subtract Date From Date    ${today_date}    ${week_start_date_obj}    result_format=number
    ${current_day_number}=    Evaluate    int(${day_diff_seconds} / 86400)
    ${is_week_in_progress}=    Evaluate    0 <= ${current_day_number} <= 6
    VAR    &{week_progress_info}=    current_day_number=${current_day_number}    is_week_in_progress=${is_week_in_progress}
    RETURN    ${week_progress_info}

Get Or Fetch Shift Details
    [Documentation]    Gets shift details (gen_shift_id and staff_group_id) from provided shift_details parameter
    ...    or fetches them via API if shift_details is None.
    ...    Returns a dictionary with gen_shift_id and staff_group_id keys.
    [Arguments]    ${shift_details}    ${week_start_date}    ${user_key}    ${personId}
    IF    ${shift_details} != ${None}
        ${gen_shift_id}=    Get From Dictionary    ${shift_details}    gen_shift_id
        ${staff_group_id}=    Get From Dictionary    ${shift_details}    staff_group_id
    ELSE
        ${temp_shift_details}=    Get Shift Details Via API    ${week_start_date}    ${user_key}
        ...    ${personId}    [0]
        ${gen_shift_id}=    Get From Dictionary    ${temp_shift_details}    gen_shift_id
        ${staff_group_id}=    Get From Dictionary    ${temp_shift_details}    staff_group_id
    END
    VAR    &{result}=    gen_shift_id=${gen_shift_id}    staff_group_id=${staff_group_id}
    RETURN    ${result}

Resolve Missing Gen Shift Id
    [Documentation]    Attempts to resolve missing gen_shift_id from schedule-level data.
    ...    Returns the gen_shift_id if found, or None if not available.
    ...    Logs error and returns None if gen_shift_id cannot be retrieved.
    [Arguments]    ${gen_shift_id}    ${scheduleData}
    IF    $gen_shift_id == $None
        ${gen_shift_id}=    Extract Gen Shift Id From Schedule Level    ${scheduleData}
        IF    $gen_shift_id != $None
            Log    Successfully retrieved gen_shift_id from schedule level: ${gen_shift_id}    level=INFO
        ELSE
            Log    Cannot add shifts: gen_shift_id is not available from schedule-level data.    level=ERROR
            RETURN    ${None}
        END
    END
    RETURN    ${gen_shift_id}

Resolve Missing Staff Group Id
    [Documentation]    Attempts to resolve missing staff_group_id from schedule-level data or associate details.
    ...    Returns the staff_group_id if found, or None if not available.
    ...    Logs error and returns None if staff_group_id cannot be retrieved.
    [Arguments]    ${staff_group_id}    ${scheduleData}    ${full_response}    ${personId}
    IF    $staff_group_id == $None
        ${staff_group_id}=    Extract Staff Group Id From Schedule Level    ${scheduleData}
        IF    $staff_group_id == $None
            ${has_associate_details}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${full_response}
            ...    associateAdvDetails
            IF    ${has_associate_details}
                ${associateAdvDetails}=    Get From Dictionary    ${full_response}    associateAdvDetails
                FOR    ${associate}    IN    @{associateAdvDetails}
                    ${associate_person_id}=    Get From Dictionary    ${associate}    personId
                    IF    ${associate_person_id} == ${personId}
                        ${staff_group_id}=    Get From Dictionary    ${associate}    primaryStaffGroupId
                        Log    Successfully retrieved staff_group_id from associateAdvDetails: ${staff_group_id}    level=INFO
                        BREAK
                    END
                END
            END
        END
        IF    $staff_group_id != $None
            Log    Successfully retrieved staff_group_id from schedule level: ${staff_group_id}    level=INFO
        ELSE
            Log    Cannot add shifts: staff_group_id is not available from schedule-level data.    level=ERROR
            RETURN    ${None}
        END
    END
    RETURN    ${staff_group_id}

Resolve Missing Shift Details From Schedule Level
    [Documentation]    Fallback logic to fetch missing gen_shift_id and staff_group_id from schedule-level data.
    ...    Returns a dictionary with gen_shift_id and staff_group_id, or None values if retrieval fails.
    [Arguments]    ${gen_shift_id}    ${staff_group_id}    ${week_start_date}    ${user_key}    ${personId}
    IF    $gen_shift_id == $None or $staff_group_id == $None
        Log
        ...    WARNING: gen_shift_id=${gen_shift_id}, staff_group_id=${staff_group_id} are None. This typically occurs when schedule is generated but contains no shifts yet. Attempting to fetch from schedule-level data ...
        ...    level=WARN
        Generate Auth Token With User Credentials    ${user_key}
        ${endpoint}    ${_}=    Prepare Shift Details Endpoint    ${week_start_date}
        ${full_response}=    Fetch Generated Schedule Data Via API On Week Schedule Page    ${endpoint}    ${week_start_date}
        ${scheduleData}=    Get From Dictionary    ${full_response}    schBasicDetails
        ${gen_shift_id}=    Resolve Missing Gen Shift Id    ${gen_shift_id}    ${scheduleData}
        IF    $gen_shift_id == $None
            VAR    &{result}=    gen_shift_id=${None}    staff_group_id=${None}
            RETURN    ${result}
        END
        ${staff_group_id}=    Resolve Missing Staff Group Id    ${staff_group_id}    ${scheduleData}    ${full_response}    ${personId}
        IF    $staff_group_id == $None
            VAR    &{result}=    gen_shift_id=${None}    staff_group_id=${None}
            RETURN    ${result}
        END
    END
    VAR    &{result}=    gen_shift_id=${gen_shift_id}    staff_group_id=${staff_group_id}
    RETURN    ${result}

Add Single Shift Via API
    [Documentation]    Adds a single shift via API after resolving the day value and checking for past days.
    ...    Returns the API response or None if shift is skipped.
    ...
    ...    Arguments:
    ...    - shift: Shift data dictionary containing day, start_time, end_time, etc.
    ...    - personId: Employee/person identifier
    ...    - staff_group_id: Staff group identifier
    ...    - store: Store identifier
    ...    - gen_shift_id: Generated shift identifier
    ...    - user_key: User credentials key for authentication
    ...    - week_info: Dictionary containing week-related information with keys:
    ...    - week_start_date_obj: Week start date as datetime object
    ...    - week_start_date: Week start date string (e.g., "0_0", "1_0")
    ...    - is_week_in_progress: Boolean indicating if week is in progress
    ...    - current_day_number: Current day number (0-6) for week in progress
    [Arguments]    ${shift}    ${personId}    ${staff_group_id}    ${store}    ${gen_shift_id}    ${user_key}    ${week_info}
    ${week_start_date}=    Get From Dictionary    ${week_info}    week_start_date
    ${week_start_date_obj}=    Get From Dictionary    ${week_info}    week_start_date_obj
    ${is_week_in_progress}=    Get From Dictionary    ${week_info}    is_week_in_progress
    ${current_day_number}=    Get From Dictionary    ${week_info}    current_day_number
    ${day_from_template}=    Get From Dictionary    ${shift}    day
    ${day}=    Resolve Day Value    ${day_from_template}    ${week_start_date}
    IF    ${is_week_in_progress} and ${day} < ${current_day_number}
        Log    Skipping shift addition for day ${day} (past day in week in progress, current day: ${current_day_number})    level=WARN
        RETURN    ${None}
    END
    ${body}=    Prepare Shift API Request Body    ${shift}    ${personId}    ${staff_group_id}    ${week_start_date_obj}    ${day}
    Generate Auth Token With User Credentials    ${user_key}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${ADD_SHIFT_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", STORE="${store}", GEN_SHIFT_ID="${gen_shift_id}")
    ${response}=    Execute Add Shift API Call    ${endpoint}    ${body}
    RETURN    ${response}

Add Shift For Days Via API
    [Documentation]    Adds shifts for a list of shift objects via API (POST with JSON body)
    ...    If shift_details is provided (a dictionary with gen_shift_id and staff_group_id),
    ...    it will reuse those details instead of fetching them again via API.
    ...    The gen_shift_id and staff_group_id are common for all shifts in the week.
    ...    Supports both numeric day values (0-6) and "today" keyword.
    ...    For week in progress, skips adding shifts on past days (before current day).
    [Arguments]    ${shifts}    ${personId}    ${store}    ${user_key}    ${week_start_date}    ${shift_details}=${None}
    VAR    @{responses}=    @{EMPTY}
    ${week_start_date_obj}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${week_progress_info}=    Calculate Week Progress Info    ${week_start_date}
    ${current_day_number}=    Get From Dictionary    ${week_progress_info}    current_day_number
    ${is_week_in_progress}=    Get From Dictionary    ${week_progress_info}    is_week_in_progress
    ${fetched_shift_details}=    Get Or Fetch Shift Details    ${shift_details}    ${week_start_date}    ${user_key}    ${personId}
    ${gen_shift_id}=    Get From Dictionary    ${fetched_shift_details}    gen_shift_id
    ${staff_group_id}=    Get From Dictionary    ${fetched_shift_details}    staff_group_id
    ${resolved_shift_details}=    Resolve Missing Shift Details From Schedule Level    ${gen_shift_id}    ${staff_group_id}
    ...    ${week_start_date}    ${user_key}    ${personId}
    ${gen_shift_id}=    Get From Dictionary    ${resolved_shift_details}    gen_shift_id
    ${staff_group_id}=    Get From Dictionary    ${resolved_shift_details}    staff_group_id
    IF    $gen_shift_id == $None or $staff_group_id == $None
        RETURN    @{EMPTY}
    END
    VAR    &{week_info}=
    ...    week_start_date_obj=${week_start_date_obj}
    ...    week_start_date=${week_start_date}
    ...    is_week_in_progress=${is_week_in_progress}
    ...    current_day_number=${current_day_number}
    FOR    ${shift}    IN    @{shifts}
        ${response}=    Add Single Shift Via API    ${shift}    ${personId}    ${staff_group_id}    ${store}
        ...    ${gen_shift_id}    ${user_key}    ${week_info}
        IF    ${response} != ${None}
            Append To List    ${responses}    ${response}
        END
    END
    RETURN    ${responses}

Set Week In Progress Copy For Current Week
    [Documentation]    Sets up a week in progress copy ONLY for the current week (week_start_date="0_0").
    ...    For other weeks, this keyword does nothing.
    ...    | =Arguments= | =Description= |
    ...    | store_id | Store identifier |
    ...    | week_start_date | Week start date (only "0_0" triggers setup) |
    ...    | store_manager_user_key | Manager's user key for API calls |
    ...
    ...    Workflow for week 0_0:
    ...    1. Check if gen_shift_id starts with 7 (WIP copy already exists)
    ...    2. If gen_shift_id starts with 7: Skip all setup (already configured)
    ...    3. If gen_shift_id does NOT start with 7:
    ...    - Clear existing schedule based on status
    ...    - Generate forecast
    ...    - Generate workload
    ...    - Generate schedule
    ...    - Publish schedule
    ...    - Generate WIP copy for published week
    ...
    ...    Example usage:
    ...    | Set Week In Progress Copy For Current Week | STORE1 | 0_0 | SM1_STORE1 |
    [Arguments]    ${store_id}    ${week_start_date}    ${store_manager_user_key}
    # Week in progress copy setup is ONLY applicable for week 0_0 (current week)
    IF    '${week_start_date}' == '0_0'
        Log    Setting up Week in Progress copy for current week (0_0)
        ${schedule_status}=    Get Generated Shift Id And Schedule Status Via API    ${week_start_date}    ${store_manager_user_key}
        ${gen_shift_id}=    Get From Dictionary    ${schedule_status}    latestGenShiftId
        ${gen_shift_id_int}=    Convert To Integer    ${gen_shift_id}
        ${gen_shift_id_str}=    Convert To String    ${gen_shift_id_int}
        # Check if gen_shift_id starts with 7 (week in progress copy already exists)
        IF    '${gen_shift_id_str}' != '-1' and '${gen_shift_id_str}'[0] == '7'
            Log    Gen Shift ID starts with 7 (${gen_shift_id_int}). Week in Progress copy already exists. Skipping all setup steps.
            ...    level=WARN
        ELSE
            Log    Gen Shift ID does not start with 7 (${gen_shift_id_int}). Proceeding with full WIP setup.
            Clear Existing Schedule Based On Status Via API    ${store_id}    ${week_start_date}    ${schedule_status}
            ...    ${store_manager_user_key}
            Generate Forecast Via API    ${store_id}    ${week_start_date}    ${store_manager_user_key}
            Generate Workload Via API    ${store_id}    ${week_start_date}    ${store_manager_user_key}
            Generate Schedule Via API And Wait For Completion    ${store_id}    ${week_start_date}    ${store_manager_user_key}
            Publish Schedule Via API    ${store_id}    ${week_start_date}    ${store_manager_user_key}
            Generate WIP Copy For Published Week On Week Schedule Page On Web    ${store_manager_user_key}
            Log    Week in Progress copy setup completed successfully for week 0_0
        END
    ELSE
        Log    Week in Progress copy setup is ONLY applicable for week 0_0. Current week is ${week_start_date}. Skipping.    level=WARN
    END

Setup Schedule For Week With Multiple Associates
    [Documentation]    Week-based schedule setup for associates.
    ...    Generates schedule ONCE, processes all associates.
    ...    Workflow:
    ...    0. Clear existing schedule
    ...    1. Generate forecast (ONCE)
    ...    2. Generate workload (ONCE)
    ...    3. Generate schedule (ONCE) - conditional
    ...    4. Process shift modifications for associates (conditional - requires modify_shifts_required=True)
    ...    5. Process pre-publish unallocation (conditional - requires pre_publish_un_allocation=True)
    ...    6. Publish schedule (ONCE) - conditional
    ...    Args: store_id, week_start_date, manager_key,
    ...    users, publish_schedule, generate_schedule, modify_shifts_required, pre_publish_un_allocation
    ...    User: {"ess_user_key": "ESS4", "edit_shift": true, "days_to_unallocate":
    ...    [0-6], "shifts_to_add": [{...}],
    ...    "required_un_allocation_before_publish": true,
    ...    "add_shift_to_be_unallocated": [6],
    ...    "days_to_unallocate_before_publish": [6]}
    ...    Example:
    ...    | ${d}= | Get Schedule Generation Setup Data | 3_0 |
    ...    | Setup Schedule For Week With Multiple Associates |
    ...    | ... | ${d}[store_id] | ${d}[week_start_date] |
    ...    | ... | ${d}[manager_key] | ${d}[users] |
    ...    | ... | modify_shifts_required=${d}[modify_shifts_required] |
    ...    | ... | pre_publish_un_allocation=${d}[pre_publish_un_allocation] |
    [Arguments]    ${store_id}
    ...    ${week_start_date}
    ...    ${store_manager_user_key}
    ...    ${users}
    ...    ${schedule_options}=${None}
    ${publish_schedule}=    Get From Dictionary    ${schedule_options}    publish_schedule    default=${True}
    ${generate_schedule}=    Get From Dictionary    ${schedule_options}    generate_schedule    default=${True}
    ${modify_shifts_required}=    Get From Dictionary    ${schedule_options}    modify_shifts_required    default=${True}
    ${pre_publish_un_allocation}=    Get From Dictionary    ${schedule_options}    pre_publish_un_allocation    default=${False}
    ${is_dynamic_user}=    Get From Dictionary    ${schedule_options}    is_dynamic_user    default=${False}
    Set Week In Progress Copy For Current Week    ${store_id}    ${week_start_date}    ${store_manager_user_key}
    ${schedule_status}=    Get Generated Shift Id And Schedule Status Via API    ${week_start_date}    ${store_manager_user_key}
    ${gen_shift_id}=    Get From Dictionary    ${schedule_status}    latestGenShiftId
    ${gen_shift_id_int}=    Convert To Integer    ${gen_shift_id}
    ${gen_shift_id_str}=    Convert To String    ${gen_shift_id_int}
    # Check if gen_shift_id starts with 7 (week in progress copy)
    IF    '${gen_shift_id_str}' != '-1' and '${gen_shift_id_str}'[0] == '7'
        Log
        ...    Gen Shift ID starts with 7 (${gen_shift_id_int}). This is a week in progress copy. Skipping schedule clear, workload, and schedule generation.
        ...    level=WARN
    ELSE
        Clear Existing Schedule Based On Status Via API    ${store_id}    ${week_start_date}    ${schedule_status}
        ...    ${store_manager_user_key}
        Generate Forecast Via API    ${store_id}    ${week_start_date}    ${store_manager_user_key}
        Generate Workload Via API    ${store_id}    ${week_start_date}    ${store_manager_user_key}
        IF    ${generate_schedule}
            Generate Schedule Via API And Wait For Completion    ${store_id}    ${week_start_date}    ${store_manager_user_key}
        ELSE
            Log    Skipping schedule generation as per template configuration (generate_schedule=False)    level=WARN
        END
    END
    IF    ${modify_shifts_required}
        Process Shift Modifications For Associates    ${users}    ${week_start_date}    ${store_id}    ${store_manager_user_key}
        ...    ${is_dynamic_user}
    ELSE
        Log    Skipping shift modifications as per template configuration (modify_shifts_required=False)    level=WARN
    END
    IF    ${pre_publish_un_allocation}
        Process Pre-Publish Unallocation For Associates    ${users}    ${week_start_date}    ${store_id}    ${store_manager_user_key}
        ...    ${is_dynamic_user}
    END
    IF    ${publish_schedule} and '${gen_shift_id_str}'[0] != '7'
        # CRITICAL: Wait for schedule generation to complete before publishing
        # Wait For Schedule Generation To Complete    ${week_start_date}    ${store_manager_user_key}

        Publish Schedule Via API    ${store_id}    ${week_start_date}    ${store_manager_user_key}
    ELSE
        IF    not ${publish_schedule}
            Log    Skipping schedule publish as per template configuration (publish_schedule=False)    level=WARN
        ELSE IF    '${gen_shift_id_str}'[0] == '7'
            Log    Skipping schedule publish - week in progress copy (gen_shift_id starts with 7: ${gen_shift_id_int})    level=WARN
        END
    END
    ${user_count}=    Get Length    ${users}
    Log    Schedule setup completed for week ${week_start_date} with ${user_count} associates

Process Shift Modifications For Associates
    [Documentation]    Processes shift modifications (unallocate, delete, add) for all associates.
    ...    This keyword:
    ...    1. Iterates through all users
    ...    2. For each user, checks if edit_shift flag is True
    ...    3. If True: Gets shift details, unallocates existing shifts, deletes open shifts, and adds new shifts
    ...    4. If False: Skips shift modifications for that user
    ...    Args:
    ...    - users: List of user dictionaries, each containing:
    ...    - ess_user_key: User key for the associate (required)
    ...    - edit_shift: Boolean flag to control shift modifications for this user (required)
    ...    - days_to_unallocate: List of day indices (0-6) to unallocate (required)
    ...    - shifts_to_add: List of shift dictionaries with day, start_time, end_time (required)
    ...    - week_start_date: Start date of the week
    ...    - store_id: Store identifier
    ...    - store_manager_user_key: Manager's user key for API calls
    [Arguments]    ${users}    ${week_start_date}    ${store_id}    ${store_manager_user_key}    ${is_dynamic_user}=False
    FOR    ${user_data}    IN    @{users}
        Log    Processing associate: ${user_data}[ess_user_key]
        ${ess_user}=    Get User With Person Id Fallback    user_key=${user_data}[ess_user_key]    is_dynamic_user=${is_dynamic_user}
        ${modify_shift}=    Get From Dictionary    ${user_data}    edit_shift
        IF    ${modify_shift}
            ${shift_details}=    Get Shift Details Via API    ${week_start_date}
            ...    ${store_manager_user_key}    ${ess_user}[personId]    ${user_data}[days_to_unallocate]
            ${shift_seq_numbers}=    Get From Dictionary    ${shift_details}    shift_seq_numbers
            ${seq_count}=    Get Length    ${shift_seq_numbers}
            IF    ${seq_count} > 0
                UnAllocate Required Shift Via API    ${shift_details}    ${store_id}    ${store_manager_user_key}
                Delete Required Open Shift Via API    ${shift_details}    ${store_id}    ${store_manager_user_key}
            ELSE
                Log    No existing shifts found for ${user_data}[ess_user_key], skipping unallocation and deletion    level=WARN
            END
            IF    len(${user_data}[shifts_to_add]) > 0
                Add Shift For Days Via API    shifts=${user_data}[shifts_to_add]    personId=${ess_user}[personId]
                ...    store=${store_id}    user_key=${store_manager_user_key}
                ...    week_start_date=${week_start_date}    shift_details=${shift_details}
            END
            ${shift_count}=    Get Length    ${user_data}[shifts_to_add]
            Log    Completed shift modifications for ${user_data}[ess_user_key]: added ${shift_count} shifts
        ELSE
            Log    Skipping shift modification for ${user_data}[ess_user_key] (edit_shift=False)    level=INFO
        END
    END

Process Pre-Publish Unallocation For Associates
    [Documentation]    Processes pre-publish unallocation for all associates that require it.
    ...    This keyword:
    ...    1. Iterates through all users
    ...    2. Checks if each user requires pre-publish unallocation
    ...    3. Adds shifts that will be unallocated (if specified)
    ...    4. Unallocates the newly added shifts (creating open shifts)
    ...    Args:
    ...    - users: List of user dictionaries, each containing:
    ...    - ess_user_key: User key for the associate
    ...    - required_un_allocation_before_publish: Boolean flag (default: False)
    ...    - add_shift_to_be_unallocated: List of shifts to add before unallocation
    ...    - days_to_unallocate_before_publish: List of day indices to unallocate
    ...    - week_start_date: Start date of the week
    ...    - store_id: Store identifier
    ...    - store_manager_user_key: Manager's user key for API calls
    [Arguments]    ${users}    ${week_start_date}    ${store_id}    ${store_manager_user_key}    ${is_dynamic_user}=False
    FOR    ${user_data}    IN    @{users}
        ${required_un_allocation}=    Get From Dictionary    ${user_data}    required_un_allocation_before_publish    default=${False}
        IF    ${required_un_allocation}
            Log    Processing pre-publish unallocation for ${user_data}[ess_user_key]
            ${ess_user}=    Get User With Person Id Fallback    user_key=${user_data}[ess_user_key]    is_dynamic_user=${is_dynamic_user}
            ${shifts_to_add_before_unallocate}=    Get From Dictionary    ${user_data}    add_shift_to_be_unallocated    default=@{EMPTY}
            ${days_to_unallocate_before_publish}=    Get From Dictionary    ${user_data}    days_to_unallocate_before_publish
            ...    default=@{EMPTY}
            # Add shifts that will be unallocated
            IF    len(${shifts_to_add_before_unallocate}) > 0
                ${shift_details}=    Get Shift Details Via API    ${week_start_date}
                ...    ${store_manager_user_key}    ${ess_user}[personId]    ${days_to_unallocate_before_publish}
                Add Shift For Days Via API    shifts=${shifts_to_add_before_unallocate}    personId=${ess_user}[personId]
                ...    store=${store_id}    user_key=${store_manager_user_key}
                ...    week_start_date=${week_start_date}    shift_details=${shift_details}
                ${added_shift_count}=    Get Length    ${shifts_to_add_before_unallocate}
                Log    Added ${added_shift_count} shifts for pre-publish unallocation for ${user_data}[ess_user_key]
            END
            # Unallocate the newly added shifts
            IF    len(${days_to_unallocate_before_publish}) > 0
                ${shift_details_to_unallocate}=    Get Shift Details Via API    ${week_start_date}
                ...    ${store_manager_user_key}    ${ess_user}[personId]    ${days_to_unallocate_before_publish}
                ${shift_seq_numbers}=    Get From Dictionary    ${shift_details_to_unallocate}    shift_seq_numbers
                ${seq_count}=    Get Length    ${shift_seq_numbers}
                IF    ${seq_count} > 0
                    UnAllocate Required Shift Via API    ${shift_details_to_unallocate}    ${store_id}    ${store_manager_user_key}
                    Log    Unallocated ${seq_count} shifts for ${user_data}[ess_user_key] before publish (creating open shifts)
                ELSE
                    Log    No shifts found to unallocate for ${user_data}[ess_user_key]    level=WARN
                END
            END
        END
    END

Prepare Shift Details Endpoint
    [Documentation]    Prepares the API endpoint and start date for fetching shift details.
    [Arguments]    ${week_start_date}
    ${date_value}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${start_of_freq}=    Convert Date    ${date_value}    result_format=${resultant_format}
    ${week_start_date_formated}=    Convert To Integer    ${start_of_freq}
    ${week_start_date_formated}=    Convert To String    ${week_start_date_formated}
    ${base_url}=    Get Config Value    key=base_url
    ${endpoint}=    Evaluate
    ...    "${GET_SHIFT_ID_API_TEMPLATE}".format(ENVIRONMENT="${base_url}", WEEK_START_DATE="${week_start_date_formated}")
    ${start_date_int}=    Convert To Integer    ${week_start_date_formated}
    RETURN    ${endpoint}    ${start_date_int}

Fetch Generated Schedule Data Via API On Week Schedule Page
    [Documentation]    Fetches schedule data from the API with retry logic.
    ...    Returns the full API response which includes both schBasicDetails and associateAdvDetails.
    ...    Uses Wait Until Keyword Succeeds to poll the API until schedule data is available,
    ...    avoiding Sleep by relying on built-in retry interval handling.
    ...    | =Arguments= | =Description= |
    ...    | endpoint | The API endpoint URL to fetch schedule data from. |
    ...    | week_start_date | The week start date used in failure messages. |
    ...
    ...    *Returns*: Full API response dict containing schBasicDetails and associateAdvDetails.
    [Arguments]    ${endpoint}    ${week_start_date}
    ${batch_plan_data}=    Get Batch Plan Data    template_name=default
    VAR    ${retry_count}=    ${batch_plan_data}[max_attempts]x
    VAR    ${retry_interval}=    ${batch_plan_data}[intervals]s
    ${response}=    Wait Until Keyword Succeeds    ${retry_count}    ${retry_interval}
    ...    Get Schedule Data From API If Available    ${endpoint}    ${week_start_date}
    RETURN    ${response}

Get Schedule Data From API If Available
    [Documentation]    Sends a GET request to the schedule API endpoint and verifies that valid schedule data is present.
    ...    Intended to be called via Wait Until Keyword Succeeds for polling without Sleep.
    ...    Fails if schBasicDetails is missing or None, which triggers a retry.
    ...    | =Arguments= | =Description= |
    ...    | endpoint | The API endpoint URL to fetch schedule data from. |
    ...    | week_start_date | The week start date used in failure messages. |
    ...
    ...    *Returns*: Full API response dict when schedule data is available.
    [Arguments]    ${endpoint}    ${week_start_date}
    ${response}=    Send A Get Request    ${endpoint}
    Log    Response Body: ${response}
    Dictionary Should Contain Key    ${response}    schBasicDetails
    ...    msg=Schedule data not yet available for week ${week_start_date} - schBasicDetails key missing
    ${schBasicDetails}=    Get From Dictionary    ${response}    schBasicDetails
    Should Not Be Equal    ${schBasicDetails}    ${None}
    ...    msg=Schedule data not yet available for week ${week_start_date} - schBasicDetails is None
    Log    Successfully retrieved schedule data for week ${week_start_date}
    RETURN    ${response}

Calculate Target Date For Day
    [Documentation]    Calculates the target date integer for a given day offset from week start.
    ...    Returns the date in YYYYMMDD integer format.
    [Arguments]    ${week_start_date_obj}    ${day}
    ${resultant_format}=    Get Config Value    SERVER_DF
    ${target_date_obj}=    Add Time To Date    ${week_start_date_obj}    ${day}d
    ${target_date_formatted}=    Convert Date    ${target_date_obj}    result_format=${resultant_format}
    ${target_date}=    Convert To Integer    ${target_date_formatted}
    RETURN    ${target_date}

Get Gen Shift Id From Week Shifts
    [Documentation]    Attempts to get gen_shift_id and staff_group_id from any shift in the target week.
    ...    Used as a fallback when no shifts are found for the specific associate.
    ...    Returns EMPTY if no shifts are found in the entire week (schedule generated but empty).
    [Arguments]    ${shifts}    ${start_date_int}    ${week_start_date}
    IF    ${shifts} == ${EMPTY}
        Log    No shifts available in schedule data to extract gen_shift_id for week ${week_start_date}.    level=WARN
        RETURN    ${EMPTY}
    END
    VAR    ${gen_shift_id}=    ${None}
    VAR    ${staff_group_id}=    ${None}
    Log
    ...    No shifts found for personId in week ${week_start_date}. Attempting to get gen_shift_id from other shifts in the week.
    ...    level=WARN
    # Try to get gen_shift_id and staff_group_id from the first available shift in the week
    FOR    ${shift}    IN    @{shifts}
        ${start_date}=    Get From Dictionary    ${shift}    startDate
        # Check if this shift is in the target week
        IF    ${start_date} >= ${start_date_int} and ${start_date} < ${start_date_int + 7}
            ${gen_shift_id}=    Get From Dictionary    ${shift}    genShiftId
            ${staff_group_id}=    Get From Dictionary    ${shift}    staffGroupId
            Log    Using gen_shift_id: ${gen_shift_id}, staff_group_id: ${staff_group_id} from another shift in the week
            BREAK
        END
    END
    # If still no gen_shift_id found, return EMPTY (schedule generated but has no shifts)
    IF    $gen_shift_id == $None
        Log    No shifts found in the entire week ${week_start_date}. Schedule is generated but empty.    level=WARN
        RETURN    ${EMPTY}
    END
    VAR    &{shift_ids}=    gen_shift_id=${gen_shift_id}    staff_group_id=${staff_group_id}
    RETURN    ${shift_ids}

Extract Gen Shift Id From Schedule Level
    [Documentation]    Attempts to extract gen_shift_id from the schedule data level.
    ...    This works even for empty schedules where no shifts exist yet.
    ...    Returns the gen_shift_id if found, otherwise returns None.
    [Arguments]    ${scheduleData}
    VAR    ${gen_shift_id}=    ${None}
    ${has_gen_shift_id}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${scheduleData}    genShiftId
    IF    ${has_gen_shift_id}
        ${gen_shift_id}=    Get From Dictionary    ${scheduleData}    genShiftId
        Log    Extracted gen_shift_id from schedule level: ${gen_shift_id}    level=INFO
    END
    RETURN    ${gen_shift_id}

Extract Staff Group Id From Schedule Level
    [Documentation]    Attempts to extract staff_group_id from the schedule data level.
    ...    Looks for staff group in shifts array if available.
    ...    Returns the staff_group_id if found, otherwise returns None.
    [Arguments]    ${scheduleData}
    VAR    ${staff_group_id}=    ${None}
    # Check if shifts exist and extract staff_group_id from first shift
    ${has_shifts}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${scheduleData}    shifts
    IF    ${has_shifts}
        ${shifts}=    Get From Dictionary    ${scheduleData}    shifts
        ${shifts_count}=    Get Length    ${shifts}
        IF    ${shifts_count} > 0
            ${first_shift}=    Get From List    ${shifts}    0
            ${has_staff_group}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${first_shift}    staffGroupId
            IF    ${has_staff_group}
                ${staff_group_id}=    Get From Dictionary    ${first_shift}    staffGroupId
                Log    Extracted staff_group_id from schedule shifts: ${staff_group_id}    level=INFO
            END
        ELSE
            Log    Schedule has no shifts, cannot extract staff_group_id from shift level    level=WARN
        END
    ELSE
        Log    scheduleData does not contain shifts key, cannot extract staff_group_id    level=WARN
    END
    RETURN    ${staff_group_id}

Calculate Current Day Offset From Week Start
    [Documentation]    Calculates the current day number offset from the week start date (0-6).
    ...    Also determines if the current week is in progress (current day falls within the week).
    ...    Returns a dictionary with current_day_number, is_week_in_progress, and week_start_date_obj.
    [Arguments]    ${week_start_date}
    ${week_start_date_obj}=    Calculate Date From Week Day Offset    ${week_start_date}
    ${today_date}=    Get Current Date
    ${day_diff_seconds}=    Subtract Date From Date    ${today_date}    ${week_start_date_obj}    result_format=number
    ${current_day_number}=    Evaluate    int(${day_diff_seconds} / 86400)
    ${is_week_in_progress}=    Evaluate    0 <= ${current_day_number} <= 6
    VAR    &{week_context}=
    ...    current_day_number=${current_day_number}
    ...    is_week_in_progress=${is_week_in_progress}
    ...    week_start_date_obj=${week_start_date_obj}
    RETURN    ${week_context}

Extract Shift Sequence Numbers For Person
    [Documentation]    Extracts shift sequence numbers for a specific person from the shifts list.
    ...    Filters shifts by personId and specified days to unallocate.
    ...    Skips past days for week in progress to avoid processing historical data.
    ...    Also captures gen_shift_id and staff_group_id from matching shifts if not already provided.
    [Arguments]    ${shifts}    ${personId}    ${days_to_unallocate}    ${week_context}    ${gen_shift_id}    ${staff_group_id}
    VAR    @{shift_seq_numbers}=    @{EMPTY}
    VAR    ${shifts_found}=    ${0}
    ${current_day_number}=    Get From Dictionary    ${week_context}    current_day_number
    ${is_week_in_progress}=    Get From Dictionary    ${week_context}    is_week_in_progress
    ${week_start_date_obj}=    Get From Dictionary    ${week_context}    week_start_date_obj
    Log    Original personId value: ${personId}, Type: ${personId.__class__.__name__}
    FOR    ${shift}    IN    @{shifts}
        ${start_date}=    Get From Dictionary    ${shift}    startDate
        ${assigned_to}=    Get From Dictionary    ${shift}    assignedTo
        Log    Checking shift: assigned_to=${assigned_to} (type: ${assigned_to.__class__.__name__}) vs personId=${personId}
        IF    ${assigned_to} == ${personId}
            ${shifts_found}=    Evaluate    ${shifts_found} + 1
            FOR    ${day}    IN    @{days_to_unallocate}
                IF    ${is_week_in_progress} and ${day} < ${current_day_number}
                    CONTINUE
                END
                ${target_date}=    Calculate Target Date For Day    ${week_start_date_obj}    ${day}
                IF    ${start_date} == ${target_date}
                    IF    $gen_shift_id == $None
                        ${gen_shift_id}=    Get From Dictionary    ${shift}    genShiftId
                        Log    Captured gen_shift_id from shift: ${gen_shift_id}
                    END
                    IF    $staff_group_id == $None
                        ${staff_group_id}=    Get From Dictionary    ${shift}    staffGroupId
                        Log    Captured staff_group_id from shift: ${staff_group_id}
                    END
                    ${shift_seq_no}=    Get From Dictionary    ${shift}    shiftSeqNo
                    Append To List    ${shift_seq_numbers}    ${shift_seq_no}
                END
            END
        END
    END
    Log    Total shifts found for associate ${personId}: ${shifts_found}
    VAR    &{result}=    shift_seq_numbers=${shift_seq_numbers}    gen_shift_id=${gen_shift_id}    staff_group_id=${staff_group_id}
    RETURN    ${result}

Fallback Extract Shift Ids From Week
    [Documentation]    Fallback method to extract gen_shift_id and staff_group_id from any shift in the week.
    ...    Used when no shifts are found for the specific associate but schedule has other shifts.
    ...    Logs a warning if no shifts are available in the entire schedule.
    [Arguments]    ${shifts}    ${start_date_int}    ${week_start_date}    ${gen_shift_id}    ${staff_group_id}
    IF    $gen_shift_id == $None and $shifts
        ${shift_ids}=    Get Gen Shift Id From Week Shifts    ${shifts}    ${start_date_int}    ${week_start_date}
        IF    ${shift_ids} != ${EMPTY}
            ${gen_shift_id}=    Get From Dictionary    ${shift_ids}    gen_shift_id
            ${staff_group_id}=    Get From Dictionary    ${shift_ids}    staff_group_id
        ELSE
            Log    No shifts available in generated schedule for week ${week_start_date}. Skipping shift detail extraction.    level=WARN
        END
    END
    VAR    &{result}=    gen_shift_id=${gen_shift_id}    staff_group_id=${staff_group_id}
    RETURN    ${result}

Extract Shift Details On Week Schedule Page
    [Documentation]    Extracts shift details for a specific associate from schedule data.
    ...    For week in progress, skips shifts on past days (before current day).
    ...    Attempts to extract gen_shift_id from scheduleData level first (works even for empty schedules).
    ...    This is a wrapper keyword that orchestrates multiple helper keywords to break down complex logic.
    [Arguments]    ${scheduleData}    ${start_date_int}    ${personId}    ${days_to_unallocate}    ${week_start_date}
    # Extract shifts from schedule data
    ${shifts}=    Get From Dictionary    ${scheduleData}    shifts
    # Step 1: Try to extract gen_shift_id from schedule level
    ${gen_shift_id}=    Extract Gen Shift Id From Schedule Level    ${scheduleData}
    # Step 2: Try to extract staff_group_id from schedule level
    ${staff_group_id}=    Extract Staff Group Id From Schedule Level    ${scheduleData}
    # Step 3: Calculate week context (current day offset and week progress status)
    ${week_context}=    Calculate Current Day Offset From Week Start    ${week_start_date}
    # Step 4: Extract shift sequence numbers for the specific person
    ${extraction_result}=    Extract Shift Sequence Numbers For Person    ${shifts}    ${personId}    ${days_to_unallocate}
    ...    ${week_context}    ${gen_shift_id}    ${staff_group_id}
    ${shift_seq_numbers}=    Get From Dictionary    ${extraction_result}    shift_seq_numbers
    ${gen_shift_id}=    Get From Dictionary    ${extraction_result}    gen_shift_id
    ${staff_group_id}=    Get From Dictionary    ${extraction_result}    staff_group_id
    # Step 5: Fallback to extract from any shift in week if still not found
    ${fallback_result}=    Fallback Extract Shift Ids From Week    ${shifts}    ${start_date_int}    ${week_start_date}    ${gen_shift_id}
    ...    ${staff_group_id}
    ${gen_shift_id}=    Get From Dictionary    ${fallback_result}    gen_shift_id
    ${staff_group_id}=    Get From Dictionary    ${fallback_result}    staff_group_id
    # Step 6: Build and return final result
    VAR    &{shift_details}=    gen_shift_id=${gen_shift_id}    shift_seq_numbers=${shift_seq_numbers}    staff_group_id=${staff_group_id}
    RETURN    ${shift_details}

Navigate To Plan Status Page From Week Schedule Page On Web
    [Documentation]
    ...    Navigates to the Plan Status page from the Week Schedule page on the web application.
    ...    Checks if the Week Schedule page is visible before attempting navigation.
    ...    Uses the railroad dropdown menu to switch between pages.
    ...    | =Arguments= | =Description= |
    ...    | None    | No arguments required |
    ...    Example usage:
    ...    | Navigate To Plan Status Page From Week Schedule Page On Web
    ${week_schedule_page_is_visible}=    Run Keyword And Return Status    Wait Until Element Is Present On Webpage
    ...    ${FIXEDSHIFTS_RAILROAD_DROPDOWN_ICON_BUTTON}
    IF    ${week_schedule_page_is_visible}
        Click Element On Webpage    ${FIXEDSHIFTS_RAILROAD_DROPDOWN_ICON_BUTTON}
        ...    error_message=Failed to find railroad dropdown icon button on Week Schedule page
        Click Element On Webpage    ${PLAN_STATUS_RAILROAD_DROPDOWN_ITEM}
        ...    error_message=Failed to find Plan Status railroad dropdown item on Week Schedule page
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${WEEK_SCHEDULE_PLAN_STATUS}
        ...    error_message=Failed to find Week Schedule Plan Status element on Plan Status page
    END

Verify Generate Schedule Using Template Failed Message On Plan Status Page On Web
    [Documentation]
    ...    Verifies that the "Generate Schedule Using Template" operation failed and the correct error message is displayed on the Plan Status page.
    ...    | =Arguments= | =Description= |
    ...    | expected_message | The expected error message to verify on the page. |
    ...    Example usage:
    ...    | Verify Generate Schedule Using Template Failed Message On Plan Status Page On Web    Schedule generation failed due to missing template.
    TRY
        Wait Until Element Is Visible On Webpage    ${PLAN_STATUS_PAGE_WORK_PATTERN_NOT_MAPPED_MESSAGE}    timeout=${LONG_TIMEOUT}
        Capture Screenshot On Webpage
        ${message_content}=    Get Element Text On Webpage    ${PLAN_STATUS_PAGE_WORK_PATTERN_NOT_MAPPED_MESSAGE}
        Log    ${message_content}
    EXCEPT
        Fail    Success message notifier is not displayed
        Capture Screenshot On Webpage
    END

Unit Status Should Be In Forecast Generated For Week
    [Documentation]    Validates if the schedule is generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Be True    ${unit_schedule_states_map}[is_forecast_generated]
    ...    msg=Forecast is NOT generated for week starting on ${week_start_date} for unit ${unit_id}

Unit Status Should Be In Forecast Not Generated For Week
    [Documentation]    Validates if the Forecast is Not generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Not Be True    ${unit_schedule_states_map}[is_forecast_generated]
    ...    msg=expected Forecast Not Generated status but got ${unit_schedule_states_map}[is_forecast_generated]

Unit Status Should Be In Workload Generated For Week
    [Documentation]    Validates if the schedule is generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Be True    ${unit_schedule_states_map}[is_workload_generated]
    ...    msg=Workload is NOT generated for week starting on ${week_start_date} for unit ${unit_id}

Unit Status Should Be In Workload Not Generated For Week
    [Documentation]    Validates if the workload is not generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Not Be True    ${unit_schedule_states_map}[is_workload_generated]
    ...    msg=Workload is generated for week starting on ${week_start_date} for unit ${unit_id}

Unit Status Should Be In Schedule Published For Week
    [Documentation]    Validates if the schedule is generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Be True    ${unit_schedule_states_map}[is_schedule_published]
    ...    msg=Schedule is NOT Published for week starting on ${week_start_date} for unit ${unit_id}

Unit Status Should Be In Schedule UnPublished For Week
    [Documentation]    Validates if the schedule is generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Not Be True    ${unit_schedule_states_map}[is_schedule_published]
    ...    msg=Schedule is Published for week starting on ${week_start_date} for unit ${unit_id}

Unit Status Should Be Can Generate Workload For Week
    [Documentation]    Validates if the unit status allows workload generation for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manager user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Be True    ${unit_schedule_states_map}[can_generate_workload]
    ...    msg=cant generate Workload for week starting on ${week_start_date} for unit ${unit_id}

Wait Until Unit Status Can Generate Workload For Week
    [Documentation]
    ...    Polls the unit schedule status map until can_generate_workload becomes True for the specified week.
    ...    Retries using the SCHEDULE_WORKFLOW_WAITING_PERIOD config value (retry count and interval).
    ...    Fails if the status does not become True within the retry limit.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manager user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    ...
    ...    Example usage:
    ...    | Wait Until Unit Status Can Generate Workload For Week    ${sm_user_key}    ${unit_id}    ${week_start_date}
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be Can Generate Workload For Week
    ...    ${user_key}    ${unit_id}    ${week_start_date}

Unit Status Should Be In Schedule Generated For Week
    [Documentation]    Validates if the schedule is generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Be True    ${unit_schedule_states_map}[is_schedule_generated]
    ...    msg=Schedule is NOT generated for week starting on ${week_start_date} for unit ${unit_id}
    IF    ${unit_schedule_states_map}[can_lock_schedule]
        Should Not Be True    ${unit_schedule_states_map}[can_publish_schedule]
        ...    msg=Schedule cant Lock for week starting on ${week_start_date} for unit ${unit_id}
    ELSE
        Should Be True    ${unit_schedule_states_map}[can_publish_schedule]
        ...    msg=Schedule cant Publish for week starting on ${week_start_date} for unit ${unit_id}
    END

Unit Status Should Be In Schedule Not Generated For Week
    [Documentation]    Validates if the schedule is generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Not Be True    ${unit_schedule_states_map}[is_schedule_generated]
    ...    msg=Schedule is generated state for week starting on ${week_start_date} for unit ${unit_id}

Unit Status Should Be In Schedule Unlocked For Week
    [Documentation]    Validates if the schedule is unlocked for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Be True    ${unit_schedule_states_map}[can_lock_schedule]
    ...    msg=Schedule is NOT unlocked for week starting on ${week_start_date} for unit ${unit_id}

Unit Status Should Be In Week In Progress Schedule Generated For Week
    [Documentation]    Validates if the schedule is generated for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${unit_schedule_states_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit Schedule States Map: ${unit_schedule_states_map}
    Should Be True    ${unit_schedule_states_map}[is_schedule_week_in_progress]
    ...    msg=Schedule is NOT in wip for week starting on ${week_start_date} for unit ${unit_id}

Generate Forecast Via API And Wait For Completion New
    [Documentation]    Generates the schedule for a specified week via API and waits for completion.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose schedule is to be generated |
    ...    | week_start_date | yyyymmdd date format |
    ...    | week_offset | The offset of the week for which the schedule is to be generated. TODO get rid of this param|
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}    ${week_offset}
    Log    Starting forecast generation for week starting on ${week_start_date} for unit ${unit_id}    console=yes
    Generate Forecast Via API    ${unit_id}    ${week_offset}    ${user_key}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Forecast Generated For Week    ${user_key}
    ...    ${unit_id}    ${week_start_date}
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be Can Generate Workload For Week    ${user_key}
    ...    ${unit_id}    ${week_start_date}
    Log    Forecast generation completed for week starting on ${week_start_date} for unit ${unit_id}    console=yes

Generate Workload Via API And Wait For Completion New
    [Documentation]    Generates the schedule for a specified week via API and waits for completion.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose schedule is to be generated |
    ...    | week_start_date | yyyymmdd date format |
    ...    | week_offset | The offset of the week for which the schedule is to be generated. TODO get rid of this param|
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}    ${week_offset}
    Generate Workload Via API    ${unit_id}    ${week_offset}    ${user_key}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Workload Generated For Week    ${user_key}
    ...    ${unit_id}    ${week_start_date}
    Log    Workload generation completed for week starting on ${week_start_date} for unit ${unit_id}    console=yes

Generate Schedule Via API And Wait For Completion New
    [Documentation]    Generates the schedule for a specified week via API and waits for completion.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose schedule is to be generated |
    ...    | week_start_date | yyyymmdd date format |
    ...    | schedule_gen_type | Optional override (Y=optimized, N=template). When omitted uses config default. |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}    ${schedule_gen_type}=${NONE}
    Generate Schedule Via API    ${unit_id}    ${week_start_date}    ${user_key}    ${schedule_gen_type}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Schedule Generated For Week    ${user_key}
    ...    ${unit_id}    ${week_start_date}
    Log    Schedule generation completed for week starting on ${week_start_date} for unit ${unit_id}    console=yes

Should Use VDI Based Workload For Store
    [Documentation]    Determines if VDI-based workload should be used for a store.
    ...    This keyword provides unified VDI detection combining two approaches:
    ...    1. If `vdi_import` config flag is present, use its value (backward compatibility).
    ...    2. If config flag is absent, query the database for VDI capability (START_STATE_FIXED_WL).
    ...    | =Arguments= | =Description= |
    ...    | store_id | Store unit ID to check (e.g., ZSITSTORE006). |
    ...    | =Returns= | =Description= |
    ...    | should_use_vdi | Boolean: True if VDI should be used, False for regular workload. |
    [Arguments]    ${store_id}
    ${is_vdi_workload_enabled_by_config}=    Is Config Enabled    key=vdi_import
    IF    ${is_vdi_workload_enabled_by_config}
        Log    VDI workload is enabled by environment config.    console=yes
        VAR    ${should_use_vdi}=    ${True}
    ELSE
        Log    VDI workload is not enabled by environment config. Checking DB for VDI capability.    console=yes
        TRY
            ${status}    ${is_vdi_enabled}=    Get VDI Based Workload Regeneration Status For Store From Database    ${store_id}
            Log    VDI capability for store ${store_id}: ${status}    console=yes
            VAR    ${should_use_vdi}=    ${is_vdi_enabled}
        EXCEPT
            Log    DB query failed; defaulting to regular workload (no VDI).    console=yes
            VAR    ${should_use_vdi}=    ${False}
        END
    END
    RETURN    ${should_use_vdi}

Get Unit State Map For Week Via API
    [Documentation]    Retrieves the unit state map for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}    ${states_event_list_map}

    ${base_url}=    Get Config Value    key=base_url
    ${get_unit_state_map_url}=    Format String    ${GET_UNIT_STATE_MAP_API}    BASE_URL=${base_url}    UNIT_ID=${unit_id}
    ...    WEEK_START_DATE=${week_start_date}
    # ${response}=    Send A Post Request    ${get_unit_state_map_url}    body=${states_event_list_map}
    ${response}=    Send A WFM POST Request    ${user_key}    ${base_url}    ${get_unit_state_map_url}    ${states_event_list_map}
    RETURN    ${response}[${unit_id}]

Get Schedule Related Status Map For Store And A Week Via API
    [Documentation]    Retrieves the unit state map for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}

    ${gen_shift_id}=    Get Gen Shift Id For The Specific Week Via API    ${user_key}    ${unit_id}    ${week_start_date}
    ${is_schedule_week_in_progress}=    Set Variable If    str(${gen_shift_id}).startswith('7')    ${True}    ${False}

    VAR    @{states}=    SCHEDULE_GENERATED    SCHEDULE_PUBLISHED    SCHEDULE_WEEK_IN_PROGRESS    WORKLOAD_GENERATED
    ...    FORECAST_GENERATED
    VAR    @{events}=    GENERATE_FC    EDIT_FC    GENERATE_SC    GENERATE_WL    DELETE_SC    DELETE_WL    PUBLISH_SC
    ...    UNPUBLISH_SC    REGEN_WL    REGENERATE_SC    EDIT_SC    LOCK_SCHEDULE    UNLOCK_SCHEDULE
    VAR    &{schedule_states_event_list_map}=    states=${states}    eventCodes=${events}
    ${unit_schedule_states_map}=    Get Unit State Map For Week Via API    ${user_key}    ${unit_id}    ${week_start_date}
    ...    ${schedule_states_event_list_map}
    Log    Response Body: ${unit_schedule_states_map}
    ${is_schedule_generated}=    Get From Dictionary    ${unit_schedule_states_map}    SCHEDULE_GENERATED    default=False
    ${is_schedule_published}=    Get From Dictionary    ${unit_schedule_states_map}    SCHEDULE_PUBLISHED    default=False
    # ${is_schedule_week_in_progress}=    Get From Dictionary    ${unit_schedule_states_map}    SCHEDULE_WEEK_IN_PROGRESS    default=False
    ${is_workload_generated}=    Get From Dictionary    ${unit_schedule_states_map}    WORKLOAD_GENERATED    default=False
    ${is_forecast_generated}=    Get From Dictionary    ${unit_schedule_states_map}    FORECAST_GENERATED    default=False
    ${can_lock_schedule}=    Get From Dictionary    ${unit_schedule_states_map}    LOCK_SCHEDULE    default=False
    ${can_unlock_schedule}=    Get From Dictionary    ${unit_schedule_states_map}    UNLOCK_SCHEDULE    default=False
    ${can_edit_schedule}=    Get From Dictionary    ${unit_schedule_states_map}    EDIT_SC    default=False
    ${can_publish_schedule}=    Get From Dictionary    ${unit_schedule_states_map}    PUBLISH_SC    default=False
    ${can_generate_schedule}=    Get From Dictionary    ${unit_schedule_states_map}    GENERATE_SC    default=False
    ${can_generate_workload}=    Get From Dictionary    ${unit_schedule_states_map}    GENERATE_WL    default=False
    ${can_generate_forecast}=    Get From Dictionary    ${unit_schedule_states_map}    GENERATE_FC    default=False
    ${can_delete_schedule}=    Get From Dictionary    ${unit_schedule_states_map}    DELETE_SC    default=False
    ${can_delete_workload}=    Get From Dictionary    ${unit_schedule_states_map}    DELETE_WL    default=False
    VAR    &{result}=
    ...    is_schedule_generated=${is_schedule_generated}
    ...    is_schedule_published=${is_schedule_published}
    ...    is_schedule_week_in_progress=${is_schedule_week_in_progress}
    ...    is_workload_generated=${is_workload_generated}
    ...    is_forecast_generated=${is_forecast_generated}
    ...    can_lock_schedule=${can_lock_schedule}
    ...    can_unlock_schedule=${can_unlock_schedule}
    ...    can_edit_schedule=${can_edit_schedule}
    ...    can_publish_schedule=${can_publish_schedule}
    ...    can_generate_schedule=${can_generate_schedule}
    ...    can_generate_workload=${can_generate_workload}
    ...    can_generate_forecast=${can_generate_forecast}
    ...    can_delete_schedule=${can_delete_schedule}
    ...    can_delete_workload=${can_delete_workload}
    RETURN    ${result}

Delete Existing Schedule Based On Current Status Via API
    [Documentation]    Retrieves the unit state map for a specified week via API.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched |
    ...    | week_start_date | yyyymmdd date format |
    ...    | week_offset | The week start date offset (e.g., "3_0", "0_0") |
    ...    | current_unit_status_map | The current status map of the unit for the week. |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}    ${week_offset}    ${current_unit_status_map}
    Log    Deleting Existing Schedule for unit ${unit_id} and week starting on ${week_start_date}    console=yes
    IF    ${current_unit_status_map}[can_unlock_schedule]
        Log    Schedule can be unlocked. Unlocking schedule before deletion.    console=yes

        Unlock Schedule Via API And Wait For Completion    store=${unit_id}    week_start_date=${week_start_date}    user_key=${user_key}
    END
    IF    ${current_unit_status_map}[is_schedule_published]
        Log    Schedule is currently Published. Unpublishing schedule before deletion.    console=yes
        Unpublish Schedule And Wait For Completion Via API    ${unit_id}    ${week_start_date}    ${week_offset}    ${user_key}
    END
    IF    ${current_unit_status_map}[is_schedule_generated]
        Log    Proceeding to delete schedule for unit ${unit_id} and week starting on ${week_start_date}.    console=yes
        Delete Schedule Via API And Wait For Completion    ${unit_id}    ${week_start_date}    ${week_offset}    ${user_key}
    END

Delete Existing Workload Based On Current Status Via API
    [Documentation]    Deletes the existing schedule using the current status map and then deletes workload only when needed.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose unit state map is to be fetched. |
    ...    | week_start_date | yyyymmdd date format. |
    ...    | week_offset | The week start date offset (e.g., "3_0", "0_0"). |
    ...    | current_unit_status_map | The current status map of the unit for the week. |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}    ${week_offset}    ${current_unit_status_map}
    Delete Existing Schedule Based On Current Status Via API    ${user_key}    ${unit_id}    ${week_start_date}
    ...    ${week_offset}    ${current_unit_status_map}
    ${current_unit_status_map}=    Get Schedule Related Status Map For Store And A Week Via API    ${user_key}    ${unit_id}
    ...    ${week_start_date}
    Log    Unit status map after schedule deletion: ${current_unit_status_map}    console=yes
    IF    ${current_unit_status_map}[can_delete_workload]
        Log    Workload delete is available. Deleting workload after schedule deletion.    console=yes
        Delete Workload Via API And Wait For Completion    ${unit_id}    ${week_start_date}    ${week_offset}    ${user_key}
    ELSE IF    ${current_unit_status_map}[is_workload_generated]
        Log    Workload is still generated, but DELETE_WL is not available in the current state.    console=yes
    ELSE
        Log    No generated workload remains after schedule deletion.    console=yes
    END

Generate Week In Progress Schedule From Servlet
    [Documentation]    Generates schedule setup data for a week in progress scenario.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose schedule is to be generated |
    [Arguments]    ${user_key}    ${unit_id}
    ${base_url}=    Get Config Value    key=base_url
    ${wip_servlet_url}=    Format String    ${WIP_SERVLET_URL}    BASE_URL=${base_url}    UNIT_ID=${unit_id}
    ${response}=    Send A WFM GET Request    ${user_key}    ${base_url}    ${wip_servlet_url}    True
    RETURN    ${response}

Generate Week In Progress Schedule And Wait For Completion
    [Documentation]    Generates the week in progress schedule via servlet and waits for completion.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose schedule is to be generated |
    ...    | week_start_date | yyyymmdd date format |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    Generate Week In Progress Schedule From Servlet    ${user_key}    ${unit_id}
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Week In Progress Schedule Generated For Week
    ...    ${user_key}    ${unit_id}    ${week_start_date}
    Log    Week In Progress Schedule generation completed for week starting on ${week_start_date} for unit ${unit_id}    console=yes

Generate Schedule For Current Week If Not Exists On Web
    [Documentation]    Sets up a week in progress copy ONLY for the current week (week_start_date="0_0").
    ...    For other weeks, this keyword does nothing.
    ...    | =Arguments= | =Description= |
    ...    | store_id | Store identifier |
    ...    | week_start_date | Week start date (only "0_0" triggers setup) |
    ...    | store_manager_user_key | Manager's user key for API calls |
    ...
    ...    Workflow for week 0_0:
    ...    1. Check if gen_shift_id starts with 7 (WIP copy already exists)
    ...    2. If gen_shift_id starts with 7: Skip all setup (already configured)
    ...    3. If gen_shift_id does NOT start with 7:
    ...    - Clear existing schedule based on status
    ...    - Generate forecast
    ...    - Generate workload
    ...    - Generate schedule
    ...
    ...    Example usage:
    ...    | Set Week In Progress Copy For Current Week | STORE1 | 0_0 | SM1_STORE1 |
    [Arguments]    ${store_id}    ${week_start_date}    ${store_manager_user_key}
    IF    '${week_start_date}' == '0_0'
        Log    Generating schedule for current week (0_0) before setting up Week in Progress copy.
        ${schedule_status}=    Get Generated Shift Id And Schedule Status Via API    ${week_start_date}    ${store_manager_user_key}
        ${gen_shift_id}=    Get From Dictionary    ${schedule_status}    latestGenShiftId
        ${gen_shift_id_int}=    Convert To Integer    ${gen_shift_id}
        ${gen_shift_id_str}=    Convert To String    ${gen_shift_id_int}
        # Check if gen_shift_id starts with 7 (week in progress copy already exists)
        IF    '${gen_shift_id_str}' != '-1' and '${gen_shift_id_str}'[0] == '7'
            Log    Gen Shift ID starts with 7 (${gen_shift_id_int}). Week in Progress copy already exists. Skipping all setup steps.
            ...    level=WARN
        ELSE
            Log    Gen Shift ID does not start with 7 (${gen_shift_id_int}). Proceeding with Schedule Generation for current week.
            Clear Existing Schedule Based On Status Via API    ${store_id}    ${week_start_date}    ${schedule_status}
            ...    ${store_manager_user_key}
            Generate Forecast Via API    ${store_id}    ${week_start_date}    ${store_manager_user_key}
            Generate Workload Via API    ${store_id}    ${week_start_date}    ${store_manager_user_key}
            Generate Schedule Via API And Wait For Completion    ${store_id}    ${week_start_date}    ${store_manager_user_key}
            Log    Schedule generation completed successfully for week 0_0
        END
    ELSE
        Log    Week in Progress copy setup is ONLY applicable for week 0_0. Current week is ${week_start_date}. Skipping.    level=WARN
    END

Get Gen Shift Id For The Specific Week Via API
    [Documentation]    Returns Gen Shift ID for a specific week via API call.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | Unit id for the store whose schedule is to be generated. |
    ...    | week_start_date | Week start date in yyyymmdd format. |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}
    ${base_url}=    Get Config Value    key=base_url
    ${gen_shift_id_url}=    Format String    ${GET_GEN_SHIFT_ID_API_TEMPLATE}    BASE_URL=${base_url}    STORE=${unit_id}
    ...    WEEK_START_DATE=${week_start_date}
    ${response}=    Send A WFM GET Request    ${user_key}    ${base_url}    ${gen_shift_id_url}    False
    RETURN    ${response}

Delete Week Plan From Servlet
    [Documentation]    Deletes the week plan for a specific week via servlet call.
    ...    | =Arguments= | =Description= |
    ...    | user_key | The store manger user key for authentication. |
    ...    | unit_id | unit id for the store whose schedule is to be deleted |
    ...    | week_start_date | Week start date in yyyymmdd format. |
    [Arguments]    ${user_key}    ${unit_id}    ${week_start_date}

    ${is_week_offset}=    Run Keyword And Return Status
    ...    Should Contain    ${week_start_date}    _
    ${server_date_format}=    Get Config Value    SERVER_DF
    VAR    ${date_format}=    ${server_date_format}

    IF    ${is_week_offset}
        Log    Week start date provided as offset: ${week_start_date}
        ${week_start_date}=    Calculate Week Start Date From Week Day Offset    ${week_start_date}    ${date_format}
    END

    ${base_url}=    Get Config Value    key=base_url
    ${delete_week_plan_url}=    Format String    ${DELETE_WEEK_PLAN_SERVLET_URL}    BASE_URL=${base_url}    UNIT_ID=${unit_id}
    ...    WEEK_START_DATE=${week_start_date}
    ${response}=    Send A WFM GET Request    ${user_key}    ${base_url}    ${delete_week_plan_url}    True
    ${retry}    ${retry_interval}=    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Unit Status Should Be In Forecast Not Generated For Week    ${user_key}
    ...    ${unit_id}    ${week_start_date}
    RETURN    ${response}
