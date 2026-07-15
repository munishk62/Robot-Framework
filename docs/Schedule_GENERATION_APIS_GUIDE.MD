# =====================================================
# WFM SCHEDULE SETUP APIs - QA29_B0 ENVIRONMENT
# POSTMAN READY FORMAT
# =====================================================
# Base URL: https://wfmproductqa29.reflexisinc.com/RWS4
#
# These APIs are executed as part of schedule setup process
# in schedule_setup.resource and batch_plan_status.resource
# =====================================================

# =====================================================
# ACTUAL HEADERS USED BY AUTOMATION (from api_executor.resource)
# =====================================================
# Accept:                      application/json; charset=utf-8
# Content-Type:                application/json
# Referer:                     https://wfmproductqa29.reflexisinc.com/RWS4
# X-Csrf-Token-X:              {{AUTH_TOKEN}}
# x-reflexis-csrf-token-x:     {{AUTH_TOKEN}}
# X-reflexis-auth-token-X:     {{AUTH_TOKEN}}
# authToken:                   {{AUTH_TOKEN}}
#
# NOTE: There is NO "Authorization: Bearer" header.
#       Reflexis uses its own custom token headers listed above.
#       Replace {{AUTH_TOKEN}} with the raw token value (NOT "Bearer <token>").
# =====================================================


# =============================================================================
# 1. DELETE WEEK PLAN (Servlet - Clears all plan data)
# =============================================================================
# Method: GET
# Description: Deletes existing week plan data (forecast, workload, schedule) for a store/week
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/servlet/DeleteWeeklyPlanData?UNIT_ID={UNIT_ID}&DATE_SKEY={WEEK_START_DATE}
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/servlet/DeleteWeeklyPlanData?UNIT_ID=ZAUTOSTORE001&DATE_SKEY=20260518
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body: None (GET request)


# =============================================================================
# 2. GET UNIT STATE MAP (Check current schedule status)
# =============================================================================
# Method: POST
# Description: Retrieves the current state/status of schedule-related events for a unit/week
# Used to check: is_schedule_generated, is_schedule_published, can_generate_workload, etc.
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/common/unit/map/getUnitStateMap/{UNIT_ID}/{WEEK_START_DATE}.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/common/unit/map/getUnitStateMap/ZAUTOSTORE001/20260518.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{
  "states": ["SCHEDULE_GENERATED", "SCHEDULE_PUBLISHED", "SCHEDULE_WEEK_IN_PROGRESS", "WORKLOAD_GENERATED", "FORECAST_GENERATED"],
  "eventCodes": ["GENERATE_FC", "EDIT_FC", "GENERATE_SC", "GENERATE_WL", "DELETE_SC", "DELETE_WL", "PUBLISH_SC", "UNPUBLISH_SC", "REGEN_WL", "REGENERATE_SC", "EDIT_SC", "LOCK_SCHEDULE", "UNLOCK_SCHEDULE"]
}


# =============================================================================
# 3. GENERATE FORECAST
# =============================================================================
# Method: POST
# Description: Triggers forecast generation for a store/week
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_FC/{STORE}/{WEEK_START_DATE}/NONE.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_FC/ZAUTOSTORE001/20260518/NONE.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{
  "FORECAST_TYPE": "WEEKLY",
  "locationType": "U",
  "fcstGenMode": "BATCH",
  "planType": "WEEKPLAN",
  "debugMode": "N"
}


# =============================================================================
# 4. GENERATE WORKLOAD
# =============================================================================
# Method: PUT
# Description: Triggers workload generation for a store/week
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/workload/generate/{STORE}/{WEEK_START_DATE}.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/workload/generate/ZAUTOSTORE001/20260518.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body: None (PUT request with no body)


# =============================================================================
# 5. GENERATE SCHEDULE
# =============================================================================
# Method: POST
# Description: Triggers schedule generation (optimized or template-based) for a store/week
# SCHEDULE_GEN_TYPE: "Y" = Optimized, "N" = Template
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_SC/{STORE}/{WEEK_START_DATE}/NONE.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/GENERATE_SC/ZAUTOSTORE001/20260518/NONE.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{
  "FISCAL_YEAR": 0,
  "FISCAL_WEEK": 0,
  "SCHEDULE_GEN_TYPE": "Y"
}


# =============================================================================
# 6. GET GENERATED SHIFT ID AND SCHEDULE STATUS
# =============================================================================
# Method: GET
# Description: Retrieves the latest generated shift ID and schedule publish status for a week
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/mobile/schedule/core/mobileweeklyschedulecontext/{WEEK_START_DATE}/false.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/mobile/schedule/core/mobileweeklyschedulecontext/20260518/false.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body: None (GET request)


# =============================================================================
# 7. GET GEN SHIFT ID (Specific Week)
# =============================================================================
# Method: GET
# Description: Returns Gen Shift ID for a specific unit and week
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/ess/core/latestgenshift/{STORE}/{WEEK_START_DATE}.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/ess/core/latestgenshift/ZAUTOSTORE001/20260518.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body: None (GET request)


