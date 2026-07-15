*** Settings ***
Documentation       Keywords for generating DataDriver CSV from visible MyWork module menus
...                 and validating page load for each menu path (same CSV columns as non-MyWork PDV).

Library             OperatingSystem
Library             String
Library             pabot.PabotLib
Library             resources/common/library/BrowserPresenterModeLibrary.py
Resource            resources/web/pdv/pdv_menu_datadriver_shared.resource
Resource            resources/web/pdv/mywork_menu_navigation.resource
Resource            resources/web/authentication/login.resource


*** Keywords ***
Generate PDV MyWork Child Menu CSV With Params And Return Config
    [Documentation]
    ...    Builds a comma-separated CSV for DataDriver by discovering visible parent/child MyWork menu items for the given user and module.
    ...
    ...    Pabot-safe: uses ``Acquire Lock`` / ``Release Lock`` keyed by user and module so one worker writes the CSV and others reuse it.
    ...
    ...    Sets ``${PDV_DATADRIVER_CHILD_MENU_CSV}`` for ``Remove PDV Datadriven Child Menu Csv For Suite``.
    ...
    ...    | =Arguments= | =Description= |
    ...    | original_config | Original DataDriver config map |
    ...    | user_key | Credential key |
    ...    | module_name | Module key (e.g. ``rws``) |
    ...    | locale | Locale passed to ``Login And Launch WFM Web App`` during CSV discovery |
    ...
    ...    | =Returns= | =Description= |
    ...    | new_config | DataDriver config map with generated CSV ``file=`` path |
    [Arguments]    ${original_config}    ${user_key}    ${module_name}    ${locale}
    Log    DataDriver original config: ${original_config}    level=DEBUG
    ${csv_dir}=    Normalize Path    ${EXECDIR}${/}test_data${/}generated
    Create Directory    ${csv_dir}
    ${csv_file}=    Normalize Path
    ...    ${csv_dir}${/}pdv_mywork_${module_name}_child_menus_${user_key}.csv
    VAR    ${PDV_DATADRIVER_CHILD_MENU_CSV}=    ${csv_file}    scope=SUITE
    ${lock_name}=    Catenate    SEPARATOR=_    pdv_mywork_menu_csv    ${user_key}    ${module_name}
    Acquire Lock    ${lock_name}
    ${csv_exists}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${csv_file}
    IF    not ${csv_exists}
        Write MyWork Child Menu Csv On Web    ${csv_file}    ${user_key}    ${module_name}    ${locale}
        Wait Until Keyword Succeeds    120x    500ms    Pdv Menu Csv File Looks Ready On Web    ${csv_file}
    ELSE
        Log    CSV already present, skipping discovery: ${csv_file}
    END
    Release Lock    ${lock_name}
    VAR    &{new_config}=    file=${csv_file}
    RETURN    ${new_config}

Write MyWork Child Menu Csv On Web
    [Documentation]
    ...    Opens a browser, discovers visible MyWork parent/child menu labels for the given user and module, and writes a DataDriver CSV.
    ...
    ...    Writes to ``${csv_file}.tmp`` then moves to ``${csv_file}`` so readers never see a half-written file.
    ...
    ...    | =Arguments= | =Description= |
    ...    | csv_file | Destination CSV path |
    ...    | user_key | Credential key (e.g. ``SM1_STORE1``, ``ESS2_STORE1``, ``SYSADMIN``) |
    ...    | module_name | Module key passed to ``Navigate To Main Module On Web`` (e.g. ``rws``) |
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
        Navigate To Main Module On Web    ${module_name}
        @{parent_pages}=    Get Elements    ${PARENT_PAGE_LOCATOR}
        ${parent_count}=    Get Length    ${parent_pages}
        FOR    ${parent_index}    IN RANGE    ${parent_count}
            Navigate To Main Module On Web    ${module_name}
            @{parent_pages}=    Get Elements    ${PARENT_PAGE_LOCATOR}
            ${parent_page}=    Get From List    ${parent_pages}    ${parent_index}
            ${parent_name}=    Get Element Text On Webpage    ${parent_page}
            ${parent_name}=    Strip String    ${parent_name}
            Evaluate JavaScript    ${parent_page}    (element) => element.click()
            Wait Until Page Is Loaded
            ${child_menu_loc}=    Update Locator With Dynamic Values    ${CHILD_PAGE_MENU_LOCATOR}    PARENT_MENU_NAME=${parent_name}
            @{child_elems}=    Get Elements    ${child_menu_loc}
            ${child_count}=    Get Length    ${child_elems}
            IF    not ${child_count}
                ${csv_line}=    Build CSV Line For DataDriver On Web    ${parent_name}    ${EMPTY}    ${parent_name}
                Append To File    ${csv_tmp}    ${csv_line}\n
            ELSE
                FOR    ${child_index}    IN RANGE    ${child_count}
                    ${child_page}=    Get From List    ${child_elems}    ${child_index}
                    ${child_name}=    Get Element Text On Webpage    ${child_page}
                    ${child_name}=    Strip String    ${child_name}
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

