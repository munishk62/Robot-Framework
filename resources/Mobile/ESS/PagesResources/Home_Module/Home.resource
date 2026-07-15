*** Settings ***
Documentation       Has all the user interaction implementations of the home module.

Library             DateTime
Library             String
Resource            resources/Mobile/ESS/PagesResources/Common/Common.resource
Resource            resources/Mobile/ESS/PagesResources/Clock_Module/clock.resource
Variables           resources/Mobile/ESS/Locators/common_data.py
Variables           resources/Mobile/ESS/Locators/Clock.py
Variables           resources/Mobile/ESS/Locators/Home.py
Variables           resources/Mobile/ESS/Locators/Login.py
Variables           resources/Mobile/ESS/Locators/Profile.py
Variables           resources/Mobile/ESS/Locators/Smoke.py
Variables           resources/Mobile/ESS/Locators/Request.py
Variables           resources/Mobile/ESS/Locators/ShiftTrade.py
Variables           resources/Mobile/ESS/Locators/TimeCard.py
Variables           resources/Mobile/ESS/Locators/StoreSchedule.py
Variables           resources/Mobile/ESS/Locators/LeaveBalance.py
Variables           resources/Mobile/ESS/Locators/Schedule.py


*** Keywords ***
Verify Mobile ESS Home Shortcut Header
    [Documentation]    Verifies a home shortcut header.
    ${localised_text}    Get Localised Message From Key    ${homeTitleShortcut}
    ${all_caps_text}    Convert To Upper Case    ${localised_text}
    ${title_shortcut_locator}    Get Locator Exact    ${all_caps_text}
    Swipe Until Visible    ${title_shortcut_locator}
    Wait Until Element Is Visible    ${title_shortcut_locator}    error="Shortcuts not visible on home screen."

Navigate Mobile ESS To Home Tab Module
    [Documentation]    Navigates mobile ess to the Home Tab module.
    ${localised_semantic_for_home_bottom_menu}    Get Localised Message From Key    ${commonBottomBarLabel}
    ${home_tab_label_semantic}    Get Localised Message From Key    ${HomeTabLabel}
    ${final_string}    Get Message With Arguments    ${localised_semantic_for_home_bottom_menu}    ${home_tab_label_semantic}    1    ''
    ${home_tab_locator}    Get Locator Contains    ${final_string}
    Click Element    ${home_tab_locator}
    ${home_tab_title_locator}    Get Localised Locator Contains    ${HomeTabLabel}
    Wait Until Element Is Visible    ${home_tab_title_locator}

Verify Mobile ESS Time Clock Shortcut
    [Documentation]    Verifies time clock shortcut module.
    ...    Args:
    ...    ${Mobile_Ess_Time_Clock_Enabled}: <Mobile ess time clock module enable status>
    [Arguments]    ${Mobile_Ess_Time_Clock_Enabled}
    IF    '${Mobile_Ess_Time_Clock_Enabled}' == "True"
        Navigate Mobile ESS To Time Clock From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${ClockButton_semantic_path}    Get Localised Locator Exact    ${ClockButtonLabel}
        Swipe Until Element Not Visible    ${ClockButton_semantic_path}    "down"    2
    END

Verify Mobile ESS Leave Balance Shortcut
    [Documentation]    Verifies leave balance shortcut module.
    ...    Args:
    ...    ${Mobile_Ess_Leave_Balance_Enabled}: <Mobile ESS leave balance module enable status>
    [Arguments]    ${Mobile_Ess_Leave_Balance_Enabled}
    IF    '${Mobile_Ess_Leave_Balance_Enabled}' == "True"
        Navigate Mobile ESS To Leave Balance From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${LeaveBalanceButton_semantic_path}    Get Localised Locator Exact    ${LeaveBalanceButtonLabel}
        Swipe Until Element Not Visible    ${LeaveBalanceButton_semantic_path}    "down"    2
    END

Verify Mobile ESS Availability Shortcut
    [Documentation]    Used for verifying availability shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Availability_Enabled}: <Mobile ess availability enable status>
    [Arguments]    ${Mobile_Ess_Availability_Enabled}
    IF    '${Mobile_Ess_Availability_Enabled}' == "True"
        Navigate Mobile ESS To Availability From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${availabilityButtonLocator}    Get Localised Locator Exact    ${AvailabilityButtonLabel}
        Swipe Until Element Not Visible    ${availabilityButtonLocator}    "down"    2
    END

Verify Mobile ESS TimeCard Shortcut
    [Documentation]    Used for verifying timeCard shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_TimeCard_Enabled}: <Mobile ess timecard enable status>
    [Arguments]    ${Mobile_Ess_TimeCard_Enabled}
    IF    '${Mobile_Ess_TimeCard_Enabled}' == "True"
        Navigate Mobile ESS To TimeCard From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${timeCardButtonLocator}    Get Localised Locator Exact    ${TimecardButtonLabel}
        Swipe Until Element Not Visible    ${timeCardButtonLocator}    "down"    2
    END

Verify Mobile ESS Store Schedule Shortcut
    [Documentation]    Used for verifying store schedule shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Store_Schedule_Enabled}: <Mobile ess store schedule enable status>
    [Arguments]    ${Mobile_Ess_Store_Schedule_Enabled}
    IF    '${Mobile_Ess_Store_Schedule_Enabled}' == "True"
        Navigate Mobile ESS To Store Schedule From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${storeScheduleButtonLocator}    Get Localised Locator Exact    ${StoreScheduleButtonLabel}
        Swipe Until Element Not Visible    ${storeScheduleButtonLocator}    "down"    2
    END

