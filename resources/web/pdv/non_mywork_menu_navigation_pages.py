BREADCRUMB_OPEN_ICON = "table#sideMenu li[data] p >> nth=0"
BREADCRUMB_EXPAND_ICON = "//a[@id and @aria-label='Expand Menu']"
PARENT_PAGES = "//a[@class='a-navigation-string']/img[@alt]/following-sibling::p"
CHILD_PAGES = "//ul[@role='menu' and contains(@style, 'display: block;')]/li[@role='menuitem' and not(contains(@style, 'display: none;'))]/a"