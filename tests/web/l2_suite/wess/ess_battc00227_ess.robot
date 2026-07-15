*** Settings ***
Documentation       Verify Whether User Is Able To Add Edit Delete Temporary Availability Request And Verify Notifications.

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/my_availability.resource
Resource            resources/Mobile/ESS/PagesResources/Availability_Module/Availability_Teardown.resource

Test Teardown       Run Keywords
...                     Clean Up Temporary Availability Request    ESS2_STORE1    SM1_STORE1    8_0    AND
...                     Close Browser

Test Tags    action:write    battc00227    dev:moiz    config:add_edit_delete_availability_ess    bat_phase2    config:ess    bug_reported
...    bug_id:wfm-139716    om_hr    config:temporary_availability_enabled


*** Test Cases ***
BATTC00227: Verify ESS user is able to add / edit / delete temporary availability in web
    [Documentation]    Verify whether user is able to add, edit, delete temporary availability request and verify notifications on ESS.
    Login And Launch WFM Web App    user_key=ESS2_STORE1
    Navigate To ESS My Availability Page
    ${availability_data}    Get Request Availability Data    template_name=add_my_availability
    VAR    @{effective_date_list}    @{EMPTY}
    Append To List    ${effective_date_list}    ${availability_data}[week_date]
    Cleanup Existing Availability Requests On My Availability Page On Web    @{effective_date_list}
    ${is_week_start_applicable}    Add Availability Request On My Availability Page On Web    ${availability_data}[week_date]
    ...    ${availability_data}[preference]    ${availability_data}[reason]    ${availability_data}
    Edit Weekly Data In Availability Request On My Availability Page On Web    ${availability_data}[week_date]
    ...    ${availability_data}[edit_my_availability]    ${is_week_start_applicable}
    Delete Availability Request On My Availability Page On Web    ${availability_data}[week_date]
