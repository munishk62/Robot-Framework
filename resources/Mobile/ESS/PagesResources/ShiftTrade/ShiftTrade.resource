*** Settings ***
Documentation       Resource file for Shift Trade Page

Library             DateTime
Library             String
Resource            resources/Mobile/ESS/PagesResources/Common/Utility.resource
Resource            resources/web/common/common_date_utility.resource
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/Common/MobileKeyboardUtils.resource
Variables           resources/Mobile/ESS/Locators/Request.py
Variables           resources/Mobile/ESS/Locators/ShiftTrade.py
Variables           resources/Mobile/ESS/Locators/Schedule.py


*** Keywords ***
Navigate Mobile ESS To Shift Trade Page
    [Documentation]    Used for navigating to Shift Trade page on mobile ESS app.
    Navigate Mobile ESS To Module    ${ShiftTradeButtonLabel}
    ${element_semantic_path}    Get Localised Locator Contains    ${trade_cover_locator}
    Wait Until Element Is Visible    ${element_semantic_path}

Select Post Tab On Mobile ESS
    [Documentation]    Used for selecting the Post Tab on mobile ESS app.
    Select Shift Trade Tab On Mobile ESS Master    ${trade_post_locator}

Select Cover Tab On Mobile ESS
    [Documentation]    Used for selecting the Cover Tab on mobile ESS app.
    Select Shift Trade Tab On Mobile ESS Master    ${trade_cover_locator}

Select Shift Trade Tab On Mobile ESS Master
    [Documentation]    Used for selecting the Shift Trade tabs on mobile ESS app.
    ...    Arguments:
    ...    - ${tab_semantic}: <Semantic of the tab to be selected>
    [Tags]    robot:private
    [Arguments]    ${tab_semantic}
    ${tab_locator}    Get Localised Locator Contains    ${tab_semantic}
    Wait Until Element Is Visible    ${tab_locator}
    Click Element    ${tab_locator}

Request Give Away Shift On Mobile ESS
    [Documentation]    Used to confirm shift request on mobile ESS app.
    ...    Arguments:
    ...    ${note_text}: <Note to be added>
    [Arguments]    ${note_text}
    Select Give Away Action On Mobile ESS
    Log    skipping add requestor notes(${note_text}) for additional work request as it is not required
    ${common_confirm_semantic_locator}    Get Localised Locator Exact    ${common_Label_Confirm}
    Wait Until Element Is Visible    ${common_confirm_semantic_locator}
    Click Element    ${common_confirm_semantic_locator}
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    Run Keyword And Ignore Error
    ...    Tap Close Toast Message On Mobile ESS

Request Additional Work Shift On Mobile ESS
    [Documentation]    Used to add additional work request on mobile ESS app.
    ...    Arguments:
    ...    ${extra_work_day}: <The specific day on which the extra shift>
    ...    ${extra_work_start_time}: <The start time of the extra shift in 24-hour format>
    ...    ${extra_work_end_time}: <The end time of the extra shift in 24-hour format>
    ...    ${shift_length}: <The total duration of the shift in hours and minutes >
    ...    ${notes}: <Notes for the request.>
    [Arguments]    ${notes}    ${extra_work_day}=NA    ${extra_work_start_time}=NA    ${extra_work_end_time}=NA
    ...    ${shift_length}=NA
    Request For Additional Work On Mobile ESS
    ${trade_title_additional_work_locator}    Get Localised Locator Exact
    ...    ${trade_title_request_additional_work}
    Wait Until Element Is Visible    ${trade_title_additional_work_locator}
    IF    '${extra_work_day}' != "NA"
        Select Additional Work Request Day On Mobile ESS    ${extra_work_day}
    END
    Enter Shift Trade Request Time Of Day On Mobile ESS    ${extra_work_start_time}
    ...    ${extra_work_end_time}
    Enter Additional Work Request Shift Total Duration On Mobile ESS    ${shift_length}
    Log    skipping add requestor notes(${notes}) for additional work request as it is not required
    Tap Submit Button On Mobile ESS
    Run Keyword And Ignore Error
    ...    Tap Close Toast Message On Mobile ESS

Verify Additional Work Requested Displayed On Post List On Mobile ESS
    [Documentation]    Verifies the Additional Work Requested label is displayed for a specific day on mobile ESS app.
    ...    Arguments:
    ...    ${date_for_shift_request}: <date on which shift is requested in week day offset format>
    [Arguments]    ${date_for_shift_request}
    ${month_day}    Get Config Value    MONTH_DAY_FORMAT
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    ${target_date_converted}    Calculate Date From Week Day Offset    ${date_for_shift_request}    ${month_day}
    ${additional_work_label}    Get Localised Message From Key    ${trade_title_additional_work_requested}
    ${shift_day_locator}    Get Message With Arguments    ${schedule_shift_day_card_locator}    ${target_date_converted}
    Swipe Until Visible    ${shift_day_locator}    maxSwipes=20
    ${additional_work_locator}    Get Message With Arguments
    ...    ${schedule_shift_day_additional_work_locator}    ${target_date_converted}    ${additional_work_label}
    Swipe Until Visible    ${additional_work_locator}
    Page Should Contain Element    ${additional_work_locator}

Request For Additional Work On Mobile ESS
    [Documentation]    Used for request additional work on on mobile ESS app.
    ${schedule_additional_work_locator}    Get Localised Locator Exact    ${schedule_additional_work}
    # Swipe Until Visible is used here to ensure the element is brought into view before interacting with it.
    # This method is preferred in scenarios where elements may be off-screen due to scrolling limitations in mobile apps.
    Swipe Until Visible    ${schedule_additional_work_locator}
    Click Element    ${schedule_additional_work_locator}

Select Additional Work Request Day On Mobile ESS
    [Documentation]    Used for selecting the Day on which the extra shift on mobile ESS app.
    ...    Arguments:
    ...    ${extra_work_day}: <The specific day on which the extra shift>
    [Arguments]    ${extra_work_day}
    ${DAY_DF}    Get Config Value    DAY_FORMAT
    ${trade_extra_work_days_title_locator}    Get Localised Locator Contains
    ...    ${trade_extra_work_days_title}
    Wait Until Element Is Visible    ${trade_extra_work_days_title_locator}
    ${extra_work_day_converted}    Calculate Date From Week Day Offset    ${extra_work_day}    ${DAY_DF}
    ${extra_work_day_locator}    Get Locator Contains    ${extra_work_day_converted}
    Swipe Until Visible    ${extra_work_day_locator}
    Click Element    ${extra_work_day_locator}

Request Direct Swap For My Store Shift On Mobile ESS
    [Documentation]    Used to Direct shift request For My Store on mobile ESS app.
    ...    Arguments:
    ...    ${note_text}: <Note to be added>
    ...    ${user}: <Note to be added>
    ...    ${swap_date}: <date on which shift to be Swap>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${note_text}    ${user}    ${swap_date}    ${start_time_24_hr}    ${end_time_24_hr}
    Select Direct Swap Action On Mobile ESS
    Select My Store Tab On Mobile ESS
    Select Associate And Request Direct Swap Shift On Mobile ESS    ${note_text}    ${user}    ${swap_date}    ${start_time_24_hr}    ${end_time_24_hr}

Select Direct Swap Action On Mobile ESS
    [Documentation]    Used for selecting the direct swap action on mobile ESS app
    Select Shift Actions On Mobile ESS    ${schedule_shift_direct_swipe}
    ${trade_label_select_associate_locator}    Get Localised Locator Exact    ${trade_label_select_associate}
    Wait Until Element Is Visible    ${trade_label_select_associate_locator}

Select My Store Tab On Mobile ESS
    [Documentation]    Used for selecting the My Store tab on mobile ESS app.
    Select Shift Trade Tab On Mobile ESS Master    ${trade_label_my_store}

Select Associate And Request Direct Swap Shift On Mobile ESS
    [Documentation]    Used for selecting associate and request direct swap shift on mobile ESS app.
    ...    Arguments:
    ...    ${note_text}: <Note to be added>
    ...    ${user}: <Note to be added>
    ...    ${swap_date}: <date on which shift to be Swap>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${note_text}    ${user}    ${swap_date}    ${start_time_24_hr}    ${end_time_24_hr}
    Select Associate For Swap Shift On Mobile ESS    ${user}
    ${schedule_shift_direct_swipe_locator}    Get Localised Locator Exact    ${schedule_shift_direct_swipe}
    Wait Until Element Is Visible    ${schedule_shift_direct_swipe_locator}
    ${trade_label_select_swap_locator}    Get Localised Locator Exact    ${trade_label_select_swap}
    Wait Until Element Is Visible    ${trade_label_select_swap_locator}
    Select Shift To Swap On The Direct Swap Page On Mobile ESS    ${swap_date}    ${start_time_24_hr}    ${end_time_24_hr}
    Log    skipping add requestor notes(${note_text}) for additional work request as it is not required
    Tap Submit Button On Mobile ESS
    Run Keyword And Ignore Error
    ...    Tap Close Toast Message On Mobile ESS
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}

Select Associate For Swap Shift On Mobile ESS
    [Documentation]    Used for Select Associate for Swap Shift on mobile ESS app.
    ...    Arguments:
    ...    ${user}: <Note to be added>
    [Arguments]    ${user}
    ${user}    Get User    ${user}
    VAR    ${associate_name}    ${user}[displayName]
    ${associate_name_locator}    Get Locator Contains    ${associate_name}
    Swipe Until Visible    ${associate_name_locator}
    Click Element    ${associate_name_locator}

