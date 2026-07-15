*** Settings ***
Documentation       Resource file for HR Pay Policy Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/hr/pay_policy_page.py


*** Keywords ***
Navigate To RTA HR Pay Policy Page On Web
    [Documentation]    Navigates to the RTA -> HR -> Pay Policy page.
    Navigate To Specific Page On Web    rta    hr    pay_policy

Click On Add Pay Policy Button On Pay Policy Page On Web
    [Documentation]    Clicks on Add Pay Policy button on Pay Policy page
    Click Element On Webpage    ${PAY_POLICY_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Pay Policy button on Pay Policy page."
    Wait Until Element Is Visible On Webpage    ${PAY_POLICY_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Pay Policy form did not open after clicking Add Pay Policy button."
    Capture Screenshot On Webpage

Click On All Tabs On Add Pay Policy Form On Web
    [Documentation]    Clicks on all tabs on Add Pay Policy form to ensure they load correctly.
    ...    For each tab, checks visibility before clicking. If a tab is visible, it also clicks
    ...    all expand icons within that tab (only if visible). If a tab is not visible, execution
    ...    continues to the next tab.
    ${tabs}    Get Element Count On Web Page    ${PAY_POLICY_PAGE_ADD_POLICY_TABS}

    FOR    ${tab}    IN RANGE    1    ${tabs+1}
        ${is_tab_visible}    Is Element Visible On Webpage    (${PAY_POLICY_PAGE_ADD_POLICY_TABS})[${tab}]
        IF    ${is_tab_visible}
            Click Element On Webpage    (${PAY_POLICY_PAGE_ADD_POLICY_TABS})[${tab}]
            Wait Until Page Is Loaded
            ${expand_icons}    Get Element Count On Web Page    ${PAY_POLICY_PAGE_ADD_POLICY_EXPAND_ICON}
            FOR    ${icon}    IN RANGE    1    ${expand_icons+1}
                ${is_icon_visible}    Is Element Visible On Webpage    (${PAY_POLICY_PAGE_ADD_POLICY_EXPAND_ICON})[${icon}]
                IF    ${is_icon_visible}
                    Click Element On Webpage    (${PAY_POLICY_PAGE_ADD_POLICY_EXPAND_ICON})[${icon}]
                    Wait Until Page Is Loaded
                END
            END
            Capture Screenshot On Webpage
        END
    END
