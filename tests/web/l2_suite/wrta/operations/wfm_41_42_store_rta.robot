*** Settings ***
Documentation       This test case is to verify computation of pay rule engine

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rta/operations/pay_rule_engine_page.resource

Test Teardown       Run Keywords    Close Browser

Test Tags           action:write    battc00049    dev:bushra    config:rta    bat_phase1    module:timekeeping


*** Test Cases ***
BATTC00049: Verify computation of pay rule engine
    [Documentation]    This test verifies the CORP user ability to compute pay rule for a given associate in a store for a week
    Login And Launch WFM Web App    user_key=SM1_STORE1
    ${ess_user}    Get User    user_key=ESS2_STORE1
    ${shift_data}    Get Timecard Shift Data    shift_day=-2_5
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Verify Timecard Page Is Loaded On Web
    Cleanup Shift And Special Pay If Exists On Timecard Page On Web    ${shift_data}[shift_day]
    ${shift_added_date}    ${formatted_start_time}    ${formatted_end_time}    Add Shift On Exception Management Page On Web
    ...    ${shift_data}
    Log    Shift Created For Date: ${shift_added_date}, Start Time: ${formatted_start_time}, End Time: ${formatted_end_time}

    IF    '${shift_added_date}' == ' '
        Fail    Shift was not added successfully.
    END
    Navigate To Pay Results Section On Web
    ${job_code_pay_result_page}    Get Job Code For Date In Pay Results Section On Web    ${shift_added_date}
    ${store_pay_result_page}    Get Store For Date In Pay Results Section On Web    ${shift_added_date}
    ${pay_category_pay_result_page}    Get Pay Category For Date In Pay Results Section On Web    ${shift_added_date}
    ${hours_pay_result_page}    Get Hours For Date In Pay Results Section On Web    ${shift_added_date}
    ${hours_pay_result_minutes}    Get Hours In Minutes For Pay Results Section On Web    ${hours_pay_result_page}
    Navigate To Timecard Section On Web
    ${emp_name}    Get Employee Name In Timecard Section On Web
    ${week_data}    Get Shown Week Date Range From Timecard Page
    VAR    ${week}    ${week_data}[1] - ${week_data}[2]
    Navigate To Pay Results Section On Web
    ${is_total_pay_displayed}    Verify Total Pay Displayed In Pay Results Section On Web
    IF    ${is_total_pay_displayed}
        ${total_pay_results_page}    Capture Total Pay In Pay Results Section On Web
        ${cost_pay_result_page}    Get Cost For Date In Pay Results Section On Web    ${shift_added_date}
    END
    Log Out From Web Application
    Run Keyword And Ignore Error    Close Browser Tab On Web

    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RTA Test Tools Pay Rule Engine Page On Web
    ${total_pay_rule_eng_page}    Compute Pay Results On Web    ${store_pay_result_page}    ${emp_name}    ${week}
    IF    ${is_total_pay_displayed}
        ${total_pay_result_page_formatted}    Replace String    ${total_pay_results_page}    ${SPACE}    ${EMPTY}
        ${total_pay_result_page_formatted_actual}    Split String    ${total_pay_result_page_formatted}    .
        Should Contain    ${total_pay_rule_eng_page}    ${total_pay_result_page_formatted_actual}[0]
        ...    msg=Total pay on pay rule engine does not match with pay results page.
        ${cost_segment_pay_cost}    Get Cost On Cost Segment For Date On Web    ${shift_added_date}
        Should Contain    ${cost_pay_result_page}    ${cost_segment_pay_cost}
        ...    msg=Cost on cost segment does not match with pay results page.
    END
    ${cost_segment_job_code}    Get Job Code On Cost Segment For Date On Web    ${shift_added_date}
    Should Contain    ${job_code_pay_result_page}    ${cost_segment_job_code}
    ...    msg=Job code on cost segment does not match with pay results page.
    ${cost_segment_pay_category}    Get Pay Category On Cost Segment For Date On Web    ${shift_added_date}
    Should Contain    ${pay_category_pay_result_page}    ${cost_segment_pay_category}
    ...    msg=Pay category on cost segment does not match with pay results page.
    ${cost_segment_hours}    Get Hours On Cost Segment For Date On Web    ${shift_added_date}
    ${cost_segment_hours_in_minutes}    Get Hours In Minutes For Pay Rule Engine Page On Web    ${cost_segment_hours}
    Should Be Equal    ${hours_pay_result_minutes}    ${cost_segment_hours_in_minutes}
    ...    msg=Hours on cost segment does not match with pay results page.
    Click On Clear Button On Web
    Log Out From Web Application
    Run Keyword And Ignore Error    Close Browser Tab On Web

    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Select Day On Exception Management Page On Web    ${shift_data}[shift_day]
    Click On Associate Clock Icon On Exception Management Page On Web    ${ess_user}[displayName]
    Delete Shift On Timecard Page On Web    ${shift_added_date}    ${formatted_start_time}
    Navigate To Pay Results Section On Web
    ${pay_result_visible}    Verify Pay Results Data Not Visible For Deleted Shift    ${shift_added_date}
    IF    ${pay_result_visible}
        Fail    Cost segment pay cost not updated after shift deletion.
    END
    ${is_total_pay_after_shift_delete}    Verify Total Pay Displayed In Pay Results Section On Web
    IF    ${is_total_pay_after_shift_delete}
        ${total_pay_results_page_updated}    Capture Total Pay In Pay Results Section On Web
    ELSE
        VAR    ${total_pay_results_page_updated}    ${EMPTY}
    END
    Log Out From Web Application
    Run Keyword And Ignore Error    Close Browser Tab On Web
    IF    ${is_total_pay_displayed}
        Login And Launch WFM Web App    user_key=SYSADMIN
        Navigate To RTA Test Tools Pay Rule Engine Page On Web
        ${updated_total_pay_rule_eng_page}    Compute Pay Results On Web    ${store_pay_result_page}    ${emp_name}    ${week}
        IF    '${updated_total_pay_rule_eng_page}' == '${total_pay_rule_eng_page}'
            IF    '${total_pay_results_page_updated}' == '${EMPTY}'
                Fail    Total pay not displayed on pay results page after shift deletion, but pay rule engine shows a value.
            ELSE
                ${total_pay_result_page_shift_delete}    Replace String    ${total_pay_results_page_updated}    ${SPACE}    ${EMPTY}
                ${total_pay_result_page_after_cleanup}    Split String    ${total_pay_result_page_shift_delete}    .
                Should Contain    ${updated_total_pay_rule_eng_page}    ${total_pay_result_page_after_cleanup}[0]
                ...    msg=Total pay on pay rule engine not updated after shift deletion.
            END
        END
        ${cost_segment_pay_cost}    Get Cost On Cost Segment For Date On Web    ${shift_added_date}
        IF    '${cost_segment_pay_cost}' != "None"
            Fail    Cost segment pay cost found for date even after shift deletion.
        END
    END
