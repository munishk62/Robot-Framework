ROSTER_PAGE_FIRST_EMP_NAME = "(//div[@role='cell']/span[@tooltip-placement='right'])[1]"
ROSTER_PAGE_FIRST_EMP_ID = "(//div[@role='cell']/span[@tooltip-placement='right'])[2]"
ROSTER_PAGE_SUMMARY_DROPDOWN = "//div[@id='rosterSecondLvl']"
ROSTER_PAGE_BASIC_DETAILS_MENU = "//tr[@id='menuHeaderBasicDetails']"
ROSTER_PAGE_BASIC_EMP_NAME = "//input[@id='displayName']"
ROSTER_PAGE_BASIC_EMP_ID = "//input[@id='empID']"
ROSTER_PAGE_BASIC_EMP_DOJ = "//input[@id='dateOfHire']"
ROSTER_PAGE_LEAVE_REQUESTS_MENU = (
    "//td[@role='menuitem' and contains(@ng-click, 'ROSTER_LEAVE_REQUESTS')]"
)
ROSTER_PAGE_ADD_DAY_OFF_ICON = "//span[@id='dayOffHeaderAddId']"
ROSTER_PAGE_DAY_OFF_START_DATE = "//input[@id='empEffDate']"
ROSTER_PAGE_DAY_OFF_END_DATE = "//input[@id='empEndDate']"
ROSTER_PAGE_DAY_OFF_REASON_DROPDOWN = "//button[contains(@aria-label, 'Reason')]//span[@class='pe-7s-angle-down dropdown-carot']"
ROSTER_PAGE_DAY_OFF_STATUS_DROPDOWN = "//button[contains(@ng-disabled, 'gatedApprovalAllowed') and @type='button' and @data-toggle='dropdown']"
ROSTER_PAGE_DAY_OFF_HOLIDAY_HOURS = "//div[@role='cell'][1]/following-sibling::div[{DAY}]//input[@aria-label='Requested Hours']"
ROSTER_PAGE_DAY_OFF_SAVE_BTN = "//button[@aria-label='Save Day Off']"
ROSTER_PAGE_DAY_OFF_REASON_OPTION = "//a[contains(@class, 'dayOffSecondDropdown') and contains(text(), '{DAY_OFF_REASON_CODE}')]"
ROSTER_PAGE_NOTIFICATION_MSG = "//div[@class='rfx-notify-message ng-scope success']"
ROSTER_PAGE_DAY_OFF_STATUS_OPTION = "//div[@role='cell']//li[@role='cell']/a[contains(@class, 'customHover') and contains(text(), '{DAY_OFF_STATUS_CODE}')]"
ROSTER_PAGE_DAY_OFF_REQUEST_DAY = (
    "//div[@role='row']/div[@role='cell']/span[contains(text(), '{DAY_OFF_DATE}')]"
)
ROSTER_PAGE_DAY_OFF_DELETE_BTN = "//button[@aria-label='Delete Day Off']"
ROSTER_PAGE_DAY_OFF_OK_BTN = "//span/button[@id='okButton']"
ROSTER_PAGE_FILTER_ICON = "//span[contains(@ng-if,'showFilter')]"
ROSTER_PAGE_FILTER_FIRST_NAME_TXT = "//input[@id='filterDiv']"
ROSTER_PAGE_FILTER_ID_TXT = "//input[contains(@ng-model, 'employeeId')]"
ROSTER_PAGE_FILTER_ASSOCIATE_TYPE_DROPDOWN = (
    "//button[contains(@aria-label,'Select associate type')]"
)
ROSTER_PAGE_FILTER_ASSOCIATE_TYPE_DROPDOWN_NONE_SELECT = "(//td[normalize-space()='Associate Type']/following::span[@aria-label='Select None'])[1] | (//td[normalize-space()='Team Member Type']/following::span[@aria-label='Select None'])[1] | (//td[normalize-space()='Colleague Type']/following::span[@aria-label='Select None'])[1] | (//td[normalize-space()='Employee Type']/following::span[@aria-label='Select None'])[1]"
ROSTER_PAGE_FILTER_ASSOCIATE_TYPE_OPTION = (
    "//span[({ASSOCIATE_TYPE_XPATH})]"
)
ROSTER_PAGE_FILTER_STATUS_DROPDOWN = (
    "(//td[normalize-space()='Status']/following::div[@class='filterMultiselect'])[1]"
)
ROSTER_PAGE_FILTER_STATUS_DROPDOWN_NONE_SELECT = (
    "(//td[normalize-space()='Status']/following::span[@aria-label='Select None'])[1]"
)
ROSTER_PAGE_FILTER_STATUS_OPTION = "//span[contains(text(), '{STATUS}')]"
ROSTER_PAGE_FILTER_RESULT_NO_RECORDS_FOUND = (
    "//div[contains(text(),'No associates present')]"
)
ROSTER_PAGE_FILTER_STATUS_AS_DATE = "//span[contains(@ng-click, 'Ctrl.showStatusAsOfDatePicker')]"
ROSTER_PAGE_REPORTEE_DROPDOWN = "//td[contains(text(),'Reportee')]"
ROSTER_PAGE_FILTER_REPORTEE_TYPE_DIRECT = "//label[@id='directReporteeLabel']"
ROSTER_PAGE_FILTER_REPORTEE_TYPE_INDIRECT = "//label[@id='inDirectReporteeLabel']"
ROSTER_PAGE_FILTER_REPORTEE_TYPE_MY_LOCATION = "//label[@id='noneReporteeLabel']"
ROSTER_PAGE_FILTER_RESET_BTN = "//button[normalize-space()='Reset']"
ROSTER_PAGE_FILTER_APPLY_BTN = "//button[@type='button' and contains(@ng-click, 'applyListFilter')]"
ROSTER_PAGE_FILTERED_ASSOCIATE_ROW = (
    "(//div[contains(@aria-label, '{ASSOCIATE_NAME}')]/following::div[({ASSOCIATE_TYPE_XPATH})]/ancestor::div[contains(@class, 'customHoverList') and contains(@class, 'pointer')])[1]"
)
ROSTER_PAGE_SPINNER_ICON = "//div[@class='rfx-spinner ng-scope']/span[@role='alert']"
ROSTER_PAGE_TIME_OFF_REQUESTS_MENU = (
    "//td[@role='menuitem' and contains(@ng-click, 'ROSTER_TIME_OFF')]"
)
ROSTER_PAGE_ADD_TIME_OFF_ICON = "//span[@id='timeOffHeaderAddId']"
ROSTER_PAGE_TIME_OFF_DATE = "//input[@aria-label='Date']"
ROSTER_PAGE_TIME_OFF_START_TIME = "//input[@aria-label='Enter Start Time']"
ROSTER_PAGE_TIME_OFF_DURATION_DROPDOWN = "//button[@aria-label='Select Duration ']"
ROSTER_PAGE_TIME_OFF_REASON_DROPDOWN = "//button[contains(@aria-label, 'Reason')]//span[@class='pe-7s-angle-down dropdown-carot']"
ROSTER_PAGE_TIME_OFF_REASON = "//a[contains(@class, 'dayOffSecondDropdown') and contains(text(), '{TIME_OFF_REASON_CODE}')]"
ROSTER_PAGE_TIME_OFF_STATUS_DROPDOWN = "//button[contains(@ng-disabled, 'gatedApprovalAllowed') and @type='button' and @data-toggle='dropdown']"
ROSTER_PAGE_TIME_OFF_STATUS_CODE = (
    "//li[@role='button']/a[contains(text(), '{TIME_OFF_STATUS_CODE}')]"
)
ROSTER_PAGE_TIME_OFF_SAVE_BTN = "//button[@aria-label='Save Time Off']"
ROSTER_PAGE_LEAVE_DATES = (
    "//span[@id and @uib-tooltip and not(contains(@tooltip-placement, 'left'))]"
)
ROSTER_PAGE_TIME_OFF_REQUEST_DAY = (
    "//div[@role='row']/div[@role='cell']/span[contains(text(), '{TIME_OFF_DATE}')]"
)
ROSTER_PAGE_TIME_OFF_UPDATE_BTN = "//button[@aria-label='Update Time Off']"
ROSTER_PAGE_TIME_OFF_DELETE_BTN = "//button[@aria-label='Delete Time Off']"
ROSTER_PAGE_DAY_OFF_DELETE_OK_BTN = "//span/button[@id='okButton']"
ROSTER_PAGE_DAY_OFF_REASON = "//button[contains(@aria-label, 'Reason')]//span[@class='pe-7s-angle-down dropdown-carot']"
ROSTER_PAGE_TIME_OFF_DATES = "//div[@class]/span[@id and @class='ng-binding']"
# ROSTER_PAGE_EMP_SEARCH_BOX = "//input[@placeholder='Search by associate name']"
ROSTER_PAGE_EMP_SEARCH_BOX = "//input[@ng-model='filteredAssociates.displayName']"
ROSTER_PAGE_EMP_SEARCH_ICON = "//span[@uib-tooltip='Search']"
ROSTER_PAGE_RELEASE_TO_STORE_MENU = (
    "(//tr[contains(@ng-if, 'ROSTER_RELEASE')]/td[text()])[1]"
)
ROSTER_PAGE_ADD_RELEASE_TO_STORE_ICON = "//span[@id='releaseToStoreHeaderAddId']"
ROSTER_PAGE_RELEASE_TO_STORE_STORE_ASSIGNED_TO_DROPDOWN = (
    "//button[@id='unitId-multi-sel-btn']"
)
RELEASE_TO_STORE_STORE_ASSIGNED_TO_SEARCH_FIELD = (
    "(//input[@ng-model='searchFilter'])[1]"
)
RELEASE_TO_STORE_STORE_ASSIGNED_TO_STORE = "(//div[@role='option'])[1]"
ROSTER_PAGE_RELEASE_TO_STORE_ALL_DAYS_TOGGLE_BTN = (
    "//span[@ng-click='releaseToStoreCtrl.checkForDays()']"
)
ROSTER_PAGE_RELEASE_TO_STORE_REASON_DROPDOWN = "//button[@aria-label='Select Reason']"
ROSTER_PAGE_RELEASE_TO_STORE_RELEASE_REASON_OPTION = (
    "//button[@aria-label='Select Reason']//parent::div/ul/li[2]"
)
ROSTER_PAGE_RELEASE_TO_STORE_SPECIFIC_REASON_OPTION = (
"//button[@aria-label='Select Reason']//parent::div/ul//li//a[contains(text(),'{REASON}')]"
)
ROSTER_PAGE_RELEASE_TO_STORE_SAVE_BTN = "//button[@id='btSave']"
ROSTER_PAGE_RELEASE_TO_STORE_DELETE_BTN = "//span[@uib-tooltip='Delete']"
ROSTER_PAGE_RELEASE_TO_STORE_DELETE_OK_BTN = "//button[@id='okButton']"
ROSTER_PAGE_AVAILABILITY_REQUESTS_MENU = (
    "(//td[@role='menuitem' and contains(@ng-click, 'ROSTER_AVAILABILITY')])[1]"
)
ROSTER_PAGE_ADD_AVAILABILITY_ICON = "//span[@id='availabilityHeaderAddId']"
ROSTER_PAGE_AVAILABILITY_EFFECTIVE_WEEK = "//input[contains(@id,'addAvailability_eff')]"
ROSTER_PAGE_AVAILABILITY_STATUS_DROPDOWN = "//button[contains(@ng-disabled, 'isStatusDisabled ') and @type='button' and @data-toggle='dropdown']"
ROSTER_PAGE_AVAILABILITY_STATUS = "//a[normalize-space()='{AVAILABILITY_STATUS}']"
ROSTER_PAGE_AVAILABILITY_PERMANENT_CHECKBOX = "//div[@aria-label='Permanent Category']"
ROSTER_PAGE_AVAILABILITY_NEXT_BTN = (
    "//div/button[@type='button' and @set-focus='addAvailHours']"
)
ROSTER_PAGE_TOTALLY_AVAILABLE_LBL = "input[ng-click*='TotallyAvailable']"
ROSTER_PAGE_AVAILABILITY_REQUEST_EDIT_LINK = (
    "//div[contains(text(), '{AVAILABILITY_DATE}')]/preceding-sibling::div[@id]/span"
)
ROSTER_PAGE_AVAILABILITY_REQUEST_SAVE_BTN = "//button[normalize-space()='Submit']"
ROSTER_PAGE_AVAILABILITY_REQUEST_DELETE_BTN = "//div[contains(text(), '{AVAILABILITY_DATE}')]/following-sibling::div[@role='cell']//span[@role='button']"
ROSTER_PAGE_ASSOCIATE_ID = "(//span[normalize-space()='{ASSOCIATE_NAME}']//ancestor::div[@id and @role='row']/div/following-sibling::div[@id]/span)[1]"
ROSTER_PAGE_FILTER_ON_ICON = "//span[@class='ws-icon ws-iconFilterON' and not(contains(@style, 'display: none'))]"
ROSTER_PAGE_SELECT_ASSOCIATE = "//div[contains(@aria-label,'{FIRST_NAME}') and contains(@aria-label,'{LAST_NAME}')]"
ROSTER_PAGE_TIME_OFF_SELECT_DURATION = "//a[contains(text(), '{HRS} Hrs {MIN} Mins')]"
ROSTER_PAGE_TIME_OFF_ADD_COMMENT = "//textarea[contains(@aria-label,'Enter Request')]"
ROSTER_PAGE_RELEASE_TO_STORE_STAFF_GROUP_DROPDOWN = (
    "(//button[@id='staffGroupId-multi-sel-btn' or @id='logStaffGroupId-multi-sel-btn'])[1]"
)
ROSTER_PAGE_RELEASE_TO_STORE_STAFF_GROUP_FIRST_OPTION = (
    "(//div[@role='listbox']/div[1])[2]"
)
ROSTER_PAGE_RELEASE_TO_STORE_EFFECTIVE_DATE = (
    "//span/input[@ng-model='releaseToStoreCtrl.effDate']"
)
ROSTER_PAGE_AVAILABILITY_REASON_DROPDOWN = "//div[contains(@aria-label,'Reason')]"
ROSTER_AVAILABILITY_REASON_OPTION = "//a[contains(text(),'{REASON_TYPE}')]"
ROSTER_PAGE_AVAILABILITY_START_INPUT = (
    "//input[@id='{ROTATION_VALUE}start0{DAY_NUMBER}{ROW_NUMBER}']"
)
ROSTER_PAGE_AVAILABILITY_DURATION_INPUT = (
    "//input[@id='{ROTATION_VALUE}duration0{DAY_NUMBER}{ROW_NUMBER}']"
)
ROSTER_PAGE_AVAILABILITY_HOURS_TEXT = (
    "//span[contains(normalize-space(), 'Availability Hours')]"
)
ROSTER_PAGE_AVAILABILITY_MIN_WEEK_HOURS_INPUT = "//input[@name='inputValidatePatternMinWeekHrs']"
ROSTER_PAGE_AVAILABILITY_SELECTED_OPTION = "(//div[(@id='staffGroupId-multi-sel-options' or @id='logStaffGroupId-multi-sel-options')])[1]//div[@role='option' and @aria-selected='true']"
ROSTER_PAGE_AVAILABILITY_FLEX_CONTAINER = "(//div[@class='flex-basis-100-percent flex-row ws-align-items-center'])[1]"
ROSTER_PAGE_AVAILABILITY_HOURS_TAB = "//span[contains(@id, 'availabilityHours') and @role='tab']"
ROSTER_PAGE_AVAILABILITY_MIN_DAILY_HOURS_INPUT = "//input[@name='inputValidatePatternMinDailyHrs']"
ROSTER_PAGE_AVAILABILITY_SELECT_ROTATION_DROPDOWN = "//div[contains(@ng-if,'enableStaffRotation')]//button[contains(@data-toggle,'dropdown')]"
ROSTER_PAGE_AVAILABILITY_ROTATION_OPTION = "//div[contains(@ng-if,'enableStaffRotation')]//li//*[contains(text(),'{ROTATION_NUMBER}')]"