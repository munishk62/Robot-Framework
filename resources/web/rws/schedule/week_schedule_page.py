# Week Schedule Page elements
WEEK_SCHEDULE_SCHEDULE_ROWS = "//table[@role='presentation']//tr[@class='empShiftRow']"
WEEK_SCHEDULE_DAY_HEADER = (
    "//table[@class='gridHeaderContent']//tr/td[contains(@class, 'weekDayLabel')]"
)
WEEK_SCHEDULE_GRID_COLUMNS = (
    "(//table[@role='presentation']//tr[@class='empShiftRow'])[{ROW_NUM}]/td"
)
WEEK_SCHEDULE_GRID_ELEMENT = (
    "(//table[@role='presentation']//tr[@class='empShiftRow'])[{ROW_NUM}]/td[{COL_NUM}]"
)
WEEK_SCHEDULE_CURRENT_DAY_HEADER = (
    "(//tr/td[contains(@class, 'weekDayLabel')])[{COL_NUM}]"
)
WEEK_SCHEDULE_HOLIDAY_CELL = "((//table[@role='presentation']//tr[@class='empShiftRow'])[{TEMP_ROW}]/td[{TEMP_COL}]/div[not(contains(@class, 'dayOffTimeOffIndicator dayoff'))])[1]"
WEEK_SCHEDULE_SHIFT_START_TIME = "id=starTimeInput"
WEEK_SCHEDULE_SHIFT_END_TIME = "id=endTimeInput"
WEEK_SCHEDULE_ADD_SHIFT_ICON = "id=inlineAddShift"
WEEK_SCHEDULE_ADD_SHIFT_POPUP_ICON = "//span[@id='inlineAddShift']"
WEEK_SCHEDULE_EDIT_SHIFT_BUTTON = "#shiftEdit"
WEEK_SCHEDULE_TIME_PICKER_START_TIME = (
    "//input[@id='timePickerPop' and not(preceding::input[@id='timePickerPop'])]"
)
WEEK_SCHEDULE_TIME_PICKER_END_TIME = (
    "//input[@id='timePickerPop' and not(following::input[@id='timePickerPop'])]"
)
WEEK_SCHEDULE_EDIT_SAVE_BTN = "//button[@class='btn btn-primary btn-sm ']"
WEEK_SCHEDULE_UN_ALLOCATE_SHIFT_BTN = "//div[@id='shiftUnallocate']"
WEEK_SCHEDULE_DELETE_OK_BTN = "id=okButton"
WEEK_SCHEDULE_VACANT_CELL = "(//table[@role='presentation']//tr[@class='empShiftRow' and not(.//td[contains(@class, 'inactive')])])[{ROW_NUM}]/td[{COL_NUM}]"
WEEK_SCHEDULE_LEGENDS_ICON = ".ws-iconLegend"
WEEK_SCHEDULE_SHIFT_IMAGE = "(//*[@class='shiftImageSection'])[1]"
WEEK_SCHEDULE_ICONS_TAB = "[ng-click='legendPopUpCtrl.iconsView = true']"
WEEK_SCHEDULE_ICONS_VIEW_CONTAINER = ".ws-p-l-20"
WEEK_SCHEDULE_PRINT_ICON = "//span[@title='Print']/span"
WEEK_SCHEDULE_WEEKLY_SCHEDULE_SUMMARY = (
    "//div/span[contains(text(),'Weekly Schedule Summary')]"
)
WEEK_SCHEDULE_PDF_DOWNLOAD_ICON = "span[title='PDF']"
WEEK_SCHEDULE_WEEKLY_SUMMARY_PDF_LINK = (
    "//span[contains(text(),'Weekly Schedule Summary')]"
)
WEEK_SCHEDULE_WEEKLY_SCHEDULE_DETAIL_PDF_LINK = (
    "//span[contains(text(),'Weekly Schedule Detail')]"
)
WEEK_SCHEDULE_FIRST_ASSOCIATE_NAME = "//td[@class='empDetail']/div/span[contains(@class, 'assocNameContainer') and not(preceding::span[contains(@class, 'assocNameContainer')])]"
WEEK_SCHEDULE_WEEKLY_ASSOCIATE_SUMMARY_PDF_LINK = (
    "//span[contains(text(),'Weekly Associate Summary')]"
)
WEEK_SCHEDULE_PDF_REPORT_POPUP_NAME_TXT = "//input[@aria-label='Enter associate name']"
WEEK_SCHEDULE_PDF_REPORT_POPUP_DOWNLOAD_BTN = "button[aria-label='Download PDF file']"
WEEK_SCHEDULE_PDF_REPORT_POPUP_NAME_LNK = (
    "//a/strong[contains(text(),'{ASSOCIATE_NAME}')]"
)
WEEK_SCHEDULE_WEEKLY_ASSOCIATE_DETAIL_PDF_LINK = (
    "//span[contains(text(),'Weekly Associate Detail')]"
)
WEEK_SCHEDULE_BACKWARD_ARROW = "span.pointer.ws-icon.ws-iconArrowDateLeft"
WEEK_SCHEDULE_SELECTED_WEEK = "//span[text()='{WEEK}']"
WEEK_SCHEDULE_FORWARD_ARROW = "span.pointer.ws-icon.ws-iconArrowDateRight"
WEEK_SCHEDULE_SORT_PREFERENCE_ICON = ".ws-iconSort"
WEEK_SCHEDULE_SORT_PREFERENCE_TAB = (
    "//div[contains(@class, 'ws-bottom-tab') and contains(text(), 'Sort Preference')]"
)
WEEK_SCHEDULE_SORT_PREFERENCE_NONE_RADIO_BTN = "[for='unit']"
WEEK_SCHEDULE_SORT_APPLY_BTN = "[ng-click='scheduleCtrl.applySortPreference()']"
WEEK_SCHEDULE_GROUP_BY_HEADER = "(//div[@class='scheduleGroupStatsRow'])[1]"
WEEK_SCHEDULE_GROUP_BY_HEADER_TEXT = "(//emp-shift-row//parent::div//parent::div//parent::div/preceding-sibling::div//td[contains(@class,'nameContainer')]/span[contains(text(),'{HEADER_TEXT}')])[1]"
WEEK_SCHEDULE_SORT_PREFERENCE_DEPARTMENT_RADIO_BTN = "[for='department']"
WEEK_SCHEDULE_SORT_PREFERENCE_STAFF_GROUP_RADIO_BTN = "[for='staffGroup']"
WEEK_SCHEDULE_SORT_HIRE_DATE_RADIO_BTN = "[for='sort_HIRE_DATE']"
WEEK_SCHEDULE_SORT_PREFERENCE_WINDOW = "//div[@class='preferenceBody']"
WEEK_SCHEDULE_SORT_PREF_RESET = ".btn-secondary"
WEEK_SCHEDULE_PAGE_ADVANCED_FILTER_ICON = "#advanceFilter"
WEEK_SCHEDULE_PAGE_FILTER_SETTING_TAB = "//div[contains(@class,'scheduleAdvanceFilter')]//div[contains(@ng-click, 'Filters')][1]"
WEEK_SCHEDULE_PAGE_TASK_DROPDOWN_OPTION = (
    "(//select[@id='taskSelect']/option[normalize-space()='{TASK}'])[1]"
)
WEEK_SCHEDULE_PAGE_TASK_DROPDOWN_SELECT = "//select[@id='taskSelect']"
WEEK_SCHEDULE_PAGE_FETCH_BTN = (
    "[ng-click='scheduleCtrl.fetchAssociatesBasedOnFilter()']"
)
WEEK_SCHEDULE_PAGE_PLEASE_WAIT_SPINNER = (
    "div.rfx-spinner span[ng-style*='display:spinnerMessage?']"
)
WEEK_SCHEDULE_PAGE_FILTER_ON_ICON = (
    "span[ng-if*='isAdvanceFilterApplied'][class*='FilterON']"
)
WEEK_SCHEDULE_PAGE_EMP_ROW = "(//tr[@class='empShiftRow'])[1]"
WEEK_SCHEDULE_PAGE_NEXT_WEEK = "span.pointer.ws-icon.ws-iconArrowDateRight"
WEEK_SCHEDULE_NEXT_WEEK_ARROW = "//span[@aria-label='Next Week']"
WEEK_SCHEDULE_RELEASED_TO_STORE_MSG = "(//div[@class='releasedInfo' and contains(text(),'{RELEASED_TO_STORE}')])[{MSG_INDEX}]"
WEEK_SCHEDULE_EMPLOYEE_SEARCH_INPUT = "//input[@id='empFilterFocusId']"
WEEK_SCHEDULE_SEARCHED_EMPLOYEE = "//li[@role='option']/a"
WEEK_SCHEDULE_DISPLAY_PREFERENCE_ICON = ".ws-iconDisplayPrefs"
WEEK_SCHEDULE_DISPLAY_PREFERENCE_TAB = "//div[contains(@class, 'ws-bottom-tab') and contains(text(), 'Display Preference')]"
WEEK_SCHEDULE_DISPLAY_PREFERENCE_COLLEAGUE_PRIMARY_JOB = "[for='showPrimaryJob']"
WEEK_SCHEDULE_DISPLAY_PREFERENCE_COLLEAGUE_PRIMARY_JOB_INPUT = (
    "//label[@for='showPrimaryJob']//preceding-sibling::input"
)
WEEK_SCHEDULE_DISPLAY_PREFERENCE_DETAILED_VIEW = "[for='showDetailedView']"
WEEK_SCHEDULE_DISPLAY_PREFERENCE_DETAILED_VIEW_INPUT = (
    "//label[@for='showDetailedView']/preceding-sibling::input"
)
WEEK_SCHEDULE_DISPLAY_PREFERENCE_APPLY_BTN = (
    "//button[contains(@class,'btn btn-primary') and contains(text(), 'Apply')]"
)
WEEK_SCHEDULE_DETAILED_VIEW = (
    "(//div[@ng-if='scheduleCtrl.displayConfig.showDetailedView'])[1]"
)
WEEK_SCHEDULE_DISPLAY_PREFERENCE_RESET_BTN = ".btn-secondary"
WEEK_SCHEDULE_FIRST_SHIFT_START_TIME = (
    "(//div[contains(@class,'shiftBubble')]//span[contains(@class,'startTime')]//span)[1]"
)
WEEK_SCHEDULE_FIRST_SHIFT_END_TIME = "(//div[contains(@class,'shiftBubble')]//span[contains(@class,'startTime')]//following-sibling::span//span)[1]"
WEEK_SCHEDULE_FIRST_SHIFT_TASK_DETAILS = (
    "(//div[contains(@class,'shiftBubble')]//div[contains(@class,'taskDisplayContainer')])[1]"
)
WEEK_SCHEDULE_PLAN_STATUS = "//tr/td[@id='railRoad']/span"
WEEK_SCHEDULE_INITIAL_STATE = ".scheduleStatus > span"
WEEK_SCHEDULE_ACTION_DROPDOWN = (
    "[ng-click='scheduleCtrl.onOtherActionsClick =!scheduleCtrl.onOtherActionsClick ']"
)
WEEK_SCHEDULE_LOCK_SCHEDULE_OPTION = "//a[contains(@ng-if,'&& scheduleCtrl.constants.lockSchedulePermission')]"
WEEK_SCHEDULE_LOCKED_STATE = "//span[.='Locked']"
WEEK_SCHEDULE_UNPUBLISH_CURRENT = "//a[@ng-click='scheduleCtrl.renderScheduleActionUnPublish()']"
WEEK_SCHEDULE_OK_BTN = "id=okButton"
WEEK_SCHEDULE_UNPUBLISHED_STATE = "//div[@class='scheduleStatus']/span[.='Unpublished'] | //div[@class='scheduleStatus']/span[.='Pharmacist Published']"
WEEK_SCHEDULE_EMPLOYEE_SHIFT_ROW = "//emp-shift-row"
WEEK_SCHEDULE_PUBLISH_CURRENT = "//span[.='Publish Current Schedule']"
WEEK_SCHEDULE_PUBLISHED_STATE = "//div[@class='scheduleStatus']/span[.='Published']"
WEEK_SCHEDULE_SCHEDULED_CELL_COUNT = "//div[@id='scheduleShiftGridContainerRootElement']//td//div[contains(@class,'parentShiftContainer') and not(contains(@class,'isCrossStoreShift'))]//span[@class='startTime']"
WEEK_SCHEDULE_ADVANCED_FILTER_ICON = "#advanceFilter"
WEEK_SCHEDULE_FILTER_SETTING_TAB = (
    "//div[contains(@class, 'ws-bottom-tab') and contains(text(), 'Filter Settings')]"
)
WEEK_SCHEDULE_FILTER_ALL_UNSCHEDULED_CHECKBOX = "[for='UNSCHEDULED']"
WEEK_SCHEDULE_ADVANCED_FILTER_FETCH_BTN = (
    "[ng-click='scheduleCtrl.fetchAssociatesBasedOnFilter()']"
)
WEEK_SCHEDULE_ADVANCED_FILTER_LOADING_SPINNER = (
    "//div[@id='rfx_spinner']//div[@class='rfx-spinner']"
)
WEEK_SCHEDULE_ADVANCED_FILTER_APPLY_BTN = "[ng-disabled='(!scheduleCtrl.isAssociateSelectionChanged) || !scheduleCtrl.isAtleastOneFilteredAssociateSelected()']"
WEEK_SCHEDULE_SHIFT_CLOSE_BTN = "//div[@class='gridHeader']//span[contains(@class,'ws-iconXclose')]"
WEEK_SCHEDULE_SHIFT_COUNT = ".shiftInfo"
WEEK_SCHEDULE_FILTER_BY_EMP = "//input[@id='empFilterFocusId']"
WEEK_SCHEDULE_EMPLOYEE_RECORDS = "//td[@class='empDetail']"
WEEKSCHEDULEPAGE_SHIFT_RECORD_CANCEL = "//button[contains(text(),'Cancel')]"
WEEKSCHEDULEPAGE_VERIFY_MSG = "//div[@class='notifyMsg']"
WEEKSCHEDULEPAGE_HEADER_WEEK_LABEL = (
    "//*[contains(@class,'calendarNav')]//span[contains(text(),'{WEEK}')] | //span[@data-testid='forecast-review-btn-date-picker' and contains(@aria-label, '{WEEK}')]"
)
WEEKLYPLANPAGE_HEADING = "//span[@class='header ws-fs-md ws-fw-bold' and @role='heading' and @aria-level='1' and contains(text(), 'Plan Status')]"
WEEKSCHEDULEPAGE_CALENDERNAV_SPINNER = "(//*[@id='rfx_spinner']/div[2])[1]"
WEEKSCHEDULEPAGE_UNDO_ICON = "span[aria-label='Undo']"
WEEKSCHEDULEPAGE_OPEN_SHIFTS_DELETE_TAB = "#openShiftDelete"
WEEKSCHEDULEPAGE_SWAP_SHIFT_ICON = "//div[@id='shiftSwap']"
WEEKSCHEDULEPAGE_EDIT_TASK = "//td//select[@aria-label='Shift Task']"
WEEKSCHEDULEPAGE_CHECKIN_STARTTIME = (
    "(//tr//input[@aria-label='Select Task Start Time'])[1]"
)
WEEKSCHEDULEPAGE_UNALLOCATE_SHIFT_POPUPWINDOW = (
    "//div[@class='confirmPopup modal-body']"
)
WEEKSCHEDULEPAGE_REASSIGN_SHIFT_ICON = "//div[@id='shiftReassign']"
WEEKSCHEDULE_SCHEDULE_GENERATE_USING_TEMPLATE = (
    "//button[@title='Generate Schedule Using Templates']"
)
WEEKSCHEDULE_SCHEDULE_SCHEDULE_LINK = "//span[normalize-space()='Go to Schedule Page']"
WEEKSCHEDULEPAGE_ALERT_MESSAGE = "//div[@class='notifyMsg']"
WEEKSCHEDULEPAGE_GENERATE_WEEK_PLAN_CHECK = (
    "//button[@title='Generate Week Plan']//img[@alt='Check']"
)
WEEKSCHEDULEPAGE_ALERT_TAB = "div#shiftAlert"
WEEKSCHEDULEPAGE_ALERTS = "(//tr[@class='alertRow'])"
WEEKSCHEDULEPAGE_SHIFT_NOTES_TAB = (
    "//div[@class='shiftDetails']//div[@id='shiftTabDetails']//div[@id='shiftNote']"
)
WEEKSCHEDULEPAGE_SHIFT_NOTES_TXTBOX = (
    "//input[@data-testid='schedule-shift-notes-panel-input-note-text-2'] | //input[@class='form-control input-sm ng-pristine ng-untouched ng-valid ng-empty']"
)
WEEKSCHEDULEPAGE_DELETE_NOTE_WITH_TXT = "//div[contains(text(),'{ADDED_NOTE}')]/parent::td/following-sibling::td/button[@ng-click='scheduleCtrl.deleteShiftNote(note.noteId,$index,note.noteTypeId)']"
WEEKSCHEDULEPAGE_GENERATE_OPTIMIZE_SCH = (
    "//button[@title='Generate Optimized Schedule']"
)
WEEKSCHEDULEPAGE_OPEN_SHIFTS_TAB = "//span[normalize-space()='Open Shifts']"
WEEK_SCHEDULE_PAGE_OPEN_SHIFT_BADGE = (
    "(//span[normalize-space()= 'Open Shifts']/following::span[@class='badge'])[1]"
)
WEEKSCHEDULEPAGE_OPEN_SHIFTS_PLUS_ICON = (
    "(//span[contains(@title,'Add Open Shift')])[contains(@id,'Date_{DATE}')]"
)
WEEKSCHEDULEPAGE_SCHEDULE_NOTES_TAB = "//span[normalize-space()='Schedule Notes']"
WEEKSCHEDULEPAGE_SUCCESS_NOTIFIER_MESSAGE = "div[class='rfx-notify-message success']"
WEEKSCHEDULEPAGE_REQUESTS_TAB = "//span[normalize-space()='Requests']"
WEEKSCHEDULEPAGE_MOVE_TAB = "div#shiftMove"
WEEKSCHEDULEPAGE_COPY_SHIFT_TAB = "#shiftCopy"
WEEKSCHEDULEPAGE_COPY_SHIFT_FOR_WEEKDAY = "//label[@for='{DAY}']"
WEEKSCHEDULEPAGE_COPY_SHIFT_COPY_BTN = "//button[contains(normalize-space(),'Copy')]"
WEEKSCHEDULEPAGE_HEADING = "//span[@role='heading']"
WEEKSCHEDULEPAGE_ALERTS_MESSAGE_TEXT = (
    "//tr[@class='alertRow']//td[@class='description']"
)
WEEKSCHEDULEPAGE_ALERTS_MESSAGE_BY_TEXT_IN_REPORT = "//tr[@class='alertRow']//td[@class='description' and contains(text(),'{ALERT_MESSAGE}')]"
# Dynamic locator for Alerts Report - Works for both Employee and Shift alerts
# The alert type (employee vs shift) is distinguished by the alert message text, not the DOM structure
WEEKSCHEDULEPAGE_ALERTS_REPORT_ALERT_BY_ASSOCIATE_DATE_MESSAGE = "(//td[contains(@aria-label, '{ASSOCIATE_NAME}')]/following::div[contains(@aria-label, '{FORMATTED_DATE}')]/following::td[contains(@aria-label, '{ALERT_MESSAGE}')])[1]"
WEEKSCHEDULEPAGE_REPORTS_SCHEDULE_NOTES = (
    "(//tr[@class='ws-row'][1]//td[text()='{SCHEDULE_NOTES}'])[1]"
)
WEEKSCHEDULEPAGE_REPORTS_NOTES_PANEL = (
    "//div[@class='ws-modal fade in']//div[@class='modal-content']"
)
WEEKSCHEDULEPAGE_REPORTS_NOTES_FILTER_ICON = (
    "//span[normalize-space()='Notes']/following::span[@id='advanceFilter']"
)
WEEKSCHEDULEPAGE_REPORTS_NOTES_FILTER_APPLY_BTN = "//button[normalize-space()='Apply']"
WEEKSCHEDULEPAGE_REPORTS_NOTES_FILTER_RESET_BTN = "//button[normalize-space()='Reset']"
WEEKSCHEDULEPAGE_REPORTS_NOTES_CATEGORY_FILTER = "//select[@aria-label='Category']"
WEEKSCHEDULEPAGE_REPORTS_EMPLOYEE_NOTES = (
    "(//tr[@class='ws-row'][1]//td[contains(text(),'{EMPLOYEE_NOTES}')])[1]"
)
WEEKSCHEDULEPAGE_REPORTS_SHIFT_NOTES = (
    "(//tr[@class='ws-row']//td[contains(text(),'{SHIFT_NOTES}')])[1]"
)
WEEKSCHEDULEPAGE_REPORTS_NOTES_CLOSE_BTN = (
    "//div[@class='ws-modal fade in']//span[@aria-label='Close']"
)
WEEKSCHEDULEPAGE_EMP_ALERTS_TAB = "//div[@id='employeeAlert' and @role='tab']"
WEEKSCHEDULEPAGE_ALERT_MESSAGE_BY_TEXT = (
    "//td[@class='description' and normalize-space()='{ALERT_MESSAGE}']"
)
WEEKSCHEDULEPAGE_EMP_ALERTS_TAB_LABEL = "//td[@class='description' and translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='no alerts present'] | (//span[contains(@class, 'ws-iconCalendar') and @title='Calendar'])[1]"
WEEKSCHEDULEPAGE_EMP_NOTES_TAB = "//div[@id='employeeNote' and @role='tab']"
WEEKSCHEDULEPAGE_EMP_NOTES_TEXTBOX = "//input[@aria-label='Add Notes']"
WEEKSCHEDULEPAGE_ASSOCIATE_BY_NAME = "//span[@class='pointer ws-fw-bold assocNameContainer' and normalize-space()='{ASSOCIATE_NAME}']"
WEEKSCHEDULEPAGE_CAL_NAV_DATE_LABEL = "//div[contains(@class, 'calendarNav')]/span[2]"
WEEKSCHEDULEPAGE_SHIFT_FOR_EMP_NAME_AND_DATE = "(//span[contains(text(),'{EMP_NAME}')]//ancestor::tr[@class='empShiftRow']//td[@class='weekDayContainer'])[{DAY}]//div[@class='parentShiftContainer']"
WEEKSCHEDULEPAGE_SHIFT_RESPONSES_RESPONDER_NAME = (
    "//div[@class='essResponsePanel']//td[@class='associateName']//span"
)
WEEKSCHEDULEPAGE_SHIFT_RESPONSES_RESPONDER_NOTES = (
    "//div[@class='essResponsePanel']//td[@class='notes']"
)
WEEKSCHEDULEPAGE_OPEN_SHIFT_START_TIME_INPUT = (
    "//td[@class='startTime']//input[@id='timePickerPop']"
)
WEEKSCHEDULEPAGE_OPEN_SHIFT_END_TIME_INPUT = (
    "//td[@class='endTime']//input[@id='timePickerPop']"
)
WEEKSCHEDULEPAGE_EDIT_OPEN_SHIFT_TAB = "#shiftEdit"
WEEKSCHEDULEPAGE_COPY_OPEN_SHIFT_TAB = "#openShiftCopy"
WEEKSCHEDULEPAGE_ASSIGN_OPEN_SHIFT_TAB = "#openShiftAssign"
WEEKSCHEDULEPAGE_MOVE_OPEN_SHIFT_TAB = "#openShiftMove"
WEEKSCHEDULEPAGE_ASSOCIATE_WEEKDAY_CELL = "//span[contains(@class,'assocNameContainer') and normalize-space()='{ASSOCIATE_NAME}']//ancestor::tr[@class='empShiftRow']//td[@class='weekDayContainer'][{DAY}]//div[@class='addShiftPopContent']"
WEEKSCHEDULEPAGE_OPEN_SHIFT_TASK_SELECT = "//td[@class='task']//select[1]"

