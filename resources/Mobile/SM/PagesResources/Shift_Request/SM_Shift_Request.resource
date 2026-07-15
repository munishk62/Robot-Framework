*** Settings ***
Documentation       This resource contains keywords required for Shift Request and related trade/approval flows in the SM mobile app.

Library             DateTime
Library             Process
Library             String
Library             test_data/TestDataLibrary.py
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/SM/PagesResources/Common/Localised_Locator.resource
Variables           resources/Mobile/SM/Locators/SM_Shift_Request.py


*** Keywords ***
Navigate To Shift Request On SM Mobile
    [Documentation]   Navigates to shift request page on SM mobile app.
    ${sm_shift_request_locator}    Get Localised Locator Contains For SM    ${SM_SHIFT_REQUEST_LABEL}
    Wait Until Page Contains Element    ${sm_shift_request_locator}
    Click Element    ${sm_shift_request_locator}

Select Trade Request On SM Mobile
    [Documentation]    Select trade request on SM mobile app
    ...    | === Arguments === | === Description === |
    ...    | swap_type_label | Label of the trade/swap request to select |
    ...    | user_key | User unique key from credentials |
    ...    | swap_date | Date or weekday offset for the swap request |
    ...    | start_time | Start time of the shift in 24-hour format (HH:mm) |
    ...    | end_time | End time of the shift in 24-hour format (HH:mm) |
    [Arguments]    ${swap_type_label}    ${user_key}    ${swap_date}    ${start_time}    ${end_time}
    ${user}    Get User    ${user_key}    mask_password=False
    ${LONG_DAY_MONTH_FORMAT}    Get Config Value    DAY_DATE_FORMAT
    Validate 24 Hour Time Format    ${start_time}
    Validate 24 Hour Time Format    ${end_time}
    ${start_localised_time}    Format Time String    ${start_time}
    ${end_localised_time}    Format Time String    ${end_time}

    ${target_date_converted}    Calculate Date From Week Day Offset    ${swap_date}    ${LONG_DAY_MONTH_FORMAT}
    IF    ${swap_type_label} == ${SM_OPEN_SHIFT_REQUEST_LIST}
        ${swap_item}    Get Localised Locator Contains For SM    ${SM_OPEN_SHIFT_REQUEST_LIST}    ${target_date_converted}    ${start_localised_time} - ${end_localised_time}    ''
    ELSE
        ${swap_item}    Get Localised Locator Contains For SM    ${swap_type_label}    ${user}[displayName]    ${target_date_converted}    ${start_localised_time} - ${end_localised_time}
    END
    Wait Until Page Contains Element    ${swap_item}
    Click Element    ${swap_item}

Approve Responder On SM Mobile
    [Documentation]    Approve responder on SM Mobile
    ...    Arguments:
    ...    - ${user_key}: User unique key from credentials
    [Arguments]    ${user_key}
    ${user}    Get User    ${user_key}    mask_password=False
    ${sm_responder_locator}    Get Localised Locator Contains For SM    ${SM_RESPONDER_LABEL}
    Wait Until Page Contains Element    ${sm_responder_locator}    ${MEDIUM_TIMEOUT}
    Click Element    ${sm_responder_locator}
    ${responder_name_locator}    Get Message With Arguments    ${SM_RESPONDER_DISPLAY_NAME}    ${user}[displayName]
    Wait Until Page Contains Element    ${responder_name_locator}
    Click Element    ${responder_name_locator}
    ${sm_shift_assign_locator}    Get Localised Locator Contains For SM    ${SM_SHIFT_ASSIGN_LABEL}
    Wait Until Page Contains Element    ${sm_shift_assign_locator}
    Click Element    ${sm_shift_assign_locator}

Decline Responder On SM Mobile
    [Documentation]    Decline responder on SM Mobile
    ...    Arguments:
    ...    - ${user_key}: User unique key from credentials
    [Arguments]    ${user_key}
    ${user}    Get User    ${user_key}    mask_password=False
    ${sm_responder_locator}    Get Localised Locator Contains For SM    ${SM_RESPONDER_LABEL}
    Wait Until Page Contains Element    ${sm_responder_locator}    ${MEDIUM_TIMEOUT}
    Click Element    ${sm_responder_locator}
    ${responder_name_locator}    Get Message With Arguments    ${SM_RESPONDER_DISPLAY_NAME}    ${user}[displayName]
    Wait Until Page Contains Element    ${responder_name_locator}
    Click Element    ${responder_name_locator}
    ${sm_shift_decline_locator}    Get Localised Locator Contains For SM    ${SM_SHIFT_DECLINE_LABEL}
    Wait Until Page Contains Element    ${sm_shift_decline_locator}
    Click Element    ${sm_shift_decline_locator}

Decline Request On SM Mobile
    [Documentation]    Decline a shift trade request on the SM mobile app.
    ...    After selecting the trade request from the shift request list,
    ...    this keyword clicks the decline button and confirms the action.
    ${sm_shift_decline_locator}    Get Localised Locator Contains For SM    ${SM_SHIFT_DECLINE_LABEL}
    Wait Until Page Contains Element    ${sm_shift_decline_locator}
    Click Element    ${sm_shift_decline_locator}
    Wait Until Page Contains Element    ${SM_REQ_POSITIVE_CONFIRM_BUTTON}
    Click Element    ${SM_REQ_POSITIVE_CONFIRM_BUTTON}

Approve Responder Nearby Location On SM Mobile
    [Documentation]    Approve responder on SM Mobile
    ...    Arguments:
    ...    - ${requestor_user_key}: User unique key from credentials
    ...    - ${responder_user_key}: User unique key from credentials
    [Arguments]    ${requestor_user_key}    ${responder_user_key}
    ${requestor_user}    Get User    ${requestor_user_key}    mask_password=False
    Log    ${requestor_user}
    ${responder_user}    Get User    ${responder_user_key}    mask_password=False
    ${sm_responder_locator}    Get Localised Locator Contains For SM    ${SM_RESPONDER_LABEL}
    Wait Until Page Contains Element    ${sm_responder_locator}    ${MEDIUM_TIMEOUT}
    Click Element    ${sm_responder_locator}
    ${responder_name_locator}    Get Message With Arguments    ${SM_RESPONDER_DISPLAY_NAME}    ${responder_user}[displayName]
    Wait Until Page Contains Element    ${responder_name_locator}
    Click Element    ${responder_name_locator}
    ${sm_shift_assign_locator}    Get Localised Locator Contains For SM    ${SM_SHIFT_ASSIGN_LABEL}
    Wait Until Page Contains Element    ${sm_shift_assign_locator}
    Click Element    ${sm_shift_assign_locator}
