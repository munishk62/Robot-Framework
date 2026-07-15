# filepath: resources/web/admin/organization_distribution_lists_page.py
# Organization Distribution Lists Page elements

# Other elements
ORG_DIST_LIST_PAGE_DIST_LIST_NAME = (
    "//a[@id='editDistList' and normalize-space()='{DIST_LIST_NAME}']"
)
# Add/Edit elements
ORG_DIST_LIST_PAGE_ADD_DIST_LIST = "#addDistList"
ORG_DIST_LIST_PAGE_ADD_DIST_NAME_TXT = "#name"
ORG_DIST_LIST_PAGE_ADD_DIST_DESC_TXT = "//textarea[@name='DESCRIPTION']"
ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG = (
    "//div[@id='info_message']//div[@role='alert' and normalize-space()='{MSG}']"
)
ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_TYPE_LIST = "#CRITERIA_TYPE"
# Button elements
ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_BTN = "#addDistList"
ORG_DIST_LIST_PAGE_ADD_DIST_CONFIG_SAVE_BTN = "#addDistListCriteria"
ORG_DIST_LIST_PAGE_DEL_DIST_BTN = "#deleteDistList"