WEEK_SCHEDULE_ASSOCIATE_CELL = "//tr//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr//td[@class='weekDayContainer'][{DAY_INDEX}]"
WEEK_SCHEDULE_ASSOCIATE_START_TIME_INPUT = "//tr//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr//td[@class='weekDayContainer'][{DAY_INDEX}]//input[@id='starTimeInput']"
WEEK_SCHEDULE_ASSOCIATE_END_TIME_INPUT = "//tr//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr//td[@class='weekDayContainer'][{DAY_INDEX}]//input[@id='endTimeInput']"
WEEK_SCHEDULE_SWAP_ASSOCIATE_CELL = "//tr//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr//td[@class='weekDayContainer'][{DAY_INDEX}]"
WEEK_SCHEDULE_SWAP_BUTTON = "(//tr//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr//td//button[contains(@ng-click,'swapScheduledShift')])[1]"
WEEK_SCHEDULE_UNALLOCATE_ASSOCIATE_CELL = "//tr//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr//td[@class='weekDayContainer'][{DAY_INDEX}]"
WEEK_SCHEDULE_REASSIGN_ASSOCIATE_CELL = "//tr//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr//td[@class='weekDayContainer'][{DAY_INDEX}]"
WEEK_SCHEDULE_REASSIGN_BUTTON = "(//tr//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr//td//button[normalize-space()='Assign'])[1]"
WEEK_SCHEDULE_EDIT_ASSOCIATE_CELL = "(//tr//span[contains(text(),'{FIRST_NAME}') and contains(text(),'{LAST_NAME}')]/ancestor::tr//td[@class='weekDayContainer'])[{DAY_INDEX}]"
WEEK_SCHEDULE_EDIT_END_TIME_INPUT = (
    "(//tr//input[@aria-label='Select Task End Time'])[{TASK_COUNT}]"
)
WEEKSCHEDULEPAGE_EDIT_DELETE_TASK_ICON = "(//span[@title='Delete Task'])[{TASK_COUNT}]"
# Filter elements
WEEKSCHEDULEPAGE_FILTER_SETTING_TAB = (
    "//div[contains(@class, 'ws-bottom-tab') and contains(text(), 'Filter Settings')]"
)
# Button elements
WEEKSCHEDULEPAGE_EDIT_SHIFT_BUTTON = "id=shiftEdit"
WEEKSCHEDULEPAGE_SCHEDULE_DELETE_OK_BTN = "id=okButton"
WEEKSCHEDULEPAGE_SHIFT_CLOSE_BTN = "//span[@title='Close']"
WEEKSCHEDULEPAGE_OPEN_SHIFT_REQUEST_DETAILS_BY_DATE_TIME_BTN = "//td[contains(text(),'{DATE}') and contains(text(),'{START_TIME}') and contains(text(),'{END_TIME}')]/following::button[1]"
WEEKSCHEDULEPAGE_OPEN_SHIFT_REQUEST_APPROVE_BY_DATE_TIME_BTN = "(//td[contains(text(),'{RESPONSE_DATE}') and contains(text(),'{START_TIME}') and contains(text(),'{END_TIME}')]/following::button[contains(text(),'Approve')])[1]"
WEEKSCHEDULEPAGE_OPEN_SHIFT_REQUEST_RESPOSES_BTN = "//div[@id='openShiftResponse']"
WEEKSCHEDULEPAGE_ADVERTISE_SHIFT_REQUEST_RESPONSES_BTN = (
    "xpath=//div[@id='shiftResponse']"
)
WEEKSCHEDULEPAGE_SWAP_SHIFT_REQUEST_RESPONSES_BTN = "xpath=//div[@id='shiftResponse']"
WEEKSCHEDULEPAGE_SWAP_SHIFT_REQUEST_APPROVE_BTN = "(//span[contains(text(),'{ASSOCIATE_NAME}')]/ancestor::td[@class='associateName']/following::button[contains(@ng-click,'approveResponse')])[1]"
WEEKSCHEDULEPAGE_EXTRAWORK_SHIFT_REQUEST_RESPONSES_BTN = (
    "xpath=//div[@id='extraWorkResponse']"
)
WEEKSCHEDULEPAGE_EXTRAWORK_SHIFT_REQUEST_APPROVE_BTN = (
    "//button[normalize-space()='Approve']"
)
WEEKSCHEDULEPAGE_RESPONSES_CLOSE_BTNN = "xpath=//span[@aria-label='Close']"
WEEKSCHEDULEPAGE_OPEN_SHIFT_CLOSE_BTN = "//span[@id='closeDetails']"
WEEKSCHEDULEPAGE_PUBLISH_BUTTON = "//button[@title='Publish Schedule']"
WEEKSCHEDULEPAGE_UNPUBLISH_BUTTON = "//button[@title='Unpublish Schedule']"
WEEKSCHEDULEPAGE_DLTSCHEDULE_BUTTON = "//button[@title='Delete Schedule']"
WEEKSCHEDULEPAGE_DLT_CONFIRM_BUTTON = "//button[normalize-space()='OK']"
WEEKSCHEDULEPAGE_EDIT_SHIFT_SAVE_BUTTON = "//button[normalize-space()='Save']"
WEEKSCHEDULEPAGE_UNALLOCATE_SHIFT_BUTTON = "//div[@id='shiftUnallocate']"
WEEKSCHEDULEPAGE_UNALLOCATE_SHIFT_OK_BTN = "//button[@id='okButton']"
WEEKSCHEDULEPAGE_ALERT_CLOSE_BUTTON = "#closeBtn"
WEEKSCHEDULEPAGE_GENERATE_WEEK_PLAN_BUTTON = "//button[@title='Generate Week Plan']"
WEEKSCHEDULEPAGE_GENERATE_WORKLOAD_BUTTON = "button[ng-class*='GENERATE_WL']"
WEEKSCHEDULEPAGE_SHIFT_NOTES_ADD_BTN = "//button[@ng-click='scheduleCtrl.saveShiftNote(scheduleCtrl.selectedShift.newNote)']"
WEEKSCHEDULEPAGE_APPROVE_BTN = "//button[normalize-space()='Approve']"
WEEKSCHEDULEPAGE_RESPONSE_TAB_CLOSE_BTN = "//span[@title='Close']"
WEEKSCHEDULEPAGE_SCHEDULE_NOTES_ADD_BTN = "//button[normalize-space()='Add']"
WEEKSCHEDULEPAGE_SCHEDULE_NOTES_DELETE_BTN = "(//span[normalize-space()='{NOTES_TEXT}']/ancestor::tr[@class='notesRow']/descendant::button[normalize-space()='Delete'])[1]"
WEEKSCHEDULEPAGE_EMP_NOTES_DELETE_BTN = "(//span[normalize-space()='{NOTES_TEXT}']/ancestor::tr[@class='notesRow']/descendant::button[normalize-space()='Delete'])[1]"
WEEKSCHEDULEPAGE_DELETE_NOTES_OK_BTN = "(//button[normalize-space()='OK'])[1]"
WEEKSCHEDULEPAGE_EMP_ADD_NOTE_BTN = "//button[contains(@class, 'btn-primary') and contains(@class, 'btn-sm') and normalize-space()='Add']"
WEEKSCHEDULEPAGE_OPEN_SHIFT_SAVE_BTN = "//button[normalize-space()='Save']"
WEEKSCHEDULEPAGE_OPEN_SHIFT_DAY_BTN = "//label[@for='{OFFSET_DAY}']"
WEEKSCHEDULEPAGE_OPEN_SHIFT_COPY_BTN = "//button[normalize-space()='Copy']"
WEEKSCHEDULEPAGE_OPEN_SHIFT_MOVE_BTN = "//button[normalize-space()='Move']"
WEEKSCHEDULEPAGE_ASSIGN_OPEN_SHIFT_STORE_TYPE_BTN = (
    "//div[@class='shiftReassignPanel']//td[contains(@ng-click,'storeSelected=true')]"
)
WEEKSCHEDULEPAGE_ASSOCIATE_ASSIGN_BTN = "//div[contains(text(),'{ASSOCIATE_DISPLAY_NAME}')]//parent::td[@class='associatename']//following-sibling::td//button[contains(@class,'btn-primary')]"
WEEKSCHEDULEPAGE_GO_TO_SCHEDULE_LINK = (
    "//a[contains(@ng-class,'SCHEDULE_GENERATED')]//span[@class='redirectLinks']"
)

