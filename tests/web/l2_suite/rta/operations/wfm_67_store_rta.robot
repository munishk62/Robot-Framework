*** Settings ***
Documentation       This test case is to verify if the user is able to add, edit and delete Daily and Weekly Notes.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/timecard_list.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    config:rta    action:write


*** Test Cases ***
WFM-67-1 Verify User Is Able To Add, Edit And Delete Daily Notes
    [Documentation]    This test case is to verify if the user is able to add, edit and delete Daily Notes.
    [Tags]    timecard_daily_notes
    # Perform login as corporate user
    Login And Launch WFM Web App    user_key=SYSADMIN
    # Get Store Details and Switch to Store Admin Profile
    ${store_data}    Get Store Data
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    # Switch to Store
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    Navigate To RTA Operations Timecard List Page On Web
    Click On The Associate At Required Index On Timecard List Page On Web    1
    Go To Notes Tab On Timecard List Page On Web
    # Store the existing note (if any)
    ${existing_note}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    1
    # Clear the note
    Delete Note In Daily Notes Table At Row Number On Timecard List Page On Web    1
    ${empty_note}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    1
    # Add The Note in Daily Notes Table
    Add Note In Daily Notes Table At Row Number On Timecard List Page On Web    1    Added the notes!!
    ${added_note}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    1
    Open The Audit From The Row In Daily Notes Table On Timecard List Page On Web    1
    Verify And Validate The Notes Audit Data From The Latest Timestamp On Timecard List Page On Web
    ...    Added    ${empty_note}    ${added_note}
    Close Notes Audit Table Window On Timecard List Page On Web
    # Edit The Note in Daily Notes Table
    Add Note In Daily Notes Table At Row Number On Timecard List Page On Web    1    Updated the notes!!
    ${edited_note}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    1
    Open The Audit From The Row In Daily Notes Table On Timecard List Page On Web    1
    Verify And Validate The Notes Audit Data From The Latest Timestamp On Timecard List Page On Web
    ...    Edited    ${added_note}    ${edited_note}
    Close Notes Audit Table Window On Timecard List Page On Web
    # Delete The Note in Daily Notes Table
    Delete Note In Daily Notes Table At Row Number On Timecard List Page On Web    1
    ${deleted_note}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    1
    Open The Audit From The Row In Daily Notes Table On Timecard List Page On Web    1
    Verify And Validate The Notes Audit Data From The Latest Timestamp On Timecard List Page On Web
    ...    Deleted    ${edited_note}    ${deleted_note}
    Close Notes Audit Table Window On Timecard List Page On Web
    # Reset the note with the initial value.
    Add Note In Daily Notes Table At Row Number On Timecard List Page On Web    1    ${existing_note}
    ${restored_note}    Get Note From The Row In Daily Notes Table On Timecard List Page On Web    1
    Should Be Equal As Strings    ${restored_note}    ${existing_note}
    Switch To Home From Store On Web

WFM-67-2 Verify User Is Able To Add, Edit And Delete Weekly Notes
    [Documentation]    This test case is to verify if the user is able to add, edit and delete Weekly Notes.
    [Tags]    timecard_weekly_notes    obsolete
    # Perform login as corporate user
    Login And Launch WFM Web App    user_key=SYSADMIN
    # Get Store Details and Switch to Store Admin Profile
    ${store_data}    Get Store Data
    ${store_profile_name}    Get System Value    UserProfiles    STORE_ADMIN
    # Switch to Store
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile_name}
    Navigate To RTA Operations Timecard List Page On Web
    Click On The Associate At Required Index On Timecard List Page On Web    1
    Go To Notes Tab On Timecard List Page On Web
    # Store the existing note (if any)
    ${existing_weekly_note}    Get Note From The Weekly Notes Table On Timecard List Page On Web
    # Clear the note
    Delete Note In Weekly Notes Table On Timecard List Page On Web
    ${empty_weekly_note}    Get Note From The Weekly Notes Table On Timecard List Page On Web
    # Add The Note in Weekly Notes Table
    Add Note In Weekly Notes Table On Timecard List Page On Web    Added Weekly Notes!!
    ${added_weekly_note}    Get Note From The Weekly Notes Table On Timecard List Page On Web
    Open The Audit From The Weekly Notes Table On Timecard List Page On Web
    Verify And Validate The Notes Audit Data From The Latest Timestamp On Timecard List Page On Web
    ...    Added    ${empty_weekly_note}    ${added_weekly_note}
    Close Notes Audit Table Window On Timecard List Page On Web
    # Edit The Note in Weekly Notes Table
    Add Note In Weekly Notes Table On Timecard List Page On Web    Updated Weekly Notes!!
    ${edited_weekly_note}    Get Note From The Weekly Notes Table On Timecard List Page On Web
    Open The Audit From The Weekly Notes Table On Timecard List Page On Web
    Verify And Validate The Notes Audit Data From The Latest Timestamp On Timecard List Page On Web
    ...    Edited    ${added_weekly_note}    ${edited_weekly_note}
    Close Notes Audit Table Window On Timecard List Page On Web
    # Delete The Note in Weekly Notes Table
    Delete Note In Weekly Notes Table On Timecard List Page On Web
    ${empty_weekly_note}    Get Note From The Weekly Notes Table On Timecard List Page On Web
    Open The Audit From The Weekly Notes Table On Timecard List Page On Web
    Verify And Validate The Notes Audit Data From The Latest Timestamp On Timecard List Page On Web
    ...    Deleted    ${edited_weekly_note}    ${empty_weekly_note}
    Close Notes Audit Table Window On Timecard List Page On Web
    # Reset the note with the initial value.
    Add Note In Weekly Notes Table On Timecard List Page On Web    ${existing_weekly_note}
    ${restored_note}    Get Note From The Weekly Notes Table On Timecard List Page On Web
    Should Be Equal As Strings    ${restored_note}    ${existing_weekly_note}
    Switch To Home From Store On Web
