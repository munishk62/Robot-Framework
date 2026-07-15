USER_PROFILE_MENU_PROFILE_ICON = "#userSettings"
USER_PROFILE_MENU_LOGOUT_LNK = "//button[@aria-label=' Sign Out ']"
USER_PROFILE_MENU_SWITCH_TO_LNK = (
    "//div[@class='dd-menu-description']//a[@id='aHelpSwitchStore']"
)
MYWORK_USER_PROFILE_MENU_SWITCH_TO_LNK = "id=switch-to-button"
USER_PROFILE_MENU_SWITCH_TO_POPUP_WINDOW = "//span[@role='heading']"
MYWORK_USER_PROFILE_MENU_SWITCH_TO_POPUP_WINDOW = "//h2[text()='Switch To']"
USER_PROFILE_MENU_SWITCH_TO_HOME_ICON = "//img[@alt='RWS-My Home CORP']"
MYWORK_USERPROFILEMENU_SWITCH_TO_HOME_ICON = "//div[@id='switch-home']//img[contains(@aria-label,'Switch To')]"
USER_PROFILE_MENU_PROFILE_STORE_NAME = "//div[@class='user-settings-profile']/span[2]"
USER_PROFILE_MENU_EXPECTED_UNIT_NAME_IN_PROFILE_DETAILS = (
    "//div[@id='user-details']/div/div[contains(text(),'{UNIT_LEVEL}')]"
)
USER_PROFILE_MENU_SELECT_FIRST_AVAILABLE_UNIT = (
    "css=.ps-content div div:first-child ul li:first-child"
)
USER_PROFILE_MENU_MY_HOME = "(//a[@id='ddMenuHome'])[1]"
USER_PROFILE_MENU_MY_HOME_STORE_ADMIN = "//a[@id='aAdminHome']"
USER_PROFILE_MENU_UNIT_NAME = "css=#switch-unit-name-text"
USER_PROFILE_MENU_UNIT_ID = "css=#switch-unitId"
USER_PROFILE_MENU_USER_DESIGNATION = "//*[contains(@class,'user-designation')]"
USER_PROFILE_MENU_APPLY_BTN = "//span[normalize-space()='Apply']"
USER_PROFILE_MENU_CHECK_LOADED_DIALOG = (
    "//div[contains(@class, 'organisation-select-profile')]"
)
USER_PROFILE_MENU_USER_NAME = "css=.user-name"
USER_PROFILE_MENU_TOGGLE_HEADER = "//span[@id='spanToggleHeaderVisibility']"
USER_PROFILE_MENU_USER_SETTINGS_PROFILE = "//div[@class='user-settings-profile']"
MYWORK_USERPROFILEMENU_PROFILE_ICON = "#user-details"
USERPROFILEMENU_LANGUAGE_LOCATOR = "css=span.grey-label.mr-2"
USERPROFILEMENU_CHANGE_LANGUAGE_DROPDOWN_OPTION = "css=#languages-button"
USER_PROFILE_MENU_LOGOUT_LINK = (
    "//button[@id='rfxHeaderSignOutButton'] | //button[@id='sign-out-button']"
)