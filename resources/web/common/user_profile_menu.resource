*** Settings ***
Documentation       This resource file contains locators of User Profile Menu seen on top right of the Landing page

Resource            resources/web/common/common.resource
Resource            resources/web/pdv/non_mywork_menu_navigation.resource
Variables           resources/web/common/user_profile_menu_page.py


*** Variables ***
${STORE_PROFILE_TEXT}           ""
${DEFAULT_DEPARTMENT_NAME}      Store
${CURRENT_STORE_NAME}           ""


*** Keywords ***
Check And Switch To Store With Profile
    [Documentation]    Check if the give store is already selected, if not then switch to the store with profile
    ...
    ...    Args:
    ...    ${store_name}: store name as seen in ui. only Name not id (Mandatory)
    ...    ${store_profile_name}: profile name to be selected while switching the store (Optional)
    [Arguments]    ${store_name}    ${store_profile_name}=${NONE}
    Set Selector Prefix    ${NONE}

    ${my_work_enabled}    Get Config Value    key=MYWORK_ENABLED
    IF    '${my_work_enabled}' == 'True'
        ${store_status}    Run Keyword And Return Status
        ...    Verify User Profile Designation Contains Selected Store Name    ${store_name}
    ELSE
        Wait Until Page Is Loaded
        ${store_name_from_ui}    Get Current Store Name In Non My Work Integrated
        ${store_status}    Evaluate    "${store_name}" in """${store_name_from_ui}"""
    END
    IF    "${store_status}" == "False"
        Switch To Store With Profile    store_name=${store_name}    store_profile_name=${store_profile_name}
    END

Verify User Profile Designation Contains Selected Store Name
    [Documentation]    Verify User Profile Designation Contains Selected Store Name
    ...
    ...    Args:
    ...    ${store_name}: store_name
    [Arguments]    ${store_name}
    Get Text    ${USER_PROFILE_MENU_USER_DESIGNATION}    contains    ${store_name}

Get Current Store Name In Non My Work Integrated
    [Documentation]    Get the current store name in non My Work Integrated
    Click    ${USER_PROFILE_MENU_TOGGLE_HEADER}
    ${value}    browser.Get Text    ${USER_PROFILE_MENU_USER_SETTINGS_PROFILE}
    RETURN    ${value}
    [Teardown]    Click    ${USER_PROFILE_MENU_TOGGLE_HEADER}

Switch To Store With Profile
    [Documentation]
    ...    Switches to a store by filtering the list using store ID when
    ...    ${store_id} is provided, or using store name when only ${store_name}
    ...    is provided, and selecting the first store in the filtered list.
    ...    Args:
    ...    ${store_id}: Store ID to search by instead of store name (Optional)
    ...    ${store_name}: store name as seen in ui. only Name not id (Mandatory)
    ...    ${store_profile_name}: profile name to be selected while switching the store (Optional)
    [Arguments]    ${store_name}    ${store_id}=${NONE}    ${store_profile_name}=${NONE}
    Set Selector Prefix    ${NONE}
    ${my_work_enabled}    Get Config Value    key=MYWORK_ENABLED
    IF    '${my_work_enabled}' == 'True'
        Switch To Store With Profile For My Work Integrated    store_name=${store_name}    store_id=${store_id}
        ...    store_profile_name=${store_profile_name}
    ELSE
        Switch To Store With Profile For Non My Work    store_id=${store_id}    store_name=${store_name}
        ...    store_profile_name=${store_profile_name}
    END

