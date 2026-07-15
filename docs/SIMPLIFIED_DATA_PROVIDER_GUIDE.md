# Simplified Auto-Discovery Test Data Provider

## Overview

The new **Generic Data Provider** eliminates the need for testers to write Python code when adding new test data entities. The system automatically discovers entities and creates Robot Framework keywords dynamically.

## How It Works

### For Testers (No Code Required!)

To add a new entity (e.g., "schedule"), you only need to:

1. **Create the entity folder structure:**
   ```
   test_data/entities/schedule/
   ├── base_templates.json     # Required: Your templates
   ├── entity_config.json      # Optional: Configuration
   └── overrides/              # Optional: Test-specific overrides
   ```

2. **Add your base templates** (`base_templates.json`):
   ```json
   {
     "default": {
       "schedule_start_date": "1_0",
       "schedule_end_date": "1_6",
       "start_time": "09:00",
       "end_time": "17:00",
       "employee_id": null,
       "status": "ScheduleStatus.ACTIVE",
       "location": "STORE_001"
     },
     "weekend": {
       "schedule_start_date": "2_0",
       "schedule_end_date": "2_6",
       "start_time": "10:00",
       "end_time": "18:00",
       "employee_id": null,
       "status": "ScheduleStatus.ACTIVE",
       "location": "STORE_001"
     }
   }
   ```
```Note
This is just a sample template and does not reflect actual business logic. Adjust the fields as needed for your entity.
```
3. **Add configuration** (optional, `entity_config.json`):
   ```json
   {
     "constant_classes": ["ScheduleStatus"],
     "date_fields": ["schedule_start_date", "schedule_end_date"],
   }
   ```
   Include date_fields if you want to use evaluated date (%Y-%m-%d) in your tests. Check the **Date Processing** section below for more details.
4. **Add Constants** (if needed):
   - Define any logical constants in your environment's `constants.json` file i.e. under `test_data/environments/{ENV_NAME}/constants.json`:
   ```json
   {
     "ScheduleStatus": {
       "ACTIVE": "Active",
       "CANCELED": "Canceled"
     }
   }
   ```

5. **Use the keyword in your Robot tests:**
   ```robotframework
   *** Settings ***
   Library     /test_data/TestDataLibrary.py

   *** Test Cases ***
   Create Schedule Test
       ${schedule_data}=    Get Schedule Data    
       ...    template_name=weekend
       ...    employee_id=12345
       ...    start_time=08:00
       
       # Use ${schedule_data} in your test...
   ```

**That's it!** The system automatically:
- Discovers your new entity
- Creates the `Get Schedule Data` keyword
- Handles template loading, overrides, and constant resolution

## Entity Configuration Options

### entity_config.json (Optional)

```json
{
  "constant_classes": ["ScheduleStatus", "TaskName"],
  "date_fields": ["start_date", "end_date", "schedule_date"],
  "time_fields": ["startTime", "endTime"],
  "template_references": {
    "shift_pattern": "shift_pattern",
    "task_template": "task"
  },
  "required_processing": ["validation", "location_lookup"],
  "description": "Configuration for schedule entity",
  "version": "1.0"
}
```

**Fields:**
- `constant_classes`: List of logical constants that need environment resolution (e.g., "ScheduleStatus.ACTIVE" → actual system value)
- `date_fields`: Fields that support date placeholder processing (e.g., "1_2" → actual planning date)
- `time_fields`: **NEW!** Fields containing time in minutes that should be converted to display time format (e.g., 480 → "08:00" or "08:00 AM")
- `template_references`: Mapping of fields to entity names for automatic template resolution (e.g., {"shift_pattern": "shift_pattern"})
- `required_processing`: Additional processing requirements (for future enhancements)

## Available Keywords for Any Entity

Once you create the templates, these keywords become automatically available:

### Entity-Specific Keywords
- `Get {EntityName} Data` - Get data for your entity
- Example: `Get Schedule Data`, `Get Shift Data`, `Get Task Data`

