*** Settings ***
Documentation
...                 This resource file provides keywords for automating the MyWork menu navigation and screenshot capture for RWS and RTA modules.
...
...                 = Purpose =
...                 - Centralizes actions for navigating MyWork menus across RWS and RTA modules and capturing screenshots for verification.
...
...                 = Prerequisites =
...                 - Required resources and variable files must be available and imported.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/pdv/mywork_menu_navigation_pages.py


*** Keywords ***
Iterate Over Mywork Pages And Capture Screenshots
    [Documentation]    Iterates over all parent and child menus, handles page load timeouts gracefully,
    ...    and saves screenshots to 'Passed' or 'Failed' folders.
    [Arguments]    ${module_name}    ${screenshot_dir}=${EMPTY}

    ${passed_dir}    ${failed_dir}    Setup PDV Screenshot Directory On Web    ${screenshot_dir}
    Navigate To Main Module On Web    ${module_name}
    ${parent_menu_names}    Get Elements    ${PARENT_PAGE_LOCATOR}
    ${parent_count}    Get Length    ${parent_menu_names}

    FOR    ${parent_index}    IN RANGE    ${parent_count}
        Navigate To Main Module On Web    ${module_name}

        ${parent_menu_names}    Get Elements    ${PARENT_PAGE_LOCATOR}
        ${parent_page}    Get From List    ${parent_menu_names}    ${parent_index}
        ${parent_menu_text}    Get Element Text On Webpage    ${parent_page}
        # Click Element On Webpage    ${parent_page}    error_message="Failed to click parent page: ${parent_menu_text}"
        Evaluate JavaScript    ${parent_page}    (element) => element.click()
        Wait Until Page Is Loaded
        ${child_menu}    Update Locator With Dynamic Values    ${CHILD_PAGE_MENU_LOCATOR}    PARENT_MENU_NAME=${parent_menu_text}
        ${child_menu_names}    Get Elements    ${child_menu}
        ${child_count}    Get Length    ${child_menu_names}
        ${no_child_menu_exists}    Evaluate    ${child_count} == 0

        IF    ${no_child_menu_exists}
            ${parent_menu_text}    Get Sanitized Page Name On Web    ${parent_menu_text}
            Take Screenshot    ${passed_dir}${/}${parent_menu_text}.png
        ELSE
            FOR    ${child_index}    IN RANGE    ${child_count}
                Navigate To Main Module On Web    ${module_name}
                ${parent_menu_names}    Get Elements    ${PARENT_PAGE_LOCATOR}
                ${parent_page}    Get From List    ${parent_menu_names}    ${parent_index}
                Click Element On Webpage    ${parent_page}    error_message="Failed to click parent page: ${parent_menu_text}"
                Wait Until Page Is Loaded
                ${child_menu_panel}    Update Locator With Dynamic Values    ${CHILD_MENU_EXPANSION_PANEL}
                ...    PARENT_MENU_NAME=${parent_menu_text}
                ${expansion_panel}    Update Locator With Dynamic Values    ${CHILD_PAGE_EXPANSION_PANEL}
                ...    PARENT_MENU_NAME=${parent_menu_text}
                ${is_panel_collapsed}    Is Element Visible On Webpage    ${expansion_panel}
                IF    ${is_panel_collapsed}
                    Click Element On Webpage    ${child_menu_panel}
                    ...    error_message="Failed to click child menu expansion panel: ${child_menu_panel}"
                    Wait Until Page Is Loaded
                END

                ${child_menu_names}    Get Elements    ${child_menu}
                ${child_page}    Get From List    ${child_menu_names}    ${child_index}
                ${child_page_text}    Get Element Text On Webpage    ${child_page}
                Click Element On Webpage    ${child_page}    error_message="Failed to click child page: ${child_page_text}"
                ${is_page_loaded_on_time}    Run Keyword And Return Status    Wait For Load State    networkidle    timeout=30s

                IF    ${is_page_loaded_on_time}
                    ${parent_menu_text}    Get Sanitized Page Name On Web    ${parent_menu_text}
                    ${child_page_text}    Get Sanitized Page Name On Web    ${child_page_text}
                    Take Screenshot    ${passed_dir}${/}${parent_menu_text}_${child_page_text}.png
                ELSE
                    Log    Page '${parent_menu_text} > ${child_page_text}' failed to load within the timeout.    WARN
                    ${parent_menu_text}    Get Sanitized Page Name On Web    ${parent_menu_text}
                    ${child_page_text}    Get Sanitized Page Name On Web    ${child_page_text}
                    Take Screenshot    ${failed_dir}${/}${parent_menu_text}_${child_page_text}.png
                END
            END
        END
    END

Get Sanitized Page Name On Web
    [Documentation]    Extracts and sanitizes page name from element for use in filenames.
    ...    Replaces special characters like ':', '/' with '_' and removes '*', ' ' to create a valid filename.
    ...    For example, '**Req:FCST/WKLD/SCHD**' becomes 'Req_FCST_WKLD_SCHD'.
    ...    | =Arguments= | =Description= |
    ...    | page_element_text | The text of the page element to sanitize |
    ...    | =Returns= | =Description= |
    ...    | sanitized_name | The cleaned page name suitable for filenames |
    [Tags]    robot:private
    [Arguments]    ${page_element_text}
    ${page_name}    Strip String    ${page_element_text}
    ${page_name}    Replace String    ${page_name}    *    ${EMPTY}
    ${page_name}    Replace String    ${page_name}    :    _
    ${page_name}    Replace String    ${page_name}    /    _
    ${page_name}    Replace String    ${page_name}    ${SPACE}    ${EMPTY}
    RETURN    ${page_name}

Setup PDV Screenshot Directory On Web
    [Documentation]    Creates 'Passed' and 'Failed' subdirectories for screenshots and returns their paths.
    [Arguments]    ${screenshot_dir}
    ${passed_dir}    Catenate    SEPARATOR=${/}    ${screenshot_dir}    Passed
    ${failed_dir}    Catenate    SEPARATOR=${/}    ${screenshot_dir}    Failed
    Create Directory    ${passed_dir}
    Create Directory    ${failed_dir}
    RETURN    ${passed_dir}    ${failed_dir}

Navigate To Main Module On Web
    [Documentation]    Navigates to the specified main module (RWS, RTA, or ESS).
    [Arguments]    ${module_name}
    IF    '${module_name}' == 'rws'
        Click Element On Webpage    ${RWS_MODULE_LOCATOR}    error_message="Failed to click RWS module locator: ${RWS_MODULE_LOCATOR}"
        Wait Until Page Is Loaded
    ELSE IF    '${module_name}' == 'rta'
        Click Element On Webpage    ${RTA_MODULE_LOCATOR}    error_message="Failed to click RTA module locator: ${RTA_MODULE_LOCATOR}"
        Wait Until Page Is Loaded
    ELSE IF    '${module_name}' == 'ess'
        Click Element On Webpage    ${ESS_MODULE_LOCATOR}    error_message="Failed to click ESS module locator: ${ESS_MODULE_LOCATOR}"
        Wait Until Page Is Loaded
    END
