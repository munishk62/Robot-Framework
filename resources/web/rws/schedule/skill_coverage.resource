*** Settings ***
Documentation       This resource file contains keywords related to the RWS > Schedule > Skill Coverage page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/schedule/skill_coverage_page.py


*** Keywords ***
Navigate To RWS Skill Coverage Page On Web
    [Documentation]    Navigate To RWS -> Schedule -> Skill Coverage Page On Web
    Navigate To Specific Page On Web    rws    schedule    skill_coverage

Click On Add Skill Coverage Button In Skill Coverage Page On Web
    [Documentation]    Click on Add Skill Coverage button in Skill Coverage page on Web
    Click Element On Webpage    ${SKILL_COVERAGE_ADD_SKILL_COVERAGE_BTN}
    ...    error_message=Failed to click on Add Skill Coverage button
    Wait Until Element Is Visible On Webpage    ${SKILL_COVERAGE_ADD_SKILL_COVERAGE_PREVIOUS_BTN}    timeout=${LONG_TIMEOUT}
    ...    error_message=Add Skill Coverage Previous button was not visible after clicking Add Skill Coverage button
    Capture Screenshot On Webpage
