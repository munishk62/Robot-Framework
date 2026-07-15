*** Settings ***
Documentation       This resource file contains keywords related to the Calendar > Store Blackouts page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/calendar/store_blackouts_page.py


*** Keywords ***
Navigate To RWS Store Blackouts Page On Web
    [Documentation]    Navigate To RWS -> Calendar -> Store Blackouts Page On Web
    Navigate To Specific Page On Web    rws    calendar    store_blackouts

Expand Banner Dropdown On Store Blackouts Page On Web
    [Documentation]    Click on the banner dropdown to expand it on Store Blackouts page.
    Click Element On Webpage    ${STORE_BLACKOUTS_BANNER_DROPDOWN}
    ...    error_message=Failed to expand banner dropdown
    Wait Until Element Is Visible On Webpage    ${STORE_BLACKOUTS_BANNER_DROPDOWN_FIRST_OPTION}
    ...    error_message=Banner dropdown options were not visible after clicking dropdown
