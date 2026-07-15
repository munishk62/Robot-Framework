# Criteria Configuration Page Elements

# Add/Edit elements
CRITERIACONFIGURATION_ADD_ICON = "#addCriteria"
CRITERIACONFIGURATION_ADD_CRITERIA_NAME = "//input[@id='criteriaName']"

# Criteria Applied On - multiselect dropdown (using multiselect id)
CRITERIACONFIGURATION_ADD_CRITERIA_APPLIED_ON = (
    "//multiselect[@id='critiaAppliedOn']//button[@id='key-multi-sel-btn']"
)
CRITERIACONFIGURATION_ADD_CRITERIA_APPLIED_ON_UNIT = (
    "//multiselect[@id='critiaAppliedOn']//span[@id='displayOption_1_Unit']"
)

# Criteria Type - multiselect dropdown
CRITERIACONFIGURATION_ADD_CRITERIA_TYPE = (
    "//multiselect[@id='criteriaType']//button[@id='codeValue-multi-sel-btn']"
)
CRITERIACONFIGURATION_ADD_CRITERIA_TYPE_SHARE = (
    "//multiselect[@id='criteriaType']//span[@id='displayOption_1_SHARE']"
)

# Status - multiselect dropdown (using multiselect id)
CRITERIACONFIGURATION_ADD_CRITERIA_STATUS = (
    "//multiselect[@id='criteriaStatus']//button[@id='key-multi-sel-btn']"
)
CRITERIACONFIGURATION_ADD_CRITERIA_STATUS_ACTIVE = (
    "//multiselect[@id='criteriaStatus']//span[@id='displayOption_0_A']"
)

# Unit Selection
CRITERIACONFIGURATION_ADD_CRITERIA_UNIT = "//input[@id='criteriaUnit']"
CRITERIACONFIGURATION_ADD_CRITERIA_UNIT_OPTION = "//li[@role='option']//a"

# Date Picker Icons
CRITERIACONFIGURATION_EFFECTIVE_DATE_PICKER = "//span[contains(@class,'ws-iconCalendar') and contains(@aria-label,'Effective Date Calendar')]"
CRITERIACONFIGURATION_END_DATE_PICKER = "//span[contains(@class,'ws-iconCalendar') and contains(@aria-label,'End Date Calendar')]"

# Override Manual Share Request Toggle
CRITERIACONFIGURATION_OVERRIDE_SHARE_REQUEST_TOGGLE = (
    "//span[@aria-label='Override Manual Share Request'][@role='checkbox']"
)
# Indicates the toggle is currently ON (aria-checked=true) - used to detect state before clicking
CRITERIACONFIGURATION_OVERRIDE_SHARE_REQUEST_TOGGLE_ON = (
    "//span[@aria-label='Override Manual Share Request'][@role='checkbox'][@aria-checked='true']"
)

# Condition Builder Elements
CRITERIACONFIGURATION_ADD_CONDITION_BUTTON = "//input[@value='Add Condition']"
CRITERIACONFIGURATION_CONDITION_ATTRIBUTE = "//select[contains(@id,'Attribute')]"
CRITERIACONFIGURATION_CONDITION_ATTRIBUTE_ID = "(//select[@id='AttrId1 + 0 + 1'])[1]"
CRITERIACONFIGURATION_CONDITION_VALUE_TEXT = "//input[contains(@id,'AttrValueT')]"

# Search elements
CRITERIACONFIGURATION_SEARCH_CRITERIA = "//input[@id='searchCriteria']"
CRITERIACONFIGURATION_SEARCH_RESULT_BY_NAME = (
    "(//span[@role='link'][normalize-space(text())='{CRITERIA_NAME}'])[1]"
)

# Button elements
CRITERIACONFIGURATION_SAVE_BUTTON = "//input[@value='Save']"
CRITERIACONFIGURATION_DELETE_BUTTON = "//input[@type='button' and @value='Delete']"
CRITERIACONFIGURATION_DELETE_CONFIRMATION_OK_BUTTON = "//button[@id='okButton']"
