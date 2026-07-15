*** Settings ***
Documentation       This resource file contains keywords related to the RWS > Schedule > Net Rules page on Web.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/net_rules_page.py


*** Keywords ***
Navigate To RWS Net Rules Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Net Rules Page On Web
    Navigate To Specific Page On Web    rws    schedule    net_rules

Click On Add Net Rule Button In Net Rules Page On Web
    [Documentation]    Click on Add Net Rule button in Net Rules page on Web
    Click Element On Webpage    ${NET_RULES_ADD_NET_RULE_BTN}
    ...    error_message=Failed to click on Add Net Rule button
    Wait Until Element Is Visible On Webpage    ${NET_RULES_ADD_NET_RULE_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Net Rule Save button was not visible after clicking Add Net Rule button
    Capture Screenshot On Webpage
