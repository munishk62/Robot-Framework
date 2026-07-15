*** Settings ***
Documentation       This contains keywords related to Release Checks page

Resource            resources/web/common/common.resource
Variables           resources/web/payroll/release_checks_page.py
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RTA Payroll Release Checks Page On Web
    [Documentation]    Navigate To RTA -> Payroll -> Release Checks Page
    ...    and verifies release checks heading at the top of the page
    Navigate To Specific Page On Web    rta    payroll    release_checks

Add Payroll Check Set On Web
    [Documentation]    This keyword is used to add Payroll Check Set. It takes check set id and check set name
    ...    as argument values to create the check set.
    ...    | =Arguments=    | =Description= |
    ...    | check_set_name    | Check Set Name to be added |
    ...    | check_set_id    | (Optional) Check Set ID to be added. If not provided, current timestamp will be used as check set id |
    ...    | check_set_description    | (Optional) Check Set Description to be added |
    [Arguments]    ${check_set_name}    ${check_set_id}=${None}    ${check_set_description}=${None}
    IF    '${check_set_id}' == '${None}'
        ${date_format}    Get Config Value    DATE_FMT_MONTH_DAY_YEAR_HOUR_MINUTE_SECOND_NO_SEPARATOR
        ${check_set_id}    Get Current Date    result_format=${date_format}
    END
    Click Element On Webpage    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_ADD_BTN}
    Wait Until Element Disappears On Webpage    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_ADD_BTN}
    Wait Until Element Is Visible On Webpage    ${RELEASECHECKSPAGE_CHECKSET_ID_TXTBOX}    timeout=30s
    ...    error_message=Check Set ID textbox is not visible after clicking on Add Payroll Check Set button!
    Fill Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_ID_TXTBOX}    ${check_set_id}
    Fill Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_NAME_TXTBOX}    ${check_set_name}
    IF    '${check_set_description}' != '${None}'
        Fill Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_DESCRIPTION_TXTBOX}    ${check_set_description}
    END
    Save The Check Set On Web
    Capture Screenshot On Webpage
    RETURN    ${check_set_id}

Save The Check Set On Web
    [Documentation]    This keyword is used to save the added/modified checkset for Payroll/Policy.
    Click Element On Webpage    ${RELEASECHECKSPAGE_SAVE_CHECKSET_BTN}
    Verify If Success Notifier Message Is Displayed On Web

Verify If Success Notifier Message Is Displayed On Web
    [Documentation]    This keyword is used to verify if success message is displayed after adding/editing
    ...    checksets.
    Wait Until Element Is Visible On Webpage    ${RELEASECHECKSPAGE_SUCCESS_NOTIFIER_MSG}
    ...    error_message=Success message not displayed!
    Capture Screenshot On Webpage
    Wait Until Element Disappears On Webpage    ${RELEASECHECKSPAGE_SUCCESS_NOTIFIER_MSG}

Verify If Check Set Is Displayed In Payroll Check Sets Section On Web
    [Documentation]    This keyword verifies if the added/edited checkset is displayed in Payroll Check Sets
    ...    section. It accepts check set id to verify check set details.
    ...    | =Arguments=    | =Description= |
    ...    | check_set_id    | Check Set ID to verify in Payroll Check Sets section |
    [Arguments]    ${check_set_id}
    Wait Until Element Is Visible On Webpage    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_SECTION_TITLE}
    ${payroll_checksets_count}    Get Element Count
    ...    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_TBL_CONTENT_COUNT}
    VAR    ${found_at_index}    ${None}
    FOR    ${index}    IN RANGE    1    ${payroll_checksets_count}+1
        ${index_string}    Convert To String    ${index}
        ${payroll_checkset_id_element}    Update Locator With Dynamic Values    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_LIST_CHECKSET_ID}
        ...    INDEX=${index_string}
        ${payroll_checkset_id}    Get Element Text On Webpage    ${payroll_checkset_id_element}
        IF    '${payroll_checkset_id}' == '${check_set_id}'
            ${actual_payroll_checkset_name}    Update Locator With Dynamic Values
            ...    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_LIST_CHECKSET_NAME}    INDEX=${index_string}
            ${payroll_checkset_name}    Get Element Text On Webpage    ${actual_payroll_checkset_name}
            ${actual_payroll_checkset_status}    Update Locator With Dynamic Values
            ...    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_LIST_CHECKSET_STATUS}    INDEX=${index_string}
            ${payroll_checkset_status}    Get Element Text On Webpage    ${actual_payroll_checkset_status}
            VAR    ${found_at_index}    ${index}
            BREAK
        END
    END
    IF    '${found_at_index}' != '${None}'
        Capture Screenshot On Webpage
        RETURN    ${payroll_checkset_name}    ${payroll_checkset_status}
    ELSE
        Capture Screenshot On Webpage
        Fail    Checkset with id ${check_set_id} is not found in Payroll Check Sets!!
    END