Select Shift To Swap On The Direct Swap Page On Mobile ESS
    [Documentation]    Used to select shift on mobile ESS app.
    ...    Arguments:
    ...    ${swap_date}: <date on which shift to be Swap>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${swap_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${LONG_DAY_MONTH_FORMAT}    Get Config Value    LONG_DAY_MONTH
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    Validate 24 Hour Time Format    ${start_time_24_hr}
    Validate 24 Hour Time Format    ${end_time_24_hr}
    ${start_localised_time}    Format Time String    ${start_time_24_hr}
    ${end_localised_time}    Format Time String    ${end_time_24_hr}
    ${target_date_converted}    Calculate Date From Week Day Offset    ${swap_date}    ${LONG_DAY_MONTH_FORMAT}
    VAR    ${start_end_time_localised}    ${target_date_converted}, ${start_localised_time} - ${end_localised_time}
    # Shift Tuesday, Jan 14 05:15 pm - 09:15 pm 4.0 hr
    ${shift_locator}    Get Locator Contains    ${start_end_time_localised}
    Swipe Until Visible    ${shift_locator}
    Click Element    ${shift_locator}

Enter Shift Trade Request Time Of Day On Mobile ESS
    [Documentation]    Enter Start And End Time of the shift on mobile ESS app.
    ...    Arguments:
    ...    ${work_start_time}: <The start time of the extra shift in 24-hour format>
    ...    ${work_end_time}: <The end time of the extra shift in 24-hour format>
    [Arguments]    ${work_start_time}=NA    ${work_end_time}=NA
    ${trade_extra_work_time_of_day_locator}    Get Localised Locator Exact
    ...    ${trade_extra_work_time_of_day_title}
    Wait Until Element Is Visible    ${trade_extra_work_time_of_day_locator}

    ${hh_mm_text}    Get Localised Message From Key    ${common_hint_time_picker}

    ${after_text}    Get Localised Message From Key    ${trade_label_duration_after}
    ${trade_duration_after_locator}    Get Locator Exact    ${after_text} ${hh_mm_text}

    ${before_text}    Get Localised Message From Key    ${trade_label_duration_before}
    ${trade_duration_before_locator}    Get Locator Exact    ${before_text} ${hh_mm_text}

    Swipe Until Visible    ${trade_duration_after_locator}
    IF    '${work_start_time}' != "NA" and '${work_end_time}' != "NA"
        Swipe Until Visible    ${trade_duration_after_locator}
        Click Element    ${trade_duration_after_locator}
        Select Time On Time Picker    ${work_start_time}
        Select Time On Time Picker    ${work_end_time}
    END
    IF    '${work_start_time}' != "NA" and '${work_end_time}' == "NA"
        Swipe Until Visible    ${trade_duration_after_locator}
        Click Element    ${trade_duration_after_locator}
        Select Time On Time Picker    ${work_start_time}
        ${cancel_button_locator}    Get Localised Locator Exact    ${common_Label_Cancel}
        Click Element    ${cancel_button_locator}
    END
    IF    '${work_start_time}' == "NA" and '${work_end_time}' != "NA"
        Swipe Until Visible    ${trade_duration_before_locator}
        Click Element    ${trade_duration_before_locator}
        Select Time On Time Picker    ${work_end_time}
    END

Enter Additional Work Request Shift Total Duration On Mobile ESS
    [Documentation]    Enter Shift Total Duration of the extra shift on mobile ESS app.
    ...    Arguments:
    ...    ${shift_length}: <The total duration of the shift in hours and minutes >
    [Arguments]    ${shift_length}=NA
    ${trade_extra_work_shift_length_locator}    Get Localised Locator Exact
    ...    ${trade_extra_work_shift_length_title}
    Wait Until Element Is Visible    ${trade_extra_work_shift_length_locator}
    ${hh_mm_text}    Get Localised Message From Key    ${common_hint_time_picker}

    ${duration_text}    Get Localised Message From Key    ${trade_extra_work_label_duration}
    ${trade_extra_work_duration_locator}    Get Locator Exact    ${duration_text} ${hh_mm_text}

    Swipe Until Visible    ${trade_extra_work_duration_locator}
    ${summary_label}    Get Localised Locator Exact    ${common_label_summary}
    Swipe Until Visible    ${summary_label}
    IF    '${shift_length}' != "NA"
        Click Element    ${trade_extra_work_duration_locator}
        ${hour_input_locator}    Get Localised Locator Contains    ${common_label_hour}
        ${hour_value}    Evaluate    '${shift_length}'.split(':')[0]
        ${minute_value}    Evaluate    '${shift_length}'.split(':')[1]
        Input Text    ${hour_input_locator}    ${hour_value}
        ${minute_input_locator}    Get Localised Locator Contains    ${common_label_minutes}
        Click Element    ${minute_input_locator}
        ${minute_value_locator}    Get Locator Contains    ${minute_value}
        Wait Until Element Is Visible    ${minute_value_locator}
        Click Element    ${minute_value_locator}
        ${ok_button_locator}    Get Localised Locator Exact    ${calendar_Ok_Button}
        Click Element    ${ok_button_locator}
    END

Add Requestor Notes On Mobile ESS
    [Documentation]    Add requestor notes on mobile ESS app.
    ...    Arguments:
    ...    ${note_text}: <Note to be added>
    [Arguments]    ${note_text}
    ${trade_requestor_notes_locator}    Get Localised Locator Contains    ${trade_requestor_notes}
    Swipe Until Visible    ${trade_requestor_notes_locator}
    ${add_note_label}    Get Localised Locator Exact    ${common_notes_locator}
    Swipe Until Visible    ${add_note_label}
    Click Element    ${add_note_label}
    Swipe Until Visible    ${add_note_label}
    Input Text    ${add_note_label}    ${note_text}
    Hide Mobile Keyboard

Select MyRequest Tab On Mobile ESS
    [Documentation]    Used for selecting the MyRequest Tab on mobile ESS app.
    Select Shift Trade Tab On Mobile ESS Master    ${trade_my_request_locator}

Select Shift Actions On Mobile ESS
    [Documentation]    Used to select Shift actions Direct Swap Swap with Anyone or Give Away on mobile ESS app.
    ...    Arguments:
    ...    ${shift_action}: <select shift actions>
    [Arguments]    ${shift_action}
    ${shift_action_type}    Get Localised Locator Exact    ${shift_action}
    Wait Until Element Is Visible    ${shift_action_type}
    Click Element    ${shift_action_type}

Select Give Away Action On Mobile ESS
    [Documentation]    Used to select Shift Give Away Action on mobile ESS app.
    Select Shift Actions On Mobile ESS    ${schedule_shift_give_away_locator}
    ${trade_title_give_away_locator}    Get Localised Locator Exact    ${trade_title_give_away}
    Wait Until Element Is Visible    ${trade_title_give_away_locator}
    Click Element    ${trade_title_give_away_locator}

Select Pending Status In MyRequest Filter On Mobile ESS
    [Documentation]    Used for selecting the Pending Status in MyRequest Filter on mobile ESS app.
    ...    Arguments:
    ...    ${start_date}: <start date for filter>
    ...    ${end_date}: <end date for filter>
    ...    ${date_range_req_calender}: <No. of days from current date>
    [Arguments]    ${start_date}    ${end_date}    ${date_range_req_calender}
    Open Custom Filter On Mobile ESS
    Reset Custom Filter On Mobile ESS
    Select Date Range In MyRequest Filter On Mobile ESS    ${start_date}    ${end_date}    ${date_range_req_calender}
    Select Status In MyRequest Filter On Mobile ESS    ${trade_label_pending}
    Apply Custom Filter On Mobile ESS

Select Approved Status In MyRequest Filter On Mobile ESS
    [Documentation]    Used for selecting the Approved Status in MyRequest Filter on mobile ESS app.
    ...    Args:
    ...    ${start_date}: <start date for filter>
    ...    ${end_date}: <end date for filter>
    ...    ${date_range_req_calender}: <No. of days from current date>
    [Arguments]    ${start_date}    ${end_date}    ${date_range_req_calender}
    Open Custom Filter On Mobile ESS
    Reset Custom Filter On Mobile ESS
    Select Date Range In MyRequest Filter On Mobile ESS    ${start_date}    ${end_date}    ${date_range_req_calender}
    Select Status In MyRequest Filter On Mobile ESS    ${trade_label_approved}
    Apply Custom Filter On Mobile ESS

Select Dates In MyRequest Filter On Mobile ESS
    [Documentation]    Used for selecting the Dates in MyRequest Filter on mobile ESS app.
    ...    Arguments:
    ...    ${start_date}: <start date for filter>
    ...    ${end_date}: <end date for filter>
    ...    ${date_range_req_calender}: <No. of days from current date>
    [Arguments]    ${start_date}    ${end_date}    ${date_range_req_calender}
    Open Custom Filter On Mobile ESS
    Reset Custom Filter On Mobile ESS
    Select Date Range In MyRequest Filter On Mobile ESS    ${start_date}    ${end_date}    ${date_range_req_calender}
    Apply Custom Filter On Mobile ESS

Withdraw Shift Request On Mobile ESS
    [Documentation]    Used to Withdraw shift request on mobile ESS app.
    ${trade_label_actions_withdraw_locator}    Get Localised Locator Exact    ${trade_label_actions_withdraw}
    Wait Until Element Is Visible    ${trade_label_actions_withdraw_locator}
    Click Element    ${trade_label_actions_withdraw_locator}
    ${trade_label_withdraw_cnf_locator}    Get Localised Locator Exact    ${trade_label_withdraw_confirmation}
    Wait Until Element Is Visible    ${trade_label_withdraw_cnf_locator}
    Click Element    ${trade_label_actions_withdraw_locator}
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    Run Keyword And Ignore Error
    ...    Tap Close Toast Message On Mobile ESS

Verify Shift Request Not Displayed For Respective Day On Mobile ESS
    [Documentation]    Verify shift Request Not displayed for Respective day on mobile ESS app.
    ...    Arguments:
    ...    ${request_date}: <date on which shift to be advertised>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${shift_request_label}    Get Localized Shift Time Locator With Comma On Mobile ESS    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    Page Should Not Contain Element    ${shift_request_label}

Select Status In MyRequest Filter On Mobile ESS
    [Documentation]    Used for selecting the Status in MyRequest Filter on mobile ESS app.
    ...    Arguments:
    ...    ${status_semantic}: Status of Schedule
    [Arguments]    ${status_semantic}
    ${schedule_todo_label_status_locator}    Get Localised Locator Exact
    ...    ${schedule_todo_label_status}
    Wait Until Element Is Visible    ${schedule_todo_label_status_locator}
    ${status_locator}    Get Localised Locator Exact    ${status_semantic}
    Wait Until Element Is Visible    ${status_locator}
    Click Element    ${status_locator}

Get Localized Shift Time Locator With Comma On Mobile ESS
    [Documentation]    Get localized shift time locator on mobile ESS app.
    ...    Arguments:
    ...    ${request_date}: <date on which shift to be advertised>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${month_day}    Get Config Value    MONTH_DAY_FORMAT

    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    Validate 24 Hour Time Format    ${start_time_24_hr}
    Validate 24 Hour Time Format    ${end_time_24_hr}
    ${start_localised_time}    Format Time String    ${start_time_24_hr}
    ${end_localised_time}    Format Time String    ${end_time_24_hr}
    ${target_date_converted}    Calculate Date From Week Day Offset    ${request_date}    ${month_day}
    VAR    ${start_end_time_localised}    ${target_date_converted}, ${start_localised_time} - ${end_localised_time}
    # Shift Tuesday, Jan 14, 05:15 pm - 09:15 pm 4.0 hr
    ${shift_locator}    Get Locator Contains    ${start_end_time_localised}
    RETURN    ${shift_locator}

Select Shift From My Requests On Mobile ESS
    [Documentation]    Used to select shift from My Requests on mobile ESS app.
    ...    Arguments:
    ...    ${request_date}: <date on which shift to be advertised>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${shift_locator}    Get Localized Shift Time Locator Without Comma On Mobile ESS    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    Swipe Until Visible    ${shift_locator}    maxSwipes=10
    Click Element    ${shift_locator}

Select Shift From Post List On Mobile ESS
    [Documentation]    Used to select shift From Post List on mobile ESS app.
    ...    Arguments:
    ...    ${request_date}: <date on which shift to be advertised>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${shift_locator}    Get Localized Shift Time Locator With Comma On Mobile ESS    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    Swipe Until Visible    ${shift_locator}
    Click Element    ${shift_locator}

Verify Shift On Post List On Mobile ESS
    [Documentation]    Used to select shift From Post List on mobile ESS app.
    ...    Arguments:
    ...    ${request_date}: <date on which shift to be advertised>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${shift_locator}    Get Localized Shift Time Locator With Comma On Mobile ESS    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    Swipe Until Visible    ${shift_locator}

Verify Swap Label Displayed On Mobile ESS
    [Documentation]    Verifies the Swap label is displayed for a specific day on mobile ESS app.
    ...    Arguments:
    ...    ${date_for_shift_request}: <date on which shift is requested in week day offset format>
    [Arguments]    ${date_for_shift_request}
    ${month_day}    Get Config Value    MONTH_DAY_FORMAT
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    ${target_date_converted}    Calculate Date From Week Day Offset    ${date_for_shift_request}    ${month_day}
    ${swap_label}    Get Localised Message From Key    ${schedule_label_swap}
    ${shift_day_locator}    Get Message With Arguments    ${schedule_shift_day_card_locator}    ${target_date_converted}
    Swipe Until Visible    ${shift_day_locator}
    ${swap_label_locator}    Get Message With Arguments
    ...    ${schedule_shift_day_trade_label_locator}    ${target_date_converted}    ${swap_label}
    Swipe Until Visible    ${swap_label_locator}
    Page Should Contain Element    ${swap_label_locator}

Select Shift From Cover List On Mobile ESS
    [Documentation]    Used to select shift From Cover List on mobile ESS app.
    ...    Arguments:
    ...    ${request_date}: <date on which shift to be advertised>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${shift_locator}    Get Localized Shift Time Locator Without Comma On Mobile ESS    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    Swipe Until Visible    ${shift_locator}    maxSwipes=20
    Click Element    ${shift_locator}

Select Additional Work Shift From Post List On Mobile ESS
    [Documentation]
    ...    Selects an additional work shift request from the Post list on mobile ESS app.
    ...    Builds a locator using the localized "Additional Work Requested" title and the start/end time range.
    ...    | =Arguments= | =Description= |
    ...    | request_date    | Weekday offset string (e.g., 2_4) for the shift date. |
    ...    | start_time_24_hr    | Start time in 24-hour format (e.g., 01:00). |
    ...    | end_time_24_hr    | End time in 24-hour format (e.g., 23:00). |
    ...    Example usage:
    ...    | Select Additional Work Shift From Post List On Mobile ESS    2_4    01:00    23:00
    [Arguments]    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    ${date_format}    Get Config Value    DATE_FMT_ABBR_WEEKDAY_MONTH_DAY
    ${target_date}    Calculate Date From Week Day Offset    ${request_date}    ${date_format}
    # ${additional_work_label}    Get Localised Message From Key    ${trade_title_additional_work_requested}
    Validate 24 Hour Time Format    ${start_time_24_hr}
    Validate 24 Hour Time Format    ${end_time_24_hr}
    # ${start_localised_time}    Format Time String    ${start_time_24_hr}
    # ${end_localised_time}    Format Time String    ${end_time_24_hr}
    VAR    ${card_text}    ${target_date}
    # ${additional_work_label} ${start_localised_time} - ${end_localised_time}
    ${shift_locator}    Get Locator Contains    ${card_text}
    Swipe Until Visible    ${shift_locator}
    Click Element    ${shift_locator}

Get Localized Shift Time Locator Without Comma On Mobile ESS
    [Documentation]    Get localized shift time locator on mobile ESS app.
    ...    Arguments:
    ...    ${request_date}: <date on which shift to be advertised>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${month_day}    Get Config Value    MONTH_DAY_FORMAT
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    ${target_date_converted}    Calculate Date From Week Day Offset    ${request_date}    ${month_day}

    Validate 24 Hour Time Format    ${start_time_24_hr}
    Validate 24 Hour Time Format    ${end_time_24_hr}
    ${start_localised_time}    Format Time String    ${start_time_24_hr}
    ${end_localised_time}    Format Time String    ${end_time_24_hr}
    VAR    ${start_end_time_localised}    ${target_date_converted} ${start_localised_time} - ${end_localised_time}

    # Shift Tuesday, Jan 14 05:15 pm - 09:15 pm 4.0 hr
    ${shift_locator}    Get Locator Contains    ${start_end_time_localised}
    RETURN    ${shift_locator}

Verify Shift Request Give Away Label Not Displayed For Respective Day On Mobile ESS
    [Documentation]    Verify shift Request Label Not displayed for Respective day on mobile ESS app.
    ...    Arguments:
    ...    ${date_for_shift_request}: <date on which shift to be advertised>
    [Arguments]    ${date_for_shift_request}
    Verify Shift Request Label Not Displayed For Respective Day On Mobile ESS    ${date_for_shift_request}
    ...    ${schedule_shift_give_away_locator}

Verify Shift Request Label Not Displayed For Respective Day On Mobile ESS
    [Documentation]    Verify shift Request Label Not displayed for Respective day on mobile ESS app.
    ...    Arguments:
    ...    ${date_for_shift_request}: <date on which shift to be advertised>
    ...    ${label_semantic}: <semantic label>
    [Arguments]    ${date_for_shift_request}    ${label_semantic}
    ${month_day}    Get Config Value    MONTH_DAY_FORMAT
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    ${target_date_converted}    Calculate Date From Week Day Offset    ${date_for_shift_request}    ${month_day}
    ${shift_request_label}    Get Localised Message From Key    ${label_semantic}
    ${shift_request_label_semantic}    Get Message With Arguments    ${shift_request_label}
    VAR    ${shift_request_label_localised}    ${target_date_converted} ${shift_request_label_semantic}
    ${shift_request_label_locator}    Get Locator Contains    ${shift_request_label_localised}
    Page Should Not Contain Element    ${shift_request_label_locator}

Verify Shift Request Label Displayed For Respective Day On Mobile ESS
    [Documentation]    Verify shift Request Label displayed for Respective day on mobile ESS app.
    ...    Validates the label is present as a child element under the shift card for the given day,
    ...    matching the actual UI hierarchy: day card -> label element.
    ...    Arguments:
    ...    ${date_for_shift_request}: <date on which shift is requested in week day offset format>
    ...    ${label_semantic}: <semantic label key>
    [Arguments]    ${date_for_shift_request}    ${label_semantic}
    ${month_day}    Get Config Value    MONTH_DAY_FORMAT
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    ${target_date_converted}    Calculate Date From Week Day Offset    ${date_for_shift_request}    ${month_day}
    ${shift_request_label}    Get Localised Message From Key    ${label_semantic}
    ${shift_day_locator}    Get Message With Arguments    ${schedule_shift_day_card_locator}    ${target_date_converted}
    Swipe Until Visible    ${shift_day_locator}
    ${shift_request_label_locator}    Get Message With Arguments    ${schedule_shift_day_trade_label_locator}    ${target_date_converted}    ${shift_request_label}
    Swipe Until Visible    ${shift_request_label_locator}
    Page Should Contain Element    ${shift_request_label_locator}

Verify Shift Request Give Away Label Displayed For Respective Day On Mobile ESS
    [Documentation]    Verify shift Request Label displayed for Respective day on mobile ESS app.
    ...    Arguments:
    ...    ${date_for_shift_request}: <date on which shift to be advertised>
    [Arguments]    ${date_for_shift_request}
    Verify Shift Request Label Displayed For Respective Day On Mobile ESS    ${date_for_shift_request}
    ...    ${schedule_shift_give_away_locator}

Verify Shift Unassigned And Schedule Is Not Scheduled On Mobile ESS
    [Documentation]    Verifies the Shift Unassigned and schedule is not scheduled on mobile ESS app.
    ...    Args:
    ...    ${date_for_not_scheduled}: <date on which schedule is not scheduled>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${date_for_not_scheduled}    ${start_time_24_hr}    ${end_time_24_hr}
    ${shift_locator}    Get Localized Shift Time Locator With Comma On Mobile ESS    ${date_for_not_scheduled}    ${start_time_24_hr}    ${end_time_24_hr}
    Page Should Not Contain Element    ${shift_locator}

Verify Extra Work Request Detail Page On Mobile ESS
    [Documentation]
    ...    Verifies the extra work request detail page on mobile ESS app after tapping on the request.
    ...    Checks status, shift details (start/end time), preference (time of day, shift length), and requested on label.
    ...    | =Arguments= | =Description= |
    ...    | status_semantic    | Semantic key for the expected request status (e.g., trade_label_pending_associate_response). |
    ...    | extra_work_start_time    | Expected start time in 24-hour format (e.g., 01:00). |
    ...    | extra_work_end_time    | Expected end time in 24-hour format (e.g., 23:00). |
    ...    | extra_work_shift_length    | Expected shift length (e.g., 08:00). |
    ...    Example usage:
    ...    | Verify Extra Work Request Detail Page On Mobile ESS    ${trade_label_pending_associate_response}    01:00    23:00    08:00
    [Arguments]    ${status_semantic}    ${extra_work_start_time}    ${extra_work_end_time}    ${extra_work_shift_length}    ${requested_by}=NA
    # Verify title
    IF    '${requested_by}' != "NA"
        ${user}    Get User    ${requested_by}
        VAR    ${associate_name}    ${user}[displayName]
        ${title_message}    Get Localised Message From Key    ${trade_label_users_additional_work}
        ${title_text}    Replace String    ${title_message}    {0}    ${associate_name}
        ${title_locator}    Get Locator Contains    ${title_text}
    ELSE
        ${title_locator}    Get Localised Locator Exact    ${trade_label_my_additional_work}
    END
    Wait Until Element Is Visible    ${title_locator}
    # Verify status
    ${status_locator}    Get Localised Locator Exact    ${status_semantic}
    Wait Until Element Is Visible    ${status_locator}
    # Verify preference label
    IF    '${requested_by}' != "NA"
        ${user}    Get User    ${requested_by}
        VAR    ${associate_name}    ${user}[displayName]
        ${preference_message}    Get Localised Message From Key    ${trade_label_users_preference}
        ${preference_text}    Replace String    ${preference_message}    {0}    ${associate_name}
        ${preference_locator}    Get Locator Contains    ${preference_text}
    ELSE
        ${preference_locator}    Get Localised Locator Exact    ${trade_label_my_preference}
    END
    Page Should Contain Element    ${preference_locator}
    # Verify shift details - start and end time
    ${start_localised_time}    Format Time String    ${extra_work_start_time}
    ${end_localised_time}    Format Time String    ${extra_work_end_time}
    VAR    ${start_end_time_localised}    ${start_localised_time} - ${end_localised_time}
    ${shift_start_locator}    Get Locator Contains    ${start_end_time_localised}
    Swipe Until Visible    ${shift_start_locator}
    # Verify preference - shift length (convert "08:00" to int 8, build "Length - 8 Hours")
    ${shift_length_hours}    Evaluate    int('${extra_work_shift_length}'.split(':')[0])
    ${hours_label}    Get Localised Message From Key    ${common_hours_label}
    ${hours_text}    Get Message With Arguments    ${hours_label}    ${shift_length_hours}
    ${duration_label}    Get Localised Message From Key    ${trade_label_duration_length}
    ${duration_text}    Get Message With Arguments    ${duration_label}    ${hours_text}
    ${shift_length_locator}    Get Locator Contains    ${duration_text}
    Swipe Until Visible    ${shift_length_locator}
    # Verify requested on label
    ${requested_on_locator}    Get Localised Locator Exact    ${trade_label_requested_on}
    Swipe Until Visible    ${requested_on_locator}
    # Verify requested on date contains today's date
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${today_date}    Get Current Date As Per Specific Timezone    ${date_format}
    ${today_date_locator}    Get Locator Contains    ${today_date}
    Page Should Contain Element    ${today_date_locator}

Verify Give Away Request Detail Page On Mobile ESS
    [Documentation]
    ...    Verifies the give away request detail page on mobile ESS app after tapping on the request.
    ...    Checks status, shift details (start/end time, date), and requested on label.
    ...    | =Arguments= | =Description= |
    ...    | status_semantic    | Semantic key for the expected request status (e.g., trade_label_pending_associate_response). |
    ...    | start_time    | Expected start time in 24-hour format (e.g., 01:00). |
    ...    | end_time    | Expected end time in 24-hour format (e.g., 23:00). |
    ...    | shift_date    | Date of the shift in week day offset format (e.g., 2_4). |
    ...    | requested_by    | (Optional) User for whom the shift is requested |
    [Arguments]    ${status_semantic}    ${start_time}    ${end_time}    ${shift_date}    ${requested_by}=NA
    ${month_day_format}    Get Config Value    MONTH_DAY_FORMAT
    # Verify title
    IF    '${requested_by}' != "NA"
        ${user}    Get User    ${requested_by}
        VAR    ${associate_name}    ${user}[displayName]
        ${title_message}    Get Localised Message From Key    ${trade_label_users_give_away_shift}
        ${title_text}    Replace String    ${title_message}    {0}    ${associate_name}
        ${title_locator}    Get Locator Contains    ${title_text}
    ELSE
        ${title_locator}    Get Localised Locator Exact    ${trade_label_my_give_away_shift}
    END
    Wait Until Element Is Visible    ${title_locator}
    # Verify status
    ${status_locator}    Get Localised Locator Exact    ${status_semantic}
    Wait Until Element Is Visible    ${status_locator}

    ${shift_date}    Calculate Date From Week Day Offset    ${shift_date}    ${month_day_format}

    # Verify shift details - start and end time
    ${start_localised_time}    Format Time String    ${start_time}
    ${end_localised_time}    Format Time String    ${end_time}
    VAR    ${shift_detail}    ${shift_date} ${start_localised_time} - ${end_localised_time}
    ${shift_detail_locator}    Get Locator Contains    ${shift_detail}
    Swipe Until Visible    ${shift_detail_locator}

    # Verify requested on date contains today's date
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${today_date}    Get Current Date As Per Specific Timezone    ${date_format}
    ${today_date_locator}    Get Locator Contains    ${today_date}
    Swipe Until Visible    ${today_date_locator}

Verify Swap Request Detail Page On Mobile ESS
    [Documentation]
    ...    Verifies the swap request detail page on mobile ESS app after tapping on the request.
    ...    Checks status, shift details (start/end time, date) and requested on label.
    ...    | =Arguments= | =Description= |
    ...    | status_semantic    | Semantic key for the expected request status (e.g., trade_label_pending_associate_response). |
    ...    | start_time    | Expected start time in 24-hour format (e.g., 01:00). |
    ...    | end_time    | Expected end time in 24-hour format (e.g., 23:00). |
    ...    | shift_date    | Date of the shift in week day offset format (e.g., 2_4). |
    ...    | requested_by    | (Optional) User for whom the shift is requested |
    [Arguments]    ${status_semantic}    ${start_time}    ${end_time}    ${shift_date}    ${requested_by}=NA
    ${month_day_format}    Get Config Value    MONTH_DAY_FORMAT
    # Verify title
    IF    '${requested_by}' != "NA"
        ${user}    Get User    ${requested_by}
        VAR    ${associate_name}    ${user}[displayName]
        ${title_message}    Get Localised Message From Key    ${trade_label_users_swap_shift}
        ${title_text}    Replace String    ${title_message}    {0}    ${associate_name}
        ${title_locator}    Get Locator Contains    ${title_text}
    ELSE
        ${title_locator}    Get Localised Locator Exact    ${trade_swap_label_my_swapped_shift}
    END
    Wait Until Element Is Visible    ${title_locator}
    # Verify status
    ${status_locator}    Get Localised Locator Exact    ${status_semantic}
    Wait Until Element Is Visible    ${status_locator}

    ${shift_date}    Calculate Date From Week Day Offset    ${shift_date}    ${month_day_format}

    # Verify shift details - start and end time
    ${start_localised_time}    Format Time String    ${start_time}
    ${end_localised_time}    Format Time String    ${end_time}
    VAR    ${shift_detail}    ${shift_date} ${start_localised_time} - ${end_localised_time}
    ${shift_detail_locator}    Get Locator Contains    ${shift_detail}
    Swipe Until Visible    ${shift_detail_locator}

    # Verify requested on label
    ${requested_on_locator}    Get Localised Locator Exact    ${trade_label_requested_on}
    Swipe Until Visible    ${requested_on_locator}
    # Verify requested on date contains today's date
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${today_date}    Get Current Date As Per Specific Timezone    ${date_format}
    ${today_date_locator}    Get Locator Contains    ${today_date}
    Swipe Until Visible    ${today_date_locator}
    Page Should Contain Element    ${today_date_locator}

Verify Responder Declined Swap Request On Mobile ESS
    [Documentation]    Verifies, from the requestor's swap request detail page, that a responder
    ...    has declined the swap. A declined directed swap leaves the request itself open, so the
    ...    "Declined" status is shown on the responder card lower on the page rather than as the
    ...    top-level request status; it is therefore swiped into view.
    ...    | =Arguments= | =Description= |
    ...    | responder_user | (Optional) responder user key; when provided, the responder name is also asserted on the card. |
    [Arguments]    ${responder_user}=NA
    ${declined_text}    Get Localised Message From Key    ${trade_label_declined}
    IF    '${responder_user}' != 'NA'
        # The responder card (a ZdsListTile) merges the responder name, shift details and the
        # "Declined" status into a single accessibility node, so match the node that contains BOTH
        # the responder name and "Declined". This targets the responder card specifically and skips
        # the top-level status bar (which shows "Declined" but not the responder name).
        ${user}    Get User    ${responder_user}
        VAR    ${responder_name}    ${user}[displayName]
        VAR    ${declined_locator}
        ...    xpath=//*[contains(@label,"${responder_name}") and contains(@label,"${declined_text}")] | //*[contains(@content-desc,"${responder_name}") and contains(@content-desc,"${declined_text}")]
    ELSE
        ${declined_locator}    Get Localised Locator Contains    ${trade_label_declined}
    END
    Scroll To Element On Mobile ESS    ${declined_locator}
    Page Should Contain Element    ${declined_locator}

Verify Responder Accepted Swap Request On Mobile ESS
    [Documentation]    Verifies, from the requestor's swap request detail page, that a responder has
    ...    accepted the swap. The Flutter responder card only renders a "Declined" status for
    ...    declined responses (responseStatus D); an accepted responder is shown as a normal
    ...    responder card with no status text. Acceptance is therefore asserted as: the responder
    ...    appears in the responder list AND the responder card does NOT carry the "Declined" status.
    ...    | =Arguments= | =Description= |
    ...    | responder_user | Responder user key whose acceptance is asserted on the requestor's detail page. |
    [Arguments]    ${responder_user}
    ${declined_text}    Get Localised Message From Key    ${trade_label_declined}
    ${user}    Get User    ${responder_user}
    VAR    ${responder_name}    ${user}[displayName]
    ${responder_name_locator}    Get Locator Contains    ${responder_name}
    Scroll To Element On Mobile ESS    ${responder_name_locator}
    Page Should Contain Element    ${responder_name_locator}
    VAR    ${responder_declined_locator}
    ...    xpath=//*[contains(@label,"${responder_name}") and contains(@label,"${declined_text}")] | //*[contains(@content-desc,"${responder_name}") and contains(@content-desc,"${declined_text}")]
    Page Should Not Contain Element    ${responder_declined_locator}

Verify Swap Request Status On Mobile ESS
    [Documentation]    Verifies the top-level request status shown on the swap request detail page
    ...    (for example Pending Manager Approval once at least one responder has accepted).
    ...    | =Arguments= | =Description= |
    ...    | status_semantic | Semantic key for the expected request status. |
    [Arguments]    ${status_semantic}
    ${status_locator}    Get Localised Locator Contains    ${status_semantic}
    Scroll To Element On Mobile ESS    ${status_locator}
    Page Should Contain Element    ${status_locator}

Scroll To Element On Mobile ESS
    [Documentation]    Scrolls the current scrollable page until the given element is visible, trying
    ...    downward first and then upward. This finds an element regardless of whether it is above or
    ...    below the current viewport, which is needed when verifying several items (e.g. multiple
    ...    responder cards) whose order on the page is not known in advance.
    ...    | =Arguments= | =Description= |
    ...    | locator | Locator of the element to bring into view. |
    ...    | max_swipes | Maximum swipes attempted in each direction. |
    [Tags]    robot:private
    [Arguments]    ${locator}    ${max_swipes}=15
    ${found}    Run Keyword And Return Status    Swipe Until Visible    ${locator}    "down"    ${max_swipes}
    IF    not ${found}
        Swipe Until Visible    ${locator}    "up"    ${max_swipes}
    END

Verify Open Shift Request Detail Page On Mobile ESS
    [Documentation]
    ...    Verifies the open shift request detail page on mobile ESS app after tapping on the request.
    ...    Checks status, shift detail and requested on label.
    ...    | =Arguments= | =Description= |
    ...    | status_semantic    | Semantic key for the expected request status (e.g., trade_label_pending_associate_response). |
    ...    | requested_by    | (Optional) User for whom the shift is requested |
    [Arguments]    ${status_semantic}    ${requested_by}=NA
    # Verify title
    IF    '${requested_by}' != "NA"
        ${user}    Get User    ${requested_by}
        VAR    ${associate_name}    ${user}[displayName]
        ${title_message}    Get Localised Message From Key    ${trade_label_users_swap_shift}
        ${title_text}    Replace String    ${title_message}    {0}    ${associate_name}
        ${title_locator}    Get Locator Contains    ${title_text}
    ELSE
        ${title_locator}    Get Localised Locator Exact    ${schedule_label_open_shift}
    END
    Wait Until Element Is Visible    ${title_locator}
    # Verify status
    ${status_locator}    Get Localised Locator Exact    ${status_semantic}
    Wait Until Element Is Visible    ${status_locator}

    # Verify requested on label
    ${requested_on_locator}    Get Localised Locator Exact    ${trade_label_requested_on}
    Swipe Until Visible    ${requested_on_locator}
    # Verify requested on date contains today's date
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${today_date}    Get Current Date As Per Specific Timezone    ${date_format}
    ${today_date_locator}    Get Locator Contains    ${today_date}
    Swipe Until Visible    ${today_date_locator}
    Page Should Contain Element    ${today_date_locator}

Accept Additional Work Shift On Mobile ESS
    [Documentation]    Accept request for Additional Work on mobile ESS app.
    ...    Arguments:
    ...    ${request_date}: <the date on which the shift is requested for trade.>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    ...    ${note_text}: <Note to be added>
    [Arguments]    ${note_text}    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    Accept Shift Trade Request On Mobile ESS    ${note_text}    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}

