*** Settings ***
Documentation
...                 This resource file provides keywords for automating non-MyWork menu navigation and screenshot capture for supported modules (e.g., RWS, RTA).
...
...                 = Purpose =
...                 - Centralizes actions for navigating module menus (such as RWS and RTA) and capturing screenshots for verification.
...
...                 = Prerequisites =
...                 - Required resources and variable files must be available and imported.

Resource            resources/web/common/common.resource
Variables           resources/web/pdv/non_mywork_menu_navigation_pages.py


*** Keywords ***
Iterate Over Non-Mywork Pages And Capture Screenshots
    [Documentation]    Iterates over all parent and child pages for a module, navigates to each page,
    ...    waits for it to load, and captures a screenshot for verification.
    ...
    ...    Screenshots are saved with naming convention: ParentPageName_ChildPageName.png
    ...    If a parent page has no children, screenshot is saved as: ParentPageName.png
    ...    | =Arguments= | =Description= |
    ...    | module_name | The module to navigate (e.g., rws, rta). Defaults to rws. |
    ...    | screenshot_dir | (Optional) Directory path for saving screenshots. Defaults to pdv_downloads in EXECDIR. |
    [Arguments]    ${module_name}    ${screenshot_dir}=${EMPTY}

    Ensure Breadcrumb Menu Is Expanded On Web
    ${rws_page_names}    Get Elements    ${PARENT_PAGES}

    FOR    ${parent_page}    IN    @{rws_page_names}
        Process Parent Page And All Associated Child Pages On Web    ${parent_page}    ${screenshot_dir}    ${module_name}
        Wait Until Page Is Loaded
    END

