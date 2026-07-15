DRIVER_FORECAST_FORWARD_ARROW = ".glyphicon-chevron-right"
DRIVER_FORECAST_BACKWARD_ARROW = ".glyphicon-chevron-left"
DRIVER_FORECAST_SELECTED_WEEK = "//span[text()='{WEEK}']"
DRIVER_FORECAST_PAGE_CAL_NAV_DATE_LABEL = (
    "//td[contains(@class, 'calendarNav')]/span[2]"
)

# Forecast table elements
DRIVER_FORECAST_ROW_BY_TITLE = "//td[@title='{DRIVER_NAME}']"
DRIVER_FORECAST_EXPORT_ICON = "//img[@title='Export']"
DRIVER_FORECAST_SELECTED_DATE_LABEL = (
    "span[ng-bind='railRoadCtrl.selectedScheduleDateUILabel']"
)
DRIVER_FORECAST_SATURDAY_HEADER = (
    "//td[@id='tdFixedHeader' and contains(text(), 'Sat,')]"
)
DRIVER_FORECAST_SATURDAY_INPUT_BY_DRIVER_DATE = "({ROW_LOCATOR}/ancestor::table//input[@type='text' and contains(@id, '{DRIVER_ID}_0_{DATE}_S_')])[last()]"
# Dynamic driver discovery locators
DRIVER_FORECAST_SUMMARY_ALL_ROWS = "//table[@id='summaryContentTab']//tr[td[@title]]"
DRIVER_FORECAST_STF_PLANNED_HEADER = "(//td[@id='tdFixedHeader' and normalize-space(text())='STF Planned'])[1]"
