*** Settings ***
Documentation       RTA > HR > Pay Policy page related keywords

Resource            resources/web/common/common.resource
Library             resources/web/common/utility.py
Variables           resources/web/rta/operations/pay_policy_page.py
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RTA HR Pay Policy Page On Web
    [Documentation]    Navigate To RTA -> HR -> Pay Policy Page
    ...    and verifies pay policy heading at the top of the page
    Navigate To Specific Page On Web    rta    hr    pay_policy

Verify Pay Policy Page Is Loaded On Web
    [Documentation]    This keyword verifies loading of Pay Policy page
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_HEADING}

Verify Add Pay Policy Button Present On Web
    [Documentation]    This keyword verifies presence of Add Pay Policy button on Pay Policy page
    ${add_button_present}    Is Element Visible On Webpage    ${PAY_POLICY_PAGE_ADD_BTN}
    RETURN    ${add_button_present}

Select Add New Pay Policy On Web
    [Documentation]    This keyword will navigate user to pay policy details page
    Click Element On Webpage    ${PAY_POLICY_PAGE_ADD_BTN}

Get Range Of Date For Pay Policy To Be Active From Current Date On Web
    [Documentation]    Get range of date for pay policy to be active
    ...    | =Arguments= | =Description= |
    ...    | days_from_current_day | No. of days from current day |
    ...    | =Returns= | =Description= |
    ...    | target_date | effective date / end date for pay policy |
    [Arguments]    ${days_from_current_day}
    ${pay_policy_date_format}    Get Config Value    DATE_FORMAT_MONTH_DAY_YEAR
    ${current_date}    Get Current Date    result_format=${pay_policy_date_format}
    ${target_date}    Add Time To Date    ${current_date}
    ...    ${days_from_current_day}    date_format=${pay_policy_date_format}    result_format=${pay_policy_date_format}
    RETURN    ${target_date}

Fill Basic Details In Add Pay Policy On Web
    [Documentation]    This keyword will fill specific details provided for add pay policy
    ...    | =Arguments= | =Description= |
    ...    | pay_policy_data | Pay policy data object from template |
    ...    | eff_date | Effective date for pay policy |
    ...    | end_date | End date for pay policy |
    ...    | =Returns= | =Description= |
    ...    | default_status | Status of pay policy added |
    [Arguments]    ${pay_policy_data}    ${eff_date}=${EMPTY}    ${end_date}=${EMPTY}
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_ADD_ID}
    Wait Until Page Is Loaded
    IF    'policy_id' in ${pay_policy_data}
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_ADD_ID}    ${pay_policy_data}[policy_id]
    END
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_ADD_NAME}
    IF    'policy_name' in ${pay_policy_data}
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_ADD_NAME}    ${pay_policy_data}[policy_name]
    END
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_DESCRIPTION}
    IF    'description' in ${pay_policy_data}
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_DESCRIPTION}    ${pay_policy_data}[description]
    END
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_ADD_VERSION}
    IF    'version_name' in ${pay_policy_data}
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_ADD_VERSION}    ${pay_policy_data}[version_name]
    END
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_ADD_EFFECTIVE_DATE}
    IF    $eff_date != ''
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_ADD_EFFECTIVE_DATE}    ${eff_date}
    END
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_ADD_END_DATE}
    IF    $end_date != ''
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_ADD_END_DATE}    ${end_date}
    END
    ${default_status}    Get Element Text On Webpage    ${PAY_POLICY_PAGE_DEFAULT_STATUS}
    RETURN    ${default_status}

Edit Basic Details In Add Pay Policy On Web
    [Documentation]    This keyword will edit specific details in pay policy details page
    ...    | =Arguments= | =Description= |
    ...    | pay_policy_name | Pay policy name |
    ...    | pay_policy_description | Pay policy description |
    ...    | pay_policy_version | Pay policy version |
    ...    | eff_date | Effective date |
    ...    | end_date | End date |
    [Arguments]    ${pay_policy_name}=${EMPTY}
    ...    ${pay_policy_description}=${EMPTY}
    ...    ${pay_policy_version}=${EMPTY}
    ...    ${eff_date}=${EMPTY}
    ...    ${end_date}=${EMPTY}
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_ADD_NAME}
    IF    $pay_policy_name != ''
        Fill Text    ${PAY_POLICY_PAGE_ADD_NAME}    ${pay_policy_name}
    END
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_DESCRIPTION}
    IF    $pay_policy_description != ''
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_DESCRIPTION}    ${pay_policy_description}
    END
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_ADD_VERSION}
    IF    $pay_policy_version != ''
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_ADD_VERSION}    ${pay_policy_version}
    END
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_ADD_EFFECTIVE_DATE}
    IF    $eff_date != ''
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_ADD_EFFECTIVE_DATE}    ${eff_date}
    END
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_ADD_END_DATE}
    IF    $end_date != ''
        Fill Textbox On Webpage    ${PAY_POLICY_PAGE_ADD_END_DATE}    ${end_date}
    END

Save Pay Policy On Web
    [Documentation]    This keyword clicks on Save button on pay policy details page
    Click Element On Webpage    ${PAY_POLICY_PAGE_SAVE_POLICY_BUTTON}

Verify Pay Policy Page Notification Status On Web
    [Documentation]    This keyword verifies that a success notification is displayed on the pay policy page
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_NOTIFICATION_SUCCESS}

Navigate Back To Pay Policy Page On Web
    [Documentation]    This keyword clicks on the Previous button to navigate back to the pay policy list
    Click Element On Webpage    ${PAY_POLICY_PAGE_PREVIOUS_BUTTON}
    Click Element On Webpage    ${PAY_POLICY_PAGE_VERSION_PREVIOUS_BUTTON}