Decline Shift Trade Request On Mobile ESS
    [Documentation]    Declines a swap shift request on mobile ESS app following the full Flutter flow.
    ...    Tapping Decline on the Trade Details page does not decline directly; it opens the
    ...    Decline Swap Shift page (the responder shift is auto-selected for a direct swap, and the
    ...    first eligible shift is pre-selected for a swap-with-anyone). Tapping Decline on that page
    ...    raises a decline confirmation popup, and confirming it triggers the decline API.
    ...    Flow: tap Decline (details) -> Decline Swap Shift page -> tap Decline (submit)
    ...    -> confirm decline popup -> wait for loader -> dismiss toast.
    ...    Example usage:
    ...    | Decline Shift Trade Request On Mobile ESS
    Tap Shift Trade Decline Button On Mobile ESS
    ${decline_page_title_locator}    Get Localised Locator Exact    ${trade_decline_swap_shift_title}
    Wait Until Element Is Visible    ${decline_page_title_locator}
    # For a swap-with-anyone the decline page fetches eligible shifts asynchronously and pre-selects
    # the first one; wait for that loader to clear so the Decline submit button is enabled before tap.
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    Tap Shift Trade Decline Button On Mobile ESS
    Confirm Decline Swap Shift Request On Mobile ESS
    Wait Until Page Does Not Contain Element    ${loader_label}
    Run Keyword And Ignore Error
    ...    Tap Close Toast Message On Mobile ESS

