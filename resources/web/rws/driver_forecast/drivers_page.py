# filepath: resources/web/rws/driver_forecast/drivers_page.py
# Drivers Page elements

# Other elements
DRIVERSPAGE_DRIVER_CATEGORY = "select[name='metriccat']"
DRIVERSPAGE_DRIVER_CODE = "input#txtExtDriverName"
DRIVERSPAGE_DRIVER_DESCRIPTION = "input[name='txtExtDriverDesc']"
DRIVERSPAGE_FORECAST_DRIVER_TYPE = "select[name='txtMetricType_F']"
DRIVERSPAGE_DRIVER_GROUP = "select[name='txtMetricGroup']"
DRIVERSPAGE_DRIVER_GRANULARITY = "select[name='txtMetricGranlrty']"
DRIVERSPAGE_ADJUSTMENT_MODE = "select[name='txtAdjustmentMode']"
DRIVERSPAGE_AGGREGATE_RULE = "select[name='aggrule1']"
DRIVERSPAGE_DISPLAY_FORMAT = "select[name='dispfmt1']"
DRIVERSPAGE_FORECAST_CALCULATION_METHOD = "select[name='metricMethId1']"
DRIVERSPAGE_NOTIFICATION_SUCCESS_MESSAGE = (
    "#info_message.succ_bg[style*='display: block;']"
)
DRIVERSPAGE_UPDATED_FORECAST_DRIVER_TYPE = (
    "//tr[td/a[text()='{DESC}']]/td[text()='{TYPE}']"
)
DRIVERSPAGE_ALERT = "//div[@role='alert']"
DRIVERSPAGE_CREATED_DRIVER = "//a[contains(text(),'{DESC}')]"

# Button elements
DRIVERSPAGE_ADD_BUTTON = "input[value='Add']"
DRIVERSPAGE_SAVE_BUTTON = "input[value='Save']"
DRIVERSPAGE_DELETE_BUTTON = "//input[@type='button' and @value='Delete']"
