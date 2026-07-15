*** Settings ***
Documentation       Timekeeping payroll REST APIs — keywords and coverage in one place.
...
...                 = For test suites (import this file only) =
...                 = Payroll HTTP endpoints (see also ``resources/api/api_endpoints.py``)
...
...                 | API | Method | Purpose |
...                 | ``.../unit/periodPayroll/fetchPayrollReleaseData/...`` | GET | Period rows (support). |
...                 | ``.../rta/web/payroll/release/...`` | POST | Release pay group. |
...                 | ``.../rta/web/payroll/open/...`` | POST | Re-open for edits. |
...                 | ``.../rta/web/payroll/data/generate/...`` | POST | Generate payroll test data (queue/initiate). |
...                 | ``.../rta/web/payroll/file/generate/...`` | POST | Generate payroll file (trigger file output). |
...                 | ``.../servlet/ResaveTimecardUtilityServlet`` | GET | Resave timecard utility (person/week matrix). |

Library             Collections
Library             DateTime
Library             String
Resource            resources/api/api_executor.resource
Variables           resources/api/rta/payroll.py


*** Variables ***
${PAYROLL_FILE_STATUS_DATA_GENERATED}       D    # Data generated
${PAYROLL_FILE_STATUS_FILE_GENERATED}       F    # File generated


*** Keywords ***
Release Payroll For Period After Fetch Validation Using API
    [Documentation]    Calls ``Fetch Payroll Release Data Via API`` with ``period_start_date`` / ``period_end_date`` so the GET result is the matching row only,
    ...    validates ``action`` is ``R`` and ``fileStatus`` is ``N`` or null, then calls ``Release Payroll Via API`` using ``configName``
    ...    and ``configType`` from that row.
    ...
    ...    ``year`` is derived from the first four characters of ``period_start_date``.
    ...
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key | User key for WFM API authentication. |
    ...    | unit_id | Store or unit id. |
    ...    | period_start_date | Period start ``YYYYMMDD``. |
    ...    | period_end_date | Period end ``YYYYMMDD``. |
    ...    | frequency | Pay frequency code (e.g. ``SM``). |
    ...    | re_open_for_edits | ``reOpenForEdits`` path segment (e.g. ``N``). |
    ...    | frequency_start_date | Optional. Defaults to ``0``. |
    ...    | base_url | Optional. Defaults to ``base_url`` from environment config. |
    ...
    ...    *Returns:* Parsed JSON body from the release POST response.
    [Arguments]    ${auth_user_key}    ${unit_id}    ${period_start_date}    ${period_end_date}
    ...    ${frequency}    ${re_open_for_edits}    ${frequency_start_date}=0    ${base_url}=${EMPTY}
    ${ps}    Convert To String    ${period_start_date}
    ${pe}    Convert To String    ${period_end_date}
    ${year}    Get Substring    ${ps}    0    4
    ${period_row}    Fetch Payroll Release Data Via API    ${auth_user_key}    ${unit_id}    ${year}
    ...    ${frequency}    ${frequency_start_date}    ${re_open_for_edits}    ${base_url}    ${ps}    ${pe}
    Validate Payroll Release Row Ready For Release    ${period_row}
    ${pay_config_name}    Get From Dictionary    ${period_row}    configName
    ${release_model}    Get From Dictionary    ${period_row}    configType
    ${response}    Release Payroll Via API    ${auth_user_key}    ${unit_id}    ${release_model}
    ...    ${pay_config_name}    ${ps}    ${pe}    ${base_url}
    RETURN    ${response}

