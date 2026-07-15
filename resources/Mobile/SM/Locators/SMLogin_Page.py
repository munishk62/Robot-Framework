SM_ENTER_REGISTRATION_BUTTON = '//*[@resource-id and substring-after(@resource-id, ":id/")="manualProductKeyBtn"] | //android.widget.Button[@content-desc="Enter Product ID Manually"] | //*[@name="Enter Product ID Manually"]'
SM_ENTER_REGISTRATION_FIELD = '//android.widget.EditText[contains(@resource-id,"productKeyText")] | //XCUIElementTypeTextField[@name="Enter Product Id"]'
SM_REGISTRATION_SUBMIT_BUTTON = '//*[@resource-id and substring-after(@resource-id, ":id/")="proceed"] | //*[@name="Done"]'
QR_REGISTRATION_SUBMIT_BUTTON = '//*[contains(@content-desc,"Submit")] | //*[contains(@label,"Submit")] | //XCUIElementTypeButton[@name="Done"]'
SM_LOGIN_USERNAME_FIELD = '//android.widget.EditText[@password="false"] | //*[@value="Enter username"]'
SM_LOGIN_USERNAME_PASSWORD = '//android.widget.EditText[@password="true"] | //*[@value="Enter password"]'
SM_LOGIN_SUBMIT_BUTTON = '//android.widget.Button[@resource-id="loginButton"] | //android.widget.Button[@text="Login"] | //XCUIElementTypeButton[@label="{0}"] | //XCUIElementTypeButton[@label="{0}"]'
SM_LOGIN_SUBMIT_BUTTON_KEY = "1000000001609"

# Chrome Custom Tab "Close tab" (X) control. When the SSO/web login is served in a
# Chrome Custom Tab and a suite starts cleanup while the tab is still on top, none
# of the native SM detectors match; closing the tab returns to the native launch
# page so Clear Data can proceed. Mirrors the ESS ``close_custom_tab`` locator.
SM_CLOSE_CUSTOM_TAB = (
    '//android.widget.ImageButton[@content-desc="Close tab"]'
    ' | //android.widget.ImageButton[@resource-id="com.android.chrome:id/close_button"]'
    ' | //*[@value="Cancel"]'
)
SM_MORE_BUTTON = '//*[@resource-id and substring-after(@resource-id, ":id/")="moreBtn"] | //XCUIElementTypeButton[@name="More"]'
SM_LOGOUT_YES = '//android.widget.Button[contains(@resource-id,"btnPositive")] | //XCUIElementTypeButton[@name="Confirm"]'
LOGIN_BACK = '//*[@resource-id and substring-after(@resource-id, ":id/")="login_again_btn"] | //*[@type="XCUIElementTypeButton" and @label=" Click here to login "] | //XCUIElementTypeImage[@name="loggedOut"]//following-sibling::XCUIElementTypeButton'
SM_LOGOUT_BTN = '//android.widget.LinearLayout[@content-desc=" Logout  Button"] | //XCUIElementTypeStaticText[@name="{0}"]'
SM_CLEAR_DATA_BUTTON = '//*[@resource-id and substring-after(@resource-id, ":id/")="tv_clear_data"] | //*[@name="Clear Data"]'
SM_CONFIRM_CLEAR_DATA='//XCUIElementTypeButton[@name="Continue"]'
CLEAR_DATA_CONTINUE_BUTTON_NATIVE = '//*[@name="Continue"]'
SM_SETTING_BUTTON = '//*[@resource-id and substring-after(@resource-id, ":id/")="ib_setting"] | //android.widget.Button[@content-desc="Settings"] | //XCUIElementTypeButton[@name="Settings"]'
SM_ACCESS_FORBIDDEN_MESSAGE = '//*[@label="Access Forbidden"] | //*[@text="Access Forbidden"] | //XCUIElementTypeStaticText[@name="Access Forbidden"]'
SM_LOGOUT = '//*[@resource-id and substring-after(@resource-id, ":id/")="logout"] | //XCUIElementTypeButton[@name="Logout"]'
LOGOUT_NO = '//*[@resource-id and substring-after(@resource-id, ":id/")="buttonLeft"] | //*[@label="No" and @type="XCUIElementTypeButton"]'
CLICK_DONT_ALLOW_ALERT_NATIVE='//*[@name="Don’t Allow"] | //*[@name="No"] | //*[@name="Ok"]'
LANGUAGE_OPTION = '//*[@name="English (India)"]'
SELECT_LANGUAGE_NATIVE = '//*[@label="Language"]//following::*[2]'
LANGUAGE_NATIVE ='//XCUIElementTypeLink[@name="${LANGUAGE}"]'
SM_IOS_PERMISSIONS_ALLOW_BUTTON = '//XCUIElementTypeButton[@name="Allow"]'