Verify Pay Policy Visible On Web
    [Documentation]    Verifies that a pay policy with specified attributes is visible in the pay policy list page
    ...    | =Arguments= | =Description= |
    ...    | policy_id | Pay policy id |
    ...    | policy_name | Pay policy name |
    ...    | eff_date | Effective date |
    ...    | end_date | End date |
    ...    | policy_status | Pay policy status|
    [Arguments]    ${policy_id}    ${policy_name}    ${eff_date}    ${policy_status}    ${end_date}=${EMPTY}
    ${id_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_NON_LINK_ATTRIBUTE}    POLICY_ID=${policy_id}
    Wait Until Element Is Visible On Webpage    ${id_locator}
    ${name_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_LINK_ATTRIBUTE}    POLICY_NAME=${policy_name}
    Wait Until Element Is Visible On Webpage    ${name_locator}
    ${eff_date_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_EFF_DATE}    POLICY_ID=${policy_id}
    ${actual_eff_date}    Get Text    ${eff_date_locator}
    Should Be Equal As Strings    ${actual_eff_date}    ${eff_date}
    ${copy_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_COPY_BUTTON}    POLICY_ID=${policy_id}
    Wait Until Element Is Visible On Webpage    ${copy_locator}
    ${status_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_STATUS}    POLICY_ID=${policy_id}
    ${status_text}    Get Text    ${status_locator}
    Should Be Equal As Strings    ${status_text}    ${policy_status}
    IF    $end_date != ''
        ${end_date_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_END_DATE}    POLICY_ID=${policy_id}
        ${actual_end_date}    Get Text    ${end_date_locator}
        Should Be Equal As Strings    ${actual_end_date}    ${end_date}
    END

Copy Pay Policy By Id On Web
    [Documentation]    Creates a copy of the specified pay policy using the provided policy ID
    ...    | =Arguments= | =Description= |
    ...    | policy_id | Pay policy id |
    ...    | new_policy_id | Pay policy id for copied pay policy |
    [Arguments]    ${policy_id}    ${new_policy_id}
    ${copy_policy_btn}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_COPY_BUTTON}    POLICY_ID=${policy_id}
    Click Element On Webpage    ${copy_policy_btn}
    Click Element On Webpage    ${PAY_POLICY_PAGE_COPY_ID}
    Fill Textbox On Webpage    ${PAY_POLICY_PAGE_COPY_ID}    ${new_policy_id}
    Click Element On Webpage    ${PAY_POLICY_PAGE_COPY_OK_BUTTON}

Delete Pay Policy Version By Name On Web
    [Documentation]    This will delete pay policy version of provided id in pay policy page
    ...    | =Arguments= | =Description= |
    ...    | policy_name | Pay policy name |
    ...    | policy_version | Pay policy version |
    [Arguments]    ${policy_name}    ${policy_version}
    ${policy_name_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_LINK_ATTRIBUTE}    POLICY_NAME=${policy_name}
    Click Element On Webpage    ${policy_name_locator}
    ${delete_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_DELETE_BUTTON}    POLICY_VERSION=${policy_version}
    Wait Until Element Is Visible On Webpage    ${delete_locator}
    ${promise}    Promise To    Wait For Alert    action=accept
    Click Element On Webpage    ${delete_locator}
    Wait For    ${promise}
    Verify Pay Policy Page Notification Status On Web
    Click Element On Webpage    ${PAY_POLICY_PAGE_VERSION_PREVIOUS_BUTTON}

Open Pay Policy Details Page On Web
    [Documentation]    This keyword will select pay policy from the list by given pay policy name
    ...    | =Arguments= | =Description= |
    ...    | policy_name | Pay policy name |
    ...    | policy_version | Pay policy version |
    [Arguments]    ${policy_name}    ${policy_version}
    ${pay_policy_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_LINK_ATTRIBUTE}    POLICY_NAME=${policy_name}
    Click Element On Webpage    ${pay_policy_locator}
    ${version_locator}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_VERSION_LINK}    POLICY_VERSION=${policy_version}
    Click Element On Webpage    ${version_locator}
    Wait Until Page Is Loaded

Get Pay Policy Description From Details Page On Web
    [Documentation]    This keyword retrieves the description of the pay policy from the pay rule policy details page
    ...    | =Returns= | =Description= |
    ...    | description | Returns description of pay policy |
    ${description}    Get Element Text On Webpage    ${PAY_POLICY_PAGE_DESCRIPTION}
    RETURN    ${description}

Cleanup Existing Policies In Pay Policy Page On Web
    [Documentation]    This keyword cleans up existing policies in pay policy page
    ...    | =Arguments= | =Description= |
    ...    | pay_policy_data | Pay policy data object from template |
    [Arguments]    ${pay_policy_data}
    VAR    ${policy_id_1}    ${pay_policy_data}[policy_id]
    VAR    ${policy_id_2}    ${pay_policy_data}[policy_id]_copy
    ${policy_locator_1}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_NON_LINK_ATTRIBUTE}    POLICY_ID=${policy_id_1}
    ${is_policy_1_present}    Is Element Present On Webpage    ${policy_locator_1}
    ${policy_locator_2}    Update Locator With Dynamic Values    ${PAY_POLICY_PAGE_NON_LINK_ATTRIBUTE}    POLICY_ID=${policy_id_2}
    ${is_policy_2_present}    Is Element Present On Webpage    ${policy_locator_2}
    IF    ${is_policy_1_present}
        Delete Pay Policy Version By Name On Web    ${pay_policy_data}[policy_name]    ${pay_policy_data}[version_name]
    END
    IF    ${is_policy_2_present}
        Delete Pay Policy Version By Name On Web    Copy of ${pay_policy_data}[policy_name]    ${pay_policy_data}[version_name]
    END