Tap Shift Trade Decline Button On Mobile ESS
    [Documentation]    Clicks the shift trade decline button on mobile ESS app.
    [Tags]    robot:private
    ${decline_button_locator}    Get Localised Locator Exact    ${trade_decline_button_locator}
    Wait Until Element Is Visible    ${decline_button_locator}
    Click Element    ${decline_button_locator}

Confirm Decline Swap Shift Request On Mobile ESS
    [Documentation]    Confirms the decline on the decline confirmation popup that appears after
    ...    tapping Decline on the Decline Swap Shift page. Confirming calls the decline API.
    ...    The confirmation dialog uses the standard Yes/No actions; this keyword clicks the localized
    ...    "Yes" button to proceed with declining the swap shift request.
    [Tags]    robot:private
    ${decline_confirmation_locator}    Get Localised Locator Contains    ${trade_decline_swap_confirmation}
    Wait Until Element Is Visible    ${decline_confirmation_locator}
    ${decline_confirm_button_locator}    Get Localised Locator Contains    ${common_label_yes}
    Click Element    ${decline_confirm_button_locator}

Accept Shift Trade Request On Mobile ESS
    [Documentation]    Used to accept shift request on mobile ESS app.
    ...    Arguments:
    ...    ${note_text}: <Note to be added>
    ...    ${request_date}: <the date on which the shift is requested for trade.>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${note_text}    ${request_date}=NA    ${start_time_24_hr}=NA    ${end_time_24_hr}=NA
    Tap Shift Trade Accept Button On Mobile ESS
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    IF    '${request_date}' != "NA" and '${start_time_24_hr}' != "NA" and '${end_time_24_hr}' != "NA"
        Select Additional Work Shift On The Respond Page On Mobile ESS    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    END
    Log    skipping add responder notes(${note_text}) for shift trade request as it is not required
    Tap Submit Button On Mobile ESS
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    Run Keyword And Ignore Error
    ...    Tap Close Toast Message On Mobile ESS

