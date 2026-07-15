*** Settings ***
Documentation       Example test demonstrating the simplified auto-discovery data provider

Library             test_data/TestDataLibrary.py


*** Test Cases ***
Test Auto-Discovery Data Provider
    [Documentation]    Demonstrates how easy it is to use the new generic data provider

    # Get list of all available entities
    ${entities}=    Get Available Entities
    Log    Available entities: ${entities}

    # Test the shift entity (auto-discovered)
    ${shift_data}=    Get Shift Data
    Log    Default shift data: ${shift_data}
    Should Not Be Empty    ${shift_data}[task_name]
    Should Not Be Empty    ${shift_data}[status]

    # Test with template override
    ${morning_shift}=    Get Shift Data    template_name=morning_shift
    Log    Morning shift data: ${morning_shift}
    Should Be Equal    ${morning_shift}[start_time]    06:00

    # Test with direct overrides
    ${custom_shift}=    Get Shift Data
    ...    template_name=evening_shift
    ...    employee_id=EMP12345
    ...    location=STORE_002
    ...    notes=Custom evening shift
    Log    Custom shift data: ${custom_shift}
    Should Be Equal    ${custom_shift}[employee_id]    EMP12345
    Should Be Equal    ${custom_shift}[location]    STORE_002

    # Test generic method (works for any entity)
    ${generic_shift}=    Get Generic Entity Data    shift    template_name=weekend_shift
    Log    Generic shift data: ${generic_shift}

    ${payroll_data}=    Get Payroll Data
    Log    Payroll data: ${payroll_data}

Test Entity Templates
    [Documentation]    Test getting available templates for entities

    # Get available templates for shift entity
    ${shift_templates}=    Get Entity Templates    shift
    Log    Shift templates: ${shift_templates}
    Should Not Be Empty    ${shift_templates}

Test Day Off Provider Still Works
    [Documentation]    Ensure backward compatibility with existing providers

    ${day_off_data}=    Get Day Off Data    template_name=approval_scenario
    Log    Day off data: ${day_off_data}
    Should Not Be Empty    ${day_off_data}[reason]
