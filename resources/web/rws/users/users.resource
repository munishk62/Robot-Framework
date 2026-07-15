*** Settings ***
Documentation
...                 This resource file provides keywords for automating the User Profile page.

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/rws/users/users_page.py
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/common/calendar_navigation.resource
Resource            resources/web/authentication/login.resource


*** Keywords ***
Navigate To RWS Users User Page On Web
    [Documentation]    Navigate To RWS -> Users -> User Profile Page
    ...    and verifies user profile heading at the top of the page
    Navigate To Specific Page On Web    rws    users    users

Add User On Users Page On Web
    [Documentation]    Add User On Users Page On Web
    [Arguments]    ${user_id}    ${user_data}
    Click Element On Webpage    ${USER_PAGE_ADD_USER_BTN}
    Wait Until Element Is Visible On Webpage    ${USER_PAGE_USER_ID_TXT}
    Fill In Mandatory User Data And Save User On Web    ${user_id}    ${user_data}[user_name]    ${user_data}[recovery_email]
    ...    password=${user_data}[password]    status=${user_data}[user_status]    work_in=${user_data}[user_work_in]

Fill In Mandatory User Data And Save User On Web
    [Documentation]    Enter mandatory user details as per stated fields.
    [Arguments]    ${user_id}    ${user_name}    ${recovery_email}    ${password}    ${status}    ${work_in}
    Wait Until Element Is Visible On Webpage    ${USER_PAGE_USER_ID_TXT}
    Fill Textbox On Webpage    ${USER_PAGE_USER_ID_TXT}    ${user_id}
    Fill Textbox On Webpage    ${USER_PAGE_USER_NAME_TXT}    ${user_name}
    Fill Textbox On Webpage    ${USER_PAGE_RECOVERY_EMAIL_ID_TXT}    ${user_id}_${recovery_email}
    Fill Textbox On Webpage    ${USER_PAGE_USER_PASSWORD_TXT}    ${password}
    Select List Item On Webpage    ${USER_PAGE_USER_STATUS_LIST}    value    ${status}
    Select List Item On Webpage    ${USER_PAGE_USER_WORKS_IN_LIST}    value    ${work_in}
    Click Element On Webpage    ${USER_PAGE_UNIT}
    Click Element On Webpage    ${USER_PAGE_UNIT_OPTION}
    Click Element On Webpage    ${USER_PAGE_PROFILE_NAME_SYSADMIN_CHK}
    Click Element On Webpage    ${USER_PAGE_DEPARTMENT_CORP_CHK}
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${USER_PAGE_USER_SAVE_BTN}
    Wait For    ${promise}
    # Replace Class Names Dynamically And Perform Further Actions
    Click Element On Webpage    ${USER_PAGE_ADD_USER_PREVIOUS_BTN}

Verify User Is Created Successfully
    [Documentation]    Check if the user is created successfully.
    [Arguments]    ${user_id_value}
    Search User With User Id In Users Page On Web    ${user_id_value}
    Capture Screenshot On Webpage

Search User With User Id In Users Page On Web
    [Documentation]    Search user with userId
    [Arguments]    ${user_id_value}
    Click Element On Webpage    ${USER_PAGE_USER_LIST_LNK}
    Click Element On Webpage    ${USER_PAGE_USER_SEARCH_CLEAR_BTN}
    Wait For Elements State    ${USER_PAGE_USER_SEARCH_USER_ID}
    Fill Textbox On Webpage    ${USER_PAGE_USER_SEARCH_USER_ID}    ${user_id_value}
    Click Element On Webpage    ${USER_PAGE_USER_SEARCH_APPLY_BTN}
    Wait For Elements State    ${USER_PAGE_USER_SEARCH_USER_ID}    hidden
    Wait Until Element Is Visible On Webpage    ${USER_PAGE_USER_SEARCH_RESULT}

Open User Details Page And Edit User In Users Page On Web
    [Documentation]    Open user details page and edit user.
    [Arguments]    ${user_id_value}    ${user_name}    ${new_user_name}
    Search User With User Id In Users Page On Web    ${user_id_value}
    ${user_navigation_lnk_dynamic}    Replace String    ${USER_PAGE_USER_NAVIGATION_LNK}
    ...    {automation_user_name}    ${user_name}
    Click Element On Webpage    ${user_navigation_lnk_dynamic}
    Wait Until Element Is Visible On Webpage    ${USER_PAGE_USER_EDIT_PAGE_HEADER}
    Wait Until Spinner Disappears On Users Page On Web
    Fill Textbox On Webpage    ${USER_PAGE_USER_NAME_TXT}    ${new_user_name}
    Click Element On Webpage    ${USER_PAGE_USER_EDIT_PAGE_HEADER}
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${USER_PAGE_USER_SAVE_BTN}
    Capture Screenshot On Webpage
    Wait Until Spinner Disappears On Users Page On Web
    Wait For    ${promise}

