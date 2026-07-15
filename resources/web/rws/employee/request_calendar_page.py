# filepath: web\resources\hr\new_locators1\ess_request_calendar_page.py
# Request Calendar Page elements
spinner = "xpath=//img[@alt='spinner']"
# Other elements
REQUEST_CALENDAR_PAGE_NEXT_WEEK = "//div[@aria-label='Next Week']"
REQUEST_CALENDAR_PAGE_WEEK_LABEL = (
    "//span[@ng-bind='reqCalendarCtrl.selectedScheduleDateUILabel']"
)
REQUEST_CALENDAR_PAGE_ASSOCIATE_START_DATE_AVAILABILITY = "input#empEffDate"
REQUEST_CALENDAR_PAGE_CALENDAR_RIGHT_ARROW = "[alt='arrow date right']"
REQUEST_CALENDAR_PAGE_CALENDAR_AVAILABILITY_ROTATION_DROPDOWN = (
    "//button[contains(@aria-label, 'Number of Rotations')]"
)
REQUEST_CALENDAR_PAGE_CALENDAR_AVAILABILITY_DELETE = "button.btn.btn-gray"
REQUEST_CALENDAR_PAGE_CALENDAR_AVAILABILITY_DELETE_CONFIRM = "button#okButton"
REQUEST_CALENDAR_PAGE_ADD_REQUEST_BUTTON = "//span[@aria-label='Add Request']"
REQUEST_CALENDAR_PAGE_START_DATE = "input#empEffDate"
REQUEST_CALENDAR_PAGE_END_DATE = "input#empEndDate"
REQUEST_CALENDAR_PAGE_STATUS_TEXT = "//div[contains(@ng-if,'requestStatus')]"
REQUEST_CALENDAR_PAGE_START_TIME_TIME_OFF = "((//tr[contains(@ng-if,'reqCalendarCtrl.empRequest.requestType')]//td[1])/following::button)[1]"
REQUEST_CALENDAR_PAGE_DURATION_TIME_OFF = "((//tr[contains(@ng-if,'reqCalendarCtrl.empRequest.requestType')]//td[1])/following::button)[2]"
REQUEST_CALENDAR_PAGE_CALENDAR_MONTH_AND_YEAR = (
    "//span[contains(@ng-bind,'selectedScheduleDateUILabel')]"
)
REQUEST_CALENDAR_PAGE_ASSOCIATE_SEARCH_FIELD = "input[placeholder='Search']"
REQUEST_CALENDAR_PAGE_DAY_OFF_REASON_DROPDOWN_BUTTON = "//tr[@ng-if='!reqCalendarCtrl.showUsedLeaves']//following::input[@ng-model=\"reqCalendarCtrl.selectedReasonObject.requestTypeName\"]/following::button[1]"
REQUEST_CALENDAR_PAGE_DAY_OFF_SUBMIT_BUTTON = (
    "xpath=//button[@aria-label='Submit Request']"
)
REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON_DROPDOWN = (
    "//button[contains(@aria-label,'Reason for Availability Request')]"
)

# Add/Edit elements
REQUEST_CALENDAR_PAGE_ADD_DAY_OR_TIME_OFF_REQUESTS = "span#addDayOffTimeoffReqId"
REQUEST_CALENDAR_PAGE_ADD_AVAILABILITY_REQUEST = "span#addAvailabilityReqId"
REQUEST_CALENDAR_PAGE_HOLIDAY_HOURS_INPUT = (
    "//td[1]//following-sibling::td[{DAY}]//input[contains(@aria-label,'week hours')]"
)

# Dropdown elements
REQUEST_CALENDAR_PAGE_SELECT_ASSOCIATE_DROPDOWN = "button#employeeId-multi-sel-btn"
REQUEST_CALENDAR_PAGE_SELECT_FIRST_ASSOCIATE = (
    "(//span[contains(@class,'ws-fs-12 ws-fw-normal')])[1]"
)
REQUEST_CALENDAR_PAGE_TIME_OFF_SELECT_TIME = "//a[.='{TIME}']"
REQUEST_CALENDAR_PAGE_TIME_OFF_SELECT_DURATION = (
    "//a[contains(text(), '{HRS} Hrs {MIN} Mins')]"
)
REQUEST_CALENDAR_PAGE_SELECT_STATUS_VALUE = "//button[@id='statusCd']"

