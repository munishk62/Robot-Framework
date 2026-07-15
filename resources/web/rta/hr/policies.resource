*** Settings ***
Documentation       Resource file for HR Policies Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/policies_page.py


*** Keywords ***
Navigate To RTA HR Policies Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Policies page.
    Navigate To Specific Page On Web    rta    hr    policies

Click On Add Policies Button On Policies Page On Web
    [Documentation]    Clicks on Add Policies button on Policies page
    Click Element On Webpage    ${POLICIES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Policies button on Policies page."
    Wait Until Element Is Visible On Webpage    ${POLICIES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Policies form did not open after clicking Add Policies button."
    Capture Screenshot On Webpage

Click On All Tabs On Add Policy Form On Web
    [Documentation]    Clicks on all tabs on Add Policy form to ensure they load correctly.
    ...    For each tab, checks visibility before clicking. If a tab is visible, it also clicks
    ...    all expand icons within that tab (only if visible). If a tab is not visible, execution
    ...    continues to the next tab.
    ${tabs}    Get Element Count On Web Page    ${POLICIES_PAGE_ADD_POLICY_TABS}

    FOR    ${tab}    IN RANGE    1    ${tabs+1}
        ${is_tab_visible}    Is Element Visible On Webpage    (${POLICIES_PAGE_ADD_POLICY_TABS})[${tab}]
        IF    ${is_tab_visible}
            Click Element On Webpage    (${POLICIES_PAGE_ADD_POLICY_TABS})[${tab}]
            Wait Until Page Is Loaded
            ${expand_icons}    Get Element Count On Web Page    ${POLICIES_PAGE_ADD_POLICY_EXPAND_ICONS}
            FOR    ${icon}    IN RANGE    1    ${expand_icons+1}
                ${is_icon_visible}    Is Element Visible On Webpage    (${POLICIES_PAGE_ADD_POLICY_EXPAND_ICONS})[${icon}]
                IF    ${is_icon_visible}
                    Click Element On Webpage    (${POLICIES_PAGE_ADD_POLICY_EXPAND_ICONS})[${icon}]
                    Wait Until Page Is Loaded
                END
            END
            Capture Screenshot On Webpage
        END
    END
