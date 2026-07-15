# filepath: web\resources\payroll\release_checks_page_locators.py
# Release Checks elements

RELEASECHECKSPAGE_PAYROLL_CHECKSETS_ADD_BTN = (
    "//div[@id='payrollchecksets']/ancestor::tr[1]/following-sibling::tr[1]/td/input"
)
RELEASECHECKSPAGE_CHECKSET_ID_TXTBOX = "#rulesetId"
RELEASECHECKSPAGE_CHECKSET_NAME_TXTBOX = "#ruleSetName"
RELEASECHECKSPAGE_CHECKSET_DESCRIPTION_TXTBOX = "#ruleDesc"
RELEASECHECKSPAGE_SUCCESS_NOTIFIER_MSG = "//div[@id='info_message'][@class='succ_bg ']"
RELEASECHECKSPAGE_SAVE_CHECKSET_BTN = "//tr/td/input[@value='Save']"
RELEASECHECKSPAGE_PAYROLL_CHECKSETS_SECTION_TITLE = (
    "//div[@id='payrollchecksets']/ancestor::tr/preceding-sibling::tr[1]"
)
RELEASECHECKSPAGE_PAYROLL_CHECKSETS_TBL_CONTENTS = (
    "//div[@id='payrollchecksets']/div[@class='objbox']/table/tbody"
)
RELEASECHECKSPAGE_CHECKSET_STATUS_DRPDWN = "#STATUS"
RELEASECHECKSPAGE_DELETE_CHECKSET_BTN = "//tr/td/input[@value='Delete']"
RELEASECHECKSPAGE_POLICY_CHECKSETS_ADD_BTN = (
    "//div[@id='policychecksets']/ancestor::tr[1]/following-sibling::tr[1]/td/input"
)
RELEASECHECKSPAGE_POLICY_CHECKSETS_TBL_CONTENTS = (
    "//div[@id='policychecksets']/div[@class='objbox']/table/tbody"
)
RELEASECHECKSPAGE_POLICY_CHECKSETS_SECTION_TITLE = (
    "//div[@id='policychecksets']/ancestor::tr/preceding-sibling::tr[1]"
)
RELEASECHECKSPAGE_PREVIOUS_BTN = "//tr/td/input[@value='Previous']"
RELEASECHECKSPAGE_PAYROLL_CHECKSETS_TBL_CONTENT_COUNT = (
    "//div[@id='payrollchecksets']/div[@class='objbox']/table/tbody/tr"
)
RELEASECHECKSPAGE_PAYROLL_CHECKSETS_LIST_CHECKSET_ID = (
    "(//div[@id='payrollchecksets']//tbody//td[1]//a)[{INDEX}]"
)
RELEASECHECKSPAGE_PAYROLL_CHECKSETS_LIST_CHECKSET_NAME = "(//div[@id='payrollchecksets']//tbody//td[1]//a)[{INDEX}]//parent::td/following-sibling::td[1]"
RELEASECHECKSPAGE_PAYROLL_CHECKSETS_LIST_CHECKSET_STATUS = "(//div[@id='payrollchecksets']//tbody//td[1]//a)[{INDEX}]//parent::td/following-sibling::td[5]"
RELEASECHECKSPAGE_POLICY_CHECKSETS_TBL_CONTENT_COUNT = (
    "//div[@id='policychecksets']/div[@class='objbox']/table/tbody/tr"
)
RELEASECHECKSPAGE_POLICY_CHECKSETS_LIST_CHECKSET_ID = (
    "(//div[@id='policychecksets']//tbody//td[1]//a)[{INDEX}]"
)
RELEASECHECKSPAGE_POLICY_CHECKSETS_LIST_CHECKSET_NAME = "(//div[@id='policychecksets']//tbody//td[1]//a)[{INDEX}]//parent::td/following-sibling::td[1]"
RELEASECHECKSPAGE_POLICY_CHECKSETS_LIST_CHECKSET_STATUS = "(//div[@id='policychecksets']//tbody//td[1]//a)[{INDEX}]//parent::td/following-sibling::td[5]"
RELEASECHECKSPAGE_CHECKSETS_ID_LINK = "//a[normalize-space()='{CHECKSET_ID}']"