Verify Mobile ESS Work Location Shortcut
    [Documentation]    Used for verifying work location shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Work_Location_Enabled}: <Mobile ess work location enable status>
    [Arguments]    ${Mobile_Ess_Work_Location_Enabled}
    IF    '${Mobile_Ess_Work_Location_Enabled}' == "True"
        Navigate Mobile ESS To Work Location From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${workLocationButtonLocator}    Get Localised Locator Exact    ${AltWorkLocationButtonLabel}
        Swipe Until Element Not Visible    ${workLocationButtonLocator}    "down"    2
    END

Verify Mobile ESS Profile Shortcut
    [Documentation]    Used for verifying profile shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Profile_Enabled}: <Mobile ess profile enable status>
    [Arguments]    ${Mobile_Ess_Profile_Enabled}
    IF    '${Mobile_Ess_Profile_Enabled}' == "True"
        Navigate Mobile ESS To Profile From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${profileButtonLocator}    Get Localised Locator Exact    ${ProfileButtonLabel}
        Swipe Until Element Not Visible    ${profileButtonLocator}    "down"    2
    END

Verify Mobile ESS Attendance Management Shortcut
    [Documentation]    Used for verifying attendance management shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Attendance_Management_Enabled}: <Mobile ess attendance management enable status>
    [Arguments]    ${Mobile_Ess_Attendance_Management_Enabled}
    IF    '${Mobile_Ess_Attendance_Management_Enabled}' == "True"
        Navigate Mobile ESS To Attendance Management From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${attendanceManagementButtonLocator}    Get Localised Locator Exact    ${AttendanceManagementButtonLabel}
        Swipe Until Element Not Visible    ${attendanceManagementButtonLocator}    "down"    2
    END

Verify Mobile ESS Schedule Shortcut
    [Documentation]    Used for verifying schedule shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Schedule_Enabled}: <Mobile ess schedule enable status>
    [Arguments]    ${Mobile_Ess_Schedule_Enabled}
    IF    '${Mobile_Ess_Schedule_Enabled}' == "True"
        Navigate Mobile ESS To Schedule From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${scheduleButtonLocator}    Get Localised Locator Exact    ${ScheduleButtonLabel}
        Swipe Until Element Not Visible    ${scheduleButtonLocator}    "down"    2
    END

Verify Mobile ESS Requests Shortcut
    [Documentation]    Used for verifying requests shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Requests_Enabled}: <Mobile ess requests enable status>
    [Arguments]    ${Mobile_Ess_Requests_Enabled}
    IF    '${Mobile_Ess_Requests_Enabled}' == "True"
        Navigate Mobile ESS To Request From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${requestsButtonLocator}    Get Localised Locator Exact    ${RequestButtonLabel}
        Swipe Until Element Not Visible    ${requestsButtonLocator}    "down"    2
    END

Verify Mobile ESS Shift Trade Shortcut
    [Documentation]    Used for verifying shift trade shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Shift_Trade_Enabled}: <Mobile ess shift trade enable status>
    [Arguments]    ${Mobile_Ess_Shift_Trade_Enabled}
    IF    '${Mobile_Ess_Shift_Trade_Enabled}' == "True"
        Navigate Mobile ESS To Shift Trade From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${shiftTradeButtonLocator}    Get Localised Locator Exact    ${ShiftTradeButtonLabel}
        Swipe Until Element Not Visible    ${shiftTradeButtonLocator}    "down"    2
    END

Verify Mobile ESS Delegation Shortcut
    [Documentation]    Used for verifying delegation shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Delegation_Enabled}: <Mobile ess delegation enable status>
    [Arguments]    ${Mobile_Ess_Delegation_Enabled}
    IF    '${Mobile_Ess_Delegation_Enabled}' == "True"
        Navigate Mobile ESS To Delegation From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${delegationButtonLocator}    Get Localised Locator Exact    ${homeDelegationButtonShortcut}
        Swipe Until Element Not Visible    ${delegationButtonLocator}    "down"    2
    END

Verify Mobile ESS Absence Calendar Shortcut
    [Documentation]    Used for verifying absence calendar shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_Absence_Calendar_Enabled}: <Mobile ess absence calendar enable status>
    [Arguments]    ${Mobile_Ess_Absence_Calendar_Enabled}
    IF    '${Mobile_Ess_Absence_Calendar_Enabled}' == "True"
        Navigate Mobile ESS To Absence Calendar From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${absenceCalendarButtonLocator}    Get Localised Locator Exact    ${AbsenceCalendarButtonLabel}
        Swipe Until Element Not Visible    ${absenceCalendarButtonLocator}    "down"    2
    END

