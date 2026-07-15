*** Settings ***
Documentation       This resource file contains keywords related to the PSA > State Machine Configuration page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/psa/state_machine_configuration/state_machine_configuration_page.py


*** Keywords ***
Navigate To PSA State Machine Configuration Page On Web
    [Documentation]    Navigate To PSA -> State Machine Configuration Page On Web
    Navigate To Specific Page On Web    psa    state_machine_configuration    state_machine_configuration

Click On System Configuration Tab On State Machine Configuration Page On Web
    [Documentation]    Click on the System Configuration tab on the State Machine Configuration page.
    Click Element On Webpage    ${SMC_PAGE_SYSTEM_CONFIGURATION_TAB}
    ...    error_message=Failed to click on System Configuration tab
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${SMC_PAGE_SYSTEM_CONFIGURATION_SECTION}    timeout=${LONG_TIMEOUT}
    ...    error_message=System Configuration section was not visible after clicking System Configuration tab
    Capture Screenshot On Webpage

Click On Unit Configuration Tab On State Machine Configuration Page On Web
    [Documentation]    Click on the Unit Configuration tab on the State Machine Configuration page.
    Click Element On Webpage    ${SMC_PAGE_UNIT_CONFIGURATION_TAB}
    ...    error_message=Failed to click on Unit Configuration tab
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${SMC_PAGE_UNIT_CONFIGURATION_SECTION}    timeout=${LONG_TIMEOUT}
    ...    error_message=Unit Configuration section was not visible after clicking Unit Configuration tab
    Capture Screenshot On Webpage

Click On Configure State Machine Tab On State Machine Configuration Page On Web
    [Documentation]    Click on the Configure State Machine tab on the State Machine Configuration page.
    Click Element On Webpage    ${SMC_PAGE_CONFIGURE_STATE_MACHINE_TAB}
    ...    error_message=Failed to click on Configure State Machine tab
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${SMC_PAGE_CONFIGURE_STATE_MACHINE_SECTION}    timeout=${LONG_TIMEOUT}
    ...    error_message=Configure State Machine section was not visible after clicking Configure State Machine tab
    Capture Screenshot On Webpage
