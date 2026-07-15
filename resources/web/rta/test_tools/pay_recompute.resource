*** Settings ***
Documentation       Pay Recompute page keywords implementation

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/web/authentication/login.resource
Variables           resources/web/rta/test_tools/pay_recompute_page.py


*** Keywords ***
Navigate To RTA Test Tools Pay Recompute Page On Web
    [Documentation]    Navigate To RTA -> Test Tools -> Pay Recompute Page
    ...    and verifies pay recompute heading at the top of the page
    Navigate To Specific Page On Web    rta    test_tools    pay_recompute
    Wait Until Page Is Loaded

Select Store From Dropdown On Pay Recompute Page On Web
    [Documentation]    This keyword selects store from dropdown on Pay Recompute page
    [Arguments]    ${store_name}
    Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_STORE_DROPDOWN}
    ...    error_message=Store dropdown not found on Pay Recompute page within timeout.
    Select List Item On Webpage    ${PAY_RECOMPUTE_PAGE_STORE_DROPDOWN}    text    ${store_name}

Get Required Store Name From Dropdown On Pay Recompute Page On Web
    [Documentation]    This keyword gets required store from dropdown on Pay Recompute page
    [Arguments]    ${index}
    Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_STORE_DROPDOWN}
    ...    error_message=Store dropdown not found on Pay Recompute page within timeout.
    @{store_list}    Get All Options From Dropdown On Web    ${PAY_RECOMPUTE_PAGE_STORE_DROPDOWN}
    ${store_name}    Get From List    ${store_list}    ${index}
    ${store}    Get From Dictionary    ${store_name}    label
    RETURN    ${store}

Select Week In Start Week Dropdown On Pay Recompute Page On Web
    [Documentation]    This keyword selects week in start week dropdown on Pay Recompute page
    [Arguments]    ${start_week_date}
    Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_START_WEEK_DROPDOWN}
    ...    error_message=Start week dropdown not found on Pay Recompute page within timeout.
    Select List Item On Webpage    ${PAY_RECOMPUTE_PAGE_START_WEEK_DROPDOWN}    value    ${start_week_date}

Select Week In End Week Dropdown On Pay Recompute Page On Web
    [Documentation]    This keyword selects week in end week dropdown on Pay Recompute page
    [Arguments]    ${end_week_date}
    Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_END_WEEK_DROPDOWN}
    ...    error_message=End week dropdown not found on Pay Recompute page within timeout.
    Select List Item On Webpage    ${PAY_RECOMPUTE_PAGE_END_WEEK_DROPDOWN}    value    ${end_week_date}

Select Mode Option On Pay Recompute Page On Web
    [Documentation]    This keyword selects mode option on Pay Recompute page
    [Arguments]    ${mode_option}
    IF    '${mode_option}' == 'UNRELEASED_TIMECARD'
        Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_MODE_UNRELEASED_TIMECARD}
        Click Element On Webpage    ${PAY_RECOMPUTE_PAGE_MODE_UNRELEASED_TIMECARD}
        ...    error_message='Unreleased Timecard' mode option not found on Pay Recompute page.
    ELSE IF    '${mode_option}' == 'RELEASED_UNRELEASED_TIMECARD'
        Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_MODE_RELEASED_AND_UNRELEASED_TIMECARD}
        Click Element On Webpage    ${PAY_RECOMPUTE_PAGE_MODE_RELEASED_AND_UNRELEASED_TIMECARD}
        ...    error_message='Released and Unreleased Timecard' mode option not found on Pay Recompute page.
    END

Select Action Option On Pay Recompute Page On Web
    [Documentation]    This keyword selects action option on Pay Recompute page
    [Arguments]    ${action_option}
    Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_ACTION_RECOMPUTE_PAY}
    ...    error_message=Radio button for 'Recompute Pay' action option not found on Pay Recompute page within timeout.
    IF    '${action_option}' == 'RECOMPUTE_PAY'
        Click Element On Webpage    ${PAY_RECOMPUTE_PAGE_ACTION_RECOMPUTE_PAY}
        ...    error_message='Recompute Pay' action option not found on Pay Recompute page.
    ELSE IF    '${action_option}' == 'RESAVE_TIMECARD'
        Click Element On Webpage    ${PAY_RECOMPUTE_PAGE_ACTION_RESAVE_TIMECARD}
        ...    error_message='Resave Timecard' action option not found on Pay Recompute page.
    END

Click On Submit Button On Pay Recompute Page On Web
    [Documentation]    This keyword clicks on submit button on Pay Recompute page
    Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_SUBMIT_BUTTON}
    ...    error_message=Submit button not found on Pay Recompute page within timeout.
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${PAY_RECOMPUTE_PAGE_SUBMIT_BUTTON}
    ...    error_message=Submit button not clickable on Pay Recompute page.
    Run Keyword And Ignore Error    Wait For    ${promise}
    # Log    Alert text received: ${alert_text}    INFO
    Run Keyword And Ignore Error    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    Capture Screenshot On Webpage

Verify Batch Job Message Displayed On Pay Recompute Page On Web
    [Documentation]    This keyword verifies batch job message displayed on Pay Recompute page
    Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_SUCCESS_MESSAGE}    timeout=${MEDIUM_TIMEOUT}
    ...    error_message=Success message did not appear on Pay Recompute page within timeout.

Recompute For Given Store & Week On Pay Recompute Page On Web
    [Documentation]    This keyword recomputes pay for given store and week on Pay Recompute page
    [Arguments]    ${store_name}    ${start_week_start_date}    ${end_week_start_date}    ${mode_option}    ${action_option}
    Wait Until Element Is Visible On Webpage    ${PAY_RECOMPUTE_PAGE_SPECIFIC_STORE_RADIO_BTN}
    ...    error_message='Specific Store' radio button not found on Pay Recompute page within timeout.
    Click Element On Webpage    ${PAY_RECOMPUTE_PAGE_SPECIFIC_STORE_RADIO_BTN}
    ...    error_message='Specific Store' radio button not clickable on Pay Recompute page.
    Wait Until Page Is Loaded
    Select Store From Dropdown On Pay Recompute Page On Web    ${store_name}
    Sleep    5s
    Select Week In Start Week Dropdown On Pay Recompute Page On Web    ${start_week_start_date}
    Select Week In End Week Dropdown On Pay Recompute Page On Web    ${end_week_start_date}
    Select Mode Option On Pay Recompute Page On Web    ${mode_option}
    Select Action Option On Pay Recompute Page On Web    ${action_option}
    Click On Submit Button On Pay Recompute Page On Web
    Capture Screenshot On Webpage