Verify Mobile ESS School Calendar Shortcut
    [Documentation]    Used for verifying school calendar shortcut module on mobile Nextgen ESS app.
    ...    Args:
    ...    ${Mobile_Ess_School_Calendar_Enabled}: <Mobile ess school calendar enable status>
    [Arguments]    ${Mobile_Ess_School_Calendar_Enabled}
    IF    '${Mobile_Ess_School_Calendar_Enabled}' == "True"
        Navigate Mobile ESS To School Calendar From Shortcut Menu
        Navigate Mobile ESS To Home Tab Module
    ELSE
        ${schoolCalendarButtonLocator}    Get Localised Locator Exact    ${homeSchoolCalendarButtonShortcut}
        Swipe Until Element Not Visible    ${schoolCalendarButtonLocator}    "down"    2
    END

Navigate Mobile ESS To Time Clock From Shortcut Menu
    [Documentation]    Navigates mobile nextgen ESS to the time Clock from shortcut menu.
    ${time_clock_title_locator}    Get Localised Locator Exact    ${ClockButtonLabel}
    Swipe Until Visible    ${time_clock_title_locator}
    Navigate Mobile ESS To Module    ${ClockButtonLabel}
    Wait Until Element Is Visible    ${time_clock_title_locator}

Navigate Mobile ESS To Leave Balance From Shortcut Menu
    [Documentation]    Navigates mobile Nextgen ESS to the Leave Balance from shortcut menu.
    ${leave_balance_semantic_path}    Get Localised Locator Exact    ${LeaveBalanceButtonLabel}
    Swipe Until Visible    ${leave_balance_semantic_path}
    Navigate Mobile ESS To Module    ${LeaveBalanceButtonLabel}
    ${leave_balance_title_locator}    Get Localised Locator Contains    ${requestsTabBalanceTitle}
    Wait Until Element Is Visible    ${leave_balance_title_locator}

Navigate Mobile ESS To Availability From Shortcut Menu
    [Documentation]    Navigates mobile Nextgen ESS to the availability from shortcut menu.
    ${availability_title_locator}    Get Localised Locator Exact    ${AvailabilityButtonLabel}
    Swipe Until Visible    ${availability_title_locator}
    Navigate Mobile ESS To Module    ${AvailabilityButtonLabel}
    Wait Until Element Is Visible    ${availability_title_locator}

Navigate Mobile ESS To TimeCard From Shortcut Menu
    [Documentation]    Navigates mobile Nextgen ESS to the timeCard From Shortcut Menu.
    ${timeCard_title_locator}    Get Localised Locator Exact    ${TimecardButtonLabel}
    Swipe Until Visible    ${timeCard_title_locator}
    Navigate Mobile ESS To Module    ${TimecardButtonLabel}
    Wait Until Element Is Visible    ${timeCard_title_locator}

Navigate Mobile ESS To Store Schedule From Shortcut Menu
    [Documentation]    Navigates mobile nextgen ESS to the Store Schedule From Shortcut Menu.
    ${store_schedule_title_locator}    Get Localised Locator Exact    ${StoreScheduleButtonLabel}
    Swipe Until Visible    ${store_schedule_title_locator}
    Navigate Mobile ESS To Module    ${StoreScheduleButtonLabel}
    Wait Until Element Is Visible    ${store_schedule_title_locator}

Navigate Mobile ESS To Work Location From Shortcut Menu
    [Documentation]    Navigates mobile nextgen ESS to the Work Location From Shortcut Menu.
    ${work_location_title_locator}    Get Localised Locator Contains    ${AltWorkLocationButtonLabel}
    Swipe Until Visible    ${work_location_title_locator}
    Navigate Mobile ESS To Module    ${AltWorkLocationButtonLabel}
    Wait Until Element Is Visible    ${work_location_title_locator}

Navigate Mobile ESS To Profile From Shortcut Menu
    [Documentation]    Navigates mobile Nextgen ESS to the profile From Shortcut Menu.
    ${profile_title_locator}    Get Localised Locator Contains    ${ProfileButtonLabel}
    Swipe Until Visible    ${profile_title_locator}
    Navigate Mobile ESS To Module    ${ProfileButtonLabel}
    Wait Until Element Is Visible    ${profile_title_locator}

Navigate Mobile ESS To Attendance Management From Shortcut Menu
    [Documentation]    Navigates mobile nextgen ESS to the Attendance Management From Shortcut Menu.
    ${attendance_management_title_locator}    Get Localised Locator Contains    ${AttendanceManagementButtonLabel}
    Swipe Until Visible    ${attendance_management_title_locator}
    Navigate Mobile ESS To Module    ${AttendanceManagementButtonLabel}
    Wait Until Element Is Visible    ${attendance_management_title_locator}

Navigate Mobile ESS To Schedule From Shortcut Menu
    [Documentation]    Navigates mobile nextgen ESS to the Schedule From Shortcut Menu.
    ${schedule_title_locator}    Get Localised Locator Contains    ${ScheduleButtonLabel}
    Swipe Until Visible    ${schedule_title_locator}
    Navigate Mobile ESS To Module    ${ScheduleButtonLabel}
    Wait Until Element Is Visible    ${schedule_title_locator}

Navigate Mobile ESS To Request From Shortcut Menu
    [Documentation]    Navigates mobile Nextgen ESS to the request From Shortcut Menu.
    ${request_title_locator}    Get Localised Locator Contains    ${Request_Button_Label}
    Swipe Until Visible    ${request_title_locator}
    Navigate Mobile ESS To Module    ${Request_Button_Label}
    Wait Until Element Is Visible    ${request_title_locator}

