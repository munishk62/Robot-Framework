*** Settings ***
Documentation       Tests to verify Exception Details Are Displayed Properly On Screen functionality on RTA.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/exception_management.resource
Variables           resources/web/common/timeout_variables.py

Test Teardown       Close Browser

Test Tags           action:write    config:rta    battc00068    dev:azar    obsolete


*** Test Cases ***
RTA-54-1 Verify Whether Exception Details Are Displayed Properly On Screen
    [Documentation]    Verifies that exception and violation counts are correctly updated when punch data
    ...    is added to and removed from the timecard.
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${store_data}    Get Store Data
    ${store_profile}    Get System Value    UserProfiles    STORE_ADMIN
    Check And Switch To Store With Profile    ${store_data}[store_name]    ${store_profile}
    Navigate To RTA Operations Exception Management Page On Web
    Shift To Previous Week Exception Management Page On Web
    Wait Until Page Is Loaded
    ${original_violation_count}    Get Violation Count Of First Employee On Exception Management Page On Web
    ${original_exceptions_count}    Get Total Number Of Exceptions Shown In Exception Management Page On Web
    Capture Screenshot On Webpage
    Click On Clock Icon Of First Employee On Exception Management Page On Web
    Verify Timecard Page Is Loaded On Web
    ${punch_data}    Get Timecard Punch Data
    ${punch_added_date}    ${formatted_start_time}    Add Punch Where No Actual Is Present On Web
    ...    transaction_type=${punch_data}[transaction_type]    time=${punch_data}[punch_time]    reason_code=${punch_data}[reason_code]
    IF    '${punch_added_date}'
        Verify Timecard Success Toast Notification On Web
        Verify Punch Visible In Timecard Page On Web    transaction_type=${punch_data}[transaction_type]
        ...    date=${punch_added_date}    time=${formatted_start_time}
        Capture Screenshot On Webpage
        ${warning_icon_count}    Get Warning Icon Count Of Punch Data In Timecard On Web
        ...    ${punch_added_date}    ${formatted_start_time}
        ${expected_exceptions_count}    Evaluate    ${original_exceptions_count} + ${warning_icon_count} + 1
        ${expected_violation_count}    Evaluate    ${original_violation_count}+1
        Navigate To RTA Operations Exception Management Page On Web
        Shift To Previous Week Exception Management Page On Web
        Wait Until Page Is Loaded
        ${actual_violation_count}    Get Violation Count Of First Employee On Exception Management Page On Web
        Should Be Equal    ${expected_violation_count}    ${actual_violation_count}
        ...    msg=Violation count should increase after adding punch
        ${actual_exceptions_count}    Get Total Number Of Exceptions Shown In Exception Management Page On Web
        Should Be Equal    ${expected_exceptions_count}    ${actual_exceptions_count}
        ...    msg=Exception count should increase after adding punch
        Capture Screenshot On Webpage
        Click On Clock Icon Of First Employee On Exception Management Page On Web
        Verify Timecard Page Is Loaded On Web
        Delete Actual Punch Of Given Transaction Type On Web    ${punch_data}[transaction_type]
        ...    ${punch_added_date}    ${formatted_start_time}    ${punch_data}[reason_code]
        Verify Timecard Success Toast Notification On Web
        Capture Screenshot On Webpage
        Navigate To RTA Operations Exception Management Page On Web
        Shift To Previous Week Exception Management Page On Web
        Wait Until Page Is Loaded
        ${final_violation_count}    Get Violation Count Of First Employee On Exception Management Page On Web
        Should Be Equal    ${original_violation_count}    ${final_violation_count}
        ...    msg=Violation count should return to original after deleting punch
        ${final_exceptions_count}    Get Total Number Of Exceptions Shown In Exception Management Page On Web
        Should Be Equal    ${original_exceptions_count}    ${final_exceptions_count}
        ...    msg=Exception count should return to original after deleting punch
        Capture Screenshot On Webpage
    END
