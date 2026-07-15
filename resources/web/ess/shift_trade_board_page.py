# ESS Shift Trade Board Page elements
SHIFT_TRADE_BOARD_PAGE_SELECTED_WEEK = "//span[contains(@class,'weekDateLabel')]"
SHIFT_TRADE_BOARD_PAGE_WITHDRAW_REQUEST_OPTION = (
    "//span[normalize-space()='Withdraw Request']"
)
SHIFT_TRADE_BOARD_PAGE_WITHDRAW_REQUEST_BUTTON = (
    "//button[normalize-space()='Withdraw Request']"
)
SHIFT_TRADE_BOARD_PAGE_NEXT_WEEK_BUTTON = "//span[@aria-label='Next Week']"
SHIFT_TRADE_BOARD_PAGE_SCHEDULE_NOT_PUBLISHED_MESSAGE = (
    "//span[normalize-space()='Schedule is not published for the selected']"
)
SHIFT_TRADE_BOARD_PAGE_SCHEDULE_SUMMARY_TAB = "//label[normalize-space()='Summary']"
SHIFT_TRADE_BOARD_PAGE_ACCEPT_SWAP_BUTTON = "//button[normalize-space()='Accept Swap'] | //button[@data-testid='shift-trade-board-btn-accept-swap']"
SHIFT_TRADE_BOARD_PAGE_OFFER_SHIFT_BUTTON = "//button[normalize-space()='Offer Shift']"
SHIFT_TRADE_BOARD_PAGE_SWAP_START_TIME = (
    "//input[@id='timePickerPop' and @aria-label='Select shift start Time']"
)
SHIFT_TRADE_BOARD_PAGE_SWAP_END_TIME = (
    "//input[@id='timePickerPop' and @aria-label='Select shift end Time']"
)
SHIFT_TRADE_BOARD_PAGE_SWAP_MIN_TIME = (
    "//input[@aria-label='Select minimum shift length']"
)
SHIFT_TRADE_BOARD_PAGE_SWAP_MAX_TIME = (
    "//input[@aria-label='Select maximum shift length']"
)
SHIFT_TRADE_BOARD_PAGE_SWAP_OPTION = "//span[normalize-space()='Swap']"
SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_SHIFT = (
    "(//div[contains(@ng-repeat,'shift in shifts')])[{TEMP_INDEX}]"
)
SHIFT_TRADE_BOARD_PAGE_SWAP_NOTES = "//textarea[@id='myNotes']"
SHIFT_TRADE_BOARD_PAGE_SUBMIT_REQUEST_BUTTON = (
    "//button[contains(text(),'Submit Request')]"
)
SHIFT_TRADE_BOARD_PAGE_NOTIFICATION_MESSAGE = "//div[@class='notifyMsg']"
SHIFT_TRADE_BOARD_PAGE_SWAP_ALL_ELIGIBLE = "//span[contains(text(),'All Eligible')]"
SHIFT_TRADE_BOARD_PAGE_DAY = "//div[contains(@ng-repeat,'shift in shifts')]"
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT = "//tr//td[contains(@class,'weekDayContainer')][{DAY_INDEX}]//div[contains(@aria-label,'Open Shifts') and not(.//span[@class='available'])]"
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_WITH_TIMINGS = "//td[contains(@class,'weekDayContainer')][{DAY_INDEX}]//span[contains(text(),'{START_TIME}')]/parent::span[contains(@class,'startTime')]/following-sibling::span/span[contains(text(),'{END_TIME}')]//ancestor::div[contains(@aria-label,'Open Shifts')]"
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_RESPOND_TAB = (
    "//span[@class='tabHeader'][contains(text(),'Respond')]"
)
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_MY_RESPONSE_TAB = (
    "//div[@id='essMyResponse']//span[@class='tabHeader']"  # "//div[@data-testid='shift-trade-board-tab-my-response']"
)
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_RESPONSE_NOTES = "//textarea[@id='responseNotes']"
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_ACCEPT_BUTTON = (
    "//button[@class='primary-button'][text()='Accept']"
)
SHIFT_TRADE_BOARD_PAGE_SHIFT_PANEL_CLOSE_ICON = "//span[contains(@class,'iconXclose')]"
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_START_TIME = "//td[contains(@class,'weekDayContainer')][{DAY_INDEX}]//div[contains(@aria-label,'Open Shifts')]//span[@class='startTime']/span"
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_END_TIME = "//td[contains(@class,'weekDayContainer')][{DAY_INDEX}]//div[contains(@aria-label,'Open Shifts')]//span[@class='startTime']/following-sibling::span/span"
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_RESPONSE_CHECKMARK = "//td[contains(@class,'weekDayContainer')][{DAY_INDEX}]//span[contains(text(),'{END_TIME}')]/parent::span/preceding-sibling::span[@class='startTime']/span[contains(text(),'{START_TIME}')]/ancestor::div/following-sibling::div//span[contains(@class,'ws-iconCheckmark')]"
SHIFT_TRADE_BOARD_PAGE_OPEN_DAY_SHIFT_WITHDRAW_RESPONSE_BUTTON = (
    "//button[@class='primary-button'][text()='Withdraw Response']"
)
SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_START_TIME = (
    "//input[@aria-label='Select shift start Time']"
)
SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_END_TIME = (
    "//input[@aria-label='Select shift end Time']"
)
SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_HOURS = (
    "//input[@aria-label='Preferred Shift Length']"
)
SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_NOTES = "//input[@id='requestorNotes']"
SHIFT_TRADE_BOARD_PAGE_REQUEST_BUTTON = "//button[contains(text(),'Request')]"
SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_MY_REQUEST_OPTION = (
    "//span[normalize-space()='My Request']"
)
SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_WITHDRAW_BUTTON = (
    "//button[normalize-space()='Withdraw']"
)
SHIFT_TRADE_BOARD_PAGE_DAY_FIRST_REQUEST = "(//td[@ng-repeat='shifts in essCtrl.filteredHomeStoreTradeBoardShifts'][{TEMP_INDEX}]//div[text()='{TEMP_NAME}'])[1]"
SHIFT_TRADE_BOARD_PAGE_RESPOND_BUTTON = "//span[normalize-space()='Respond']"
SHIFT_TRADE_BOARD_PAGE_RESPONSE_TEXTBOX = "//textarea[@id='responseNotes']"
SHIFT_TRADE_BOARD_PAGE_CLOSE_BUTTON = "#closeButton"
SHIFT_TRADE_BOARD_PAGE_MY_RESPONSE_TAB = (
    "//span[normalize-space()='My Response']"
)
SHIFT_TRADE_BOARD_PAGE_EXTRA_WORK_WITHDRAW_RESPONSE_BUTTON = (
    "//button[normalize-space()='Withdraw Response']"
)
SHIFT_TRADE_BOARD_PAGE_ADVERTISE_OPTION = "//span[normalize-space()='Advertise']"
SHIFT_TRADE_BOARD_PAGE_ADVERTISE_NOTES = "//textarea[@aria-label='Add My Notes']"
SHIFT_TRADE_BOARD_PAGE_ADVERTISE_BUTTON = "//button[normalize-space()='Advertise']"
SHIFT_TRADE_BOARD_PAGE_ACCEPT_BUTTON = "//button[normalize-space()='Accept']"
SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_WITHDRAW_RESPONSE_BUTTON = (
    "//button[normalize-space()='Withdraw Response']"
)
SHIFT_TRADE_BOARD_PAGE_SWAP_ASSOCIATE_LIST = "//multiselect[@id='addAccrPolDropdown']"
SHIFT_TRADE_BOARD_PAGE_SWAP_ASSOCIATE_TEXTBOX = (
    "//input[@ng-model='searchFilter' and @aria-label='Search ']"
)
SHIFT_TRADE_BOARD_PAGE_SWAPWITH_DROPDOWN = "//button[@id='shiftDropdown']"
SHIFT_TRADE_BOARD_PAGE_SWAP_ASSOCIATE_LIST_FIRST_OPTION = (
    "//div[@class='dropdown-menu-section']/div/div[1]"
)
SHIFT_TRADE_BOARD_PAGE_SWAPWITH_FIRST_OPTION = (
    "//button[@id='shiftDropdown']/following-sibling::ul[1]"
)
SHIFTTRADEBOARD_CALENDAR_BUTTON = "//span[@role='button' and contains(@aria-label, 'Week Of') and contains(@ng-bind, 'essCtrl.selectedScheduleDateUILabel')]"
# Popup confirmation dialog elements
SHIFT_TRADE_BOARD_PAGE_CONFIRMATION_POPUP_MODAL = "//div[@class='confirmPopup modal-body' and @id='modal-body']"
SHIFT_TRADE_BOARD_PAGE_CONFIRMATION_POPUP_MESSAGE = "//div[@class='confirmPopup modal-body']//span[@class='message']"
SHIFT_TRADE_BOARD_PAGE_CONFIRMATION_POPUP_I_AGREE_BUTTON = "//button[@class='btn btn-sm btn-primary' and @type='button' and contains(text(), 'I Agree')]"

