*** Settings ***
Documentation       Test Suite to verify ESS3_Store1 Current Week Timecard related scenarios

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource

Test Teardown       Run Keywords    Close Browser

Test Tags           bat_phase1    config:rta    timecard_current_week


*** Test Cases ***
BATTC00061: Verify display and sort preferences in exception management
    [Documentation]    Test Case To Verify Display And Sort Preferences In Exception Management Page
    [Tags]    dev:yogesh    action:read    battc00061    module:timekeeping
    ${roster_filter_data}    Get Roster Filter Data
    ${ft_employee}    Get User    ${roster_filter_data}[ft_employee_key]
    ${pt_employee}    Get User    ${roster_filter_data}[pt_employee_key]
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RTA Operations Exception Management Page On Web

    ${is_emp_icon_visible}    Is Employee Icon Visible For Employees On Exception Management Page On Web
    IF    not ${is_emp_icon_visible}
        Log    Employee icons are not visible on Exception Management page
        Skip    Employee icons are not visible on Exception Management page, cannot verify display preferences related to employee icon
    END

    Verify Associate Presence On Exception Management Page On Web    ${ft_employee}[displayName]
    Verify Associate Presence On Exception Management Page On Web    ${pt_employee}[displayName]
    Verify Employee Type Employee Id And Employee Icon On Exception Management Page On Web    ${ft_employee}[displayName]
    ...    ${ft_employee}[username]    ${roster_filter_data}[ft_employee_type]
    Verify Employee Type Employee Id And Employee Icon On Exception Management Page On Web    ${pt_employee}[displayName]
    ...    ${pt_employee}[username]    ${roster_filter_data}[pt_employee_type]

    # Employee Type: Visible
    Select Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ICON}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ID}
    ${ft_employee_id_locator}
    ...    ${ft_employee_type_locator}
    ...    ${ft_employee_icon_locator}
    ...    ${ft_employee_name}
    ...    Build Locator For Display Preference On Exception Management Page On Web    ${ft_employee}[displayName]    ${ft_employee}[username]    ${roster_filter_data}[ft_employee_type]
    Verify Display Preference On Exception Management Page On Web    ${ft_employee_type_locator}    ${ft_employee_id_locator}
    ...    ${ft_employee_icon_locator}
    ${pt_employee_id_locator}
    ...    ${pt_employee_type_locator}
    ...    ${pt_employee_icon_locator}
    ...    ${pt_employee_name}
    ...    Build Locator For Display Preference On Exception Management Page On Web    ${pt_employee}[displayName]    ${pt_employee}[username]    ${roster_filter_data}[pt_employee_type]
    Verify Display Preference On Exception Management Page On Web    ${pt_employee_type_locator}    ${pt_employee_id_locator}
    ...    ${pt_employee_icon_locator}

    # Employee Icon: Visible
    Select Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_TYPE}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ID}
    Verify Display Preference On Exception Management Page On Web    ${ft_employee_icon_locator}    ${ft_employee_id_locator}
    ...    ${ft_employee_type_locator}

    # Employee Id: Visible
    Select Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ICON}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_TYPE}
    Verify Display Preference On Exception Management Page On Web    ${ft_employee_id_locator}    ${ft_employee_type_locator}
    ...    ${ft_employee_icon_locator}

    # All Options Unselected
    Select Display Configurations On Exception Management Page On Web
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ICON}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_TYPE}
    ...    ${EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ID}
    Verify Display Preference On Exception Management Page On Web    ${ft_employee_name}    ${ft_employee_type_locator}
    ...    ${ft_employee_icon_locator}
    Verify Display Preference On Exception Management Page On Web    ${pt_employee_name}    ${pt_employee_type_locator}
    ...    ${pt_employee_icon_locator}
    Reset Display Configurations On Exception Management Page On Web
    Verify Employee Type Employee Id And Employee Icon On Exception Management Page On Web    ${ft_employee}[displayName]
    ...    ${ft_employee}[username]    ${roster_filter_data}[ft_employee_type]
    Verify Employee Type Employee Id And Employee Icon On Exception Management Page On Web    ${pt_employee}[displayName]
    ...    ${pt_employee}[username]    ${roster_filter_data}[pt_employee_type]
    Apply Advanced Filter For Department On Web
    Apply Sort Preference And Verify Order On Exception Management Page On Web    Full Timers First
    Apply Sort Preference And Verify Order On Exception Management Page On Web    Alphabetical

