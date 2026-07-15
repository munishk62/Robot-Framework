LABOR_FORECAST_PAGE_SELECT_UNIT_CORP_FILTER = (
    '//td[@class="unitSearch ng-scope"]/unit-search/span/div[1]/span[1]/div'
)
LABOR_FORECAST_PAGE_FILTER_SEARCH_TXT_BOX = "input[ng-model='searchKey']"
LABOR_FORECAST_PAGE_EXPECTED_DROPDOWN_SEARCH_RESULT = (
    "(//div[@class='dropdownOptions']//a/span[contains(text(),'{UNIT_ID}')])[1]"
)
LABOR_FORECAST_PAGE_FILTER_SEARCH_BTN = "span[ng-click='applyDirectFilter()']"
LABOR_FORECAST_PAGE_WEEKVIEW_DAY_OF_WEEK = "//div[@id='workload-content']/div[@id='workloadContainerGridHeaderUIElement']/div/div/table/tbody/tr/td[1]/table/tbody/tr/td[@class='weekDayLabel ng-binding ng-scope pointer'][{DAY_INDEX}]"
LABOR_FORECAST_PAGE_DAYVIEW_TOTAL_WKLD_HRS_OF_DAY = "//div[@id='workload-content']/div[@id='workloadgridfooter']/div/div[@class='workloadStatsRow ng-scope']/table/tbody/tr/td[@class='totalsContainer']/span"
LABOR_FORECAST_PAGE_DAYVIEW_DAY_LABEL = (
    "//span[@id='daily_navBack' or @id='spread_navBack']/following-sibling::span"
)
LABOR_FORECAST_PAGE_WKLD_NOT_GENERATED_MSG = (
    "//span[@ng-bind=\"workloadCtrl.i18nFn('Workload is not generated')\"]"
)
LABOR_FORECAST_PAGE_NO_WKLD_MSG = "//div[@id='workload-content']/div[@class='gridContent']/div/div/div[@ng-show='workloadCtrl.viewType == workloadCtrl.constants.viewType.weekly']/div[@class='noDataMsg ng-scope']"
LABOR_FORECAST_PAGE_CAL_NAV_DATE_LABEL = "//td[contains(@class, 'calendarNav')]/span[2]"
LABOR_FORECAST_PAGE_CALENDAR_BUTTON = (
    "//span[contains(@ng-bind, 'Ctrl.selectedScheduleDateUILabel')]"
)
LABOR_FORECAST_PAGE_PREVIOUS_WEEK_BTN = (
    "span[ng-click=\"workloadCtrl.navigateToNextOrPrevWeek('prev')\"]"
)
LABOR_FORECAST_PAGE_WKLD_VALUES_FOR_UNIT = "//div[@id='workload-content']/div[@class='gridContent']/div/div/div/div[@class='workloadSummaryContainer ng-scope']/div/div/table/tbody/tr"
LABOR_FORECAST_PAGE_WEEKVIEW_TOTAL_WKLD_HRS_OF_DAY = "//div[@id='workload-content']/div[@id='workloadgridfooter']/div/div/table/tbody/tr/td[@class='weekDayContainer ng-scope'][{DAY_INDEX}]/div/span"
LABOR_FORECAST_PAGE_FORWARD_ARROW = "span.pointer.ws-icon.ws-iconArrowDateRight"
LABOR_FORECAST_PAGE_BACKWARD_ARROW = "span.pointer.ws-icon.ws-iconArrowDateLeft"
LABOR_FORECAST_PAGE_SELECTED_WEEK = "//span[normalize-space(text())='{WEEK}']"
LABOR_FORECAST_PAGE_SORT_PREFERENCE_ICON = "//span[@id='sortPreference']"
LABOR_FORECAST_PAGE_SORT_PREFERENCE_TAB = "//div/span[@id='sortIconId']"
LABOR_FORECAST_PAGE_TOTAL_SORT_PREFERENCE_RADIO_BTN = (
    "//div[@class='ws-radio']/label[@for='pref_Total']"
)
LABOR_FORECAST_PAGE_TASK_NAME = "//span[@class='taskName']/span[2] >> nth=0"
LABOR_FORECAST_PAGE_STAFF_GROUP = "//span[@ng-bind='wkldData.staffGroup'] >> nth=0"
LABOR_FORECAST_PAGE_SORT_APPLY_BTN = (
    "//div/button[contains(@ng-click,'applySortPreference')]"
)
LABOR_FORECAST_PAGE_SORT_RESET_BTN = (
    "//div/button[contains(@ng-click,'resetSortPreference')]"
)
LABOR_FORECAST_PAGE_FORWARD_WEEK_BTN = "//span[@aria-label='Next Week']"
LABOR_FORECAST_PAGE_WORKLOAD_ROW = "(//tr[starts-with(@class, 'workloadRowContainer')])[1]"
LABOR_FORECAST_PAGE_STAFF_GRP_SORT_PREFERENCE_RADIO_BTN = (
    "//div[@class='ws-radio']/label[@for='pref_staff']"
)
LABOR_FORECAST_PAGE_DEPT_SORT_PREFERENCE_RADIO_BTN = (
    "//div[@class='ws-radio']/label[@for='pref_department']"
)
LABOR_FORECAST_PAGE_TASK_SORT_PREFERENCE_RADIO_BTN = (
    "//div[@class='ws-radio']/label[@for='pref_task']"
)
LABOR_FORECAST_PAGE_DISPLAY_PREF_ICON = "//span[@id='displayPreference']"
LABOR_FORECAST_PAGE_SHORT_NAME_DISPLAY_PREF_RADIO_BTN = (
    "//div[@class='ws-radio']/label[@for='displayShortNameOrIcon1']"
)
LABOR_FORECAST_PAGE_DISPLAY_PREF_TAB = "//div/span[@id='diplayPrefId']"
LABOR_FORECAST_PAGE_APPLY_BTN = "//div/button[contains(@ng-click,'applyDisplayConfig')]"
LABOR_FORECAST_PAGE_SHORT_NAME = "(//span[@class='shortName ng-binding ng-scope'])[1]"
LABOR_FORECAST_PAGE_RESET_BTN = (
    "//div/button[contains(@ng-click, 'resetDisplayConfig')]"
)
LABOR_FORECAST_PAGE_ADVANCE_SEARCH_ICON = "//span[@id='advanceFilter']"
LABOR_FORECAST_PAGE_SAVED_FILTERS = "//div/span[@aria-label='Saved Filters']"
LABOR_FORECAST_PAGE_FILTER_SETTINGS = "//div/span[@id='filterIconId']"
LABOR_FORECAST_PAGE_TASK_NAME_COUNT = "//span[@class='taskName']/span[2][string-length() > 0 and not(@aria-label)]"
LABOR_FORECAST_PAGE_ADVANCE_FILTER_APPLY_BTN = (
    "//div/button[contains(@ng-click,'applyAdvancedFilter')]"
)
LABOR_FORECAST_PAGE_ADVANCE_FILTER_RESET_BTN = (
    "//div/button[contains(@ng-click,'resetAdvancedFilter')]"
)
LABOR_FORECAST_PAGE_STAFF_GROUP_DROPDOWN = "//select[@id='filterStaffGroup']"
LABOR_FORECAST_PAGE_STAFF_GROUP_DROPDOWN_SELECT = (
    "(//select[@id='filterStaffGroup']/option[contains(text(),'{STAFF_GRP}')])[1]"
)
LABOR_FORECAST_PAGE_ACTIVITY_DROPDOWN = "//select[@id='filterJob']"
LABOR_FORECAST_PAGE_ACTIVITY_DROPDOWN_SELECT = (
    "(//select[@id='filterJob']/option[contains(text(),'{ACTIVITY}')])[1]"
)
LABOR_FORECAST_PAGE_TOTAL_WORKLOAD = (
    "//span[contains(@aria-label, 'Total workload of all tasks')]"
)
LABOR_FORECAST_PAGE_PLEASE_WAIT_SPINNER = "(//div[contains(@class,'rfx-spinner')])[1]"
LABOR_FORECAST_PAGE_NO_WORKLOAD_DATA_MSG = "(//div[contains(@class,'noDataMsg')])[1]"
LABOR_FORECAST_PAGE_PDF_ICON = ".ws-iconPdf"
LABOR_FORECAST_PAGE_WORKLOAD_PANEL = "(//table[@class='ng-scope'])[2]"
LABOR_FORECAST_PAGE_THIRD_COLUMN = ".ws-main-header-row td:nth-of-type(4)"
LABOR_FORECAST_PAGE_DAY_TOTAL_HRS = "[ng-bind='workloadCtrl.toDecimalFormat(workloadCtrl.decimalRound(workloadCtrl.unitWorkloadTotals.total))']"
LABOR_FORECAST_PAGE_GENERATE_BTN = "//a[@aria-label='Generate']"
LABOR_FORECAST_PAGE_ACTION_DRPDWN_DELETE = "//a[contains(@ng-click,'DELETE')]"
LABOR_FORECAST_PAGE_ACTION_DROPDOWN = (
    "//span[contains(@class,'iconArrowDown ') and @tooltip='Action']"
)
LABOR_FORECAST_PAGE_WKLD_SUMMARY = "//div[@class='workloadSummaryContainer']"
LABOR_FORECAST_PAGE_WEEK_IN_PROGRESS = (
    "//span[@ng-click='workloadCtrl.showRailRoad =!workloadCtrl.showRailRoad ']"
)
LABOR_FORECAST_PAGE_DAY_HEADER_COLUMN = (
    ".ws-main-header-row td:nth-of-type({DAY_INDEX})"
)
LABOR_FORECAST_PAGE_BACK_TO_WEEK_DISPLAY_BUTTON = "//span[@id='daily_navBack' or @id='spread_navBack']"
LABOR_FORECAST_PAGE_ADVANCE_FILTER_PANEL = (
    "//div[@class='workloadAdvanceFilter ng-scope']"
)
LABOR_FORECAST_PAGE_FILTER_PANEL = "//td[@class='filters']"
LABOR_FORECAST_PAGE_WORKLOAD_ROW_ACTIVITIES = "//tr[@class='workloadRowContainer']"
LABOR_FORECAST_PAGE_WORKLOAD_TABLE = "(//table[@class='ws-table'])[1]"
LABOR_FORECAST_PAGE_CONTENT_TABLE = "//table[@class='border-radius-bottom-fix']"
LABOR_FORECAST_PAGE_DATE_LABEL = "//span[contains(text(), '{DATE}')]"
LABOR_FORECAST_PAGE_WORKLOAD_CONTAINER = "//div[@class='workloadSummaryContainer']"
LABOR_FORECAST_PAGE_WORKLOAD_CONTAINER_LAZY_LOAD = "//div[@id='workloadSummaryContainerLazyLoadRootElement']"