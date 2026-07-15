*** Settings ***
Documentation       Test case for verifying Add/Edit/Delete Availability On SM Request Calendar

Resource            resources/web/rws/employee/request_calendar.resource
Resource            resources/Mobile/ESS/PagesResources/Availability_Module/Availability_Teardown.resource

Test Teardown       Run Keywords
...                     Verify Permanent Availability Requests For Multiple Dates    AND
...                     Close Browser

Test Tags           dev:yogesh    action:write    battc00038    config:add_edit_delete_availability_request_sm    bat_phase1    om_hr


*** Test Cases ***
BATTC00038: Verify add/edit/delete availability in SM Request Calendar
    [Documentation]    Test case for verifying Add/Edit/Delete Availability On SM Request Calendar
    ${ess_user_5}    Get User    user_key=ESS5_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Clean Up Permanent Availability Request    ESS5_STORE1    SM1_STORE1    9_0
    Navigate To RWS Employee Request Calendar Page On Web
    ${availability_data}    Get Availability Data
    ...  start_date=9_0
    Select Day On Request Calendar Page    ${availability_data}[start_date]
    ${status_text}    Create SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_5}[displayName]
    ...    ${availability_data}[request_preference]    ${availability_data}[start_date]    ${availability_data}[reason]
    ...    ${availability_data}[rotation_number]    ${availability_data}[days_availability_hours]
    ...    ${availability_data}[split_availability_row_number]    ${availability_data}[availability_rotation_number]
    IF    '${status_text}' == 'Not Reviewed'
        Verify SM Availability Request On Request Calendar Page On Web    ${ess_user_5}[displayName]
        ...    ${availability_data}[start_date]    ${availability_data}[request_preference]    ${availability_data}[status]
        ${edit_availability_list_data}    Get Availability Data    template_name=edit_availability
        Edit SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_5}[displayName]
        ...    ${availability_data}[start_date]    ${availability_data}[request_preference]    ${availability_data}[status]
        ...    ${edit_availability_list_data}[days_availability_hours]    ${edit_availability_list_data}[split_availability_row_number]
        ...    ${availability_data}[rotation_number]
    END
    Select Day On Request Calendar Page    ${availability_data}[start_date]
    Delete SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_5}[displayName]
    ...    ${availability_data}[start_date]    ${availability_data}[request_preference]    ${status_text}

    ${number_of_rotations}    Get Config Value    ROTATIONS_FOR_AVAILABILITY_REQUEST
    IF    ${number_of_rotations} > 1
        ${rotation_availability_data_1}    Get Availability Data    template_name=add_availability_rotation_1
        Select Day On Request Calendar Page    ${rotation_availability_data_1}[start_date]
        Fill Availability Request Form On Request Calendar Page On Web    ${ess_user_5}[displayName]
        ...    ${availability_data}[request_preference]    ${rotation_availability_data_1}[start_date]
        ...    ${availability_data}[reason]    ${number_of_rotations}
        ...    ${rotation_availability_data_1}[days_availability_hours]    ${availability_data}[split_availability_row_number]
        ...    ${rotation_availability_data_1}[availability_rotation_number]
        ${rotation_availability_data_2}    Get Availability Data    template_name=add_availability_rotation_2
        Add Availability Hours On Request Calendar Page On Web    ${rotation_availability_data_2}[days_availability_hours]
        ...    ${availability_data}[split_availability_row_number]    ${rotation_availability_data_2}[availability_rotation_number]
        Submit Availability Request On Request Calendar Page On Web And Verify API Response
        Select Day On Request Calendar Page    ${rotation_availability_data_1}[start_date]
        Delete SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_5}[displayName]
        ...    ${rotation_availability_data_1}[start_date]    ${availability_data}[request_preference]    ${availability_data}[status]
    END
    Log Out From Web Application


*** Keywords ***
Verify Permanent Availability Requests For Multiple Dates
    [Documentation]    Test case for verifying Permanent availability requests with approved status for multiple start dates
    ${ess_user_5}    Get User    user_key=ESS5_STORE1
    Login And Launch WFM Web App    user_key=SM1_STORE1
    Navigate To RWS Employee Request Calendar Page On Web
    FOR    ${start_date}    IN    5_0    6_0    7_0    8_0    9_0
        ${availability_data}    Get Availability Data    template_name=availability_fully_available    start_date=${start_date}
        Select Day On Request Calendar Page    ${availability_data}[start_date]
        ${status_text}    Create SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_5}[displayName]
        ...    ${availability_data}[request_preference]    ${availability_data}[start_date]    ${availability_data}[reason]
        ...    ${availability_data}[rotation_number]    ${availability_data}[days_availability_hours]
        ...    ${availability_data}[split_availability_row_number]    ${availability_data}[availability_rotation_number]
        ${edit_availability_data}    Get Availability Data    template_name=availability_fully_available    start_date=${start_date}    status=RequestStatus.APPROVED
        IF    '${status_text}' == 'Not Reviewed'
            Verify SM Availability Request On Request Calendar Page On Web    ${ess_user_5}[displayName]
            ...    ${availability_data}[start_date]    ${availability_data}[request_preference]    ${availability_data}[status]
            Edit Status On SM Availability Request On Request Calendar Page On Web And Verify API Response    ${ess_user_5}[displayName]
            ...    ${availability_data}[start_date]    ${availability_data}[request_preference]    ${availability_data}[status]
            ...    ${edit_availability_data}[status]
        END
    END
    Log Out From Web Application
