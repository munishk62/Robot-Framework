*** Settings ***
Documentation
...                 This resource file provides common utility keywords for web automation in the WFM test suite.
...
...                 = Purpose =
...                 - Centralizes reusable actions such as element interaction, waiting, navigation, and date handling.
...
...                 = Prerequisites =
...                 - Required libraries: BuiltIn, Collections, DateTime, OperatingSystem, String, Browser.
...                 - Variable files for locators and timeouts must be available.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Fill Login Form
...                 |    Fill Textbox On Webpage    ${login_input}    testuser
...                 |    Fill Textbox On Webpage    ${password_input}    password
...                 |    Click Element On Webpage    ${login_button}
...                 |    Capture Screenshot On Webpage
...                 |    Wait Until Element Is Visible On Webpage    ${dashboard}

Library             BuiltIn
Library             Collections
Library             DateTime
Library             OperatingSystem
Library             String
Library             test_data/TestDataLibrary.py
Variables           resources/web/common/navigation_menu_locators.py
Variables           resources/web/common/timeout_variables.py
Variables           resources/web/common/common_page.py
Resource            robotframework_playwright_helper/Playwright_Browser_Helper.resource
Variables           resources/web/rws/employee/request_calendar_page.py


*** Variables ***
${FORMAT}               %m-%d-%Y
${LOCATOR_ID_PREFIX}    id=
${BROWSER_NAME}         chrome
${CLOUD_PLATFORM}       -


*** Keywords ***
Launch Browser
    [Documentation]    Launch Browser based on the browser name provided.
    ...    Supported browsers: chrome, firefox, edge, safari
    ...    | Usage Example :
    ...    | Launch Browser    chrome
    ...    | Launch Browser    firefox    is_headless_mode=${FALSE}
    [Arguments]    ${browser_name}=${BROWSER_NAME}    ${is_headless_mode}=${ENABLE_BROWSER_HEADLESS_MODE}
    IF    '${CLOUD_PLATFORM}' == 'zTest'
        Connect To ZTest Cloud Browser
    ELSE
        ${browser_lower}    Convert To Lower Case    ${browser_name}
        IF    '${browser_lower}' == 'chrome'
            Launch Chrome Browser    ${is_headless_mode}
        ELSE IF    '${browser_lower}' == 'firefox'
            Launch Firefox Browser    ${is_headless_mode}
        ELSE IF    '${browser_lower}' == 'edge'
            Launch Microsoft Edge Browser    ${is_headless_mode}
        ELSE IF    '${browser_lower}' == 'safari'
            Launch Safari Browser    ${is_headless_mode}
        ELSE
            Fail    Unsupported browser: ${browser_name}. Supported browsers are: chrome, firefox, edge, safari
        END
    END

Connect To ZTest Cloud Browser
    [Documentation]    Connect to zTest cloud browser using WebSocket URL with credentials from environment variables.
    ...    This keyword is used when running tests on zTest cloud platform.
    ...    It retrieves CLOUD_USERNAME and CLOUD_TOKEN from environment variables to establish a connection.
    ...    Example usage:
    ...    | Connect To ZTest Cloud Browser
    ${old_level}    Set Log Level    NONE
    TRY
        ${CLOUD_USERNAME}    Get Environment Variable    CLOUD_USERNAME
        ${CLOUD_TOKEN}    Get Environment Variable    CLOUD_TOKEN
        VAR    ${test_env}    %{TEST_ENVIRONMENT=${EMPTY}}
        ${test_id}    Get Test Case ID From Tags
        Connect To Browser    ws://${CLOUD_USERNAME}:${CLOUD_TOKEN}@pune-t11-vm4.zebra.lan:8081/browserless?ztf:suite_name=${test_env}&ztf:test_name=${test_id}    browser=chromium
    EXCEPT    AS    ${error_message}
        Log    Connection failed unable to open browser on zTest farm continuing with local browser. Error: ${error_message}
        Launch Chrome Browser
    FINALLY
        Set Log Level    ${old_level}
    END

Launch The Application URL
    [Documentation]    Launch the application URL
    [Arguments]    ${app_url}
    Open New Browser Context With Page    ${app_url}

Fill Textbox On Webpage
    [Documentation]
    ...    Enters the specified text into a textbox on the webpage.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the textbox element. |
    ...    | text    | Text to input into the textbox. |
    ...    Example usage:
    ...    | Fill Textbox On Webpage    id=username    testuser
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible On Webpage    ${locator}
    Fill Text    ${locator}    ${text}

Fill Secret On Webpage
    [Documentation]    Enter the secret in textbox on webpage like credentials
    [Arguments]    ${locator}    ${text}
    Wait For Elements State    ${locator}    timeout=5s
    Fill Secret    ${locator}    $text

Click Element On Webpage
    [Documentation]
    ...    Clicks the specified element on the webpage.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element to click. |
    ...    | error_message | Custom error message if element is not visible. Optional. |
    ...    Example usage:
    ...    | Click Element On Webpage    id=submit-btn
    [Arguments]    ${locator}    ${error_message}=${locator} Locator not seen
    Wait For Elements State    ${locator}    visible    timeout=${LONG_TIMEOUT}    message=${error_message}
    Wait For Elements State    ${locator}    stable    timeout=${LONG_TIMEOUT}    message=${error_message}
    Click    ${locator}

Double Click Element On Webpage
    [Documentation]
    ...    Double clicks the specified element on the webpage.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element to click. |
    ...    | error_message | Custom error message if element is not visible. Optional. |
    ...    Example usage:
    ...    | Double Click Element On Webpage    id=submit-btn
    [Arguments]    ${locator}    ${error_message}=${locator} Locator not seen
    Wait For Elements State    ${locator}    visible    timeout=${LONG_TIMEOUT}    message=${error_message}
    Click With Options    ${locator}    clickCount=2

Right Click Element On Webpage
    [Documentation]
    ...    Right-clicks the specified element on the webpage to open context menu.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element to right-click. |
    ...    | error_message | Custom error message if element is not visible. Optional. |
    ...    Example usage:
    ...    | Right Click Element On Webpage    id=day-cell
    [Arguments]    ${locator}    ${error_message}=${locator} Locator not seen
    Wait For Elements State    ${locator}    visible    timeout=${LONG_TIMEOUT}    message=${error_message}
    Click With Options    ${locator}    button=right

Capture Screenshot On Webpage
    [Documentation]
    ...    Captures a screenshot of the current webpage and embeds it in the log.html.
    ...    Example usage:
    ...    | Capture Screenshot On Webpage
    Take Screenshot    EMBED

Clear Textbox On Webpage
    [Documentation]
    ...    Clears the content of a textbox on the webpage.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the textbox element. |
    ...    Example usage:
    ...    | Clear Textbox On Webpage    id=email
    [Arguments]    ${locator}
    Wait Until Element Is Visible On Webpage    ${locator}
    Browser.Clear Text    ${locator}

Wait Until Element Is Visible On Webpage
    [Documentation]
    ...    Waits until the specified element is visible, stable, and ready for interaction on the webpage.
    ...    This keyword ensures the element is fully loaded and not animating before proceeding.
    ...    Use this for both display verification and pre-interaction element readiness checks.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element. |
    ...    | timeout    | Maximum time to wait. Optional. Default is LONG_TIMEOUT. |
    ...    | error_message | Custom error message if element is not ready. Optional. |
    ...    Example usage:
    ...    | Wait Until Element Is Visible On Webpage    id=main-content |
    ...    | Wait Until Element Is Visible On Webpage    id=submit-button    timeout=${MEDIUM_TIMEOUT} |
    [Arguments]    ${locator}    ${timeout}=${MEDIUM_TIMEOUT}    ${error_message}=${locator} Locator not ready
    Wait For Elements State    ${locator}    visible    timeout=${timeout}    message=${error_message}
    Wait For Elements State    ${locator}    stable    timeout=${timeout}    message=${error_message}

Wait Until Element Is Detached On Webpage
    [Documentation]
    ...    Waits until the specified element is detached on the webpage and on the screen.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element. |
    ...    | timeout    | Maximum time to wait. Optional. |
    ...    | error_message | Custom error message if element is not detached. Optional. |
    ...    Example usage:
    ...    | Wait Until Element Is Detached On Webpage    id=main-content
    [Arguments]    ${locator}    ${timeout}=${LONG_TIMEOUT}    ${error_message}=${locator} Locator not seen
    Wait For Elements State    ${locator}    detached    timeout=${timeout}    message=${error_message}

Wait Until Element Is Present On Webpage
    [Documentation]
    ...    Waits until the specified element is present in the DOM and attached to the webpage.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element. |
    ...    | timeout    | Maximum time to wait. Optional. |
    ...    | error_message | Custom error message if element is not present. Optional. |
    ...    Example usage:
    ...    | Wait Until Element Is Present On Webpage    id=footer
    [Arguments]    ${locator}    ${timeout}=${MEDIUM_TIMEOUT}    ${error_message}=${locator} Locator not seen
    Wait For Elements State    ${locator}    attached    timeout=${timeout}    message=${error_message}

