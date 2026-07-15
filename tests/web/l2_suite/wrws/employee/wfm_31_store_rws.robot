*** Settings ***
Documentation       WFM-31: Verify that SM user is able to use filter to find associates as per filter criteria
...                 Applicability: RWS license enabled (PC00001)
...                 ESS3_STORE1 and ESS4_STORE1 are of different employee types (FT/PT)

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/employee/roster.resource
Resource            resources/web/rws/employee/roster_db.resource

Test Teardown       Close Browser

Test Tags           dev:azar    action:read    bat_phase1    battc00040    config:rws    om_hr


*** Test Cases ***
BATTC00040: Verify the user of filter in roster list page
    [Documentation]    Verify that SM user can filter associates using various filter criteria
    ...    Logged-in user: self_user_key (Store Manager user for this template, with direct reports ESS3_STORE1, ESS4_STORE1)
    ...    Step 1: Navigate to roster page and verify default associates (active) - #Self, #FT_Employee, #PT_Employee displayed
    ...    Step 2: Apply Filter Criteria 1 - FT Employee ID + Full Time + Active - only #FT_Employee displayed
    ...    Step 3: Apply Filter Criteria 2 - PT Employee ID + Part Time + Active - only #PT_Employee displayed
    ...    Step 4: Apply Filter Criteria 3 - Full Time only - #FT_Employee displayed, #PT_Employee not displayed
    ...    Step 5: Apply Filter Criteria 4 - Full Time + Inactive - neither #FT_Employee nor #PT_Employee displayed
    ...    Step 6: Apply Filter Criteria 5 - Direct Reportees - #FT_Employee and #PT_Employee displayed, #Self NOT displayed
    ...    Step 7: Apply Filter Criteria 6 - Indirect Reportees - #FT_Employee and #PT_Employee displayed, #Self NOT displayed
    ...    Step 8: Apply Filter Criteria 7 - My Location - #FT_Employee, #PT_Employee, and #Self all displayed
    ${roster_filter_data}    Get Roster Filter Data
    ${self_user}    Get User    ${roster_filter_data}[self_user_key]
    ${ft_employee}    Get User    ${roster_filter_data}[ft_employee_key]
    ${pt_employee}    Get User    ${roster_filter_data}[pt_employee_key]
    ${filter_1}    Get From Dictionary    ${roster_filter_data}    filter_criteria_1
    ${filter_2}    Get From Dictionary    ${roster_filter_data}    filter_criteria_2
    ${filter_3}    Get From Dictionary    ${roster_filter_data}    filter_criteria_3
    ${filter_4}    Get From Dictionary    ${roster_filter_data}    filter_criteria_4
    ${filter_5}    Get From Dictionary    ${roster_filter_data}    filter_criteria_5
    ${filter_6}    Get From Dictionary    ${roster_filter_data}    filter_criteria_6
    ${filter_7}    Get From Dictionary    ${roster_filter_data}    filter_criteria_7
    Login And Launch WFM Web App    ${self_user}[user_key]
    Navigate To RWS Employee Roster Page On Web
    Verify Filtered Associate Data Is Displayed On Roster Page On Web
    ...    ${ft_employee}[displayName]
    ...    ${ft_employee}[username]    ${filter_1}[associate_type]
    Verify Filtered Associate Data Is Displayed On Roster Page On Web
    ...    ${pt_employee}[displayName]
    ...    ${pt_employee}[username]    ${filter_2}[associate_type]
    Verify Filtered Associate Data Is Displayed On Roster Page On Web
    ...    ${self_user}[displayName]
    ...    ${self_user}[username]    ${filter_1}[associate_type]
    Apply Filter With Associate Criteria On Roster Page On Web
    ...    ${ft_employee}[username]
    ...    ${filter_1}[associate_type]    ${filter_1}[status]
    ...    ${filter_1}[reportee_type]
    Verify Filtered Associate Data Is Displayed On Roster Page On Web
    ...    ${ft_employee}[displayName]
    ...    ${ft_employee}[username]    ${filter_1}[associate_type]
    Apply Filter With Associate Criteria On Roster Page On Web
    ...    ${pt_employee}[username]
    ...    ${filter_2}[associate_type]    ${filter_2}[status]
    ...    ${filter_2}[reportee_type]
    Verify Filtered Associate Data Is Displayed On Roster Page On Web
    ...    ${pt_employee}[displayName]
    ...    ${pt_employee}[username]    ${filter_2}[associate_type]
    Apply Filter With Associate Criteria On Roster Page On Web
    ...    ${filter_3}[associate_id]
    ...    ${filter_3}[associate_type]    ${filter_3}[status]
    ...    ${filter_3}[reportee_type]
    Verify Filtered Associate Data Is Displayed On Roster Page On Web
    ...    ${ft_employee}[displayName]
    ...    ${ft_employee}[username]    ${filter_3}[associate_type]
    Apply Filter With Associate Criteria On Roster Page On Web
    ...    ${filter_4}[associate_id]
    ...    ${filter_4}[associate_type]    ${filter_4}[status]
    ...    ${filter_4}[reportee_type]
    ${reporting_hierarchy_available}    Check If Reporting Hierarchy Enabled From DB
    IF    ${reporting_hierarchy_available}
        ${reportee_info}    Is Reportee Filter Available On Roster Page On Web
        IF    ${reportee_info}[direct]
            Reset All Filters On Roster Page On Web
            Apply Filter With Associate Criteria On Roster Page On Web
            ...    ${filter_5}[associate_id]
            ...    ${filter_5}[associate_type]    ${filter_5}[status]
            ...    ${filter_5}[reportee_type]
            Verify Filtered Associate Data Is Displayed On Roster Page On Web
            ...    ${ft_employee}[displayName]
            ...    ${ft_employee}[username]    ${filter_1}[associate_type]
            Verify Filtered Associate Data Is Displayed On Roster Page On Web
            ...    ${pt_employee}[displayName]
            ...    ${pt_employee}[username]    ${filter_2}[associate_type]
            Verify Filtered Associate Data Is Not Displayed On Roster Page On Web
            ...    ${self_user}[displayName]
            ...    ${self_user}[username]    ${filter_1}[associate_type]
            Log    Step 6: Direct Reportees filter verified successfully    level=INFO
        ELSE
            Log    Step 6: Skipping Direct Reportees filter - Direct option not available in this environment    level=WARN
        END
        IF    ${reportee_info}[indirect]
            Reset All Filters On Roster Page On Web
            Apply Filter With Associate Criteria On Roster Page On Web
            ...    ${filter_6}[associate_id]
            ...    ${filter_6}[associate_type]
            ...    ${filter_6}[status]
            ...    ${filter_6}[reportee_type]
            Verify Filtered Associate Data Is Displayed On Roster Page On Web
            ...    ${ft_employee}[displayName]    ${ft_employee}[username]
            ...    ${filter_1}[associate_type]
            Verify Filtered Associate Data Is Displayed On Roster Page On Web
            ...    ${pt_employee}[displayName]    ${pt_employee}[username]
            ...    ${filter_2}[associate_type]
            Verify Filtered Associate Data Is Not Displayed On Roster Page On Web
            ...    ${self_user}[displayName]
            ...    ${self_user}[username]    ${filter_1}[associate_type]
            Log    Step 7: Indirect Reportees filter verified successfully    level=INFO
        ELSE
            Log    Step 7: Skipping Indirect Reportees filter - Indirect option not available in this environment    level=WARN
        END
        IF    ${reportee_info}[my_location]
            Reset All Filters On Roster Page On Web
            Apply Filter With Associate Criteria On Roster Page On Web
            ...    ${filter_7}[associate_id]
            ...    ${filter_7}[associate_type]    ${filter_7}[status]
            ...    ${filter_7}[reportee_type]
            Verify Filtered Associate Data Is Displayed On Roster Page On Web
            ...    ${ft_employee}[displayName]
            ...    ${ft_employee}[username]    ${filter_1}[associate_type]
            Verify Filtered Associate Data Is Displayed On Roster Page On Web
            ...    ${pt_employee}[displayName]
            ...    ${pt_employee}[username]    ${filter_2}[associate_type]
            Verify Filtered Associate Data Is Displayed On Roster Page On Web
            ...    ${self_user}[displayName]
            ...    ${self_user}[username]    ${filter_1}[associate_type]
            Log    Step 8: My Location filter verified successfully    level=INFO
        ELSE
            Log    Step 8: Skipping My Location filter - My Location option not available in this environment    level=WARN
        END
    ELSE
        Log    Steps 6-8: Skipping all reportee filters - Reportee filter not available (PC00067 not enabled)    level=WARN
    END
    Reset All Filters On Roster Page On Web