Navigate Mobile ESS To Shift Trade From Shortcut Menu
    [Documentation]    Navigates mobile nextgen ESS to the Shift Trade From Shortcut Menu.
    ${shift_trade_title_locator}    Get Localised Locator Contains    ${ShiftTradeButtonLabel}
    Swipe Until Visible    ${shift_trade_title_locator}
    Navigate Mobile ESS To Module    ${ShiftTradeButtonLabel}
    Wait Until Element Is Visible    ${shift_trade_title_locator}

Navigate Mobile ESS To Delegation From Shortcut Menu
    [Documentation]    Navigates mobile nextgen ESS to the Delegation From Shortcut Menu.
    ${delegation_title_locator}    Get Localised Locator Contains    ${homeDelegationButtonShortcut}
    Swipe Until Visible    ${delegation_title_locator}
    Navigate Mobile ESS To Module    ${homeDelegationButtonShortcut}
    Wait Until Element Is Visible    ${delegation_title_locator}

Navigate Mobile ESS To Absence Calendar From Shortcut Menu
    [Documentation]    Navigates mobile nextgen ESS to the Absence Calendar From Shortcut Menu.
    ${absence_calendar_title_locator}    Get Localised Locator Contains    ${AbsenceCalendarButtonLabel}
    Swipe Until Visible    ${absence_calendar_title_locator}
    Navigate Mobile ESS To Module    ${AbsenceCalendarButtonLabel}
    Wait Until Element Is Visible    ${absence_calendar_title_locator}

Navigate Mobile ESS To School Calendar From Shortcut Menu
    [Documentation]    Navigates mobile nextgen ESS to the School Calendar From Shortcut Menu.
    ${school_calendar_title_locator}    Get Localised Locator Contains    ${homeSchoolCalendarButtonShortcut}
    Swipe Until Visible    ${school_calendar_title_locator}
    Navigate Mobile ESS To Module    ${homeSchoolCalendarButtonShortcut}
    Wait Until Element Is Visible    ${school_calendar_title_locator}

Navigate Mobile ESS To Add Request Page
    [Documentation]    Navigates mobile Nextgen ESS to the request module.
    ...    Args:
    ...    ${add_request_quick_button_enabled}: <Mobile ess add request quick button module enable status>
    [Arguments]    ${add_request_quick_button_enabled}
    IF    '${add_request_quick_button_enabled}' == "True"
        Navigate Mobile ESS To Module    ${quickActionNewPtoRequest}
        ${element_semantic_path}    Get Localised Locator Contains    ${requestAddDayOffButton}
        Wait Until Element Is Visible    ${element_semantic_path}
    ELSE
        ${quickActionNewPtoRequest_locator}    Get Localised Locator Contains    ${quickActionNewPtoRequest}
        Page Should Not Contain Element    ${quickActionNewPtoRequest_locator}
    END

Navigate Mobile ESS To Time Card Page
    [Documentation]    Navigates mobile Nextgen ESS to the time card module.
    ...    Args:
    ...    ${timecard_quick_button_enabled}: <Mobile ess timecard quick button module enable status>
    [Arguments]    ${timecard_quick_button_enabled}
    IF    '${timecard_quick_button_enabled}' == "True"
        Navigate Mobile ESS To Module    ${quickActionTimeCard}
        ${element_semantic_path}    Get Localised Locator Contains    ${timeCardTitle}
        Wait Until Element Is Visible    ${element_semantic_path}
    ELSE
        ${quickActionTimeCard_locator}    Get Localised Locator Contains    ${quickActionTimeCard}
        Page Should Not Contain Element    ${quickActionTimeCard_locator}
    END

Navigate Mobile ESS To Store Schedule Page
    [Documentation]    Navigates mobile Nextgen ESS to the store schedule module.
    ...    Args:
    ...    ${store_schedule_quick_button_enabled}: <Mobile ess store schedule quick button module enable status>
    [Arguments]    ${store_schedule_quick_button_enabled}
    IF    '${store_schedule_quick_button_enabled}' == "True"
        Navigate Mobile ESS To Module    ${quickActionStoreSchedule}
        ${element_semantic_path}    Get Localised Locator Contains    ${storeScheduleDayTab}
        Wait Until Element Is Visible    ${element_semantic_path}
    ELSE
        ${quickActionStoreSchedule_locator}    Get Localised Locator Contains    ${quickActionStoreSchedule}
        Page Should Not Contain Element    ${quickActionStoreSchedule_locator}
    END

Navigate Mobile ESS To Home Page
    [Documentation]    Navigates mobile Nextgen ESS to the home module.
    Navigate Mobile ESS To Module    ${HomeTabLabel}

Verify Mobile ESS Schedule When Upcoming Shifts Are Not Published
    [Documentation]    Used for verifying Schedule When Upcoming Shifts Are Not Published on mobile Nextgen ESS app.
    ${localised_text}    Get Localised Message From Key    ${schedule_button_label_locator}
    ${all_caps_text}    Convert To Upper Case    ${localised_text}
    ${schedule_button_label_semantic}    Get Locator Exact    ${all_caps_text}
    Wait Until Element Is Visible    ${schedule_button_label_semantic}
    ${home_not_scheduled_semantic}    Get Localised Locator Exact    ${home_not_scheduled_locator}
    Wait Until Element Is Visible    ${home_not_scheduled_semantic}