Wait Until Element Is Not Present On Webpage
    [Documentation]
    ...    Waits until the specified element is not present in the DOM of the webpage.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element. |
    ...    | timeout    | Maximum time to wait. Optional. |
    ...    | error_message | Custom error message if element is still present. Optional. |
    ...    Example usage:
    ...    | Wait Until Element Is Not Present On Webpage    id=footer
    [Arguments]    ${locator}    ${timeout}=${MEDIUM_TIMEOUT}    ${error_message}=${locator} Locator still present
    Wait For Elements State    ${locator}    detached    timeout=${timeout}    message=${error_message}

Wait Until Element Disappears On Webpage
    [Documentation]
    ...    Waits until the specified element disappears from the webpage.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element. |
    ...    | timeout    | Maximum time to wait. Optional. |
    ...    Example usage:
    ...    | Wait Until Element Disappears On Webpage    id=loading
    [Arguments]    ${locator}    ${timeout}=${LONG_TIMEOUT}
    Wait For Elements State    ${locator}    hidden    timeout=${timeout}

Get Element Text On Webpage
    [Documentation]
    ...    Returns the text content of a web element.
    ...    | =Arguments= | =Description= |
    ...    | locator    | Locator for the element. |
    ...    | state    | State to wait for (e.g., visible). Optional. |
    ...    Example usage:
    ...    | Get Element Text On Webpage    id=welcome-msg
    [Arguments]    ${locator}    ${state}=visible
    Wait For Elements State    ${locator}    state=${state}
    ${text_attribute}    Browser.Get Text    ${locator}
    RETURN    ${text_attribute}

Wait Until Page Is Loaded
    [Documentation]
    ...    Waits until the current page is fully loaded.
    ...    | =Arguments= | =Description= |
    ...    | timeout    | Maximum time to wait. Optional. Default to PAGE_LOAD_TIMEOUT |
    ...    Example usage:
    ...    | Wait Until Page Is Loaded
    [Arguments]    ${timeout}=${PAGE_LOAD_TIMEOUT}
    Wait For Load State    domcontentloaded    ${timeout}
    Wait For Load State    load    ${timeout}
    Run Keyword And Ignore Error    Wait For Load State    networkidle    ${timeout}

Is Element Visible On Webpage
    [Documentation]
    ...    Checks if the specified element is visible on the screen.
    ...    | =Arguments= | =Description= |
    ...    | selector    | Locator for the element. |
    ...    Example usage:
    ...    | Is Element Visible On Webpage    id=main-content
    [Arguments]    ${selector}
    ${state}    Get Element States    ${selector}    then    bool(value & visible)
    RETURN    ${state}

Is Element Enabled On Webpage
    [Documentation]
    ...    Checks if the specified element is enabled on the screen.
    ...    | =Arguments= | =Description= |
    ...    | selector    | Locator for the element. |
    ...    Example usage:
    ...    | Is Element Enabled On Webpage    id=main-content
    [Arguments]    ${selector}
    ${state}    Get Element States    ${selector}    then    bool(value & enabled)
    RETURN    ${state}

Select List Item On Webpage
    [Documentation]
    ...    Select an option in drop-down by index/value/text on webpage
    ...    | =Arguments= | =Description= |
    ...    | selector    | Locator for the element. |
    ...    | attribute    | Attribute to select by (index/value/label). |
    ...    | value    | Value to select. |
    ...    Example usage:
    ...    | Select List Item On Webpage    id=dropdown    value    option1
    [Arguments]    ${selector}    ${attribute}    ${value}
    Select Options By    ${selector}    ${attribute}    ${value}

Get Selected List Item On Webpage
    [Documentation]
    ...    Retrieves the selected option(s) from a drop-down or list element on the webpage.
    ...    | =Arguments= | =Description= |
    ...    | selector    | Locator for the element. |
    ...    | attribute    | Attribute to get (index/value/label). |
    ...    | =Returns= | =Description= |
    ...    | selected_dropdown_option    | Selected attribute value (index/value/label)|
    ...    Example usage:
    ...    | Get Selected List Item On Webpage    id=dropdown    value
    [Arguments]    ${selector}    ${attribute}
    ${selected_dropdown_option}    Get Selected Options    ${selector}    ${attribute}
    RETURN    ${selected_dropdown_option}

Navigate To Specific Page On Web
    [Documentation]
    ...    Navigates to a specific page on the web application based on provided parameters.
    ...    Supports flexible navigation:
    ...    - Module only: Navigate To Specific Page On Web    rws
    ...    - Module + Parent: Navigate To Specific Page On Web    rws    reports
    ...    - Module + Parent + Child: Navigate To Specific Page On Web    rws    reports    view_reports
    ...
    ...    Args:
    ...    ${module_name}: The main module name (e.g., rws, rta)
    ...    ${parent_page_name}: The parent page name (optional, default=NA)
    ...    ${child_page_name}: The child page name (optional, default=NA)
    [Arguments]    ${module_name}    ${parent_page_name}=NA    ${child_page_name}=NA
    ${main_menu_id}    ${parent_submenu_id}    ${child_submenu_id}    Get Locators For Page Navigation
    ...    ${module_name}    ${parent_page_name}    ${child_page_name}
    Navigate To Web Menu    ${main_menu_id}    ${parent_submenu_id}    ${child_submenu_id}
    Wait Until Page Is Loaded

Get Locators For Page Navigation
    [Documentation]    Returns locators for page navigation based on provided parameters.
    ...    Handles module-only, module+parent, and module+parent+child navigation.
    ...
    ...    Args:
    ...    ${module_name}: The main module name
    ...    ${parent_page_name}: The parent page name (NA if not applicable)
    ...    ${child_page_name}: The child page name (NA if not applicable)
    [Tags]    robot:private
    [Arguments]    ${module_name}    ${parent_page_name}=NA    ${child_page_name}=NA
    IF    ${MYWORK_ENABLED_MENU}
        VAR    ${main_menu_id}    ${main_menu["${module_name}_menu"]}
    ELSE
        VAR    ${main_menu_id}    ${module_name}
    END
    # Handle parent submenu - return NA if parent_page_name is NA (module-only navigation)
    IF    "${parent_page_name}" != "NA"
        VAR    ${parent_submenu_id}    ${parent_sub_menu["${module_name}_${parent_page_name}"]}
    ELSE
        VAR    ${parent_submenu_id}    NA
    END
    # Handle child submenu
    IF    "${child_page_name}" != "NA"
        TRY
            VAR    ${child_submenu_id}    ${child_sub_menu["${module_name}_${parent_page_name}_${child_page_name}"]}
        EXCEPT
            VAR    ${child_submenu_id}    NA
        END
    ELSE
        VAR    ${child_submenu_id}    NA
    END
    RETURN    ${main_menu_id}    ${parent_submenu_id}    ${child_submenu_id}

Navigate To Web Menu
    [Documentation]    Navigates to the menu as per mentioned in the arguments.
    ...    Supports module-only, module+parent, and module+parent+child navigation.
    [Tags]    robot:private
    [Arguments]    ${main_menu_id}    ${parent_submenu_id}    ${child_submenu_id}=NA
    Wait Until Page Is Loaded
    IF    ${MYWORK_ENABLED_MENU}
        Set Selector Prefix    ${NONE}
        Navigate Via Mywork Menu    ${main_menu_id}    ${parent_submenu_id}    ${child_submenu_id}
        Wait Until Page Is Loaded    timeout=${PAGE_LOAD_TIMEOUT}
        # Only handle iframe if we navigated beyond main module
        IF    "${parent_submenu_id}" != "NA"
            IF    "${child_submenu_id}" != "NA"
                ${iframe_id}    Create Combined String    ${main_menu_id}    ${parent_submenu_id}    ${child_submenu_id}
            ELSE
                ${iframe_id}    Create Combined String    ${main_menu_id}    ${parent_submenu_id}    NA
            END
            Handle Iframe If Available    ${iframe_id}
        END
    ELSE
        Navigate Via Non Mywork Menu    ${main_menu_id}    ${parent_submenu_id}    ${child_submenu_id}
    END

