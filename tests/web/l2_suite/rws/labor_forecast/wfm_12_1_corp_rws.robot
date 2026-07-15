*** Settings ***
Documentation       Verify Workload Total Hours Values Match With UI And PDF Report For Week Level And Day Level

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/labor_forecast/labor_forecast.resource

Test Teardown       Close Browser

Test Tags    action:read    battc00014    dev:yogesh    bat_phase1    config:rws    config:weekplan_and_schedule_gen    module:forecast


*** Test Cases ***
BATTC00014: Verify total workload hours of weekly and daily views match with the pdf data
    [Documentation]    Test case to Verify Workload Total Hours Values Match With PDF Report For Week Level And Day Level
    Login And Launch WFM Web App    user_key=SYSADMIN
    ${store_data}    Get Store Data
    Navigate To RWS Labor Forecast Page On Web
    Select Store To Search Workload Values On Labor Forecast Page On Web    ${store_data}[store_id]
    ${is_workload_generated}    Check If Workload Is Generated On Labor Forecast Page On Web
    IF    ${is_workload_generated}
        Verify Data Available On Labor Forecast Page On Web
        Open And Verify Workload PDF Report On Labor Forecast Page On Web
        Collect Daily Data For All Days On Labor Forecast Page On Web
        Click On Third Day Header In Week View On Labor Forecast Page On Web
        Open And Verify Workload PDF Report On Labor Forecast Page On Web
    ELSE
        SKIP    msg=Workload is not generated for the store: ${store_data}[store_id]
    END
