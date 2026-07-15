*** Settings ***
Documentation       Device page related keyword implementation

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource


*** Keywords ***
Navigate To RTA Devices Device Page On Web
    [Documentation]    Navigate To RTA -> Devices -> Device Page
    ...    and verifies device heading at the top of the page
    Navigate To Specific Page On Web    rta    devices    device
