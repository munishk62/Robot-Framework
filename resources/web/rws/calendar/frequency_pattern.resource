*** Settings ***
Documentation       This resource file contains keywords related to the Calendar > Frequency Pattern page in RWS on the web.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/calendar/frequency_pattern_page.py


*** Keywords ***
Navigate To RWS Frequency Pattern Page On Web
    [Documentation]    Navigate To RWS -> Calendar -> Frequency Pattern page.
    Navigate To Specific Page On Web    rws    calendar    frequency_pattern

Click On Add Frequency Pattern Button In Frequency Pattern Page On Web
    [Documentation]    Click on the Add Frequency Pattern button in the Frequency Pattern page on the web.
    ${is_add_btn_present}    Is Element Present On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_BTN}
    Skip If    not ${is_add_btn_present}    Add Frequency Pattern button not present on Frequency Pattern page
    Click Element On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_BTN}
    ...    error_message=Failed to click on the Add Frequency Pattern button in the Frequency Pattern page.
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_SAVE_BTN}
    ...    error_message=Failed to wait for the Add Frequency Pattern popup to be visible after clicking the Add Frequency Pattern button in the Frequency Pattern page.
    Capture Screenshot On Webpage

Click On All Tabs In Add Frequency Pattern Page On Web
    [Documentation]    Click on all the tabs available in the Add Frequency Pattern page on the web and wait for their content to be visible.
    ${is_gregorian_cal_tab_present}    Is Element Present On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_GREGORIAN_CAL_TAB}
    IF    ${is_gregorian_cal_tab_present}
        Click Element On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_GREGORIAN_CAL_TAB}
        ...    error_message=Failed to click on the Gregorian Calendar tab in the Add Frequency Pattern page.
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_GREGORIAN_CAL_SECTION}
        ...    error_message=Failed to wait for the content of the Gregorian Calendar tab to be visible in the Add Frequency Pattern page.
    END
    ${is_fiscal_cal_tab_present}    Is Element Present On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_FISCAL_CAL_TAB}
    IF    ${is_fiscal_cal_tab_present}
        Click Element On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_FISCAL_CAL_TAB}
        ...    error_message=Failed to click on the Fiscal Calendar tab in the Add Frequency Pattern page.
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_FISCAL_CAL_SECTION}
        ...    error_message=Failed to wait for the content of the Fiscal Calendar tab to be visible in the Add Frequency Pattern page.
    END
    ${is_specific_dates_tab_present}    Is Element Present On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_SPECIFIC_DATES_TAB}
    IF    ${is_specific_dates_tab_present}
        Click Element On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_SPECIFIC_DATES_TAB}
        ...    error_message=Failed to click on the Specific Dates tab in the Add Frequency Pattern page.
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_SPECIFIC_DATES_SECTION}
        ...    error_message=Failed to wait for the content of the Specific Dates tab to be visible in the Add Frequency Pattern page.
    END
    ${is_linked_to_pattern_tab_present}    Is Element Present On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_LINKED_TO_PATTERN_TAB}
    IF    ${is_linked_to_pattern_tab_present}
        Click Element On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_LINKED_TO_PATTERN_TAB}
        ...    error_message=Failed to click on the Linked To Pattern tab in the Add Frequency Pattern page.
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_LINKED_TO_PATTERN_SECTION}
        ...    error_message=Failed to wait for the content of the Linked To Pattern tab to be visible in the Add Frequency Pattern page.
    END
    ${is_applies_to_date_range_tab_present}    Is Element Present On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_APPLIES_TO_DATE_RANGE_TAB}
    IF    ${is_applies_to_date_range_tab_present}
        Click Element On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_APPLIES_TO_DATE_RANGE_TAB}
        ...    error_message=Failed to click on the Applies To Date Range tab in the Add Frequency Pattern page.
        Wait Until Page Is Loaded
        Wait Until Element Is Visible On Webpage    ${FREQ_PATTERN_ADD_FREQ_PATTERN_APPLIES_TO_DATE_RANGE_SECTION}
        ...    error_message=Failed to wait for the content of the Applies To Date Range tab to be visible in the Add Frequency Pattern page.
    END
