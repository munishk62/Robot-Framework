*** Settings ***
Documentation       Has all the user interaction implementations of the Profile module.

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource


*** Keywords ***
Verify ESS Profile Username On Mobile ESS
    [Documentation]    Verify profile username is visible in Nextgen ESS app.
    ...    | ===Arguments=== | ===Description=== |
    ...    | profile_username | user profile name |
    [Arguments]    ${profile_username}
    ${profile_username}    Get Locator Contains    ${profile_username}
    Swipe Until Visible    ${profile_username}

Get Mobile Number On ESS Profile On Mobile ESS
    [Documentation]    Returns Mobile Number from Contact Information on Profile
    ...    | ===Returns=== | ===Description=== |
    ...    | ${mobile_number} | Mobile Number available in Contact Information |
    ${contact_info}    Get Localised Message From Key    ${PROFILE_LABEL_CONTACT_INFORMATION}
    ${mobile}    Get Localised Message From Key    ${PROFILE_LABEL_MOBILE}
    ${contact_info_mobile_locator}    Get Message With Arguments    ${PROFILE_EDIT_MOBILE_INPUT_TEXTBOX}    ${contact_info}    ${mobile}
    Swipe Until Visible    ${contact_info_mobile_locator}
    ${mobile_number}    AppiumLibrary.Get Text    ${contact_info_mobile_locator}
    RETURN    ${mobile_number}

Is Contact Information Present In UI On Mobile ESS
    [Documentation]    Returns if Contact Information is enabled or not.
    ...    | ===Returns=== | ===Description=== |
    ...    | ${True} | If Enabled |
    ${contact_info}    Get Localised Message From Key    ${PROFILE_LABEL_CONTACT_INFORMATION}
    ${mobile}    Get Localised Message From Key    ${PROFILE_LABEL_MOBILE}
    ${contact_info_mobile_locator}    Get Message With Arguments    ${PROFILE_EDIT_MOBILE_INPUT_TEXTBOX}    ${contact_info}    ${mobile}
    ${is_contact_info_available}    Is Element Present On Mobile    ${contact_info_mobile_locator}
    RETURN    ${is_contact_info_available}

Get Email On ESS Profile On Mobile ESS
    [Documentation]    Returns Mobile Number from Contact Information on Profile
    ...    | ===Returns=== | ===Description=== |
    ...    | ${email} | Email available in Contact Information |
    ${contact_info}    Get Localised Message From Key    ${PROFILE_LABEL_CONTACT_INFORMATION}
    ${mobile}    Get Localised Message From Key    ${PROFILE_LABEL_EMAIL}
    ${contact_info_email_locator}    Get Message With Arguments    ${PROFILE_EDIT_EMAIL_INPUT_TEXTBOX}    ${contact_info}    ${mobile}
    Swipe Until Visible    ${contact_info_email_locator}
    ${email}    AppiumLibrary.Get Text    ${contact_info_email_locator}
    RETURN    ${email}
