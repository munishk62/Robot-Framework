# Work Locations Page Elements

# Action buttons
WORK_LOCATIONS_PAGE_ADD_BTN = "//span[@aria-label='Add Request']"

# Form elements
WORK_LOCATIONS_PAGE_DESCRIPTION = "//input[@id='addDescription']"
WORK_LOCATIONS_PAGE_DESCRIPTION_EDIT = "//input[@id='editDescription']"

WORK_LOCATIONS_PAGE_UNIT_DROPDOWN = "//button[@id='unitId-multi-sel-btn']"
WORK_LOCATIONS_PAGE_UNIT_SEARCH = "//input[@placeholder='Search']"
WORK_LOCATIONS_PAGE_UNIT_OPTION = "(//span[@id='displayOption_0_{UNIT}'])[1]"
WORK_LOCATIONS_PAGE_START_DATE_PICKER = (
    "//span[@aria-label='Date Picker for Effective Date']"
)
WORK_LOCATIONS_PAGE_END_DATE_PICKER = "//span[@aria-label='Date Picker for End Date']"

# Save, Update and Delete buttons
WORK_LOCATIONS_PAGE_SAVE_BTN = (
    "//button[@data-test-id='save' or normalize-space(text())='Save']"
)
WORK_LOCATIONS_PAGE_UPDATE_BTN = (
    "//button[@data-test-id='save' or normalize-space(text())='Update']"
)
WORK_LOCATIONS_PAGE_DELETE_BTN = (
    "//button[@data-test-id='delete' or normalize-space(text())='Delete']"
)
# Request row - using exact match for description
WORK_LOCATIONS_PAGE_REQUEST_ROW = (
    "//span[@role='button' and normalize-space(.)='{DESCRIPTION}']"
)

