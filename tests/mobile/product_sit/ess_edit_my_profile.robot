*** Settings ***
Documentation       BATTC00113 - Verify ESS user is able to edit My Profile Contact Information

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Profile/Profile.resource
Resource            resources/Mobile/ESS/PagesResources/Profile/Profile_Edit.resource

Suite Teardown       Run Keyword And Ignore Error    Close Application

Test Tags           dev:moiz    battc00113    bat_phase2    config:ess_mobile_edit    config:ess_email_edit    mobile
...    config:mobile_shift_enabled


*** Variables ***
${NEW_MOBILE_NUMBER}    1234567890
${NEW_EMAIL}            abc@gmail.com


*** Test Cases ***
BATTC00113: Verify editing of My Profile by ESS user in mobility
    [Documentation]    Verify ESS user is able to add day off requests in mobility with holiday hours
    ${user}    Get User    user_key=ESS2_STORE2
    Open Mobile ESS App    battc00113
    Login Mobile Ess App    ESS2_STORE2
    Navigate Mobile ESS To Profile From Shortcut Menu
    Verify ESS Profile Username On Mobile ESS    ${user}[username]
    ${is_contact_info_available}    Is Contact Information Present In UI On Mobile ESS
    IF    ${is_contact_info_available}
        ${user_mobile_number}    Get Mobile Number On ESS Profile On Mobile ESS
        Update Mobile ESS Profile Mobile Number    ${NEW_MOBILE_NUMBER}
        ${user_edited_mobile_number}    Get Mobile Number On ESS Profile On Mobile ESS
        Should Be True    ${user_edited_mobile_number}    ${NEW_MOBILE_NUMBER}
        Update Mobile ESS Profile Mobile Number    ${user_mobile_number}
        ${user_email}    Get Email On ESS Profile On Mobile ESS
        Update Mobile ESS Profile Email    ${NEW_EMAIL}
        ${user_edited_email}    Get Email On ESS Profile On Mobile ESS
        Should Be True    ${user_edited_email}    ${NEW_EMAIL}
        Update Mobile ESS Profile Email    ${user_email}
    END

    [Teardown]    Teardown Test Case    battc00113
