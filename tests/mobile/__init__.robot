*** Settings ***
Documentation       WFM Mobility Main Suite: This suite contains common setup and teardown for all mobile tests, as well as shared resources and libraries.

Resource            resources/Mobile/Common/CSV_File_Util.resource

Suite Setup         Mobile Main Suite Setup
Suite Teardown      Mobile Main Teardown


*** Keywords ***
Mobile Main Suite Setup
    [Documentation]    Mobile main suite setup: initializes common resources for mobile tests.
    Init Mobility Common Resources
    Log To Console    ✅ Mobile Main Suite Setup Complete: Common resources initialized and ready for mobile tests.

Mobile Main Teardown
    [Documentation]    Mobile main suite teardown: performs any necessary cleanup after all mobile tests have run.
    Run Keyword And Ignore Error    Close Application
    Log To Console    ✅ Mobile Main Suite Teardown Complete: Main suite teardown finished.
