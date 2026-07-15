*** Settings ***
Documentation       Sample test cases to understand use of some keywords and libraries. To run this locally please remove robot:skip tag

Library             DateTime
# Use the consolidated test data library
Library             test_data/TestDataLibrary.py
Library            utils/common_utility/utility.py
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/employee/roster_db.resource
Resource            resources/Mobile/Common/Mobile_Device_Helper.resource
Resource            resources/Mobile/Common/CSV_File_Util.resource

Test Tags           examples


*** Test Cases ***
Environment Value And Data Provider Example
    [Documentation]    Example of getting environment-specific values & data provider strategies
    [Tags]    basic
    # Now using direct keywords from EnvironmentManager
    ${env}=    Get Current Environment
    ${base_url}=    Get Config Value    base_url    default=https://default.url
    Log    ${base_url}
    ${base_url2}=    Get Config Value    base_url2    default=https://default.url
    Log    ${base_url2}
    ${smuser}=    Get User    user_key=SM1_STORE1
    Log    ${smuser}
    ${essuser}=    Get User    user_key=ESS1_STORE1
    Log    ${essuser}
    # Send the delete request via API
    # ${auth_token}    Request New Auth Token    ${smuser}[username]    ${smuser}[store_id]
    ${request_value}=    Get System Value    DayOffReasonType    UNPAID_DAY_OFF
    ${MYWORK_ENABLED}=    Is Config Enabled    mywork
    Log    Current environment: ${env}
    Log    DayOffReasonType.UNPAID_DAY_OFF = ${request_value} in ${env}
    Log    MYWORK_ENABLED = ${MYWORK_ENABLED} in ${env}
    Log    base_url = ${base_url} in ${env}

Example 1: Basic Shift Pattern Usage
    [Documentation]    Demonstrates getting shift pattern data directly
    [Tags]    shift_pattern    phase1
    # Get a standard 9-hour shift pattern
    ${shift_pattern}=    Get Shift Time Pattern Data    template_name=standard_9hr
    Log    Shift Pattern: ${shift_pattern}
    Fail    Dummy Fail

Example 2: Employee Assignment With Automatic Template Resolution
    [Documentation]    Shows automatic resolution of shift_pattern references
    ...    The shift_pattern field is automatically replaced with actual startTime and duration
    [Tags]    employee_assignment
    # Get employee assignment - shift patterns are automatically resolved
    ${employee}=    Get Employee Shift Setup Data    template_name=add012_standard9

    Log    Employee Assignment (resolved): ${employee}
    Log    First Shift: ${employee}[shifts_to_add][0]

    # Verify the shift_pattern was resolved to actual values
    Should Not Contain    ${employee}[shifts_to_add][0]    shift_pattern

Example 3: Get Shift Pattern With Time Conversion
    [Documentation]    Demonstrates how time fields are automatically converted from minutes to time strings
    [Tags]    time_conversion
    ${shift_8hr1}=    Get Shift Time Pattern Data    template_name=standard_8hr    startTime=${1020}
    ${shift_8hr2}=    Get Shift Time Pattern Data    template_name=standard_8hr    startTime=${1020}    _am_pm_format=ap
    ${shift_8hr3}=    Get Shift Time Pattern Data    template_name=standard_8hr    _am_pm_format=-ap
    Log    Start Time with default format: ${shift_8hr1}
    Log    Start Time with "ap" format: ${shift_8hr2}
    Log    Start Time with "-ap" format: ${shift_8hr3}

Example 4:Login Examples
    [Documentation]    Shows usage of login keyword for different users.
    [Tags]    login_example
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Verify Successful Login To WFM Application
    Capture Screenshot On Webpage
    Login And Launch WFM Web App    user_key=SYSADMIN
    Verify Successful Login To WFM Application
    Capture Screenshot On Webpage
    Login And Launch WFM Web App    user_key=ESS1_STORE1
    Verify Successful Login To WFM Application
    Capture Screenshot On Webpage

Example 5:Login Examples Store2
    [Documentation]    Shows usage of login keyword for different users.
    [Tags]    login_example
    Login And Launch WFM Web App    user_key=SM1_STORE2
    Verify Successful Login To WFM Application
    Capture Screenshot On Webpage
    Login And Launch WFM Web App    user_key=ESS1_STORE2
    Verify Successful Login To WFM Application
    Capture Screenshot On Webpage

Example 6: DB Query
    [Documentation]    Example of executing a DB query to get staff group id for a person
    [Tags]    db_query
    ${essuser}=    Get User    user_key=ESS1_STORE1
    ${effective_start_date}=    Get Current Date    result_format=%Y%m%d
    ${effective_end_date}=    Get Current Date    result_format=%Y%m%d
    ${staff_group_id}=    Get Associate StaffGroupId From PersonId Via DB    ${essuser}[personId]    ${effective_start_date}
    ...    ${effective_end_date}
    Log    Staff Group ID for person_id ${essuser}[personId]onst: ${staff_group_id}

Example 7: Mobile test cases on zTest
    [Documentation]    Example of mobile test case that can be executed on zTest
    [Tags]    example_mobile
    Log    This is an example mobile test case that demonstrates logging into the ESS and SM apps on a mobile device.
    Init Mobility Common Resources

    Open Mobile ESS App    ess
    Login Mobile Ess App    ESS5_STORE2
    Logout Mobile ESS App
    Close Application

    Open SM Native Application On Mobile Phone    sm
    Login SM App On Mobile    SM1_STORE2
    Logout SM App On Mobile
    Close Application

