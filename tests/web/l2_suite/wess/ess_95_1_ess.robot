*** Settings ***
Documentation       Verify Whether User Is Able To Add Edit Delete Availability Request And Verify Notifications On ESS

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/ess_request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Availability_Module/Availability_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up Permanent Availability Request    ESS3_STORE1    SM1_STORE1    2_0    AND
...                     Close Browser

Test Tags           action:write    battc00100    dev:moiz    config:add_edit_delete_availability_ess    bat_phase1    config:ess    om_hr    bug_reported    bugid_wfm-138543


*** Test Cases ***
BATTC00100: Verify that an ESS user is able to add/edit delete availability requests and receive notifications
    [Documentation]    Verify whether user is able to add, edit, delete availability request and verify notifications on ESS.
    Login And Launch WFM Web App    user_key=ESS3_STORE1
    Navigate To ESS Request Calendar Page
    Cleanup Existing Availability Requests On Requests Calendar Page On Web
    ${availability_data}    Get Request Availability Data
    Select Day On Request Calendar Page    ${availability_data}[first_rotation_date]
    ${store_data}    Get System Value    StoreEntity    MODEL_STORE1
    ${availability_status}    Get System Value    AvailabilityStatus    NOT_REVIEWED
    VAR    ${rotation_num}    1
    VAR    ${add_availability_num}    1
    VAR    ${edit_availability_num}    2
    ${rotation_elements_count}    Get Count Of Rotations Available On Availability Request On Request Calendar Page On Web
    Add Availability Request On Request Calendar Page On Web    ${availability_data}[first_rotation_date]
    ...    ${availability_data}[preference]    ${availability_data}[reason]    ${availability_data}
    Verify Availability Request Values On Request Calendar Page On Web    ${availability_data}[preference]    ${store_data}[UNIT_ID]
    ...    ${availability_status}    ${availability_data}[reason]    ${rotation_num}    ${add_availability_num}    ${availability_data}
    Edit Weekly Data In Availability Request On Request Calendar Page On Web    ${availability_data}[edit_availability_request]
    Verify Availability Request Values On Request Calendar Page On Web    ${availability_data}[preference]    ${store_data}[UNIT_ID]
    ...    ${availability_status}    ${availability_data}[reason]    ${rotation_num}    ${edit_availability_num}
    ...    ${availability_data}[edit_availability_request]
    ${my_work_enabled}    Get Config Value    key=MYWORK_ENABLED
    ${availability_my_work_notification}    Get Config Value    key=AVAILABILITY_MYWORK_NOTIFICATIONS_ENABLED
    IF    ${my_work_enabled} and ${availability_my_work_notification}
        Log    Both MYWORK_ENABLED and AVAILABILITY_MYWORK_NOTIFICATIONS_ENABLED are True - Verifying notifications level=INFO
        Navigate To Web My Work Page On Web
        Verify ESS Availability Request Notification On Web    ${availability_data}[first_rotation_date]
        Capture Screenshot On Webpage
        Navigate To ESS Request Calendar Page
    ELSE
        Log
        ...    Skipping My Work notification verification - MYWORK_ENABLED: ${my_work_enabled}, AVAILABILITY_MYWORK_NOTIFICATIONS_ENABLED: ${availability_my_work_notification}
        ...    level=WARN
    END
    IF    ${rotation_elements_count} > 1
        ${availability_data_second_rotation}    Get Request Availability Data    template_name=add_edit_2_rotation
        Navigate To Next Week On Request Calendar Page On Web    times_to_navigate=1
        Add Availability Request On Request Calendar Page On Web    ${availability_data_second_rotation}[second_rotation_date]
        ...    ${availability_data_second_rotation}[preference]    ${availability_data_second_rotation}[reason]
        ...    ${availability_data_second_rotation}
    END
