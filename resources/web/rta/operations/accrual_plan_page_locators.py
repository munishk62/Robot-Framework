# Accrual Plan Page Locators
# This file contains XPath and CSS selector locators for the Accrual Plan page elements

# Dynamic Locators with Placeholders
ACCRUAL_PAGE_DELETE_BUTTON = "//span[@class='editsign' and text()='{TEMP_ID}']/../../../div[6]/div/span[@class='deletesign']"
ACCRUAL_PAGE_COPY_SIGN_LOCATOR = "//span[ @class ='editsign' and text()='{TEMP_ID}'] /../../../ div[5]/div/span[@class='copysign']"
ACCRUAL_PAGE_STATUS_LOCATOR = (
    "//span[@ class ='editsign' and text()='{TEMP_ID}'] /../../../ div[4]"
)
ACCRUAL_PAGE_DESC_LOCATOR = (
    "//span[@ class ='editsign' and text()='{TEMP_ID}'] /../../../ div[3]"
)
ACCRUAL_PAGE_ID_ATTRIBUTE = "//span[@class='editsign' and text()='{TEMP_ID}']"
ACCRUAL_PAGE_DROPDOWN_LOCATOR = "//li[text()='{STATUS_VALUE}'] "
ACCRUAL_PAGE_NAME_ATTRIBUTE = "//span[@class='editsign' and text()='{TEMP_NAME}']"

# Main Page Navigation Elements
ACCRUAL_PAGE_ACCRUAL_LIST_TAB = (
    "#mainContentDiv > table > tbody > tr.stdcontainerbg > td > span:nth-child(1)"
)
ACCRUAL_PAGE_ADD_ACCRUAL_PLAN = "//*[@id='addPlanBtn']"
ACCRUAL_PAGE_ACCRUAL_PLAN_LIST = (
    "//button[@id='prevBtn']/span[contains(text(),'Accrual Plan List')]"
)

# Form Field Elements
ACCRUAL_PAGE_ADD_ID = "//*[@id='ejsPDIdElemId']"
ACCRUAL_PAGE_ADD_NAME = "//*[@id='ejsPDIdElemName']"
ACCRUAL_PAGE_ADD_DESCRIPTION = "//*[@id='ejsPDIdElemDesc']"

# Dropdown Elements
ACCRUAL_PAGE_SELECT_STATUS = "//*[@id='ejsPDIdElemStatus-button']"
ACCRUAL_PAGE_SELECT_TERMTYPE = "//*[@id='ejsPDIdElemTermType-button']"
ACCRUAL_PAGE_SELECT_ACCRUALFREQUENCY = "//*[@id='ejsPDIdElemAccrueFreq-button']"

# Action Buttons
ACCRUAL_PAGE_SAVE_ACCRUAL_PLAN = "//*[@id='saveBtn']"
ACCRUAL_PAGE_PREVIOUS_BUTTON = "//*[@id='prevBtn']"

# Copy Dialog Elements
ACCRUAL_PAGE_COPY_NEW_ID = "//input[@id='ejsCopyPlanElemPlanId']"
ACCRUAL_PAGE_COPY_NEW_NAME = "//input[@id='ejsCopyPlanElemPlanName']"
ACCRUAL_PAGE_COPY_OK_BUTTON = "//button[@class='ui-button ui-corner-all ui-widget']"

# Checkbox Elements
ACCRUAL_PAGE_CAPS_CARRYOVER_CHECKBOX = "//input[@id='ejsPDIdElemCarryoverCap']"
ACCRUAL_PAGE_CAPS_BALANCE_CHECKBOX = "//input[@id='ejsPDIdElemBalanceCap']"
ACCRUAL_PAGE_CAPS_USAGE_CHECKBOX = "//input[@id='ejsPDIdElemUsageCap']"
ACCRUAL_PAGE_SUCCESS_MESSAGE = "div#info_message.succ_bg"
