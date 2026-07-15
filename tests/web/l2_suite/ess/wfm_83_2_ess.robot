*** Settings ***
Documentation       This test suite verifies if user is able to add/edit mobile number in My Profile page in ESS.

Resource            resources/web/authentication/login.resource
Resource            resources/web/ess/my_profile.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:write    battc00093    config:ess_mobile_edit    bat_phase1    config:ess    om_hr


*** Test Cases ***
BATTC00093: Verify editing of mobile number in My Profile by ESS user
    [Documentation]    Test case for verifying whether user is able to add/edit mobile number in My Profile page in ESS
    Login And Launch WFM Web App    user_key=ESS2_STORE1
    ${my_profile_data}    Get My Profile Data
    Navigate To ESS My Profile Page On Web
    Check Whether ESS User Has Edit Permission On Web
    Check Whether ESS User Has Mobile Number Text Field On Web
    ${current_mobile_number}    Get Current Mobile Number On Web
    Update Mobile Number On Web    ${my_profile_data}[mobile_number]
    Navigate To ESS My Profile Page On Web
    Verify Contact Mobile Number On Web    ${my_profile_data}[mobile_number]
    Update Mobile Number On Web    ${current_mobile_number}
