*** Settings ***
Documentation       RTA > Testing Tools > Pay Rule Engine page related keywords

Resource            resources/web/common/common.resource
Library             resources/web/common/utility.py
Variables           resources/web/rta/operations/pay_rule_engine_page_locators.py
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RTA Test Tools Pay Rule Engine Page On Web
    [Documentation]    Navigate To RTA -> Test Tools -> Pay Rule Engine Page
    ...    and verifies pay rule engine heading at the top of the page
    Navigate To Specific Page On Web    rta    test_tools    pay_rule_engine

Compute Pay Results On Web
    [Documentation]    This keyword computes pay results
    ...    | =Arguments= | =Description= |
    ...    | store_id | Store id |
    ...    | emp_id | Employee id |
    ...    | week_range | Week for which pay results computed |
    ...    | =Returns= | =Description= |
    ...    | total_pay | Returns the total pay for given duration for employee |
    [Arguments]    ${store_id}    ${emp_id}    ${week_range}
    Wait Until Element Is Visible On Webpage    ${PAY_RULE_ENGINE_PAGE_STORE_DROPDOWN}
    Select List Item On Webpage    ${PAY_RULE_ENGINE_PAGE_STORE_DROPDOWN}    text    ${store_id}
    Run Keyword And Ignore Error    Wait Until Element Disappears On Webpage    ${PAY_RULE_ENGINE_PAGE_LOADER}    timeout=${SHORT_TIMEOUT}
    Wait Until Element Is Visible On Webpage    ${PAY_RULE_ENGINE_PAGE_WEEK}
    Select List Item On Webpage    ${PAY_RULE_ENGINE_PAGE_WEEK}    text    ${week_range}
    Run Keyword And Ignore Error    Wait Until Element Disappears On Webpage    ${PAY_RULE_ENGINE_PAGE_WEEK}    timeout=${SHORT_TIMEOUT}
    Wait Until Element Is Visible On Webpage    ${PAY_RULE_ENGINE_PAGE_USER_ID}
    Select List Item On Webpage    ${PAY_RULE_ENGINE_PAGE_USER_ID}    text    ${emp_id}
    Run Keyword And Ignore Error    Wait Until Element Disappears On Webpage    ${PAY_RULE_ENGINE_PAGE_USER_ID}    timeout=${SHORT_TIMEOUT}
    Click Element On Webpage    ${PAY_RULE_ENGINE_PAGE_COMPUTE_BTN}
    Wait Until Element Disappears On Webpage    ${PAY_RULE_ENGINE_PAGE_LOADER}
    ${is_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${PAY_RULE_ENGINE_PAGE_ASSOCIATE_DETAILS_JOBCODE}
    IF    ${is_visible}
        ${total_pay}    Get Element Text On Webpage    ${PAY_RULE_ENGINE_PAGE_TOTAL_PAY}
        RETURN    ${total_pay}
    ELSE
        Capture Screenshot On Webpage
        RETURN
    END

Get Job Code On Cost Segment For Date On Web
    [Documentation]    This keyword give the job code for cost segment
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Shift date |
    ...    | =Returns= | =Description= |
    ...    | cost_segment_job_code | Returns the job code or NONE based on shift date presence |
    [Arguments]    ${shift_date}
    ${cost_segment_job_code_locator}    Update Locator With Dynamic Values
    ...    ${PAY_RULE_ENGINE_PAGE_COST_SEG_JOB_CODE}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Is Element Visible On Webpage    ${cost_segment_job_code_locator}
    IF    ${is_visible}
        ${cost_segment_job_code}    Get Element Text On Webpage    ${cost_segment_job_code_locator}
        RETURN    ${cost_segment_job_code}
    ELSE
        RETURN
    END

Get Pay Category On Cost Segment For Date On Web
    [Documentation]    This keyword gives the job code for cost segment
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Shift date |
    ...    | =Returns= | =Description= |
    ...    | cost_segment_pay_category | Returns the pay category or NONE based on shift date presence |
    [Arguments]    ${shift_date}
    ${cost_segment_pay_category_locator}    Update Locator With Dynamic Values
    ...    ${PAY_RULE_ENGINE_PAGE_COST_SEG_PAY_CATEGORY}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Is Element Visible On Webpage    ${cost_segment_pay_category_locator}
    IF    ${is_visible}
        ${cost_segment_pay_category}    Get Element Text On Webpage    ${cost_segment_pay_category_locator}
        RETURN    ${cost_segment_pay_category}
    ELSE
        RETURN
    END

Get Cost On Cost Segment For Date On Web
    [Documentation]    This keyword gives the cost for cost segment
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Shift date |
    ...    | =Returns= | =Description= |
    ...    | cost_segment_pay_cost | Returns the pay cost or NONE based on shift date presence |
    [Arguments]    ${shift_date}
    ${cost_segment_pay_cost_locator}    Update Locator With Dynamic Values
    ...    ${PAY_RULE_ENGINE_PAGE_COST_SEG_PAY_COST}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Is Element Visible On Webpage    ${cost_segment_pay_cost_locator}
    IF    ${is_visible}
        ${cost_segment_pay_cost}    Get Element Text On Webpage    ${cost_segment_pay_cost_locator}
        RETURN    ${cost_segment_pay_cost}
    ELSE
        RETURN
    END

Get Hours On Cost Segment For Date On Web
    [Documentation]    This keyword gives the hours for cost segment
    ...    | =Arguments= | =Description= |
    ...    | shift_date | Shift date |
    ...    | =Returns= | =Description= |
    ...    | cost_segment_pay_hours | Returns the pay hours or NONE based on shift date presence |
    [Arguments]    ${shift_date}
    ${cost_segment_pay_hours_locator}    Update Locator With Dynamic Values
    ...    ${PAY_RULE_ENGINE_PAGE_COST_SEG_PAY_HOURS}
    ...    SHIFT_DATE=${shift_date}
    ${is_visible}    Is Element Visible On Webpage    ${cost_segment_pay_hours_locator}
    IF    ${is_visible}
        ${cost_segment_pay_hours}    Get Element Text On Webpage    ${cost_segment_pay_hours_locator}
        RETURN    ${cost_segment_pay_hours}
    ELSE
        RETURN
    END

Get Hours In Minutes For Pay Rule Engine Page On Web
    [Documentation]    This keyword converts hours to minutes in pay rule engine page
    ...    | =Arguments= | =Description= |
    ...    | hours | Hours to be converted |
    ...    | =Returns= | =Description= |
    ...    | minutes | Returns the converted minutes |
    [Arguments]    ${hours}
    ${minutes}    Convert Time    ${hours}
    RETURN    ${minutes}

Click On Clear Button On Web
    [Documentation]    This keyword clicks on clear button on pay rule engine
    Click Element On Webpage    ${PAY_RULE_ENGINE_PAGE_CLEAR_BTN}
    Wait Until Page Is Loaded
