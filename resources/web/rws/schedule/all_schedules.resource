*** Settings ***
Documentation
...                 This resource file provides keywords for automating the All Schedules page.
...
...                 = Purpose =
...                 - Centralizes actions for navigating, creating, and verifying schedules on All Schedules Page.
...
...                 = Prerequisites =
...                 - Required libraries and variable files must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 |Generate Week Plan For Unscheduled Week
...                 |    Select Unscheduled Week By Date On All Schedules Page On Web
...                 |    Click On Generate Week Plan On All Schedules Page On Web
...                 |    Verify Success Notifier Message On All Schedules Page On Web

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/rws/schedule/all_schedules_page.py
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/fixed_shifts_page.py


*** Keywords ***
Navigate To RWS Schedule All Schedules Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> All Schedules Page
    ...    and verifies all schedules heading at the top of the page
    Navigate To Specific Page On Web    rws    schedule    all_schedules

Get Unscheduled Week On All Schedules Page On Web
    [Documentation]    This keyword returns week date of the unscheduled week to generate the schedule.
    ...    | =Returns= | =Description= |
    ...    | week_date | Week date of the unscheduled week |
    ${cells}=    Get Elements    ${ALLSCHEDULESPAGE_WEEK_AVAILABILITY_INFO_ROW}
    ${date_format_all_schd}=    Get Config Value    SERVER_DF
    ${cell_length}=    Get Length    ${cells}
    FOR    ${cell}    IN RANGE    1    ${cell_length+1}
        IF    ${cell} > 1
            ${cell_str}=    Convert To String    ${cell}
            TRY
                # Use dynamic locator template instead of hardcoded XPath
                ${cell_locator}=    Update Locator With Dynamic Values    ${ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX}
                ...    CELL_INDEX=${cell_str}
                ${week_status_info}=    Get Attribute    ${cell_locator}    onClick
                ${is_unscheduled_week}=    Evaluate    "showUnscheduledWeek" in "${week_status_info}"
            EXCEPT
                ${cell_locator}=    Update Locator With Dynamic Values    ${ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX}
                ...    CELL_INDEX=${cell_str}
                ${week_status}=    Get Attribute    ${cell_locator}    id
                ${is_unscheduled_week}=    Evaluate    "linkTdShowUnscheduledWeek" in "${week_status}"
                ${week_status_info}=    Get Attribute    ${cell_locator}    data
            END
            IF    ${is_unscheduled_week}
                ${week_date}=    Find Text With Pattern    ${week_status_info}    \\d{8}
                ${is_future_week_date}=    Is Future Date    ${week_date}    ${date_format_all_schd}
                IF    ${is_future_week_date}    BREAK
            END
        END
    END
    RETURN    ${week_date}

Select Unscheduled Week By Date On All Schedules Page On Web
    [Documentation]    This keyword selects the unscheduled week by identifying the start date of the week.
    ...    It accepts the date format as yyyymmdd in string format.
    ...    | =Arguments= | =Description= |
    ...    | date_of_week| Date to select the unscheduled week |
    [Arguments]    ${date_of_week}
    ${unscheduled_week_updated_loc}=    Update Locator With Dynamic Values
    ...    ${ALLSCHEDULESPAGE_DATED_UNSCHEDULED_WEEK}    DATEOFWEEK=${date_of_week}
    Click Element On Webpage    ${unscheduled_week_updated_loc}
    Wait Until Page Is Loaded

Select Unscheduled Week On All Schedules Page On Web
    [Documentation]    This keyword selects the unscheduled week to generate the schedule.
    ${unscheduled_week_all_schedules}=    Get Unscheduled Week On All Schedules Page On Web
    Select Unscheduled Week By Date On All Schedules Page On Web    ${unscheduled_week_all_schedules}

