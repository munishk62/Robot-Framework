*** Settings ***
Documentation       Test cases for verifying display preferences scenarios on exception management page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags           dev:amol    action:read    config:rta


*** Test Cases ***
RTA-51 Verify Display Preferences Select All Options
    [Documentation]    Test case to verify display preferences on exception management page

    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Select Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_JOB_TITLE}
    ${emp_icon_count}    ${emp_type_count}    ${emp_id_count}    ${emp_job_title_count}
    ...    Get Count For Selected Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ICON_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_SEARCH}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ID_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_JOB_TITLE_SEARCH}

    Validate Display Preference Count On Exception Management Page On Web
    ...    ${emp_icon_count}
    ...    ${emp_type_count}
    ...    ${emp_id_count}
    ...    ${emp_job_title_count}
    ...    all

RTA-51-2 Verify Display Preferences - Employee Type
    [Documentation]    Test case to verify display preferences on exception management page
    [Tags]    obsolete
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Select Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ICON}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ID}
    ${emp_icon_count}    ${emp_type_count}    ${emp_id_count}    ${emp_job_title_count}
    ...    Get Count For Selected Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ICON_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_SEARCH}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ID_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_JOB_TITLE_SEARCH}

    Validate Display Preference Count On Exception Management Page On Web
    ...    ${emp_icon_count}
    ...    ${emp_type_count}
    ...    ${emp_id_count}
    ...    ${emp_job_title_count}
    ...    all

RTA-51-3 Verify Display Preferences - Employee Icon
    [Documentation]    Test case to verify display preferences on exception management page
    [Tags]    obsolete
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Select Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_TYPE}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ID}
    ${emp_icon_count}    ${emp_type_count}    ${emp_id_count}    ${emp_job_title_count}
    ...    Get Count For Selected Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ICON_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_SEARCH}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ID_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_JOB_TITLE_SEARCH}

    Validate Display Preference Count On Exception Management Page On Web
    ...    ${emp_icon_count}
    ...    ${emp_type_count}
    ...    ${emp_id_count}
    ...    ${emp_job_title_count}
    ...    employee type

RTA-51-4 Verify Display Preferences - Employee Id
    [Documentation]    Test case to verify display preferences on exception management page
    [Tags]    obsolete
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Select Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ICON}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_TYPE}
    ${emp_icon_count}    ${emp_type_count}    ${emp_id_count}    ${emp_job_title_count}
    ...    Get Count For Selected Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ICON_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_SEARCH}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ID_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_JOB_TITLE_SEARCH}

    Validate Display Preference Count On Exception Management Page On Web
    ...    ${emp_icon_count}
    ...    ${emp_type_count}
    ...    ${emp_id_count}
    ...    ${emp_job_title_count}
    ...    employee icon

RTA-51-5 Verify Display Preferences - Job Title
    [Documentation]    Test case to verify display preferences on exception management page
    [Tags]    obsolete
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web
    Select Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ID}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_JOB_TITLE}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ICON}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_TYPE}
    ${emp_icon_count}    ${emp_type_count}    ${emp_id_count}    ${emp_job_title_count}
    ...    Get Count For Selected Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ICON_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_SEARCH}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ID_SEARCH}    ${EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_JOB_TITLE_SEARCH}

    Validate Display Preference Count On Exception Management Page On Web
    ...    ${emp_icon_count}
    ...    ${emp_type_count}
    ...    ${emp_id_count}
    ...    ${emp_job_title_count}
    ...    employee job title
