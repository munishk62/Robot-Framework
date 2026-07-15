MY_SCHEDULE_PAGE_NEXT_WEEK_ICON = "//span[@aria-label='Next Week']"
MY_SCHEDULE_PAGE_SCHEDULE_NOT_PUBLISHED_MESSAGE = (
    "//span[normalize-space()='Schedule is Not Published for the selected']"
)
MY_SCHEDULE_PAGE_WEEK_LABEL = "//span[contains(@class,'weekDateLabel')]"
MY_SCHEDULE_PAGE_SUMMARY_HEADER_FIELD = (
    "//span[@class='statName' and contains(text(),'{HEADER_NAME}')]"
)
MY_SCHEDULE_PAGE_DETAILS_HEADER_FIELD = "//div[@class='gridHeader']//div[@role='columnheader' and contains(text(),'{HEADER_NAME}')]"
MY_SCHEDULE_SCHD_NOT_PUBLISHED_MSG = (
    "//span[@ng-bind=\"essCtrl.i18nFn('Schedule is Not Published for the selected')\"]"
)
MY_SCHEDULE_PAGE_DAY_SHIFT_CONTAINER = "(//div[@role='cell' and contains(@class, 'dateContainer ')])[{DAY_SHIFT}]/following-sibling::div[2]"
MY_SCHEDULE_PAGE_PRINT_ICON = "span#essQLaunchPrintButton"
MY_SCHEDULE_PAGE_PRINT_BUTTON_MENU = "//div[@id='printButtonMenu']"
MY_SCHEDULE_PAGE_PDF_ICON = "span#essQLaunchPdfButton"
MY_SCHEDULE_PAGE_PDF_BUTTON_MENU = "//div[@id='pdfButtonMenu']"
MY_SCHEDULE_PAGE_LINE_VIEW_ICON = "//span[contains(@class, 'iconLineView')]"
MY_SCHEDULE_PAGE_LIST_VIEW_ICON = "//span[contains(@class, 'iconListView')]"
MY_SCHEDULE_PAGE_LEGEND_ICON = "//span[@id='essQLaunchLegendButton']"
MY_SCHEDULE_PAGE_LEGEND_POPUP = "//div[@id='legendDialog']"
MY_SCHEDULE_PAGE_SUMMARY_ICON = "//span[@id='summaryButton']"
MY_SCHEDULE_PAGE_DATE_PICKER_POPUP = "//div[@class='uib-datepicker']"
MY_SCHEDULE_PAGE_TIMECARD_LNK = "//span[@class='statName' and contains(@ng-bind, 'Timecard')]"