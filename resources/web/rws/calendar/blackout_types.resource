*** Settings ***
Documentation       This resource file contains keywords related to the Calendar > Blackout Types page in RWS.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/calendar/blackout_types_page.py


*** Keywords ***
Navigate To RWS Blackout Types Page On Web
    [Documentation]    Navigate To RWS -> Calendar -> Blackout Types Page On Web
    Navigate To Specific Page On Web    rws    calendar    blackout_types

Click On Add Holiday Type Button On Blackout Types Page On Web
    [Documentation]    Clicks on the "Add Holiday Type" button on the Blackout Types page to open the add holiday type details
    ${is_add_holiday_type_btn_present}    Is Element Present On Webpage    ${BLACKOUT_TYPES_ADD_HOLIDAY_TYPE_BTN}
    Skip If    not ${is_add_holiday_type_btn_present}    Add Holiday Type button not present on Blackout Types page
    Click Element On Webpage    ${BLACKOUT_TYPES_ADD_HOLIDAY_TYPE_BTN}
    ...    error_message=Failed to click on Add Holiday Type button on Blackout Types page
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${BLACKOUT_TYPES_ADD_HOLIDAY_TYPE_SAVE_BTN}
    ...    error_message=Failed to open add holiday type details after clicking on Add Holiday Type button on Blackout Types page
    Capture Screenshot On Webpage
