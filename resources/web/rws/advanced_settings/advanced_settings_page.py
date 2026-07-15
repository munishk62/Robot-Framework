# filepath: resources/web/rws/advanced_settings/advanced_settings_page.py
# Advanced Settings Page elements for BATTC00243 test case

# Form dropdown elements
ADVANCEDSETTINGSPAGE_SELECTED_TYPE = "//select[@id='cboType' and @name='cboType']"
ADVANCEDSETTINGSPAGE_SELECTED_STORE_GROUP = "//select[@id='cboStoreGrp']"
ADVANCEDSETTINGSPAGE_SELECTED_FISCAL_YEAR = "//select[@id='cboFiscalYear']"
ADVANCEDSETTINGSPAGE_SELECTED_FISCAL_WEEK = "//select[@id='cboFiscalWeek']"

# Action buttons
ADVANCEDSETTINGSPAGE_SELECTED_DELETE_BUTTON = "//input[@id='del']"
ADVANCEDSETTINGSPAGE_SELECTED_DELETE_GENERATE_BUTTON = "//input[@id='delg']"
ADVANCEDSETTINGSPAGE_SELECT_QUEUE = "//input[@id='validateSubmit']"

# Schedule Preference dropdown (shown for the "Delete & Generate" operation). Options:
#   B  -> "Delete and Generate unedited schedules" (page default)
#   C  -> "Delete and Generate all schedules"
#   SA -> "Delete and Generate based on Store Attribute" (the spec's "based on unit attribute")
ADVANCEDSETTINGSPAGE_SELECTED_SCHEDULE_PREFERENCE = "//select[@id='schedRegenOption']"

# Popup confirmation
ADVANCEDSETTINGSPAGE_POPUP_WINDOW_OK_BUTTON = "//button[normalize-space()='Ok']"
