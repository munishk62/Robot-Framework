*** Settings ***
Documentation       RTA > Payroll > Status page related keywords

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rta/operations/payroll_status_page.py


*** Keywords ***
Navigate To RTA Payroll Status Page On Web
    [Documentation]    Navigate To RTA -> Payroll -> Status Page
    ...    and verifies status heading at the top of the page
    Navigate To Specific Page On Web    rta    payroll    status

Apply Filter On Payroll Status Page On Web
    [Documentation]    This keyword applies filter on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | quarter | Quarter to be selected |
    ...    | month | month to be selected |
    ...    | week | week to be selected |
    ...    | release_status | release status to be selected |
    [Arguments]    ${year}=${EMPTY}
    ...    ${quarter}=${EMPTY}
    ...    ${month}=${EMPTY}
    ...    ${week}=${EMPTY}
    ...    ${release_status}=${EMPTY}
    Click Filter Icon On Payroll Status Page On Web
    Wait Until Page Is Loaded
    IF    '${year}' != '${EMPTY}'
        Select Year In Payroll Status Filter On Web    ${year}
    END
    IF    '${quarter}' != '${EMPTY}'
        Select Quarter In Payroll Status Filter On Web    ${quarter}
    END
    IF    '${month}' != '${EMPTY}'
        Select Month In Payroll Status Filter On Web    ${month}
    END
    IF    '${week}' != '${EMPTY}'
        Select Week In Payroll Status Filter On Web    ${week}
    END
    IF    '${release_status}' != '${EMPTY}'
        Select Release Status In Payroll Status Filter On Web    ${release_status}
    END
    Click Element On Webpage    ${PAYROLL_STATUS_PAGE_APPLY}
    ...    error_message="Filter options did not appear within 30 seconds after selecting filter criteria"
    Wait Until Page Is Loaded

Select Release Status In Payroll Status Filter On Web
    [Documentation]    This keyword selects release status on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | release_status | Release status to be selected |
    [Arguments]    ${release_status}
    Select List Item On Webpage    ${PAYROLL_STATUS_PAGE_RELEASE_STATUS}    text
    ...    ${release_status}

Select Year In Payroll Status Filter On Web
    [Documentation]    This keyword selects year on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | year | Year to be selected |
    [Arguments]    ${year}
    Select List Item On Webpage    ${PAYROLL_STATUS_PAGE_YEAR}    text
    ...    ${year}

Select Quarter In Payroll Status Filter On Web
    [Documentation]    This keyword selects quarter on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | quarter | Quarter to be selected |
    [Arguments]    ${quarter}
    Select List Item On Webpage    ${PAYROLL_STATUS_PAGE_QUARTER}    text
    ...    ${quarter}

Select Month In Payroll Status Filter On Web
    [Documentation]    This keyword selects month on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | month | Month to be selected |
    [Arguments]    ${month}
    Select List Item On Webpage    ${PAYROLL_STATUS_PAGE_PERIOD}    text
    ...    ${month}

Select Week In Payroll Status Filter On Web
    [Documentation]    This keyword selects week on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | week_range | Week to be selected |
    [Arguments]    ${week_range}
    VAR    ${week_found}    False
    ${current_year}    Get Current Date    result_format=%Y
    ${previous_year}    Evaluate    str(int(${current_year}) - 1)
    FOR    ${year}    IN    ${current_year}    ${previous_year}
        Select Year In Payroll Status Filter On Web    ${year}
        ${quarter_options}    Get Select Options    ${PAYROLL_STATUS_PAGE_QUARTER}
        FOR    ${option}    IN    @{quarter_options}[1:]    # Skip the first option
            VAR    ${quarter_label}    ${option['label']}
            Select List Item On Webpage    ${PAYROLL_STATUS_PAGE_QUARTER}    text    value=${quarter_label}
            ${month_options}    Get Select Options    ${PAYROLL_STATUS_PAGE_PERIOD}
            FOR    ${month_option}    IN    @{month_options}[1:]
                VAR    ${month_label}    ${month_option['label']}
                Select List Item On Webpage    ${PAYROLL_STATUS_PAGE_PERIOD}    text    value=${month_label}
                ${week_options}    Get Select Options    ${PAYROLL_STATUS_PAGE_WEEK}
                VAR    @{week_labels}    @{EMPTY}
                FOR    ${week_option}    IN    @{week_options}[1:]
                    VAR    ${week_label}    ${week_option['label']}
                    Append To List    ${week_labels}    ${week_label}
                END
                IF    '${week_range}' in ${week_labels}
                    Select List Item On Webpage    ${PAYROLL_STATUS_PAGE_WEEK}    text    value=${week_range}
                    VAR    ${week_found}    True
                    BREAK
                END
            END
            IF    ${week_found}    BREAK
        END
        IF    ${week_found}    BREAK
    END
    IF    not ${week_found}
        Fail    Desired week range: ${week_range} not found in current or previous year.
    END

