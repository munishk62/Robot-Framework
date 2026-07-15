*** Settings ***
Documentation       Test to verify environment-specific locator functionality

Variables           resources/web/rws/schedule/all_schedules_page.py

Test Tags           locator_test


*** Test Cases ***
Test Locator Variable Loading
    [Documentation]    Test that locator variables are properly loaded from page files

    # These should be loaded from the page file via the locator manager
    Log    ${ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX}
    Log    ${ALLSCHEDULESPAGE_PUBLISHED_SCHEDULE_LOCATOR}
    Should Not Be Empty    ${ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX}
    Should Not Be Empty    ${ALLSCHEDULESPAGE_PUBLISHED_SCHEDULE_LOCATOR}
    Should Not Be Empty    ${ALLSCHEDULESPAGE_UNPUBLISHED_SCHEDULE_LOCATOR}
    Should Not Be Empty    ${ALLSCHEDULESPAGE_UNSCHEDULED_LOCATOR}

    # Static locators should also be available
    Should Not Be Empty    ${ALLSCHEDULESPAGE_WEEK_AVAILABILITY_INFO_ROW}
    Should Not Be Empty    ${ALLSCHEDULESPAGE_DATED_UNSCHEDULED_WEEK}
