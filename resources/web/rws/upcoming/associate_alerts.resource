*** Settings ***
Documentation       This resource file contains keywords related to the Upcoming > Associate Alerts page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/upcoming/associate_alerts_page.py


*** Keywords ***
Navigate To RWS Associate Alerts Page On Web
    [Documentation]    Navigate To RWS -> Upcoming -> Associate Alerts Page On Web
    Navigate To Specific Page On Web    rws    upcoming    associate_alerts

Click On First Visible Request On Associate Alerts Page On Web
    [Documentation]    Click on the first visible request on the Associate Alerts page.
    ${is_request_present}    Is Element Present On Webpage    ${ASSOCIATE_ALERTS_FIRST_VISIBLE_REQUEST}
    Skip If    not ${is_request_present}    No visible requests were found on the Associate Alerts page to click on.
    Click Element On Webpage    ${ASSOCIATE_ALERTS_FIRST_VISIBLE_REQUEST}
    ...    error_message=Failed to click on the first visible request on Associate Alerts page
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ASSOCIATE_ALERTS_REQUEST_DETAILS_AVAILABLE_TABS} >> nth=0    timeout=${LONG_TIMEOUT}
    ...    error_message=Request details available tabs were not visible after clicking on the first visible request on Associate Alerts page
    Capture Screenshot On Webpage

Click On Request Details All Tab On Associate Alerts Page On Web
    [Documentation]    Click on the all available tabs in the request details section on the Associate Alerts page.
    ${tab_count}    Get Element Count On Webpage    ${ASSOCIATE_ALERTS_REQUEST_DETAILS_AVAILABLE_TABS}
    FOR    ${index}    IN RANGE    1    ${tab_count + 1}
        ${tab_locator}    Update Locator With Dynamic Values    ${ASSOCIATE_ALERTS_REQUEST_DETAILS_TAB}    TAB_INDEX=${index}
        Click Element On Webpage    ${tab_locator}
        ...    error_message=Failed to click on request details tab with index ${index} on Associate Alerts page
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${tab_locator}.activeTab
        ...    error_message=The request details tab with index ${index} did not become active after clicking on it on Associate Alerts page
        Capture Screenshot On Webpage
    END