Tap Shift Trade Accept Button On Mobile ESS
    [Documentation]    Click on shift trade accept button on mobile ESS app.
    ${accept_button_semantic_locator}    Get Localised Locator Exact    ${trade_accept_button_locator}
    Wait Until Element Is Visible    ${accept_button_semantic_locator}
    Click Element    ${accept_button_semantic_locator}

Select Additional Work Shift On The Respond Page On Mobile ESS
    [Documentation]    Select Additional Work Shift On The Respond Page on mobile ESS app.
    ...    Arguments:
    ...    ${request_date}: <the date on which the shift is requested for trade.>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    [Arguments]    ${request_date}    ${start_time_24_hr}    ${end_time_24_hr}
    ${LONG_DAY_MONTH_FORMAT}    Get Config Value    LONG_DAY_MONTH
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    Validate 24 Hour Time Format    ${start_time_24_hr}
    Validate 24 Hour Time Format    ${end_time_24_hr}
    # ${start_localised_time}    Format Time String    ${start_time_24_hr}
    # ${end_localised_time}    Format Time String    ${end_time_24_hr}
    ${target_date_converted}    Calculate Date From Week Day Offset    ${request_date}    ${LONG_DAY_MONTH_FORMAT}
    VAR    ${start_end_time_localised}    ${target_date_converted},
    # ${start_localised_time} - ${end_localised_time}
    # Shift Tuesday, Jan 14 05:15 pm - 09:15 pm 4.0 hr
    ${shift_locator}    Get Locator Contains    ${start_end_time_localised}
    Swipe Until Visible    ${shift_locator}
    Click Element    ${shift_locator}

