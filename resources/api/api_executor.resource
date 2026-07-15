*** Settings ***
Documentation       This resource file contains keywords related to API calls.

Library             Collections
Library             RequestsLibrary
Library             CacheLibrary
Library             pabot.PabotLib
Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/reports/cognos_login.resource
Resource            resources/web/authentication/auth_api.resource


*** Variables ***
${API_AUTH_TOKEN}               ${EMPTY}
${HEADER_MAP}                   ${EMPTY}
${MOBILE_PAGE_LOGIN_BUTTON}     //span[@class='login-big-font login-button-fix']
${TOKEN_EXPIRY_IN_SECONDS}      3600


*** Keywords ***
Generate Auth Token With User Credentials
    [Documentation]    This keyword generates the authentication token for the API.
    ...    Args:
    ...    - user_key: The unique key to identify the user in the encrypted file.
    ...    - base_url: The base URL for the API (optional, defaults to config value)
    [Arguments]    ${user_key}    ${base_url}=${EMPTY}
    Generate Auth Token With Username And Password    ${ALL_CREDENTIALS}[${user_key}][username]
    ...    ${ALL_CREDENTIALS}[${user_key}][password]    ${base_url}

Generate Auth Token With Username And Password
    [Documentation]    This keyword generates the authentication token for the API.
    ...    Args:
    ...    - username: The username of the user.
    ...    - password: The password of the user.
    ...    - base_url: The base URL for the API (optional, defaults to config value)
    [Arguments]    ${username}    ${password}    ${base_url}=${EMPTY}
    ${auth_token}    Login With Credentials And Return Token    ${username}    ${password}
    VAR    ${API_AUTH_TOKEN}    ${auth_token}    scope=SUITE

    IF    '${base_url}' == '${EMPTY}'
        ${api_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${api_base_url}    ${base_url}
    END

    Generate API HeaderMap    ${api_base_url}

Get Auth Token Cache Key
    [Documentation]
    ...    Generates a cache key for storing auth tokens for a user given userId and storeId.
    ...    | =Arguments= | =Description= |
    ...    | user_key    | user_key for authentication. |
    ...    Example usage:
    ...    | Get Auth Token Cache Key    SM1_STORE1
    [Arguments]    ${user_key}
    ${pabot_id}    Get Pabot Execution Pool ID
    RETURN    auth_token_${user_key}_${pabot_id}

Get Pabot Execution Pool ID
    [Documentation]
    ...    Gets the Pabot execution pool ID for the current execution.
    ...    Example usage:
    ...    | Get Pabot Execution Pool ID

    ${pabot_id}    Get Variable Value    ${PABOTEXECUTIONPOOLID}    1
    RETURN    ${pabot_id}

Get Auth Token With User Credentials With Caching
    [Documentation]
    ...    Gets the auth token for a user, caching it to avoid multiple requests.
    ...    | =Arguments= | =Description= |
    ...    | user_key    | User ID for authentication. |
    ...    Example usage:
    ...    | Get Auth Token With User Credentials With Caching    SM1_STORE1
    [Arguments]    ${user_key}
    ${pabot_id}    Get Pabot Execution Pool ID
    VAR    ${lock_key}    auth_token_lock_${user_key}_${pabot_id}
    Acquire Lock    ${lock_key}
    ${cache_key}    Get Auth Token Cache Key    ${user_key}
    ${cached_token}    Cache Retrieve Value    ${cache_key}
    IF    $cached_token is not $None
        Release Lock    ${lock_key}
        RETURN    ${cached_token}
    END
    ${auth_token}    Login With Credentials And Return Token    ${ALL_CREDENTIALS}[${user_key}][username]
    ...    ${ALL_CREDENTIALS}[${user_key}][password]
    Cache Store Value    ${cache_key}    ${auth_token}    expire_in_seconds=${TOKEN_EXPIRY_IN_SECONDS}
    Release Lock    ${lock_key}
    RETURN    ${auth_token}

Login With Credentials And Return Token
    [Documentation]    This keyword logs in with the given credentials and returns the authentication token.
    ...    If the mobile view is not supported, it returns a predefined site token from environment variables.
    ...    This keyword opens new browser window in headless mode and logs in with the given credentials.
    ...    After login, it extracts the authentication token from the html_body tag.
    ...    Args:
    ...    - username: The username of the user.
    ...    - password: The password of the user.
    [Arguments]    ${username}    ${password}
    ${prefix}    Set Selector Prefix    ${NONE}
    ${APP_URL}    Get Config Value    key=app_url
    New Browser    headless=True
    ${mob_url}    Replace String    ${APP_URL}    /W/    /M/
    # Retry logic for flaky page navigation (1 retry = 2 total attempts)
    Wait Until Keyword Succeeds    3x    1s    New Page    ${mob_url}

    IF    '${username}' == 'SYSADMIN' and '%SITE_TOKEN' != ''
        VAR    ${resolved_site_token}    %{SITE_TOKEN=}
        RETURN    ${resolved_site_token}
    END

    ${is_mobile_view_supported}    Is Element Visible On Webpage    ${loginpage_username_txt}
    IF    ${is_mobile_view_supported}
        Wait Until Page Is Loaded
        Enter Username    ${username}
        Enter Password    ${password}
        Click    ${MOBILE_PAGE_LOGIN_BUTTON}
        Wait Until Page Is Loaded

        ${html_body}    Get Property    css=body    innerText
        ${json_data}    Evaluate    json.loads('''${html_body}''')    json
        ${auth_token}    Get From Dictionary    ${json_data}    authToken
        Set Selector Prefix    ${prefix}
        Close Browser
        RETURN    ${auth_token}
    ELSE
        Log    Mobile view is not supported
        Close Browser
        VAR    ${resolved_site_token}    %{SITE_TOKEN}
        RETURN    ${resolved_site_token}
    END

Generate API HeaderMap
    [Documentation]    This keyword initializes the header map with the API base URL.
    ...
    ...    Arguments:
    ...    - base_url: The base URL for the API endpoint
    [Arguments]    ${base_url}
    ${header_map_const}    Get API HeaderMap With WFM Auth Token    ${base_url}    ${API_AUTH_TOKEN}
    VAR    ${HEADER_MAP}    ${header_map_const}    scope=SUITE

Get API HeaderMap With WFM Auth Token
    [Documentation]    This keyword returns the header map to be used with wfm api with passed in auth token.
    ...    | =Arguments= | =Description= |
    ...    | base_url    | base_url for the app |
    ...    | auth_token    | authentication token for the app |
    [Arguments]    ${base_url}    ${auth_token}
    VAR    &{header_map_const}
    ...    Accept=application/json; charset=utf-8
    ...    Referer=${base_url}
    ...    X-Csrf-Token-X=${auth_token}
    ...    x-reflexis-csrf-token-x=${auth_token}
    ...    X-reflexis-auth-token-X=${auth_token}
    ...    authToken=${auth_token}
    ...    Content-Type=application/json
    RETURN    ${header_map_const}

Get Session For API
    [Documentation]    This keyword returns the session object if present else create new session.
    ...
    ...    Arguments:
    ...    - base_url: The base URL for creating the API session
    [Arguments]    ${base_url}
    ${session_exist}    Session Exists    ${API_AUTH_TOKEN}
    IF    ${session_exist}
        RETURN    ${API_AUTH_TOKEN}
    ELSE
        Create Session    ${API_AUTH_TOKEN}    ${base_url}    headers=${HEADER_MAP}    disable_warnings=True    timeout=${LONG_API_TIMEOUT}
    END
    RETURN    ${API_AUTH_TOKEN}

Send A Post Request
    [Documentation]    This keyword sets the post request for the API.
    ...
    ...    Args:
    ...    ${endpoint}: End point of the API. from api_endpoints.py
    ...    @{path_params}: path parameters to be sent in the request.
    ...    ${body}: json body to be sent in the request (optional, default: None).
    ...    ${base_url}: The base URL for the API (optional, defaults to config value)
    ...
    ...    Returns:
    ...    ${response}: response of the request.
    [Arguments]    ${endpoint}    @{path_params}    ${body}=None    ${base_url}=${EMPTY}

    VAR    ${parsed_end_point}    ${endpoint}
    ${param_count}    Get Length    ${path_params}
    FOR    ${index}    IN RANGE    ${param_count}
        VAR    ${placeholder}    {${index}}
        ${param_value}    Get From List    ${path_params}    ${index}
        ${parsed_end_point}    Replace String    ${parsed_end_point}    ${placeholder}    ${param_value}
    END

    IF    '${base_url}' == '${EMPTY}'
        ${api_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${api_base_url}    ${base_url}
    END

    ${session}    Get Session For API    ${api_base_url}
    ${response}    POST On Session    ${session}    ${parsed_end_point}    json=${body}
    IF    '${response.status_code}' != '200' and '${response.status_code}' != '201'
        Fail    Status code is not 200 or 201, it was ${response.status_code}
    END
    RETURN    ${response.json()}

Send A Put Request
    [Documentation]    This keyword sets the put request for the API.
    ...
    ...    Args:
    ...    ${endpoint}: End point of the API. from api_endpoints.py
    ...    ${body}: json body to be sent in the request.
    ...    @{path_params}: path parameters to be sent in the request.
    ...    ${base_url}: The base URL for the API (optional, defaults to config value)
    ...
    ...    Returns:
    ...    ${response}: response object of the request.
    [Arguments]    ${endpoint}    @{path_params}    ${body}=None    ${base_url}=${EMPTY}

    VAR    ${parsed_end_point}    ${endpoint}
    ${param_count}    Get Length    ${path_params}
    FOR    ${index}    IN RANGE    ${param_count}
        VAR    ${placeholder}    {${index}}
        ${param_value}    Get From List    ${path_params}    ${index}
        ${parsed_end_point}    Replace String    ${parsed_end_point}    ${placeholder}    ${param_value}
    END

    IF    '${base_url}' == '${EMPTY}'
        ${api_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${api_base_url}    ${base_url}
    END

    ${session}    Get Session For API    ${api_base_url}
    ${response}    PUT On Session    ${session}    ${parsed_end_point}    json=${body}
    IF    '${response.status_code}' != '200' and '${response.status_code}' != '201'
        Fail    Status code is not 200 or 201, it was ${response.status_code}
    END
    RETURN    ${response.json()}

Get Session For WFM API
    [Documentation]    This keyword returns the session object if present else create new session.
    ...
    ...    | =Arguments= | =Description= |
    ...    | base_url    | The base URL for creating the API session |
    ...    | auth_token    | authentication token for the app |
    [Arguments]    ${base_url}    ${auth_token}    ${header_map}
    ${session_exist}    Session Exists    ${auth_token}
    IF    ${session_exist}
        RETURN    ${auth_token}
    ELSE
        Create Session    ${auth_token}    ${base_url}    headers=${header_map}    disable_warnings=True
    END
    RETURN    ${auth_token}

Process WFM API Response
    [Documentation]    This keyword processes the WFM API response.
    ...    | =Arguments= | =Description= |
    ...    | response    | response object of the request. |
    [Arguments]    ${response}    ${return_raw_response}=False
    Log    Response Body: ${response.text}
    IF    ${response.status_code} == ${422}
        Fail Test With Response Message From WFM API    ${response}
    END
    IF    '${response.status_code}' != '200' and '${response.status_code}' != '201'
        Fail    Status code is not 200 or 201, it was ${response.status_code}
    END
    IF    ${return_raw_response}
        RETURN    ${response}
    ELSE
        RETURN    ${response.json()}
    END

Fail Test With Response Message From WFM API
    [Documentation]    This keyword fails the test with the error message from WFM API response when status code is 422.
    ...    | =Arguments= | =Description= |
    ...    | response    | response object of the request. |
    [Arguments]    ${response}
    VAR    ${error_message}    API failure with status 422. Response body: ${response.text}
    Log    ${error_message}    level=ERROR
    Fail    ${error_message}

Get Session Alias For User
    [Documentation]    Generates the session alias for a user based on user key and pabot process ID.
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key    | user_key for authentication. |
    [Arguments]    ${auth_user_key}
    ${pabot_id}    Get Pabot Execution Pool ID
    RETURN    session_${auth_user_key}_${pabot_id}

Setup WFM Session For API
    [Documentation]    This keyword sets the session for WFM API with automatic token expiry tracking.
    ...    Sessions must pass both existence and validity checks before reuse.
    ...    Sessions expire after 20 minutes (1200s) of inactivity and trigger re-authentication upon expiry.
    ...    Session creation drives auth token creation to avoid reusing a token with a new session.
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key    | user_key for authentication. |
    ...    | base_url    | The base URL for the API |
    [Arguments]    ${auth_user_key}    ${base_url}
    ${pabot_id}    Get Pabot Execution Pool ID
    Log    ${pabot_id}
    VAR    ${session_alias}    session_${auth_user_key}_${pabot_id}
    VAR    ${session_cache_key}    session_valid_${auth_user_key}_${pabot_id}

    # Session is only reusable if it exists AND hasn't expired (20-min TTL)
    ${session_exist}    Session Exists    ${session_alias}
    ${session_valid}    Cache Retrieve Value    ${session_cache_key}
    IF    ${session_exist} and ${session_valid} is not ${None}
        Cache Store Value    ${session_cache_key}    ${True}    expire_in_seconds=${SESSION_TTL_TIMEOUT}
        Log    Reusing WFM session: ${session_alias}    level=INFO
        RETURN    ${session_alias}
    END

    VAR    ${lock_key}    session_lock_${auth_user_key}_${pabot_id}
    Acquire Lock    ${lock_key}
    TRY
        # Double-check inside lock
        ${session_exist}    Session Exists    ${session_alias}
        ${session_valid}    Cache Retrieve Value    ${session_cache_key}
        IF    ${session_exist} and $session_valid is not $None
            Cache Store Value    ${session_cache_key}    ${True}    expire_in_seconds=${SESSION_TTL_TIMEOUT}
            Log    Reusing WFM session: ${session_alias}    level=INFO
            RETURN    ${session_alias}
        END
        ${auth_token}    Login With Credentials And Return Token    ${ALL_CREDENTIALS}[${auth_user_key}][username]
        ...    ${ALL_CREDENTIALS}[${auth_user_key}][password]
        ${header_map}    Get API HeaderMap With WFM Auth Token    ${base_url}    ${auth_token}
        # Delete stale session if it exists (expired token case)
        # IF    ${session_exist}    Delete All Sessions

        Create Session    ${session_alias}    ${base_url}    headers=${header_map}    disable_warnings=True    timeout=${LONG_API_TIMEOUT}
        # Mark session as valid with 20-minute TTL
        Cache Store Value    ${session_cache_key}    ${True}    expire_in_seconds=${SESSION_TTL_TIMEOUT}
        Log    Created WFM session: ${session_alias}    level=INFO
        RETURN    ${session_alias}
    FINALLY
        Release Lock    ${lock_key}
    END

Send A WFM POST Request
    [Documentation]    This keyword sets the post request for the WFM API.
    ...    Automatically retries with new auth token if PossibleRequestTamperingException is detected.
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key    | user_key for authentication. |
    ...    | api_base_url    | The base URL for the API |
    ...    | endpoint    | End point of the API. from api_endpoints.py |
    ...    | body    | json body to be sent in the request |
    ...    | return_raw_response    | Boolean to indicate if raw response is to be returned. (default: False) |
    ...    | custom_headers    | Optional dictionary of additional headers to include in the request |
    [Arguments]    ${auth_user_key}    ${api_base_url}    ${endpoint_url}    ${body}=${None}    ${return_raw_response}=False
    ...    ${custom_headers}=${None}
    ${session}    Setup WFM Session For API    ${auth_user_key}    ${api_base_url}
    ${response}    POST On Session    ${session}    ${endpoint_url}    json=${body}    expected_status=any    headers=${custom_headers}
    ${processed_response}    Process WFM API Response    ${response}    ${return_raw_response}
    RETURN    ${processed_response}

Send A WFM GET Request
    [Documentation]    This keyword sets the get request for the WFM API.
    ...    Automatically retries with new auth token if PossibleRequestTamperingException is detected.
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key    | user_key for authentication. |
    ...    | api_base_url    | The base URL for the API |
    ...    | endpoint    | End point of the API. from api_endpoints.py |
    ...    | return_raw_response    | Boolean to indicate if raw response is to be returned. (default: False) |
    [Arguments]    ${auth_user_key}    ${api_base_url}    ${endpoint_url}    ${return_raw_response}=False
    ${session}    Setup WFM Session For API    ${auth_user_key}    ${api_base_url}
    ${response}    GET On Session    ${session}    ${endpoint_url}    expected_status=any
    ${processed_response}    Process WFM API Response    ${response}    ${return_raw_response}
    RETURN    ${processed_response}

Send A WFM Delete Request
    [Documentation]    This keyword sets the delete request for the WFM API.
    ...    Automatically retries with new auth token if PossibleRequestTamperingException is detected.
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key    | user_key for authentication. |
    ...    | api_base_url    | The base URL for the API |
    ...    | endpoint    | End point of the API. from api_endpoints.py |
    ...    | return_raw_response    | Boolean to indicate if raw response is to be returned. (default: False) |
    [Arguments]    ${auth_user_key}    ${api_base_url}    ${endpoint_url}    ${return_raw_response}=False
    ${session}    Setup WFM Session For API    ${auth_user_key}    ${api_base_url}
    ${response}    Delete On Session    ${session}    ${endpoint_url}    expected_status=any
    ${processed_response}    Process WFM API Response    ${response}    ${return_raw_response}
    RETURN    ${processed_response}

Send A WFM PUT Request
    [Documentation]    This keyword sets the put request for the WFM API.
    ...    Automatically retries with new auth token if PossibleRequestTamperingException is detected.
    ...    | =Arguments= | =Description= |
    ...    | auth_user_key    | user_key for authentication. |
    ...    | api_base_url    | The base URL for the API |
    ...    | endpoint    | End point of the API. from api_endpoints.py |
    ...    | body    | json body to be sent in the request |
    ...    | return_raw_response    | Boolean to indicate if raw response is to be returned. (default: False) |
    [Arguments]    ${auth_user_key}    ${api_base_url}    ${endpoint_url}    ${body}=${None}    ${return_raw_response}=False
    ${session}    Setup WFM Session For API    ${auth_user_key}    ${api_base_url}
    ${response}    PUT On Session    ${session}    ${endpoint_url}    json=${body}    expected_status=any
    ${processed_response}    Process WFM API Response    ${response}    ${return_raw_response}
    RETURN    ${processed_response}

Send A Get Request
    [Documentation]    This keyword sets the get request for the API.
    ...
    ...    Args:
    ...    ${endpoint}: End point of the API. from api_endpoints.py
    ...    @{path_params}: path parameters to be sent in the request.
    ...    ${base_url}: The base URL for the API (optional, defaults to config value)
    ...
    ...    Returns:
    ...    ${response}: response object of the request.
    [Arguments]    ${endpoint}    @{path_params}    ${base_url}=${EMPTY}    ${return_raw_response}=False

    VAR    ${parsed_end_point}    ${endpoint}
    ${param_count}    Get Length    ${path_params}
    FOR    ${index}    IN RANGE    ${param_count}
        VAR    ${placeholder}    {${index}}
        ${param_value}    Get From List    ${path_params}    ${index}
        ${parsed_end_point}    Replace String    ${parsed_end_point}    ${placeholder}    ${param_value}
    END

    IF    '${base_url}' == '${EMPTY}'
        ${api_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${api_base_url}    ${base_url}
    END

    ${session}    Get Session For API    ${api_base_url}
    ${response}    GET On Session    ${session}    ${parsed_end_point}
    IF    '${response.status_code}' != '200' and '${response.status_code}' != '201'
        Fail    Status code is not 200 or 201, it was ${response.status_code}
    END
    IF    ${return_raw_response}
        RETURN    ${response}
    ELSE
        RETURN    ${response.json()}
    END

Send A Delete Request
    [Documentation]    This keyword sets the delete request for the API.
    ...
    ...    Args:
    ...    ${endpoint}: End point of the API. from api_endpoints.py
    ...    @{path_params}: path parameters to be sent in the request.
    ...    ${base_url}: The base URL for the API (optional, defaults to config value)
    ...
    ...    Returns:
    ...    ${response}: response object of the request.
    [Arguments]    ${endpoint}    @{path_params}    ${base_url}=${EMPTY}

    VAR    ${parsed_end_point}    ${endpoint}
    ${param_count}    Get Length    ${path_params}
    FOR    ${index}    IN RANGE    ${param_count}
        VAR    ${placeholder}    {${index}}
        ${param_value}    Get From List    ${path_params}    ${index}
        ${parsed_end_point}    Replace String    ${parsed_end_point}    ${placeholder}    ${param_value}
    END

    IF    '${base_url}' == '${EMPTY}'
        ${api_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${api_base_url}    ${base_url}
    END

    ${session}    Get Session For API    ${api_base_url}
    ${response}    DELETE On Session    ${session}    ${parsed_end_point}
    IF    '${response.status_code}' != '200' and '${response.status_code}' != '201'
        Fail    Status code is not 200 or 201, it was ${response.status_code}
    END
    RETURN    ${response.json()}

Send A Get Request And Return Raw Response
    [Documentation]    Sends a GET request and returns the raw response object (no JSON parsing).
    ...    Use this for endpoints that do not return JSON (e.g. servlets).
    ...
    ...    Args:
    ...    ${endpoint}: End point of the API (string with optional {0}, {1} placeholders).
    ...    @{path_params}: Path parameters to be substituted into the endpoint.
    ...    ${base_url}: The base URL for the API (optional, defaults to config value).
    ...
    ...    Returns:
    ...    ${response}: raw response object from RequestsLibrary.
    [Arguments]    ${endpoint}    @{path_params}    ${base_url}=${EMPTY}

    VAR    ${parsed_end_point}    ${endpoint}
    ${param_count}    Get Length    ${path_params}
    FOR    ${index}    IN RANGE    ${param_count}
        VAR    ${placeholder}    {${index}}
        ${param_value}    Get From List    ${path_params}    ${index}
        ${parsed_end_point}    Replace String    ${parsed_end_point}    ${placeholder}    ${param_value}
    END

    IF    '${base_url}' == '${EMPTY}'
        ${api_base_url}    Get Config Value    key=base_url
    ELSE
        VAR    ${api_base_url}    ${base_url}
    END

    ${session}    Get Session For API    ${api_base_url}
    ${response}    GET On Session    ${session}    ${parsed_end_point}
    IF    '${response.status_code}' != '200' and '${response.status_code}' != '201'
        Fail    Status code is not 200 or 201, it was ${response.status_code}
    END
    RETURN    ${response}
