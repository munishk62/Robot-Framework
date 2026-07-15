# Data Provider Strategy for Robot Test Cases

## Introduction

This document outlines our test data provider strategy for Robot Framework test cases

## 🚀 NEW: Simplified Auto-Discovery Provider

**For new entities, use the simplified approach that requires ZERO coding!**
```
We received feedback that the previous approach was too complex for testers. The new **Generic Data Provider** eliminates the need for testers to write Python code when adding new test data entities. The system automatically discovers entities and creates Robot Framework keywords dynamically.
```
See [SIMPLIFIED_DATA_PROVIDER_GUIDE.md](SIMPLIFIED_DATA_PROVIDER_GUIDE.md) for complete documentation.

## OLD: Domain-Specific Python based Data Providers with External JSON Data

After evaluating different approaches, we've implemented a hybrid solution that combines the best aspects of each approach. Our solution uses domain-specific data providers written in Python that load data from external JSON files.

### Core Components

1. **Base Provider Class**: A foundational class that handles common operations like loading templates and resolving constants.
2. **Domain-Specific Providers**: Specialized classes for each domain (day_off, time_off, shifts etc.) with domain-specific logic.
3. **JSON Templates**: External JSON files for base templates and test-specific overrides.
4. **Environment-Specific Value Resolution**: System to resolve logical constants to environment-specific values.

### Directory Structure

```
test_data/
├── constants/                  # Constants and enums
│   ├── date_helper.py          # Date utility functions
│   └── ...                     # Any other utility functions
├── providers/                  # Data provider classes
│   ├── base_provider.py        # Base provider with common functionality
│   ├── day_off_provider.py     # Day off request provider. These have specific logic for day off requests
│   ├── time_off_provider.py    # Time off request provider
│   └── ...
├── templates/                   # JSON templates for each domain
│   ├── day_off/
│   │   ├── base_templates.json # Base templates for day off
│   │   └── overrides/          # Test-specific overrides
│   │       ├── TC34038.json    # Override for specific test
│   │       └── ...
│   ├── time_off/
│   │   ├── base_templates.json
│   │   └── overrides/
└── TestDataLibrary.py           # Unified library for Robot Framework
```

### How It Works

1. **Template Layer**: Base templates define default values for each domain entity.
2. **Test-Specific Overrides**: Test-specific JSON files override base template values.
3. **Provider Classes**: Python providers load and process the JSON data, resolving placeholders and logical constants.
4. **Robot Framework Keywords**: Exposed as keywords for use in Robot Framework tests.

## The Template and Override System

Our data provider system uses a multi-layered approach to test data management:

### Base Templates

Each domain has a `base_templates.json` file that defines the default templates for that domain. For example, the day off domain might have templates for different scenarios:

```json
{
  "default": {
    "start_date": "1_1",
    "end_date": "1_1",
    "reason": "DayOffReasonType.UNPAID_DAY_OFF",
    "notes": "Automated test case",
    "status": "RequestStatus.NOT_REVIEWED"
  },
  "approval_scenario": {
    "start_date": "1_2",
    "end_date": "1_2",
    "reason": "DayOffReasonType.PAID_VACATION",
    "notes": "Approval scenario automated test",
    "expected_status_after_approval": "RequestStatus.APPROVED"
  }
}
```

### Test-Specific Overrides

Can be done in two ways:
1. For test cases that need customized data, we create test-specific override files in the `overrides` directory. For example, for test case TC34038:

```TC34038.json
{
  "start_date": "2_3",
  "end_date": "2_4"
}
```
You also need to include the test caseid in the provider function call to load this specific override. 
```robotframework
${day_off_data}=    Get Day Off Data  test_id=TC34038
```
Note: In the above provider, since no template_name is provided, it will use the default template. If you want to use a specific template, you can provide it as well:
```robotframework 
${day_off_data}=    Get Day Off Data  template_name=approval_scenario  test_id=TC34038
```
This will override just the `start_date` and `end_date` fields from the base template, keeping all other fields unchanged.

2. Override directly in the test case using the provider function. For example, in a Robot Framework test case, you can pass overrides directly:

```robotframework
${day_off_data}=    Get Day Off Data  start_date=2_4  end_date=2_5
```

**Our Recommendation**: Use test specific overrides directly in the test case (*.robot file) rather than the JSON file. This makes it easier to read and maintain the test case.

### Environment-Specific Values

Logical constants like `DayOffReasonType.UNPAID_DAY_OFF` are resolved to environment-specific values at runtime. This allows us to handle differences between environments (QA28, QA29, STAGING, etc.) without changing the test data.

### Override Process Flow

1. Start with the base template (e.g., "default" or a named template)
2. Apply environment-specific overrides if available
3. Apply test-specific overrides if a test ID is provided
4. Apply direct overrides passed as arguments to the provider function
5. Process placeholders (e.g., relative dates)
6. Resolve logical constants to environment-specific values

## Usage in Robot Framework Tests

Here's how to use the data providers in your test cases:

