*** Settings ***
Documentation       This resource file contains keywords related to the RWS > Schedule > Acknowledgements page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/acknowledgements_page.py


*** Keywords ***
Navigate To RWS Acknowledgements Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Acknowledgements Page On Web
    Navigate To Specific Page On Web    rws    schedule    acknowledgements

Click On Add Acknowledgement Button In Acknowledgements Page On Web
    [Documentation]    Click on Add Acknowledgement button in Acknowledgements page on Web
    Click Element On Webpage    ${ACKNOWLEDGEMENTS_ADD_ACKNOWLEDGEMENT_BTN}
    ...    error_message=Failed to click on Add Acknowledgement button
    Wait Until Element Is Visible On Webpage    ${ACKNOWLEDGEMENTS_ADD_ACKNOWLEDGEMENT_SAVE_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Acknowledgement Save button was not visible after clicking Add Acknowledgement button
    Capture Screenshot On Webpage
