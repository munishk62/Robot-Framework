*** Settings ***
Documentation       This resource file contains keywords related to the Organization Units page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/organization/units_page.py


*** Keywords ***
Navigate To RWS Organization Units Page On Web
    [Documentation]    Navigate To RWS -> Organization -> Units Page On Web
    Navigate To Specific Page On Web    rws    organization    units

Click On First Store Name In Units Page On Web
    [Documentation]    Click On First Store Name In Units Page On Web
    Click Element On Webpage    ${UNITS_FIRST_STORE_NAME}
    ...    error_message=Failed to click on first store name in units page.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${UNITS_STORE_DETAILS_STORE_LIST_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Units details page did not load after clicking first store name.

Click On Basic Details Of Store Details In Units Page On Web
    [Documentation]    Click On Basic Details Of Store Details In Units Page On Web
    Click Element On Webpage    ${UNITS_STORE_BASIC_DETAILS}
    ...    error_message=Failed to click on basic details in store details of units page.
    Wait Until Element Is Visible On Webpage    ${UNITS_STORE_BASIC_DETAILS_UNIT_ID}
    ...    error_message=Basic details section did not open after clicking on basic details in store details of units page.
    Capture Screenshot On Webpage

Click On Departments Of Store Details In Units Page On Web
    [Documentation]    Click On Departments Of Store Details In Units Page On Web
    Click Element On Webpage    ${UNITS_STORE_DEPARTMENTS}
    ...    error_message=Failed to click on departments in store details of units page.
    Wait Until Element Is Visible On Webpage    ${UNITS_STORE_DEPARTMENTS_SELECTED}
    ...    error_message=Departments section did not open after clicking on departments in store details of units page.
    Capture Screenshot On Webpage

Click On Staff Groups Of Store Details In Units Page On Web
    [Documentation]    Click On Staff Groups Of Store Details In Units Page On Web
    Click Element On Webpage    ${UNITS_STORE_STAFF_GROUPS}
    ...    error_message=Failed to click on staff groups in store details of units page.
    Wait Until Element Is Visible On Webpage    ${UNITS_STORE_STAFF_GROUPS_SELECTED}
    ...    error_message=Staff groups section did not open after clicking on staff groups in store details of units page.
    Capture Screenshot On Webpage

Click On Scheduled Events Of Store Details In Units Page On Web
    [Documentation]    Click On Scheduled Events Of Store Details In Units Page On Web
    Click Element On Webpage    ${UNITS_STORE_SCHEDULED_EVENTS}
    ...    error_message=Failed to click on scheduled events in store details of units page.
    Wait Until Element Is Visible On Webpage    ${UNITS_STORE_SCHEDULED_EVENTS_SELECTED}
    ...    error_message=Scheduled events section did not open after clicking on scheduled events in store details of units page.
    Capture Screenshot On Webpage