### Generic Keywords
- `Get Available Entities` - List all discovered entities
- `Get Entity Templates    entity_name` - List templates for an entity
- `Get Generic Entity Data    entity_name    ...` - Fallback method for any entity

## Usage Examples [Check \web\test_data\examples\test_auto_discovery_provider.robot]

### Basic Usage
```robotframework
*** Test Cases ***
Basic Schedule Test
    ${schedule}=    Get Schedule Data
    Log    ${schedule}[start_time]    # Uses default template
```

### With Template
```robotframework
*** Test Cases ***
Weekend Schedule Test
    ${schedule}=    Get Schedule Data    template_name=weekend
    Log    ${schedule}[start_time]    # Uses weekend template
```

### With Overrides
```robotframework
*** Test Cases ***
Custom Schedule Test
    ${schedule}=    Get Schedule Data    
    ...    template_name=weekend
    ...    employee_id=12345
    ...    start_time=08:00
    ...    location=STORE_002
```

### With Test-Specific Override File
```robotframework
*** Test Cases ***
TC12345 Schedule Test
    ${schedule}=    Get Schedule Data    test_id=TC12345
    # Loads overrides from templates/schedule/overrides/TC12345.json
```

## Template References (Composition)

**NEW FEATURE!** Template references allow you to compose entities by referencing templates from other entities, eliminating data duplication and improving maintainability.

### How It Works

1. **Define reusable templates** in a base entity (e.g., `shift_pattern`):
   ```json
   // test_data/entities/shift_pattern/base_templates.json
   {
     "standard_9hr": {
       "startTime": 480,
       "duration": 540
     },
     "short_4hr": {
       "startTime": 540,
       "duration": 240
     }
   }
   ```

2. **Reference templates** from other entities using field names:
   ```json
   // test_data/entities/employee_shift_assignment/base_templates.json
   {
     "ess4_three_days": {
       "ess_user_key": "ESS4_STORE1",
       "shifts_to_add": [
         {"dayNo": "0", "shift_pattern": "standard_9hr"},
         {"dayNo": "1", "shift_pattern": "standard_9hr"},
         {"dayNo": "2", "shift_pattern": "standard_9hr"}
       ]
     }
   }
   ```

3. **Configure template references** in `entity_config.json`:
   ```json
   {
     "template_references": {
       "shift_pattern": "shift_pattern",
       "employee_assignment": "employee_shift_assignment"
     }
   }
   ```

4. **Automatic resolution** happens when you load the data:
   ```robotframework
   ${employee}=    Get Employee Shift Assignment Data    template_name=ess4_three_days
   # shift_pattern fields are automatically resolved to startTime and duration
   Log    ${employee}[shifts_to_add][0][startTime]    # 480
   Log    ${employee}[shifts_to_add][0][duration]     # 540
   ```

### Benefits

✅ **No Duplication**: Define shift patterns once, reference everywhere  
✅ **Easy Maintenance**: Update shift timing in one place  
✅ **Composability**: Build complex data from simple, reusable pieces  
✅ **Type Safety**: Template references are validated at load time  
✅ **Automatic**: Resolution happens transparently in the data provider  

### Nested Template References

Template references work at **one level deep** only (to prevent circular dependencies):

```json
// Schedule setup can reference employee assignments
{
  "3_0_sm1_store1": {
    "week_offset": "3_0",
    "employee_operations": [
      {"employee_assignment": "ess4_three_days"}  // References employee entity
    ]
  }
}

// Employee assignment references shift patterns
{
  "ess4_three_days": {
    "ess_user_key": "ESS4_STORE1",
    "shifts_to_add": [
      {"dayNo": "0", "shift_pattern": "standard_9hr"}  // References shift_pattern entity
    ]
  }
}
```

Both levels are resolved automatically when you load the schedule setup data.

### Examples

See [test_template_references.robot](../tests/web/examples/test_template_references.robot) for complete examples.

## Advanced Features

### Test-Specific Override Files

