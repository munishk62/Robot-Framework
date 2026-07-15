*** Settings ***
Documentation       Resource file for Accrual Plan Page related keywords

Resource            resources/web/common/common.resource
Resource            resources/web/common/common_date_utility.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rta/operations/accrual_plan_page_locators.py
Variables           resources/web/rta/operations/accrual_plan_page_api.py


*** Keywords ***
Navigate To RTA HR Accrual Plan Page On Web
    [Documentation]    Navigate To RTA -> HR -> Accrual Plan Page
    ...    and verifies accrual plan heading at the top of the page
    Navigate To Specific Page On Web    rta    hr    accrual_plan

Fill Details In Accrual Plan Page On Web
    [Documentation]    This keyword fills the details in accrual plan page form
    ...    | =Arguments= | =Description= |
    ...    | accrual_id | The ID to be filled in the ID field. |
    ...    | accrual_plan_name | The name to be filled in the Name field. |
    ...    | accrual_desc | The description to be filled in the Description field. |
    ...    | accrual_status | The status to be selected from the Status dropdown. |
    ...    | accrual_term_type | The term type to be selected from the Term Type dropdown. |
    ...    | plan_accrual_frequency | The accrual frequency to be selected from the Accrual Frequency dropdown. |
    ...    | created_status_code | The expected status code after saving the accrual plan details. |
    ...    Example usage:
    ...    | Fill Details In Accrual Plan Page On Web    ACCRUAL001    Annual Leave Plan
    ...    This is an annual leave accrual plan.    Active    Yearly    Monthly    201
    [Arguments]    ${accrual_id}
    ...    ${accrual_plan_name}
    ...    ${accrual_desc}
    ...    ${accrual_status}
    ...    ${accrual_term_type}
    ...    ${plan_accrual_frequency}
    ...    ${created_status_code}
    Fill ID Field On Accrual Plan Page On Web    ${accrual_id}
    Fill Name Field On Accrual Plan Page On Web    ${accrual_plan_name}
    Fill Description Field On Accrual Plan Page On Web    ${accrual_desc}
    Select Status From Dropdown On Accrual Plan Page    ${accrual_status}
    Select Term Type From Dropdown On Accrual Plan Page    ${accrual_term_type}
    Select Accrual Frequency From Dropdown On Accrual Plan Page    ${plan_accrual_frequency}
    Click Checkbox In Caps Applicable On Accrual Plan Page On Web
    Click Save And Next Button On Web    ${created_status_code}

Fill ID Field On Accrual Plan Page On Web
    [Documentation]    This keyword fills the ID field in the accrual plan page form
    ...    | =Arguments= | =Description= |
    ...    | accrual_id | The ID to be filled in the ID field. |
    ...    Example usage:
    ...    | Fill ID Field On Accrual Plan Page On Web    ACCRUAL
    [Arguments]    ${accrual_id}
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PAGE_ADD_ID}
    Fill Textbox On Webpage    ${ACCRUAL_PAGE_ADD_ID}    ${accrual_id}

Fill Name Field On Accrual Plan Page On Web
    [Documentation]    This keyword fills the Name field in the accrual plan page form
    ...    | =Arguments= | =Description= |
    ...    | accrual_plan_name | The name to be filled in the Name field. |
    ...    Example usage:
    ...    | Fill Name Field On Accrual Plan Page On Web    Annual Leave Plan
    [Arguments]    ${accrual_plan_name}
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PAGE_ADD_NAME}    error_message=Name field is not visible on Accrual Plan page
    Clear Textbox On Webpage    ${ACCRUAL_PAGE_ADD_NAME}
    Fill Textbox On Webpage    ${ACCRUAL_PAGE_ADD_NAME}    ${accrual_plan_name}

Fill Description Field On Accrual Plan Page On Web
    [Documentation]    This keyword fills the Description field in the accrual plan page form
    ...    | =Arguments= | =Description= |
    ...    | accrual_desc | The description to be filled in the Description field. |
    ...    Example usage:
    ...    | Fill Description Field On Accrual Plan Page On Web    This is an annual leave accrual plan.
    [Arguments]    ${accrual_desc}
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PAGE_ADD_DESCRIPTION}
    Clear Textbox On Webpage    ${ACCRUAL_PAGE_ADD_DESCRIPTION}
    Fill Textbox On Webpage    ${ACCRUAL_PAGE_ADD_DESCRIPTION}    ${accrual_desc}

