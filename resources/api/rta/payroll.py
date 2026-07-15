# Timekeeping (RTA) payroll REST API path templates (Robot Variables).


# POST {base_url}/controller/rta/web/payroll/release/{unitId}/{releaseModel}/{payConfigName}/
#      {periodStartDate}/{periodEndDate}/{releaseMode}.json
TIMEKEEPING_PAYROLL_RELEASE_API = (
    "{BASE_URL}/controller/rta/web/payroll/release/{UNIT_ID}/{RELEASE_MODEL}/"
    "{PAY_CONFIG_NAME}/{PERIOD_START_DATE}/{PERIOD_END_DATE}/{RELEASE_MODE}.json"
)

# POST {base_url}/controller/rta/web/payroll/open/{unitId}/{releaseModel}/{payConfigName}/
#      {periodStartDate}/{periodEndDate}/{releaseMode}.json
TIMEKEEPING_PAYROLL_OPEN_API = (
    "{BASE_URL}/controller/rta/web/payroll/open/{UNIT_ID}/{RELEASE_MODEL}/"
    "{PAY_CONFIG_NAME}/{PERIOD_START_DATE}/{PERIOD_END_DATE}/{RELEASE_MODE}.json"
)

# --- Support (prefetch / preconditions for composites) ---

# GET {base_url}/controller/rta/web/unit/periodPayroll/fetchPayrollReleaseData/{unitId}/{year}/{frequency}/
#     {frequencyStartDate}/{reOpenForEdits}.json
TIMEKEEPING_FETCH_PAYROLL_RELEASE_DATA_API = (
    "{BASE_URL}/controller/rta/web/unit/periodPayroll/fetchPayrollReleaseData/{UNIT_ID}/"
    "{YEAR}/{FREQUENCY}/{FREQUENCY_START_DATE}/{REOPEN_FOR_EDITS}.json"
)

# POST {base_url}/controller/rta/web/payroll/data/generate/{unitId}/{releaseModel}/
#      {payConfigName}/{periodStartDate}/{periodEndDate}/{fileStatus}/{releaseMode}.json
TIMEKEEPING_PAYROLL_DATA_GENERATE_API = (
    "{BASE_URL}/controller/rta/web/payroll/data/generate/{UNIT_ID}/{RELEASE_MODEL}/"
    "{PAY_CONFIG_NAME}/{PERIOD_START_DATE}/{PERIOD_END_DATE}/"
    "{FILE_STATUS}/{RELEASE_MODE}.json"
)

# POST {base_url}/controller/rta/web/payroll/file/generate/{unitId}/{releaseModel}/
#      {payConfigName}/{periodStartDate}/{periodEndDate}/{fileStatus}/{releaseMode}.json
TIMEKEEPING_PAYROLL_FILE_GENERATE_API = (
    "{BASE_URL}/controller/rta/web/payroll/file/generate/{UNIT_ID}/{RELEASE_MODEL}/"
    "{PAY_CONFIG_NAME}/{PERIOD_START_DATE}/{PERIOD_END_DATE}/"
    "{FILE_STATUS}/{RELEASE_MODE}.json"
)

# GET {base_url}/servlet/ResaveTimecardUtilityServlet?weekStartDateSkeyCsv={csv}&personIdCsv={csv}
RESAVE_TIMECARD_UTILITY_SERVLET_URL = (
    "{BASE_URL}/servlet/ResaveTimecardUtilityServlet?"
    "weekStartDateSkeyCsv={WEEK_START_DATE_SKEY_CSV}&personIdCsv={PERSON_ID_CSV}"
)
