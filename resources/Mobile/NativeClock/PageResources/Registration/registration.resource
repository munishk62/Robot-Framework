*** Settings ***
Documentation       This resource contains keyword required for login and registration related features.

Library             Process
Resource            resources/Mobile/Common/Mobile_Device_Helper.resource
Variables           resources/Mobile/NativeClock/PageResources/Locators/registration.py


*** Keywords ***
Select Store For Registration For Native Clock
    [Documentation]    This keyword will select the store for registration in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${store_id}: Store unique key from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will select the store for registration.
    ...    Example:
    ...    -    Select Store For Registration    ESS-STORE1
    [Arguments]    ${store_id}
    Wait Until Element Is Visible    ${edit_store}    20s
    Click Element    ${edit_store}
    ${select_store_locator}    Get Message With Arguments    ${select_store}    ${store_id}
    Swipe Until Visible    ${select_store_locator}
    Click Element    ${select_store_locator}

Enter Device ID For Registration For Native Clock
    [Documentation]    This keyword will enter the device ID for registration in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${device_id}: Device ID from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will enter the device ID for registration.
    ...    Example:
    ...    -    Select Store For Registration    Tab 20
    [Arguments]    ${device_id}=${None}
    IF    $device_id is None
        ${device_id}    Generate Dynamic Device ID
    END
    Wait Until Element Is Visible    ${edit_device_id}
    Input Text    ${edit_device_id}    ${device_id}
    Hide Keyboard

Select Device Location For Registration For Native Clock
    [Documentation]    This keyword will select the device location for registration in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${device_location}: Device location from variation csv sheets.
    ...    Behavior:
    ...    -    Keyword will select the device location for registration.
    ...    Example:
    ...    -    Select Device Location For Registration    Front Desk
    [Arguments]    ${device_location}
    Wait Until Element Is Visible    ${edit_device_location}
    Click Element    ${edit_device_location}
    ${select_device_location_locator}    Get Message With Arguments    ${select_device_location}    ${device_location}
    Swipe Until Visible    ${select_device_location_locator}
    Click Element    ${select_device_location_locator}

Select Language For Registration For Native Clock
    [Documentation]    This keyword will select the language for registration in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${language}: Language from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will select the language for registration.
    ...    Example:
    ...    -    Select Language For Registration    English
    [Arguments]    ${language}
    Swipe Until Visible    ${edit_language}
    Click Element    ${edit_language}
    ${select_device_location_locator}    Get Message With Arguments    ${select_language}    ${language}
    Swipe Until Visible    ${select_device_location_locator}
    Click Element    ${select_device_location_locator}

Enable Location For Registration For Native Clock
    [Documentation]    This keyword will enable the location for registration in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${enable_location}: Enable location from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will enable the location for registration.
    ...    Example:
    ...    -    Enable Location For Registration    True
    [Arguments]    ${enable_location}
    IF    ${enable_location}
        Swipe Until Visible    ${enable_location_yes}
        Click Element    ${enable_location_yes}
    ELSE
        Swipe Until Visible    ${enable_location_no}
        Click Element    ${enable_location_no}
    END

Submit Registration For Native Clock
    [Documentation]    This keyword will submit the registration in the Mobile Native Clock App.
    ...    Arguments:
    ...    - ${enable_location}: Enable location from variation csv sheets.
    ...    Behavior:
    ...    - Keyword will submit the registration.
    ...    Example:
    ...    -    Submit Registration For Native Clock    True
    [Arguments]    ${enable_location}
    Click Element    ${proceed_registration}
    IF    not ${enable_location}
        Wait Until Element Is Visible    ${accept_terms_condition}
        Click Element    ${accept_terms_condition}
        Wait Until Element Is Visible    ${continue_terms}
        Click Element    ${continue_terms}
    END

Finish Registration For Native Clock
    [Documentation]    This keyword will submit the registration in the Mobile Native Clock App.
    ...    Behavior:
    ...    - Keyword will submit the registration.
    ...    Example:
    ...    -    Submit Registration For Native Clock
    ${CUSTOM_TAB_LOGIN}    Get Config Value    CUSTOM_TAB_LOGIN
    Wait Until Element Is Visible    ${finish_registration}
    Click Element    ${finish_registration}
    Sleep    3s
    IF    '${MOBILE_PLATFORM}' != 'android'
        Run Keyword And Ignore Error    Click Alert Button    Continue
    END
    IF    ${CUSTOM_TAB_LOGIN}
        Wait Until Element Is Visible    ${close_registration_logout}
        Click Element    ${close_registration_logout}
    END

Generate Dynamic Device ID
    [Documentation]    This keyword will generate the dynamic device id for registration in the Mobile Native Clock App.
    ...    Behavior:
    ...    - Keyword will generate the dynamic device id for registration.
    ...    Example:
    ...    -    Generate Dynamic Device ID
    ${today_time_stamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    IF    '${MOBILE_PLATFORM}' == 'android'
        VAR    ${id}    DVC_TABA_${today_time_stamp}
    ELSE
        VAR    ${id}    DVC_TABI_${today_time_stamp}
    END
    RETURN    ${id}

Register With Supervisor On Tablet Clock
    [Documentation]    This keyword will perform the registration in the Mobile Native Clock App for the user by using other keywords in this resource.
    ...    | =Arguments= | =Description= |
    ...    | ${user_key} | User unique key from variation csv sheets. |
    ...    | ${clock_registration_template_data} | Clock registration template data from base_template.
    [Arguments]    ${user_key}    ${clock_registration_template_data}
    ${user}    Get User    ${user_key}
    VAR    ${store_name}    ${user}[unitID]     -     ${user}[unitName]
    Select Store For Registration For Native Clock    ${store_name}
    Enter Device ID For Registration For Native Clock
    Select Device Location For Registration For Native Clock    ${clock_registration_template_data}[device_location]
    Enable Location For Registration For Native Clock    ${clock_registration_template_data}[enable_location_services]
    Submit Registration For Native Clock    ${clock_registration_template_data}[enable_location_services]
    Finish Registration For Native Clock
