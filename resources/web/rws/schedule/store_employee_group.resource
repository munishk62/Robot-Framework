*** Settings ***
Documentation       This resource file contains keywords related to the RWS > Schedule > Store Employee Group page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/store_employee_group_page.py


*** Keywords ***
Navigate To RWS Store Employee Group Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Store Employee Group Page On Web
    Navigate To Specific Page On Web    rws    schedule    store_employee_group

Click On Employee Group Types Link In Store Employee Group Page On Web
    [Documentation]    Click On Employee Group Types Link In Store Employee Group Page On Web
    Click Element On Webpage    ${STORE_EMP_GROUP_EMPLOYEE_GROUP_TYPES_LINK}
    ...    error_message=Failed to click on Employee Group Types link in Store Employee Group page on web
    Wait Until Element Is Visible On Webpage    ${STORE_EMP_GROUP_EMPLOYEE_GROUP_TYPES_SAVE_BTN}
    ...    error_message=Employee Group Types Save button is not visible after clicking on Employee Group Types link
    Capture Screenshot On Webpage

Click On Employee Groups Link In Store Employee Group Page On Web
    [Documentation]    Click On Employee Groups Link In Store Employee Group Page On Web
    Click Element On Webpage    ${STORE_EMP_GROUP_EMPLOYEE_GROUPS_LINK}
    ...    error_message=Failed to click on Employee Groups link in Store Employee Group page on web
    Wait Until Element Is Visible On Webpage    ${STORE_EMP_GROUP_EMPLOYEE_GROUPS_SAVE_BTN}
    ...    error_message=Employee Groups Save button is not visible after clicking on Employee Groups link
    Capture Screenshot On Webpage

Click On Store Employee Groups Link In Store Employee Group Page On Web
    [Documentation]    Click On Store Employee Groups Link In Store Employee Group Page On Web
    Click Element On Webpage    ${STORE_EMP_GROUP_STORE_EMPLOYEE_GROUPS_LINK}
    ...    error_message=Failed to click on Store Employee Groups link in Store Employee Group page on web
    Wait Until Element Is Visible On Webpage    ${STORE_EMP_GROUP_STORE_EMPLOYEE_GROUPS_SAVE_BTN}
    ...    error_message=Store Employee Groups Save button is not visible after clicking on Store Employee Groups link
    Capture Screenshot On Webpage
