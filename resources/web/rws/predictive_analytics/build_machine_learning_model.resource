*** Settings ***
Documentation       This resource file contains keywords related to the Predictive Analytics > Build Machine Learning Model page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/predictive_analytics/build_machine_learning_model_page.py


*** Keywords ***
Navigate To RWS Build Machine Learning Model Page On Web
    [Documentation]    Navigate To RWS -> Predictive Analytics -> Build Machine Learning Model Page On Web
    Navigate To Specific Page On Web    rws    predictive_analytics    build_machine_learning_model

Click On Add Machine Learning Model Button On Build Machine Learning Model Page On Web
    [Documentation]    Click on the Add Machine Learning Model button on the Build Machine Learning Model page.
    Click Element On Webpage    ${BMLM_PAGE_ADD_MACHINE_LEARNING_MODEL_BTN}
    ...    error_message=Failed to click on Add Machine Learning Model button
    Wait Until Page Is Loaded
    Wait Until Element Is Visible On Webpage    ${BMLM_PAGE_ADD_MACHINE_LEARNING_MODEL_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Machine Learning Model Previous button was not visible after clicking Add Machine Learning Model button
    Capture Screenshot On Webpage