Navigate Mobile ESS To Home Page Side Menu
    [Documentation]    Navigates mobile Nextgen ESS to the home side menu.
    Navigate Mobile ESS To Module    ${HOME_DRAWER}
    ${log_out_locator}    Get Localised Locator Contains    ${LOG_OUT}
    Wait Until Element Is Visible    ${log_out_locator}

Verify Mobile ESS Associate Name
    [Documentation]    Verify associate name is visible in Nextgen ESS app.
    ...    Arg:
    ...    - ${displayName}: Display name of the user which is expected to be visible on home screen.
    [Arguments]    ${displayName}
    @{name}    Split String    ${displayName}    ,
    ${first_name_normalized}    Replace String    ${name}[1]    ${SPACE}    ${EMPTY}
    ${localised_semantic_home_label}    Get Localised Message From Key    ${homeLabelGreeting}
    ${final_string}    Get Message With Arguments    ${localised_semantic_home_label}    ${first_name_normalized}
    ${associate_name_locator}    Get Locator Contains    ${final_string}
    # There is "User Authenticated Successfully" popup which takes time to go of screen and has no exit or close button.
    Wait Until Element Is Visible    ${associate_name_locator}    timeout=${LONG_TIMEOUT}

Verify Mobile ESS Associate Information
    [Documentation]    Used for Associate Information is visible in Nextgen ESS app.
    ...    Arg:
    ...    - ${User_Key}: User unique key from master users sheet.
    ...    - ${Job_Code}: Job code.
    ...    - ${Department_name}: Department Name.
    [Arguments]    ${User_Key}    ${Job_Code}    ${Department_name}
    ${user}    Get User    ${User_Key}
    VAR    ${associate_name}    ${user}[lastName], ${user}[firstName]
    ${associate_store_name_locator}    Get Locator Contains    ${associate_name}
    Wait Until Element Is Visible    ${associate_store_name_locator}
    ${job_code_locator}    Get Locator Contains    ${Job_Code}
    Wait Until Element Is Visible    ${job_code_locator}
    ${localised_semantic_unit_name_label}    Get Localised Locator Contains    ${commonUnitNameLabel}
    Wait Until Element Is Visible    ${localised_semantic_unit_name_label}
    ${username}    Get Unit Display Text    ${User_Key}
    ${unit_name_locator}    Get Locator Contains    ${username}
    Wait Until Element Is Visible    ${unit_name_locator}
    ${localised_semantic_department_name_label}    Get Localised Locator Contains    ${commonDepartmentNameLabel}
    Wait Until Element Is Visible    ${localised_semantic_department_name_label}
    ${unit_name_locator}    Get Locator Contains    ${Department_name}
    Wait Until Element Is Visible    ${unit_name_locator}

Verify New PTO Request Header Option On Home Screen On Mobile ESS
    [Documentation]    Verify new PTO request header button on mobile ESS app.
    ...    Args:
    ...    ${add_request_quick_button_enabled}: <Mobile ess add request quick button module enable status True or False based on visibility>
    [Arguments]    ${add_request_quick_button_enabled}
    ${quick_action_new_pto_request_locator}    Get Localised Locator Contains    ${quickActionNewPtoRequest}
    IF    ${add_request_quick_button_enabled}
        Wait Until Element Is Visible    ${quick_action_new_pto_request_locator}
    ELSE
        Page Should Not Contain Element    ${quick_action_new_pto_request_locator}
    END

Verify Shift Trade Header Option On Home Screen On Mobile ESS
    [Documentation]    Verify shift trade header option on mobile ESS app.
    ...    Args:
    ...    ${shift_trade_quick_button_enabled}: <Mobile ess shift trade quick button module enable status True or False based on visibility>
    [Arguments]    ${shift_trade_quick_button_enabled}
    ${quick_action_start_shift_trade_locator}    Get Localised Locator Contains    ${quickActionStartShiftTrade}
    IF    ${shift_trade_quick_button_enabled}
        Wait Until Element Is Visible    ${quick_action_start_shift_trade_locator}
    ELSE
        Page Should Not Contain Element    ${quick_action_start_shift_trade_locator}
    END

Verify Store Schedule Header Option On Home Screen On Mobile ESS
    [Documentation]    Verify store schedule header option on mobile ESS app.
    ...    Args:
    ...    ${store_schedule_quick_button_enabled}: <Mobile ess store schedule quick button module enable status True or False based on visibility>
    [Arguments]    ${store_schedule_quick_button_enabled}
    ${quick_action_store_schedule_locator}    Get Localised Locator Contains    ${quickActionStoreSchedule}
    IF    ${store_schedule_quick_button_enabled}
        Wait Until Element Is Visible    ${quick_action_store_schedule_locator}
    ELSE
        Page Should Not Contain Element    ${quick_action_store_schedule_locator}
    END

Verify Time Off Balance Label On Home Screen On Mobile ESS
    [Documentation]    Used for verifying leave balance header on home screen on mobile ESS app.
    ${time_off_balance_text}    Get Localised Message From Key    ${homeTimeOffBalance}
    ${time_off_balance_text_upper}    Convert To Upper Case    ${time_off_balance_text}
    ${title_time_Off_balance_locator}    Get Locator Exact    ${time_off_balance_text_upper}
    Swipe Until Visible    ${title_time_Off_balance_locator}

