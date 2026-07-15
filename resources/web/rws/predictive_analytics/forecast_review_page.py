"""
Forecast Review Page Locators

This module contains locators for the Forecast Review page under Predictive Analytics.
"""

# Search and navigation elements
FORECAST_REVIEW_SEARCH_INPUT = "//input[@id='rflxcsspa-search-text']"
FORECAST_REVIEW_MORE_ICON = "//span[@title='More']"
FORECAST_REVIEW_EXPORT_TO_EXCEL = "//span[normalize-space()='Export To Excel']"
FORECAST_REVIEW_FILTER_ICON = "[data-testid='forecast-review-btn-forecast-filter']"
FORECAST_REVIEW_DRIVER_FILTER_BUTTON = "(//button[@id='metricId-multi-sel-btn'])[1]"
FORECAST_REVIEW_APPLY_FILTER_BUTTON = "(//button[@class='btn btn-sm btn-primary'])[1]"
FORECAST_REVIEW_DRIVER_FILTER_OPTION_BY_CODE = (
    "[data-testid='rfx-multiselect-row-resolved-option-{DRIVER_CODE}']"
)

# Driver row identification
FORECAST_REVIEW_DRIVER_ROW_BY_NAME = "//span[@role='button' and contains(normalize-space(@title), '{DRIVER_NAME}')]"
FORECAST_REVIEW_DRIVER_TABLE_BY_NAME = "//span[@role='button' and contains(normalize-space(@title), '{DRIVER_NAME}')]/ancestor::table[@role='presentation']"

# Search dropdown driver td element
FORECAST_REVIEW_DROPDOWN_DRIVER_TD = "//td[@title='{DRIVER_EXCEL_NAME} : {DRIVER_NAME}']"
FORECAST_REVIEW_DROPDOWN_TD_BY_DRIVER = "//td[@title and contains(@title, ': {DRIVER_NAME}')]"

# Last fiscal day of week column header
FORECAST_REVIEW_LAST_FISCAL_DAY_HEADER = "(//tr[@class='ws-main-header-row']/td[@role='button'])[last()]"

# Weekly Adjusted row locators
FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_INPUT = (
    "//td[text()='Weekly Adjusted']/following-sibling::td[1]//input"
)
FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_SPAN = (
    "//td[text()='Weekly Adjusted']/following-sibling::td[1]//span"
)

# Weekly Adjusted last fiscal day of week input field - using aria-label for reliability
# Format: "Driver2 for Forecast Weekly Adjusted Sat, 20 Dec"
# Uses dynamic date from header (e.g., 'Sat, 21 Feb') via LAST_DAY_OF_WEEK placeholder
FORECAST_REVIEW_WEEKLY_ADJUSTED_LAST_FISCAL_DAY_INPUT = "(//input[@type='text' and contains(@aria-label, '{DRIVER_NAME}') and contains(@aria-label, 'Weekly Adjusted') and contains(@aria-label, '{LAST_DAY_OF_WEEK}')])[1]"
FORECAST_REVIEW_WEEK_DAY_HEADERS = (
    "(//tr[@class='ws-main-header-row']/td[@role='button'])[position() > last()-7]"
)
FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_INPUT_BY_DRIVER = (
    "//table[.//span[contains(normalize-space(@title), '{DRIVER_NAME}')]]"
    "//tr[.//td[contains(normalize-space(), 'Weekly Adjusted')]]"
    "//td[contains(@class, 'ws-table-scroll-td')]//input"
)
FORECAST_REVIEW_WEEKLY_ADJUSTED_DAY_INPUT_BY_DRIVER_AND_DAY = (
    "(//input[contains(@aria-label, '{DRIVER_NAME}') and contains(@aria-label, "
    "'Weekly Adjusted') and contains(@aria-label, '{DAY_HEADER}')])[1]"
)

# Success/notification messages
FORECAST_REVIEW_SUCCESS_MESSAGE = "//div[@id='notificationMsg']"

# Dynamic driver discovery locators
FORECAST_REVIEW_ALL_DRIVER_TABLES = "//table[@role='presentation' and @ng-repeat]"
FORECAST_REVIEW_DRIVER_NAME_SPAN_BY_TABLE = "//span[@role='button' and @tabindex='-1']"
FORECAST_REVIEW_GRANULARITY_INDICATOR_BY_TABLE = "//span[contains(@class, 'Indicator') and (@title='Daily' or @title='Weekly' or @title='Minute' or @title='Annual')]"
FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_INPUT_BY_TABLE = "//td[text()='Weekly Adjusted']/following-sibling::td[1]//input"
FORECAST_REVIEW_WEEKLY_ADJUSTED_TOTAL_SPAN_BY_TABLE = "//td[text()='Weekly Adjusted']/following-sibling::td[1]//span"
FORECAST_REVIEW_MARKERS_TAB = "div[ng-bind*='Markers']"
FORECAST_REVIEW_ADD_MARKER_TAB = "div[ng-bind*='Add Marker']"
