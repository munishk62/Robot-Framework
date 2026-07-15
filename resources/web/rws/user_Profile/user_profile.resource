*** Settings ***
Documentation
...                 This resource file provides keywords for automating the User Profile page.

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/rws/user_Profile/user_profile_page.py
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/common/calendar_navigation.resource


*** Keywords ***
Navigate To RWS Users User Profile Page On Web
    [Documentation]    Navigate To RWS -> Users -> User Profile Page
    ...    and verifies user profile heading at the top of the page
    Navigate To Specific Page On Web    rws    users    user_profile

Add RWS User Profile On Web
    [Documentation]    Add RWS User Profile
    ...    This keyword adds a new user profile with proper error handling and wait conditions.
    ...    It handles environment-specific values and timing issues that may occur across different environments.
    [Arguments]    ${profile_id}    ${profile_description}=Automation
    Click Element On Webpage    ${USER_PROFILE_PAGE_ADD_BUTTON}
    ...    error_message=Failed to click Add button on User Profile page
    Wait Until Page Is Loaded
    Fill Textbox On Webpage    ${USER_PROFILE_PAGE_PROFILE_ID_TEXTBOX}    ${profile_id}
    Fill Textbox On Webpage    ${USER_PROFILE_PAGE_DESCRIPTION_TEXTBOX}    ${profile_description}
    ${org_level_value}    Get System Value    UserProfileOrganizationLevel    CORPORATE
    Wait Until Element Is Visible On Webpage    ${USER_PROFILE_PAGE_ORGANIZATION_LEVEL_LIST}
    ...    error_message=Organization level dropdown not visible
    Select List Item On Webpage    ${USER_PROFILE_PAGE_ORGANIZATION_LEVEL_LIST}    value    ${org_level_value}
    ${org_level}    Get Selected List Item On Webpage    ${USER_PROFILE_PAGE_ORGANIZATION_LEVEL_LIST}    text
    Click Element On Webpage    ${USER_PROFILE_PAGE_ORGANIZATION_LEVEL_LIST}
    ${copy_permission_option}    Get System Value    UserProfileCopyPermissions    SYSTEM_ADMINISTRATOR
    Wait Until Element Is Visible On Webpage    ${USER_PROFILE_PAGE_COPY_PERMISSIONS_LIST}
    ...    error_message=Copy permissions dropdown not visible
    Select List Item On Webpage    ${USER_PROFILE_PAGE_COPY_PERMISSIONS_LIST}    value    ${copy_permission_option}
    Wait Until Element Is Visible On Webpage    ${USER_PROFILE_PAGE_USED_FOR_PERMISSIONS_CHECKBOX}
    ...    error_message=Used for Permissions checkbox not visible
    Click Element On Webpage    ${USER_PROFILE_PAGE_USED_FOR_PERMISSIONS_CHECKBOX}
    ...    error_message=Failed to click 'Used for Permissions' checkbox

    Wait Until Element Is Visible On Webpage    ${USER_PROFILE_PAGE_ASSOCIATED_DEPT_CORP_CHECKBOX}
    ...    error_message=Associated department corporate checkbox not visible
    Click Element On Webpage    ${USER_PROFILE_PAGE_ASSOCIATED_DEPT_CORP_CHECKBOX}
    ...    error_message=Failed to click associated department corporate checkbox
    ${promise}    Promise To    Wait For Alert    action=accept    timeout=3s
    Wait Until Element Is Visible On Webpage    ${USER_PROFILE_PAGE_SAVE_BUTTON}
    ...    error_message=Save button not visible
    Click Element On Webpage    ${USER_PROFILE_PAGE_SAVE_BUTTON}
    ${alert_appeared}    Run Keyword And Return Status    Wait For    ${promise}
    IF    ${alert_appeared}
        Log    Alert was accepted successfully    level=INFO
    ELSE
        Log    No alert appeared - continuing without alert handling    level=INFO
    END
    Wait Until Element Is Visible On Webpage    ${USER_PROFILE_PAGE_HEADER_ITEM}
    ...    timeout=${LONG_TIMEOUT}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage
    VAR    ${selected_org_level}    ${org_level}[0]
    RETURN    ${selected_org_level}

