# Configuration Generation Utility

## Overview

This utility generates JSON configuration files for test prerequisites by executing SQL queries against the database and converting CSV API responses to JSON format. It dynamically processes all SQL queries from Python modules and creates environment-specific JSON files in a structured directory layout for test prerequisite validation and profile permission management.

## Purpose

- **Generate JSON configuration files** from SQL database queries with dynamic discovery
- **Convert CSV profile permissions** from API responses to grouped JSON format
- **Create structured prerequisite validation** files in environment-specific directories
- **Support flexible file path management** with configurable output locations
- **Provide reusable configuration patterns** that adapt to new queries automatically
- **Enable profile-based permission management** with hierarchical JSON structure

## Files Structure

```
config_utils/
├── config_data_generator.resource                    # Core database and JSON generation keywords
├── config_data_generator_setup.robot                # Main orchestration test with dual operations
├── config_data_generator_queries.py                 # SQL query variable definitions
├── config_data_endpoints.py                         # API endpoint configuration
├── convert_profile_permissions_csv_to_json.py       # CSV to JSON conversion utility
└── (generated files) → test_data/environments/{ENV}/config_checklist/
```

## Key Components

### 1. Main Test File (`config_data_generator_setup.robot`)
**Orchestrates dual data generation operations:**
- **Database Processing**: Dynamic SQL query discovery and JSON generation
- **API Processing**: CSV profile permissions to grouped JSON conversion
- **File Path Management**: Configurable output directories with environment support
- **Error Handling**: Comprehensive logging and file overwrite management

### 2. Resource File (`config_data_generator.resource`)
**Core database and JSON processing capabilities:**
- Database connection management with automatic cleanup
- Advanced SQL parsing with alias and multi-line support
- JSON value detection and parsing within database columns
- Flexible file path handling for reusable keywords

### 3. CSV Conversion Utility (`convert_profile_permissions_csv_to_json.py`)
**Specialized CSV processing module:**
- Profile-based grouping using SYSADMIN column values
- Data normalization and empty value filtering
- Robot Framework integration with string formatting
- Comprehensive error handling and validation

### 4. Query Definitions (`config_data_generator_queries.py`)
**SQL query configuration module:**
- Parameterized query definitions with placeholder support
- Variable naming conventions for automatic discovery
- Owner ID parameterization for environment-specific data

### 5. API Configuration (`config_data_endpoints.py`)
**API endpoint definitions:**
- Profile permissions CSV endpoint configuration
- Request parameter specifications
- Authentication requirement definitions

## Prerequisites

1. **Environment Configuration**:
   - TEST_ENVIRONMENT variable via `--test-env` parameter
   - OWNER_ID configuration for SQL query parameterization
   - domainId configuration for API authentication
   - Active database connection to DB2

2. **System Dependencies**:
   - Python 3.13+ with Robot Framework 7.3.2+
   - DB2 database connectivity and credentials
   - API access with ESS2_STORE1 user authentication
   - Required packages via `uv sync`

## Usage

### Basic Execution

```bash
# Generate both database and API configuration files
python executor.py --test-env QA28_B0 config_utils/config_data_generator_setup.robot

# Include debugging visibility
python executor.py --test-env QA28_B0 config_utils/config_data_generator_setup.robot --show-browser
```

### Advanced Execution

```bash
# Validation without actual file generation
python executor.py --dry-run --test-env QA28_B0 config_utils/config_data_generator_setup.robot

# Filtered execution with specific tags
python executor.py --test-env QA28_B0 --include-tags generate_feature_configs config_utils/
```

## Output Structure

### File Locations and Naming
- **Base Path**: `test_data/environments/{TEST_ENVIRONMENT}/config_checklist/`
- **Database Files**: `{query_variable_name}.json` (lowercase conversion)
- **Profile Permissions**: `profile_permissions.json`
- **Format**: JSON with 4-space indentation for readability

### Database Query JSON Structure
```json
[
    {
        "feature_id": "FEAT001",
        "feature_name": "Advanced Feature",
        "config_data": {
            "enabled": true,
            "settings": {
                "threshold": 100,
                "mode": "automatic"
            }
        }
    }
]
```

### Profile Permissions JSON Structure
```json
{
    "DIST_SUPERVISOR": [
        {
            "TESTING1": "TESTING1",
            "MWSWA": "RWS",
            "SYSADMIN": "DIST_SUPERVISOR",
            "WALK_CATEGORY_ADD": "READ^PERMISSION",
            "enable": "enable"
        }
    ],
    "ASSOCIATE": [
        {
            "TESTING1": "TESTING1",
            "MWSWA": "PSA", 
            "SYSADMIN": "ASSOCIATE",
            "WALK_CATEGORY_ADD": "WRITE^PERMISSION",
            "enable": "disable"
        }
    ]
}
```

## Enhanced Features

### Flexible File Path Management
- **Configurable Output Directories**: Keywords accept file paths as arguments
- **Environment-Specific Organization**: Structured directory layout with config_checklist subdirectory
- **Reusable Keywords**: Path parameterization enables multiple use cases
- **Error Recovery**: File existence checking and overwrite handling

### Advanced SQL Processing
- **Dynamic Query Discovery**: Automatic detection of query variables in Python modules
- **Intelligent Column Parsing**: Multi-line SQL support with alias recognition
- **JSON Column Detection**: Embedded JSON parsing within database fields
- **Parameter Substitution**: Owner ID replacement for environment-specific queries