SHIFT_TRADE_BOARD_PAGE_PRINT_ICON = "span#essQLaunchPrintButton"
SHIFT_TRADE_BOARD_PAGE_PRINT_BUTTON_MENU = "//div[@id='printButtonMenu']"
SHIFT_TRADE_BOARD_PAGE_PDF_ICON = "span#essQLaunchPdfButton"
SHIFT_TRADE_BOARD_PAGE_PDF_BUTTON_MENU = "//div[@id='pdfButtonMenu']"
SHIFT_TRADE_BOARD_PAGE_LEGEND_ICON = "//span[@id='essQLaunchLegendButton']"
SHIFT_TRADE_BOARD_PAGE_LEGEND_POPUP = "//div[@id='legendDialog']"
SHIFT_TRADE_BOARD_PAGE_SUMMARY_ICON = "//span[@id='summaryButton']"
SHIFT_TRADE_BOARD_PAGE_DATE_PICKER_POPUP = "//div[@class='uib-datepicker']"
SHIFT_TRADE_BOARD_PAGE_FILTER_ICON = "//span[contains(@class, 'iconFilter')]"
SHIFT_TRADE_BOARD_PAGE_FILTER_POPUP = "//div[@id='filterDialog']"
SHIFT_TRADE_BOARD_PAGE_MY_SCHEDULE_SHIFT = (
    "(//tr[@role='row']//div[@id and @aria-label])[last()]"
)
SHIFT_TRADE_BOARD_PAGE_SHIFT_DETAILS_PANE = "//input[@id='detailedView']"
SHIFT_TRADE_BOARD_PAGE_TIME_PICKER = "//input[@id='timePickerPop']"
SHIFT_TRADE_BOARD_PAGE_TIME_PICKER_POPUP = "//div[contains(@class, 'rfxTimepickerPopDiv') and not(contains(@class, 'hidden'))]"
SHIFT_TRADE_BOARD_PAGE_MY_STORE_RADIO_BUTTON = "//label[@id='my_store']//input[@name='storeType']//following-sibling::span[@class='checkmark']"
SHIFT_TRADE_BOARD_PAGE_INDIVIDUAL_ASSOCIATE_RADIO_BUTTON = "//label[@id='individual_Ass']//input[@name='selectAssociate']//following-sibling::span[@class='checkmark']"
SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_DECLINE_BUTTON = "//button[contains(@data-testid,'shift-trade-board-btn-decline-swap')]"
SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_APPROVAL_STATUS = "//div[contains(@ng-bind,'Approval Status')]//following-sibling::span"
SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_RESPONSES_TAB = "//div[@data-testid='shift-trade-board-tab-request-responses']"
SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_OTHER_RESPONSES_TAB = "//div[@data-testid='shift-trade-board-tab-other-responses']"
SHIFT_TRADE_BOARD_PAGE_RESPONSES_RESPONDER_NAME = "//span[contains(@ng-bind,'responderName')][text()='{ASSOCIATE_NAME}']"
SHIFT_TRADE_BOARD_PAGE_RESPONSES_SHIFT_TIMINGS = "//span[text()='{ASSOCIATE_NAME}']//ancestor::tr[@class='homeResponses']//td//div[contains(@ng-bind,'getTimeString')]"
SHIFT_TRADE_BOARD_PAGE_RESPONSES_LOCATION = "//span[text()='{ASSOCIATE_NAME}']//ancestor::tr[@class='homeResponses']//td//div[contains(@ng-bind,'unitDisplayName')]"
SHIFT_TRADE_BOARD_PAGE_RESPONSES_STATUS_DECLINED = "//span[text()='{ASSOCIATE_NAME}']//ancestor::tr[@class='homeResponses']//td[@class='preferenceContainer']//span[contains(@ng-bind,'Declined')]"
SHIFT_TRADE_BOARD_PAGE_RESPONSES_STATUS = "//span[text()='{ASSOCIATE_NAME}']//ancestor::tr[@class='homeResponses']//td[@class='preferenceContainer']//img"
SHIFT_TRADE_BOARD_PAGE_SWAP_SHIFT_WITH_TIMINGS = "(//td[contains(@class,'weekDayContainer')])[{DAY_INDEX}]//span[contains(text(),'{END_TIME}')]/preceding-sibling::span[contains(text(),'{START_TIME}')]//ancestor::div[contains(@class, 'swapshift')]"
SHIFT_TRADE_BOARD_PAGE_OTHER_RESPONSES_ASSOCIATE_RESPONSE = "//span[contains(@ng-bind,'responderName')][text()='{ASSOCIATE_NAME}']//ancestor::tr//td/span[contains(@ng-bind,'responseStatus')]"
SHIFT_TRADE_BOARD_PAGE_SPINNER = "(//div[contains(@class,'rfx-spinner')]//img)[1]"