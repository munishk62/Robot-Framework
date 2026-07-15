*** Settings ***
Documentation       Resource file for Device Groups Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/devices/device_groups_page.py


*** Keywords ***
Navigate To RTA Devices Device Groups Page On Web
    [Documentation]    Navigates to the RTA -> Devices -> Device Groups page.
    Navigate To Specific Page On Web    rta    devices    device_groups

Click On Add Device Group Button On Device Groups Page On Web
    [Documentation]    Clicks on Add Device Group button on Device Groups page
    Click Element On Webpage    ${DEVICE_GROUPS_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Device Group button on Device Groups page."
    Wait Until Element Is Visible On Webpage    ${DEVICE_GROUPS_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Device Group form did not open after clicking Add Device Group button."
    Capture Screenshot On Webpage
