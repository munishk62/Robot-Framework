*** Settings ***
Documentation
...                 This resource file provides API request keywords for the WFM web app.
...
...                 = Purpose =
...                 - Centralizes API authentication and token management for test automation.
...
...                 = Prerequisites =
...                 - Required libraries: Collections, OperatingSystem, RequestsLibrary, CacheLibrary.
...                 - Test data library must be available and imported.
...
...                 = Example Usage =
...                 | *** Test Cases ***
...                 | Get Auth Token
...                 |    ${token}=    Get Authtoken For User With Caching    testuser    101

Library             Collections
Library             OperatingSystem
Library             RequestsLibrary
Library             CacheLibrary
Library             test_data/TestDataLibrary.py


*** Variables ***
${BASE_URL}                     http://localhost:8080/rws4
${DOMAIN_ID}                    ${EMPTY}
${TOKEN_EXPIRY_IN_SECONDS}      3600


*** Keywords ***
Get Authtoken For User With Caching
    [Documentation]
    ...    Gets the auth token for a user, caching it to avoid multiple requests.
    ...    | =Arguments= | =Description= |
    ...    | userId    | User ID for authentication. |
    ...    | storeId    | Store ID for authentication. |
    ...    Example usage:
    ...    | Get Authtoken For User With Caching    testuser    101
    [Arguments]    ${userId}    ${storeId}
    ${cache_key} =    Get Auth Token Cache Key    ${userId}    ${storeId}
    ${cached_token} =    Cache Retrieve Value    ${cache_key}
    IF    $cached_token is not $None    RETURN    ${cached_token}
    ${auth_token} =    Request New Auth Token    ${userId}    ${storeId}
    Cache Store Value    ${cache_key}    ${auth_token}    expire_in_seconds=${TOKEN_EXPIRY_IN_SECONDS}
    RETURN    ${auth_token}

Request New Auth Token
    [Documentation]
    ...    Requests a new auth token for the user from kernel using the TAPILogin endpoint.
    ...    | =Arguments= | =Description= |
    ...    | userId    | User ID for authentication. |
    ...    | storeId    | Store ID for authentication. |
    ...    Example usage:
    ...    | Request New Auth Token    testuser    101
    [Arguments]    ${userId}    ${storeId}
    ${domainId} =    Get Config Value    domainId
    ${kernelUrl} =    Get Config Value    kernel_url
    VAR    &{request_body} =
    ...    domainId=${domainId}
    ...    firstname=Test
    ...    lastname=User
    ...    location=${storeId}
    ...    mail=TestLocation@example.com
    ...    userId=${userId}
    ...    username=${userId}
    VAR    &{auth_headers} =
    ...    X-reflexis-auth-token-X=%{SITE_TOKEN}
    ...    Accept=*/*
    ${response} =    POST
    ...    ${kernelUrl}/auth/extauthhandler/TAPILogin.json
    ...    json=${request_body}
    ...    headers=${auth_headers}
    ...    expected_status=anything
    Should Be Equal As Strings    ${response.status_code}    200
    VAR    ${auth_token} =    ${response.json()}[authToken]
    RETURN    ${auth_token}

Get Auth Token Cache Key
    [Documentation]
    ...    Generates a cache key for storing auth tokens for a user given userId and storeId.
    ...    | =Arguments= | =Description= |
    ...    | userId    | User ID for authentication. |
    ...    | storeId    | Store ID for authentication. |
    ...    Example usage:
    ...    | Get Auth Token Cache Key    testuser    101
    [Arguments]    ${userId}    ${storeId}
    VAR    ${cache_key} =    auth_token_${userId}_${storeId}
    RETURN    ${cache_key}