# =============================================================================
# 8. GET GENSHIFT ID (Using Unit SKEY)
# =============================================================================
# Method: GET
# Description: Retrieves the latest generated shift ID using unit_skey
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/shift/basic/genshift/{UNIT_SKEY}/{WEEK_START_DATE}.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/shift/basic/genshift/12345/20260518.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body: None (GET request)


# =============================================================================
# 9. GET FISCAL WEEK NUMBER
# =============================================================================
# Method: POST
# Description: Retrieves the fiscal week number for a given week start date
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/mobile/schedule/rosom/mobileschedulecontext/new/MGR/IPAD.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{
  "appId": "STORE_MGR",
  "appVersion": "4.5.20",
  "pkgName": "com.reflexisinc.reflexissm43",
  "DEVICE_TOKEN": "",
  "osName": "ios",
  "osVersion": "15.2"
}


# =============================================================================
# 10. PUBLISH SCHEDULE
# =============================================================================
# Method: GET
# Description: Publishes the schedule for a store/week
# USER_TYPE: MANAGER or ADMIN
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/mobile/schedule/core/advanced/publish/{STORE}/{WEEK_START_DATE}/{USER_TYPE}.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/mobile/schedule/core/advanced/publish/ZAUTOSTORE001/20260518/MANAGER.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body: None (GET request)


# =============================================================================
# 11. UNPUBLISH SCHEDULE
# =============================================================================
# Method: POST
# Description: Unpublishes the schedule for a store/week
# SCHEDULE_ITERATION: MANAGER
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/UNPUBLISH_SC/{STORE}/{WEEK_START_DATE}/{SCHEDULE_ITERATION}.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/UNPUBLISH_SC/ZAUTOSTORE001/20260518/MANAGER.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{}


# =============================================================================
# 12. DELETE SCHEDULE
# =============================================================================
# Method: POST
# Description: Deletes the schedule for a store/week
# SCHEDULE_ITERATION: MANAGER
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/DELETE_SC/{STORE}/{WEEK_START_DATE}/{SCHEDULE_ITERATION}.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/DELETE_SC/ZAUTOSTORE001/20260518/MANAGER.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{}


# =============================================================================
# 13. LOCK SCHEDULE
# =============================================================================
# Method: POST
# Description: Locks the schedule before publishing
# SCHEDULE_ITERATION: MANAGER
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/LOCK_SCHEDULE/{STORE}/{WEEK_START_DATE}/{SCHEDULE_ITERATION}.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/LOCK_SCHEDULE/ZAUTOSTORE001/20260518/MANAGER.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{}


# =============================================================================
# 14. UNLOCK SCHEDULE
# =============================================================================
# Method: POST
# Description: Unlocks a previously locked schedule
# SCHEDULE_ITERATION: MANAGER
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/UNLOCK_SCHEDULE/{STORE}/{WEEK_START_DATE}/{SCHEDULE_ITERATION}.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/core/advanced/executeplanstatusevent/UNLOCK_SCHEDULE/ZAUTOSTORE001/20260518/MANAGER.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{}


# =============================================================================
# 15. GENERATE WEEK IN PROGRESS (WIP) SCHEDULE (Servlet)
# =============================================================================
# Method: GET
# Description: Generates Week In Progress schedule copy for current week (0_0)
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/servlet/PublishSchedules?unitId={UNIT_ID}
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/servlet/PublishSchedules?unitId=ZAUTOSTORE001
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body: None (GET request)


# =============================================================================
# SHIFT MANAGEMENT APIs (Used during shift setup)
# =============================================================================


# =============================================================================
# 16. GET SHIFT DETAILS FOR ASSOCIATES
# =============================================================================
# Method: POST
# Description: Retrieves shift details for multiple associates by person IDs
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/shift/map/associatelvl/{GEN_SHIFT_ID}/withtasks.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/shift/map/associatelvl/62548/withtasks.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON - List of person IDs):
[12345, 67890]


# =============================================================================
# 17. ADD SHIFT
# =============================================================================
# Method: POST
# Description: Adds a new shift for an associate
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/shift/basic/{STORE}/{GEN_SHIFT_ID}/0/1440/false.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/shift/basic/ZAUTOSTORE001/62548/0/1440/false.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{
  "applyBreakRules": "DEFAULT",
  "assignedTo": 12345,
  "dedicated": false,
  "duration": 480,
  "reasonCd": null,
  "shiftLock": null,
  "shiftSource": "M",
  "staffGroupId": "SG001",
  "startDate": 20260518,
  "startDateSkey": 20260518,
  "startTime": 540,
  "wtasks": [
    {
      "activityType": "U",
      "duration": 480,
      "projectSkey": 0,
      "rolePreference": 1,
      "staffGroupId": "SG001",
      "startTime": 540,
      "taskId": 0,
      "taskSkey": 0
    }
  ]
}
# Notes for Body:
# - assignedTo: Person ID of the employee
# - duration: Shift duration in minutes (e.g., 480 = 8 hours)
# - startTime: Start time in minutes from midnight (e.g., 540 = 9:00 AM)
# - startDate/startDateSkey: Date in YYYYMMDD format


