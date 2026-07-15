*** Settings ***
Documentation       Resource file for Pay Results Page

Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Utility.resource
Variables           resources/Mobile/ESS/Locators/TimeCard.py


*** Keywords ***
Select Pay Results Tab On Mobile ESS
    [Documentation]    Used for selecting the Pay Results tab on mobile ESS app
    ...    Args:
    ...    ${max_swipes}: <maximum number of swipes to find the pay results tab>
    [Arguments]    ${max_swipes}=3
    ${pay_results_tab_locator}    Get Localised Locator Contains    ${timecard_tabs_title_pay_results}
    ${audit_tab_locator}    Get Localised Locator Contains    ${timecard_tabs_title_audit}
    ${is_pay_results_tab_visible}    Run Keyword And Return Status    Page Should Contain Element    ${pay_results_tab_locator}
    IF    ${is_pay_results_tab_visible}
        Click Element    ${pay_results_tab_locator}
        RETURN
    END
    Wait Until Page Contains Element    ${audit_tab_locator}
    Click Element    ${audit_tab_locator}
    FOR    ${_}    IN RANGE    ${max_swipes}
        ${is_pay_results_tab_visible}    Run Keyword And Return Status    Page Should Contain Element    ${pay_results_tab_locator}
        IF    ${is_pay_results_tab_visible}    BREAK
        Swipe Right On Element    ${audit_tab_locator}
    END
    IF    not ${is_pay_results_tab_visible}
        Capture Page Screenshot
        Fail    Pay Results tab not found after swiping ${max_swipes} times.
    ELSE
        Click Element    ${pay_results_tab_locator}
    END

Verify Shift Timings On Mobile ESS
    [Documentation]    Used for verifying the shift timings in pay results tab on mobile ESS app.
    ...    Args:
    ...    ${shift_date}: The date of the shift for which pay results are being verified.
    ...    ${shift_start_time}: The time when the shift starts.
    ...    ${shift_end_time}: The time when the shift ends.
    [Arguments]    ${shift_date}    ${shift_start_time}    ${shift_end_time}
    ${day_date_format}    Get Config Value    DAY_DATE_FORMAT
    ${shift_date_formatted}    Calculate Date From Week Day Offset    ${shift_date}    ${day_date_format}
    ${date_label_locator}    Get Locator Contains    ${shift_date_formatted}
    Wait Until Element Is Visible    ${date_label_locator}
    ${formatted_shift_start_time}    Format Time String    ${shift_start_time}
    ${formatted_shift_end_time}      Format Time String    ${shift_end_time}
    ${shift_time_locator}    Get Locator Contains    ${formatted_shift_start_time} - ${formatted_shift_end_time}
    Wait Until Element Is Visible    ${shift_time_locator}
    Log    Successfully verified shift timings: ${formatted_shift_start_time} - ${formatted_shift_end_time} for shift date: ${shift_date_formatted}
