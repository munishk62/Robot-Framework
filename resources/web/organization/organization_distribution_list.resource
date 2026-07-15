*** Settings ***
Documentation       This resource file contains keywords related to Distribution Lists

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Resource            resources/api/api_executor.resource
Variables           resources/web/organization/organization_distribution_list_page.py
Variables           resources/api/api_endpoints.py
Variables           resources/web/organization/organization_distribution_list_page_api.py


*** Keywords ***
Navigate To RWS Organization Distribution List Page On Web
    [Documentation]    Navigate To RWS -> Organization -> Distribution List Page On Web
    Navigate To Specific Page On Web    rws    organization    distribution_list

Verify RWS Distribution List Page Loaded On Web
    [Documentation]    Verify RWS Distribution List page is loaded successfully on web
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_LIST}    timeout=${LONG_TIMEOUT}
    ...    error_message=Distribution List page did not load successfully on web
    Capture Screenshot On Webpage

Add New Distribution List From Distribution List Maintenance Page On Web
    [Documentation]    Add new distribution list on Distribution List Maintenance Page On Web
    ...    | =Arguments= | =Description= |
    ...    | unit | Store id for which distribution list is added to be appended in description    |
    ...    | distribution_list_data | Object of distribution list template |
    ...    | =Returns= | Distribution list name and description created |
    [Arguments]    ${unit}    ${distribution_list_data}
    VAR    ${store_id}    ${unit}[store_id]
    VAR    ${dist_list_name}    ${store_id}${distribution_list_data}[name]
    VAR    ${dist_list_description}    ${distribution_list_data}[description] ${store_id}
    ${distribution_list_locator}    Update Locator With Dynamic Values    ${ORG_DIST_LIST_PAGE_DIST_LIST_NAME}
    ...    DIST_LIST_NAME=${dist_list_name}
    ${is_dist_list_already_present}    Is Element Present On Webpage    ${distribution_list_locator}
    Skip If    ${is_dist_list_already_present}    Distribution list with name '${dist_list_name}' already exists, skipping creation.
    Click Element On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_LIST}
    Wait Until Page Is Loaded
    Fill Fields For Distribution List On Distribution List Maintenance Page On Web    ${dist_list_name}    ${dist_list_description}
    ...    ${distribution_list_data}[frozen]
    Wait Until Page Is Loaded
    Click Element On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_BTN}
    Wait Until Element Is Visible On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}    timeout=${LONG_TIMEOUT}
    ...    error_message=Success message not displayed after adding distribution list
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}
    Log    Distribution list created with name: ${dist_list_name} and description: ${dist_list_description}
    RETURN    ${dist_list_name}    ${dist_list_description}

Edit Distribution List From Distribution List Maintenance Page On Web
    [Documentation]    Edit Distribution list on Distribution List Maintenance Page on web
    ...    | =Arguments= | =Description= |
    ...    | name | Distribution list name text |
    ...    | description | Distribution list description text    |
    ...    | frozen | Frozen status to be set for distribution list Yes/No |
    [Arguments]    ${name}=${EMPTY}    ${description}=${EMPTY}    ${frozen}=${EMPTY}
    Wait Until Page Is Loaded
    Fill Fields For Distribution List On Distribution List Maintenance Page On Web    ${name}    ${description}    ${frozen}
    Click Element On Webpage    ${ORG_DIST_LIST_PAGE_UPDATE_DIST_LIST_BTN}
    Wait Until Element Is Visible On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}    timeout=${LONG_TIMEOUT}
    ...    error_message=Success message not displayed after updating distribution list
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}

Fill Fields For Distribution List On Distribution List Maintenance Page On Web
    [Documentation]    Fill fields for distribution list on distribution list maintenance page on web
    ...    | =Arguments= | =Description= |
    ...    | name | Distribution list name text |
    ...    | description | Distribution list description text    |
    ...    | frozen | Frozen status to be set for distribution list Yes/No |
    [Arguments]    ${name}=${EMPTY}    ${description}=${EMPTY}    ${frozen}=${EMPTY}
    Wait Until Page Is Loaded
    IF    $name != ''
        Fill Textbox On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_NAME_TXT}    ${name}
    END
    IF    $description != ''
        Fill Textbox On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_DESC_TXT}    ${description}
    END
    IF    $frozen != ''
        IF    '${frozen}' == 'Yes'
            Click Element On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_FROZEN_CHK_YES}
        ELSE
            Click Element On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_FROZEN_CHK_NO}
        END
    END

