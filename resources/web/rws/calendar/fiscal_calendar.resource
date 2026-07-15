*** Settings ***
Documentation       This resource file contains keywords related to the Calendar > Fiscal Calendar page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/calendar/fiscal_calendar_page.py


*** Keywords ***
Navigate To RWS Fiscal Calendar Page On Web
    [Documentation]    Navigate To RWS -> Calendar -> Fiscal Calendar Page On Web
    Navigate To Specific Page On Web    rws    calendar    fiscal_calendar

Open First Calendar Group Details On Fiscal Calendar Page On Web
    [Documentation]    Clicks on the first calendar group in the list to open the calendar group details page.
    ${is_calendar_group_present}    Is Element Present On Webpage    ${FISCAL_CALENDAR_FIRST_CALENDAR_GROUP}
    Skip If    not ${is_calendar_group_present}    No calendar groups found on fiscal calendar page; skipping step to open calendar group details page.
    Click Element On Webpage    ${FISCAL_CALENDAR_FIRST_CALENDAR_GROUP}
    ...    error_message=Failed to click element on first calendar group
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${FISCAL_CALENDAR_GROUP_DETAILS_SAVE_BTN}
    ...    error_message=Failed to load calendar group details page after clicking on first calendar group
    Capture Screenshot On Webpage

Switch To Fiscal Calendar Tab On Calendar Group Details Page On Web
    [Documentation]    Switches to the fiscal calendar tab on the calendar group details page to surface additional visible text for i18n verification.
    ${is_fiscal_calendar_tab_present}    Is Element Present On Webpage    ${FISCAL_CALENDAR_GROUP_FIS_CAL_TAB}
    IF    not ${is_fiscal_calendar_tab_present}
        Log    Fiscal calendar tab not found on calendar group details page
        RETURN
    END
    Click Element On Webpage    ${FISCAL_CALENDAR_GROUP_FIS_CAL_TAB}
    ...    error_message=Failed to click on fiscal calendar tab on calendar group details page
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${FISCAL_CALENDAR_GROUP_ADD_FISCAL_YEAR_BTN}
    ...    error_message=Failed to switch to fiscal calendar tab on calendar group details page

Click On Add Fiscal Year Button On Fiscal Calendar Tab On Web
    [Documentation]    Clicks on the "Add Fiscal Year" button on the fiscal calendar tab to open the add fiscal year page, which surfaces additional visible text for i18n verification.
    ${is_add_fiscal_year_btn_present}    Is Element Present On Webpage    ${FISCAL_CALENDAR_GROUP_ADD_FISCAL_YEAR_BTN}
    IF    not ${is_add_fiscal_year_btn_present}
        Log    Add Fiscal Year button not found on fiscal calendar tab
        RETURN
    END
    Click Element On Webpage    ${FISCAL_CALENDAR_GROUP_ADD_FISCAL_YEAR_BTN}
    ...    error_message=Failed to click on Add Fiscal Year button on fiscal calendar tab
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${FISCAL_CALENDAR_GROUP_FISCAL_YEAR_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Failed to open add fiscal year page after clicking on Add Fiscal Year button on fiscal calendar tab
