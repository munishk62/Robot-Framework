*** Settings ***
Documentation       This test case is to verify user is able to add/edit/copy/delete pay policies

Resource            resources/web/authentication/login.resource
Resource            resources/web/rta/operations/pay_policy.resource

Suite Teardown      Close Browser
Test Teardown       Run Keywords
...                     Navigate To RTA HR Pay Policy Page On Web    AND
...                     Run Keyword And Continue On Failure    Run Keyword If    ${POLICY_ADDED}    Delete Pay Policy Version By Name On Web    ${pay_policy_data}[policy_name]    ${pay_policy_data}[version_name]    AND
...                     Run Keyword And Continue On Failure    Run Keyword If    ${COPY_POLICY_ADDED}    Delete Pay Policy Version By Name On Web    ${copied_policy_name}    ${pay_policy_data}[version_name]    AND
...                     Close Browser

Test Tags           action:write    battc00054    dev:bushra    config:rta    bat_phase1    module:timekeeping


*** Variables ***
${POLICY_ADDED}    ${False}
${COPY_POLICY_ADDED}    ${False}


*** Test Cases ***
BATTC00054: Verify user is able to add/edit/copy/delete pay policies
    [Documentation]    This test case is to verify user is able to add/edit/copy/delete pay policies
    ${pay_policy_data}    Get Pay Policy Data
    VAR    ${new_id}    ${pay_policy_data}[policy_id]_copy
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RTA HR Pay Policy Page On Web
    ${add_btn_present}    Verify Add Pay Policy Button Present On Web
    IF    not ${add_btn_present}
        Skip    Add pay policy button not present, skipping the Test Case
    END
    Cleanup Existing Policies In Pay Policy Page On Web    ${pay_policy_data}
    Select Add New Pay Policy On Web
    # Get range of date for policy to be active
    ${effective_date}
    ...    Get Range Of Date For Pay Policy To Be Active From Current Date On Web    2 days
    ${default_status}    Fill Basic Details In Add Pay Policy On Web    ${pay_policy_data}
    ...    eff_date=${effective_date}
    Save Pay Policy On Web
    Verify Pay Policy Page Notification Status On Web
    Navigate Back To Pay Policy Page On Web
    Verify Pay Policy Visible On Web    ${pay_policy_data}[policy_id]    ${pay_policy_data}[policy_name]
    ...    eff_date=${effective_date}    policy_status=${default_status}
    Open Pay Policy Details Page On Web    ${pay_policy_data}[policy_name]    ${pay_policy_data}[version_name]
    VAR    ${edited_description}    ${pay_policy_data}[description]_edited
    Edit Basic Details In Add Pay Policy On Web    pay_policy_description=${edited_description}
    Save Pay Policy On Web
    Verify Pay Policy Page Notification Status On Web
    VAR    ${POLICY_ADDED}    ${True}    scope=SUITE
    Navigate Back To Pay Policy Page On Web
    Open Pay Policy Details Page On Web    ${pay_policy_data}[policy_name]    ${pay_policy_data}[version_name]
    ${pay_policy_desc}    Get Pay Policy Description From Details Page On Web
    Should Be Equal As Strings    ${pay_policy_desc}    ${edited_description}
    Navigate Back To Pay Policy Page On Web
    Verify Pay Policy Visible On Web    ${pay_policy_data}[policy_id]    ${pay_policy_data}[policy_name]
    ...    eff_date=${effective_date}    policy_status=${default_status}
    Copy Pay Policy By Id On Web    ${pay_policy_data}[policy_id]    ${new_id}
    Verify Pay Policy Page Notification Status On Web
    VAR    ${COPY_POLICY_ADDED}    ${True}    scope=SUITE
    VAR    ${copied_policy_name}    Copy of ${pay_policy_data}[policy_name]
    Verify Pay Policy Visible On Web    ${new_id}    ${copied_policy_name}
    ...    eff_date=${effective_date}    policy_status=${default_status}
