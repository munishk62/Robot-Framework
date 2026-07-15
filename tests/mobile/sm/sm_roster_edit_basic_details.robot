*** Settings ***
Documentation       BATTC00130 - Verify editing basic details of associate on associate roster page

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Associate_Roster/Associate_Roster.resource
Resource            resources/Mobile/SM/PagesResources/More/More.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           action:write    dev:moiz    battc00130    mobile    bat_phase2    config:rws    bug_reported    bugid_wfm_138085  regrooming_required
...    config:mobile_sm_enabled


*** Test Cases ***
BATTC00130: Verify user is able to edit basic details from roster in mobility
    [Documentation]    Verifies that SM user can edit the basic details of an associate on the associate roster page
    ${user}    Get User    ESS2_STORE2
    # Regrooming required for the below verification steps.

    # VAR    &{gender_details}    gender=Male
    # @{name_parts}    Split String    ${user}[displayName]    ,
    # ${last_name}    Strip String    ${name_parts}[0]
    # ${first_name}    Strip String    ${name_parts}[1]

    Open SM Native Application On Mobile Phone    battc00130
    Login SM App On Mobile    SM1_STORE2
    Select More Tab On SM Phone App
    Select Associate Roster From More Tab On SM Phone App
    Verify Associate Roster Page Is Visible On SM Phone App
    Search And Select Associate Name On Associate Roster Page On SM Phone App    ${user}[displayName]

    # Regrooming required for the below verification steps.
    # Verify Basic Details Of Associate On Associate Roster Page On SM Phone App    ${user}[username]    ${first_name}    ${last_name}
    # ...    ${user}[displayName]    ${gender_details}
    # Edit Basic Details Of Associate On Associate Roster Page On SM Phone App    edit_first_name=Edit ${first_name}
    # Verify Basic Details Of Associate On Associate Roster Page On SM Phone App    ${user}[username]    Edit ${first_name}    ${last_name}
    # ...    ${user}[displayName]    ${gender_details}
    # Edit Basic Details Of Associate On Associate Roster Page On SM Phone App    edit_first_name=${first_name}
    # Verify Basic Details Of Associate On Associate Roster Page On SM Phone App    ${user}[username]    ${first_name}    ${last_name}
    # ...    ${user}[displayName]    ${gender_details}

    Verify Basic Details Of Associate On Associate Roster Page On SM Phone App    ${user}[displayName]
    Logout SM App On Mobile

    [Teardown]    Teardown Test Case    battc00130
