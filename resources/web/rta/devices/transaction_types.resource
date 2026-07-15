*** Settings ***
Documentation       Resource file for Transaction Types Page related keywords

Resource            resources/web/common/common.resource
Variables           resources/web/rta/devices/transaction_types_page.py


*** Keywords ***
Navigate To RTA Devices Transaction Types Page On Web
    [Documentation]    Navigates to the RTA -> Devices -> Transaction Types page.
    Navigate To Specific Page On Web    rta    devices    transaction_types

Click On Add Transaction Type Button On Transaction Types Page On Web
    [Documentation]    Clicks on Add Transaction Type button on Transaction Types page
    Click Element On Webpage    ${TRANSACTION_TYPES_PAGE_ADD_BUTTON}
    ...    error_message="Failed to click on Add Transaction Type button on Transaction Types page."
    Wait Until Element Is Visible On Webpage    ${TRANSACTION_TYPES_PAGE_PREVIOUS_BUTTON}
    ...    error_message="Add Transaction Type form did not open after clicking Add Transaction Type button."
    Capture Screenshot On Webpage
