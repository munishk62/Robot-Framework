*** Settings ***
Documentation       Test case for verifying that SM user is not able to search employees using invalid employee ID & invalid employee names in Time Card page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Resource            resources/web/rta/operations/timecard.resource

Test Teardown       Close Browser

Test Tags           dev:rushikesh    action:read    config:rta    sittc86003    sit_b0    sit    web    sit_epic    sit_r22


*** Test Cases ***
SITTC86003: Verify SM user is not able to search employees using invalid employee ID & invalid employee names in timecard page
    [Documentation]    This test case is to Verify SM User Is Not Able To Search Employees Using Invalid Employee ID & Invalid Employee Names In Timecard Page
    VAR    ${test_data_1}    SITE
    VAR    ${test_data_2}    999
    VAR    ${test_data_3}    ZSITStore2

    Login And Launch WFM Web App    user_key=SM1_STORE1_SIT
    Navigate To RTA Operations Exception Management Page On Web
    Click On Clock Icon Of First Employee On Exception Management Page On Web

    ${is_matching_records_visible}    Search And Validate Employee Search On Time Card Page On Web    emp_data=${test_data_1}
    Should Not Be True    ${is_matching_records_visible}
    ...    msg=Expected employee '${test_data_1}' not to be visible in search results, but it was. Actual visibility: ${is_matching_records_visible}

    ${is_matching_records_visible}    Search And Validate Employee Search On Time Card Page On Web    emp_data=${test_data_2}
    Should Not Be True    ${is_matching_records_visible}
    ...    msg=Expected employee '${test_data_2}' not to be visible in search results, but it was. Actual visibility: ${is_matching_records_visible}

    ${is_matching_records_visible}    Search And Validate Employee Search On Time Card Page On Web    emp_data=${test_data_3}
    Should Not Be True    ${is_matching_records_visible}
    ...    msg=Expected employee '${test_data_3}' not to be visible in search results, but it was. Actual visibility: ${is_matching_records_visible}