Open Check Set From Payroll Check Sets On Web
    [Documentation]    This keyword is used to delete the check set from Payroll check sets.
    ...    | =Arguments=    | =Description= |
    ...    | check_set_id    | Check Set ID to be opened in Payroll Check Sets section |
    [Arguments]    ${check_set_id}
    ${payroll_checksets_count}    Get Element Count
    ...    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_TBL_CONTENT_COUNT}
    VAR    ${found_at_index}    ${None}
    FOR    ${index}    IN RANGE    1    ${payroll_checksets_count}+1
        ${index_string}    Convert To String    ${index}
        ${payroll_checkset_id_element}    Update Locator With Dynamic Values    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_LIST_CHECKSET_ID}
        ...    INDEX=${index_string}
        ${payroll_checkset_id}    Get Element Text On Webpage    ${payroll_checkset_id_element}
        IF    '${payroll_checkset_id}' == '${check_set_id}'
            VAR    ${found_at_index}    ${index}
            Click Element On Webpage    ${payroll_checkset_id_element}
            Wait Until Page Is Loaded
            BREAK
        END
    END
    IF    '${found_at_index}' == '${None}'
        Capture Screenshot On Webpage
        Fail    Couldn't open checkset with id ${check_set_id} as it is not found in Payroll Check Sets!
    END

Update Check Set Name On Web
    [Documentation]    This keyword updates the checkset name for Payroll/Policy check sets. It
    ...    accepts a new value to be updated. User needs to be on edit check set page.
    ...    checkset page.
    [Arguments]    ${check_set_name_to_be_updated}
    Clear Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_NAME_TXTBOX}
    Fill Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_NAME_TXTBOX}    ${check_set_name_to_be_updated}
    Capture Screenshot On Webpage

Update Check Set Description On Web
    [Documentation]    This keyword updates the checkset description for Payroll/Policy check sets. It
    ...    accepts a new value to be updated. User needs to be on edit check set page.
    ...    checkset page.
    [Arguments]    ${check_set_desc_to_be_updated}
    Clear Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_DESCRIPTION_TXTBOX}
    Fill Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_DESCRIPTION_TXTBOX}    ${check_set_desc_to_be_updated}
    Capture Screenshot On Webpage

Update Check Set Status On Web
    [Documentation]    This keyword is used to update Status value based on input argument. User needs
    ...    to be on edit check set page.
    [Arguments]    ${status_option}
    Select List Item On Webpage    ${RELEASECHECKSPAGE_CHECKSET_STATUS_DRPDWN}    attribute=text
    ...    value=${status_option}
    Capture Screenshot On Webpage

Delete Check Set From Payroll Check Sets On Web
    [Documentation]    This keyword is used to delete the check set from Payroll check sets.
    ...    | =Arguments=    | =Description= |
    ...    | check_set_id    | Check Set ID to be deleted in Policy Check Sets section |
    [Arguments]    ${check_set_id}
    ${payroll_checksets_count}    Get Element Count
    ...    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_TBL_CONTENT_COUNT}
    VAR    ${found_at_index}    ${None}
    FOR    ${index}    IN RANGE    1    ${payroll_checksets_count}+1
        ${index_string}    Convert To String    ${index}
        ${payroll_checkset_id_element}    Update Locator With Dynamic Values    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_LIST_CHECKSET_ID}
        ...    INDEX=${index_string}
        ${payroll_checkset_id}    Get Element Text On Webpage    ${payroll_checkset_id_element}
        IF    '${payroll_checkset_id}' == '${check_set_id}'
            VAR    ${found_at_index}    ${index}
            Click Element On Webpage    ${payroll_checkset_id_element}
            BREAK
        END
    END
    IF    '${found_at_index}' != '${None}'
        Delete The Check Set On Web
        ${payroll_checksets_new_count}    Get Element Count
        ...    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_TBL_CONTENT_COUNT}
        IF    ${payroll_checksets_new_count} > 0
            FOR    ${index}    IN RANGE    1    ${payroll_checksets_new_count}+1
                ${index_string}    Convert To String    ${index}
                ${payroll_checkset_id_element}    Update Locator With Dynamic Values
                ...    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_LIST_CHECKSET_ID}    INDEX=${index_string}
                ${payroll_checkset_element_visible}    Is Element Visible On Webpage    ${payroll_checkset_id_element}
                IF    ${payroll_checkset_element_visible}
                    ${payroll_checkset_id}    Get Element Text On Webpage    ${payroll_checkset_id_element}
                    IF    '${payroll_checkset_id}' == '${check_set_id}'
                        Log    Payroll Check Set is still visible on webpage.
                        Fail    Couldn't delete checkset with id ${check_set_id} as it is still found in Payroll Check Sets!
                        BREAK
                    END
                END
            END
        END
        Capture Screenshot On Webpage
        Log    The checkset with ID ${check_set_id} is deleted successfully!
    ELSE
        Capture Screenshot On Webpage
        Fail    Couldn't delete checkset with id ${check_set_id} as it is not found in Payroll Check Sets!!
    END

