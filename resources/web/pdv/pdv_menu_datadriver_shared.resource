*** Settings ***
Documentation       Shared helpers for PDV menu DataDriver CSV rows (headers ``parent_menu``, ``child_menu``, ``page_name``).
...                 Used by MyWork and non-MyWork menu discovery and teardown.

Library             OperatingSystem
Library             String


*** Variables ***
${PDV_DATADRIVER_CHILD_MENU_CSV}    ${EMPTY}


*** Keywords ***
Build CSV Line For DataDriver On Web
    [Documentation]
    ...    Creates one CSV-safe line for DataDriver menu arguments.
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu display text |
    ...    | child_menu | Child menu display text |
    ...    | page_name | Human readable page identifier |
    ...
    ...    | =Returns= | =Description= |
    ...    | csv_line | Quoted CSV line |
    [Arguments]    ${parent_menu}    ${child_menu}    ${page_name}
    ${parent_menu}=    Replace String    ${parent_menu}    "    ""
    ${child_menu}=    Replace String    ${child_menu}    "    ""
    ${page_name}=    Replace String    ${page_name}    "    ""
    ${csv_line}=    Catenate    SEPARATOR=,    "${parent_menu}"    "${child_menu}"    "${page_name}"
    RETURN    ${csv_line}

Pdv Menu Csv File Looks Ready On Web
    [Documentation]
    ...    Fails until the CSV exists and looks parseable (header plus at least one data row).
    ...
    ...    | =Arguments= | =Description= |
    ...    | csv_file | Absolute path to the generated CSV |
    [Arguments]    ${csv_file}
    OperatingSystem.File Should Exist    ${csv_file}
    ${text}=    OperatingSystem.Get File    ${csv_file}
    Should Contain    ${text}    parent_menu
    @{lines}=    Split String    ${text}    \n
    ${line_count}=    Get Length    ${lines}
    Should Be True    ${line_count} >= 2    CSV at ${csv_file} must have a header and at least one data row

Remove PDV Datadriven Child Menu Csv For Suite
    [Documentation]
    ...    Deletes ``${PDV_DATADRIVER_CHILD_MENU_CSV}`` when it was set during a PDV menu ``config_keyword``. Ignores a missing file.
    IF    '${PDV_DATADRIVER_CHILD_MENU_CSV}' == '${EMPTY}'    RETURN
    Run Keyword And Ignore Error    Remove File    ${PDV_DATADRIVER_CHILD_MENU_CSV}
