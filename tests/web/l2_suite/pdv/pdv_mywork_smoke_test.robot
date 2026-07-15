*** Settings ***
Documentation       Test case for verifying each page loads successfully on Mywork env.

Resource            resources/web/authentication/login.resource
Resource            resources/web/pdv/mywork_menu_navigation.resource
Library             pabot.PabotLib

Suite Setup         Run Only Once    Check If Environment Is MyWork Environment
Test Teardown       Close Browser

Test Tags           dev:ravi    action:read    bat_phase2    pdv_mywork


*** Variables ***
${USER_KEY_SM_USER}         SM1_STORE1
${USER_KEY_SYSADMIN}        SYSADMIN
${USER_KEY_ESS_USER}        ESS2_STORE1
${PDV_SCREENSHOT_BASE}      ${EXECDIR}${/}pdv_screenshots_mywork


*** Test Cases ***
BATTC00247: Verify SM user is able to navigate to all menus, submenus and side menus successfully in web for RWS (Scheduling) with PDV pre/post comparison
    [Documentation]    Test case for verifying each page loads successfully on Mywork env.
    [Tags]    pdv_mywork_sm_rws    config:rws    battc00247

    VAR    ${module_name}    rws
    Login And Launch WFM Web App    user_key=${USER_KEY_SM_USER}
    VAR    ${pdv_screenshot_dir}    ${PDV_SCREENSHOT_BASE}${/}${module_name}${/}${USER_KEY_SM_USER}

    Navigate To Specific Page On Web    ${module_name}
    Iterate Over Mywork Pages And Capture Screenshots    ${module_name}    ${pdv_screenshot_dir}

BATTC00248: Verify SM user is able to navigate to all menus, submenus and side menus successfully in web for TA with PDV pre/post comparison
    [Documentation]    Test case for verifying each page loads successfully on Mywork env.
    [Tags]    pdv_mywork_sm_rta    config:rta    battc00248

    VAR    ${module_name}    rta
    Login And Launch WFM Web App    user_key=${USER_KEY_SM_USER}
    VAR    ${pdv_screenshot_dir}    ${PDV_SCREENSHOT_BASE}${/}${module_name}${/}${USER_KEY_SM_USER}

    Navigate To Specific Page On Web    ${module_name}
    Iterate Over Mywork Pages And Capture Screenshots    ${module_name}    ${pdv_screenshot_dir}

BATTC00245: Verify CORP user is able to navigate to all menus, submenus and side menus successfully in web for RWS (Scheduling) with PDV pre/post comparison
    [Documentation]    Test case for verifying each page loads successfully on Mywork env.
    [Tags]    pdv_mywork_sysadmin_rws    config:rws    battc00245

    VAR    ${module_name}    rws
    Login And Launch WFM Web App    user_key=${USER_KEY_SYSADMIN}
    VAR    ${pdv_screenshot_dir}    ${PDV_SCREENSHOT_BASE}${/}${module_name}${/}${USER_KEY_SYSADMIN}

    Navigate To Specific Page On Web    ${module_name}
    Iterate Over Mywork Pages And Capture Screenshots    ${module_name}    ${pdv_screenshot_dir}

BATTC00246: Verify CORP user is able to navigate to all menus, submenus and side menus successfully in web for TA with PDV pre/post comparison
    [Documentation]    Test case for verifying each page loads successfully on Mywork env.
    [Tags]    pdv_mywork_sysadmin_rta    config:rta    battc00246

    VAR    ${module_name}    rta
    Login And Launch WFM Web App    user_key=${USER_KEY_SYSADMIN}
    VAR    ${pdv_screenshot_dir}    ${PDV_SCREENSHOT_BASE}${/}${module_name}${/}${USER_KEY_SYSADMIN}

    Navigate To Specific Page On Web    ${module_name}
    Iterate Over Mywork Pages And Capture Screenshots    ${module_name}    ${pdv_screenshot_dir}

BATTC00249: Verify ESS user is able to navigate to all menus, submenus and side menus successfully in web with PDV pre/post comparison
    [Documentation]    Test case for verifying each page loads successfully on Mywork env.
    [Tags]    pdv_mywork_ess    config:ess    battc00249    om_hr

    VAR    ${module_name}    ess
    Login And Launch WFM Web App    user_key=${USER_KEY_ESS_USER}
    VAR    ${pdv_screenshot_dir}    ${PDV_SCREENSHOT_BASE}${/}${module_name}${/}${USER_KEY_ESS_USER}

    Navigate To Specific Page On Web    ${module_name}
    Iterate Over Mywork Pages And Capture Screenshots    ${module_name}    ${pdv_screenshot_dir}


*** Keywords ***
Check If Environment Is MyWork Environment
    [Documentation]    Checks if the current environment is a MyWork environment

    ${is_mywork_integrated}    Get Config Value    MYWORK

    IF    '${is_mywork_integrated}' == 'true'
        Log    Environment is identified as MyWork. Proceeding with test execution.
        No Operation
    ELSE
        Log    Environment is identified as Non-MyWork. Skipping test execution.
        Skip    This test is only applicable for MyWork environments.
    END
