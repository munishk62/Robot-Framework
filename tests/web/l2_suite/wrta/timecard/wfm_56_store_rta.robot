*** Settings ***
Documentation       Test case for verifying Timecard page UI

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Test Teardown       Close Browser

Test Tags           dev:ravi    action:read    config:rta    battc00070    obsolete


*** Test Cases ***
BATTC00070: WFM-56 Verify Timecard Page UI
    [Documentation]    Test case for verifying Timecard page UI and to assert associate name on the page
    ${sm_user}    Get User    user_key=SM1_STORE1
    Login And Launch WFM Web App    ${sm_user}[user_key]

    ${store_data}    Get Store Data
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    Navigate To RTA Operations Exception Management Page On Web

    ${employee_id}    Get First Employee Id On Exception Management Page On Web

    Click On Clock Icon Of First Employee On Exception Management Page On Web
    Verify Timecard Page Is Loaded On Web
    Verify Employee Id On Timecard Page On Web    ${employee_id}
