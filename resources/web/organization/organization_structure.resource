*** Settings ***
Documentation       This resource file contains keywords related to the Organization Structure page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/organization/organization_structure_page.py


*** Keywords ***
Navigate To RWS Organization Structure Page On Web
    [Documentation]    Navigate To RWS -> Organization -> Organization Structure Page On Web
    Navigate To Specific Page On Web    rws    organization    organization_structure

Click On Organization Levels Link On Organization Structure Page On Web
    [Documentation]    Clicks the "Organization Levels" link on the organization structure page.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_ORG_LEVELS_LINK}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_ORG_LEVELS_LINK} on webpage
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_ACT_CONTENT}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_ACT_CONTENT} was not visible on webpage
    Capture Screenshot On Webpage

Click On Organization Attributes Link On Organization Structure Page On Web
    [Documentation]    Clicks the "Organization Attributes" link on the organization structure page.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_ATTRIBUTES_LINK}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_ATTRIBUTES_LINK} on webpage
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_ALL_ATTRIBUTE_LINK}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_ALL_ATTRIBUTE_LINK} was not visible on webpage
    Capture Screenshot On Webpage

Click On All Attribute Name Link On Organization Attributes Page On Web
    [Documentation]    Clicks on "All" attribute name link on the organization attributes page.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_ALL_ATTRIBUTE_LINK}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_ALL_ATTRIBUTE_LINK} on webpage
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_ADD_ATTRIBUTE_BTN}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_ADD_ATTRIBUTE_BTN} was not visible on webpage
    Capture Screenshot On Webpage

Click On Add Attribute Button On Organization Attributes Page On Web
    [Documentation]    Clicks the "Add Attribute" button on the organization attributes page to open the add attribute form page.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_ADD_ATTRIBUTE_BTN}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_ADD_ATTRIBUTE_BTN} on webpage
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_SAVE_BTN}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_SAVE_BTN} was not visible on webpage
    Capture Screenshot On Webpage

Click On Departments Link And Expand Store On Organization Structure Page On Web
    [Documentation]    Clicks the "Departments" link on the organization structure page and expands the "Store" department.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_DEPARTMENTS_LINK}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_DEPARTMENTS_LINK} on webpage
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_STORE_COLLAPSE_BTN}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_STORE_COLLAPSE_BTN} was not visible on webpage
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_STORE_COLLAPSE_BTN}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_STORE_COLLAPSE_BTN} on webpage
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_STORE_CONTAINER}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_STORE_CONTAINER} was not visible on webpage
    Capture Screenshot On Webpage

Click On Add Store Department Button On Organization Structure Page On Web
    [Documentation]    Clicks the "Add Store Department" button under the expanded "Store" department to open the add store department form page.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_ADD_DEPT_BTN}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_ADD_DEPT_BTN} on webpage
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_SAVE_BTN}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_SAVE_BTN} was not visible on webpage
    Capture Screenshot On Webpage

Click On Scheduled Events Link On Organization Structure Page On Web
    [Documentation]    Clicks the "Scheduled Events" link on the organization structure page.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_SCHEDULED_EVENTS_LINK}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_SCHEDULED_EVENTS_LINK} on webpage
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_ADD_EVENT_GROUP_BTN}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_ADD_EVENT_GROUP_BTN} was not visible on webpage
    Capture Screenshot On Webpage

Click On Add Scheduled Event Group Button On Scheduled Events Page On Web
    [Documentation]    Clicks the "Add Scheduled Event Group" button on the scheduled events page to open the add scheduled event group form page.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_ADD_EVENT_GROUP_BTN}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_ADD_EVENT_GROUP_BTN} on webpage
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_SAVE_BTN}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_SAVE_BTN} was not visible on webpage
    Capture Screenshot On Webpage

Click On Staff Groups Link On Organization Structure Page On Web
    [Documentation]    Clicks the "Staff Groups" link on the organization structure page.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_STAFF_GROUPS_LINK}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_STAFF_GROUPS_LINK} on webpage
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_ADD_STAFF_GROUP_BTN}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_ADD_STAFF_GROUP_BTN} was not visible on webpage
    Capture Screenshot On Webpage

Click On Add Staff Group Button On Staff Groups Page On Web
    [Documentation]    Clicks the "Add Staff Group" button on the staff groups page to open the add staff group details form page.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_ADD_STAFF_GROUP_BTN}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_ADD_STAFF_GROUP_BTN} on webpage
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_HOURS_BY_GROUP_TAB}    timeout=${LONG_TIMEOUT}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_HOURS_BY_GROUP_TAB} was not visible on webpage
    Capture Screenshot On Webpage

Click On Hours Allocation By Store Tab On Staff Group Details Page On Web
    [Documentation]    Switches to the "Hours Allocation by Store" tab on the add staff group details page and clicks on the calendar icon on that tab to reveal hidden text elements for inventory.
    Click Element On Webpage    ${ORG_STRUCTURE_PAGE_HOURS_BY_STORE_TAB}
    ...    error_message=Failed to click element ${ORG_STRUCTURE_PAGE_HOURS_BY_STORE_TAB} on webpage
    Wait Until Element Is Visible On Webpage    ${ORG_STRUCTURE_PAGE_STORE_DROPDOWN}
    ...    error_message=Element ${ORG_STRUCTURE_PAGE_STORE_DROPDOWN} was not visible on webpage
