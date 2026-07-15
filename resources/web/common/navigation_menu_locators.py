"""
Navigation menu locators with auto-configuration from config.json
"""

import sys
from pathlib import Path

# Add the project root and the web directory to sys.path to ensure imports work
project_root = Path(__file__).parent.parent.parent.parent
web_dir = Path(__file__).parent.parent.parent

if str(project_root) not in sys.path:
    sys.path.insert(0, str(project_root))

# Import environment manager directly
from test_data.environment_manager import EnvironmentManager


def get_variables():
    """
    Get navigation menu variables based on MYWORK_ENABLED config from config.json
    """
    # Get MYWORK_ENABLED flag from config.json
    env_manager = EnvironmentManager()
    mywork_enabled_str = env_manager.get_config_value("MYWORK_ENABLED", "FALSE")
    is_my_work_enabled = mywork_enabled_str.upper() == "TRUE"

    print(f"Navigation menu locators: MYWORK_ENABLED={is_my_work_enabled}")

    if is_my_work_enabled:
        common = navigate_menu["my_work"]
    else:
        common = navigate_menu["non_my_work"]

    # Create fallback mechanisms for each menu type
    main_menu = {**common.get("main_menu", {})}
    parent_sub_menu = {**common.get("parent_sub_menu", {})}
    child_sub_menu = {**common.get("child_sub_menu", {})}

    # Combine common and client-specific menus
    menus = {**common}
    menus["main_menu"] = main_menu
    menus["parent_sub_menu"] = parent_sub_menu
    menus["child_sub_menu"] = child_sub_menu

    # Add MYWORK_ENABLED to the returned dictionary so it's available to Robot Framework
    menus["MYWORK_ENABLED_MENU"] = is_my_work_enabled

    return menus


"""**************************************************************************************************************************
Guidelines:
1. For main menu key names, use the id value (RWS) with the suffix “_menu” 
(e.g., rws_menu).
2. For parent sub-menu key names, use the menu name from the UI, converting it to lowercase and underscores 
(e.g., Driver Forecast → driver_forecast).
3. For child sub-menu key names, use the menu name from the UI, converting it to lowercase and underscores 
(e.g., Week Schedule → week_schedule).
4. In cases of duplicate menu names, prefix the key name with the respective main menu name 
(e.g., if Schedule appears in multiple menus, use rws_schedule and rta_schedule).
5. Include comments for hierarchy details as specified below.
(e.g., # RWS - Driver Forecast
       "forecast": "id=submenu-RWS^GENFORECAST",)
6. If the menu locator differs for a client, specify the menu level as shown below. Provide the key and its value in the same format as above. These will be selected if available for that client.
main_menu
parent_sub_menu 
child_sub_menu
**************************************************************************************************************************"""

