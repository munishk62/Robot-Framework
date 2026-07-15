APPROVE_DAY_OFF_SM_API_REGEX = (
    "**/controller/rws/weekplan/web/requestcalendar/associate/actions/approveleave/**"
)
DECLINE_DAY_OFF_SM_API_REGEX = (
    "**/controller/rws/weekplan/web/requestcalendar/associate/actions/declineleave/**"
)
APPROVE_TIMEOFF_SM_API_REGEX = (
    "**/controller/rws/weekplan/web/requestcalendar/associate/actions/approvetimeoff/**"
)
DECLINE_TIMEOFF_SM_API_REGEX = (
    "**/controller/rws/weekplan/web/requestcalendar/associate/actions/declinetimeoff/**"
)
APPROVE_SELECTED_DAY_OFF_BULK_SM_API_REGEX = (
    "**/controller/rws/associate/requests/bulk/update/**"
)
SM_ADD_DAY_OFF_API_REGEX = "**/controller/rws/weekplan/web/requestcalendar/dayoff/**"
SM_DELETE_DAY_OFF_API_REGEX = "**/controller/rws/weekplan/web/requestcalendar/dayoff/**"
SM_EDIT_DAY_OFF_API_REGEX = "**/controller/rws/weekplan/web/requestcalendar/**"
DELETE_DAY_OFF_SM_API_URL = "**/controller/rws/weekplan/web/requestcalendar/dayoff/**"
DELETE_TIME_OFF_SM_API_URL = "**/controller/rws/weekplan/web/requestcalendar/timeoff/**"
SM_ADD_TIME_OFF_API_REGEX = "**/controller/rws/associate/timeoff/**"
SM_EDIT_TIME_OFF_API_REGEX = "**/controller/rws/weekplan/web/requestcalendar/**"
SM_ADD_AVAILABILITY_API_REGEX = (
    "**/controller/rws/weekplan/web/requestcalendar/associate/requests/availability/**"
)
DELETE_SM_AVAILABILITY_API_URL = (
    "**/controller/rws/weekplan/web/requestcalendar/associate/requests/availability/**"
)

# This api is to fetch leave accruals for a specific associate as on given date
RWS_FETCH_LEAVE_ACCRUALS = "/controller/ess/associate/requests/accruals/{0}.json"