Delete The Check Set On Web
    [Documentation]    This keyword is used to delete the checkset for Payroll/Policy.
    Wait Until Element Is Visible On Webpage    ${RELEASECHECKSPAGE_DELETE_CHECKSET_BTN}
    ...    timeout=${LONG_TIMEOUT}    error_message=Delete checkset button is not visible!
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${RELEASECHECKSPAGE_DELETE_CHECKSET_BTN}
    ...    error_message=Failed to click on delete checkset button
    Wait For    ${promise}
    Verify If Success Notifier Message Is Displayed On Web

Add Policy Check Set On Web
    [Documentation]    This keyword is used to add Policy Check Set. It takes check set id and check set name
    ...    as argument values to create the check set. If checkset id is not provide, it will add timestamp
    ...    as checkset id.
    ...    | =Arguments=    | =Description= |
    ...    | check_set_name    | Check Set Name to be added |
    ...    | check_set_id    | (Optional) Check Set ID to be added. If not provided, current timestamp will be used as check set id |
    ...    | check_set_description    | (Optional) Check Set Description to be added |
    [Arguments]    ${check_set_name}    ${check_set_id}=${None}    ${check_set_description}=${None}
    IF    '${check_set_id}' == '${None}'
        ${date_format}    Get Config Value    DATE_FMT_MONTH_DAY_YEAR_HOUR_MINUTE_SECOND_NO_SEPARATOR
        ${check_set_id}    Get Current Date    result_format=${date_format}
    END
    Click Element On Webpage    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_ADD_BTN}
    Wait Until Element Disappears On Webpage    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_ADD_BTN}
    Wait Until Element Is Visible On Webpage    ${RELEASECHECKSPAGE_CHECKSET_ID_TXTBOX}    timeout=30s
    ...    error_message=Check Set ID textbox did not become visible after clicking the Add Policy Check Set button; verify that the Add Policy Check Set dialog opened successfully.
    Fill Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_ID_TXTBOX}    ${check_set_id}
    Fill Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_NAME_TXTBOX}    ${check_set_name}
    IF    '${check_set_description}' != '${None}'
        Fill Textbox On Webpage    ${RELEASECHECKSPAGE_CHECKSET_DESCRIPTION_TXTBOX}    ${check_set_description}
    END
    Save The Check Set On Web
    Capture Screenshot On Webpage
    RETURN    ${check_set_id}

Verify If Check Set Is Displayed In Policy Check Sets Section On Web
    [Documentation]    This keyword verifies if the added/edited checkset is displayed in Payroll Check Sets
    ...    section. It accepts check set id to verify check set details.
    ...    | =Arguments=    | =Description= |
    ...    | check_set_id    | Check Set ID to verify in Policy Check Sets section |
    [Arguments]    ${check_set_id}
    Wait Until Element Is Visible On Webpage    ${RELEASECHECKSPAGE_PAYROLL_CHECKSETS_SECTION_TITLE}
    ${policy_checksets_count}    Get Element Count
    ...    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_TBL_CONTENT_COUNT}
    VAR    ${found_at_index}    ${None}
    FOR    ${index}    IN RANGE    1    ${policy_checksets_count}+1
        ${index_string}    Convert To String    ${index}
        ${policy_checkset_id_element}    Update Locator With Dynamic Values    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_LIST_CHECKSET_ID}
        ...    INDEX=${index_string}
        ${policy_checkset_id}    Get Element Text On Webpage    ${policy_checkset_id_element}
        IF    '${policy_checkset_id}' == '${check_set_id}'
            ${actual_policy_checkset_name}    Update Locator With Dynamic Values
            ...    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_LIST_CHECKSET_NAME}    INDEX=${index_string}
            ${policy_checkset_name}    Get Element Text On Webpage    ${actual_policy_checkset_name}
            ${actual_policy_checkset_status}    Update Locator With Dynamic Values
            ...    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_LIST_CHECKSET_STATUS}    INDEX=${index_string}
            ${policy_checkset_status}    Get Element Text On Webpage    ${actual_policy_checkset_status}
            VAR    ${found_at_index}    ${index}
            BREAK
        END
    END
    IF    '${found_at_index}' != '${None}'
        Capture Screenshot On Webpage
        RETURN    ${policy_checkset_name}    ${policy_checkset_status}
    ELSE
        Capture Screenshot On Webpage
        Fail    Checkset with checkset id ${check_set_id} is not found in Policy Check Sets!!
    END