Verify RWS User Profile Seen Under Organization Level On Web
    [Documentation]    Verify RWS User Profile Seen Under Organization Level
    [Arguments]    ${organization_level}    ${profile_id}
    Wait Until Element Disappears On Webpage    ${USER_PROFILE_PAGE_SPINNER}    timeout=${LONG_TIMEOUT}
    Wait Until Page Is Loaded
    ${user_profile_created}    Update Locator With Dynamic Values    ${USER_PROFILE_PAGE_USER}    organization_level=${organization_level}
    ...    profile_id=${profile_id}
    Capture Screenshot On Webpage
    Wait For Elements State    ${user_profile_created}    timeout=${LONG_TIMEOUT}

Edit RWS User Profile On Web
    [Documentation]    Edit the Description of the User Profile
    [Arguments]    ${profile_id}    ${organization_level}    ${profile_description}=Edited_Profile_Description
    ${user}    Update Locator With Dynamic Values    ${USER_PROFILE_PAGE_USER}    organization_level=${organization_level}
    ...    profile_id=${profile_id}
    Click Element On Webpage    ${user}
    ...    error_message=Failed to click on user profile '${profile_id}' under organization level '${organization_level}'
    Type Text    ${USER_PROFILE_PAGE_DESCRIPTION_TEXTBOX}    ${profile_description}
    ${promise}    Promise To    Wait For Alert    action=accept    timeout=3s
    Click Element On Webpage    ${USER_PROFILE_PAGE_SAVE_BUTTON}
    ...    error_message=Failed to click Save button while editing user profile
    ${alert_appeared}    Run Keyword And Return Status    Wait For    ${promise}
    IF    ${alert_appeared}
        Log    Alert was accepted successfully    level=INFO
    ELSE
        Log    No alert appeared - continuing without alert handling    level=INFO
    END
    Wait Until Element Disappears On Webpage    ${USER_PROFILE_PAGE_SAVE_BUTTON}

Delete RWS User Profile On Web
    [Documentation]    Delete the User Profile
    [Arguments]    ${profile_id}
    ${user_delete_icon}    Update Locator With Dynamic Values    ${USER_PROFILE_PAGE_DELETE_ICON}    profile_id=${profile_id}
    ${promise}    Promise To    Wait For Alert    action=accept    timeout=3s
    Click Element On Webpage    ${user_delete_icon}
    ${alert_appeared}    Run Keyword And Return Status    Wait For    ${promise}
    IF    ${alert_appeared}
        Log    Delete confirmation alert was accepted    level=INFO
    ELSE
        Log    No alert appeared - profile may have been deleted without confirmation    level=INFO
    END
    Wait Until Element Disappears On Webpage    ${USER_PROFILE_PAGE_SPINNER}    timeout=${LONG_TIMEOUT}
    Capture Screenshot On Webpage
    Wait Until Page Is Loaded

Verify RWS User Profile Not Seen On Web
    [Documentation]    Verify RWS User Profile Not Seen
    [Arguments]    ${organization_level}    ${profile_id}
    Wait Until Page Is Loaded
    ${user_profile_created}    Update Locator With Dynamic Values    ${USER_PROFILE_PAGE_USER}    organization_level=${organization_level}
    ...    profile_id=${profile_id}
    ${user_profile_created_not_displayed}    Is Element Visible On Webpage    ${user_profile_created}
    Should Not Be True    ${user_profile_created_not_displayed}    User profile ${profile_id} is still visible on the page

Click On Add User Profile Button On User Profile Page On Web
    [Documentation]    Clicks the "Add User Profile" button on the user profile page to open the add user profile form, which surfaces additional visible text for i18n verification.
    Click Element On Webpage    ${USER_PROFILE_PAGE_ADD_BUTTON}
    ...    error_message=Failed to click element ${USER_PROFILE_PAGE_ADD_BUTTON} on webpage
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${USER_PROFILE_PAGE_SAVE_BUTTON}
    ...    error_message=Element ${USER_PROFILE_PAGE_SAVE_BUTTON} was not visible on webpage
    Capture Screenshot On Webpage
