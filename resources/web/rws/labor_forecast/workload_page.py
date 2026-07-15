# Workload Page Locators
# This file contains locators for the Workload page (activity-based workload verification)

WORKLOAD_PAGE_ACTIVITY_WORKLOAD_BY_DAY = "((//td[contains(@data-testid,'labor-forecast-page-cell-weekly-grid-above-store-week')])/following::span[contains(@aria-label,'workload of {ACTIVITY_NAME}')])[{DAY_NUMB}]"