Navigate Via Mywork Menu
    [Documentation]    Navigates to the menu as per mentioned in the arguments for MyWork enabled environments.
    ...    Supports module-only navigation when parent_submenu_id is NA.
    [Arguments]    ${main_menu_id}    ${parent_submenu_id}=NA    ${child_submenu_id}=NA
    VAR    ${is_main_menu_present}    ${None}
    TRY
        Wait For Elements State    ${main_menu_id}    visible    timeout=${MEDIUM_TIMEOUT}
        ${is_main_menu_present}    Is Element Visible On Webpage    ${main_menu_id}
    EXCEPT
        ${is_main_menu_present}    Is Element Visible On Webpage    ${main_menu_id}
    END
    IF    ${is_main_menu_present}
        Click Element On Webpage    ${main_menu_id}
        Wait Until Page Is Loaded
        # If parent_submenu_id is NA, we only navigate to main module - stop here
        IF    "${parent_submenu_id}" == "NA"
            Log    Navigated to main module only: ${main_menu_id}
            RETURN
        END
        Wait Until Element Is Visible On Webpage    ${submenu_list}
        Navigate To SubMenu For Mywork    ${parent_submenu_id}    ${child_submenu_id}
    ELSE
        Click Element On Webpage    id=more-menu
        ${more_main_menu_id}    Replace String    ${main_menu_id}    id=menu-    id=more-menu-
        ${is_main_menu_present}    Is Element Visible On Webpage    ${more_main_menu_id}
        IF    ${is_main_menu_present}
            Click Element On Webpage    ${more_main_menu_id}
            # If parent_submenu_id is NA, we only navigate to main module - stop here
            IF    "${parent_submenu_id}" == "NA"
                Log    Navigated to main module only via more menu: ${more_main_menu_id}
                RETURN
            END
            Wait Until Element Is Visible On Webpage    ${submenu_list}
            Navigate To SubMenu For Mywork    ${parent_submenu_id}    ${child_submenu_id}
        ELSE
            Capture Screenshot On Webpage
            Skip    Menu ${more_main_menu_id} not found!!
        END
    END

Navigate To SubMenu For Mywork    # My Work
    [Documentation]    Navigate to submenu when mywork is enabled
    [Arguments]    ${parent_submenu_id}    ${child_submenu_id}
    ${parent_submenu_id_value}    Replace String    ${parent_submenu_id}    ${LOCATOR_ID_PREFIX}    ${EMPTY}
    Wait Until Page Is Loaded    timeout=${PAGE_LOAD_TIMEOUT}
    ${is_parent_submenu_present}    Is Element Visible On Webpage    ${parent_submenu_id}
    IF    ${is_parent_submenu_present}
        ${submenu_list_expanded}    Get Attribute
        ...    mat-expansion-panel[id='${parent_submenu_id_value}']>mat-expansion-panel-header
        ...    attribute=aria-expanded
        IF    "${submenu_list_expanded}" == "true"
            No Operation
        ELSE
            Click Element On Webpage    ${parent_submenu_id}
        END
        IF    "${child_submenu_id}" != "NA"
            TRY
                Click Element On Webpage    ${child_submenu_id}
                Wait Until Page Is Loaded    timeout=${PAGE_LOAD_TIMEOUT}
            EXCEPT
                Capture Screenshot On Webpage
                Skip    Child Submenu ${child_submenu_id} not found!!
            END
        END
    ELSE
        Capture Screenshot On Webpage
        Skip    Parent Submenu ${parent_submenu_id} not found!!
    END

Create Combined String
    [Documentation]    Short description.
    ...
    ...    Args:
    ...    ${main_menu}: <description>
    ...    ${parent_submenu}: <description>
    ...    ${child_submenu}: <description>
    ...
    ...    Returns:
    ...    ${combined_string}: <description>
    [Tags]    robot:private
    [Arguments]    ${main_menu}    ${parent_submenu}    ${child_submenu}
    VAR    ${main_menu_value}    ${main_menu.split('menu-')[1]}
    IF    "${child_submenu}" != "NA"
        VAR    ${parent_submenu_value}    ${child_sub_menu.split('submenu-')[1]}
        VAR    ${combined_string}    ${main_menu_value}_${parent_submenu_value}
    ELSE
        VAR    ${parent_submenu_value}    ${parent_submenu.split('main-menu-')[1]}
        VAR    ${combined_string}    ${main_menu_value}_${parent_submenu_value}
    END
    RETURN    ${combined_string}

Handle Iframe If Available
    [Documentation]    Check if the iframe is available, then perform operations; otherwise, skip.
    [Arguments]    ${iframe_id_input}
    VAR    ${dynamic_iframe_xpath}    //iframe[@id='${iframe_id_input}']
    Wait For Elements State    ${dynamic_iframe_xpath}    timeout=${LONG_TIMEOUT}
    Set Selector Prefix    prefix=${dynamic_iframe_xpath} >>>

