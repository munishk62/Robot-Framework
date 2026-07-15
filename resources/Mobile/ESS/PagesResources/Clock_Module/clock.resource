*** Settings ***
Documentation       Clock module resources

Library             test_data/TestDataLibrary.py
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Variables           resources/Mobile/ESS/Locators/Clock.py


*** Keywords ***
Navigate To Clock Module On Mobile ESS
    [Documentation]    Navigates mobile ESS to the clock module.
    Navigate Mobile ESS To Module    ${ClockButtonLabel}
    ${clock_title_locator}    Get Localised Locator Contains    ${ClockButtonLabel}
    Wait Until Element Is Visible    ${clock_title_locator}    error="Clock module is not opened."

Verify Device In Store For Mobile ESS
    [Documentation]    Verifies user is within his home store
    [Arguments]    ${unit_name}
    ${storeIdLocator}    Get Locator Contains    ${unit_name}
    Wait Until Element Is Visible
    ...    ${storeIdLocator}
    ...    error="Device is not within store check latitude and longitude are configured for the selected store. Device location and store location are the same (Lookup: #PC00117)"

Clock In On Mobile ESS
    [Documentation]    Performs clock in transaction on UI.
    ...    Args:
    ...    ${activity_code}: <activity code>
    ...    ${questionnaire}: <questionnaire>
    ...    Example:
    ...    - Clock In On Mobile ESS    1234    1,2,3,4
    [Arguments]    ${activity_code}=''    ${questionnaire}=''
    ${readyForYourBreakLocator}    Get Localised Locator Contains    ${ready_for_your_break}
    Perform Transaction On Mobile ESS    ${clock_in}    ${activity_code}    ${questionnaire}
    Wait Until Element Is Visible    ${readyForYourBreakLocator}

Clock Out On Mobile ESS
    [Documentation]    Clock Out on mobile ESS.
    ...    Args:
    ...    ${questionnaire}: <questionnaire>
    ...    Example:
    ...    - Clock Out On Mobile ESS    1,2,3,4
    [Arguments]    ${questionnaire}=''
    ${clockedOutLocator}    Get Localised Locator Contains    ${clocked_out}
    ${dismissButtonLocator}    Get Localised Locator Contains    ${dismiss_button}
    ${transactionLocator}    Get Localised Locator Contains    ${clock_in}
    Perform Transaction On Mobile ESS    ${clock_out}    questionnaire=${questionnaire}
    Wait Until Element Is Visible    ${clockedOutLocator}
    Click Element    ${dismissButtonLocator}
    Wait Until Element Is Visible    ${transactionLocator}

Meal End On Mobile ESS
    [Documentation]    Performs meal end transaction on UI.
    ...    Args:
    ...    ${activity_code}: <activity code>
    ...    ${questionnaire}: <questionnaire>
    ...    Example:
    ...    - Meal End On Mobile ESS    1234    1,2,3,4
    [Arguments]    ${activity_code}=''    ${questionnaire}=''
    ${readyForYourBreakLocator}    Get Localised Locator Contains    ${ready_for_your_break}
    Perform Transaction On Mobile ESS    ${end_meal}    ${activity_code}    ${questionnaire}
    Wait Until Element Is Visible    ${readyForYourBreakLocator}

Perform Transaction On Mobile ESS
    [Documentation]    Perform Transaction On Mobile ESS app.
    ...    Args:
    ...    ${transaction}: <start date for request>
    ...    ${activity_code}: <activity code>
    ...    ${questionnaire}: <questionnaire>
    ...    Example:
    ...    - Perform Transaction On Mobile ESS    Clock in    1234    1,2,3,4
    [Arguments]    ${transaction}    ${activity_code}=''    ${questionnaire}=''
    ${transactionLocator}    Get Localised Locator Contains    ${transaction}
    Wait Until Element Is Visible    ${transactionLocator}
    Click Element    ${transactionLocator}
    ${selectActivity}    Evaluate    "${activity_code}" != "''"
    ${activityCodeReq}    Get Config Value    key=ACTIVITY_CODE_REQUIRED
    ${sendActivityToClock}    Get Config Value    key=SEND_ACTIVITY_TO_CLOCK
    IF    ${selectActivity} and ${sendActivityToClock}
        Select Mobile Activity Code For Transaction On Mobile ESS    ${activity_code}
    ELSE IF    "${activityCodeReq}" != "True" and ${sendActivityToClock} and "${transaction}" != "${clock_out}"
        ${applyButtonLocator}    Get Localised Locator Contains    ${apply_button}
        Wait Until Element Is Visible    ${applyButtonLocator}
        Click Element    ${applyButtonLocator}
    END
    IF    "${questionnaire}" != "''"
        Submit Clock Questionnaire On Mobile ESS    ${questionnaire}
    END

