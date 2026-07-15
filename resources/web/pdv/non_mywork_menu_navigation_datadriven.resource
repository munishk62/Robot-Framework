*** Settings ***
Documentation       Keywords for generating DataDriver CSV from visible non-MyWork menu items
...                 and validating page load for each menu path.
...                 Pabot-safe CSV generation uses ``Acquire Lock`` / ``Release Lock`` plus a per-user CSV path.

Library             OperatingSystem
Library             String
Library             pabot.PabotLib
Library             resources/common/library/BrowserPresenterModeLibrary.py
Resource            resources/web/pdv/pdv_menu_datadriver_shared.resource
Resource            resources/web/pdv/non_mywork_menu_navigation.resource
Resource            resources/web/authentication/login.resource


*** Keywords ***
Generate PDV Non-MyWork Child Menu CSV With Params And Return Config
    [Documentation]
    ...    Builds a comma-separated CSV for DataDriver by discovering visible child menu items for the given user and module in non-MyWork mode.
    ...
    ...    Safe under Pabot: DataDriver calls the suite ``config_keyword`` wrapper in every worker. ``Acquire Lock`` / ``Release Lock`` with a lock name derived from user and module ensures one worker writes the CSV while others wait, then all read the same file.
    ...
    ...    The CSV path is stored in suite variable ``${PDV_DATADRIVER_CHILD_MENU_CSV}`` (from shared PDV resources) before any keyword arguments cross PabotLib bridges (avoids Windows path mangling).
    ...
    ...    | =Arguments= | =Description= |
    ...    | original_config | Original DataDriver config map |
    ...    | user_key | Credential key (e.g. ``SM1_STORE1``, ``SYSADMIN``) |
    ...    | module_name | Module route/name (e.g. ``rws``) |
    ...    | locale | Locale passed to ``Login And Launch WFM Web App`` during CSV discovery |
    ...
    ...    | =Returns= | =Description= |
    ...    | new_config | DataDriver config map with generated CSV ``file=`` path |
    [Arguments]    ${original_config}    ${user_key}    ${module_name}    ${locale}
    Log    DataDriver original config: ${original_config}    level=DEBUG
    ${csv_dir}=    Normalize Path    ${EXECDIR}${/}test_data${/}generated
    Create Directory    ${csv_dir}
    ${csv_file}=    Normalize Path
    ...    ${csv_dir}${/}pdv_non_mywork_${module_name}_child_menus_${user_key}.csv
    VAR    ${PDV_DATADRIVER_CHILD_MENU_CSV}=    ${csv_file}    scope=SUITE
    ${lock_name}=    Catenate    SEPARATOR=_    pdv_non_mywork_menu_csv    ${user_key}    ${module_name}
    Acquire Lock    ${lock_name}
    ${csv_exists}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${csv_file}
    IF    not ${csv_exists}
        Write Non-MyWork Child Menu Csv On Web    ${csv_file}    ${user_key}    ${module_name}    ${locale}
        Wait Until Keyword Succeeds    120x    500ms    Pdv Menu Csv File Looks Ready On Web    ${csv_file}
    ELSE
        Log    CSV already present, skipping discovery: ${csv_file}
    END
    Release Lock    ${lock_name}
    VAR    &{new_config}=    file=${csv_file}
    RETURN    ${new_config}

Remove PDV Non-MyWork Child Menu Csv For Suite
    [Documentation]
    ...    Deletes the generated PDV menu CSV for this suite. Delegates to ``Remove PDV Datadriven Child Menu Csv For Suite``.
    Remove PDV Datadriven Child Menu Csv For Suite

