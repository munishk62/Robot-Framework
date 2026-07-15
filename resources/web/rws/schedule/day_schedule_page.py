# Day Schedule Page elements
DAY_SCHEDULE_SCHEDULE_ROWS = "//tr[@class='empShiftRow']/td[@id='empShiftRow' and not(.//div[contains(@class, 'inactive')])]"
DAY_SCHEDULE_SHIFT_ROW = "(//tr[@class='empShiftRow']/td[@id='empShiftRow'])[{ROW_NUM}]//div//div[2]/div[@shift-templates='scheduleCtrl.shiftTemplateStaffGroupMap']/div"
DAY_SCHEDULE_SHIFT_VACANT_ROW = "(//tr[@class='empShiftRow']/td[@id='empShiftRow'])[{ROW_NUM}]//div//div[2]//div[@class='availabilityIndicatorAvailable']"
DAY_SCHEDULE_SHIFT_TEXT = (
    "(//tr[@class='empShiftRow']/td[@id='empShiftRow'])[{ROW_NUM}]"
)
DAY_SCHEDULE_SHIFT_STARTTIME_TXT = "#starTimeInput"
DAY_SCHEDULE_SHIFT_ENDTIME_TXT = "#endTimeInput"
DAY_SCHEDULE_SHIFT_ADD_ICON = "//div[@class='actions']/span[@id='inlineAddShift']"
DAY_SCHEDULE_NOTIFICATION_MSG = "div[class='rfx-notify-message success']"
DAY_SCHEDULE_SHIFT_EDIT_BTN = "id=shiftEdit"
DAY_SCHEDULE_TIMEPICKER_ENDTIME_TXT = (
    "//input[@id='timePickerPop' and not(following::input[@id='timePickerPop'])]"
)
DAY_SCHEDULE_SHIFT_EDIT_SAVE_BTN = (
    "//button[@type='button' and contains(@class, 'btn-primary') and not (@disabled)]"
)
# DAY_SCHEDULE_SHIFT_DELETE_ROW = "(//div[@tooltip-class='wage-tooltip'])[{ROW_NUM}]"
DAY_SCHEDULE_SHIFT_DELETE_BTN = "id=shiftUnallocate"
DAY_SCHEDULE_DELETE_OK_BTN = "id=okButton"
DAY_SCHEDULE_UNDO_ICON = "span[title='Undo']"
DAY_SCHEDULE_DAY_OFFSET = "(//td[contains(@class, 'weekDayLabel')])[{DAY_OFFSET}]"
DAY_SCHEDULE_ASSOCIATE_SHIFT = "//td/span[normalize-space()='{ASSOCIATE_NAME}']/ancestor::td[contains(@class, 'nameContainer pointer')]/following-sibling::td//div[@class='availabilityIndicatorContainer ']"
DAY_SCHEDULE_SHIFT_DELETE_ROW = "//td/span[normalize-space()='Store1, Associate01']/ancestor::td[contains(@class, 'nameContainer pointer')]/following-sibling::td[@id='empShiftRow']//div[@tooltip-class='wage-tooltip']"
DAY_SCHEDULE_OPEN_SHIFTS_TAB = "//span[normalize-space()='Open Shifts']"
DAY_SCHEDULE_SHIFT_TO_DELETE = "(//div[@class='timeContainer' and .//span[@class='startTime' and contains(text(),'{SHIFT_START_TIME}')] and .//span[@class='endTime' and contains(text(), '{SHIFT_END_TIME}')]])[last()]"
DAY_SCHEDULE_OPEN_SHIFTS_DELETE_TAB = "#openShiftDelete"
