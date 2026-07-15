*** Settings ***
Documentation       This resource file contains keywords related to the Organization Switch Store page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/organization/switch_store_page.py


*** Keywords ***
Navigate To RWS Organization Switch Store Page On Web
    [Documentation]    Navigate To RWS -> Organization -> Switch Store Page On Web
    Navigate To Specific Page On Web    rws    organization    switch_store

Click On First Store Link On Switch Store Page On Web
    [Documentation]    Clicks on the first store in the switch store list page to switch to that store's context.
    Wait Until Element Is Visible On Webpage    ${SWITCH_STORE_PAGE_FIRST_STORE_LINK}    timeout=${LONG_TIMEOUT}
    ...    error_message=Element ${SWITCH_STORE_PAGE_FIRST_STORE_LINK} was not visible
    Click Element On Webpage    ${SWITCH_STORE_PAGE_FIRST_STORE_LINK}
    ...    error_message=Failed to click element ${SWITCH_STORE_PAGE_FIRST_STORE_LINK} on webpage
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${SWITCH_STORE_PAGE_SWITCH_PROFILE_DIALOG}    timeout=${LONG_TIMEOUT}
    ...    error_message=Element ${SWITCH_STORE_PAGE_SWITCH_PROFILE_DIALOG} was not visible on webpage
    Capture Screenshot On Webpage
