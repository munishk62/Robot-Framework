PLAN_STATUS_GENERATE_SCHEDULE_BUTTON = "button[ng-click=\"planStatusCtrl.generateForecast(planStatusCtrl.selectedUnit,planStatusCtrl.selectedDate,'WEEKLY')\"]"
PLAN_STATUS_GENERATE_WORKLOAD_BUTTON = "//div[@ng-if='planStatusCtrl.generateWorkloadPermission']//button[contains(@class,'planStatusActionButton')]"
PLAN_STATUS_GENERATE_SCHEDULE_USING_TEMPLATE_BTN = "//button[contains(@ng-click, 'planStatusCtrl.generateSchedule(planStatusCtrl.selectedUnit,planStatusCtrl.selectedDate,planStatusCtrl.planStatusConstants.scheduleGenType.SCHEDULE_USING_TEMPLATE,0,0)')]"
PLAN_STATUS_GENERATE_SCHEDULE_BUTTON_CHECK = '//button[contains(@ng-click, "planStatusCtrl.generateForecast")]//img[contains(@ng-src, "check-icon.png")]'
PLAN_STATUS_GENERATE_WORKLOAD_BUTTON_CHECK = '//button[contains(@ng-click, "planStatusCtrl.generateWorkload")]//img[contains(@ng-src, "check-icon.png")]'
PLAN_STATUS_GENERATE_SCHD_USING_TEMPLATE_BTN_CHECK = '//button[contains(@ng-click, "SCHEDULE_USING_TEMPLATE")]//img[contains(@ng-src, "check-icon.png")]'
PLAN_STATUS_DISABLED_TIMELINE_CONTAINER = (
    'div[class="ws-card-body disablTimeLineContainer"]'
)
PLAN_STATUS_REFRESH_ICON = 'span[ng-click="planStatusCtrl.refreshAllStatus()"]'
PLAN_STATUS_SUCCESS_NOTIFIER_MESSAGE = 'div[class="rfx-notify-message success"]'
PLAN_STATUS_SUCCESS_MESSAGE_CONTENT = 'div[class="rfx-notify-message success"] tbody tr td:nth-child(3) > div > div:nth-child(1)'
PLAN_STATUS_PAGE_GO_TO_SCHEDULE_PAGE = "//span[normalize-space()='Go to Schedule Page']"
PLAN_STATUS_GOTO_SCHEDULE_LINK = "a[ng-click=\"planStatusCtrl.secureDirect(planStatusCtrl.appName+'/weekplan/schedule.jsp?viewType=weekly&mm=SCHD&scheduleDate='+planStatusCtrl.selectedDate )\"]"
PLAN_STATUS_GOTO_FORECAST_LINK = "a[ng-click=\"planStatusCtrl.secureDirect(planStatusCtrl.appName+'/rfp/forecast/volume_forecast.jsp?fcstDate='+planStatusCtrl.selectedDate )\"]"
PLAN_STATUS_GOTO_WORKLOAD_LINK = "a[ng-click=\"planStatusCtrl.secureDirect(planStatusCtrl.appName+'/weekplan/workload.jsp?viewType=weekly&mm=LABORFCAST&fcstDate='+planStatusCtrl.selectedDate+'&_rfxHeaderLess=false&_rfxMenuLess=false' )\"]"
PLAN_STATUS_SCHEDULE_STATUS_CONTAINER = ".scheduleStatus > span"
PLAN_STATUS_ACTION_DROPDOWN = "//span[@ng-click='scheduleCtrl.onOtherActionsClick =!scheduleCtrl.onOtherActionsClick ']"
PLAN_STATUS_ACTION_DELETE_CURRENT_SCHEDULE = (
    "//a[@ng-click='scheduleCtrl.renderScheduleActionDelete()']"
)
PLAN_STATUS_OK_BTN = "#okButton"
PLAN_STATUS_PLAN_PROGRESS_PANEL = (
    "[ng-include=\"planStatusCtrl.templatePath+'planProgressPanel.html'\"]"
)
PLAN_STATUS_DELETE_WORKLOAD = "//button[@ng-click='planStatusCtrl.deleteCurrentWorkload(planStatusCtrl.selectedUnit,planStatusCtrl.selectedDate)']"
PLAN_STATUS_DELETE_WKLD_SCHD = "//button[@ng-click=\"planStatusCtrl.deleteWorkloadAndSchedule(planStatusCtrl.selectedUnit,planStatusCtrl.selectedDate,'Y')\"]"
PLAN_STATUS_DELETE_WORKLOAD_CONFIRMATION_OK = "//button[@ng-click='planStatusCtrl.deleteWorkload(planStatusCtrl.selectedUnit, planStatusCtrl.selectedDate); planStatusPopCtrl.close()']"
PLAN_STATUS_DELETE_WKLD_SCHD_CONFIRM_OK = "//button[@ng-click=\"planStatusCtrl.deleteWorkload(planStatusCtrl.selectedUnit, planStatusCtrl.selectedDate, 'Y'); planStatusPopCtrl.close()\"]"
PLAN_STATUS_DELETE_SCHD_CONFIRM_OK = "//button[@ng-click='planStatusPopCtrl.deleteSchedule(planStatusCtrl.selectedUnit, planStatusCtrl.selectedDate, planStatusCtrl.currentIteration); planStatusPopCtrl.close()']"
PLAN_STATUS_WORKPATTERN_NOT_MAPPED_MSG = ".workPatternNotMapped"
PLAN_STATUS_GENERATE_OPTIMIZED_SCHEDULE_BUTTON = 'button[ng-click="planStatusCtrl.generateSchedule(planStatusCtrl.selectedUnit,planStatusCtrl.selectedDate,planStatusCtrl.planStatusConstants.scheduleGenType.OPTIMIZED_SCHEDULE,0,0)"]'
PLAN_STATUS_GENERATE_OPTIMIZED_SCHEDULE_BUTTON_CHECK = '//button[contains(@ng-click, "OPTIMIZED_SCHEDULE")]//img[contains(@ng-src, "check-icon.png")]'
PLAN_STATUS_GENERATE_SCHEDULE_USING_TEMPLATE_BTN_ALTERNATE = "tbody tr div[ng-if='planStatusCtrl.scheduleGenerationMode != planStatusCtrl.planStatusConstants.scheduleGenType.SCHEDULE_USING_TEMPLATE'] div div:nth-child(1)"
PLAN_STATUS_NEXT_WEEK_BTN = "span[title='Next Week']"
PLAN_STATUS_CAL_NAV_DATE_LABEL = "//span[@ng-click='planStatusCtrl.onDateLabelClick()']"
PLAN_STATUS_DELETE_SCHD = "//button[@title='Delete Schedule']"
PLAN_STATUS_RAILROAD_DRPDWN = "//span[@class='menu-wrapper-dropdown']/span[@ng-click='railRoadCtrl.showRailRoad =!railRoadCtrl.showRailRoad ' or @id='btn-railroad-toggle']"
PLAN_STATUS_PLAN_STATUS_OPTION = "//span[contains(text(),'Plan Status')]"
PLAN_STATUS_PLAN_TITLE = "//td[@id='railRoad']/span[contains(text(),'Plan Status')]"
PLAN_STATUS_PAGE_DATE_LABEL = "//span[contains(text(), '{DATE}')]"
PLAN_STATUS_MAIN_PAGE_CONTAINER = "//div[@class='ws-main-page-container']"
PLAN_STATUS_BATCH_QUEUE_SECTION = "//table[@class='ws-table']//tr[contains(@ng-if,'planStatusCtrl.unitsActiveStatusBatchMap')]"
PLAN_STATUS_FORECAST_TABLE_HEADER = "//table[@id='summaryHdrTab']"
PLAN_STATUS_FORECAST_TABLE_BODY = "//td[@class='ws-cell'][1]"
PLAN_STATUS_EMPTY_BATCH = "//div[contains(@ng-if,'unitsActiveStatusBatchMap') and text()]"
