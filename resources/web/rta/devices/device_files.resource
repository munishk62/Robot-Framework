*** Settings ***
Documentation       Resource file for Device Files Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/devices/device_files_page.py


*** Keywords ***
Navigate To RTA Devices Device Files Page On Web
    [Documentation]    Navigates to the RTA -> Devices -> Device Files page.
    Navigate To Specific Page On Web    rta    devices    device_files

Click On Add Device Files Button On Device Files Page On Web
    [Documentation]    Clicks on Add Device Files button on Device Files page
    Click Element On Webpage    ${DEVICE_FILES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Device Files button on Device Files page."
    Wait Until Element Is Visible On Webpage    ${DEVICE_FILES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Device Files form did not open after clicking Add Device Files button."
    Capture Screenshot On Webpage