Reopen Payroll For Period After Fetch Validation Using API
    [Documentation]    Calls ``Fetch Payroll Release Data Via API`` with period bounds so the GET result is the matching row only,
    ...    validates ``action`` is ``O``,
    ...    then POSTs **open** using ``configName`` and ``configType`` from that row.
    ...
    ...    ``year`` is derived from the first four characters of ``period_start_date``.
    ...
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key | User key for WFM API authentication. |
    ...    | unit_id | Store or unit id. |
    ...    | period_start_date | Period start ``YYYYMMDD``. |
    ...    | period_end_date | Period end ``YYYYMMDD``. |
    ...    | frequency | Pay frequency code (e.g. ``SM``). |
    ...    | re_open_for_edits | ``reOpenForEdits`` path segment for the GET (e.g. ``Y`` when testing re-open flows). |
    ...    | frequency_start_date | Optional. Defaults to ``0``. |
    ...    | base_url | Optional. Defaults to ``base_url`` from environment config. |
    ...
    ...    *Returns:* Parsed JSON body from the re-open POST response.
    [Arguments]    ${auth_user_key}    ${unit_id}    ${period_start_date}    ${period_end_date}
    ...    ${frequency}    ${re_open_for_edits}    ${frequency_start_date}=0    ${base_url}=${EMPTY}
    ${ps}    Convert To String    ${period_start_date}
    ${pe}    Convert To String    ${period_end_date}
    ${year}    Get Substring    ${ps}    0    4
    ${period_row}    Fetch Payroll Release Data Via API    ${auth_user_key}    ${unit_id}    ${year}
    ...    ${frequency}    ${frequency_start_date}    ${re_open_for_edits}    ${base_url}    ${ps}    ${pe}
    Validate Payroll Release Row Ready For Reopen    ${period_row}
    ${pay_config_name}    Get From Dictionary    ${period_row}    configName
    ${release_model}    Get From Dictionary    ${period_row}    configType
    ${response}    Reopen Payroll Via API    ${auth_user_key}    ${unit_id}    ${release_model}
    ...    ${pay_config_name}    ${ps}    ${pe}    ${base_url}
    RETURN    ${response}

