requestAddDayOffButton = "requests.add.title"
requestFilter = "requests.title.quick_filter.dayoff"
requestTimeoff = "requests.title.quick_filter.timeoff"
requestStartDate = "requests.add.label.start_date"
requestEndDate = "requests.add.label.end_date"
reasonLabel = "requests.add.label.reason"
requiredLabel = "common.semantics.label.required"
selectLabel = "common.semantics.label.select"
note = "common.label.notes"
submitButton = "common.label.submit"
holidayHoursLabel = "requests.details.label.holiday_hours"
requestPending = "requests.title.pending"
requestApproved = "requests.title.approved"
requestDeclined = "requests.title.declined"
requestCancelled = "requests.title.cancelled"
requestDelete = "common.label.delete"
requestEdit = "common.label.edit"
requestCancel = "common.label.cancel"
requestCancelYes = "common.label.yes"
requestDayOffList = "requests.semantics.list.day_off"
requestTimeOffList = "requests.semantics.list.time_off"
requestSuccessMessage = "request.success.message"
requestStartTime = "requests.add.label.start_time"
requestEndTime = "requests.add.label.end_time"
requestHourField = "common.hour.label"
requestMinuteField = "common.minute.label"
requestTimeOkButton = "common.label.ok"
requestConflictLabel = "requests.add.title.sch_conflicts"
requestNotPresentLabel = "request.list.none"
requestFilterWindowHeader = "requests.label.filter"
requestFilterDateRangeLabel = "requests.filter.label.date_range"
requestFrom = "requests.filter.label.from"
requestTo = "requests.filter.label.to"
request_cancel_confirm_window_title = "requests.cancel.confirmation.title"
request_delete_confirm_window_title = "requests.details.delete.confirmation.title"
request_details_window_title = "requests.title.request_details"
request_edit_window_title = "requests.edit.title"

# Native ESS
date_locator = '//*[contains(@content-desc,"Select Day")]'
month_locator = '//*[contains(@content-desc,"Select Month")]'
year_locator = '//*[contains(@content-desc,"Select Year")]'
ok_button = '//*[@resource-id and substring-after(@resource-id, ":id/")="buttonRight"]'
filter_icon = (
    '//*[@resource-id and substring-after(@resource-id, ":id/")="requestFilterTv"]'
)
hour_locator = '//*[@resource-id and substring-after(@resource-id, ":id/")="picker_one_time"] | //*[@resource-id and substring-after(@resource-id, ":id/")="hoursPicker"] | //XCUIElementTypeTable[1]'
minute_locator = '//*[@resource-id and substring-after(@resource-id, ":id/")="picker_two_time"] | //*[@resource-id and substring-after(@resource-id, ":id/")="minutesPicker"] | //XCUIElementTypeTable[2]'
am_pm_locator = '//*[@resource-id and substring-after(@resource-id, ":id/")="picker_three_time"] | //*[@resource-id and substring-after(@resource-id, ":id/")="meridianPicker"] | //XCUIElementTypeTable[3]'
all_day_switch = '//*[@type="XCUIElementTypeSwitch"]'
add_notes_native = (
    '//*[contains(@label,"{0}")]//following-sibling::XCUIElementTypeTextView'
)
request_start_date_native = (
    '//*[contains(@label,"{0}")]//following-sibling::XCUIElementTypeButton'
)
date_calendar = '//XCUIElementTypeCell[contains(@label,"{0}")]'
request_list_ios = '//XCUIElementTypeCell[./*[@label="{0}"] and ./*[@name="{1}"] and ./XCUIElementTypeImage[@label="{2}"]]'
edit_locator = '//*[contains(@resource-id,"action_legend")]'
edit_dayoff_start_date = '//*[contains(@resource-id,"etStartDate")]'
edit_dayoff_end_date = '//*[contains(@resource-id,"endDateEdt")]'
day_off_locator_values = '//*[contains(@content-desc,"{0}") and contains(@content-desc, "{1}") and contains(@content-desc, "{2}") and contains(@content-desc, "{3}")]'
day_off_list_ios = (
    '//XCUIElementTypeCell[./*[@label="{0}"] and ./*[contains(@label,"{1}")]]'
)
approval_due_by = '//XCUIElementTypeStaticText[(@label="{0}")] | //*[(@name="{0}")]'
time_off_list = '//XCUIElementTypeCell/XCUIElementTypeOther[./*[contains(@name, "{0}")] and ./*[contains(@name,"{1}") and contains(@name,"{2}") and contains(@name,"{3}")]]'
time_off_list_android = '//android.widget.LinearLayout[android.widget.LinearLayout[android.widget.TextView[contains(@text,"{0}")]] and android.widget.TextView[contains(@text,"{1}")] and android.widget.TextView[contains(@text,"{4}")]]'
all_day_switch_android = '//android.widget.Switch[contains(@content-desc, "{0}")]'
holiday_hours_button = (
    '//android.widget.TextView[contains(@resource-id, "HolidayHoursSubmit")]'
)
time_off_list_ess = '//XCUIElementTypeCell[./*[@name="{0}"] and ./*[contains(@name,"{1}") and contains(@name,"{2}") and contains(@name,"{3}")]]'
holiday_hours_label_android = (
    '//android.widget.EditText[contains(@resource-id, "day{0}")]'
)