navigate_menu = {
    "my_work": {
        "submenu_list": "div[id*='cdk-overlay'] div perfect-scrollbar div[class='ps-content']",
        "parent_sub_menu_panel": "//mat-expansion-panel",
        "page_heading": "//span[@role='heading']",
        "page_title": "//*[contains(@class,'quickLaunchTitle')]",
        "page_title_2": "//*[contains(@class,'quickLaunchHeader')]",
        "page_title_3": "(//*[contains(@ng-if,'ctrl.isEssLogin')])[1]",
        "main_menu": {
            "my_work_rsp": "id=menu-RSP",
            "rws_menu": "id=menu-RWS",
            "rta_menu": "id=menu-RTA",
            "org_menu": "id=menu-ORG",
            "ess_menu": "id=menu-ESS",
            "psa_menu": "id=menu-PSA"
        },
        "parent_sub_menu": {
            # RWS
            "rws_admin": "id=main-menu-RWS^ADMIN",
            "rws_driver_forecast": "id=main-menu-RWS^FORECAST",
            "rws_schedule": "id=main-menu-RWS^SCHD",
            "rws_employee": "id=main-menu-RWS^STAFF",
            "rws_users": "id=main-menu-RWS^SECURITY",
            "rws_reports": "id=main-menu-RWS^RAR",
            "rws_labor_forecast": "id=main-menu-RWS^LABORFCAST",
            "rws_predictive_analytics": "id=main-menu-RWS^PREDICTIVE",
            "rws_organization": "id=main-menu-RWS^ADM",
            "rws_calendar": "id=main-menu-RWS^CALENDAR",
            "rws_plan_budget": "id=main-menu-RWS^BUDGET",
            "rws_upcoming": "id=main-menu-RWS^PREPLAN",
            # RTA
            "rta_operations": "id=main-menu-RTA^OPERATIONS",
            "rta_devices": "id=main-menu-RTA^DEVICES",
            "rta_test_tools": "id=main-menu-RTA^TOOLS",
            "rta_payroll": "id=main-menu-RTA^PAYROLL",
            "rta_hr": "id=main-menu-RTA^RHR",
            "rta_configuration": "id=main-menu-RTA^CONFIG",
            "rta_attendance": "id=main-menu-RTA^ATTENDANCE",
            # ESS
            "ess_my_schedule": "id=main-menu-ESS^ESS",
            "ess_shift_trade_board": "id=main-menu-ESS^ESS_SHIFTTRADEBOARD",
            "ess_day_off_request": "id=main-menu-ESS^ESSDAYOFF",
            "ess_time_off_requests": "id=main-menu-ESS^ESSTIMEOFF",
            "ess_my_timecard": "id=main-menu-ESS^ESSTIMECARD",
            "ess_my_availability": "id=main-menu-ESS^ESSAVAIL",
            "ess_request_calendar": "id=main-menu-ESS^ESS_REQS_CALENDAR",
            "ess_my_profile": "id=main-menu-ESS^ESS_PROFILE",
            "ess_store_schedule": "id=main-menu-ESS^ESS_SCHEDULEWEEKLY",
            "ess_my_monthly_calendar": "id=main-menu-ESS^ESS_MONTHLY_CALENDAR",
            "ess_leave_balance": "id=main-menu-ESS^ESS_ACCRUAL_BALANCES",
            "ess_work_locations": "id=main-menu-ESS^EMP_SHARE_ESS",
            # PSA
            "psa_process_simulator": "id=main-menu-PSA^PROCESS_SIMULATOR",
            "psa_advanced_settings": "id=main-menu-PSA^ADVANCED_SETTINGS",
            "psa_state_machine_configuration": "id=main-menu-PSA^STATEMACHINECONFIG"
        },
        "child_sub_menu": {
            # RWS - Workcloud Scheduling - Driver Forecast
            "rws_driver_forecast_forecast": "id=submenu-RWS^GENFORECAST",
            "rws_driver_forecast_weekly_plan": "id=submenu-RWS^WEEKPLAN",
            "rws_driver_forecast_drivers": "id=submenu-RWS^WLDRIVER",
            "rws_driver_forecast_driver_models": "id=submenu-RWS^STG_FC_MOD",
            "rws_driver_forecast_events_calendar": "id=submenu-RWS^EVENTS",
            # RWS - Workcloud Scheduling - Labor Forecast
            "rws_labor_forecast_labor_forecast": "id=submenu-RWS^NEW_WORKLOAD",
            "rws_labor_forecast_activities": "id=submenu-RWS^WLACT",
            "rws_labor_forecast_calculation_methods": "id=submenu-RWS^WLMETHOD",
            "rws_labor_forecast_workload_batch_config": "id=submenu-RWS^STG_WLD_GEN",
            # RWS - Workcloud Scheduling - Schedule
            "rws_schedule_week_schedule": "id=submenu-RWS^WEEK_SCHEDULE",
            "rws_schedule_all_schedules": "id=submenu-RWS^SCHDHISTORY",
            "rws_schedule_day_schedule": "id=submenu-RWS^DAY_SCHEDULE",
            "rws_schedule_fixed_shifts_corp": "id=submenu-RWS^RWS_WORK_PATTERN_CORP",
            "rws_schedule_fixed_shifts": "id=submenu-RWS^RWS_WORK_PATTERN_STORE",
            "rws_schedule_shift_policy": "id=submenu-RWS^SCHEDULE_SHIFT_POLICY",
            "rws_schedule_shift_template": "id=submenu-RWS^RWS_SHIFT_TEMPLATES_CORP",
            "rws_schedule_labor_law": "id=submenu-RWS^LBRLAW",
            "rws_schedule_skill_coverage": "id=submenu-RWS^MINCOVEVT",
            "rws_schedule_acknowledgements": "id=submenu-RWS^ORGACKWLMTS",
            "rws_schedule_scheduling_models": "id=submenu-RWS^SCHMODEL",
            "rws_schedule_store_employee_group": "id=submenu-RWS^RWS_EMP_GROUPS",
            "rws_schedule_net_rules": "id=submenu-RWS^STORE_EMP_GROUPS",
            # RWS - Workcloud Scheduling - Admin
            "rws_admin_system_codes": "id=submenu-RWS^SYSCODE",
            "rws_admin_batch_jobs_monitor": "id=submenu-RWS^BATCH_STATUS",
            "rws_admin_rws_upload": "id=submenu-RWS^UPLOAD",
            "rws_admin_rws_logs": "id=submenu-RWS^VIEWLOGS",
            "rws_admin_rfp_upload": "id=submenu-RWS^RFPUPLOAD",
            "rws_admin_rfp_logs": "id=submenu-RWS^RFPVIEWLOGS",
            # RWS - Workcloud Scheduling - Employee
            "rws_employee_request_calendar": "id=submenu-RWS^STFREQCALRN_RV",
            "rws_employee_requests": "id=submenu-RWS^STFTOFF",
            "rws_employee_roster": "id=submenu-RWS^ROSTER",
            "rws_employee_criteria_configuration": "id=submenu-RWS^RWS_CRITERIA_CONFIG",
            "rws_employee_school_calendar": "id=submenu-RWS^SCHLCAL",
            "rws_employee_request_types": "id=submenu-RWS^REQUEST_TYPE",
            "rws_employee_associate_delegation": "id=submenu-RWS^ASSOCIATE_DELEGATION",
            "rws_employee_reporting_hierarchy": "id=submenu-RWS^REPORTING_HIERARCHY",
            "rws_employee_employee_groups": "id=submenu-RWS^EMP_GROUP",
            "rws_employee_gated_approval_configuration": "id=submenu-RWS^GATED_APPROVAL",
            # RWS - Workcloud Scheduling - Users
            "rws_users_users": "id=submenu-RWS^USERS",
            "rws_users_user_profile": "id=submenu-RWS^PROFILE",
            "rws_users_job_mapping": "id=submenu-RWS^DEPTGRP",
            # RWS - Workcloud Scheduling - Reports
            "rws_reports_view_reports": "id=submenu-RWS^RAR_VIEW",
            "rws_reports_authoring_and_analysis": "id=submenu-RWS^RAR_AUTH",
            # RWS - Workcloud Scheduling - Organization
            "rws_organization_distribution_list": "id=submenu-RWS^DISTLIST",
            "rws_organization_units": "id=submenu-RWS^ORG",
            "rws_organization_organization_structure": "id=submenu-RWS^STG",
            "rws_organization_attribute_report": "id=submenu-RWS^ATTR_RPT",
            "rws_organization_switch_store": "id=submenu-RWS^SWITCH_STORE",
            # RWS - Workcloud Scheduling - Predictive Analytics
            "rws_predictive_analytics_forecast_review": "id=submenu-PRE^FORECAST_REVIEW_MAIN",
            "rws_predictive_analytics_driver_setup": "id=submenu-PRE^DRIVER_SETUP",
            "rws_predictive_analytics_forecast_model_setup": "id=submenu-PRE^DRIVER_MODEL_SETUP",
            "rws_predictive_analytics_marker": "id=submenu-PRE^MARKER_CALENDAR",
            "rws_predictive_analytics_seasonality_index": "id=submenu-PRE^SEASONALITY",
            "rws_predictive_analytics_rounding_and_smoothing": "id=submenu-PRE^RASPROCESSING",
            "rws_predictive_analytics_forecast_driver_analysis": "id=submenu-PRE^FORECAST_ANALYSIS_MAIN",
            "rws_predictive_analytics_build_machine_learning_model": "id=submenu-PRE^BUILD_MACHINE_LEARNING_MODEL",
            # RTA - Workcloud Timekeeping - Operations
            "rta_operations_exception_management": "id=submenu-RTA^EXCEPTION_MANAGEMENT",
            "rta_operations_timecard_list": "id=submenu-RTA^TIMECARD",
            "rta_operations_manager_functions": "id=submenu-RTA^MANAGERFUNCTIONS",
            "rta_operations_clock_supervisors": "TBD",
            # RTA - Workcloud Timekeeping - Devices
            "rta_devices_device": "id=submenu-RTA^DEVICE",
            "rta_devices_device_groups": "id=submenu-RTA^DEVICE_GROUPS",
            "rta_devices_operations_policy": "id=submenu-RTA^OPERATIONSPOL",
            "rta_devices_transaction_types": "id=submenu-RTA^TRANSACTIONS",
            "rta_devices_device_monitoring": "id=submenu-RTA^DEV_MONITOR",
            "rta_devices_device_files": "id=submenu-RTA^DVC_FILE",
            "rta_devices_device_types": "id=submenu-RTA^DEVICE_TYPES",
            # RTA - Workcloud Timekeeping - HR
            "rta_hr_accrual_plan": "id=submenu-RTA^ACCRUAL_PLAN",
            "rta_hr_pay_policy": "id=submenu-RTA^PAY_POLICY",
            "rta_hr_agreement": "id=submenu-RTA^RHR_AGMT",
            "rta_hr_policies": "id=submenu-RTA^POLICIES",
            "rta_hr_time_rounding_policy": "id=submenu-RTA^ROUNDING",
            "rta_hr_accrual_policy": "id=submenu-RTA^ACCRUAL_POLICY",
            "rta_hr_exception_correction_policy": "id=submenu-RTA^WARNING_POLICY",
            "rta_hr_pay_time_rate_rules": "id=submenu-RTA^PAY_TIME_RATE",
            "rta_hr_pay_accumulator": "id=submenu-RTA^PAY_ACCUM",
            "rta_hr_accrual_plan": "id=submenu-RTA^ACCRUAL_PLAN",
            "rta_hr_accrual_accumulators": "id=submenu-RTA^ACCRUAL_ACCUM",
            # RTA - Workcloud Timekeeping - Test Tools
            "rta_test_tools_punch_import": "id=submenu-RTA^REQMAN",
            "rta_test_tools_simulate_punches": "id=submenu-RTA^PUNCH_IMPORT",
            "rta_test_tools_pay_rule_engine": "id=submenu-RTA^PAYRULEENGINE",
            "rta_test_tools_pay_recompute": "id=submenu-RTA^RECOMPUTE_PAY",
            # RTA - Workcloud Timekeeping - Payroll
            "rta_payroll_release_checks": "id=submenu-RTA^RELEASE_CHECKS",
            "rta_payroll_process_store_release": "id=submenu-RTA^PROCESS_STORE_RELEASE",
            "rta_payroll_status": "id=submenu-RTA^STATUS",
            "rta_payroll_period_payroll_release": "id=submenu-RTA^PERIOD_PAYROLL",
            # RWS - Workcloud Scheduling - Calendar
            "rws_calendar_fiscal_calendar": "id=submenu-RWS^FISCAL",
            "rws_calendar_blackout_types": "id=submenu-RWS^HOLIDAY",
            "rws_calendar_frequency_pattern": "id=submenu-RWS^FREQUENCY_PATTERN",
            # RTA - Workcloud Timekeeping - Configuration
            "rta_configuration_pay_codes": "id=submenu-RTA^STGSTRPAYCD",
            "rta_configuration_pay_code_groups": "id=submenu-RTA^PAY_CODE_GRPS",
            "rta_configuration_pay_category_groups": "id=submenu-RTA^PAY_CAT_GRPS",
            "rta_configuration_pay_categories": "id=submenu-RTA^PAY_CAT",
            "rta_configuration_earning_code_groups": "id=submenu-RTA^EARN_CODE_GRPS",
            "rta_configuration_earning_codes": "id=submenu-RTA^STGSTREARNCD",
            "rta_configuration_accrual_types": "id=submenu-RTA^ACCRUAL_TYPE",
            "rta_configuration_job_codes": "id=submenu-RTA^STGSTRJOBCD",
            "rta_configuration_activity_codes": "id=submenu-RTA^ACTIVITY_CODE",
            "rta_configuration_activity_code_groups": "id=submenu-RTA^ACT_CODE_GRPS",
            "rta_configuration_action_codes": "id=submenu-RTA^ACTION_CODE",
            "rta_configuration_actionset_codes": "id=submenu-RTA^ACTIONSET_CODE",
            "rta_configuration_day_definition": "id=submenu-RTA^DAY_DEF",
            "rta_configuration_pay_types": "id=submenu-RTA^PAY_TYPE",
            #RTA - Attendance
            "rta_attendance_attendance_management": "id=submenu-RTA^ATTENDANCE_MANAGEMENT",
            # RWS - Workcloud Scheduling - Plan Budget
            "rws_plan_budget_budget_plan": "id=submenu-RWS^BUDGET_PLAN",
            "rws_plan_budget_budget_generation": "id=submenu-RWS^BUDGET_GENERATION",
            "rws_plan_budget_budget_heads": "id=submenu-RWS^STG_BDGT_HD",
            # PSA - Professional Service Admin - Advanced Settings
            "psa_advanced_settings_queue_status": "id=submenu-PSA^BATCHQUESTAT",
            "psa_advanced_settings_worker_status": "id=submenu-PSA^BATCHWORKER",
            # RWS - Workcloud Scheduling - Upcoming
            "rws_upcoming_associate_alerts": "id=submenu-RWS^EMPLOYEE_ALERTS",
            "rws_upcoming_upcoming": "id=submenu-RWS^REVIEW_PREPLAN"
        },
    },
    "non_my_work": {
        "main_menu": {
            "hamburger_menu": "//a[@aria-label='Expand Menu'] | //a[@id='nav-icon1']",  # Check the naming # Main menu at the top of the page Hamburg icon
            "product_list_icon": "//i[@id='iToggleHeaderVisibility'] | (//i[contains(@class,'menu-list-icon')])[1]",
            "product_RWS": "//span[@id='spanHeaderLoadProduct_RWS'] | //a[contains(@onclick,'loadProduct(\"RWS\")')]",
            "product_RTA": "//span[@id='spanHeaderLoadProduct_RTA'] | //a[contains(@onclick,'loadProduct(\"RTA\")')]",
            "product_ESS": "//span[@id='spanHeaderLoadProduct_ESS'] | //a[contains(@onclick,'loadProduct(\"ESS\")')]",
            "product_PSA": "//span[@id='spanHeaderLoadProduct_PSA'] | //a[contains(@onclick,'loadProduct(\"PSA\")')]",
            "ess_submenu": "//img[@alt='RWS-ESS'] | //img[@alt='ESS ESS']",
            "switch_search_textbox": "//input[@id='search']",
            "switch_search_button": "//input[@id='searchButton']",
            "switch_profile_tab": "//span[@class='title-text stdcontainer-text title']",
            "rws_first_parent_menu": "img[data*='/rws/'] >> nth=0",
            "rta_first_parent_menu": "img[data*='/rta/'] >> nth=0",
            "ess_first_parent_menu": "img[data*='/ess/'] >> nth=0",
            "page_title_1": "//*[contains(@class,'quickLaunchTitle')] | //span[@role='heading']",
            "page_title_2": "//th[contains(@class,'ws-fs-md')]/span[@ng-if='ctrl.isEssLogin']",
            "ess_first_submenu_title": "(//li[contains(@id,'basemenu')]/a/p)[1]",
            "side_menu_table": "#sideMenu",
            "visible_childmenu_list": "ul[role='menu']:visible"
        },
        "parent_sub_menu": {            
            "rws_organization": "img[src*='Organization.']",
            "rws_users": "img[src*='usersIcon.']",  # User Tab in the navigation Menu
            "rws_calendar": "img[src*='Calendar.']",
            "rws_driver_forecast": "img[src*='DriverForecast.']",
            "rws_labor_forecast": "img[src*='LaborForecast.']",
            "rws_plan_budget": "img[src*='default-budget-icon.']",
            "rws_schedule": "img[src*='Schedule.']",
            "rws_employee": "img[src*='Employee.']",
            "rws_predictive_analytics": "img[src*='icon-module-pre.']",
            "rws_admin": "img[src*='Admin.']",
            "rws_reports": "img[src*='Reports.']",
            "rws_advanced_settings": "img[src*='AdvancedSettings.']",
            "rws_wlm_work": "//img[@alt='RWS-WLM Work']",
            "rws_upcoming": "img[src*='preplan.']",
            # RTA - Workcloud Timekeeping
            "rta_configuration": "img[src*='Configuration.']",
            "rta_operations": "img[src*='Operations.']",
            "rta_test_tools": "img[src*='TestTools.']",
            "rta_devices": "img[src*='Devices.']",
            "rta_hr": "img[src*='HR.']",
            "rta_payroll": "img[src*='Payroll.']",
            "rta_attendance": "//img[@alt='RWS-Attendance']",
            # PSA - Professional Service Admin
            "psa_process_simulator": "img[data*='processSimulator.'][src*='openLink.']",
            "psa_advanced_settings": "img[data*='UICustomizationAdmin.'][src*='openLink.']",
            "psa_state_machine_configuration": "img[data*='stateMachine.'][src*='openLink.']",
            # ESS - Employee Self Service
            "ess_my_schedule": "[data*='ess_emp_schedule.']",
            "ess_shift_trade_board": "[data*='ess_shiftTradeBoard.']",
            "ess_my_monthly_calendar": "[data*='essMonthlyCalendar.']",
            "ess_store_schedule": "[data*='employee_schedule_weekly.']",
            "ess_my_timecard": "[data*='tcard.']",
            "ess_my_availability": "[data*='stf_emp_avl_list.']",
            "ess_leave_balance": "[data*='essAccrualBalance.']",
            "ess_request_calendar": "[data*='ess_requests_calendar']",
            "ess_work_locations": "[data*='shareRequests.']",
            "ess_my_profile": "[data*='essMyProfile.']",
            "ess_attendance_management": "[data*='attendanceManagement.']",
            "ess_day_off_request": "[data*='ess_dayoff_request.']",
            "ess_time_off_requests": "[data*='ess_timeoff_request.']",
        },
        "child_sub_menu": {            
            "rws_organization_units": "[data*='adm_unit_lst.']",
            "rws_organization_organization_structure": "[data*='storeDepts.']",
            "rws_organization_distribution_list": "[data*='DistListDisplay.']",
            "rws_organization_attribute_report": "[data*='unit_attr_report.']",
            "rws_organization_switch_store": "[data*='SelectStore.'][id*='aFlexSubMenu']",
            # RWS - Workcloud Scheduling - Users
            "rws_users_users": "[data*='users.']",
            "rws_users_user_profile": "[data*='userProfileDetails.']",
            "rws_users_job_mapping": "[data*='jobcodeList.']",
            # RWS - Workcloud Scheduling - Calendar
            "rws_calendar_fiscal_calendar": "[data*='calendarGroup.']",
            "rws_calendar_store_blackouts": "[data*='annual_na_day_plan.']",
            "rws_calendar_blackout_types": "[data*='holidayTypes.']",
            "rws_calendar_frequency_pattern": "[data*='frequencyPattern.']",
            # RWS - Workcloud Scheduling - Driver Forecast
            "rws_driver_forecast_forecast": "[data*='volume_forecast.']",
            "rws_driver_forecast_drivers": "[data*='cfg_wdr_drv.']",
            "rws_driver_forecast_driver_models": "[data*='adm_forecast_model_lst.']",
            "rws_driver_forecast_events_calendar": "[data*='fca_mktevnt_bulkedit.']",
            "rws_driver_forecast_annual_plan": "Annual Plan",
            "rws_driver_forecast_period_plan": "Period Plan",
            "rws_driver_forecast_weekly_plan": "[data*='forecast_initialize_stf.']",
            # RWS - Workcloud Scheduling - Labor Forecast
            "rws_labor_forecast_labor_forecast": "[data*='workload.']",
            "rws_labor_forecast_activities": "[data*='act_lst.']",
            "rws_labor_forecast_calculation_methods": "[data*='cfg_wdr_cal.']",
            "rws_labor_forecast_workload_batch_config": "[data*='wld_mnt_list.']",
            # RWS - Workcloud Scheduling - Plan Budget
            "rws_plan_budget_budget_plan": "[data*='budgetPlan.']",
            "rws_plan_budget_budget_generation": "[data*='budgetGeneration.']",
            "rws_plan_budget_budget_heads": "[data*='adm_budget_model_lst.']",
            # RWS - Workcloud Scheduling - Schedule
            "rws_schedule_shift_policy": "[data*='shift_policy.']",
            "rws_schedule_day_schedule": "[data*='schedule.'][data*='viewType=daily\"']",
            "rws_schedule_week_schedule": "[data*='schedule.'][data*='viewType=weekly\"']",
            "rws_schedule_all_schedules": "[data*='sch_history.']",
            "rws_schedule_compare_schedule": "Compare Schedule",
            "rws_schedule_fixed_shifts": "[data*='template_calendar.'] >> nth=0",
            "rws_schedule_fixed_shifts_corp": "[data*='generic_template.'] >> nth=0",
            "rws_schedule_shift_template": "[data*='shift_templates.'] >> nth=0",
            "rws_schedule_labor_law": "[data*='adm_labordetails.']",
            "rws_schedule_skill_coverage": "[data*='min_cov_evt_drv_lst.']",
            "rws_schedule_acknowledgements": "[data*='certificateMaintenance.']",
            "rws_schedule_scheduling_models": "[data*='sch_model.']",
            "rws_schedule_store_employee_group": "[data*='employeeGroups.']",
            "rws_schedule_net_rules": "[data*='storeEmployeeGroups.']",
            "rws_schedule_ai_model": "AI Model",
            # RWS - Workcloud Scheduling - Employee
            "rws_employee_roster": "[data*='roster.']",
            "rws_employee_school_calendar": "[data*='schoolCalendar.']",
            "rws_employee_requests": "[data*='staff_timeoff_request.']",
            "rws_employee_request_calendar": "[data*='requestsCalendar']",
            "rws_employee_request_types": "[data*='requestType.']",
            "rws_employee_associate_delegation": "[data*='associateDelegation.']",
            "rws_employee_reporting_hierarchy": "[data*='reportingHierarchy.']",
            "rws_employee_criteria_configuration": "[data*='criteriaConfig.']",
            "rws_employee_employee_groups": "[data*='emp_group_criteria.']",
            "rws_employee_gated_approval_configuration": "[data*='gatedApprovalConfig.']",
            # RWS - Workcloud Scheduling - Predictive Analytics
            "rws_predictive_analytics_driver_setup": "[data*='driverSetup.']",
            "rws_predictive_analytics_forecast_admin_menu": "[data*='forecastAdminMenu.']",
            "rws_predictive_analytics_forecast_model_setup": "[data*='driverModel.']",
            "rws_predictive_analytics_marker": "[data*='event.']",
            "rws_predictive_analytics_seasonality_index": "[data*='pre_seasonality.']",
            "rws_predictive_analytics_rounding_and_smoothing": "[data*='rounding_and_smoothing.']",
            "rws_predictive_analytics_forecast_alerts": "[data*='pre_forecast_alerts.']",
            "rws_predictive_analytics_forecast_review": "[data*='forecastReview.']",
            "rws_predictive_analytics_forecast_driver_analysis": "[data*='driverDataAnalysis.']",
            "rws_predictive_analytics_marker_data_import": "[data*='markerdataupload.']",
            "rws_predictive_analytics_week_plan": "[data*='initializeForecast.'][data*='sm=WEEK']",
            "rws_predictive_analytics_period_plan": "[data*='initializeForecast.'][data*='sm=PERIOD']",
            "rws_predictive_analytics_annual_plan": "[data*='initializeForecast.'][data*='sm=ANNUAL']",
            "rws_predictive_analytics_mid_week": "[data*='initializeForecast.'][data*='sm=MIDWEEK']",
            "rws_predictive_analytics_forecast_scenario": "[data*='scenario.']",
            "rws_predictive_analytics_build_machine_learning_model": "[data*='buildMachineLearningModel.']",
            "rws_predictive_analytics_initialize_scenario": "[data*='initializeForecastUsingML.']",
            # RWS - Workcloud Scheduling - Admin
            "rws_admin_system_codes": "[data*='cfg_attr_maintlookup.']",
            "rws_admin_ros_upload": "ROS Upload",
            "rws_admin_ros_logs": "ROS Logs",
            "rws_admin_rfp_upload": "[data*='rfp/admin/uploadMenu.']",
            "rws_admin_rfp_logs": "[data*='rfp/admin/viewlogMenu.']",
            "rws_admin_rws_upload": "[data*='rws/admin/uploadMenu.']",
            "rws_admin_rws_logs": "[data*='rws/admin/rwsViewlogMenu.']",
            "rws_admin_data_imports_monitor": "[data*='dataMonitor.']",
            "rws_admin_batch_jobs_monitor": "[data*='batch_job_status.']",
            # RWS - Workcloud Scheduling - Advanced Settings
            # Scope to the clickable menu-item anchor and support both legacy and
            # newer `my-`-prefixed test-id variants rendered by the sidenav.
            "rws_advanced_settings_advanced_settings": "a[data-testid$='RWS^ADVANCED_SETTINGS']",
            # RWS - Workcloud Scheduling - Reports
            "rws_reports_authoring_and_analysis": "[data*='reportAuth.'],[onclick*='reportAuth.']",
            "rws_reports_view_reports": "[data*='showRwsReport']",
            # RTA - Workcloud Timekeeping - Configuration
            "rta_configuration_codes_setup": "Codes Setup",
            "rta_configuration_pay_codes": "[id=aSubMenu][data*='PayCodesOrg.']",
            "rta_configuration_pay_code_groups": "[data*='payCodeGroups.']",
            "rta_configuration_pay_categories": "[data*='payCategories.']",
            "rta_configuration_pay_category_groups": "[data*='payCategoryGroups.']",
            "rta_configuration_earning_codes": "[data*='earnCodesOrg.']",
            "rta_configuration_earning_code_groups": "[data*='earnCodesGroups.']",
            "rta_configuration_accrual_types": "[data*='taAccrualTypesList.']",
            "rta_configuration_job_codes": "[data*='jobCodesOrg.']",
            "rta_configuration_activity_codes": "[data*='activityCodesList.']",
            "rta_configuration_activity_code_groups": "[data*='activityCodeGroups.']",
            "rta_configuration_action_codes": "[data*='actionList.']",
            "rta_configuration_actionset_codes": "[data*='actionSetList.']",
            "rta_configuration_time_and_attendance": "Time and Attendance",
            "rta_configuration_day_definition": "[data*='dayDefinitionList.'] >> nth=-1",
            "rta_configuration_pay_types": "[data*='payTypeList.']",
            # RTA - Workcloud Timekeeping - Operations
            "rta_operations_time_summary": "Time Summary",
            "rta_operations_timecard_list": "[data*='associatesInStore'] >> nth=0",
            "rta_operations_manager_functions": "[data*='empMsgList.'] >> nth=0",
            "rta_operations_message_list": "Message List",
            "rta_operations_manager_summary": "Manager Summary",
            "rta_operations_weekly_exceptions": "Weekly Exceptions",
            "rta_operations_daily_summary": "Daily Summary",
            "rta_operations_exception_management": "[data*='exceptionManagement.']",
            "rta_operations_weekly_labor": "Weekly - Labor",
            "rta_operations_daily_hours": "Daily - Hours",
            "rta_operations_daily_labor": "Daily - Labor",
            "rta_operations_schedule_vs_actual": "Schedule Vs Actual",
            "rta_operations_accrual_balances": "Accrual Balances",
            "rta_operations_employee_exception_report": "Employee Exception Report",
            "rta_operations_approaching_ot": "Approaching OT",
            "rta_operations_unaccepted_punches": "Unaccepted Punches",
            "rta_operations_unresolved_punches": "Unresolved Punches",
            "rta_operations_temporary_badges": "[data*='tempBadge.']",
            "rta_operations_clock_supervisors": "[data*='clkSupervisor.']",
            # RTA - Workcloud Timekeeping - Test Tools
            "rta_test_tools_schedule_import": "[data*='schUpload.']",
            "rta_test_tools_punch_import": "[data*='TestRequestManager.']",
            "rta_test_tools_special_pay_import": "[data*='specialPayImport.']",
            "rta_test_tools_cardid_import": "CardID Import",
            "rta_test_tools_simulate_punches": "Simulate Punches",
            "rta_test_tools_pay_rule_engine": "[data*='invokePayProcessor.']",
            "rta_test_tools_device_import": "[data*='deviceImports.']",
            "rta_test_tools_pay_recompute": "[data*='recomputePay.']",
            # RTA - Workcloud Timekeeping - Devices
            "rta_devices_device": "[data*='deviceList.']",
            "rta_devices_device_groups": "[data*='deviceGroupList.']",
            "rta_devices_device_types": "[data*='deviceTypeList.']",
            "rta_devices_operations_policy": "[data*='devOpsOrg.']",
            "rta_devices_transaction_types": "[data*='transactionTypes.']",
            "rta_devices_device_monitoring": "[data*='appMonitor.']",
            "rta_devices_device_files": "[data*='deviceFileList.']",
            # RTA - Workcloud Timekeeping - HR
            "rta_hr_agreement": "[data*='rhrAgmtList.']",
            "rta_hr_policies": "[data*='timeCollectionList'] >> nth=0",
            "rta_hr_time_collection_policy": "Time Collection Policy",
            "rta_hr_time_rounding_policy": "[data*='taRoundingList.']",
            "rta_hr_accrual_policy": "[data*='accrualPlcyList.']",
            "rta_hr_pay_policy": "[data*='payRulePolicyList.']",
            "rta_hr_exception_correction_policy": "[data*='warningPolicyList.']",
            "rta_hr_pay_time_rate_rules": "[data*='payTimeRateList.']",
            "rta_hr_pay_accumulator": "[data*='payAccumulators.']",
            "rta_hr_accrual_plan": "[data*='accrualPlanList.']",
            "rta_hr_accrual_accumulators": "[data*='accrualAccumulatorList.']",
            "rta_hr_employee_accrual_transactions": "Employee Accrual Transactions",
            "rta_hr_accrual_engine_process": "Accrual Engine Process",
            # RTA - Workcloud Timekeeping - Payroll
            "rta_payroll_dashboard": "[data*='payrollDashboard.']",
            "rta_payroll_status": "[data*='payrollStatus.']",
            "rta_payroll_period_payroll_release": "[data*='periodPayrollRelease.']",
            "rta_payroll_release_checks": "[data*='payrollCheckSetsList.']",
            "rta_payroll_configuration": "[data*='payrollReleaseConfig.']",
            "rta_payroll_control_total": "Control Total",
            "rta_payroll_pay_file_configuration": "[data*='payFileConfig.']",
            "rta_payroll_process_store_release": "[data*='processStoreRelease.']",
            "rta_payroll_pay_results_summary": "[data*='payrollSummary.']",
            "rta_payroll_do_not_export": "Do Not Export",
            # RTA - Attendance
            "rta_attendance_attendance_management": "[data*='attendanceManagement.'] >> nth=0",
            # PSA - Professional Service Admin - Process Simulator
            "psa_process_simulator_process_simulator": "[data*='processSimulator.']",
            # PSA - Professional Service Admin - Advanced Settings
            "psa_advanced_settings_queue_status": "[data*='BatchQueStatus.']",
            "psa_advanced_settings_worker_status": "[data*='BatchWorker.']",
            # PSA - Professional Service Admin - State Machine Configuration
            "psa_state_machine_configuration_state_machine_configuration": "[data*='stateMachine.']",
            # RWS - Workcloud Scheduling - Upcoming
            "rws_upcoming_associate_alerts": "[data*='employeeAlerts.']",
            "rws_upcoming_upcoming": "[data*='preplan.']"
        },
    },
}
