# filepath: resources\web\rws\schedule\associate_template.py
# Associate Template elements

# Dropdown elements
ASSOCIATE_TEMPLATES_CALENDAR_DROPDOWN = "//span[@id='railroadDropDownIcon']"
ASSOCIATE_TEMPLATES_SELECT_WORK_PATTERN = (
    "//span[contains(text(),'Select Work Pattern')]"
)
REVIEW_FIXED_TEMPLATES_FROM_DROPDOWN = "//span[text()='Review Fixed Shifts']"

# Dynamic locator templates for Update Locator functions
ASSOCIATE_TEMPLATES_MAPPED_WORK_PATTERN = "//span[text()='{WORK_PATTERN_NAME}']/following::span[contains(@id,'removePattern')]"
ASSOCIATE_TEMPLATES_TEMPLATE_BY_NUMBER = (
    "//div[contains(@id,'tempEffDate') and contains(@id,'{TEMPLATE_NUMBER}')]"
)
ASSOCIATE_TEMPLATES_DELETE_TEMPLATE_BY_NUMBER = "//div[contains(@id,'tempEffDate') and contains(@id,'{TEMPLATE_NUMBER}')]/following::span[contains(@aria-label,'Delete')][1]"
ASSOCIATE_TEMPLATES_SHIFT_DAY_CONTAINER = "(//div[@day-no='{DAY_NUMBER}'])[1]"
ASSOCIATE_TEMPLATES_SHIFT_START_TIME_INPUT = (
    "((//div[@day-no='{DAY_NUMBER}'])[1])/descendant::input[@id='startTimeInput']"
)
ASSOCIATE_TEMPLATES_SHIFT_END_TIME_INPUT = (
    "((//div[@day-no='{DAY_NUMBER}'])[1])/descendant::input[@id='endTimeInput']"
)
ASSOCIATE_TEMPLATES_WORK_PATTERN_OPTION = "//span[normalize-space()='Work Patterns']/following::span[contains(text(),'{WORK_PATTERN_NAME}')][1]"
ASSOCIATE_TEMPLATES_WORK_PATTERN_SEARCH_RESULT = "//input[contains(@placeholder,'Search')]/following::span[contains(text(),'{WORK_PATTERN_NAME}')][1]"
ASSOCIATE_TEMPLATES_ASSOCIATE_OPTION = (
    "//li//*[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]"
)


# Other elements
ASSOCIATE_TEMPLATES_FROM_CALENDAR = "//span[text()='Associate Template']"
ASSOCIATE_TEMPLATES_HEADING = "//span[text()='Associate Template']"
ASSOCIATE_TEMPLATES_NEXTGEN = "//span[contains(text(),'NEXT_GEN_TEMPLATE')]"
ASSOCIATE_TEMPLATES_SAVE_TEMP = "//button[text()='Save']"
ASSOCIATE_TEMPLATES_NOTIFICATION = "//div[@class='notifyMsg ng-binding ng-scope']"
ASSOCIATE_TEMPLATES_CREATED_TEMP_PANEL = "class='ng-binding'"
ASSOCIATE_TEMPLATES_CLOSE_PANEL = "//span[@aria-label='close']"
ASSOCIATE_TEMPLATES_FIRST_HALF_SHIFT = "//input[@tabindex='1']"
ASSOCIATE_TEMPLATES_SECOND_HALF_SHIFT = "//input[@tabindex='2']"
ASSOCIATE_TEMPLATES_TEMP_SHIFTS = "//span[@aria-label='Template Shifts']"
ASSOCIATE_TEMPLATES_DELETE = "//span[@aria-label='Delete']"
ASSOCIATE_TEMPLATES_DELETE_CONFIRM = "//button[@id='okButton']"
ASSOCIATE_TEMPLATES_SEARCH_FILTER = "//input[@aria-label='Filter By Employee']"
ASSOCIATE_TEMPLATES_SEARCH_SUGGESTION = "//a[@class='ng-binding ng-scope']"
ASSOCIATE_TEMPLATES_SEARCH_OP = "//span[@class='templateNameOverflow ng-binding']"

