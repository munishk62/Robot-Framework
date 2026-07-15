*** Settings ***
Documentation       Resource file for Device Groups Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/devices/operations_policy_page.py


*** Keywords ***
Navigate To RTA Devices Operations Policy Page On Web
    [Documentation]    Navigates to the RTA -> Devices -> Operations Policy page.
    Navigate To Specific Page On Web    rta    devices    operations_policy

Click On Add Device Group Button On Operations Policy Page On Web
    [Documentation]    Clicks on Add Device Group button on Operations Policy page
    Click Element On Webpage    ${OPERATIONS_POLICY_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Device Group button on Operations Policy page."
    Wait Until Element Is Visible On Webpage    ${OPERATIONS_POLICY_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Device Group form did not open after clicking Add Device Group button."
    Capture Screenshot On Webpage
