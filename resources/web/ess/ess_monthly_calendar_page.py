# ESS My Monthly Calendar page locators
ESS_MONTHLY_CALENDAR_BUTTON = (
    "//span[contains(@ng-bind, 'Ctrl.selectedScheduleDateUILabel')]"
)
# Dynamic shift container locator with date (e.g., 'Feb 04 2026')
ESS_MONTHLY_CALENDAR_SHIFT_CONTAINER_BY_DATE = (
    "//div[@class='shiftContainer' and contains(@aria-label, '{DATE} Shift')]"
)
ESS_MONTHLY_CALENDAR_PAGE_DATE_PICKER_POPUP = "//div[@class='uib-datepicker']"
ESS_MONTHLY_CALENDAR_PAGE_FILTER_ICON = "//span[contains(@class, 'iconFilter')]"
ESS_MONTHLY_CALENDAR_PAGE_FILTER_DIALOG = "#filterDialog"
ESS_MONTHLY_CALENDAR_PAGE_LEGEND_ICON = "//span[@id='essQLaunchLegendButton']"
ESS_MONTHLY_CALENDAR_PAGE_LEGEND_POPUP = "#legendDialog"
ESS_MONTHLY_CALENDAR_PAGE_ACTION_BUTTON = "#essQLaunchActionButton"
ESS_MONTHLY_CALENDAR_PAGE_ACTION_BUTTON_MENU = "#actionButtonMenu"
ESS_MONTHLY_CALENDAR_PAGE_BALANCE_DATE_PICKER = "//span[contains(@ng-click, 'balanceDatepickerPopUpOpen')]"
ESS_MONTHLY_CALENDAR_PAGE_BALANCE_DATE_PICKER_POPUP = ".datepickerContainer>ul"
ESS_MONTHLY_CALENDAR_PAGE_SCHEDULE_LNK = "//div[@class='ess-table']//div/span[contains(@ng-bind, 'Schedule')]"