COMMON_REQUESTS_CALENDAR_DATE_PICKER_MONTH_HEADING = (
    "//button[contains(@class,'datePickerDayHeader')]"
)
COMMON_REQUESTS_CALENDAR_DATE_PICKER_YEAR_HEADING = (
    "//button[contains(@class,'datePickerMonthHeader')]"
)
COMMON_REQUESTS_CALENDAR_DATE_PICKER_YEAR_LOCATOR = (
    "//td//button[contains(@class,'btn-default')]/span[text()='{YEAR_TWO_DIGITS}']"
)
COMMON_REQUESTS_CALENDAR_DATE_PICKER_MONTH_LOCATOR = (
    "//td//button[contains(@class,'btn-default')]/span[text()='{MONTH_NAME}']"
)
COMMON_REQUESTS_CALENDAR_DATE_PICKER_DAY_LOCATOR = (
    "//td//button[contains(@aria-label,'{SHORTENED_MONTH}')]/span[text()='{DATE}']"
)
COMMON_REQUESTS_CALENDAR_DATE_PICKER_SELECTION_MODE=(
    "//div[@ng-switch='datepickerMode']"
)
COMMON_NOTIFICATION_MESSAGE = "div#info_message, div.rfx-notify-message"
