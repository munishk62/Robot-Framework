# Config Rules Metadata Reference

The `enabled_config_rules` section in `metadata.yaml` allows you to derive feature flags (e.g., `rta`, `legacy_forecasting`) based on the data fetched from databases or APIs by the `env_config_sync` utility. The utility evaluates these rules against the cached data snapshots to populated the `enabled_configs` list in `config.json`.
Refer [Cached Query Block](ENV_CONFIG_SYNC_README.md#cache-query-block) for details on how data is fetched and cached.

## Base Rule Structure

Every rule requires a `key` (the resulting tag name) and a definition of where and how to look for data.
Each rule requires
- key: The name of the feature flag to add to `enabled_configs` if the rule evaluates to true.
- source: Where to look for the data (usually `cache`).
- cache_key: The key under which the data was cached in previous steps.
- path: (optional) A list of keys to traverse the cached data structure to reach the target value.
- condition: The logic to evaluate against the extracted value.

```yaml
- key: MyEnabledFeature           # The string added to enabled_configs if true
  description: "Enables X feature based on Y setting" # Optional human-readable description
  source: cache                   # Usually 'cache' to read fetched data
  cache_key: my_cached_data       # The key where the data was stored in previous steps. Refer the cache_key in Cached Query Block.
  path:                           # Optional: Path to traverse to specific value. This is json path traversal starting from root of cached object.
    - ROOT_KEY
    - CHILD_KEY
  transform: none                 # Optional: string, integer, boolean, etc.
  condition:                      # The logic to evaluate
    type: equals
    value: "SomeValue"
```
## Understanding JSON Path Traversal
When a rule specifies a `path`, the utility traverses the cached data structure (which can be nested dictionaries and lists) according to the keys in the `path` list. Each key in the path corresponds to a level in the JSON structure. For example, given the following JSON data:
```json 
{
  "sys_config": {
    "modules": {
      "scheduler": {
        "status": "active"
      }
    }
  }
}
``` 
A path of `["sys_config", "modules", "scheduler", "status"]` would navigate through the JSON to retrieve the value `"active"`.
A path of `["sys_config", "modules"]` would retrieve the nested object:
```json
{
  "scheduler": {
    "status": "active"
  }
}
```
Your conditions will then evaluate against the final value obtained after traversing the path.

## Scenarios & Examples

### 1. Simple Key-Value Map Comparison
**Scenario:** You fetched a key-value map (e.g., global settings) cached under `product_features`. You want to enable a feature if a specific key equals a specific value.

**JSON Data (`cache_key: product_features`):**
```json
{
  "RTA_INTEGRATION": "Y",
  "FORECASTING_MODEL": "LEGACY",
  "TIMEOUT_MS": 5000
}
```

**Metadata Rule:**
```yaml
- key: rta_enabled
  source: cache
  cache_key: product_features
  path:
    - RTA_INTEGRATION
  condition:
    type: equals
    value: Y
```
If the conditions is met, `rta_enabled` will be added to `enabled_configs`.

### 2. Nested Data Access
**Scenario:** The data structure is deep (e.g., API response). You need to drill down to find the value.

**JSON Data (`cache_key: app_config`):**
```json
{
  "sys_config": {
    "modules": {
      "scheduler": {
        "status": "active"
      }
    }
  }
}
```

**Metadata Rule:**
```yaml
- key: scheduler_active
  source: cache
  cache_key: app_config
  path:
    - sys_config
    - modules
    - scheduler
    - status
  condition:
    type: equals
    value: active
```
if the condition is met, `scheduler_active` will be added to `enabled_configs`.

### 3. Permissions/List of Objects (`list_match`)
**Scenario:** Commonly used for verifying permissions. The data is a list of objects, and you need to check if *at least one* object in that list matches a set of criteria.

**JSON Data (`cache_key: profile_permissions`):**
```json
[
  { "id": "EDIT_USER", "access": "enable", "scope": "global" },
  { "id": "DELETE_USER", "access": "disable", "scope": "local" }
]
```

**Metadata Rule:**
```yaml
- key: can_edit_user
  source: cache
  cache_key: profile_permissions
  # No path needed if the root object is the list
  condition:
    type: list_match
    match:
      id: EDIT_USER
      access: enable
```
*Logic: Iterates through the list. Variable `can_edit_user` is enabled if ANY item in the list has BOTH `id=EDIT_USER` AND `access=enable`.*
In case the list is nested under a key, use `path` to navigate to it first -> e.g.
```json
{
"ADMIN_PROFILE":
                [
                    { "id": "EDIT_USER", "access": "enable", "scope": "global" },
                    { "id": "DELETE_USER", "access": "disable", "scope": "local" }
                ],
"EMPLOYEE_PROFILE":
                [
                    { "id": "VIEW_SCHEDULE", "access": "enable", "scope": "self" }
                ]
}
```

**Metadata Rule:**
```yaml
- key: can_edit_user_admin
  source: cache
  cache_key: profile_permissions
  path:
    - ADMIN_PROFILE
  condition:
    type: list_match
    match:
      id: EDIT_USER
      access: enable
```


### 4. Searching a List of Values (`contains`)
**Scenario:** The data is a simple list of strings or numbers (e.g., list of installed product codes).

**JSON Data (`cache_key: installed_products`):**
```json
["WFM", "RTA", "Analytics"]
```

**Metadata Rule:**
```yaml
- key: has_analytics
  source: cache
  cache_key: installed_products
  condition:
    type: contains
    value: Analytics
```

### 5. Truthy/Boolean Logic
**Scenario:** The value might be varying representations of "True" (e.g., "Y", "Yes", "1", "True", "true"). Use the `truthy` type to handle these loosely.

**JSON Data (`cache_key: flags`):**
```json
{
  "is_beta_user": "yes",
  "is_admin": "0"
}
```

**Metadata Rule:**
```yaml
- key: beta_mode
  source: cache
  cache_key: flags
  path:
    - is_beta_user
  condition:
    type: truthy
```
*Note: Strings "false", "0", "n", "no", and "" (empty) are considered False. Everything else is True.*

### 6. Compound Conditions (`all` / `any`)
**Scenario:** You need to check multiple conditions. For example, a user must have two specific permissions to enable a feature.

**JSON Data (`cache_key: user_perms`):**
```json
{
  "role": "manager",
  "permissions": [
    { "code": "APPROVE", "state": "ON" },
    { "code": "REJECT", "state": "ON" }
  ]
}
```

**Metadata Rule:**
```yaml
- key: approval_workflow
  source: cache
  cache_key: user_perms
  condition:
    type: all    # Can also be 'any'
    conditions:
      # Condition 1: Check role
      - path:
          - role
        condition:
          type: equals
          value: manager
      
      # Condition 2: Check for APPROVE permission
      - path:
          - permissions
        condition:
          type: list_match
          match:
            code: APPROVE
            state: ON
```

## Transforms

Sometimes data types fetched from DB/API don't match the rule's expected type (e.g., "100" string vs 100 integer). Use `transform` before evaluation.

| Transform | Description |
|-----------|-------------|
| `boolean` | Converts "true", "t", "1", "y", "yes" (case-insensitive) to Python `True`. |
| `negate_boolean` | Inverse of boolean. |
| `integer` | Parses string to int. |
| `string` | Converts keys/values to string. |
| `json` | Parses a JSON string inside a value into a dictionary/list. |

**Example:**
```yaml
- key: high_limit
  # ...
  path: 
    - threshold
  transform: integer   # Converts "500" string to 500 int
  condition: 
    type: equals
    value: 500
```