Add Unit Selection Criteria Based On Criterion Type On Web
    [Documentation]    Add unit selection criteria for different criterion type on web
    ...    | =Arguments= | =Description= |
    ...    | criterion_type | Criterion type for distribution list |
    ...    | criterion | Criterion for distribution list    |
    ...    | criterion_value | Criterion value for distribution list |
    [Arguments]    ${criterion_type}    ${criterion}    ${criterion_value_name}    ${criterion_value_id}=${None}
    Wait Until Element Is Visible On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_CONFIG_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Distribution list maintenance page did not load successfully on web, save button not visible
    IF    $criterion_value_id is None
        VAR    ${criterion_value_id}    ${criterion_value_name}
    END
    Click Element On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_TYPE_LIST}
    Select List Item On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_TYPE_LIST}    text
    ...    ${criterion_type}
    IF    '${criterion_type}'=='Organization Structure'
        Click Element On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_LIST_ORG_STRUCTURE}
        ...    error_message=Failed to click on Organization Structure criterion type in criteria type dropdown
        Select List Item On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_LIST_ORG_STRUCTURE}    text
        ...    ${criterion}
        Fill Textbox On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_CRITERION_VALUE_TEXTFIELD}    ${criterion_value_id}
        ${criterion_value_locator}    Update Locator With Dynamic Values
        ...    ${ORG_DIST_LIST_PAGE_ADD_DIST_CRITERION_VALUE_DROPDOWN}
        ...    CRITERION_VALUE_1=${criterion_value_name}
        ...    CRITERION_VALUE_2=${criterion_value_id}
    ELSE IF    '${criterion_type}'=='Geographic Location'
        Click Element On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_LIST_GEO_LOC}
        ...    error_message=Failed to click on Geographic Location criterion type in criteria type dropdown
        Select List Item On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_LIST_GEO_LOC}    text
        ...    ${criterion}
        ${criterion_value_locator}    Update Locator With Dynamic Values
        ...    ${ORG_DIST_LIST_PAGE_ADD_DIST_CRITERION_VALUE_CHECKBOX}
        ...    CRITERION_VALUE=${criterion_value_name}
    END
    Wait Until Element Is Visible On Webpage    ${criterion_value_locator}    timeout=${LONG_TIMEOUT}
    ...    error_message=Criterion value '${criterion_value_name}' not visible
    Click Element On Webpage    ${criterion_value_locator}
    Click Element On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_CONFIG_SAVE_BTN}
    Wait Until Element Is Visible On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}    timeout=${LONG_TIMEOUT}
    ...    error_message=Success message not displayed after adding distribution list criteria
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}

Select Distribution List In Distribution Lists Page On Web
    [Documentation]    Select distribution list in distribution lists page on web
    ...    | =Arguments= | =Description= |
    ...    | distribution_list_name | Name of distribution list |
    [Arguments]    ${distribution_list_name}
    ${distribution_list_locator}    Update Locator With Dynamic Values
    ...    ${ORG_DIST_LIST_PAGE_DIST_LIST_NAME}
    ...    DIST_LIST_NAME=${distribution_list_name}
    Click Element On Webpage    ${distribution_list_locator}
    Wait Until Element Disappears On Webpage    ${distribution_list_locator}
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Navigate Back To Distribution List Page From Distribution List Maintenance Page On Web
    [Documentation]    Navigate back from distribution list maintenance page on web
    Click Element On Webpage    ${ORG_DIST_LIST_PAGE_PREVIOUS_BTN}
    Verify RWS Distribution List Page Loaded On Web
    Capture Screenshot On Webpage

Regenerate Units List From UI On Web
    [Documentation]    Click on regenerate unit on web
    Click Element On Webpage    ${ORG_DIST_LIST_PAGE_REGENERATE_UNIT_BTN}
    Wait Until Element Is Visible On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}    timeout=${LONG_TIMEOUT}
    ...    error_message=Success message not displayed after regenerating distribution list units
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}
    Log    Refresh distribution list units initiated from UI

Regenerate Units List Using Servlet On Web
    [Documentation]    Regenerate units list using servlet on web
    ...    | =Arguments= | =Description= |
    ...    | user_key | User key to generate auth token |
    [Arguments]    ${user_key}
    Generate Auth Token With User Credentials    ${user_key}
    VAR    ${api_endpoint}    ${DISTRIBUTION_LIST_SERVLET_URL}
    ${date_format}    Get Config Value    SERVER_DF
    ${current_date}    Get Current Date    result_format=${date_format}
    ${base_url}    Get Config Value    key=base_url
    ${distribution_list_servlet_url}    Evaluate    "${base_url}" + "/${api_endpoint}=${current_date}"
    ${response}    Send A Get Request    ${distribution_list_servlet_url}    return_raw_response=True
    ${status_ok}    Get System Value    HttpStatusCode    OK
    Should Be Equal As Integers    ${response.status_code}    ${status_ok}
    ...    msg=Failed to publish schedule via servlet; expected HTTP 200.