Verify MyWork Child Menu Page Loads On Web
    [Documentation]
    ...    Navigates to a MyWork parent/child path from CSV labels and verifies page load (``networkidle``) with PDV screenshots.
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu label from generated CSV |
    ...    | child_menu | Child label; empty when the parent has no sub-items |
    ...    | page_name | Combined identifier from generated CSV |
    ...    | user_key | Optional; screenshots go under a per-user subdirectory when set |
    ...    | module_name | Module key for ``Navigate To Main Module On Web`` (default ``rws``) |
    [Arguments]    ${parent_menu}    ${child_menu}    ${page_name}    ${user_key}=${EMPTY}    ${module_name}=rws
    Navigate To MyWork Menu Path By Text On Web    ${parent_menu}    ${child_menu}    ${module_name}
    ${loaded}=    Run Keyword And Return Status    Wait For Load State    networkidle    timeout=30s
    Run Generic Validations For Loaded MyWork PDV Page On Web    ${parent_menu}    ${child_menu}    ${page_name}
    VAR    ${shot_base}=    ${EXECDIR}${/}pdv_screenshots_mywork${/}datadriven
    IF    '${user_key}' != '${EMPTY}'
        VAR    ${shot_base}=    ${shot_base}${/}${user_key}
    END
    IF    ${loaded}
        Take Screenshot    ${shot_base}${/}Passed${/}${page_name}.png
    ELSE
        Take Screenshot    ${shot_base}${/}Failed${/}${page_name}.png
    END
    Should Be True    ${loaded}    Page '${page_name}' did not reach networkidle within timeout.

Navigate To MyWork Menu Path By Text On Web
    [Documentation]
    ...    From the module home, opens the parent row and optional child item matching the given labels (same flow as ``Iterate Over Mywork Pages And Capture Screenshots``).
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu display text |
    ...    | child_menu | Child text; empty or equal to parent selects parent-only navigation |
    ...    | module_name | Module key (``rws``, ``rta``, ``ess``) |
    [Arguments]    ${parent_menu}    ${child_menu}    ${module_name}
    ${parent_stripped}=    Strip String    ${parent_menu}
    ${child_stripped}=    Strip String    ${child_menu}
    ${child_len}=    Get Length    ${child_stripped}
    IF    not ${child_len}
        VAR    ${parent_only}=    ${True}
    ELSE
        ${parent_only}=    Run Keyword And Return Status    Should Be Equal As Strings    ${child_stripped}    ${parent_stripped}
    END
    ${parent_page}=    Find MyWork Parent Page Element By Menu Text On Web    ${module_name}    ${parent_stripped}
    Evaluate JavaScript    ${parent_page}    (element) => element.click()
    Wait Until Page Is Loaded
    IF    ${parent_only}    RETURN
    ${child_menu_panel}=    Update Locator With Dynamic Values    ${CHILD_MENU_EXPANSION_PANEL}    PARENT_MENU_NAME=${parent_stripped}
    ${expansion_panel}=    Update Locator With Dynamic Values    ${CHILD_PAGE_EXPANSION_PANEL}    PARENT_MENU_NAME=${parent_stripped}
    ${is_panel_collapsed}=    Is Element Visible On Webpage    ${expansion_panel}
    IF    ${is_panel_collapsed}
        Click Element On Webpage    ${child_menu_panel}
        ...    error_message=Failed to expand MyWork child panel for parent '${parent_stripped}'
        Wait Until Page Is Loaded
    END
    ${child_menu_loc}=    Update Locator With Dynamic Values    ${CHILD_PAGE_MENU_LOCATOR}    PARENT_MENU_NAME=${parent_stripped}
    @{child_elems}=    Get Elements    ${child_menu_loc}
    ${child_count}=    Get Length    ${child_elems}
    FOR    ${child_index}    IN RANGE    ${child_count}
        ${child_el}=    Get From List    ${child_elems}    ${child_index}
        ${child_text}=    Get Element Text On Webpage    ${child_el}
        ${child_text}=    Strip String    ${child_text}
        ${match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${child_text}    ${child_stripped}
        IF    ${match}
            Click Element On Webpage    ${child_el}    error_message=Failed to click MyWork child '${child_stripped}'
            Wait Until Page Is Loaded
            RETURN
        END
    END
    Fail    MyWork child menu not found: '${child_stripped}' under parent '${parent_stripped}'

Find MyWork Parent Page Element By Menu Text On Web
    [Documentation]
    ...    Returns the parent menu web element whose visible text equals ``${menu_text}`` after ``Navigate To Main Module On Web``.
    ...
    ...    | =Arguments= | =Description= |
    ...    | module_name | Module key |
    ...    | menu_text | Expected parent label (trimmed equality) |
    ...
    ...    | =Returns= | =Description= |
    ...    | parent_page | Playwright element handle for the matching parent row |
    [Arguments]    ${module_name}    ${menu_text}
    Navigate To Main Module On Web    ${module_name}
    @{parents}=    Get Elements    ${PARENT_PAGE_LOCATOR}
    ${parent_count}=    Get Length    ${parents}
    FOR    ${i}    IN RANGE    ${parent_count}
        ${p}=    Get From List    ${parents}    ${i}
        ${txt}=    Get Element Text On Webpage    ${p}
        ${txt}=    Strip String    ${txt}
        ${match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${txt}    ${menu_text}
        IF    ${match}    RETURN    ${p}
    END
    Fail    MyWork parent menu not found: '${menu_text}'

Run Generic Validations For Loaded MyWork PDV Page On Web
    [Documentation]
    ...    Extension hook for future generic validations per loaded MyWork page.
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu display text |
    ...    | child_menu | Child menu display text |
    ...    | page_name | Page identifier |
    [Arguments]    ${parent_menu}    ${child_menu}    ${page_name}
    Log    MyWork page loaded for parent='${parent_menu}', child='${child_menu}', page='${page_name}'.