Add Responder Notes On Mobile ESS
    [Documentation]    Add responder notes on mobile ESS app.
    ...    Arguments:
    ...    ${note_text}: <Note to be added>
    [Arguments]    ${note_text}
    ${trade_responder_notes_locator}    Get Localised Locator Contains    ${trade_responder_notes}
    Wait Until Element Is Visible    ${trade_responder_notes_locator}
    ${add_note_label}    Get Localised Locator Exact   ${common_notes_locator}
    Wait Until Element Is Visible    ${add_note_label}
    Click Element    ${add_note_label}
    Input Text    ${add_note_label}    ${note_text}
    Sleep    1s
    Hide Mobile Keyboard

Request Swap Shift With Anyone On Mobile ESS
    [Documentation]    Used to submit a swap-with-anyone shift trade request on mobile ESS app.
    ...    Args:
    ...    ${work_days}: <list of days to be selected for swap shift>
    ...    ${notes}: <Notes for the request.>
    ...    ${after_time}: <The after time of the extra shift in 24-hour format>
    ...    ${before_time}: <The before time of the extra shift in 24-hour format>
    ...    ${shift_length_start_time}: <The shift length start time in hours and minutes>
    ...    ${shift_length_end_time}: <The shift length end time in hours and minute>
    [Arguments]    ${work_days}    ${notes}    ${after_time}=NA    ${before_time}=NA    ${shift_length_start_time}=NA    ${shift_length_end_time}=NA
    Select Swap With Anyone Action On Mobile ESS
    ${trade_extra_work_days_title_locator}    Get Localised Locator Exact
    ...    ${trade_extra_work_days_title}
    Wait Until Element Is Visible    ${trade_extra_work_days_title_locator}
    Toggle Days On Day Picker    ${work_days}
    Enter Shift Trade Request Time Of Day On Mobile ESS    ${after_time}
    ...    ${before_time}
    Enter Shift Length For Swap With Anyone On Mobile ESS    ${shift_length_start_time}    ${shift_length_end_time}
    Select Shift Trade My Location On Mobile ESS
    Log    skipping add requestor notes(${notes}) for additional work request as it is not required
    Tap Submit Button On Mobile ESS
    Run Keyword And Ignore Error
    ...    Tap Close Toast Message On Mobile ESS

Select Swap With Anyone Action On Mobile ESS
    [Documentation]    Used to select swap with anyone action on mobile ESS app.
    Select Shift Actions On Mobile ESS    ${schedule_shift_swipe_with_anyone}
    ${trade_title_swap_with_anyone_locator}    Get Localised Locator Exact    ${trade_title_swap_with_anyone}
    Wait Until Element Is Visible    ${trade_title_swap_with_anyone_locator}

Enter Shift Length For Swap With Anyone On Mobile ESS
    [Documentation]    Enter Start And End Time of the shift on mobile ESS app.
    ...    Args:
    ...    ${shift_length_start_time}: <The start time of the extra shift in 24-hour format>
    ...    ${shift_length_end_time}: <The end time of the extra shift in 24-hour format>
    [Arguments]    ${shift_length_start_time}=NA    ${shift_length_end_time}=NA
    ${trade_extra_work_time_of_day_locator}    Get Localised Locator Exact
    ...    ${trade_extra_work_time_of_day_title}
    ${trade_location_label_locator}    Get Localised Locator Exact    ${trade_label_location}
    Swipe Until Visible    ${trade_extra_work_time_of_day_locator}
    ${common_hint_time_picker_localised}    Get Localised Message From Key    ${common_hint_time_picker}
    ${trade_label_date_from_localised}    Get Localised Message From Key    ${trade_label_date_from}
    ${trade_label_date_to_localised}    Get Localised Message From Key    ${trade_label_date_to}
    VAR    ${trade_duration_after}    ${trade_label_date_from_localised} ${common_hint_time_picker_localised}
    VAR    ${trade_duration_before}
    ...    ${trade_label_date_to_localised} ${common_hint_time_picker_localised}
    ${trade_duration_after_locator}    Get Locator Exact    ${trade_duration_after}
    ${trade_duration_before_locator}    Get Locator Exact    ${trade_duration_before}
    Swipe Until Visible    ${trade_location_label_locator}
    IF    '${shift_length_start_time}' != "NA" and '${shift_length_end_time}' != "NA"
        Click Element    ${trade_duration_after_locator}
        Select Time Length On Time Picker On Mobile ESS    ${shift_length_start_time}    prepopulated_time=''
        Select Time Length On Time Picker On Mobile ESS    ${shift_length_end_time}    prepopulated_time=''
    END
    IF    '${shift_length_start_time}' != "NA" and '${shift_length_end_time}' == "NA"
        Click Element    ${trade_duration_after_locator}
        Select Time Length On Time Picker On Mobile ESS    ${shift_length_start_time}    prepopulated_time=''
        ${cancel_button_locator}    Get Localised Locator Exact    ${common_Label_Cancel}
        Click Element    ${cancel_button_locator}
    END
    IF    '${shift_length_start_time}' == "NA" and '${shift_length_end_time}' != "NA"
        Swipe Until Visible    ${trade_duration_before_locator}
        Click Element    ${trade_duration_before_locator}
        Select Time Length On Time Picker On Mobile ESS    ${shift_length_end_time}    prepopulated_time=''
    END

Select Shift Trade My Location On Mobile ESS
    [Documentation]    Used to select my location for shift trade on mobile ESS app.
    Select Shift Trade Location On Mobile ESS    ${trade_my_location}

Select Shift Trade Location On Mobile ESS
    [Documentation]    Used to select the location for shift trade on mobile ESS app.
    ...    Args:
    ...    ${trade_location}: <The location for shift trade>
    [Arguments]    ${trade_location}
    ${trade_location_locator}    Get Localised Locator Contains    ${trade_location}
    Swipe Until Visible    ${trade_location_locator}
    Click Element    ${trade_location_locator}