Switch To Plan Status From All Schedule Page On Web
    [Documentation]    Check if the schedule is published for the specified week in All Schedules page
    [Arguments]    ${planning_week}
    ${week_date}=    Calculate Date From Week Day Offset    ${planning_week}

    # Get individual date components to format day without leading zero
    ${month_only_format}=    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${day_only_format}=    Get Config Value    DATE_FMT_DAY_ONLY
    ${year_only_format}=    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${month_name}=    Convert Date    ${week_date}    result_format=${month_only_format}
    ${day_with_zero}=    Convert Date    ${week_date}    result_format=${day_only_format}
    ${year}=    Convert Date    ${week_date}    result_format=${year_only_format}

    # Remove leading zero from day using string manipulation
    ${day_no_zero}=    Evaluate    str(int("${day_with_zero}"))
    VAR    ${week_date_formated}=    ${month_name} ${day_no_zero}, ${year}
    # Use Update Locator functions instead of hardcoded dynamic XPath
    ${published_locator}=    Update Locator With Dynamic Values
    ...    ${ALLSCHEDULESPAGE_PUBLISHED_SCHEDULE_LOCATOR}    WEEK_DATE=${week_date_formated}
    ${unpublished_locator}=    Update Locator With Dynamic Values
    ...    ${ALLSCHEDULESPAGE_UNPUBLISHED_SCHEDULE_LOCATOR}    WEEK_DATE=${week_date_formated}
    ${unscheduled_locator}=    Update Locator With Dynamic Values
    ...    ${ALLSCHEDULESPAGE_UNSCHEDULED_LOCATOR}    WEEK_DATE=${week_date_formated}
    ${published_found}=    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${published_locator}
    ${unpublished_found}=    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${unpublished_locator}
    ${unscheduled_found}=    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${unscheduled_locator}

    IF    ${published_found}
        Click Element On Webpage    ${published_locator}
        Click Element On Webpage    ${FIXEDSHIFTS_RAILROAD_DROPDOWN_ICON_BUTTON}
        Click Element On Webpage    ${PLAN_STATUS_RAILROAD_DROPDOWN_ITEM}
    ELSE IF    ${unpublished_found}
        Click Element On Webpage    ${unpublished_locator}
        Click Element On Webpage    ${FIXEDSHIFTS_RAILROAD_DROPDOWN_ICON_BUTTON}
        Click Element On Webpage    ${PLAN_STATUS_RAILROAD_DROPDOWN_ITEM}
    ELSE IF    ${unscheduled_found}
        Click Element On Webpage    ${unscheduled_locator}
    ELSE
        Fail    No schedule element (Published/Unpublished/Unscheduled) found for Planning Week: ${planning_week}
    END

Select Year In All Schedules Page On Web
    [Documentation]    Selects the specified fiscal year from the dropdown on the All Schedules page.
    [Arguments]    ${planning_week}
    ${year_date}=    Calculate Date From Week Day Offset    ${planning_week}
    ${year_date_format}=    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${year_date_formated}=    Convert Date    ${year_date}    result_format=${year_date_format}
    Wait Until Element Is Visible On Webpage    ${ALLSCHEDULESPAGE_YEAR}
    Select Options By    ${ALLSCHEDULESPAGE_YEAR}    text    ${year_date_formated}

Navigate To All Schedule Page Switch To Plan Status Page For Given Planning Week On Web
    [Documentation]    Selects the specified fiscal week from the dropdown on the All Schedules page.
    [Arguments]    ${planning_week}
    Navigate To RWS Schedule All Schedules Page On Web
    Wait Until Page Is Loaded
    ${is_week_in_current_fiscal_year}=    Run Keyword And Return Status
    ...    Switch To Plan Status From All Schedule Page On Web    ${planning_week}
    IF    not ${is_week_in_current_fiscal_year}
        Select Year In All Schedules Page On Web    ${planning_week}
        Switch To Plan Status From All Schedule Page On Web    ${planning_week}
    END
    Wait Until Page Is Loaded
