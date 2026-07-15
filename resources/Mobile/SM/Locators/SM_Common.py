# Date Selection from week start list
YEAR_TAB_LOCATOR = '//android.widget.TextView[contains(@resource-id,"tv_curr_year") and @text="{0}"]'
WEEK_START_LOCATOR = '//android.widget.TextView[contains(@resource-id,"TV_text") and @text="{0}"]'

# Search from list and tap
LIST_PICKER_SEARCH_BOX = '//android.widget.EditText[contains(@resource-id,"searchValueEdt")]'
SEARCH_LIST_FIRST_OPTION = '//androidx.recyclerview.widget.RecyclerView[contains(@resource-id,"reasons_recycler_view")]/android.widget.RelativeLayout[1]'

# Round Time picker locators
ROUND_TIME_HOUR = 'id=android:id/hours'
ROUND_TIME_MINUTE = 'id=android:id/minutes'
ROUND_TIME_AM = 'id=android:id/am_label'
ROUND_TIME_PM = 'id=android:id/pm_label'
ROUND_TIME_MINUTES_HOUR = '//android.widget.RadialTimePickerView.RadialPickerTouchHelper[@content-desc="{0}"]'
ROUND_TIME_OK_BUTTON = '//android.widget.Button[@resource-id="android:id/button1"]'

# Scrollable Time picker locators
TIME_HOURS_CONTAINER = '//android.widget.LinearLayout[contains(@resource-id,"picker_one_time")]'
TIME_HOUR_LOCATOR = '//android.widget.LinearLayout[contains(@content-desc,"{0}")]'
TIME_MINUTES_CONTAINER = '//android.widget.LinearLayout[contains(@resource-id,"picker_three_time")]'
TIME_MINUTE_LOCATOR = '//android.widget.LinearLayout[contains(@content-desc,"{0}")]'
TIME_SAVE_BUTTON = '//android.widget.ImageView[contains(@resource-id,"saveTimeIV")]'

BACK_BUTTON = '//android.widget.ImageButton[contains(@resource-id,"btn_back")]'
CANCEL_BUTTON = '1000000000107'
CLOSE_SNACK_BAR_BUTTON = '//android.widget.ImageButton[contains(@resource-id,"btnCloseSnackBar")]'
