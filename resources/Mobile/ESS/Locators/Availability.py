availabilityDeleteButton = "availability.label.delete"
availabilityEditButton = "availability.label.edit"
availabilityEditLabel = "availability.add.label.edit_availability"
requestDeleteYes = "common.label.yes"
requestDeleteNo = "common.label.no"
availabilityNotReviewed = "availability.title.not_reviewed"
availabilityApproved = "availability.title.approved"
availabilityDeclined = "availability.title.declined"
availabilityRequestsFilterButton = "availability.label.filter_requests"
availabilityRequestFilterWindowHeader = "availability.label.filter"
availabilityPermanentRequestItem = "availability.label.permanent"
availabilityTemporaryRequestItem = "availability.label.temporary"
availability_label_copy_as_new = "availability.label.copy_as_new"
# Native
Add_Availability_Button = (
    '//*[@resource-id and substring-after(@resource-id, ":id/")="action_add"]'
)
Start_Date_Locator_Native = '//*[@resource-id and substring-after(@resource-id, ":id/")="weekStartIL"] | //*[@name="Week Starting"]//following-sibling::XCUIElementTypeButton'
ok_button_ava = '//*[@resource-id and substring-after(@resource-id, ":id/")="tvButtonPositive"] | //XCUIElementTypeButton[@label="OK"]'
filter_icon_ava = '//*[@resource-id and substring-after(@resource-id, ":id/")="filterBtn"] | //XCUIElementTypeButton[@label="Filter"]'
filter_from_date = '//*[@name="From"]//following-sibling::XCUIElementTypeButton'
filter_to_date = '//*[@name="TO"]//following-sibling::XCUIElementTypeButton'
avail_request_list = '//XCUIElementTypeCell[./*[@label="{0}"] and ./*[@name="{1}"]]'
availability_requests = '//*[@content-desc[contains(., "{0}") and contains(., "Tab")]] | //*[@label[contains(., "{0}") and contains(., "Tab")]]'