Verify Time Off Balance Total Hours For Reason On Home Screen On Mobile ESS
    [Documentation]    Used for verifying leave balance displayed on home screen on mobile ESS app.
    ...    Args:
    ...    ${leave_reason}: <Leave Reason>
    ...    ${total_hours}: <Total hours for the leave reason>
    [Arguments]    ${leave_reason}    ${total_hours}=8.0
    VAR    ${total_hours_with_reason}    ${leave_reason}
    ${balance_total_hrs_locator}    Get Locator Contains    ${total_hours_with_reason}
    Swipe Until Visible    ${balance_total_hrs_locator}
    Wait Until Page Contains Element    ${balance_total_hrs_locator}

Verify Home Menu Option Visible On Home Screen On Mobile ESS
    [Documentation]    Used for verifying home menu options visible on home screen on mobile ESS app.
    ...    Args:
    ...    ${is_visible}: <True if menu option is expected to be visible, False if not expected to be visible>
    [Arguments]    ${is_visible}
    Verify Menu Option Visible On Home Screen On Mobile ESS    ${HomeTabLabel}    ${is_visible}

Verify Schedule Menu Option Visible On Home Screen On Mobile ESS
    [Documentation]    Used for verifying schedule menu options visible on home screen on mobile ESS app.
    ...    Args:
    ...    ${is_visible}: <True if menu option is expected to be visible, False if not expected to be visible>
    [Arguments]    ${is_visible}
    Verify Menu Option Visible On Home Screen On Mobile ESS    ${ScheduleButtonLabel}    ${is_visible}

Verify Requests Menu Option Visible On Home Screen On Mobile ESS
    [Documentation]    Used for verifying requests menu options visible on home screen on mobile ESS app.
    ...    Args:
    ...    ${is_visible}: <True if menu option is expected to be visible, False if not expected to be visible>
    [Arguments]    ${is_visible}
    Verify Menu Option Visible On Home Screen On Mobile ESS    ${RequestButtonLabel}    ${is_visible}

Verify More Menu Option Visible On Home Screen On Mobile ESS
    [Documentation]    Used for verifying more menu options visible on home screen on mobile ESS app.
    ...    Args:
    ...    ${is_visible}: <True if menu option is expected to be visible, False if not expected to be visible>
    [Arguments]    ${is_visible}
    Verify Menu Option Visible On Home Screen On Mobile ESS    ${MoreTabLabel}    ${is_visible}

Verify Menu Option Visible On Home Screen On Mobile ESS
    [Documentation]    Used for verifying menu options visible on home screen on mobile ESS app.
    ...    Args:
    ...    ${menu_option}: <Menu option to be verified>
    ...    ${is_visible}: <True if menu option is expected to be visible, False if not expected to be visible>
    [Arguments]    ${menu_option}    ${is_visible}
    ${menu_option_locator}    Get Localised Locator Contains    ${menu_option}
    IF    ${is_visible}
        Swipe Until Visible    ${menu_option_locator}
        Wait Until Page Contains Element    ${menu_option_locator}
    ELSE
        Page Should Not Contain Element    ${menu_option_locator}
    END

Verify At Least One Shortcut Visible On Home Screen On Mobile ESS
    [Documentation]    Used for verifying at least one shortcut (Availability, Store Schedule, Profile) is visible on home screen on mobile ESS app.
    Verify Mobile ESS Home Shortcut Header
    ${availability_shortcut_locator}    Get Localised Locator Contains    ${AvailabilityButtonLabel}
    ${store_schedule_shortcut_locator}    Get Localised Locator Contains    ${StoreScheduleButtonLabel}
    ${profile_shortcut_locator}    Get Localised Locator Contains    ${ProfileButtonLabel}
    Swipe Until Visible    ${profile_shortcut_locator}
    ${is_availability_shortcut_visible}    Is Element Present On Mobile    ${availability_shortcut_locator}    timeout=${MEDIUM_TIMEOUT}    interval=2s
    ${is_store_schedule_shortcut_visible}    Is Element Present On Mobile    ${store_schedule_shortcut_locator}    timeout=${MEDIUM_TIMEOUT}    interval=2s
    ${is_profile_shortcut_visible}     Is Element Present On Mobile    ${profile_shortcut_locator}    timeout=${MEDIUM_TIMEOUT}    interval=2s
    IF    not ${is_availability_shortcut_visible} and not ${is_store_schedule_shortcut_visible} and not ${is_profile_shortcut_visible}
        Fail    At least one shortcut is expected to be visible on home screen of mobile ESS app, but none of the shortcuts are visible.
    END

