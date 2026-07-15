*** Settings ***
Documentation       Verify whether user is able to navigate past and future weeks using week navigator in Timecard Page.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    config:rta    action:read    obsolete


*** Test Cases ***
WFM-68-1 Verify Navigation In Past And Future Weeks Using Week Navigator In Timecard Page
    [Documentation]    This test case is to verify if the user is able to navigate past
    ...    and future weeks using the week navigator in the Timecard page.
    [Tags]    timecard_navigator
    ${sys_admin_user}    Get User    user_key=SYSADMIN
    Login To WFM    ${sys_admin_user}[user_key]
    ${store_data}    Get Store Data
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    Navigate To RTA Operations Exception Management Page On Web
    Click On Clock Icon Of First Employee On Exception Management Page On Web
    Verify Timecard Page Is Loaded On Web
    &{week_info}    Verify Week Navigation Info In Timecard Page On Web
    Capture Screenshot On Webpage
    Shift To Next Week Timecard Of User
    ${next_week_number}    ${next_week_start_date}    ${next_week_end_date}
    ...    Get Shown Week Date Range From Timecard Page
    Validate The Navigation Date Info On Timecard Page On Web
    ...    ${week_info}
    ...    ${next_week_number}
    ...    ${next_week_start_date}
    ...    ${next_week_end_date}
    ...    navigate_next
    Shift To Previous Week Timecard Of User
    Shift To Previous Week Timecard Of User
    ${previous_week_number}    ${previous_week_start_date}    ${previous_week_end_date}
    ...    Get Shown Week Date Range From Timecard Page
    Validate The Navigation Date Info On Timecard Page On Web
    ...    ${week_info}
    ...    ${previous_week_number}
    ...    ${previous_week_start_date}
    ...    ${previous_week_end_date}
    ...    navigate_previous
