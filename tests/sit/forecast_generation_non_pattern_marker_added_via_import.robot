*** Settings ***
Documentation       Suite verifies validate the forecast generation for recurring non-pattern based markers added from imports.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/admin/rfp_upload.resource
Resource            resources/web/rws/predictive_analytics/forecast_review.resource
Resource            resources/web/rws/driver_forecast/predictive_driver_forecast.resource

Test Teardown       Close Browser

Test Tags           dev:amol    action:write    sittc76102    config:rws    sit    sit_v4    module:forecast    sit_r22    web    sit_epic


*** Test Cases ***
SITTC76102: Verify forecast generation for recurring non-pattern based marker added from imports
    [Documentation]
    ...    Validates forecast generation and review values for recurring non-pattern marker data.
    ...    Workflow:
    ...    1. Import VDI and VDP files with date-window data and verify RFP logs.
    ...    2. Generate forecast via API for planning weeks #1 to #4.
    ...    3. Validate Weekly Adjusted totals/day values for PRE VDP Store Driver01 and PRE VDI Store Driver01.

    ${marker_data}    Get Marker Data
    ${sm_user}    Get User    user_key=SM1_STORE2_SIT
    ${vdi_upload_file_path}    ${vdp_upload_file_path}    Generate SIT Marker Import Files    ${marker_data}    ${sm_user}[unitID]

    Login And Launch WFM Web App    user_key=SYSADMIN
    Verify VDI Import On Web    ${vdi_upload_file_path}
    Verify VDP Import On Web    ${vdp_upload_file_path}
    Close Browser

    Generate Forecast For Marker Validation Weeks Via API    ${marker_data}    ${sm_user}

    Login And Launch WFM Web App    ${sm_user}[user_key]
    Verify Marker Forecast Review Values On Web    ${marker_data}
    Log Out From Web Application
