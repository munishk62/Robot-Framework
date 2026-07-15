*** Settings ***
Documentation       Dispatches PDV menu DataDriver ``config_keyword``, suite login, and per-row verification based on environment ``MYWORK`` (MyWork vs non-MyWork).

Library             String
Resource            resources/web/pdv/pdv_menu_datadriver_shared.resource
Resource            resources/web/authentication/login.resource
Resource            resources/web/pdv/mywork_menu_navigation_datadriven.resource
Resource            resources/web/pdv/non_mywork_menu_navigation_datadriven.resource


*** Keywords ***
Environment Is MyWork Mode On Web
    [Documentation]
    ...    Returns whether the active test environment is integrated MyWork mode using config key ``MYWORK`` (case-insensitive ``true``; defaults to false when the key is absent).
    ...
    ...    | =Returns= | =Description= |
    ...    | is_mywork | Boolean ``True`` when ``MYWORK`` is true, else ``False`` |
    ${raw}=    Get Config Value    MYWORK    false
    ${low}=    Convert To Lower Case    ${raw}
    ${result}=    Evaluate    """${low}""" == "true"
    RETURN    ${result}

Login For PDV Menu Datadriven Suite On Web
    [Documentation]
    ...    Logs in with the given user and opens the module root so DataDriver template tests reuse one browser session (MyWork and non-MyWork).
    ...
    ...    | =Arguments= | =Description= |
    ...    | user_key | Credential key (suite-defined) |
    ...    | module_name | Module to open (e.g. ``rws``, ``ess``) |
    ...    | locale | Locale for ``Login And Launch WFM Web App`` |
    [Arguments]    ${user_key}    ${module_name}    ${locale}
    Login And Launch WFM Web App    user_key=${user_key}    locale=${locale}
    Navigate To Specific Page On Web    ${module_name}

Generate PDV Child Menu CSV For Environment With Params And Return Config
    [Documentation]
    ...    Generates the menu CSV using MyWork discovery when ``MYWORK`` is true, otherwise non-MyWork discovery. Call from a suite ``config_keyword`` wrapper that passes user, module, and locale.
    ...
    ...    | =Arguments= | =Description= |
    ...    | original_config | Original DataDriver config map |
    ...    | user_key | Credential key for discovery login and CSV file naming |
    ...    | module_name | Module for discovery and CSV file naming |
    ...    | locale | Locale for discovery login |
    ...
    ...    | =Returns= | =Description= |
    ...    | new_config | Updated config with ``file=`` path to the generated CSV |
    [Arguments]    ${original_config}    ${user_key}    ${module_name}    ${locale}
    ${is_mywork}=    Environment Is MyWork Mode On Web
    IF    ${is_mywork}
        ${new_config}=    Generate PDV MyWork Child Menu CSV With Params And Return Config
        ...    ${original_config}
        ...    ${user_key}
        ...    ${module_name}
        ...    ${locale}
    ELSE
        ${new_config}=    Generate PDV Non-MyWork Child Menu CSV With Params And Return Config
        ...    ${original_config}
        ...    ${user_key}
        ...    ${module_name}
        ...    ${locale}
    END
    RETURN    ${new_config}

Verify PDV Child Menu Page For Datadriven Row On Web
    [Documentation]
    ...    Navigates and asserts page load for one CSV row using MyWork or non-MyWork keywords based on ``MYWORK``.
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu label from generated CSV |
    ...    | child_menu | Child label (may be empty) |
    ...    | page_name | Row identifier for logging and screenshots |
    ...    | user_key | Credential key for screenshot subfolders |
    ...    | module_name | Module key for MyWork navigation |
    [Arguments]    ${parent_menu}    ${child_menu}    ${page_name}    ${user_key}    ${module_name}
    ${is_mywork}=    Environment Is MyWork Mode On Web
    IF    ${is_mywork}
        Verify MyWork Child Menu Page Loads On Web
        ...    ${parent_menu}
        ...    ${child_menu}
        ...    ${page_name}
        ...    ${user_key}
        ...    ${module_name}
    ELSE
        Verify Non-MyWork Child Menu Page Loads On Web
        ...    ${parent_menu}
        ...    ${child_menu}
        ...    ${page_name}
        ...    ${user_key}
    END
