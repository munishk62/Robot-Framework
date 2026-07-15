PAYROLL_STATUS_PAGE_FILTER_ICON = "//img[@id='filterImg']"
PAYROLL_STATUS_PAGE_RELEASE_STATUS = (
    "//select[@class='ipfield v5-filter-select v5-cus-select']"
)
PAYROLL_STATUS_PAGE_YEAR = "//select[@id='year']"
PAYROLL_STATUS_PAGE_QUARTER = "//select[@id='quarter']"
PAYROLL_STATUS_PAGE_PERIOD = "//select[@id='period']"
PAYROLL_STATUS_PAGE_WEEK = "//select[@id='week']"
PAYROLL_STATUS_PAGE_APPLY = "//input[@type='button' and @id='apply']"
PAYROLL_STATUS_PAGE_RELEASED_COUNT = "//td[text()='{TARGET_WEEK}']//following-sibling::td[1]/a[text()='{STORE_NAME}']//ancestor::td//following-sibling::td[1]"
PAYROLL_STATUS_PAGE_OPEN_COUNT = "//td[text()='{TARGET_WEEK}']//following-sibling::td[1]/a[text()='{STORE_NAME}']//ancestor::td//following-sibling::td[2]"
PAYROLL_STATUS_PAGE_TOTAL_COUNT = "//td[text()='{TARGET_WEEK}']//following-sibling::td[1]/a[text()='{STORE_NAME}']//ancestor::td//following-sibling::td[3]"
PAYROLL_STATUS_PAGE_STORE_LINK = (
    "//td[text()='{TARGET_WEEK}']//following-sibling::td[1]/a[text()='{STORE_NAME}']"
)
PAYROLL_STATUS_PAGE_STORE_LEVEL_STORE_LINK = "//span[text()='{TARGET_WEEK}']//parent::div//parent::td//parent::tr//following-sibling::tr//td[1]//span//a[text()='{STORE_NAME}']"
PAYROLL_STATUS_PAGE_DEPT_LEVEL_DEPT_LINK = "//div[@id='gridbox_emp_tc_pay_status']/div[2]//following-sibling::tr[1]//span[text()='{DEPT_NAME}']//preceding-sibling::img[2]"
PAYROLL_STATUS_PAGE_DEPT_LEVEL_ASSOCIATE_LIST = (
    "//a[@class='tblrow-sp v5-pad0-lt display']"
)
PAYROLL_STATUS_PAGE_SPINNER = "//div[@id='bulkSignOffSpinner']//img"
