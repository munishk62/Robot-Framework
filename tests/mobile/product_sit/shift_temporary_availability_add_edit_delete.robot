*** Settings ***
Documentation       BATTC00229 - Verify ESS user is able to add, edit and delete temporary availability in mobility

Resource        resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource        resources/Mobile/ESS/PagesResources/Availability_Module/availability.resource

Suite Teardown      Run Keyword And Ignore Error    Close Application

Test Tags           action:write    dev:ashish    battc00229    config:ess    config:add_edit_delete_availability_ess    config:temporary_availability_enabled    mobile    bat_phase2
...    config:mobile_shift_enabled


*** Test Cases ***
BATTC00229: Verify ESS user is able to add / edit / delete temporary availability in mobility
    [Documentation]    Verify ESS user is able to add, edit and delete temporary availability in mobility
    ${add_availability_3}    Get Shift Availability Data    template_name=add_availability#3
    Open Mobile ESS App    battc00229
    Login Mobile Ess App    ESS3_STORE2
    Navigate To Availability Module On Mobile ESS
    Navigate To Add Availability Page On Mobile ESS
    Select Availability Temporary Type On Mobile ESS
    Select Availability Start Date On Mobile ESS    ${add_availability_3}[start_date]
    Select Availability Reason On Mobile ESS     ${add_availability_3}[reason]
    Select Entire Week Available On Mobile ESS
    Open Availability Timings Window Details On Mobile ESS    00:00    00:00    0,1,2,3,4,5,6
    Delete Availability Timings Window On Mobile ESS
    Add Availability Timing Windows On Mobile ESS    ${add_availability_3}[rotations]
    Submit Availability For Approval On Mobile ESS
    Verify Availability List Item On Mobile ESS    ${add_availability_3}

    # Edit Availability
    ${edit_availability_3}    Get Shift Availability Data    template_name=edit_availability_#3
    Tap Availability List Item On Mobile ESS    ${add_availability_3}
    Tap Edit Availability Request Details On Mobile ESS
    Add Availability Timing Windows On Mobile ESS    ${edit_availability_3}[rotations]
    Submit Availability For Approval On Mobile ESS
    Tap Availability List Item On Mobile ESS    ${add_availability_3}
    Delete Availability From Request Details On Mobile ESS
    Select Availability Tab On Mobile ESS
    Verify Availability List Item Not Present On Mobile ESS    ${add_availability_3}

    [Teardown]    Teardown Test Case    battc00229
