*** Settings ***
Documentation       Resource file for Criteria Configuration page under RWS Employee module.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/employee/criteria_configuration_page.py
Variables           resources/web/employee/criteria_configuration_api.py
Variables           resources/web/common/status_codes.py


*** Keywords ***
Navigate To RWS Employee Criteria Configuration Page On Web
    [Documentation]    Navigates to RWS -> Employee -> Criteria Configuration page.
    Navigate To Specific Page On Web    rws    employee    criteria_configuration

Add Criteria On Criteria Configuration Page On Web
    [Documentation]    Adds a new criteria configuration with complete setup including conditions.
    ...
    ...    *Arguments:*
    ...    - ``criteria_data``: Dictionary containing criteria configuration data from entity templates
    ...
    ...    *Example:*
    ...    | ${criteria_data}= | Get Generic Entity Data | criteria_configuration | template_name=default |
    ...    | Add Criteria On Criteria Configuration Page On Web | ${criteria_data} |
    [Arguments]    ${criteria_data}

    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_ADD_ICON}
    ...    error_message=Add Criteria icon not visible on Criteria Configuration page
    Click Element On Webpage    ${CRITERIACONFIGURATION_ADD_ICON}

    Fill Textbox On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_NAME}    ${criteria_data}[name]

    Click Element On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_APPLIED_ON}
    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_APPLIED_ON_UNIT}
    ...    error_message=Applied On dropdown options not visible after clicking the dropdown
    Click Element On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_APPLIED_ON_UNIT}

    Click Element On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_TYPE}
    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_TYPE_SHARE}
    ...    error_message=Criteria Type SHARE option not visible after clicking the Type dropdown
    Click Element On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_TYPE_SHARE}

    # Fill unit field to close the Type dropdown before selecting Status
    Fill Textbox On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_UNIT}    ${criteria_data}[unit]
    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_UNIT_OPTION}
    ...    error_message=Unit search result not visible for unit '${criteria_data}[unit]'
    Click Element On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_UNIT_OPTION}

    Click Element On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_STATUS}
    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_STATUS_ACTIVE}
    ...    error_message=Status Active option not visible after clicking the Status dropdown
    Click Element On Webpage    ${CRITERIACONFIGURATION_ADD_CRITERIA_STATUS_ACTIVE}

    Select Date Through Date Picker For ESS Requests On Webpage    ${CRITERIACONFIGURATION_EFFECTIVE_DATE_PICKER}
    ...    ${criteria_data}[eff_date]
    Select Date Through Date Picker For ESS Requests On Webpage    ${CRITERIACONFIGURATION_END_DATE_PICKER}    ${criteria_data}[end_date]

    # Ensure Override Manual Share Request toggle is OFF (disabled) - click only if currently ON
    ${is_toggle_on}    Is Element Visible On Webpage    ${CRITERIACONFIGURATION_OVERRIDE_SHARE_REQUEST_TOGGLE_ON}
    IF    ${is_toggle_on}
        Click Element On Webpage    ${CRITERIACONFIGURATION_OVERRIDE_SHARE_REQUEST_TOGGLE}
    END

    Click Element On Webpage    ${CRITERIACONFIGURATION_ADD_CONDITION_BUTTON}
    Select List Item On Webpage    ${CRITERIACONFIGURATION_CONDITION_ATTRIBUTE}    value    ${criteria_data}[condition_attribute]
    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_CONDITION_ATTRIBUTE_ID}
    ...    error_message=Condition Attribute ID dropdown not visible after selecting condition attribute
    Select List Item On Webpage    ${CRITERIACONFIGURATION_CONDITION_ATTRIBUTE_ID}    value    ${criteria_data}[condition_attribute_id]
    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_CONDITION_VALUE_TEXT}
    ...    error_message=Condition Value text input not visible after selecting condition attribute ID
    Fill Textbox On Webpage    ${CRITERIACONFIGURATION_CONDITION_VALUE_TEXT}    ${criteria_data}[condition_attribute_value]

    ${promise}    Promise To    Wait For Response    ${ADD_CRITERIA_API_REGEX}
    Click Element On Webpage    ${CRITERIACONFIGURATION_SAVE_BUTTON}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Should Be Equal As Strings    ${response_body.body}[statusCode]    1

