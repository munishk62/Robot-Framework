TIMECARD_PAGE_ASSOCIATE_NAME = "//span[contains(@class,'ui-selectmenu-text') and contains(text(),'{associate_id}')]"
TIMECARD_PAGE_EXPORT_BUTTON = "//div[@title='Export' and not(@style)]"
TIMECARD_PAGE_ADD_BREAK_ICON = "//div[@title='Add Break']"
TIMECARD_PAGE_WEEK_NAVIGATOR = "#weekend-button > .ui-selectmenu-text"
TIMECARD_PAGE_SCHEDULE_SHIFT_DATES = "//span[1][@id='gridboxDiv']//tr[contains(@class,'_light')]/td[1][contains(text(),'/')]"
TIMECARD_PAGE_ADD_SHIFT_ICON = "//div[@title='Add Shift']/img/following-sibling::div"
TIMECARD_PAGE_ADD_SHIFT_WINDOW = "//div[@id='shiftAdd']"
TIMECARD_PAGE_SHIFT_START_DATE_ICON = "//img[@id='pDate']"
TIMECARD_PAGE_SHIFT_DAY_CURRENT_WEEK = (
    "//div[@id='ui-datepicker-div']"
    "//table[contains(@class,'ui-datepicker-calendar')]"
    "//td/a[normalize-space(text())='{TEMP_DAY}']"
)
TIMECARD_PAGE_SHIFT_DAY_NEXT_MONTH = (
    "//div[@id='ui-datepicker-div']"
    "//a[contains(@class,'ui-datepicker-next')]"
)
TIMECARD_PAGE_SHIFT_DAY_PREV_MONTH = (
    "//td[@class='button nav' and contains(text(),'‹')]"
)
TIMECARD_PAGE_SHIFT_END_DATE_ICON = "//img[@id='eDate']"
TIMECARD_PAGE_SHIFT_START_TIME = "//input[@id='txtAddShiftStartTime']"
TIMECARD_PAGE_SHIFT_END_TIME = "//input[@id='txtAddShiftEndTime']"
TIMECARD_PAGE_ADD_SHIFT_LOCATION = "#shUnit"
TIMECARD_PAGE_ADD_SHIFT_DEPT = "#shDept"
TIMECARD_PAGE_ADD_SHIFT_DEPT_FIRST_OPTION = "(//select[@id='shDept']/option)[1]"
TIMECARD_PAGE_ADD_SHIFT_ACTIVITY_CODE = "#shActivityCode"
TIMECARD_PAGE_ADD_SHIFT_ACTIVITY_CODE_MANDATORY_STAR = "//select[@id='shActivityCode']/ancestor::tr//img[@class='v5-rws-redstar']"
TIMECARD_PAGE_ADD_SHIFT_ACTIVITY_CODE_FIRST_OPTION = "(//select[@id='shActivityCode']/option)[1]"
TIMECARD_PAGE_SHIFT_REASON_CODE_DROPDOWN = "#shReasonCode"
TIMECARD_PAGE_ADD_SHIFT_BUTTON = "#addShiftBtnWid"
TIMECARD_PAGE_DELETE_SHIFT = "div[title='Remove Shift'] div"
TIMECARD_PAGE_MESSAGE_ALERT = "//div[@class='info_message_text message_area']"
TIMECARD_PAGE_ERROR_MESSAGE_ALERT = "//div[contains(@class,'error_bg_sign_area')]//following-sibling::div[contains(@class,'info_message_text')]"
TIMECARD_PAGE_ADD_BREAK_START_DATE_ICON = "//img[@id='bSDate']"
TIMECARD_PAGE_ADD_BREAK_REASON_CODE_DROPDOWN = "#bReasonCode"
TIMECARD_PAGE_ADD_BREAK_START_TIME = "#txtAddBreakStartTime"
TIMECARD_PAGE_ADD_BREAK_END_TIME = "#txtAddBreakEndTime"
TIMECARD_PAGE_ADD_BREAK_BUTTON = "#addMealDataId"
TIMECARD_PAGE_SHIFT_REQUEST_WEEK = "(//div[@id='gridbox']//tr[td[contains(text(),'{TEMP_WEEK}')] and td[5][contains(text(),':') or contains(@style,'border:')]]/td[1])[1]"
TIMECARD_PAGE_SHIFT_REQUEST_ACTUAL_WEEK = (
    "//div[@id='gridbox']//tr[td[contains(.,'{TEMP_WEEK}')]]/td[5]"
)
TIMECARD_PAGE_EDIT_BREAK_DEPARTMENT_WEEK = "//div[@id='gridbox']//td[contains(., '{TEMP_WEEK}')]/ancestor::tr/following-sibling::tr[1]/td[11]/a"
TIMECARD_PAGE_EDIT_BREAK_REASON_CODE_WEEK = "//div[@id='gridbox']//td[contains(., '{TEMP_WEEK}')]/ancestor::tr/following-sibling::tr[1]/td[15]/a"
TIMECARD_PAGE_CHANGE_LOCATION_POPUP = "//div/span[@id='ui-id-3']"
TIMECARD_PAGE_SHIFT_EDIT_DEPT_DROPDOWN = "#chgLocDept"
TIMECARD_PAGE_SHIFT_EDIT_REASON_CODE_DROPDOWN = "#chLocReasonCode"
TIMECARD_PAGE_SHIFT_EDIT_CHANGE_LOCATION_BTN = (
    "//div[@id='chgLoc']//input[@class='positive-button']"
)
TIMECARD_PAGE_BREAK_END_SHIFT_WEEK_ROW = "//div[@id='gridbox']//td[contains(., '{TEMP_WEEK}')]/ancestor::tr/following-sibling::tr[2]/td[5][contains(text(),'{END_TIME}')]"
TIMECARD_PAGE_BREAK_START_SHIFT_WEEK_ROW = "//td[contains(., '{TEMP_WEEK}')]/ancestor::tr/following-sibling::tr[2]/td[5][contains(text(),':')]/parent::tr/preceding-sibling::tr[1]//td[1]"
TIMECARD_PAGE_DELETE_BREAK = "//div[@title='Remove Break']//div"
TIMECARD_PAGE_SHIFT_DELETE_REASON_CODE = "#delRCode"
TIMECARD_PAGE_SHIFT_DELETE_YES_BTN = "#delRCodeDiv .positive-button"
TIMECARD_PAGE_SHIFT_DELETE_CONFIRMATION_YES = (
    "//input[@id='confirmRCodeDeleteYId' and @value='Yes']"
)
TIMECARD_PAGE_PREVIOUS_WEEK_BTN = "#leftMove"
TIMECARD_PAGE_ACCRUALBALANCE_BTN = "//div[@title='Accrual Balances' and not(@style)]"
TIMECARD_PAGE_ACCRUALBALANCE_TAB = (
    "//div[@id='accrualBalances']/div[2]/div/table/tbody/tr[1]/td"
)
TIMECARD_PAGE_ACCRUALBALANCE_CLOSE = "//div[@id='accrualBalances']/div[1]/div/a[2]"
TIMECARD_PAGE_ACCRUALBALANCE_TAB_ACCRUAL_TYPE = (
    "//div[@id='accrualBalances']/div[2]//tbody/tr[2]/td//table//td[1]/div"
)
TIMECARD_PAGE_ACCRUALBALANCE_TAB_BAL_DATE = (
    "//div[@id='accrualBalances']/div[2]//tbody/tr[2]/td//table//td[2]/div"
)
TIMECARD_PAGE_ACCRUALBALANCE_TAB_ACTUAL_BAL = (
    "//div[@id='accrualBalances']/div[2]//tbody/tr[2]/td//table//td[3]//*[normalize-space(text())][1]"
)
TIMECARD_PAGE_ACCRUALBALANCE_TAB_UNIT = (
    "//div[@id='accrualBalances']/div[2]//tbody/tr[2]/td//table//td[4]//*[normalize-space(text())][1]"
)
TIMECARD_PAGE_ACCRUALBALANCE_VALUE = (
    "//*[@id='gridbox_accrualBalances']/div[2]/table/tbody/tr//td[normalize-space()='{ACCRUAL_TYPE}']//following-sibling::td[2]"
)
TIMECARD_PAGE_ADD_PUNCH_BUTTON = "//div[contains(text(),'+ Punch')]"
TIMECARD_PAGE_PUNCH_DIALOG_BOX = "#punchAdd"
TIMECARD_PAGE_PUNCH_DATE_ICON = "#puDate"
TIMECARD_PAGE_PUNCH_TRANSACTION_TYPE = "#txntype"
TIMECARD_PAGE_PUNCH_TIME = "#txtAddPunchTime"
TIMECARD_PAGE_ADD_PUNCH_ACTIVITY_CODE = "#shActivityCode"
TIMECARD_PAGE_PUNCH_REASON = "#pReasonCode"
TIMECARD_PAGE_PUNCH_ADD_PUNCH = "#addPunchDisplayDataId"
TIMECARD_PAGE_PUNCH_SHOWN_START_TIME = "(//div[@id='gridbox']/div[2]/table/tbody/tr/td[contains(text(),'{TEMP_date}')]/../td[contains(text(),'{TEMP_time}')])[1]"
TIMECARD_PAGE_PUNCH_FOLLOWING_ACTUAL = "(//div[@id='gridbox']/div[2]/table/tbody/tr/td[contains(text(),'{TEMP_date}')]/../following-sibling::tr/td[contains(text(),'{TEMP_time}')])[1]"
TIMECARD_PAGE_PUNCH_DELETE_BTN = (
    "//div[contains(text(),'- Punch')] | //img[@title='Delete']"
)
TIMECARD_PAGE_PUNCH_DELETE_DIALOG_BOX = (
    "//div[@class='ui-dialog-titlebar'] | //span[normalize-space()='Reason Code']"
)
TIMECARD_PAGE_PUNCH_DELETE_REASON = "#delRCode"
TIMECARD_PAGE_NOTIFICATION_SUCCESS_TOAST = (
    "//div[@class='info_message_text message_area' and contains(text(),'success')]"
)
TIMECARD_PAGE_ADD_PUNCH_REASON_CODE_DROPDOWN = "#pReasonCode"
TIMECARD_PAGE_ADD_PUNCH_ACTIVITY_CODE_DROPDOWN = "//select[@id='pActivityCode']"
TIMECARD_PAGE_ADD_PUNCH_ACTIVITY_CODE_ROW = "//tr[@id='activityCodeRow']"
TIMECARD_PAGE_ADD_PUNCH_ACTIVITY_CODE_ASTERICS = "//tr[@data-testid='timecard-row-activity-code']/td/img"
TIMECARD_PAGE_ADD_PUNCH_START_TIME = "#txtAddPunchTime"
TIMECARD_PAGE_PUNCH_START_SHIFT_WEEK_ROW = "(//div[@id='gridbox']//td[normalize-space()='{TEMP_WEEK}']/following::td[normalize-space()='{PUNCH_TIME}'][@align='center'][1] | //div[@id='gridbox']//td[normalize-space()='{TEMP_WEEK}']/following-sibling::td[normalize-space()='{PUNCH_TIME}'][@align='center'][1])[1]"
TIMECARD_PAGE_PUNCH_END_SHIFT_WEEK_ROW = "(//div[@id='gridbox']//td[normalize-space()='{TEMP_WEEK}']/following::tr/td[normalize-space()='{PUNCH_TIME}'][@align='center'] | //div[@id='gridbox']//td[normalize-space()='{TEMP_WEEK}']/following::td[@title='{PUNCH_TIME}'][@align='center'])[1]"
TIMECARD_PAGE_DELETE_PUNCH = "//div[@title='Remove Punch']//div"
TIMECARD_PAGE_EDIT_PUNCH_DEPARTMENT_WEEK = "(//div[@id='gridbox']//td[contains(., '{TEMP_WEEK}')]/ancestor::tr//following-sibling::td/a)[2]"
TIMECARD_PAGE_PUNCHES_ADD_PUNCH_BTN = "//input[@value='Add Punch']"
TIMECARD_PAGE_ADD_LUNCH_REASON_CODE_DROPDOWN = "#mReasonCode"
TIMECARD_PAGE_ADD_LUNCH_START_TIME = "#txtAddMealStartTime"
TIMECARD_PAGE_ADD_LUNCH_END_TIME = "#txtAddMealEndTime"
TIMECARD_PAGE_LUNCH_ADD_LUNCH_BTN = "//input[@value='Add Meal']"
TIMECARD_PAGE_LUNCH_START_SHIFT_WEEK_ROW = "//td[text()='{TEMP_WEEK} ']/ancestor::tr/following::tr[contains(@class,'light')]/child::td[text()='{LUNCH_TIME}']"
TIMECARD_PAGE_DELETE_LUNCH = "//div[@title='Remove Lunch']//div"
TIMECARD_PAGE_WEEK_CALENDAR_LIST = "//div[contains(text(),'{WEEK_START_DATE}')]"
TIMECARD_LISTPAGE_CURRENT_WEEK_BUTTON = (
    "//span[@id='weekend-button']/span[@class='ui-selectmenu-text']"
)
TIMECARD_LISTPAGE_PREV_WEEK_BUTTON = "//*[@title='Previous Week']"
TIMECARD_PAGE_CROSS_WEEK_NOTIFICATION = "//div[contains(@class, 'ui-dialog') and contains(.//text(), 'portion of the shift falls outside')] | //div[contains(.//text(), 'portion will be moved to the next week')]"
TIMECARD_PAGE_CROSS_WEEK_NOTIFICATION_OK_BUTTON = "//div[contains(@class, 'ui-dialog')]//button[text()='OK'] | //button[@id='okButton']"
TIMECARD_PAGE_USER_ID_BUTTON = "//span[@id='UserId-button']"
TIMECARD_PAGE_EMPLOYEE_SEARCH_BOX = "//div[@class='tcard-userid-filter-wrap']/input"
TIMECARD_PAGE_SEARCHED_EMPLOYEE = "(//div[@role='option' and contains(text(), '{SEARCH_INPUT}')])[1]"
TIMECARD_PAGE_WEEK_NAVIGATOR_BAR = "//span[@class='ui-selectmenu-text' and contains(text(), '{EXPECTED_DATE}')]"
