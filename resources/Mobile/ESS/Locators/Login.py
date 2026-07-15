ENTER_REGISTRATION_BUTTON = '//*[contains(@content-desc,"Enter Registration Code Manually")] | //*[contains(@label,"Enter Registration Code Manually")] | //*[contains(@content-desc,"MANUALLY ENTER PRODUCT KEY")] | //*[contains(@label,"MANUALLY ENTER PRODUCT KEY")] | //XCUIElementTypeOther[@label="Registration Code"]'
ENTER_REGISTRATION_FIELD = "//*[contains(@content-desc,'Enter Registration Code')] | //*[contains(@label,'Enter Registration Code')]"
REGISTRATION_SUBMIT_BUTTON = (
    "//*[contains(@content-desc,'Submit')] | //*[contains(@label,'Submit')]"
)
CLEAR_DATA_BUTTON = (
    "//*[contains(@content-desc,'Clear Data')] | //*[contains(@label,'Clear Data')]"
)
YES_BUTTON = "//*[contains(@content-desc,'Yes')] | //*[contains(@label,'Yes')]"
LOGIN_USERNAME_FIELD = "xpath=(//*[contains(@class,'android.widget.EditText')])[1] | //XCUIElementTypeTextField[@value='Enter username']"
LOGIN_USERNAME_PASSWORD = (
    "xpath=//android.widget.EditText[@hint='Enter password']"
    " | (//android.widget.EditText[@password='true'])[1]"
    " | (//*[contains(@class,'android.widget.EditText')])[2]"
    " | //XCUIElementTypeSecureTextField[contains(@value,'Enter password') or contains(@name,'Enter password') or contains(@label,'Enter password')]"
)
LOGIN_SUBMIT_BUTTON = (
    '//android.widget.Button[@resource-id="loginButton"]'
    ' | //*[contains(@label,"Login")]'
    ' | //android.widget.Button[@text="Login"]'
    ' | //android.view.View[@text="Login"]'
    ' | //*[@name="Login"]'
    ' | //android.webkit.WebView[@text="Sign In"]'
    ' | //*[@name="Sign In" and @type="XCUIElementTypeButton"]'
    ' | //*[@resource-id="primaryAuthenticationContainer"]/following-sibling::android.view.View[1]'
)
# Chrome Custom Tab login (SSO/browser).
# Enabled per-environment via the CHROME_TAB_LOGIN_ENABLED flag in config.json.
# For these environments the ESS login page is served inside com.android.chrome
# (a Chrome Custom Tab) rather than the in-app hybrid WebView, so the native
# EditText overlays used by LOGIN_USERNAME_FIELD/LOGIN_USERNAME_PASSWORD never
# exist. Once Chrome populates the web accessibility tree the inputs surface as
# real android.widget.EditText nodes, but their resource-ids are randomly
# generated per render (e.g. "n1783601742065", "u2757426840057960998"), so they
# cannot be matched by id. Each field's EditText sits inside an android.view.View
# whose text is the placeholder ("Enter username" / "Enter password"); the two
# fields are also distinguishable by the password attribute (username=false,
# password=true). The submit control keeps the stable resource-id "loginButton".
LOGIN_USERNAME_FIELD_CHROME = (
    '//android.view.View[@text="Enter username"]//android.widget.EditText'
    ' | //android.widget.EditText[@password="false"]'
)
LOGIN_USERNAME_PASSWORD_CHROME = (
    '//android.view.View[@text="Enter password"]//android.widget.EditText'
    ' | //android.widget.EditText[@password="true"]'
)
LOGIN_SUBMIT_BUTTON_CHROME = (
    '//android.widget.Button[@resource-id="loginButton"]'
    ' | //android.widget.Button[@text="Login"]'
)

LANGUAGE_SELECTION_DROPDOWN = (
    '//android.view.View[@text="Language"]/following-sibling::android.view.View'
    ' | //XCUIElementTypeStaticText[@name="Language"]/following-sibling::*[1]'
    ' | //XCUIElementTypeStaticText[@label="Language"]/following-sibling::*[1]'
)
LANGUAGE_SELECTION_BOX = (
    '//*[@resource-id="box"]'
    ' | //XCUIElementTypePicker'
    ' | //XCUIElementTypeOther[@name="Language"]'
)
LANGUAGE_SELECTION_FLAG = (
    'xpath=(//android.widget.Image)[2] | (//XCUIElementTypeImage)[2]'
)
HOME_DRAWER = "common.label.drawer"
LOG_OUT = "common.menu.title.logout"
LOG_BACK_IN = (
    '//*[contains(@content-desc,"Log Back In")] | //*[contains(@label,"Log Back In")]'
)
SETTING_BUTTON = '//XCUIElementTypeOther[@name="Manage settings"] | //android.widget.Button[@content-desc="Manage settings"] | //*[contains(@label,"Manage settings")]'
UNABLE_TO_LOGIN= "//*[contains(@content-desc,'Unable to Login')] | //*[contains(@label,'Unable to Login')]"
POPUP_OK_BUTTON= "//*[contains(@content-desc,'OK')] | //*[contains(@label,'OK')]"

