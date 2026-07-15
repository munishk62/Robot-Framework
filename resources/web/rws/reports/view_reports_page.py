REPORTS_VIEW_REPORTS_REPORT_LINK = (
    "//a[normalize-space()='{REPORT_NAME}']/following-sibling::span"
)
REPORTS_VIEW_REPORTS_FIELD_ID = "((//a[contains(text(),'{REPORT_NAME}')])/following::md-autocomplete[contains(@placeholder,'Search')]//input[@type='search'])[1]"
REPORTS_VIEW_REPORTS_FIELD_ID_AUTO_SUGGESTION = (
    "//ul[@class='md-autocomplete-suggestions']//span[contains(@title, '{FIELD_ID}')]"
)
REPORTS_VIEW_REPORTS_POP_UP_APPLY_BTN = "//div[@class='autoComplete' and contains(@title, '{FIELD_ID}')]/parent::div/following-sibling::div/input[@value='Apply']"
REPORTS_VIEW_REPORTS_PROGRESS_INDICATOR = (
    "//td[@valign='middle']/img[@name='progress' and @alt='Your report is running.']"
)
REPORTS_VIEW_REPORTS_STORE_REPORT_LINK = "//b[@class='ng-binding' and (normalize-space()='Store')]/parent::div/following-sibling::ul//a[normalize-space()='{REPORT_NAME}']/following-sibling::span"
REPORTS_VIEW_REPORTS_STORE_ID = "//div/b[normalize-space()='Store']/parent::div/following-sibling::ul/report/li/a[normalize-space()='{REPORT_NAME}']/parent::li//form//div//input[@type='search']"
REPORTS_VIEW_REPORTS_STORE_POP_UP_APPLY_BTN = "//div/b[normalize-space()='Store']/parent::div/following-sibling::ul/report/li/a[normalize-space()='{REPORT_NAME}']/parent::li//form//div//input[@type='button']"
REPORTS_VIEW_REPORTS_CORPORATE_POP_UP_APPLY_BTN = "//div/b[normalize-space()='Corporate']/parent::div/following-sibling::ul/report/li/a[normalize-space()='{REPORT_NAME}']/parent::li//form//div//input[@type='button']"
REPORTS_VIEW_REPORTS_CORPORATE_REPORT_LINK = "//b[@class='ng-binding' and (normalize-space()='Corporate')]/parent::div/following-sibling::ul//a[normalize-space()='{REPORT_NAME}']/following-sibling::span"
REPORTS_VIEW_REPORTS_EXPAND_ICON = "//div[@class='stdcontainer-text']//img"
REPORTS_VIEW_REPORTS_CORPORATE_REPORT_TITLE = "iframe[id='reportFrame'] >>> iframe[title='RSIframe']:last-child >>> div[lid='block_ReportName']>span"
REPORTS_VIEW_REPORTS_FIELD_REPORT_TITLE = (
    "iframe[id='reportFrame'] >>> iframe >>> div[lid='block_ReportName_NS_']>span"
)
REPORTS_VIEW_REPORTS_STORE_REPORT_TITLE = (
    "iframe[id='reportFrame'] >>> iframe >>> div[lid='block_ReportName_NS_']>span"
)
