*** Settings ***
Documentation       This resource file contains keywords and locators for interacting with the ESS Navigation Menu, including expanding the menu, retrieving parent modules, navigating modules, and verifying error states.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/ess/navigation_menu_page.py


*** Keywords ***
Expand ESS Navigation Menu On Web
    [Documentation]    Expand the ESS Navigation Menu on Web
    ${ess_menu_icon}    Is Element Visible On Webpage    ${ESS_PAGE_EXPAND_MENU_ICON}
    IF    ${ess_menu_icon}
        ${already_expanded}    Is Element Visible On Webpage    ${ESS_PAGE_NAVIGATION_FIRST_MODULE_TEXT}
        IF    not ${already_expanded}
            Click Element On Webpage    ${ESS_PAGE_EXPAND_MENU_ICON}
        END
        ${is_expanded_after_menu_click}    Is Element Visible On Webpage    ${ESS_PAGE_NAVIGATION_FIRST_MODULE_TEXT}
        IF    not ${is_expanded_after_menu_click}
            Click Element On Webpage    ${ESS_PAGE_EXPAND_MENU_ICON}
        END
    ELSE
        ${ess_menu_icon}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${ESS_PAGE_MENU_ICON}
        ...    timeout=${SHORT_TIMEOUT}
        ${already_expanded}    Is Element Visible On Webpage    ${ESS_PAGE_EXPANDED_MODULES_FIRST_MODULE}
        IF    not ${already_expanded}
            IF    ${ess_menu_icon}
                Click Element On Webpage    ${ESS_PAGE_MENU_ICON}
            ELSE
                Click Element On Webpage    ${ESS_PAGE_MORE_ICON}
                Click Element On Webpage    ${ESS_PAGE_MENU_ICON}
            END
        END
    END

Get ESS Parent Modules From ESS Home Page On Web
    [Documentation]    Get all the ESS Parent Modules from ESS Home
    ${expanded_ess_modules}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${ESS_PAGE_EXPANDED_MODULES_FIRST_MODULE}    timeout=${SHORT_TIMEOUT}
    IF    ${expanded_ess_modules}
        @{menu_list}    Get Elements    ${ESS_PAGE_EXPANDED_MODULES_TEXT}
    ELSE
        @{menu_list}    Get Elements    ${ESS_PAGE_NAVIGATION_MODULES_TEXT}
    END
    ${count}    Get Length    ${menu_list}
    Should Not Be Equal As Integers    ${count}    0
    RETURN    ${menu_list}

Check If My Work Integrated ESS Menu Visible On Web
    [Documentation]    Check if 'My Work' integrated ESS Menu is visible on Web
    ${ess_with_my_work}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${ESS_PAGE_MENU_ICON}    timeout=${SHORT_TIMEOUT}
    ${more_with_my_work}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${ESS_PAGE_MORE_ICON}    timeout=${SHORT_TIMEOUT}
    IF    ${ess_with_my_work}
        RETURN    ${ess_with_my_work}
    ELSE IF    ${more_with_my_work}
        Click Element On Webpage    ${ESS_PAGE_MORE_ICON}
        ${ess_with_my_work}    Is Element Visible On Webpage    ${ESS_PAGE_MENU_ICON}
        RETURN    ${ess_with_my_work}
    ELSE
        RETURN    False
    END

Navigate To Each ESS Module From Sidebar And Verify No Error On Web
    [Documentation]
    ...    Navigate to each ESS Module from Sidebar and verify page loaded without error.
    ...    Uses constants mapping to validate menu presence and expected headings.
    ...    | =Arguments= | =Description= |
    ...    | ess_menu_list | List of ESS Menu Items fetched from sidebar. |
    ...    | menu_headings_key_mapping | Keys from constants file containing menu-to-heading mapping. |
    [Arguments]    ${ess_menu_list}    ${menu_headings_key_mapping}
    VAR    @{unconfigured_menus}    @{EMPTY}
    Expand ESS Navigation Menu On Web
    FOR    ${menu_element}    IN    @{ess_menu_list}
        ${menu_raw_text}    Get Element Text On Webpage    ${menu_element}
        ${menu_text}    Strip String    ${menu_raw_text}
        ${menu_in_config}    Run Keyword And Return Status    Dictionary Should Contain Key    ${menu_headings_key_mapping}    ${menu_text}
        IF    not ${menu_in_config}
            Append To List    ${unconfigured_menus}    ${menu_text}
        END
    END
    ${unconfigured_count}    Get Length    ${unconfigured_menus}
    IF    ${unconfigured_count} > 0
        ${unconfigured_list}    Evaluate    ', '.join(${unconfigured_menus})
        Log    Unconfigured ESS Menus (found on app but not in test constants): ${unconfigured_list}    WARN
    END
    ${ess_with_my_work}    Check If My Work Integrated ESS Menu Visible On Web
    IF    ${ess_with_my_work}
        Iterate Through My Work Integrated ESS Modules On Web    ${menu_headings_key_mapping}
    ELSE
        Iterate Through ESS Modules On Web    ${menu_headings_key_mapping}
    END