Select Mobile Activity Code For Transaction On Mobile ESS
    [Documentation]    Select Activity Code on mobile ESS app.
    ...    Args:
    ...    ${activity_code}: <activity code>
    ...    Example:
    ...    - Select Mobile Activity Code For Transaction On Mobile ESS    1234
    [Arguments]    ${activity_code}
    ${activityCodeLocator}    Get Locator Contains    ${activity_code}
    ${applyButtonLocator}    Get Localised Locator Contains    ${apply_button}
    Wait Until Element Is Visible    ${activityCodeLocator}
    Click Element    ${activityCodeLocator}
    Wait Until Element Is Visible    ${applyButtonLocator}
    Click Element    ${applyButtonLocator}

Submit Clock Questionnaire On Mobile ESS
    [Documentation]    Submit Mobile ESS Clock Questionnaire
    ...    Args:
    ...    ${questionnaire}: <questionnaire>
    ...    Example:
    ...    - Submit Clock Questionnaire On Mobile ESS    1,2,2,1
    [Arguments]    ${questionnaire}
    ${clockOverrideSubmitButtonLocator}    Get Localised Locator Contains    ${clock_override_submit_button}
    @{answers}    Evaluate    "${questionnaire}".split(',')
    FOR    ${index}    ${answer}    IN ENUMERATE    @{answers}
        ${questionNumber}    Evaluate    ${index}+1
        Answer Clock Questionnaire Question On Mobile ESS    ${questionNumber}    ${answer}
    END
    Click Element    ${clockOverrideSubmitButtonLocator}

Answer Clock Questionnaire Question On Mobile ESS
    [Documentation]    Answer Mobile ESS Clock Questionnaire Question
    ...    Args:
    ...    ${question}: <question index>
    ...    ${answer}: <answer>
    ...    Example:
    ...    - Answer Clock Questionnaire Question On Mobile ESS    1    1
    [Arguments]    ${question}    ${answer}
    ${clockAnswerLocator}    Get Localised Locator Contains
    ...    ${clock_questionnaire_answer}
    ...    ${question}
    ...    ${answer}
    ...    ''
    Swipe Until Visible    ${clockAnswerLocator}    maxSwipes=1
    Click Element    ${clockAnswerLocator}

Take Break On Mobile ESS
    [Documentation]    Starts take break by tapping.
    ...    Args:
    ...    ${questionnaire}: <questionnaire>
    [Arguments]    ${questionnaire}=''
    Perform Transaction On Mobile ESS    ${take_break}    questionnaire=${questionnaire}
    ${readyToClockOutLocator}    Get Localised Locator Contains    ${ready_to_clock_out}
    Wait Until Element Is Visible    ${readyToClockOutLocator}

Take Meal On Mobile ESS
    [Documentation]    Starts take meal by tapping.
    ...    Args:
    ...    ${user_display_name}: users display name
    [Arguments]    ${user_display_name}
    Perform Transaction On Mobile ESS    ${take_meal}
    ${enjoy_meal_locator}    Get Localised Locator Contains    ${enjoy_meal}    ${user_display_name}
    Wait Until Element Is Visible    ${enjoy_meal_locator}

