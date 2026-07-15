*** Settings ***
Documentation       This resource contains keyword required for Alternate work location related features.

Library            DateTime
Resource        resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource        resources/Mobile/Common/MobileKeyboardUtils.resource
Variables        resources/Mobile/ESS/Locators/AlternateWorkLocation.py


*** Keywords ***
Navigate To ESS Work Locations Page On Mobile ESS
    [Documentation]    Navigates mobile ESS to the Alternate Work Location module.
    Navigate Mobile ESS To Module    ${Alt_Work_Location_Button_Label}
    ${add_work_loc_title_locator}    Get Localised Locator Contains    ${alternate_work_loc_add_title}
    Wait Until Element Is Visible    ${add_work_loc_title_locator}

Open Add Alternate Work Location Page On Mobile ESS
    [Documentation]    Taps on Add button on Alternate Work Location module to open add request page.
    ${add_alternate_loc_btn}    Get Localised Locator Exact    ${alternate_work_loc_add_btn}
    Wait Until Element Is Visible    ${add_alternate_loc_btn}
    Click Element    ${add_alternate_loc_btn}

Select Alternate Work Location Requests Tab On Mobile ESS
    [Documentation]    Open alternate work location request on mobile ESS app.
    ${loader_label}    Get Localised Locator Exact    ${common_page_loader}
    Wait Until Page Does Not Contain Element    ${loader_label}
    ${tab_localised_name}    Get Localised Message From Key    ${alternate_work_loc_request_title}
    ${tab_locator}    Get Message With Arguments    ${alternate_work_loc_requests_tab}    ${tab_localised_name}
    Wait Until Element Is Visible    ${tab_locator}
    Click Element    ${tab_locator}

Add Alternate Work Location Request On Mobile ESS
    [Documentation]    Adds alternate work location on mobile ESS app. Don't use this method directly, it is a master method used for implementation
    ...    Args:
    ...    ${description}: Description for the request.
    ...    ${request_start_week_day}: Start week date for the request.
    ...    ${request_end_week_day}: End week date for the request.
    ...    ${store_names}: Store full name where associate is requesting to work.
    ...    ${note}: Notes for the request.
    [Arguments]    ${description}    ${request_start_week_day}    ${request_end_week_day}    ${store_names}    ${note}=None
    Enter Description Of Alternate Work Location Request On Mobile ESS    ${description}
    Select Alternate Work Location Request Start Date On Mobile ESS    ${request_start_week_day}
    Select Alternate Work Location Request End Date Directly On Mobile ESS    ${request_end_week_day}    ${request_start_week_day}
    IF    '${note}'!='None'
        Enter Note For Alternate Work Location Request On Mobile ESS    ${note}
    END
    Tap Add Location To Open Select Alternate Stores On Mobile ESS
    Search And Select Multiple Alternate Work Location On Mobile ESS    ${store_names}
    Submit Alternate Work Location Request For Approval On Mobile ESS

Enter Description Of Alternate Work Location Request On Mobile ESS
    [Documentation]    Enters description of alternate work location request on mobile ESS app.
    ...    Args:
    ...    ${descriptionData}: <description for request>
    [Arguments]    ${description_data}
    ${description_label}    Get Localised Locator Exact    ${alternate_work_loc_description}
    Swipe Until Visible    ${description_label}
    Wait Until Page Contains Element    ${description_label}
    Click Element    ${description_label}
    Input Text    ${description_label}    ${description_data}
    Hide Mobile Keyboard

Edit Description Of Alternate Work Location Request On Mobile ESS
    [Documentation]    Enters description of alternate work location request on mobile ESS app.
    ...    Args:
    ...    ${old_description}: <old description for request>
    ...    ${new_description}: <description for request>
    [Arguments]    ${old_description}    ${new_description}
    ${description_label}    Get Localised Message From Key    ${alternate_work_loc_description}
    VAR    ${old_complete_semantic}    ${description_label} ${old_description}
    ${old_description_label}    Get Locator Exact    ${old_complete_semantic}
    Wait Until Page Contains Element    ${old_description_label}
    Click Element    ${old_description_label}
    Clear Text    ${old_description_label}
    Hide Mobile Keyboard
    Input Text    ${old_description_label}    ${new_description}
    Hide Mobile Keyboard

Select Alternate Work Location Request Start Date On Mobile ESS
    [Documentation]    Selects start date for alternate work location request on mobile ESS app.
    ...    Args:
    ...    ${request_start}: Start week date for the request.
    ...    ${calendar_open_date}: (optional) Date on which calendar should open. If not provided, calendar will open on current month.
    [Arguments]    ${request_start}    ${calendar_open_date}=NA
    ${request_start_date_label}    Get Localised Locator Contains    ${alternate_work_loc_start_date}
    Select Date On Calendar    ${request_start_date_label}    ${request_start}    ${calendar_open_date}

