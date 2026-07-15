*** Settings ***
Documentation       BATTC00131 - Verify User Is Able To Edit Contact Details From Roster In Mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/More/More.resource
Resource            resources/Mobile/SM/PagesResources/Associate_Roster/Associate_Roster.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           dev:bushra    battc00131    config:rws    mobile    bat_phase2    config:mobile_sm_enabled    bug_reported    bugid_wfm_138085


*** Variables ***
${NEW_PHONE_NUMBER}     1234567890


*** Test Cases ***
BATTC00131: Verify user is able to edit contact details from roster in mobility
    [Documentation]    Verifies that users can edit their contact details from the roster in the SM mobile application.
    Open SM Native Application On Mobile Phone    battc00131
    Login SM App On Mobile    SM1_STORE2
    ${ess_user2}    Get User    user_key=ESS2_STORE2
    Select More Tab On SM Phone App
    Select Associate Roster From More Tab On SM Phone App
    Verify Associate Roster Page Is Visible On SM Phone App
    Search And Select Associate Name On Associate Roster Page On SM Phone App    ${ess_user2}[displayName]
    ${phone}    Get Mobile Phone From Contact Info Associate Roster Page On SM Phone App
    Edit Mobile Phone In Contact Info Associate Roster Page On SM Phone App    ${NEW_PHONE_NUMBER}
    ${edited_phone}    Get Mobile Phone From Contact Info Associate Roster Page On SM Phone App
    Should Be Equal    ${edited_phone}    ${NEW_PHONE_NUMBER}    msg=Mobile phone was not updated successfully.
    Edit Mobile Phone In Contact Info Associate Roster Page On SM Phone App    ${phone}
    ${restored_phone}    Get Mobile Phone From Contact Info Associate Roster Page On SM Phone App
    Should Be Equal    ${restored_phone}    ${phone}    msg=Mobile phone was not restored successfully.
    Logout SM App On Mobile

    [Teardown]    Teardown Test Case    battc00131
