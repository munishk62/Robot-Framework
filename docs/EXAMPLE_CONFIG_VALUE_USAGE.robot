*** Settings ***
Documentation       Example showing how to use config:KEY:VALUE tags and config_or: for OR logic
# This is just an example file - you can delete it after understanding the pattern


*** Test Cases ***
Example Test That Runs Only When USE_LEAVE_HRS_IN_TA is N
    [Documentation]    This test will EXECUTE when USE_LEAVE_HRS_IN_TA=N and SKIP when USE_LEAVE_HRS_IN_TA=Y
    [Tags]    config:use_leave_hrs_in_ta:n
    Log    This test is running because USE_LEAVE_HRS_IN_TA is set to N in config.json

Example Test That Runs Only When USE_LEAVE_HRS_IN_TA is Y
    [Documentation]    This test will EXECUTE when USE_LEAVE_HRS_IN_TA=Y and SKIP when USE_LEAVE_HRS_IN_TA=N
    [Tags]    config:use_leave_hrs_in_ta:y
    Log    This test is running because USE_LEAVE_HRS_IN_TA is set to Y in config.json

Example Test With OR Condition - Runs If Either Config Is Enabled
    [Documentation]    This test requires EITHER direct_login OR mywork to be enabled
    ...    If EITHER one is enabled, the test runs
    ...    Only skips if BOTH are disabled
    [Tags]    config_or:direct_login    config_or:mywork
    Log    This test runs when EITHER direct_login OR mywork is enabled

Example Test With OR Condition Using Values
    [Documentation]    This test runs if USE_LEAVE_HRS_IN_TA is Y OR MYWORK is true
    ...    Only skips if USE_LEAVE_HRS_IN_TA is not Y AND MYWORK is not true
    [Tags]    config_or:use_leave_hrs_in_ta:y    config_or:mywork:true
    Log    This test runs when USE_LEAVE_HRS_IN_TA=Y OR MYWORK=true

Example Test Combining AND and OR Logic
    [Documentation]    This test requires:
    ...    1. rta must be enabled (AND condition)
    ...    2. EITHER direct_login OR mywork must be enabled (OR condition)
    ...    Runs only if: rta is enabled AND (direct_login OR mywork)
    [Tags]    config:rta    config_or:direct_login    config_or:mywork
    Log    This test runs when rta is enabled AND (direct_login OR mywork)

Example For Your Use Case - Direct Login Test
    [Documentation]    Apply this to your wfm_1_1_user_login.robot test
    ...    This shows how to run test if EITHER direct_login is enabled OR DIRECT_LOGIN value is True
    [Tags]    config_or:direct_login    config_or:direct_login:true
    Log    This runs if direct_login config exists OR DIRECT_LOGIN=True

Example Complex OR Condition
    [Documentation]    Test runs if ANY of these conditions match:
    ...    - USE_LEAVE_HRS_IN_TA equals N
    ...    - USE_LEAVE_HRS_IN_TA equals Y
    ...    - rta is enabled
    ...    Basically runs on any environment with rta OR if USE_LEAVE_HRS_IN_TA has any value
    [Tags]    config_or:use_leave_hrs_in_ta:n    config_or:use_leave_hrs_in_ta:y    config_or:rta
    Log    This test runs if ANY condition matches
