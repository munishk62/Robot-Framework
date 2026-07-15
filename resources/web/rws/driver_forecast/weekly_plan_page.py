WEEKLY_PLAN_PAGE_WEEKLY_PLANNING_WEEK = "#planningWeek"
WEEKLY_PLAN_PAGE_NEXT_WEEK_BTN = (
    "//span[@ng-click=\"railRoadCtrl.navigateToNextOrPrevWeek('next')\"]"
)
WEEKLY_PLAN_PAGE_INIT_BTN = "#btnInitialize > input"
WEEKLY_PLAN_PAGE_PENDING_INIT_LABEL = "#pendingId"
WEEKLY_PLAN_PAGE_VIEW_JOBS_BTN = "#viewJob"
WEEKLY_PLAN_PAGE_BATCH_JOB_STATUS = "#batchJobStatus"
WEEKLY_PLAN_PAGE_LOCATION_DRPDWN = "#locationDrpDwn > a"
WEEKLY_PLAN_PAGE_STORE_DRPDWN = "#dropmenu1"
WEEKLY_PLAN_PAGE_ORG_LEVEL_SELECT = (
    "(//div[@id='dropmenudiv']/a[normalize-space()='{ORG_LEVEL}'])[1]"
)

WEEKLY_PLAN_PAGE_UNIT_SELECT = "(//div[@id='dropmenu1']/a[normalize-space()='{UNIT}'])[1]"

WEEKLY_PLAN_PAGE_SEARCH_FILTER = "//div[@id='searchFilter']"
WEEKLY_PLAN_PAGE_SELECTED_WEEK = "//span[@ng-click='railRoadCtrl.datepickerPopUpOpen =!railRoadCtrl.datepickerPopUpOpen']"
WEEKLY_PLAN_PAGE_SELECTED_WEEK_NUMBER = "//button[contains(@class, 'active')]/parent::td/preceding-sibling::td[@ng-if='showWeeks']//span"
WEEKLY_PLAN_PAGE_WEEK_DISPLAYED = "//span[@class='pointer ng-binding' and contains(text(),'{WEEK}')]"
WEEKLY_PLAN_PAGE_CALENDAR_NAV_HEADER = "(//td[@class='calendarNav jm-td-header-fix']/span)[2]"