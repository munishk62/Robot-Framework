ENTER_REGISTRATION_BUTTON_NATIVE_CLOCK = '//*[@resource-id and substring-after(@resource-id, ":id/")="manualProductKeyBtn"] | //*[@name="Enter Product ID Manually"]'
ENTER_REGISTRATION_FIELD_NATIVE_CLOCK = '//*[@resource-id and substring-after(@resource-id, ":id/")="productKeyText"] | //*[@name="Enter Product Id"]'
ENTER_REGISTRATION_FIELD_POPUP_NATIVE_CLOCK = '//*[@name="Product Id" and @type="XCUIElementTypeAlert"]'
REGISTRATION_SUBMIT_BUTTON_NATIVE_CLOCK = '//*[@resource-id and substring-after(@resource-id, ":id/")="proceed"] | //*[@name="Done"]'


LOGIN_USERNAME_FIELD_NATIVE_CLOCK = '//android.widget.EditText[@password="false"] | //*[@value="Enter username"]'
LOGIN_USERNAME_PASSWORD_NATIVE_CLOCK = '//android.widget.EditText[@password="true"] | //*[@value="Enter password"]'

LOGIN_SUBMIT_BUTTON_NATIVE_CLOCK = '//android.widget.Button[@resource-id="loginButton"] | //*[@label="Login"] | //android.widget.Button[@text="Login"]'

LANGUAGE_SELECTION_NATIVE_CLOCK = '//*[@resource-id and substring-after(@resource-id, ":id/")="primaryAuthenticationContainer"]//android.widget.Image | //*[@label="English (United States)"]'

LOG_BACK_IN_NATIVE_CLOCK = '//*[@resource-id and substring-after(@resource-id, ":id/")="login_again_btn"] | //*[@type="XCUIElementTypeButton" and @label=" Click here to login "] | //XCUIElementTypeImage[@name="loggedOut"]//following-sibling::XCUIElementTypeButton'

close_registration_logout = '//*[@resource-id and substring-after(@resource-id, ":id/")="close_button"] | //*[@name="Cancel"]'
settings_button_native_clock = '//*[@resource-id and substring-after(@resource-id, ":id/")="ivSetting"] | //*[@label="Settings"]'
clear_data_button_native_clock = '//*[@resource-id and substring-after(@resource-id, ":id/")="tv_clear_data"] | //*[@name="Clear Data"]'
continue_button_native_clock = '//*[@label="Continue"]'
yes_button_native_clock = "//*[contains(@content-desc,'Yes')] | //*[contains(@label,'Yes')]"

reset_application = '//*[@resource-id and substring-after(@resource-id, ":id/")="btnResetApp"] | //*[@name="Reset Application"]'
reset_application_option = '//*[@resource-id and substring-after(@resource-id, ":id/")="btnRestart"] | //*[@name="Reset Tap"]'
reset_proceed_button = '//*[@text="OK"] | //*[@name="Proceed"]'