# =============================================================================
# 18. UNALLOCATE SHIFT
# =============================================================================
# Method: POST
# Description: Unallocates a shift (removes employee assignment but keeps as open shift)
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/shift/advanced/actions/unallocate/{GEN_SHIFT_ID}/{STORE}/{SHIFT_SEQ_NO}/0/1440/false.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/shift/advanced/actions/unallocate/62548/ZAUTOSTORE001/1/0/1440/false.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Content-Type": "application/json",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body (raw JSON):
{}


# =============================================================================
# 19. DELETE OPEN SHIFT
# =============================================================================
# Method: DELETE
# Description: Deletes an open (unallocated) shift
#
# URL:
https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/openshift/basic/{STORE}/{GEN_SHIFT_ID}/{SHIFT_SEQ_NO}/0/1440.json
#
# Example URL:
# https://wfmproductqa29.reflexisinc.com/RWS4/controller/rws/weekplan/web/schedule/openshift/basic/ZAUTOSTORE001/62548/1/0/1440.json
#
# Headers:
# {
#   "Accept": "application/json; charset=utf-8",
#   "Referer": "https://wfmproductqa29.reflexisinc.com/RWS4",
#   "X-Csrf-Token-X": "{{AUTH_TOKEN}}",
#   "x-reflexis-csrf-token-x": "{{AUTH_TOKEN}}",
#   "X-reflexis-auth-token-X": "{{AUTH_TOKEN}}",
#   "authToken": "{{AUTH_TOKEN}}"
# }
#
# Body: None (DELETE request)


# =====================================================
# VARIABLE PLACEHOLDERS LEGEND
# =====================================================
# {{AUTH_TOKEN}}       = Raw auth token value (obtained from mobile login response field "authToken")
# {STORE} / {UNIT_ID}  = Store identifier (e.g., ZAUTOSTORE001)
# {UNIT_SKEY}          = Unit surrogate key (numeric, from database)
# {WEEK_START_DATE}    = Week start date in YYYYMMDD format (e.g., 20260518)
# {SCHEDULE_ITERATION} = Schedule iteration type (typically: MANAGER)
# {USER_TYPE}          = User role type (MANAGER or ADMIN)
# {GEN_SHIFT_ID}       = Generated shift ID (numeric, returned from schedule generation)
# {SHIFT_SEQ_NO}       = Shift sequence number (numeric)
# {PERSON_ID}          = Employee person ID (numeric)
# {STAFF_GROUP_ID}     = Staff group identifier


# =====================================================
# HOW TO GET AUTH TOKEN FOR POSTMAN
# =====================================================
# 1. Make a GET request to:
#    https://wfmproductqa29.reflexisinc.com/kernel/views/authenticate/M/TESTING1.view
#    (Replace /W/ with /M/ in app_url from config.json)
#
# 2. Login with username + password via the mobile login page.
#
# 3. The response body will be JSON containing:
#    { "authToken": "<your_token_here>", ... }
#
# 4. Copy the value of "authToken" and set it as {{AUTH_TOKEN}} in Postman environment.
#    Do NOT prefix it with "Bearer" - use the raw token value as-is.


# =====================================================
# POSTMAN ENVIRONMENT VARIABLES (Suggested Setup)
# =====================================================
# Variable Name       | Example Value                                    | Description
# ------------------- | ------------------------------------------------ | -----------
# BASE_URL            | https://wfmproductqa29.reflexisinc.com/RWS4      | Base API URL
# AUTH_TOKEN          | eyJhbGciOi...                                    | Raw auth token (no "Bearer" prefix)
# STORE               | ZAUTOSTORE001                                    | Store/Unit ID
# WEEK_START_DATE     | 20260518                                         | Week start date (YYYYMMDD)
# GEN_SHIFT_ID        | 62548                                            | Generated shift ID
# SCHEDULE_ITERATION  | MANAGER                                          | Schedule iteration type
# USER_TYPE           | MANAGER                                          | User type for publish
# UNIT_ID             | ZAUTOSTORE001                                    | Unit ID (same as STORE)
# UNIT_SKEY           | 12345                                            | Unit surrogate key (from DB)


# =====================================================
# SCHEDULE SETUP WORKFLOW ORDER
# =====================================================
# 1. Delete Week Plan (optional - clears all data)
# 2. Get Unit State Map (check current status)
# 3. Generate Forecast
# 4. Wait & Verify Forecast Generated (using Unit State Map)
# 5. Generate Workload
# 6. Wait & Verify Workload Generated (using Unit State Map)
# 7. Generate Schedule
# 8. Wait & Verify Schedule Generated (using Unit State Map)
# 9. [If Week 0_0] Publish Schedule
# 10. [If Week 0_0] Generate Week In Progress Schedule
# 11. Process Shift Modifications:
#     a. Get Shift Details for Associates
#     b. Unallocate existing shifts
#     c. Delete open shifts
#     d. Add new shifts
# 12. Lock Schedule (if enabled)
# 13. Publish Schedule (for other weeks)
# =====================================================
