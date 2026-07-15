FIXED_SHIFTS_DROPDOWN_ICON = "span#railroadDropDownIcon"
TEMPLATE_CALENDAR_MENU_OPTION = "(//span[contains(text(),'Template Calendar')])[1]"
TEMPLATE_CALENDAR_MENU_OPTIONAL = "(//span[contains(text(),'Template Calendar')])[2]"
SELECTED_YEAR_DROPDOWN = "//span[@id='selectedYear']"
WORK_PATTERN_SELECTED_ICON = "//span[@role='presentation']"
WORK_PATTERN_SEARCH_BOX = "(//div[@class='multiSelectDrodownHeader']//descendant::div[@class='searchContainer']//descendant::input)[1]"
APPLY_WORK_PATTERN_BUTTON = "//button[normalize-space()='Apply']"
SAVE_CHANGES_BUTTON = "//button[normalize-space()='Save Changes']"
SELECT_STORE_DROPDOWN = "div[class='searchandselect ng-scope ng-isolate-scope'] div[class='fitLabel ng-binding']"
STORE_SEARCH_INPUT = "//input[@placeholder='Search for...']"
CONFIRM_STORE_SEARCH_BUTTON = "//span[@aria-label='Search']"
ADD_WORK_PATTERN_BUTTON = "//span[@id='addWorkPattern']"
WORK_PATTERN_NAME_INPUT = "//input[@placeholder='Add Work Pattern']"
WORK_PATTERN_CHECKBOX = "//label[@for='statusBool']"
WORK_PATTERN_CONFIRM_ADD_BUTTON = "//button[@id='addWorkPattern']"
WORK_PATTERN_CLOSE_BUTTON = "//span[@id='closeWorkPattern']"
SUCCESS_NOTIFICATION_MESSAGE = "//div[text()='Week Mapping updated successfully']"
TEMPLATE_CALENDAR_DELETE_BUTTON = "//button[text()='Delete']"

# Dynamic Locator Templates for Update Locator With Dynamic Values
WORK_PATTERN_SELECT_BY_TITLE_LOCATOR = (
    "//span[contains(@title,'{WORK_PATTERN_NAME}')][1]"
)
YEAR_OPTION_DROPDOWN_LOCATOR = "//div[contains(@class,'templateCalendarDropdown')]/descendant::span[contains(text(),'{CURRENT_PLANNING_YEAR}')]"
DATE_XPATH_FOLLOWING_DIV_LOCATOR = (
    "//span[contains(text(),'{SELECTED_DATE}')]//following::div[1]"
)
WORK_PATTERN_MAPPED = (
    "//span[contains(text(),'{SELECTED_DATE}')]//following::div[1]//span[1]"
)
WORK_PATTERN_DELETE_BY_ARIA_LABEL_LOCATOR = "//span[contains(@aria-label,'Delete') and contains(@aria-label,'{WORK_PATTERN_NAME}')]"
WORK_PATTERN_MAPPED_TO = "//div[contains(@aria-label,'{WORK_PATTERN_NAME}') and contains(@aria-label,'{FORMATTED_DATE}')]"
WORK_PATTERN_STORE_OPTION_LOCATOR = "(//span[contains(text(),'{STORE_ID}')])[1]"
