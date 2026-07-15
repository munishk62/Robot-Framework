REPORTS_AUTHORIZING_PAGE_PROGRESS_BAR_LOADER = "//div[@class='ba-splash-center']"
REPORTS_AUTHORIZING_PAGE_HEADER = "//div[@class='pluginContainer']/a/span"
# ICN_IBM_COGNOS_ANALYTICS_PAGE_TAB_PROGRESSBAR_LOADER = "//div[@aria-hidden='false']//div[@role='progressbar']"
REPORTS_AUTHORIZING_PAGE_ERROR_ICON = "//img[contains(@src,'_error.gif')]"
# ICN_IBM_COGNOS_ANALYTICS_PAGE_CONTENT_PROGRESSBAR_LOADER = "//div[@class='loading_indicator']//div[@role='progressbar']"
REPORTS_AUTHORIZING_PAGE_SPINNER_ICON = (
    "//table[@class='workingDialogInnerTable']//img[@name='progress']"
)
# REPORTS_AUTHORIZING_PAGE_RE_PROMPT_OK_BTN = "//*[not(@disabled) and text()='OK' or text()='Finish' or @type='submit' or @value='OK']"
REPORTS_AUTHORIZING_PAGE_RE_PROMPT_OK_BTN = "(//*[@class='clsPromptButton'][not(@disabled)][text()='OK' or text()='Finish' or @type='submit' or @value='OK' or text()='Cancel'])[1]"
REPORTS_PAGE_LONG_LOADING_CANCEL_BTN = (
    "//td[@class='workingDialogCancelButton' and @id='btnAnchor']"
)
REPORTS_AUTHORIZING_PAGE_INTERNAL_SERVER_ERROR = (
    "(//h1[normalize-space()='Internal Server Error'] | //h1[normalize-space()='Error: Server Error'])[1]"
)