Select Alternate Work Location Request End Date Directly On Mobile ESS
    [Documentation]    Selects end date for alternate work location request on mobile ESS app by directly tapping on end date field and selecting date from calendar. This keyword should be used when start and end date are in different months and calendar opens on start date month, so that we can directly open calendar on end date month by tapping on end date field.
    ...    Args:
    ...    ${request_end}: End week date for the request.
    ...    ${calendar_open_date}: (optional) Date on which calendar should open. If not provided, calendar will open on current month.
    [Arguments]    ${request_end}    ${calendar_open_date}
    ${date_format}    Get Config Value    SERVER_DF
    ${calendar_open_date_converted}    Calculate Date From Week Day Offset    ${calendar_open_date}    ${date_format}
    Navigate Calendar To    ${request_end}    ${calendar_open_date_converted}

Tap Add Location To Open Select Alternate Stores On Mobile ESS
    [Documentation]    Taps on add location button to open select alternate stores screen on mobile ESS app.
    ${add_alternate_loc_btn}    Get Localised Locator Exact    ${alternate_work_loc_add_location}
    Wait Until Element Is Visible    ${add_alternate_loc_btn}
    Click Element    ${add_alternate_loc_btn}
    ${select_location_window_lbl}    Get Localised Locator Exact    ${alternate_work_loc_select_title}
    Wait Until Element Is Visible    ${select_location_window_lbl}

Search And Select Multiple Alternate Work Location On Mobile ESS
    [Documentation]    Searches and selects alternate work location on mobile ESS app. This keyword is used when there are multiple stores with same name and we need to select multiple stores for alternate work location request.
    ...    Args:
    ...    ${store_names}: List of store full names where associate is requesting to work
    [Arguments]    ${store_names}
    FOR    ${store_full_name}    IN    @{store_names}
        ${location_search_lbl}    Get Localised Locator Contains    ${alternate_work_loc_search}
        Swipe Until Visible    ${location_search_lbl}
        Wait Until Page Contains Element    ${location_search_lbl}
        Click Element    ${location_search_lbl}
        Run Keyword And Ignore Error    Clear Text    ${location_search_lbl}
        ${store_name_search_keyword}    Get Substring    ${store_full_name}    0    -1
        Input Text    ${location_search_lbl}    ${store_name_search_keyword}
        IF    '${MOBILE_PLATFORM}'=='android'
            Hide Mobile Keyboard
        ELSE
            Press Search On IOS Keyboard
        END
        ${store_option}    Get Locator Contains    ${store_full_name}
        Wait Until Element Is Visible    ${store_option}
        Click Element    ${store_option}
    END
    ${confirm_store}    Get Localised Locator Exact    ${alternate_work_loc_confirm_store}
    Wait Until Element Is Visible    ${confirm_store}
    Click Element    ${confirm_store}

Enter Note For Alternate Work Location Request On Mobile ESS
    [Documentation]    Used for entering note for alternate work location request on mobile ESS app.
    ...    Args:
    ...    ${noteData}: <note for request>
    [Arguments]    ${note_data}
    ${note_label}    Get Localised Locator Contains    ${alternate_work_loc_note}
    Swipe Until Visible    ${note_label}
    Wait Until Page Contains Element    ${note_label}
    Click Element    ${note_label}
    Input Text  ${note_label}    ${note_data}

Submit Alternate Work Location Request For Approval On Mobile ESS
    [Documentation]    Used for submitting alternate work location request for approval on mobile ESS app.
    ${submit_btn_label}    Get Localised Locator Exact    ${alternate_work_loc_sel_loc_submit}
    ${is_keyboard_visible}    Run Keyword And Return Status    Is Keyboard Shown
    IF    ${is_keyboard_visible}    Hide Keyboard
    Swipe Until Visible    ${submit_btn_label}
    Wait Until Element Is Visible    ${submit_btn_label}
    Click Element    ${submit_btn_label}

Verify Mobile ESS Alternate Work Location Request List Item On Mobile ESS
    [Documentation]    Used for verifying alternate work location request list item in tab on mobile ESS app.
    ...    Args:
    ...    ${store_name}: Store Name
    ...    ${start_date}: Start date for the request.
    ...    ${end_date}: End date for the request.
    ...    ${req_status}: Status of the request.
    [Arguments]    ${store_name}    ${start_date}    ${end_date}    ${req_status}    ${max_swipes}=2
    ${request_list_item_semantic}    Get Alternate Work Location Request List Semantic On Mobile ESS    ${store_name}    ${start_date}    ${end_date}    ${req_status}
    Swipe Until Visible    ${request_list_item_semantic}    maxSwipes=${max_swipes}