SETTING_BUTTON_TYPE_1 = "xpath=(//*[contains(@class,'android.widget.Button')])[2] | //XCUIElementTypeButton[@name='Manage settings']"
SETTING_BUTTON_TYPE_2 = "//android.widget.Button[@content-desc='Manage settings']"
SETTING_BUTTON_TYPE_3= '//android.widget.FrameLayout[@resource-id="android:id/content"]/android.widget.FrameLayout/android.widget.FrameLayout/android.view.View/android.view.View/android.view.View/android.view.View[3]/android.widget.Button[1]'

# Native App
PROGRESS_BAR_NATIVE = '//android.widget.ProgressBar | //*[@label="In progress"]'
ENTER_REGISTRATION_BUTTON_NATIVE = '//*[@resource-id and substring-after(@resource-id, ":id/")="manualProductKeyBtn"] | //*[@name="Enter Product ID Manually"]'
ENTER_REGISTRATION_FIELD_NATIVE = '//*[@resource-id and substring-after(@resource-id, ":id/")="productKeyText"] | //*[@name="Enter Product Id"]'
ENTER_REGISTRATION_FIELD_POPUP_NATIVE = (
    '//*[@name="Product Id" and @type="XCUIElementTypeAlert"]'
)
REGISTRATION_SUBMIT_BUTTON_NATIVE = '//*[@resource-id and substring-after(@resource-id, ":id/")="proceed"] | //*[@name="Done"]'
CLEAR_DATA_BUTTON_NATIVE = '//*[@resource-id and substring-after(@resource-id, ":id/")="tv_clear_data"] | //*[@name="Clear Data"]'
CLEAR_DATA_CONTINUE_BUTTON_NATIVE = '//*[@label="Continue"]'
YES_BUTTON_NATIVE = "//*[contains(@content-desc,'Yes')] | //*[contains(@label,'Yes')]"
LOGIN_USERNAME_FIELD_NATIVE = (
    '//android.widget.EditText[@password="false"] | //*[@value="Enter username"]'
)
LOGIN_USERNAME_PASSWORD_NATIVE = (
    '//android.widget.EditText[@password="true"] | //*[@value="Enter password"]'
)
LOGIN_SUBMIT_BUTTON_NATIVE = (
    '//android.widget.Button[@resource-id="loginButton"] | //*[@label="Login"]'
)
LANGUAGE_SELECTION_NATIVE = '//*[@resource-id and substring-after(@resource-id, ":id/")="primaryAuthenticationContainer"]//android.widget.Image | //*[@label="English (United States)"]'
LOG_BACK_IN_NATIVE = '//*[@resource-id and substring-after(@resource-id, ":id/")="login_again_btn"] | //*[@type="XCUIElementTypeButton" and @label=" Click here to login "] | //XCUIElementTypeImage[@name="loggedOut"]//following-sibling::XCUIElementTypeButton '
SETTING_BUTTON_NATIVE = '//*[@resource-id and substring-after(@resource-id, ":id/")="ib_setting"] | //*[@label="Settings"]'

logout_no = '//*[@resource-id and substring-after(@resource-id, ":id/")="buttonLeft"] | //*[@label="No" and @type="XCUIElementTypeButton"]'
logout_yes = '//*[@resource-id and substring-after(@resource-id, ":id/")="buttonRight"] | //*[@type="XCUIElementTypeButton" and @label="Yes"]'
ALERT_DONT_ALLOW_NATIVE = (
    '//*[@name="Don’t Allow"] | //*[@name="No"] | //*[@name="OK"] | //*[@name="Cancel"]'
)
SELECT_LANGUAGE_NATIVE = '//*[@label="Language"]//following::*[2]'
LANGUAGE_NATIVE = '//XCUIElementTypeLink[@name="${LANGUAGE}"]'
location_allow = '//XCUIElementTypeButton[@name="Allow While Using App"]'
access_forbidden_native = (
    '//*[@label="Access Forbidden"] | //*[@text="Access Forbidden"]'
)
ess_logout_btn = '//XCUIElementTypeButton[@label="{0}"] | //*[@resource-id and substring-after(@resource-id, ":id/")="logout"]'

# Zebra PingID
close_custom_tab = (
    '//android.widget.ImageButton[@content-desc="Close tab"] | //*[@value="Cancel"]'
)
ios_web_open_popup_text = (
    '//*[@name="This allows the app and website to share information about you."]'
)
ios_continue_button = '//*[@name="Continue"]'
ping_id_username = '//android.widget.EditText[@resource-id="username"] | //*[@type="XCUIElementTypeTextField"]'
ping_id_password = '//android.widget.EditText[@resource-id="password"] | //*[@type="XCUIElementTypeSecureTextField"]'
ping_id_sign_in = '//*[@resource-id="submit_id"] | //*[@name="Sign In" and @type="XCUIElementTypeButton"]'
ping_id_settings_button = (
    '//android.view.View[@content-desc="Settings"] | //*[@name="Sign On"]'
)
ping_id_cookie_accept_button = (
    '//android.widget.Button[@resource-id="onetrust-accept-btn-handler"]'
)
ping_id_otp_field = '//android.widget.EditText[@resource-id="otp"] | //*[@type="XCUIElementTypeTextField"]'
ping_id_sign_on_button = (
    '//android.widget.Button[@text="Sign On"] | //*[@name="Sign On"]'
)
