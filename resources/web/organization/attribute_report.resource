*** Settings ***
Documentation       This resource file contains keywords related to the Organization Attribute Report page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RWS Organization Attribute Report Page On Web
    [Documentation]    Navigate To RWS -> Organization -> Attribute Report Page On Web
    Navigate To Specific Page On Web    rws    organization    attribute_report