# Dropdown elements
WEEKSCHEDULEPAGE_REPORTS_DROPDOWN = (
    "[ng-click='scheduleCtrl.onReportsMenuClick =!scheduleCtrl.onReportsMenuClick ']"
)
WEEKSCHEDULEPAGE_REPORTS_PAGE_DROPDOWN = (
    "//div[normalize-space()='Reports']/following::span[@title='Navigate to Screen']"
)
WEEKSCHEDULEPAGE_REPORTS_DROPDOWN_OPTION = (
    "//a//span[contains(text(),'{REPORTS_OPTION}')]"
)
# Add/Edit elements
WEEKSCHEDULEPAGE_SCHEDULE_NOTES_ADD_NOTES_TXT = "//input[@aria-label='Add Notes']"
WEEKSCHEDULEPAGE_DELETE_WORKLOAD = "button[ng-class*='DELETE_WL']:not([ng-class*='DELETE_SC'])"
WEEKSCHEDULEPAGE_DELETE_SCHEDULE_AND_WORKLOAD = (
    "//button[contains(@ng-disabled, 'DELETE_SC') and contains(@ng-click, 'deleteWorkloadAndSchedule')]"
)
WEEK_SCHEDULE_WEEKLY_SCHEDULE_DETAIL = (
    "//div/span[contains(text(),'Weekly Schedule Detail')]"
)
WEEK_SCHEDULE_WEEKLY_ASSOCIATE_SUMMARY = (
    "//div/span[contains(text(),'Weekly Associate Summary')]"
)
WEEK_SCHEDULE_WEEKLY_ASSOCIATE_DETAIL = (
    "//div/span[contains(text(),'Weekly Associate Detail')]"
)
WEEK_SCHEDULE_PERIOD_ASSOCIATE_SUMMARY = (
    "//div/span[contains(text(),'Period Associate Summary')]"
)
WEEK_SCHEDULE_PERIOD_ASSOCIATE_DETAIL = (
    "//div/span[contains(text(),'Period Associate Detail')]"
)
WEEK_SCHEDULE_PERIOD_ASSOCIATE_NAME_INPUT_TEXTBOX = (
    "//input[@aria-label='Enter associate name']"
)
WEEK_SCHEDULE_PRINT_BTN = "//button[@ng-if='!printSumPopUpCtrl.isPDF']"
WEEK_SCHEDULE_SEARCHED_ASSOCIATE = "(//ul[@class='dropdown-menu']/li/a)[1]"
WEEK_SCHEDULE_PERIOD_ASSOCIATE_START_DATE_CALENDAR = (
    "//span[@aria-label='Start Date Calendar']"
)
WEEK_SCHEDULE_PERIOD_ASSOCIATE_END_DATE_CALENDAR = (
    "//span[@aria-label='End Date Calendar']"
)
WEEK_SCHEDULE_SUMMARY_EMPLOYEE_DETAILS = (
    "(//td[contains(@class,'employeeDetails ')])[1]"
)
WEEK_SCHEDULE_SUMMARY_SHIFT_DETAILS = "(//div[@class='shiftStart shiftTimingsCSS '])[1]"
WEEK_SCHEDULE_DETAILS_SHIFT_DETAILS = (
    "(//td[contains(@class,'employeeDetailsdetailed')])[1]"
)
WEEK_SCHEDULE_ASSOCIATE_NAME = "//div[contains(text(),'{EMP_NAME}')]"
WEEK_SCHEDULE_ASSOCIATE_SHIFT_ROW = (
    "(//tr[@class='rowStyle bb-border-box-important'])[1]"
)
WEEK_SCHEDULE_DETAILS_SHIFT_ROW = "(//tr[@class='rowStyle'])[1]"
WEEK_SCHEDULE_STORE_SCHEDULE_SUMMARY_REPORT_TITLE = (
    "//div/span[contains(text(),'Weekly Store Schedule - Summary')]"
)
WEEK_SCHEDULE_STORE_SCHEDULE_DETAIL_REPORT_TITLE = (
    "//div/span[contains(text(),'Weekly Store Schedule - Detail')]"
)
WEEK_SCHEDULE_ASSOCIATE_SCHEDULE_SUMMARY_REPORT_TITLE = (
    "//div/span[contains(text(),'Weekly Associate Schedule - Summary')]"
)
WEEK_SCHEDULE_ASSOCIATE_SCHEDULE_DETAIL_REPORT_TITLE = (
    "(//div/span[contains(text(),'Weekly Associate Schedule - Detail')])[1]"
)
WEEK_SCHEDULE_PERIOD_ASSOCIATE_SCHEDULE_SUMMARY_REPORT_TITLE = (
    "//div/span[contains(text(),'Period Associate Schedule - Summary')]"
)
WEEK_SCHEDULE_PERIOD_ASSOCIATE_SCHEDULE_DETAIL_REPORT_TITLE = (
    "(//div/span[contains(text(),'Period Associate Schedule - Detail')])[1]"
)
WEEK_SCHEDULE_ASSOCIATE_WITH_SHIFT = "((//div[@id='shiftBubbleContainer'])[1]//ancestor::tr[contains(@id,'empShiftRow')]//td[@class='empDetail']/div/span[1])[1]"
WEEK_SCHEDULE_PAGE_UPDATED_SHIFT_TIME = "(//table[@role='presentation']//tr[@class='empShiftRow'])[{ROW_NUM}]/td[{COL_NUM}]//div[contains(@class, 'shiftInfo')]"
WEEK_SCHEDULE_PAGE_OPEN_SHIFT_ENTRY = "(//div[contains(@aria-label,'Shift is Open From {START_TIME}') and contains(@aria-label,'To {END_TIME}') and contains(@aria-label,'{FORMATTED_DATE}')])[1]"
WEEK_SCHEDULE_PAGE_OPEN_POOL_SHIFT = "(//div[normalize-space()='{SHIFT_TIME}'])[last()]"
WEEK_SCHEDULE_PAGE_FIRST_VACANT_DAY_CELL = "(//tr[@class='empShiftRow']//td[@class='weekDayContainer' and not(.//div[@id='shiftBubbleContainer'])])[1]"
WEEK_SCHEDULE_PAGE_FIRST_AVAILABLE_SHIFT_DAY_CELL = "(//tr[@class='empShiftRow']//td[@class='weekDayContainer' and (.//div[@id='shiftBubbleContainer'])])[1]"
WEEK_SCHEDULE_PAGE_ASSOCIATE_DAY_SHIFT = "((//span[contains(@aria-label,'{ASSOCIATE_DISPLAY_NAME}')])/ancestor::tr[@class='empShiftRow'])[1]/descendant::div[contains(@aria-label,'From {START_TIME}') and contains(@aria-label,'To {END_TIME}') and contains(@aria-label,'{FORMATTED_DATE}')]"
WEEK_SCHEDULE_PAGE_ANY_SHIFT_EXIST_ASSOCIATE_DAY = "//tbody/tr[@id='empShiftRow_{PERSON_ID}']//td[@data-testid='weekday_{DAY_NO}']//basic-shift-bubble"
WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT_UNALLOCATED = "(//span[normalize-space()='{ASSOCIATE_DISPLAY_NAME}']//ancestor::table[@role='presentation']//tr[@class='empShiftRow'])[1]/td[@class='weekDayContainer'][{DAY_OFFSET}]/descendant::div[@id='shiftBubbleContainer']"
WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFT = "(//span[normalize-space()='{ASSOCIATE_DISPLAY_NAME}']//ancestor::table[@role='presentation']//tr[@class='empShiftRow'])[1]/td[@class='weekDayContainer'][{DAY_OFFSET}]"
WEEK_SCHEDULE_DISPLAY_PREF_SHIFT_DETAILS_RADIO = "//input[@type='radio'][@name='shiftDetails']//following-sibling::label[text()='{DETAIL}']"
WEEK_SCHEDULE_DISPLAY_PREF_SELECTION_PANEL = "//td[contains(@class,'commonConfig')]"
WEEK_SCHEDULE_PAGE_SHIFT_DETAILS_TAB = "(//span[contains(@aria-label,'{ASSOCIATE_DISPLAY_NAME}')]/following::td[@class='weekDayContainer'])[{SHIFT_DAY}]"
# WEEK_SCHEDULE_PAGE_ASSOCIATE_STAFF_GROUP_LBL = "//td[@class='empDetail']/div/span[contains(text(), '{ASSOCIATE_DISPLAY_NAME}')]/parent::div/following-sibling::div/span[contains(@ng-if, 'showPrimaryJob')]"
WEEK_SCHEDULE_PAGE_ASSOCIATE_STAFF_GROUP_LBL = "//div[contains(@ng-repeat, 'groupingId') and .//span[contains(text(), '{ASSOCIATE_DISPLAY_NAME}')]]//span[@class='ws-fw-semibold']"
WEEK_SCHEDULE_PAGE_STAFF_GROUP_DROPDOWN_OPTION = (
    "(//select[@id='staffGrpSelect']/option[normalize-space()='{STAFF_GROUP}'])[1]"
)
# Detailed Shift Modal Locators (Right-click Add Shift)
WEEK_SCHEDULE_DETAILED_SHIFT_START_TIME = "(//input[@aria-label='Select Start Time'])[{INDEX}]"
WEEK_SCHEDULE_DETAILED_SHIFT_END_TIME = "(//input[@aria-label='Select End Time'])[{INDEX}]"
WEEK_SCHEDULE_DETAILED_SHIFT_TASK_DROPDOWN = "(//td[@class='task']/select)[{INDEX}]"
WEEK_SCHEDULE_DETAILED_SHIFT_ADD_TASK_ICON = "(//span[contains(@ng-click,'onAddTask')])[{INDEX}]"
WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_BTN = "(//button[normalize-space()='Save'])[1]"
WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_DROPDOWN_ARROW = "//button[@title='Meal break rule options']"
WEEK_SCHEDULE_DETAILED_SHIFT_SAVE_NO_MEAL_RULES = "//li[contains(@ng-click,'applyBreakRulesOption.NO')]"
WEEK_SCHEDULE_DETAILED_SHIFT_ADD_NO_MEAL_RULES = "//li[contains(@ng-click,'applyBreakRulesOption.NO')]"
WEEK_SCHEDULE_DETAILED_SHIFT_TIME_PICKER_EDIT_INDEX = "(//input[@id='timePickerPop'])[{INDEX}]"
WEEK_SCHEDULE_SHIFT_TASK_DROPDOWN = "//select[@aria-label='Shift Task' or @aria-label='Task']"
WEEK_SCHEDULE_SHIFT_TASK_DROPDOWN_INDEX = "(//select[@aria-label='Shift Task' or @aria-label='Task'])[{INDEX}]"
WEEK_SCHEDULE_SHIFT_TASK_DROPDOWN_FIRST = "(//select[@aria-label='Shift Task' or @aria-label='Task'])[1]"
WEEK_SCHEDULE_PAGE_FILTER_NAME_INPUT = "//input[@placeholder='Filter Name']"
WEEK_SCHEDULE_PAGE_FETCH_BUTTON = "//button[normalize-space()='Fetch']"
WEEK_SCHEDULE_PAGE_SAVE_FILTER_BUTTON = "//button[normalize-space()='Save']"
WEEK_SCHEDULE_PAGE_ADV_FILTER_APPLY_BTN = "//button[@class='btn btn-primary weekplan-sch-btn-sm weekplan-sch-ml-0'][normalize-space()='Apply']"
WEEK_SCHEDULE_PAGE_ADV_FILTER_STAFF_GRP_LBL = "//td/span[@class='ws-fw-semibold']"
WEEK_SCHEDULE_PAGE_ADV_FILTER_SAVED_FILTERS_TAB = (
    "//div[normalize-space()='Saved Filters']"
)
WEEK_SCHEDULE_PAGE_ADV_FILTER_CLOSE_BTN = "//button[@class='btn btn-primary weekplan-sch-btn-sm weekplan-sch-ml-0'][normalize-space()='Close']"
WEEK_SCHEDULE_PAGE_ADV_FILTER_NAME = "//div[contains(@class, 'saved-set')]//div[@class='desc' and normalize-space(text()) = '{FILTER_NAME}']"
WEEK_SCHEDULE_PAGE_ADV_FILTER_DELETE_BTN = "//button[normalize-space()='Delete']"
WEEK_SCHEDULE_PAGE_ADV_FILTER_CLEAR_BTN = "//button[normalize-space()='Clear']"
WEEK_SCHEDULE_PAGE_CONTENT_AREA = (
    "(//tr[@class='aggregateRow']/td/span[@class='ws-fw-semibold'])[1]"
)
OVERS_SHORTS_REPORT_DROPDOWN_OPTION = "//a[contains(@ng-click,'scheduleCtrl.onScheduleReportsMenuClick')]//span[text()='Overs & Shorts']"
WEEK_SCHEDULE_TOTAL_SCHEDULED_HOURS = "//td[contains(@class, 'nameContainer') and contains(text(), 'Total Scheduled')]/following-sibling::td[contains(@class, 'weekDayContainer')][{DAY_INDEX}]"
WEEK_SCHEDULE_TOTAL_WORKLOAD_HOURS = "(//td[@class='weekDayContainer']//span[starts-with(@aria-label, 'Total Demand hours')])[{DAY_INDEX}]"
WEEK_SCHEDULE_TOTAL_UNALLOCATED_HOURS = "(//td[@class='weekDayContainer']//span[starts-with(@aria-label, 'Total Unfilled')])[{DAY_INDEX}]"
OVERS_SHORTS_REPORT_TOTAL_WORKLOAD_HOURS_FOR_DAY = "(//tr[@class='ws-row']//td[@class='ws-cell'][contains(@aria-label, 'Total Workload Hours')])[{DAY_INDEX}]"
OVERS_SHORTS_REPORT_TOTAL_SCHEDULED_HOURS_FOR_DAY = "(//tr[@class='ws-row']//td[@class='ws-cell'][contains(@aria-label, 'Total Scheduled Hours (Without Break)')])[{DAY_INDEX}]"
OVERS_SHORTS_REPORT_UNALLOCATED_HOURS_FOR_DAY = "(//td[substring(@aria-label, string-length(@aria-label) - string-length('Unallocated Hours') + 1) = 'Unallocated Hours'])[{DAY_INDEX}]"
WEEK_SCHEDULE_PAGE_SEARCHED_ASSOCIATE = (
    "//td[@class='empDetail']/div/span[text()='{EMP_NAME}']"
)
WEEK_SCHEDULE_EDIT_OPEN_SHIFT = "(//div[@class='openShiftsWeeklyPanel']//td[@class='weekDayContainer'][{DAY}]//span[@class='startTime'][contains(text(),'{START_TIME}')]/following-sibling::span[@class='endTime'][contains(text(),'{END_TIME}')]//ancestor::div[contains(@class,'shiftBubble')])[1]"
WEEKSCHEDULEPAGE_REVIEW_SCHEDULE_CHANGES_REPORT_OPTION = (
    "//a//span[contains(text(),'Review Schedule Changes')]"
)
WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_ADD_SHIFT_ROW = "(//td[contains(@aria-label,'{FORMATTED_DATE}')]/following::span[contains(@aria-label,'{ASSOCIATE_NAME}')]/following::td[contains(text(),'Add Shift')]/preceding-sibling::td[contains(@aria-label,'New Shift {START_TIME}') and contains(@aria-label,'{END_TIME}')])[1]/ancestor::tr[1]"
WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_SHIFT_EXTEND_ROW = "(//td[contains(@aria-label,'{FORMATTED_DATE}')]/following::span[contains(@aria-label,'{ASSOCIATE_NAME}')]/following::td[contains(text(),'Shift Extend')]/preceding-sibling::td[contains(@aria-label,'New Shift {START_TIME}') and contains(@aria-label,'{END_TIME}')])[1]/ancestor::tr[1]"
WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_UNALLOCATE_SHIFT_ROW = "(//td[contains(@aria-label,'{FORMATTED_DATE}')]/following::span[contains(@aria-label,'{ASSOCIATE_NAME}')]/following::td[contains(text(),'Shift Unallocate')]/preceding-sibling::td[contains(text(),'Unassigned')])[1]/ancestor::tr[1]"
WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_DELETE_OPEN_SHIFT_ROW = "(//td[contains(@aria-label,'{FORMATTED_DATE}')]/following::td[contains(text(),'Delete Open Shift')]/preceding-sibling::td[contains(@aria-label,'New Shift {START_TIME}') and contains(@aria-label,'{END_TIME}')])[1]/ancestor::tr[1]"
WEEKSCHEDULEPAGE_SCHEDULE_CHANGES_DELETION_AND_REGENERATION_ROW = "(//td[contains(@aria-label,'{FORMATTED_DATE}')]/following::span[contains(@aria-label,'{ASSOCIATE_NAME}')]/following::td[contains(text(),'Deleted') or contains(text(),'Regenerated')])[1]/ancestor::tr[1]"
WEEKSCHEDULEPAGE_SCHEDULE_DELETED_AND_GENERATION="//td[@aria-label='Description Schedule Deleted and Generated']"
WEEK_PLAN_SCHEDULE_REPORT_ASSOCIATE_SHIFTS = "//div[contains(text(),'{ASSOCIATE_DISPLAY_NAME}')]/ancestor::tr//td//div[contains(@class,'shiftStart shiftTimingsCSS ')]"
WEEK_PLAN_SCHEDULE_REPORT_ASSOCIATE_SHIFTS_INDEX = "(//div[contains(text(),'{ASSOCIATE_DISPLAY_NAME}')]/ancestor::tr//td//div[contains(@class,'shiftStart shiftTimingsCSS ')])[{INDEX}]"
WEEK_PLAN_SCHEDULE_REPORT_ASSOCIATE_TOTAL_HOURS = "//div[normalize-space(text())='{ASSOCIATE_DISPLAY_NAME}']/ancestor::tr//div[@class='dyn-fs-css ']"
WEEK_PLAN_SCHEDULE_REPORT_ASSOCIATE_MIN_MAX_HOURS = "//div[text()='{ASSOCIATE_DISPLAY_NAME}']/ancestor::tr//div[contains(@class,'minMaxHours')]"
WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFTS = "//td//span[contains(text(),'{ASSOCIATE_DISPLAY_NAME}')]/ancestor::tr//div[contains(@id,'shiftBubbleContainer')]"
WEEK_SCHEDULE_PAGE_ASSOCIATE_SHIFTS_INDEX = "(//td//span[contains(text(),'{ASSOCIATE_DISPLAY_NAME}')]/ancestor::tr//div[contains(@id,'shiftBubbleContainer')])[{INDEX}]"
WEEK_SCHEDULE_PAGE_ASSOCIATE_TOTAL_HOURS = "//td//span[contains(text(),'{ASSOCIATE_DISPLAY_NAME}')]//ancestor::tr//span[contains(@title,'Scheduled hours in group')]"
WEEK_SCHEDULE_PAGE_ASSOCIATE_MIN_MAX_HOURS = "//td//span[contains(text(),'{ASSOCIATE_DISPLAY_NAME}')]//ancestor::tr//span[contains(@title,'Min / Max Hours')]"
WEEKSCHEDULEPAGE_MOVE_SHIFT_FOR_WEEKDAY = "//label[@for='{DAY}']"
WEEKSCHEDULEPAGE_MOVE_SHIFT_MOVE_BTN = "//button[contains(normalize-space(),'Move')]"
WEEKSCHEDULEPAGE_REPORTS_SCHEDULE_WEEKLY = "//div[contains(@class,'scheduleReportsMenu')]//span[contains(@class,'iconRWS')]/../../span[@class='option']"
WEEK_SCHEDULE_DISPLAY_PREFERENCE_DEMAND_UNALLOCATED = "[for='showGroupDemandStats']"
WEEK_SCHEDULE_DISPLAY_PREFERENCE_DEMAND_UNALLOCATED_INPUT = "//label[@for='showGroupDemandStats']/preceding-sibling::input"
ASSOCIATE_SCHEDULED_HOURS_FOR_DAY = "(//span[contains(@aria-label,'Associate {ASSOCIATE_DISPLAY_NAME}')]/preceding::span[contains(@aria-label,'Scheduled hours for') and contains(@aria-label,'{FORMATTED_DATE}')])[1]"
ASSOCIATE_DEMAND_HOURS_FOR_DAY = "(//span[contains(@aria-label,'Associate {ASSOCIATE_DISPLAY_NAME}')]/preceding::span[contains(@aria-label,'Demand hours for') and contains(@aria-label,'{FORMATTED_DATE}')])[1]"
ASSOCIATE_UNFILLED_HOURS_FOR_DAY = "(//span[contains(@aria-label,'Associate {ASSOCIATE_DISPLAY_NAME}')]/preceding::span[contains(@aria-label,'Unfilled hours for') and contains(@aria-label,'{FORMATTED_DATE}')])[1]"
WEEKSCHEDULEPAGE_SOURCE_SHIFT_WITH_NAME_DAYOFFSET = "((//tr[@class='empShiftRow' and contains(normalize-space(),'{EMP_NAME}')]/td[@class='weekDayContainer'])[{DAY_OFFSET}+1]//div[contains(@class,'shiftBubble') and @ng-class])[1]"
WEEKSCHEDULEPAGE_TARGET_SHIFT_CELL_WITH_NAME_DAYOFFSET = "((//tr[@class='empShiftRow' and contains(normalize-space(),'{EMP_NAME}')]/td[@class='weekDayContainer'])[{DAY_OFFSET}+1]//div[contains(@class,'cellContent')])[1]"
