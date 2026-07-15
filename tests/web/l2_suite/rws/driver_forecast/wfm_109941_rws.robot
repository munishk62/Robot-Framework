*** Settings ***
Documentation       This test case will verify week navigation for predictive driver forecast page
...                 It follows the pattern of navigating forward or backward as specified for given number of weeks,,
...                 verification that the week displays predictive forecast correctly for each navigated period with page load.

Resource            resources/web/authentication/login.resource
Resource            resources/web/rws/driver_forecast/predictive_driver_forecast.resource
Resource            resources/web/rws/predictive_analytics/forecast_review.resource

Suite Teardown      Close Browser
Test Teardown       Run Keyword And Ignore Error    Close Browser

Test Tags    dev:bushra    action:read    battc00175    config:rws    config:predictive_forecasting    bat_phase2
...    config:weekplan_and_schedule_gen    module:forecast


*** Test Cases ***
BATTC00175: Verify week navigation for predictive driver forecast page
    [Documentation]    Test case will verify week navigation for predictive driver forecast page
    VAR    ${number_of_weeks_to_navigate}    1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Predictive Driver Forecast Page On Web
    Repeat Keyword    2 times    Navigate Forward And Verify Forecast Week On Predictive Driver Forecast Page On Web
    ...    ${number_of_weeks_to_navigate}
    Repeat Keyword    2 times    Navigate Backward And Verify Forecast Week On Predictive Driver Forecast Page On Web
    ...    ${number_of_weeks_to_navigate}
