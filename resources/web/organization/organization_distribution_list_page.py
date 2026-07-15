# Other elements
ORG_DIST_LIST_PAGE_DIST_LIST_NAME = (
    "//a[@id='editDistList' and normalize-space()='{DIST_LIST_NAME}']"
)
ORG_DIST_LIST_PAGE_ADD_DIST_NAME_TXT = "#name"
ORG_DIST_LIST_PAGE_ADD_DIST_DESC_TXT = "//textarea[@name='DESCRIPTION']"
ORG_DIST_LIST_PAGE_ADD_DIST_FROZEN_CHK_NO = "//label[@for='optFrozenList_n']"
ORG_DIST_LIST_PAGE_ADD_DIST_FROZEN_CHK_YES = "//label[@for='optFrozenList_y']"
ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_BTN = "#addDistList"
ORG_DIST_LIST_PAGE_ADD_DIST_SAVE_SUCCESS_MSG = (
    "//div[@class='succ_bg_sign_area']//following-sibling::div[@role='alert']"
)
ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_LIST_GEO_LOC = "#CRITERIA"
ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_LIST_ORG_STRUCTURE = "#selectOrgLevel"
ORG_DIST_LIST_PAGE_ADD_DIST_CRITERION_VALUE_DROPDOWN = (
    "//td[@class='unit-info']//div[contains(text(),'{CRITERION_VALUE_1}') or contains(text(),'{CRITERION_VALUE_2}')]"
)
ORG_DIST_LIST_PAGE_ADD_DIST_CRITERION_VALUE_CHECKBOX = "//span[@class='ws-checkbox ws-checkbox-inline']//following::label[contains(text(),'{CRITERION_VALUE}')]"
ORG_DIST_LIST_PAGE_ADD_DIST_CRITERION_VALUE_TEXTFIELD = (
    "//input[@class='select2-input select2-default']"
)
ORG_DIST_LIST_PAGE_ADD_DIST_LIST_BUILDING_CRITERIA_VALUE = (
    "//td[@class='v5-bdr-rt v5-bdr-btm']//following-sibling::td[2][contains(text(),'{CRITERION_VALUE_1}') or contains(text(),'{CRITERION_VALUE_2}')]"
)
ORG_DIST_LIST_PAGE_ADD_DIST_LIST = "#addDistList"
ORG_DIST_LIST_PAGE_ADD_DIST_CRITERIA_TYPE_LIST = "#CRITERIA_TYPE"
ORG_DIST_LIST_PAGE_ADD_DIST_CONFIG_SAVE_BTN = "#addDistListCriteria"
# Button elements
ORG_DIST_LIST_PAGE_UPDATE_DIST_LIST_BTN = "#updateDistList"
ORG_DIST_LIST_PAGE_PREVIOUS_BTN = "//input[@id='previous']"
ORG_DIST_LIST_PAGE_REGENERATE_UNIT_BTN = "#refreshStores"
ORG_DIST_LIST_PAGE_DEL_DIST_BTN = "#deleteDistList"
