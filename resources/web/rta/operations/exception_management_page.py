EXCEPTION_MANAGEMENT_PAGE_FIRST_EMPLOYEE_ID = (
    "(//td[@class='empDetail']//tr/td/span[contains(@ng-if, 'showEmployeeId')])[1]"
)
EXCEPTION_MANAGEMENT_PAGE_CLOCK_ICON = "(//span[@ng-click='exceptionManagementCtrl.onTimecardBtnClick(associateDetail.personId)'])[1]"
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION = "span#displayPreference"
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_TYPE = (
    "label[for='Employee Type']"
)
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ICON = (
    "label[for='Employee Icon']"
)
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_ID = "label[for='Employee Id']"
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMPLOYEE_JOB_TITLE = (
    "label[for='Job Title']"
)
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_RESET = (
    "//button[contains(@ng-click,'resetDisplayPreference()')]"
)
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_APPLY = "button.btn.btn-primary"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ICON_SEARCH = "//img[@class='circular-img']"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_NAME = "//span[text()='{EMPLOYEE_NAME}']"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_WITH_ICON_SEARCH = (
    "//img[@class='circular-img']/following::span[contains(text(),'{EMPLOYEE_NAME}')]"
)
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_SEARCH = (
    "//span[@ng-if='exceptionManagementCtrl.appliedDisplayPreference.showEmployeeType']"
)
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_WITH_TYPE = "//span[contains(text(),'{EMPLOYEE_NAME}')]/ancestor::tr//span[contains(text(),'{EMPLOYEE_TYPE}')]"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ID_SEARCH = (
    "//span[@ng-if='exceptionManagementCtrl.appliedDisplayPreference.showEmployeeId']"
)
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_WITH_ID_SEARCH = "//span[contains(text(),'{EMPLOYEE_NAME}')]/ancestor::tr//span[contains(text(),'{EMPLOYEE_ID}')]"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_JOB_TITLE_SEARCH = (
    "//span[@ng-if='exceptionManagementCtrl.appliedDisplayPreference.showJobTitle']"
)
EXCEPTION_MANAGEMENT_PAGE_DISPLAYED_RECORDS = "//tr[@class='empShiftRow']"
EXCEPTION_MANAGEMENT_PAGE_PRINT_ICON = "span[ng-if='::exceptionManagementCtrl.constants.permissions.display.exportAsPrint']"
EXCEPTION_MANAGEMENT_PAGE_SUMMARY_REPORT_RECORDS = "//td[contains(@class,'associate')]"
EXCEPTION_MANAGEMENT_PAGE_TAB_LABEL = (
    "//*[@id='mainContainer']/div[2]/div/table/tbody/tr/td[1]/span[2]"
)
EXCEPTION_MANAGEMENT_PAGE_LEGEND_ICON = "//img[@title='Legend']"
EXCEPTION_MANAGEMENT_PAGE_CLOSE_LEGENDS = "//span[@ng-click='legendPopUpCtrl.close()']"
EXCEPTION_MANAGEMENT_PAGE_LEGEND_TAB_LABEL = (
    "//div[@aria-describedby='legendDiv']/div/span[text()='Legend']"
)
EXCEPTION_MANAGEMENT_TIMECARD_PAGE_LEGEND_LABEL = "//div[@id='legendDiv']"
EXCEPTION_MANAGEMENT_PAGE_WEEKEND_LABEL_ON_TIMECARD_PAGE = (
    "//*[@id='weekend-button']/span[2]"
)
EXCEPTION_MANAGEMENT_PAGE_NEXT_WEEK_TIMECARD = "#rightMove"
EXCEPTION_MANAGEMENT_PAGE_PREVIOUS_WEEK_TIMECARD = "#leftMove"
EXCEPTION_MANAGEMENT_PAGE_PAY_STATISTICS_TABS = (
    "(//span[contains(@class,'ws-m-r-100')])[{TAB_INDEX}]"
)
EXCEPTION_MANAGEMENT_PAGE_PAY_TOTAL_HOURS = "//td[@class='totalContainer ws-p-4']"
EXCEPTION_MANAGEMENT_PAGE_PAY_STATISTICS_HOURS = (
    "(//td/span[@class='statisticsValue'])[1]"
)
EXCEPTION_MANAGEMENT_PAGE_SCHEDULE_DATES = "//div[@id='gridbox' or @id='sppaybox']//tbody/tr[not(contains(@style, 'display: none')) and (contains(@class,'ev_light') or contains(@class,'odd_light')) ]/td[@align='left' and not(ancestor-or-self::*[contains(@style, 'display: none')]) and not(ancestor-or-self::*[contains(@style, 'visibility:hidden')]) and string-length(normalize-space(text())) > 7 and normalize-space(text()) != 'Unaccepted Punches' ][1]"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_BUTTON = "//img[contains(@src,'Shift')]/following-sibling::div[contains(text(),'+ ')] | //div[contains(text(),'+ Shift')] "
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_POPUP = "id=shiftAdd"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_CALENDAR_ICON = "#pDate"
EXCEPTION_MANAGEMENT_PAGE_NO_OF_DAYS_IN_CURRENT_WEEK = (
    "(//td[contains(@class,'day false')]/..)[1]/td[contains(@class,'day false')]"
)
EXCEPTION_MANAGEMENT_PAGE_NAV_NEXT_WEEK = "//td[@colspan='1' and contains(text(), '›')]"
EXCEPTION_MANAGEMENT_PAGE_NAV_PRE_WEEK = "//td[@colspan='1' and contains(text(), '‹')]"
EXCEPTION_MANAGEMENT_PAGE_CAL_POP_UP = "//tr[@class='daynames']"
EXCEPTION_MANAGEMENT_PAGE_SHIFT_DATE_ON_CALENDAR = (
    "//div[@id='ui-datepicker-div']"
    "//table[contains(@class,'ui-datepicker-calendar')]"
    "//td/a[normalize-space(text())='{SHIFT_DATE}']"
)
EXCEPTION_MANAGEMENT_PAGE_SHIFT_FROM_DATE_TXT_BOX_ON_POPUP = "#fromDt"
EXCEPTION_MANAGEMENT_PAGE_PUNCH_FROM_DATE_TXT_BOX_ON_POPUP = "#pStDt"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_START_TIME = "#txtAddShiftStartTime"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_END_TIME = "#txtAddShiftEndTime"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_REASON_CODE = "#shReasonCode"
EXCEPTION_MANAGEMENT_PAGE_SHIFT_DELETE_REASON_CODE = "#delRCode"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_DEPT = "#shDept"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_ACTIVITY_CODE = "#shActivityCode"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_LOCATION = "#shUnit"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_BUTTON_ON_POPUP = "#addShiftBtnWid"
EXCEPTION_MANAGEMENT_PAGE_SAVE_SHIFT_BTN = "div.dhx_toolbar_btn:has(img:is([src*='TCSave.'],[style*='TCSave.']))"
EXCEPTION_MANAGEMENT_PAGE_CANCEL_SHIFT_BTN = "#cancelAddbtnIdG"
EXCEPTION_MANAGEMENT_PAGE_SHIFT_SAVED_SUCCESS_ALERT = (
    "//div[@class='succ_bg_sign_area']//following-sibling::div[1] | //div[@data-testid='rfx-alert-message-info-message-text']"
)
EXCEPTION_MANAGEMENT_PAGE_EXCEP_COUNT_COLUMN = "//div[@class='scheduleStatsUnitWeekRow']/table/tbody/tr/td/table/tbody/tr/td[@class='weekDayContainer'][{COL}]/span"
EXCEPTION_MANAGEMENT_PAGE_FIRST_UNSCHEDULED_WORK = "//*[@id='scheduledShiftContainerUIElement']/div[2]/div/div/div[2]/div[1]/div/table/tbody/tr/td[6]"
EXCEPTION_MANAGEMENT_PAGE_UNSCHEDULED_WORK = "//span[text()='{EMP_NAME}']//ancestor::td[3]//following-sibling::td[5]//div[1]//span"
EXCEPTION_MANAGEMENT_PAGE_UNSCHEDULED_ABSENCE = "//span[text()='{EMP_NAME}']//ancestor::td[3]//following-sibling::td[4]//div[1]//span"
EXCEPTION_MANAGEMENT_PAGE_WARNING_ICON = "//div[@id='gridbox']/div[2]/table/tbody/tr/td[contains(text(),'{SHIFT_DATE}')]/../td[contains(text(),'{SHIFT_TIME}')]/../td[7]"
EXCEPTION_MANAGEMENT_PAGE_SHIFT_DELETE_DATE = "(//div[@id='gridbox']//tr[td[contains(text(),'{SHIFT_DATE}')] and td[5][contains(text(),':') or contains(@style,'border:')]]/td[1])[1]"
EXCEPTION_MANAGEMENT_PAGE_SHIFT_DELETE_DATE_TIME = "//td[contains(text(),'{SHIFT_DATE}')]//following-sibling::td[contains(text(),'{SHIFT_TIME}') or contains(text(),'{ALT_SHIFT_TIME}')]//following-sibling::td/img[@class='v5-rta-img tcard-anchor-cursor']//parent::td//parent::tr/td[1]"
EXCEPTION_MANAGEMENT_PAGE_DELETE_SHIFT = "div[title='Remove Shift'] div"
EXCEPTION_MANAGEMENT_PAGE_SHIFT_DELETE_CONFIRMATION_YES = (
    "//input[@id='confirmRCodeDeleteYId' and @value]"
)
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_PT = "//span[@ng-if='exceptionManagementCtrl.appliedDisplayPreference.showEmployeeType'][normalize-space()='PT']"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE_FT = "//span[@ng-if='exceptionManagementCtrl.appliedDisplayPreference.showEmployeeType'][normalize-space()='FT']"
EXCEPTION_MANAGEMENT_PAGE_FILTER_EMPLOYEE_TYPE_FT = "label[for='F']"
EXCEPTION_MANAGEMENT_PAGE_FILTER_EMPLOYEE_TYPE_PT = "label[for='P']"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TYPE = "//span[normalize-space(text())='{NAME_STRIPPED}']/ancestor::tr//span[contains(@ng-if, 'showEmployeeType')]"
EXCEPTION_MANAGEMENT_PAGE_FILTER_ICON = "span#advanceFilter>span"
EXCEPTION_MANAGEMENT_PAGE_FILTER_CLEAR_BUTTON = "//button[contains(.,'Clear')]"
EXCEPTION_MANAGEMENT_PAGE_FILTER_FETCH_BUTTON = "//button[contains(.,'Fetch')]"
EXCEPTION_MANAGEMENT_PAGE_FILTER_APPLY_BUTTON = "//button[.='Apply']"
EXCEPTION_MANAGEMENT_PAGE_PDF_ICON = (
    "span[ng-if='::exceptionManagementCtrl.constants.permissions.display.exportAsPDF']"
)
EXCEPTION_MANAGEMENT_PAGE_NO_OF_ASSOCIATES = "(//span[@ng-click='exceptionManagementCtrl.onTimecardBtnClick(associateDetail.personId)'])"
EXCEPTION_MANAGEMENT_PAGE_RANDOM_CLOCK_ICON = "(//span[@ng-click='exceptionManagementCtrl.onTimecardBtnClick(associateDetail.personId)'])[{TEMP}]"
EXCEPTION_MANAGEMENT_PAGE_RANDOM_ASSOCIATE_ID = "(//span[@ng-click='exceptionManagementCtrl.onTimecardBtnClick(associateDetail.personId)'])[{TEMP}]/../preceding-sibling::td//td/span[contains(@ng-if, 'showEmployeeId')]"
EXCEPTION_MANAGEMENT_PAGE_IMPORTED_SHIFT_DATE_LBL = "(//div[@id='gridbox']/div[2]/table/tbody/tr/td[contains(text(),'{SHIFT_DATE}')])[1]"
EXCEPTION_MANAGEMENT_PAGE_FIRST_EMPLOYEE_NAME = (
    "(//span[@ng-click='exceptionManagementCtrl.onEmployeeClick(associateDetail)'])[1]"
)
EXCEPTION_MANAGEMENT_PAGE_FILTER_BOX = "//input[@placeholder='Filter By Employee']"
EXCEPTION_MANAGEMENT_PAGE_SECOND_EMPLOYEE_SHOWN = "(//span[@ng-click='exceptionManagementCtrl.onTimecardBtnClick(associateDetail.personId)'])[2]/../..//following-sibling::td/span[@class='pointer ws-fw-bold']"
EXCEPTION_MANAGEMENT_PAGE_FIRST_VIOLATION_COUNT = "//div[@id='scheduledShiftContainerUIElement']/div[2]/div/div[1]/div[2]/div[1]/div/table/tbody/tr/td[2]/div[1]/div/div/div/span"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_STAFF_GROUP = "#shJob,#shStaffGroup"
EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_BTN = "//div[@title='Add Special Pay']"
EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_BUTTON = "//div[contains(text(),'+ Spl pay')]"
EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_DATE = "//img[@id='spDate']"
EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_PAY_CODE = "#splPayCode"
EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_USAGE = "#splUsage"
EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_LOCATION = "#splUnit"
EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_DEPARTMENT = "#splDept"
EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_ON_DIALOGUE = "#addSplPay"
EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_REASON = "#splReason"
EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_DATE_TEXT_BOX = "#spStDt"
EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_CHARGE_LOC_TYPE = (
    "//input[@name='splocType'][{LOC_OPTION}]"
)
EXCEPTION_MANAGEMENT_PAGE_WEEK_TO_RAISE_SPECIAL_PAY_REQ = (
    "(//div[@id='sppaybox']//td[contains(.,'{SP_PAY_ADDED_DATE}')])[1]"
)
EXCEPTION_MANAGEMENT_PAGE_DELETE_SPECIAL_PAY = "div[title='Remove Special Pay'] div"
EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_DELETE_YES_BTN = (
    "//button[@class='btn btn-primary doAction']"
)
EXCEPTION_MANAGEMENT_PAGE_NOTIFICATION_SUCCESS = "div#info_message.succ_bg"
EXCEPTION_MANAGEMENT_PAGE_ACTUAL_DATES = "//div[@id='gridbox']/div[@class='objbox']//tbody/tr[not(contains(@style, 'display: none')) and (contains(@class,'ev_light') or contains(@class,'odd_light')) ]/td[@align='left' and not(ancestor-or-self::*[contains(@style, 'display: none')]) and not(ancestor-or-self::*[contains(@style, 'visibility:hidden')]) and string-length(normalize-space(text())) > 7 and normalize-space(text()) != 'Unaccepted Punches' ][1]"
EXCEPTION_MANAGEMENT_PAGE_SHIFT_ADD_DATE = "//div[@id='gridbox']//td[@align='left' and contains(text(), '{SHIFT_DATE}')]/following-sibling::td[4]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_TAB = "//div[@class='dhx_tabbar_row']/div[3]/span"
EXCEPTION_MANAGEMENT_PAGE_TIMECARD_TAB = "(//span[@id='activeTab'])[1]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DROP_DOWN = (
    "//iframe[@id='iframe_pay_results'] >>> //select[@id='viewSel']"
)
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_HOURS = "//iframe[@id='iframe_pay_results'] >>> (//td[contains(text(),'{SHIFT_DATE}')]/following-sibling::td[last()-4])[1]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_START_TIME = "//iframe[@id='iframe_pay_results'] >>> //div[@id='detailedView']//div[1]//td[text()='{SHIFT_DATE}']/following-sibling::td[1]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_END_TIME = "//iframe[@id='iframe_pay_results'] >>> //div[@id='detailedView']//div[1]//td[text()='{SHIFT_DATE}']/following-sibling::td[2]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_HOURS = "//iframe[@id='iframe_pay_results'] >>> //div[@id='detailedView']//div[1]//td[text()='{SHIFT_DATE}']/following-sibling::td[10]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_COST = "//iframe[@id='iframe_pay_results'] >>> //div[@id='detailedView']//div[1]//td[text()='{SHIFT_DATE}']/following-sibling::td[11]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_MUL = "//iframe[@id='iframe_pay_results'] >>> //div[@id='detailedView']//div[1]//td[text()='{SHIFT_DATE}']/following-sibling::td[13]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_DETAILED_VIEW_RATE = "//iframe[@id='iframe_pay_results'] >>> //div[@id='detailedView']//div[1]//td[text()='{SHIFT_DATE}']/following-sibling::td[14]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_JOB_CODE = "//iframe[@id='iframe_pay_results'] >>> //div[@id='summaryView']//td[text()='{SHIFT_DATE}']/following-sibling::td[last()-6]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_PAY_CATEGORY = "//iframe[@id='iframe_pay_results'] >>> //div[@id='summaryView']//td[text()='{SHIFT_DATE}']/following-sibling::td[last()-5]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_STORE = "//iframe[@id='iframe_pay_results'] >>> //div[@id='summaryView']//td[text()='{SHIFT_DATE}']/following-sibling::td[1]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_COST = "//iframe[@id='iframe_pay_results'] >>> //div[@id='summaryView']//td[text()='{SHIFT_DATE}']/following-sibling::td[last()-1]"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_NO_DATA_MSG = (
    "//iframe[@id='iframe_pay_results'] >>> //td[text()='No data to display.']"
)
EXCEPTION_MANAGEMENT_PAGE_SP_BY_DATE = (
    "//div[@id='sppaybox']//following::div//following::td[text()=' {SP_DATE} ']"
)
EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_SECTION = "//div[@id='sppayboxDiv']"
EXCEPTION_MANAGEMENT_PAGE_REVIEW_WARNINGS_BTN = "div#toolbar_zone img[src*='warning']"
EXCEPTION_MANAGEMENT_PAGE_EMP_NAME = (
    "span[id='UserId-button'] span[class='ui-selectmenu-text']"
)
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_ROW = (
    "iframe[id='iframe_pay_results'] >>> (//tr[@class='ev_light '])[1]"
)
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_TOTAL_PAY = "iframe[id='iframe_pay_results'] >>> //b[normalize-space()='Total']/../following-sibling::td/b"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_CLOCK_ICON = "//span[contains(text(), '{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr[contains(@class,'empShiftRow')]//span[contains(@class, 'ws-iconTimecard')]"
EXCEPTION_MANAGEMENT_PAGE_EMP_ROW = (
    "//td[@class='empDetail']//td/span[text()='{EMP_NAME}']"
)
EXCEPTION_MANAGEMENT_PAGE_BOTTOM_TAB = "//div[@id='employeeTabDetails']"
EXCEPTION_MANAGEMENT_PAGE_EMP_DETAILS_DEPARTMENT = "//td[@class='homeDepartment']"
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_DATE = (
    "//iframe[@id='iframe_pay_results'] >>> (//td[contains(text(),'{REQUEST_DAY}')])[1]"
)
EXCEPTION_MANAGEMENT_PAGE_PAY_RESULTS_SUMMARY_VIEW_PAY_CODE = "//iframe[@id='iframe_pay_results'] >>> (//td[contains(text(),'{REQUEST_DAY}')]/following-sibling::td[text()='{PAY_CODE}'])[1]"
EXCEPTION_MANAGEMENT_PAGE_CALENDAR_BUTTON = (
    "//span[contains(@ng-bind,'exceptionManagementCtrl.selectedDateUILabel')]"
)
EXCEPTION_MANAGEMENT_PAGE_CALENDAR_MONTH_NAVIGATION_LOCATOR = (
    "//div[@id='ui-datepicker-div']"
    "//a[contains(@class,'ui-datepicker-next')]"
)
# Punch-related page object variables
EXCEPTION_MANAGEMENT_PAGE_PUNCH_ADD_BTN = "//div[contains(@title, 'Add Punch')]"
EXCEPTION_MANAGEMENT_PAGE_PUNCH_DATE_ICON = "	//img[@id='puDate']"
EXCEPTION_MANAGEMENT_PAGE_PUNCH_TRANSACTION_TYPE = "//select[@id='txntype']"
EXCEPTION_MANAGEMENT_PAGE_ADD_LUNCH_BTN = "//div[contains(@title, 'Add Lunch')]"
EXCEPTION_MANAGEMENT_PAGE_LUNCH_DATE_ICON = "//img[@id='mSDate']"
EXCEPTION_MANAGEMENT_PAGE_SELECT_ASSOCIATE = "//td[.//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]]//span[contains(@class,'ws-iconTimecard')]"
EXCEPTION_MANAGEMENT_PAGE_ASSOCIATE_SEARCH_BOX = (
    "//input[@ng-model='exceptionManagementCtrl.filteredAssociate']"
)
EXCEPTION_MANAGEMENT_PAGE_LINK_TO_CLICK_EMPLOYEE = "//span[normalize-space(text())='{EMP_ID}']/ancestor::tr//span[@ng-click='exceptionManagementCtrl.onTimecardBtnClick(associateDetail.personId)']"
EXCEPTION_MANAGEMENT_PAGE_CALENDAR_LEFT_ARROW_FOR_CLOCK = "img#leftMove"
EXCEPTION_MANAGEMENT_PAGE_REMOVE_SHIFT_ICON = (
    "//div[@class='float_left']/div[@class='dhx_toolbar_btn def']/div[.='- Shift']"
)
EXCEPTION_MANAGEMENT_PAGE_DELETE_REASON_CODE = "select#delRCode"
EXCEPTION_MANAGEMENT_PAGE_DELETE_CONFIRMATION_BUTTON = "input#confirmRCodeDeleteYId"
EXCEPTION_MANAGEMENT_PAGE_NOTIFICATION_MESSAGE = (
    "#info_message.succ_bg"
)
EXCEPTION_MANAGEMENT_PAGE_TIMECARD_FIRST_SHIFT_INSTANCE = (
    "(//td[contains(text(),'{DAY}')])[1]"
)
EXCEPTION_MANAGEMENT_PAGE_WARNING_COUNT = "//span[text()='{EMP_NAME}']//ancestor::td[@class='nameContainer']//following-sibling::td[2]/div//span"
EXCEPTION_MANAGEMENT_PAGE_BOTTOM_TAB_CLOSE = (
    "//div[@class='otherAction ws-p-t-4 ws-p-r-10']//span[1]"
)
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_TIMECARD_ROW = "(//tr[contains(@class, '_light') and .//td[1][normalize-space()='{DATE}'] and .//td[5][string-length(normalize-space()) > 0 and (contains(translate(normalize-space(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'am') or contains(translate(normalize-space(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'pm') or (string-length(normalize-space()) >= 4 and contains(normalize-space(), ':')))] and .//td[@style='display: none;' and normalize-space()='Shift Start'] and .//img[contains(@src, 'TCShiftStart.png')] and .//td[10]//a[@class='tblrow-sp tcard-anchor-cursor' and string-length(normalize-space()) > 0]])[1]"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_DETAIL = "//td[.//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]]//td[@class='empDetail']"
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_STAFF_GROUP = (
    "//select[@id='staffGrpSelect']//option[@label='{STAFF_GROUP}']"
)
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_SELECT_ALL = (
    "label[for='selectAllFilteredAssociates']"
)
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_EMP_NAME = (
    "//div[@class='ws-checkbox']//label[text()='{EMP_NAME}']//parent::div"
)
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_REPORTEE_TYPE = (
    "(//label[@for='Reportee_Type'])[1]"
)
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_DIRECT_REPORTEE = "//td[@class='filters']//label[input[@value='D']]//span[@class='radiolabel']"
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_INDIRECT_REPORTEE = "//td[@class='filters']//label[input[@value='I']]//span[@class='radiolabel']"
EXCEPTION_MANAGEMENT_PAGE_DISPLAY_CONFIGURATION_MY_LOCATION_REPORTEE = "//td[@class='filters']//label[input[@value='N']]//span[@class='radiolabel']"
EXCEPTION_MANAGEMENT_PAGE_SPINNER = (
    "//span[@ng-show='exceptionManagementCtrl.spinnerMessage']"
)
EXCEPTION_MANAGEMENT_PAGE_SORT_PREFERENCE_ICON = "//span[@id='sortPreference']"
EXCEPTION_MANAGEMENT_PAGE_SORT_BY_FULL_TIMERS_FIRST_RADIO = (
    "//input[@type='radio' and @value='EMP_TYPE']"
)
EXCEPTION_MANAGEMENT_PAGE_SORT_BY_ALPHABETICAL_RADIO = (
    "//input[@type='radio' and @value='DISPLAY_NAME']"
)
EXCEPTION_MANAGEMENT_PAGE_SORT_PREFERENCE_APPLY_BTN = (
    "//button[contains(text(),'Apply')]"
)
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_NAME_LIST = (
    "//span[@ng-click='exceptionManagementCtrl.onEmployeeClick(associateDetail)']"
)
EXCEPTION_MANAGEMENT_PAGE_FILTER_RESET_BUTTON = (
    "//button[contains(@ng-click,'resetAssociateLookupFilter()')]"
)
EXCEPTION_MANAGEMENT_PAGE_DEPARTMENT_OPTION = (
    "//select[@id='deptSelect']//option[normalize-space(text())='{DEPT_NAME}']"
)
EXCEPTION_MANAGEMENT_PAGE_EMP_LIST = "//div[@class='empShiftRowContainer']"
EXCEPTION_MANAGEMENT_PAGE_FIRST_EMP_LIST = "(//div[@class='empShiftRowContainer'])[1]"
EXCEPTION_MANAGEMENT_PAGE_DEPARTMENT_NAME = (
    "(//td[@class='nameContainer pointer']//span)[1]"
)
EXCEPTION_MANAGEMENT_PAGE_ADD_SPECIAL_PAY_STAFF_GROUP = "#splShJob"
EXCEPTION_MANAGEMENT_PAGE_REPORTEE_TYPE_RADIO_BTN = "//span[@class='radiolabel' and contains(text(), '{TYPE}')]"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_ICON = "(//img[@class='circular-img'])[1]"
EXCEPTION_MANAGEMENT_PAGE_AD_FILTER_STAFF_GROUPS = "//select[@id='staffGrpSelect']/option"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_CLOSE_BTN = "#hsCloseIdM"
EXCEPTION_MANAGEMENT_PAGE_SHIFT_ACTUALS = "//div[@id='gridbox']//tr[(td/a)[last()]/../following-sibling::td[1][normalize-space()='{DATE}'] and td[5][contains(text(),':')] and td[4][normalize-space(string-length())<9]]"
EXCEPTION_MANAGEMENT_PAGE_SPECIAL_PAY_ADDED = "(//div[@id='sppaybox']//td[contains(.,'{SP_PAY_ADDED_DATE}')]/../td[5][string-length(normalize-space())>1] | //div[@id='sppaybox']//td[contains(.,'{SP_PAY_ADDED_DATE}')]/../td[6][string-length(normalize-space())>1])[1]"
EXCEPTION_MANAGEMENT_PAGE_EMPLOYEE_SEARCH_BOX = "//input[@ng-model='exceptionManagementCtrl.filteredAssociate']"
EXCEPTION_MANAGEMENT_PAGE_SEARCHED_EMPLOYEE = "(//li[@role='option']/a/strong[contains(text(), '{SEARCH_INPUT}')])[1]"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_SCHEDULED_TASK = "#shTask"
EXCEPTION_MANAGEMENT_PAGE_ADD_SHIFT_ACTIVITY_CODE_MANDATORY_STAR = "//select[@id='shActivityCode']/../preceding-sibling::td/img"