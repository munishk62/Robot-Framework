USER_PAGE_ADD_USER_BTN = "//iframe[@id='usersListIframe'] >>> #addUserId"
USER_PAGE_USER_ID_TXT = "//iframe[@id='usersListIframe'] >>> //input[@name='userId']"
USER_PAGE_USER_NAME_TXT = (
    "//iframe[@id='usersListIframe'] >>> //input[@name='userName']"
)
USER_PAGE_USER_PASSWORD_TXT = (
    "//iframe[@id='usersListIframe'] >>> //input[@name='password']"
)
USER_PAGE_USER_STATUS_LIST = "//iframe[@id='usersListIframe'] >>> id=status"
USER_PAGE_USER_WORKS_IN_LIST = "//iframe[@id='usersListIframe'] >>> id=worksIn"
USER_PAGE_ADD_USER_PREVIOUS_BTN = (
    "//iframe[@id='usersListIframe'] >>> //button[@id='userList']"
)
USER_PAGE_USER_SAVE_BTN = "//iframe[@id='usersListIframe'] >>> //button[@id='save']"
USER_PAGE_USER_LIST_LNK = "//iframe[@id='usersListIframe'] >>> //img[@id='filterImg']"
USER_PAGE_USER_SEARCH_CLEAR_BTN = (
    "//iframe[@id='usersListIframe'] >>> //button[normalize-space()='Clear']"
)
USER_PAGE_USER_SEARCH_USER_ID = "//iframe[@id='usersListIframe'] >>> id=userId"
USER_PAGE_USER_SEARCH_APPLY_BTN = (
    "//iframe[@id='usersListIframe'] >>> //button[normalize-space()='Apply']"
)
USER_PAGE_USER_SEARCH_RESULT = (
    "//iframe[@id='usersListIframe'] >>> //span[contains(text(), ' of  1')]"
)
USER_PAGE_UNIT = (
    "//iframe[@id='usersListIframe'] >>> //input[@id='dataListSearchTextField']"
)
USER_PAGE_UNIT_OPTION = "//iframe[@id='usersListIframe'] >>> //div[@id='CORP']"
USER_PAGE_PROFILE_NAME_SYSADMIN_CHK = (
    "//iframe[@id='usersListIframe'] >>> //input[@id='SYSADMIN']"
)
USER_PAGE_DEPARTMENT_CORP_CHK = (
    "//iframe[@id='usersListIframe'] >>> (//input[@id='checkBox#deptIds#CORP' or @id='checkBox#deptIds#HEAD'])[1]"
)
USER_PAGE_RECOVERY_EMAIL_ID_TXT = (
    "//iframe[@id='usersListIframe'] >>> //input[@id='recoveryEmailId']"
)
USER_PAGE_USER_NAVIGATION_LNK = "//iframe[@id='usersListIframe'] >>> //a[normalize-space()='{automation_user_name}']"
USER_PAGE_USER_EDIT_PAGE_HEADER = (
    "//iframe[@id='usersListIframe'] >>> //span[normalize-space()='User ID :']"
)
USER_PAGE_USER_DELETE_BTN = (
    "//iframe[@id='usersListIframe'] >>> //button[@id='deleteUser']"
)
USER_PAGE_USER_DELETED_STATUS_LBL = (
    "//iframe[@id='usersListIframe'] >>> //td[normalize-space()='INACTIVE']"
)
USER_PAGE_ERROR_MESSAGE = "//div[@class='errorMessage']"
USER_PAGE_ERROR_RED_MESSAGE = "//td[@id='invalidUserCredentials']"
USER_PAGE_USER_DETAILS_LINK = "//iframe[@id='usersListIframe'] >>> //tbody[@id='usersSearchResult']/tr/td[normalize-space()='{USER_ID}']/following-sibling::td/a"
USER_PAGE_USER_NEW_PASSWORD_FIELD = "//input[@id='newPassword']"
USER_PAGE_USER_RETYPE_PASSWORD_FIELD = "//input[@id='retypePassword']"
USER_PAGE_USER_SECURITY_QUESTION_DROPDOWN = "//select[@id='question_{DROPDOWN}']"
USER_PAGE_USER_SECURITY_ANSWER_FIELD = "//input[@id='securityQuestion_{ANSWER}']"
USER_PAGE_USER_RESET_SAVE_BTN = "//button[@id='saveId']"
USER_PAGE_USER_RESET_HEADER = "(//span[@class='subHeader'])[2]"
USER_PAGE_USER_SECURITY_QUESTION_DROPDOWN_COUNT = "//select[@name='question_']"
USER_PAGE_SPINNER = "//div[@id='spinner']"
