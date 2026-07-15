*** Settings ***
Documentation       Resource file for Device Monitoring Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/devices/device_monitoring_page.py


*** Keywords ***
Navigate To RTA Devices Device Monitoring Page On Web
    [Documentation]    Navigates to the RTA -> Devices -> Device Monitoring page.
    Navigate To Specific Page On Web    rta    devices    device_monitoring

Click On Add Device Monitoring Button On Device Monitoring Page On Web
    [Documentation]    Clicks on Add Device Monitoring button on Device Monitoring page
    Click Element On Webpage    ${DEVICE_MONITORING_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Device Monitoring button on Device Monitoring page."
    Wait Until Element Is Visible On Webpage    ${DEVICE_MONITORING_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Device Monitoring form did not open after clicking Add Device Monitoring button."
    Capture Screenshot On Webpage
