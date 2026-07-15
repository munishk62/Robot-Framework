*** Settings ***
Documentation       WFM Mobility SIT Suite: This suite serves as the main entry point for all mobile-related SIT tests. It includes common setup and teardown processes, as well as shared resources and libraries that are used across multiple mobile test suites.

Resource            resources/Mobile/Common/CSV_File_Util.resource

Suite Setup         SIT Main Suite Setup
Suite Teardown      SIT Main Teardown


*** Keywords ***
SIT Main Suite Setup
    [Documentation]    SIT main suite setup: initializes common resources for SIT tests.
    Init Mobility Common Resources
    # Setting this variable to True will enable the logic to calculate the planning week base date in the SIT tests. This is necessary for the tests that involve scheduling and planning features, ensuring that the base date is correctly determined based on config.json
    VAR    ${PLANNING_WEEK_ENABLED}    ${True}    scope=GLOBAL
    Log To Console    ✅ SIT Main Suite Setup Complete: Common resources initialized and ready for SIT tests.

SIT Main Teardown
    [Documentation]    SIT main suite teardown: performs any necessary cleanup after all SIT tests have run.
    Run Keyword And Ignore Error    Close Application
    Log To Console    ✅ SIT Main Suite Teardown Complete: Main suite teardown finished.