Verify User Data Is Updated Successfully On Users Page On Web
    [Documentation]    Verify the user data is updated successfully.
    [Arguments]    ${user_id_value}    ${new_user_name}
    Click Element On Webpage    ${USER_PAGE_ADD_USER_PREVIOUS_BTN}
    Search User With User Id In Users Page On Web    ${user_id_value}
    ${user_navigation_lnk_dynamic}    Replace String    ${USER_PAGE_USER_NAVIGATION_LNK}    {automation_user_name}    ${new_user_name}
    Search User With User Id In Users Page On Web    ${user_id_value}
    ${updated_user_name_displayed}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${user_navigation_lnk_dynamic}
    Should Be True    ${updated_user_name_displayed}    msg=User name was not updated successfully

Open User Details Page And Delete User In Users Page On Web
    [Documentation]    Open the user details page and then delete the user.
    [Arguments]    ${user_id_value}    ${new_user_name}
    Search User With User Id In Users Page On Web    ${user_id_value}
    ${user_navigation_lnk_dynamic}    Replace String    ${USER_PAGE_USER_NAVIGATION_LNK}
    ...    {automation_user_name}    ${new_user_name}
    Click Element On Webpage    ${user_navigation_lnk_dynamic}
    Wait Until Element Is Visible On Webpage    ${USER_PAGE_USER_EDIT_PAGE_HEADER}
    Click Element On Webpage    ${USER_PAGE_USER_DELETE_BTN}

Verify User Is Deleted Successfully
    [Documentation]    Verify the user is deleted successfully.
    [Arguments]    ${user_id_value}
    Search User With User Id In Users Page On Web    ${user_id_value}
    Wait Until Element Is Visible On Webpage    ${USER_PAGE_USER_DELETED_STATUS_LBL}

Verify Error Message Displayed On Web
    [Documentation]    Check if an error message is displayed on the user page.
    Wait Until Page Is Loaded
    ${is_error_displayed}    Is Element Visible On Webpage    ${USER_PAGE_ERROR_MESSAGE}
    IF    not ${is_error_displayed}
        ${is_red_error_displayed}    Is Element Visible On Webpage    ${USER_PAGE_ERROR_RED_MESSAGE}
        Should Be True    ${is_red_error_displayed}    msg=Expected error message to be displayed on the user page.
    END

Login With New User On Web
    [Documentation]    Login with newly created user credentials
    [Arguments]    ${user_id}    ${password}    ${url}
    Launch Browser
    Launch WFM Web Application    ${url}
    Enter Username    ${user_id}
    Enter Password    ${password}
    Click Login Button
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Open User Details Page And Delete User On Web
    [Documentation]    Open the user details page and then delete the user.
    [Arguments]    ${user_id}
    Search User With User Id In Users Page On Web    ${user_id}
    ${user_navigation_link}    Update Locator With Dynamic Values    ${USER_PAGE_USER_DETAILS_LINK}    USER_ID=${user_id}
    Click Element On Webpage    ${user_navigation_link}
    Wait Until Element Is Visible On Webpage    ${USER_PAGE_USER_EDIT_PAGE_HEADER}
    Click Element On Webpage    ${USER_PAGE_USER_DELETE_BTN}
    Wait Until Page Is Loaded