Verify Shift Present For Associate On Home Screen On Mobile ESS
    [Documentation]    Used for verifying shift present for associate on home screen on mobile ESS app and return value true or false.
    ...    Args:
    ...    ${shift_day}: <shift day>
    ...    ${max_swipes}: <maximum number of swipes to find the shift>
    [Arguments]    ${shift_day}    ${max_swipes}=3
    ${shift_date_format}    Get Config Value    DATE_FMT_ABBR_WEEKDAY_MONTH_DAY
    ${target_day}    Calculate Date From Week Day Offset    ${shift_day}    ${shift_date_format}
    ${shift_block_message}    Get Localised Message From Key    ${home_shift_locator}
    @{shift_block_message_parts}    Split String    ${shift_block_message}
    VAR    ${shift_block}    ${shift_block_message_parts}[0] ${shift_block_message_parts}[1]
    ${shift_block_locator}    Get Locator Contains    ${shift_block}
    Swipe Until Visible    ${shift_block_locator}    direction="up"
    ${actual_shift_locator}    Get Locator Contains    ${target_day}
    VAR    ${is_specific_shift_visible}    ${False}
    FOR    ${_}    IN RANGE    ${max_swipes}
        ${is_specific_shift_visible}    Is Element Present On Mobile    ${actual_shift_locator}    timeout=${MEDIUM_TIMEOUT}    interval=1s
        IF    ${is_specific_shift_visible}    BREAK
        Swipe Right On Element    ${shift_block_locator}
    END
    RETURN    ${is_specific_shift_visible}

Verify At Least Two Top Options Visible On Home Screen On Mobile ESS
    [Documentation]    Used for verifying at least two top options (New PTO Request, Start Shift trade, Store Schedule) are visible on home screen on mobile ESS app.
    ${quick_action_new_pto_request_locator}    Get Localised Locator Contains    ${quickActionNewPtoRequest}
    ${quick_action_start_shift_trade_locator}    Get Localised Locator Contains    ${quickActionStartShiftTrade}
    ${quick_action_store_schedule_locator}    Get Localised Locator Contains    ${quickActionStoreSchedule}
    ${is_new_pto_request_visible}    Is Element Present On Mobile    ${quick_action_new_pto_request_locator}    timeout=${MEDIUM_TIMEOUT}    interval=2s
    ${is_start_shift_trade_visible}    Is Element Present On Mobile    ${quick_action_start_shift_trade_locator}    timeout=${MEDIUM_TIMEOUT}    interval=2s
    ${is_store_schedule_visible}    Is Element Present On Mobile    ${quick_action_store_schedule_locator}    timeout=${MEDIUM_TIMEOUT}    interval=2s
    ${visible_count}    Evaluate    int(${is_new_pto_request_visible}) + int(${is_start_shift_trade_visible}) + int(${is_store_schedule_visible})
    IF    ${visible_count} < 2
        Fail    At least 2 shortcuts are expected to be visible on home screen of mobile ESS app, but only ${visible_count} shortcut(s) are visible.
    END

Verify Clock In Visible On Home Screen On Mobile ESS
    [Documentation]    Used for verifying clock in option is visible on home screen on mobile ESS app.
    ${clock_in_locator}    Get Localised Locator Contains    ${clock_in}
    Swipe Until Visible    ${clock_in_locator}
    Wait Until Element Is Visible     ${clock_in_locator}

Swipe Until Time Clock Label Visible On Home Screen On Mobile ESS
    [Documentation]
    ...    Swipes the home feed until the given time-clock action label is visible,
    ...    then waits for that element.
    ...    | =Arguments= | =Description= |
    ...    | time_clock_message_key | Localisation key constant from ``Clock.py`` for the clock action label. |
    ...    Example usage:
    ...    | Swipe Until Time Clock Label Visible On Home Screen On Mobile ESS | ${take_meal} |
    [Arguments]    ${time_clock_message_key}
    ${time_clock_locator}    Get Localised Locator Contains    ${time_clock_message_key}
    Swipe Until Visible    ${time_clock_locator}
    Wait Until Element Is Visible    ${time_clock_locator}

Wait Until Shift Started Message Visible On Home Screen On Mobile ESS
    [Documentation]
    ...    Waits until the home ``Shift Start: {time}`` reminder is visible after clock-in.
    ...    | =Arguments= | =Description= |
    ...    | clock_in_time | Punch timestamp from ``Get Today Date With Timezone`` (``DATE_FORMAT_YYMMDDHHMM``). |
    ...    Example usage:
    ...    | Wait Until Shift Started Message Visible On Home Screen On Mobile ESS | ${clock_in_time} |
    [Arguments]    ${clock_in_time}
    ${24_hr_time}    Convert Punch Timestamp To 24 Hour Time    ${clock_in_time}
    ${formatted_clock_in_time}    Format Time String    ${24_hr_time}
    ${formatted_clock_in_time}    Evaluate    __import__('re').sub(r'^0(?=\d:)', '', '${formatted_clock_in_time}')    modules=re
    ${shift_started_locator}    Get Localised Locator Contains    ${shift_started}    ${formatted_clock_in_time}
    Wait Until Element Is Visible    ${shift_started_locator}

Clock In From Home Screen On Mobile ESS
    [Documentation]
    ...    Swipes to clock-in on the home screen, completes clock-in (activity and questionnaire as needed),
    ...    then waits for the home shift-started reminder instead of the clock-module break-ready header.
    ...    Returns the clock-in timestamp used for the shift-start message.
    ...    | =Arguments= | =Description= |
    ...    | activity_code | Activity code when required for the transaction. |
    ...    | questionnaire | Comma-separated questionnaire answers when required. |
    ...    | unit_id | Store unit id for timezone when capturing clock-in time. |
    ...    Example usage:
    ...    | ${clock_in_time} | Clock In From Home Screen On Mobile ESS | activity_code=${data}[code] | questionnaire=${data}[q] | unit_id=${user}[unitID] |
    [Arguments]    ${activity_code}=''    ${questionnaire}=''    ${unit_id}=${EMPTY}
    Verify Clock In Visible On Home Screen On Mobile ESS
    Perform Transaction On Mobile ESS    ${clock_in}    ${activity_code}    ${questionnaire}
    ${timestamp_format}    Get Config Value    DATE_FORMAT_YYMMDDHHMM
    ${clock_in_time}    Get Today Date With Timezone    ${timestamp_format}    ${unit_id}
    Wait Until Shift Started Message Visible On Home Screen On Mobile ESS    ${clock_in_time}
    RETURN    ${clock_in_time}

