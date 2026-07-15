*** Settings ***
Documentation       Test case to Verify Corp User Can Search Add Edit Delete User

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/users/users.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:write    battc00002    config:corp_add_edit_delete_user    bat_phase1    config:rws    om_hr


*** Test Cases ***
BATTC00002: Verify search/add/edit/delete for users
    [Documentation]    Test case to Verify Corp User Can Add Edit Delete User Profile
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${APP_URL}    Get Config Value    key=app_url
    Navigate To RWS Users User Page On Web
    ${random_num}    Generate Random String    5    [NUMBERS]
    VAR    ${user_id}    user_${random_num}
    ${user_data}    Get Users Data
    Add User On Users Page On Web    ${user_id}    ${user_data}
    Verify User Is Created Successfully    ${user_id}
    Log Out From Web Application
    Login With New User On Web    ${user_id}    ${user_data}[password]    ${APP_URL}
    ${is_reset_header_visible}    Verify If Password Reset Page Displayed On Web
    IF    ${is_reset_header_visible}
        ${is_new_password_field_visible}    Reset Password For New User On Web    ${user_data}[reset_password]
        IF    ${is_new_password_field_visible}
            Login With New User On Web    ${user_id}    ${user_data}[reset_password]    ${APP_URL}
        ELSE
            Login With New User On Web    ${user_id}    ${user_data}[password]    ${APP_URL}
        END
    END
    Navigate To RWS Users User Page On Web
    Search User With User Id In Users Page On Web    ${user_id}
    Open User Details Page And Edit User In Users Page On Web    ${user_id}    ${user_data}[user_name]    ${user_data}[user_name]_edited
    Verify User Data Is Updated Successfully On Users Page On Web    ${user_id}    ${user_data}[user_name]_edited
    Log Out From Web Application
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Users User Page On Web
    Open User Details Page And Delete User In Users Page On Web    ${user_id}    ${user_data}[user_name]_edited
    Verify User Is Deleted Successfully    ${user_id}
    Log Out From Web Application
    IF    ${is_reset_header_visible}
        IF    ${is_new_password_field_visible}
            Login With New User On Web    ${user_id}    ${user_data}[reset_password]    ${APP_URL}
            Verify Error Message Displayed On Web
        ELSE
            Login With New User On Web    ${user_id}    ${user_data}[password]    ${APP_URL}
            Verify Error Message Displayed On Web
        END
    END
    Login With New User On Web    ${user_id}    ${user_data}[password]    ${APP_URL}
    Verify Error Message Displayed On Web
