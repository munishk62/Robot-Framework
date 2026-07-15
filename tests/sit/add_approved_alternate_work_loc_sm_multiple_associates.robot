*** Settings ***
Documentation       SITTC60073 - SM adds approved alternate location requests for associates A16 to A18 at Store 14
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource
Resource            resources/Mobile/ESS/PagesResources/Alt_Work_Location_Module/Alternate_Work_Location.resource
Resource            resources/Mobile/SM/PagesResources/Alt_Work_Location_Module/Alternate_Work_Location.resource
Resource            resources/Mobile/SM/PagesResources/Associate_Roster/Associate_Details.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:bushra    sittc60073    config:rws    config:ess    config:ess_alternate_work_location    config:weekplan_and_schedule_gen    mobile    sit


*** Variables ***
@{UNIT_ID}    STORE15


*** Test Cases ***
SITTC60073: SM adds approved alternate location requests for associates A16 to A18 at Store 14
    [Documentation]    SM adds approved alternate location requests for associates A16 to A18 at Store 14
    ${work_location_data}    Get Alternate Work Location Data    start_date=6_0    end_date=6_6    unit_ids=${UNIT_ID}
    ${status_approved}    Get System Value    RequestStatus    APPROVED
    ${ess_user1}    Get User    ESS16_STORE14
    ${ess_user2}    Get User    ESS17_STORE14
    ${ess_user3}    Get User    ESS18_STORE14

    Open SM Native Application On Mobile Phone    sittc60073_add_approved_alternate_work_location_request_sm
    Login SM App On Mobile    SM1_STORE14
    Navigate To Associate Roster Module On SM Phone App
    Search And Select Associate Name On Associate Roster Page On SM Phone App    ${ess_user1}[displayName]
    Navigate To Alternate Work Location Tab On Associate Roster Page On SM Phone App
    Open Add Alternate Work Location Page On Mobile SM
    Add Alternate Work Location Request On Mobile SM    ${work_location_data}[description]    ${work_location_data}[start_date]    ${work_location_data}[end_date]    ${work_location_data}[unit_ids]    status=${status_approved}
    Verify Alternate Work Location Request List Item On SM Phone App    ${work_location_data}[start_date]    ${work_location_data}[end_date]
    Close Snack Bar When Visible On SM Phone App
    Navigate Back From Alternate Work Location On SM Phone App

    Search And Select Associate Name On Associate Details Page On SM Phone App    ${ess_user2}[displayName]
    Navigate To Alternate Work Location Tab On Associate Roster Page On SM Phone App
    Open Add Alternate Work Location Page On Mobile SM
    Add Alternate Work Location Request On Mobile SM    ${work_location_data}[description]    ${work_location_data}[start_date]    ${work_location_data}[end_date]    ${work_location_data}[unit_ids]    status=${status_approved}
    Verify Alternate Work Location Request List Item On SM Phone App    ${work_location_data}[start_date]    ${work_location_data}[end_date]
    Close Snack Bar When Visible On SM Phone App
    Navigate Back From Alternate Work Location On SM Phone App

    Search And Select Associate Name On Associate Details Page On SM Phone App    ${ess_user3}[displayName]
    Navigate To Alternate Work Location Tab On Associate Roster Page On SM Phone App
    Open Add Alternate Work Location Page On Mobile SM
    Add Alternate Work Location Request On Mobile SM    ${work_location_data}[description]    ${work_location_data}[start_date]    ${work_location_data}[end_date]    ${work_location_data}[unit_ids]    status=${status_approved}
    Verify Alternate Work Location Request List Item On SM Phone App    ${work_location_data}[start_date]    ${work_location_data}[end_date]
    Close Snack Bar When Visible On SM Phone App
    Navigate Back From Alternate Work Location On SM Phone App

    Search And Select Associate Name On Associate Details Page On SM Phone App    ${ess_user1}[displayName]
    Navigate To Alternate Work Location Tab On Associate Roster Page On SM Phone App
    Select Alternate Work Location Request List Item On SM Phone App    ${work_location_data}[start_date]    ${work_location_data}[end_date]
    Withdraw Alternate Work Location Request On SM Phone App
    Delete Alternate Work Location Request From Details On SM Phone App
    Close Snack Bar When Visible On SM Phone App
    Navigate Back From Alternate Work Location On SM Phone App
    Search And Select Associate Name On Associate Details Page On SM Phone App    ${ess_user2}[displayName]
    Navigate To Alternate Work Location Tab On Associate Roster Page On SM Phone App
    Select Alternate Work Location Request List Item On SM Phone App    ${work_location_data}[start_date]    ${work_location_data}[end_date]
    Withdraw Alternate Work Location Request On SM Phone App
    Delete Alternate Work Location Request From Details On SM Phone App
    Close Snack Bar When Visible On SM Phone App
    Navigate Back From Alternate Work Location On SM Phone App
    Search And Select Associate Name On Associate Details Page On SM Phone App    ${ess_user3}[displayName]
    Navigate To Alternate Work Location Tab On Associate Roster Page On SM Phone App
    Select Alternate Work Location Request List Item On SM Phone App    ${work_location_data}[start_date]    ${work_location_data}[end_date]
    Withdraw Alternate Work Location Request On SM Phone App
    Delete Alternate Work Location Request From Details On SM Phone App
    Close Snack Bar When Visible On SM Phone App
    Navigate Back From Alternate Work Location On SM Phone App

    [Teardown]    Teardown Test Case    sittc60073_add_approved_alternate_work_location_request_sm
