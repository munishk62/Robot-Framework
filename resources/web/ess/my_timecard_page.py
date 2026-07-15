from utils.dynamic_locator_loader import apply_environment_locators

MY_TIMECARD_PAGE_LEGEND_ICON = "//img[@title='Legend']"
MY_TIMECARD_PAGE_LEGEND_TIMECARD_STATUS = "//b[normalize-space()='Timecard Status']"
MY_TIMECARD_PAGE_LEGEND_TRANSACTION_TYPES = "//b[normalize-space()='Transaction Types']"
MY_TIMECARD_PAGE_LEGEND_TIME_GRID = "//b[normalize-space()='Time Grid']"
MY_TIMECARD_PAGE_LEGEND_RAW_PUNCHES_GRID = "//b[normalize-space()='Raw Punches Grid']"
MY_TIMECARD_PAGE_LEGEND_AUDIT_GRID = "//b[normalize-space()='Audit Grid']"
MY_TIMECARD_PAGE_TIME_GRID = "//div[@id='gridbox']"
MY_TIMECARD_PAGE_WEEK_LABEL = "//span[@class='ui-selectmenu-text']"
MY_TIMECARD_PAGE_LEGEND_CLOSE_BUTTON = (
    "(//button[@title='Close'][normalize-space()='Close'])[3]"
)
MY_TIMECARD_PAGE_LEGEND_TIMECARD_STATUS_FIRST_ICON = "(//b[normalize-space()='Timecard Status']//ancestor::tr//following-sibling::tr//img)[1]"
MY_TIMECARD_PAGE_LEGEND_TIMECARD_STATUS_FIRST_LABEL = "(//b[normalize-space()='Timecard Status']//ancestor::tr//following-sibling::tr//td/following-sibling::td)[1]"
MY_TIMECARD_PAGE_LEGEND_TRANSACTION_TYPES_FIRST_ICON = "(//b[normalize-space()='Transaction Types']//ancestor::tr//following-sibling::tr//img)[1]"
MY_TIMECARD_PAGE_LEGEND_TRANSACTION_TYPES_FIRST_LABEL = "(//b[normalize-space()='Transaction Types']//ancestor::tr//following-sibling::tr//td/following-sibling::td)[1]"
MY_TIMECARD_PAGE_LEGEND_TIME_GRID_FIRST_ICON = (
    "(//b[normalize-space()='Time Grid']//ancestor::tr//following-sibling::tr//img)[1]"
)
MY_TIMECARD_PAGE_LEGEND_TIME_GRID_FIRST_LABEL = "(//b[normalize-space()='Time Grid']//ancestor::tr//following-sibling::tr//td/following-sibling::td)[1]"
MY_TIMECARD_PAGE_LEGEND_RAW_PUNCHES_GRID_FIRST_ICON = "(//b[normalize-space()='Raw Punches Grid']//ancestor::tr//following-sibling::tr//img)[1]"
MY_TIMECARD_PAGE_LEGEND_RAW_PUNCHES_GRID_FIRST_LABEL = "(//b[normalize-space()='Raw Punches Grid']//ancestor::tr//following-sibling::tr//td/following-sibling::td)[1]"
MY_TIMECARD_PAGE_LEGEND_AUDIT_GRID_FIRST_ICON = (
    "(//b[normalize-space()='Audit Grid']//ancestor::tr/following-sibling::tr//td)[1]"
)
MY_TIMECARD_PAGE_LEGEND_AUDIT_GRID_FIRST_LABEL = "(//b[normalize-space()='Audit Grid']//ancestor::tr/following-sibling::tr//td[2])[1]"
MY_TIMECARD_PAGE_AUDIT_TAB = "//span[normalize-space()='Audit']"
MY_TIMECARD_PAGE_AUDIT_TAB_CHANGE_LOG = "//iframe[@id='iframe_tcard_audit'] >>> //b[normalize-space()='Change Log'] | //div[@id='gridbox_timecard_audit']/descendant::b[normalize-space()='Change Log']"
MY_TIMECARD_PAGE_AUDIT_TAB_SPECIFIC_RECORD_TIME = "//iframe[@id='iframe_tcard_audit'] >>> (//div[@id='gridbox_timecard_audit']//tr[contains(@class,'_light')]//td[contains(text(),'{AUDIT_DATE}')])[1]"
MY_TIMECARD_PAGE_AUDIT_TAB_SPECIFIC_RECORD_ACTION = "//iframe[@id='iframe_tcard_audit'] >>> (//div[@id='gridbox_timecard_audit']//tr[contains(@class,'_light')]//td[contains(text(),'{AUDIT_DATE}')])[1]//following-sibling::td[4]"
MY_TIMECARD_PAGE_AUDIT_TAB_SPECIFIC_RECORD_SHIFT_TIME = "//iframe[@id='iframe_tcard_audit'] >>> (//div[@id='gridbox_timecard_audit']//tr[contains(@class,'_light')]//td[contains(text(),'{AUDIT_DATE}')])[1]//following-sibling::td[7]"
MY_TIMECARD_PAGE_AUDIT_TAB_SPECIFIC_RECORD_LOCATION = "//iframe[@id='iframe_tcard_audit'] >>> (//div[@id='gridbox_timecard_audit']//tr[contains(@class,'_light')]//td[contains(text(),'{AUDIT_DATE}')])[1]//following-sibling::td[8]"
MY_TIMECARD_PAGE_PAY_RESULTS_TAB = "//span[normalize-space()='Pay Results']"
MY_TIMECARD_PAGE_PAY_RESULTS_TAB_DATE = (
    "//iframe[@id='iframe_pay_results'] >>> //span[normalize-space()='Date']"
)
MY_TIMECARD_PAGE_TIMECARD_TAB = "//span[normalize-space()='Timecard']"
MY_TIMECARD_PAGE_TIMECARD_GRID_DATE_FIELD = (
    "(//div[@id='gridbox']//table//tr//td//div[contains(@class,'hdrcell')])[1]"
)
MY_TIMECARD_PAGE_TIMECARD_GRID_SCHEDULE_FIELD = (
    "(//div[@id='gridbox']//table//tr//td//div[contains(@class,'hdrcell')])[4]/center"
)
MY_TIMECARD_PAGE_TIMECARD_GRID_ACTUAL_FIELD = (
    "(//div[@id='gridbox']//table//tr//td//div[contains(@class,'hdrcell')])[5]/center"
)
MY_TIMECARD_PAGE_TIMECARD_GRID_TOTAL_HRS_FIELD = (
    "(//div[@id='gridbox']//table//tr//td//div[contains(@class,'hdrcell')])[9]"
)
MY_TIMECARD_PAGE_TIMECARD_GRID_LOCATION_FIELD = (
    "(//div[@id='gridbox']//table//tr//td//div[contains(@class,'hdrcell')])[10]"
)
MY_TIMECARD_PAGE_TIMECARD_GRID_DEPARTMENT_FIELD = (
    "(//div[@id='gridbox']//table//tr//td//div[contains(@class,'hdrcell')])[11]"
)
MY_TIMECARD_PAGE_TIMECARD_GRID_ACTIVITY_FIELD = (
    "(//div[@id='gridbox']//table//tr//td[not(contains(@style,'display: none'))]//div[contains(@class,'hdrcell')])[last()-1]"
)
MY_TIMECARD_PAGE_TIMECARD_GRID_REASON_CODE_FIELD = (
    "(//div[@id='gridbox']//table//tr//td[not(contains(@style,'display: none'))]//div[contains(@class,'hdrcell')])[last()]"
)
MY_TIMECARD_PAGE_TIMECARD_GRID_RECORD_BY_DATE_TIME = "(//div[@id='gridbox']//tr[contains(@class,'_light')]//td[contains(text(),'{SHIFT_DATE}')])//following-sibling::td[4][text()='{SHIFT_TIME}']"
MY_TIMECARD_PAGE_NEXT_WEEK_BUTTON = "//img[@id='rightMove']"
MY_TIMECARD_PAGE_PREVIOUS_WEEK_BUTTON = "//img[@id='leftMove']"
MY_TIMECARD_PAGE_AUDIT_TAB_PUNCH_DELETED_INFO = "//iframe[@id='iframe_tcard_audit'] >>> (//tr[td[contains(text(),'{CURRENT_DATE}')] and td[del[contains(text(),'{PUNCH_DATE}')]] and td[contains(text(),'Deleted')] and td[del[contains(.,'{PUNCH_TIME}')]]])[1]"
MY_TIMECARD_PAGE_AUDIT_TAB_PUNCH_ADDED_INFO = "//iframe[@id='iframe_tcard_audit'] >>> (//tr[td[contains(text(),'{CURRENT_DATE}')] and td[contains(text(),'{PUNCH_DATE}')] and td[contains(text(),'Added')] and td[span[contains(text(),'{PUNCH_TIME}')]]])[1]"
MY_TIMECARD_PAGE_LOADER = "#lblPageLoadMessage"
MY_TIMECARD_PAGE_WEEKEND_DROPDOWN = "#weekend-button"
MY_TIMECARD_PAGE_WEEKEND_MENU = "#weekend-menu"
MY_TIMECARD_PAGE_LEGEND_MENU = "#legendDiv"
MY_TIMECARD_PAGE_SHOW_PUNCHES_ICON = "#punchBoxExpandView"
MY_TIMECARD_PAGE_SHOW_PUNCHES_MENU = "//span[@id='punchboxDiv']"
apply_environment_locators("my_timecard", globals())
