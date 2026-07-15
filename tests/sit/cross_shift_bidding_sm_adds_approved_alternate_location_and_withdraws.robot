*** Settings ***
Documentation       SITTC60072 - Cross Shift Bidding - SM adds approved alternate location request and withdraws it
Library             Collections
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Alt_Work_Location_Module/Alternate_Work_Location.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:rashi    sittc60072    config:rws    config:ess    config:ess_alternate_work_location    config:weekplan_and_schedule_gen    mobile    sit


*** Variables ***
@{UNIT_ID}    STORE14


*** Test Cases ***
SITTC60072: Cross Shift Bidding - SM adds approved alternate location request and withdraws it
    [Documentation]    Cross Shift Bidding - SM adds approved alternate location request and withdraws it
    ${work_location_data}    Get Alternate Work Location Data    unit_ids=${UNIT_ID}
    ${ess_user}    Get User    user_key=ESS25_STORE15
    ${status_approved}    Get System Value    RequestStatus    APPROVED

    Open SM Native Application On Mobile Phone    sittc60072
    Login SM App On Mobile    SM1_STORE15
    Select More Tab On SM Phone App
    Select Associate Roster From More Tab On SM Phone App
    Search And Select Associate Name On Associate Roster Page On SM Phone App    ${ess_user}[displayName]
    Navigate To Alternate Work Location Tab On Associate Roster Page On SM Phone App

    Delete Alternate Work Location Request If Present For Any Status On Mobile SM App
    ...    ${work_location_data}[unit_ids]    ${work_location_data}[start_date]    ${work_location_data}[end_date]

    Open Add Alternate Work Location Page On Mobile SM
    Add Alternate Work Location Request On Mobile SM    ${work_location_data}[description]    ${work_location_data}[start_date]    ${work_location_data}[end_date]    ${work_location_data}[unit_ids]    status=${status_approved}
    Verify Mobile SM Alternate Work Location Request List Item On Mobile SM App    ${status_approved}    ${work_location_data}[unit_ids]
    ...    ${work_location_data}[start_date]    ${work_location_data}[end_date]

    Tap Alternate Work Location Request List Item On Mobile SM App    ${status_approved}    ${work_location_data}[unit_ids]    ${work_location_data}[start_date]
    ...    ${work_location_data}[end_date]
    Withdraw Alternate Work Location Request On SM Phone App
    Sleep    5s
    Close Details Page Of Alternate Work Location Request On SM Phone App

    Verify Mobile SM Alternate Work Location Request List Item On Mobile SM App    Partially Reviewed    ${work_location_data}[unit_ids]
    ...    ${work_location_data}[start_date]    ${work_location_data}[end_date]
    Tap Alternate Work Location Request List Item On Mobile SM App    Partially Reviewed    ${work_location_data}[unit_ids]    ${work_location_data}[start_date]
    ...    ${work_location_data}[end_date]
    Delete Alternate Work Location Request From Details On SM Phone App

    [Teardown]    Teardown Test Case    sittc60072_sm_add_approved_withdraw