Verify No Shifts Covered On Mobile ESS
    [Documentation]    Used to verify no shifts covered message visible on cover screen
    ${no_shift_covered_msg}    Get Localised Locator Contains    ${trade_no_shifts_covered_msg}
    Wait Until Element Is Visible    ${no_shift_covered_msg}

Select View Trade Details In Shift Actions PopUp On Mobile ESS
    [Documentation]    Click on view trade details on shift actions window
    ${view_trade_details}    Get Localised Locator Contains    ${schedule_details_trade_details}
    Wait Until Element Is Visible    ${view_trade_details}
    Click Element    ${view_trade_details}

Verify Open Shift Is Visible On Cover Tab On Mobile ESS
    [Documentation]
    ...    Verifies that the specified open shift is visible on the Shift Trade Cover tab for a home associate.
    ...    Navigates to the Shift Trade module, selects the Cover tab, navigates to the target
    ...    planning week and asserts the shift card with the given start/end times is present.
    ...    | =Arguments= | =Description= |
    ...    | shift_week_day | Week-day offset of the open shift (e.g., 6_6 for week 6 day 7). |
    ...    | start_time_24_hr | Open shift start time in 24-hour format (e.g., 08:00). |
    ...    | end_time_24_hr | Open shift end time in 24-hour format (e.g., 16:00). |
    ...
    ...    Example usage:
    ...    | Verify Open Shift Is Visible On Cover Tab On Mobile ESS    6_6    08:00    16:00
    [Arguments]    ${shift_week_day}    ${start_time_24_hr}    ${end_time_24_hr}
    ${shift_locator}    Get Localized Shift Time Locator Without Comma On Mobile ESS    ${shift_week_day}    ${start_time_24_hr}    ${end_time_24_hr}
    Swipe Until Visible    ${shift_locator}    maxSwipes=10
    Page Should Contain Element    ${shift_locator}

Respond To Open Shift As Nearby Associate On Mobile ESS
    [Documentation]
    ...    Responds to an open shift as a nearby associate on mobile ESS app.
    ...    Navigates to the Shift Trade Cover tab, navigates to the target planning week,
    ...    selects the shift from the cover list and accepts the shift trade request.
    ...    | =Arguments= | =Description= |
    ...    | shift_week_day | Week-day offset of the open shift (e.g., 6_6 for week 6 day 7). |
    ...    | start_time_24_hr | Open shift start time in 24-hour format (e.g., 08:00). |
    ...    | end_time_24_hr | Open shift end time in 24-hour format (e.g., 16:00). |
    ...    | respond_note | Note to add when responding to the open shift. |
    ...
    ...    Example usage:
    ...    | Respond To Open Shift As Nearby Associate On Mobile ESS    6_6    08:00    16:00    Responding as nearby associate
    [Arguments]    ${shift_week_day}    ${start_time_24_hr}    ${end_time_24_hr}    ${respond_note}
    Select Shift From Cover List On Mobile ESS    ${shift_week_day}    ${start_time_24_hr}    ${end_time_24_hr}
    Accept Shift Trade Request On Mobile ESS    ${respond_note}
    Navigate Back On Mobile ESS

Select Filter Option On Shift Trade Screen On Mobile ESS
    [Documentation]
    ...    Selects a filter option on the Shift Trade screen.
    ...    This keyword is used to filter shifts by type or location when browsing available shifts.
    ...    Maps filter options to their semantic locator keys and embeds them into the checkbox locator pattern.
    ...    Scrolls horizontally within the HorizontalScrollView container to find the filter checkbox.
    ...    | =Arguments= | =Description= |
    ...    | filter_option | Filter option to select. Supported values: "Open Shifts", "Give away", "Swap", |
    ...    | | "Additional Work", "Responded", "Not Responded", "Home Stores", "Nearby Stores". |
    [Arguments]    ${filter_option}
    ${filter_option_normalized}    Evaluate    "${filter_option}".lower().replace(" ", "_")

    # Verify filter option is supported
    VAR    @{supported_options}    open_shifts    give_away    swap    additional_work    responded    not_responded    home_stores    nearby_stores
    IF    "${filter_option_normalized}" not in ${supported_options}
        Fail    Unsupported filter option: ${filter_option}. Supported values: Open Shifts, Give away, Swap, Additional Work, Responded, Not Responded, Home Stores, Nearby Stores
    END

    # Map filter option to semantic locator key
    ${semantic_locator_key}    Set Variable If
    ...    "${filter_option_normalized}" == "home_stores"    ${trade_label_home_stores}
    ...    "${filter_option_normalized}" == "nearby_stores"    ${trade_label_nearby_stores}
    ...    ${EMPTY}

    # Get localized filter option text and build final locator
    IF    "${semantic_locator_key}" != "${EMPTY}"
        # For location filters, get localized text from semantic key
        ${filter_text}    Get Localised Message From Key    ${semantic_locator_key}
    ELSE
        # For shift type filters, use the filter option as-is
        VAR    ${filter_text}    ${filter_option}
    END

    # Build final locator using checkbox pattern (replace {0} placeholder with filter text)
    ${filter_locator}    Get Message With Arguments    ${trade_filter_checkbox_locator}    ${filter_text}

    # Find HorizontalScrollView and scroll horizontally within it to reveal the checkbox
    Wait Until Element Is Visible    ${trade_filter_scroll_container}
    Swipe Element Within Container    ${trade_filter_scroll_container}    ${filter_locator}    right
    Wait Until Element Is Visible    ${filter_locator}    timeout=10s
    Click Element    ${filter_locator}