Write Non-MyWork Child Menu Csv On Web
    [Documentation]
    ...    Opens a browser, discovers visible parent/child menu labels for the given user and module, and writes a DataDriver CSV.
    ...
    ...    Writes to ``${csv_file}.tmp`` then moves to ``${csv_file}`` so readers never see a half-written file.
    ...
    ...    | =Arguments= | =Description= |
    ...    | csv_file | Destination CSV path |
    ...    | user_key | Credential key (e.g. ``SM1_STORE1``, ``ESS2_STORE1``, ``SYSADMIN``) |
    ...    | module_name | Module route/name passed to ``Navigate To Specific Page On Web`` (e.g. ``rws``) |
    ...    | locale | Locale for ``Login And Launch WFM Web App`` during discovery |
    [Arguments]    ${csv_file}    ${user_key}    ${module_name}    ${locale}
    VAR    ${csv_tmp}=    ${csv_file}.tmp
    Run Keyword And Ignore Error    Remove File    ${csv_tmp}
    Run Keyword And Ignore Error    Remove File    ${csv_file}
    Create File    ${csv_tmp}    \${parent_menu},\${child_menu},\${page_name}\n
    Push Browser Presenter Mode Disabled
    TRY
        Login And Launch WFM Web App    user_key=${user_key}    locale=${locale}
        Verify Successful Login To WFM Application
        Navigate To Specific Page On Web    ${module_name}
        Log    PDV non-MyWork CSV discovery module=${module_name}    level=DEBUG
        Ensure Breadcrumb Menu Is Expanded For DataDriver On Web
        @{parent_pages}=    Get Elements    ${PARENT_PAGES}
        FOR    ${parent_page}    IN    @{parent_pages}
            ${parent_name}=    Get Sanitized Menu Text On Web    ${parent_page}
            Hover    ${parent_page}
            Sleep    1s
            ${child_names}=    Get Child Menu Label Texts From Open Flyout On Web
            VAR    @{filtered_children}=    @{EMPTY}
            FOR    ${child_name}    IN    @{child_names}
                ${child_stripped}=    Strip String    ${child_name}
                Append To List    ${filtered_children}    ${child_stripped}
            END
            # ${n_children}=    Get Length    ${filtered_children}
            IF    not ${filtered_children}
                ${csv_line}=    Build CSV Line For DataDriver On Web    ${parent_name}    ${EMPTY}    ${parent_name}
                Append To File    ${csv_tmp}    ${csv_line}\n
            ELSE
                FOR    ${child_name}    IN    @{filtered_children}
                    ${page_name}=    Catenate    SEPARATOR=_    ${parent_name}    ${child_name}
                    ${csv_line}=    Build CSV Line For DataDriver On Web    ${parent_name}    ${child_name}    ${page_name}
                    Append To File    ${csv_tmp}    ${csv_line}\n
                END
            END
        END
        Move File    ${csv_tmp}    ${csv_file}
    FINALLY
        Run Keyword And Ignore Error    Close Browser
        Pop Browser Presenter Mode
        Run Keyword And Ignore Error    Remove File    ${csv_tmp}
    END

Get Child Menu Label Texts From Open Flyout On Web
    [Documentation]    Returns open-flyout child menu labels as a list of strings.
    ...
    ...    Uses ``Evaluate JavaScript`` with ``all_elements=True`` so we do not pass multi-match Playwright locator
    ...    lists into keywords that expect a single selector (which breaks under DataDriver in some setups).
    ...
    ...    | =Returns= | =Description= |
    ...    | labels | List of trimmed ``textContent`` values for nodes matching ``${CHILD_PAGES}`` |
    ${labels}=    Evaluate JavaScript    ${CHILD_PAGES}
    ...    (elements, arg) => Array.from(elements).map(e => (e.textContent || '').replace(/\\s+/g, ' ').trim()).filter(t => t.length > 0)
    ...    all_elements=${True}
    RETURN    ${labels}

Get Sanitized Menu Text On Web
    [Documentation]    Reads text for a menu element (including hidden submenu items) and normalizes it for CSV rows.
    ...
    ...    Uses ``Get Property`` with ``textContent`` so hidden flyout items are readable without a ``visible`` wait, and
    ...    avoids ``Get Text``/record-selector behavior that can require a headed browser in some setups.
    ...
    ...    | =Arguments= | =Description= |
    ...    | menu_element | Menu web element or chained locator (e.g. ``... >> nth=0``) |
    ...
    ...    | =Returns= | =Description= |
    ...    | menu_text | Trimmed menu text with collapsed spaces |
    [Arguments]    ${menu_element}
    ${menu_text}=    Get Property    ${menu_element}    textContent
    ${menu_text}=    Strip String    ${menu_text}
    ${menu_text}=    Replace String Using Regexp    ${menu_text}    \\s+    ${SPACE}
    RETURN    ${menu_text}

