trade_post_locator = "trade.tabs.post"
trade_cover_locator = "trade.tabs.cover"
trade_my_request_locator = "trade.tabs.my_requests"
trade_accept_button_locator = "trade.label.actions.accept"
trade_decline_button_locator = "trade.label.decline"
trade_decline_swap_shift_title = "trade.title.decline_swap_shift"
trade_decline_swap_confirmation = "trade.swap.decline_confirmation"
trade_label_bids = "trade.label.bids"
trade_label_one_bid = "trade.label.one_bid"
trade_requestor_notes = "trade.label.requestor_notes"
trade_give_away_summary = "trade.label.give_away_summary"
trade_give_away_on = "trade.label.give_away_on"
trade_date_from_time = "trade.label.date_from_time"
trade_responder_notes = "trade.label.responder_notes"
trade_open_shift_summary = "trade.label.open_shift_summary"
trade_accept_shift_on = "trade.label.accept_shift_on"
trade_title_give_away = "trade.title.give_away"
trade_label_pending = "trade.label.pending"
trade_label_approved = "trade.label.approved"
trade_label_declined = "trade.label.declined"
trade_label_actions_withdraw = "trade.label.actions.withdraw"
trade_label_withdraw_confirmation = "trade.details.withdraw.confirmation.title"
trade_title_request_additional_work = "trade.title.request_additional_work"
trade_extra_work_days_title = "trade.extra_work.label.days"
trade_extra_work_time_of_day_title = "trade.extra_work.label.time_of_day"
trade_extra_work_shift_length_title = "trade.extra_work.label.shift_length"
trade_extra_work_label_duration = "trade.label.duration"
trade_label_duration_after = "trade.label.duration.after"
trade_label_duration_before = "trade.label.duration.before"
trade_label_my_give_away_shift = "trade.label.my_give_away_shift"
trade_swap_label_my_swapped_shift = "trade.swap.label.my_swapped_shift"
trade_swap_label_no_shifts = "trade.swap.label.no_shifts"
trade_label_responders = "trade.label.responders"
trade_label_no_responders = "trade.label.no_responders"
trade_title_additional_work_requested = "trade.title.additional_work_requested"
trade_label_my_additional_work = "trade.label.my_additional_work"
trade_label_my_preference = "trade.label.my_preference"
trade_label_requested_on = "trade.label.requested_on"
trade_label_users_additional_work = "trade.label.users_additional_work"
trade_label_users_preference = "trade.label.users_preference"
trade_label_users_give_away_shift = "trade.label.users_give_away_shift"
trade_label_users_swap_shift = "trade.label.users_swap_shift"
trade_semantics_list_card = "trade.semantics.list.card"
trade_label_pending_associate_response = "trade.swap.label.pending_associate_response"
trade_swap_label_pending_mgr_approval = "trade.swap.label.pending_mgr_approval"
trade_label_any_time_of_day = "trade.label.any_time_of_day"
trade_label_any_shift_length = "trade.swap_details.label.any_shift_length"
trade_label_select_associate = "trade.swap.label.select_associate"
trade_label_select_swap = "trade.swap.label.select_swap"
trade_label_my_store = "trade.swap.label.my_store"
trade_label_nearby_stores = "trade.swap.label.nearby_stores"
trade_title_swap_with_anyone = "schedule.label.swap.all_eligible"
trade_label_date_from = "trade.label.date_from"
trade_label_date_to = "trade.label.date_to"
trade_location_all = "common.label.selectall"
trade_my_location = "trade.swap.label.my_location"
trade_nearby_location = "trade.swap.label.nearby_location"
trade_label_my_response = "trade.label.my_response"
trade_label_location = "trade.swap.label.location"
trade_no_request_message = "trade.no_results.my_requests"
trade_label_duration_length = "trade.label.duration_length"
trade_no_shifts_covered_msg = "trade.no_results.cover"
trade_label_home_stores = "trade.swap.label.home_stores"
trade_label_nearby_stores = "trade.swap.label.nearby_stores"
# Native ESS
Schedule_Start_Date_Label_Native = '//*[@resource-id and substring-after(@resource-id, ":id/")="tvWeekHeader"] | //*[@resource-id and substring-after(@resource-id, ":id/")="weekTV"]'
Preference_Associate_Know_Native = (
    '//*[@resource-id and substring-after(@resource-id, ":id/")="checkMarkInd"]'
)
Search_Box_Native = (
    '//*[@resource-id and substring-after(@resource-id, ":id/")="searchBox"]'
)
confirm_button_native = (
    '//*[@resource-id and substring-after(@resource-id, ":id/")="tvButtonPositive"]'
)
next_month_locator = '//*[@resource-id and substring-after(@resource-id, ":id/")="ivNext"] | //*[@name="{0}"]'
prev_month_locator = '//*[@resource-id and substring-after(@resource-id, ":id/")="ivPrevious"] | //*[@name="{0}"]'
cover_start_date_label_native = '//*[@resource-id and substring-after(@resource-id, ":id/")="weekTV"] | //*[@resource-id and substring-after(@resource-id, ":id/")="tvWeekHeader"] | //*[contains(@name,"{0}")]'
cover_tab = "//XCUIElementTypeCollectionView/XCUIElementTypeCell[1]"
post_tab = "//XCUIElementTypeCollectionView/XCUIElementTypeCell[2]"
accept_button = '//*[@label="{0}" and @type="XCUIElementTypeButton"] | //*[@resource-id and substring-after(@resource-id, ":id/")="acceptBtn" and @text="{0}"]'
popup_confirm_button = '//*[@name="{0}" and @type="XCUIElementTypeButton"] | //*[@resource-id and substring-after(@resource-id, ":id/")="tvButtonPositive" and @text="{0}"]'
select_open_shift_locator = '//*[@type="XCUIElementTypeOther"  and ./*[@name="{0}"]  and //*[contains(@name,"{1}")]]/./parent::*//*[@name="{2}"]'
select_specific_shift_from_post_list = '//*[contains(@label,"{0}") and contains(@label,"{1}") and contains(@label,"{2}")] | //android.widget.RelativeLayout[./*/*[contains(@text,"{0}") and contains(@text,"{1}")] and ./*/*/*/*[contains(@text,"{2}")]]'
select_shift_to_swap_with_associate = '//*[contains(@name,"{0}, {1}")]'
select_shift_button = '//*[@name="{0}" and @type="XCUIElementTypeButton"]'
cover_start_date_label_native_IOS = '//XCUIElementTypeButton[contains(@label,"{0}")]'
cover_semantic_list_IOS = (
    '//XCUIElementTypeCell[*/*/*[@label="{0}"] and */*/*[@label="{1}"]]'
)
cover_tab_IOS = "//XCUIElementTypeCollectionView/XCUIElementTypeCell[1]"  # Label based locator is not working in IOS for this element
confirm_btn_ios = '//XCUIElementTypeButton[@label="{0}"]'
schedule_calender_all_button = (
    '//*[@resource-id and substring-after(@resource-id, ":id/")="ivSelectedDate"]'
)
swap_my_store = '//*[@type="XCUIElementTypeCollectionView"]/*[1]'
swap_shift_list = '//*[@name="{0}" and preceding::*[contains(@label,"{1}")]]'
responder_notes = '//*[@resource-id and substring-after(@resource-id, ":id/")="etNote"]'
shift_duration = (
    '//*[@resource-id and substring-after(@resource-id, ":id/")="shiftDurationET"]'
)
non_home_store_shift_list = '//XCUIElementTypeCell[//child::*[@name="NonHome"] and //child::*[contains(@label,"{0}")]] | //android.widget.RelativeLayout[contains(@resource-id,"mainRL") and //child::android.widget.TextView[contains(@text,"{0}")]]'
note_close_button_locator = '//*[@resource-id and substring-after(@resource-id, ":id/")="ivCloseIcon" and @content-desc="{0}"]'
additional_work_shift_locator = '//android.widget.LinearLayout[android.widget.TextView[@text="ELIGIBLE SHIFT(S)"]]//android.widget.LinearLayout[.//android.widget.TextView[contains(@text,"{0}")] and .//android.widget.TextView[contains(@text,"{1}")]]'
trade_filter_checkbox_locator = '//android.widget.CheckBox[@content-desc="{0}"]'
trade_filter_scroll_container = '//android.widget.HorizontalScrollView'
trade_my_request_card_with_status_locator = '//android.view.View[@content-desc="{0}"]/android.view.View[contains(@content-desc,"{1}") and contains(@content-desc,"{2}")]'
trade_nearby_store_unit_button_locator = '//android.widget.Button[contains(@content-desc,"{0}")]'
