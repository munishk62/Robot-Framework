*** Settings ***
Documentation       Has all the user interaction implementations of the About us module.

Library             DateTime
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Variables           resources/Mobile/ESS/Locators/About.py


*** Keywords ***
Navigate Mobile ESS To About Us Module
    [Documentation]    Navigates mobile Nextgen ESS to about us module.
    Navigate Mobile ESS To Home Page Side Menu
    ${about_semantic_path}    Get Localised Locator Contains    ${about_menu_title_locator}
    Wait Until Page Contains Element    ${about_semantic_path}
    Click Element    ${about_semantic_path}
    ${about_us_title_semantic_locator}    Get Localised Locator Contains    ${about_us_title_locator}
    Wait Until Element Is Visible    ${about_us_title_semantic_locator}

Verify Mobile ESS App Version Details Information
    [Documentation]    Used for app version details is visible in Nextgen ESS app.
    ${localised_semantic_app_version_label}    Get Localised Locator Contains    ${about_app_version_label_locator}
    Swipe Until Visible    ${localised_semantic_app_version_label}
    Wait Until Element Is Visible    ${localised_semantic_app_version_label}
    ${localised_semantic_build_version_label}    Get Localised Locator Contains    ${about_build_version_locator}
    Swipe Until Visible    ${localised_semantic_build_version_label}
    Wait Until Element Is Visible    ${localised_semantic_build_version_label}
    ${localised_semantic_build_date_label}    Get Localised Locator Contains    ${about_build_date_locator}
    Swipe Until Visible    ${localised_semantic_build_date_label}
    Wait Until Element Is Visible    ${localised_semantic_build_date_label}
    ${localised_semantic_branch_label}    Get Localised Locator Contains    ${about_branch_locator}
    Swipe Until Visible    ${localised_semantic_branch_label}
    Wait Until Element Is Visible    ${localised_semantic_branch_label}
    ${localised_semantic_copyright_label}    Get Localised Locator Contains    ${about_copyright_locator}
    Swipe Until Visible    ${localised_semantic_copyright_label}
    Wait Until Element Is Visible    ${localised_semantic_copyright_label}

Navigate Mobile ESS To Logs
    [Documentation]    Navigates mobile Nextgen ESS to logs.
    ${localised_semantic_app_version_label}    Get Localised Locator Contains    ${about_app_version_label_locator}
    Wait Until Element Is Visible    ${localised_semantic_app_version_label}
    Run Keyword And Ignore Error    Tap Multiple Time On Element    ${localised_semantic_app_version_label}
    ${localised_semantic_menu_title_logs}    Get Localised Locator Contains    ${menu_title_logs_locator}
    Wait Until Element Is Visible    ${localised_semantic_menu_title_logs}

Verify Mobile ESS App Logs Details
    [Documentation]    Used for logs details is visible in Nextgen ESS app.
    ${localised_semantic_j_session_name_label}    Get Localised Locator Contains    ${about_logs_j_session_name_locator}
    Swipe Until Visible    ${localised_semantic_j_session_name_label}
    Wait Until Element Is Visible    ${localised_semantic_j_session_name_label}
    ${localised_semantic_logs_detail}    Get Localised Locator Contains    ${about_logs_detail_locator}
    Swipe Until Visible    ${localised_semantic_logs_detail}
    Wait Until Element Is Visible    ${localised_semantic_logs_detail}

Navigate Mobile ESS To Licenses Page
    [Documentation]    Navigates mobile Nextgen ESS to Licenses Page.
    ${localised_semantic_licenses_button}    Get Localised Locator Contains    ${about_licenses_locator}
    Click Element    ${localised_semantic_licenses_button}
    ${localised_semantic_licenses_Title}    Get Localised Locator Contains    ${licenses_title_locator}
    Swipe Until Visible    ${localised_semantic_licenses_Title}
    Wait Until Element Is Visible    ${localised_semantic_licenses_Title}

Navigate Mobile ESS To Report An Issue Page
    [Documentation]    Navigates mobile ess to the Report An Issue Page. (Flutter-only)
    ${localised_semantic_report_button}    Get Localised Locator Contains    ${about_report_locator}
    Click Element    ${localised_semantic_report_button}

Verify Mobile ESS App Report An Issue Page
    [Documentation]    Verify Mobile ESS report an issue page. (Flutter-only)
    Hide Keyboard
    Swipe Until Visible    ${workcloud_ess_log_attach_locator}
    Wait Until Element Is Visible    ${workcloud_ess_log_attach_locator}
    Swipe Until Visible    ${email_id_locator}    "up"    4
    Wait Until Element Is Visible    ${email_id_locator}
    Wait Until Element Is Visible    ${send_issue_mail_locator}

Verify Report An Issue Not Enabled On Mobile ESS
    [Documentation]    Used for verify report an issue not Enabled in Nextgen ESS app.
    Run Keyword And Expect Error    *    Navigate Mobile ESS To Report An Issue Page
