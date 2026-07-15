*** Settings ***
Documentation       Test case for verifying that SM user is able to search employees using ID & names in Exception Management page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:read    config:rta    sittc86001    sit_b0    sit    web    sit_r22    sit_epic


*** Test Cases ***
SITTC86001: Verify SM user is able to search employees using ID & names in exception management page
    [Documentation]    This test case is to verify that SM user is able to search employees using ID & names in Exception Management page
    ${user}    Get User    user_key=ESS2_STORE1_SIT
    VAR    ${emp_id}    ${user}[username]
    ${test_data_1}    Evaluate    $Emp_id[1:4]
    ${test_data_2}    Evaluate    $Emp_id[7:]
    ${test_data_3}    Evaluate    $Emp_id[-3:]
    ${test_data_4}    Evaluate    str(int($Emp_id[-3:]))
    ${test_data_5}    Evaluate    $Emp_id[:4] + "Store" + str(int($Emp_id[4:7]))
    ${test_data_6}    Evaluate    "Associate" + $Emp_id[-3:]

    Login And Launch WFM Web App    user_key=SM1_STORE1_SIT
    Navigate To RTA Operations Exception Management Page On Web

    ${is_Employee_visible}    Search And Validate Employee Search On Exception Management Page On Web    employee_data=${emp_id}
    Should Be True    ${is_Employee_visible}
    ...    msg=Expected employee '${emp_id}' to be visible in search results, but it was not. Actual visibility: ${is_Employee_visible}

    ${is_matching_records_visible}    Search And Validate Employee Search On Exception Management Page On Web
    ...    employee_data=${test_data_1}
    Should Be True    ${is_matching_records_visible}
    ...    msg=Expected employee '${test_data_1}' to be visible in search results, but it was not. Actual visibility: ${is_matching_records_visible}

    ${is_matching_records_visible}    Search And Validate Employee Search On Exception Management Page On Web
    ...    employee_data=${test_data_2}
    Should Be True    ${is_matching_records_visible}
    ...    msg=Expected employee '${test_data_2}' to be visible in search results, but it was not. Actual visibility: ${is_matching_records_visible}

    ${is_matching_records_visible}    Search And Validate Employee Search On Exception Management Page On Web
    ...    employee_data=${test_data_3}
    Should Be True    ${is_matching_records_visible}
    ...    msg=Expected employee '${test_data_3}' to be visible in search results, but it was not. Actual visibility: ${is_matching_records_visible}

    ${is_matching_records_visible}    Search And Validate Employee Search On Exception Management Page On Web
    ...    employee_data=${test_data_4}
    Should Be True    ${is_matching_records_visible}
    ...    msg=Expected employee '${test_data_4}' to be visible in search results, but it was not. Actual visibility: ${is_matching_records_visible}

    ${is_matching_records_visible}    Search And Validate Employee Search On Exception Management Page On Web
    ...    employee_data=${test_data_5}
    Should Be True    ${is_matching_records_visible}
    ...    msg=Expected employee '${test_data_5}' to be visible in search results, but it was not. Actual visibility: ${is_matching_records_visible}

    ${is_matching_records_visible}    Search And Validate Employee Search On Exception Management Page On Web
    ...    employee_data=${test_data_6}
    Should Be True    ${is_matching_records_visible}
    ...    msg=Expected employee '${test_data_6}' to be visible in search results, but it was not. Actual visibility: ${is_matching_records_visible}