Reset Password For New User On Web
    [Documentation]    Reset password for new user on web while logging in for the first time
    [Arguments]    ${new_password}
    ${dropdown_count}    Get Element Count On Web Page    ${USER_PAGE_USER_SECURITY_QUESTION_DROPDOWN_COUNT}
    FOR    ${index}    IN RANGE    0    ${dropdown_count}
        ${dropdown}    Update Locator With Dynamic Values    ${USER_PAGE_USER_SECURITY_QUESTION_DROPDOWN}    DROPDOWN=${index}
        ${option_index}    Evaluate    ${index} + 1
        Select List Item On Webpage    ${dropdown}    index    ${option_index}
        ${answer_field}    Update Locator With Dynamic Values    ${USER_PAGE_USER_SECURITY_ANSWER_FIELD}    ANSWER=${index}
        Fill Textbox On Webpage    ${answer_field}    Answer_${index}
    END
    ${is_new_password_field_visible}    Is Element Visible On Webpage    ${USER_PAGE_USER_NEW_PASSWORD_FIELD}
    IF    ${is_new_password_field_visible}
        Fill Textbox On Webpage    ${USER_PAGE_USER_NEW_PASSWORD_FIELD}    ${new_password}
        Fill Textbox On Webpage    ${USER_PAGE_USER_RETYPE_PASSWORD_FIELD}    ${new_password}
    END
    Click Element On Webpage    ${USER_PAGE_USER_RESET_SAVE_BTN}
    Wait Until Page Is Loaded
    RETURN    ${is_new_password_field_visible}

Verify If Password Reset Page Displayed On Web
    [Documentation]    Verify if password reset page is displayed on web
    Wait Until Page Is Loaded
    ${is_reset_header_visible}    Is Element Visible On Webpage    ${USER_PAGE_USER_RESET_HEADER}
    RETURN    ${is_reset_header_visible}

Click On Add User Button On Users Page On Web
    [Documentation]    Clicks the "Add User" button on the users page to open the add user form, which surfaces additional visible text for i18n verification.
    Click Element On Webpage    ${USER_PAGE_ADD_USER_BTN}
    ...    error_message=Failed to click element ${USER_PAGE_ADD_USER_BTN} on webpage
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${USER_PAGE_ADD_USER_PREVIOUS_BTN}
    ...    error_message=Element ${USER_PAGE_ADD_USER_PREVIOUS_BTN} was not visible on webpage
    Capture Screenshot On Webpage

Wait Until Spinner Disappears On Users Page On Web
    [Documentation]    Waits until the loading spinner disappears on users page.
    ${spinner_wait}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${USER_PAGE_SPINNER}    timeout=${SHORT_TIMEOUT}
    IF    ${spinner_wait}
        Wait Until Element Disappears On Webpage    ${USER_PAGE_SPINNER}    timeout=${LONG_TIMEOUT}
    END

Finish New Hire Setup If Required On Web
    [Documentation]    Reset password for new user on web while logging in for the first time
    [Arguments]    ${new_hire_user_key}
    ${is_reset_header_visible}    Is Element Visible On Webpage    ${USER_PAGE_USER_RESET_HEADER}
    IF    ${is_reset_header_visible}
        ${dropdown_count}    Get Element Count On Web Page    ${USER_PAGE_USER_SECURITY_QUESTION_DROPDOWN_COUNT}
        FOR    ${index}    IN RANGE    0    ${dropdown_count}
            ${dropdown}    Update Locator With Dynamic Values    ${USER_PAGE_USER_SECURITY_QUESTION_DROPDOWN}    DROPDOWN=${index}
            ${option_index}    Evaluate    ${index} + 1
            Select List Item On Webpage    ${dropdown}    index    ${option_index}
            ${answer_field}    Update Locator With Dynamic Values    ${USER_PAGE_USER_SECURITY_ANSWER_FIELD}    ANSWER=${index}
            Fill Textbox On Webpage    ${answer_field}    Answer_${index}
        END
        ${is_new_password_field_visible}    Is Element Visible On Webpage    ${USER_PAGE_USER_NEW_PASSWORD_FIELD}
        IF    ${is_new_password_field_visible}
            ${employee}    Get Dynamic Employee    ${new_hire_user_key}
            Fill Textbox On Webpage    ${USER_PAGE_USER_NEW_PASSWORD_FIELD}    ${employee}[password]
            Fill Textbox On Webpage    ${USER_PAGE_USER_RETYPE_PASSWORD_FIELD}    ${employee}[password]
        ELSE
            Log    New password fields are not visible on the reset page. Skipping password reset.
            ${employee}    Get Dynamic Employee    ${new_hire_user_key}
            ${employee}    Set To Dictionary    ${employee}    password=${employee}[employee_id]
            Set Dynamic Employee    ${new_hire_user_key}    ${employee}
        END
        Click Element On Webpage    ${USER_PAGE_USER_RESET_SAVE_BTN}
        Wait Until Page Is Loaded
    END
