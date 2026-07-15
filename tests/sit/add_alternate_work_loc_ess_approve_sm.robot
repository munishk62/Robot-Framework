*** Settings ***
Documentation       SITTC60069 - Cross Shift Bidding - Add alternate location request from ESS and approve from SM
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Request_Module/Request_Teardown.resource
Resource            resources/Mobile/ESS/PagesResources/Alt_Work_Location_Module/Alternate_Work_Location.resource
Resource            resources/Mobile/SM/PagesResources/Alt_Work_Location_Module/Alternate_Work_Location.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags    dev:bushra    sittc60069    config:rws    config:ess    config:ess_alternate_work_location    config:weekplan_and_schedule_gen    mobile    sit


*** Variables ***
@{UNIT_ID}    STORE14


*** Test Cases ***
SITTC60069: Cross Shift Bidding - Add alternate location request from ESS and approve from SM
    [Documentation]    Cross Shift Bidding - Add alternate location request from ESS and approve from SM
    ${work_location_data}    Get Alternate Work Location Data    start_date=6_0    end_date=6_6    unit_ids=${UNIT_ID}
    ${ess_user}    Get User    ESS16_STORE15
    Open Mobile ESS App    sittc60069
    Login Mobile Ess App    ESS16_STORE15
    Navigate To ESS Work Locations Page On Mobile ESS
    Select Alternate Work Location Requests Tab On Mobile ESS

    # Delete any existing requests for same duration to avoid conflicts
    ${is_same_request_present}    Run Keyword And Return Status
    ...    Verify Mobile ESS Alternate Work Location Request List Item On Mobile ESS    ${work_location_data}[unit_ids]
    ...    ${work_location_data}[start_date]    ${work_location_data}[end_date]    ${work_location_data}[status]
    IF    ${is_same_request_present}
        Tap Alternate Work Location Request List Item On Mobile ESS    ${work_location_data}[unit_ids]    ${work_location_data}[start_date]
        ...    ${work_location_data}[end_date]    ${work_location_data}[status]
        Delete Alternate Work Location Request From Details On Mobile ESS
    END
    Open Add Alternate Work Location Page On Mobile ESS
    Add Alternate Work Location Request On Mobile ESS    ${work_location_data}[description]    ${work_location_data}[start_date]
    ...    ${work_location_data}[end_date]    ${work_location_data}[unit_ids]    ${work_location_data}[note]
    Select Alternate Work Location Requests Tab On Mobile ESS
    Verify Mobile ESS Alternate Work Location Request List Item On Mobile ESS    ${work_location_data}[unit_ids]
    ...    ${work_location_data}[start_date]    ${work_location_data}[end_date]    ${work_location_data}[status]
    Close Mobile Application    sittc60069_alternate_work_location_request_ess

    Open SM Native Application On Mobile Phone    sittc60069
    Login SM App On Mobile    SM1_STORE15
    Navigate To Associate Roster Module On SM Phone App
    Search And Select Associate Name On Associate Roster Page On SM Phone App    ${ess_user}[displayName]
    Navigate To Alternate Work Location Tab On Associate Roster Page On SM Phone App
    Select Alternate Work Location Request List Item On SM Phone App    ${work_location_data}[start_date]    ${work_location_data}[end_date]
    Select Edit Status Of Alternate Work Location Request On SM Phone App
    Select Approved Status Of Alternate Work Location Request On SM Phone App
    Update Status Of Alternate Work Location Request On SM Phone App
    Verify Request Status Is Approved On SM Phone App
    Close Snack Bar When Visible On SM Phone App
    Close Details Page Of Alternate Work Location Request On SM Phone App
    Select Alternate Work Location Request List Item On SM Phone App    ${work_location_data}[start_date]    ${work_location_data}[end_date]
    Withdraw Alternate Work Location Request On SM Phone App
    Delete Alternate Work Location Request From Details On SM Phone App

    [Teardown]    Teardown Test Case    sittc60069_sm1_approve