Verify Non-MyWork Child Menu Page Loads On Web
    [Documentation]
    ...    Navigates to a specific non-MyWork child menu path and verifies page load state.
    ...    When ``child_menu`` is empty or equals ``parent_menu`` (parent-only entry from CSV discovery), clicks the parent menu item instead of a flyout child.
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu display text |
    ...    | child_menu | Child menu display text; empty or same as parent means navigate via parent click only |
    ...    | page_name | Page identifier used for logs and screenshot naming |
    ...    | user_key | Optional; when set, screenshots are stored under a per-user subdirectory for parallel runs |
    [Arguments]    ${parent_menu}    ${child_menu}    ${page_name}    ${user_key}=${EMPTY}
    Navigate To Non-MyWork Menu Path By Text On Web    ${parent_menu}    ${child_menu}
    ${loaded}=    Run Keyword And Return Status    Wait For Load State    networkidle    timeout=30s
    Run Generic Validations For Loaded PDV Page On Web    ${parent_menu}    ${child_menu}    ${page_name}
    VAR    ${shot_base}=    ${EXECDIR}${/}pdv_screenshots_non_mywork${/}datadriven
    ${shot_base}=    Set Variable If    '${user_key}' == '${EMPTY}'    ${shot_base}    ${shot_base}${/}${user_key}
    IF    ${loaded}
        Take Screenshot    ${shot_base}${/}Passed${/}${page_name}.png
    ELSE
        Take Screenshot    ${shot_base}${/}Failed${/}${page_name}.png
    END
    Should Be True    ${loaded}    Page '${page_name}' did not reach networkidle within timeout.

Navigate To Non-MyWork Menu Path By Text On Web
    [Documentation]
    ...    Opens breadcrumb menu and navigates by parent/child labels.
    ...    If ``child_menu`` is empty or matches ``parent_menu``, hovers the parent and clicks it (no child flyout).
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu display text |
    ...    | child_menu | Child menu display text; empty or same as parent selects parent-only navigation |
    [Arguments]    ${parent_menu}    ${child_menu}
    ${parent_stripped}=    Strip String    ${parent_menu}
    ${child_stripped}=    Strip String    ${child_menu}
    # ${child_len}=    Get Length    ${child_stripped}
    IF    not "${child_stripped}"
        VAR    ${parent_only}=    ${True}
    ELSE
        ${parent_only}=    Run Keyword And Return Status    Should Be Equal As Strings    ${child_stripped}    ${parent_stripped}
    END
    Ensure Breadcrumb Menu Is Expanded For DataDriver On Web
    VAR    ${parent_locator}=    //p[normalize-space()="${parent_stripped}"]
    Wait Until Element Is Visible On Webpage    ${parent_locator}
    Hover    ${parent_locator}
    Sleep    1s
    IF    ${parent_only}
        Click Element On Webpage    ${parent_locator}    Failed to click parent menu '${parent_stripped}' (parent-only path)
    ELSE
        VAR    ${child_locator}=
        ...    //ul[@role='menu' and contains(@style, 'display: block;')]/li[@role='menuitem']/a[contains(text(),"${child_stripped}")]
        Wait Until Element Is Visible On Webpage    ${child_locator}
        Click Element On Webpage    ${child_locator}    Failed to click child menu '${child_stripped}' under '${parent_stripped}'
    END

Run Generic Validations For Loaded PDV Page On Web
    [Documentation]    Extension hook for future generic validations per loaded page.
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu display text |
    ...    | child_menu | Child menu display text |
    ...    | page_name | Page identifier |
    [Arguments]    ${parent_menu}    ${child_menu}    ${page_name}
    Log    Page loaded for parent='${parent_menu}', child='${child_menu}', page='${page_name}'.

Ensure Breadcrumb Menu Is Expanded For DataDriver On Web
    [Documentation]    Ensures breadcrumb menu is expanded before menu traversal.
    ${is_breadcrumb_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${BREADCRUMB_OPEN_ICON}    ${MEDIUM_TIMEOUT}
    IF    not ${is_breadcrumb_visible}
        Wait Until Page Is Loaded
        Evaluate JavaScript    ${BREADCRUMB_EXPAND_ICON}    (element) => element.click()
        Wait Until Element Is Visible On Webpage    ${BREADCRUMB_OPEN_ICON}
        ...    error_message=Element ${BREADCRUMB_OPEN_ICON} not visible after clicking expand icon
    END
