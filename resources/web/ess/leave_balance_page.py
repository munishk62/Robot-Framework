from utils.dynamic_locator_loader import apply_environment_locators

# filepath: web/resources/ess/leave_balance_page.py
# Leave Balance Page elements
LEAVE_BALANCE_PAGE_HEADING = "(//span[contains(@ng-if, 'ACCRUALBALANCE')])[1]"
LEAVE_BALANCE_PAGE_BALANCE_VALUE = "(//span[contains(text(), '{REASON}')]//parent::div//following-sibling::div[4])/span[1]"
apply_environment_locators("leave_balance", globals())