Select Status From Dropdown On Accrual Plan Page
    [Documentation]    This keyword selects status from dropdown in accrual plan page form
    ...    | =Arguments= | =Description= |
    ...    | accrual_status | The status to be selected from the Status dropdown. |
    ...    Example usage:
    ...    | Select Status From Dropdown On Accrual Plan Page    Active
    [Arguments]    ${accrual_status}
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PAGE_SELECT_STATUS}
    Select Dropdown Option By Name On Accrual Plan Page    ${ACCRUAL_PAGE_SELECT_STATUS}    ${accrual_status}

Select Term Type From Dropdown On Accrual Plan Page
    [Documentation]    This keyword selects term type from dropdown in accrual plan page form
    ...    | =Arguments= | =Description= |
    ...    | accrual_term_type | The term type to be selected from the Term Type dropdown. |
    ...    Example usage:
    ...    | Select Term Type From Dropdown On Accrual Plan Page    Yearly
    [Arguments]    ${accrual_term_type}
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PAGE_SELECT_TERMTYPE}
    Select Dropdown Option By Name On Accrual Plan Page    ${ACCRUAL_PAGE_SELECT_TERMTYPE}    ${accrual_term_type}

Select Accrual Frequency From Dropdown On Accrual Plan Page
    [Documentation]    This keyword selects accrual frequency from dropdown in accrual plan page form
    ...    | =Arguments= | =Description= |
    ...    | plan_accrual_frequency | The accrual frequency to be selected from the Accrual Frequency dropdown. |
    ...    Example usage:
    ...    | Select Accrual Frequency From Dropdown On Accrual Plan Page    Monthly
    [Arguments]    ${plan_accrual_frequency}
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PAGE_SELECT_ACCRUALFREQUENCY}
    Select Dropdown Option By Name On Accrual Plan Page    ${ACCRUAL_PAGE_SELECT_ACCRUALFREQUENCY}
    ...    ${plan_accrual_frequency}

Click Checkbox In Caps Applicable On Accrual Plan Page On Web
    [Documentation]    This keyword will click on Caps Applicable checkboxes in accrual plan page form
    ...    Example usage:
    ...    | Click Checkbox In Caps Applicable On Accrual Plan Page On Web
    Click Element On Webpage    ${ACCRUAL_PAGE_CAPS_CARRYOVER_CHECKBOX}
    Click Element On Webpage    ${ACCRUAL_PAGE_CAPS_BALANCE_CHECKBOX}

Click Save And Next Button On Web
    [Documentation]    This keyword click on Save and Next button in accrual plan page form
    ...    and verifies the response status code after saving the details
    ...    | =Arguments= | =Description= |
    ...    | status_code | The expected status code after saving the accrual plan details. |
    ...    Example usage:
    ...    | Click Save And Next Button On Web    201
    [Arguments]    ${status_code}
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PAGE_SAVE_ACCRUAL_PLAN}
    ${promise}    Promise To    Wait For Response    ${SAVE_ACCRUAL_PLAN_DETAILS_API}
    Click Element On Webpage    ${ACCRUAL_PAGE_SAVE_ACCRUAL_PLAN}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.body}
    Should Be Equal As Strings    ${response_body.status}    ${status_code}
    Wait Until Element Disappears On Webpage    ${ACCRUAL_PAGE_SUCCESS_MESSAGE}
    Capture Screenshot On Webpage

Go Back To Accrual Plan List On Web
    [Documentation]    This will click on Previous Button, present in plan details page
    ...    to get back to accrual plan list page
    Is Element Visible On Webpage    ${ACCRUAL_PAGE_PREVIOUS_BUTTON}
    Click Element On Webpage    ${ACCRUAL_PAGE_PREVIOUS_BUTTON}
    Click Element On Webpage    ${ACCRUAL_PAGE_ACCRUAL_PLAN_LIST}

