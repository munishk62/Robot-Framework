*** Settings ***
Documentation       Resource file for Device Types Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/devices/device_types_page.py


*** Keywords ***
Navigate To RTA Devices Device Types Page On Web
    [Documentation]
    ...    Navigates to the RTA -> Devices -> Device Types page from the devices resource.
    Navigate To Specific Page On Web    rta    devices    device_types

Click On First Device Type On Device Types Page On Web
    [Documentation]    Check and click on the first device type link on the Device Types page.
    ${is_device_present}    Is Element Present On Webpage    ${DEVICE_TYPES_FIRST_DEVICE_TYPE}
    Skip If    not ${is_device_present}    No device types are present on the Device Types page to click on.
    Click Element On Webpage    ${DEVICE_TYPES_FIRST_DEVICE_TYPE}
    ...    error_message=Unable to click on the first device type link on the Device Types page.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${DEVICE_TYPES_DEVICE_DETAILS_PREVIOUS_BUTTON}
    ...    error_message=Device details page did not load after clicking on the first device type
    Capture Screenshot On Webpage