Open Check Set From Policy Check Sets On Web
    [Documentation]    This keyword is used to delete the check set from Policy check sets.
    ...    | =Arguments=    | =Description= |
    ...    | check_set_id    | Check Set ID to be opened in Policy Check Sets section |
    [Arguments]    ${check_set_id}
    ${policy_checksets_count}    Get Element Count
    ...    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_TBL_CONTENT_COUNT}
    VAR    ${found_at_index}    ${None}
    FOR    ${index}    IN RANGE    1    ${policy_checksets_count}+1
        ${index_string}    Convert To String    ${index}
        ${policy_checkset_id_element}    Update Locator With Dynamic Values    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_LIST_CHECKSET_ID}
        ...    INDEX=${index_string}
        ${policy_checkset_id}    Get Element Text On Webpage    ${policy_checkset_id_element}
        IF    '${policy_checkset_id}' == '${check_set_id}'
            VAR    ${found_at_index}    ${index}
            Click Element On Webpage    ${policy_checkset_id_element}
            Wait Until Page Is Loaded
            BREAK
        END
    END
    IF    '${found_at_index}' == '${None}'
        Capture Screenshot On Webpage
        Fail    Couldn't open checkset with id ${check_set_id} as it is not found in Policy Check Sets!
    END

Delete Check Set From Policy Check Sets On Web
    [Documentation]    This keyword is used to delete the check set from Policy check sets.
    ...    | =Arguments=    | =Description= |
    ...    | check_set_id    | Check Set ID to be deleted in Policy Check Sets section |
    [Arguments]    ${check_set_id}
    ${policy_checksets_count}    Get Element Count
    ...    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_TBL_CONTENT_COUNT}
    VAR    ${found_at_index}    ${None}
    FOR    ${index}    IN RANGE    1    ${policy_checksets_count}+1
        ${index_string}    Convert To String    ${index}
        ${policy_checkset_id_element}    Update Locator With Dynamic Values    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_LIST_CHECKSET_ID}
        ...    INDEX=${index_string}
        ${policy_checkset_id}    Get Element Text On Webpage    ${policy_checkset_id_element}
        IF    '${policy_checkset_id}' == '${check_set_id}'
            VAR    ${found_at_index}    ${index}
            Click Element On Webpage    ${policy_checkset_id_element}
            BREAK
        END
    END
    IF    '${found_at_index}' != '${None}'
        Delete The Check Set On Web
        ${policy_checksets_new_count}    Get Element Count
        ...    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_TBL_CONTENT_COUNT}
        IF    ${policy_checksets_new_count} > 0
            FOR    ${index}    IN RANGE    1    ${policy_checksets_new_count}+1
                ${index_string}    Convert To String    ${index}
                ${policy_checkset_id_element}    Update Locator With Dynamic Values
                ...    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_LIST_CHECKSET_ID}    INDEX=${index_string}
                ${policy_checkset_element_visible}    Is Element Visible On Webpage    ${policy_checkset_id_element}
                IF    ${policy_checkset_element_visible}
                    ${policy_checkset_id}    Get Element Text On Webpage    ${policy_checkset_id_element}
                    IF    '${policy_checkset_id}' == '${check_set_id}'
                        Log    Policy Check Set is still visible on webpage.
                        Fail    Couldn't delete checkset with id ${check_set_id} as it is still found in Policy Check Sets!
                        BREAK
                    END
                END
            END
        END
        Capture Screenshot On Webpage
        Log    The checkset with ID ${check_set_id} is deleted successfully!
    ELSE
        Capture Screenshot On Webpage
        Fail    Couldn't delete checkset with id ${check_set_id} as it is not found in Policy Check Sets!!
    END