# Button elements
REQUEST_CALENDAR_PAGE_ASSOCIATE_DELETE_BUTTON_DAY_OFF = "button#decline_5"
REQUEST_CALENDAR_PAGE_TIME_OFF_TOGGLE_BUTTON = "span#reqTypeToggle>span"
REQUEST_CALENDAR_PAGE_AVAILABILITY_REQUEST_NEXT_BUTTON = (
    "button[set-focus='addAvailHoursId']"
)
REQUEST_CALENDAR_PAGE_ASSOCIATE_SUBMIT_BUTTON_AVAILABILITY = (
    "[ng-click='reqCalendarCtrl.submitAvailabilityRequest();']"
)
REQUEST_CALENDAR_PAGE_DAY_OFF_CLOSE_BUTTON = (
    "xpath=//span[contains(@aria-label,'Close')]"
)
REQUEST_CALENDAR_PAGE_DELETE_DAY_OFF_REQUEST_BUTTON = (
    "xpath=//button[@aria-label='Delete Request']"
)
REQUEST_CALENDAR_APPROVE_BUTTON = "xpath=//button[@id='approveSelReq']"
REQUEST_CALENDAR_DECLINE_BUTTON = "//button[@aria-label='Decline Request']"
REQUEST_CALENDAR_PAGE_REQUEST_STATUS = (
    "xpath=//span[normalize-space()='Status']//following::td[1]"
)
REQUEST_CALENDAR_PAGE_FILTER_BUTTON = "//span[@aria-label='Filter Requests']"
REQUEST_CALENDAR_PAGE_FILTER_PANEL = "//a[normalize-space()='Filter Settings']"
REQUEST_CALENDAR_PAGE_FILTER_REQUEST_STATUS_DROPDOWN = "//td[normalize-space()='Request Status']/following-sibling::td//button"
REQUEST_CALENDAR_PAGE_FILTER_REQUEST_TYPE_DROPDOWN = "//td[normalize-space()='Request Type']/following-sibling::td//button"
SM_REQUEST_DROPDOWN_APPLY_BUTTON = "//button[@aria-label='Apply']"
SM_REQUEST_CALENDAR_PAGE_REQUESTS_PRESENT = (
    "//div[starts-with(@id,'AB') or starts-with(@id,'TO') or starts-with(@id,'DO')]"
)
LOAD_SPINNER = "//img[@alt='spinner']"
SM_REQUEST_CALENDAR_PAGE_LIST_VIEW_BUTTON = "//span[contains(@class,'iconListView')]"
SM_BULK_DAY_OFF_REQUEST_VIEW_ALL_BUTTON = (
    "(//span[contains(text(),'Day Off')]/following::a[normalize-space()='View All'])[1]"
)
SM_BULK_TIME_OFF_REQUEST_VIEW_ALL_BUTTON = "(//span[contains(text(),'Time Off')]/following::a[normalize-space()='View All'])[1]"
SM_BULK_AVAILABILITY_REQUEST_VIEW_ALL_BUTTON = "(//span[contains(text(),'Availability')]/following::a[normalize-space()='View All'])[1]"
SM_BULK_APPROVE_BUTTON = "//button[normalize-space()='Approve Selected']"
SM_BULK_NAVIGATION_LIST_VIEW = "//span[normalize-space()='{PANEL_TYPE}']"
SM_BULK_DECLINE_BUTTON = "//button[normalize-space()='Decline Selected']"
SUCCESS_TOAST_POPUP = "//div[@class='rfx-notify-message ng-scope success']"
# Navigation Panel Type Locators
SM_BULK_NAVIGATION_LEAVE_AND_AVAILABILITY = "//div[@id='requestNavPanel']/span[contains(@ng-if,'LeaveAndAvailibility')]"
SM_BULK_NAVIGATION_SHIFT_REQUEST = "//div[@id='requestNavPanel']/span[contains(@ng-if,'ShiftRequest')]"
SM_BULK_NAVIGATION_ALTERNATE_WORK_LOCATION = "//div[@id='requestNavPanel']/span[contains(@ng-if,'AlternateWorkLocation')]"
SM_BULK_NAVIGATION_EMPLOYEE_PROFILE = "//div[@id='requestNavPanel']/span[contains(@ng-if,'EmployeeProfile')]"
# Dynamic Locator Templates for Update Locator With Dynamic Values
REQUEST_CALENDAR_PAGE_ASSOCIATE_NAME_INPUT = (
    "xpath=//div[normalize-space(@title)=normalize-space('{ASSOCIATE_NAME}')]"
)
REQUEST_CALENDAR_PAGE_REASON_OPTION = "//a[starts-with(normalize-space(text()), '{REASON_TYPE}')]"
REQUEST_CALENDAR_PAGE_STATUS_OPTION = "(//*[contains(normalize-space(text()), 'Status')]/following::*[contains(normalize-space(text()), '{REQUEST_STATUS}')])[1]"
REQUEST_CALENDAR_PAGE_FILTER_STATUS_OPTION = "(//td[contains(normalize-space(text()), 'Request Status')]/following::td//*[contains(normalize-space(text()), '{REQUEST_STATUS}')])[1]"
REQUEST_CALENDAR_PAGE_FILTER_TYPE_OPTION = "(//td[normalize-space()='Request Type']/following::div[1]//*[contains(normalize-space(text()), '{REQUEST_TYPE}')])[1]"
REQUEST_CALENDAR_PAGE_REQUESTS_COUNT_DAY_OFF = (
    "//div[(starts-with(@id,'DO')) and contains(@aria-label,'{REQUEST_STATUS}')]"
)
REQUEST_CALENDAR_PAGE_REQUESTS_COUNT_TIME_OFF = (
    "//div[(starts-with(@id,'TO')) and contains(@aria-label,'{REQUEST_STATUS}')]"
)
REQUEST_CALENDAR_PAGE_REQUESTS_COUNT_AVAILABILITY = (
    "//div[(starts-with(@id,'AB')) and contains(@aria-label,'{REQUEST_STATUS}')]"
)
REQUEST_CALENDAR_PAGE_WEEK_HOURS_XPATH = "//span[@ng-if='weekHours[{XPATH_DAY_INDEX}]']"
REQUEST_CALENDAR_PAGE_ROTATION_OPTION = "//a[text()='{ROTATION_TYPE}']"
REQUEST_CALENDAR_PAGE_AVAILABILITY_REASON_OPTION = (
    "//a[contains(text(),'{REASON_TYPE}')]"
)
REQUEST_CALENDAR_PAGE_ALL_REQUESTS = "(//table[contains(@class,'request-block')][contains(@aria-label,'{ASSOCIATE_NAME}')]//span[contains(@class,'requestType')])[1]"