Ensure Breadcrumb Menu Is Expanded On Web
    [Documentation]    Checks if breadcrumb menu is visible and expands it if collapsed.
    ...    This ensures the navigation menu is accessible for page traversal.
    ${is_breadcrumb_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage   ${BREADCRUMB_OPEN_ICON}    timeout=${SHORT_TIMEOUT}
    Capture Screenshot On Webpage
    IF    not ${is_breadcrumb_visible}
        Wait Until Keyword Succeeds    3x    500ms    Expand Breadcrumb Menu Once And Verify On Web
    END

Expand Breadcrumb Menu Once And Verify On Web
    [Documentation]    Attempts one breadcrumb expansion action and verifies menu visibility.
    Click Element On Webpage    ${BREADCRUMB_EXPAND_ICON}    Failed to click on breadcrumb expand icon ${BREADCRUMB_EXPAND_ICON}
    ${is_breadcrumb_visible}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage   ${BREADCRUMB_OPEN_ICON}    timeout=${SHORT_TIMEOUT}
    Capture Screenshot On Webpage
    Should Be True    ${is_breadcrumb_visible}    The main menu is still not visible, failing the test

Process Parent Page And All Associated Child Pages On Web
    [Documentation]    Processes a single parent page and all its child pages.
    ...    Captures screenshots for parent-only pages or iterates through children.
    ...    | =Arguments= | =Description= |
    ...    | parent_page | The parent page element locator |
    ...    | pdv_screenshot_dir | Directory path for saving screenshots |
    ...    | module_name | The module name for navigation recovery |
    [Tags]    robot:private
    [Arguments]    ${parent_page}    ${pdv_screenshot_dir}    ${module_name}

    Ensure Parent Page Menu Is Visible On Web    ${parent_page}    ${module_name}
    Ensure Breadcrumb Menu Is Expanded On Web
    ${parent_page_name}    Get Sanitized Page Name On Web    ${parent_page}
    Hover    ${parent_page}

    ${child_page_names}    Get Elements    ${CHILD_PAGES}
    ${no_of_child_pages}    Get Length    ${child_page_names}
    ${has_child_pages}    Evaluate    ${no_of_child_pages}==0

    IF    ${has_child_pages}
        Capture Parent Only Page Screenshot On Web    ${parent_page}    ${parent_page_name}    ${pdv_screenshot_dir}
    ELSE
        Process All Child Menu Pages On Web    ${parent_page}    ${parent_page_name}    ${child_page_names}    ${pdv_screenshot_dir}
        ...    ${module_name}
    END

Get Sanitized Page Name On Web
    [Documentation]    Extracts and sanitizes page name from element for use in filenames.
    ...    Removes slashes and spaces to create valid filename.
    ...    | =Arguments= | =Description= |
    ...    | page_element | The page element to extract text from |
    ...    | =Returns= | =Description= |
    ...    | sanitized_name | The cleaned page name suitable for filenames |
    [Tags]    robot:private
    [Arguments]    ${page_element}
    ${page_name}    Get Element Text On Webpage    ${page_element}
    ${page_name}    Strip String    ${page_name}
    ${page_name}    Replace String    ${page_name}    /    ${EMPTY}
    ${page_name}    Replace String    ${page_name}    :    ${EMPTY}
    ${page_name}    Replace String    ${page_name}    ${SPACE}    ${EMPTY}
    RETURN    ${page_name}

Ensure Parent Page Menu Is Visible On Web
    [Documentation]    Ensures the parent page element is visible, recovering navigation if needed.
    ...    | =Arguments= | =Description= |
    ...    | parent_page | The parent page element locator |
    ...    | module_name | The module name for navigation recovery |
    [Tags]    robot:private
    [Arguments]    ${parent_page}    ${module_name}
    ${is_parent_page_visible}    Is Element Visible On Webpage    ${parent_page}
    IF    not ${is_parent_page_visible}
        Recover Navigation To Main Menu On Web    ${module_name}
    END

Recover Navigation To Main Menu On Web
    [Documentation]    Recovers navigation back to the specified module menu when parent page becomes invisible.
    ...    Attempts to expand breadcrumb first, then navigates to the module if needed.
    ...    | =Arguments= | =Description= |
    ...    | module_name | The module name to navigate to (e.g., rws, rta) |
    [Tags]    robot:private
    [Arguments]    ${module_name}

    ${is_breadcrumb_visible}    Is Element Visible On Webpage    ${BREADCRUMB_OPEN_ICON}
    ${rws_page_names}    Get Elements    ${PARENT_PAGES}
    ${is_parent_menu_visible}    Evaluate    len(${rws_page_names}) > 0
    IF    not ${is_breadcrumb_visible} and ${is_parent_menu_visible}
        Click Element On Webpage    ${BREADCRUMB_EXPAND_ICON}    Failed to click on breadcrumb expand icon ${BREADCRUMB_EXPAND_ICON}
        Wait Until Element Is Visible On Webpage    ${BREADCRUMB_OPEN_ICON}
        ...    error_message=Element ${BREADCRUMB_OPEN_ICON} not visible after clicking expand icon
        Wait Until Page Is Loaded
    ELSE
        Navigate To Specific Page On Web    ${module_name}
        Wait Until Page Is Loaded
    END

Capture Parent Only Page Screenshot On Web
    [Documentation]    Captures screenshot for a parent page that has no child pages.
    ...    | =Arguments= | =Description= |
    ...    | parent_page | The parent page element locator |
    ...    | parent_page_name | Sanitized name for the screenshot filename |
    ...    | pdv_screenshot_dir | Directory path for saving screenshots |
    [Tags]    robot:private
    [Arguments]    ${parent_page}    ${parent_page_name}    ${pdv_screenshot_dir}
    Click Element On Webpage    ${parent_page}    Failed to click on parent page ${parent_page}
    ${is_page_loaded_on_time}    Run Keyword And Return Status    Wait For Load State    networkidle    timeout=30s

    IF    ${is_page_loaded_on_time}
        Take Screenshot    ${pdv_screenshot_dir}${/}Passed${/}${parent_page_name}.png
    ELSE
        Log    Page '${parent_page_name}' failed to load within the timeout.    WARN
        Take Screenshot    ${pdv_screenshot_dir}${/}Failed${/}${parent_page_name}.png
    END

Process All Child Menu Pages On Web
    [Documentation]    Iterates through all child pages of a parent and captures screenshots.
    ...    | =Arguments= | =Description= |
    ...    | parent_page | The parent page element locator |
    ...    | parent_page_name | Sanitized parent page name |
    ...    | child_page_names | List of child page element locators |
    ...    | pdv_screenshot_dir | Directory path for saving screenshots |
    ...    | module_name | The module name for navigation recovery |
    [Tags]    robot:private
    [Arguments]    ${parent_page}
    ...    ${parent_page_name}
    ...    ${child_page_names}
    ...    ${pdv_screenshot_dir}
    ...    ${module_name}
    FOR    ${child_page}    IN    @{child_page_names}
        Process Single Child Menu Page On Web    ${parent_page}    ${parent_page_name}    ${child_page}    ${pdv_screenshot_dir}
        ...    ${module_name}
        Wait Until Page Is Loaded
    END

Process Single Child Menu Page On Web
    [Documentation]    Processes a single child page: navigates to it and captures screenshot.
    ...    Handles both same-window and new-window navigation scenarios.
    ...    | =Arguments= | =Description= |
    ...    | parent_page | The parent page element locator |
    ...    | parent_page_name | Sanitized parent page name |
    ...    | child_page | The child page element locator |
    ...    | pdv_screenshot_dir | Directory path for saving screenshots |
    ...    | module_name | The module name for navigation recovery |
    [Tags]    robot:private
    [Arguments]    ${parent_page}    ${parent_page_name}    ${child_page}    ${pdv_screenshot_dir}    ${module_name}
    Prepare Child Menu Page Navigation On Web    ${parent_page}    ${module_name}
    Sleep    0.25s    # Short sleep to allow any hover-triggered menus to stabilize

    ${is_child_page_visible}    Is Element Visible On Webpage    ${child_page}
    IF    not ${is_child_page_visible}
        Log    Child page ${child_page} not visible after hover, capturing parent menu screenshot    level=WARN
        Capture Fallback Menu Screenshot On Web    ${parent_page}    ${parent_page_name}    ${pdv_screenshot_dir}
        RETURN
    END

    ${child_page_name}    Get Sanitized Page Name On Web    ${child_page}
    Click Element On Webpage    ${child_page}    Failed to click on child page ${child_page}
    Sleep    0.25s    # Short sleep to allow any hover-triggered menus to stabilize

    ${is_page_loaded_on_time}    Run Keyword And Return Status    Wait For Load State    networkidle    timeout=30s

    IF    ${is_page_loaded_on_time}
        Capture Child Menu Page Screenshot With Window Handling On Web    ${parent_page_name}    ${child_page_name}
        ...    ${pdv_screenshot_dir}${/}Passed
    ELSE
        Log    Page '${parent_page_name} > ${child_page_name}' failed to load within the timeout.    WARN
        Capture Child Menu Page Screenshot With Window Handling On Web    ${parent_page_name}    ${child_page_name}
        ...    ${pdv_screenshot_dir}${/}Failed
    END

Prepare Child Menu Page Navigation On Web
    [Documentation]    Prepares navigation to child page by ensuring parent visibility and hovering.
    ...    | =Arguments= | =Description= |
    ...    | parent_page | The parent page element locator |
    ...    | module_name | The module name for navigation recovery |
    [Tags]    robot:private
    [Arguments]    ${parent_page}    ${module_name}
    Ensure Parent Page Menu Is Visible On Web    ${parent_page}    ${module_name}
    Hover    ${parent_page}
    Sleep    0.25s    # Short sleep to allow any hover-triggered menus to stabilize

Capture Fallback Menu Screenshot On Web
    [Documentation]    Captures a fallback screenshot when child page navigation fails.
    ...    Clicks parent page and captures the resulting menu state.
    ...    | =Arguments= | =Description= |
    ...    | parent_page | The parent page element locator |
    ...    | parent_page_name | Sanitized parent page name |
    ...    | pdv_screenshot_dir | Directory path for saving screenshots |
    [Tags]    robot:private
    [Arguments]    ${parent_page}    ${parent_page_name}    ${pdv_screenshot_dir}
    Click Element On Webpage    ${parent_page}    Failed to click on parent page ${parent_page}
    ${is_page_loaded_on_time}    Run Keyword And Return Status    Wait For Load State    networkidle    timeout=30s

    IF    ${is_page_loaded_on_time}
        Take Screenshot    ${pdv_screenshot_dir}${/}Passed${/}${parent_page_name}.png
    ELSE
        Log    Page '${parent_page_name}' failed to load within the timeout.    WARN
        Take Screenshot    ${pdv_screenshot_dir}${/}Failed${/}${parent_page_name}.png
    END

Capture Child Menu Page Screenshot With Window Handling On Web
    [Documentation]    Captures screenshot after navigating to child page.
    ...    Handles scenarios where child page opens in new window/tab.
    ...    | =Arguments= | =Description= |
    ...    | parent_page_name | Sanitized parent page name |
    ...    | child_page_name | Sanitized child page name |
    ...    | pdv_screenshot_dir | Directory path for saving screenshots |
    [Tags]    robot:private
    [Arguments]    ${parent_page_name}    ${child_page_name}    ${pdv_screenshot_dir}
    ${window_handles}    Get Page Ids
    ${window_count}    Get Length    ${window_handles}
    VAR    ${screenshot_path}    ${pdv_screenshot_dir}${/}${parent_page_name}_${child_page_name}.png

    IF    ${window_count} > 1
        Capture Screenshot In New Window And Close On Web    ${screenshot_path}
    ELSE
        Capture Screenshot In Current Window On Web    ${screenshot_path}
    END

Capture Screenshot In New Window And Close On Web
    [Documentation]    Switches to new window, captures screenshot, closes it, and returns to original.
    ...    | =Arguments= | =Description= |
    ...    | screenshot_path | Full path for saving the screenshot |
    [Tags]    robot:private
    [Arguments]    ${screenshot_path}
    Switch To New Window On Web
    Run Keyword And Ignore Error    Wait Until Page Is Loaded
    Take Screenshot    ${screenshot_path}
    Close Page    CURRENT
    Switch Back To First Opened Page Tab On Web

Capture Screenshot In Current Window On Web
    [Documentation]    Waits for page load and captures screenshot in current window.
    ...    | =Arguments= | =Description= |
    ...    | screenshot_path | Full path for saving the screenshot |
    [Tags]    robot:private
    [Arguments]    ${screenshot_path}
    Wait Until Page Is Loaded
    Take Screenshot    ${screenshot_path}
