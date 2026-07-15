PAY_POLICY_PAGE_HEADING = (
    "#content-wrapper > table.tblOuter > tbody > tr.stdcontainerbg > td"
)
PAY_POLICY_PAGE_ADD_BTN = "//input[@id='addPayPolicy']"
PAY_POLICY_PAGE_ADD_ID = "#policyId"
PAY_POLICY_PAGE_ADD_NAME = "#policyName"
PAY_POLICY_PAGE_DESCRIPTION = "#policyDesc"
PAY_POLICY_PAGE_ADD_VERSION = "#versionName"
PAY_POLICY_PAGE_ADD_EFFECTIVE_DATE = "#effFromDate"
PAY_POLICY_PAGE_ADD_END_DATE = "#effToDate"
PAY_POLICY_PAGE_DEFAULT_STATUS = (
    "//div[@id='basicDetails']/table/tbody/tr[last()-1]/td[2]"
)
PAY_POLICY_PAGE_SAVE_POLICY_BUTTON = "#content-wrapper > table > tbody > tr.buttonbg > td:nth-child(2) > input#validatePolicyId.positive-button"
PAY_POLICY_PAGE_NOTIFICATION_SUCCESS = "div#info_message.succ_bg"
PAY_POLICY_PAGE_PREVIOUS_BUTTON = (
    "#content-wrapper > table > tbody > tr.buttonbg > td:nth-child(1) > input"
)
PAY_POLICY_PAGE_VERSION_PREVIOUS_BUTTON = (
    "#content-wrapper > table.tblOuter > tbody > tr.buttonbg > td > input"
)
PAY_POLICY_PAGE_NON_LINK_ATTRIBUTE = (
    "//div[@id='timeColPlcyList']/div[2]/table/tbody/tr/td[text()='{POLICY_ID}']"
)
PAY_POLICY_PAGE_LINK_ATTRIBUTE = (
    "//div[@id='timeColPlcyList']/div[2]/table/tbody/tr/td/a[text()='{POLICY_NAME}']"
)
PAY_POLICY_PAGE_STATUS = "//div[@id='timeColPlcyList']/div[2]/table/tbody/tr/td[text()='{POLICY_ID}']/../td[5]"
PAY_POLICY_PAGE_EFF_DATE = "//div[@id='timeColPlcyList']/div[2]/table/tbody/tr/td[text()='{POLICY_ID}']/../td[1]"
PAY_POLICY_PAGE_END_DATE = "//div[@id='timeColPlcyList']/div[2]/table/tbody/tr/td[text()='{POLICY_ID}']/../td[2]"
PAY_POLICY_PAGE_COPY_BUTTON = "//div[@id='timeColPlcyList']/div[2]/table/tbody/tr/td[text()='{POLICY_ID}']/../td[6]/a/img"
PAY_POLICY_PAGE_COPY_ID = "#newPlcyId"
PAY_POLICY_PAGE_COPY_OK_BUTTON = (
    "#divCopyPlcyId > table > tbody > tr:nth-child(4) > td > span:nth-child(2) > input"
)
PAY_POLICY_PAGE_DELETE_BUTTON = "//div[@id='payPlcyList']/div[2]/table/tbody/tr/td/a[text()='{POLICY_VERSION}']/../../td[6]/a/img"
PAY_POLICY_PAGE_VERSION_LINK = "//a[text()='{POLICY_VERSION}']"