# Availability input field locators
REQUEST_CALENDAR_PAGE_AVAILABILITY_START_INPUT = (
    "//input[@id='{ROTATION_VALUE}start0{DAY_NUMBER}{ROW_NUMBER}']"
)
REQUEST_CALENDAR_PAGE_AVAILABILITY_DURATION_INPUT = (
    "//input[@id='{ROTATION_VALUE}duration0{DAY_NUMBER}{ROW_NUMBER}']"
)
REQUEST_CALENDAR_PAGE_AVAILABILITY_HOURS_TEXT = "//a[text()='Availability Hours']"

# Day off request locators
REQUEST_CALENDAR_PAGE_DAY_OFF_REQUEST_TEMPLATE = "//div[@id='DO_{REQUEST_NO}']"
REQUEST_CALENDAR_PAGE_SM_DAY_OFF_REQUEST_LOCATOR = "(//table[contains(@aria-label, '{ASSOCIATE_NAME}') and contains(@aria-label,'{REASON_TYPE}') and contains(@aria-label,'{START_FORMATTED}') and contains(@aria-label,'{REQUEST_STATUS}')] | //div[contains(@aria-label, '{ASSOCIATE_NAME}') and contains(@aria-label,'{REASON_TYPE}') and contains(@aria-label,'{START_FORMATTED}') and contains(@aria-label,'{REQUEST_STATUS}')])[1]"
REQUEST_CALENDAR_PAGE_SM_DAY_OFF_REQUEST_LINE_VIEW_LOCATOR = "//tr[contains(@aria-label,'{ASSOCIATE_NAME}') and contains(@aria-label,'{START_FORMATTED}') and contains(@aria-label,'{END_FORMATTED}') and contains(@aria-label,'{REQUEST_STATUS}')]"
REQUEST_CALENDAR_PAGE_REQUEST_EXISTS_LOCATOR = "//table[contains(@aria-label,'{ASSOCIATE_NAME}') and contains(@aria-label,'{START_FORMATTED}')]"
REQUEST_CALENDAR_PAGE_DAY_OFF_CHECKBOX_LOCATOR = "//input[@type='checkbox' and contains(@aria-label,'{FIRST_NAME}, {LAST_NAME}') and contains(@aria-label,'{REASON_TYPE}') and contains(@aria-label,'{START_FORMATTED}')]"
REQUEST_CALENDAR_PAGE_DAY_OFF_REQUESTS = "(//table[contains(@class,'request-block')][contains(@aria-label,'{ASSOCIATE_NAME}')]//span[@aria-label='Day Off'])[1]"
REQUEST_CALENDAR_PAGE_DAY_OFF_MY_WORK_NOTIFICATION = "//span[contains(text(), 'DayOff')]/parent::div/following-sibling::div//span[contains(text(), '{DATE}')]"
REQUEST_CALENDAR_PAGE_DAY_OFF_MY_WORK_NEXT_WEEK = (
    "//button[@id='date-selection-next-arrow']"
)