Tap Alternate Work Location Request List Item On Mobile ESS
    [Documentation]    Used for tapping on alternate work location request list item in tab on mobile ESS app to open details page.
    ...    Args:
    ...    ${store_name}: Store Name
    ...    ${start_date}: Start date for the request.
    ...    ${end_date}: End date for the request.
    ...    ${req_status}: Status of the request.
    [Arguments]    ${store_name}    ${start_date}    ${end_date}    ${req_status}
    ${request_list_item_semantic}    Get Alternate Work Location Request List Semantic On Mobile ESS    ${store_name}    ${start_date}    ${end_date}    ${req_status}
    Swipe Until Visible    ${request_list_item_semantic}
    Click Element    ${request_list_item_semantic}

Tap Edit Alternate Work Location Request Page On Mobile ESS
    [Documentation]    Click on edit alternate work location button on mobile ESS
    ${edit_btn_label}    Get Localised Locator Exact    ${common_Label_edit}
    Wait Until Element Is Visible    ${edit_btn_label}
    Click Element    ${edit_btn_label}

Resubmit Alternate Work Location Request For Approval On Mobile ESS
    [Documentation]    Tap resubmit for approval button to edit alternate location request on mobile ESS app.
    ${resubmit_for_approval_btn_label}    Get Localised Locator Exact    ${alternate_work_loc_resubmit_for_approval}
    Wait Until Element Is Visible    ${resubmit_for_approval_btn_label}
    Click Element    ${resubmit_for_approval_btn_label}

Delete Alternate Work Location Request From Details On Mobile ESS
    [Documentation]    Tap delete button on details page to delete alternate location request on mobile ESS app.
    Tap Withdraw Alternate Work Location Request On Mobile ESS
    Confirm Withdraw Alternate Work Location Request On Mobile ESS

Tap Withdraw Alternate Work Location Request On Mobile ESS
    [Documentation]    Tap on withdraw alternate work location button for eligible user for mobile ESS
    ${alternate_loc_withdraw_btn}    Get Localised Locator Exact    ${alternate_work_loc_request_withdraw}
    Wait Until Element Is Visible    ${alternate_loc_withdraw_btn}
    Click Element    ${alternate_loc_withdraw_btn}

Confirm Withdraw Alternate Work Location Request On Mobile ESS
    [Documentation]    Tap on confirm alternate work location button for eligible user for mobile ESS
    ${confirm_withdraw_request_title}    Get Localised Locator Exact
    ...    ${alternate_work_loc_request_withdraw_window_header}
    Wait Until Element Is Visible    ${confirm_withdraw_request_title}
    ${alternate_loc_withdraw_confirm_btn_lbl}    Get Localised Locator Exact    ${common_label_yes}
    Wait Until Element Is Visible    ${alternate_loc_withdraw_confirm_btn_lbl}
    Click Element    ${alternate_loc_withdraw_confirm_btn_lbl}

Get Alternate Work Location Request List Semantic On Mobile ESS
    [Documentation]    Used for verifying request in list on mobile ESS app.
    ...    Args:
    ...    ${store_name}: Store Name
    ...    ${req_start_date}: Start date for the request.
    ...    ${req_end_date}: End date for the request.
    ...    ${req_status}: Status of the request.
    [Arguments]    ${store_name}    ${req_start_date}    ${req_end_date}    ${req_status}
    ${date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    VAR    ${date_text}    ''
    IF    '${req_start_date}' == '${req_end_date}'
        ${date_text}    Calculate Date From Week Day Offset    ${req_start_date}    ${date_format}
    ELSE
        ${request_start_text}    Calculate Date From Week Day Offset    ${req_start_date}    ${date_format}
        ${request_end_text}    Calculate Date From Week Day Offset    ${req_end_date}    ${date_format}
        VAR    ${date_text}    ${request_start_text} - ${request_end_text}
    END
    ${status_label}    Get Localised Message From Key    ${alternate_work_loc_status}
    ${final_status_label}     Get Message With Arguments    ${status_label}    ${SPACE}${req_status}
    ${final_string}    Get Message With Arguments    {0} {1} {2}    ${store_name}[0]    ${date_text}    ${final_status_label}
    ${request_list_item_semantic}    Get Locator Contains    ${final_string}
    RETURN    ${request_list_item_semantic}
