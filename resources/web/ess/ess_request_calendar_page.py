# ESS Request Calendar Page elements
ESS_ADD_REQUEST_BUTTON = "//span[@aria-label='Add Request']"
ESS_ADD_REQUEST_TYPE_BUTTON = "//span[text()='Type']"
ESS_REQUEST_TYPE_DROPDOWN = "//select[@id='selectType']"
ESS_REASON_TYPE_DROPDOWN = "//select[@aria-label='Select Reason']"
ESS_REQUEST_CALENDAR_PAGE_START_DATE = "input#empEffDate"
ESS_REQUEST_CALENDAR_PAGE_END_DATE = "input#empEndDate"
Add_DAY_OFF_DEFAULT_STATUS_ESS = "//span[@aria-label='Status Not Reviewed']"
ESS_REQUEST_SAVE_BUTTON = "//button[normalize-space()='Save']"
ESS_REQUEST_CLOSE_BUTTON = "//span[contains(@class,'ws-iconXclose')]"
ESS_REQUEST_CANCEL_BUTTON = "//button[normalize-space()='Cancel Request']"
ESS_REQUEST_DELETE_BUTTON = "//button[normalize-space()='Delete']"
REQUEST_CALENDAR_APPROVE_BUTTON = "xpath=//button[@aria-label='Approve Request']"
SUCCESS_TOAST_POPUP = "//div[@class='rfx-notify-message ng-scope success']"
Add_TIME_OFF_DEFAULT_STATUS_ESS = "//span[@aria-label='Status Not Reviewed']"
ADD_TIME_OFF_START_TIME = "//input[@id='timePickerPop']"
ADD_TIME_OFF_NOTE_TO_MANAGER_ESS = "//textarea[@aria-label='Requester Comment']"
ADD_TIME_OFF_DURATION_TIME = "//input[@aria-label='Select Duration']"
HOLIDAY_HOURS_INPUT_GRID = "//div[@id='holHrs']"
HOLIDAY_HOURS_ICON = "//a[text()='Holiday Hours']"
TIME_OFF_REQUEST_NOTIFICATION = "(//span[contains(@class, 'title') and contains(text(), 'Time-Off Request') and contains(text(), '{DATE}') and contains(text(), '{START_time}') and contains(text(), 'from') and contains(text(), '{END_TIME}')])[1]"
ESS_REQUEST_CALENDAR_REQUEST_ENTRY = "//span[contains(@class,'requestType')][contains(text(),'{REQUEST_TYPE}')]/parent::span/following-sibling::span[contains(@class,'requestDuration')][contains(text(),'{DURATION}')]"
ESS_REQUEST_CALENDAR_REQUEST_SELECTED_REASON = (
    "(//select[@role='listbox'][@aria-label='Reason'])[1]"
)
ESS_REQUEST_CALENDAR_REQUEST_STATUS = (
    "//span[contains(@ng-if,'requestStatus')][not (contains(@class,'ws-icon'))]"
)
ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_EDIT_START_DATE_TIMEPICKER = "//input[@id='empEffDate']/following-sibling::span//img[contains(@class,'calendar-icon')]"
ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_EDIT_END_DATE_TIMEPICKER = "//input[@id='empEndDate']/following-sibling::span//img[contains(@class,'calendar-icon')]"
ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_EDIT_DUE_DATE_TIMEPICKER = "//input[@id='dueByDate']//following-sibling::span//img[contains(@class,'calendar-icon')]"
ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_EDIT_DUE_DATE_TEXTBOX = "//input[@id='dueByDate']"
ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_REQUESTER_COMMENT = (
    "//textarea[@id='comment'][contains(@aria-label,'Requester')]"
)
ESS_REQUEST_CALENDAR_PAGE_NEXT_WEEK_ICON = (
    "//span[contains(@class,'ws-iconArrowDateRight')]"
)
ESS_REQUEST_CALENDAR_PAGE_PREVIOUS_WEEK_ICON = (
    "//span[contains(@class,'ws-iconArrowDateLeft')]"
)
ESS_REQUEST_CALENDAR_PAGE_SUCCESS_NOTIFICATION_TEXT = "//div[contains(@class,'rfx-notify-message') and (contains(@class,'success'))]//div[contains(@class,'notifyMsg')]"
ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_TAB = (
    "//span[@role='tab'][contains(text(),'Day Off')]"
)
ESS_REQUEST_CALENDAR_PAGE_DAY_OFF_REQUEST = (
    "(//div[contains(@class,'request-block')][contains(@aria-label,'Day Off')])[1]"
)
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_PREFERENCE = "//select[@id='availCd']"
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_PREFERENCE_VALUE = (
    "//span[contains(@aria-label,'Preference')]"
)
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_WEEK_START = "//input[@id='avlWeekStart']"
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_STORE_ID = (
    "//div[contains(@class,'storeId')]/following-sibling::div//span"
)
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_STATUS = "//span[contains(@aria-label,'Status')]"
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_WEEK_START_DATEPICKER = "//div[contains(@class,'weekStart')]/following-sibling::div//span[@aria-label='Calendar']"
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON = "//select[@id='reasonCd']"
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_TOTALLY_AVAILABLE_BUTTON = (
    "(//input[@value='Totally Available'])[1]"
)
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_NOT_AVAILABLE_CHECKBOX = (
    "((//tbody//input[@type='checkbox'])[{DAY}])[{ROTATION}]"
)
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_NOT_AVAILABLE_CHECKBOX_CHECKED = "((//tbody//input[@type='checkbox'])[{DAY}])[{ROTATION}][contains(@class,'ng-not-empty')]"
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DAY_START_INPUT = "((((//span[contains(text(),'Availability')]//parent::td/parent::tr)[{AVAIL}])//div[@class='typeAheadFilter']/input[1])[{DAY}])[{ROTATION}]"
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DAY_END_INPUT = "((((//span[contains(text(),'Availability')]//parent::td/parent::tr)[{AVAIL}])//div[@class='typeAheadFilter']/input[2])[{DAY}])[{ROTATION}]"
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_ROTATION_HEADING = (
    "//th/span[contains(@ng-bind,'Rotation')]"
)
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_SUBMIT_BUTTON = (
    "button[ng-click*='submitAvailabilityRequest']"
)
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_ENTRY = (
    "//span[contains(@class,'requestType')][contains(text(),'Availability')]"
)
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUESTS_TAB = (
    "//span[@role='tab'][contains(text(),'Availability')]"
)
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_DELETE_BUTTON = (
    "//button[normalize-space()='Delete']"
)
ESS_REQUEST_CALENDAR_PAGE_CONFIRMATION_OK_BUTTON = "//button[@id='okButton']"
ESS_REQUEST_CALENDAR_PAGE_AVAILABILITY_ROTATIONS_ELEMENTS = (
    "//div[contains(@class,'availabilityDaywiseDetails')]//tbody"
)
ESS_REQUEST_CALENDAR_PAGE_HOLIDAY_HOURS_INPUT = "(//div[@id='holHrs']//tr//td/following-sibling::td)[{DAY}]/input[contains(@aria-label,'Holiday Hours')]"
AVAILABILITY_REQUEST_NOTIFICATION = "(//span[contains(@class, 'title') and contains(text(), 'Availability Request') and contains(text(), '{DATE}')])[1]"