Example 9: All date operations in DateTime library with planning week base date
    [Documentation]    Example of using various date operations from the DateTime library.
    [Tags]    planning_week_date_example
    # Setting this variable to True will enable the logic to calculate the planning week base date in the SIT tests. This is necessary for the tests that involve scheduling and planning features, ensuring that the base date is correctly determined based on config.json
    VAR    ${PLANNING_WEEK_ENABLED}    ${True}    scope=TEST
    ${date_format}=    Get Config Value    DATE_FMT_YEAR_MONTH_DAY
    ${config_value}=    Get Config Value    PLANNING_WEEK_BASE_DATE

    ${date}=    Calculate Date From Week Day Offset    0_0    date_format=${date_format}
    Should Be Equal As Strings    ${date}    ${config_value}

    ${date}=    Calculate Date From Week Day Offset    0_1    date_format=${date_format}
    ${actual_date}=    Add Time To Date    ${config_value}    1 days    result_format=${date_format}
    Should Be Equal As Strings    ${date}    ${actual_date}

    ${date}=    Calculate Date From Week Day Offset    1_0    date_format=${date_format}
    ${actual_date}=    Add Time To Date    ${config_value}    7 days    result_format=${date_format}
    Should Be Equal As Strings    ${date}    ${actual_date}

    ${date}=    Calculate Date From Week Day Offset    -1_1    date_format=${date_format}
    ${actual_date}=    Subtract Time From Date    ${config_value}    6 days    result_format=${date_format}
    Should Be Equal As Strings    ${date}    ${actual_date}

    ${today}=    Get Current Date    result_format=${date_format}    exclude_millis=True
    # Default call (no offset) -> today's planning week_day offset
    ${today_offset}=    Get Current Week Day Offset
    # Cross-validate: resolving the returned offset back to a date must equal today's date
    ${resolved_today}=    Calculate Date From Week Day Offset    ${today_offset}    date_format=${date_format}
    Should Be Equal As Strings    ${resolved_today}    ${today}

Example 10: All date operations in DateTime library without planning week base date
    [Documentation]    Example of using various date operations from the DateTime library without planning week base date.
    ...    With ${PLANNING_WEEK_ENABLED}=False, the framework ignores PLANNING_WEEK_BASE_DATE from config.json and
    ...    anchors all calculations to the current real-world planning week (derived from FISCAL_WEEK_START_DAY).
    [Tags]    no_planning_week_date_example
    # Explicitly disable planning-week base date so calculations are anchored to today's actual planning week.
    VAR    ${PLANNING_WEEK_ENABLED}    ${False}    scope=TEST
    ${date_format}=    Get Config Value    DATE_FMT_YEAR_MONTH_DAY

    # Reference base = start of the CURRENT planning week (computed from FISCAL_WEEK_START_DAY, not from config base date).
    ${current_week_start}=    Get Planning Week Start    date_format=${date_format}

    ${date}=    Calculate Date From Week Day Offset    0_0    date_format=${date_format}
    Should Be Equal As Strings    ${date}    ${current_week_start}

    ${date}=    Calculate Date From Week Day Offset    0_1    date_format=${date_format}
    ${actual_date}=    Add Time To Date    ${current_week_start}    1 days    result_format=${date_format}
    Should Be Equal As Strings    ${date}    ${actual_date}

    ${date}=    Calculate Date From Week Day Offset    1_0    date_format=${date_format}
    ${actual_date}=    Add Time To Date    ${current_week_start}    7 days    result_format=${date_format}
    Should Be Equal As Strings    ${date}    ${actual_date}

    ${date}=    Calculate Date From Week Day Offset    -1_1    date_format=${date_format}
    ${actual_date}=    Subtract Time From Date    ${current_week_start}    6 days    result_format=${date_format}
    Should Be Equal As Strings    ${date}    ${actual_date}

    ${today}=    Get Current Date    result_format=${date_format}    exclude_millis=True
    # Default call (no offset) -> today's offset within the CURRENT real planning week.
    # When PLANNING_WEEK_ENABLED=False the week part must always be 0 and the day part within [0, 6].
    ${today_offset}=    Get Current Week Day Offset
    ${week_part}    ${day_part}=    Split String    ${today_offset}    _
    Should Be Equal As Strings    ${week_part}    0
    Should Be True    0 <= ${day_part} <= 6    Day part out of range: ${today_offset}
    # Cross-validate: resolving the returned offset back to a date must equal today's date.
    ${resolved_today}=    Calculate Date From Week Day Offset    ${today_offset}    date_format=${date_format}
    Should Be Equal As Strings    ${resolved_today}    ${today}

    # Same day next week and last week should be exactly +/- 7 days from today.
    ${next_week_offset}=    Get Current Week Day Offset    week_offset=1
    ${resolved_next_week}=    Calculate Date From Week Day Offset    ${next_week_offset}    date_format=${date_format}
    ${expected_next_week}=    Add Time To Date    ${today}    7 days    result_format=${date_format}
    Should Be Equal As Strings    ${resolved_next_week}    ${expected_next_week}

    ${last_week_offset}=    Get Current Week Day Offset    week_offset=-1
    ${resolved_last_week}=    Calculate Date From Week Day Offset    ${last_week_offset}    date_format=${date_format}
    ${expected_last_week}=    Subtract Time From Date    ${today}    7 days    result_format=${date_format}
    Should Be Equal As Strings    ${resolved_last_week}    ${expected_last_week}
