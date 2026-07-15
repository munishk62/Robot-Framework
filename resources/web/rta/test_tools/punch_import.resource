*** Settings ***
Documentation       Punch Import page related keyword implementation

Library             resources/web/common/utility.py
Resource            resources/web/common/common.resource
Variables           resources/web/rta/test_tools/punch_import_page.py
Resource            resources/web/common/util_keywords.resource
Variables           resources/web/rta/test_tools/punch_import_db_queries.py
Resource            resources/web/common/database.resource


*** Keywords ***
Navigate To RTA Test Tools Punch Import Page On Web
    [Documentation]    Navigate To RTA -> Test Tools -> Punch Import Page
    ...    and verifies punch import heading at the top of the page
    Navigate To Specific Page On Web    rta    test_tools    punch_import

Update Punch Data In Excel File On Web
    [Documentation]    This keyword updates punch data in excel file
    [Arguments]    ${file_path}    ${data}
    Update Excel File    ${file_path}    ${data}

Enter Device Id On Punch Import Page On Web
    [Documentation]    This keyword Enters Device Id on Punch Import page.
    [Arguments]    ${device_id}
    Fill Textbox On Webpage    ${PUNCH_IMPORT_DEVICE_ID_TXT}    ${device_id}

Upload Punch Import Excel File On Web
    [Documentation]    This keyword imports punch import excel file
    [Arguments]    ${file_path}
    Upload File By Selector    ${PUNCH_IMPORT_FILE_IMPORT_BTN}    ${file_path}

Click Preview Punches Button On Punch Import Page On Web
    [Documentation]    This keyword Preview Punches button on Punch Import page.
    Click Element On Webpage    locator=${PUNCH_IMPORT_PREVIEW_PUNCHES_BTN}

Assert Punch Preview Is Successful On Web
    [Documentation]    This keyword asserts Punch Preview is successful
    Wait Until Element Is Visible On Webpage    ${PUNCH_IMPORT_IMPORT_PUNCHES_BTN}

Import Shift Punch File On Web
    [Documentation]    This keyword clicks on Import Punches button
    Click Element On Webpage    ${PUNCH_IMPORT_IMPORT_PUNCHES_BTN}

Upload And Import Punch File On Web
    [Documentation]    Uploads punch import file, previews punches, and imports them.
    ...    Combines upload, preview validation, and import steps with screenshots.
    ...    | =Arguments= | =Description= |
    ...    | device_id | Device ID for punch import |
    ...    | file_path | Full path to punch import Excel file |
    ...    Example usage:
    ...    | Upload And Import Punch File On Web    DVCSTORE1    ${EXECDIR}/web/external_files/punch_import/Punch_Import_File.xls
    [Arguments]    ${device_id}    ${file_path}
    Enter Device Id On Punch Import Page On Web    ${device_id}
    Upload Punch Import Excel File On Web    ${file_path}
    Click Preview Punches Button On Punch Import Page On Web
    Assert Punch Preview Is Successful On Web
    Capture Screenshot On Webpage
    Import Shift Punch File On Web
    Wait Until Page Is Loaded
    Capture Screenshot On Webpage

Add Clock-In Clock-Out Data In Punch Import File On Web
    [Documentation]    Creates clock-in and clock-out punch data and updates the punch import Excel file
    [Arguments]    ${punch_import_file}    ${associate_id}    ${device_id}    ${store_id}    ${punch_import_date}    ${punch_date}

    VAR    ${punch_time1}    ${punch_date}${punch_import_date}[start_time]
    VAR    ${punch_time2}    ${punch_date}${punch_import_date}[end_time]
    VAR    ${override_punch_time1}    ${punch_date}${punch_import_date}[override_start_time]
    VAR    ${override_punch_time2}    ${punch_date}${punch_import_date}[override_end_time]

    VAR    &{punch_import_data_clock_in}
    ...    A2=${associate_id}
    ...    B2=${punch_import_date}[transaction_type_clock_in]
    ...    C2=${punch_import_date}[status_flag]
    ...    D2=${punch_time1}
    ...    F2=${punch_import_date}[biometric_flag]
    ...    G2=${punch_import_date}[entry_mode]
    ...    I2=${device_id}
    ...    J2=${store_id}
    ...    M2=${override_punch_time1}
    ...    N2=${punch_time1}
    Update Punch Data In Excel File On Web    ${punch_import_file}    ${punch_import_data_clock_in}

    VAR    &{punch_import_data_clock_out}
    ...    A3=${associate_id}
    ...    B3=${punch_import_date}[transaction_type_clock_out]
    ...    C3=${punch_import_date}[status_flag]
    ...    D3=${punch_time2}
    ...    F3=${punch_import_date}[biometric_flag]
    ...    G3=${punch_import_date}[entry_mode]
    ...    I3=${device_id}
    ...    J3=${store_id}
    ...    M3=${override_punch_time2}
    ...    N3=${punch_time2}
    Update Punch Data In Excel File On Web    ${punch_import_file}    ${punch_import_data_clock_out}

