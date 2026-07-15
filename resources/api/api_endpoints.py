# This file contains all endpoints for the API calls in the application.
# Please follow similar format when adding new endpoints

# Common end point which are not user dependant
# This api is just to initiate the session from auth token at server side and get the session cookies in response.
# GET controller/rosom/mobile/pinboard/initiatesession.json

RWS_INIT_SESSION = "controller/rosom/mobile/pinboard/initiatesession.json"

# This api is to fetch all standard cognos reports available.
COGNOS_STANDARD_REPORT_LIST = "/rar/ras/bi/DESKTOP/report.json?authToken={0}"

# SM end points (requires token generation with SM user)
# This api call is to delete the day off request. API belongs to SM module
# DELETE controller/rws/weekplan/web/requestcalendar/dayoff/{personId}/{effDate}/{reqStatusCd}/{requestNo}.json
SM_DELETE_DAY_OFF_REQUEST = (
    "controller/rws/weekplan/web/requestcalendar/dayoff/{0}/{1}/{2}/{3}.json"
)


# TestRay Integration Endpoints
# Endpoint to get/post with test cycles and test run ids for a given test plan
TESTRAY_TEST_PLAN_URL = "https://jira.zebra.com/rest/synapse/latest/public/testPlan"
TESTRAY_TEST_CYCLE_URL = "/{0}/cycles"
TESTRAY_TEST_RUN_UPDATE_URL = "/{0}/cycle/{1}/updateTestRun"
TESTRAY_TEST_ATTACHMENT_URL = (
    "https://jira.zebra.com/rest/synapse/latest/public/attachment/{0}/testrun"
)
TESTRAY_TEST_ID_URL = "https://jira.zebra.com/rest/api/2/search"


# SM end points (requires token generation with SM user)
# This api call is to delete the day off request. API belongs to SM module
# DELETE controller/rws/weekplan/web/requestcalendar/dayoff/{personId}/{effDate}/{reqStatusCd}/{requestNo}.json
sm_delete_day_off_request = (
    "controller/rws/weekplan/web/requestcalendar/dayoff/{0}/{1}/{2}/{3}.json"
)

# This api call is to delete an alternate work location request. API belongs to SM module
# GET controller/ess/sharerequests/delete/{requestNo}.json
sm_delete_alt_work_location = "controller/ess/sharerequests/delete/{0}.json"

# This api call is for the details of availability request for the user. API belongs to SM module
# GET controller/rws/weekplan/web/requestcalendar/associate/requests/availability/{requestNo}.json
sm_availability_details = "controller/rws/weekplan/web/requestcalendar/associate/requests/availability/{0}.json"

# This api call is to get the availability request list for the user. API belongs to SM module
# PUT controller/rws/weekplan/web/requestcalendar/associate/requests/availability/edit/{personId}/{unitId}.json
sm_update_availability_request = "controller/rws/weekplan/web/requestcalendar/associate/requests/availability/edit/{0}/{1}.json"

# This api call is delete the availability request for the user. API belongs to SM module
# DELETE controller/rws/weekplan/web/requestcalendar/associate/requests/availability/delete/{requestNo}.json
sm_delete_availability_request = "controller/rws/weekplan/web/requestcalendar/associate/requests/availability/delete/{0}.json"

# This api call is to delete the time off request. API belongs to SM module
# DELETE controller/rws/weekplan/web/requestcalendar/timeoff/{personId}/{effDate}/{startTime}/{reqStatusCd}/{requestNo}
sm_delete_time_off_request = (
    "controller/rws/weekplan/web/requestcalendar/timeoff/{0}/{1}/{2}/{3}/{4}.json"
)

# This call is to get users timecard details. API belongs to SM module
# GET controller/rta/mobile/associate/timecard/advanced/{personId}/{weekStartDate}/{includeCrossWeekShifts}.json
sm_get_timecard = (
    "controller/rta/mobile/associate/timecard/advanced/{0}/{1}/true.json"
)

# This api is to delete punches for the user. API belongs to SM module
# POST controller/rta/mobile/associate/time/adjusted/delete/{personID}/{weekStartDate}.json
sm_delete_punch_timecard = (
    "controller/rta/mobile/associate/time/adjusted/delete/{0}/{1}.json"
)

# This api call is to add punch timecard for the user. API belongs to SM module
# POST controller/rta/mobile/associate/time/adjusted/add/{personId}/{effDate}.json
sm_add_punch_timecard = (
    "controller/rta/mobile/associate/time/adjusted/add/{0}/{1}.json"
)

# ESS end points (requires token generation with ESS user)
# This api call is to get the leave request list for the user. API belongs to ESS module
# GET controller/ess/list/leaverequest/{requestType}/{effDate}/{endDate}.json
ess_request_list = "controller/ess/list/leaverequest/B/{0}/{1}.json"