```robotframework
*** Settings ***
Library    test_data/TestDataLibrary.py

*** Test Cases ***
Create Day Off Request
    # Get user data
    ${sm_user}=    Get User    user_key=SM1_STORE1
    ${ess_user}=   Get User    user_key=ESS1_STORE1
    
    # Get day off data with overrides
    ${day_off_data}=    Get Day Off Data    
    ...    test_id=TC34038    # Optional test-specific data
    ...    start_date=2_4     # Direct override
    ...    end_date=2_4       # Direct override
    
    # Use the data in the test
    Login To WFM Using Provider    ${sm_user}[user_key]
    Navigate To RWS Employee Request Calendar Page On Web
    Select Day On Request Calendar Page    ${day_off_data}[start_date]
    ${created_day_off}=    SM Creates Day Off Request Using Provider And Verify API Success
    ...    ${ess_user}[displayName]
    ...    ${day_off_data}
```

## Best Practices

1. **Create Domain-Specific Templates**: Organize templates by domain (day_off, time_off, users, etc.)
2. **Use Logical Constants**: Reference constants like `RequestStatus.APPROVED` instead of hard-coding values
3. **Prefer Test-Specific Override In test case**: For test-specific data, add override directly in the test case rather than creating a separate JSON file
4. **Add Documentation**: Document the purpose of each template and override

## Benefits of Our Approach

1. **Separation of Concerns**: Clear separation between test logic and test data
2. **Reusability**: Templates can be reused across multiple tests
3. **Maintainability**: Changes to data structures only need to be made in one place
4. **Readability**: Tests focus on behavior, not data setup
5. **Flexibility**: Multiple layers of overrides provide flexibility for different testing scenarios
6. **Environment Support**: Logical constants are resolved to environment-specific values


## Comparison with Other Approaches

In this section, we will compare different approaches to test data management, and provide guidance on when to use each approach.

## Test Data Management Approaches

### CSV-Based Static Variable Files

CSV files provide a simple tabular format for storing test data that can be easily edited by team members, even those without programming experience.

#### Advantages of CSV Format:

1. **Accessibility**: Non-technical team members can view and edit CSV files using spreadsheet applications.
2. **Tabular Structure**: Natural fit for representing related test data in rows and columns.
3. **Simple Parsing**: CSV files can be easily imported into most programming languages.
4. **Version Control Friendly**: Plain text format works well with version control systems.

#### Limitations of CSV Format:

1. **Limited Structure**: Difficult to represent hierarchical data or complex relationships.
2. **Data Typing Issues**: All values are typically stored as strings, requiring additional parsing.
3. **No Inheritance**: Hard to implement template-based inheritance patterns.
4. **Limited Validation**: No built-in schema validation.

### JSON-Based Data Templates

JSON files provide a more structured approach to storing test data with support for hierarchical relationships and complex data types.

#### Advantages of JSON Format:

1. **Hierarchical Structure**: Natural fit for representing nested data structures.
2. **Native Data Types**: Support for numbers, booleans, arrays, null values, and strings.
3. **Template System**: Easy to implement base templates with overrides.
4. **Readability**: Format is human-readable while still being machine-parseable.
5. **Schema Validation**: Can be validated against JSON schema.

#### Limitations of JSON Format:

1. **More Complex**: Less approachable for non-technical team members.
2. **No Comments**: Standard JSON doesn't support comments.
3. **Verbose Syntax**: More characters required for structure compared to CSV.

### Python-Based Data Providers

Python modules provide the most flexibility for dynamic generation of test data with built-in logic and processing.

#### Advantages of Python Format:

1. **Full Programming Power**: Use conditions, loops, functions, and classes.
2. **Dynamic Data Generation**: Generate data on-the-fly based on conditions.
3. **Data Validation**: Implement robust validation and defaults.
4. **Integration**: Easy to integrate with other Python libraries and APIs.

#### Limitations of Python Format:

1. **Technical Barrier**: Requires programming knowledge to modify.
2. **Harder to Externalize**: More difficult to separate data from code.
3. **Potential Complexity**: May grow overly complex if not well-structured.

## When to Use Each Approach

- **CSV Files**: Best for large datasets with simple structures, especially when non-technical users need to edit
- **JSON Templates**: Best for hierarchical data with relationships and complex structures
- **Python Providers**: Best for dynamic data generation and complex processing logic
- **Our Hybrid Approach**: Combines the best of all approaches for most test cases

## Conclusion

Our domain-specific data provider strategy with external JSON files provides a flexible, maintainable, and readable solution for test data management. By separating test data from test logic and providing multiple layers of overrides, we can handle complex testing scenarios while keeping our tests clean and focused on behavior.

As we continue to evolve our test automation framework, this approach will scale to support thousands of test cases across multiple domains while keeping the codebase manageable and maintainable.


## Next Steps
- Auto populate configs & logical constants given an environment. Check [TEST_DATA_PROVIDER_STRATEGY.md](TEST_DATA_PROVIDER_STRATEGY.md) for details.