Swipe Element Within Container
    [Documentation]
    ...    Scrolls horizontally within a container (HorizontalScrollView) to make a target element visible.
    ...    This keyword is used to scroll within a specific scrollable container without affecting other page elements.
    ...    | =Arguments= | =Description= |
    ...    | container_locator | Locator of the scroll container (e.g., HorizontalScrollView). |
    ...    | target_locator | Locator of the element to scroll into view. |
    ...    | direction | Scroll direction: "left" or "right". Default is "right". |
    ...    | max_swipes | Maximum horizontal swipes to attempt. Default is 10. |
    [Arguments]    ${container_locator}    ${target_locator}    ${direction}=right    ${max_swipes}=10
    ${found}    Run Keyword And Return Status    Wait Until Element Is Visible    ${target_locator}    timeout=1s
    IF    ${found}    RETURN

    # Get container element to use for scrolling
    ${container_element}    Get Webelement    ${container_locator}
    ${container_x}    Evaluate    int(${container_element.location['x']})
    ${container_y}    Evaluate    int(${container_element.location['y']})
    ${container_width}    Evaluate    int(${container_element.size['width']})
    ${container_height}    Evaluate    int(${container_element.size['height']})

    # Calculate swipe coordinates within container bounds
    ${start_x}    Evaluate    ${container_x} + ${container_width} - 50
    ${end_x}    Evaluate    ${container_x} + 50
    ${center_y}    Evaluate    ${container_y} + (${container_height} // 2)

    # Adjust start and end based on direction
    IF    "${direction}" == "left"
        VAR    ${temp}       ${start_x}
        VAR    ${start_x}    ${end_x}
        VAR    ${end_x}      ${temp}

    END

    # Perform horizontal swipes within the container
    FOR    ${_}    IN RANGE    ${max_swipes}
        Swipe    start_x=${start_x}    start_y=${center_y}    end_x=${end_x}    end_y=${center_y}
        ${found}    Run Keyword And Return Status    Wait Until Element Is Visible    ${target_locator}    timeout=1s
        IF    ${found}    RETURN
    END

    Fail    Could not scroll target element into view within ${max_swipes} swipes

Deselect Filter Option On Shift Trade Screen On Mobile ESS
    [Documentation]
    ...    Deselects/unchecks a filter option on the Shift Trade screen.
    ...    This keyword is used to remove filters from shifts when browsing available shifts.
    ...    Maps filter options to their semantic locator keys and embeds them into the checkbox locator pattern.
    ...    | =Arguments= | =Description= |
    ...    | filter_option | Filter option to deselect. Supported values: "Open Shifts", "Give away", "Swap", |
    ...    | | "Additional Work", "Responded", "Not Responded", "Home Stores", "Nearby Stores". |
    [Arguments]    ${filter_option}
    ${filter_option_normalized}    Evaluate    "${filter_option}".lower().replace(" ", "_")

    # Verify filter option is supported
    VAR    @{supported_options}    open_shifts    give_away    swap    additional_work    responded    not_responded    home_stores    nearby_stores
    IF    "${filter_option_normalized}" not in ${supported_options}
        Fail    Unsupported filter option: ${filter_option}. Supported values: Open Shifts, Give away, Swap, Additional Work, Responded, Not Responded, Home Stores, Nearby Stores
    END

    # Map filter option to semantic locator key
    ${semantic_locator_key}    Set Variable If
    ...    "${filter_option_normalized}" == "home_stores"    ${trade_label_home_stores}
    ...    "${filter_option_normalized}" == "nearby_stores"    ${trade_label_nearby_stores}
    ...    ${EMPTY}

    # Get localized filter option text and build final locator
    IF    "${semantic_locator_key}" != "${EMPTY}"
        # For location filters, get localized text from semantic key
        ${filter_text}    Get Localised Message From Key    ${semantic_locator_key}
    ELSE
        # For shift type filters, use the filter option as-is
        VAR    ${filter_text}    ${filter_option}
    END

    # Build final locator using checkbox pattern (replace {0} placeholder with filter text)
    ${filter_locator}    Get Message With Arguments    ${trade_filter_checkbox_locator}    ${filter_text}

    # Scroll within HorizontalScrollView container to reveal the checkbox
    Swipe Until Visible    ${trade_filter_scroll_container}    "up"
    Wait Until Element Is Visible    ${trade_filter_scroll_container}
    Swipe Element Within Container    ${trade_filter_scroll_container}    ${filter_locator}    right
    Wait Until Element Is Visible    ${filter_locator}    timeout=10s
    Click Element    ${filter_locator}

Verify Request Status On MyRequest Tab On Mobile ESS
    [Documentation]
    ...    Navigates to the MyRequest tab and verifies that a shift request for the given date and time
    ...    is visible in the list with the expected status label.
    ...    | =Arguments= | =Description= |
    ...    | planning_week_date | Shift date in week day offset format (e.g., 6_6). |
    ...    | start_time_24_hr | Expected shift start time in 24-hour format (e.g., 06:00). |
    ...    | end_time_24_hr | Expected shift end time in 24-hour format (e.g., 13:00). |
    ...    | status | Expected status label. Supported values: "Pending", "Approved", "Declined". |
    ...
    ...    Example usage:
    ...    | Verify Request Status On MyRequest Tab On Mobile ESS    6_6    06:00    13:00    Pending
    ...    | Verify Request Status On MyRequest Tab On Mobile ESS    6_6    06:00    13:00    Approved
    [Arguments]    ${planning_week_date}    ${start_time_24_hr}    ${end_time_24_hr}    ${status}
    ${status_normalized}    Evaluate    "${status}".lower()

    # Map plain status string to semantic locator key
    ${status_semantic}    Set Variable If
    ...    "${status_normalized}" == "pending"      ${trade_label_pending}
    ...    "${status_normalized}" == "approved"     ${trade_label_approved}
    ...    "${status_normalized}" == "declined"     ${trade_label_declined}
    ...    ${EMPTY}

    IF    "${status_semantic}" == "${EMPTY}"
        Fail    Unsupported status: ${status}. Supported values: Pending, Approved, Declined
    END

    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    Validate 24 Hour Time Format    ${start_time_24_hr}
    Validate 24 Hour Time Format    ${end_time_24_hr}
    ${month_day}    Get Config Value    MONTH_DAY_FORMAT
    ${target_date}    Calculate Date From Week Day Offset    ${planning_week_date}    ${month_day}
    ${start_localised_time}    Format Time String    ${start_time_24_hr}
    ${end_localised_time}    Format Time String    ${end_time_24_hr}
    ${status_text}    Get Localised Message From Key    ${status_semantic}
    # Build a locator scoped to the specific card matching date + time range + status
    # This avoids false positives when multiple cards share the same status on screen
    VAR    ${time_range}    ${start_localised_time} - ${end_localised_time}
    ${card_locator}    Get Message With Arguments
    ...    ${trade_my_request_card_with_status_locator}    ${target_date}    ${time_range}    ${status_text}
    Swipe Until Visible    ${card_locator}    maxSwipes=10
    Page Should Contain Element    ${card_locator}

Verify Additional Work Requested Not Displayed On Cover Tab On Mobile ESS
    [Documentation]    Verifies the Additional Work Requested label is not displayed for a specific day on mobile ESS app.
    ...    Arguments:
    ...    ${date_for_shift_request}: <date on which shift is requested in week day offset format>
    [Arguments]    ${date_for_shift_request}
    ${month_day}    Get Config Value    MONTH_DAY_FORMAT
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    ${target_date_converted}    Calculate Date From Week Day Offset    ${date_for_shift_request}    ${month_day}
    ${additional_work_label}    Get Localised Message From Key    ${trade_title_additional_work_requested}
    ${shift_day_locator}    Get Message With Arguments    ${schedule_shift_day_card_locator}    ${target_date_converted}
    Swipe Until Visible    ${shift_day_locator}    maxSwipes=10
    ${additional_work_locator}    Get Message With Arguments
    ...    ${schedule_shift_day_additional_work_locator}    ${target_date_converted}    ${additional_work_label}
    Page Should Not Contain Element    ${additional_work_locator}

Respond To Extra Work Shift As Nearby Associate On Mobile ESS
    [Documentation]
    ...    Responds to an extra work shift as a nearby associate on mobile ESS app.
    ...    Navigates to the Shift Trade Cover tab, navigates to the target planning week,
    ...    selects the shift from the cover list and accepts the shift trade request.
    ...    | =Arguments= | =Description= |
    ...    | shift_week_day | Week-day offset of the extra work shift (e.g., 6_6 for week 6 day 7). |
    ...    | start_time_24_hr | Extra work shift start time in 24-hour format (e.g., 08:00). |
    ...    | end_time_24_hr | Extra work shift end time in 24-hour format (e.g., 16:00). |
    ...    | respond_note | Note to add when responding to the extra work shift. |
    ...
    ...    Example usage:
    ...    | Respond To Extra Work Shift As Nearby Associate On Mobile ESS    6_6    08:00    16:00    Responding as nearby associate
    [Arguments]    ${respond_note}    ${shift_week_day}=NA    ${start_time_24_hr}=NA    ${end_time_24_hr}=NA
    Accept Shift Trade Request On Mobile ESS    ${respond_note}    ${shift_week_day}    ${start_time_24_hr}    ${end_time_24_hr}
    Navigate Back On Mobile ESS

Request Direct Swap On Mobile ESS
    [Documentation]
    ...    Opens the direct swap flow for a my-store shift and selects the target associate.
    ...    | =Arguments= | =Description= |
    ...    | ${user} | Associate selected for the direct swap request. |
    ...    | ${store} | Store scope to use for swap: My Store or Nearby Store. |
    ...    Example usage:
    ...    | Request Direct Swap On Mobile ESS    ESS20_STORE15    My Store
    [Arguments]    ${user}    ${store}=My Store    ${store_unit}=None
    ${normalized_store}    Evaluate    $store.lower().replace(' ', '_')
    Select Direct Swap Action On Mobile ESS
    IF    $normalized_store == "my_store"
        Select My Store Tab On Mobile ESS
    ELSE IF    $normalized_store == "nearby_store"
        Select Nearby Store Tab On Mobile ESS    ${store_unit}
    END
    Select Associate For Swap Shift On Mobile ESS    ${user}

Verify Associate Has No Shifts Available To Swap On Mobile ESS
    [Documentation]
    ...    Opens the direct swap flow for the selected associate, verifies the no-shifts-available message, and returns to the previous screen.
    ...    | =Arguments= | =Description= |
    ...    | ${user} | Associate selected for the direct swap request. |
    ...    Example usage:
    ...    | Verify Associate Has No Shifts Available To Swap On Mobile ESS    ESS20_STORE15
    [Arguments]    ${user}    ${store}    ${store_unit}=None
    Request Direct Swap On Mobile ESS    ${user}    ${store}    ${store_unit}
    Verify No Shifts Available To Swap On Mobile ESS
    Navigate Back On Mobile ESS

Verify No Shifts Available To Swap On Mobile ESS
    [Documentation]
    ...    Verifies the no-shifts-available message
    ${trade_no_shifts_available_locator}    Get Localised Locator Exact    ${trade_swap_label_no_shifts}
    Wait Until Element Is Visible    ${trade_no_shifts_available_locator}

Request Direct Swap For Nearby Store Shift On Mobile ESS
    [Documentation]    Used to Direct shift request For My Store on mobile ESS app.
    ...    Arguments:
    ...    ${note_text}: <Note to be added>
    ...    ${user}: <Note to be added>
    ...    ${swap_date}: <date on which shift to be Swap>
    ...    ${start_time_24_hr}: <start time in 24 hr format>
    ...    ${end_time_24_hr}: <end time in 24 hr format>
    ...    ${store_unit}: <Store unit to select (for example, Store 14).>
    [Arguments]    ${note_text}    ${user}    ${swap_date}    ${start_time_24_hr}    ${end_time_24_hr}    ${store_unit}
    Select Direct Swap Action On Mobile ESS
    Select Nearby Store Tab On Mobile ESS    ${store_unit}
    Select Associate And Request Direct Swap Shift On Mobile ESS    ${note_text}    ${user}    ${swap_date}    ${start_time_24_hr}    ${end_time_24_hr}

Select Nearby Store Tab On Mobile ESS
    [Documentation]
    ...    Opens Nearby Stores and selects the specific store unit for the passed user.
    ...    | =Arguments= | =Description= |
    ...    | ${store_unit} | Store unit to select (for example, Store 14). |
    [Arguments]    ${store_unit}
    ${nearby_store_tab_locator}    Get Localised Locator Contains    ${trade_label_nearby_stores}
    Wait Until Element Is Visible    ${nearby_store_tab_locator}
    Click Element    ${nearby_store_tab_locator}
    ${store_unit_locator}    Get Message With Arguments    ${trade_nearby_store_unit_button_locator}    ${store_unit}
    Wait Until Element Is Visible    ${store_unit_locator}
    Click Element    ${store_unit_locator}