Switch To Store With Profile For My Work Integrated
    [Documentation]
    ...    Switches to a store by searching the store ID in the My Work integrated UI.
    ...    If store_id is provided, the store ID field is used for search; otherwise, the store name field is used.
    ...    Args:
    ...    ${store_id}: Store ID to search by instead of store name (Optional)
    ...    ${store_name}: store name as seen in ui. only Name not id (Mandatory)
    ...    ${store_profile_name}: profile name to be selected while switching the store (Optional)
    [Tags]    robot:private
    [Arguments]    ${store_name}    ${store_id}=${NONE}    ${store_profile_name}=${NONE}
    Open Switch Store Popup Window
    IF    "${store_id}" != "${NONE}" and "${store_id}" != ""
        Fill Textbox On Webpage    ${USER_PROFILE_MENU_UNIT_ID}    ${store_id}
    ELSE
        Fill Textbox On Webpage    ${USER_PROFILE_MENU_UNIT_NAME}    ${store_name}
    END
    Click Apply Button In Switch To Popup
    IF    "${store_id}" != "${NONE}" and "${store_id}" != ""
        Click Element On Webpage    (//li[contains(text(),'${store_id}')])[1]
    ELSE
        Click Element On Webpage    (//li[contains(text(),'${store_name}')])[1]
    END
    IF    "${store_profile_name}" != "${NONE}" and "${store_profile_name}" != ""
        Select Switch Store Profile    ${store_profile_name}
    END
    Verify WFM Switch To Home Icon Is Seen
    IF    "${store_profile_name}" != "${NONE}" and "${store_profile_name}" != ""
        Log To Console    Verify User Profile Name Contains Store Profile Name: ${store_profile_name}
    END
    Verify User Profile Designation Contains Selected Store Name    ${store_name}

Switch To Store With Profile For Non My Work
    [Documentation]    Short description.
    ...
    ...    Args:
    ...    ${store_name}: <description>
    ...    ${store_profile_name}: <description>
    ...    ${store_id}: <description>
    [Tags]    robot:private
    [Arguments]    ${store_name}    ${store_profile_name}=${NONE}    ${store_id}=${NONE}
    Open Switch Store Popup Window
    Type Text    ${main_menu["switch_search_textbox"]}    ${store_name}
    Click Element On Webpage    ${main_menu["switch_search_button"]}
    ${is_by_name}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage
    ...    (//a[contains(@aria-label, '${store_name}')])[1]
    ...    timeout=${SHORT_TIMEOUT}
    IF    not ${is_by_name}
        Clear Textbox On Webpage    ${main_menu["switch_search_textbox"]}
        Type Text    ${main_menu["switch_search_textbox"]}    ${store_id}
        Click Element On Webpage    ${main_menu["switch_search_button"]}
    END
    Wait Until Element Is Visible On Webpage
    ...    (//a[contains(@aria-label, '${store_name}')])[1]
    Click Element On Webpage
    ...    (//a[contains(@aria-label, '${store_name}')])[1]
    ${is_store_profile}    Evaluate    str($store_profile_name).strip().lower() not in ["none", "na", "-", ""]
    IF    ${is_store_profile}
        # Selecting Profile
        Wait Until Element Is Visible On Webpage    ${main_menu["switch_profile_tab"]}
        Click Element On Webpage    //a[normalize-space()='${store_profile_name}']
    END
    Wait Until Page Is Loaded
    Ensure Breadcrumb Menu Is Expanded On Web
    Wait Until Element Is Visible On Webpage    ${userprofilemenu_switch_to_home_icon}

Open Switch Store Popup Window
    [Documentation]    Open Switch Store Popup Window : Click on Profile Icon at the top of the page
    ...    and then click on the Switch To Option
    Click Profile Icon
    Click Switch To Link
    Wait For Switch To Popup Window

Click Profile Icon
    [Documentation]    Click on user profile icon.
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    ${MY_WORK_INTEGRATED}
        Click Element On Webpage    ${MYWORK_USERPROFILEMENU_PROFILE_ICON}
    ELSE
        Click Element On Webpage    ${USER_PROFILE_MENU_PROFILE_ICON}
    END

Click Switch To Link
    [Documentation]    Clicks on switch to link to switch to store/other dept.
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    ${MY_WORK_INTEGRATED}
        Click Element On Webpage    ${MYWORK_USERPROFILEMENU_SWITCH_TO_LNK}
    ELSE
        Click Element On Webpage    ${USER_PROFILE_MENU_SWITCH_TO_LNK}
    END

Wait For Switch To Popup Window
    [Documentation]    Waits for Switch To details in pop up window.
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    ${MY_WORK_INTEGRATED}
        Wait Until Element Is Visible On Webpage    ${MYWORK_USERPROFILEMENU_SWITCH_TO_POPUP_WINDOW}
    ELSE
        Wait Until Element Is Visible On Webpage    ${USER_PROFILE_MENU_SWITCH_TO_POPUP_WINDOW}
    END

Click Apply Button In Switch To Popup
    [Documentation]    Clicks on Apply button in Switch To popup.
    Click Element On Webpage    ${USER_PROFILE_MENU_APPLY_BTN}
    Wait Until Page Is Loaded

Select Switch Store Profile
    [Documentation]    Selects the given profile from the list of profiles available in the Switch Store Popup
    ...    one the store is selected.
    ...
    ...    Args:
    ...    ${store_profile_name}: store_profile_name
    [Arguments]    ${store_profile_name}
    Wait Until Element Is Visible On Webpage    ${USER_PROFILE_MENU_CHECK_LOADED_DIALOG}
    Click Element On Webpage    //label[normalize-space()='${store_profile_name}']

Verify WFM Switch To Home Icon Is Seen
    [Documentation]    Verify WFM Switch To Home Icon Is Seen
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    ${MY_WORK_INTEGRATED}
        Wait Until Element Is Visible On Webpage    ${MYWORK_USERPROFILEMENU_SWITCH_TO_HOME_ICON}
    ELSE
        Wait Until Element Is Visible On Webpage    ${USER_PROFILE_MENU_SWITCH_TO_HOME_ICON}
    END

Verify User Profile Name Contains Store Profile Name
    [Documentation]    Verify User Profile Name Contains Store Profile Name
    ...
    ...    Args:
    ...    ${store_profile_name}: store_profile_name
    [Arguments]    ${store_profile_name}
    @{store_profile_name_split}    Split String    ${store_profile_name}    ${SPACE}-
    VAR    ${store_profile_text}    ${store_profile_name_split}[0]
    ${user_profile_text}    Get Element Text On Webpage    ${USER_PROFILE_MENU_USER_NAME}
    Should Contain    ${user_profile_text}    ${store_profile_text}

Switch To Home From Store On Web
    [Documentation]    Clicks on the switch to home menu
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    ${MY_WORK_INTEGRATED}
        Set Selector Prefix    ${NONE}
        Click Element On Webpage    ${MYWORK_USERPROFILEMENU_SWITCH_TO_HOME_ICON}
        ...    error_message=Home icon not clickable/not visible.
        Wait For Load State    networkidle    timeout=${PAGE_LOAD_TIMEOUT}
    ELSE
        Click Element On Webpage    ${USER_PROFILE_MENU_SWITCH_TO_HOME_ICON}
        ...    error_message=Home icon not clickable/not visible.
    END
    Wait Until Page Is Loaded

Get Logged In User Name
    [Documentation]    Get the logged in user name
    ${name_profile}    Get Element Text On Webpage    ${userprofilemenu_user_name}
    VAR    ${name}    ${name_profile.split(" (")[0]}
    RETURN    ${name}

Language Check And Change To English
    [Documentation]    Checks if default Language is English, if not it will change it to English
    ${CLIENT_CONFIG}    Get Config Value    CLIENT
    IF    "${CLIENT_CONFIG}" == "SMLC"    RETURN
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    '${MY_WORK_INTEGRATED}' == 'True'
        ${presence_count}    Get Element Count    ${USERPROFILEMENU_LANGUAGE_LOCATOR}
        Log    Check Presence on page :: ${presence_count}
        IF    ${presence_count} == 1
            ${current_language}    Get Element Text On Webpage    ${USERPROFILEMENU_LANGUAGE_LOCATOR}

            IF    'English' in '${current_language}'
                RETURN    # Exit from the keyword
            ELSE
                Change Language To English
                Wait Until Page Is Loaded
                ${updated_language}    Run Keyword And Return Status
                ...    Wait Until Element Is Visible On Webpage
                ...    ${USERPROFILEMENU_LANGUAGE_LOCATOR}:has-text("English")    timeout=${PAGE_LOAD_TIMEOUT}
                Should Be True    ${updated_language}    Language did not change
                Log    Language changed to English (United States)
                RETURN    # Exit after changing the language
            END
        ELSE
            RETURN    # Exit if the language element is not present
        END
    END

Change Language To English
    [Documentation]    Changing language to English (United States)
    Click Element On Webpage    ${USERPROFILEMENU_LANGUAGE_LOCATOR}
    Wait Until Element Is Visible On Webpage    ${USERPROFILEMENU_CHANGE_LANGUAGE_DROPDOWN_OPTION}
    Hover    ${USERPROFILEMENU_CHANGE_LANGUAGE_DROPDOWN_OPTION}
    Wait Until Page Is Loaded
    Click    role=menuitem[name="English (United States)"]
    # Reload
    Wait Until Page Is Loaded

Verify WFM Home Page Is Seen
    [Documentation]    Wait for home page to get loaded.
    ${MY_WORK_INTEGRATED}    Get Config Value    MYWORK_ENABLED
    IF    ${MY_WORK_INTEGRATED}
        Wait Until Element Is Visible On Webpage    ${MYWORK_USERPROFILEMENU_PROFILE_ICON}
    ELSE
        Wait Until Element Is Visible On Webpage    ${USER_PROFILE_MENU_PROFILE_ICON}
    END

Get Switched Store Name
    [Documentation]    Get the switched store name
    ...    | =Returns=    | =Description= |
    ...    | store_name    | Store name of the switched store. |
    Click Element On Webpage    ${userprofilemenu_profile_icon}
    ${store_name}    Get Element Text On Webpage    ${userprofilemenu_profile_store_name}
    Click Element On Webpage    ${userprofilemenu_profile_icon}
    VAR    ${store_name}    ${store_name.split(",")[0]}
    RETURN    ${store_name}

Click Logout Link On Web
    [Documentation]    Click on logout link to logout from application.
    Click Element On Webpage    ${USER_PROFILE_MENU_LOGOUT_LINK}