BATTC00067: Verify user is able to filter associates in exception management
    [Documentation]    Verify that a SM user is able to use filter to find the associates in exception management as per the provided filter criteria
    ...    Filter_Criteria1 - Staffgroup: Staffgroup of #PT_Employee (multi select list support needed)
    ...    Filter_Criteria2 - Employee Name: #FT_Employee (checkbox)
    ...    Filter_Criteria3 - Employee Type: FT - Full Time
    ...    Filter_Criteria4 - Employee Type: PT - Part Time
    ...    Filter_Criteria5 - Reportee: Direct
    ...    Filter_Criteria6 - Reportee: Indirect
    ...    Filter_Criteria7 - Reportee: My Location
    [Tags]    action:write    dev:bushra    battc00067    module:timekeeping
    ${roster_filter_data}    Get Roster Filter Data
    ${self_user}    Get User    ${roster_filter_data}[self_user_key]
    ${ft_employee}    Get User    ${roster_filter_data}[ft_employee_key]
    ${pt_employee}    Get User    ${roster_filter_data}[pt_employee_key]
    Login And Launch WFM Web App    ${self_user}[user_key]
    Navigate To RTA Operations Exception Management Page On Web
    Verify Associate Presence On Exception Management Page On Web    ${self_user}[displayName]
    Verify Associate Presence On Exception Management Page On Web    ${ft_employee}[displayName]
    Verify Associate Presence On Exception Management Page On Web    ${pt_employee}[displayName]

    Assert At Least Two Staff Groups Are Available On Web
    ${staff_group_PT}    Get System Value    StaffGroup    SG3
    Apply Advanced Filter By Staff Group On Exception Management Page On Web
    ...    ${staff_group_PT}
    Verify Associate Presence On Exception Management Page On Web    ${pt_employee}[displayName]
    Verify Associate Presence On Exception Management Page On Web    ${ft_employee}[displayName]    False

    ${staff_group_FT}    Get System Value    StaffGroup    SG1
    Apply Advanced Filter By Name On Exception Management Page On Web    ${staff_group_FT}    ${ft_employee}[displayName]
    ${emp_count}    Get All Employee Count On Web
    Should Be Equal As Numbers    ${emp_count}    1    msg=Filtered employee count doesn't match the search criteria
    Verify Associate Presence On Exception Management Page On Web    ${ft_employee}[displayName]
    Verify Associate Presence On Exception Management Page On Web    ${pt_employee}[displayName]    False

    ${ft_filtered_count}    Apply Advanced Filter For Full Time Employees On Web
    Log    Filtered full-time employee count on Exception Management page: ${ft_filtered_count}
    Verify Associate Presence On Exception Management Page On Web    ${ft_employee}[displayName]
    Verify Associate Presence On Exception Management Page On Web    ${pt_employee}[displayName]    False

    ${pt_filtered_count}    Apply Advanced Filter For Part Time Employees On Web
    Log    Filtered part-time employee count on Exception Management page: ${pt_filtered_count}
    Verify Associate Presence On Exception Management Page On Web    ${pt_employee}[displayName]
    Verify Associate Presence On Exception Management Page On Web    ${ft_employee}[displayName]    False

    ${reporting_hierarchy_enabled}    Get Config Value    key=ENABLE_REPORTING_HIERARCHY
    IF    '${reporting_hierarchy_enabled}' == 'Y'
        Clear Filter In Exception Management Page On Web
        ${reportee_type_direct}    Get System Value    ReporteeType    DIRECT
        IF    '${reportee_type_direct}' != 'NA'
            Apply Advanced Filter By Reportee Type On Exception Management Page On Web    DIRECT
            Verify Associate Presence On Exception Management Page On Web    ${ft_employee}[displayName]
            Verify Associate Presence On Exception Management Page On Web    ${pt_employee}[displayName]
            Verify Associate Presence On Exception Management Page On Web    ${self_user}[displayName]    False
        END
        ${reportee_type_indirect}    Get System Value    ReporteeType    INDIRECT
        IF    '${reportee_type_indirect}' != 'NA'
            Apply Advanced Filter By Reportee Type On Exception Management Page On Web    INDIRECT
            Verify Associate Presence On Exception Management Page On Web    ${pt_employee}[displayName]
            Verify Associate Presence On Exception Management Page On Web    ${ft_employee}[displayName]
        END
        ${reportee_type_my_location}    Get System Value    ReporteeType    MY_LOCATION
        IF    '${reportee_type_my_location}' != 'NA'
            Apply Advanced Filter By Reportee Type On Exception Management Page On Web    MY_LOCATION
            Verify Associate Presence On Exception Management Page On Web    ${ft_employee}[displayName]
            Verify Associate Presence On Exception Management Page On Web    ${pt_employee}[displayName]
            Verify Associate Presence On Exception Management Page On Web    ${self_user}[displayName]
        END
    ELSE
        Log    Steps 6-8: Skipping reportee filters - Reportee filter not available (PC00067 not enabled)    level=WARN
    END

    [Teardown]    Run Keywords
    ...    Clear Filter In Exception Management Page On Web    AND
    ...    Wait Until Element Is Visible On Webpage    ${EXCEPTION_MANAGEMENT_PAGE_SECOND_EMPLOYEE_SHOWN}    timeout=${MEDIUM_TIMEOUT}    AND
    ...    Capture Screenshot On Webpage    AND
    ...    Close Browser
