*** Settings ***
Documentation       This resource contains keywords required for Associate Roster Page.

Library             Process
Resource            resources/Mobile/SM/PagesResources/Common/Common.resource
Resource            resources/Mobile/Common/MobileKeyboardUtils.resource


*** Keywords ***
Tap More Options Icon On Associate Roster Page On SM Phone App
    [Documentation]    This keyword is used to tap on more options icon on associate roster page
    Wait Until Page Contains Element    ${ROSTER_MORE_OPTIONS_ICON}
    Click Element    ${ROSTER_MORE_OPTIONS_ICON}

Navigate To Availability Tab On Associate Roster Page On SM Phone App
    [Documentation]    This keyword is used to navigate to availability tab on associate roster page
    Tap More Options Icon On Associate Roster Page On SM Phone App
    ${availability_localised}    Get Localised Message From Key For SM    1000000000051
    ${availability_more_option_locator}    Get Message With Arguments For SM    ${ROSTER_MORE_OPTIONS_AVAILABILITY}    ${availability_localised}
    Wait Until Page Contains Element    ${availability_more_option_locator}
    Click Element    ${availability_more_option_locator}
    ${availability_page_header_locator}    Get Message With Arguments For SM    ${AVAILABILITY_TAB_HEADER}    ${availability_localised}
    Wait Until Page Contains Element    ${availability_page_header_locator}    error=Availability page is not visible after clicking on availability option in more options on associate roster page

Verify Associate Roster Page Is Visible On SM Phone App
    [Documentation]    Used to verify associate roster page is navigated and visible.
    ${retry}    ${retry_interval}    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Wait Until Page Contains Element    ${ASSOCIATE_FILTER_ICON}
    ...    error=Associate Roster page is not visible after clicking on associate roster option

Click On Filter Icon On Associate Roster Page On SM Phone App
    [Documentation]    Used to click on filter icon on associate roster page.
    Wait Until Page Contains Element    ${ASSOCIATE_FILTER_ICON}    error=Filter icon is not visible on associate roster page
    Click Element    ${ASSOCIATE_FILTER_ICON}

Select Active Status From Filter Options On Associate Roster Page On SM Phone App
    [Documentation]    Used to select associate status from filter options on associate roster page.
    [Arguments]    ${status}
    ${is_active_status_selected}    Run Keyword And Return Status    Wait Until Element Is Visible    ${ACTIVE_STATUS_SELECTED_ICON}
    IF    ${is_active_status_selected}
        Log    ✅ Active status is already selected in filter options on associate roster page, hence reset and select again to avoid test flakiness.
        Click Element    ${ACTIVE_STATUS_SELECTED_ICON}
    END
    Wait Until Page Contains Element    ${ASSOCIATE_STATUS_ARROW}
    ...    error=Status dropdown is not visible in filter options on associate roster page
    Click Element    ${ASSOCIATE_STATUS_ARROW}
    ${active_status_locator}    Get Message With Arguments For SM    ${ACTIVE_STATUS}    ${status}
    Wait Until Page Contains Element    ${active_status_locator}
    ...    error=Active option is not visible in status dropdown in filter options on associate roster page
    Click Element    ${active_status_locator}

Apply Filter On Associate Roster Page On SM Phone App
    [Documentation]    Used to apply filter after selecting filter options on associate roster page.
    Wait Until Page Contains Element    ${APPLY_FILTER_BUTTON}
    ...    error=Apply button is not visible in filter options on associate roster page
    Click Element    ${APPLY_FILTER_BUTTON}

Search And Select Associate Name On Associate Roster Page On SM Phone App
    [Documentation]    Used to search associate name on associate roster page.
    ...    | === Arguments === | === Description === |
    ...    | associate_name | Name of the associate to be searched |
    [Arguments]    ${associate_name}
    Wait Until Page Contains Element    ${SEARCH_ICON}    error=Search icon is not visible on associate roster page
    Click Element    ${SEARCH_ICON}
    Wait Until Page Contains Element    ${SEARCH_FIELD}
    ...    error=Search textbox is not visible after clicking search icon on associate roster page
    Input Text    ${SEARCH_FIELD}    ${associate_name}
    ${formatted_searched_associate}    Get Message With Arguments For SM    ${SEARCHED_ASSOCIATE}    ${associate_name}
    Wait Until Page Contains Element    ${formatted_searched_associate}
    ...    error=Associate with name ${associate_name} is not visible after searching on associate roster page
    Click Element    ${formatted_searched_associate}

Verify Basic Details Of Associate On Associate Roster Page On SM Phone App
    [Documentation]    This keyword is used to verify the basic details of associate on associate roster page
    [Arguments]    ${associate_display_name}
    # Regrooming required for the below verification steps.
    # [Arguments]    ${associate_username}    ${associate_first_name}    ${associate_last_name}    ${associate_display_name}
    # ...    ${other_associate_details}
    # ${last_name_locator}    Get Message With Arguments For SM    ${ASSOCIATE_DYNAMIC_LAST_NAME}    ${associate_last_name}
    # Swipe Until Visible    ${last_name_locator}
    # ${first_name_locator}    Get Message With Arguments For SM    ${ASSOCIATE_DYNAMIC_FIRST_NAME}    ${associate_first_name}
    # Swipe Until Visible    ${first_name_locator}
    ${display_name_locator}    Get Message With Arguments For SM    ${ASSOCIATE_DYNAMIC_DISPLAY_NAME}    ${associate_display_name}
    Swipe Until Visible    ${display_name_locator}
    # Regrooming required for the below verification steps.
    # ${gender_locator}    Get Message With Arguments For SM    ${ASSOCIATE_DYNAMIC_GENDER}    ${other_associate_details}[gender]
    # Swipe Until Visible    ${gender_locator}
    # ${associate_id_locator}    Get Message With Arguments For SM    ${DYNAMIC_ASSOCIATE_ID}    ${associate_username}
    # Swipe Until Visible    ${associate_id_locator}
    # Swipe In Container Until Visible    ${ASSOCIATE_SCROLL_VIEW_CONTAINER}   ${last_name_locator}    6    0.2    0.8    0