Release Payroll Via API
    [Documentation]    POSTs to the payroll release endpoint to release pay for a unit or employee group.
    ...
    ...    Path:
    ...    ``RWS4/controller/rta/web/payroll/release/{unitId}/{releaseModel}/{payConfigName}/{periodStartDate}/{periodEndDate}/{releaseMode}.json``
    ...
    ...    ``releaseMode`` is fixed to ``M`` (manual) per product contract.
    ...
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key | User key for WFM API authentication (e.g. SYSADMIN). |
    ...    | unit_id | Store id for store-based release, or ``CORP`` for employee group-based release. |
    ...    | release_model | ``E`` (employee) or ``S`` (store). |
    ...    | pay_config_name | Pay configuration name (path segment). |
    ...    | period_start_date | Period start in ``YYYYMMDD`` format. |
    ...    | period_end_date | Period end in ``YYYYMMDD`` format. |
    ...    | base_url | Optional. Defaults to ``base_url`` from environment config. |
    ...
    ...    *Returns:* Parsed JSON body of the response (``dict``).
    ...
    ...    HTTP status is validated by ``Send A WFM POST Request`` (expects 200 or 201). The response body is then
    ...    checked with ``Validate Payroll Release Api Response`` (``statusCode`` 1, ``metaInfo.fileStatus`` ``Q``; message logged).
    [Arguments]    ${auth_user_key}    ${unit_id}    ${release_model}    ${pay_config_name}
    ...    ${period_start_date}    ${period_end_date}    ${base_url}=${EMPTY}
    VAR    ${release_mode}    M
    IF    '${base_url}' == '${EMPTY}'
        ${resolved_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${resolved_base_url}    ${base_url}
    END
    ${endpoint_url}    Format String    ${TIMEKEEPING_PAYROLL_RELEASE_API}
    ...    BASE_URL=${resolved_base_url}
    ...    UNIT_ID=${unit_id}
    ...    RELEASE_MODEL=${release_model}
    ...    PAY_CONFIG_NAME=${pay_config_name}
    ...    PERIOD_START_DATE=${period_start_date}
    ...    PERIOD_END_DATE=${period_end_date}
    ...    RELEASE_MODE=${release_mode}
    Log    Payroll release API URL: ${endpoint_url}    level=INFO
    VAR    &{release_post_body}    &{EMPTY}
    ${response_json}    Send A WFM POST Request    ${auth_user_key}    ${resolved_base_url}    ${endpoint_url}
    ...    ${release_post_body}
    Log    Payroll release API response: ${response_json}    level=INFO
    Validate Payroll Release Api Response    ${response_json}
    RETURN    ${response_json}

Reopen Payroll Via API
    [Documentation]    POSTs to the payroll **open** endpoint to re-open a released period for edits.
    ...
    ...    Path:
    ...    ``RWS4/controller/rta/web/payroll/open/{unitId}/{releaseModel}/{payConfigName}/{periodStartDate}/{periodEndDate}/{releaseMode}.json``
    ...
    ...    ``releaseMode`` is fixed to ``M`` (manual) per product contract.
    ...
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key | User key for WFM API authentication (e.g. SYSADMIN). |
    ...    | unit_id | Store id or ``CORP`` for employee group-based. |
    ...    | release_model | ``E`` or ``S`` (must match ``configType`` from fetch when using composite flow). |
    ...    | pay_config_name | Pay configuration name (path segment). |
    ...    | period_start_date | Period start ``YYYYMMDD``. |
    ...    | period_end_date | Period end ``YYYYMMDD``. |
    ...    | base_url | Optional. Defaults to ``base_url`` from environment config. |
    ...
    ...    *Returns:* Parsed JSON body of the response (``dict``).
    ...
    ...    HTTP status is validated by ``Send A WFM POST Request``. The body is checked with ``Validate Payroll Reopen Api Response``.
    [Arguments]    ${auth_user_key}    ${unit_id}    ${release_model}    ${pay_config_name}
    ...    ${period_start_date}    ${period_end_date}    ${base_url}=${EMPTY}
    VAR    ${release_mode}    M
    IF    '${base_url}' == '${EMPTY}'
        ${resolved_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${resolved_base_url}    ${base_url}
    END
    ${endpoint_url}    Format String    ${TIMEKEEPING_PAYROLL_OPEN_API}
    ...    BASE_URL=${resolved_base_url}
    ...    UNIT_ID=${unit_id}
    ...    RELEASE_MODEL=${release_model}
    ...    PAY_CONFIG_NAME=${pay_config_name}
    ...    PERIOD_START_DATE=${period_start_date}
    ...    PERIOD_END_DATE=${period_end_date}
    ...    RELEASE_MODE=${release_mode}
    Log    Payroll re-open API URL: ${endpoint_url}    level=INFO
    VAR    &{reopen_post_body}    &{EMPTY}
    ${response_json}    Send A WFM POST Request    ${auth_user_key}    ${resolved_base_url}    ${endpoint_url}
    ...    ${reopen_post_body}
    Log    Payroll re-open API response: ${response_json}    level=INFO
    Validate Payroll Reopen Api Response    ${response_json}
    RETURN    ${response_json}

Generate Payroll Data Via API
    [Documentation]    POSTs to the payroll data **generate** endpoint to queue payroll data generation for automation.
    ...
    ...    Path:
    ...    ``RWS4/controller/rta/web/payroll/data/generate/{unitId}/{releaseModel}/{payConfigName}/``
    ...    ``{periodStartDate}/{periodEndDate}/{fileStatus}/{releaseMode}.json``
    ...
    ...    ``releaseMode`` is fixed to ``M`` (manual) per product contract.
    ...
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key | User key for WFM API authentication (e.g. ``SYSADMIN``). |
    ...    | unit_id | Store or unit id (path segment). |
    ...    | release_model | ``E`` (employee) or ``S`` (store). |
    ...    | pay_config_name | Pay configuration name (path segment). |
    ...    | period_start_date | Period start ``YYYYMMDD``. |
    ...    | period_end_date | Period end ``YYYYMMDD``. |
    ...    | file_status | ``fileStatus`` path segment (e.g. ``Q``). |
    ...    | base_url | Optional. Defaults to ``base_url`` from environment config. |
    ...
    ...    *Returns:* Parsed JSON body of the response (``dict``).
    ...
    ...    HTTP status is validated by ``Send A WFM POST Request`` (expects 200 or 201). The body is checked with
    ...    ``Validate Payroll Api Response`` (expected ``metaInfo.fileStatus`` ``D``).
    ...
    [Arguments]    ${auth_user_key}    ${unit_id}    ${release_model}    ${pay_config_name}
    ...    ${period_start_date}    ${period_end_date}    ${file_status}    ${base_url}=${EMPTY}
    ${ps}    Convert To String    ${period_start_date}
    ${pe}    Convert To String    ${period_end_date}
    ${fs}    Convert To String    ${file_status}
    VAR    ${release_mode}    M
    IF    '${base_url}' == '${EMPTY}'
        ${resolved_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${resolved_base_url}    ${base_url}
    END
    ${endpoint_url}    Format String    ${TIMEKEEPING_PAYROLL_DATA_GENERATE_API}
    ...    BASE_URL=${resolved_base_url}
    ...    UNIT_ID=${unit_id}
    ...    RELEASE_MODEL=${release_model}
    ...    PAY_CONFIG_NAME=${pay_config_name}
    ...    PERIOD_START_DATE=${ps}
    ...    PERIOD_END_DATE=${pe}
    ...    FILE_STATUS=${fs}
    ...    RELEASE_MODE=${release_mode}
    Log    Payroll data generate API URL: ${endpoint_url}    level=INFO
    VAR    &{generate_post_body}    &{EMPTY}
    ${response_json}    Send A WFM POST Request    ${auth_user_key}    ${resolved_base_url}    ${endpoint_url}
    ...    ${generate_post_body}
    Log    Payroll data generate API response: ${response_json}    level=INFO
    Validate Payroll Api Response    ${response_json}    ${PAYROLL_FILE_STATUS_DATA_GENERATED}
    RETURN    ${response_json}

Generate Payroll File Via API
    [Documentation]    POSTs to the payroll file **generate** endpoint to trigger payroll file output for automation.
    ...
    ...    Path:
    ...    ``RWS4/controller/rta/web/payroll/file/generate/{unitId}/{releaseModel}/{payConfigName}/``
    ...    ``{periodStartDate}/{periodEndDate}/{fileStatus}/{releaseMode}.json``
    ...
    ...    ``releaseMode`` is fixed to ``M`` (manual) per product contract.
    ...
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key | User key for WFM API authentication (e.g. ``SYSADMIN``). |
    ...    | unit_id | Store or unit id (path segment). |
    ...    | release_model | ``E`` (employee) or ``S`` (store). |
    ...    | pay_config_name | Pay configuration name (path segment). |
    ...    | period_start_date | Period start ``YYYYMMDD``. |
    ...    | period_end_date | Period end ``YYYYMMDD``. |
    ...    | file_status | ``fileStatus`` path segment (e.g. ``D`` after data generation). |
    ...    | base_url | Optional. Defaults to ``base_url`` from environment config. |
    ...
    ...    *Returns:* Parsed JSON body of the response (``dict``).
    ...
    ...    HTTP status is validated by ``Send A WFM POST Request`` (expects 200 or 201). The body is checked with
    ...    ``Validate Payroll Api Response`` (expected ``metaInfo.fileStatus`` ``F``).
    ...
    [Arguments]    ${auth_user_key}    ${unit_id}    ${release_model}    ${pay_config_name}
    ...    ${period_start_date}    ${period_end_date}    ${file_status}    ${base_url}=${EMPTY}
    ${ps}    Convert To String    ${period_start_date}
    ${pe}    Convert To String    ${period_end_date}
    ${fs}    Convert To String    ${file_status}
    VAR    ${release_mode}    M
    IF    '${base_url}' == '${EMPTY}'
        ${resolved_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${resolved_base_url}    ${base_url}
    END
    ${endpoint_url}    Format String    ${TIMEKEEPING_PAYROLL_FILE_GENERATE_API}
    ...    BASE_URL=${resolved_base_url}
    ...    UNIT_ID=${unit_id}
    ...    RELEASE_MODEL=${release_model}
    ...    PAY_CONFIG_NAME=${pay_config_name}
    ...    PERIOD_START_DATE=${ps}
    ...    PERIOD_END_DATE=${pe}
    ...    FILE_STATUS=${fs}
    ...    RELEASE_MODE=${release_mode}
    Log    Payroll file generate API URL: ${endpoint_url}    level=INFO
    VAR    &{generate_post_body}    &{EMPTY}
    ${response_json}    Send A WFM POST Request    ${auth_user_key}    ${resolved_base_url}    ${endpoint_url}
    ...    ${generate_post_body}
    Log    Payroll file generate API response: ${response_json}    level=INFO
    Validate Payroll Api Response    ${response_json}    ${PAYROLL_FILE_STATUS_FILE_GENERATED}
    RETURN    ${response_json}

Fetch Payroll Release Data Via API
    [Documentation]    GETs payroll release configuration rows for a unit (``fetchPayrollReleaseData``). Used by composite flows.
    ...
    ...    Path:
    ...    ``RWS4/controller/rta/web/unit/periodPayroll/fetchPayrollReleaseData/{unitId}/{year}/{frequency}/{frequencyStartDate}/{reOpenForEdits}.json``
    ...
    ...    When ``@{period_filter}`` supplies two ``YYYYMMDD`` values (start and end), the response list is reduced to the
    ...    single row whose ``periodStartDate`` / ``periodEndDate`` match; that dict is returned. With no period arguments, the
    ...    full parsed JSON list is returned (unchanged).
    ...
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key | User key for WFM API authentication. |
    ...    | unit_id | Store or unit id. |
    ...    | year | Calendar year (use the year of ``period_start_date``, typically first four digits of ``YYYYMMDD``). |
    ...    | frequency | Pay frequency code (e.g. ``SM``, ``WK``). |
    ...    | frequency_start_date | Path segment; use ``0`` when not filtering by frequency start. |
    ...    | re_open_for_edits | Path segment (e.g. ``N``). |
    ...    | base_url | Optional. Defaults to ``base_url`` from environment config. |
    ...    | @{period_filter} | Optional trailing pair ``period_start_date`` ``period_end_date`` (``YYYYMMDD`` each). Omit both to return full list; pass both to resolve a single matching row. |
    ...
    ...    *Returns:* Parsed JSON: either a ``list`` of period rows (no ``@{period_filter}``), or one ``dict`` (two period values given).
    [Arguments]    ${auth_user_key}    ${unit_id}    ${year}    ${frequency}
    ...    ${frequency_start_date}    ${re_open_for_edits}    ${base_url}=${EMPTY}    @{period_filter}
    IF    '${base_url}' == '${EMPTY}'
        ${resolved_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${resolved_base_url}    ${base_url}
    END
    ${endpoint_url}    Format String    ${TIMEKEEPING_FETCH_PAYROLL_RELEASE_DATA_API}
    ...    BASE_URL=${resolved_base_url}
    ...    UNIT_ID=${unit_id}
    ...    YEAR=${year}
    ...    FREQUENCY=${frequency}
    ...    FREQUENCY_START_DATE=${frequency_start_date}
    ...    REOPEN_FOR_EDITS=${re_open_for_edits}
    Log    fetchPayrollReleaseData URL: ${endpoint_url}    level=INFO
    ${response_json}    Send A WFM GET Request    ${auth_user_key}    ${resolved_base_url}    ${endpoint_url}
    Log    fetchPayrollReleaseData response: ${response_json}    level=INFO
    ${pf_len}    Get Length    ${period_filter}
    IF    ${pf_len} == 1
        Fail    Expected zero or two period filter values (period_start_date, period_end_date); got one.
    ELSE IF    ${pf_len} == 2
        ${pf_start}    Get From List    ${period_filter}    0
        ${pf_end}    Get From List    ${period_filter}    1
        ${period_row}    Find Payroll Release Row For Period In List    ${response_json}    ${pf_start}    ${pf_end}
        RETURN    ${period_row}
    ELSE IF    ${pf_len} > 2
        Fail    Expected at most two period filter values; got ${pf_len}.
    END
    RETURN    ${response_json}

Find Payroll Release Row For Period In List
    [Documentation]    From a ``fetchPayrollReleaseData`` JSON array, returns the row whose ``periodStartDate`` and
    ...    ``periodEndDate`` match ``period_start`` and ``period_end`` (``YYYYMMDD`` as int or string). Rows that cannot be
    ...    compared (missing keys or non-numeric dates) are skipped. Fails if no row matches.
    [Tags]    robot:private
    [Arguments]    ${rows}    ${period_start}    ${period_end}
    ${expected_ps}    Convert To Integer    ${period_start}
    ${expected_pe}    Convert To Integer    ${period_end}
    FOR    ${row}    IN    @{rows}
        ${is_match}    Run Keyword And Return Status    Payroll Release Period Row Matches Dates
        ...    ${row}    ${expected_ps}    ${expected_pe}
        IF    not ${is_match}    CONTINUE
        RETURN    ${row}
    END
    Fail    No payroll release row for the requested period in fetch response.

Payroll Release Period Row Matches Dates
    [Documentation]    Inner check: succeeds iff ``periodStartDate`` / ``periodEndDate`` equal expected integers (after coercion).
    [Tags]    robot:private
    [Arguments]    ${row}    ${expected_ps}    ${expected_pe}
    ${rps_raw}    Get From Dictionary    ${row}    periodStartDate
    ${rpe_raw}    Get From Dictionary    ${row}    periodEndDate
    ${rps}    Convert To Integer    ${rps_raw}
    ${rpe}    Convert To Integer    ${rpe_raw}
    Should Be Equal As Integers    ${rps}    ${expected_ps}
    Should Be Equal As Integers    ${rpe}    ${expected_pe}

Validate Payroll Release Row Ready For Release
    [Documentation]    Internal: fails unless the period row allows a release (``action`` ``R``, ``fileStatus`` ``N`` or null).
    ...
    ...    Called from ``Release Payroll For Period After Fetch Validation Using API``.
    [Tags]    robot:private
    [Arguments]    ${row}
    ${is_none}    Evaluate    $row is None
    IF    ${is_none}
        Fail    No payroll release row for the requested period in fetch response.
    END
    ${action}    Get From Dictionary    ${row}    action
    Should Be Equal As Strings    ${action}    R
    ...    msg=Expected action 'R' before release; got '${action}'.
    ${fs_valid}    Evaluate    ($row.get("fileStatus") is None or $row.get("fileStatus") == "N")
    IF    "${fs_valid}" != "True"
        ${got_fs}    Evaluate    $row.get("fileStatus")
        Fail    Expected fileStatus 'N' or null before release; got '${got_fs}'.
    END

Validate Payroll Release Row Ready For Reopen
    [Documentation]    Internal: fails unless the period row allows re-open (``action`` ``O``, ``fileStatus`` ``F``).
    ...
    ...    Called from ``Reopen Payroll For Period After Fetch Validation Using API``.
    [Tags]    robot:private
    [Arguments]    ${row}
    ${is_none}    Evaluate    $row is None
    IF    ${is_none}
        Fail    No payroll row for the requested period in fetch response.
    END
    ${action}    Get From Dictionary    ${row}    action
    Should Be Equal As Strings    ${action}    O
    ...    msg=Expected action 'O' before re-open; got '${action}'.
    ${got_fs}    Evaluate    $row.get("fileStatus")
    Should Be Equal As Strings    ${got_fs}    F
    ...    msg=Expected fileStatus 'F' before re-open; got '${got_fs}'.

Validate Payroll Release Api Response
    [Documentation]    Logs the release API ``message`` (console + log). Fails unless ``statusCode`` is ``1`` and
    ...    ``metaInfo.fileStatus`` is ``Q`` (released / complete per product contract).
    ...
    ...    Example success body: ``statusCode`` 1, ``metaInfo.fileStatus`` ``Q``, and ``message`` like pay group release complete.
    ...    Example failure body: ``statusCode`` -1 and an error ``message``.
    [Tags]    robot:private
    [Arguments]    ${response}
    ${status_code}    Get From Dictionary    ${response}    statusCode
    ${msg}    Get From Dictionary    ${response}    message
    Log To Console    Payroll release API message: ${msg}
    Log    Payroll release API message: ${msg}    level=INFO
    Should Be Equal As Integers    ${status_code}    1
    ...    msg=Payroll release failed (statusCode=${status_code}): ${msg}
    ${meta_info}    Get From Dictionary    ${response}    metaInfo
    ${file_status}    Get From Dictionary    ${meta_info}    fileStatus
    Log To Console    Payroll release API metaInfo.fileStatus: ${file_status}
    Log    Payroll release API metaInfo.fileStatus: ${file_status}    level=INFO
    Should Be Equal As Strings    ${file_status}    Q
    ...    msg=Expected metaInfo.fileStatus 'Q' after successful release, got '${file_status}'. Message: ${msg}

Validate Payroll Reopen Api Response
    [Documentation]    Logs the re-open API ``message`` (console + log). Fails unless ``statusCode`` is ``1`` and
    ...    ``metaInfo.fileStatus`` is ``N`` (period open for edits; adjust if the product returns another code).
    ...
    ...    Example success: ``statusCode`` 1 and a completion ``message``.
    [Tags]    robot:private
    [Arguments]    ${response}
    ${status_code}    Get From Dictionary    ${response}    statusCode
    ${msg}    Get From Dictionary    ${response}    message
    Log To Console    Payroll re-open API message: ${msg}
    Log    Payroll re-open API message: ${msg}    level=INFO
    Should Be Equal As Integers    ${status_code}    1
    ...    msg=Payroll re-open failed (statusCode=${status_code}): ${msg}
    ${meta_info}    Get From Dictionary    ${response}    metaInfo
    ${file_status}    Get From Dictionary    ${meta_info}    fileStatus
    Log To Console    Payroll re-open API metaInfo.fileStatus: ${file_status}
    Log    Payroll re-open API metaInfo.fileStatus: ${file_status}    level=INFO
    Should Be Equal As Strings    ${file_status}    N
    ...    msg=Expected metaInfo.fileStatus 'N' after successful re-open, got '${file_status}'. Message: ${msg}

Validate Payroll Api Response
    [Documentation]    Logs the payroll API ``message`` (console + log). Fails unless ``statusCode`` is ``1``
    ...    and ``metaInfo.fileStatus`` equals the expected ``file_status`` value passed as argument.
    ...    | =Arguments= | =Description= |
    ...    | response    | Parsed JSON response dict from the API call. |
    ...    | file_status | Expected ``metaInfo.fileStatus`` value (e.g. ``Q`` after release, ``D`` after data generation). |
    [Tags]    robot:private
    [Arguments]    ${response}    ${file_status}
    ${status_code}    Get From Dictionary    ${response}    statusCode
    ${msg}    Get From Dictionary    ${response}    message
    Log To Console    Payroll API message: ${msg}
    Log    Payroll API message: ${msg}    level=INFO
    Should Be Equal As Integers    ${status_code}    1
    ...    msg=Payroll API failed (statusCode=${status_code}): ${msg}
    ${has_meta}    Run Keyword And Return Status    Dictionary Should Contain Key    ${response}    metaInfo
    IF    ${has_meta}
        ${meta_info}    Get From Dictionary    ${response}    metaInfo
        ${has_fs}    Run Keyword And Return Status    Dictionary Should Contain Key    ${meta_info}    fileStatus
        IF    ${has_fs}
            ${actual_file_status}    Get From Dictionary    ${meta_info}    fileStatus
            Log To Console    Payroll API metaInfo.fileStatus: ${actual_file_status}
            Log    Payroll API metaInfo.fileStatus: ${actual_file_status}    level=INFO
            Should Be Equal As Strings    ${actual_file_status}    ${file_status}
            ...    msg=Expected metaInfo.fileStatus '${file_status}', got '${actual_file_status}'. Message: ${msg}
        END
    END

Resave Timecard Utility Via Servlet And Validate Output
    [Documentation]    GETs ``ResaveTimecardUtilityServlet`` for every week start between ``first_week_start`` and
    ...    ``last_week_start`` (inclusive, stepped by 7 days) and each ``@{person_ids}``, then validates every
    ...    returned ``personId_weekStart_weekEnd`` entry is contained in the expected person/week matrix.
    ...    Partial success is allowed when some person ids have no resave records.
    ...
    ...    Example URL:
    ...    ``{base_url}/servlet/ResaveTimecardUtilityServlet?weekStartDateSkeyCsv=20260308,20260315&personIdCsv=1034,1035,1036``
    ...
    ...    Example validated output:
    ...    ``[1034_20260308_20260314, 1035_20260308_20260314, 1036_20260308_20260314, 1034_20260315_20260321, ...]``
    ...
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key | User key for WFM API authentication. |
    ...    | first_week_start | First week start date ``YYYYMMDD``. |
    ...    | last_week_start | Last week start date ``YYYYMMDD`` (inclusive). |
    ...    | @{person_ids} | Person or employee ids to include in ``personIdCsv``. |
    ...    | base_url | Optional. Defaults to ``base_url`` from environment config. |
    ...
    ...    *Returns:* ``list`` of validated ``personId_weekStart_weekEnd`` strings from the servlet response.
    [Arguments]    ${auth_user_key}    ${first_week_start}    ${last_week_start}    @{person_ids}
    ...    ${base_url}=${EMPTY}
    IF    '${base_url}' == '${EMPTY}'
        ${resolved_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${resolved_base_url}    ${base_url}
    END
    ${server_df}    Get Config Value    SERVER_DF
    @{week_starts}    Build Week Start Date Skey List Between Range    ${first_week_start}    ${last_week_start}    ${server_df}
    ${week_start_csv}    Catenate    SEPARATOR=,    @{week_starts}
    ${person_id_csv}    Catenate    SEPARATOR=,    @{person_ids}
    ${endpoint_url}    Format String    ${RESAVE_TIMECARD_UTILITY_SERVLET_URL}
    ...    BASE_URL=${resolved_base_url}
    ...    WEEK_START_DATE_SKEY_CSV=${week_start_csv}
    ...    PERSON_ID_CSV=${person_id_csv}
    Log    ResaveTimecardUtilityServlet URL: ${endpoint_url}    level=INFO
    ${response}    Send A WFM GET Request    ${auth_user_key}    ${resolved_base_url}    ${endpoint_url}    True
    ${expected_output}    Build Expected Resave Timecard Utility Output    ${week_starts}    ${person_ids}    ${server_df}
    ${actual_output}    Parse Resave Timecard Utility Servlet Response    ${response.text}
    Validate Resave Timecard Utility Servlet Output    ${expected_output}    ${actual_output}
    RETURN    ${actual_output}

Build Week Start Date Skey List Between Range
    [Documentation]    Returns inclusive week start dates from ``first_week_start`` through ``last_week_start``, stepping 7 days.
    ...    Uses ``SERVER_DF`` (``%Y%m%d``) for date skey parsing and output.
    [Tags]    robot:private
    [Arguments]    ${first_week_start}    ${last_week_start}    ${server_df}
    ${first}    Convert To String    ${first_week_start}
    ${last}    Convert To String    ${last_week_start}
    VAR    @{week_starts}    @{EMPTY}
    VAR    ${current}    ${first}
    WHILE    '${current}' <= '${last}'
        Append To List    ${week_starts}    ${current}
        ${current}    Add Time To Date    ${current}    7 days    result_format=${server_df}    date_format=${server_df}
    END
    RETURN    @{week_starts}

Build Expected Resave Timecard Utility Output
    [Documentation]    Builds expected ``personId_weekStart_weekEnd`` values in week-then-person order.
    ...    Uses ``SERVER_DF`` (``%Y%m%d``) for week end date skey calculation.
    [Tags]    robot:private
    [Arguments]    ${week_starts}    ${person_ids}    ${server_df}
    VAR    @{expected_output}    @{EMPTY}
    FOR    ${week_start}    IN    @{week_starts}
        ${week_end}    Add Time To Date    ${week_start}    6 days    result_format=${server_df}    date_format=${server_df}
        FOR    ${person_id}    IN    @{person_ids}
            ${entry}    Catenate    SEPARATOR=_    ${person_id}    ${week_start}    ${week_end}
            Append To List    ${expected_output}    ${entry}
        END
    END
    RETURN    ${expected_output}

Parse Resave Timecard Utility Servlet Response
    [Documentation]    Parses servlet body into a list of ``personId_weekStart_weekEnd`` tokens.
    ...    Supports comma- and newline-delimited bodies and ignores non-matrix lines such as
    ...    ``Person Id is not present : {personId}`` warnings.
    [Tags]    robot:private
    [Arguments]    ${response_text}
    ${normalized}    Replace String Using Regexp    ${response_text}    \\r\\n?    \n
    ${without_brackets}    Replace String Using Regexp    ${normalized}    [\\[\\]]    ${EMPTY}
    @{lines}    Split String    ${without_brackets}    \n
    VAR    @{parsed_output}    @{EMPTY}
    FOR    ${line}    IN    @{lines}
        @{tokens}    Split String    ${line}    ,
        FOR    ${token}    IN    @{tokens}
            ${trimmed}    Strip String    ${token}
            IF    $trimmed == ''    CONTINUE
            ${is_resave_entry}    Run Keyword And Return Status    Should Match Regexp    ${trimmed}    ^.+_\\d{8}_\\d{8}$
            IF    ${is_resave_entry}
                Append To List    ${parsed_output}    ${trimmed}
                CONTINUE
            END
            ${is_missing_person_warning}    Run Keyword And Return Status    Should Contain    ${trimmed}    Person Id is not present
            IF    ${is_missing_person_warning}
                Log    ResaveTimecardUtilityServlet warning: ${trimmed}    level=WARN
            ELSE
                Log    ResaveTimecardUtilityServlet ignored response token: ${trimmed}    level=WARN
            END
        END
    END
    RETURN    ${parsed_output}

Validate Resave Timecard Utility Servlet Output
    [Documentation]    Fails unless every returned servlet entry is a valid ``personId_weekStart_weekEnd`` value contained in ``expected_output``.
    ...    Partial success is allowed when some submitted person ids have no resave records.
    [Tags]    robot:private
    [Arguments]    ${expected_output}    ${actual_output}
    ${expected_len}    Get Length    ${expected_output}
    ${actual_len}    Get Length    ${actual_output}
    IF    not ${actual_len}
        Fail    ResaveTimecardUtilityServlet returned no resave entries; expected up to ${expected_len}.
    END
    FOR    ${entry}    IN    @{actual_output}
        Should Match Regexp    ${entry}    ^.+_\\d{8}_\\d{8}$
        ...    msg=Invalid servlet entry '${entry}'; expected personId_weekStart_weekEnd with YYYYMMDD dates.
        List Should Contain Value    ${expected_output}    ${entry}
        ...    msg=ResaveTimecardUtilityServlet returned unexpected entry '${entry}' not in expected person/week matrix.
    END
    Log    ResaveTimecardUtilityServlet validated ${actual_len} of ${expected_len} expected resave entries.    level=INFO