# Add/Edit elements
ASSOCIATE_TEMPLATES_ADD_TEMPLATE = "//span[@id='addTemplateIcon']"
ASSOCIATE_TEMPLATES_ADD_BLANK_TEMPLATE = "//span[text()='Blank Template']"
ASSOCIATE_TEMPLATES_ADD_EFFECTIVE_DATE = "//*[@id='effDateCalendar']"
ASSOCIATE_TEMPLATES_ADD_EFFECTIVE_DATE_INPUT_TEXT_BOX = (
    "//input[@aria-label='Effective Date']"
)
ASSOCIATE_TEMPLATES_ADD_TEMP_EMP = "//input[@id='empSelForAddEmpTemp']"
ASSOCIATE_TEMPLATES_ADD_TEMP_FIRST_EMP = "//shortcut//ul/li[1]/a"
ASSOCIATE_TEMPLATES_ADD_SHIFT_DAYS = "//div[@on-add-shift='assocTmplCtrl.onAddNewShiftPop(createdShift,dayNoList)' and @day-no='${value}']"
ASSOCIATE_TEMPLATES_ADD_SHIFT = "//span[@id='inlineAddShift']"
ASSOCIATE_TEMPLATES_ADD_WORK_PATTERN = "//*[@id='addWorkPattern']"
ASSOCIATE_TEMPLATES_SEARCH_WORK_PATTERN = "//input[contains(@placeholder,'Search')]"
ASSOCIATE_TEMPLATES_SHIFT_TIME_TICK_BUTTON = (
    "//div[@id='buttonsContainer']//span[@id='inlineAddShift']"
)
ASSOCIATE_TEMPLATES_MAP_TO_OPTION = "//span[contains(text(),'Map to')]"
ASSOCIATE_TEMPLATES_MAP_TO_SAVE_OPTION = "//button[@id='savePatternSelection']"
ASSOCIATE_TEMPLATES_LOCK_OPTION = "//span[contains(text(),'Lock')]"
ASSOCIATE_TEMPLATES_LOCK_ALL_SHIFTS = (
    "//label[normalize-space()='Lock All Shifts'] | //label[@id='lockShift']"
)
ASSOCIATE_TEMPLATES_LOCK_OPTION_SAVE = (
    "//button[@id='saveLockStatus']  | //button[@id='saveDetails']"
)
ASSOCIATE_TEMPLATES_MAPPED_TO_OPTION = "//span[text()='{WORK_PATTERN_NAME}']/following::span[contains(@id,'removePattern')]"
ASSOCIATE_TEMPLATES_TEMPLATE_PREVIEW_BY_NUMBER = (
    "//div[contains(@id,'tempEffDate') and contains(@id,'{TEMPLATE_NUMBER}')]"
)
TEMPLATE_SHIFTS_START_TIME_PATH = "//input[@id='starTimeInput']"
TEMPLATE_SHIFTS_END_TIME_PATH = "//input[@id='endTimeInput']"

# Copy Shift dynamic locator templates
ASSOCIATE_TEMPLATES_SHIFT_BUBBLE_BY_INDEX = "(//div[@class='shiftBubble'])[{INDEX}]"
ASSOCIATE_TEMPLATES_EDIT_SHIFT = "//span[normalize-space()='Edit Shift']"
ASSOCIATE_TEMPLATES_COPY_SHIFT = "//span[normalize-space()='Copy Shift']"
ASSOCIATE_TEMPLATES_COPY_DAY_BY_INDEX = "(//div[@id='addDays{DAY_NUMBER}'])[1]"
ASSOCIATE_TEMPLATES_COPY_SHIFT_SAVE = "//button[normalize-space()='Save']"

# Notification elements
SUCCESS_TOAST_POPUP = "//div[@class='rfx-notify-message ng-scope success']"
