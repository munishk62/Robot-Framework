# Config Tag Usage Guide

## ✅ QUICK ANSWERS TO YOUR QUESTIONS

### Q: Is `config:rws_legacy_forecasting:Y` valid?
**Answer: YES** ✅ This is **Format #2** (config:KEY:VALUE)
- Checks if `rws_legacy_forecasting` key in config.json equals `"Y"`
- Test runs ONLY if that exact key-value pair exists

### Q: Is `config_or:ess` valid?
**Answer: YES** ✅ This is **Format #3** (config_or:name)
- Checks if `"ess"` exists in the `enabled_configs` array
- When combined with other `config_or:` tags, uses OR logic (at least one must match)

---

# Config Tag Usage Guide

## Overview
The ConfigFilter supports both AND and OR logic for configuration-based test filtering.

## Tag Formats

### 1. Boolean Check (AND logic)
```robot
[Tags]    config:rta    config:ess
```
- Checks if 'rta' AND 'ess' are both in the `enabled_configs` array
- Test runs only if ALL conditions match

### 2. Value Check (AND logic)
```robot
[Tags]    config:USE_LEAVE_HRS_IN_TA:N    config:MYWORK:false
```
- Checks if config value equals the specified value
- Test runs only if ALL conditions match

### 3. OR Logic with Boolean Check
```robot
[Tags]    config_or:rta    config_or:ess
```
- Checks if EITHER 'rta' OR 'ess' is in enabled_configs
- Test runs if AT LEAST ONE condition matches

### 4. OR Logic with Value Check
```robot
[Tags]    config_or:USE_LEAVE_HRS_IN_TA:N    config_or:MYWORK:true
```
- Checks if USE_LEAVE_HRS_IN_TA=N OR MYWORK=true
- Test runs if AT LEAST ONE condition matches

### 5. Combined AND + OR Logic
```robot
[Tags]    config:rta    config_or:direct_login    config_or:mywork
```
- Requires: rta is enabled AND (direct_login OR mywork)
- AND conditions must ALL match
- At least ONE OR condition must match

## Examples for Your Use Cases

### Example 1: Run test if direct_login OR DIRECT_LOGIN is True
```robot
Test Tags    config_or:direct_login    config_or:DIRECT_LOGIN:True    config_or:DIRECT_LOGIN:true
```

### Example 2: Run test only when USE_LEAVE_HRS_IN_TA is N
```robot
[Tags]    config:USE_LEAVE_HRS_IN_TA:N
```

### Example 3: Run test when USE_LEAVE_HRS_IN_TA is N OR Y (always run)
```robot
[Tags]    config_or:USE_LEAVE_HRS_IN_TA:N    config_or:USE_LEAVE_HRS_IN_TA:Y
```

### Example 4: Run test if rta is enabled AND direct_login is True
```robot
[Tags]    config:rta    config:DIRECT_LOGIN:True
```

## Logging
The ConfigFilter logs detailed information about why tests are skipped:

**AND condition failure:**
```
PRE-RUN: Skipping test case 'Test Name' because AND config 'rta' is not enabled
```

**OR condition failure:**
```
PRE-RUN: Skipping test case 'Test Name' because NONE of the OR conditions matched: ['direct_login', 'DIRECT_LOGIN:True']
```

**OR condition success:**
```
PRE-RUN: Test 'Test Name' OR condition matched: config_or:direct_login
```

## Best Practices

1. **Use AND for strict requirements:**
   ```robot
   [Tags]    config:rta    config:ess
   ```

2. **Use OR for flexible alternatives:**
   ```robot
   [Tags]    config_or:direct_login    config_or:DIRECT_LOGIN:True
   ```

3. **Combine both for complex logic:**
   ```robot
   [Tags]    config:rta    config_or:env1    config_or:env2
   ```
   Means: "Requires rta AND runs on (env1 OR env2)"

4. **For value-based checks, use exact string matching:**
   - Config values are compared as strings
   - "True" ≠ "true" ≠ true (JSON boolean)
   - Use both if uncertain: `config_or:MYWORK:True    config_or:MYWORK:true`

