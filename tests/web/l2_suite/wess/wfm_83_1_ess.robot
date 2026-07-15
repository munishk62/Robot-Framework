*** Settings ***
Documentation       This test suite verifies if user is able to add/edit email id in My Profile page in ESS.

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/my_profile.resource

Test Teardown       Close Browser

Test Tags    action:write    battc00092    config:ess_email_edit    dev:ravi    bat_phase1    config:ess    om_hr    bug_reported


*** Test Cases ***
BATTC00092: Verify editing of email in My Profile by ESS user
    [Documentation]    Test case for verifying whether user is able to add/edit email id in My Profile page in ESS
    Login And Launch WFM Web App    user_key=ESS2_STORE1
    ${my_profile_data}    Get My Profile Data
    Navigate To ESS My Profile Page On Web
    Check Whether ESS User Has Edit Permission On Web
    Check Whether ESS User Has Email Text Field On Web
    ${current_email_id}    Get Current Email ID On Web
    Update Contact Email On Web    ${my_profile_data}[email_id]
    Navigate To ESS My Profile Page On Web
    Verify Contact Email On Web    ${my_profile_data}[email_id]
    Update Contact Email On Web    ${current_email_id}