Verify Unit Present In Distribution List Criteria On Web
    [Documentation]    Verify unit is present in list building criteria section of distribution list on web
    ...    | =Arguments= | =Description= |
    ...    | criteria_value | Name of the unit to be verified in criteria list |
    [Arguments]    ${criterion_value_name}    ${criterion_value_id}=${None}
    IF    $criterion_value_id is None
        VAR    ${criterion_value_id}    ${criterion_value_name}
    END
    Wait Until Page Is Loaded
    ${criteria_value_locator}    Update Locator With Dynamic Values
    ...    ${ORG_DIST_LIST_PAGE_ADD_DIST_LIST_BUILDING_CRITERIA_VALUE}
    ...    CRITERION_VALUE_1=${criterion_value_name}
    ...    CRITERION_VALUE_2=${criterion_value_id}
    Wait Until Element Is Visible On Webpage    ${criteria_value_locator}
    ...    error_message=Unit with value '${criterion_value_name}' not found in distribution list criteria list
    Capture Screenshot On Webpage

Delete Distribution List From Distribution Lists Page On Web
    [Documentation]    Delete distribution list from distribution lists page on web
    ...    | =Arguments= | =Description= |
    ...    | distribution_list_name | Name of distribution list to be deleted |
    [Arguments]    ${distribution_list_name}
    Select Distribution List In Distribution Lists Page On Web    ${distribution_list_name}
    Wait Until Element Is Visible On Webpage    ${ORG_DIST_LIST_PAGE_DEL_DIST_BTN}
    Wait Until Page Is Loaded
    ${promise_alert}    Promise To    Wait For Alert    action=accept    timeout=${LONG_TIMEOUT}
    Click Element On Webpage    ${ORG_DIST_LIST_PAGE_DEL_DIST_BTN}
    Wait For    ${promise_alert}
    Wait Until Element Is Visible On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}    timeout=${LONG_TIMEOUT}
    ...    error_message=Success message not displayed after deleting distribution list
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG}
    Log    Distribution list '${distribution_list_name}' deleted successfully

Check If Distribution List Exists On Distribution List Page On Web
    [Documentation]    Check if distribution list exists on web
    ...    | =Arguments= | =Description= |
    ...    | distribution_list_name | Name of distribution list to be checked |
    ...    | =Returns= | True if distribution list exists, False otherwise |
    [Arguments]    ${distribution_list_name}
    Wait Until Page Is Loaded
    ${distribution_list_locator}    Update Locator With Dynamic Values
    ...    ${ORG_DIST_LIST_PAGE_DIST_LIST_NAME}
    ...    DIST_LIST_NAME=${distribution_list_name}
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible On Webpage
    ...    ${distribution_list_locator}    timeout=${MEDIUM_TIMEOUT}
    RETURN    ${is_visible}

Cleanup Distribution Lists If Exists On Web
    [Documentation]    Cleanup two distribution lists if exists on web
    ...    | =Arguments= | =Description= |
    ...    | store_data | Store data object to get store id for distribution list name    |
    ...    | distributionlist_data_1 | Distribution list data object for first distribution list to be cleaned up    |
    ...    | distributionlist_data_2 | Distribution list data object for second distribution list to be cleaned up    |
    [Arguments]    ${store_data}    ${distributionlist_data_1}    ${distributionlist_data_2}
    VAR    ${distribution_list_name_1}    ${store_data}[store_id]${distributionlist_data_1}[name]
    VAR    ${distribution_list_name_2}    ${store_data}[store_id]${distributionlist_data_2}[name]
    ${distribution_list_locator_1}    Update Locator With Dynamic Values    ${ORG_DIST_LIST_PAGE_DIST_LIST_NAME}
    ...    DIST_LIST_NAME=${distribution_list_name_1}
    ${distribution_list_locator_2}    Update Locator With Dynamic Values    ${ORG_DIST_LIST_PAGE_DIST_LIST_NAME}
    ...    DIST_LIST_NAME=${distribution_list_name_2}
    ${is_dist_list_1_present}    Is Element Present On Webpage    ${distribution_list_locator_1}
    ${is_dist_list_2_present}    Is Element Present On Webpage    ${distribution_list_locator_2}
    IF    ${is_dist_list_1_present}
        Delete Distribution List From Distribution Lists Page On Web    ${distribution_list_name_1}
    END
    IF    ${is_dist_list_2_present}
        Delete Distribution List From Distribution Lists Page On Web    ${distribution_list_name_2}
    END

Open Add Distribution List Page On Web
    [Documentation]    Clicks the "Add Distribution List" button on the distribution list page to open the add distribution list form page.
    ${is_add_dist_list_btn_present}    Is Element Present On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_LIST}
    Skip If    not ${is_add_dist_list_btn_present}    Add Distribution List button not present on distribution list page, cannot open add distribution list page.
    Click Element On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_LIST}
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_BTN}
    ...    error_message=Add distribution list page did not load successfully on web
    Capture Screenshot On Webpage