Tap For Clock Out On Mobile ESS
    [Documentation]    Clock out by tapping (waits for ready-to-clock-out state).
    ...    Args:
    ...    ${questionnaire}: <questionnaire>
    [Arguments]    ${questionnaire}=''
    Perform Transaction On Mobile ESS    ${clock_out}    questionnaire=${questionnaire}
    ${readyToClockOutLocator}    Get Localised Locator Contains    ${ready_to_clock_out}
    Wait Until Element Is Visible    ${readyToClockOutLocator}

View Clock Punch Card On Mobile ESS
    [Documentation]    View Clock Punch Card For Mobile ESS
    Tap Clock Menu Options On Mobile ESS
    ${clockPunchCardLocator}    Get Localised Locator Contains    ${clock_view_punch_card_option}
    Click Element    ${clockPunchCardLocator}

Tap Clock Menu Options On Mobile ESS
    [Documentation]    Tap Mobile ESS Native Clock Menu Options on mobile ESS app.
    ${clockMoreOptionLocator}    Get Localised Locator Contains    ${clock_menu_option}
    Click Element    ${clockMoreOptionLocator}

Tap Clock More Options On Mobile ESS
    [Documentation]    Tap Mobile ESS Native Clock More Options on mobile ESS app.
    ${clockMoreOptionLocator}    Get Localised Locator Contains    ${clock_more_option}
    Click Element    ${clockMoreOptionLocator}

Verify Clock In Transaction Time In Punch Card On Mobile ESS
    [Documentation]
    ...    Verifies clock-in transaction type is present on the ESS punch card.
    ...    Example usage:
    ...    | Verify Clock In Transaction Time In Punch Card On Mobile ESS |
    Verify Clock Punch Card Detail For Punch On Mobile ESS    ${clock_in}

Verify Take Break Transaction Time In Punch Card On Mobile ESS
    [Documentation]
    ...    Verifies take-break transaction type is present on the ESS punch card.
    ...    Example usage:
    ...    | Verify Take Break Transaction Time In Punch Card On Mobile ESS |
    Verify Clock Punch Card Detail For Punch On Mobile ESS    ${take_break}

Verify Break End Transaction Time In Punch Card On Mobile ESS
    [Documentation]
    ...    Verifies break-end transaction type is present on the ESS punch card.
    ...    Example usage:
    ...    | Verify Break End Transaction Time In Punch Card On Mobile ESS |
    Verify Clock Punch Card Detail For Punch On Mobile ESS    ${end_break}

Verify Take Meal Transaction Time In Punch Card On Mobile ESS
    [Documentation]
    ...    Verifies take-meal transaction type is present on the ESS punch card.
    ...    Example usage:
    ...    | Verify Take Meal Transaction Time In Punch Card On Mobile ESS |
    Verify Clock Punch Card Detail For Punch On Mobile ESS    ${meal_start}

Verify Meal End Transaction Time In Punch Card On Mobile ESS
    [Documentation]
    ...    Verifies meal-end transaction type is present on the ESS punch card.
    ...    Example usage:
    ...    | Verify Meal End Transaction Time In Punch Card On Mobile ESS |
    Verify Clock Punch Card Detail For Punch On Mobile ESS    ${end_meal}

Verify Clock Out Transaction Time In Punch Card On Mobile ESS
    [Documentation]
    ...    Verifies clock-out transaction type is present on the ESS punch card.
    ...    Example usage:
    ...    | Verify Clock Out Transaction Time In Punch Card On Mobile ESS |
    Verify Clock Punch Card Detail For Punch On Mobile ESS    ${clock_out}

Verify Clock Punch Card Detail For Punch On Mobile ESS
    [Documentation]
    ...    Verifies the punch card page contains the localized transaction type label.
    ...    | =Arguments= | =Description= |
    ...    | transaction_type | Localization key from ``Clock.py`` (for example ``timeclock.label.clock_in``). |
    ...    Example usage:
    ...    | Verify Clock Punch Card Detail For Punch On Mobile ESS | ${clock_in} |
    [Arguments]    ${transaction_type}
    ${transaction_localised}    Get Localised Message From Key    ${transaction_type}
    ${transaction_type_locator}    Get Locator Contains    ${transaction_localised}
    Wait Until Page Contains Element    ${transaction_type_locator}
