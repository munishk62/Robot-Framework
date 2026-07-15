*** Settings ***
Documentation       Resource file for Timecard Warnings Page

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Variables           resources/Mobile/ESS/Locators/TimeCard.py


*** Keywords ***
Select Warnings Tab On Mobile ESS
    [Documentation]    Used for selecting the Warnings tab on the mobile ESS app.
    ${tab_locator}    Get Localised Locator Contains    ${timeCardWarningsTab}
    Wait Until Element Is Visible    ${tab_locator}
    Click Element    ${tab_locator}

Tap First Warning Item Found For Given Criteria On Mobile ESS
    [Documentation]    Used for tapping on the first warning item for the mentioned criteria in the warnings tab on mobile ESS app.
    ...    Args:
    ...    ${timecard_warning_description}: <Description of the warning>
    ...    ${timecard_warning_status}: <Status of the warning>
    [Arguments]    ${timecard_warning_description}    ${timecard_warning_status}
    VAR    ${warning_list_item}    ${timecard_warning_description}, ${timecard_warning_status}
    ${warning_list_item_locator}    Get Locator Contains    ${warning_list_item}
    Wait Until Element Is Visible    ${warning_list_item_locator}
    Click Element    ${warning_list_item_locator}

Verify Timecard Warning Details On Mobile ESS
    [Documentation]    Verifies the warning list item.
    ...    Args:
    ...    ${timecard_warning_details_warning_date}: <Date of the warning event>
    ...    ${timecard_warning_details_warning_time}: <Time of the warning event>
    ...    ${timecard_warning_description}: <Description of the warning>
    [Arguments]    ${timecard_warning_description}    ${timecard_warning_details_warning_date}    ${timecard_warning_details_warning_time}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${formattedWarningDate}    Calculate Date From Week Day Offset    ${timecard_warning_details_warning_date}    ${date_format}
    ${formattedWarningTime}    Format Time String    ${timecard_warning_details_warning_time}
    ${warning_description_locator}    Get Locator Contains    ${timecard_warning_description}
    Wait Until Element Is Visible    ${warning_description_locator}
    VAR    ${warning_date_time}    ${formattedWarningDate} ${formattedWarningTime}
    ${warning_date_time_locator}    Get Locator Contains    ${warning_date_time}
    Wait Until Element Is Visible    ${warning_date_time_locator}
    Navigate Back On Mobile ESS
