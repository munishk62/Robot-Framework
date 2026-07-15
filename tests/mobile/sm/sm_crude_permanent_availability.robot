*** Settings ***
Documentation       BATTC00128 - Verify SM user is able to add/edit/delete/approve availability requests in mobility

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Login_Page/SMLogin.resource
Resource            resources/Mobile/SM/PagesResources/Associate_Roster/Availability_Tab.resource
Resource            resources/Mobile/SM/PagesResources/More/More.resource

Suite Teardown      Run Keyword And Ignore Error    Close Mobile Application    battc00128

Test Tags    action:read    dev:ashish    battc00128    mobile    bat_phase2    config:rws
...    config:add_edit_delete_availability_request_sm    config:temporary_availability_enabled
...    config:mobile_sm_enabled


*** Variables ***
${SM_USER}      SM1_STORE2
${ESS_USER}     ESS5_STORE2


*** Test Cases ***
BATTC00128: Verify SM user is able to add/edit/delete/approve availability requests in mobility
    [Documentation]    Verify SM user is able to add/edit/delete/approve availability requests in mobility
    ${ess_user}    Get User    ${ESS_USER}
    ${availability_add_data}    Get Shift Availability Data    template_name=sm_add_perm_availability
    Open SM Native Application On Mobile Phone    battc00128
    Login SM App On Mobile    SM1_STORE2
    Navigate To Associate Roster Module On SM Phone App
    Search And Select Associate Name On Associate Roster Page On SM Phone App    ${ess_user}[displayName]
    Navigate To Availability Tab On Associate Roster Page On SM Phone App
    ${is_same_avail_present}    Run Keyword And Return Status    Verify Availability List Item On SM Phone App    ${availability_add_data}
    ...    ${SM_USER}
    IF    ${is_same_avail_present}
        Tap Availability List Item On SM Phone App    ${availability_add_data}    ${SM_USER}
        Delete Availability Request On SM Phone App
        Verify Availability List Item Not Present On SM Phone App    ${availability_add_data}    ${SM_USER}
        Sleep    5s  # This sleep required as notification popup overlaps the add button on availability tab which creates issue in clicking add button, so added sleep to avoid that issue.
    END
    Tap Add Button On Availability Tab On SM Phone App
    Select Start Date For Availability On SM Phone App    ${availability_add_data}[start_date]
    Select Availability Reason On SM Phone App    ${availability_add_data}[reason]
    Select Availability Status On SM Phone App    ${availability_add_data}[status]
    Add Availability Timing Windows On SM Phone App    ${availability_add_data}[rotations]
    Tap Submit Availability Request On SM Phone App
    Verify Availability List Item On SM Phone App    ${availability_add_data}    ${SM_USER}
    Tap Availability List Item On SM Phone App    ${availability_add_data}    ${SM_USER}
    Tap Edit Availability Request Details On SM Phone App
    VAR    ${start_time}    22:00
    VAR    ${end_time}    23:00
    VAR    @{applicable_days}    5
    Add Base Availability Timings On SM Phone App    ${start_time}    ${end_time}    ${applicable_days}    2
    Tap Save To Edited Availability Request On SM Phone App
    Tap Availability List Item On SM Phone App    ${availability_add_data}    ${SM_USER}
    Verify Availability Request Details On SM Phone App    ${availability_add_data}
    Delete Availability Request On SM Phone App
    Verify Availability List Item Not Present On SM Phone App    ${availability_add_data}    ${SM_USER}
    Sleep    5s
    ${rotations_enabled}    Get Rotations Enabled For Availability
    IF    '${rotations_enabled}' == 'True'
        ${availability_add_data}    Get Shift Availability Data
        ...    template_name=sm_add_perm_availability_with_rotations
        Tap Add Button On Availability Tab On SM Phone App
        Select Start Date For Availability On SM Phone App    ${availability_add_data}[start_date]
        Select Availability Reason On SM Phone App    ${availability_add_data}[reason]
        Select Availability Status On SM Phone App    ${availability_add_data}[status]
        Add Availability Timing Windows On SM Phone App    ${availability_add_data}[rotations]
        Tap Submit Availability Request On SM Phone App
        Tap Availability List Item On SM Phone App    ${availability_add_data}    ${SM_USER}
        Verify Availability Request Details On SM Phone App    ${availability_add_data}
        Delete Availability Request On SM Phone App
        Verify Availability List Item Not Present On SM Phone App    ${availability_add_data}    ${SM_USER}
    END
    Sleep    5s
    ${availability_add_data}    Get Shift Availability Data    template_name=sm_add_perm_availability_3
    Tap Add Button On Availability Tab On SM Phone App
    Select Start Date For Availability On SM Phone App    ${availability_add_data}[start_date]
    Select Availability Reason On SM Phone App    ${availability_add_data}[reason]
    Select Availability Status On SM Phone App    ${availability_add_data}[status]
    Add Availability Timing Windows On SM Phone App    ${availability_add_data}[rotations]
    Tap Submit Availability Request On SM Phone App
    Tap Availability List Item On SM Phone App    ${availability_add_data}    ${SM_USER}
    Verify Availability Request Details On SM Phone App    ${availability_add_data}
    [Teardown]    Teardown With Adding Availability To Given Associate


*** Keywords ***
Get Rotations Enabled For Availability
    [Documentation]    This keyword is used to get the rotations enabled for permanent availability from config #PC00035.
    ${emp_avail}    Get Config Value    EMP_AVL_ROTATION
    ${staff_rotation}    Get Config Value    STAFF_ROTATION
    IF    '${emp_avail}' == 'Y' and '${staff_rotation}' == 'Y'
        VAR    ${rotations}    True
    ELSE
        VAR    ${rotations}    False
    END
    RETURN    ${rotations}

Teardown With Adding Availability To Given Associate
    [Documentation]    This is just teardown step very specific to this test case only. because availability is required for other operations.
    Run Keyword And Ignore Error    Close Mobile Application    battc00128
    ${availability_add_data}    Get Shift Availability Data    template_name=sm_add_perm_availability_3
    ${ess_user}    Get User    ESS5_STORE2
    Open SM Native Application On Mobile Phone    battc00128_teardown
    Login SM App On Mobile    SM1_STORE2
    Navigate To Associate Roster Module On SM Phone App
    Search And Select Associate Name On Associate Roster Page On SM Phone App    ${ess_user}[displayName]
    Navigate To Availability Tab On Associate Roster Page On SM Phone App
    Tap Add Button On Availability Tab On SM Phone App
    Select Start Date For Availability On SM Phone App    ${availability_add_data}[start_date]
    Select Availability Reason On SM Phone App    ${availability_add_data}[reason]
    Select Availability Status On SM Phone App    ${availability_add_data}[status]
    Tap Submit Availability Request On SM Phone App
    Close Mobile Application    battc00128_teardown
