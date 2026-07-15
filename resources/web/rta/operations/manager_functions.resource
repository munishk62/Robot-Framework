*** Settings ***
Documentation       Resource file for Manager Functions Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/operations/manager_functions_page.py


*** Keywords ***
Navigate To RTA Operations Manager Functions Page On Web
    [Documentation]    Navigates to the RTA -> Operations -> Manager Functions page.
    Navigate To Specific Page On Web    rta    operations    manager_functions

Click On Add Manager Button On Manager Functions Page On Web
    [Documentation]    Clicks on Add Manager button on Manager Functions page
    Click Element On Webpage    ${MANAGER_FUNCTIONS_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Manager button on Manager Functions page."
    Wait Until Element Is Visible On Webpage    ${MANAGER_FUNCTIONS_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Manager form did not open after clicking Add Manager button."
    Capture Screenshot On Webpage
