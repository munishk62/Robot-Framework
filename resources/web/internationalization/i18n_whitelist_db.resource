*** Settings ***
Documentation       Database helpers for internationalization (i18n) visible-text verification.
...
...                 Fetches literal strings (unit identifiers, names, employee display names) from DB2
...                 so suites can pass them to ``text_whitelist`` on
...                 `Verify Visible Texts Against Locale Bundles` in ``WebInternationalizationLibrary``.
...
...                 Uses ``Execute Query And Return Result`` (connect/disconnect per query) like
...                 ``resources/web/om/unit_db.resource``. This resource does *not* import ``WebInternationalizationLibrary``;
...                 suites wire ``${whitelist}`` into the library (e.g. ``Set Cached I18n Text Whitelist``)
...                 or use ``resources/web/internationalization/i18n_pabot_shared.resource`` for Pabot publish/apply.

Resource            resources/web/common/database.resource
Library             Collections
Library             String


*** Keywords ***
Get Db First Column Values As Text List
    [Documentation]    Runs ``sql_query`` and returns the first column of each row as stripped strings.
    ...    Empty or null-like values are omitted. Result tuples come from ``Execute Query And Return Result``.
    ...
    ...    | =Arguments= | =Description= |
    ...    | sql_query | Full SQL ``SELECT`` (single column recommended). |
    ...
    ...    | =Returns= | =Description= |
    ...    | values | List of strings suitable for ``text_whitelist``. |
    ...
    ...    Example usage:
    ...    | ${ids}=    Get Db First Column Values As Text List    SELECT unit_id FROM unit WHERE owner_id = '1' |
    [Arguments]    ${sql_query}
    ${result}=    Execute Query And Return Result    ${sql_query}
    VAR    @{out}=    @{EMPTY}
    IF    not ${result}    RETURN    ${out}
    FOR    ${row}    IN    @{result}
        ${val}=    Get From List    ${row}    0
        IF    $val is None    CONTINUE
        ${s}=    Convert To String    ${val}
        ${s}=    Strip String    ${s}
        ${is_empty}=    Evaluate    $s in ('', 'None')
        IF    ${is_empty}    CONTINUE
        Append To List    ${out}    ${s}
    END
    RETURN    ${out}

Get I18n Text Whitelist From Db Queries
    [Documentation]    Executes each SQL query, collects first-column text values, then merges them into
    ...    one list with duplicates removed (first-seen order preserved). Use for ad hoc or extended
    ...    whitelist sources beyond the default owner-scoped queries.
    ...
    ...    | =Arguments= | =Description= |
    ...    | sql_queries | One or more full SQL strings (each should return one text column). |
    ...
    ...    | =Returns= | =Description= |
    ...    | whitelist | Combined de-duplicated list for ``text_whitelist``. |
    ...
    ...    Example usage:
    ...    | @{queries}=    Create List    SELECT x FROM t WHERE owner_id = '1'    SELECT y FROM u WHERE owner_id = '1' |
    ...    | ${wl}=    Get I18n Text Whitelist From Db Queries    @{queries} |
    [Arguments]    @{sql_queries}
    VAR    @{merged}=    @{EMPTY}
    FOR    ${q}    IN    @{sql_queries}
        ${part}=    Get Db First Column Values As Text List    ${q}
        ${merged}=    Combine Lists    ${merged}    ${part}
    END
    ${unique}=    Evaluate    list(dict.fromkeys($merged))
    RETURN    ${unique}

Get I18n Text Whitelist From Db
    [Documentation]    Loads default whitelist literals for the current owner: ``unit.unit_id``, ``unit.unit_name``,
    ...    and ``RWS_EMPLOYEE.display_name``. Optional fragments add ``AND (fragment)`` to the ``unit`` queries
    ...    and/or the employee query so you can narrow rows (e.g. status flags) per table.
    ...
    ...    | =Arguments= | =Description= |
    ...    | owner_id | Owner key; pass ``${EMPTY}`` to use ``OWNER_ID`` from test config (same as ``unit_db.resource``). |
    ...    | unit_extra_where | Optional SQL predicate for ``unit`` only (no leading ``AND``); appended as ``AND (...)``. |
    ...    | employee_extra_where | Optional SQL predicate for ``RWS_EMPLOYEE``; appended as ``AND (...)``. |
    ...
    ...    | =Returns= | =Description= |
    ...    | whitelist | De-duplicated list for ``text_whitelist`` on `Verify Visible Texts Against Locale Bundles`. |
    ...
    ...    Example usage:
    ...    | ${wl}=    Get I18n Text Whitelist From Db |
    ...    | Set Cached I18n Text Whitelist    ${wl} |
    ...    | ${wl}=    Get I18n Text Whitelist From Db    ${EMPTY}    status = 'A' |
    ...    | Verify Visible Texts Against Locale Bundles    ${LOCALE}    ${texts}    text_whitelist=${wl} |
    [Arguments]    ${owner_id}=${EMPTY}    ${unit_extra_where}=${EMPTY}    ${employee_extra_where}=${EMPTY}
    IF    '${owner_id}' == '${EMPTY}'
        VAR    ${oid}=    Get Config Value    OWNER_ID
    ELSE
        VAR    ${oid}=    ${owner_id}
    END
    IF    '${unit_extra_where}' != '${EMPTY}'
        VAR    ${q_unit_id}=
        ...    SELECT unit_id FROM unit WHERE owner_id = '${oid}' AND (${unit_extra_where})
        VAR    ${q_unit_name}=
        ...    SELECT unit_name FROM unit WHERE owner_id = '${oid}' AND (${unit_extra_where})
    ELSE
        VAR    ${q_unit_id}=    SELECT unit_id FROM unit WHERE owner_id = '${oid}'
        VAR    ${q_unit_name}=    SELECT unit_name FROM unit WHERE owner_id = '${oid}'
    END
    IF    '${employee_extra_where}' != '${EMPTY}'
        VAR    ${q_emp}=
        ...    SELECT display_name FROM RWS_EMPLOYEE WHERE OWNER_ID = '${oid}' AND (${employee_extra_where})
    ELSE
        VAR    ${q_emp}=    SELECT display_name FROM RWS_EMPLOYEE WHERE OWNER_ID = '${oid}'
    END
    VAR    @{queries}=    ${q_unit_id}    ${q_unit_name}    ${q_emp}
    ${whitelist}=    Get I18n Text Whitelist From Db Queries    @{queries}
    RETURN    ${whitelist}