# This api call is to approve shift trade request. API belongs to SM module where 1st argument is request type and 2nd argument is request number and 3rd argument is responderId
# POST controller/rws/weekplan/web/schedule/ess/response/approve/{request_type}/{requestNo}/{responderId}.json
shift_trade_approve = (
    "controller/rws/weekplan/web/schedule/ess/response/approve/{0}/{1}/{2}.json"
)

# This api call is to decline shift trade request. API belongs to SM module where 1st argument is request type and 2nd argument is request number and 3rd argument is responderId
# POST controller/rws/weekplan/web/schedule/ess/response/approve/{requestType}/{requestNo}.json
shift_trade_request_decline = (
    "controller/rws/weekplan/web/schedule/ess/requests/decline/{0}/{1}.json"
)

# This api call is to decline shift trade response. API belongs to SM module where 1st argument is request number and 2nd argument is responder Id
# POST controller/rws/weekplan/web/schedule/ess/response/decline/{requestNo}/{responderId}.json
shift_trade_response_decline = (
    "controller/rws/weekplan/web/schedule/ess/response/decline/{0}/{1}.json"
)

# This api call is to create work pattern. API uses SYS Admin user
# POST controller/rws/scheduletemplate/0.json
create_work_pattern = "controller/rws/scheduletemplate/0.json"

# This api call is to add template to associate
# POST controller/rws/scheduletemplate/employeetemplate/add.json
add_associate_template = (
    "controller/rws/scheduletemplate/employeetemplate/add.json"
)

# This api call is to map work pattern with employee template
# POST controller/rws/scheduletemplate/mapTemplateToScheduleTemplate/{templateNo}/{refererType}.json
map_work_pattern_with_employee_template = (
    "controller/rws/scheduletemplate/mapTemplateToScheduleTemplate/{0}/{1}.json"
)

# This api is to add shift for particular day to template
# POST controller/rws/scheduletemplate/shift/basic/{templateNo}/{shiftDateSkey}/{unitId}.json
add_shift_to_template = (
    "controller/rws/scheduletemplate/shift/basic/{0}/{1}/{2}.json"
)

# This api call is to map work pattern with template
# PUT controller/rws/scheduletemplate/mapping/addTemplateWeekMappings/{storeId}.json
map_work_pattern_with_template = (
    "controller/rws/scheduletemplate/mapping/addTemplateWeekMappings/{0}.json"
)

# This api call is to get the calendar for fiscal year and fiscal period wise. API belongs to SM module
# GET /controller/rosom/basic/fiscalDateDetails/{unitId}/{date}.json
calendar_fiscal_api = "controller/rosom/basic/fiscalDateDetails/{0}/{1}.json"

# This api will generate schedule forecast for the store for particular week
# POST controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_FC/{unitId}/{weekStartDate}/NONE.json
generate_schedule_forecast = "controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_FC/{0}/{1}/NONE.json"

# This api will generate schedule workload for the store for particular week
# POST controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_WL/{unitId}/{weekStartDate}/NONE.json
generate_schedule_workload = "controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_WL/{0}/{1}/NONE.json"

# This api will generate optimized schedule using forecast for the store for particular week
# POST controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_SCHEDULE/{unitId}/{weekStartDate}/NONE.json
generate_optimized_schedule = "controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_SC/{0}/{1}/NONE.json"

# This api will generate schedule using template for the store for particular week
# POST controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_SC/{unitId}/{weekStartDate}/NONE.json
generate_template_schedule = "controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_SC/{0}/{1}/NONE.json"

# This api will delete the schedule for the store for particular week
# PUT controller/rws/weekplan/web/schedule/core/advanced/delete/{unitId}/{weekStartDate}/MANAGER.json
delete_schedule = "controller/rws/weekplan/web/schedule/core/advanced/delete/{0}/{1}/MANAGER.json"

# This api will get associate details for particular associate
# GET controller/rws/associate/core/basic/{personId}.json
associate_details = "controller/rws/associate/core/basic/{0}.json"

# This api will delete associate template for particular associate
# DELETE controller/rws/scheduletemplate/employeetemplate/basic/{templateNo}.json
delete_associate_template = (
    "controller/rws/scheduletemplate/employeetemplate/basic/{0}.json"
)

# This api is used to get the associate shifts for particular week for particular person
# GET controller/rws/weekplan/mobile/schedule/shift/basic/associateshifts/week/{unitId}/{genShiftId}/{personId}/{withTasks}.json
fetch_weekly_shifts = "controller/rws/weekplan/mobile/schedule/shift/basic/associateshifts/week/{0}/{1}/{2}/false.json"

# This api is used to unallocate the shift for the associate
# POST controller/rws/weekplan/web/schedule/shift/advanced/actions/unallocate/{genShiftId}/{unitId}/{shiftSeqNo}/{intervalStart}/{intervalDuration}/{suppressAckAlertsException}.json
unallocate_shift = "controller/rws/weekplan/web/schedule/shift/advanced/actions/unallocate/{0}/{1}/{2}/{3}/{4}/false.json"