Get Count Of Associates With Released Status In Payroll Status Page On Web
    [Documentation]    This keyword returns released count in release status on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | store_name | Store object fetched from template |
    ...    | week_period_value | Week period value in 'MM/DD/YYYY - MM/DD/YYYY' format |
    ...    | =Returns= | =Description= |
    ...    | released_count | Returns released count in release status |
    [Arguments]    ${store_name}    ${week_period_value}
    Wait Until Page Is Loaded
    ${released_count_locator}    Update Locator With Dynamic Values    ${PAYROLL_STATUS_PAGE_RELEASED_COUNT}
    ...    TARGET_WEEK=${week_period_value}    STORE_NAME=${store_name}
    Wait Until Element Is Visible On Webpage    ${released_count_locator}    timeout=${LONG_TIMEOUT}
    ...    error_message="Released count for store ${store_name} and week ${week_period_value} did not appear within 30 seconds"
    Wait Until Element Disappears On Webpage    ${PAYROLL_STATUS_PAGE_SPINNER}
    ${released_count_text}    Get Element Text On Webpage    ${released_count_locator}
    ${released_count}    Convert To Integer    ${released_count_text}
    RETURN    ${released_count}

Get Count Of Associates With Open Status In Payroll Status Page On Web
    [Documentation]    This keyword returns open count in release status on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | store_name | Store object fetched from template |
    ...    | week_period_value | Week period value in 'MM/DD/YYYY - MM/DD/YYYY' format |
    ...    | =Returns= | =Description= |
    ...    | open_count | Returns open count in release status |
    [Arguments]    ${store_name}    ${week_period_value}
    ${open_count_locator}    Update Locator With Dynamic Values    ${PAYROLL_STATUS_PAGE_OPEN_COUNT}
    ...    TARGET_WEEK=${week_period_value}    STORE_NAME=${store_name}
    Wait Until Element Disappears On Webpage    ${PAYROLL_STATUS_PAGE_SPINNER}
    Wait Until Element Is Visible On Webpage    ${open_count_locator}    timeout=${LONG_TIMEOUT}
    ...    error_message="Open count for store ${store_name} and week ${week_period_value} did not appear within 30 seconds"
    ${open_count_text}    Get Element Text On Webpage    ${open_count_locator}
    ${open_count}    Convert To Integer    ${open_count_text}
    RETURN    ${open_count}

Get Total Count For Release Status In Payroll Status Page On Web
    [Documentation]    This keyword returns total count in release status on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | store_name | Store object fetched from template |
    ...    | week_period_value | Week period value in 'MM/DD/YYYY - MM/DD/YYYY' format |
    ...    | =Returns= | =Description= |
    ...    | total_count | Returns total count in release status |
    [Arguments]    ${store_name}    ${week_period_value}
    ${total_count_locator}    Update Locator With Dynamic Values    ${PAYROLL_STATUS_PAGE_TOTAL_COUNT}
    ...    TARGET_WEEK=${week_period_value}    STORE_NAME=${store_name}
    ${total_count_text}    Get Element Text On Webpage    ${total_count_locator}
    ${total_count}    Convert To Integer    ${total_count_text}
    RETURN    ${total_count}

Click On Unit Link On Payroll Status Page On Web
    [Documentation]    This keyword clicks on unit link for given week on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | store_name | Store object fetched from template |
    ...    | week_period_value | Week period value in 'MM/DD/YYYY - MM/DD/YYYY' format |
    [Arguments]    ${store_name}    ${week_period_value}
    ${unit_link_locator}    Update Locator With Dynamic Values    ${PAYROLL_STATUS_PAGE_STORE_LINK}
    ...    TARGET_WEEK=${week_period_value}    STORE_NAME=${store_name}
    Click Element On Webpage    ${unit_link_locator}
    Wait Until Page Is Loaded

Click On Store Name Link On Payroll Status Page On Web
    [Documentation]    This keyword clicks on store name link for given week on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | store_name | Store object fetched from template |
    ...    | week_period_value | Week period value in 'MM/DD/YYYY - MM/DD/YYYY' format |
    [Arguments]    ${store_name}    ${week_period_value}
    ${store_link_locator}    Update Locator With Dynamic Values    ${PAYROLL_STATUS_PAGE_STORE_LEVEL_STORE_LINK}
    ...    TARGET_WEEK=${week_period_value}    STORE_NAME=${store_name}
    Click Element On Webpage    ${store_link_locator}
    Wait Until Page Is Loaded

Expand Department On Payroll Status Page On Web
    [Documentation]    This keyword selects department on Payroll Status page
    ...    | =Arguments= | =Description= |
    ...    | dept_name | Department name |
    [Arguments]    ${dept_name}
    ${dept_link_locator}    Update Locator With Dynamic Values    ${PAYROLL_STATUS_PAGE_DEPT_LEVEL_DEPT_LINK}    DEPT_NAME=${dept_name}
    Click Element On Webpage    ${dept_link_locator}
    Wait Until Page Is Loaded

Get Associates Count On Payroll Status Page On Web
    [Documentation]    This keyword gets associate count under selected department for given week on Payroll Status page
    ...    | =Returns= | =Description= |
    ...    | associates_count | Returns associates count in payroll status page |
    ${associates_count}    Get Element Count On Web Page    ${PAYROLL_STATUS_PAGE_DEPT_LEVEL_ASSOCIATE_LIST}
    RETURN    ${associates_count}

Click Filter Icon On Payroll Status Page On Web
    [Documentation]    This keyword clicks on filter icon on Payroll Status page if it is not expanded
    Wait Until Page Is Loaded
    ${is_filter_open}    Is Element Visible On Webpage    ${PAYROLL_STATUS_PAGE_APPLY}
    IF    not ${is_filter_open}
        Click Element On Webpage    ${PAYROLL_STATUS_PAGE_FILTER_ICON}
    END
    Wait Until Element Is Visible On Webpage    ${PAYROLL_STATUS_PAGE_APPLY}    timeout=${LONG_TIMEOUT}
    ...    error_message="Filter icon did not expand to show filter options within 30 seconds"