Edit Basic Details Of Associate On Associate Roster Page On SM Phone App
    [Documentation]    This keyword is used to edit the basic details of associate on associate roster page
    [Arguments]    ${edit_first_name}    ${edit_last_name}=${None}    ${edit_display_name}=${None}
    Wait Until Element Is Visible    ${ASSOCIATE_ROSTER_PAGE_LAST_NAME}    10s
    Click Element    ${ASSOCIATE_ROSTER_PAGE_EDIT_ICON}
    Hide Mobile Keyboard
    Clear Text    ${ASSOCIATE_ROSTER_PAGE_FIRST_NAME}
    Input Text    ${ASSOCIATE_ROSTER_PAGE_FIRST_NAME}    ${edit_first_name}
    IF    '${edit_last_name}' != '${None}'
        Clear Text    ${ASSOCIATE_ROSTER_PAGE_LAST_NAME}
        Input Text    ${ASSOCIATE_ROSTER_PAGE_LAST_NAME}    ${edit_last_name}
    END
    IF    '${edit_display_name}' != '${None}'
        Clear Text    ${ASSOCIATE_ROSTER_PAGE_DISPLAY_NAME}
        Input Text    ${ASSOCIATE_ROSTER_PAGE_DISPLAY_NAME}    ${edit_display_name}
    END
    # additional edit operations can be added here
    Click Element    ${ASSOCIATE_ROSTER_PAGE_SAVE_BUTTON}
    Verify Notification Message Appears On Associate Roster Page On SM Phone App

Verify Notification Message Appears On Associate Roster Page On SM Phone App
    [Documentation]    This keyword is used to verify the notification message on associate roster page
    ${roaster_notification}    Get Message With Arguments For SM    ${ASSOCIATE_ROSTER_DYNAMIC_NOTIFICATION}    success
    Wait Until Element Is Visible    ${roaster_notification}    10s
    Wait Until Page Does Not Contain Element    ${roaster_notification}

Navigate To Contact Info Tab In Contact On Associate Roster Page On SM Phone App
    [Documentation]    This keyword is used to navigate to contact info tab in contact section on associate roster page
    ${ASSOCIATE_ROSTER_PAGE_CONTACT_LOCATOR}    Get Localised Locator Contains For SM    ${ASSOCIATE_ROSTER_PAGE_HEADER_CONTACT_TAB}
    Wait Until Page Contains Element    ${ASSOCIATE_ROSTER_PAGE_CONTACT_LOCATOR}
    Click Element    ${ASSOCIATE_ROSTER_PAGE_CONTACT_LOCATOR}
    Wait Until Page Contains Element    ${ASSOCIATE_ROSTER_PAGE_CONTACT_TAB_CONTACT_INFO}
    Click Element    ${ASSOCIATE_ROSTER_PAGE_CONTACT_TAB_CONTACT_INFO}
    Wait Until Page Contains Element    ${ASSOCIATE_ROSTER_PAGE_CONTACT_INFO_MOBILE_PHONE}

Get Mobile Phone From Contact Info Associate Roster Page On SM Phone App
    [Documentation]    This keyword is used to get the mobile phone of associate from associate roster page
    Navigate To Contact Info Tab In Contact On Associate Roster Page On SM Phone App
    ${mobile_phone}    AppiumLibrary.Get Text    ${ASSOCIATE_ROSTER_PAGE_CONTACT_INFO_MOBILE_PHONE}
    RETURN    ${mobile_phone}

Edit Mobile Phone In Contact Info Associate Roster Page On SM Phone App
    [Documentation]    This keyword is used to edit the mobile phone of associate from associate roster page
    [Arguments]    ${edit_mobile_phone}
    Navigate To Contact Info Tab In Contact On Associate Roster Page On SM Phone App
    Click Element    ${ASSOCIATE_ROSTER_PAGE_EDIT_ICON}
    Swipe Until Visible    ${ASSOCIATE_ROSTER_PAGE_CONTACT_INFO_MOBILE_PHONE}
    Clear Text    ${ASSOCIATE_ROSTER_PAGE_CONTACT_INFO_MOBILE_PHONE}
    Input Text    ${ASSOCIATE_ROSTER_PAGE_CONTACT_INFO_MOBILE_PHONE}    ${edit_mobile_phone}
    Click Element    ${ASSOCIATE_ROSTER_PAGE_SAVE_BUTTON}
    Verify Notification Message Appears On Associate Roster Page On SM Phone App
    ${ASSOCIATE_ROSTER_PAGE_PROFILE_LOCATOR}    Get Localised Locator Contains For SM    ${ASSOCIATE_ROSTER_PAGE_HEADER_PROFILE_TAB}
    Wait Until Page Contains Element    ${ASSOCIATE_ROSTER_PAGE_PROFILE_LOCATOR}
