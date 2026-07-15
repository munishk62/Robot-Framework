TIMECARDLISTPAGE_ASSOCIATE = (
    "//div[@id='gridbox']/div[@class='objbox']/table/tbody/tr[{INDEX}]/td[3]/a"
)
TIMECARDLISTPAGE_NOTES_TAB = (
    "//div[@class='dhx_tablist_zone']//span[contains(text(), 'Notes')]"
)
TIMECARDLISTPAGE_DAILY_NOTES_TBL = (
    "iframe[id='iframe_notes'] >>> //div[@id='notesGridBox']/div[@class='objbox']"
)
TIMECARDLISTPAGE_DAILY_NOTES_TBL_NOTES_COL = "iframe[id='iframe_notes'] >>> //div[@id='notesGridBox']/div[@class='objbox']/table/tbody/tr[{ROW_NUM}]/td[2]"
TIMECARDLISTPAGE_TEXT_AREA_FOR_NOTES = (
    "iframe[id='iframe_notes'] >>> //textarea[@class='dhx_textarea']"
)
TIMECARDLISTPAGE_SAVE_BTN = "iframe[id='iframe_notes'] >>> //input[@onclick='javascript:saveNotes();' or @id='saveNoteId']"
TIMECARDLISTPAGE_NOTIFICATION_MESSAGE = (
    "iframe[id='iframe_notes'] >>> //div[@id='MSG_DIV']"
)
TIMECARDLISTPAGE_DAILY_NOTES_TBL_AUDIT_ICON = "iframe[id='iframe_notes'] >>> //div[@id='notesGridBox']/div[@class='objbox']/table/tbody/tr[{ROW_NUM}]/td[5]/img"
TIMECARDLISTPAGE_AUDIT_TBL = (
    "iframe[id='iframe_notes'] >>> //div[@id='highslide-wrapper-0']"
)
TIMECARDLISTPAGE_AUDIT_TBL_BODY = "iframe[id='iframe_notes'] >>> //div[@id='noteAuditsGrid']/div[@class='objbox']/table/tbody"
TIMECARDLISTPAGE_AUDIT_TBL_HEADER = "iframe[id='iframe_notes'] >>> //div[@id='noteAuditsGrid']/div[@class='xhdr']/table/tbody/tr[3]"
TIMECARDLISTPAGE_AUDIT_TBL_CLOSE_BTN = (
    "iframe[id='iframe_notes'] >>> //div[@id='noteAudits']//a[@class='close']"
)
TIMECARDLISTPAGE_WEEKLY_NOTES_TBL_NOTES_COL = "iframe[id='iframe_notes'] >>> //div[@id='weeklyNotesGridBox']/div[@class='objbox']/table/tbody/tr[2]/td[1]"
TIMECARDLISTPAGE_WEEKLY_NOTES_TBL_AUDIT_ICON = "iframe[id='iframe_notes'] >>> //div[@id='weeklyNotesGridBox']/div[@class='objbox']/table/tbody/tr[2]/td[4]/img"
TIMECARDLISTPAGE_HEADER_WEEK_LABEL_PREV_BUTTON = "//img[@id='leftMove']"
TIMECARDLISTPAGE_HEADER_WEEK_LABEL_NEXT_BUTTON = "//img[@id='rightMove']"
TIMECARDLISTPAGE_PLEASE_WAIT_LOADER = "//td[@id='lblPageLoadMessage']"
