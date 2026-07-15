REQUEST_TAB = '1000000000007'
ADD_REQUEST = '//*[contains(@resource-id,"btn_add_request")] | //XCUIElementTypeButton[@name="BUTTON_ADD_REQUEST"]'
PENDING_REQUESTS_LIST = '//*[contains(@resource-id, "btn_legend_request")] | //XCUIElementTypeButton[@name="Switch view to pending requests"]'
DAY_OFF = '1000000000052'
TIME_OFF = '1000000000050'
NAME_DROP_DOWN = '//*[contains(@resource-id,"etName")] | //XCUIElementTypeButton[@name="btnNameDropDown"]'
REQUEST_REASON_DROP_DOWN = '//*[contains(@resource-id,"et_Reason")] | //XCUIElementTypeButton[@name="btnReasonDropDown"]'
EDIT_REQUEST_REASON_DROP_DOWN = "//*[contains(@resource-id,'etReason')]"
REASON_VALUE = '//android.widget.TextView[@resource-id="com.reflexisinc.reflexissm43.beta:id/tv_reason_desc" and @text="{0}"] | //XCUIElementTypeStaticText[contains(@name,"{0}")]'
REQUEST_LIST = '//android.widget.TextView[@text="{0}"] | //XCUIElementTypeCell[contains(@name,"{0}")]'
START_DATE_FIELD = '//*[contains(@resource-id,"et_StartDate")] | //XCUIElementTypeButton[@name="btnStart"]'
END_DATE_FIELD = '//*[contains(@resource-id,"et_EndDate")] | //XCUIElementTypeButton[@name="btnEnd"]'
EDIT_START_DATE_FIELD = '//*[contains(@resource-id,"etStartDate")] | //XCUIElementTypeTextField[@name="etStartDate"]'
EDIT_END_DATE_FIELD = '//*[contains(@resource-id,"etEndDate")] | //XCUIElementTypeTextField[@name="etEndDate"]'
TIME_OFF_DATE_FIELD = "//*[contains(@resource-id,'et_DateTimeOff')]"
EDIT_TIME_OFF_DATE_FIELD = "//*[contains(@resource-id,'etStartDate_TimeOff')]"
START_TIME_FIELD = "//*[contains(@resource-id,'et_startTime')]"
EDIT_START_TIME_FIELD = "//*[contains(@resource-id,'etStartTime')]"
DURATION_TIME_FIELD = "//*[contains(@resource-id,'et_DurationTimeOff')]"
EDIT_DURATION_TIME_FIELD = "//*[contains(@resource-id,'etDuration')]"
END_TIME_FIELD = "//*[contains(@resource-id,'et_endTime')]"
EDIT_END_TIME_FIELD = "//*[contains(@resource-id,'etEndTime')]"
REQUEST_STATUS_DROP_DOWN = "//*[contains(@resource-id,'tv_Status')]"
TIME_OFF_REQUEST_STATUS_DROP_DOWN = '//*[contains(@resource-id,"etStatus")] | //XCUIElementTypeButton[@name="btnStatus"]'
EDIT_REQUEST_STATUS_DROP_DOWN = '//*[contains(@resource-id,"etStatus")] | //XCUIElementTypeButton[@name="btnStatus"]'
REQUESTER_NOTES = "//*[contains(@resource-id,'ibRequesterNotes')]"
APPROVER_NOTES = "//*[contains(@resource-id,'ibApproverNote')]"
SEARCH_USER_FIELD = '//*[contains(@resource-id,"searchValueEdt")] | //XCUIElementTypeImage[@label="Search"]'
NOTES_FIELD = "//*[contains(@resource-id,'etTextNotes')]"
REQUESTER_NOTE_TEXT = "//*[contains(@resource-id,'et_RequesterNotes')]"
APPROVER_NOTE_TEXT = "//*[contains(@resource-id,'et_ApproverNote')]"
EDIT_REQUESTER_NOTE_TEXT = "//*[contains(@resource-id,'etRequesterNote')]"
EDIT_APPROVER_NOTE_TEXT = "//*[contains(@resource-id,'etApproverNotes')]"
BACK_BUTTON = "//*[contains(@resource-id,'btn_home')]"
REQUEST_SAVE_BUTTON = '//*[contains(@resource-id,"btn_save")] | //XCUIElementTypeButton[@name="Save"]'
CANCEL_BUTTON = "//*[contains(@resource-id,'btn_cancel')]"
REQUEST_SUBMIT_BUTTON = '//*[contains(@resource-id,"btnSubmit")] | //XCUIElementTypeButton[@name="Submit"]'
CANCEL_BUTTON_MAIN = "//*[contains(@resource-id,'btnCancel')]"
EDIT_BUTTON = '//*[contains(@resource-id,"ib_edit_button")] | //XCUIElementTypeButton[@name="Edit"]'
DELETE_BUTTON = '//*[contains(@resource-id,"delete_button")] | //XCUIElementTypeButton[@name="Delete"]'
DECLINE_BUTTON = '//*[contains(@resource-id,"decline_button")]|//XCUIElementTypeButton[@name="{0}"]'
DECLINE_LOCALISED = '1000000000085'
APPROVE_BUTTON = '//*[contains(@resource-id,"approve_button")]|//XCUIElementTypeButton[@name="{0}"]'
APPROVE_LOCALISED = '1000000000087'
AVAIL_APPROVE_BUTTON = "//*[contains(@resource-id,'btn_approve')]"
AVAIL_DECLINE_BUTTON = "//*[contains(@resource-id,'btn_decline')]"
AVAIL_DELETE_BUTTON = "//*[contains(@resource-id,'btn_delete')]"
NEGATIVE_CONFIRM_BUTTON = '//*[contains(@resource-id,"button2")]|//XCUIElementTypeButton[@name="{0}"]'
NEGATIVE_CONFIRM_LOCALISED = '1000000000107'
POSITIVE_CONFIRM_BUTTON = '//*[contains(@resource-id,"button1")]|//XCUIElementTypeButton[@name="{0}"]'
POSITIVE_CONFIRM_LOCALISED = '1000000000139'
APPROVED_STATUS = '1000000000250'
CANCELED_STATUS = '1000000000251'
DECLINED_STATUS = '1000000000252'
EXPIRED_STATUS = '1000000001212'
NOT_REVIEWED_STATUS = '1000000000253'
SM_HOLIDAY_HOURS_BUTTON= '//android.widget.TextView[contains(@resource-id,"holidayHoursTV")]'
SM_HOLIDAY_HOURS_TITLE = '//android.widget.TextView[contains(@resource-id,"tv_title") and @text="{0}"]'
SM_HOLIDAY_HOURS_DONE_BUTTON= '//android.widget.TextView[contains(@resource-id,"btn_save")]'
SM_HOLIDAY_HRS_DAY_BY_WEEK_TEXT = '//android.widget.EditText[contains(@text,"{0} {1} {2}{3}")]'
SM_HOLIDAY_HOURS_TOTAL = '//android.widget.TextView[contains(@resource-id,"totalHrsTV") and @text="{0}"]'
SM_REQ_DAY_OFF_TOTAL_DAYS_LABEL = '1000000000048'
SM_REQ_DAY_OFF_TOTAL_DAYS = '//android.widget.EditText[@text="{0}"] | //XCUIElementTypeStaticText[@name="{0}"] | //XCUIElementTypeStaticText[@label="{0}"]'
SM_DAY_OFF_REQUEST_SINGLE_DAY = '1000000004372'
SM_DAY_OFF_REQUEST_MULTIPLE_DAYS = '1000000004373'
SM_DAY_OFF_REQUEST_SINGLE_DAY_DROPDOWN = '1000000004381'
SM_DAY_OFF_REQUEST_MULTIPLE_DAYS_DROPDOWN = '1000000004382'
SM_TIME_OFF_REQUEST = '1000000004374'
SM_DROPDOWN_MORE_OPTIONS = '1000000004200'
SM_PERMANENT_AVAILABILITY_REQUEST = '1000000004375'
SM_TEMPORARY_AVAILABILITY_REQUEST = '1000000004376'
SM_CROSS_DAY_ERROR_SNACKBAR_TITLE = '//android.widget.TextView[contains(@resource-id,"snackBarTitle")]'
SM_PENDING_REQUEST_FILTER = '1000000000264'
SM_FILTER_REQUEST_TYPE = '1000000000580'
SM_FILTER_MY_REPORTS = '1000000000668'
SM_FILTER_REPORTS_ASSOCIATE = '1000000000669'
SM_FILTER_APPLY_BUTTON = '1000000000286'
SM_MORE_OPTIONS_ARROW = '1000000000001'
SM_DECLINE_REQUEST_LABEL = '1000000000085'
SM_REQUEST_DETAILS_BACK_BUTTON = '//android.widget.ImageButton[contains(@resource-id,"ib_back_arrow")]'
SM_REQUEST_DECLINE_OPTION = '1000000000085'
SM_FILTER_MY_REPORTS_DIRECT = '1000000000670'
SM_FILTER_MY_REPORTS_INDIRECT = '1000000000671'
SM_FILTER_MY_REPORTS_MY_LOCATION = '1000000000672'

CALENDAR_BTN = '//*[contains(@resource-id,"btn_req_cal_date")]|//XCUIElementTypeButton[@name="btn_req_cal_date"]'

time_off_list = '//*[./*[contains(@name, "{0}")] and ./*[contains(@name,"{1}") and contains(@name,"{2}") and contains(@name,"{3}")]]'
