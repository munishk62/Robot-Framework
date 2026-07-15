schedule_tabs_title_week = "schedule.tabs.title.week"
schedule_tabs_title_day = "schedule.tabs.title.day"
schedule_tabs_title_month = "schedule.tabs.title.month"
schedule_publish_status_not_published = "schedule.publish.status.not_published"
schedule_label_not_published = "schedule.label.not_published"
schedule_label_not_scheduled = "schedule.label.not_scheduled"
schedule_additional_work = "schedule.label.extra_work"
schedule_start_date_locator = "schedule.label.start_date"
schedule_end_date_locator = "schedule.label.end_date"
schedule_shift_actions_locator = "schedule.label.shift_actions"
schedule_shift_direct_swipe = "schedule.label.swap.individual"
schedule_shift_swipe_with_anyone = "schedule.label.swap.all_eligible"
schedule_shift_give_away_locator = "schedule.label.advertise"
schedule_shift_details_label_locator = "schedule.title.shift_details"
schedule_shift_description = "schedule.semantic.shift_description"
schedule_filter_date_range = "schedule.filter.label.date_range"
schedule_todo_label_status = "schedule.todo.label.status"
schedule_details_trade_details = "schedule.details.trade_details"
schedule_label_swap = "schedule.label.swap"
schedule_label_day_off = "schedule.label.day_off"
schedule_label_open_shift = "schedule.label.open_shift"
schedule_label_open_shifts = "schedule.label.open_shifts"
quick_filter_scroll_view = '//android.widget.ScrollView/android.widget.HorizontalScrollView | //*[@type="XCUIElementTypeOther"]//*[@name="All"]'
schedule_day_tab_date_scroll_view = "//android.widget.ScrollView/android.view.View[1] | //XCUIElementTypeApplication[@name='Shift']/XCUIElementTypeWindow[1]/XCUIElementTypeOther[2]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[2]/XCUIElementTypeOther[2]/XCUIElementTypeOther[4]/XCUIElementTypeOther[2]/XCUIElementTypeOther[2]/XCUIElementTypeOther[2]/XCUIElementTypeOther[2]/XCUIElementTypeOther[2]/XCUIElementTypeOther[2]/XCUIElementTypeScrollView"
schedule_date_to_label = "schedule.label.date_to"
schedule_published_icon_month_tab = "schedule.semantic.published"
schedule_filter_label_sch_days = "schedule.filter.label.sch_days"
schedule_filter_label_all_days = "schedule.filter.label.all_days"
schedule_filter_title = "schedule.filter.title"
schedule_shift_end_detail = "schedule.label.shift_end"
schedule_day_details_month_tab = "schedule.semantic.day_details"
schedule_find_work = "schedule.label.find_work"
schedule_home_store_filter = "trade.swap.label.home_stores"
schedule_nearby_stores_filter = "trade.swap.label.nearby_stores"
schedule_menu_label_share = "schedule.menu.label.share"
schedule_menu_label_add_to_cal = "schedule.menu.label.add_to_cal"
schedule_menu_label_print_detail = "schedule.menu.print_detail"
schedule_menu_label_print_summary = "schedule.menu.print_summary"
schedule_menu_label_share_schedule = "schedule.menu.label.share_schedule"
schedule_calendar_add_success = "schedule.calendar.add.success"
schedule_menu_label_remove_from_cal = "schedule.menu.label.remove_from_cal"
schedule_calendar_remove_success = "schedule.calendar.remove.success"
schedule_additional_shift_tab = "schedule.label.tab"
schedule_additional_work_label = "schedule.label.additional_work"
schedule_shift_day_card_locator = '//android.view.View[contains(@content-desc,"{0}")]'
schedule_shift_day_additional_work_locator = '//android.view.View[contains(@content-desc,"{0}") and contains(@content-desc,"{1}")]'
schedule_shift_day_trade_label_locator = '//android.view.View[contains(@content-desc,"{0}")]//*[normalize-space(@content-desc)="{1}" or normalize-space(@text)="{1}"]'

# native apps
schedule_week_tab = (
    '//XCUIElementTypeStaticText[contains(@label,"{0}") and contains(@label,"{1}")]'
)
weekly_schedule = '//XCUIElementTypeCell[./*[@name="{0}"] and ./*[contains(@label,"{1}")] and ./*[contains(@label,"{2}")]]'
schedule_day_tab = (
    '//XCUIElementTypeStaticText[contains(@label,"{0}") and contains(@label,"{1}")]'
)
daily_monthly_schedule = '//XCUIElementTypeOther[@name="{0}" and ./*[contains(@label,"{1}")] and ./*[contains(@label,"{2}")]]'
schedule_month_tab = (
    '//XCUIElementTypeStaticText[contains(@label,"{0}") and contains(@label,"{1}")]'
)
