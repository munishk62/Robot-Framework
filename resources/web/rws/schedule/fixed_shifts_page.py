# Button elements
FIXEDSHIFTSPAGE_WEEK_MAP_STATUS_FOR_GIVEN_DATE = (
    "//span[text() = '{DATEOFWEEK}']/parent::div/following-sibling::div/div/span"
)
FIXEDSHIFTSPAGE_SELECT_WORK_PATTERN = "//div[@id='templateId-multi-sel-options']/div[2]//div[@role='listbox']/div[{INDEX}]"
FIXEDSHIFTSPAGE_APPLY_BTN = "#applyButton"
FIXEDSHIFTSPAGE_SAVE_CHANGES_BTN = "#saveButton"
FIXEDSHIFTSPAGE_DELETE_BTN = "#closeEditPanel"

# Calendar navigation dynamic locator templates for Update Locator functions
FIXEDSHIFTSPAGE_CALENDAR_MONTH_YEAR_HEADER = (
    "//button[contains(@class, 'datePickerDayHeader')]"
)
FIXEDSHIFTSPAGE_CALENDAR_BUTTON = (
    "//span[contains(@ng-bind, 'Ctrl.selectedScheduleDateUILabel')] | //span[@data-testid='forecast-review-btn-date-picker']"
)
FIXEDSHIFTPAGE_CALENDAR_POP_UP = "//ul[@role='button']"
FIXEDSHIFTSPAGE_YEAR_BUTTON_BY_YEAR = (
    "//button[contains(normalize-space(@aria-label), '{TARGET_YEAR}')]"
)
FIXEDSHIFTSPAGE_YEAR_BUTTON_DYNAMIC_BY_YEAR = (
    "//button[contains(@class,'datePickerMonthHeader')]"
)
FIXEDSHIFTSPAGE_YEAR_DIGITS_BY_LAST_TWO = (
    "//button[contains(@class, 'btn-default')]//span[text()='{YEAR_LAST_2_DIGITS}']"
)
FIXEDSHIFTSPAGE_MONTH_BUTTON_BY_NAME = "//button[contains(@class, 'btn-default')]//span[text()='{MONTH_NAME}'] | //span[normalize-space()='{MONTH_NAME}']"
FIXEDSHIFTSPAGE_DAY_BUTTON_BY_FORMATTED_DATE = (
    "//button[contains(normalize-space(@aria-label), '{FORMATTED_DATE}')]"
)
FIXEDSHIFTSPAGE_WEEK_NUMBER_BUTTON = (
    "{DAY_LOCATOR}/preceding::td[@ng-if='showWeeks'][1]/button"
)

# Dropdown elements
PLAN_STATUS_RAILROAD_DROPDOWN_ITEM = "//span[contains(text(),'Plan Status')]"
# Other elements
FIXEDSHIFTS_TEMPLATE_CALENDAR_SHIFT_SCHEDULE_BY_DATE = "(//span[contains(text(),'{PLANNING_WEEK_START_DATE}')]//following::div[3]/span[contains(@aria-label,'Fixed Shift Schedule')])[1]"
FIXEDSHIFT_REVIEW_REVIEWSHIFT_ACTION_ICON = "//div[@id='mainContainer']/div/div/table/tbody/tr/td//span[contains(@ng-click,'ActionsClick')]|//span[contains(@ng-click, 'ActionsClick')]"
FIXEDSHIFT_REVIEW_REVIEWSHIFT_ACTION_REGENERATE_WEEK = (
    "//span[contains(text(),'Regenerate Week Fixed Shift Schedule')] "
)
FIXEDSHIFTSPAGE_PLEASE_WAIT_SPINNER = (
    "//div[@id='rfx_spinner']//div[@class='rfx-spinner']"
)

# Button elements
FIXEDSHIFTS_RAILROAD_DROPDOWN_ICON_BUTTON = "//span[@id='btn-railroad-toggle']"
FIXEDSHIFT_REVIEW_REVIEWSHIFT_ACTION_ALERT_BUTTON = "//button[@id='okButton']"
FIXEDSHIFT_REVIEW_REVIEWSHIFT_LOADING_PROGRESS_BAR = (
    "//span[contains(@aria-label,'Please Wait')]"
)

# Review Fixed Shifts - Shift verification locators
REVIEW_FIXED_SHIFTS_ASSOCIATE_SHIFT_IN_DAY = "//span[contains(text(),'{ASSOCIATE_NAME}')]/ancestor::tr//td[@data-testid='weekday_{DAY_INDEX}']//div[@class='shiftBubble']"
REVIEW_FIXED_SHIFTS_SHIFT_DATE = "(//span[contains(@aria-label,'{ASSOCIATE_NAME}')]//following::div[(contains(@aria-label, '{START_TIME}') or contains(@aria-label, '{START_TIME_NO_SPACE}')) and (contains(@aria-label, '{END_TIME}') or contains(@aria-label, '{END_TIME_NO_SPACE}')) and contains(@aria-label, '{SHIFT_DAY}')])[1]"
REVIEW_FIXED_SHIFTS_SHIFT_TIME_TEXT = "//span[contains(text(),'{ASSOCIATE_NAME}')]/ancestor::tr//td[@data-testid='weekday_{DAY_INDEX}']//div[@class='shiftBubble']//div[@class='shiftTime']"
REVIEW_FIXED_SHIFTS_EMP_TEMP_DELETE_ICONS = "//span[contains(text(),'{ASSOCIATE_NAME}')]/ancestor::div[contains(@id,'associateTemplateRow')]//span[contains(@ng-click,'DeleteAssociateTemplateIcon')]"
FIXEDSHIFTS_NOTIFICATION_CLOSE_BTN = "//div[contains(@class,'rfx-notify-message')]//span[@id='closeBtn']"
FIXEDSHIFTS_ADD_TEMPLATE_BTN = "span#addTemplateicon"
FIXEDSHIFTS_ADD_TEMPLATE_SAVE_BTN = "button[ng-click*='addNewGenericTemplate']"
