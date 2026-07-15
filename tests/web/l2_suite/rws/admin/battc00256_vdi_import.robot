*** Settings ***
Documentation       Suite verifies VDI file generation and upload via RWS Admin RFP Upload page

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/admin/rfp_upload.resource

Test Teardown       Close Browser

Test Tags           dev:ravi    action:write    battc00256    config:rws    bat_phase2    config:vdi_import    module:forecast


*** Test Cases ***
BATTC00256: Verify the user is able to do all categories (Clock In, Meal In, Meal End, Break In, Break Out, Clock Out) of punch transaction for a single day
    [Documentation]    This test case is to upload VDI file.
    ${vdi_import_data}=    Get VDI Import Data
    ${vdi_upload_file_path}=    Generate VDI Upload File    vdi_import_data=${vdi_import_data}
    Login And Launch WFM Web App    user_key=SYSADMIN
    Navigate To RWS Admin RFP Upload Page On Web
    Upload VDI File On Web    ${vdi_upload_file_path}
    Navigate To RWS Admin RFP Logs Page On Web
    Apply Filter And Select Latest Log File On RFP Logs Page    Volume Driver Interval Import
    Verify Log File Content On Web
    Log Out From Web Application
