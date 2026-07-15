*** Settings ***
Documentation       Resource file for Job Codes Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/configuration/job_codes_page.py


*** Keywords ***
Navigate To RTA Configuration Job Codes Page On Web
    [Documentation]    Navigates to the RTA -> Configuration -> Job Codes page.
    Navigate To Specific Page On Web    rta    configuration    job_codes

Click On Add Job Code Button On Job Codes Page On Web
    [Documentation]    Clicks on Add Job Code button on Job Codes page
    Click Element On Webpage    ${JOB_CODES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Job Code button on Job Codes page."
    Wait Until Element Is Visible On Webpage    ${JOB_CODES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Job Code form did not open after clicking Add Job Code button."
    Capture Screenshot On Webpage
