*** Settings ***
Documentation       Test case to verify sorting on Sort Preferences on Schedule Page

Resource            resources/web/rws/schedule/week_schedule.resource
Resource            resources/web/authentication/login.resource

Test Teardown       Close Browser

Test Tags           dev:moiz    action:read    battc00029    obsolete


*** Test Cases ***
BATTC00029: WFM-24 Verify Sort Preferences On Week Schedule Page
    [Documentation]    Test case for verifying None, Department and Reset sorting on Week Schedule page
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${store_data}    Get Store Data
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    Navigate To RWS Schedule Week Schedule Page On Web
    ${week_schedule_page_loaded}    Check If Week Schedule Page Is Loaded On Web
    IF    ${week_schedule_page_loaded}
        # before department sorting, set page view of none group type sort
        Perform Group By None Sorting On Sort Preferences On Week Schedule Page On Web
        Verify Group By Header Not Visible On Week Schedule Page On Web
        # sort by department
        Perform Group By Department Sorting On Sort Preferences On Week Schedule Page On Web
        Verify Group By Header Visible On Week Schedule Page On Web
        # revert to None Group sort
        Perform Group By None Sorting On Sort Preferences On Week Schedule Page On Web
        # reset sort preferences
        Perform Reset For Sort Preferences On Week Schedule Page On Web
        Verify Group By Header Visible On Week Schedule Page On Web
    ELSE
        SKIP    msg=Week Schedule page is not loaded for the store: ${store_data}[store_name]
    END
