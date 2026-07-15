# filepath: resources/web/admin/requests_page.py
# Requests Page elements

# Other elements
REQUESTSPAGE_START_DATE = "input#stDate"
REQUESTSPAGE_END_DATE = "input#edDate"
REQUESTSPAGE_REQUEST_STATUS = "select#requestStatus"
REQUESTSPAGE_REASON = "select#entitlementCode"
REQUESTSPAGE_TYPE = "select#offType"
REQUESTSPAGE_DEPARTMENT = "select#staffDept"
REQUESTSPAGE_PROFILE = (
    "//td[normalize-space()='Profile']/following::select[@id='profilesList']"
)
REQUESTSPAGE_PROFILE_OPTIONS = "//td[normalize-space()='Profile']/following::select[@id='profilesList']/option[normalize-space(translate(text(), '\u00a0', ''))='{PROFILE_OPTION}']"
REQUESTSPAGE_NOTIFICATION_MESSAGE_VERIFY = (
    "#info_message.succ_bg .info_message_text .succ_bg_text"
)
REQUESTSPAGE_REQUEST_LOCATOR = "(//a[contains(@aria-label,'{ASSOCIATE_NAME}') and contains(@aria-label,'From {START_FORMATTED}') and contains(@aria-label,'To {END_FORMATTED}') and contains(@aria-label,'{REQUEST_STATUS}')]/following::td[contains(@aria-label,'{REASON_TYPE}')]/following::td[contains(@name,'Status')])[1]"
REQUESTSPAGE_SPECIFIC_REQUEST_STATUS_DROP_DOWN = "(//a[contains(@aria-label,'{ASSOCIATE_NAME}') and contains(@aria-label,'From {START_FORMATTED}') and contains(@aria-label,'To {END_FORMATTED}') and contains(@aria-label,'{REQUEST_STATUS}')]/following::td[contains(@aria-label,'{REASON_TYPE}')]/following::td[contains(@name,'Status')])[1]/select"
REQUESTSPAGE_REQUEST_STATUS_OPTION = "(//a[contains(@aria-label,'{ASSOCIATE_NAME}') and contains(@aria-label,'From {START_FORMATTED}') and contains(@aria-label,'To {END_FORMATTED}') and contains(@aria-label,'{REQUEST_STATUS}')]/following::td[contains(@aria-label,'{REASON_TYPE}')]/following::td[contains(@name,'Status')])[1]/select/option[normalize-space(translate(text(), '\u00a0', ''))='{STATUS_VALUE}']"
REQUESTSPAGE_ANY_REQUEST_BY_ASSOCIATE_AND_DATE = "//a[contains(@aria-label,'{ASSOCIATE_NAME}') and contains(@aria-label,'From {START_FORMATTED}') and contains(@aria-label,'To {END_FORMATTED}')]"
REQUESTSPAGE_STATUS_UPDATE_SUCCESS_TOAST_POPUP = (
    "//span[normalize-space()='Request Successfully Updated']"
)
# Button elements
REQUESTSPAGE_CLEAR_ALL_FILTERS_BUTTON = "#btnClearSelection"
REQUESTSPAGE_APPLY_BUTTON = (
    "button.btn.btn-primary.operation-btn.width-20-percent.ws-m-l-10 "
)
REQUESTSPAGE_LOADING_PROGRESS_BAR = "//div[@id='dLoading']"
REQUESTSPAGE_SAVE_BUTTON = (
    "button.btn.btn-primary.float-right.operation-btn.width-100px.ws-m-r-10.ws-m-b-10"
)