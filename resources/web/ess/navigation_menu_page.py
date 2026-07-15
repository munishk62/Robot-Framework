ESS_PAGE_EXPAND_MENU_ICON = "//ul[@id='nav-icon1-ul']//a"
ESS_PAGE_MENU_ICON = "//li[contains(@id,'menu-ESS')]//img"
ESS_PAGE_MORE_ICON = "//li[@id='more-menu']//img"
ESS_PAGE_NAVIGATION_MODULES_TEXT = "//li[contains(@role,'menu')]//p"
ESS_PAGE_NAVIGATION_FIRST_MODULE_TEXT = "(//li[contains(@role,'menu')]//p)[1]"
ESS_PAGE_EXPANDED_MODULES_TEXT = (
    "//mat-panel-title[contains(@class,'sub-module-title')]"
)
ESS_PAGE_MY_WORK_INTEGRATED_MODULES_TEXT = "//mat-panel-title[contains(@class,'sub-module-title')][contains(text(),'{MODULE_NAME}')]/parent::span/parent::mat-expansion-panel-header/parent::mat-expansion-panel"
ESS_PAGE_EXPANDED_MODULES_FIRST_MODULE = (
    "(//mat-panel-title[contains(@class,'sub-module-title')])[1]"
)
ESS_PAGE_NAVIGATION_MODULE = "//li[contains(@role,'menu')]//p[contains(text(),'{MODULE_NAME}')]/preceding-sibling::img"
ESS_PAGE_PLEASE_WAIT_LOADER = "(//div[contains(@class,'rfx-spinner')])[1]"
ESS_PAGE_HEADER_TEXT = "(//*[contains(@class,'quickLaunchTitle') or contains(@role,'heading') or contains(@ng-if,'isEssLogin')][contains(text(),'{PAGE_HEADING}')])[1]"
ESS_PAGE_ERROR_RIBBON_NOTIFICATION = (
    "//*[contains(@class,'notify')][contains(@class,'error')]"
)
ESS_PAGE_ERROR_RIBBON_NOTIFICATION_TEXT = (
    "//*[@id='notificationMsg'][contains(@role,'alert')]"
)
