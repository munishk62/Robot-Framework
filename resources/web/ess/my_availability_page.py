# ESS My Availability Page elements
ESS_MY_AVAILABILITY_PAGE_ADD_BUTTON = "#buttonAdd"
ESS_MY_AVAILABILITY_PAGE_SELECT_PREFERENCE = "//select[@id='availCd']"
ESS_MY_AVAILABILITY_PAGE_SELECT_YEAR = "//select[@id='cboYear']"
ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK = "//select[@id='cboWeek']"
ESS_MY_AVAILABILITY_PAGE_WEEK_START_INPUT = "//input[@id='cboWeek']"
ESS_MY_AVAILABILITY_PAGE_WEEK_END_INPUT = "//input[@id='endDate']"
ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER = "//input[@id='cboWeek']//following-sibling::img[@class='ui-datepicker-trigger']"
ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER_MONTH = "//select[@class='ui-datepicker-month']"
ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER_YEAR = "//select[@class='ui-datepicker-year']"
ESS_MY_AVAILABILITY_PAGE_SELECT_WEEK_START_DATEPICKER_DATE = "//table[@class='ui-datepicker-calendar']//td/a[text()='{DATE}']"
ESS_MY_AVAILABILITY_PAGE_AVAILABILITY_REASON = "//select[@id='reasonCd']"
ESS_MY_AVAILABILITY_PAGE_TOTALLY_AVAILABLE_BUTTON = (
    "//div[@id='BA_Div']//input[@id='makeTotallyAvailableBtnId']"
)
ESS_MY_AVAILABILITY_PAGE_NOT_AVAILABLE_CHECKBOX = (
    "((//tbody//input[@type='checkbox'])[{DAY}])[{ROTATION}]"
)
ESS_MY_AVAILABILITY_PAGE_NOT_AVAILABLE_CHECKBOX_CHECKED = "((//tbody//input[@type='checkbox'])[{DAY}])[{ROTATION}]//ancestor::td/following-sibling::td[1]//select[contains(@class,'avl-dropdown-field')][@disabled]"
ESS_MY_AVAILABILITY_PAGE_SELECT_DAY_START = "(//select[contains(@class,'avl-dropdown-field')][@id='BA*START_0{DAY}_{AVAIL}'])[{ROTATION}]"
ESS_MY_AVAILABILITY_PAGE_SELECT_DAY_END = "(//select[contains(@class,'avl-dropdown-field')][@id='BA*DURATION_0{DAY}_{AVAIL}'])[{ROTATION}]"
ESS_MY_AVAILABILITY_PAGE_AVAILABILITY_SUBMIT_BUTTON = "//input[@value='Submit']"
ESS_MY_AVAILABILITY_PAGE_SUCCESS_NOTIFICATION = (
    "(//div[contains(@class,'succ_bg')]//div[contains(@class,'info_message_text')])[1]"
)
ESS_MY_AVAILABILITY_PAGE_EFFECTIVE_DATE_LINK = (
    "//a[@id='effDate'][contains(text(),'{EFFECTIVE_DATE}')]"
)
ESS_MY_AVAILABILITY_PAGE_DELETE_BUTTON = "//input[@value='Delete']"
ESS_MY_AVAILABILITY_PAGE_PREVIOUS_BUTTON = "//input[@id='previousBtnId']"
ESS_MY_AVAILABILITY_PAGE_LOADING_ICON = "(//div[@id='dLoading'])[1]"
ESS_MY_AVAILABILITY_PAGE_FIRST_EFFECTIVE_DATE_LINK = "(//tr[@role='row']/td[@role='cell']/a[@id='effDate'])[1]"
ESS_MY_AVAILABILITY_PAGE_FILTER_ICON = "#filterIcon"
ESS_MY_AVAILABILITY_PAGE_ADD_AVAILABILITY_ICON = "#addAvailability"
ESS_MY_AVAILABILITY_PAGE_FILTER_MENU = "//div/button[@id='clearSearch']"