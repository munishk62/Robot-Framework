*** Settings ***
Documentation       SITTC60063 - Requests - SM cross-day time off validation, add time off ending at midnight, and edit in month view
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Request/Request.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource

Test Setup          Run Keywords
...        Clean Up Time Off Request For User On Date    ESS8_STORE11    SM1_STORE11    start_date_offset=2_6    AND
...        Clean Up Time Off Request For User On Date    ESS8_STORE11    SM1_STORE11    start_date_offset=3_1

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    SITTC60063    config:ess    config:ess_request_calendar    config:add_edit_delete_timeoff_request_sm
...          mobile    sit    sit_b0    sit_v1    sit_r22
...    config:mobile_sm_enabled


*** Test Cases ***
SITTC60063: Requests - SM cross-day time off validation, add time off ending at midnight, and edit in month view
    [Documentation]    Verify SM cross-day time off constraints, midnight end time handling, and month-view edit across planning weeks.
    ${cross_day_time_off_data}    Get Time Off Data    start_date=2_6    start_time=22:00    end_time=2:00    duration=04:00
    ${midnight_time_off_data}    Get Time Off Data    start_date=2_6    start_time=20:00    end_time=00:00    duration=04:00
    ${edited_time_off_data}    Get Time Off Data    start_date=3_1    start_time=20:00    end_time=00:00    duration=04:00

    Open SM Native Application On Mobile Phone    SITTC60063
    Login SM App On Mobile    SM1_STORE11
    Navigate To Request On SM Phone App

    Add Time Off Details On SM Phone App    ESS8_STORE11    ${cross_day_time_off_data}[reason]
    ...    ${cross_day_time_off_data}[start_date]    ${cross_day_time_off_data}[start_time]    ${cross_day_time_off_data}[duration]
    Verify Snackbar Is Visible On SM Phone App
    Add Time Off Details On SM Phone App    ESS8_STORE11    ${midnight_time_off_data}[reason]
    ...    ${midnight_time_off_data}[start_date]    ${midnight_time_off_data}[start_time]    ${midnight_time_off_data}[duration]
    Request Calendar Navigation On SM Phone App    ${midnight_time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App
    ...    ESS8_STORE11
    ...    ${midnight_time_off_data}[start_date]
    ...    ${midnight_time_off_data}[start_time]
    ...    ${midnight_time_off_data}[end_time]
    ...    ${midnight_time_off_data}[status]
    Verify Time Off Details On SM Phone App
    ...    ${midnight_time_off_data}[start_date]
    ...    status=${midnight_time_off_data}[status]

    Edit Time Off Details On SM Phone App    date_time_off=${edited_time_off_data}[start_date]    calendar_open_date=${midnight_time_off_data}[start_date]
    Request Calendar Navigation On SM Phone App    ${edited_time_off_data}[start_date]    ${midnight_time_off_data}[start_date]
    Select Specific Time Off Request On SM Phone App
    ...    ESS8_STORE11
    ...    ${edited_time_off_data}[start_date]
    ...    ${midnight_time_off_data}[start_time]
    ...    ${midnight_time_off_data}[end_time]
    ...    ${midnight_time_off_data}[status]
    Verify Time Off Details On SM Phone App
    ...    ${edited_time_off_data}[start_date]
    ...    status=${midnight_time_off_data}[status]
    [Teardown]    Teardown Test Case    sittc60063_sm1_cross_day_time_off