Add Full Day Punch Data With Meal In Punch Import File
    [Documentation]    Creates all 4 punch records (Clock In, Meal In, Meal Out, Clock Out) and updates the punch import Excel file.
    ...    This keyword handles a complete day of punches including meal breaks.
    ...    | =Arguments= | =Description= |
    ...    | punch_import_file | Full path to the punch import Excel file |
    ...    | associate_id | Badge ID of the associate (e.g., 10000004) |
    ...    | device_id | Device ID for the punch (e.g., DVCSTORE1) |
    ...    | store_id | Store/Unit ID (e.g., STORE1) |
    ...    | punch_import_date | Dictionary with punch configuration from data provider |
    ...    | punch_date | Date prefix in yyyyMMdd format |
    ...    Example usage:
    ...    | ${punch_data}    Get Punch Import Data
    ...    | ${punch_date}    Convert Date    ${target_date}    result_format=%Y%m%d
    ...    | Add Full Day Punch Data With Meal In Punch Import File    ${file}    10000004    DVCSTORE1    STORE1    ${punch_data}    ${punch_date}
    [Arguments]    ${punch_import_file}    ${associate_id}    ${device_id}    ${store_id}    ${punch_import_date}    ${punch_date}
    VAR    ${clock_in_time}    ${punch_date}${punch_import_date}[clock_in_time]
    VAR    ${meal_in_time}    ${punch_date}${punch_import_date}[meal_in_time]
    VAR    ${meal_out_time}    ${punch_date}${punch_import_date}[meal_out_time]
    VAR    ${clock_out_time}    ${punch_date}${punch_import_date}[clock_out_time]
    # Clock In punch (Row 2)
    VAR    &{punch_data_clock_in}
    ...    A2=${associate_id}
    ...    B2=${punch_import_date}[transaction_type_clock_in]
    ...    C2=${punch_import_date}[status_flag]
    ...    D2=${clock_in_time}
    ...    F2=${punch_import_date}[biometric_flag]
    ...    G2=${punch_import_date}[entry_mode]
    ...    I2=${device_id}
    ...    J2=${store_id}
    ...    M2=${clock_in_time}
    ...    N2=${clock_in_time}
    Update Punch Data In Excel File On Web    ${punch_import_file}    ${punch_data_clock_in}
    # Meal In punch (Row 3)
    VAR    &{punch_data_meal_in}
    ...    A3=${associate_id}
    ...    B3=${punch_import_date}[transaction_type_meal_in]
    ...    C3=${punch_import_date}[status_flag]
    ...    D3=${meal_in_time}
    ...    F3=${punch_import_date}[biometric_flag]
    ...    G3=${punch_import_date}[entry_mode]
    ...    I3=${device_id}
    ...    J3=${store_id}
    ...    M3=${meal_in_time}
    ...    N3=${meal_in_time}
    Update Punch Data In Excel File On Web    ${punch_import_file}    ${punch_data_meal_in}
    # Meal Out punch (Row 4)
    VAR    &{punch_data_meal_out}
    ...    A4=${associate_id}
    ...    B4=${punch_import_date}[transaction_type_meal_out]
    ...    C4=${punch_import_date}[status_flag]
    ...    D4=${meal_out_time}
    ...    F4=${punch_import_date}[biometric_flag]
    ...    G4=${punch_import_date}[entry_mode]
    ...    I4=${device_id}
    ...    J4=${store_id}
    ...    M4=${meal_out_time}
    ...    N4=${meal_out_time}
    Update Punch Data In Excel File On Web    ${punch_import_file}    ${punch_data_meal_out}
    # Clock Out punch (Row 5)
    VAR    &{punch_data_clock_out}
    ...    A5=${associate_id}
    ...    B5=${punch_import_date}[transaction_type_clock_out]
    ...    C5=${punch_import_date}[status_flag]
    ...    D5=${clock_out_time}
    ...    F5=${punch_import_date}[biometric_flag]
    ...    G5=${punch_import_date}[entry_mode]
    ...    I5=${device_id}
    ...    J5=${store_id}
    ...    M5=${clock_out_time}
    ...    N5=${clock_out_time}
    Update Punch Data In Excel File On Web    ${punch_import_file}    ${punch_data_clock_out}

Check If Punches Already Exist For Today From DB
    [Documentation]    Checks if punches already exist in TA_PUNCH table for the given associate, store, device, and date.
    ...    Returns True if punches exist (count > 0), False if no punches found (count = 0).
    ...    Use this to skip punch import tests when data already exists.
    ...    | =Arguments= | =Description= |
    ...    | owner_id | Owner ID from config (e.g., from Get Config Value OWNER_ID) |
    ...    | badge_id | Badge ID of the associate (username) |
    ...    | device_id | Device ID for punch import (e.g., DVCSTORE1) |
    ...    | unit_id | Store/Unit ID (e.g., STORE1) |
    ...    | punch_date | Date in yyyyMMdd format |
    ...    Returns: Boolean - True if punches exist, False if no punches
    ...    Example usage:
    ...    | ${punches_exist}    Check If Punches Already Exist For Today From DB    111110051    10000004    DVCSTORE1    STORE1    20251223
    ...    | Skip If    ${punches_exist}    Punches already exist for this employee today
    [Arguments]    ${owner_id}    ${badge_id}    ${device_id}    ${unit_id}    ${punch_date}

    # Build query using template and Replace String
    ${db_query}    Replace String    ${CHECK_EXISTING_PUNCHES_COUNT}    {owner_id}    ${owner_id}
    ${db_query}    Replace String    ${db_query}    {badge_id}    ${badge_id}
    ${db_query}    Replace String    ${db_query}    {device_id}    ${device_id}
    ${db_query}    Replace String    ${db_query}    {unit_id}    ${unit_id}
    ${db_query}    Replace String    ${db_query}    {punch_date}    ${punch_date}

    Log    Checking for existing punches in TA_PUNCH table    level=INFO
    ${result}    Execute Query And Return Result    ${db_query}

    ${first_row}    Get From List    ${result}    0
    VAR    ${punch_count}    ${first_row[0]}
    Log    Found ${punch_count} existing punch(es) for badge ${badge_id} on date ${punch_date}    level=INFO

    IF    ${punch_count} > 0    RETURN    ${True}    ELSE    RETURN    ${False}
