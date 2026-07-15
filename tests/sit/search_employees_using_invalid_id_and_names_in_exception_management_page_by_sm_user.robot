*** Settings ***
Documentation       Test case for verifying that SM user is not able to search employees using invalid employee ID & invalid employee names in Exception Management page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:read    config:rta    sittc86004    sit_b0    sit    web    sit_epic    sit_r22


*** Test Cases ***
SITTC86004: Verify SM user is not able to search employees using invalid employee ID & invalid employee names in exception management page
    [Documentation]    This test case is to verify that SM user is not able to search employees using invalid employee ID & invalid employee names in Exception Management page
    VAR    ${test_data_1}    SITE
    VAR    ${test_data_2}    999
    VAR    ${test_data_3}    ZSITStore2

    Login And Launch WFM Web App    user_key=SM1_STORE1_SIT
    Navigate To RTA Operations Exception Management Page On Web

    ${is_Employee_visible}    Search And Validate Employee Search On Exception Management Page On Web    employee_data=${test_data_1}
    Should Not Be True    ${is_Employee_visible}
    ...    msg=Expected employee '${test_data_1}' Not to be visible in search results, but it was. Actual visibility: ${is_Employee_visible}

    ${is_Employee_visible}    Search And Validate Employee Search On Exception Management Page On Web    employee_data=${test_data_2}
    Should Not Be True    ${is_Employee_visible}
    ...    msg=Expected employee '${test_data_2}' Not to be visible in search results, but it was. Actual visibility: ${is_Employee_visible}

    ${is_Employee_visible}    Search And Validate Employee Search On Exception Management Page On Web    employee_data=${test_data_3}
    Should Not Be True    ${is_Employee_visible}
    ...    msg=Expected employee '${test_data_3}' Not to be visible in search results, but it was. Actual visibility: ${is_Employee_visible}
