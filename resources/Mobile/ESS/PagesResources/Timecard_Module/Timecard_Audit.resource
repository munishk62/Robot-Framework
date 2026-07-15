*** Settings ***
Documentation       Resource file for Timecard Audit Page

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Variables           resources/Mobile/ESS/Locators/TimeCard.py


*** Keywords ***
Select Audit Tab On Mobile ESS
    [Documentation]    Used for selecting the Audit tab in the NextGen ESS app
    ${tab_locator}    Get Localised Locator Contains    ${timecardTabsTitleAudit}
    Wait Until Element Is Visible    ${tab_locator}
    Click Element    ${tab_locator}

Verify Audit List Item On Mobile ESS
    [Documentation]    Used for verifying audit list item details on mobile ESS app.
    ...    Args:
    ...    ${AUDIT_CHANGE_LOG_TYPE}: Type of the audit change log
    ...    ${AUDIT_ACTION}: Action performed in the audit change log
    ...    ${AUDIT_TIME}: Time for which action performed
    ...    ${AUDIT_USERNAME}: User who performed the action
    [Arguments]     ${AUDIT_CHANGE_LOG_TYPE}    ${AUDIT_ACTION}    ${AUDIT_TIME}    ${AUDIT_USERNAME}
    ${formatted_time}    Format Time String     ${AUDIT_TIME}
    VAR    ${concatenatedAuditListDetail}    ${AUDIT_CHANGE_LOG_TYPE}, ${AUDIT_ACTION}, ${formatted_time}, ${AUDIT_USERNAME}
    # Punch, Added, 01:00 common.label.pm_string, ZAUTOSTORE001, Mar 11, 2026, Not Reviewed common.semantics.list.suffix
    ${locator}    Get Locator Contains    ${concatenatedAuditListDetail}
    Swipe Until Visible    ${locator}
