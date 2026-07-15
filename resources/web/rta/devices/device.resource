*** Settings ***
Documentation       Resource file for Device Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/devices/device_page.py


*** Keywords ***
Navigate To RTA Devices Device Page On Web
    [Documentation]
    ...    Navigates to the RTA -> Devices -> Device page from the
    ...    devices resource.
    Navigate To Specific Page On Web    rta    devices    device

Click On Add Device Button On Device Page On Web
    [Documentation]    Clicks on Add Device button on Device page
    Click Element On Webpage    ${DEVICE_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Device button on Device page."
    Wait Until Element Is Visible On Webpage    ${DEVICE_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Device form did not open after clicking Add Device button."
    Capture Screenshot On Webpage
