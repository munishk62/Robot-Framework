*** Settings ***
Documentation       Has all the user interaction implementations of the Profile edit module.

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource


*** Keywords ***
Tap Edit Button On ESS Profile On Mobile
    [Documentation]    Taps the mobile ESS profile edit button.
    ${locator}    Get Localised Locator Contains    ${commonLabelEdit}
    VAR    @{commonLabelEdit}    ${locator}
    Wait Until Element Is Visible    @{commonLabelEdit}
    Click Element    @{commonLabelEdit}

Save ESS Profile Edit On Mobile
    [Documentation]    Save a profile edit on mobile Nextgen ESS app.
    ${common_label_save_locator}    Get Localised Locator Exact    ${common_label_save}
    Wait Until Element Is Visible    ${common_label_save_locator}
    Click Element    ${common_label_save_locator}

Verify Edit Success Notification For Profile On Mobile
    [Documentation]    Edit success notification
    Wait Until Element Is Visible    ${PROFILE_EDIT_NOTIFICATION}
    Wait Until Page Does Not Contain Element    ${PROFILE_EDIT_NOTIFICATION}

Update Contact Information Mobile On ESS Profile On Mobile
    [Documentation]    Updates the mobile Nextgen ESS profile contact information mobile.
    ...    | ===Arguments=== | ===Description=== |
    ...    | new_mobile_number |    Mobile Number to be updated |
    [Arguments]    ${new_mobile_number}
    ${mobile_field_editable}    Run Keyword And Return Status    Wait Until Element Is Visible    ${PROFILE_EDIT_MOBILE_INPUT_TEXTBOX}
    IF    not ${mobile_field_editable}
        Skip    msg=Mobile Number field not available for edit in this env.
    END
    Swipe Until Visible    ${PROFILE_EDIT_MOBILE_INPUT_TEXTBOX}
    Input Text    ${PROFILE_EDIT_MOBILE_INPUT_TEXTBOX}    ${new_mobile_number}

Update Mobile ESS Profile Mobile Number
    [Documentation]    Updates the mobile ESS profile contact information mobile number.
    ...    | ===Arguments=== | ===Description=== |
    ...    | new_mobile_number |    Mobile Number to be updated |
    [Arguments]    ${new_mobile_number}
    Tap Edit Button On ESS Profile On Mobile
    Update Contact Information Mobile On ESS Profile On Mobile    ${new_mobile_number}
    Save ESS Profile Edit On Mobile
    Verify Edit Success Notification For Profile On Mobile

Update Contact Information Email On ESS Profile On Mobile
    [Documentation]    Updates the mobile Nextgen ESS profile contact information email.
    ...    | ===Arguments=== | ===Description=== |
    ...    | new_email |    Email to be updated |
    [Arguments]    ${new_email}
    ${email_field_editable}    Run Keyword And Return Status    Wait Until Element Is Visible    ${PROFILE_EDIT_EMAIL_INPUT_TEXTBOX}
    IF    not ${email_field_editable}
        Skip    msg=Email field not available for edit in this env.
    END
    Swipe Until Visible    ${PROFILE_EDIT_EMAIL_INPUT_TEXTBOX}
    Input Text    ${PROFILE_EDIT_EMAIL_INPUT_TEXTBOX}    ${new_email}

Update Mobile ESS Profile Email
    [Documentation]    Updates the mobile ESS profile contact information email.
    ...    | ===Arguments=== | ===Description=== |
    ...    | new_email |    Email to be updated |
    [Arguments]    ${new_email}
    Tap Edit Button On ESS Profile On Mobile
    Update Contact Information Email On ESS Profile On Mobile    ${new_email}
    Save ESS Profile Edit On Mobile
    Verify Edit Success Notification For Profile On Mobile
