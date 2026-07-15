*** Settings ***
Documentation       This resource file contains keywords related to the Upcoming > Upcoming page.

Resource            resources/web/common/common.resource
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rws/upcoming/upcoming_page.py


*** Keywords ***
Navigate To RWS Upcoming Page On Web
    [Documentation]    Navigate To RWS -> Upcoming -> Upcoming Page On Web
    Navigate To Specific Page On Web    rws    upcoming    upcoming

Click On All Visible Add Icons And Iterate Through Available Tabs On Upcoming Page On Web
    [Documentation]    Click On All Visible Add Icons And Iterate Through Available Tabs On Upcoming Page On Web
    ${is_add_icon_present}    Is Element Present On Webpage    ${UPCOMING_VISIBLE_ADD_ICONS} >> nth=0
    Skip If    not ${is_add_icon_present}    No add icons are present on the Upcoming page
    ${add_icon_elements}    Get Elements    ${UPCOMING_VISIBLE_ADD_ICONS}
    FOR    ${add_icon}    IN    @{add_icon_elements}
        Click Element On Webpage    ${add_icon}
        ...    error_message=Failed to click on add icon on Upcoming page
        Wait Until Page Is Loaded
        ${is_tab_visible}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible On Webpage
        ...    ${UPCOMING_VISIBLE_AVAILABLE_TABS} >> nth=0    timeout=${SHORT_TIMEOUT}
        IF    ${is_tab_visible}
            ${tab_count}    Get Element Count On Webpage    ${UPCOMING_VISIBLE_AVAILABLE_TABS}
            FOR    ${index}    IN RANGE    1    ${tab_count + 1}
                ${tab_locator}    Update Locator With Dynamic Values    ${UPCOMING_VISIBLE_TAB}    TAB_INDEX=${index}
                Click Element On Webpage    ${tab_locator}
                ...    error_message=Failed to click on tab with index ${index} on Upcoming page
                Wait Until Page Is Loaded
                Wait Until Element Is Visible On Webpage    ${tab_locator}.activeTab
                ...    error_message=The tab with index ${index} did not become active after clicking on it on Upcoming page
                Capture Screenshot On Webpage
            END
        ELSE
            Log    No tabs became visible after clicking on add icon on Upcoming page
            Capture Screenshot On Webpage
        END
        ${is_close_btn_visible}    Is Element Visible On Webpage    ${UPCOMING_VISIBLE_TAB_CLOSE_BTN}
        IF    ${is_close_btn_visible}
            Click Element On Webpage    ${UPCOMING_VISIBLE_TAB_CLOSE_BTN}
            ...    error_message=Failed to click on tab close button on Upcoming page
            Wait Until Element Disappears On Webpage    ${UPCOMING_VISIBLE_TAB_CLOSE_BTN}
        ELSE
            Click Element On Webpage    ${add_icon}
        END
    END
