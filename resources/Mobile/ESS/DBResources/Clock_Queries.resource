*** Settings ***
Documentation       This resource file contains keyword to perform db operations related to clock.

Resource            resources/web/common/database.resource
Library             Collections
Library             Process
Library             String
Library             utils/common_utility/utility.py


*** Keywords ***
Update Lat Long For Store
    [Documentation]    Update latitude and longitude for a store.
    ...    The request is identified by store_id.
    ...    Args:
    ...    store_id (str): The store ID example STORE14.
    ...    latitude (str): The latitude.
    ...    longitude (str): The longitude.
    [Arguments]    ${store_id}    ${lat}    ${long}
    VAR    ${query}    UPDATE unit SET LATITUDE=${lat}, LONGITUDE=${long} WHERE unit_id='${store_id}' AND owner_id='${DB2_OWNER_ID}';
    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}

Get TimeZone For Store
    [Documentation]    Get timezone for a store.
    ...    The request is identified by store_id.
    ...    Args:
    ...    store_id (str): The store ID example STORE14.
    [Arguments]    ${store_id}
    VAR    ${query}    SELECT TIME_ZONE FROM unit WHERE OWNER_ID='${DB2_OWNER_ID}' AND UNIT_ID='${store_id}';
    ${result}    Execute Query And Return Result    ${query}
    VAR    ${timezone}    ${result}[0][TIME_ZONE]
    RETURN    ${timezone}

Select Badge ID For User
    [Documentation]    Get badge id for a user.
    ...    The request is identified by user_id.
    ...    Args:
    ...    user_id (str): User from encrypted user id example 10000001.
    ...    unit_id (str): The unit id example STORE1.
    [Arguments]    ${user_id}    ${unit_id}
    ${query}    Catenate    SELECT BADGE_ID FROM TA_EMP_BADGE WHERE UNIT_ID='${unit_id}'
    ...    AND OWNER_ID=${DB2_OWNER_ID} AND PERSON_ID IN (SELECT PERSON_ID FROM RWS_EMPLOYEE WHERE OWNER_ID=${DB2_OWNER_ID}
    ...    AND system_user_id='${user_id}');
    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}

Get Device ID For Store
    [Documentation]    Get device id for a store.
    ...    The request is identified by store_id.
    ...    Args:
    ...    store_id (str): The store ID example STORE14.
    [Arguments]    ${store_id}
    ${query}    Catenate
    ...    SELECT DEVICE_ID FROM TA_DEVICE WHERE UNIT_ID='${store_id}' AND OWNER_ID=${DB2_OWNER_ID} AND DEVICE_TYPE_ID=501;
    ${results}    Execute Query And Return Result    ${query}
    RETURN    ${results}
