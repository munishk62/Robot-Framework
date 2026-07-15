*** Settings ***
Documentation       This resource file contains keywords related to the Job Mapping page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/users/job_mapping_page.py


*** Keywords ***
Navigate To RWS Users Job Mapping Page On Web
    [Documentation]    Navigate To RWS -> Users -> Job Mapping Page On Web
    Navigate To Specific Page On Web    rws    users    job_mapping

Click On Create Job Code Button On Job Mapping Page On Web
    [Documentation]    Clicks the "Create Job Code" button on the job mapping page to open the create job code form, which surfaces additional visible text for i18n verification.
    Click Element On Webpage    ${JOB_MAPPING_PAGE_ADD_JOB_CODE_BTN}
    ...    error_message=Failed to click element ${JOB_MAPPING_PAGE_ADD_JOB_CODE_BTN} on webpage
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${JOB_MAPPING_PAGE_JOB_CODE_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Element ${JOB_MAPPING_PAGE_JOB_CODE_SAVE_BTN} was not visible on webpage
    Capture Screenshot On Webpage