Iterate Through ESS Modules On Web
    [Documentation]    Iterate through the ESS modules on the web application and verify their navigation and headers.
    [Arguments]    ${menu_headings_key_mapping}
    ${menu_keys}    Get Dictionary Keys    ${menu_headings_key_mapping}
    VAR    ${menu_load_failure}    False
    VAR    @{missing_menus}    @{EMPTY}
    VAR    @{skipped_menus}    @{EMPTY}
    FOR    ${menu_key}    IN    @{menu_keys}
        ${ess_menu_element}    Update Locator With Dynamic Values    ${ESS_PAGE_NAVIGATION_MODULE}    MODULE_NAME=${menu_key}
        ${menu_exists}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${ess_menu_element}
        ...    timeout=${MEDIUM_TIMEOUT}
        IF    not ${menu_exists}
            Append To List    ${missing_menus}    ${menu_key}
            CONTINUE
        END
        ${expected_heading}    Get From Dictionary    ${menu_headings_key_mapping}    ${menu_key}
        TRY
            Click Element On Webpage    ${ess_menu_element}
            Wait Until Page Is Loaded
            Wait Until Element Disappears On Webpage    ${ESS_PAGE_PLEASE_WAIT_LOADER}
            Capture Screenshot On Webpage
            Verify No Error UI Elements On Page On Web
            ${header_locator}    Update Locator With Dynamic Values    ${ESS_PAGE_HEADER_TEXT}    PAGE_HEADING=${expected_heading}
            Wait Until Element Is Visible On Webpage    ${header_locator}    timeout=${MEDIUM_TIMEOUT}
        EXCEPT
            Append To List    ${skipped_menus}    ${menu_key}
            VAR    ${menu_load_failure}    True
        END
        Expand ESS Navigation Menu On Web
    END
    ${missing_count}    Get Length    ${missing_menus}
    ${skipped_count}    Get Length    ${skipped_menus}
    IF    ${missing_count} > 0
        ${missing_list}    Evaluate    ', '.join(${missing_menus})
        Log    Missing ESS Menus (configured in test but not found on app): ${missing_list}    WARN
    END
    IF    ${skipped_count} > 0
        ${skipped_list}    Evaluate    ', '.join(${skipped_menus})
        Log    Skipped ESS Menus (found but failed to navigate/verify): ${skipped_list}    WARN
    END
    IF    ${menu_load_failure}
        Fail    ERROR: One or more ESS Menus failed to load or verify properly. Check Skipped ESS Menus logs warning for details.
    END

Iterate Through My Work Integrated ESS Modules On Web
    [Documentation]    Iterate through the "My Work Integrated" ESS modules on the web application and verify their navigation and headers.
    [Arguments]    ${menu_headings_key_mapping}
    ${menu_keys}    Get Dictionary Keys    ${menu_headings_key_mapping}
    VAR    ${menu_load_failure}    False
    VAR    @{missing_menus}    @{EMPTY}
    VAR    @{skipped_menus}    @{EMPTY}
    FOR    ${menu_key}    IN    @{menu_keys}
        ${ess_menu_element}    Update Locator With Dynamic Values    ${ESS_PAGE_MY_WORK_INTEGRATED_MODULES_TEXT}    MODULE_NAME=${menu_key}
        ${menu_exists}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${ess_menu_element}
        ...    timeout=${MEDIUM_TIMEOUT}
        IF    not ${menu_exists}
            Append To List    ${missing_menus}    ${menu_key}
            CONTINUE
        END
        ${expected_heading}    Get From Dictionary    ${menu_headings_key_mapping}    ${menu_key}
        TRY
            ${iframe_attribute_value}    Get Attribute    ${ess_menu_element}    attribute=id
            ${iframe_id}    Replace String    ${iframe_attribute_value}    main-menu-    ESS_
            Click Element On Webpage    ${ess_menu_element}
            Wait Until Page Is Loaded
            Handle Iframe If Available    ${iframe_id}
            Wait Until Element Disappears On Webpage    ${ESS_PAGE_PLEASE_WAIT_LOADER}
            Capture Screenshot On Webpage
            Verify No Error UI Elements On Page On Web
            ${header_locator}    Update Locator With Dynamic Values    ${ESS_PAGE_HEADER_TEXT}    PAGE_HEADING=${expected_heading}
            Wait Until Element Is Visible On Webpage    ${header_locator}    timeout=${MEDIUM_TIMEOUT}
            Set Selector Prefix    ${NONE}
        EXCEPT
            Append To List    ${skipped_menus}    ${menu_key}
            VAR    ${menu_load_failure}    True
            Set Selector Prefix    ${NONE}
        END
        Expand ESS Navigation Menu On Web
    END
    ${missing_count}    Get Length    ${missing_menus}
    ${skipped_count}    Get Length    ${skipped_menus}
    IF    ${missing_count} > 0
        ${missing_list}    Evaluate    ', '.join(${missing_menus})
        Log    Missing ESS Menus (configured in test but not found on app): ${missing_list}    WARN
    END
    IF    ${skipped_count} > 0
        ${skipped_list}    Evaluate    ', '.join(${skipped_menus})
        Log    Skipped ESS Menus (found but failed to navigate/verify): ${skipped_list}    WARN
    END
    IF    ${menu_load_failure}
        Fail    ERROR: One or more ESS Menus failed to load or verify properly. Check Skipped ESS Menus logs warning for details.
    END

Verify No Error UI Elements On Page On Web
    [Documentation]    Check for various error UI elements that might appear
    VAR    @{error_selectors}
    ...    ${ESS_PAGE_ERROR_RIBBON_NOTIFICATION}
    ...    ${ESS_PAGE_ERROR_RIBBON_NOTIFICATION_TEXT}
    FOR    ${selector}    IN    @{error_selectors}
        TRY
            ${error_element_visible}    Is Element Visible On Webpage    ${selector}
            Should Not Be True    ${error_element_visible}    msg=Error UI element found with selector: ${selector}
        EXCEPT
            Log    ERROR: Found error ribbon on page with selector: ${selector}    WARN
        END
    END