Create override files for specific test cases:
```
templates/schedule/overrides/TC12345.json
```
```json
{
  "employee_id": "EMP001",
  "start_time": "07:00",
  "special_notes": "Early shift for Black Friday"
}
```

### Environment-Specific Values

The system automatically resolves logical constants:
- `"ScheduleStatus.ACTIVE"` → Environment-specific value (e.g., "A", "ACTIVE", "1")
- `"TaskName.CASHIER"` → Environment-specific task ID

### Date Processing

The date_fields if included will evaluate the date specified in week_day_offset format to an actual date (%Y-%m-%d).Check details for week_day offset notation below.

**week_day offset notation** (e.g., '1_4') to represent dates relative to the current week start.
    Here, first number is the week offset (0=current week, 1=next week, -1=previous week) and second number is the day of the week
    (0=first day of week, 6=7th day of week).
    - 1_4 means next week ahead, 5th day of that week.
    - 1_6 means next week, 7th (last) day of that week.
    - 0_0 means current week, first day of the week.
    - -1_3 means previous week, 4th day of that week.
    - -1_0 means previous week, first day of that week.

    Note the first day of week is determined by the FISCAL_WEEK_START_DAY setting in config.json where values can be 1 to 7, 1=Sunday, 2=Monday, ..., 7=Saturday.

#### Custom date format support in templates
Custom date formats is now supported using the field "_date_format" in your template. We recommend using test case override to pass this format so that its specific to your test case & not hard coded in the base template. For example:
```robotframework
*** Test Cases ***
TC12345 Schedule Test
    ${schedule}=    Get Schedule Data    template_name=custom  _date_format=%d-%Y
    ${rta_date_format}    Get Config Value    RTA_DATE_FORMAT
    ${payroll_data}    Get Payroll Data    _date_format=${rta_date_format}
```
The above example will format all date fields in the schedule and payroll entities to the specified formats provieded the date fields are included in the entity_config.json file for those entities.


### Time Processing

**NEW FEATURE!** The data provider now supports automatic conversion of time fields from minutes to display time format.

#### How It Works

1. **Store time in minutes** in your templates (e.g., 480 for 8:00 AM, 1020 for 5:00 PM)
2. **Configure time_fields** in entity_config.json to specify which fields should be converted
3. **Display format is determined** by the `TIME_FORMAT_12_HRS` config setting in your environment's config.json

#### Configuration

In your `entity_config.json`:
```json
{
  "time_fields": ["startTime", "endTime"],
  "description": "Fields in minutes that should be converted to display time"
}
```

In your environment's `config.json`:
```json
{
  "TIME_FORMAT_12_HRS": true  // or false for 24-hour format
}
```

#### Conversion Examples

**24-Hour Format** (TIME_FORMAT_12_HRS=false):
- 0 minutes → "00:00"
- 480 minutes → "08:00"
- 540 minutes → "09:00"
- 720 minutes → "12:00"
- 1020 minutes → "17:00"
- 1440 minutes → "24:00"

**12-Hour Format** (TIME_FORMAT_12_HRS=true):
- 0 minutes → "12:00 AM"
- 480 minutes → "08:00 AM"
- 540 minutes → "09:00 AM"
- 720 minutes → "12:00 PM"
- 1020 minutes → "05:00 PM"
- 1440 minutes → "12:00 AM"

#### Template Example

```json
// test_data/entities/shift_time_pattern/base_templates.json
{
  "standard_8hr": {
    "startTime": 480,    // Will be converted to "08:00" or "08:00 AM"
    "duration": 480,     // Will NOT be converted (not in time_fields)
    "description": "8:00 AM - 4:00 PM"
  },
  "standard_9hr": {
    "startTime": 480,    // Will be converted to "08:00" or "08:00 AM"
    "duration": 540,     // Will NOT be converted (not in time_fields)
    "description": "8:00 AM - 5:00 PM"
  }
}
```

#### Important Notes