Open An Existing Check Set From Payroll Check Sets On Web
    [Documentation]    This keyword checks if check set exists in payroll check sets.If exists, it opens
    ...    the first check set in the list. If not present, it will log message.
    Wait Until Element Is Visible On Webpage    ${releasecheckspage_payroll_checksets_section_title}
    ${check_set_present}    Is Element Present On Webpage
    ...    ${releasecheckspage_payroll_checksets_tbl_contents}/tr[2]/td[1]/a
    IF    ${check_set_present}
        Click Element On Webpage
        ...    ${releasecheckspage_payroll_checksets_tbl_contents}/tr[2]/td[1]/a
        Wait Until Page Is Loaded
        Capture Screenshot On Webpage
        Go Back To Check Set List Page On Web
        Capture Screenshot On Webpage
    END
    RETURN    ${check_set_present}

Open An Existing Check Set From Policy Check Sets On Web
    [Documentation]    This keyword checks if check set exists in policy check sets.If exists, it opens
    ...    the first check set in the list. If not present, it will log message.
    Wait Until Element Is Visible On Webpage    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_SECTION_TITLE}
    ${check_set_present}    Is Element Present On Webpage
    ...    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_TBL_CONTENTS}/tr[2]/td[1]/a
    IF    ${check_set_present}
        Click Element On Webpage
        ...    ${RELEASECHECKSPAGE_POLICY_CHECKSETS_TBL_CONTENTS}/tr[2]/td[1]/a
        Wait Until Page Is Loaded
        Capture Screenshot On Webpage
        Go Back To Check Set List Page On Web
        Capture Screenshot On Webpage
    END
    RETURN    ${check_set_present}

Go Back To Check Set List Page On Web
    [Documentation]    This keyword is used to go back from check set detail page to check set list page.
    Click Element On Webpage    ${RELEASECHECKSPAGE_PREVIOUS_BTN}
    Wait Until Page Is Loaded

Verify Payroll Check Set Name And Status On Release Checks Page On Web
    [Documentation]    This keyword verifies the check set name and status in release checks page.
    ...    | =Arguments= | =Description= |
    ...    | payroll_checkset_id    | Check Set ID to verify in Payroll Check Sets section |
    ...    | expected_checkset_name    | Expected Check Set Name to verify |
    ...    | expected_checkset_status    | Expected Check Set Status to verify |
    [Arguments]    ${payroll_checkset_id}    ${expected_checkset_name}    ${expected_checkset_status}
    ${actual_checkset_name}    ${actual_checkset_status}    Verify If Check Set Is Displayed In Payroll Check Sets Section On Web
    ...    ${payroll_checkset_id}
    Should Be Equal As Strings    ${actual_checkset_name}    ${expected_checkset_name}
    Should Be Equal As Strings    ${actual_checkset_status}    ${expected_checkset_status}

Verify Policy Check Set Name And Status On Release Checks Page On Web
    [Documentation]    This keyword verifies the check set name and status in release checks page.
    ...    | =Arguments= | =Description= |
    ...    | policy_checkset_id    | Check Set ID to verify in Policy Check Sets section |
    ...    | expected_checkset_name    | Expected Check Set Name to verify |
    ...    | expected_checkset_status    | Expected Check Set Status to verify |
    [Arguments]    ${policy_checkset_id}    ${expected_checkset_name}    ${expected_checkset_status}
    ${actual_checkset_name}    ${actual_checkset_status}    Verify If Check Set Is Displayed In Policy Check Sets Section On Web
    ...    ${policy_checkset_id}
    Should Be Equal As Strings    ${actual_checkset_name}    ${expected_checkset_name}
    Should Be Equal As Strings    ${actual_checkset_status}    ${expected_checkset_status}

Cleanup Existing Check Set On Web
    [Documentation]    This keyword cleans up existing check set.
    ...    | =Arguments= | =Description= |
    ...    | check_set_id    | Check Set ID to cleanup in Check Sets section |
    [Arguments]    ${check_set_id}
    ${check_set_link}    Update Locator With Dynamic Values    ${RELEASECHECKSPAGE_CHECKSETS_ID_LINK}    CHECKSET_ID=${check_set_id}
    ${is_checkset_id_already_present}    Is Element Present On Webpage    ${check_set_link}
    IF    ${is_checkset_id_already_present}
        Click Element On Webpage    ${check_set_link}
        ...    error_message=Failed to click on check set link
        Delete The Check Set On Web
    END
