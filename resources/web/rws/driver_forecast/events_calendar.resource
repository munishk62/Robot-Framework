*** Settings ***
Documentation       This resource file contains keywords related to the Events Calendar page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/driver_forecast/events_calendar_page.py


*** Keywords ***
Navigate To RWS Events Calendar Page On Web
    [Documentation]    Navigate To RWS -> Driver Forecast -> Events Calendar Page On Web
    Navigate To Specific Page On Web    rws    driver_forecast    events_calendar

Click On Add Event Button In Events Calendar Page On Web
    [Documentation]    Click On Add Event Button In Events Calendar Page On Web
    ${is_add_button_present}    Is Element Present On Webpage    ${EVENTS_CALENDAR_ADD_EVENT_BTN}
    Skip If    not ${is_add_button_present}    Add Event button not present on Events Calendar page, skipping click action
    Click Element On Webpage    ${EVENTS_CALENDAR_ADD_EVENT_BTN}
    ...    error_message=Failed to click on Add Event button in Events Calendar page on web.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${EVENTS_CALENDAR_PREVIOUS_BTN}
    ...    error_message=Add Event form did not open after clicking on Add Event button in Events Calendar page on web.
    Capture Screenshot On Webpage

Click On View Report Button In Events Calendar Page On Web
    [Documentation]    Click On View Report Button In Events Calendar Page On Web
    ${is_view_report_button_present}    Is Element Present On Webpage    ${EVENTS_CALENDAR_VIEW_REPORT_BTN}
    Skip If    not ${is_view_report_button_present}    View Report button not present on Events Calendar page, skipping click action
    Click Element On Webpage    ${EVENTS_CALENDAR_VIEW_REPORT_BTN}
    ...    error_message=Failed to click on View Report button in Events Calendar page on web.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${EVENTS_CALENDAR_PREVIOUS_BTN}
    ...    error_message=Report did not open after clicking on View Report button in Events Calendar page on web.
    Capture Screenshot On Webpage
