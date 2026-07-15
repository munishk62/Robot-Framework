*** Settings ***
Documentation       This resource file contains keywords related to the PSA > Advanced Settings > Queue Status page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/psa/advanced_settings/queue_status_page.py


*** Keywords ***
Navigate To PSA Queue Status Page On Web
    [Documentation]    Navigate To PSA -> Advanced Settings -> Queue Status Page On Web
    Navigate To Specific Page On Web    psa    advanced_settings    queue_status

Click On Add Queue Button On Queue Status Page On Web
    [Documentation]    Click on the Add Queue button on the Queue Status page.
    Click Element On Webpage    ${QUEUE_STATUS_ADD_QUEUE_BTN}
    ...    error_message=Failed to click on Add Queue button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${QUEUE_STATUS_ADD_QUEUE_BACK_TO_LIST_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Queue Back to List button was not visible after clicking Add Queue button
    Capture Screenshot On Webpage
