RequestButtonLabel = "common.menu.title.requests"
ScheduleButtonLabel = "common.menu.title.schedule"
ShiftTradeButtonLabel = "common.menu.title.shift_trade"
LeaveBalanceButtonLabel = "common.menu.title.leave_balance"
AvailabilityButtonLabel = "common.menu.title.availability"
TimecardButtonLabel = "common.menu.title.timecard"
StoreScheduleButtonLabel = "common.menu.title.store_schedule"
AltWorkLocationButtonLabel = "common.menu.title.alt_work_loc"
AbsenceCalendarButtonLabel = "common.menu.title.absence_calendar"
ProfileButtonLabel = "common.menu.title.profile"
AttendanceManagementButtonLabel = "common.menu.title.attendance_management"
HomeTabLabel = "common.menu.title.home"
MoreTabLabel = "common.menu.title.more"
BottomTabLabel = "common.semantic.bottom_bar.label"
ClockButtonLabel = "common.menu.title.timeclock"

navigationList = [
    RequestButtonLabel,
    ScheduleButtonLabel,
    ShiftTradeButtonLabel,
    LeaveBalanceButtonLabel,
    AvailabilityButtonLabel,
    TimecardButtonLabel,
    StoreScheduleButtonLabel,
    AltWorkLocationButtonLabel,
    AbsenceCalendarButtonLabel,
    ProfileButtonLabel,
    AttendanceManagementButtonLabel,
]
schedule_bottom_nav_locator = (
    '//*[contains(normalize-space(@content-desc),"{0}") and '
    'not(contains(normalize-space(@content-desc),"{1}"))] | '
    '//*[contains(normalize-space(@text),"{0}") and '
    'not(contains(normalize-space(@text),"{1}"))] | '
    '//*[contains(normalize-space(@label),"{0}") and '
    'not(contains(normalize-space(@label),"{1}"))] | '
    '//*[contains(normalize-space(@name),"{0}") and '
    'not(contains(normalize-space(@name),"{1}"))]'
)