# This api is used to publish the schedule for particular week
# POST controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/{eventType}/{unitId}/{scheduleDate}/{instanceType}.json
publish_schedule = "controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/PUBLISH_SC/{0}/{1}/MANAGER.json"

# This api is used to unpublish the schedule for particular week
# POST controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/{eventType}/{unitId}/{scheduleDate}/{instanceType}.json
unpublish_schedule = "controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/UNPUBLISH_SC/{0}/{1}/MANAGER.json"

# This api is used to get the week plan state for particular week
# GET controller/rws/weekplan/mobile/dashboard/getWeekPlanState/{unitId}/{startWeekStartDate}/{endWeekStartDate}.json
week_plan_state = (
    "controller/rws/weekplan/mobile/dashboard/getWeekPlanState/{0}/{1}/{2}.json"
)

# This api is used to regenerate shift mapping for particular week
# POST controller/rws/scheduletemplate/precursorschedule/add/{unitId}/{weekStartDate}.json
regenerate_shifts_mapping = (
    "controller/rws/scheduletemplate/precursorschedule/add/{0}/{1}.json"
)

# This api is used to get the shift id for particular week
# GET controller/dashboard/getGenShiftId/{unitId}/{weekStartDate}.json
gen_shift_id = "controller/dashboard/getGenShiftId/{0}/{1}.json"

# This api is used to get the shift details
# GET   controller/rws/weekplan/web/schedule/shift/map/associatelvl/{genShiftId}/withtasks.json
shift_detail = "controller/rws/weekplan/web/schedule/shift/map/associatelvl/{0}/withtasks.json"

# SM end points (requires token generation with SM user)
# This api call is to approve the time off request. API belongs to SM module
# APPROVE controller/rws/weekplan/web/requestcalendar/associate/actions/approvetimeoff/{unitId}/{reviewerId}/{personId}/{reqStatusCd}/{statusDate}/{startTime}/{requestNo}/{mgrComment}.json
sm_approve_time_off_request = "controller/rws/weekplan/web/requestcalendar/associate/actions/approvetimeoff/{0}/{1}/{2}/{3}/{4}/{5}/{6}/.json"

# SM end points (requires token generation with SM user)
# This api call is to decline the time off request. API belongs to SM module
# DECLINE controller/rws/weekplan/web/requestcalendar/associate/actions/declinetimeoff/{unitId}/{reviewerId}/{personId}/{reqStatusCd}/{statusDate}/{startTime}/{requestNo}/{mgrComment}.json
sm_decline_time_off_request = "controller/rws/weekplan/web/requestcalendar/associate/actions/declinetimeoff/{0}/{1}/{2}/{3}/{4}/{5}/{6}/.json"

# SM end points (requires token generation with SM user)
# This api call is to approve the day off request. API belongs to SM module
# APPROVE /controller/rws/weekplan/web/requestcalendar/associate/actions/approveleave/{unitId}/{reviewerId}/{personId}/{reqStatusCd}/{statusDate}/{requestNo}/{mgrComment}.json
sm_approve_day_off_request = "controller/rws/weekplan/web/requestcalendar/associate/actions/approveleave/{0}/{1}/{2}/{3}/{4}/{5}/.json"

# SM end points (requires token generation with SM user)
# This api call is to decline the day off request. API belongs to SM module
# DECLINE /controller/rws/weekplan/web/requestcalendar/associate/actions/declineleave/{unitId}/{reviewerId}/{personId}/{reqStatusCd}/{statusDate}/{requestNo}/{notApprovedComments}/{mgrComment}.json
sm_decline_day_off_request = "controller/rws/weekplan/web/requestcalendar/associate/actions/declineleave/{0}/{1}/{2}/{3}/{4}/{5}/{6}/.json"

# SM end points (requires token generation with SM user)
# This api call is to edit the shift. API belongs to SM module
# EDIT /controller/rws/weekplan/mobile/schedule/shift/basic/{unitId}/{genShiftId}/{shiftSeqNo}.json
sm_edit_shift = (
    "controller/rws/weekplan/mobile/schedule/shift/basic/{0}/{1}/{2}.json"
)

# SM end points (requires token generation with SM user)
# This api call is to add the shift. API belongs to SM module
# ADD /controller/rws/weekplan/mobile/schedule/shift/basic/{unitId}/{genShiftId}.json
sm_add_shift = "controller/rws/weekplan/mobile/schedule/shift/basic/{0}/{1}.json"

# This api is to delete special pays for the user. API belongs to SM module
# POST controller/rta/mobile/associate/time/specialpays/delete/{personId}/{weekStartDate}.json
sm_delete_special_pays_timecard = (
    "controller/rta/mobile/associate/time/specialpays/delete/{0}/{1}.json"
)

# This api is to add special pays for the user. API belongs to SM module
# POST controller/rta/mobile/associate/time/specialpays/add/{personId}/{weekStartDate}.json
sm_add_special_pays_timecard = (
    "controller/rta/mobile/associate/time/specialpays/add/{0}/{1}.json"
)