Verify Accrual Plan Is Shown In Accrual Plan Page On Web
    [Documentation]    This keyword will verify the accrual plan with provided id and name present in accrual plan list
    [Arguments]    ${accrual_plan_id}    ${accrual_plan_name}    ${accrual_plan_status}    ${accrual_plan_desc}
    Wait Until Page Is Loaded
    ${id_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_ID_ATTRIBUTE}    TEMP_ID=${accrual_plan_id}
    Scroll And Verify Element Presence On Webpage    ${id_locator}
    Wait Until Element Is Visible On Webpage    ${id_locator}
    ${name_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_NAME_ATTRIBUTE}    TEMP_NAME=${accrual_plan_name}
    Wait Until Element Is Visible On Webpage    ${name_locator}
    ${delete_sign_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_DELETE_BUTTON}    TEMP_ID=${accrual_plan_id}
    Wait Until Element Is Visible On Webpage    ${delete_sign_locator}
    ${copy_sign_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_COPY_SIGN_LOCATOR}    TEMP_ID=${accrual_plan_id}
    Wait Until Element Is Visible On Webpage    ${copy_sign_locator}
    ${status_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_STATUS_LOCATOR}    TEMP_ID=${accrual_plan_id}
    ${status_text}    Get Element Text On Webpage    ${status_locator}
    Should Be Equal    ${status_text}    ${accrual_plan_status}
    ${desc_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_DESC_LOCATOR}    TEMP_ID=${accrual_plan_id}
    ${desc_text}    Get Element Text On Webpage    ${desc_locator}
    Should Be Equal    ${desc_text}    ${accrual_plan_desc}
    Capture Screenshot On Webpage

Click Add New Accrual Plan On Web
    [Documentation]    This keyword will navigate user to add new Accrual plan page
    Click Element On Webpage    ${ACCRUAL_PAGE_ADD_ACCRUAL_PLAN}
    Wait Until Page Is Loaded

Verify Accrual Page Is Loaded On Web
    [Documentation]    This keyword verifies loading of Accrual Plan page
    Wait Until Page Is Loaded
    Get Element Text On Webpage    ${ACCRUAL_PAGE_ACCRUAL_LIST_TAB}

View Accrual Plan Details By ID On Web
    [Documentation]    This will show added accrual plan details using its id
    [Arguments]    ${Accrual_plan_id}
    ${id_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_ID_ATTRIBUTE}    TEMP_ID=${Accrual_plan_id}
    Click Element On Webpage    ${id_locator}
    Wait Until Page Is Loaded

Delete Accrual Plan By ID On Web
    [Documentation]    This will delete accrual plan by provided id in accrual plan list page
    ...    and verifies the response status code after deleting the details
    ...    | =Arguments= | =Description= |
    ...    | accrual_plan_id | The ID of the accrual plan to be deleted. |
    ...    | ok_status_code | The expected status code after deleting the accrual plan. |
    ...    Example usage:
    ...    | Delete Accrual Plan By ID On Web    ACCRUAL001    200
    [Arguments]    ${accrual_plan_id}    ${ok_status_code}
    ${delete_sign_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_DELETE_BUTTON}    TEMP_ID=${accrual_plan_id}
    Wait Until Element Is Visible On Webpage    ${delete_sign_locator}    timeout=${LONG_TIMEOUT}
    ${promise_1}    Promise To    Wait For Alert    action=accept
    ${promise_2}    Promise To    Wait For Response    ${DELETE_ACCRUAL_PLAN_DETAILS_API}
    Click Element On Webpage    ${delete_sign_locator}
    Wait For    ${promise_1}
    ${response_body}    Wait For    ${promise_2}
    Log    ${response_body.status}
    Should Be Equal As Strings    ${response_body.status}    ${ok_status_code}
    Wait Until Element Disappears On Webpage    ${ACCRUAL_PAGE_SUCCESS_MESSAGE}

Verify Accrual Plan Not Shown In Accrual Plan Page On Web
    [Documentation]    This keyword will verify the accrual plan with provided id and name
    ...    is not present in accrual plan list
    [Arguments]    ${id}    ${name}
    ${id_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_ID_ATTRIBUTE}    TEMP_ID=${id}
    ${name_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_NAME_ATTRIBUTE}    TEMP_NAME=${name}
    Wait Until Element Is Detached On Webpage    ${id_locator}
    Wait Until Element Is Detached On Webpage    ${name_locator}
    Capture Screenshot On Webpage

Select Dropdown Option By Name On Accrual Plan Page
    [Documentation]    Select an option from dropdown by clicking on dropdown and then option
    ...    | =Arguments= | =Description= |
    ...    | dropdown_button_locator | Locator for the dropdown button to open the options. |
    ...    | option_value | The visible text/value of the option to select. |
    ...    Example usage:
    ...    | Select Dropdown Option By Name    id=dropdown-btn    start date
    [Arguments]    ${dropdown_button_locator}    ${option_to_select}
    Click Element On Webpage    ${dropdown_button_locator}
    ${option_value}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_DROPDOWN_LOCATOR}    STATUS_VALUE=${option_to_select}
    Click Element On Webpage    ${option_value}

