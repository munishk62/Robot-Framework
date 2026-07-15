ALLSCHEDULESPAGE_WEEK_AVAILABILITY_INFO_ROW = (
    "//div[@id='mainContainer']//tbody[@id='tBodyContainer']/tr/td"
)
ALLSCHEDULESPAGE_DATED_UNSCHEDULED_WEEK = (
    "//td[contains(@onclick, '{DATEOFWEEK}') or contains(@data, '{DATEOFWEEK}')]"
)

# Dynamic locator templates for Update Locator functions
ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX = (
    "//div[@id='mainContainer']//tbody[@id='tBodyContainer']/tr/td[{CELL_INDEX}]"
)
ALLSCHEDULESPAGE_PUBLISHED_SCHEDULE_LOCATOR = "//span[contains(normalize-space(@aria-label), 'Published Schedule For {WEEK_DATE}')]"
ALLSCHEDULESPAGE_UNPUBLISHED_SCHEDULE_LOCATOR = "//span[contains(normalize-space(@aria-label), 'Schedule Available For {WEEK_DATE}')]"
ALLSCHEDULESPAGE_UNSCHEDULED_LOCATOR = "//div[contains(normalize-space(@aria-label), 'Schedule Unavailable For {WEEK_DATE}')]"

# Other elements
ALLSCHEDULESPAGE_YEAR = "//select[@id='cboYear']"