### Enhanced CSV Processing
- **Profile-Based Grouping**: Hierarchical JSON structure by SYSADMIN values
- **Data Cleaning**: Empty key-value pair filtering
- **Format Normalization**: Line ending standardization across platforms
- **Type Preservation**: Maintains data integrity during conversion

## Configuration Management

### Adding New SQL Queries

1. **Query Definition**:
   ```python
   # In config_data_generator_queries.py
   USER_PERMISSIONS_QUERY = """
   SELECT 
       user_id,
       permission_name,
       permission_value,
       config_json AS configuration
   FROM user_permissions 
   WHERE owner_id = '{OWNER_ID}'
   AND status = 'ACTIVE'
   """
   ```

2. **Automatic Processing**: Test discovers and processes new queries automatically
3. **Generated Output**: Creates `user_permissions_query.json` in config_checklist directory

### API Endpoint Enhancement

1. **Endpoint Configuration**:
   ```python
   # In config_data_endpoints.py
   USER_ROLES_CSV = {
       "url": "/api/user-management/roles/csv",
       "method": "POST",
       "auth_required": True,
       "params": {"domainId": "required"}
   }
   ```

2. **Test Integration**: Add keyword to process new endpoint
3. **Output Management**: Configure target file path and naming

## Error Handling and Troubleshooting

### Database Issues
- **Connection Failures**: Verify DB2 connectivity and credentials
- **Query Errors**: Check SQL syntax and parameter placeholders
- **Permission Issues**: Ensure database user has required access rights

### API Processing Issues
- **Authentication Failures**: Verify ESS2_STORE1 user credentials
- **Endpoint Accessibility**: Check API endpoint availability and parameters
- **CSV Format Issues**: Validate SYSADMIN column presence and data structure

### File System Issues
- **Directory Access**: Ensure write permissions to environment directories
- **Path Resolution**: Verify TEST_ENVIRONMENT parameter and directory existence
- **File Conflicts**: Check existing file removal and creation logging

### Configuration Issues
- **Environment Variables**: Verify --test-env parameter specification
- **Module Imports**: Check Python module paths and availability
- **Parameter Values**: Validate OWNER_ID and domainId configuration

## Integration Patterns

### Test Prerequisites Validation
```robotframework
# Import generated configuration files
Variables    test_data/environments/${TEST_ENV}/config_checklist/features.json
Variables    test_data/environments/${TEST_ENV}/config_checklist/profile_permissions.json

# Validate feature availability
${feature_enabled}    Get From Dictionary    ${FEATURE_CONFIG}[0]    enabled
Run Keyword If    not ${feature_enabled}    Skip Test    Feature not available

# Check user profile permissions
${user_permissions}    Get From Dictionary    ${PROFILE_PERMS}    ${USER_PROFILE}
Should Not Be Empty    ${user_permissions}    User profile not found
```

### Dynamic Configuration Loading
```robotframework
# Load configuration based on test requirements
${config_files}    List Files In Directory    test_data/environments/${TEST_ENV}/config_checklist/    *.json
FOR    ${config_file}    IN    @{config_files}
    ${config_name}    Get File Name    ${config_file}
    Variables    ${config_file}    # Load as test data
END
```

### Conditional Test Execution
```robotframework
# Execute tests based on configuration availability
${prereq_check}    Run Keyword And Return Status    
...    File Should Exist    test_data/environments/${TEST_ENV}/config_checklist/user_features.json

Run Keyword If    ${prereq_check}    Execute Feature Tests
...    ELSE    Log    Prerequisites not met, skipping feature tests
```

## Maintenance and Monitoring

### Regular Maintenance Tasks
1. **Query Optimization**: Review and optimize SQL queries for performance
2. **API Monitoring**: Verify endpoint availability and response formats
3. **Configuration Validation**: Check generated JSON file accuracy and completeness
4. **Environment Synchronization**: Update configuration values across environments
5. **File Cleanup**: Remove obsolete configuration files and directories

### Performance Monitoring
- **Database Query Execution Time**: Monitor SQL query performance
- **API Response Time**: Track CSV endpoint response times
- **File Generation Duration**: Measure JSON file creation performance
- **Error Rate Tracking**: Monitor failed executions and error patterns

### Quality Assurance
- **JSON Structure Validation**: Verify output format consistency
- **Data Accuracy Verification**: Compare generated data with source systems
- **Profile Permission Completeness**: Ensure all required profiles are included
- **Cross-Environment Consistency**: Validate configuration differences across environments

## Support and Documentation

### Troubleshooting Resources
1. **Execution Logs**: Detailed logging for all operations and errors
2. **Debug Mode**: Dry-run capability for validation without execution
3. **Modular Testing**: Individual keyword execution for isolated testing
4. **Configuration Verification**: Built-in validation for prerequisites

### Reference Documentation
- **Keyword Documentation**: Comprehensive documentation within resource files
- **Example Usage**: Sample implementations in test files
- **Configuration Templates**: Standard patterns for new queries and endpoints
- **Best Practices**: Guidelines for optimal usage and maintenance

### Development Support
- **Framework Integration**: Seamless integration with existing test framework
- **Extensibility**: Clear patterns for adding new functionality
- **Version Control**: Git-tracked configuration changes and enhancements
- **Code Review**: Established review processes for configuration updates