Edit Accrual Plan Details On Accrual Plan Page On Web
    [Documentation]    This keyword will edit accrual plan description by provided id in accrual plan list page
    ...    and verifies the response status code after saving the details
    ...    | =Arguments= | =Description= |
    ...    | accrual_plan_id | The ID of the accrual plan to be edited. |
    ...    | edit_accrual_plan_desc | The new description to be filled in the Description field. |
    ...    | ok_status_code | The expected status code after editing the accrual plan. |
    ...    Example usage:
    ...    | Edit Accrual Plan Details On Accrual Plan Page On Web    ACCRUAL001
    ...    Updated description for the accrual plan.    200
    [Arguments]    ${accrual_plan_id}    ${edit_accrual_plan_desc}    ${ok_status_code}
    View Accrual Plan Details By ID On Web    ${accrual_plan_id}
    Fill Description Field On Accrual Plan Page On Web    ${edit_accrual_plan_desc}
    Click Save And Next Button On Web    ${ok_status_code}

Copy Accrual Plan By ID On Accrual Plan Page On Web
    [Documentation]    This will copy accrual plan by provided id in accrual plan list page
    ...    and verifies the response status code after copying the details
    ...    | =Arguments= | =Description= |
    ...    | accrual_plan_id | The ID of the accrual plan to be copied. |
    ...    | new_accrual_plan_id | The new ID to be assigned to the copied accrual plan. |
    ...    | new_accrual_plan_name | The new name to be assigned to the copied accrual plan. |
    ...    | ok_status_code | The expected status code after copying the accrual plan. |
    ...    Example usage:
    ...    | Copy Accrual Plan By ID On Accrual Plan Page On Web    ACCRUAL001
    ...    ACCRUAL002    Annual Leave Plan Copy    201
    [Arguments]    ${accrual_plan_id}    ${new_accrual_plan_id}    ${new_accrual_plan_name}    ${ok_status_code}
    ${copy_sign_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_COPY_SIGN_LOCATOR}    TEMP_ID=${accrual_plan_id}
    Click Element On Webpage    ${copy_sign_locator}
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PAGE_COPY_NEW_ID}
    Fill Textbox On Webpage    ${ACCRUAL_PAGE_COPY_NEW_ID}    ${new_accrual_plan_id}
    Fill Textbox On Webpage    ${ACCRUAL_PAGE_COPY_NEW_NAME}    ${new_accrual_plan_name}
    Wait Until Element Is Visible On Webpage    ${ACCRUAL_PAGE_COPY_OK_BUTTON}
    ${promise}    Promise To    Wait For Response    ${COPY_ACCRUAL_PLAN_DETAILS_API}
    Click Element On Webpage    ${ACCRUAL_PAGE_COPY_OK_BUTTON}
    ${response_body}    Wait For    ${promise}
    Log    ${response_body.status}
    Should Be Equal As Strings    ${response_body.status}    ${ok_status_code}
    Wait Until Element Disappears On Webpage    ${ACCRUAL_PAGE_SUCCESS_MESSAGE}
    Wait Until Page Is Loaded

Cleanup Accrual Plans If Exists On Web
    [Documentation]    This keyword will delete the accrual plans if exists in accrual plan list page using their ids
    ...    | =Arguments= | =Description= |
    ...    | @{accrual_plan_ids} | The list of IDs of accrual plans to be deleted. |
    ...    Example usage:
    ...    | Cleanup Accrual Plans If Exists On Web    ACCRUAL001    ACCRUAL002 |
    [Arguments]    @{accrual_plan_ids}
    ${status_code}    Get System Value    HttpStatusCode    OK
    FOR    ${plan_id}    IN    @{accrual_plan_ids}
        ${delete_sign_locator}    Update Locator With Dynamic Values    ${ACCRUAL_PAGE_DELETE_BUTTON}    TEMP_ID=${plan_id}
        ${is_plan_present}    Is Element Present On Webpage    ${delete_sign_locator}
        IF    ${is_plan_present}
            Delete Accrual Plan By ID On Web    ${plan_id}    ${status_code}
        END
    END
