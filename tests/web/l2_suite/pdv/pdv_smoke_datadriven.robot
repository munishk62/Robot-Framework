*** Settings ***
Documentation       Unified PDV menu DataDriver: discovers parent/child menus into a CSV and loads each row once.
...                 Uses ``MYWORK`` in the environment config to choose MyWork vs non-MyWork navigation and CSV discovery.
...                 Set suite variables ``${PDV_DATADRIVER_MENU_USER_KEY}``, ``${PDV_DATADRIVER_MENU_MODULE}``, and ``${I18N_LOCALE}``; suite keywords pass them into shared resources (copy this suite for other users/locales).
...                 DataDriver ``config_keyword`` and template keyword must live in *this* file so DataDriver can read argument names.

Resource            resources/web/pdv/pdv_menu_datadriver_dispatch.resource
Library             DataDriver    dialect=excel    encoding=utf_8
...                     config_keyword=Generate PDV Child Menu CSV For Environment And Return Config

Suite Setup         Login For PDV Menu Datadriven Suite On Web
...                     user_key=${PDV_DATADRIVER_MENU_USER_KEY}
...                     module_name=${PDV_DATADRIVER_MENU_MODULE}
...                     locale=${I18N_LOCALE}
Suite Teardown      Remove PDV Datadriven Child Menu Csv For Suite

Test Tags           dev:kapil    action:read    robot:skip


*** Variables ***
${PDV_DATADRIVER_MENU_USER_KEY}     ESS2_STORE1
${PDV_DATADRIVER_MENU_MODULE}       ess
${I18N_LOCALE}                      en_US


*** Test Cases ***
BATTC00247: Verify SM user is able to navigate to all menus, submenus and side menus successfully in web for RWS (Scheduling) with PDV pre/post comparison
    [Documentation]    Verifies each discovered RWS child menu page loads for the active MyWork or non-MyWork mode.
    [Tags]    pdv_smoke_datadriven_rws    config:rws    battc00247    datadriven
    [Template]    Verify PDV Menu Datadriven Template Row


*** Keywords ***
Generate PDV Child Menu CSV For Environment And Return Config
    [Documentation]
    ...    DataDriver ``config_keyword``: forwards suite user, module, and locale into ``Generate PDV Child Menu CSV For Environment With Params And Return Config``.
    ...
    ...    | =Arguments= | =Description= |
    ...    | original_config | Original DataDriver config map |
    ...
    ...    | =Returns= | =Description= |
    ...    | new_config | Updated DataDriver config with generated CSV path |
    [Arguments]    ${original_config}
    ${new_config}=    Generate PDV Child Menu CSV For Environment With Params And Return Config
    ...    ${original_config}
    ...    ${PDV_DATADRIVER_MENU_USER_KEY}
    ...    ${PDV_DATADRIVER_MENU_MODULE}
    ...    ${I18N_LOCALE}
    RETURN    ${new_config}

Verify PDV Menu Datadriven Template Row
    [Documentation]
    ...    DataDriver template: CSV columns ``parent_menu``, ``child_menu``, ``page_name``. Dispatches using suite user and module.
    ...
    ...    | =Arguments= | =Description= |
    ...    | parent_menu | Parent menu label from generated CSV |
    ...    | child_menu | Child label; empty when the parent has no sub-items |
    ...    | page_name | Combined identifier from generated CSV |
    [Arguments]    ${parent_menu}    ${child_menu}    ${page_name}
    Verify PDV Child Menu Page For Datadriven Row On Web
    ...    ${parent_menu}
    ...    ${child_menu}
    ...    ${page_name}
    ...    ${PDV_DATADRIVER_MENU_USER_KEY}
    ...    ${PDV_DATADRIVER_MENU_MODULE}

# PDV Flow Per User & use case

# Input: user_key, locale
# config_keyword = logs in with user_key and locale & generates a 3 level menu csv file used for data driven test_case

# suite setup:
# Login as user key & navigate to module. [This is to reduce total logins to num of processes than num of test cases.
# Assumption no of process < no of test cases i.e. number of different child menu combinations]

# Test Case: Template
# Navigate to given child menu page for each csv record & verify successful load. This assumes the browser is open and logged in to app.

# Suite Teardown:
# Close browser
# One of the teardown to delete the csv file generated in config_keyword
