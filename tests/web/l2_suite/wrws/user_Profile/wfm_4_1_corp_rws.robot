*** Settings ***
Documentation       Test case to Verify Corp User Can Add Edit Delete User Profile

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/user_Profile/user_profile.resource

Test Teardown       Close Browser

Test Tags    dev:rushikesh    action:write    battc00004    config:corp_add_edit_delete_user_profile    bat_phase1    om_hr


*** Test Cases ***
BATTC00004: Verify add/edit/delete for user profiles
    [Documentation]    Test case to Verify Corp User Can Add Edit Delete User Profile
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Users User Profile Page On Web
    ${random_num}    Generate Random String    5    [NUMBERS]
    VAR    ${profile_id}    user_${random_num}
    ${organization_level}    Add RWS User Profile On Web    ${profile_id}
    Verify RWS User Profile Seen Under Organization Level On Web    ${organization_level}    ${profile_id}
    Edit RWS User Profile On Web    ${profile_id}    ${organization_level}
    Verify RWS User Profile Seen Under Organization Level On Web    ${organization_level}    ${profile_id}
    [Teardown]    Run Keyword And Ignore Error    Cleanup User Profile    ${profile_id}    ${organization_level}


*** Keywords ***
Cleanup User Profile
    [Documentation]    Cleans up the created user profile and verifies deletion
    [Arguments]    ${profile_id}    ${organization_level}
    Run Keyword And Continue On Failure    Delete RWS User Profile On Web    ${profile_id}
    Navigate To RWS Users User Profile Page On Web
    Wait Until Page Is Loaded
    Verify RWS User Profile Not Seen On Web    ${organization_level}    ${profile_id}