Wait Until End Meal Visible On Home Screen On Mobile ESS
    [Documentation]
    ...    Waits until the end-meal time-clock action is visible on the home screen after take meal.
    ${end_meal_locator}    Get Localised Locator Contains    ${end_meal}
    Wait Until Element Is Visible    ${end_meal_locator}

Wait Until Take Meal Visible On Home Screen On Mobile ESS
    [Documentation]
    ...    Waits until the take-meal time-clock action is visible on the home screen after end meal.
    ${take_meal_locator}    Get Localised Locator Contains    ${take_meal}
    Wait Until Element Is Visible    ${take_meal_locator}

Take Meal From Home Screen On Mobile ESS
    [Documentation]
    ...    Swipes to take-meal on the home screen, completes take meal, then waits for end-meal on the home feed.
    ...    Example usage:
    ...    | Take Meal From Home Screen On Mobile ESS |
    Swipe Until Time Clock Label Visible On Home Screen On Mobile ESS    ${take_meal}
    Perform Transaction On Mobile ESS    ${take_meal}
    Wait Until End Meal Visible On Home Screen On Mobile ESS

Meal End From Home Screen On Mobile ESS
    [Documentation]
    ...    Swipes to end-meal on the home screen, completes end meal including activity/questionnaire handling,
    ...    then waits for take-meal on the home feed.
    ...    | =Arguments= | =Description= |
    ...    | activity_code | Activity code when required for the transaction. |
    ...    | questionnaire | Comma-separated questionnaire answers when required. |
    ...    Example usage:
    ...    | Meal End From Home Screen On Mobile ESS | activity_code=${data}[code] | questionnaire=${data}[q] |
    [Arguments]    ${activity_code}=''    ${questionnaire}=''
    Perform Transaction On Mobile ESS    ${end_meal}    ${activity_code}    ${questionnaire}
    Wait Until Take Meal Visible On Home Screen On Mobile ESS

Take Break From Home Screen On Mobile ESS
    [Documentation]
    ...    Swipes to take-break on the home screen, then starts break (same as clock module confirmation flow).
    ...    | =Arguments= | =Description= |
    ...    | questionnaire | Questionnaire answers for take-break when required. |
    [Arguments]    ${questionnaire}=''
    Swipe Until Time Clock Label Visible On Home Screen On Mobile ESS    ${take_break}
    Take Break On Mobile ESS    questionnaire=${questionnaire}

Break End From Home Screen On Mobile ESS
    [Documentation]
    ...    Swipes to end-break on the home screen, then completes break end including activity/questionnaire handling.
    ...    | =Arguments= | =Description= |
    ...    | activity_code | Activity code when required for the transaction. |
    ...    | questionnaire | Comma-separated questionnaire answers when required. |
    [Arguments]    ${activity_code}=''    ${questionnaire}=''
    Swipe Until Time Clock Label Visible On Home Screen On Mobile ESS    ${end_break}
    Break End On Mobile ESS    ${activity_code}    ${questionnaire}

Tap Clock More Options On Home Screen On Mobile ESS
    [Documentation]
    ...    Swipes until clock more-options is visible on the home screen, then taps it so the app opens the clock screen.
    Swipe Until Time Clock Label Visible On Home Screen On Mobile ESS    ${clock_more_option}
    Tap Clock More Options On Mobile ESS

Wait Until Clock Out Visible On Clock Screen On Mobile ESS
    [Documentation]
    ...    Waits for clock-out on the clock screen after More options navigates away from home (no swipe needed).
    ${clock_out_locator}    Get Localised Locator Contains    ${clock_out}
    Wait Until Element Is Visible    ${clock_out_locator}

Complete Clock Out From Home Screen On Mobile ESS
    [Documentation]
    ...    Opens more options from home (navigates to clock screen), waits for clock-out, then completes clock-out with
    ...    ``Perform Transaction On Mobile ESS`` only (no two-step tap flow, no clocked-out/dismiss handling on this path).
    ...    Caller should apply rounding-policy sleep afterward if needed.
    ...    | =Arguments= | =Description= |
    ...    | questionnaire | Comma-separated questionnaire answers when required for clock-out; use ``''`` if none. |
    ...    Example usage:
    ...    | Complete Clock Out From Home Screen On Mobile ESS | questionnaire=${data}[clock_in_questionnaire] |
    ...    Then call ``Sleep`` with the suite rounding duration (e.g. ``${ROUNDING_POLICY}s``).
    [Arguments]    ${questionnaire}=''
    Tap Clock More Options On Home Screen On Mobile ESS
    Wait Until Clock Out Visible On Clock Screen On Mobile ESS
    Perform Transaction On Mobile ESS    ${clock_out}    questionnaire=${questionnaire}
