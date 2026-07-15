PAY_RULE_ENGINE_PAGE_STORE_DROPDOWN = "id=storeName"
PAY_RULE_ENGINE_PAGE_USER_ID = "id=UserId"
PAY_RULE_ENGINE_PAGE_WEEK = "id=week"
PAY_RULE_ENGINE_PAGE_COMPUTE_BTN = "css=input[type='button'][value='Compute']"
PAY_RULE_ENGINE_PAGE_CLEAR_BTN = "css=input[type='button'][value='Clear']"
PAY_RULE_ENGINE_PAGE_TOTAL_PAY = "//tr/td[@class='tblrow' and contains(text(), 'Total Pay')]/following-sibling::td[1]"
PAY_RULE_ENGINE_PAGE_COST_SEG_JOB_CODE = (
    "(//td[text()='{SHIFT_DATE}']/following-sibling::td[7])[1]"
)
PAY_RULE_ENGINE_PAGE_COST_SEG_PAY_CATEGORY = (
    "(//td[text()='{SHIFT_DATE}']/following-sibling::td[8])[1]"
)
PAY_RULE_ENGINE_PAGE_COST_SEG_PAY_HOURS = (
    "(//td[text()='{SHIFT_DATE}']/following-sibling::td[9])[1]"
)
PAY_RULE_ENGINE_PAGE_COST_SEG_PAY_COST = (
    "(//td[text()='{SHIFT_DATE}']/following-sibling::td[12])[1]"
)
PAY_RULE_ENGINE_PAGE_LOADER = "//td[@id='lblPageLoadMessage']"
PAY_RULE_ENGINE_PAGE_ASSOCIATE_DETAILS_JOBCODE = "(//table[@class='tbllines'])[2]//tr[2]/td[2]"
