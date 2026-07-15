*** Settings ***
Documentation       Test case to verify advance filter functionality on exception management page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           battc00060    dev:amol    action:read    obsolete


*** Test Cases ***
WFM-50 Verify Advance Filter Functionality
    [Documentation]    Validates advanced filter functionality on Exception Management page:
    ...    1. Verifies baseline employee counts (Total = PT + FT)
    ...    2. Validates PT filter shows only PT employees
    ...    3. Validates FT filter shows only FT employees
    ...    4. Validates combined PT+FT filter shows correct sum
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    ${all_emp_count}    Get All Employee Count On Web
    ${pt_emp_count}    Get Part Time Employee Count On Web
    ${ft_emp_count}    Get Full Time Employee Count On Web
    ${expected_total}    Evaluate    ${pt_emp_count} + ${ft_emp_count}
    Should Be Equal As Numbers    ${all_emp_count}    ${expected_total}
    ...    msg=Total employee count validation failed: Total (${all_emp_count}) ≠ PT (${pt_emp_count}) + FT (${ft_emp_count})
    ${pt_filtered_count}    Apply Advanced Filter For Part Time Employees On Web
    Should Be Equal As Numbers    ${pt_filtered_count}    ${pt_emp_count}
    ...    msg=PT filter failed: Filtered count (${pt_filtered_count}) ≠ Baseline (${pt_emp_count})
    ${ft_filtered_count}    Apply Advanced Filter For Full Time Employees On Web
    Should Be Equal As Numbers    ${ft_filtered_count}    ${ft_emp_count}
    ...    msg=FT filter failed: Filtered count (${ft_filtered_count}) ≠ Baseline (${ft_emp_count})
    ${combined_filtered_count}    Apply Advanced Filter For Combined Employees On Web
    Should Be Equal As Numbers    ${combined_filtered_count}    ${expected_total}
    ...    msg=Combined filter failed: Filtered count (${combined_filtered_count}) ≠ Expected PT+FT (${expected_total})
    Clear Advanced Filter On Web
