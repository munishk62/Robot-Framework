*** Settings ***
Documentation       This resource file contains keywords related to the PSA > Advanced Settings > Worker Status page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/psa/advanced_settings/worker_status_page.py


*** Keywords ***
Navigate To PSA Worker Status Page On Web
    [Documentation]    Navigate To PSA -> Advanced Settings -> Worker Status Page On Web
    Navigate To Specific Page On Web    psa    advanced_settings    worker_status

Click On Add Worker Button On Worker Status Page On Web
    [Documentation]    Click on the Add Worker button on the Worker Status page.
    Click Element On Webpage    ${WORKER_STATUS_ADD_WORKER_BTN}
    ...    error_message=Failed to click on Add Worker button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${WORKER_STATUS_ADD_WORKER_BACK_TO_LIST_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Worker Back to List button was not visible after clicking Add Worker button
    Capture Screenshot On Webpage