Search And Select Criteria On Criteria Configuration Page On Web
    [Documentation]    Searches for a criteria by name and selects it.
    ...
    ...    *Arguments:*
    ...    - ``criteria_name``: Name of the criteria configuration to search
    [Arguments]    ${criteria_name}

    Fill Textbox On Webpage    ${CRITERIACONFIGURATION_SEARCH_CRITERIA}    ${criteria_name}
    Press Keys    ${CRITERIACONFIGURATION_SEARCH_CRITERIA}    ENTER

    ${search_result_locator}    Update Locator With Dynamic Values    ${CRITERIACONFIGURATION_SEARCH_RESULT_BY_NAME}
    ...    CRITERIA_NAME=${criteria_name}
    Wait Until Element Is Visible On Webpage    ${search_result_locator}
    ...    error_message=Criteria '${criteria_name}' not found in search results
    Click Element On Webpage    ${search_result_locator}

Delete Criteria On Criteria Configuration Page On Web
    [Documentation]    Deletes a criteria configuration by searching and confirming deletion.
    ...
    ...    *Arguments:*
    ...    - ``criteria_name``: Name of the criteria configuration to delete
    [Arguments]    ${criteria_name}

    Fill Textbox On Webpage    ${CRITERIACONFIGURATION_SEARCH_CRITERIA}    ${criteria_name}

    ${search_result_locator}    Update Locator With Dynamic Values    ${CRITERIACONFIGURATION_SEARCH_RESULT_BY_NAME}
    ...    CRITERIA_NAME=${criteria_name}
    Wait Until Element Is Visible On Webpage    ${search_result_locator}
    ...    error_message=Criteria '${criteria_name}' not found in search results
    Click Element On Webpage    ${search_result_locator}

    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_DELETE_BUTTON}
    ...    error_message=Delete button not visible on Criteria Configuration page
    ${promise}    Promise To    Wait For Response    ${DELETE_CRITERIA_API_REGEX}
    Click Element On Webpage    ${CRITERIACONFIGURATION_DELETE_BUTTON}

    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_DELETE_CONFIRMATION_OK_BUTTON}
    ...    error_message=Delete confirmation dialog did not appear
    Click Element On Webpage    ${CRITERIACONFIGURATION_DELETE_CONFIRMATION_OK_BUTTON}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Should Be Equal As Strings    ${response_body.body}[statusCode]    1

Delete Criteria If Exists On Criteria Configuration Page On Web
    [Documentation]    Deletes a criteria configuration by name if it exists.
    ...    Safe to call even when the criteria is not present — used as a pre-test cleanup guard.
    ...    | =Arguments=    | =Description=    |
    ...    | criteria_name    | Name of the criteria configuration to conditionally delete    |
    [Arguments]    ${criteria_name}

    Fill Textbox On Webpage    ${CRITERIACONFIGURATION_SEARCH_CRITERIA}    ${criteria_name}

    ${search_result_locator}    Update Locator With Dynamic Values    ${CRITERIACONFIGURATION_SEARCH_RESULT_BY_NAME}
    ...    CRITERIA_NAME=${criteria_name}
    ${exists}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible On Webpage    ${search_result_locator}    timeout=${SHORT_TIMEOUT}
    IF    not ${exists}    RETURN
    Click Element On Webpage    ${search_result_locator}

    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_DELETE_BUTTON}
    ...    error_message=Delete button not visible on Criteria Configuration page
    ${promise}    Promise To    Wait For Response    ${DELETE_CRITERIA_API_REGEX}
    Click Element On Webpage    ${CRITERIACONFIGURATION_DELETE_BUTTON}

    Wait Until Element Is Visible On Webpage    ${CRITERIACONFIGURATION_DELETE_CONFIRMATION_OK_BUTTON}
    ...    error_message=Delete confirmation dialog did not appear
    Click Element On Webpage    ${CRITERIACONFIGURATION_DELETE_CONFIRMATION_OK_BUTTON}
    ${response_body}    Wait For    ${promise}
    Should Be Equal As Strings    ${response_body.status}    ${HTTP_STATUS_CODES}[OK]
    Should Be Equal As Strings    ${response_body.body}[statusCode]    1
