*** Settings ***
Documentation       Resource file for Attendance Management Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/attendance/attendance_management_page.py


*** Keywords ***
Navigate To RTA Attendance Management Page On Web
    [Documentation]    Navigates to the RTA -> Attendance -> Management page.
    Navigate To Specific Page On Web    rta    attendance    attendance_management

Click On Add Attendance Button On Attendance Management Page On Web
    [Documentation]    Clicks on the Add Attendance button on Attendance Management page.
    Click Element On Webpage    ${ATTENDANCE_MANAGEMENT_PAGE_ADD_ATTENDANCE_BUTTON}
    ...    error_message="Failed to click on the Add Attendance button on Attendance Management page."
    Wait Until Element Is Visible On Webpage    ${ATTENDANCE_MANAGEMENT_PAGE_SAVE_BUTTON}
    ...    error_message="Add Attendance form did not open after clicking on Add Attendance button."
    Capture Screenshot On Webpage