1. **Only specified fields are converted**: Fields listed in `time_fields` of entity_config.json
2. **Duration fields stay as integers**: Only fields representing time-of-day should be in time_fields
3. **Works with nested structures**: Time conversion happens recursively in lists and dicts
4. **Happens after template resolution**: References are resolved first, then time conversion applies

#### Usage Example

```robotframework
*** Settings ***
Library     /test_data/TestDataLibrary.py

*** Test Cases ***
Create Shift Pattern Test
    ${shift_pattern}=    Get Shift Time Pattern Data    template_name=standard_8hr
    # startTime will be "08:00" or "08:00 AM" based on config
    # duration will remain as 480 (minutes)
    Log    Start Time: ${shift_pattern}[startTime]
    Log    Duration Minutes: ${shift_pattern}[duration]
```


## Migration from Old System

### Old Way (Required Code)
1. Create `schedule_provider.py`
2. Extend `BaseDataProvider`
3. Implement `get_schedule_data()` method
4. Add to `PROVIDER_MAPPING`
5. Update `TestDataLibrary.py`

### New Way (No Code!)
1. Create `templates/schedule/base_templates.json`
2. Add optional `entity_config.json`
3. Use `Get Schedule Data` keyword

## Benefits

### For Testers
- **Zero coding required** - Just JSON files
- **Immediate availability** - Keywords auto-generated
- **Consistent interface** - All entities work the same way
- **Easy maintenance** - Change templates, not code

### For Developers
- **No boilerplate code** - No more provider classes
- **Automatic discovery** - System finds new entities
- **Consistent behavior** - All entities follow same patterns
- **Easy to extend** - Add new features once, all entities benefit

## Entity Examples

### Shift Entity
```json
// templates/shift/base_templates.json
{
  "default": {
    "start_time": "08:00",
    "end_time": "17:00",
    "task_name": "TaskName.CASHIER",
    "status": "ShiftStatus.SCHEDULED"
  }
}
```

### Task Entity
```json
// templates/task/base_templates.json
{
  "default": {
    "name": "TaskName.FLOOR_ASSOCIATE",
    "priority": "TaskPriority.NORMAL",
    "estimated_duration": 60,
    "status": "TaskStatus.PENDING"
  }
}
```

### Employee Entity
```json
// templates/employee/base_templates.json
{
  "default": {
    "role": "EmployeeRole.ASSOCIATE", 
    "status": "EmployeeStatus.ACTIVE",
    "hire_date": "1_0",
    "location": "STORE_001"
  }
}
```
### When to Use Each Approach

| Requirement | Use Simplified Approach | Use Custom Provider |
|-------------|------------------------|-------------------|
| Simple test data | ✅ Yes | ❌ Overkill |
| Complex business logic | ❌ Limited | ✅ Yes |
| Non-technical users | ✅ Perfect | ❌ Too complex |
| Rapid prototyping | ✅ Instant | ❌ Time-consuming |
| Advanced processing | ❌ Basic only | ✅ Full control |

**Recommendation:** Start with the simplified approach. Migrate to custom providers only if you need complex business logic that can't be handled by templates and configuration

## Troubleshooting

### Entity Not Found
- Ensure `base_templates.json` exists in correct folder
- Check folder name matches entity name
- Verify JSON syntax is valid

### Constant Not Resolved
- Add constant class to `entity_config.json`
- Check environment configuration has the constant defined
- Verify constant format: `"ClassName.CONSTANT_NAME"`

### Date Not Processed
- Add field name to `date_fields` in `entity_config.json`
- Use supported date format: `"week_day"` (e.g., "1_2")

## Best Practices

1. **Use descriptive template names** - `morning_shift`, `weekend_schedule`
2. **Keep templates simple** - Complex logic belongs in test code
3. **Use logical constants** - Don't hard-code environment values
4. **Document your templates** - Add comments in config files
5. **Group related entities** - Consider entity relationships
6. **Test your templates** - Verify keywords work as expected

This simplified approach makes test data management accessible to all team members while maintaining the flexibility and power of the original system.
