# Web Clock Login Page Locators
# Contains element locators for web clock login functionality

# Clock action buttons
WEB_CLOCK_CLOCK_IN_BTN = "a#clockIn,button#clockIn"
WEB_CLOCK_CLOCK_OUT_BTN = "a#clockOut,button#clockOut"
WEB_CLOCK_MEAL_START_BTN = "a#mealStart,button#mealStart"
WEB_CLOCK_MEAL_END_BTN = "a#mealEnd,button#mealEnd"
WEB_CLOCK_BREAK_START_BTN = "a#breakStart,button#breakStart"
WEB_CLOCK_BREAK_END_BTN = "a#breakEnd,button#breakEnd"
WEB_CLOCK_PASSWORD_INPUT = "//input[@id='clockInPanelPassword']"

# Navigation buttons
WEB_CLOCK_TAP_TO_CONTINUE_BTN = "button#tapToContinue"

# Virtual keyboard for badge ID entry

# Universal locator for both numbers and characters, only visible elements
WEB_CLOCK_KEYBOARD_DIGIT_TEMPLATE = "//*[@id='actionContainer']//div[contains(@class, 'digit txt') and normalize-space(text())='{char}'] | (//*[contains(@class, 'nwc-key') and normalize-space(text())='{char}'])[1]"
# Uppercase toggle button on virtual keyboard
WEB_CLOCK_KEYBOARD_UPPERCASE_BTN = "//img[@id='localeStringB'] | //*[@data-action='caps']"


# Error messages
# Modal error message (one possible display location across scenarios)
WEB_CLOCK_ERROR_MESSAGE_MODAL = "css=#infoMsg"
# Top notification error message (alternative display location across scenarios)
WEB_CLOCK_ERROR_MESSAGE_TOP = ".center_auto .error_bg_text,#nwcSnackbar.error"

WEB_CLOCK_LOGIN_ACTIVITY = "//div[@id='activity-code-list']//button[contains(@class, 'webclock-list-item')][1]"
WEB_CLOCK_LOGIN_ACTIVITY_SUBMIT = "//button[@id='activityCodeModalSubmit']"
WEB_CLOCK_LOGIN_EMPLOYEE_NAME_SUBMIT = "//button[@id='employeeNameModalSubmit']"
WEB_CLOCK_LOGIN_CONFIRMATION_OK_BUTTON = "button#infoModalBtnOk"
WEB_CLOCK_LOGIN_CURRENT_DATE = "#mobileDisplayDate,#nwcHeaderDate"
WEB_CLOCK_LOGIN_CURRENT_TIME_DEVICE = "#mobileDigitalClock,#nwcHeaderTime"