Navigate Via Non Mywork Menu
    [Documentation]    Navigates to the menu on Non Mywork Integrated Environments
    [Tags]    robot:private
    [Arguments]    ${main_menu_id}    ${parent_submenu_id}    ${child_submenu_id}=NA
    ${is_sidemenu_visible}    Is Element Visible On Webpage    ${main_menu["side_menu_table"]}
    IF    not ${is_sidemenu_visible}
        Run Keyword And Ignore Error    Click Element On Webpage    ${main_menu["hamburger_menu"]}
        ${is_sidemenu_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
        ...    ${main_menu["side_menu_table"]}    timeout=${SHORT_TIMEOUT}
        IF    not ${is_sidemenu_visible}
            Capture Screenshot On Webpage
            Fail    Side Menu not visible!!
        END
    END
    Check And Navigate To Main Menu On Non Mywork Menu    ${main_menu_id}
    IF    "${parent_submenu_id}" == "NA"
        Log    Navigated to "${main_menu_id}" module only
        RETURN
    END
    ${is_child_menu}    Evaluate    """${child_submenu_id}""" != "NA"
    IF    not ${is_child_menu}
        VAR    ${child_submenu_id}    ${parent_submenu_id}
        VAR    ${parent_submenu_id}    img${parent_submenu_id}
    END
    Wait Until Element Is Present On Webpage    ${main_menu["side_menu_table"]}
    ${is_parent_menu_present}    Is Element Present On Webpage    ${parent_submenu_id}
    IF    not ${is_parent_menu_present}
        ${is_ess_parent_present}    Is Element Present On Webpage    ${main_menu["ess_submenu"]}
        IF    ${is_ess_parent_present} and "${main_menu_id}" == "ess"
            VAR    ${parent_submenu_id}    ${main_menu["ess_submenu"]}
        ELSE
            Capture Screenshot On Webpage
            Skip    Parent Submenu """${parent_submenu_id}""" not found!!
        END
    END
    ${is_submenu_visible}    Is Element Visible On Webpage    ${parent_submenu_id}
    IF    not ${is_submenu_visible}
        Click Element On Webpage    ${main_menu["hamburger_menu"]}
        ${is_submenu_visible}    Is Element Visible On Webpage    ${parent_submenu_id}
        IF    not ${is_submenu_visible}
            Click Element On Webpage    ${main_menu["hamburger_menu"]}
            ${is_submenu_visible}    Is Element Visible On Webpage    ${parent_submenu_id}
        END
    END
    IF    ${is_submenu_visible}
        Hover    ${parent_submenu_id}
        Run Keyword And Ignore Error    Wait Until Element Is Visible On Webpage
        ...    ${main_menu["visible_childmenu_list"]}    timeout=2
    ELSE
        Capture Screenshot On Webpage
        Fail    Failed to locate Parent Submenu """${parent_submenu_id}"""!!
    END
    # Some child locators already point directly at the clickable anchor.
    ${child_locator_targets_anchor}    Evaluate    """${child_submenu_id}""".lstrip().startswith(("a[", "a#", "a."))
    IF    ${child_locator_targets_anchor}
        VAR    ${new_child_submenu_id}    ${child_submenu_id}
    ELSE
        VAR    ${new_child_submenu_id}    a[href='#']${child_submenu_id}
    END
    ${is_child_menu_visible}    Is Element Visible On Webpage    ${new_child_submenu_id}
    IF    ${is_child_menu_visible}
        Click Element On Webpage    ${new_child_submenu_id}
    ELSE
        VAR    ${new_parent_submenu_id}    img${child_submenu_id}
        ${is_parent_a_child_menu}    Is Element Visible On Webpage    ${new_parent_submenu_id}
        IF    ${is_parent_a_child_menu}
            Click Element On Webpage    ${new_parent_submenu_id}
        ELSE
            Capture Screenshot On Webpage
            Skip    Child Submenu """${new_child_submenu_id}""" not found!!
        END
    END
    Wait Until Page Is Loaded

Check And Navigate To Main Menu On Non Mywork Menu
    [Documentation]
    ...    Check and navigate to the main menu if it is not visible.
    ...    | =Arguments= | =Description= |
    ...    | main_menu_id | Main menu identifier (e.g., rta, rws, ess, psa). |
    [Arguments]    ${main_menu_id}
    IF    "${main_menu_id}" == "rta"
        ${is_rta_first_parentmenu_visible}    Is Element Visible On Webpage    ${main_menu["rta_first_parent_menu"]}
        IF    not ${is_rta_first_parentmenu_visible}
            Click Element On Webpage    ${main_menu["product_list_icon"]}
            ${is_rta_present}    Is Element Present On Webpage    ${main_menu["product_RTA"]}
            IF    not ${is_rta_present}    Skip    RTA Menu not found!!
            Click Element On Webpage    ${main_menu["product_RTA"]}
        END
    ELSE IF    "${main_menu_id}" == "rws"
        ${is_rws_first_parentmenu_visible}    Is Element Visible On Webpage    ${main_menu["rws_first_parent_menu"]}
        IF    not ${is_rws_first_parentmenu_visible}
            Click Element On Webpage    ${main_menu["product_list_icon"]}
            ${is_rws_present}    Is Element Present On Webpage    ${main_menu["product_RWS"]}
            IF    not ${is_rws_present}    Skip    RWS Menu not found!!
            Click Element On Webpage    ${main_menu["product_RWS"]}
        END
    ELSE IF    "${main_menu_id}" == "ess"
        ${is_ess_first_parentmenu_visible}    Is Element Visible On Webpage    ${main_menu["ess_first_parent_menu"]}
        IF    not ${is_ess_first_parentmenu_visible}
            Click Element On Webpage    ${main_menu["product_list_icon"]}
            ${is_ess_present}    Is Element Present On Webpage    ${main_menu["product_ESS"]}
            IF    not ${is_ess_present}    Skip    ESS Menu not found!!
            Click Element On Webpage    ${main_menu["product_ESS"]}
        END
    ELSE IF    "${main_menu_id}" == "psa"
        Click Element On Webpage    ${main_menu["product_list_icon"]}
        ${is_psa_present}    Is Element Present On Webpage    ${main_menu["product_PSA"]}
        IF    not ${is_psa_present}    Skip    PSA Menu not found!!
        Click Element On Webpage    ${main_menu["product_PSA"]}
    END
    Wait Until Page Is Loaded

Set Date With JavaScript
    [Documentation]    Using java script to set the value of a date input field.
    ...    Bypass browser-specific input issues
    ...    Ensure proper event propagation for Angular to detect the changes
    ...    Directly interact with the DOM which is often more reliable for complex web application
    ...    | =Arguments= | =Description= |
    ...    | locator | The locator for the date input field. |
    ...    | date_value    | Date in the format that locator expects |
    [Arguments]    ${locator}    ${date_value}
    Evaluate JavaScript    ${locator}
    ...    (el) => {
    ...    el.value = "${date_value}";
    ...    // Trigger input event
    ...    const inputEvent = new Event('input', { bubbles: true });
    ...    el.dispatchEvent(inputEvent);
    ...    // Trigger change event
    ...    const changeEvent = new Event('change', { bubbles: true });
    ...    el.dispatchEvent(changeEvent);
    ...    // Trigger blur event to activate the ng-blur function
    ...    const blurEvent = new Event('blur', { bubbles: true });
    ...    el.dispatchEvent(blurEvent);
    ...    return true;
    ...    }

Verify Success Toast Notification
    [Documentation]    Verifies that the toast message notification is displayed in WFM.
    Wait For Elements State    ${SUCCESS_TOAST_POPUP}    visible    timeout=${LONG_TIMEOUT}
    Wait Until Element Disappears On Webpage    ${SUCCESS_TOAST_POPUP}

Input Date In Date Picker Through Input Box
    [Documentation]    Inputs a date into the start date field with proper format
    ...    | =Arguments= | =Description= |
    ...    | date_picker_locator | The locator for the date input field. |
    ...    | pw_date    | Date in the week_day format e.g. 1_1 |
    [Arguments]    ${date_picker_locator}
    ...    ${pw_date}
    ${date_value}    Calculate Date From Week Day Offset    ${pw_date}
    # Format date based on environment - MyWork uses DD/MM/YYYY, non-MyWork uses MM/DD/YYYY
    ${date_format}    Get Config Value    key=DATE_FORMAT_MONTH_DAY_YEAR
    ${formatted_date}    Convert Date    ${date_value}    result_format=${date_format}

    # Ensure formatted_date is a string
    ${formatted_date}    Convert To String    ${formatted_date}

    # Clear existing text and input the new date
    Wait For Elements State    ${date_picker_locator}    visible    timeout=5s

    Set Date With JavaScript    ${date_picker_locator}    ${formatted_date}

    # Verify the date was accepted - check for week start date
    ${current_value}    Get Property    ${date_picker_locator}    value

    # Calculate the week start date for verification
    ${week_start_date}    Calculate Week Start    ${date_value}
    ${expected_week_start}    Convert Date    ${week_start_date}    result_format=${date_format}
    ${expected_week_start}    Convert To String    ${expected_week_start}

    # Verify either the exact date or week start date was accepted
    ${date_matches}    Run Keyword And Return Status
    ...    Should Be Equal    ${current_value}    ${formatted_date}
    ${week_start_matches}    Run Keyword And Return Status
    ...    Should Be Equal    ${current_value}    ${expected_week_start}

    # If neither matches, fail with helpful message
    IF    not ${date_matches} and not ${week_start_matches}
        Fail
        ...    Date input was not accepted correctly. Expected: ${formatted_date} or week start: ${expected_week_start}, but got: ${current_value}
    END

Is Element Present On Webpage
    [Documentation]    Verifies if the element corresponding to provided locator is attached to DOM.
    [Arguments]    ${selector}
    ${state}    Get Element States    ${selector}    then    bool(value & attached)
    RETURN    ${state}

Get Element Count On Web Page
    [Documentation]    Retrieve element count on web page
    [Arguments]    ${locator}
    ${element_count}    Get Element Count    ${locator}
    RETURN    ${element_count}

Is Text Seen On Webpage
    [Documentation]
    ...    Check if the given exact/partial text is seen in the webpage and return True or False.
    ...    | =Arguments= | =Description= |
    ...    | text_value    | The exact text to search for on the webpage. |
    ...    Example usage:
    ...    | Is Text Seen In Webpage    Welcome User
    [Arguments]    ${text_value}
    ${text_length}    Get Length    ${text_value}
    Run Keyword And Return If    ${text_length} == 0
    ...    Fail    Given Text is Empty
    ${is_element_present}    Run Keyword And Ignore Error    Wait For Elements State    text=${text_value}    timeout=${SHORT_TIMEOUT}
    IF    not ${is_element_present}    RETURN    False
    ${count}    Get Element Count    text=${text_value}
    RETURN    ${count} > 0

URL Should Contain
    [Documentation]    Gets the current URL and compares with expected URL
    [Arguments]    ${expected_part}
    ${current_url}    Get URL
    Should Contain    ${current_url}    ${expected_part}

Download File From Webpage
    [Documentation]    Downloads a file from the webpage and returns the suggested filename.
    ...    | =Arguments= | =Description= |
    ...    | file_download_path | The path where the downloaded file should be saved. |
    [Arguments]    ${file_download_path}    ${download_wait_time}=${PAGE_LOAD_TIMEOUT}
    ${download_promise}    Promise To Wait For Download
    ...    saveAs=${file_download_path}    download_timeout=${download_wait_time}
    ${download_info}    Wait For    ${download_promise}
    RETURN    ${download_info.suggestedFilename}

Is Element Disabled On Webpage
    [Documentation]    Verifies if the element corresponding to provided locator is disabled.
    ...    | =Arguments= | =Description= |
    ...    | selector | The locator for the element to be checked |
    ...    | returns | True if the element is disabled, False otherwise |
    [Arguments]    ${selector}
    ${state}    Get Element States    ${selector}    then    bool(value & disabled)
    RETURN    ${state}

Get Text Value Of All Elements Of Given Locator As List
    [Documentation]    This keyword returns the list of all text values of the given locator
    ...    | =Arguments= | =Description= |
    ...    | locator | The locator for the elements to retrieve text from. |
    ...    | =Returns=    | =Description= |
    ...    | values_list    | List of text values from the elements. |
    [Arguments]    ${locator}
    ${elements}    Get Elements    ${locator}
    ${prefix}    Set Selector Prefix    ${NONE}
    TRY
        VAR    @{elem_text_values_list}    @{EMPTY}
        FOR    ${element}    IN    @{elements}
            ${text}    Get Text    ${element}
            Append To List    ${elem_text_values_list}    ${text}
        END
    FINALLY
        Set Selector Prefix    ${prefix}
    END
    RETURN    ${elem_text_values_list}

Does Element State Contain Value On Webpage
    [Documentation]    Checks if the element states contain a specific value.
    ...    Useful for checking complex state combinations or specific state values.
    ...    | =Arguments= | =Description= |
    ...    | selector | The locator for the element to be checked |
    ...    | expected_value | The value to check for in the element states |
    ...    | returns | True if the element states contain the expected value, False otherwise |
    ...    Example usage:
    ...    | Does Element State Contain Value On Webpage    ${BUTTON}    enabled
    ...    | Does Element State Contain Value On Webpage    ${INPUT}    focused
    [Arguments]    ${selector}    ${expected_value}
    ${retry}    ${retry_interval}    Get Config Value    SCHEDULE_WORKFLOW_WAITING_PERIOD
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    Wait Until Element Is Visible On Webpage    ${selector}
    ${state_contains_value}    Run Keyword And Return Status    Get Element States    ${selector}    contains    ${expected_value}
    RETURN    ${state_contains_value}

Scroll And Verify Element Presence On Webpage
    [Documentation]    Scrolls through the page to find the specified web element.
    [Arguments]    ${web_element_locator}
    ${browser_height}    Evaluate JavaScript    ${None}    window.innerHeight
    ${page_height}    Evaluate JavaScript    ${None}    document.body.scrollHeight
    FOR    ${_}    IN RANGE    0    ${page_height}    ${browser_height}
        Mouse Wheel    0    ${browser_height}
        ${element_visible}    Wait Until Element Is Present On Webpage    ${web_element_locator}
        IF    ${element_visible}    BREAK
    END
    Wait Until Page Is Loaded

Click Element And Switch To New Browser Tab On Web
    [Documentation]    This is a keyword to Click on an Element and Switch To New Window by window handle(page id) or NEW
    ...    | =Arguments=    | =Description= |
    ...    | element_selector | The locator for the element to be clicked. |
    ...    | window_handle    | The window handle to switch to. Defaults to NEW for a new window. |
    [Arguments]    ${element_selector}    ${window_handle}=None
    Click Element On Webpage    ${element_selector}
    IF    '${window_handle}' == 'None'
        VAR    ${window_handle}    NEW
    ELSE
        VAR    ${window_handle}    ${window_handle}
    END
    Browser.Switch Page    ${window_handle}

Close Browser Tab On Web
    [Documentation]    This is a keyword to Close Window by window handle(page id) or CURRENT/ALL
    ...    | =Arguments=    | =Description= |
    ...    | window_handle | The window handle to close |
    [Arguments]    ${window_handle}=None
    IF    '${window_handle}' == "None"
        VAR    ${window_handle}    CURRENT
    END
    Browser.Close Page    ${window_handle}

Validate 24 Hour Time Format For Web
    [Documentation]    Validate 24 Hour Time Format.
    ...    Arguments:
    ...    ${time_string}: <Time>
    [Arguments]    ${time_string}
    # Handle special case where 24:00 represents midnight of next day
    ${normalized_time}    Set Variable If    '${time_string}' == '24:00'    00:00    ${time_string}
    TRY
        Evaluate    datetime.datetime.strptime('${normalized_time}', "%H:%M")    datetime
        Log    Time format is valid: ${time_string}
    EXCEPT
        Fail    Invalid time format: ${time_string}
    END

Convert Time From 24 Hour To 12 Hour Format For Web
    [Documentation]    Formats the time string from 24 hour to 12 hour format based on profile configuration.
    ...    Arguments:
    ...    - ${24_hrs_time_format}: The time 24 hour string to be formatted in format configured in profile variation.
    [Arguments]    ${24_hrs_time_format}
    Validate 24 Hour Time Format For Web    ${24_hrs_time_format}
    ${is_time_format_12hrs}    Get Config Value    key=TIME_FORMAT_12_HRS
    IF    ${is_time_format_12hrs}
        ${formatted_time}    Convert 24hr Time To 12hr    ${24_hrs_time_format}
    ELSE
        VAR    ${formatted_time}    ${24_hrs_time_format}
    END
    VAR    ${am_suffix}    a
    VAR    ${pm_suffix}    p
    ${localised_formated_time}    Evaluate
    ...    '${formatted_time}'.replace('AM', '${am_suffix}').replace('PM', '${pm_suffix}')
    RETURN    ${localised_formated_time}

Convert UI Time Format To 24 Hour Format For Web
    [Documentation]    Converts time from UI format (12hr or 24hr) to 24hr format for verification/comparison.
    ...
    ...    This keyword intelligently detects the time format and converts accordingly:
    ...    - If time is in 12hr format (contains 'a' or 'p'): Converts to 24hr format
    ...    - If time is already in 24hr format: Returns as-is
    ...    - Handles overnight shifts with dash prefix for both formats (e.g., "- 05:00p" → "17:00", "- 16:00" → "16:00")
    ...
    ...    | =Arguments= | =Description= |
    ...    | time_string | Time string in either 12hr UI format (e.g., "08:00a", "- 05:00p") or 24hr format (e.g., "08:00") |
    ...
    ...    | =Returns= | =Description= |
    ...    | time_24hr | Time in 24hr format (HH:MM) |
    ...
    ...    Example usage:
    ...    | ${time_24hr} | Convert UI Time Format To 24 Hour Format For Web | 08:00a |
    ...    | ${time_24hr} | Convert UI Time Format To 24 Hour Format For Web | - 05:00p |
    ...    | ${time_24hr} | Convert UI Time Format To 24 Hour Format For Web | 08:00 |
    ...    | ${time_24hr} | Convert UI Time Format To 24 Hour Format For Web | - 16:00 |
    [Arguments]    ${time_string}
    ${time_24hr}    Convert UI Time To 24hr    ${time_string}
    RETURN    ${time_24hr}

Convert Time From 12 Hour To 24 Hour Format For Web
    [Documentation]    Converts a 12-hour time string (AM/PM or a/p) into 24-hour HH:MM.
    ...    | =Arguments= | =Description= |
    ...    | 12_hrs_time_format | Time string in 12-hour format (e.g., 09:00 AM, 9:00pm, 09:00a). |
    ...    Example usage:
    ...    | ${time_fetched}    Convert Time From 12 Hour To 24 Hour Format For Web    09:15 PM
    ...    | # Returns: 21:15
    [Arguments]    ${12_hrs_time_format}
    ${ante_meridiem}    Get System Value    TimeIndicators    ANTE_MERIDIEM
    ${post_meridiem}    Get System Value    TimeIndicators    POST_MERIDIEM
    ${raw_string}    Convert To String    ${12_hrs_time_format}
    ${raw}    Strip String    ${raw_string}
    ${upper}    Convert To Upper Case    ${raw}
    # Support environments using 'a'/'p' suffixes by mapping to AM/PM
    ${upper}    Replace String    ${upper}    A    ${ante_meridiem}
    ${upper}    Replace String    ${upper}    P    ${post_meridiem}
    # Check if AM/PM suffix exists
    ${suffix_matches}    Get Regexp Matches    ${upper}    (AM|PM)$
    # If no AM/PM present, assume already 24-hour and return as-is
    IF    not ${suffix_matches}    RETURN    ${upper}
    # Extract suffix and time part
    ${suffix}    Get From List    ${suffix_matches}    0
    ${time_part}    Replace String Using Regexp    ${upper}    (AM|PM)$    ${EMPTY}
    ${time_part}    Strip String    ${time_part}
    # Rebuild with single space before suffix
    VAR    ${upper}    ${time_part} ${suffix}
    # Parse and convert to 24-hour HH:MM
    TRY
        ${24_hour_format}    Get Config Value    WEB_CLOCK_PARSE_TIME_FORMAT_24HR
        ${twenty_four}    Evaluate    datetime.datetime.strptime('''${upper}''', "%I:%M %p").strftime("${24_hour_format}")    datetime
        RETURN    ${twenty_four}
    EXCEPT
        Fail    Invalid 12-hour time format: ${12_hrs_time_format}. Expected like '09:00 AM' or '9:00pm'.
    END

Reload Web Page
    [Documentation]    Reload Web Page and handle popup that appears after reload
    Reload
    Wait For Load State    networkidle    timeout=${MEDIUM_TIMEOUT}
    # Handle popup/alert that appears after reload
    TRY
        # Accept any browser dialog/alert that may appear
        Run Keyword And Ignore Error    Accept Browser Dialog
        Log    Successfully handled popup after page reload
    EXCEPT
        Log    No popup appeared after page reload or popup handling failed
    END

Clean Leading And Trailing Space On Text
    [Documentation]
    ...    Removes leading and trailing whitespace from text if present.
    ...    Returns the original text if no whitespace needs to be removed.
    ...    | =Arguments=    | =Description=    |
    ...    | text_input    | The text to clean    |
    ...    Example usage:
    ...    | ${clean_text}    Clean Leading Space Of Text    ${user_input}
    [Arguments]    ${text_input}
    ${cleaned_text}    Strip String    ${text_input}
    RETURN    ${cleaned_text}

Get Selected Value In Dropdown On Web
    [Documentation]    Keyword to return selected option in a dropdown
    ...    | =Arguments=    | =Description=    |
    ...    | element    | The locator for the dropdown element.    |
    ...    | =Returns=    | =Description=    |
    ...    | selected_option    | The selected option in the dropdown.    |
    [Arguments]    ${element}
    ${options_list}    Browser.Get Selected Options    ${element}
    ${selected_option}    Get From List    ${options_list}    0
    RETURN    ${selected_option}

Convert Hours To Minutes On Web
    [Documentation]    Converts hours to minutes.
    ...    | =Arguments=    | =Description=    |
    ...    | hours_input    | The number of hours to convert.    |
    ...    Example usage:
    ...    | ${minutes}    Convert Hours To Minutes On Web    2.5
    [Arguments]    ${hours_input}
    ${hour_text_parts}    Split String    ${hours_input}    .
    ${hours}    Convert To Integer    ${hour_text_parts[0]}
    VAR    ${minutes}    0
    IF    len(${hour_text_parts}) > 1
        VAR    ${decimal}    0.${hour_text_parts[1]}
        ${minutes}    Evaluate    int(round(float(${decimal}) * 60))
    END
    ${minutes_value}    Evaluate    ${hours} * 60 + ${minutes}
    RETURN    ${minutes_value}

Click Element With Fallback On Web
    [Documentation]    Click element with fallback option - migrated from legacy framework
    [Arguments]    ${locator1}    ${locator2}
    ${status}    Run Keyword And Return Status    Click Element On Webpage    ${locator2}
    IF    '${status}' == 'False'    Click Element On Webpage    ${locator1}

Wait Until Element Disappears With Refresh
    [Documentation]
    ...    Waits for an element to disappear, clicking a refresh button at intervals if it's still visible.
    ...    This is useful for waiting for loading indicators, notifications, or temporary elements to disappear.
    ...    | =Arguments=    | =Description=    |
    ...    | target_element    | The element locator to wait for disappearance    |
    ...    | refresh_button    | The refresh button locator to click if element is still visible    |
    ...    | max_attempts    | Maximum number of refresh attempts (default: 10)    |
    ...    | interval    | Time to wait between refresh attempts in seconds (default: 5)    |
    ...    Example usage:
    ...    | Wait Until Element Disappears With Refresh    ${LOADING_SPINNER}    ${REFRESH_BUTTON}
    ...    | Wait Until Element Disappears With Refresh    ${NOTIFICATION}    ${REFRESH_BUTTON}    max_attempts=15    interval=3
    [Arguments]    ${target_element}    ${refresh_button}    ${max_attempts}    ${interval}

    # Convert max_attempts to integer for mathematical operations
    ${max_attempts_int}    Convert To Integer    ${max_attempts}

    FOR    ${attempt}    IN RANGE    1    ${max_attempts_int}
        Log    Attempt ${attempt}/${max_attempts}: Checking if element has disappeared

        # Try to wait for element to disappear using existing keyword
        ${disappeared}    Run Keyword And Return Status
        ...    Wait Until Element Disappears On Webpage    ${target_element}    timeout=${interval}s

        IF    ${disappeared}
            Log    Element ${target_element} has disappeared after ${attempt} attempt(s)
            # Click refresh button after element disappears
            Click Element On Webpage    ${refresh_button}
            Log    Refresh button clicked after element disappeared
            RETURN
        END

        # Element still visible, click refresh and continue
        Log    Element still visible, clicking refresh button (attempt ${attempt}/${max_attempts})
        Click Element On Webpage    ${refresh_button}

        # Wait for page to stabilize after refresh
        TRY
            Wait Until Page Is Loaded    timeout=${interval}s
        EXCEPT
            Wait Until Page Is Loaded
        END
    END

    # If we reach here, all attempts failed
    Fail    Element ${target_element} did not disappear after ${max_attempts} refresh attempts

Select Date Through Date Picker For ESS Requests On Webpage
    [Documentation]    Selects a date through the date picker widget on the webpage.
    ...    | =Arguments=    | =Description=    |
    ...    | date_picker_locator | The locator for the date picker input field.    |
    ...    | target_date    | Date in offset format e.g.: 1_1 for next week's first day    |
    [Arguments]    ${date_picker_locator}    ${target_date_offset}
    ${date_result_format}    Get Config Value    DATE_FMT_DAY_ONLY
    ${month_result_format}    Get Config Value    DATE_FORMAT_MONTH_ONLY
    ${year_result_format}    Get Config Value    DATE_FORMAT_YEAR_ONLY
    ${date_day}    ${date_month}    ${date_year}    Calculate Date From Week Day Offset In Multiple Formats
    ...    ${target_date_offset}    ${date_result_format}    ${month_result_format}    ${year_result_format}
    Click Until Element Is Visible On Web    ${date_picker_locator}    ${COMMON_REQUESTS_CALENDAR_DATE_PICKER_MONTH_HEADING}
    Click Element On Webpage    ${COMMON_REQUESTS_CALENDAR_DATE_PICKER_MONTH_HEADING}
    Click Element On Webpage    ${COMMON_REQUESTS_CALENDAR_DATE_PICKER_YEAR_HEADING}
    ${date_last_two_digits}    Evaluate    '${date_year}'[-2:]
    ${year_to_be_selected}    Replace String    ${COMMON_REQUESTS_CALENDAR_DATE_PICKER_YEAR_LOCATOR}    {YEAR_TWO_DIGITS}
    ...    ${date_last_two_digits}
    Click Element On Webpage    ${year_to_be_selected}
    ${date_shortened_month}    Evaluate    '${date_month}'[:3]
    ${month_to_be_selected}    Replace String    ${COMMON_REQUESTS_CALENDAR_DATE_PICKER_MONTH_LOCATOR}    {MONTH_NAME}    ${date_month}
    Click Element On Webpage    ${month_to_be_selected}
    ${day_to_be_selected}    Replace String    ${COMMON_REQUESTS_CALENDAR_DATE_PICKER_DAY_LOCATOR}    {SHORTENED_MONTH}
    ...    ${date_shortened_month}
    ${day_to_be_selected}    Replace String    ${day_to_be_selected}    {DATE}    ${date_day}
    Click Element On Webpage    ${day_to_be_selected}
    Run Keyword And Ignore Error
    ...    Wait Until Element Disappears On Webpage    ${date_picker_locator}    timeout=${MEDIUM_TIMEOUT}
    Wait Until Element Disappears On Webpage    ${COMMON_REQUESTS_CALENDAR_DATE_PICKER_SELECTION_MODE}
    Wait Until Element Is Visible On Webpage    ${date_picker_locator}    timeout=${LONG_TIMEOUT}
    ...    error_message=Date not changed to selected date after selection through date picker!!
    Wait Until Page Is Loaded

Is Text Present In The Element On Webpage
    [Documentation]    Returns true/false based on the presence of the given text in the element located by locator.
    ...    | =Arguments=    | =Description=    |
    ...    | text_value    | The text to check for presence in the element    |
    ...    | selector    | The locator for the element to check    |
    [Arguments]    ${text_value}    ${selector}
    ${text_value_from_element}    Get Element Text On Webpage    ${selector}
    ${is_present}    Evaluate    '${text_value}' in '${text_value_from_element}'
    RETURN    ${is_present}

Close New Tab
    [Documentation]    This Keyword used to close new tab
    Close Page    CURRENT    CURRENT    CURRENT

Switch Back To First Opened Page Tab On Web
    [Documentation]    Switches back to the first opened page tab.
    ${pages}    Get Page Ids
    Switch Page    ${pages}[0]
    Wait Until Page Is Loaded

Toggle Checkbox In Checked Or Unchecked State On Web
    [Documentation]
    ...    Toggles checkbox preference to match desired state.
    ...    Only clicks if current state differs from desired state.
    ...    | =Arguments= | =Description= |
    ...    | checkbox_locator | Locator for the checkbox element. |
    ...    | desired_state | True to check, False to uncheck. |
    ...    | checkbox_input_locator | (Optional) Locator for the checkbox input element to verify state. |
    ...    | attribute | (Optional) Attribute to verify checkbox state (e.g., 'checked'). |
    ...    | expected_attribute_value | (Optional) Expected value of the attribute to determine checkbox state. |
    [Arguments]    ${checkbox_locator}
    ...    ${desired_state}
    ...    ${checkbox_input_locator}=${None}
    ...    ${attribute}=${None}
    ...    ${expected_attribute_value}=${None}
    VAR    ${is_checked}    False
    IF    '${attribute}' != '${None}' and '${expected_attribute_value}' != '${None}'
        ${actual_attribute_value}    Get Attribute    ${checkbox_input_locator}    ${attribute}
        ${is_checked}    Run Keyword And Return Status    Should Contain
        ...    ${actual_attribute_value}    ${expected_attribute_value}
    END
    IF    ${desired_state} and not ${is_checked}
        Click Element On Webpage    ${checkbox_locator}
        Log    Checked: ${checkbox_locator}
    ELSE IF    not ${desired_state} and ${is_checked}
        Click Element On Webpage    ${checkbox_locator}
        Log    Unchecked: ${checkbox_locator}
    ELSE
        Log    Checkbox already in desired state.
    END

Close Window
    [Documentation]    This is a wrapper method used to Close Window by window handle(page id) or CURRENT / ALL.
    [Arguments]    ${window_handle}=None
    ${window_handle}    Set Variable If    '${window_handle}' == "None"    CURRENT    ${window_handle}
    Browser.Close Page    ${window_handle}

Switch To New Window On Web
    [Documentation]    This is a wrapper keyword used to Switch To New Window by window handle(page id) or NEW.
    [Arguments]    ${window_handle}=None
    ${window_handle}    Set Variable If    '${window_handle}' == "None"    NEW    ${window_handle}
    Browser.Switch Page    ${window_handle}

Get Active IFrame Element
    [Documentation]    Get the first visible iframe element (active frame) from the top-level document.
    ...    Temporarily clears any selector prefix to search in the main document context.
    ...    | =Returns= | =Description= |
    ...    | iframe_element | The first visible iframe element, or empty string if none found |
    ...    Example usage:
    ...    | ${iframe}=    Get Active IFrame Element
    Set Selector Prefix    ${None}

    TRY
        ${iframes}    Get Elements    iframe
        FOR    ${iframe}    IN    @{iframes}
            ${result}    Is Element Visible On Webpage    ${iframe}
            IF    ${result}
                Log    Active iframe found: ${iframe}
                RETURN    ${iframe}
            END
        END
        Log    No active (visible) iframe found.
        # Set Selector Prefix    ${prefix}
        RETURN    ${EMPTY}
    EXCEPT    AS    ${error}
        Log    Error while searching for iframes: ${error}    level=WARN
        # Set Selector Prefix    ${prefix}
        RETURN    ${EMPTY}
    END

Verify Visibility Of Frame Element
    [Documentation]    Verify the visibility of a frame element.
    ...    |    Example    |
    ...    | Verify Visibility Of Frame Element    |    iframe_locator    |    element_locator    |    10s    |
    [Arguments]    ${iframe}    ${locator}
    ${selector}    Get Frame Element    ${iframe}    ${locator}
    ${result}    Is Element Visible On Webpage    ${selector}
    RETURN    ${result}

Get Frame Element
    [Documentation]    This keyword gets the combined locator for an element inside nested iframes.
    [Arguments]    @{iframes}
    VAR    ${locator}    ${EMPTY}

    FOR    ${frame}    IN    @{iframes}
        ${locator_value}    Run Keyword And Return Status    Should Be Empty    ${locator}
        IF    ${locator_value}
            ${locator}    Catenate    ${frame}
        ELSE
            ${locator}    Catenate    ${locator} >>> ${frame}
        END
    END
    RETURN    ${locator}

Capture And Return Full Screenshot File Path
    [Documentation]    Captures a full screenshot and returns the file path.
    ${screenshot_path}    Take Screenshot    fullPage=True
    RETURN    ${screenshot_path}

Get All Options From Dropdown On Web
    [Documentation]    Keyword to return all options in a dropdown
    ...    | =Arguments=    | =Description=    |
    ...    | element    | The locator for the dropdown element. |
    ...    | =Returns=    | =Description=    |
    ...    | options_list    | List of all options in the dropdown. |
    [Arguments]    ${element}
    ${options_list}    Browser.Get Select Options    ${element}
    RETURN    ${options_list}

Drag And Drop Element On Webpage
    [Documentation]    Drags an element from source locator and drops it to target locator.
    ...    | =Arguments=    | =Description=    |
    ...    | source_locator | The locator for the source element to be dragged. |
    ...    | target_locator | The locator for the target element where the source will be dropped. |
    ...    | steps | (Optional) Number of intermediate steps for the drag action. Default is 2. |
    ...    | post_drag_locator | (Optional) Locator of the element to wait for after the drag completes. Defaults to target_locator. |
    ...    | post_drag_state | (Optional) Desired state of post_drag_locator to wait for after the drag completes. Default is visible. |
    ...    Example usage:
    ...    | Drag And Drop Element On Webpage    ${SOURCE}    ${TARGET} |
    ...    | Drag And Drop Element On Webpage    ${SOURCE}    ${TARGET}    steps=3    post_drag_locator=${CONFIRM_LOCATOR}    post_drag_state=visible |
    [Arguments]    ${source_locator}
    ...    ${target_locator}
    ...    ${steps}=10
    ...    ${post_drag_locator}=${target_locator}
    ...    ${post_drag_state}=visible
    Wait For Elements State    ${source_locator}    visible    timeout=${MEDIUM_TIMEOUT}
    Wait For Elements State    ${target_locator}    visible    timeout=${MEDIUM_TIMEOUT}

    ${drag_promise}    Promise To    Wait For Elements State    ${post_drag_locator}
    ...    state=${post_drag_state}
    ...    timeout=${LONG_TIMEOUT}

    Drag And Drop    ${source_locator}    ${target_locator}    steps=${steps}
    Wait For    ${drag_promise}

Scroll Element To Center Of Webpage
    [Documentation]    Scrolls the page so the target element is centered in the viewport.
    ...    Ensures the element is attached and visible before scrolling.
    ...    | =Arguments= | =Description= |
    ...    | web_element_locator | The locator for the web element to scroll into view. |
    ...    | timeout | (Optional) Maximum time to wait for element presence and visibility. Default is ${MEDIUM_TIMEOUT}. |
    ...    Example usage:
    ...    | Scroll Element To Center Of Webpage    ${ELEMENT_LOCATOR}    ${TIMEOUT} |
    [Arguments]    ${web_element_locator}    ${timeout}=${MEDIUM_TIMEOUT}
    Wait Until Element Is Present On Webpage    ${web_element_locator}    timeout=${timeout}
    Wait For Elements State    ${web_element_locator}    visible    timeout=${timeout}
    Evaluate JavaScript    ${web_element_locator}
    ...    (el) => {el.scrollIntoView({ block: 'center', inline: 'center' }); return true;}
    Wait Until Element Is Visible On Webpage    ${web_element_locator}    timeout=${timeout}
    Wait Until Page Is Loaded

Wait Until Element Appears With Refresh On Web
    [Documentation]
    ...    Waits for an element to appear, clicking a refresh button at intervals if it's not visible yet.
    ...    This is useful for waiting for status updates, notifications, or elements that require page refresh to appear.
    ...    | =Arguments=    | =Description=    |
    ...    | target_element    | The element locator to wait for appearance    |
    ...    | refresh_button    | The refresh button locator to click if element is not visible    |
    ...    | max_attempts    | Maximum number of refresh attempts (default: 10)    |
    ...    | interval    | Time to wait between refresh attempts in seconds (default: 5)    |
    ...    Example usage:
    ...    | Wait Until Element Appears With Refresh On Web    ${PAYFILE_STATUS}    ${REFRESH_BUTTON}    max_attempts=20    interval=10
    [Arguments]    ${target_element}    ${refresh_button}    ${max_attempts}=10    ${interval}=5

    # Calculate total timeout based on max_attempts and interval
    ${total_timeout}    Evaluate    ${max_attempts} * ${interval}

    # Use Wait Until Keyword Succeeds to retry the check and refresh operation
    Wait Until Keyword Succeeds
    ...    ${total_timeout}s
    ...    ${interval}s
    ...    Check Element Presence And Refresh Page If Element Is Not Visible On Web
    ...    ${target_element}
    ...    ${refresh_button}
    ...    ${interval}

Check Element Presence And Refresh Page If Element Is Not Visible On Web
    [Documentation]
    ...    Helper keyword that checks if an element is visible, and if not, clicks the refresh button.
    ...    This keyword is designed to be used with Wait Until Keyword Succeeds.
    ...    | =Arguments=    | =Description=    |
    ...    | target_element    | The element locator to wait for appearance    |
    ...    | refresh_button    | The refresh button locator to click if element is not visible    |
    ...    | interval    | Time to wait for element visibility in seconds    |
    [Arguments]    ${target_element}    ${refresh_button}    ${interval}

    # Check if element is already visible
    ${is_element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${target_element}
    ...    timeout=${interval}s    error_message=Element ${target_element} not visible

    # If element is visible, we're done
    IF    ${is_element_visible}
        Log    Element ${target_element} has appeared
        RETURN
    END

    # Element not visible - click refresh button to trigger update
    Click Element On Webpage    ${refresh_button}    error_message=Failed to click refresh button

    # Wait for page to stabilize after refresh
    Wait Until Page Is Loaded    timeout=${interval}s

    # Check if element is now visible after refresh - this will trigger retry if it fails
    Wait Until Element Is Visible On Webpage    ${target_element}    timeout=${interval}s
    ...    error_message=Element ${target_element} not yet visible after refresh

Switch To Page On Web
    [Documentation]    Switches to the requested page handle with retry and waits for page load.
    ...    Useful when switching to NEW page/tab where creation can be delayed.
    ...    Uses Wait Until Keyword Succeeds for robust retry logic.
    ...    | =Arguments= | =Description= |
    ...    | window_handle | The page id/handle to switch to. Default is NEW. |
    ...    | timeout | Maximum time to wait for page switch and load. Default is MEDIUM_TIMEOUT. |
    ...    | =Returns= | =Description= |
    ...    | page_id | The page ID of the switched page. |
    [Arguments]    ${window_handle}=NEW    ${timeout}=${LONG_PAGE_LOAD_TIMEOUT}
    ${page_id}    Wait Until Keyword Succeeds
    ...    ${timeout}
    ...    1s
    ...    Browser.Switch Page    ${window_handle}
    Wait Until Page Is Loaded    timeout=${timeout}
    RETURN    ${page_id}

Get Day Number Based On Fiscal Week Start Day On Web
    [Documentation]    Calculates the day of the week based on the fiscal week start day configuration.
    ...    | =Arguments= | =Description= |
    ...    | day_num | The original day number (1-7) to be converted based on fiscal week start. |
    ...    | =Returns= | =Description= |
    ...    | day_of_week | The calculated day of the week (1-7) based on fiscal week start. |
    [Arguments]    ${day_num}
    ${day_num_int}    Convert To Integer    ${day_num}
    ${fiscal_week_start}    Get Config Value    FISCAL_WEEK_START_DAY
    ${fiscal_start_day_int}    Convert To Integer    ${fiscal_week_start}
    ${day_of_week}    Evaluate    ((${day_num_int} - ${fiscal_start_day_int} + 7) % 7)
    ${day_of_week}    Convert To String    ${day_of_week}
    RETURN    ${day_of_week}

Is Number Of Days Within Range Of Week Day Offset Value On Web
    [Documentation]    Determines whether the given number of days is within the actual number of days from today until the date represented by the week day offset.
    ...    | =Arguments= | =Description= |
    ...    | number_of_days | The number of days to compare. |
    ...    | week_day_offset | The week day offset value in the format "week_day" (e.g., "1_3" for 1 week and 3 days). |
    ...    | =Returns= | =Description= |
    ...    | is_within_range | True if number_of_days is less than or equal to the number of whole days from today until the target date, False otherwise. |
    [Arguments]    ${number_of_days}    ${week_day_offset}
    ${days}    Convert To Integer    ${number_of_days}
    ${target_date}    Calculate Date From Week Day Offset    ${week_day_offset}
    ${today}    Get Current Date
    ${target_datetime}    Convert Date    ${target_date}
    ${seconds_until_target}    Subtract Date From Date    ${target_datetime}    ${today}    result_format=number
    ${days_until_target}    Evaluate    int(${seconds_until_target} / 86400)
    ${is_within_range}    Evaluate    ${days} <= ${days_until_target}
    RETURN    ${is_within_range}

Verify Header Week Start Date On Week Label On Web
    [Documentation]    This keyword verifies that the date on week label on header is correct based on the week day offset provided
    ...    | =Arguments= | =Description= |
    ...    | week_day_offset | The week day offset to calculate the expected date on week label |
    ...    | week_label_selector | The locator for the week label element on the header to verify the date text |
    [Arguments]    ${week_day_offset}    ${week_label_selector}
    ${date_format}    Get Config Value    CALENDAR_NAVIGATION_DATE_FORMAT
    ${week_start_date}    Calculate Week Start Date From Week Day Offset    ${week_day_offset}    ${date_format}
    ${actual_week_label}    Get Element Text On Webpage    ${week_label_selector}
    Should Contain    ${actual_week_label}    ${week_start_date}
    ...    msg=Expected week label to contain '${week_start_date}' but actual label was '${actual_week_label}'
    Log    Verified date on week label: expected to contain '${week_start_date}', actual label: '${actual_week_label}'

Convert Day Number By Fiscal Week Start
    [Documentation]
    ...    Converts a day number based on the configured fiscal week start day.
    ...    Adjusts the original day position (0-6 range) to align with the fiscal week start configuration.
    ...    | =Arguments= | =Description= |
    ...    | day_num | The original day number (0-6) to be converted based on fiscal week start. |
    ...
    ...    *Returns*: The calculated day of the week (0-6) based on fiscal week start configuration.
    ...
    ...    Example usage:
    ...    | ${adjusted_day}=    Convert Day Number By Fiscal Week Start    3
    ...    | Log    Adjusted day: ${adjusted_day}
    [Arguments]    ${day_num}
    ${day_num_int}    Convert To Integer    ${day_num}
    ${fiscal_week_start}    Get Config Value    FISCAL_WEEK_START_DAY
    ${fiscal_start_day_int}    Convert To Integer    ${fiscal_week_start}
    ${day_of_week}    Evaluate    ((${fiscal_start_day_int} - ${day_num_int} + 6) % 7)
    ${day_of_week}    Convert To String    ${day_of_week}
    RETURN    ${day_of_week}

Reverse Day Number Based On Fiscal Week Start Day On Web
    [Documentation]    Reverses the fiscal week day conversion back to the original day number.
    ...    This is the inverse operation of 'Get Day Number Based On Fiscal Week Start Day On Web'.
    ...    Converts from fiscal week-based day (0-6) back to standard day number (0-6).
    ...    FISCAL_WEEK_START_DAY uses 1-7 numbering (1=Sunday, 2=Monday, ..., 7=Saturday).
    ...    Standard day_number uses 0-6 numbering (0=Sunday, 1=Monday, ..., 6=Saturday).
    ...    | =Arguments= | =Description= |
    ...    | fiscal_day_num | The fiscal week-based day number (0-6) to be converted back to original day. |
    ...    | =Returns= | =Description= |
    ...    | original_day_num | The original day number (0-6) before fiscal week conversion. |
    [Arguments]    ${fiscal_day_num}
    ${fiscal_day_int}    Convert To Integer    ${fiscal_day_num}
    ${fiscal_week_start}    Get Config Value    FISCAL_WEEK_START_DAY
    ${fiscal_start_day_int}    Convert To Integer    ${fiscal_week_start}
    ${original_day}    Evaluate    (${fiscal_day_int} - ${fiscal_start_day_int} + 1) % 7
    ${original_day}    Convert To String    ${original_day}
    RETURN    ${original_day}

Click Until Element Is Visible On Web
    [Documentation]    Clicks on a specified element repeatedly until another target element appears or a maximum number of attempts is reached.
    ...    | =Arguments= | =Description= |
    ...    | click_element_locator | The locator for the element to be clicked. |
    ...    | target_element_locator | The locator for the element to wait for appearance. |
    ...    | max_attempts | (Optional) Maximum number of click attempts. Default is 10. |
    ...    | wait_timeout | (Optional) Time to wait for the target element to become visible. Default is ${SHORT_TIMEOUT}. |
    [Arguments]    ${click_element_locator}    ${target_element_locator}    ${max_attempts}=10    ${wait_timeout}=${SHORT_TIMEOUT}
    ${max_attempts_int}    Convert To Integer    ${max_attempts}
    FOR    ${_}    IN RANGE    ${max_attempts_int}
        Click Element On Webpage    ${click_element_locator}    error_message=Failed to click element ${click_element_locator}
        ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage    ${target_element_locator}
        ...    timeout=${wait_timeout}
        IF    ${is_visible}
            Log    Target element appeared after clicking ${click_element_locator}
            RETURN
        END
        Log    Target element not visible yet, retrying...
    END
    Fail    Target element ${target_element_locator} did not appear after ${max_attempts} attempts of clicking ${click_element_locator}

Get Test Case ID From Tags
    [Documentation]
    ...    Retrieves the test case ID from the current running test's tags.
    ...    Searches for the first tag starting with 'sittc' or 'battc' and returns it.
    ...
    ...    *Returns*: The test case ID tag string (e.g., 'sittc00111' or 'battc00234').
    ...    Fails if no matching tag is found.
    ...
    ...    Example usage:
    ...    | ${tc_id}=    Get Test Case ID From Tags
    ...    | Log    Test Case ID: ${tc_id}
    FOR    ${tag}    IN    @{TEST TAGS}
        ${tag_lower}    Convert To Lower Case    ${tag}
        ${is_match}    Evaluate    $tag_lower.startswith('sittc') or $tag_lower.startswith('battc')
        IF    ${is_match}    RETURN    ${tag_lower}
    END
    Log    No test case ID tag found (expected 'sittc*' or 'battc*') in tags: ${TEST TAGS}, Please provide a valid test case ID tag in the test case.    WARN
