*** Settings ***
Documentation       Test case to verify user is able to add/edit/delete distribution list and its criteria

Resource            resources/web/authentication/login.resource
Resource            resources/web/organization/organization_distribution_list.resource

Test Teardown       Close Browser

Test Tags           dev:bushra    action:write    battc00252    config:rws    bat_phase2    om_hr


*** Test Cases ***
BATTC00252: Verify user is able to add/edit/delete distribution list and its criteria
    [Documentation]    Test case to verify user is able to add/edit/delete distribution list and its criteria
    VAR    ${status_dl1}    ${False}
    VAR    ${status_dl2}    ${False}
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Organization Distribution List Page On Web
    Verify RWS Distribution List Page Loaded On Web
    ${store_data}    Get Store Data    template_name=model_store2
    ${distribution_list_data_dl1}    Get Distribution List Data    template_name=org_structure
    ${distribution_list_data_dl2}    Get Distribution List Data    template_name=geographic_location
    Log    Initial status of first distribution list set to ${status_dl1}
    Log    Initial status of second distribution list set to ${status_dl2}
    Cleanup Distribution Lists If Exists On Web    ${store_data}    ${distribution_list_data_dl1}    ${distribution_list_data_dl2}
    ${dl1_name}    ${dl1_description}    Add New Distribution List From Distribution List Maintenance Page On Web
    ...    ${store_data}    ${distribution_list_data_dl1}
    Log    Distribution list added with name: ${dl1_name} and description: ${dl1_description}
    Add Unit Selection Criteria Based On Criterion Type On Web    ${distribution_list_data_dl1}[criterion_type]
    ...    ${distribution_list_data_dl1}[criterion]    ${store_data}[store_name]    ${store_data}[store_id]
    VAR    ${status_dl1}    ${True}
    Navigate Back To Distribution List Page From Distribution List Maintenance Page On Web
    Select Distribution List In Distribution Lists Page On Web    ${dl1_name}
    Edit Distribution List From Distribution List Maintenance Page On Web    description=${dl1_description} edited
    Regenerate Units List From UI On Web
    Verify Unit Present In Distribution List Criteria On Web    ${store_data}[store_name]    ${store_data}[store_id]
    Navigate Back To Distribution List Page From Distribution List Maintenance Page On Web
    ${dl2_name}    ${dl2_description}    Add New Distribution List From Distribution List Maintenance Page On Web
    ...    ${store_data}    ${distribution_list_data_dl2}
    VAR    ${status_dl2}    ${True}
    Log    Distribution list added with name: ${dl2_name} and description: ${dl2_description}
    # Currently getting country value from json, needs to be fetched from DB for particular store
    ${country_criteria_value}    Get System Value    DistListCriterionGeoLocTypeValue    CRITERION_VALUE
    Add Unit Selection Criteria Based On Criterion Type On Web    ${distribution_list_data_dl2}[criterion_type]
    ...    ${distribution_list_data_dl2}[criterion]    ${country_criteria_value}
    Regenerate Units List Using Servlet On Web    user_key=SYSADMIN
    Verify Unit Present In Distribution List Criteria On Web    ${country_criteria_value}
    Navigate Back To Distribution List Page From Distribution List Maintenance Page On Web

    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Run Keyword If    ${status_dl1}    Delete Distribution List From Distribution Lists Page On Web    ${dl1_name}
    ...    AND
    ...    Run Keyword And Continue On Failure    Run Keyword If    ${status_dl2}    Delete Distribution List From Distribution Lists Page On Web    ${dl2_name}
