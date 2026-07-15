*** Settings ***
Documentation       This resource file contains keywords related to ESS -> My Profile Page.

Library             test_data/TestDataLibrary.py
Variables           resources/web/ess/my_profile_page.py
Variables           resources/web/ess/my_profile_page_api.py
Variables           resources/web/common/status_codes.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To ESS My Profile Page On Web
    [Documentation]    Navigate To ESS -> My Profile -> My Profile Page
    Navigate To Specific Page On Web    ess    my_profile

Check Whether ESS User Has Edit Permission On Web
    [Documentation]    This keyword checks whether the ESS User has Edit Permission
    ...    | =Behavior= | Skips test if edit icon is not present |
    ${edit_icon_present}    Is Element Present On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}
    IF    ${edit_icon_present}
        Log    ESS User has Edit Permission
    ELSE
        Capture Screenshot On Webpage
        SKIP    ESS User does not have Edit Permission
    END

Check Whether ESS User Has Mobile Number Text Field On Web
    [Documentation]    This keyword checks whether the ESS User has Mobile Number Text Field
    ...    | =Behavior= | Skips test if mobile number input field is not present |
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}
    ${mob_input_field_present}    Is Element Present On Webpage    ${MY_PROFILE_PAGE_CONTACT_MOBILE_NUMBER_INPUT_FIELD}
    IF    ${mob_input_field_present}
        Log    ESS User has Mobile Number Text Field
    ELSE
        Capture Screenshot On Webpage
        SKIP    ESS User does not have Mobile Number Text Field
    END
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}

Verify Contact Mobile Number On Web
    [Documentation]    This keyword verifies the Contact Mobile Number on My Profile Page
    ...    | =Arguments= | =Description= |
    ...    | mobile_number | Mobile number to be verified and validated |
    [Arguments]    ${mobile_number}
    ${expected_mobile_number}    Update Locator With Dynamic Values    ${MY_PROFILE_PAGE_MOBILE_NUMBER_VALUE}
    ...    MOBILE_NUMBER=${mobile_number}
    Wait Until Element Is Visible On Webpage    ${expected_mobile_number}

Update Mobile Number On Web
    [Documentation]    This keyword updates Mobile Number on My Profile Page with the given mobile number and saves the changes.
    ...    | =Arguments= | =Description= |
    ...    | mobile_number | Mobile number to be updated |
    [Arguments]    ${mobile_number}
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}
    Fill Text    ${MY_PROFILE_PAGE_CONTACT_MOBILE_NUMBER_INPUT_FIELD}    ${mobile_number}
    Click My Profile Save Button On Web

Get Current Mobile Number On Web
    [Documentation]    Get the current mobile number from the Mobile Number field on My Profile Page
    ...    | =Returns= | =Description= |
    ...    | mobile_number | Current mobile number present in the field |
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}
    ${mobile_number}    Get Element Text On Webpage    ${MY_PROFILE_PAGE_CONTACT_MOBILE_NUMBER_INPUT_FIELD}
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}
    RETURN    ${mobile_number}

Click My Profile Save Button On Web
    [Documentation]    This keyword is used to click on Save button on My Profile Page
    ${promise}    Promise To    Wait For Response    ${MY_PROFILE_PAGE_CONTACT_UPDATE_NOTIFICATION_API}
    Click Element On Webpage    ${MY_PROFILE_PAGE_SAVE_BUTTON}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]

Verify Green Bar Success Message Is Seen In Web
    [Documentation]    This keyword verifies if the success notification message is popped up after saving the changes on My Profile Page.
    Wait Until Element Is Visible On Webpage    ${MY_PROFILE_PAGE_SUCCESS_NOTIFICATION}
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${MY_PROFILE_PAGE_SUCCESS_NOTIFICATION}

Check Whether ESS User Has Email Text Field On Web
    [Documentation]    Check whether the ESS User has Email Text Field
    ...    | =Behavior= | Skips test if email input field is not present |
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}
    ${value}    Is Element Present On Webpage    ${MY_PROFILE_PAGE_CONTACT_EMAIL_INPUT_FIELD}
    IF    ${value}
        Log    ESS User has Email Text Field
    ELSE
        Capture Screenshot On Webpage
        SKIP    ESS User does not have Email Text Field
    END
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}

Update Contact Email On Web
    [Documentation]    Edit Contact Email on My Profile Page with the given email id and save
    ...    | =Arguments= | =Description= |
    ...    | email_id | Email id to be updated |
    [Arguments]    ${email_id}
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}
    Fill Text    ${MY_PROFILE_PAGE_CONTACT_EMAIL_INPUT_FIELD}    ${email_id}
    Click My Profile Save Button On Web

Get Current Email ID On Web
    [Documentation]    Get the current email id from the Contact Email field on My Profile Page
    ...    | =Returns= | =Description= |
    ...    | email_id | Current email id present in the field |
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}
    ${email_id}    Get Element Text On Webpage    ${MY_PROFILE_PAGE_CONTACT_EMAIL_INPUT_FIELD}
    Click Element On Webpage    ${MY_PROFILE_PAGE_CONTACT_INFO_EDIT_ICON}
    RETURN    ${email_id}

Verify Contact Email On Web
    [Documentation]    Verify the Contact Email on My Profile Page
    ...    | =Arguments= | =Description= |
    ...    | email_id | Email id to be verified and validated |
    [Arguments]    ${email_id}
    ${expected_email_id}    Update Locator With Dynamic Values    ${MY_PROFILE_PAGE_EMAIL_ID_VALUE}
    ...    EMAIL_ID=${email_id}
    Wait Until Element Is Visible On Webpage    ${expected_email_id}
