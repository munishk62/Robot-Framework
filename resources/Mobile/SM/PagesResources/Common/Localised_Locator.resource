*** Settings ***
Documentation       This resource file contains keywords for locators which deal with localised locators.

Library             Collections
Library             utils/common_utility/utility.py


*** Variables ***
${MOBILE_PLATFORM}      ${MOBILE_PLATFORM}


*** Keywords ***
Get Localised Locator Exact For SM
    [Documentation]    Gets the localise locator based on semantic label of selected language.
    ...    Arguments:
    ...    - ${semantic_label}: key for semantic label from locale properties file.
    ...    - ${varargs}: additional arguments for semantic label to replace {0}.
    ...    Example:
    ...    - Get Localised Locator Exact    common.button.ok
    ...    - Get Localised Locator Exact    label.quick_filter.request    Jan    Feb
    [Arguments]    ${semantic_label}    @{varargs}
    ${localised_semantic}    Get Localised Message From Key For SM    ${semantic_label}
    ${final_message}    Get Message With Arguments For SM    ${localised_semantic}    @{varargs}
    ${result}    Get Locator Exact For SM    ${final_message}
    RETURN    ${result}

Get Localised Locator Contains For SM
    [Documentation]    Gets the localise locator based on semantic label of selected language.
    ...    Arguments:
    ...    - ${semantic_label}: key for semantic label from locale properties file.
    ...    - ${varargs}: additional arguments for semantic label to replace {0}.
    ...    Example:
    ...    - Get Localised Locator Contains    common.button.ok
    ...    - Get Localised Locator Contains    label.quick_filter.request    Jan    Feb
    [Arguments]    ${semantic_label}    @{varargs}
    ${localised_semantic}    Get Localised Message From Key For SM    ${semantic_label}
    ${final_message}    Get Message With Arguments For SM    ${localised_semantic}    @{varargs}
    ${result}    Get Locator Contains For SM    ${final_message}
    RETURN    ${result}

Get Localised Message From Key For SM
    [Documentation]    Gets the localised message based on semantic label of selected language.
    ...    Arguments:
    ...    - ${semantic_key}: key for semantic label from locale properties file.
    ...    Example:
    ...    - Get Localised Message    common.button.ok
    [Arguments]    ${semantic_Key}
    ${localised_semantic}    Get From Dictionary    ${TRANSLATED_SM_MAP}    ${semantic_Key}
    RETURN    ${localised_semantic}

Get Message With Arguments For SM
    [Documentation]    Gets the message based on passed arguments.
    ...    Arguments:
    ...    - ${message}: localised message from locale csv file or direct message containing {0} {1} ...{n} i18n format.
    ...    - ${varargs}: additional arguments for semantic label to replace {0}.
    ...    Example:
    ...    - Get Message    I have {0} apples and one {1}    5    orange
    ...    Returns:
    ...    - I have 5 apples and one orange
    [Arguments]    ${message}    @{varargs}
    ${is_varargs_empty}    Evaluate    len(${varargs}) == 0
    IF    ${is_varargs_empty}
        ${result}    Evaluate    '${message}'
    ELSE
        ${result_temp}    Evaluate    '${message}'.format(*${varargs})
        ${result}    Evaluate    '${result_temp}'.replace('""', '').strip()
    END
    RETURN    ${result}

Get Locator Exact For SM
    [Documentation]    Gets the exact locator based on platform
    ...    Arguments:
    ...    - ${semanticLabel}: semantic label for locating the object in screen.
    ...    Example:
    ...    - Get Locator    OK
    [Arguments]    ${semantic_label}
    ${result}    Get Locator Value    ${semantic_label}    ${MOBILE_PLATFORM}    EXACT
    RETURN    ${result}

Get Locator Contains For SM
    [Documentation]    Gets the exact locator based on platform
    ...    Arguments:
    ...    - ${semanticLabel}: semantic label for locating the object in screen.
    ...    Example:
    ...    - Get Locator    OK
    [Arguments]    ${semantic_label}
    ${result}    Get Locator Value    ${semantic_label}    ${MOBILE_PLATFORM}    CONTAINS
    RETURN    ${result}

Get Value Locator Contains For SM
    [Documentation]    Returns a CONTAINS locator that also matches an iOS @value.
    ...    The base locator (Android @text/@content-desc + iOS @name/@label) is kept as-is,
    ...    so Android behaviour is unchanged. On iOS, form/detail field values (e.g. a date
    ...    "08/19/2026" or status "Declined") are exposed via @value while the caption sits
    ...    in @name/@label, so an iOS @value branch is appended with `|`.
    ...    Arguments:
    ...    - ${text}: the visible field value to locate.
    [Arguments]    ${text}
    ${base_locator}    Get Locator Contains For SM    ${text}
    ${ios_value_locator}    Get Message With Arguments For SM
    ...    //*[contains(@value,"{0}") and not(@visible="false")]    ${text}
    RETURN    ${base_locator} | ${ios_value_locator}

Get Localised Message With Arguments From Key For SM
    [Documentation]    Gets the message based on passed arguments.
    ...    Arguments:
    ...    - ${key}: number key for strings in locale csv file.
    ...    - ${varargs}: additional arguments for semantic label to replace {0}.
    ...    Example:
    ...    - Get Message With Arguments For SM    I have {0} apples and one {1}    5    orange
    ...    Returns:
    ...    - I have 5 apples and one orange
    [Arguments]    ${key}    @{varargs}
    ${localised_message}    Get Localised Message From Key For SM    ${key}
    ${result}    Get Message With Arguments For SM    ${localised_message}    @{varargs}
    RETURN    ${result}
