*** Settings ***
Documentation       Examples demonstrating template reference resolution in data provider
...
...                 This test file shows how to use the new template reference feature
...                 that automatically resolves template references from other entities.

Library             test_data/TestDataLibrary.py

Test Tags           examples    data_provider    template_references


*** Test Cases ***
Example 1: Basic Shift Pattern Usage
    [Documentation]    Demonstrates getting shift pattern data directly

    # Get a standard 9-hour shift pattern
    ${shift_pattern}=    Get Shift Time Pattern Data    template_name=standard_9hr
    Log    Shift Pattern: ${shift_pattern}
    Should Be Equal As Numbers    ${shift_pattern}[startTime]    480
    Should Be Equal As Numbers    ${shift_pattern}[duration]    540

Example 2: Employee Assignment With Automatic Template Resolution
    [Documentation]    Shows automatic resolution of shift_pattern references
    ...    The shift_pattern field is automatically replaced with actual startTime and duration

    # Get employee assignment - shift patterns are automatically resolved
    ${employee}=    Get Employee Shift Setup Data    template_name=add012_standard9

    Log    Employee Assignment (resolved): ${employee}
    Log    First Shift: ${employee}[shifts_to_add][0]

    # Verify the shift_pattern was resolved to actual values
    Should Not Contain    ${employee}[shifts_to_add][0]    shift_pattern
    Should Contain    ${employee}[shifts_to_add][0]    startTime
    Should Contain    ${employee}[shifts_to_add][0]    duration

    # Verify the resolved values are correct (standard_9hr)
    Should Be Equal As Numbers    ${employee}[shifts_to_add][0][startTime]    480
    Should Be Equal As Numbers    ${employee}[shifts_to_add][0][duration]    540

Example 4: Override Template Reference
    [Documentation]    Shows how to override with custom values while still using templates

    # Get employee with custom shift timing override
    ${employee}=    Get Employee Shift Setup Data
    ...    template_name=add012_standard9
    ...    shifts_to_add=${{[{"dayNo": "0", "shift_pattern": "standard_9hr"}]}}

    Log    Employee with override: ${employee}

    # Verify the overridden shift uses the early shift pattern
    Should Be Equal As Numbers    ${employee}[shifts_to_add][0][startTime]    480
    Should Be Equal As Numbers    ${employee}[shifts_to_add][0][duration]    540
    ${employee2}=    Get Employee Shift Setup Data
    ...    template_name=add012_standard9
    ...    shifts_to_add=${{[{"dayNo": "0", "startTime": 600, "duration": 300}]}}

    Log    Employee with override: ${employee2}

Example 5: Mix Template References and Direct Values
    [Documentation]    Shows mixing template references with direct values in the same structure

    # Create employee with mixed approach - some shifts use templates, some have direct values
    ${employee}=    Get Employee Shift Setup Data
    ...    shifts_to_add=${{[{"dayNo": "0", "shift_pattern": "standard_9hr"},{"dayNo": "1", "startTime": 600, "duration": 300}]}}

    Log    Mixed assignment: ${employee}

    # First shift should be resolved from template
    Should Be Equal As Numbers    ${employee}[shifts_to_add][0][startTime]    480

    # Second shift should have direct values
    Should Be Equal As Numbers    ${employee}[shifts_to_add][1][startTime]    600

Example 6: List Available Entities And Templates
    [Documentation]    Demonstrates discovery of entities and their templates

    ${entities}=    Get Available Entities
    Log    Available entities: ${entities}
    Should Contain    ${entities}    shift_time_pattern
    Should Contain    ${entities}    employee_shift_setup

    ${shift_templates}=    Get Entity Templates    shift_time_pattern
    Log    Shift pattern templates: ${shift_templates}
    Should Contain    ${shift_templates}    standard_9hr
    Should Contain    ${shift_templates}    standard_8hr

    ${employee_templates}=    Get Entity Templates    employee_shift_setup
    Log    Employee assignment templates: ${employee_templates}
    Should Contain    ${employee_templates}    addtoday_standard8


*** Keywords ***
Verify Shifts Are Resolved
    [Documentation]    Helper keyword to verify shifts have resolved values
    [Arguments]    ${shifts_list}

    FOR    ${shift}    IN    @{shifts_list}
        Should Contain    ${shift}    startTime
        Should Contain    ${shift}    duration
        Should Not Contain    ${shift}    shift_pattern
    END