# Time off request locators
REQUEST_CALENDAR_PAGE_SM_TIME_OFF_REQUEST_LOCATOR = "//table[contains(@aria-label, '{FIRST_NAME}') and contains(@aria-label, '{LAST_NAME}') and contains(normalize-space(@aria-label), '{REQUEST_REASON}') and contains(normalize-space(@aria-label), '{FORMATTED_DATE}') and contains(normalize-space(@aria-label), '{START_TIME}') and contains(normalize-space(@aria-label), '{END_TIME}') and contains(normalize-space(@aria-label), '{STATUS}')]"
REQUEST_CALENDAR_PAGE_SM_TIME_OFF_REQUEST_LINE_VIEW_LOCATOR = "//tr[contains(@aria-label,'{ASSOCIATE_NAME}') and contains(@aria-label,'{START_FORMATTED}') and contains(@aria-label,'{START_TIME}') and contains(@aria-label,'{END_TIME}') and contains(@aria-label,'{REQUEST_STATUS}')]"
REQUEST_CALENDAR_PAGE_TIME_OFF_CHECKBOX_LOCATOR = "//input[@type='checkbox' and contains(@aria-label,'{FIRST_NAME}, {LAST_NAME}') and contains(@aria-label,'{REASON_TYPE}') and contains(@aria-label,'{FORMATTED_DATE}') and contains(@aria-label,'{START_TIME}') and contains(@aria-label,'{END_TIME}')]"
REQUEST_CALENDAR_PAGE_SM_AVAILABILITY_REQUEST_LOCATOR = "//table[contains(@aria-label,'{FIRST_NAME}') and contains(@aria-label,'{LAST_NAME}') and contains(@aria-label,'{REQUEST_REASON}') and contains(@aria-label,'{FORMATTED_DATE}') and contains(@aria-label,'{STATUS}')]"
REQUEST_CALENDAR_PAGE_SM_AVAILABILITY_REQUEST_LINE_VIEW_LOCATOR = "//tr[contains(@aria-label,'{ASSOCIATE_NAME}') and contains(@aria-label,'{REASON}') and contains(@aria-label,'{START_FORMATTED}') and contains(@aria-label,'{REQUEST_STATUS}')]"

# Dynamic locator templates
REQUEST_CALENDAR_PAGE_APPROVED_REQUEST_LOCATOR = (
    "//span[@aria-label='Approved Request']"
)

# Bulk request selection locators
REQUEST_CALENDAR_PAGE_VIEW_ALL_BY_REQUEST_TYPE = "(//span[contains(normalize-space(text()),'{REQUEST_TYPE}')]/following-sibling::span/a[contains(normalize-space(),'View All')])[1]"
REQUEST_CALENDAR_PAGE_REQUEST_CHECKBOX_DYNAMIC = "(//tr[contains(@aria-label,'{ASSOCIATE_NAME}') and contains(@aria-label,'{DATE}')]/descendant::input[@id='reqCalCheckbox'])[1]"
REQUEST_CALENDAR_PAGE_AVAILABILITY_CHECKBOX_DYNAMIC = "(//tr[contains(@aria-label,'{ASSOCIATE_NAME}')]/descendant::input[@id='reqCalCheckbox'])[1]"
REQUEST_CALENDAR_PAGE_GROUP_BY_BUTTON = (
    "(//a[contains(normalize-space(),'Group By')])[1]"
)

REQUEST_CALENDAR_PAGE_AVAILABILITY_CATEGORY_RADIO = (
    "//label//div[contains(@aria-label,'Category {CATEGORY}')]"
)
REQUEST_CALENDAR_PAGE_AVAILABILITY_STATUS_OPTION = "//ul[contains(@class,'dropdownBorder scrollBarEmpStatusDropdown')]//li//a[contains(text(),'{STATUS}')]"
REQUEST_CALENDAR_PAGE_DAY_REQUEST = ".rflxcsspa-form-table[aria-label*='{EMP_NAME}'][aria-label*='Request'][aria-label*='{START_DATE}']"
REQUEST_CALENDAR_PAGE_SELECTED_VIEW_WEEKLY = "//span[contains(@class,'ws-iconWeek') and contains(@class, 'selectedViewType')]"
REQUEST_CALENDAR_PAGE_WEEKLY_VIEW_BUTTON = "//span[contains(@class,'ws-iconWeek')]"
REQUEST_CALENDAR_PAGE_HEADER_ICONS = "//div[contains(@class,'header-icons-flex')]"
REQUEST_CALENDAR_PAGE_ADD_DAYOFF_PAGE_CLOSE_BTN = "span.ws-iconXclose[ng-click*='showHideEmployeeDetails']"
REQUEST_CALENDAR_PAGE_ADD_AVAILABILITY_PAGE_HOURS_TAB_ACTIVE = "div#avr_tabIndex.active-tab"
