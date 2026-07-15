*** Settings ***
Documentation       Resource file containing keywords for ESS Leave Balance page.

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/ess/leave_balance_page.py


*** Keywords ***
Navigate To ESS Leave Balance Page On Web
    [Documentation]    Navigate To ESS -> Leave Balance Page
    ...    and verifies leave balance heading at the top of the page
    Navigate To Specific Page On Web    ess    leave_balance
    Wait Until Element Is Visible On Webpage    ${LEAVE_BALANCE_PAGE_HEADING}

Get Accrual Balance For Specific Balance Type On Leave Balance Page On Web
    [Documentation]    Retrieves the leave balance value for a specific reason.
    ...    | =Arguments= | =Description= |
    ...    | reason_code | The reason for which to fetch the balance (e.g. Vacation). |
    ...    | =Returns= | =Description= |
    ...    | balance | The numeric balance value. |
    [Arguments]    ${reason_code}
    ${balance_locator}    Update Locator With Dynamic Values    ${LEAVE_BALANCE_PAGE_BALANCE_VALUE}
    ...    REASON=${reason_code}
    Wait Until Element Is Visible On Webpage    ${balance_locator}
    ${balance_text}    Get Element Text On Webpage    ${balance_locator}
    RETURN    ${balance_text}
