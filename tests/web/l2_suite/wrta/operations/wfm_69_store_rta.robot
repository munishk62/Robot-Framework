*** Settings ***
Documentation       This test case is to verify if the user is able to use legend functionality.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    config:rta    action:read    obsolete


*** Test Cases ***
WFM-69-1 Verify whether user is able to use legend functionality
    [Documentation]    This test case is to verify if the user is able to use legend functionality.
    [Tags]    timecard_legend
    ${sys_admin_user}    Get User    user_key=SYSADMIN
    Login To WFM    ${sys_admin_user}[user_key]
    ${store_data}    Get Store Data
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    Navigate To RTA Operations Exception Management Page On Web
    Verify Exception Management Page Is Loaded On Web
    Wait Until Page Is Loaded
    Click On Clock Icon Of First Employee On Exception Management Page On Web
    Verify Timecard Page Is Loaded On Web
    Show Legend Dialog Box On Timecard Page On Web
    Verify Legend Tab Is Visible On TimeCard Page On Web
    Capture Screenshot On Webpage
