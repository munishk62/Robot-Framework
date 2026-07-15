*** Settings ***
Documentation       This resource file contains keywords related to the RWS > Schedule > Scheduling Models page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/scheduling_models_page.py


*** Keywords ***
Navigate To RWS Scheduling Models Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Scheduling Models Page On Web
    Navigate To Specific Page On Web    rws    schedule    scheduling_models

Click On First Scheduling Model In Scheduling Models Page On Web
    [Documentation]    Click on the first Scheduling Model in Scheduling Models page on Web
    ${is_scheduling_model_present}    Is Element Present On Webpage    ${SCH_MODELS_FIRST_MODEL_NAME}
    Skip If    not ${is_scheduling_model_present}    No Scheduling Models are present in the page to click on.
    Click Element On Webpage    ${SCH_MODELS_FIRST_MODEL_NAME}
    ...    error_message=Failed to click on the first Scheduling Model
    Wait Until Element Is Visible On Webpage    ${SCH_MODELS_BASIC_DETAILS_TAB}    timeout=${LONG_TIMEOUT}
    ...    error_message=Scheduling Model details did not open after clicking on the first Scheduling Model
    Capture Screenshot On Webpage

Switch To All Available Tabs In Scheduling Model Details Section On Web
    [Documentation]    Switch to all available tabs in Scheduling Model details section on Web
    ${tabs_count}    Get Element Count On Webpage    ${SCH_MODELS_MODEL_DETAILS_AVAILABLE_TABS}
    FOR    ${tab_index}    IN RANGE    1    ${tabs_count + 1}
        ${tab_locator}    Update Locator With Dynamic Values    ${SCH_MODELS_MODEL_DETAILS_TAB}    TAB_INDEX=${tab_index}
        Click Element On Webpage    ${tab_locator}
        ...    error_message=Failed to click on tab ${tab_index} in Scheduling Model details section
        Wait Until Element Is Visible On Webpage    ${tab_locator}.active-tab    timeout=${LONG_TIMEOUT}
        ...    error_message=Tab ${tab_index} in Scheduling Model details section did not become active after clicking
        Capture Screenshot On Webpage
    END
